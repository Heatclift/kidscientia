package com.difrancescogianmarco.arcore_flutter_plugin

import android.app.Activity
import android.app.Application
import android.content.Context
import android.graphics.BitmapFactory
import android.os.Bundle
import android.os.Handler
import android.os.Looper
import android.util.Log
import android.view.GestureDetector
import android.view.MotionEvent
import android.view.SurfaceHolder
import android.view.SurfaceView
import android.view.View
import android.widget.Toast
import com.difrancescogianmarco.arcore_flutter_plugin.flutter_models.FlutterArCoreHitTestResult
import com.difrancescogianmarco.arcore_flutter_plugin.flutter_models.FlutterArCoreNode
import com.difrancescogianmarco.arcore_flutter_plugin.flutter_models.FlutterArCorePose
import com.difrancescogianmarco.arcore_flutter_plugin.models.RotatingNode
import com.difrancescogianmarco.arcore_flutter_plugin.utils.ArCoreUtils
import com.google.ar.core.*
import com.google.ar.core.exceptions.CameraNotAvailableException
import com.google.ar.core.exceptions.FatalException
import com.google.ar.core.exceptions.MissingGlContextException
import com.google.ar.core.exceptions.UnavailableException
import com.google.ar.core.exceptions.UnavailableUserDeclinedInstallationException
import com.google.ar.sceneform.*
import com.google.ar.sceneform.rendering.ModelRenderable
import com.google.ar.sceneform.rendering.Texture
import com.google.ar.sceneform.ux.AugmentedFaceNode
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.platform.PlatformView

import android.graphics.Bitmap
import android.os.Environment
import android.view.PixelCopy
import android.os.HandlerThread
import java.io.FileOutputStream
import java.io.File
import java.io.IOException
import com.google.ar.sceneform.SceneView

class ArCoreView(val activity: Activity, context: Context, messenger: BinaryMessenger, id: Int, private val isAugmentedFaces: Boolean, private val debug: Boolean) : PlatformView, MethodChannel.MethodCallHandler {
    private val methodChannel: MethodChannel = MethodChannel(messenger, "arcore_flutter_plugin_$id")
    private val utilsChannel: MethodChannel = MethodChannel(messenger, "arcore_flutter_plugin/utils")
    //       private val activity: Activity = (context.applicationContext as FlutterApplication).currentActivity
    lateinit var activityLifecycleCallbacks: Application.ActivityLifecycleCallbacks
    private var installRequested: Boolean = false
    private var mUserRequestedInstall = true
    private val TAG: String = ArCoreView::class.java.name
    private var arSceneView: SafeArSceneView? = null
    // Kept for Flutter's PlatformView detach after onDestroy() nulls arSceneView.
    private val platformView: View
    private val gestureDetector: GestureDetector
    private val RC_PERMISSIONS = 0x123
    private var sceneUpdateListener: Scene.OnUpdateListener
    private var faceSceneUpdateListener: Scene.OnUpdateListener
    private var isDisposed = false
    private var lifecycleRegistered = false
    private var surfaceReady = false
    private var isRendererRunning = false
    private var isResumeInFlight = false
    private var arReadyNotified = false
    private val mainHandler = Handler(Looper.getMainLooper())
    private var resumeRetryRunnable: Runnable? = null
    private var surfaceCallback: SurfaceHolder.Callback? = null

    //AUGMENTEDFACE
    private var faceRegionsRenderable: ModelRenderable? = null
    private var faceMeshTexture: Texture? = null
    private val faceNodeMap = HashMap<AugmentedFace, AugmentedFaceNode>()

    companion object {
        private const val ENGINE_SETTLE_MS = 1000L

        /** True while Filament/ARCore is destroying or settling after destroy. */
        @Volatile
        var isEngineBusy: Boolean = false
            private set

        @Volatile
        private var activeView: ArCoreView? = null

        private var previousUncaughtHandler: Thread.UncaughtExceptionHandler? = null
        private var glExceptionHandler: Thread.UncaughtExceptionHandler? = null

        fun markEngineBusy() {
            isEngineBusy = true
        }

        fun markEngineIdle() {
            isEngineBusy = false
        }

        /**
         * Sceneform can throw MissingGlContextException on the Choreographer thread
         * outside our resume try/catch. Flutter often re-installs its kill-process
         * handler after ours, so we re-wrap whenever we are not already outermost.
         */
        fun ensureGlExceptionHandler() {
            val current = Thread.getDefaultUncaughtExceptionHandler()
            if (current != null && current === glExceptionHandler) {
                return
            }
            previousUncaughtHandler = current
            val handler = Thread.UncaughtExceptionHandler { thread, throwable ->
                if (isMissingGlContext(throwable)) {
                    Log.e("ArCoreView", "Caught MissingGlContextException; recovering AR", throwable)
                    activeView?.handleMissingGlContext()
                    // Do not forward to Flutter/Android — they kill the process.
                    return@UncaughtExceptionHandler
                }
                previousUncaughtHandler?.uncaughtException(thread, throwable)
            }
            glExceptionHandler = handler
            Thread.setDefaultUncaughtExceptionHandler(handler)
        }

        private fun isMissingGlContext(throwable: Throwable?): Boolean {
            var t = throwable
            while (t != null) {
                if (t is MissingGlContextException) return true
                val message = t.message.orEmpty()
                if (message.contains("MISSING_GL_CONTEXT") ||
                    message.contains("MissingGlContextException")
                ) {
                    return true
                }
                t = t.cause
            }
            return false
        }
    }

    init {
        // Block construction until any prior Sceneform teardown has settled.
        // This runs on the platform-view create path; Dart also waits on ArSessionGate.
        var spins = 0
        while (isEngineBusy && spins < 50) {
            try {
                Thread.sleep(100)
            } catch (ignored: InterruptedException) {
            }
            spins++
        }

        ensureGlExceptionHandler()
        activeView = this
        methodChannel.setMethodCallHandler(this)
        arSceneView = SafeArSceneView(context).also { view ->
            view.onMissingGlContext = { handleMissingGlContext() }
            view.onFirstSuccessfulFrame = { notifyArReady() }
        }
        platformView = arSceneView as View
        bindSurfaceLifecycle(arSceneView as SurfaceView)
        // Set up a tap gesture detector.
        gestureDetector = GestureDetector(
                context,
                object : GestureDetector.SimpleOnGestureListener() {
                    override fun onSingleTapUp(e: MotionEvent): Boolean {
                        onSingleTap(e)
                        return true
                    }

                    override fun onDown(e: MotionEvent): Boolean {
                        return true
                    }
                })

        sceneUpdateListener = Scene.OnUpdateListener { frameTime ->

            val frame = arSceneView?.arFrame ?: return@OnUpdateListener

            if (frame.camera.trackingState != TrackingState.TRACKING) {
                return@OnUpdateListener
            }

            for (plane in frame.getUpdatedTrackables(Plane::class.java)) {
                if (plane.trackingState == TrackingState.TRACKING) {

                    val pose = plane.centerPose
                    val map: HashMap<String, Any> = HashMap<String, Any>()
                    map["type"] = plane.type.ordinal
                    map["centerPose"] = FlutterArCorePose(pose.translation, pose.rotationQuaternion).toHashMap()
                    map["extentX"] = plane.extentX
                    map["extentZ"] = plane.extentZ

                    methodChannel.invokeMethod("onPlaneDetected", map)
                }
            }
        }

        faceSceneUpdateListener = Scene.OnUpdateListener { frameTime ->
            run {
                //                if (faceRegionsRenderable == null || faceMeshTexture == null) {
                if (faceMeshTexture == null) {
                    return@OnUpdateListener
                }

                val faceList = arSceneView?.session?.getAllTrackables(AugmentedFace::class.java)

                faceList?.let {
                    // Make new AugmentedFaceNodes for any new faces.
                    for (face in faceList) {
                        if (!faceNodeMap.containsKey(face)) {
                            val faceNode = AugmentedFaceNode(face)
                            faceNode.setParent(arSceneView?.scene)
                            faceNode.faceRegionsRenderable = faceRegionsRenderable
                            faceNode.faceMeshTexture = faceMeshTexture
                            faceNodeMap[face] = faceNode
                        }
                    }

                    // Remove any AugmentedFaceNodes associated with an AugmentedFace that stopped tracking.
                    val iter = faceNodeMap.iterator()
                    while (iter.hasNext()) {
                        val entry = iter.next()
                        val face = entry.key
                        if (face.trackingState == TrackingState.STOPPED) {
                            val faceNode = entry.value
                            faceNode.setParent(null)
                            iter.remove()
                        }
                    }
                }
            }
        }

        // Lastly request CAMERA permission which is required by ARCore.
        ArCoreUtils.requestCameraPermission(activity, RC_PERMISSIONS)
        setupLifeCycle(context)
    }

    /**
     * ARCore requires a current GL context during Session.update(). With Flutter
     * Hybrid Composition the SurfaceView can frame before EGL is ready
     * (MissingGlContextException), especially on the second AR open.
     * Resume only after surfaceChanged with a non-zero size.
     */
    private fun bindSurfaceLifecycle(surfaceView: SurfaceView) {
        val callback = object : SurfaceHolder.Callback {
            override fun surfaceCreated(holder: SurfaceHolder) {
                debugLog("AR surface created (waiting for size)")
            }

            override fun surfaceChanged(holder: SurfaceHolder, format: Int, width: Int, height: Int) {
                val ready = width > 0 && height > 0 && holder.surface?.isValid == true
                surfaceReady = ready
                debugLog("AR surface changed ${width}x${height} ready=$ready")
                if (ready && !isDisposed) {
                    ensureGlExceptionHandler()
                    surfaceView.post { if (!isDisposed && surfaceReady) onResume() }
                }
            }

            override fun surfaceDestroyed(holder: SurfaceHolder) {
                surfaceReady = false
                isRendererRunning = false
                isResumeInFlight = false
                arReadyNotified = false
                debugLog("AR surface destroyed — pausing session")
                try {
                    arSceneView?.pause()
                } catch (ignored: Exception) {
                }
            }
        }
        surfaceCallback = callback
        surfaceView.holder.addCallback(callback)
        // Surface may already be sized when re-attached.
        val w = surfaceView.width
        val h = surfaceView.height
        if (surfaceView.holder.surface?.isValid == true && w > 0 && h > 0) {
            surfaceReady = true
            ensureGlExceptionHandler()
            surfaceView.post { if (!isDisposed && surfaceReady) onResume() }
        }
    }

    private fun notifyArReady() {
        if (isDisposed || arReadyNotified) return
        arReadyNotified = true
        try {
            methodChannel.invokeMethod("onArReady", null)
        } catch (ignored: Exception) {
        }
    }

    /**
     * Called only after SafeArSceneView has skipped many frames without EGL.
     * Do not pause/resume-loop here — that caused the black screen.
     */
    private fun handleMissingGlContext() {
        if (isDisposed) return
        isRendererRunning = false
        isResumeInFlight = false
        mainHandler.post {
            if (isDisposed) return@post
            try {
                methodChannel.invokeMethod(
                    "onError",
                    "AR OpenGL context was lost. Go back and try again."
                )
            } catch (ignored: Exception) {
            }
        }
    }

    fun debugLog(message: String) {
        if (debug) {
            Log.i(TAG, message)
        }
    }


    fun loadMesh(textureBytes: ByteArray?) {
        // Load the face regions renderable.
        // This is a skinned model that renders 3D objects mapped to the regions of the augmented face.
        /*ModelRenderable.builder()
                .setSource(activity, Uri.parse("fox_face.sfb"))
                .build()
                .thenAccept { modelRenderable ->
                    faceRegionsRenderable = modelRenderable;
                    modelRenderable.isShadowCaster = false;
                    modelRenderable.isShadowReceiver = false;
                }*/

        // Load the face mesh texture.
        //                .setSource(activity, Uri.parse("fox_face_mesh_texture.png"))
        Texture.builder()
                .setSource(BitmapFactory.decodeByteArray(textureBytes, 0, textureBytes!!.size))
                .build()
                .thenAccept { texture -> faceMeshTexture = texture }
    }


    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        if (isDisposed && call.method != "dispose") {
            result.success(null)
            return
        }

        when (call.method) {
            "init" -> {
                arScenViewInit(call, result, activity)
            }
            "addArCoreNode" -> {
                debugLog(" addArCoreNode")
                val map = call.arguments as HashMap<String, Any>
                val flutterNode = FlutterArCoreNode(map);
                onAddNode(flutterNode, result)
            }
            "addArCoreNodeWithAnchor" -> {
                debugLog(" addArCoreNode")
                val map = call.arguments as HashMap<String, Any>
                val flutterNode = FlutterArCoreNode(map)
                addNodeWithAnchor(flutterNode, result)
            }
            "removeARCoreNode" -> {
                debugLog(" removeARCoreNode")
                val map = call.arguments as HashMap<String, Any>
                removeNode(map["nodeName"] as String, result)
            }
            "positionChanged" -> {
                debugLog(" positionChanged")

            }
            "rotationChanged" -> {
                debugLog(" rotationChanged")
                updateRotation(call, result)

            }
            "updateMaterials" -> {
                debugLog(" updateMaterials")
                updateMaterials(call, result)

            }
            "takeScreenshot" -> {
                debugLog(" takeScreenshot")
                takeScreenshot(call, result)

            }
            "loadMesh" -> {
                val map = call.arguments as HashMap<String, Any>
                val textureBytes = map["textureBytes"] as ByteArray
                loadMesh(textureBytes)
            }
            "dispose" -> {
                debugLog("Soft-disposing ARCore (pause only)")
                // Pause now; PlatformView.dispose() destroys after Flutter detaches the view.
                softTeardown()
                result.success(null)
            }
            "resume" -> {
                debugLog("Resuming ARCore now")
                onResume()
            }
            "getTrackingState" -> {
                debugLog("1/3: Requested tracking state, returning that back to Flutter now")

                val trState = arSceneView?.arFrame?.camera?.trackingState
                debugLog("2/3: Tracking state is " + trState.toString())
                methodChannel.invokeMethod("getTrackingState", trState.toString())
            }
            "togglePlaneRenderer" -> {
                debugLog(" Toggle planeRenderer visibility" )
                arSceneView!!.planeRenderer.isVisible = !arSceneView!!.planeRenderer.isVisible
            }
            else -> {
            }
        }
    }

/*    fun maybeEnableArButton() {
        Log.i(TAG,"maybeEnableArButton" )
        try{
            val availability = ArCoreApk.getInstance().checkAvailability(activity.applicationContext)
            if (availability.isTransient) {
                // Re-query at 5Hz while compatibility is checked in the background.
                Handler().postDelayed({ maybeEnableArButton() }, 200)
            }
            if (availability.isSupported) {
                debugLog("AR SUPPORTED")
            } else { // Unsupported or unknown.
                debugLog("AR NOT SUPPORTED")
            }
        }catch (ex:Exception){
            Log.i(TAG,"maybeEnableArButton ${ex.localizedMessage}" )
        }

    }*/

    private fun setupLifeCycle(context: Context) {
        activityLifecycleCallbacks = object : Application.ActivityLifecycleCallbacks {
            override fun onActivityCreated(activity: Activity, savedInstanceState: Bundle?) {
                debugLog("onActivityCreated")
//                maybeEnableArButton()
            }

            override fun onActivityStarted(activity: Activity) {
                debugLog("onActivityStarted")
            }

            override fun onActivityResumed(activity: Activity) {
                debugLog("onActivityResumed")
                onResume()
            }

            override fun onActivityPaused(activity: Activity) {
                debugLog("onActivityPaused")
                onPause()
            }

            override fun onActivityStopped(activity: Activity) {
                debugLog("onActivityStopped (Just so you know)")
//                onPause()
            }

            override fun onActivitySaveInstanceState(activity: Activity, outState: Bundle) {}

            override fun onActivityDestroyed(activity: Activity) {
                debugLog("onActivityDestroyed (Just so you know)")
//                onDestroy()
//                dispose()
            }
        }

        activity.application.registerActivityLifecycleCallbacks(this.activityLifecycleCallbacks)
        lifecycleRegistered = true
    }

    private fun onSingleTap(tap: MotionEvent?) {
        debugLog(" onSingleTap")
        val frame = arSceneView?.arFrame
        if (frame != null) {
            if (tap != null && frame.camera.trackingState == TrackingState.TRACKING) {
                val hitList = frame.hitTest(tap)
                val list = ArrayList<HashMap<String, Any>>()
                for (hit in hitList) {
                    val trackable = hit.trackable
                    if (trackable is Plane && trackable.isPoseInPolygon(hit.hitPose)) {
                        hit.hitPose
                        val distance: Float = hit.distance
                        val translation = hit.hitPose.translation
                        val rotation = hit.hitPose.rotationQuaternion
                        val flutterArCoreHitTestResult = FlutterArCoreHitTestResult(distance, translation, rotation)
                        val arguments = flutterArCoreHitTestResult.toHashMap()
                        list.add(arguments)
                    }
                }
                methodChannel.invokeMethod("onPlaneTap", list)
            }
        }
    }

    private fun takeScreenshot(call: MethodCall, result: MethodChannel.Result) {
        try {
            // create bitmap screen capture

            // Create a bitmap the size of the scene view.
            val bitmap: Bitmap = Bitmap.createBitmap(arSceneView!!.getWidth(), arSceneView!!.getHeight(),
                    Bitmap.Config.ARGB_8888)

            // Create a handler thread to offload the processing of the image.
            val handlerThread = HandlerThread("PixelCopier")
            handlerThread.start()
            // Make the request to copy.
            // Make the request to copy.
            PixelCopy.request(arSceneView!!, bitmap, { copyResult ->
                if (copyResult === PixelCopy.SUCCESS) {
                    try {
                        saveBitmapToDisk(bitmap)
                    } catch (e: IOException) {
                        e.printStackTrace();
                    }
                }
                handlerThread.quitSafely()
            }, Handler(handlerThread.getLooper()))

        } catch (e: Throwable) {
            // Several error may come out with file handling or DOM
            e.printStackTrace()
        }
        result.success(null)
    }

    @Throws(IOException::class)
    fun saveBitmapToDisk(bitmap: Bitmap):String {

//        val now = LocalDateTime.now()
//        now.format(DateTimeFormatter.ofPattern("M/d/y H:m:ss"))
        val now = "rawScreenshot"
        // android/data/com.hswo.mvc_2021.hswo_mvc_2021_flutter_ar/files/
        // activity.applicationContext.getFilesDir().toString() //doesnt work!!
        // Environment.getExternalStorageDirectory()
        val mPath: String =  Environment.getExternalStorageDirectory().toString() + "/DCIM/" + now + ".jpg"
        val mediaFile = File(mPath)
        debugLog(mediaFile.toString())
        //Log.i("path","fileoutputstream opened")
        //Log.i("path",mPath)
        val fileOutputStream = FileOutputStream(mediaFile)
        bitmap.compress(Bitmap.CompressFormat.JPEG, 100, fileOutputStream)
        fileOutputStream.flush()
        fileOutputStream.close()
//        Log.i("path","fileoutputstream closed")
        return mPath as String
    }

    private fun arScenViewInit(call: MethodCall, result: MethodChannel.Result, context: Context) {
        debugLog("arScenViewInit")
        val enableTapRecognizer: Boolean? = call.argument("enableTapRecognizer")
        if (enableTapRecognizer != null && enableTapRecognizer) {
            arSceneView
                    ?.scene
                    ?.setOnTouchListener { hitTestResult: HitTestResult, event: MotionEvent? ->

                        if (hitTestResult.node != null) {
                            debugLog(" onNodeTap " + hitTestResult.node?.name)
                            debugLog(hitTestResult.node?.localPosition.toString())
                            debugLog(hitTestResult.node?.worldPosition.toString())
                            methodChannel.invokeMethod("onNodeTap", hitTestResult.node?.name)
                            return@setOnTouchListener true
                        }
                        return@setOnTouchListener event != null && gestureDetector.onTouchEvent(event)
                    }
        }
        val enableUpdateListener: Boolean? = call.argument("enableUpdateListener")
        if (enableUpdateListener != null && enableUpdateListener) {
            // Set an update listener on the Scene that will hide the loading message once a Plane is
            // detected.
            arSceneView?.scene?.addOnUpdateListener(sceneUpdateListener)
        }

        val enablePlaneRenderer: Boolean? = call.argument("enablePlaneRenderer")
        if (enablePlaneRenderer != null && !enablePlaneRenderer) {
            debugLog(" The plane renderer (enablePlaneRenderer) is set to " + enablePlaneRenderer.toString())
            arSceneView!!.planeRenderer.isVisible = false
        }

        // Do not resume here — surfaceCreated (or a later lifecycle resume) owns that
        // so Session.resume is not called twice without a current GL context.
        if (surfaceReady && !isRendererRunning && !isDisposed) {
            arSceneView?.post { onResume() }
        }
        result.success(null)
    }

    fun addNodeWithAnchor(flutterArCoreNode: FlutterArCoreNode, result: MethodChannel.Result) {

        if (arSceneView == null) {
            return
        }

        RenderableCustomFactory.makeRenderable(activity.applicationContext, flutterArCoreNode) { renderable, t ->
            if (t != null) {
                result.error("Make Renderable Error", t.localizedMessage, null)
                return@makeRenderable
            }
            val myAnchor = arSceneView?.session?.createAnchor(Pose(flutterArCoreNode.getPosition(), flutterArCoreNode.getRotation()))
            if (myAnchor != null) {
                val anchorNode = AnchorNode(myAnchor)
                anchorNode.name = flutterArCoreNode.name
                anchorNode.renderable = renderable

                debugLog("addNodeWithAnchor inserted ${anchorNode.name}")
                attachNodeToParent(anchorNode, flutterArCoreNode.parentNodeName)

                for (node in flutterArCoreNode.children) {
                    node.parentNodeName = flutterArCoreNode.name
                    onAddNode(node, null)
                }
            }
            result.success(null)
        }
    }

    fun onAddNode(flutterArCoreNode: FlutterArCoreNode, result: MethodChannel.Result?) {

        debugLog(flutterArCoreNode.toString())
        NodeFactory.makeNode(activity.applicationContext, flutterArCoreNode, debug) { node, throwable ->

            debugLog("onAddNode inserted ${node?.name}")

/*            if (flutterArCoreNode.parentNodeName != null) {
                debugLog(flutterArCoreNode.parentNodeName);
                val parentNode: Node? = arSceneView?.scene?.findByName(flutterArCoreNode.parentNodeName)
                parentNode?.addChild(node)
            } else {
                debugLog("addNodeToSceneWithGeometry: NOT PARENT_NODE_NAME")
                arSceneView?.scene?.addChild(node)
            }*/
            if (node != null) {
                attachNodeToParent(node, flutterArCoreNode.parentNodeName)
                for (n in flutterArCoreNode.children) {
                    n.parentNodeName = flutterArCoreNode.name
                    onAddNode(n, null)
                }
            }

        }
        result?.success(null)
    }

    fun attachNodeToParent(node: Node?, parentNodeName: String?) {
        if (parentNodeName != null) {
            debugLog(parentNodeName);
            val parentNode: Node? = arSceneView?.scene?.findByName(parentNodeName)
            parentNode?.addChild(node)
        } else {
            debugLog("addNodeToSceneWithGeometry: NOT PARENT_NODE_NAME")
            arSceneView?.scene?.addChild(node)
        }
    }

    fun removeNode(name: String, result: MethodChannel.Result) {
        val node = arSceneView?.scene?.findByName(name)
        if (node != null) {
            arSceneView?.scene?.removeChild(node);
            debugLog("removed ${node.name}")
        }

        result.success(null)
    }

    fun updateRotation(call: MethodCall, result: MethodChannel.Result) {
        val name = call.argument<String>("name")
        val node = arSceneView?.scene?.findByName(name) as RotatingNode
        debugLog("rotating node:  $node")
        val degreesPerSecond = call.argument<Double?>("degreesPerSecond")
        debugLog("rotating value:  $degreesPerSecond")
        if (degreesPerSecond != null) {
            debugLog("rotating value:  ${node.degreesPerSecond}")
            node.degreesPerSecond = degreesPerSecond.toFloat()
        }
        result.success(null)
    }

    fun updateMaterials(call: MethodCall, result: MethodChannel.Result) {
        val name = call.argument<String>("name")
        val materials = call.argument<ArrayList<HashMap<String, *>>>("materials")!!
        val node = arSceneView?.scene?.findByName(name)
        val oldMaterial = node?.renderable?.material?.makeCopy()
        if (oldMaterial != null) {
            val material = MaterialCustomFactory.updateMaterial(oldMaterial, materials[0])
            node.renderable?.material = material
        }
        result.success(null)
    }

    override fun getView(): View {
        return platformView
    }

    /**
     * Pause and detach callbacks without destroying the Sceneform view.
     * Safe to call while the Android view is still attached (method-channel dispose).
     */
    private fun softTeardown() {
        if (isDisposed) {
            return
        }
        isDisposed = true
        isRendererRunning = false
        isResumeInFlight = false
        arReadyNotified = false

        resumeRetryRunnable?.let { mainHandler.removeCallbacks(it) }
        resumeRetryRunnable = null

        if (lifecycleRegistered) {
            try {
                activity.application.unregisterActivityLifecycleCallbacks(activityLifecycleCallbacks)
            } catch (ignored: Exception) {
            }
            lifecycleRegistered = false
        }

        try {
            methodChannel.setMethodCallHandler(null)
        } catch (ignored: Exception) {
        }

        try {
            arSceneView?.pause()
        } catch (e: Exception) {
            e.printStackTrace()
        }

        if (activeView === this) {
            activeView = null
        }
    }

    /**
     * Destroy ArSceneView. Must run after Flutter has detached the platform view.
     * Do not call Session.close() here — ArSceneView.destroy() owns that; double-close
     * corrupts ARCore/Filament and crashes the next AR session.
     *
     * [onArTeardownComplete] is delayed so Filament can finish native cleanup before
     * Dart opens another AR session.
     */
    private fun destroySceneView() {
        val sceneView = arSceneView ?: return
        arSceneView = null
        surfaceReady = false
        markEngineBusy()

        surfaceCallback?.let { callback ->
            try {
                (sceneView as? SurfaceView)?.holder?.removeCallback(callback)
            } catch (ignored: Exception) {
            }
        }
        surfaceCallback = null

        try {
            sceneView.scene?.removeOnUpdateListener(sceneUpdateListener)
            sceneView.scene?.removeOnUpdateListener(faceSceneUpdateListener)
        } catch (ignored: Exception) {
        }

        try {
            sceneView.pause()
        } catch (ignored: Exception) {
        }

        val renderer = try {
            sceneView.renderer
        } catch (ignored: Exception) {
            null
        }

        try {
            sceneView.destroy()
        } catch (e: Exception) {
            e.printStackTrace()
        }

        // Sceneform destroy() often skips renderer.dispose(). Release shared Filament
        // resources only after a settle delay so Flutter finishes detaching the view.
        mainHandler.postDelayed({
            try {
                renderer?.javaClass?.methods
                    ?.firstOrNull { it.name == "dispose" && it.parameterTypes.isEmpty() }
                    ?.invoke(renderer)
            } catch (ignored: Exception) {
            }
            try {
                SceneView.destroyAllResources()
            } catch (ignored: Exception) {
            }
            try {
                SceneView.reclaimReleasedResources()
            } catch (ignored: Exception) {
            }
            markEngineIdle()
            notifyTeardownComplete()
        }, ENGINE_SETTLE_MS)
    }

    private fun notifyTeardownComplete() {
        val notify = Runnable {
            try {
                utilsChannel.invokeMethod("onArTeardownComplete", null)
            } catch (ignored: Exception) {
            }
        }
        if (Looper.myLooper() == Looper.getMainLooper()) {
            notify.run()
        } else {
            mainHandler.post(notify)
        }
    }

    override fun dispose() {
        softTeardown()
        if (arSceneView != null) {
            destroySceneView()
        } else if (!isEngineBusy) {
            // Still unblock Dart's ArSessionGate if the view was already cleared.
            notifyTeardownComplete()
        }
    }

    fun onResume() {
        debugLog("onResume()")

        if (isDisposed || arSceneView == null) {
            return
        }

        // Stay outermost so Flutter's kill-process handler cannot wrap us again.
        ensureGlExceptionHandler()

        if (isRendererRunning || isResumeInFlight) {
            debugLog("Renderer already running or resume in flight; ignoring")
            return
        }

        if (isEngineBusy) {
            debugLog("Engine busy after prior teardown; delaying resume")
            resumeRetryRunnable?.let { mainHandler.removeCallbacks(it) }
            val retry = Runnable { onResume() }
            resumeRetryRunnable = retry
            mainHandler.postDelayed(retry, 200L)
            return
        }

        if (!surfaceReady) {
            debugLog("AR surface not ready yet; waiting for surfaceChanged")
            return
        }

        val sceneW = arSceneView?.width ?: 0
        val sceneH = arSceneView?.height ?: 0
        if (sceneW <= 0 || sceneH <= 0 || arSceneView?.holder?.surface?.isValid != true) {
            debugLog("AR surface size not valid yet (${sceneW}x${sceneH}); waiting")
            return
        }

        isResumeInFlight = true

        // request camera permission if not already requested
        if (!ArCoreUtils.hasCameraPermission(activity)) {
            ArCoreUtils.requestCameraPermission(activity, RC_PERMISSIONS)
        }

        if (arSceneView?.session == null) {
            debugLog("session is null")
            try {
                val session = ArCoreUtils.createArSession(activity, mUserRequestedInstall, isAugmentedFaces)
                if (session == null) {
                    mUserRequestedInstall = false
                    isResumeInFlight = false
                    return
                }
                val config = Config(session)
                if (isAugmentedFaces) {
                    config.augmentedFaceMode = Config.AugmentedFaceMode.MESH3D
                }
                config.updateMode = Config.UpdateMode.LATEST_CAMERA_IMAGE
                config.focusMode = Config.FocusMode.AUTO
                session.configure(config)
                arSceneView?.setupSession(session)
            } catch (ex: UnavailableUserDeclinedInstallationException) {
                Toast.makeText(activity, "TODO: handle exception " + ex.localizedMessage, Toast.LENGTH_LONG)
                    .show()
                isResumeInFlight = false
                return
            } catch (e: UnavailableException) {
                ArCoreUtils.handleSessionException(activity, e)
                methodChannel.invokeMethod("onError", "AR unavailable: ${e.message}")
                isResumeInFlight = false
                return
            } catch (e: FatalException) {
                ArCoreUtils.displayError(activity, "AR session failed to create", e)
                methodChannel.invokeMethod("onError", "AR session failed: ${e.message}")
                isResumeInFlight = false
                return
            } catch (e: Exception) {
                ArCoreUtils.displayError(activity, "AR session failed to create", e)
                methodChannel.invokeMethod("onError", "AR session failed: ${e.message}")
                isResumeInFlight = false
                return
            }
        }

        val sceneView = arSceneView
        if (sceneView == null) {
            isResumeInFlight = false
            return
        }
        sceneView.post { resumeArSceneViewWithRetry() }
    }

    private fun resumeArSceneViewWithRetry(attempt: Int = 0) {
        if (isDisposed || arSceneView == null) {
            isResumeInFlight = false
            return
        }

        if (isRendererRunning) {
            isResumeInFlight = false
            return
        }

        if (!surfaceReady || arSceneView?.holder?.surface?.isValid != true) {
            if (attempt < 20) {
                debugLog("Waiting for valid GL surface, retry ${attempt + 1}/20")
                resumeRetryRunnable?.let { mainHandler.removeCallbacks(it) }
                val retry = Runnable { resumeArSceneViewWithRetry(attempt + 1) }
                resumeRetryRunnable = retry
                mainHandler.postDelayed(retry, 200L)
            } else {
                isResumeInFlight = false
                methodChannel.invokeMethod("onError", "AR surface failed to start")
            }
            return
        }

        try {
            ensureGlExceptionHandler()
            arSceneView?.resetFrameGuards()
            arSceneView?.resume()
            isRendererRunning = true
            isResumeInFlight = false
            // onArReady is deferred until SafeArSceneView's first successful frame.
        } catch (ex: CameraNotAvailableException) {
            // Scanner CameraX can hold the camera briefly after pushReplacement.
            if (attempt < 20) {
                debugLog("Camera not available, retry ${attempt + 1}/20")
                resumeRetryRunnable?.let { mainHandler.removeCallbacks(it) }
                val retry = Runnable { resumeArSceneViewWithRetry(attempt + 1) }
                resumeRetryRunnable = retry
                mainHandler.postDelayed(retry, 500L)
            } else {
                isResumeInFlight = false
                ArCoreUtils.displayError(activity, "Unable to get camera", ex)
                methodChannel.invokeMethod("onError", "Unable to get camera: ${ex.message}")
            }
        } catch (ex: MissingGlContextException) {
            isRendererRunning = false
            if (attempt < 20) {
                debugLog("Missing GL context, retry ${attempt + 1}/20")
                try {
                    arSceneView?.pause()
                } catch (ignored: Exception) {
                }
                resumeRetryRunnable?.let { mainHandler.removeCallbacks(it) }
                val retry = Runnable { resumeArSceneViewWithRetry(attempt + 1) }
                resumeRetryRunnable = retry
                mainHandler.postDelayed(retry, 250L)
            } else {
                isResumeInFlight = false
                methodChannel.invokeMethod("onError", "AR OpenGL context failed: ${ex.message}")
            }
        } catch (ex: FatalException) {
            isRendererRunning = false
            isResumeInFlight = false
            ArCoreUtils.displayError(activity, "AR session failed to start", ex)
            methodChannel.invokeMethod("onError", "AR session failed: ${ex.message}")
        }
    }

    fun onPause() {
        isRendererRunning = false
        isResumeInFlight = false
        if (isDisposed) {
            return
        }

        if (arSceneView != null) {
            arSceneView?.pause()
        }
    }

    fun onDestroy() {
        // Full teardown is owned by dispose(); keep this for lifecycle symmetry.
        dispose()
    }

    /* private fun tryPlaceNode(tap: MotionEvent?, frame: Frame) {
        if (tap != null && frame.camera.trackingState == TrackingState.TRACKING) {
            for (hit in frame.hitTest(tap)) {
                val trackable = hit.trackable
                if (trackable is Plane && trackable.isPoseInPolygon(hit.hitPose)) {
                    // Create the Anchor.
                    val anchor = hit.createAnchor()
                    val anchorNode = AnchorNode(anchor)
                    anchorNode.setParent(arSceneView?.scene)

                    ModelRenderable.builder()
                            .setSource(activity.applicationContext, Uri.parse("TocoToucan.sfb"))
                            .build()
                            .thenAccept { renderable ->
                                val node = Node()
                                node.renderable = renderable
                                anchorNode.addChild(node)
                            }.exceptionally { throwable ->
                                Log.e(TAG, "Unable to load Renderable.", throwable);
                                return@exceptionally null
                            }
                }
            }
        }

    }*/

    /*    fun updatePosition(call: MethodCall, result: MethodChannel.Result) {
        val name = call.argument<String>("name")
        val node = arSceneView?.scene?.findByName(name)
        node?.localPosition = parseVector3(call.arguments as HashMap<String, Any>)
        result.success(null)
    }*/
}

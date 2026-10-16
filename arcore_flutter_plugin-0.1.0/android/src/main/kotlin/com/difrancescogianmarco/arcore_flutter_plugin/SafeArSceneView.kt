package com.difrancescogianmarco.arcore_flutter_plugin

import android.content.Context
import android.util.AttributeSet
import android.util.Log
import com.google.ar.core.exceptions.MissingGlContextException
import com.google.ar.sceneform.ArSceneView

/**
 * Catches [MissingGlContextException] inside Sceneform's frame loop so it never
 * reaches Android/Flutter uncaught handlers (which kill the process).
 *
 * Skips frames while EGL is not current instead of pausing immediately (pause/resume
 * loops left a black screen). Reports fatal only after many consecutive misses.
 */
class SafeArSceneView : ArSceneView {
    var onMissingGlContext: (() -> Unit)? = null
    var onFirstSuccessfulFrame: (() -> Unit)? = null

    private var consecutiveGlMisses = 0
    private var reportedFirstFrame = false
    private var reportedFatalGl = false

    constructor(context: Context) : super(context)
    constructor(context: Context, attrs: AttributeSet?) : super(context, attrs)

    fun resetFrameGuards() {
        consecutiveGlMisses = 0
        reportedFirstFrame = false
        reportedFatalGl = false
    }

    override fun onBeginFrame(frameTimeNanos: Long): Boolean {
        return try {
            val ok = super.onBeginFrame(frameTimeNanos)
            consecutiveGlMisses = 0
            if (!reportedFirstFrame && ok) {
                reportedFirstFrame = true
                onFirstSuccessfulFrame?.invoke()
            }
            ok
        } catch (e: MissingGlContextException) {
            consecutiveGlMisses++
            if (consecutiveGlMisses >= MAX_GL_MISSES && !reportedFatalGl) {
                reportedFatalGl = true
                Log.e(TAG, "MissingGlContextException persisted after $consecutiveGlMisses frames", e)
                try {
                    pause()
                } catch (ignored: Exception) {
                }
                onMissingGlContext?.invoke()
            }
            false
        }
    }

    override fun doFrame(frameTimeNanos: Long) {
        try {
            super.doFrame(frameTimeNanos)
        } catch (e: MissingGlContextException) {
            consecutiveGlMisses++
            if (consecutiveGlMisses >= MAX_GL_MISSES && !reportedFatalGl) {
                reportedFatalGl = true
                try {
                    pause()
                } catch (ignored: Exception) {
                }
                onMissingGlContext?.invoke()
            }
        }
    }

    companion object {
        private const val TAG = "SafeArSceneView"
        private const val MAX_GL_MISSES = 60
    }
}

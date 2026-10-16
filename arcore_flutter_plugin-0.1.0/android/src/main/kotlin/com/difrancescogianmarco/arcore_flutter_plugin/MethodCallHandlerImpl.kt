package com.difrancescogianmarco.arcore_flutter_plugin

import android.app.Activity
import android.os.Handler
import android.os.Looper
import android.util.Log
import com.google.ar.core.ArCoreApk
import com.google.ar.core.exceptions.UnavailableDeviceNotCompatibleException
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel

class MethodCallHandlerImpl(private val activity: Activity, private val messenger: BinaryMessenger) : MethodChannel.MethodCallHandler {
    private var methodChannel: MethodChannel? = null
    private val UTILS_CHANNEL_NAME = "arcore_flutter_plugin/utils"
    private val MAX_AVAILABILITY_CHECKS = 25
    private val AVAILABILITY_CHECK_INTERVAL_MS = 200L

    init {
        methodChannel = MethodChannel(messenger, UTILS_CHANNEL_NAME)
        methodChannel?.setMethodCallHandler(this)
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        Log.i(ArcoreFlutterPlugin.TAG, "Method called: " + call.method)
        when (call.method) {
            "checkArCoreApkAvailability" -> {
                maybeEnableAr { available ->
                    Log.i(ArcoreFlutterPlugin.TAG, "checkArCoreApkAvailability handler")
                    result.success(available)
                }
            }
            "checkIfARCoreServicesInstalled" -> {
                isARServicesInstalled { isInstalled ->
                    Log.i(ArcoreFlutterPlugin.TAG, "checkIfARCoreServicesInstalled handler")
                    result.success(isInstalled)
                }
            }
            "getArCoreAvailability" -> {
                checkAvailability(0) { availability ->
                    Log.i(ArcoreFlutterPlugin.TAG, "getArCoreAvailability: $availability")
                    result.success(availability.name)
                }
            }
            "requestArCoreInstall" -> {
                requestArCoreInstall(result)
            }
            "isArEngineReady" -> {
                result.success(!ArCoreView.isEngineBusy)
            }
            else -> {
                result.notImplemented()
            }
        }
    }

    private fun maybeEnableAr(handler: (Boolean) -> Unit) {
        Log.i(ArcoreFlutterPlugin.TAG, "maybeEnableAr")
        val availability: ArCoreApk.Availability = ArCoreApk.getInstance().checkAvailability(activity)
        if (availability.isTransient) {
            // Re-query at 5Hz while compatibility is checked in the background.
            Handler().postDelayed({
                maybeEnableAr {
                    Log.i(ArcoreFlutterPlugin.TAG, "handler")
                    handler(it)
                }
            }, 200)
        } else handler(availability.isSupported)
    }

    private fun checkAvailability(attempt: Int, handler: (ArCoreApk.Availability) -> Unit) {
        val availability = try {
            ArCoreApk.getInstance().checkAvailability(activity)
        } catch (e: Exception) {
            Log.e(ArcoreFlutterPlugin.TAG, e.toString())
            ArCoreApk.Availability.UNKNOWN_ERROR
        }

        if (!availability.isTransient) {
            handler(availability)
        } else if (attempt < MAX_AVAILABILITY_CHECKS) {
            Handler(Looper.getMainLooper()).postDelayed({
                checkAvailability(attempt + 1, handler)
            }, AVAILABILITY_CHECK_INTERVAL_MS)
        } else {
            handler(ArCoreApk.Availability.UNKNOWN_TIMED_OUT)
        }
    }

    private fun requestArCoreInstall(result: MethodChannel.Result) {
        try {
            val status = ArCoreApk.getInstance().requestInstall(activity, true)
            result.success(status == ArCoreApk.InstallStatus.INSTALLED)
        } catch (e: UnavailableDeviceNotCompatibleException) {
            result.error("UNSUPPORTED", e.localizedMessage, null)
        } catch (e: Exception) {
            Log.e(ArcoreFlutterPlugin.TAG, e.toString())
            result.error("UNAVAILABLE", e.localizedMessage, null)
        }
    }

    private fun isARServicesInstalled(handler: (Boolean) -> Unit) {
        Log.i(ArcoreFlutterPlugin.TAG, "isARServicesInstalled")
        var isInstalled = false;
        try {
            val status = ArCoreApk.getInstance().requestInstall(activity, false)
            if (status == ArCoreApk.InstallStatus.INSTALLED) {
                isInstalled = true;
            }
        } catch (e: Exception) {
            Log.e(ArcoreFlutterPlugin.TAG, e.toString());
        } finally {
            handler(isInstalled)
        }
        
    }

    fun stopListening() {
        methodChannel?.setMethodCallHandler(null)
    }

}

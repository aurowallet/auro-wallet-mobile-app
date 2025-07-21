package com.aurowallet.www.aurowallet

import io.flutter.embedding.android.FlutterFragmentActivity
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import android.content.Intent
import android.content.pm.PackageManager
import androidx.core.view.WindowCompat

class MainActivity : FlutterFragmentActivity() {
    private val CHANNEL = "browser_launcher" // Channel name to match Flutter

    override fun onCreate(savedInstanceState: android.os.Bundle?) {
        super.onCreate(savedInstanceState)
        // Enable Edge-to-Edge mode
        WindowCompat.setDecorFitsSystemWindows(window, false)
    }

    override fun configureFlutterEngine(flutterEngine: io.flutter.embedding.engine.FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            if (call.method == "openBrowser") {
                val packageName = call.argument<String>("packageName") ?: "com.android.chrome" // Default to Chrome if not provided
                openBrowser(packageName, result)
            } else {
                result.notImplemented()
            }
        }
    }

    private fun openBrowser(packageName: String, result: MethodChannel.Result) {
        try {
            val intent = packageManager.getLaunchIntentForPackage(packageName)
            if (intent != null) {
                // Reuse the existing browser instance if it’s running
                intent.flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TOP
                startActivity(intent)
                result.success(null) // Success, no return value needed
            } else {
                // Package not installed, return an error to Flutter
                result.error("PACKAGE_NOT_FOUND", "The browser with package $packageName is not installed.", null)
            }
        } catch (e: Exception) {
            // Handle any unexpected errors (e.g., security exceptions)
            result.error("LAUNCH_ERROR", "Failed to launch browser: ${e.message}", null)
        }
    }
}
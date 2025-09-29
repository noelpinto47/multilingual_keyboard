package com.example.multilingual_keyboard

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import android.view.inputmethod.InputConnection

class MainActivity : FlutterActivity() {
    private val CHANNEL = "com.exam.keyboard/input"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler {
            call, result ->
            when (call.method) {
                "warmup" -> {
                    // Pre-warm any native resources
                    result.success("Keyboard warmed up")
                }
                "insertText" -> {
                    val text = call.argument<String>("text")
                    if (text != null) {
                        // In a real keyboard IME, this would use InputConnection
                        // For demo purposes, we just acknowledge the call
                        result.success("Text inserted: $text")
                    } else {
                        result.error("INVALID_TEXT", "Text cannot be null", null)
                    }
                }
                else -> {
                    result.notImplemented()
                }
            }
        }
    }
}

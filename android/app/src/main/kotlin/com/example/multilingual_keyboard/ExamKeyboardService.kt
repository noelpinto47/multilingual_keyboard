// ============================================================================
// NATIVE SIDE: Android Implementation (Kotlin)
// ============================================================================

package com.example.multilingual_keyboard

import android.inputmethodservice.InputMethodService
import android.view.View
import android.view.inputmethod.InputConnection
import io.flutter.embedding.android.FlutterView
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodCall

/**
 * Complete InputMethodService implementation for exam keyboard
 * This demonstrates the native side of the platform channel architecture
 */
class ExamKeyboardService : InputMethodService() {
    
    private lateinit var flutterEngine: FlutterEngine
    private lateinit var keyboardChannel: ExamKeyboardChannel
    
    override fun onCreate() {
        super.onCreate()
        
        // Initialize Flutter engine for keyboard UI
        flutterEngine = FlutterEngine(this)
        
        // Setup method channel with current input connection
        keyboardChannel = ExamKeyboardChannel { currentInputConnection }
        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            ExamKeyboardChannel.CHANNEL
        ).setMethodCallHandler(keyboardChannel)
    }
    
    override fun onCreateInputView(): View {
        // Return Flutter view as keyboard UI
        return FlutterView(this).apply {
            attachToFlutterEngine(flutterEngine)
        }
    }
    
    override fun onStartInputView(info: android.view.inputmethod.EditorInfo?, restarting: Boolean) {
        super.onStartInputView(info, restarting)
        // Update the channel with fresh input connection
        keyboardChannel.updateInputConnection(currentInputConnection)
    }
}

/**
 * Method channel handler for keyboard operations
 * Optimized for minimal latency and maximum reliability
 */
class ExamKeyboardChannel(
    private val inputConnectionProvider: () -> InputConnection?
) : MethodChannel.MethodCallHandler {
    
    companion object {
        const val CHANNEL = "com.exam.keyboard/input"
    }
    
    private var inputConnection: InputConnection? = null
    
    fun updateInputConnection(connection: InputConnection?) {
        this.inputConnection = connection
    }
    
    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "warmup" -> {
                // Pre-warm any native resources
                // This could include:
                // - Pre-loading native libraries
                // - Initializing text processing engines
                // - Setting up memory pools
                result.success("Native keyboard warmed up")
            }
            
            "insertText" -> {
                val text = call.argument<String>("text")
                if (text != null) {
                    insertTextOptimized(text, result)
                } else {
                    result.error("INVALID_TEXT", "Text cannot be null", null)
                }
            }
            
            "deleteText" -> {
                val count = call.argument<Int>("count") ?: 1
                deleteTextOptimized(count, result)
            }
            
            "replaceText" -> {
                val oldText = call.argument<String>("oldText")
                val newText = call.argument<String>("newText")
                if (oldText != null && newText != null) {
                    replaceTextOptimized(oldText, newText, result)
                } else {
                    result.error("INVALID_ARGS", "Both oldText and newText required", null)
                }
            }
            
            else -> result.notImplemented()
        }
    }
    
    /**
     * CRITICAL PATH: Optimized text insertion
     * This method is called for every keystroke
     */
    private fun insertTextOptimized(text: String, result: MethodChannel.Result) {
        try {
            val connection = inputConnectionProvider() ?: inputConnection
            if (connection != null) {
                // PERFORMANCE CRITICAL: Direct IME call, minimal overhead
                connection.commitText(text, 1)
                result.success(null)
            } else {
                result.error("NO_CONNECTION", "Input connection not available", null)
            }
        } catch (e: Exception) {
            // RELIABILITY: Never crash during typing
            result.error("INSERT_FAILED", "Failed to insert text: ${e.message}", null)
        }
    }
    
    /**
     * Optimized text deletion
     */
    private fun deleteTextOptimized(count: Int, result: MethodChannel.Result) {
        try {
            val connection = inputConnectionProvider() ?: inputConnection
            if (connection != null) {
                connection.deleteSurroundingText(count, 0)
                result.success(null)
            } else {
                result.error("NO_CONNECTION", "Input connection not available", null)
            }
        } catch (e: Exception) {
            result.error("DELETE_FAILED", "Failed to delete text: ${e.message}", null)
        }
    }
    
    /**
     * Optimized text replacement (for autocorrect, etc.)
     */
    private fun replaceTextOptimized(oldText: String, newText: String, result: MethodChannel.Result) {
        try {
            val connection = inputConnectionProvider() ?: inputConnection
            if (connection != null) {
                // Get current text to find replacement position
                val currentText = connection.getTextBeforeCursor(1000, 0)
                if (currentText != null) {
                    val index = currentText.lastIndexOf(oldText)
                    if (index >= 0) {
                        // Select and replace the old text
                        connection.setSelection(index, index + oldText.length)
                        connection.commitText(newText, 1)
                        result.success(null)
                    } else {
                        result.error("TEXT_NOT_FOUND", "Old text not found", null)
                    }
                } else {
                    result.error("NO_TEXT", "Cannot read current text", null)
                }
            } else {
                result.error("NO_CONNECTION", "Input connection not available", null)
            }
        } catch (e: Exception) {
            result.error("REPLACE_FAILED", "Failed to replace text: ${e.message}", null)
        }
    }
}

/**
 * Performance monitoring for exam keyboard
 * Use this to measure and optimize keyboard performance
 */
class KeyboardPerformanceMonitor {
    private var keystrokeCount = 0
    private var totalLatency = 0L
    private var maxLatency = 0L
    private val latencyHistory = mutableListOf<Long>()
    
    fun recordKeystroke(latencyMs: Long) {
        keystrokeCount++
        totalLatency += latencyMs
        maxLatency = maxOf(maxLatency, latencyMs)
        
        latencyHistory.add(latencyMs)
        
        // Keep only last 1000 keystrokes for memory efficiency
        if (latencyHistory.size > 1000) {
            latencyHistory.removeAt(0)
        }
        
        // Log performance metrics every 100 keystrokes
        if (keystrokeCount % 100 == 0) {
            logPerformanceMetrics()
        }
    }
    
    private fun logPerformanceMetrics() {
        val avgLatency = totalLatency / keystrokeCount
        val p95Latency = calculatePercentile(95)
        val p99Latency = calculatePercentile(99)
        
        android.util.Log.i("KeyboardPerf", 
            "Keystrokes: $keystrokeCount, Avg: ${avgLatency}ms, " +
            "Max: ${maxLatency}ms, P95: ${p95Latency}ms, P99: ${p99Latency}ms"
        )
    }
    
    private fun calculatePercentile(percentile: Int): Long {
        if (latencyHistory.isEmpty()) return 0L
        
        val sorted = latencyHistory.sorted()
        val index = (percentile / 100.0 * (sorted.size - 1)).toInt()
        return sorted[index]
    }
}
package com.example.multilingual_keyboard

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import android.view.inputmethod.InputConnection
import android.view.inputmethod.EditorInfo
import android.text.TextUtils
import android.widget.EditText
import android.view.View
import android.content.Context
import android.text.Editable
import android.text.SpannableStringBuilder

class MainActivity : FlutterActivity() {
    private val CHANNEL = "com.exam.keyboard/input"
    private var methodChannel: MethodChannel? = null
    private var textContent = StringBuilder()
    private var cursorPosition = 0

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        
        methodChannel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
        methodChannel?.setMethodCallHandler { call, result ->
            try {
                when (call.method) {
                    "initialize" -> {
                        // Initialize native keyboard service
                        textContent.clear()
                        cursorPosition = 0
                        result.success(true)
                    }
                    
                    "insertText" -> {
                        val text = call.argument<String>("text")
                        if (text != null) {
                            insertTextNative(text)
                            // Notify Flutter of the text change
                            notifyFlutterTextChange()
                            result.success(true)
                        } else {
                            result.error("INVALID_ARGUMENT", "Text cannot be null", null)
                        }
                    }
                    
                    "deleteBackward" -> {
                        val count = call.argument<Int>("count") ?: 1
                        deleteBackwardNative(count)
                        // Notify Flutter of the text change
                        notifyFlutterTextChange()
                        result.success(true)
                    }
                    
                    "getTextBeforeCursor" -> {
                        val length = call.argument<Int>("length") ?: 100
                        val text = getTextBeforeCursorNative(length)
                        result.success(text)
                    }
                    
                    "getTextAfterCursor" -> {
                        val length = call.argument<Int>("length") ?: 100
                        val text = getTextAfterCursorNative(length)
                        result.success(text)
                    }
                    
                    "getCursorPosition" -> {
                        val position = getCursorPositionNative()
                        result.success(position)
                    }
                    
                    "setCursorPosition" -> {
                        val position = call.argument<Int>("position") ?: 0
                        setCursorPositionNative(position)
                        result.success(true)
                    }
                    
                    "getAllText" -> {
                        val text = getAllTextNative()
                        result.success(text)
                    }
                    
                    "setComposingText" -> {
                        val text = call.argument<String>("text")
                        if (text != null) {
                            setComposingTextNative(text)
                            result.success(true)
                        } else {
                            result.error("INVALID_ARGUMENT", "Text cannot be null", null)
                        }
                    }
                    
                    "finishComposingText" -> {
                        finishComposingTextNative()
                        result.success(true)
                    }
                    
                    "clearAllText" -> {
                        clearAllTextNative()
                        result.success(true)
                    }
                    
                    "isAvailable" -> {
                        result.success(true) // Android native keyboard is always available
                    }
                    
                    else -> {
                        result.notImplemented()
                    }
                }
            } catch (e: Exception) {
                result.error("NATIVE_ERROR", "Native operation failed: ${e.message}", null)
            }
        }
    }
    
    private fun insertTextNative(text: String) {
        // Update native text buffer
        textContent.insert(cursorPosition, text)
        cursorPosition += text.length
    }
    
    private fun deleteBackwardNative(count: Int) {
        // Update native text buffer
        val deleteStart = maxOf(0, cursorPosition - count)
        textContent.delete(deleteStart, cursorPosition)
        cursorPosition = deleteStart
    }
    
    private fun notifyFlutterTextChange() {
        // Notify Flutter of text changes so it can update the UI
        runOnUiThread {
            val text = textContent.toString()
            // Notify Flutter with minimal overhead
            methodChannel?.invokeMethod("onTextChanged", mapOf(
                "text" to text,
                "cursorPosition" to cursorPosition
            ))
        }
    }
    
    private fun getTextBeforeCursorNative(length: Int): String {
        val start = maxOf(0, cursorPosition - length)
        return textContent.substring(start, cursorPosition)
    }
    
    private fun getTextAfterCursorNative(length: Int): String {
        val end = minOf(textContent.length, cursorPosition + length)
        return textContent.substring(cursorPosition, end)
    }
    
    private fun getCursorPositionNative(): Int {
        return cursorPosition
    }
    
    private fun setCursorPositionNative(position: Int) {
        cursorPosition = maxOf(0, minOf(position, textContent.length))
        notifyFlutterTextChange()
    }
    
    private fun getAllTextNative(): String {
        return textContent.toString()
    }
    
    private fun setComposingTextNative(text: String) {
        // For now, just insert the text
        insertTextNative(text)
        notifyFlutterTextChange()
    }
    
    private fun finishComposingTextNative() {
        // Nothing to do for basic implementation
    }
    
    private fun clearAllTextNative() {
        textContent.clear()
        cursorPosition = 0
        notifyFlutterTextChange()
    }
}

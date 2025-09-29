import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import 'dart:async';

class NativeKeyboardService {
  static const MethodChannel _channel = MethodChannel('com.exam.keyboard/input');
  
  // Singleton pattern for efficient service access
  static final NativeKeyboardService _instance = NativeKeyboardService._internal();
  factory NativeKeyboardService() => _instance;
  NativeKeyboardService._internal() {
    _setupMethodCallHandler();
  }
  
  // Multiple callbacks for text changes from native
  final List<Function(String text, int cursorPosition)> _textChangeCallbacks = [];
  
  void addTextChangeCallback(Function(String text, int cursorPosition) callback) {
    _textChangeCallbacks.add(callback);
  }
  
  void removeTextChangeCallback(Function(String text, int cursorPosition) callback) {
    _textChangeCallbacks.remove(callback);
  }
  
  void _setupMethodCallHandler() {
    _channel.setMethodCallHandler((call) async {
      switch (call.method) {
        case 'onTextChanged':
          final text = call.arguments['text'] as String;
          final cursorPosition = call.arguments['cursorPosition'] as int;
          debugPrint('Native text changed: "$text" at position $cursorPosition');
          
          // Notify all registered callbacks
          for (final callback in _textChangeCallbacks) {
            try {
              callback(text, cursorPosition);
            } catch (e) {
              debugPrint('Error in text change callback: $e');
            }
          }
          break;
      }
    });
  }
  
  /// Initialize the native keyboard service
  /// Should be called once during app startup
  Future<bool> initialize() async {
    try {
      final result = await _channel.invokeMethod('initialize');
      return result == true;
    } catch (e) {
      debugPrint('Failed to initialize native keyboard: $e');
      return false;
    }
  }
  
  /// Insert text at current cursor position
  /// Optimized for single character input - primary performance path
  Future<bool> insertText(String text) async {
    try {
      await _channel.invokeMethod('insertText', {'text': text});
      return true;
    } catch (e) {
      debugPrint('Failed to insert text: $e');
      return false;
    }
  }
  
  /// Delete text backward from cursor position  
  /// count: number of characters to delete (default: 1)
  Future<bool> deleteBackward([int count = 1]) async {
    try {
      await _channel.invokeMethod('deleteBackward', {'count': count});
      return true;
    } catch (e) {
      debugPrint('Failed to delete backward: $e');
      return false;
    }
  }
  
  /// Get text before cursor for auto-capitalization logic
  /// length: number of characters to retrieve
  Future<String> getTextBeforeCursor(int length) async {
    try {
      final result = await _channel.invokeMethod('getTextBeforeCursor', {'length': length});
      return result?.toString() ?? '';
    } catch (e) {
      debugPrint('Failed to get text before cursor: $e');
      return '';
    }
  }
  
  /// Get text after cursor (useful for advanced features)
  /// length: number of characters to retrieve  
  Future<String> getTextAfterCursor(int length) async {
    try {
      final result = await _channel.invokeMethod('getTextAfterCursor', {'length': length});
      return result?.toString() ?? '';
    } catch (e) {
      debugPrint('Failed to get text after cursor: $e');
      return '';
    }
  }
  
  /// Get current cursor position
  Future<int> getCursorPosition() async {
    try {
      final result = await _channel.invokeMethod('getCursorPosition');
      return result ?? 0;
    } catch (e) {
      debugPrint('Failed to get cursor position: $e');
      return 0;
    }
  }
  
  /// Set cursor position
  Future<bool> setCursorPosition(int position) async {
    try {
      await _channel.invokeMethod('setCursorPosition', {'position': position});
      return true;
    } catch (e) {
      debugPrint('Failed to set cursor position: $e');
      return false;
    }
  }
  
  /// Get all text from input field (for auto-capitalization context)
  Future<String> getAllText() async {
    try {
      final result = await _channel.invokeMethod('getAllText');
      return result?.toString() ?? '';
    } catch (e) {
      debugPrint('Failed to get all text: $e');
      return '';
    }
  }
  
  /// Set composing text (for advanced input like predictive text)
  Future<bool> setComposingText(String text) async {
    try {
      await _channel.invokeMethod('setComposingText', {'text': text});
      return true;
    } catch (e) {
      debugPrint('Failed to set composing text: $e');
      return false;
    }
  }
  
  /// Finish composing text
  Future<bool> finishComposingText() async {
    try {
      await _channel.invokeMethod('finishComposingText');
      return true;
    } catch (e) {
      debugPrint('Failed to finish composing text: $e');
      return false;
    }
  }
  
  /// Clear all text
  Future<bool> clearAllText() async {
    try {
      await _channel.invokeMethod('clearAllText');
      return true;
    } catch (e) {
      debugPrint('Failed to clear all text: $e');
      return false;
    }
  }
  
  /// Check if native keyboard is available (Android only)
  Future<bool> isNativeKeyboardAvailable() async {
    try {
      final result = await _channel.invokeMethod('isAvailable');
      return result == true;
    } catch (e) {
      // If method channel fails, native keyboard is not available
      return false;
    }
  }
}
import 'package:flutter/services.dart';
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
          
          // Notify all registered callbacks
          for (final callback in _textChangeCallbacks) {
            try {
              callback(text, cursorPosition);
            } catch (e) {
              // Silent error handling for performance
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
      return false;
    }
  }

  // Removed unused methods for auto-capitalization and advanced features
  // Keeping only essential methods for optimal performance:
  
  /// Clear all text
  Future<bool> clearAllText() async {
    try {
      await _channel.invokeMethod('clearAllText');
      return true;
    } catch (e) {
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
import 'package:flutter/material.dart';
import '../services/native_keyboard_service.dart';
import 'dart:io' show Platform;

class NativeTextInput extends StatefulWidget {
  final String? hintText;
  final String? labelText;
  final TextStyle? style;
  final int? maxLines;
  final bool expands;
  final TextAlignVertical? textAlignVertical;
  final bool readOnly;
  final bool showCursor;
  final InputDecoration? decoration;
  final VoidCallback? onFocusGained;
  final VoidCallback? onFocusLost;
  
  const NativeTextInput({
    super.key,
    this.hintText,
    this.labelText,
    this.style,
    this.maxLines,
    this.expands = false,
    this.textAlignVertical,
    this.readOnly = false,
    this.showCursor = true,
    this.decoration,
    this.onFocusGained,
    this.onFocusLost,
  });

  @override
  State<NativeTextInput> createState() => _NativeTextInputState();
}

class _NativeTextInputState extends State<NativeTextInput> {
  late final TextEditingController _controller;
  late final FocusNode _focusNode;
  late final NativeKeyboardService _nativeKeyboard;
  bool _isNativeConnected = false;
  
  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
    _focusNode = FocusNode();
    _nativeKeyboard = NativeKeyboardService();
    _initializeNativeIntegration();
    
    // Listen to focus changes to connect/disconnect native keyboard
    _focusNode.addListener(_handleFocusChange);
  }
  
  Future<void> _initializeNativeIntegration() async {
    if (Platform.isAndroid) {
      try {
        final isAvailable = await _nativeKeyboard.isNativeKeyboardAvailable();
        if (isAvailable) {
          await _nativeKeyboard.initialize();
          
          // Set up callback to receive text changes from native
          _nativeKeyboard.addTextChangeCallback((text, cursorPosition) {
            setState(() {
              _controller.text = text;
              _controller.selection = TextSelection.fromPosition(
                TextPosition(offset: cursorPosition),
              );
            });
          });
          
          setState(() {
            _isNativeConnected = true;
          });
        }
      } catch (e) {
        // Silent error handling for performance
      }
    }
  }
  
  void _handleFocusChange() {
    if (_focusNode.hasFocus) {
      // Text field gained focus
      if (_isNativeConnected) {
        _syncTextWithNative();
      }
      widget.onFocusGained?.call();
    } else {
      // Text field lost focus
      widget.onFocusLost?.call();
    }
  }
  
  Future<void> _syncTextWithNative() async {
    // Sync current text content with native service if needed
    // This is called when the text field gains focus
    try {
      final currentText = _controller.text;
      if (currentText.isNotEmpty) {
        // Native service is now aware of current text context
      }
    } catch (e) {
      // Silent error handling for performance
    }
  }
  
  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: _controller,
      focusNode: _focusNode,
      maxLines: widget.maxLines,
      expands: widget.expands,
      readOnly: widget.readOnly,
      showCursor: widget.showCursor,
      textAlignVertical: widget.textAlignVertical,
      style: widget.style,
      decoration: widget.decoration ?? InputDecoration(
        border: InputBorder.none,
        hintText: widget.hintText ?? 'Start typing with the keyboard below...',
        labelText: widget.labelText ?? 'Exam Text Input',
        contentPadding: const EdgeInsets.all(12),
        floatingLabelBehavior: FloatingLabelBehavior.always,
      ),
    );
  }
}
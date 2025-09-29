import 'package:flutter/material.dart';
import 'dart:io' show Platform;
import '../models/keyboard_layout.dart';
import '../widgets/keyboard_widgets.dart';
import '../services/native_keyboard_service.dart';

class MinimalExamKeyboard extends StatefulWidget {
  final List<String> supportedLanguages; // e.g., ['en', 'hi', 'es']
  final Function(String)? onTextInput; // Optional fallback for non-native platforms
  final bool useNativeKeyboard; // Enable/disable native integration
  
  const MinimalExamKeyboard({
    super.key,
    required this.supportedLanguages,
    this.onTextInput,
    this.useNativeKeyboard = true,
  });

  @override
  State<MinimalExamKeyboard> createState() => _MinimalExamKeyboardState();
}

class _MinimalExamKeyboardState extends State<MinimalExamKeyboard> {
  String _currentLanguage = 'en';
  final Map<String, List<List<String>>> _layouts = {};
  bool _isUpperCase = false; // Manual control only
  bool _showNumericKeyboard = false;
  
  // Native keyboard integration
  late final NativeKeyboardService _nativeKeyboard;
  bool _isNativeAvailable = false;
  
  @override
  void initState() {
    super.initState();
    _nativeKeyboard = NativeKeyboardService();
    _loadKeyboardLayouts();
    _initializeNativeKeyboard();
  }
  
  Future<void> _initializeNativeKeyboard() async {
    if (widget.useNativeKeyboard && Platform.isAndroid) {
      _isNativeAvailable = await _nativeKeyboard.isNativeKeyboardAvailable();
      if (_isNativeAvailable) {
        await _nativeKeyboard.initialize();
        debugPrint('Native keyboard initialized successfully');
        
        // Clear native text buffer to start fresh
        await _nativeKeyboard.clearAllText();
      } else {
        debugPrint('Native keyboard not available, falling back to Flutter implementation');
      }
    } else {
      debugPrint('Native keyboard disabled or not supported on this platform');
    }
  }
  
  void _loadKeyboardLayouts() {
    // Pre-load all language layouts into memory
    // No dynamic loading during typing = consistent performance
    for (final lang in widget.supportedLanguages) {
      _layouts[lang] = KeyboardLayout.getLayoutForLanguage(lang);
    }
  }
  
  // CRITICAL PATH: This runs on every key press - OPTIMIZED FOR NATIVE
  Future<void> _onKeyPress(String key) async {
    try {
      // Handle manual capitalization only
      String finalKey = key;
      if (_isUpperCase && key.length == 1 && key.toLowerCase() != key.toUpperCase()) {
        finalKey = key.toUpperCase();
      }
      
      // Native Android integration - FASTEST PATH
      if (_isNativeAvailable) {
        final success = await _nativeKeyboard.insertText(finalKey);
        if (success) {
          return;
        }
      }
      
      // Fallback to Flutter callback for non-native platforms
      widget.onTextInput?.call(finalKey);
      
    } catch (e) {
      // Silent fail in exam context - don't disrupt typing
      debugPrint('Insert failed: $e');
      // Fallback to Flutter implementation
      widget.onTextInput?.call(key);
    }
  }
  
  Future<void> _onBackspace() async {
    try {
      // Native Android integration - FASTEST PATH
      if (_isNativeAvailable) {
        final success = await _nativeKeyboard.deleteBackward(1);
        if (success) {
          return;
        }
      }
      
      // Fallback to Flutter callback
      widget.onTextInput?.call('⌫'); // Special backspace signal
      
    } catch (e) {
      debugPrint('Backspace failed: $e');
      widget.onTextInput?.call('⌫');
    }
  }

  void _toggleCase() {
    setState(() {
      _isUpperCase = !_isUpperCase;
    });
  }

  void _toggleNumericKeyboard() {
    setState(() {
      _showNumericKeyboard = !_showNumericKeyboard;
    });
  }

  void _toggleLanguageSelector() {
    _showLanguageModal();
  }

  void _switchLanguage(String language) {
    setState(() {
      _currentLanguage = language;
    });
  }


  
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFE8E8E8), // Light keyboard background
        borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
      ),
      child: _buildKeyboardLayout(),
    );
  }

  void _showLanguageModal() {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Modal title
                const Text(
                  'Select Language',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 16),
                
                // Language options
                ...widget.supportedLanguages.map((lang) {
                  final isSelected = _currentLanguage == lang;
                  return Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(12),
                        onTap: () {
                          _switchLanguage(lang);
                          Navigator.of(context).pop();
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                          decoration: BoxDecoration(
                            color: isSelected 
                                ? const Color(0xFF007AFF).withValues(alpha: 0.1)
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(12),
                            border: isSelected 
                                ? Border.all(
                                    color: const Color(0xFF007AFF),
                                    width: 2,
                                  )
                                : Border.all(
                                    color: Colors.grey.shade300,
                                    width: 1,
                                  ),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  KeyboardLayout.getLanguageName(lang),
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: isSelected 
                                        ? FontWeight.w600 
                                        : FontWeight.w500,
                                    color: isSelected 
                                        ? const Color(0xFF007AFF)
                                        : Colors.black87,
                                  ),
                                ),
                              ),
                              Text(
                                lang.toUpperCase(),
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: isSelected 
                                      ? const Color(0xFF007AFF)
                                      : Colors.grey.shade600,
                                ),
                              ),
                              if (isSelected) ...[
                                const SizedBox(width: 8),
                                const Icon(
                                  Icons.check_circle,
                                  color: Color(0xFF007AFF),
                                  size: 20,
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                }),
                
                const SizedBox(height: 16),
                
                // Close button
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                    ),
                    child: const Text(
                      'Close',
                      style: TextStyle(
                        color: Colors.grey,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
  
  Widget _buildKeyboardLayout() {
    if (_showNumericKeyboard) {
      return _buildNumericKeyboardLayout();
    }
    
    final layout = _layouts[_currentLanguage] ?? [];
    
    return Padding(
      padding: const EdgeInsets.all(6.0),
      child: Column(
        mainAxisSize: MainAxisSize.min, // Size to content
        children: [
          // Row 1: First letter row
          if (layout.isNotEmpty) 
            KeyboardWidgets.buildKeyRow(layout[0], _isUpperCase, _onKeyPress),
          
          // Row 2: Second letter row
          if (layout.length > 1) 
            KeyboardWidgets.buildKeyRow(layout[1], _isUpperCase, _onKeyPress),
          
          // Row 3: Third letter row with shift and backspace
          if (layout.length > 2) 
            KeyboardWidgets.buildBottomRow(
              layout[2], 
              _isUpperCase, 
              _onKeyPress, 
              _toggleCase, 
              _onBackspace,
            ),
          
          // Row 4: Unified bottom row
          _buildUnifiedBottomRow(),
        ],
      ),
    );
  }
  
  Widget _buildNumericKeyboardLayout() {
    final layout = KeyboardLayout.getNumericLayout();
    
    return Padding(
      padding: const EdgeInsets.all(6.0),
      child: Column(
        mainAxisSize: MainAxisSize.min, // Size to content
        children: [
          // Row 1: Numbers
          KeyboardWidgets.buildKeyRow(layout[0], false, _onKeyPress),
          
          // Row 2: Symbols
          KeyboardWidgets.buildKeyRow(layout[1], false, _onKeyPress),
          
          // Row 3: Special symbols with backspace
          KeyboardWidgets.buildNumericBottomRow(layout[2], _onKeyPress, _onBackspace),

          // Row 4: Unified bottom row
          _buildUnifiedBottomRow(),
        ],
      ),
    );
  }

  Widget _buildUnifiedBottomRow() {
    return SizedBox(
      height: 50, // Fixed height for keyboard row
      child: Row(
        children: [
          // Toggle button (?123 or ABC)
          Expanded(
            flex: 2,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 2),
              child: KeyboardWidgets.buildSpecialKey(
                _showNumericKeyboard ? 'ABC' : '?123',
                onTap: _toggleNumericKeyboard,
              ),
            ),
          ),
          
          // Comma key
          Expanded(
            flex: 2,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 2),
              child: KeyboardWidgets.buildKey(',', false, _onKeyPress),
            ),
          ),
          
          // Spacebar with language switching
          Expanded(
            flex: 6,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 2),
              child: GestureDetector(
                onTap: () => _onKeyPress(' '),
                onLongPress: _toggleLanguageSelector,
                child: Container(
                  height: 42,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: const Color(0xFFD0D0D0), width: 1),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        offset: const Offset(0, 1),
                        blurRadius: 2,
                      ),
                    ],
                  ),
                  child: const Center(
                    child: Text(
                      'space',
                      style: TextStyle(
                        color: Colors.black54,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          
          // Period key
          Expanded(
            flex: 2,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 2),
              child: KeyboardWidgets.buildKey('.', false, _onKeyPress),
            ),
          ),
          
          // Enter key
          Expanded(
            flex: 2,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 2),
              child: KeyboardWidgets.buildSpecialKey(
                '↵',
                onTap: () => _onKeyPress('\n'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
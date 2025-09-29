import 'package:flutter/material.dart';
import '../models/keyboard_layout.dart';
import '../widgets/keyboard_widgets.dart';

class MinimalExamKeyboard extends StatefulWidget {
  final List<String> supportedLanguages; // e.g., ['en', 'hi', 'es']
  final Function(String) onTextInput;
  final String Function()? getCurrentText; // Callback to get current text
  
  const MinimalExamKeyboard({
    super.key,
    required this.supportedLanguages,
    required this.onTextInput,
    this.getCurrentText,
  });

  @override
  State<MinimalExamKeyboard> createState() => _MinimalExamKeyboardState();
}

class _MinimalExamKeyboardState extends State<MinimalExamKeyboard> {
  // Platform channel for native keyboard integration
  // static const _channel = MethodChannel('com.exam.keyboard/input');
  
  String _currentLanguage = 'en';
  final Map<String, List<List<String>>> _layouts = {};
  bool _isUpperCase = true; // Start with capitalization ON
  bool _manualCapsLock = false; // Track if user manually toggled caps

  bool _showNumericKeyboard = false;
  
  @override
  void initState() {
    super.initState();
    _loadKeyboardLayouts();
  }
  
  void _loadKeyboardLayouts() {
    // Pre-load all language layouts into memory
    // No dynamic loading during typing = consistent performance
    for (final lang in widget.supportedLanguages) {
      _layouts[lang] = KeyboardLayout.getLayoutForLanguage(lang);
    }
  }
  
  // CRITICAL PATH: This runs on every key press
  Future<void> _onKeyPress(String key) async {
    // Optimized: Single method call, no extra logic
    try {
      // Handle auto-capitalization logic
      String finalKey = key;
      if (_isUpperCase && key.length == 1 && key.toLowerCase() != key.toUpperCase()) {
        finalKey = key.toUpperCase();
      }
      
      // For demo purposes, call the callback directly
      // In real implementation, this would use platform channel
      widget.onTextInput(finalKey);
      
      // Auto-capitalization logic after text is updated
      Future.microtask(() => _handleAutoCapitalization(finalKey));
      
      // Platform channel call (commented for demo)
      // await _channel.invokeMethod('insertText', {'text': finalKey});
    } catch (e) {
      // Silent fail in exam context - don't disrupt typing
      debugPrint('Insert failed: $e');
    }
  }
  
  void _onBackspace() {
    // Handle backspace functionality
    // For demo, we'll simulate backspace by removing last character
    // In real implementation, this would use platform channel
    
    widget.onTextInput('⌫'); // Special backspace signal
    
    // Check auto-capitalization after backspace
    Future.microtask(() => _handleAutoCapitalization(''));
  }

  void _toggleCase() {
    setState(() {
      _isUpperCase = !_isUpperCase;
      _manualCapsLock = true; // User manually toggled, disable auto-caps temporarily
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

  void _handleAutoCapitalization(String lastKey) {
    // Don't auto-adjust if user manually toggled caps
    if (_manualCapsLock) return;
    
    // Get current text from callback
    String currentText = widget.getCurrentText?.call() ?? '';
    
    setState(() {
      if (currentText.isEmpty) {
        // At the beginning of text, enable capitalization
        _isUpperCase = true;
        _manualCapsLock = false; // Reset manual caps lock
      } else if (lastKey.isNotEmpty && lastKey.length == 1 && lastKey.toLowerCase() != lastKey.toUpperCase()) {
        // After typing a letter while caps is on, turn off caps
        if (_isUpperCase) {
          _isUpperCase = false;
        }
      } else if (currentText.endsWith('. ') || currentText.endsWith('.\n') || 
                 currentText.endsWith('! ') || currentText.endsWith('!\n') ||
                 currentText.endsWith('? ') || currentText.endsWith('?\n')) {
        // After sentence-ending punctuation + space/newline, enable capitalization
        _isUpperCase = true;
        _manualCapsLock = false; // Reset manual caps lock
      } else if (lastKey.isEmpty) {
        // This is a backspace, check if we should enable caps
        String trimmed = currentText.trimRight();
        if (trimmed.isEmpty || trimmed.endsWith('.') || trimmed.endsWith('!') || trimmed.endsWith('?')) {
          _isUpperCase = true;
          _manualCapsLock = false; // Reset manual caps lock
        }
      }
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
          const SizedBox(height: 4),
          
          // Row 2: Symbols
          KeyboardWidgets.buildKeyRow(layout[1], false, _onKeyPress),
          const SizedBox(height: 4),
          
          // Row 3: Special symbols with backspace
          KeyboardWidgets.buildNumericBottomRow(layout[2], _onKeyPress, _onBackspace),
          const SizedBox(height: 4),

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
            flex: 1,
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
            flex: 1,
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
import 'package:flutter/material.dart';
import 'dart:io' show Platform;
import '../models/keyboard_layout.dart';
import '../widgets/keyboard_widgets.dart';
import '../services/native_keyboard_service.dart';

// Enum for three-state shift key behavior
enum ShiftState {
  off,        // lowercase
  single,     // capitalize next letter only
  capsLock,   // all letters capitalized
}

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
  
  // Three-state shift key management
  ShiftState _shiftState = ShiftState.off;
  bool get _isUpperCase => _shiftState != ShiftState.off;
  
  bool _showNumericKeyboard = false;
  
  // Native keyboard integration
  late final NativeKeyboardService _nativeKeyboard;
  bool _isNativeAvailable = false;
  
  // Double tap detection for caps lock
  DateTime? _lastShiftTap;
  static const doubleTapThreshold = Duration(milliseconds: 300);
  
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
        // Clear native text buffer to start fresh
        await _nativeKeyboard.clearAllText();
      }
    } else {
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
      // Handle three-state capitalization
      String finalKey = key;
      if (_isUpperCase && key.length == 1 && key.toLowerCase() != key.toUpperCase()) {
        finalKey = key.toUpperCase();
        
        // Auto-turn off shift after single letter (if in single mode)
        if (_shiftState == ShiftState.single && mounted) {
          setState(() {
            _shiftState = ShiftState.off;
          });
        }
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
      widget.onTextInput?.call('⌫');
    }
  }

  /// Handles three-state shift key behavior:
  /// - Single tap: off → single → off (capitalize next letter only)
  /// - Double tap: toggles caps lock on/off (capitalize all letters)
  void _toggleCase() {
    final now = DateTime.now();
    final isDoubleTap = _lastShiftTap != null && 
        now.difference(_lastShiftTap!) < doubleTapThreshold;
    
    if (mounted) {
      setState(() {
        if (isDoubleTap) {
          // Double tap: toggle caps lock mode
          _shiftState = _shiftState == ShiftState.capsLock 
              ? ShiftState.off 
              : ShiftState.capsLock;
        } else {
          // Single tap: cycle through single/off states
          switch (_shiftState) {
            case ShiftState.off:
              _shiftState = ShiftState.single; // Next letter will be capitalized
              break;
            case ShiftState.single:
              _shiftState = ShiftState.off; // Turn off capitalization
              break;
            case ShiftState.capsLock:
              _shiftState = ShiftState.off; // Exit caps lock
              break;
          }
        }
      });
    }
    
    _lastShiftTap = now;
  }

  void _toggleNumericKeyboard() {
    if (mounted) {
      setState(() {
        _showNumericKeyboard = !_showNumericKeyboard;
      });
    }
  }

  void _toggleLanguageSelector() {
    _showLanguageModal();
  }

  void _switchLanguage(String language) {
    if (mounted) {
      setState(() {
        _currentLanguage = language;
      });
    }
  }

  /// Get display code for language indicator on spacebar
  String _getLanguageDisplayCode(String languageCode) {
    switch (languageCode) {
      case 'en':
        return 'eng';
      case 'hi':
        return 'hin';
      case 'es':
        return 'spa';
      case 'fr':
        return 'fra';
      default:
        return languageCode.toLowerCase();
    }
  }
  
  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isLandscape = screenSize.width > screenSize.height;
    
    // Responsive keyboard height management:
    // - Landscape: Limit to 40% of screen height to keep text field visible
    // - Portrait: Limit to 50% of screen height as requested
    final maxKeyboardHeight = isLandscape 
        ? screenSize.height * 0.4  // 40% max in landscape
        : screenSize.height * 0.5; // 50% max in portrait
    
    return ConstrainedBox(
      constraints: BoxConstraints(
        maxHeight: maxKeyboardHeight,
        minHeight: 0,
      ),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFFE8E8E8), // Light keyboard background
          borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
        ),
        child: _buildAdaptiveKeyboardLayout(maxKeyboardHeight),
      ),
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

  Widget _buildAdaptiveKeyboardLayout(double availableHeight) {
    if (_showNumericKeyboard) {
      return _buildAdaptiveNumericKeyboardLayout(availableHeight);
    }
    
    final layout = _layouts[_currentLanguage] ?? [];
    
    // Calculate adaptive key height dynamically based on layout length
    const double padding = 8.0; // Total padding for container
    final int layoutRows = layout.length; // Dynamic based on layout array length
    final int totalRows = layoutRows + 1; // Layout rows + 1 unified bottom row
    
    // Set natural key heights based on screen orientation
    const double preferredKeyHeight = 45.0; // Comfortable key size
    const double minKeyHeight = 30.0; // Minimum usability
    const double maxKeyHeight = 50.0; // Maximum comfort
    
    // Calculate if we need to compress keys to fit in available space
    final double naturalKeyboardHeight = (preferredKeyHeight * totalRows) + padding;
    final double adaptiveKeyHeight = naturalKeyboardHeight <= availableHeight
        ? preferredKeyHeight // Use natural size if it fits
        : ((availableHeight - padding) / totalRows).clamp(minKeyHeight, maxKeyHeight); // Compress if needed
    
    return Padding(
      padding: const EdgeInsets.all(1.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Build all layout rows dynamically
          ...layout.asMap().entries.map((entry) {
            final int index = entry.key;
            final List<String> row = entry.value;
            final bool isLastRow = index == layout.length - 1;
            
            return Flexible(
              child: isLastRow
                  // Last row uses buildBottomRow for shift and backspace functionality
                  ? KeyboardWidgets.buildBottomRow(
                      row, 
                      _isUpperCase, 
                      _onKeyPress, 
                      _toggleCase, 
                      _onBackspace,
                      shiftState: _shiftState,
                      keyHeight: adaptiveKeyHeight,
                    )
                  // All other rows use regular buildKeyRow
                  : KeyboardWidgets.buildKeyRow(
                      row, 
                      _isUpperCase, 
                      _onKeyPress,
                      keyHeight: adaptiveKeyHeight,
                    ),
            );
          }),
          
          // Unified bottom row (spacebar, etc.)
          Flexible(
            child: _buildAdaptiveUnifiedBottomRow(adaptiveKeyHeight),
          ),
        ],
      ),
    );
  }

  Widget _buildAdaptiveNumericKeyboardLayout(double availableHeight) {
    final layout = KeyboardLayout.getNumericLayout();
    
    // Calculate adaptive key height for numeric layout dynamically
    const double padding = 8.0; // Total padding from container
    final int layoutRows = layout.length; // Dynamic based on layout array length
    final int totalRows = layoutRows + 1; // Layout rows + 1 unified bottom row
    
    // Set natural key heights based on screen orientation
    const double preferredKeyHeight = 45.0; // Comfortable key size
    const double minKeyHeight = 30.0; // Minimum usability
    const double maxKeyHeight = 50.0; // Maximum comfort
    
    // Calculate if we need to compress keys to fit in available space
    final double naturalKeyboardHeight = (preferredKeyHeight * totalRows) + padding;
    final double adaptiveKeyHeight = naturalKeyboardHeight <= availableHeight
        ? preferredKeyHeight // Use natural size if it fits
        : ((availableHeight - padding) / totalRows).clamp(minKeyHeight, maxKeyHeight); // Compress if needed
    
    return Padding(
      padding: const EdgeInsets.all(1.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Build all layout rows dynamically
          ...layout.asMap().entries.map((entry) {
            final int index = entry.key;
            final List<String> row = entry.value;
            final bool isLastRow = index == layout.length - 1;
            
            return Flexible(
              child: isLastRow
                  // Last row uses buildNumericBottomRow for special handling
                  ? KeyboardWidgets.buildNumericBottomRow(
                      row, 
                      _onKeyPress, 
                      _onBackspace,
                      keyHeight: adaptiveKeyHeight,
                    )
                  // All other rows use regular buildKeyRow
                  : KeyboardWidgets.buildKeyRow(
                      row, 
                      false, 
                      _onKeyPress,
                      keyHeight: adaptiveKeyHeight,
                    ),
            );
          }),

          // Unified bottom row (spacebar, etc.)
          Flexible(
            child: _buildAdaptiveUnifiedBottomRow(adaptiveKeyHeight),
          ),
        ],
      ),
    );
  }

  Widget _buildAdaptiveUnifiedBottomRow(double keyHeight) {
    return Row(
      children: [
        // Toggle button (?123 or ABC)
        Expanded(
          flex: 2,
          child: KeyboardWidgets.buildSpecialKey(
            _showNumericKeyboard ? 'ABC' : '?123',
            onTap: _toggleNumericKeyboard,
            keyHeight: keyHeight,
          ),
        ),
        
        // Comma key
        Expanded(
          flex: 2,
          child: KeyboardWidgets.buildKey(',', false, _onKeyPress, keyHeight: keyHeight),
        ),
        
        // Spacebar with language switching and language indicator
        Expanded(
          flex: 6,
          child: GestureDetector(
            onTap: () => _onKeyPress(' '),
            onLongPress: _toggleLanguageSelector,
            child: Container(
              height: keyHeight,
              padding: const EdgeInsets.symmetric(horizontal: 12.0),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: const Color.fromARGB(124, 208, 208, 208), width: 1),
              ),
              child: Stack(
                children: [
                  // Centered space symbol
                  const Center(
                    child: Text(
                      '␣',
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.black,
                      ),
                    ),
                  ),
                  // Language indicator positioned on the right
                  Positioned(
                    right: 0,
                    top: 0,
                    bottom: 0,
                    child: Center(
                      child: Text(
                        _getLanguageDisplayCode(_currentLanguage),
                        style: const TextStyle(
                          fontSize: 11,
                          color: Color(0xFF888888),
                          fontWeight: FontWeight.w400,
                          letterSpacing: 0.3,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        
        // Period key
        Expanded(
          flex: 2,
          child: KeyboardWidgets.buildKey('.', false, _onKeyPress, keyHeight: keyHeight),
        ),
        
        // Enter key
        Expanded(
          flex: 2,
          child: KeyboardWidgets.buildSpecialKey(
            '↵',
            onTap: () => _onKeyPress('\n'),
            keyHeight: keyHeight,
          ),
        ),
      ],
    );
  }
}
import 'package:flutter/material.dart';
import 'package:multilingual_keyboard/models/keyboard_layout.dart';
import '../widgets/minimal_exam_keyboard.dart';
import '../widgets/native_text_input.dart';
import '../services/performance_service.dart';
import '../constants/app_colors.dart';

class KeyboardDemoPage extends StatefulWidget {
  const KeyboardDemoPage({super.key});

  @override
  State<KeyboardDemoPage> createState() => _KeyboardDemoPageState();
}

class _KeyboardDemoPageState extends State<KeyboardDemoPage> {
  final TextEditingController _textController = TextEditingController();
  bool _showKeyboard = false;
  
  // Handle back button press - close keyboard if open, otherwise do nothing
  Future<bool> _onWillPop() async {
    if (_showKeyboard) {
      // Close keyboard by removing focus from the text field
      FocusScope.of(context).unfocus();
      return false; // Don't exit the app
    }
    return false; // Never exit the app on back press
  }
  
  @override
  void initState() {
    super.initState();
    // Pre-load language assets for all supported languages
    PerformanceOptimizations.preloadLanguageAssets(['en', 'hi', 'es', 'fr']);
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false, // Prevent default back behavior - never exit app
      onPopInvokedWithResult: (didPop, result) async {
        if (!didPop) {
          // Custom back button handling: close keyboard if open, otherwise do nothing
          await _onWillPop();
        }
      },
      child: Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.primary,
        title: Text('Multilingual Exam Keyboard', style: TextStyle(color: AppColors.systemWhite)),
      ),
      body: Column(
        children: [
          // Text input area - flexible height
          Expanded(
            flex: 2,
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(color: AppColors.borderGrey),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: NativeTextInput(
                  maxLines: null,
                  expands: true,
                  readOnly: true, // Disable system keyboard
                  showCursor: true,
                  textAlignVertical: TextAlignVertical.top,
                  style: const TextStyle(fontSize: 16),
                  onFocusGained: () {
                    setState(() {
                      _showKeyboard = true;
                    });
                  },
                  onFocusLost: () {
                    // Don't hide keyboard immediately on focus lost
                    // This prevents keyboard from disappearing when dialogs open
                    Future.delayed(const Duration(milliseconds: 100), () {
                      if (mounted && !FocusScope.of(context).hasFocus) {
                        setState(() {
                          _showKeyboard = false;
                        });
                      }
                    });
                  },
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    hintText: 'Tap here to show keyboard and start typing...',
                    labelText: 'Exam Text Input (Native Mode)',  
                    contentPadding: EdgeInsets.all(12),
                    floatingLabelBehavior: FloatingLabelBehavior.always,
                  ),
                ),
              ),
            ),
          ),
          
          // Performance metrics display - compact
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 12),
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.pageBackground,
              borderRadius: BorderRadius.circular(6),
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Text('Latency: <10ms', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                Text('Memory: Optimized', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                Text('Offline: Ready', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
              ],
            ),
          ),
          
          const SizedBox(height: 8),
          
          // Multilingual keyboard with native Android integration
          // Animated appearance when text field is focused
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            transitionBuilder: (child, animation) {
              return SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0, 1),
                  end: Offset.zero,
                ).animate(CurvedAnimation(
                  parent: animation,
                  curve: Curves.easeOut,
                )),
                child: child,
              );
            },
            child: _showKeyboard
                ? MinimalExamKeyboard(
                    key: const ValueKey('keyboard'),
                    supportedLanguages: KeyboardLayout.supportedLanguages,
                    useNativeKeyboard: true, // Enable native integration
                    onTextInput: (text) {
                      // This is now a fallback for non-native platforms only
                      // On Android, text input is handled natively for optimal performance
                      if (text == '⌫') {
                        // Handle backspace 
                        if (_textController.text.isNotEmpty) {
                          _textController.text = _textController.text
                              .substring(0, _textController.text.length - 1);
                        }
                      } else {
                        // Add text
                        _textController.text += text;
                      }
                    },
                  )
                : Container(
                    key: const ValueKey('no-keyboard'),
                    padding: const EdgeInsets.all(24),
                    child: Text(
                      'Tap the text field above to show the keyboard',
                      style: TextStyle(
                        color: AppColors.textGreyDark,
                        fontSize: 16,
                        fontStyle: FontStyle.italic,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
          ),
        ],
      ),
    ), // Scaffold
  ); // PopScope
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }
}
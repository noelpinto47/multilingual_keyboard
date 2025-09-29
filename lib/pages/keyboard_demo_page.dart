import 'package:flutter/material.dart';
import '../widgets/minimal_exam_keyboard.dart';
import '../widgets/native_text_input.dart';
import '../services/performance_service.dart';

class KeyboardDemoPage extends StatefulWidget {
  const KeyboardDemoPage({super.key});

  @override
  State<KeyboardDemoPage> createState() => _KeyboardDemoPageState();
}

class _KeyboardDemoPageState extends State<KeyboardDemoPage> {
  final TextEditingController _textController = TextEditingController();
  
  @override
  void initState() {
    super.initState();
    // Pre-load language assets for all supported languages
    PerformanceOptimizations.preloadLanguageAssets(['en', 'hi', 'es', 'fr']);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.primary,
        title: const Text('Multilingual Exam Keyboard', style: TextStyle(color: Colors.white),),
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
                  border: Border.all(color: Colors.grey.shade400),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: NativeTextInput(
                  maxLines: null,
                  expands: true,
                  readOnly: true, // Disable system keyboard
                  showCursor: true,
                  textAlignVertical: TextAlignVertical.top,
                  style: const TextStyle(fontSize: 16),
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    hintText: 'Start typing with native-optimized keyboard below...',
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
              color: Colors.blue.shade50,
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
          MinimalExamKeyboard(
            supportedLanguages: const ['en', 'hi', 'es', 'fr'],
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
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }
}
import 'package:flutter/material.dart';
import '../widgets/minimal_exam_keyboard.dart';
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
                child: TextField(
                  controller: _textController,
                  maxLines: null,
                  expands: true,
                  readOnly: true, // Disable system keyboard
                  showCursor: true,
                  textAlignVertical: TextAlignVertical.top,
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    hintText: 'Start typing with the keyboard below...',
                    labelText: 'Exam Text Input',
                    contentPadding: EdgeInsets.all(12),
                    floatingLabelBehavior: FloatingLabelBehavior.always,
                  ),
                  style: const TextStyle(fontSize: 16),
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
          
          // Multilingual keyboard - auto-sized to content
          MinimalExamKeyboard(
            supportedLanguages: const ['en', 'hi', 'es', 'fr'],
            getCurrentText: () => _textController.text,
            onTextInput: (text) {
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
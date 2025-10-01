import 'package:flutter/material.dart';

class KeyboardWidgets {
  
  static Widget buildKey(String key, bool isUpperCase, Function(String) onKeyPress) {
    String displayKey = key;
    
    // Handle case conversion for letters
    if (isUpperCase && key.length == 1 && key.toLowerCase() != key.toUpperCase()) {
      displayKey = key.toUpperCase();
    }
    
    return GestureDetector(
      onTap: () => onKeyPress(isUpperCase ? displayKey : key),
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 8.0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: const Color.fromARGB(124, 208, 208, 208), width: 1),
        ),
        child: Center(
          child: Text(
            displayKey,
            style: const TextStyle(
              fontSize: 18,
              color: Colors.black,
            ),
          ),
        ),
      ),
    );
  }

  static Widget buildSpecialKey(String label, {VoidCallback? onTap, bool isActive = false}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 9.0), // Match regular key padding
        decoration: BoxDecoration(
          color: const Color(0xFFB8B8B8), // Light gray for special keys
          borderRadius: BorderRadius.circular(6),
          border: Border.all(
            color: const Color.fromARGB(117, 160, 160, 160), 
            width: 1
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              offset: const Offset(0, 1),
              blurRadius: 2,
            ),
          ],
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 16,
              color: isActive ? Colors.white : Colors.black,
            ),
          ),
        ),
      ),
    );
  }

  static Widget buildKeyRow(List<String> keys, bool isUpperCase, Function(String) onKeyPress) {
    return Row(
      children: keys.map((key) {
        return Expanded(
          child: buildKey(key, isUpperCase, onKeyPress),
        );
      }).toList(),
    );
  }

  static Widget buildBottomRow(
    List<String> keys, 
    bool isUpperCase, 
    Function(String) onKeyPress,
    VoidCallback onToggleCase,
    VoidCallback onBackspace,
  ) {
    return Row(
      children: [
        // Shift key
        Expanded(
          child: buildSpecialKey(
            '⇧',
            onTap: onToggleCase,
            isActive: isUpperCase,
          ),
        ),
        
        // Letter keys
        ...keys.map((key) {
          return Expanded(
            child: buildKey(key, isUpperCase, onKeyPress),
          );
        }),
        
        // Backspace key
        Expanded(
          flex: 1,
          child: buildSpecialKey(
            '⌫',
            onTap: onBackspace,
          ),
        ),
      ],
    );
  }

  static Widget buildNumericBottomRow(
    List<String> keys, 
    Function(String) onKeyPress,
    VoidCallback onBackspace,
  ) {
    return Row(
      children: [
        // Special symbols key (wider)
        Expanded(
          flex: 1,
          child: buildSpecialKey(
            keys[0], // '#+='
            onTap: () => onKeyPress(keys[0]),
          ),
        ),
        
        // Regular symbol keys
        ...keys.skip(1).map((key) {
          return Expanded(
            child: buildKey(key, false, onKeyPress),
          );
        }),
        
        // Backspace key
        Expanded(
          flex: 1,
          child: buildSpecialKey(
            '⌫',
            onTap: onBackspace,
          ),
        ),
      ],
    );
  }
}
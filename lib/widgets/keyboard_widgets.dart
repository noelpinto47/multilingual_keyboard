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

  // Helper method to get shift key display text based on state
  static String _getShiftDisplayText(dynamic shiftState) {
    if (shiftState.toString().contains('capsLock')) {
      return '⇪'; // Caps lock symbol
    } else if (shiftState.toString().contains('single')) {
      return '⇧'; // Regular shift with dot for single mode
    } else {
      return '⇧'; // Regular shift
    }
  }
  
  // Helper method to get shift key color based on state
  static Color _getShiftKeyColor(dynamic shiftState, bool isActive) {
    if (shiftState.toString().contains('capsLock')) {
      return const Color(0xFF007AFF); // Bright blue for caps lock
    } else if (shiftState.toString().contains('single')) {
      return const Color(0xFF87CEEB); // Light blue for single tap
    } else {
      return const Color(0xFFB8B8B8); // Default gray
    }
  }
  
  // Helper method to get shift text color based on state
  static Color _getShiftTextColor(dynamic shiftState, bool isActive) {
    if (shiftState.toString().contains('capsLock')) {
      return Colors.white; // White text on blue background
    } else if (shiftState.toString().contains('single')) {
      return Colors.black; // Black text on light blue background
    } else {
      return Colors.black; // Default black
    }
  }
  
  // Helper method to get shift font weight based on state
  static FontWeight _getShiftFontWeight(dynamic shiftState) {
    if (shiftState.toString().contains('capsLock')) {
      return FontWeight.bold; // Bold for caps lock
    } else {
      return FontWeight.normal; // Normal weight
    }
  }
  
  static Widget buildSpecialKey(String label, {VoidCallback? onTap, bool isActive = false, dynamic shiftState}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 9.0), // Match regular key padding
        decoration: BoxDecoration(
          color: _getShiftKeyColor(shiftState, isActive),
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
              color: _getShiftTextColor(shiftState, isActive),
              fontWeight: _getShiftFontWeight(shiftState),
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
    VoidCallback onBackspace, {
    dynamic shiftState,
  }) {
    return Row(
      children: [
        // Shift key with three states
        Expanded(
          child: buildSpecialKey(
            _getShiftDisplayText(shiftState),
            onTap: onToggleCase,
            isActive: isUpperCase,
            shiftState: shiftState,
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
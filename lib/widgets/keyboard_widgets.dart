import 'package:flutter/material.dart';

class KeyboardWidgets {
  
  static Widget buildKey(String key, bool isUpperCase, Function(String) onKeyPress, {double? keyHeight}) {
    String displayKey = key;
    
    // Handle case conversion for letters
    if (isUpperCase && key.length == 1 && key.toLowerCase() != key.toUpperCase()) {
      displayKey = key.toUpperCase();
    }
    
    return GestureDetector(
      onTap: () => onKeyPress(isUpperCase ? displayKey : key),
      child: Container(
        height: keyHeight,
        padding: keyHeight == null ? const EdgeInsets.symmetric(vertical: 8.0) : null,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: const Color.fromARGB(124, 208, 208, 208), width: 1),
        ),
        child: Center(
          child: Text(
            displayKey,
            style: TextStyle(
              fontSize: keyHeight != null ? (keyHeight * 0.4).clamp(12.0, 18.0) : 18,
              fontWeight: FontWeight.normal,
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
  // static FontWeight _getShiftFontWeight(dynamic shiftState) {
  //   if (shiftState.toString().contains('capsLock')) {
  //     return FontWeight.bold; // Bold for caps lock
  //   } else {
  //     return FontWeight.normal; // Normal weight
  //   }
  // }
  
  static Widget buildSpecialKey(String label, {VoidCallback? onTap, bool isActive = false, dynamic shiftState, double? keyHeight}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: keyHeight,
        padding: keyHeight == null ? const EdgeInsets.symmetric(vertical: 8.0) : null,
        decoration: BoxDecoration(
          color: _getShiftKeyColor(shiftState, isActive),
          borderRadius: BorderRadius.circular(6),
          border: Border.all(
            color: const Color.fromARGB(125, 249, 249, 249), 
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
          child: FittedBox(
            child: Text(
              label,
              style: TextStyle(
                fontSize: keyHeight != null ? (keyHeight * 0.35).clamp(10.0, 16.0) : 16,
                color: _getShiftTextColor(shiftState, isActive),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
      ),
    );
  }

  static Widget buildKeyRow(List<String> keys, bool isUpperCase, Function(String) onKeyPress, {double? keyHeight}) {
    return Row(
      children: keys.map((key) {
        return Expanded(
          child: buildKey(key, isUpperCase, onKeyPress, keyHeight: keyHeight),
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
    double? keyHeight,
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
            keyHeight: keyHeight,
          ),
        ),
        
        // Letter keys
        ...keys.map((key) {
          return Expanded(
            child: buildKey(key, isUpperCase, onKeyPress, keyHeight: keyHeight),
          );
        }),
        
        // Backspace key
        Expanded(
          flex: 1,
          child: buildSpecialKey(
            '⌫',
            onTap: onBackspace,
            keyHeight: keyHeight,
          ),
        ),
      ],
    );
  }

  static Widget buildNumericBottomRow(
    List<String> keys, 
    Function(String) onKeyPress,
    VoidCallback onBackspace, {
    double? keyHeight,
  }) {
    return Row(
      children: [
        // Special symbols key (wider)
        Expanded(
          flex: 1,
          child: buildSpecialKey(
            keys[0], // '#+='
            onTap: () => onKeyPress(keys[0]),
            keyHeight: keyHeight,
          ),
        ),
        
        // Regular symbol keys
        ...keys.skip(1).map((key) {
          return Expanded(
            child: buildKey(key, false, onKeyPress, keyHeight: keyHeight),
          );
        }),
        
        // Backspace key
        Expanded(
          flex: 1,
          child: buildSpecialKey(
            '⌫',
            onTap: onBackspace,
            keyHeight: keyHeight,
          ),
        ),
      ],
    );
  }
}
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:multilingual_keyboard/widgets/minimal_exam_keyboard.dart';
import '../constants/app_colors.dart';

class KeyboardWidgets {
  
  static Widget buildKey(String key, bool isUpperCase, Function(String) onKeyPress, {double? keyHeight}) {
    String displayKey = key;
    
    // Handle case conversion for letters
    if (isUpperCase && key.length == 1 && key.toLowerCase() != key.toUpperCase()) {
      displayKey = key.toUpperCase();
    }
    
    return Material(
      color: AppColors.keyBackground,
      borderRadius: BorderRadius.circular(6),
      elevation: 1,
      child: InkWell(
        onTap: () => onKeyPress(isUpperCase ? displayKey : key),
        borderRadius: BorderRadius.circular(6),
        splashColor: AppColors.keySplashWithAlpha,
        highlightColor: AppColors.keyHighlightWithAlpha,
        child: Container(
          height: keyHeight,
          padding: keyHeight == null ? const EdgeInsets.symmetric(vertical: 8.0) : null,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: AppColors.keyBorder, width: 1),
          ),
          child: Center(
            child: Text(
              displayKey,
              style: TextStyle(
                fontSize: keyHeight != null ? (keyHeight * 0.4).clamp(12.0, 18.0) : 18,
                fontWeight: FontWeight.normal,
                color: AppColors.keyText,
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Helper method to get shift key icon path based on state
  static String _getShiftIconPath(dynamic shiftState) {
    if (shiftState.toString().contains('capsLock')) {
      return 'assets/icons/caps-lock-hold.svg'; // Caps lock enabled
    } else if (shiftState.toString().contains('single')) {
      return 'assets/icons/caps-lock-enabled.svg'; // Single tap - hold state
    } else {
      return 'assets/icons/default-caps-lock-off.svg'; // Default off state
    }
  }
  
  // Helper method to get shift text color based on state
  static Color _getShiftTextColor(dynamic shiftState, bool isActive) {
    if (shiftState == 2) {
      return AppColors.textOnPrimary; // White text on blue background
    } else if (shiftState == 1) {
      return AppColors.textOnLight; // Black text on light blue background
    }
      return AppColors.textOnLight; // Default black
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
    final keyColor = AppColors.specialKeyDefault;
    return Material(
      color: keyColor,
      borderRadius: BorderRadius.circular(6),
      elevation: 1,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(6),
        splashColor: AppColors.specialKeySplashWithAlpha,
        highlightColor: AppColors.specialKeyHighlightWithAlpha,
        child: Container(
          height: keyHeight,
          padding: keyHeight == null ? const EdgeInsets.symmetric(vertical: 8.0) : null,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(6),
            border: Border.all(
              color: AppColors.specialKeyBorder, 
              width: 1
            ),
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
      ),
    );
  }

  // Special method for building shift key with SVG icons
  static Widget buildShiftKey({VoidCallback? onTap, bool isActive = false, dynamic shiftState, double? keyHeight}) {
    final keyColor = AppColors.specialKeyDefault;
    final iconPath = _getShiftIconPath(shiftState);
    
    return Material(
      color: keyColor,
      borderRadius: BorderRadius.circular(6),
      elevation: 1,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(6),
        splashColor: AppColors.specialKeySplashWithAlpha,
        highlightColor: AppColors.specialKeyHighlightWithAlpha,
        child: Container(
          height: keyHeight,
          padding: keyHeight == null ? const EdgeInsets.symmetric(vertical: 8.0) : null,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(6),
            border: Border.all(
              color: AppColors.specialKeyBorder, 
              width: 1
            ),
          ),
          child: Center(
            child: SvgPicture.asset(
              iconPath,
              width: shiftState is ShiftState && shiftState == ShiftState.capsLock ? 12 : 8,
              height: shiftState is ShiftState && shiftState == ShiftState.capsLock ? 12 : 8,
              colorFilter: shiftState == ShiftState.off 
                  ? ColorFilter.mode(Colors.black26, BlendMode.srcIn)
                  : null,
            ),
          ),
        ),
      ),
    );
  }

  // Special method for building layout switcher key (for non-English keyboards)
  static Widget buildLayoutSwitcherKey({VoidCallback? onTap, required String layoutPageText, double? keyHeight}) {
    return Material(
      color: AppColors.specialKeyDefault,
      borderRadius: BorderRadius.circular(6),
      elevation: 1,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(6),
        splashColor: AppColors.specialKeySplashWithAlpha,
        highlightColor: AppColors.specialKeyHighlightWithAlpha,
        child: Container(
          height: keyHeight,
          padding: keyHeight == null ? const EdgeInsets.symmetric(vertical: 8.0) : null,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(6),
            border: Border.all(
              color: AppColors.specialKeyBorder, 
              width: 1
            ),
          ),
          child: Center(
            child: Text(
              layoutPageText,
              style: TextStyle(
                fontSize: keyHeight != null ? (keyHeight * 0.35).clamp(10.0, 16.0) : 16,
                color: AppColors.textOnLight,
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
    String? currentLanguage,
    String? layoutPageText,
  }) {
    return Row(
      children: [
        // Shift key for English, Layout switcher for other languages
        Expanded(
          child: (currentLanguage == 'en') 
            ? buildShiftKey(
                onTap: onToggleCase,
                isActive: isUpperCase,
                shiftState: shiftState,
                keyHeight: keyHeight,
              )
            : buildLayoutSwitcherKey(
                onTap: onToggleCase,
                layoutPageText: layoutPageText ?? '1/4',
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
            onTap: () {
              if (keys[0].contains('more')) {
                return;
              } else {
                onKeyPress(keys[0]);
              }
            },
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
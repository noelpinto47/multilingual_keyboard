class KeyboardLayout {
  static List<List<String>> getLayoutForLanguage(String lang) {
    // Letter-only keyboard layout (numbers removed)
    switch (lang) {
      case 'en':
        return [
          ['q','w','e','r','t','y','u','i','o','p'],
          ['a','s','d','f','g','h','j','k','l'],
          ['z','x','c','v','b','n','m']
        ];
      case 'hi': // Hindi (Devanagari)
        return [
          ['क','ख','ग','घ','ङ','च','छ','ज','झ','ञ'],
          ['ट','ठ','ड','ढ','ण','त','थ','द','ध','न'],
          ['प','फ','ब','भ','म','य','र','ल','व']
        ];
      case 'es': // Spanish
        return [
          ['q','w','e','r','t','y','u','i','o','p'],
          ['a','s','d','f','g','h','j','k','l','ñ'],
          ['z','x','c','v','b','n','m']
        ];
      case 'fr': // French
        return [
          ['a','z','e','r','t','y','u','i','o','p'],
          ['q','s','d','f','g','h','j','k','l','m'],
          ['w','x','c','v','b','n']
        ];
      default:
        return [];
    }
  }
  
  static List<List<String>> getNumericLayout() {
    // Numeric and symbol layout like in the image
    return [
      ['1','2','3','4','5','6','7','8','9','0'],
      ['-','/',':', ';','(',')','£','&','@','"'],
      ['#+=','.', ',','?','!','\''],
    ];
  }
  
  static String getLanguageName(String code) {
    switch (code) {
      case 'en': return 'English';
      case 'hi': return 'हिंदी';
      case 'es': return 'Español';
      case 'fr': return 'Français';
      default: return code.toUpperCase();
    }
  }
}
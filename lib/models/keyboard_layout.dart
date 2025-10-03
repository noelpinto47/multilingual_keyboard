class KeyboardLayout {
  // List of supported language codes
  static const List<String> supportedLanguages = ['en', 'hi', 'mr'];

  static List<List<String>> getLayoutForLanguage(String lang) {
    // Letter-only keyboard layout (numbers removed)
    switch (lang) {
      case 'en':
        return [
          ['1','2','3','4','5','6','7','8','9','0'],
          ['q','w','e','r','t','y','u','i','o','p'],
          ['a','s','d','f','g','h','j','k','l'],
          ['z','x','c','v','b','n','m']
        ];
      case 'hi': // Hindi (Devanagari)
        return [
          ['1','2','3','4','5','6','7','8','9','0'],
          ['क','ख','ग','घ','ङ','च','छ','ज','झ','ञ'],
          ['ट','ठ','ड','ढ','ण','त','थ','द','ध','न'],
          ['प','फ','ब','भ','म','य','र','ल','व']
        ];
      case 'mr': // Marathi (Devanagari)
        return [
          ['1','2','3','4','5','6','7','8','9','0'],
          ['क','ख','ग','घ','ङ','च','छ','ज','झ','ञ'],
          ['ट','ठ','ड','ढ','ण','त','थ','द','ध','न'],
          ['प','फ','ब','भ','म','य','र','ल','व']
        ];
      default:
        return [];
    }
  }
  
  static List<List<String>> getNumericLayout() {
    // Numeric and symbol layout with numbers row first, then symbols
    return [
      ['1','2','3','4','5','6','7','8','9','0'],
      ['@','#','\$','_','&','-','+','(',')','/',],
      ['*','"','\'',':',';','!','?','~','<','>'],
      ['more','=','{','}','[',']','\\','%','^'],
    ];
  }
  
  static String getLanguageName(String code) {
    switch (code) {
      case 'en': return 'English';
      case 'hi': return 'हिंदी';
      case 'mr': return 'मराठी';
      default: return code.toUpperCase();
    }
  }
}
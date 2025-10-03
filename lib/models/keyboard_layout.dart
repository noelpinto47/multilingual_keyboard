class KeyboardLayout {
  // List of supported language codes
  static const List<String> supportedLanguages = ['en', 'hi', 'mr'];

  static List<List<String>> getLayoutForLanguage(String lang, {int page = 0, String? selectedLetter}) {
    switch (lang) {
      case 'en':
        return [
          ['1','2','3','4','5','6','7','8','9','0'],
          ['q','w','e','r','t','y','u','i','o','p'],
          ['a','s','d','f','g','h','j','k','l'],
          ['z','x','c','v','b','n','m']
        ];
      case 'hi': // Hindi (Devanagari) - Multiple pages
        return _getHindiLayoutPage(page, selectedLetter: selectedLetter);
      case 'mr': // Marathi (Devanagari) - Multiple pages  
        return _getMarathiLayoutPage(page, selectedLetter: selectedLetter);
      default:
        return [];
    }
  }

  static List<List<String>> _getHindiLayoutPage(int page, {String? selectedLetter}) {
    switch (page) {
      case 0: // Page 1/4 - Dynamic top row + consonants
        final topRow = selectedLetter != null && isConsonant(selectedLetter, 'hi')
            ? getVowelAttachments(selectedLetter, 'hi')
            : getMainVowels('hi');
        
        // Dynamic second row - replace '़','ं' when consonant is selected
        List<String> secondRow = ['क','ख','ग','घ','च','छ','ज','झ','़','ं'];
        if (selectedLetter != null && isConsonant(selectedLetter, 'hi')) {
          final attachments = getSecondRowAttachments(selectedLetter, 'hi');
          secondRow = ['क','ख','ग','घ','च','छ','ज','झ', attachments[0], attachments[1]];
        }
        
        // Dynamic last row - replace 'ऋ','्' when consonant is selected
        List<String> lastRow = ['ष','स','ह','ज्ञ','क्ष','श्र','ऋ','्'];
        if (selectedLetter != null && isConsonant(selectedLetter, 'hi')) {
          final attachments = getLastRowAttachments(selectedLetter, 'hi');
          lastRow = ['ष','स','ह','ज्ञ','क्ष','श्र', attachments[0], attachments[1]];
        }
        
        return [
          topRow,
          secondRow,
          ['ट','ठ','ड','ढ','ण','त','थ','द','ध','न'],
          ['प','फ','ब','भ','म','य','र','ल','व','श'],
          lastRow
        ];
      case 1: // Page 2/4 - Matras (vowel signs)
        return [
          ['ा','ि','ी','ु','ू','े','ै','ो','ौ','्'],
          ['क','का','कि','की','कु','कू','के','कै','को','कौ'],
          ['त','ता','ति','ती','तु','तू','ते','तै','तो','तौ'],
          ['म','मा','मि','मी','मु','मू','मे','मै','मो','मौ'],
          ['र','रा','रि','री','रु','रू','रे','रै','रो','रौ']
        ];
      case 2: // Page 3/4 - Numbers and special characters
        return [
          ['१','२','३','४','५','६','७','८','९','०'],
          ['।','॥','ॐ','₹','%','@','#','&','*','('],
          [')','[',']','{','}','-','+','=','<','>'],
          ['/','\\','|','_','^','~','`','\'','"',':'],
          [';',',','.','?','!','॰','॑','॒','॓','॔']
        ];
      case 3: // Page 4/4 - Additional conjuncts and rare characters
        return [
          ['त्र','क्ष','ज्ञ','श्र','द्य','द्व','स्व','ह्म','ह्न','ह्व'],
          ['क्क','ग्ग','च्च','ज्ज','ट्ट','ड्ड','त्त','द्द','प्प','ब्ब'],
          ['म्म','य्य','र्र','ल्ल','व्व','श्श','ष्ष','स्स','ह्ह','न्न'],
          ['ङ्ग','ञ्ज','ण्ड','न्त','म्प','म्ब','म्भ','ल्य','व्य','ह्य'],
          ['ऌ','ॡ','ॲ','ॅ','ऑ','ॉ','ॎ','ॏ','ॠ','ॄ']
        ];
      default:
        return _getHindiLayoutPage(0, selectedLetter: selectedLetter);
    }
  }

  static List<List<String>> _getMarathiLayoutPage(int page, {String? selectedLetter}) {
    switch (page) {
      case 0: // Page 1/4 - Basic Marathi layout with dynamic top row
        final topRow = selectedLetter != null && isConsonant(selectedLetter, 'mr')
            ? getVowelAttachments(selectedLetter, 'mr')
            : getMainVowels('mr');
        
        return [
          topRow,
          ['क','ख','ग','घ','ङ','च','छ','ज','झ','ञ'],
          ['ट','ठ','ड','ढ','ण','त','थ','द','ध','न'],
          ['प','फ','ब','भ','म','य','र','ल','व','श'],
          ['ष','स','ह','ळ','क्ष','ज्ञ','त्र','्','ं','ः']
        ];
      case 1: // Page 2/4 - Matras for Marathi
        return [
          ['ा','ि','ी','ु','ू','े','ै','ो','ौ','्'],
          ['क','का','कि','की','कु','कू','के','कै','को','कौ'],
          ['त','ता','ति','ती','तु','तू','ते','तै','तो','तौ'],
          ['म','मा','मि','मी','मु','मू','मे','मै','मो','मौ'],
          ['ळ','ळा','ळि','ळी','ळु','ळू','ळे','ळै','ळो','ळौ']
        ];
      case 2: // Page 3/4 - Numbers and symbols
        return [
          ['१','२','३','४','५','६','७','८','९','०'],
          ['।','॥','ॐ','₹','%','@','#','&','*','('],
          [')','[',']','{','}','-','+','=','<','>'],
          ['/','\\','|','_','^','~','`','\'','"',':'],
          [';',',','.','?','!','॰','॑','॒','॓','॔']
        ];
      case 3: // Page 4/4 - Marathi specific conjuncts
        return [
          ['त्र','क्ष','ज्ञ','श्र','द्य','द्व','स्व','ह्म','ळ्ह','ळ्य'],
          ['क्क','ग्ग','च्च','ज्ज','ट_ट','ड_ड','त्त','द्द','प्प','ब्ब'],
          ['म्म','य्य','र्र','ल्ल','व्व','श्श','ष्ष','स्स','ह्ह','न्न'],
          ['ङ्ग','ञ्ज','ण्ड','न्त','म्प','म्ब','म्भ','ळ्य','व्य','ह्य'],
          ['ऌ','ॡ','ॲ','ॅ','ऑ','ॉ','ॎ','ॏ','ॠ','ॄ']
        ];
      default:
        return _getMarathiLayoutPage(0);
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
  
  // Generate vowel attachments for a given consonant
  static List<String> getVowelAttachments(String consonant, String language) {
    if (language == 'hi' || language == 'mr') {
      return [
        consonant,                    // Pure consonant (with inherent 'a')
        '$consonantा',             // aa
        '$consonantि',             // i
        '$consonantी',             // ii
        '$consonantु',             // u
        '$consonantू',             // uu
        '$consonantे',             // e
        '$consonantै',             // ai
        '$consonantो',             // o
        '$consonantौ',             // au
      ];
    }
    return [];
  }

  // Generate second row attachments for a given consonant
  static List<String> getSecondRowAttachments(String consonant, String language) {
    if (language == 'hi' || language == 'mr') {
      // Return consonant with nukta and consonant with anusvara
      return [
        '$consonant़',             // Consonant with nukta
        '$consonantं',             // Consonant with anusvara
      ];
    }
    return ['़', 'ं']; // Default values
  }

  // Generate last row attachments for a given consonant
  static List<String> getLastRowAttachments(String consonant, String language) {
    if (language == 'hi' || language == 'mr') {
      // Return consonant with halant and consonant with ri vowel
      return [
        '$consonantृ',             // Consonant with ri vowel
        '$consonant्',             // Consonant with halant (virama)
      ];
    }
    return ['ऋ', '्']; // Default values
  }

  // Get main vowels (when no letter is selected)
  static List<String> getMainVowels(String language) {
    if (language == 'hi' || language == 'mr') {
      return ['अ','आ','इ','ई','उ','ऊ','ए','ऐ','ओ','औ'];
    }
    return [];
  }

  // Check if a character is a consonant that can take vowel attachments
  static bool isConsonant(String char, String language) {
    if (language == 'hi' || language == 'mr') {
      // List of common Devanagari consonants
      const consonants = [
        'क','ख','ग','घ','ङ','च','छ','ज','झ','ञ',
        'ट','ठ','ड','ढ','ण','त','थ','द','ध','न',
        'प','फ','ब','भ','म','य','र','ल','व','श',
        'ष','स','ह','ळ'
      ];
      return consonants.contains(char);
    }
    return false;
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
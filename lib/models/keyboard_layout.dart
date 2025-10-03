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
        List<String> secondRow = ['क','ख','ग','घ','ड़','च','छ','ज','झ','़','ं'];
        if (selectedLetter != null && isConsonant(selectedLetter, 'hi')) {
          final attachments = getSecondRowAttachments(selectedLetter, 'hi');
          secondRow = ['क','ख','ग','घ','ड़','च','छ','ज','झ',attachments[0], attachments[1]];
        }
        
        // Dynamic last row - replace 'ऋ','्' when consonant is selected
        List<String> lastRow = ['स','ह','ज्ञ','क्ष','त्र','श्र','ऋ','्'];
        if (selectedLetter != null && isConsonant(selectedLetter, 'hi')) {
          final attachments = getLastRowAttachments(selectedLetter, 'hi');
          lastRow = ['स','ह','ज्ञ','क्ष','त्र','श्र', attachments[0], attachments[1]];
        }
        
        return [
          topRow,
          secondRow,
          ['ट','ठ','ड','ढ','ण','त','थ','द','ध','न', 'ञ'],
          ['प','फ','ब','भ','म','य','र','ल','व','श', 'ष'],
          lastRow
        ];
      case 1: // Page 2/4 - Conjunct consonants
        return [
          ['ज्ञ','त्र','स्त','स्त','ड्ड','ज्ज','श्र','क्र','ग्र','द्र'],
          ['ध्र','प्र','ब्र','भ्र','म्र','फ्र','व्र','त्क','त्त','ह्म'],
          ['र्र', 'स्व', 'ह', 'र्क', 'र्ग', 'र्च', 'र्ज', 'र्त', 'र्थ', 'र्द'],
          ['र्न', 'र्म', 'र्श', 'र्ष', 'र्स', 'र्प', 'त्थ', 'त्स', 'त', 'त्य'],
          ['त्व', 'द्द', 'द्ध', 'द्ब', 'द्भ', 'द्य', 'द्र', 'द्व']
        ];
      case 2: // Page 3/4 - Advanced conjunct consonants
        return [
          ['ट्','ख्','य्','रख्','ज्य','त्य','ध्य','प्य','भ्र','ल्य'],
          ['व्य','प्य','स्य','न्त','न्त','न्थ','न्द','त्र','न्य','न्ह'],
          ['म्च','स्त','स्न','स्प','स्ब','म्म','म्य','म्ह','एड','एत'],
          ['पा','प्ल','बज','बद','ब्ब','ब्ल','ध्न','प्त','श्र','श्व'],
          ['ल्ट','ल्प','ल्ब','ल्ह','ष','ष्ण','ष्प','ष्क']
        ];
      case 3: // Page 4/4 - Special vowels and symbols
        return [
          ['ऍ','ऑ','ऐ','ओ','औ','अं','अः','अ','आ','ऋ'],
          ['ॅ','ॉ','ै','ो','ौ','ं','ः','ऺ','ऻ','ॄ'],
          ['ल्','ल्ल','जै','ज्ञ','ज्ञ','स','ग','ज्ञ','ड्ड','ब'],
          ['ऴ','ऴ','ऻ','ॅ','ॉ','?','न','र','ळ','ळ'],
          ['०','\\\\','\'','।','॰','\$','॥','ॐ']
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
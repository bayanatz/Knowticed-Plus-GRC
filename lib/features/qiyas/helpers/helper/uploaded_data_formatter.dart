import 'package:knowticed_plus/core/custom/helpers/date_time_in_arabic.dart';

abstract class UploadedDataFormatter {
  /// function name: [formatCustomText]
  ///
  /// purpose: Formats the input string by replacing special patterns `{}`, `<>`, and `**` with numbered items,
  ///          Arabic letters, and bullet points respectively.
  ///
  /// parameters: [String input] - The input string to format.
  ///
  /// return type: [String] - The formatted string.
  static String formatCustomText(String input) {
    int numberCounter = 1;
    int letterCounter = 0;
    List<String> arabicLetters = [
      'أ',
      'ب',
      'ج',
      'د',
      'هـ',
      'و',
      'ز',
      'ح',
      'ط',
      'ي'
    ];

    String text = input.trim();

    // Replace {} with numbers
    bool firstMatch = true;
    text = text.replaceAllMapped(RegExp(r'\{(.*?)\}'), (match) {
      String content = match.group(1)!;
      String finalNumber =
          '${firstMatch ? '' : '\n'}${englishArabicNumber(numberCounter.toString())}. $content';
      firstMatch = false;
      numberCounter++;
      return finalNumber;
    });

    // Replace <> with Arabic letters
    text = text.replaceAllMapped(RegExp(r'\<(.*?)\>'), (match) {
      String content = match.group(1)!;
      String letter = arabicLetters[letterCounter++ % arabicLetters.length];
      return '\n   $letter. $content';
    });

    // Replace ** ** with bullet points
    text = text.replaceAllMapped(RegExp(r'\*(.*?)\*', dotAll: true), (match) {
      String content = match.group(1)!;

      if (firstMatch) {
        firstMatch = false;
        return '• $content';
      } else {
        return '\n• $content';
      }
    });
    return text;
  }
}

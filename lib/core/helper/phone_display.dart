/// Module: core / helper
///
///*************************** FILE INFO ****************************///
/// File Name: phone_display.dart
/// Description: The one way to SHOW a phone number: "+20 1001234567".
/// Author: Moataz Handousa
/// Created at: 18/10/2026
///
/// Country codes are stored both as "20" and "+20" across the data, so some
/// screens printed "++20 …" (they added a '+') and others "20 …" (they did
/// not). Every screen now formats through here: exactly one '+'.
library;

/// `+code number`, the number alone when there is no code, '-' when
/// both are empty. [code] and [number] may be a String or a one-item List
/// (Firestore history arrays).
String kpPhoneDisplay(Object? code, Object? number) {
  String clean(Object? v) {
    if (v is List) v = v.isEmpty ? null : v.last;
    final String s =
        (v ?? '').toString().replaceAll(RegExp(r'[\[\]]'), '').trim();
    return s == 'null' ? '' : s;
  }

  final String digits = clean(code).replaceFirst(RegExp(r'^\++'), '');
  final String n = clean(number);
  if (digits.isEmpty && n.isEmpty) return '-';
  if (digits.isEmpty) return n;
  // U+200E keeps "+20 100…" in this order inside Arabic (RTL) text.
  if (n.isEmpty) return '\u200E+$digits';
  return '\u200E+$digits $n';
}

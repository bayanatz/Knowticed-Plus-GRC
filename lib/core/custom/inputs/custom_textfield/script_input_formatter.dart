/// Module: core/custom
///
///*************************** FILE INFO ****************************///
/// File Name: script_input_formatter.dart
/// Description: `_ScriptInputFormatter`, `_CapitalizeTextFormatter` — split out of `2-custom_textfield.dart`.
/// Author: Amr Mesbah
/// Created at: 11/10/2026

part of '../custom_textfield.dart';

// Split from 2-custom_textfield.dart to keep every file under 700 lines.

/// Refuses edits that ADD a character of the wrong script.
///
/// WHY "ADD" AND NOT "CONTAIN"
/// ---------------------------
/// 12/8/2026: both formatters used to reject any value CONTAINING a foreign
/// character, which locks a field that is already holding one — a record saved
/// before the field was restricted, or a resumed draft. Every edit of such a
/// field, backspace included, produces a value that still contains the foreign
/// character, so the rejection fires on the correction as well as on the
/// mistake and the box stops responding entirely with no way for the user to
/// find out why.
///
/// Counting instead of testing keeps the rule the user actually wants ("this
/// box will not take English") while leaving the exit open: an edit that leaves
/// the same number of foreign characters or fewer goes through, so text already
/// there can always be selected, typed over, or deleted.
///
/// Rejecting rather than stripping is deliberate. Silently dropping the Latin
/// half of a pasted "Sales قسم" leaves the user with a value they did not check
/// and did not intend; refusing the paste keeps the clipboard intact so they
/// can put it in the field it belongs to.
abstract class _ScriptInputFormatter extends TextInputFormatter {
  _ScriptInputFormatter(this._foreign);

  final RegExp _foreign;

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final int added = _count(newValue.text) - _count(oldValue.text);
    return added > 0 ? oldValue : newValue;
  }

  int _count(String text) => _foreign.allMatches(text).length;
}

/// Capitalises the first letter of every word.
class _CapitalizeTextFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (newValue.text.isEmpty) return newValue;

    final capitalizedText = newValue.text.split(' ').map((word) {
      if (word.isEmpty) return word;
      if (word.length == 1) return word.toUpperCase();
      return word[0].toUpperCase() + word.substring(1).toLowerCase();
    }).join(' ');

    return TextEditingValue(
      text: capitalizedText,
      selection: TextSelection.collapsed(offset: capitalizedText.length),
    );
  }
}

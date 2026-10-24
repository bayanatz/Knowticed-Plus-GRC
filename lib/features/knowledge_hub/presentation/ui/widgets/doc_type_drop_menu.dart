/// Module: knowledge_hub/presentation/ui/widgets
///
///*************************** FILE INFO ****************************///
/// File Name: doc_type_drop_menu.dart
/// Description: `docTypeDropMenu()`.
/// Author: Amr Mesbah
/// Created at: 06/10/2026
library;

import 'package:flutter/material.dart';

import 'package:knowticed_plus/generated/l10n.dart';
import 'package:knowticed_plus/core/custom/dropdowns/custom_dropdown.dart';

Widget docTypeDropMenu(
  BuildContext context, {
  required String dropDownMenuText,
  bool isMobile = true,
  required void Function(String?) onChanged,
}) {
  List<Map<String, String>> selectStatusList = [
    {"key": "Presentation", "value": S.of(context).presentation},
    {"key": "Form", "value": S.of(context).form},
    {"key": "Report", "value": S.of(context).report},
    {"key": "Booklet", "value": S.of(context).booklet},
    {"key": "Video Recording", "value": S.of(context).video_recording},
    {"key": "Letter", "value": S.of(context).letter},
    {"key": "Mandate", "value": S.of(context).mandate},
    {"key": "Policy", "value": S.of(context).policy},
    {"key": "Frame work", "value": S.of(context).framework},
    {"key": "Workshop", "value": S.of(context).workshop},
    {"key": "Guidlines", "value": S.of(context).guidelines},
    {"key": "Other", "value": S.of(context).other},
  ];

  // This used to be wrapped in `SizedBox(height: 36)`.
  // When `label` is set, CustomDropdown returns a Column of
  // [label, 6sp gap, trigger] — roughly 63pt tall — so clamping the WHOLE
  // widget to 36 produced the "BOTTOM OVERFLOWED BY 27 PIXELS" stripe under
  // "Document Type" on the Creating Knowledge Hub screen.
  //
  // `height` is the parameter meant for this: CustomDropdown applies it to
  // the trigger alone (see `_sized`), leaving the label to size itself.
  //
  // `key: ValueKey(dropDownMenuText)` removed. Keying the
  // dropdown off its own selected value threw the widget's State away on every
  // pick — the parent's setState changed the key, so the State that had just
  // started closing the menu was disposed mid-animation, stranding the menu's
  // full-screen dismiss layer over the app in release builds. See the note on
  // `_removeOverlayEntry` in 1-custom_dropdown.dart. CustomDropdown reads
  // `value` on rebuild; the key was never needed.
  return CustomDropdown<String>(
    value: dropDownMenuText,
    items: selectStatusList
        .map(
          (e) => DropdownItem<String>(
            value: e['key'] ?? '',
            label: e['value'] ?? '',
          ),
        )
        .toList(),
    onChanged: (v) => onChanged(v),
    label: S.of(context).document_type,
    hint: S.of(context).choose_type,
    height: 36,
  );
}

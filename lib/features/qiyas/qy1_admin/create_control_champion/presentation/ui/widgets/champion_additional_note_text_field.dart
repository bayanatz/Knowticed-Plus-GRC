/// ***************************** FILE INFO ***************************** ///
/// File Name: owner_additional_note_text_field.dart
/// Purpose: Provides a text field for adding additional notes in the "Digital Transformation Ambassador" form.
/// Author: Abdelrahman Sobhy
/// Created At: Apr/21/2025
/// Description: This widget creates a text field for entering additional notes with a title, hint text, and custom styling based on the app's theme.
///              It also includes an update mechanism through the controller to manage form data dynamically.
/// ********************************************************************* ///
library;

import 'package:flutter/material.dart';
import 'package:knowticed_plus/core/custom/inputs/custom_textfield.dart';
import 'package:knowticed_plus/features/qiyas/qy1_admin/create_control_champion/presentation/controller/qiyas_create_champion_controller_cubit.dart';

import 'package:knowticed_plus/features/qiyas/qiyas_get_it.dart';
import 'package:knowticed_plus/features/qiyas/qy1_admin/create_control_core/presentation/controller/control_core_cubit.dart';

class ChampionAdditionalNoteTextField extends StatelessWidget {
  ChampionAdditionalNoteTextField({super.key, required this.index});
  final QiyasCreateChampionControllerCubit controller = sl();
  final int index;

  @override
  Widget build(BuildContext context) {
    return CustomTextField(
      label: "ملاحظة إضافية",
      hint: "اكتب هنا",
      maxLines: 3,
      height: 72,
      maxLength: 500,
      showCharCount: true,
      textDirection: TextDirection.rtl,
      controller: controller.notesControllersList[index],
      onChanged: (_) {
        controller.emitState(VisionsDataChanged());
      },
    );
  }
}

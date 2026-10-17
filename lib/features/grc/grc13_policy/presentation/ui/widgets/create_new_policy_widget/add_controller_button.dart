/// Module: GRC Policy Management
/// Description: "+ Add Controller" button shown on the Create Policy preview
///              step when there are no touched controls yet.
/// Author: Mohamed Magdy Abdelkhalek
/// Date: 2026-07-16
/// Dependencies: Flutter SDK, AppColors, StyleText, customButtonWithSvg
/// Revision History: 2026-07-16 - Extracted from create_new_policy.dart
library;

import 'package:flutter/material.dart';
import 'package:grc_module/core/custom/buttons/custom_black_button.dart';
import 'package:grc_module/generated/l10n.dart';

/// class name: [AddControllerButton]
///
/// purpose: sends the user back to step 1 (Controls) so they can add one,
///          matching the "+ Control" button styling used there.
///
/// authors: Mohamed Magdy Abdelkhalek
///
/// created at: 16/7/2026
class AddControllerButton extends StatelessWidget {
  final VoidCallback onPressed;

  const AddControllerButton({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      // CHANGED 17/10/2026: the shared black button.
      child: customBlackButton(
        title: S.of(context).addController,
        image: 'assets/icons_assets/main_icons_assets/ic_action_plus.svg',
        function: onPressed,
      ),
    );
  }
}

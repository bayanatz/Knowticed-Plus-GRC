/// Module: knowledge_hub/kh1_create_new_knowledge/presentation/ui/widgets
/// ************************* FILE INFO *************************** ///
/// File Name: action_buttons.dart
/// Description: Widget for action buttons (Discard & Submit)
/// Author: Amr Mesbah
/// Created at: 22/10/2025
/// Updated: 22/9/2026 - The submit label follows KnowledgeHubAccess, and
///          distinguishes creating (Create_Without_Need_Approval) from
///          editing (Edit_Document_Without_Approval).
library;

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:knowticed_plus/generated/l10n.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/features/knowledge_hub/helpers/knowledge_hub_permissions.dart';
import 'package:knowticed_plus/core/custom/buttons/custom_button.dart';
import 'package:knowticed_plus/core/extensions/context_extensions.dart';

class ActionButtonsSection extends StatelessWidget {
  final VoidCallback onDiscard;
  final VoidCallback onSubmit;
  final bool isFormComplete;

  /// Whether the page is editing an existing document rather than creating a
  /// new one. The button label has to name what the tap
  /// does, and creating and editing are now governed by different permissions.
  final bool isEditing;

  const ActionButtonsSection({
    super.key,
    required this.onDiscard,
    required this.onSubmit,
    this.isFormComplete = false,
    this.isEditing = false,
  });

  /// Whether THIS submission skips the approval queue.
  ///
  /// This asked `editDocumentWithoutApproval` for both
  /// cases, so on a NEW document the button read "Submit" (publishes directly)
  /// for anyone who could edit without approval, while the document itself is
  /// now correctly queued. Label and outcome have to come from the same
  /// question, so both go through [KnowledgeHubAccess] — the same source
  /// `_getKnowledgeStatus` uses.
  bool _publishesDirectly() => isEditing
      ? KnowledgeHubAccess.editAccess.publishesDirectly
      : KnowledgeHubAccess.createsWithoutApproval;

  @override
  Widget build(BuildContext context) {
    final isMobile = ContextExtension(context).isPhone;
    Theme.of(context).brightness == Brightness.light;

    // ✅ Check permission
    final bool publishesDirectly = _publishesDirectly();

    // The "without approval" branch said `save`, so a user who
    // CAN publish without approval saw a button labelled "Save" while the tap
    // actually submitted the document (status `approved`, no supervisor
    // notification — see _getKnowledgeStatus in creating_knowledge_hub.actions).
    // The label now names what the tap does in both branches:
    //   permission ON  → "Submit"              (goes live immediately)
    //   permission OFF → "Submit For Approval" (queued for a supervisor)
    final String submitButtonText = publishesDirectly
        ? S
              .of(context)
              .submit // Publishes directly, no approval step
        : S.of(context).submit_for_approval; // Requires approval

    return Row(
      textDirection: TextDirection
          .ltr, // X-73: Cancel left, action right in both languages

      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        customButton(
          height: 38.h,
          width: isMobile ? 150.w : 185.w,
          title: S.of(context).discard,
          textStyle: StyleText.fontSize16Weight500.copyWith(
            color: AppColors.onSecondaryAction,
          ),
          function: onDiscard,
          color: AppColors.secondaryAction, // branding (KH mobile p.2)
        ),
        const Spacer(),

        // ✅ Submit button - text changes based on permission
        customButton(
          color: isFormComplete ? AppColors.primary : AppColors.darkGrey,
          height: 38.h,
          width: isMobile ? 150.w : 185.w,
          // 14/10/2026 — KH mobile report p.2 "decrease font size to show
          // all word": "Submit For Approval" wrapped onto a second line and
          // was cut off at 16 on a phone; 13 fits it on one line.
          textStyle:
              (isMobile
                      ? StyleText.fontSize13Weight500
                      : StyleText.fontSize16Weight500)
                  .copyWith(
                    color: isFormComplete
                        ? AppColors.textButton
                        : AppColors.colorBlack,
                  ),
          title: submitButtonText, // ✅ Dynamic text
          function: isFormComplete ? onSubmit : () {},
        ),
      ],
    );
  }
}

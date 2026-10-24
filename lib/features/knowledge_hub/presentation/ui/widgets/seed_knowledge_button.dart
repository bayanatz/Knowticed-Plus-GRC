/// Module: knowledge_hub/presentation/ui/widgets
/// ************************* FILE INFO *************************** ///
/// File Name: seed_knowledge_button.dart
/// Description: Debug-only buttons: create sample knowledge documents, and
///              backfill the visibility fields of older documents.
/// Author: Amr Mesbah
/// Created at: 11/10/2026
library;

import 'package:knowticed_plus/features/onboarding/o3_authentication/data/utils/debug_test_employee_switch.dart'
    show kOwnerTools;
import 'package:knowticed_plus/core/theme/app_animations.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:knowticed_plus/core/custom/buttons/custom_button.dart';
import 'package:knowticed_plus/core/extensions/context_extensions.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/generated/l10n.dart';

import 'package:knowticed_plus/features/knowledge_hub/kh1_create_new_knowledge/presentation/controller/create_knowledge_cubit.dart';
import 'package:knowticed_plus/core/theme/haptic_controller.dart';

/// The seed button writes test data, so it only exists in DEBUG builds.
// Owner-only (17/10/2026): developers running the code must not see the
// sample-data / backfill tools — only Moataz's KP_OWNER_TOOLS run does.
const bool kShowSeedKnowledgeButton = kDebugMode && kOwnerTools;

class SeedKnowledgeButton extends StatefulWidget {
  const SeedKnowledgeButton({super.key});

  @override
  State<SeedKnowledgeButton> createState() => _SeedKnowledgeButtonState();
}

class _SeedKnowledgeButtonState extends State<SeedKnowledgeButton> {
  bool _loading = false;

  Future<void> _seed() async {
    if (_loading) return;
    final S s = S.of(context);
    final bool? confirmed = await showAppDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(s.khSeedTitle),
        content: Text(s.khSeedBody),
        actions: [
          TextButton(
            style: TextButton.styleFrom(
              backgroundColor: AppColors.secondaryAction,
              foregroundColor: AppColors.onSecondaryAction,
            ),
            onPressed: withHaptic(
              () => Navigator.of(ctx).pop(false),
              HapticLevel.low,
            ),
            child: Text(s.cancel),
          ),
          TextButton(
            onPressed: withHaptic(
              () => Navigator.of(ctx).pop(true),
              HapticLevel.low,
            ),
            child: Text(s.create),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    final ScaffoldMessengerState messenger = ScaffoldMessenger.of(context);
    final CreateKnowledgeCubit? cubit = context.read<CreateKnowledgeCubit?>();
    setState(() => _loading = true);
    // The cubit writes the data and reloads the hub (rule 3: no services in
    // widgets).
    final int? count = await cubit?.seedSampleDocuments();
    if (!mounted) return;
    setState(() => _loading = false);

    messenger.showSnackBar(
      SnackBar(
        backgroundColor: count == null ? AppColors.darkRed : null,
        content: Text(
          count == null ? s.khSeedFailed : '${s.khSeedDone} $count',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isMobile = ContextExtension(context).isPhone;
    return Opacity(
      opacity: _loading ? 0.6 : 1,
      child: AbsorbPointer(
        absorbing: _loading,
        child: customButton(
          title: _loading
              ? S.of(context).khSeedCreating
              : S.of(context).khSeedTitle,
          function: _seed,
          width: isMobile ? 150.w : 200.w,
          height: 38.h,
          textStyle: StyleText.fontSize14Weight500.copyWith(
            color: AppColors.textButton,
            letterSpacing: .1,
          ),
        ),
      ),
    );
  }
}

/// Debug-only: runs the one-off data fixes — the visibility fields
/// (`currentStatus`, `isPublic`, `accessDepartments`) on documents saved before
/// they existed, and employee IDs on older file actions (KH-CREATE-14). Run once
/// per environment; until then older documents do not appear on the hub.
class BackfillVisibilityButton extends StatefulWidget {
  const BackfillVisibilityButton({super.key});

  @override
  State<BackfillVisibilityButton> createState() =>
      _BackfillVisibilityButtonState();
}

class _BackfillVisibilityButtonState extends State<BackfillVisibilityButton> {
  bool _running = false;

  Future<void> _run() async {
    if (_running) return;
    final S s = S.of(context);
    final ScaffoldMessengerState messenger = ScaffoldMessenger.of(context);
    final CreateKnowledgeCubit? cubit = context.read<CreateKnowledgeCubit?>();
    setState(() => _running = true);
    final int? count = await cubit?.runDataBackfill();
    if (!mounted) return;
    setState(() => _running = false);
    messenger.showSnackBar(
      SnackBar(
        backgroundColor: count == null ? AppColors.darkRed : null,
        content: Text(
          count == null ? s.khBackfillFailed : '${s.khBackfillDone} $count',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: _running ? 0.6 : 1,
      child: AbsorbPointer(
        absorbing: _running,
        child: customButton(
          title: _running
              ? S.of(context).khBackfillRunning
              : S.of(context).khBackfillTitle,
          function: _run,
          width: 150.w,
          height: 38.h,
          textStyle: StyleText.fontSize14Weight500.copyWith(
            color: AppColors.textButton,
          ),
        ),
      ),
    );
  }
}

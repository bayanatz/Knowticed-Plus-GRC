/// Module: knowledge_hub/kh5_submission_details/presentation/ui/widgets/analytics_section/statistics_tab
/// ************************* FILE INFO *************************** ///
/// File Name: filter_statistics.dart
/// Description: Filter statistics — Submission Details (S5) screen UI.
/// Author: Amr Mesbah
/// Created at: 11/10/2025
library;

import 'package:knowticed_plus/core/custom/buttons/custom_button_sizing.dart';
import 'package:knowticed_plus/features/knowledge_hub/helpers/kh_locale.dart';
import 'package:knowticed_plus/features/knowledge_hub/helpers/kh_log.dart';

import 'package:flutter/material.dart';
import 'package:knowticed_plus/core/constants/app_assets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:knowticed_plus/core/custom/dialogs/custom_dialog_manager.dart';
import 'package:knowticed_plus/core/custom/inputs/custom_search_widget_custom.dart';
import 'package:knowticed_plus/core/custom/buttons/custom_filter_icon.dart';
import 'package:knowticed_plus/generated/l10n.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/custom/helpers/custom_svg.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/core/helper/csv_helper.dart';
import 'package:knowticed_plus/features/knowledge_hub/presentation/controller/analytics/analytics_cubit.dart';
import 'package:knowticed_plus/features/knowledge_hub/kh5_submission_details/presentation/ui/widgets/analytics_section/statistics_tab/filter_statistics_dialog.dart';
// The Export permission check.
import 'package:knowticed_plus/features/knowledge_hub/helpers/knowledge_hub_permissions.dart';
import 'package:knowticed_plus/core/theme/app_animations.dart';
import 'package:knowticed_plus/core/theme/haptic_controller.dart';

Widget filterStatistics(
  BuildContext context, {
  required TextEditingController searchController,
  required Function(String) onSearchChanged,
}) {
  // 15/10/2026 — KH vertical report p.18 "Icon only": in portrait the Filter
  // button drops its label and becomes a 38.w square, as on Approvals.
  final bool iconOnly =
      MediaQuery.orientationOf(context) == Orientation.portrait;
  return Row(
    crossAxisAlignment: CrossAxisAlignment.center,
    children: [
      AppSearchTextField(
        controller: searchController,
        onChanged: onSearchChanged,
      ),
      SizedBox(width: ButtonSizing.toolbarGap(context)),
      _buildStatisticsFilterButton(context, iconOnly: iconOnly),
      // GATED 2/9/2026 on `exportStatisticsTable`.
      if (KnowledgeHubAccess.canExportStatistics) ...[
        SizedBox(width: ButtonSizing.toolbarGap(context)),
        _buildStatisticsExportButton(context),
      ],
    ],
  );
}

/// Opens the statistics filter dialog.
Widget _buildStatisticsFilterButton(
  BuildContext context, {
  required bool iconOnly,
}) {
  // CHANGED 18/10/2026 (Moataz: Filter looks the same in every module): the
  // shared CustomFilterIcon (was a hand-built 16/500 button with a 23pt icon).
  // Icon-only in portrait, as before.
  return CustomFilterIcon(
    iconOnly: iconOnly,
    onTap: () {
      showAppDialog(
        context: context,
        builder: (ctx) => Center(
          child: BlocProvider.value(
            value: context.read<AnalyticsCubit>(),
            child: FilterStatisticsDialog(),
          ),
        ),
      );
    },
  );
}

/// Writes the VISIBLE rows (after filter and search) to a CSV through the
/// app's one save path (22/9/2026 — the button used to do nothing).
Widget _buildStatisticsExportButton(BuildContext context) {
  return GestureDetector(
    onTapDown: (_) => HapticController.low(),
    onTap: () => _exportStatistics(context),
    child: Container(
      height: ButtonSizing.height,
      width: 100.w,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8.r),
        color: AppColors.primary,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CustomSvgImage(
            assetPath: AppAssets.export,
            height: 20.h,
            width: 20.w,
            fit: BoxFit.fill,
            color: AppColors.textButton,
          ),
          SizedBox(width: 5.w),
          Text(
            S.of(context).export,
            // 22/10/2026 — Owner: toolbar text is 14 in every module (was 16).
            style: StyleText.fontSize14Weight500.copyWith(
              color: AppColors.textButton,
            ),
          ),
        ],
      ),
    ),
  );
}

/// Writes the statistics table to a CSV and hands it to the user.
///
/// Reads the rows from [AnalyticsCubit] rather than rebuilding them from the
/// widget tree, so the file matches the table exactly — same columns, same
/// order, same filter.
Future<void> _exportStatistics(BuildContext context) async {
  final cubit = context.read<AnalyticsCubit>();
  final bool isArabic = KhLocale.isArabic(context);

  final List<String> headers = <String>[
    S.of(context).number,
    S.of(context).employeeName,
    S.of(context).department,
    S.of(context).jobTitle,
    S.of(context).date,
    S.of(context).time,
    S.of(context).action,
  ];

  final rows = cubit.buildStatisticsExportRows(
    headers: headers,
    isArabic: isArabic,
  );

  // Header only: nothing to export, and a file with one line in it is a worse
  // answer than saying so.
  if (rows.length <= 1) {
    await CustomDialogManager.showMessage(
      context: context,
      lottiePath:
          'assets/lottie_assets/main_lottie_assets/lot_status_warning.json',
      title: S.of(context).noDataAvailable,
    );
    return;
  }

  final String fileName =
      'knowledge_hub_statistics_${DateTime.now().millisecondsSinceEpoch}';

  final result = await CSVHelper().exportRowsForUser(
    fileName: fileName,
    rows: rows,
  );

  if (!context.mounted) return;

  // The outcome is a
  // confirmation DIALOG, not a SnackBar ("Export Successful" in the corner),
  // and — see `CSVHelper.exportForUser` — the file manager no longer opens.
  final String? error = result.fold((l) => l, (_) => null);
  final String? path = result.fold((_) => null, (r) => r);

  if (error != null) {
    khLog('❌ Statistics export failed: $error');
    await CustomDialogManager.showMessage(
      context: context,
      lottiePath:
          'assets/lottie_assets/main_lottie_assets/lot_status_error.json',
      title: S.of(context).exportFailed,
      subtitle: error,
    );
    return;
  }

  // An empty path is the user dismissing the save sheet — nothing was written
  // and nothing went wrong, so there is nothing to report.
  if (path == null || path == CSVHelper.exportCancelled) return;
  khLog('✅ Statistics exported to: $path');
  await CustomDialogManager.showSuccess(
    context: context,
    lottiePath: 'assets/lottie_assets/main_lottie_assets/lot_status_check.json',
    title: S.of(context).exportSuccessful,
    subtitle: S.of(context).exportSuccess,
  );
}

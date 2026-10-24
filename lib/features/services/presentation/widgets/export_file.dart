/// Module: services / presentation / widgets
///
///*************************** FILE INFO ****************************///
/// File Name: export_file.dart
/// Purpose: Export file — declares ExportDialog, _ExportDialogState.
/// Author: Amr Mesbah
/// Created At: 18/10/2026
library;

import 'package:knowticed_plus/core/custom/helpers/custom_svg.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:knowticed_plus/core/custom/inputs/custom_textfield.dart';
import 'package:knowticed_plus/core/helper/csv_helper.dart';
import 'package:knowticed_plus/features/services/data/data_source/remote_data_source/services_csv_exporter.dart';

import 'package:knowticed_plus/generated/l10n.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/custom/buttons/custom_button.dart';

import 'package:knowticed_plus/core/theme/app_theme.dart';

import 'package:knowticed_plus/features/services/presentation/widgets/home_services_dialog.dart';
import 'package:knowticed_plus/core/extensions/context_extensions.dart';

import 'package:knowticed_plus/features/services/helpers/constants/services_lottie.dart';

class ExportDialog extends StatefulWidget {
  final List<dynamic> filteredModel;
  final Map selectedProviders;
  final String Function(dynamic date) formatStartDate;

  const ExportDialog({
    super.key,
    required this.filteredModel,
    required this.selectedProviders,
    required this.formatStartDate,
  });

  @override
  State<ExportDialog> createState() => _ExportDialogState();
}

class _ExportDialogState extends State<ExportDialog> {
  /// Lets this screen's builder/logic extensions refresh it (setState
  /// itself may only be called inside the State class).
  void rebuild(VoidCallback fn) => setState(fn);

  final TextEditingController controller = TextEditingController();
  final ServicesCsvExporter _exporter = const ServicesCsvExporter();
  OverlayEntry? _overlayEntry;
  bool _isExporting = false;

  void _hideLoadingIndicator() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  /// The download button is only live once there is a file name to save to.
  bool get _canExport => !_isExporting && controller.text.trim().isNotEmpty;

  Future<void> _exportToCSVSimple(BuildContext context) async {
    if (_isExporting) return;

    final fileName = controller.text.trim();
    if (fileName.isEmpty) {
      Get.snackbar(
        S.of(context).error,
        S.of(context).pleaseEnterFileName,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.orange,
        colorText: AppColors.white,
      );
      return;
    }

    if (widget.filteredModel.isEmpty) {
      Get.snackbar(
        S.of(context).noData,
        S.of(context).svcNoServicesToExport,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.orange,
        colorText: AppColors.white,
      );
      return;
    }

    setState(() {
      _isExporting = true;
    });
    // Services mobile QA p.21 ("remove this loading"): the dark 70pt spinner
    // box stayed on screen behind the phone's Save sheet for as long as the
    // sheet was open. The save sheet (and the Export button's own busy state)
    // is the feedback now, so no overlay is shown.

    // The exporter returns Either and never throws, so the loading overlay and
    // the button state are always reset and a failure is always reported.
    final result = await _exporter.export(
      items: widget.filteredModel,
      selectedProviders: widget.selectedProviders,
      fileName: fileName,
      labels: _csvLabels(S.of(context)),
    );
    _hideLoadingIndicator();
    if (mounted) {
      setState(() {
        _isExporting = false;
      });
    }
    if (!mounted) return;

    final String? error = result.fold((l) => l, (_) => null);
    if (error != null) {
      if (!context.mounted) return;
      Get.snackbar(
        S.of(context).error,
        error,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.red,
        colorText: AppColors.white,
      );
      return;
    }
    // Save sheet dismissed on a phone — nothing written, nothing to report.
    if (result.getOrElse(() => '') == CSVHelper.exportCancelled) return;

    if (!context.mounted) return;
    if (Navigator.canPop(context)) {
      if (!context.mounted) return;
      Navigator.pop(context);
    }

    if (!context.mounted) return;
    await showSuccessDialogMaster(
      lottiePath: ServicesLottie.approved,
      title: S.of(context).exported,
      subtitle: S.of(context).fileSavedSuccessfully,
      context: context,
    );
  }

  @override
  void dispose() {
    _hideLoadingIndicator();
    controller.dispose();
    super.dispose();
  }

  /// H21/H22: the CSV column titles and Yes/No texts in the reader's language.
  ServicesCsvLabels _csvLabels(S s) => ServicesCsvLabels(
        headers: [
          s.num,
          s.svcServiceNameEnglishColumn,
          s.svcServiceNameArabicColumn,
          s.svcServiceDescriptionEnglishColumn,
          s.svcServiceDescriptionArabicColumn,
          s.status,
          s.duration,
          s.timeUnit,
          s.department,
          s.limitServiceAvailability,
          s.requiresApproval,
          s.startDate,
          s.serviceProvider,
        ],
        yes: s.yes,
        no: s.no,
        noProvider: s.svcNoServiceProvider,
      );

  @override
  Widget build(BuildContext context) {
    var isMobile = ContextExtension(context).isPhone;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r)),
      child: IntrinsicHeight(
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.card,
            borderRadius: BorderRadius.circular(8.r),
          ),
          constraints: BoxConstraints(
            maxWidth: 411.sp,
            minWidth: isMobile ? 280.sp : 350.sp,
          ),
          child: Padding(
            // CHANGED 9/9/2026: 20 -> 12 on every side.
            padding: EdgeInsets.all(12.sp),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 30.sp,
                      height: 30.sp,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.primary,
                      ),
                      child: Center(
                        child: CustomSvgImage.natural(
                          assetPath:
                              "assets/icons_assets/main_icons_assets/ic_action_export.svg",
                          width: 16.sp,
                          height: 16.sp,
                          color: AppColors.textButton,
                        ),
                      ),
                    ),
                    SizedBox(width: 8.sp),
                    Text(
                      S.of(context).export,
                      style: StyleText.fontSize16Weight500.copyWith(
                        color: AppColors.blackButton,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 20.sp),
                CustomTextField(
                  controller: controller,
                  height: 36,
                  label: S.of(context).fileName,
                  hint: S.of(context).Texthere,
                  restrictByDirection: true,
                  autoCapitalize: true,
                  onChanged: (_) => setState(() {}),
                ),
                SizedBox(height: 20.sp),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    customButton(
                      width: isMobile ? 120.w : 135.w,
                      title: S.of(context).discard,
                      color: AppColors.secondaryAction,
                      height: 38.sp,
                      textStyle: StyleText.fontSize16Weight500.copyWith(
                        color: AppColors.onSecondaryAction,
                      ),
                      radius: 8.r,
                      function: () {
                        if (!_isExporting) {
                          Navigator.pop(context);
                        }
                      },
                    ),
                    SizedBox(width: 15.sp),
                    customButton(
                      width: isMobile ? 120.w : 135.w,
                      title: _isExporting
                          ? "${S.of(context).export}..."
                          : S.of(context).download,
                      // Was always enabled: pressing it with an empty name ran
                      // the export, failed the check inside, and surfaced an
                      // error toast. Disable it up front instead — the field
                      // already calls setState on every keystroke.
                      // CHANGED 9/9/2026 — the disabled pair was `grey` fill
                      // with `mediumGrey` text, two greys close enough that the
                      // word "Download" all but vanished until a file name was
                      // typed. Disabled is now `darkGrey` behind `white`, which
                      // reads at a glance while still saying "not yet".
                      //
                      // The ENABLED pair is untouched: `textButton` resolves to
                      // the on-primary colour, and white on the yellow primary
                      // would be the unreadable case in the other direction.
                      color:
                          _canExport ? AppColors.primary : AppColors.darkGrey,
                      height: 38.sp,
                      textStyle: StyleText.fontSize16Weight500.copyWith(
                        color:
                            _canExport ? AppColors.textButton : AppColors.white,
                      ),
                      radius: 8.r,
                      function: () {
                        if (_canExport) {
                          _exportToCSVSimple(context);
                        }
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

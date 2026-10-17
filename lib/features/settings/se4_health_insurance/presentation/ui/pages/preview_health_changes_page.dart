/// Module: settings/se4_health_insurance
///
///*************************** FILE INFO ****************************///
/// File Name: preview_health_changes_page.dart
/// Description: Reviews health-insurance edits before they are submitted as a request.
/// Author: Amr Mesbah
/// Created at: 20/11/2024
/// Updated: 11/8/2026 - CR-SKEL-SE4-N11/N15/N17: the Firestore batch write and its try/catch moved
///          into RequestsCubit/RequestsRepository; raw colours route through
///          AppColors.
///
/// REMAINING (CR-SKEL-SE4-N12): still ~1,200 LOC. Decomposing it into
/// widgets/sections/ is separate work.
library;

///*************************** FILE INFO ****************************///
/// Description: Preview page for comparing old and new health insurance information
/// Modified: Mobile responsive layout - vertical stacking on mobile, show only changed fields
import 'package:grc_module/core/custom/feedback/circle_progress.dart';
import 'package:grc_module/core/custom/inputs/custom_textfield.dart';
import 'package:grc_module/core/theme/app_theme.dart';

import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:grc_module/core/theme/app_colors.dart';
// REMOVED_MODULE: import 'package:grc_module/features/external/grc/grc_module/grc_owner/presentation/ui/create_policy.dart';
// REMOVED_MODULE: import 'package:grc_module/core/helper/inventory_module/core/text_field.dart';
// REMOVED_MODULE: import 'package:grc_module/features/external/services_mangment_module/core/new_theme.dart';
import 'package:lottie/lottie.dart';
import 'package:grc_module/core/custom/navigation/custom_side_frame_master.dart';
import 'package:grc_module/generated/l10n.dart';
import 'package:grc_module/features/notification/data/repository/settings_notification_service.dart';
import 'package:grc_module/features/settings/se6_requests/domain/entities/field_change.dart';
import 'package:grc_module/features/settings/se6_requests/presentation/controller/requests_cubit.dart';
import 'package:grc_module/features/settings/se6_requests/presentation/ui/widgets/request_error_dialog.dart';
import 'package:grc_module/core/custom/dialogs/custom_confirm_dialog.dart';
// REMOVED_MODULE: import '../../../../../external/inventory_module/core/custom_button_widget.dart';

// REMOVED_MODULE: import '../../../../../external/services_mangment_module/Category/presentation/ui/service_department_manager/tablet/s3_services_requests/my_request_details/widget/dailog.dart';
// REMOVED_MODULE: import '../../../../../external/services_mangment_module/Category/presentation/ui/services_admin/Widget/W3_Frame_Screen_tablet.dart';
import 'package:grc_module/features/settings/presentation/ui/pages/settings_screen.dart';

import 'package:grc_module/core/custom/helpers/custom_svg.dart';
import 'package:grc_module/core/custom/buttons/custom_button.dart';
import 'package:grc_module/core/extensions/context_extensions.dart';
import 'package:grc_module/core/theme/app_animations.dart';

part '../widgets/preview_health_changes_page/preview_health_insurance_changes_page_builders.dart';
part '../widgets/preview_health_changes_page/preview_health_insurance_changes_page_logic.dart';

class PreviewHealthInsuranceChangesPage extends StatefulWidget {
  final Map<String, dynamic> changes;

  // Health Insurance Controllers
  final TextEditingController insuranceNameController;
  final TextEditingController insurancePolicyNumberController;

  // 1st Emergency Contact Controllers
  final TextEditingController firstContactFirstNameController;
  final TextEditingController firstContactLastNameController;
  final TextEditingController firstContactRelationshipController;
  final TextEditingController firstContactEmailController;
  final TextEditingController firstContactPhoneController;
  final TextEditingController firstContactLanguageController;
  final TextEditingController firstContactCountryController;
  final TextEditingController firstContactProvinceController;
  final TextEditingController firstContactCityController;
  final TextEditingController firstContactStreetController;

  // 2nd Emergency Contact Controllers
  final TextEditingController secondContactFirstNameController;
  final TextEditingController secondContactLastNameController;
  final TextEditingController secondContactRelationshipController;
  final TextEditingController secondContactEmailController;
  final TextEditingController secondContactPhoneController;
  final TextEditingController secondContactLanguageController;
  final TextEditingController secondContactCountryController;
  final TextEditingController secondContactProvinceController;
  final TextEditingController secondContactCityController;
  final TextEditingController secondContactStreetController;

  const PreviewHealthInsuranceChangesPage({
    super.key,
    required this.changes,
    required this.insuranceNameController,
    required this.insurancePolicyNumberController,
    required this.firstContactFirstNameController,
    required this.firstContactLastNameController,
    required this.firstContactRelationshipController,
    required this.firstContactEmailController,
    required this.firstContactPhoneController,
    required this.firstContactLanguageController,
    required this.firstContactCountryController,
    required this.firstContactProvinceController,
    required this.firstContactCityController,
    required this.firstContactStreetController,
    required this.secondContactFirstNameController,
    required this.secondContactLastNameController,
    required this.secondContactRelationshipController,
    required this.secondContactEmailController,
    required this.secondContactPhoneController,
    required this.secondContactLanguageController,
    required this.secondContactCountryController,
    required this.secondContactProvinceController,
    required this.secondContactCityController,
    required this.secondContactStreetController,
  });

  @override
  State<PreviewHealthInsuranceChangesPage> createState() =>
      _PreviewHealthInsuranceChangesPageState();
}

class _PreviewHealthInsuranceChangesPageState
    extends State<PreviewHealthInsuranceChangesPage> {
  /// Lets this screen's builder/logic extensions refresh it (setState
  /// itself may only be called inside the State class).
  void rebuild(VoidCallback fn) => setState(fn);

  late TextEditingController requestNoteController;

  /// Owned by this page: the request flow is entered from here and torn down
  /// with it, so there is nothing to provide higher up the tree.
  final RequestsCubit _requestsCubit = RequestsCubit();
  bool isSubmitting = false;

  @override
  void initState() {
    super.initState();
    requestNoteController = TextEditingController();
  }

  /// The request note is MANDATORY (24/8/2026).
  ///
  /// An approver reading the request needs to know why the change is being
  /// asked for, and the note was the only place that says so — it was optional,
  /// so most requests arrived with nothing. Submit is now inert until it holds
  /// something other than whitespace.
  bool get _hasRequestNote => requestNoteController.text.trim().isNotEmpty;

  /// Submit, greyed out and untappable until the note is filled — and while a
  /// submit is already in flight, which is what `isSubmitting` guarded before.
  Widget _buildSubmitButton(BuildContext context, {required double width}) {
    final enabled = _hasRequestNote && !isSubmitting;

    // FIXED 8/9/2026 — the disabled label was unreadable. Two causes, both
    // here: `AppColors.textButton` is `AppTheme.readableOn(AppColors.primary)`, so in light
    // mode it resolves to (near) black — dark text on the grey disabled fill —
    // and the `Opacity(0.5)` wrapper then washed out whatever was left.
    // The grey fill already reads as disabled on its own, so the opacity layer
    // is gone and the disabled label is pinned to white.
    return IgnorePointer(
      ignoring: !enabled,
      child: customButton(
        title: isSubmitting ? S.of(context).submitting : S.of(context).submit,
        function: () => _submitChanges(context),
        height: 38.h,
        width: width,
        color: enabled ? AppColors.primary : AppColors.darkGrey,
        textStyle: StyleText.fontSize16Weight500.copyWith(
          color: enabled ? AppColors.textButton : AppColors.white,
        ),
      ),
    );
  }

  @override
  void dispose() {
    requestNoteController.dispose();
    _requestsCubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;
    var lightMode = Theme.of(context).brightness == Brightness.light;

    return Scaffold(
      body: SideFrameMasterServices(
        titleText: S.of(context).settings,
        onFirstTap: () {
          Navigator.pop(context);
        },
        secondTitle: S.of(context).previewHealthInsuranceChanges,
        child: SingleChildScrollView(
          physics: ClampingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header - Conditional based on device
              if (isMobile)
                // CHANGED 8/9/2026 — the trailing `SizedBox(height: 10.sp)`
                // that used to close this Column is gone.
                //
                // The shared `SizedBox(height: 10.sp)` below already separates
                // this heading from the card under it, so the local one made
                // the gap 20.sp here while "New Details" — which has only its
                // own 10.sp — sat at half that. The two headings now clear
                // their cards by the same amount.
                Text(
                  S.of(context).current_details,
                  style: StyleText.fontSize16Weight600.copyWith(
                    color: AppColors.blackButton,
                  ),
                )
              else
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        S.of(context).current_details,
                        style: StyleText.fontSize16Weight600.copyWith(
                          color: AppColors.blackButton,
                        ),
                      ),
                    ),
                    SizedBox(width: 20.sp),
                    Expanded(
                      child: Text(
                        S.of(context).new_details,
                        style: StyleText.fontSize16Weight600.copyWith(
                          color: AppColors.blackButton,
                        ),
                      ),
                    ),
                  ],
                ),

              SizedBox(height: 10.sp),

              // Main Content - Conditional layout
              if (isMobile)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Current Details
                    _buildDetailsColumn(
                      context,
                      lightMode,
                      isCurrentColumn: true,
                    ),

                    SizedBox(height: 20.sp),

                    // New Details Header
                    Text(
                      S.of(context).new_details,
                      style: StyleText.fontSize16Weight600.copyWith(
                        color: AppColors.blackButton,
                      ),
                    ),

                    SizedBox(height: 10.sp),

                    // New Details
                    _buildDetailsColumn(
                      context,
                      lightMode,
                      isCurrentColumn: false,
                    ),
                  ],
                )
              else
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Current Details Column
                    Expanded(
                      child: _buildDetailsColumn(
                        context,
                        lightMode,
                        isCurrentColumn: true,
                      ),
                    ),

                    SizedBox(width: 16.sp),

                    // New Details Column
                    Expanded(
                      child: _buildDetailsColumn(
                        context,
                        lightMode,
                        isCurrentColumn: false,
                      ),
                    ),
                  ],
                ),

              SizedBox(height: 30.sp),

              // Bottom Action Buttons
              // CHANGED 8/9/2026 — both buttons are 150.w x 38.h with a Spacer
              // between them, which is exactly what the Discard / Preview pair
              // at the bottom of edit_page_request_health.dart uses. This page
              // is the step straight after that one, so the row must not change
              // shape underneath the user.
              //
              // `150.w`, not `150.sp`, for the same reason — matching the edit
              // page means matching the unit it measures in.
              //
              // Mobile used to wrap each button in `Expanded` with a 10.sp gap,
              // so the pair stretched the full width and read as two banners.
              isMobile
                  ? Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        customButton(
                          title: S.of(context).discardChange,
                          function: isSubmitting
                              ? () {}
                              : () {
                                  Navigator.pop(context);
                                },
                          height: 38.h,
                          width: 150.w,
                          color: AppColors.darkGrey,
                          textStyle: StyleText.fontSize16Weight500.copyWith(
                            color: AppColors.text,
                          ),
                        ),
                        Spacer(),
                        _buildSubmitButton(context, width: 150.w),
                      ],
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        customButton(
                          title: S.of(context).discardChange,
                          function: isSubmitting
                              ? () {}
                              : () {
                                  Navigator.pop(context);
                                },
                          height: 38.h,
                          width: 150.w,
                          color: AppColors.darkGrey,
                          textStyle: StyleText.fontSize16Weight500.copyWith(
                            color: AppColors.text,
                          ),
                        ),
                        Spacer(),
                        _buildSubmitButton(context, width: 150.w),
                      ],
                    ),

              SizedBox(height: 20.sp),
            ],
          ),
        ),
      ),
    );
  }

  /// One labelled read-only value.
  ///
  /// [showHighlight] — not "has this field changed" — because only the New
  /// Details column outlines a change. See the local wrapper in
  /// _buildDetailsColumn.
  Widget _fieldDisplay({
    required String label,
    required String value,
    required bool showHighlight,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: StyleText.fontSize14Weight400.copyWith(
            color: AppColors.text,
          ),
        ),
        SizedBox(height: 10.h),
        Container(
          // minHeight, not a fixed height: a BoxDecoration border is drawn
          // *inside* the box, so a fixed 36.h left only 36.h - 20.h padding - 4
          // border for the text and clipped it — but only on the changed
          // (green-bordered) fields, which is why those looked cut off.
          constraints: BoxConstraints(minHeight: 36.h),
          width: double.infinity,
          // ALIGNMENT 24/8/2026: was `AlignmentDirectional.centerStart`, which
          // resolves to the RIGHT edge under an Arabic (RTL) Directionality —
          // so every value jumped to the right side of its box in Arabic. The
          // values are to sit on the left in BOTH languages, so this is the
          // absolute `Alignment.centerLeft`, not the directional one. The
          // LABEL above is left directional on purpose: it still follows the
          // language.
          alignment: Alignment.centerLeft,
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
          decoration: BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.circular(4.r),
            // Always draw a 2px border — transparent when not highlighted — so
            // both columns keep identical inner geometry and the two sides of
            // the comparison stay row-for-row aligned.
            border: Border.all(
              color: showHighlight ? AppColors.green : AppColors.transparent,
              width: 2,
            ),
          ),
          child: Text(
            value.isEmpty ? '-' : value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            // Absolute left, for the same reason as the alignment above. The
            // text DIRECTION is deliberately left alone — forcing LTR would
            // mis-order punctuation inside an Arabic value.
            textAlign: TextAlign.left,
            style: StyleText.fontSize14Weight400.copyWith(
              color: AppColors.text,
            ),
          ),
        ),
      ],
    );
  }


  /// Function Name: [_isEmergencyContactField]
  ///
  /// Purpose: Whether an edited field belongs to the Emergency Contact section
  ///          rather than to Health Insurance.
  ///
  /// The edit screen emits `firstContact_*` / `secondContact_*` for the two
  /// contacts — the exact spellings `RequestFieldMapping` lists — and plain
  /// `insurance_*` names for the policy itself. Matching the prefix is what
  /// splits the two sections; `RequestFieldMapping._snakeToCamel` folds the
  /// same names, so an approval still writes them either way.
  ///
  /// Parameters:
  /// - [fieldName]: The request field name as the edit screen wrote it.
  ///
  /// Returns: [bool] true for an emergency-contact field.
  static bool _isEmergencyContactField(String fieldName) {
    final String key = fieldName.toLowerCase();
    return key.startsWith('firstcontact') || key.startsWith('secondcontact');
  }

  Future<void> showConfirmationDialog({
    required String lottiePath,
    required String title,
    required String message,
    required VoidCallback onConfirm,
  }) async {
    var isMobile = ContextExtension(context).isPhone;
    return showAppDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => Dialog(
        backgroundColor: Theme.of(context).brightness == Brightness.light
            ? AppColors.white
            : AppColors.background,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(4.r),
        ),
        child: Padding(
          padding: EdgeInsets.all(20.r),
          child: SizedBox(
            width: 405.sp,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Lottie.asset(
                  lottiePath,
                  width: 70.sp,
                  height: 70.sp,
                  fit: BoxFit.scaleDown,
                  repeat: true,
                  animate: true,
                ),
                SizedBox(height: 20.sp),
                Text(
                  title,
                  style: StyleText.fontSize20Weight500.copyWith(
                    color: AppColors.blackButton,
                  ),
                ),
                SizedBox(height: 18.sp),
                Text(
                  message,
                  textAlign: TextAlign.center,
                  style: StyleText.fontSize14Weight500.copyWith(
                    color: AppColors.secondaryText,
                  ),
                ),
                SizedBox(height: 15.sp),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 0.sp),
                  child: Row(
                    textDirection: TextDirection
                        .ltr, // X-73: Cancel left, action right in both languages

                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      customButton(
                        title: S.of(context).no,
                        function: () => Navigator.pop(context),
                        textStyle: StyleText.fontSize15Weight500.copyWith(
                          color: AppColors.text,
                        ),
                        width: isMobile ? 120.sp : 135.sp,
                        height: 38.sp,
                        radius: 4.r,
                        // 21/9/2026 — report p.14/p.22: same grey + white as Discard Changes.
                        color: AppColors.darkGrey,
                      ),
                      SizedBox(width: 20.sp),
                      customButton(
                        title: S.of(context).yes,
                        function: () {
                          Navigator.pop(context);
                          onConfirm();
                        },
                        textStyle: StyleText.fontSize18Weight500.copyWith(
                          color: AppColors.textButton,
                        ),
                        width: isMobile ? 120.sp : 135.sp,
                        height: 38.sp,
                        radius: 4.r,
                        color: AppColors.primary,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

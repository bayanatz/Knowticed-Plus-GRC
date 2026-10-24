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
import 'package:knowticed_plus/core/custom/inputs/custom_textfield.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';

import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:knowticed_plus/features/settings/se6_requests/data/data_source/remote_data_source/requests_remote_data_source.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
// REMOVED_MODULE: import 'package:knowticed_plus/features/external/grc/grc_module/grc_owner/presentation/ui/create_policy.dart';
// REMOVED_MODULE: import 'package:knowticed_plus/core/helper/inventory_module/core/text_field.dart';
// REMOVED_MODULE: import 'package:knowticed_plus/features/external/services_mangment_module/core/new_theme.dart';
import 'package:knowticed_plus/core/custom/inputs/current_new_value_pair.dart';
import 'package:knowticed_plus/core/custom/navigation/custom_side_frame_master.dart';
import 'package:knowticed_plus/core/custom/dialogs/custom_dialog_manager.dart';
import 'package:knowticed_plus/generated/l10n.dart';
import 'package:knowticed_plus/features/notification/data/repository/settings_notification_service.dart';
import 'package:knowticed_plus/features/settings/se6_requests/domain/entities/field_change.dart';
import 'package:knowticed_plus/features/settings/se6_requests/presentation/controller/requests_cubit.dart';
import 'package:knowticed_plus/features/settings/se6_requests/presentation/ui/widgets/request_error_dialog.dart';
// REMOVED_MODULE: import '../../../../../external/inventory_module/core/custom_button_widget.dart';

// REMOVED_MODULE: import '../../../../../external/services_mangment_module/Category/presentation/ui/service_department_manager/tablet/s3_services_requests/my_request_details/widget/dailog.dart';
// REMOVED_MODULE: import '../../../../../external/services_mangment_module/Category/presentation/ui/services_admin/Widget/W3_Frame_Screen_tablet.dart';
import 'package:knowticed_plus/features/settings/presentation/ui/pages/settings_screen.dart';

import 'package:knowticed_plus/core/custom/helpers/custom_svg.dart';
import 'package:knowticed_plus/core/custom/buttons/custom_button.dart';

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
  /// Set by `_performSubmit` so `_submitChanges` can show the error dialog
  /// after the shared flow returns (20/10/2026).
  bool _submitFailed = false;

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
    // Removing only the second contact needs no note (Moataz 23/10/2026).
    final enabled =
        (_hasRequestNote || _isOnlySecondContactRemoval()) && !isSubmitting;

    // FIXED 8/9/2026 — the disabled label was unreadable. Two causes, both
    // here: `AppColors.textButton` is `AppTheme.readableOn(AppColors.primary)`, so in light
    // mode it resolves to (near) black — dark text on the grey disabled fill —
    // and the `Opacity(0.5)` wrapper then washed out whatever was left.
    // The grey fill already reads as disabled on its own, so the opacity layer
    // is gone and the disabled label is pinned to white.
    // R-3 (21/10/2026, Moataz): disabled = grey, black text, 50% opacity —
    // the same look as the Personal Information Submit.
    return Opacity(
      opacity: enabled ? 1.0 : 0.5,
      child: IgnorePointer(
        ignoring: !enabled,
        child: customButton(
          title: isSubmitting ? S.of(context).submitting : S.of(context).submit,
          function: () => _submitChanges(context),
          height: 38.h,
          width: width,
          color: enabled ? AppColors.primary : AppColors.grey,
          textStyle: StyleText.fontSize16Weight500.copyWith(
            color: AppColors.textButton,
          ),
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
        // D-202 / D-224 (21/10/2026): the changed fields scroll as ONE column
        // of Current → New pairs; Discard / Submit are PINNED at the bottom.
        child: SideFrameBoundedBody(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: SingleChildScrollView(
                  physics: const ClampingScrollPhysics(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 21/10/2026 (Moataz): no "Current Details | New
                      // Details" row — each box carries its own Current / New
                      // tag, as on the Personal Information preview.
                      _buildDetailsColumn(
                        context,
                        lightMode,
                        isCurrentColumn: false,
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 16.sp),
              Row(
                children: [
                  if (isMobile)
                    Expanded(
                      child: customButton(
                        title: S.of(context).discardChange,
                        function:
                            isSubmitting ? () {} : () => Navigator.pop(context),
                        height: 38.h,
                        width: double.infinity,
                        color: AppColors.darkGrey,
                        textStyle: StyleText.fontSize16Weight500
                            .copyWith(color: AppColors.text),
                      ),
                    )
                  else
                    customButton(
                      title: S.of(context).discardChange,
                      function:
                          isSubmitting ? () {} : () => Navigator.pop(context),
                      height: 38.h,
                      width: 150.w,
                      color: AppColors.darkGrey,
                      textStyle: StyleText.fontSize16Weight500
                          .copyWith(color: AppColors.text),
                    ),
                  if (isMobile) SizedBox(width: 16.sp) else const Spacer(),
                  if (isMobile)
                    Expanded(
                        child:
                            _buildSubmitButton(context, width: double.infinity))
                  else
                    _buildSubmitButton(context, width: 150.w),
                ],
              ),
              SizedBox(height: 16.sp),
            ],
          ),
        ),
      ),
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
}

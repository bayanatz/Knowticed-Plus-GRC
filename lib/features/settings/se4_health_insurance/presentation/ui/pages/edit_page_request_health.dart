/// Module: settings/se4_health_insurance
///
///*************************** FILE INFO ****************************///
/// File Name: edit_page_request_health.dart
/// Description: The health-insurance edit form that feeds the preview page.
/// Author: Amr Mesbah
/// Created at: 20/11/2024
/// Updated: 11/8/2026 - CR-SKEL-SE4-N14/N17: the two GetBuilder`<RequestController>` wrappers are
///          gone (the controller no longer has a method that calls update());
///          Get.snackbar replaced with a themed SnackBar; raw colours routed
///          through AppColors.
///
/// REMAINING (CR-SKEL-SE4-N13): the preview page is still handed 21 freshly
/// constructed TextEditingControllers that nothing disposes. Passing a value
/// model instead changes the preview page's whole constructor and ~40 read
/// sites; staged, not done.
library;

import 'package:grc_module/core/custom/navigation/custom_side_frame_master.dart';
import 'package:grc_module/features/roles/r4_active_directory/data/models/employees_model/new_employee_model.dart';
import 'package:grc_module/core/helper/access/main_core_employee_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import 'package:grc_module/core/theme/app_colors.dart';
import 'package:grc_module/features/settings/se4_health_insurance/presentation/ui/pages/preview_health_changes_page.dart';
import 'package:lottie/lottie.dart';

import 'package:grc_module/core/helper/format_title.dart';
import 'package:grc_module/generated/l10n.dart';

import 'package:grc_module/core/theme/app_theme.dart';

// ADDED 9/10/2026 — 2nd emergency contact optional.
import 'package:grc_module/features/settings/se4_health_insurance/domain/rules/health_request_form_rules.dart';
import 'package:grc_module/features/settings/se4_health_insurance/presentation/ui/widgets/sections/edit_details.dart';
import 'package:grc_module/features/settings/se4_health_insurance/presentation/ui/widgets/sections/edit_health.dart';

import 'package:grc_module/core/custom/buttons/custom_button.dart';
import 'package:grc_module/features/settings/presentation/controller/employee_controller.dart';
import 'package:grc_module/core/extensions/context_extensions.dart';
import 'package:grc_module/core/theme/app_animations.dart';

part '../widgets/edit_page_request_health/edit_page_request_health_logic.dart';

class EditPageRequestHealth extends StatefulWidget {
  const EditPageRequestHealth({super.key});

  @override
  State<EditPageRequestHealth> createState() => _EditPageRequestHealthState();
}

class _EditPageRequestHealthState extends State<EditPageRequestHealth> {
  /// Lets this screen's builder/logic extensions refresh it (setState
  /// itself may only be called inside the State class).
  void rebuild(VoidCallback fn) => setState(fn);

  bool isEnglish = Get.locale.toString().contains('en');
  final _formKey = GlobalKey<FormState>();

  /// True once the user has tapped Preview — makes empty fields show
  /// their required-error state.
  bool _submitted = false;

  // Controllers
  final MainCoreEmployeeController employeeController =
      Get.find<MainCoreEmployeeController>();
  NewEmployeeModelHistory? currentEmployeeHistory;

  // Health Insurance Controllers
  late TextEditingController insuranceNameController;
  late TextEditingController insurancePolicyNumberController;

  // 1st Emergency Contact Controllers
  late TextEditingController firstContactFirstNameController;
  late TextEditingController firstContactLastNameController;
  late TextEditingController firstContactRelationshipController;
  late TextEditingController firstContactEmailController;
  late TextEditingController firstContactPhoneController;
  late TextEditingController firstContactLanguageController;
  late TextEditingController firstContactCountryController;
  late TextEditingController firstContactProvinceController;
  late TextEditingController firstContactCityController;
  late TextEditingController firstContactStreetController;

  // 2nd Emergency Contact Controllers
  late TextEditingController secondContactFirstNameController;
  late TextEditingController secondContactLastNameController;
  late TextEditingController secondContactRelationshipController;
  late TextEditingController secondContactEmailController;
  late TextEditingController secondContactPhoneController;
  late TextEditingController secondContactLanguageController;
  late TextEditingController secondContactCountryController;
  late TextEditingController secondContactProvinceController;
  late TextEditingController secondContactCityController;
  late TextEditingController secondContactStreetController;

  /// The values the page opened with, in `_allControllers` order. Preview
  /// compares against this so the button only lights up once something has
  /// actually been edited — a page that merely *has* all its fields filled is
  /// not a change request.
  late List<String> _initialValues;

  @override
  void initState() {
    super.initState();
    _loadEmployeeData();

    _initialValues =
        _allControllers.map((c) => c.text.trim()).toList(growable: false);

    // Rebuild on every keystroke so the Preview button enables/disables live.
    for (final c in _allControllers) {
      c.addListener(_onFieldChanged);
    }
  }

  /// Every field on this page — listened to, and compared for changes.
  /// (Since 9/10/2026 NOT all required: see [_canPreview].)
  List<TextEditingController> get _allControllers => [
        insuranceNameController,
        insurancePolicyNumberController,
        firstContactFirstNameController,
        firstContactLastNameController,
        firstContactRelationshipController,
        firstContactEmailController,
        firstContactPhoneController,
        firstContactLanguageController,
        firstContactCountryController,
        firstContactProvinceController,
        firstContactCityController,
        firstContactStreetController,
        secondContactFirstNameController,
        secondContactLastNameController,
        secondContactRelationshipController,
        secondContactEmailController,
        secondContactPhoneController,
        secondContactLanguageController,
        secondContactCountryController,
        secondContactProvinceController,
        secondContactCityController,
        secondContactStreetController,
      ];

  // CHANGED 9/10/2026 (owner decision) — the 2nd emergency contact is
  // OPTIONAL. `_allFieldsFilled` required all 22 fields, so an employee with
  // a single emergency contact could never submit. Now: insurance + 1st
  // contact required; the 2nd contact empty, or (once any of its fields is
  // typed in) complete. Rule + tests: HealthRequestFormRules.
  List<String> get _insuranceValues => <String>[
        insuranceNameController.text,
        insurancePolicyNumberController.text,
      ];

  List<String> get _firstContactValues => <String>[
        firstContactFirstNameController.text,
        firstContactLastNameController.text,
        firstContactRelationshipController.text,
        firstContactEmailController.text,
        firstContactPhoneController.text,
        firstContactLanguageController.text,
        firstContactCountryController.text,
        firstContactProvinceController.text,
        firstContactCityController.text,
        firstContactStreetController.text,
      ];

  List<String> get _secondContactValues => <String>[
        secondContactFirstNameController.text,
        secondContactLastNameController.text,
        secondContactRelationshipController.text,
        secondContactEmailController.text,
        secondContactPhoneController.text,
        secondContactLanguageController.text,
        secondContactCountryController.text,
        secondContactProvinceController.text,
        secondContactCityController.text,
        secondContactStreetController.text,
      ];

  /// True when the required fields are filled and the optional 2nd contact is
  /// either untouched or complete (9/10/2026).
  bool get _canPreview => HealthRequestFormRules.canPreview(
        insurance: _insuranceValues,
        firstContact: _firstContactValues,
        secondContact: _secondContactValues,
      );

  /// The 2nd contact's empty fields show "required" only after a submit
  /// attempt AND once that contact has been started (9/10/2026).
  bool get _secondContactSubmitted =>
      HealthRequestFormRules.showSecondContactErrors(
        submitted: _submitted,
        secondContact: _secondContactValues,
      );

  /// True once at least one field differs from what the page loaded with.
  bool get _hasChanges {
    final List<TextEditingController> current = _allControllers;
    for (int i = 0; i < current.length; i++) {
      if (current[i].text.trim() != _initialValues[i]) return true;
    }
    return false;
  }

  void _onFieldChanged() {
    if (mounted) setState(() {});
  }

  /// The Preview button. Always visible — greyed out and not tappable until
  /// the user has actually changed something AND every field has a value.
  /// Filled-but-untouched is not enough: submitting then would raise a change
  /// request that changes nothing.
  Widget _buildPreviewButton(BuildContext context) {
    // 9/10/2026: `_canPreview` (2nd contact optional) replaces
    // `_allFieldsFilled`.
    final enabled = _hasChanges && _canPreview;

    return Opacity(
      opacity: enabled ? 1.0 : 0.5,
      child: IgnorePointer(
        // 9/10/2026 (owner UI rule): a greyed-out primary button still reacts
        // to a tap once something changed — `_submitRequest` then marks the
        // missing fields red and says what is missing. With no change at all
        // there is nothing to show, so it stays inert.
        ignoring: !_hasChanges,
        child: customButton(
          title: S.of(context).preview,
          function: _submitRequest,
          color: enabled ? AppColors.primary : AppColors.darkGrey,
          width: 150.w,
          height: 38.h,
          textStyle: StyleText.fontSize16Weight500.copyWith(
            color: AppColors.textButton,
          ),
          radius: 8.r,
        ),
      ),
    );
  }

  @override
  void dispose() {
    for (final c in _allControllers) {
      c.removeListener(_onFieldChanged);
    }

    // Dispose Health Insurance Controllers
    insuranceNameController.dispose();
    insurancePolicyNumberController.dispose();

    // Dispose 1st Emergency Contact Controllers
    firstContactFirstNameController.dispose();
    firstContactLastNameController.dispose();
    firstContactRelationshipController.dispose();
    firstContactEmailController.dispose();
    firstContactPhoneController.dispose();
    firstContactLanguageController.dispose();
    firstContactCountryController.dispose();
    firstContactProvinceController.dispose();
    firstContactCityController.dispose();
    firstContactStreetController.dispose();

    // Dispose 2nd Emergency Contact Controllers
    secondContactFirstNameController.dispose();
    secondContactLastNameController.dispose();
    secondContactRelationshipController.dispose();
    secondContactEmailController.dispose();
    secondContactPhoneController.dispose();
    secondContactLanguageController.dispose();
    secondContactCountryController.dispose();
    secondContactProvinceController.dispose();
    secondContactCityController.dispose();
    secondContactStreetController.dispose();

    super.dispose();
  }

  /// Was `Get.snackbar` with raw Colors.red/white (CR-SKEL-SE4-N17).
  void _showError(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(
            message,
            style: StyleText.fontSize14Weight500.copyWith(
              color: AppColors.textButton,
            ),
          ),
          backgroundColor: AppColors.primary,
          behavior: SnackBarBehavior.floating,
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    bool isTablet = !kpIsPhoneLayout(context);
    Theme.of(context).brightness == Brightness.light;
    var isMobile = ContextExtension(context).isPhone;
    return Scaffold(
      body: isMobile
          ? SideFrameMasterServices(
              titleText: S.of(context).settings,
              onFirstTap: () {
                Navigator.pop(context);
              },
              secondTitle: S.of(context).editingHealthInsurance,
              // Was GetBuilder<RequestController>; the controller no longer has any
              // write method that calls update(), so it rebuilt on nothing
              // (CR-SKEL-SE6-N09).
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    ScrollConfiguration(
                      behavior: const ScrollBehavior().copyWith(
                        scrollbars: false,
                      ),
                      child: SingleChildScrollView(
                        physics: ClampingScrollPhysics(),
                        child: Column(
                          children: [
                            // Card shell matched to the view page (se1_profile /
                            // settings_health_insurance): AppColors.card, an 8.r
                            // radius and 15.sp between cards. The outer wrapper
                            // that used to paint its own background behind these
                            // is gone — it made the three cards read as one slab,
                            // which is exactly what the view page stopped doing.
                            Container(
                              decoration: !isTablet
                                  ? BoxDecoration(
                                      borderRadius: BorderRadius.circular(8.r),
                                      color: AppColors.card,
                                    )
                                  : null,
                              child: Padding(
                                padding: EdgeInsets.only(
                                  right: 15.sp,
                                  left: 15.sp,
                                  top: 15.sp,
                                  bottom: !isTablet ? 15.sp : 0,
                                ),
                                child: EditableHealthInsuranceSection(
                                  insuranceNameController:
                                      insuranceNameController,
                                  insurancePolicyNumberController:
                                      insurancePolicyNumberController,
                                  submitted: _submitted,
                                ),
                              ),
                            ),
                            SizedBox(height: 15.sp),

                            // 1st Emergency Contact Section (Editable)
                            Container(
                              padding: EdgeInsets.only(
                                left: !isTablet ? 15.sp : 0,
                                right: !isTablet ? 15.sp : 0,
                                top: !isTablet ? 15.sp : 0,
                                bottom: !isTablet ? 15.sp : 0,
                              ),
                              decoration: !isTablet
                                  ? BoxDecoration(
                                      borderRadius: BorderRadius.circular(8.r),
                                      color: AppColors.card,
                                    )
                                  : null,
                              child: EditableEmergencyContactInformationSection(
                                submitted: _submitted,
                                isFirstContact: true,
                                firstNameController:
                                    firstContactFirstNameController,
                                lastNameController:
                                    firstContactLastNameController,
                                relationshipController:
                                    firstContactRelationshipController,
                                emailController: firstContactEmailController,
                                mobilePhoneController:
                                    firstContactPhoneController,
                                languageController:
                                    firstContactLanguageController,
                                countryController:
                                    firstContactCountryController,
                                provinceController:
                                    firstContactProvinceController,
                                cityController: firstContactCityController,
                                streetController: firstContactStreetController,
                              ),
                            ),
                            SizedBox(height: 15.sp),

                            // 2nd Emergency Contact Section (Editable)
                            Container(
                              padding: EdgeInsets.only(
                                left: !isTablet ? 15.sp : 0,
                                right: !isTablet ? 15.sp : 0,
                                top: !isTablet ? 15.sp : 0,
                                bottom: !isTablet ? 15.sp : 0,
                              ),
                              decoration: !isTablet
                                  ? BoxDecoration(
                                      borderRadius: BorderRadius.circular(8.r),
                                      color: AppColors.card,
                                    )
                                  : null,
                              child: EditableEmergencyContactInformationSection(
                                // 9/10/2026 — optional contact: errors only once
                                // started; the hint says so.
                                submitted: _secondContactSubmitted,
                                optionalHint:
                                    S.of(context).secondContactOptionalHint,
                                isFirstContact: false,
                                firstNameController:
                                    secondContactFirstNameController,
                                lastNameController:
                                    secondContactLastNameController,
                                relationshipController:
                                    secondContactRelationshipController,
                                emailController: secondContactEmailController,
                                mobilePhoneController:
                                    secondContactPhoneController,
                                languageController:
                                    secondContactLanguageController,
                                countryController:
                                    secondContactCountryController,
                                provinceController:
                                    secondContactProvinceController,
                                cityController: secondContactCityController,
                                streetController: secondContactStreetController,
                              ),
                            ),

                            SizedBox(height: 15.sp),

                            // Action Buttons
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                // Discard Changes Button
                                customButton(
                                  title: S.of(context).discardChange,
                                  function: () {
                                    Navigator.pop(context);
                                  },
                                  color: AppColors.darkGrey,
                                  width: 150.w,
                                  height: 38.h,
                                  textStyle: StyleText.fontSize16Weight500
                                      .copyWith(color: AppColors.text),
                                  radius: 8.r,
                                ),
                                Spacer(),

                                // Submit Button (Now goes to Preview)
                                _buildPreviewButton(context),
                              ],
                            ),

                            SizedBox(height: 20.sp),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            )
          : SideFrameMasterServices(
              titleText: S.of(context).settings,
              onFirstTap: () {
                Navigator.pop(context);
              },
              secondTitle: S.of(context).editingHealthInsurance,
              // Was GetBuilder<RequestController>; the controller no longer has any
              // write method that calls update(), so it rebuilt on nothing
              // (CR-SKEL-SE6-N09).
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    Expanded(
                      child: SingleChildScrollView(
                        physics: ClampingScrollPhysics(),
                        child: Column(
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                color: AppColors.card,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Padding(
                                padding: EdgeInsets.all(15.sp),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Health Insurance Section (Editable)
                                    EditableHealthInsuranceSection(
                                      insuranceNameController:
                                          insuranceNameController,
                                      insurancePolicyNumberController:
                                          insurancePolicyNumberController,
                                      submitted: _submitted,
                                    ),
                                    SizedBox(height: 20.h),

                                    // 1st Emergency Contact Section (Editable)
                                    EditableEmergencyContactInformationSection(
                                      submitted: _submitted,
                                      isFirstContact: true,
                                      firstNameController:
                                          firstContactFirstNameController,
                                      lastNameController:
                                          firstContactLastNameController,
                                      relationshipController:
                                          firstContactRelationshipController,
                                      emailController:
                                          firstContactEmailController,
                                      mobilePhoneController:
                                          firstContactPhoneController,
                                      languageController:
                                          firstContactLanguageController,
                                      countryController:
                                          firstContactCountryController,
                                      provinceController:
                                          firstContactProvinceController,
                                      cityController:
                                          firstContactCityController,
                                      streetController:
                                          firstContactStreetController,
                                    ),
                                    SizedBox(height: 20.h),

                                    // 2nd Emergency Contact Section (Editable)
                                    EditableEmergencyContactInformationSection(
                                      // 9/10/2026 — optional contact (see phone
                                      // layout above).
                                      submitted: _secondContactSubmitted,
                                      optionalHint: S
                                          .of(context)
                                          .secondContactOptionalHint,
                                      isFirstContact: false,
                                      firstNameController:
                                          secondContactFirstNameController,
                                      lastNameController:
                                          secondContactLastNameController,
                                      relationshipController:
                                          secondContactRelationshipController,
                                      emailController:
                                          secondContactEmailController,
                                      mobilePhoneController:
                                          secondContactPhoneController,
                                      languageController:
                                          secondContactLanguageController,
                                      countryController:
                                          secondContactCountryController,
                                      provinceController:
                                          secondContactProvinceController,
                                      cityController:
                                          secondContactCityController,
                                      streetController:
                                          secondContactStreetController,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            SizedBox(height: 15.h),

                            // Action Buttons
                            // This row used to hold two Discard buttons and no
                            // Preview button, so the tablet layout had no way to
                            // reach the preview page at all.
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                // Discard Changes Button
                                customButton(
                                  title: S.of(context).discardChange,
                                  function: () {
                                    Navigator.pop(context);
                                  },
                                  color: AppColors.darkGrey,
                                  width: 150.w,
                                  height: 38.h,
                                  textStyle: StyleText.fontSize16Weight500
                                      .copyWith(color: AppColors.text),
                                  radius: 8.r,
                                ),
                                Spacer(),

                                // Preview Button
                                _buildPreviewButton(context),
                              ],
                            ),

                            SizedBox(height: 10.sp),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}

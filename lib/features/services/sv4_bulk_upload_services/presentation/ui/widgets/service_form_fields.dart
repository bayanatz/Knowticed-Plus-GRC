/// Module: services / sv4_bulk_upload_services / presentation / ui / widgets
///
///*************************** FILE INFO ****************************///
/// File Name: service_form_fields.dart
/// Purpose: Service form fields — declares ServiceFormFields,
///          _ServiceFormFieldsState.
/// Updated: 30/8/2026 - A saved DRAFT carries a Delete button above the form
///                      card, the way a draft role does on adding_new_role.dart.
/// Author: Amr Mesbah
/// Created At: 18/10/2026
library;

import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:knowticed_plus/core/custom/layout/custom_responsive_fields.dart';
import 'package:knowticed_plus/generated/l10n.dart';
import 'package:knowticed_plus/core/custom/inputs/custom_textfield.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';

import 'package:knowticed_plus/core/theme/app_theme.dart';

import 'package:knowticed_plus/features/services/sv4_bulk_upload_services/presentation/controller/create_service_cubit.dart';
import 'package:knowticed_plus/features/services/sv4_bulk_upload_services/presentation/controller/create_service_state.dart';
import 'package:knowticed_plus/features/services/sv4_bulk_upload_services/presentation/ui/widgets/image_upload_widget.dart';
import 'package:knowticed_plus/core/custom/dropdowns/custom_dropdown.dart';
import 'package:knowticed_plus/core/extensions/context_extensions.dart';
// ADDED 30/8/2026 for the draft Delete action — see `_buildDeleteDraftRow`.
import 'package:knowticed_plus/core/custom/buttons/custom_delete_icon.dart';
import 'package:knowticed_plus/core/custom/navigation/custom_navigate.dart';
import 'package:knowticed_plus/core/custom/dialogs/custom_dialog_manager.dart';
import 'package:knowticed_plus/core/custom/feedback/circle_progress.dart';
import 'package:knowticed_plus/core/helper/format_title.dart';
import 'package:knowticed_plus/features/services/helpers/services_module_access.dart';
import 'package:knowticed_plus/features/services/presentation/controller/services_manager_cubit.dart';
import 'package:knowticed_plus/features/services/sv1_home_page_services/presentation/ui/pages/home_page_services_toggle.dart';

import 'package:knowticed_plus/features/services/helpers/constants/services_lottie.dart';
import 'package:knowticed_plus/features/services/domain/enums/service_duration_unit.dart';

class ServiceFormFields extends StatefulWidget {
  const ServiceFormFields({super.key});

  @override
  State<ServiceFormFields> createState() => _ServiceFormFieldsState();
}

class _ServiceFormFieldsState extends State<ServiceFormFields> {
  // Create controllers once
  late final TextEditingController _nameEnController;
  late final TextEditingController _nameArController;
  late final TextEditingController _descEnController;
  late final TextEditingController _descArController;
  late final TextEditingController _durationController;

  @override
  void initState() {
    super.initState();
    _nameEnController = TextEditingController();
    _nameArController = TextEditingController();
    _descEnController = TextEditingController();
    _descArController = TextEditingController();
    _durationController = TextEditingController();
  }

  @override
  void dispose() {
    _nameEnController.dispose();
    _nameArController.dispose();
    _descEnController.dispose();
    _descArController.dispose();
    _durationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';

    return BlocConsumer<CreateServiceCubit, CreateServiceState>(
      listenWhen: (previous, current) {
        // Listen when form data changes from external sources
        if (previous is CreateServiceLoaded && current is CreateServiceLoaded) {
          return previous.formData != current.formData;
        }
        return false;
      },
      listener: (context, state) {
        if (state is CreateServiceLoaded) {
          // Update controllers only if values are different
          _syncControllers(state.formData);
        }
      },
      buildWhen: (previous, current) => current is CreateServiceLoaded,
      builder: (context, state) {
        if (state is! CreateServiceLoaded) return const SizedBox.shrink();

        final cubit = context.read<CreateServiceCubit>();
        final formData = state.formData;

        // Initialize controllers with current values (only once)
        _initializeControllers(formData);

        return Form(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ── DELETE (draft only) ────────────────────────────────────
              // Outside the card, above it, mirroring the Delete on
              // `adding_new_role.dart` — a draft opens straight into its
              // wizard, so this is the only screen from which it can be
              // thrown away. Renders nothing at all unless this really is a
              // saved draft; see [_buildDeleteDraftRow].
              _buildDeleteDraftRow(context, formData),

              Container(
                padding: EdgeInsets.only(top: 15.sp, right: 15.sp, left: 15.sp),
                decoration: BoxDecoration(
                  color: AppColors.card,
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Column(
                  children: [
                    const ImageUploadWidget(),
                    SizedBox(height: 24.sp),

                    // Service Names
                    isArabic
                        ? buildResponsiveFields(
                            left: _buildNameArField(cubit, state.submitted),
                            right: _buildNameEnField(cubit, state.submitted),
                            context: context,
                          )
                        : buildResponsiveFields(
                            left: _buildNameEnField(cubit, state.submitted),
                            right: _buildNameArField(cubit, state.submitted),
                            context: context,
                          ),

                    SizedBox(height: 15.h),

                    // Descriptions
                    _buildDescriptionFields(context, cubit, state.submitted),

                    SizedBox(height: 15.h),

                    // Duration
                    _buildDurationRow(
                      context,
                      cubit,
                      formData,
                      state.submitted,
                    ),

                    SizedBox(height: 15.h),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  /// Function Name: [_buildDeleteDraftRow]
  ///
  /// Purpose: The Delete action for a service that is still a DRAFT.
  ///
  /// ADDED 30/8/2026, modelled on `adding_new_role.dart`: a draft opens
  /// straight into its own wizard, so the screen that edits it is the only
  /// place it can be thrown away — there is no delete affordance on the drafts
  /// list or the service card. The button sits above the form card, aligned to
  /// the trailing edge, exactly where the role screen puts it.
  ///
  /// THREE conditions, and all three are needed:
  ///
  ///   * `isEditMode` — a form opened to CREATE a service has nothing stored to
  ///     delete yet.
  ///   * a non-empty `docId` — the Firestore document to remove.
  ///   * `state == 'draft'` — a live service is deleted from its details page,
  ///     which is where that action already lives (and where the delete
  ///     permission has always been enforced). `CreateServiceFormData.state`
  ///     defaults to `'draft'`, which is why the first two conditions carry the
  ///     weight: without them a brand-new, unsaved form would offer Delete.
  ///
  /// Behind [ServicesModuleAccess.canDeleteService], the same permission the
  /// service-details Delete uses — one action, one gate.
  ///
  /// Parameters:
  /// - [context]: for the dialogs and for the post-delete navigation.
  /// - [formData]: the open form's data; supplies the three conditions above.
  ///
  /// Returns: [Widget] — `SizedBox.shrink()` when this is not a saved draft.
  Widget _buildDeleteDraftRow(BuildContext context, dynamic formData) {
    final String docId = (formData.docId as String?)?.trim() ?? '';
    final bool isSavedDraft = formData.isEditMode == true &&
        docId.isNotEmpty &&
        (formData.state as String).trim().toLowerCase() == 'draft';

    if (!isSavedDraft || !ServicesModuleAccess.canDeleteService) {
      return const SizedBox.shrink();
    }

    final bool isMobile = ContextExtension(context).isPhone;

    return Padding(
      padding: EdgeInsets.only(bottom: 10.sp),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          CustomDeleteIcon(
            color: AppColors.red,
            borderColor: AppColors.transparent,
            svgColor: AppColors.white,
            // Icon-only on phones, matching the service-details header.
            title:
                isMobile ? '' : FormatHelper.capitalize(S.of(context).Delete),
            textStyle: StyleText.fontSize16Weight500.copyWith(
              color: AppColors.white,
            ),
            onTap: () => _confirmDeleteDraft(context, docId),
          ),
        ],
      ),
    );
  }

  /// Function Name: [_confirmDeleteDraft]
  ///
  /// Purpose: Confirm → delete → success → back to the services home.
  ///
  /// ADDED 30/8/2026. Built on [CustomDialogManager.showDialogFlow], the shared
  /// three-step flow `RoleDialogs.showDeleteRoleDialog` uses, rather than on the
  /// service-details module's own `showConfirmationDialogServicesDetails` pair:
  /// the delete this triggers is the same one, but reaching into
  /// `s5_service_details` from here would point an import back at a feature that
  /// already imports this one.
  ///
  /// `attempted` separates "the user pressed No" from "the delete failed" —
  /// without it, cancelling would raise a failure message. Same reasoning, and
  /// the same shape, as the role dialog.
  ///
  /// ⚠️ The delete is a HARD delete: `ServicesManagerCubit.deleteService`
  /// removes the document from `Modules/services/CreateServices`, which is the
  /// one collection holding both drafts and live services. It also refreshes
  /// the services list before returning, so the home screen we land on is
  /// already up to date.
  ///
  /// Parameters:
  /// - [context]: dialog host and navigation source.
  /// - [docId]: the draft document to remove.
  Future<void> _confirmDeleteDraft(BuildContext context, String docId) async {
    final ServicesManagerCubit servicesManager = ServicesManagerCubit.get(
      context,
    );

    bool attempted = false;
    bool deleted = false;

    await CustomDialogManager.showDialogFlow(
      confirmWidth: 411,
      context: context,
      confirmLottie: ServicesLottie.warning,
      confirmTitle: S.of(context).deleteServices,
      confirmSubtitle: S.of(context).AreYouSureDeleteThisService,
      confirmYesText: S.of(context).yes,
      confirmNoText: S.of(context).no,
      onConfirm: () async {
        attempted = true;
        showLoadingIndicator();

        // SVC-HOME-21: deleteService returns whether the delete succeeded.
        deleted = await servicesManager.deleteService(docId);

        hideLoadingIndicator();
        return deleted;
      },
      successLottie: ServicesLottie.approved,
      successTitle: S.of(context).deleteServices,
      successSubtitle: S.of(context).servicesDeleteDone,
      onSuccessComplete: () {
        if (!context.mounted) return;
        // The wizard's own route no longer has a document behind it, so this
        // leaves it rather than popping back into a half-edited draft.
        navigateTo(context, LayoutScreenServices());
      },
    );

    if (attempted && !deleted && context.mounted) {
      await CustomDialogManager.showMessage(
        context: context,
        title: S.of(context).error,
        subtitle: S.of(context).actionFailed,
        lottiePath: ServicesLottie.error,
      );
    }
  }

  void _initializeControllers(dynamic formData) {
    // Only set text if controller is empty and formData has value
    if (_nameEnController.text.isEmpty && formData.serviceNameEn.isNotEmpty) {
      _nameEnController.text = formData.serviceNameEn;
    }
    if (_nameArController.text.isEmpty && formData.serviceNameAr.isNotEmpty) {
      _nameArController.text = formData.serviceNameAr;
    }
    if (_descEnController.text.isEmpty && formData.descriptionEn.isNotEmpty) {
      _descEnController.text = formData.descriptionEn;
    }
    if (_descArController.text.isEmpty && formData.descriptionAr.isNotEmpty) {
      _descArController.text = formData.descriptionAr;
    }
    if (_durationController.text.isEmpty && formData.durationValue.isNotEmpty) {
      _durationController.text = formData.durationValue;
    }
  }

  void _syncControllers(dynamic formData) {
    // Only update if text is different to avoid cursor jumping
    if (_nameEnController.text != formData.serviceNameEn) {
      _nameEnController.text = formData.serviceNameEn;
    }
    if (_nameArController.text != formData.serviceNameAr) {
      _nameArController.text = formData.serviceNameAr;
    }
    if (_descEnController.text != formData.descriptionEn) {
      _descEnController.text = formData.descriptionEn;
    }
    if (_descArController.text != formData.descriptionAr) {
      _descArController.text = formData.descriptionAr;
    }
    if (_durationController.text != formData.durationValue) {
      _durationController.text = formData.durationValue;
    }
  }

  Widget _buildNameEnField(CreateServiceCubit cubit, bool submitted) {
    return Directionality(
      textDirection: ui.TextDirection.ltr,
      child: CustomTextField(
        controller: _nameEnController,
        height: 36,
        maxLines: 1,
        restrictByDirection: true,
        autoCapitalize: true,
        label: S.of(context).svcEnFieldServiceName,
        fillColor: AppColors.background,
        submitted: submitted,
        hint: S.of(context).svcEnFieldHint,
        onChanged: (value) {
          cubit.updateServiceNameEn(value);
        },
      ),
    );
  }

  Widget _buildNameArField(CreateServiceCubit cubit, bool submitted) {
    return Directionality(
      textDirection: ui.TextDirection.rtl,
      child: CustomTextField(
        controller: _nameArController,
        height: 36,
        maxLines: 1,
        fillColor: AppColors.background,
        restrictByDirection: true,
        autoCapitalize: true,
        label: S.of(context).svcArFieldServiceName,
        hint: S.of(context).svcArFieldHint,
        textDirection: ui.TextDirection.rtl,
        submitted: submitted,
        onChanged: (value) {
          cubit.updateServiceNameAr(value);
        },
      ),
    );
  }

  Widget _buildDescriptionFields(
    BuildContext context,
    CreateServiceCubit cubit,
    bool submitted,
  ) {
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';

    if (isArabic) {
      return Column(
        children: [
          Directionality(
            textDirection: ui.TextDirection.rtl,
            child: CustomTextField(
              controller: _descArController,
              height: 72,
              fillColor: AppColors.background,
              label: S.of(context).svcArFieldServiceDescription,
              submitted: submitted,
              onChanged: (value) {
                cubit.updateDescriptionAr(value);
              },
              hint: S.of(context).svcArFieldHint,
              maxLines: 3,
              restrictByDirection: true,
              autoCapitalize: true,
              textDirection: ui.TextDirection.rtl,
              showCharCount: true,
            ),
          ),
          SizedBox(height: 15.sp),
          Directionality(
            textDirection: ui.TextDirection.ltr,
            child: CustomTextField(
              fillColor: AppColors.background,
              controller: _descEnController,
              height: 72,
              label: S.of(context).svcEnFieldServiceDescription,
              hint: S.of(context).svcEnFieldHint,
              submitted: submitted,
              maxLines: 3,
              restrictByDirection: true,
              autoCapitalize: true,
              showCharCount: true,
              textDirection: ui.TextDirection.ltr,
              onChanged: (value) {
                cubit.updateDescriptionEn(value);
              },
            ),
          ),
        ],
      );
    } else {
      return Column(
        children: [
          Directionality(
            textDirection: ui.TextDirection.ltr,
            child: CustomTextField(
              fillColor: AppColors.background,
              controller: _descEnController,
              height: 72,
              label: S.of(context).svcEnFieldServiceDescription,
              hint: S.of(context).svcEnFieldHint,
              maxLines: 3,
              restrictByDirection: true,
              autoCapitalize: true,
              submitted: submitted,
              showCharCount: true,
              textDirection: ui.TextDirection.ltr,
              onChanged: (value) {
                cubit.updateDescriptionEn(value);
              },
            ),
          ),
          SizedBox(height: 15.sp),
          Directionality(
            textDirection: ui.TextDirection.rtl,
            child: CustomTextField(
              fillColor: AppColors.background,
              controller: _descArController,
              height: 72,
              label: S.of(context).svcArFieldServiceDescription,
              onChanged: (value) {
                cubit.updateDescriptionAr(value);
              },
              hint: S.of(context).svcArFieldHint,
              maxLines: 3,
              restrictByDirection: true,
              autoCapitalize: true,
              submitted: submitted,
              textDirection: ui.TextDirection.rtl,
              showCharCount: true,
            ),
          ),
        ],
      );
    }
  }

  Widget _buildDurationRow(
    BuildContext context,
    CreateServiceCubit cubit,
    dynamic formData,
    bool submitted,
  ) {
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';

    // Rule "Constants, no magic values": the saved value is the unit's enum
    // key (ServiceDurationUnit.key), never its translated name.
    final durationUnits = [
      {"key": ServiceDurationUnit.minute.key, "value": S.of(context).minutes},
      {"key": ServiceDurationUnit.hour.key, "value": S.of(context).hours},
      {"key": ServiceDurationUnit.day.key, "value": S.of(context).days},
      {"key": ServiceDurationUnit.week.key, "value": S.of(context).week},
    ];

    // Width of the duration input itself (unchanged — matches the previous
    // breakpoints).
    final double durationFieldWidth = ContextExtension(context).isPhone
        ? 200.sp
        : (ContextExtension(context).isTablet &&
                !ContextExtension(context).isLandscape
            ? 250.sp
            : 350.sp);

    final double gap = 12.sp;

    // buildResponsiveFields() stacks below 600px and otherwise splits the row
    // into two Expanded halves separated by a 15.sp gutter. Mirror that here.
    final bool nameFieldsStack = kpIsPhoneLayout(context);

    return LayoutBuilder(
      builder: (context, constraints) {
        final double rowWidth = constraints.maxWidth;

        // Trailing edge of the leading name field ("Services Name" in LTR,
        // "اسم الخدمة" in RTL) — the duration row must end on the same line.
        final double nameColumnWidth =
            nameFieldsStack ? rowWidth : (rowWidth - 15.sp) / 2;

        // ✅ FIX: the dropdown was Expanded, so it swallowed every pixel to the
        // far edge of the card instead of stopping under the name field above
        // it. Give it an explicit width: whatever remains of that column after
        // the duration input and the gap.
        final double maxDropdownWidth = rowWidth - durationFieldWidth - gap;
        final double minDropdownWidth = 120.sp;

        double dropdownWidth = nameColumnWidth - durationFieldWidth - gap;
        if (dropdownWidth > maxDropdownWidth) dropdownWidth = maxDropdownWidth;
        if (dropdownWidth < minDropdownWidth) {
          // Never clamp up past what the row can actually give us — that would
          // overflow instead of shrinking.
          dropdownWidth = minDropdownWidth > maxDropdownWidth
              ? maxDropdownWidth
              : minDropdownWidth;
        }
        if (dropdownWidth < 0) dropdownWidth = 0;

        return Row(
          // FIXED 9/9/2026 — was the default `center`. Both halves are a
          // Column of [label, gap, box], and centring aligned their MIDPOINTS,
          // not their boxes: the moment the duration field showed a validation
          // line under it, its box slid up while the dropdown's stayed put.
          // `start` pins the two label lines to the same y, and since both
          // labels are one 14.sp line above the shared `kFieldLabelGap`, the
          // two boxes start on the same line too — an error line then grows
          // downward without moving anything.
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: durationFieldWidth,
              child: Directionality(
                textDirection:
                    isArabic ? ui.TextDirection.rtl : ui.TextDirection.ltr,
                child: CustomTextField(
                  controller: _durationController,
                  fillColor: AppColors.background,
                  height: 36,
                  label: S.of(context).durationOfService,
                  hint: S.of(context).Texthere,
                  onlyDigits: true,
                  submitted: submitted,
                  textDirection:
                      isArabic ? ui.TextDirection.rtl : ui.TextDirection.ltr,
                  onChanged: (value) {
                    cubit.updateDurationValue(value);
                  },
                ),
              ),
            ),
            SizedBox(width: gap),
            // Bounded width (not Expanded) — CustomDropdown/InputDecorator
            // still needs a finite width, it just no longer takes all of it.
            SizedBox(
              width: dropdownWidth,
              child: Directionality(
                textDirection:
                    isArabic ? ui.TextDirection.rtl : ui.TextDirection.ltr,
                child: CustomDropdown<String>(
                  value: formData.durationUnit,
                  // The empty label is deliberate: it reserves the same one
                  // 14.sp line + `kFieldLabelGap` that "Duration of Service"
                  // takes on the field beside it, so both boxes start at the
                  // same height with the label written only once.
                  label: '',
                  // ADDED 9/9/2026 — the missing piece. Without it the trigger
                  // sized itself from its own content (a 20.sp chevron inside
                  // 10.sp of vertical padding), which comes out TALLER than the
                  // 36 the duration field beside it is pinned to, so the two
                  // boxes in one row were visibly different heights. `height`
                  // takes the RAW design number and scales it internally —
                  // 36, never 36.sp — exactly as `CustomTextField.height`
                  // above does.
                  height: 36,
                  // Menu ROW height; unrelated to the trigger above.
                  itemHeight: 36.sp,
                  borderRadius: BorderRadius.circular(4.r),
                  hint: S.of(context).sm_chooseunit,
                  items: durationUnits
                      .map(
                        (unit) => DropdownItem<String>(
                          value: unit['key']!,
                          label: unit['value']!,
                        ),
                      )
                      .toList(),
                  fillColor: AppColors.background,
                  onChanged: (value) => cubit.updateDurationUnit(value),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

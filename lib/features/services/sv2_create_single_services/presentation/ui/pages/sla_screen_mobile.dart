/// Module: services / sv2_create_single_services / presentation / ui / pages
///
///*************************** FILE INFO ****************************///
/// File Name: sla_screen_mobile.dart
/// Purpose: The phone version of the create-service SLA & notifications
///          step. The page owns its text fields and draws the sections;
///          SlaMobileCubit saves (submit / save for later).
/// Author: Knowticed Team
/// Created At: 02/07/2026
/// Revision History:
///   - 22/10/2026 (Amr Mesbah): moved from sv12_create_notification_mobile
///     next to the desktop sla_screen_page (Provider rule 18); split into
///     real widget files (rule 7); build-and-save moved to SlaMobileCubit
///     (rule 2), which is provided with its collaborators (rule 4); no
///     try/catch (rules 8, 12); switches keyed by stored value, not by label
///     (rule 5); unused controllers and fields removed (rule 23); the text
///     controllers are disposed (suggestion 4); home is reached by route,
///     not by importing its page (rule 3).
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:knowticed_plus/core/custom/dialogs/custom_dialog_manager.dart';
import 'package:knowticed_plus/core/custom/helpers/custom_svg.dart';
import 'package:knowticed_plus/core/helper/format_title.dart';
import 'package:knowticed_plus/core/theme/app_animations.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/core/theme/haptic_controller.dart';
import 'package:knowticed_plus/features/services/data/models/services_history_model.dart';
import 'package:knowticed_plus/features/services/helpers/constants/services_durations.dart';
import 'package:knowticed_plus/features/services/helpers/constants/services_lottie.dart';
import 'package:knowticed_plus/features/services/helpers/services_text.dart';
import 'package:knowticed_plus/features/services/presentation/controller/services_manager_cubit.dart';
import 'package:knowticed_plus/features/services/presentation/navigation/services_navigation.dart';
import 'package:knowticed_plus/features/services/sv2_create_single_services/data/models/sla_mobile_form.dart';
import 'package:knowticed_plus/features/services/sv2_create_single_services/presentation/controller/create_service_publisher.dart';
import 'package:knowticed_plus/features/services/sv2_create_single_services/presentation/controller/sla_mobile_cubit.dart';
import 'package:knowticed_plus/features/services/sv2_create_single_services/presentation/controller/sla_mobile_state.dart';
import 'package:knowticed_plus/features/services/sv2_create_single_services/presentation/ui/widgets/sla_mobile_dialogs.dart';
import 'package:knowticed_plus/features/services/sv2_create_single_services/presentation/ui/widgets/sla_mobile_manager_switches.dart';
import 'package:knowticed_plus/features/services/sv2_create_single_services/presentation/ui/widgets/sla_mobile_percentage_field.dart';
import 'package:knowticed_plus/features/services/sv2_create_single_services/presentation/ui/widgets/sla_mobile_section.dart';
import 'package:knowticed_plus/generated/l10n.dart';

/// Class Name: [SlaScreenMobile]
///
/// Purpose: Provides the cubit for the phone SLA step.
class SlaScreenMobile extends StatelessWidget {
  const SlaScreenMobile({super.key, this.editingModel});

  final ServicesHistoryModel? editingModel;

  @override
  Widget build(BuildContext context) {
    return BlocProvider<SlaMobileCubit>(
      create: (context) => SlaMobileCubit(
        publisher: CreateServicePublisher(context.read<ServicesManagerCubit>()),
      ),
      child: _SlaMobileView(editingModel: editingModel),
    );
  }
}

class _SlaMobileView extends StatefulWidget {
  const _SlaMobileView({this.editingModel});

  final ServicesHistoryModel? editingModel;

  @override
  State<_SlaMobileView> createState() => _SlaMobileViewState();
}

class _SlaMobileViewState extends State<_SlaMobileView> {
  final TextEditingController _providerPercentage = TextEditingController();
  final TextEditingController _managerPercentage = TextEditingController();
  late SlaMobileForm _form;

  bool get _isEdit => widget.editingModel != null;

  @override
  void initState() {
    super.initState();
    // SVC-PROV-04: the saved values of the service being edited.
    _form = SlaMobileForm.fromModel(
      widget.editingModel ?? context.read<ServicesManagerCubit>().docService,
    );
    _providerPercentage.text = _form.slaOne;
    _managerPercentage.text = _form.slaTwo;
  }

  @override
  void dispose() {
    _providerPercentage.dispose();
    _managerPercentage.dispose();
    super.dispose();
  }

  SlaMobileForm get _currentForm => _form.copyWith(
        slaOne: _providerPercentage.text,
        slaTwo: _managerPercentage.text,
      );

  Future<void> _confirmAndSubmit() async {
    if (!await showSlaMobileConfirmDialog(context, isEdit: _isEdit)) return;
    if (!mounted) return;
    await context.read<SlaMobileCubit>().submit(
          editing: widget.editingModel,
          form: _currentForm,
        );
  }

  Future<void> _onState(BuildContext context, SlaMobileState state) async {
    if (state is SlaMobilePublished) {
      await showSlaMobileSuccessDialog(context, isEdit: state.wasEdit);
      if (!context.mounted) return;
      context.svcGoHome();
    } else if (state is SlaMobileDraftSaved) {
      // SVC-PROV-09: "draft saved", not "service created".
      await CustomDialogManager.showMessage(
        context: context,
        lottiePath: ServicesLottie.approved,
        title: S.of(context).draftSaved,
        subtitle: S.of(context).draftSavedSuccessfully,
        closeAfter: ServicesDurations.successDialog,
      );
      if (!context.mounted) return;
      context.svcGoHome();
    } else if (state is SlaMobileFailed) {
      await CustomDialogManager.showMessage(
        context: context,
        lottiePath: ServicesLottie.error,
        title: S.of(context).error,
        subtitle: S.of(context).errorOccurred,
        closeAfter: ServicesDurations.errorDialog,
      );
    }
  }

  Widget _header() {
    final rtl = Directionality.of(context) == TextDirection.rtl;
    final model = widget.editingModel;
    return Row(
      children: [
        GestureDetector(
          onTap: () {
            HapticController.low();
            Navigator.pop(context);
          },
          child: Transform(
            alignment: Alignment.center,
            transform: rtl ? Matrix4.rotationY(3.1416) : Matrix4.identity(),
            child: CustomSvgImage.natural(
              assetPath:
                  'assets/icons_assets/main_icons_assets/ic_nav_chevron_left.svg',
              width: 18.sp,
              height: 18.sp,
              fit: BoxFit.cover,
              color: AppColors.text,
              semanticsLabel:
                  MaterialLocalizations.of(context).backButtonTooltip,
            ),
          ),
        ),
        SizedBox(width: 16.sp),
        Expanded(
          child: Text(
            model != null
                ? '${S.of(context).Editing} ${context.svcPick(model.currentServiceNameEnglish, model.currentServiceNameArabic)}'
                : S.of(context).creatingNewService,
            style: StyleText.fontSize20Weight600.copyWith(
              color: AppColors.text,
            ),
          ),
        ),
      ],
    );
  }

  Widget _actionButton(
    String text,
    Color color,
    Color textColor,
    VoidCallback onTap,
  ) {
    return Expanded(
      child: GestureDetector(
        onTapDown: (_) => HapticController.medium(),
        onTap: onTap,
        child: Container(
          height: 38.sp,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(6.r),
          ),
          alignment: Alignment.center,
          child: Text(
            text,
            style: StyleText.fontSize16Weight500.copyWith(color: textColor),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final lightMode = Theme.of(context).brightness == Brightness.light;
    return BlocListener<SlaMobileCubit, SlaMobileState>(
      listener: _onState,
      child: SlideInContent(
        from: SlideFrom.bottom,
        child: AnnotatedRegion<SystemUiOverlayStyle>(
          value: SystemUiOverlayStyle(
            statusBarColor: AppColors.background,
            statusBarIconBrightness:
                lightMode ? Brightness.dark : Brightness.light,
            statusBarBrightness: lightMode ? Brightness.light : Brightness.dark,
          ),
          child: Scaffold(
            backgroundColor: AppColors.background,
            body: SafeArea(
              child: Padding(
                padding: EdgeInsets.all(15.sp),
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      _header(),
                      SizedBox(height: 30.sp),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 15.sp),
                        decoration: BoxDecoration(
                          color: AppColors.card,
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(height: 10.sp),
                            Text(
                              FormatHelper.capitalize(s.ServiceFulfillment),
                              style: StyleText.fontSize18Weight500.copyWith(
                                color: AppColors.text,
                              ),
                            ),
                            SizedBox(height: 20.sp),
                            Text(
                              FormatHelper.capitalize(s.SendNotifications),
                              style: StyleText.fontSize14Weight500.copyWith(
                                color: AppColors.text,
                              ),
                            ),
                            SizedBox(height: 29.sp),
                            SlaMobileSection(
                              title: s.notifyServiceRequester,
                              items: [
                                s.WhenTheirManagerApprovesTheService,
                                s.whenServiceStatusChanges,
                                s.whenTheyReceiveCommentFromServiceProvider,
                                s.whenSlaIsBreached,
                              ],
                              isChecked: _form.notifyRequester,
                              onToggle: (v) => setState(
                                () =>
                                    _form = _form.copyWith(notifyRequester: v),
                              ),
                            ),
                            SlaMobileSection(
                              title: s.notifyServiceProvider,
                              items: [
                                s.WhenServiceIsRequestedAndApprovedByTheRequester,
                                s.whenTheyReceiveCommentFromRequester,
                                s.whenSlaIsBreached,
                              ],
                              isChecked: _form.notifyProvider,
                              onToggle: (v) => setState(
                                () => _form = _form.copyWith(notifyProvider: v),
                              ),
                              children: [
                                SlaMobilePercentageField(
                                  controller: _providerPercentage,
                                  onChanged: (_) => setState(() {}),
                                ),
                              ],
                            ),
                            SlaMobileSection(
                              title: s.notifyProviderManager,
                              items: [s.whenProviderBreachedSla],
                              isChecked: _form.notifyManager,
                              onToggle: (v) => setState(
                                () => _form = _form.copyWith(notifyManager: v),
                              ),
                              children: [
                                SlaMobileManagerSwitches(
                                  whenRequestedAndApproved:
                                      _form.whenRequestedAndApproved,
                                  whenStatusChanges: _form.whenStatusChanges,
                                  onRequestedAndApproved: (v) => setState(
                                    () => _form = _form.copyWith(
                                      whenRequestedAndApproved: v,
                                    ),
                                  ),
                                  onStatusChanges: (v) => setState(
                                    () => _form = _form.copyWith(
                                      whenStatusChanges: v,
                                    ),
                                  ),
                                ),
                                SlaMobilePercentageField(
                                  controller: _managerPercentage,
                                  onChanged: (_) => setState(() {}),
                                  indent: 24,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 20.sp),
                      Row(
                        children: [
                          _actionButton(
                            _isEdit ? s.discard : s.saveForLater,
                            AppColors.secondaryAction,
                            AppColors.onSecondaryAction,
                            () => _isEdit
                                // Edit mode: Discard = just go back.
                                ? Navigator.pop(context)
                                : context.read<SlaMobileCubit>().saveDraft(
                                      editing: widget.editingModel,
                                      form: _currentForm,
                                    ),
                          ),
                          SizedBox(width: 75.sp),
                          // QA p.16: "Submit" in both create and edit.
                          _actionButton(
                            s.submit,
                            AppColors.primary,
                            AppColors.textButton,
                            _confirmAndSubmit,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Module: services / sv2_create_single_services / presentation / ui / pages
///
///*************************** FILE INFO ****************************///
/// File Name: select_services_provider.dart
/// Purpose: Main provider selection page - combines all widgets Created by: Amr
///          Mesbah Last Update: 6/2/2026
/// Author: Amr Mesbah
/// Created At: 18/10/2026
library;

import 'package:flutter/material.dart';
import 'package:knowticed_plus/core/custom/navigation/custom_side_frame_master.dart';
import 'package:knowticed_plus/core/di/app_controllers.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:knowticed_plus/features/roles/r1_role_management/presentation/controller/role_cubit.dart';
import 'package:knowticed_plus/features/roles/r1_role_management/data/repository/role_repository.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:knowticed_plus/features/services/sv1_home_page_services/presentation/ui/pages/home_page_services_toggle.dart';

import 'package:knowticed_plus/core/helper/format_title.dart';

import 'package:knowticed_plus/generated/l10n.dart';

import 'package:knowticed_plus/core/custom/navigation/custom_navigate.dart';
import 'package:knowticed_plus/core/custom/dialogs/custom_dialog_manager.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_animations.dart';
import 'package:knowticed_plus/core/custom/buttons/custom_button.dart';

import 'package:knowticed_plus/core/theme/app_theme.dart';

import 'package:knowticed_plus/features/roles/r4_active_directory/presentation/controller/main_core_department_cubit.dart';
import 'package:knowticed_plus/features/services/data/models/services_history_model.dart';
import 'package:knowticed_plus/features/services/presentation/controller/services_manager_cubit.dart';

import 'package:knowticed_plus/features/services/sv2_create_single_services/presentation/ui/pages/details_switch_screen_toggle.dart';
import 'package:knowticed_plus/features/services/sv2_create_single_services/presentation/controller/provider_selection_cubit.dart';
import 'package:knowticed_plus/features/services/sv2_create_single_services/presentation/controller/provider_selection_state.dart';
import 'package:knowticed_plus/features/services/sv2_create_single_services/presentation/ui/widgets/select_provider_action_buttons_row.dart';
import 'package:knowticed_plus/features/services/sv2_create_single_services/presentation/ui/widgets/provider_grid.dart';
import 'package:knowticed_plus/features/services/sv2_create_single_services/presentation/ui/widgets/save_for_later_button.dart';
import 'package:knowticed_plus/features/services/sv2_create_single_services/presentation/ui/widgets/search_header.dart';
import 'package:knowticed_plus/features/services/sv2_create_single_services/presentation/ui/widgets/selected_provider_details.dart';
import 'package:knowticed_plus/core/custom/feedback/circle_progress.dart';

import 'package:knowticed_plus/features/services/helpers/constants/services_lottie.dart';

class SelectServicesProviderPage extends StatefulWidget {
  final ServicesHistoryModel? editingModel;
  final String? docId;
  final ServicesHistoryModel? editProvider;

  const SelectServicesProviderPage({
    super.key,
    this.editingModel,
    this.docId,
    this.editProvider,
  });

  @override
  State<SelectServicesProviderPage> createState() =>
      _SelectServicesProviderPageState();
}

class _SelectServicesProviderPageState
    extends State<SelectServicesProviderPage> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SlideInContent(
      from: SlideFrom.bottom,
      child: BlocProvider(
        create: (context) => ProviderSelectionCubit(
          employeeController: AppControllers.employee,
          departmentController: context.read<MainCoreDepartmentCubit>(),
          servicesManagerCubit: ServicesManagerCubit.get(context),
          roleRepository: context.read<RoleRepository>(),
          roles: () => roleCubit.roles,
        )..initialize(
            editingModel: widget.editingModel,
            docId: widget.docId,
            editProvider: widget.editProvider,
          ),
        // ✅ FIXED: Added missing 'child:' parameter
        child: BlocConsumer<ProviderSelectionCubit, ProviderSelectionState>(
          listenWhen: (previous, current) {
            // ✅ FIX: Don't re-fire listener if we're restoring back to loaded
            // Only listen when transitioning TO a nav/action state
            if (current is ProviderSelectionLoaded &&
                previous is ProviderSelectionLoaded) {
              return false; // Normal UI update, don't trigger listener
            }
            return current is ProviderSelectionNavigateBack ||
                current is ProviderSelectionNavigateToDetails ||
                current is ProviderSelectionProviderUpdated ||
                current is ProviderSelectionSaved ||
                current is ProviderSelectionSavedToFirebase ||
                current is ProviderSelectionShowWarning ||
                current is ProviderSelectionError;
          },
          listener: _handleStateChanges,
          builder: (context, state) {
            // Handle initial and loading states
            if (state is ProviderSelectionInitial ||
                state is ProviderSelectionLoading) {
              return Scaffold(
                backgroundColor: AppColors.background,
                body: Center(child: CircleProgressMaster.inline()),
              );
            }

            // Handle saving state - show loading with text
            if (state is ProviderSelectionSaving) {
              return Scaffold(
                backgroundColor: AppColors.background,
                body: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircleProgressMaster.inline(),
                      SizedBox(height: 16),
                      Text(S.of(context).savingDraft),
                    ],
                  ),
                ),
              );
            }

            // ✅ FIXED: This state is handled in listener, show loading while navigating
            // Don't show static screen - let listener handle navigation
            if (state is ProviderSelectionSavedToFirebase) {
              return Scaffold(
                backgroundColor: AppColors.background,
                body: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.check_circle,
                        color: AppColors.green,
                        size: 64,
                      ),
                      SizedBox(height: 16),
                      Text(S.of(context).draftSavedSuccessfully),
                      SizedBox(height: 16),
                      CircleProgressMaster
                          .inline(), // Show navigating indicator
                      SizedBox(height: 8),
                      Text(S.of(context).redirecting),
                    ],
                  ),
                ),
              );
            }

            // Handle error state
            if (state is ProviderSelectionError) {
              return Scaffold(
                backgroundColor: AppColors.background,
                body: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.error_outline,
                        color: AppColors.red,
                        size: 64.sp,
                      ),
                      SizedBox(height: 16.h),
                      Text(S.of(context).svcSomethingWentWrong),
                      SizedBox(height: 16.h),
                      customButton(
                        title: S.of(context).goBack,
                        function: () {
                          // Retry or go back
                          Navigator.pop(context);
                        },
                        width: 120.sp,
                        height: 40.sp,
                        color: AppColors.primary,
                        textColor: AppColors.textButton,
                      ),
                    ],
                  ),
                ),
              );
            }

            // Only show main UI for loaded state
            if (state is! ProviderSelectionLoaded) {
              return Scaffold(
                backgroundColor: AppColors.background,
                body: Center(child: CircleProgressMaster.inline()),
              );
            }

            final cubit = context.read<ProviderSelectionCubit>();
            final data = state.data;

            return Scaffold(
              backgroundColor: AppColors.background,
              body: SafeArea(
                child: SideFrameMasterServices(
                  titleText: S.of(context).service,
                  onFirstTap: () => _navigateToHome(context),
                  secondTitle: _screenTitle(context, cubit),
                  child: SingleChildScrollView(
                    physics: const ClampingScrollPhysics(),
                    child: Column(
                      children: [
                        // Section Header
                        _buildSectionHeader(context),
                        SizedBox(height: 8.sp),

                        // Edit Mode Banner (only in edit mode)
                        //    if (data.isEditMode) const EditModeBanner(),

                        // Main Card with Provider Grid
                        _buildProviderCard(context),

                        SizedBox(height: 20.sp),

                        // Action Buttons (Back & Next/Save)
                        const ActionButtonsRow(),

                        SizedBox(height: 10.sp),

                        // ✅          Save For Later Button — hidden in editProvider mode
                        if (data.editProvider == null)
                          const SaveForLaterButton(),

                        SizedBox(height: 20.sp),

                        SizedBox(height: 20.sp),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Text(
          FormatHelper.capitalize(S.of(context).serviceProvider),
          style: StyleText.fontSize18Weight500.copyWith(color: AppColors.text),
        ),
      ],
    );
  }

  Widget _buildProviderCard(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(left: 15.sp, right: 15.sp, top: 15.sp),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Column(
        children: [
          // Search Header
          SearchHeader(controller: _searchController),
          SizedBox(height: 15.sp),

          // Provider Grid
          const ProviderGrid(),
          SizedBox(height: 15.sp),

          // Selected Provider Details (appears when providers selected)
          const SelectedProviderDetails(),
        ],
      ),
    );
  }

  void _handleStateChanges(BuildContext context, ProviderSelectionState state) {
    if (state is ProviderSelectionShowWarning) {
      _showWarningDialog(context);
    } else if (state is ProviderSelectionNavigateBack) {
      // ✅ FIX: Check we're still mounted before popping
      if (Navigator.canPop(context)) {
        Navigator.pop(context);
      }
    } else if (state is ProviderSelectionProviderUpdated) {
      // ✅ Await the dialog before navigating. It used to be fired and
      // immediately followed by navigateTo, so the page swapped out from under
      // the dialog and the success message was never really seen.
      // CustomDialogManager.showSuccess auto-closes after 1.5s and completes.
      _showSuccessChangeProviderDialog(context).then((_) {
        if (!mounted) return;
        if (!context.mounted) return;
        navigateTo(context, LayoutScreenServices());
      });
    } else if (state is ProviderSelectionSaved) {
      // 🚫 SNACKBAR REMOVED — this raised "Draft saved successfully!", a
      // hardcoded English string that never went through S.of(context), on a
      // screen where every other message is a localized dialog. The save is
      // already confirmed by the Save For Later dialog the user just accepted,
      // so the state now needs no announcement of its own.
    } else if (state is ProviderSelectionSavedToFirebase) {
      // 🚫 SNACKBAR REMOVED — same as above ("Draft saved to Firebase!", which
      // also named our backend to the user). The navigation below is the
      // feedback: the screen closes back to the services list.
      // S2: the save already finished (this state says so) — navigate now
      // instead of after a fixed 500 ms wait.
      navigateAndFinish(context, LayoutScreenServices());
    } else if (state is ProviderSelectionNavigateToDetails) {
      _navigateToDetails(context, state);
    } else if (state is ProviderSelectionError) {
      // 🚫 SNACKBAR REMOVED — but not the message itself. Dropping a failure
      // silently would leave the user believing a save worked when it did not,
      // so this now uses CustomDialogManager.showMessage, which is documented
      // for exactly this and stays up until dismissed rather than timing out
      // after two seconds like the snackbar did.
      _showErrorDialog(context, _errorText(context, state.issue));
    }
  }

  // ✅ Both dialogs below now come from CustomDialogManager
  // (core/custom/57-custom_dialog_manager.dart).
  //
  // They used to be built inline here: a bare AlertDialog for the warning
  // (which sizes itself to its text, so it came out much narrower than
  // everything else) and a hand-rolled Dialog for the success message. Every
  // other dialog in the app is 500.sp wide with 24.r padding, so these two were
  // the odd ones out. Routing them through the manager means the width, the
  // padding, the corner radius, the dark-mode background and the lottie sizing
  // are all decided in one place.

  void _showWarningDialog(BuildContext context) {
    CustomDialogManager.showMessage(
      context: context,
      lottiePath: ServicesLottie.warningRed,
      title: S.of(context).warning,
      subtitle: S.of(context).pleaseSelectOneProviderAtLeast,
    );
  }

  Future<void> _showSuccessChangeProviderDialog(BuildContext context) {
    return CustomDialogManager.showSuccess(
      context: context,
      lottiePath: ServicesLottie.approved,
      title: S.of(context).changingServiceProvider,
      subtitle: S.of(context).successChangeServiceProvider,
    );
  }

  /// The translated text for a [ProviderSelectionIssue] (Create R3).
  String _errorText(BuildContext context, ProviderSelectionIssue issue) {
    final s = S.of(context);
    switch (issue) {
      case ProviderSelectionIssue.draftSaveFailed:
        return s.svcDraftNotSaved;
      case ProviderSelectionIssue.providerUpdateFailed:
        return s.svcProviderUpdateFailed;
      case ProviderSelectionIssue.unexpected:
        return s.svcSomethingWentWrong;
    }
  }

  void _showErrorDialog(BuildContext context, String message) {
    CustomDialogManager.showMessage(
      context: context,
      lottiePath: ServicesLottie.rejected,
      title: S.of(context).error,
      subtitle: message,
    );
  }

  void _navigateToHome(BuildContext context) {
    navigateTo(context, const LayoutScreenServices());
  }

  void _navigateToDetails(
    BuildContext context,
    ProviderSelectionNavigateToDetails state,
  ) {
    if (state.docId != null && widget.editingModel != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => DetailsToggleScreen(
            editingModel: state.completeModel,
            docId: state.docId,
          ),
          maintainState: true,
        ),
      );
    } else {
      navigateTo(
        context,
        DetailsToggleScreen(
          editingModel:
              widget.editingModel != null ? state.completeModel : null,
          docId: state.docId,
        ),
      );
    }
  }

  /// C6: the page title is built here, where the context is (it used to be
  /// a cubit method taking a BuildContext).
  String _screenTitle(BuildContext context, ProviderSelectionCubit cubit) {
    final currentState = cubit.state as ProviderSelectionLoaded;
    final data = currentState.data;

    // 004: localized title via .arb instead of a hardcoded Arabic literal.
    if (data.editProvider != null) {
      return S.of(context).editServiceProvider;
    }

    if (data.editingModel == null && data.docId == null) {
      return S.of(context).creatingNewService;
    }

    if (data.editingModel != null) {
      final isDraft = data.editingModel!.currentState == "draft" ||
          data.editingModel!.currentDurationOfServices == "-" ||
          data.editingModel!.currentDurationOfServices.isEmpty;

      final serviceName = Localizations.localeOf(context).languageCode == 'ar'
          ? data.editingModel!.currentServiceNameArabic
          : data.editingModel!.currentServiceNameEnglish;

      if (isDraft) {
        return "${S.of(context).draft} $serviceName";
      } else {
        return "${S.of(context).Editing} $serviceName";
      }
    }

    if (data.docId != null) {
      return S.of(context).creatingNewService;
    }

    return S.of(context).creatingNewService;
  }
}

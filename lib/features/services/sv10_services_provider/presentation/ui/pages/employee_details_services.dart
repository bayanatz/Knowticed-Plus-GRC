/// Module: services / sv10_services_provider / presentation / ui / pages
///
///*************************** FILE INFO ****************************///
/// File Name: employee_details_services.dart
/// Purpose: The provider's view of one request: its details, the status
///          menu (approved → in progress → done) and the comments. The status
///          rules come from ProviderRequestRules and the save from
///          EmployeeActionCubit; the page draws and listens.
/// Author: Knowticed Team
/// Created At: 02/07/2026
/// Revision History:
///   - 22/10/2026 (Amr Mesbah): one real page file (part files and the
///     toggle whose branches all returned this page removed, rules 6, 15,
///     25, 26); renamed from EmployeeDetailsServicesScreenTablet (rule 17);
///     status rules moved to the controller (rule 2); the cubit is provided
///     with injected collaborators (rule 4); no try/catch here — the page
///     listens to the cubit's states (rule 8); unused fields and label /
///     colour helpers removed (rule 22).
library;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:knowticed_plus/core/custom/inputs/custom_comment_widget.dart';
import 'package:knowticed_plus/core/custom/navigation/custom_side_frame_master.dart';
import 'package:knowticed_plus/core/di/app_controllers.dart';
import 'package:knowticed_plus/core/helper/format_title.dart';
import 'package:knowticed_plus/core/network/api_constants.dart'
    show FirestoreCollections;
import 'package:knowticed_plus/core/network/get_base_url.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/features/services/data/data_source/remote_data_source/services_notification_service.dart';
import 'package:knowticed_plus/features/services/data/models/request_comment_fields.dart';
import 'package:knowticed_plus/features/services/data/models/services_history_model.dart';
import 'package:knowticed_plus/features/services/domain/base_repository/service_repository.dart';
import 'package:knowticed_plus/features/services/helpers/services_feedback.dart';
import 'package:knowticed_plus/features/services/helpers/services_text.dart';
import 'package:knowticed_plus/features/services/sv10_services_provider/presentation/controller/employee_action_cubit.dart';
import 'package:knowticed_plus/features/services/sv10_services_provider/presentation/controller/employee_action_state.dart';
import 'package:knowticed_plus/features/services/sv10_services_provider/presentation/controller/provider_request_rules.dart';
import 'package:knowticed_plus/features/services/sv10_services_provider/presentation/ui/widgets/employee_details_dialogs_and_sections.dart';
import 'package:knowticed_plus/features/services/sv10_services_provider/presentation/ui/widgets/request_details_content.dart';
import 'package:knowticed_plus/features/services/sv10_services_provider/presentation/ui/widgets/request_status_dropdown.dart';
import 'package:knowticed_plus/generated/l10n.dart';

/// Class Name: [EmployeeDetailsServicesScreen]
///
/// Purpose: Provides the status-change cubit for [approvalModel].
class EmployeeDetailsServicesScreen extends StatelessWidget {
  const EmployeeDetailsServicesScreen({required this.approvalModel, super.key});

  final ServicesHistoryModel approvalModel;

  @override
  Widget build(BuildContext context) {
    return BlocProvider<EmployeeActionCubit>(
      create: (context) => EmployeeActionCubit(
        repository: context.read<CreateServicesRepository>(),
        notifications: context.read<ServicesNotificationService>(),
        senderEmail: AppControllers.employee.employeeEntity?.email ?? '',
      ),
      child: _EmployeeDetailsView(request: approvalModel),
    );
  }
}

class _EmployeeDetailsView extends StatefulWidget {
  const _EmployeeDetailsView({required this.request});

  final ServicesHistoryModel request;

  @override
  State<_EmployeeDetailsView> createState() => _EmployeeDetailsViewState();
}

class _EmployeeDetailsViewState extends State<_EmployeeDetailsView> {
  late String _currentState;
  String? _selectedState;
  bool _isCommentExpanded = false;

  @override
  void initState() {
    super.initState();
    // SVC-PROV-01: opening the page writes nothing.
    _currentState = ProviderRequestRules.effectiveState(widget.request);
  }

  String get _effectiveState => (_selectedState ?? _currentState).toLowerCase();

  /// Confirm, then save. Runs on a fresh event-loop turn after the menu
  /// closed — not in a post-frame callback (MouseTracker re-entrancy, see
  /// the 30/8/2026 note in git history).
  Future<void> _applyStateChange(String value) async {
    if (!await showChangeStatusConfirmationDialog(context)) return;
    if (!mounted) return;
    setState(() => _selectedState = value);
    await context.read<EmployeeActionCubit>().changeStatus(
          request: widget.request,
          newState: value,
        );
  }

  Future<void> _onActionState(
    BuildContext context,
    EmployeeActionState state,
  ) async {
    if (state is EmployeeActionSaved) {
      setState(() => _currentState = state.newState);
      // SVC-PROV-12: saved, but say so when the requester was not notified.
      if (state.notificationFailed) {
        ServicesFeedback.showWarning(
          ScaffoldMessenger.of(context),
          S.of(context).svcStatusSavedNotifyFailed,
        );
      }
      await showChangeStatusSuccessDialog(context, newStatus: state.newState);
      if (!context.mounted) return;
      // SVC-PROV-15: back to the list, which reloads.
      Navigator.of(context).pop(true);
    } else if (state is EmployeeActionRefused ||
        state is EmployeeActionFailed) {
      setState(() => _selectedState = null);
      // SVC-PROV-06: a refused change shows a message, never the exception.
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            state is EmployeeActionRefused
                ? S.of(context).notAllowed
                : S.of(context).errorOccuredPleaseTryAgain,
          ),
          backgroundColor: AppColors.red,
        ),
      );
    }
  }

  CommentSectionStyle get _commentStyle => CommentSectionStyle(
        hintStyle: StyleText.fontSize16Weight400.copyWith(
          color: AppColors.secondaryText.withValues(alpha: .5),
        ),
        commentTextStyle: StyleText.fontSize18Weight500.copyWith(
          color: AppColors.text,
        ),
        fileChipDecoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(8.r),
        ),
        fileIconColor: AppColors.text,
        fileNameStyle: StyleText.fontSize12Weight400.copyWith(
          color: AppColors.text,
        ),
        avatarColor: AppColors.background,
        inputFillColor: AppColors.card,
        containerDecoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(8.r),
        ),
        commentItemDecoration: BoxDecoration(
          color: AppColors.transparent,
          borderRadius: BorderRadius.circular(8.r),
        ),
        userNameStyle: StyleText.fontSize16Weight400.copyWith(
          color: AppColors.text,
        ),
        sendButtonDecoration: BoxDecoration(
          color: AppColors.secondaryPrimary,
          borderRadius: BorderRadius.circular(8.r),
        ),
        sendIconColor: AppColors.secondaryPrimaryText,
      );

  @override
  Widget build(BuildContext context) {
    final request = widget.request;
    final cycle = request.currentApprovalCycle;
    final displayCycle = ProviderRequestRules.displayCycle(cycle);
    final showMenu = ProviderRequestRules.showsStatusMenu(_currentState, cycle);
    final height = MediaQuery.sizeOf(context).height;

    return BlocListener<EmployeeActionCubit, EmployeeActionState>(
      listener: _onActionState,
      child: Scaffold(
        body: SafeArea(
          child: SideFrameMasterServices(
            titleText: S.of(context).serviceRequests,
            onFirstTap: () => Navigator.pop(context),
            secondTitle: S.of(context).requestedServices,
            onSecondTap: () => Navigator.pop(context),
            thirdTitle: FormatHelper.capitalize(
              context.svcPick(
                request.currentServiceNameEnglish,
                request.currentServiceNameArabic,
              ),
            ),
            child: SingleChildScrollView(
              physics: const ClampingScrollPhysics(),
              child: Column(
                children: [
                  if (!_isCommentExpanded) ...[
                    SizedBox(
                      height: 50.sp,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            S.of(context).serviceDetails,
                            style: StyleText.fontSize18Weight500.copyWith(
                              color: AppColors.blackButton,
                            ),
                          ),
                          const Spacer(),
                          if (showMenu)
                            RequestStatusDropdown(
                              currentState: _currentState,
                              selectedState: _selectedState,
                              options: ProviderRequestRules.nextStates(
                                _effectiveState,
                              ),
                              onChanged: (value) =>
                                  Future<void>.delayed(Duration.zero, () {
                                if (!mounted) return;
                                _applyStateChange(value);
                              }),
                            ),
                        ],
                      ),
                    ),
                    SizedBox(height: 10.sp),
                    RequestDetailsContent(
                      request: request,
                      displayCycle: displayCycle,
                      currentState: _currentState.isEmpty
                          ? ProviderRequestRules.effectiveState(request)
                          : _currentState,
                    ),
                    SizedBox(height: 20.sp),
                  ],
                  UniversalCommentSection(
                    collectionPath: getBaseUrl(
                      FirestoreCollections.commentsRoot,
                    ),
                    filterFields: {
                      RequestCommentFields.requestId: request.currentId,
                    },
                    currentUserId:
                        AppControllers.employee.employeeEntity?.email ?? '',
                    isExpandable: true,
                    fixedHeight: _isCommentExpanded ? height * 0.85 : height,
                    onExpandChanged: (expanded) =>
                        setState(() => _isCommentExpanded = expanded),
                    style: _commentStyle,
                  ),
                  if (!_isCommentExpanded) SizedBox(height: 20.sp),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

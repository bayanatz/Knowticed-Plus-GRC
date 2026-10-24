/// Module: services / sv6_services_requests / presentation / ui / pages
///
///*************************** FILE INFO ****************************///
/// File Name: request_details.dart
/// Purpose: The details of a service the user can request: header, provider
///          block, approval cycle and the Request button. Creating the
///          request is done by NewRequestCubit through
///          RequestServiceDialogs.run; the provider is read once in
///          initState.
/// Author: Amr Mesbah
/// Created at: 02/02/2026
library;

import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:knowticed_plus/core/custom/buttons/custom_button.dart';
import 'package:knowticed_plus/core/custom/navigation/custom_navigate.dart';
import 'package:knowticed_plus/core/custom/navigation/custom_side_frame_master.dart';
import 'package:knowticed_plus/core/extensions/context_extensions.dart';
import 'package:knowticed_plus/core/helper/format_title.dart';
import 'package:knowticed_plus/core/theme/app_animations.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/features/services/data/models/services_history_model.dart';
import 'package:knowticed_plus/features/services/data/data_source/remote_data_source/services_notification_service.dart';
import 'package:knowticed_plus/features/services/domain/base_repository/service_repository.dart';
import 'package:knowticed_plus/features/services/helpers/services_text.dart';
import 'package:knowticed_plus/features/services/presentation/controller/services_manager_cubit.dart';
import 'package:knowticed_plus/features/services/sv1_home_page_services/presentation/ui/pages/home_page_services_toggle.dart';
import 'package:knowticed_plus/features/services/sv6_services_requests/presentation/controller/new_request_cubit.dart';
import 'package:knowticed_plus/features/services/sv6_services_requests/presentation/ui/widgets/approval_cycle_widget.dart';
import 'package:knowticed_plus/features/services/sv6_services_requests/presentation/ui/widgets/request_service_dialogs.dart';
import 'package:knowticed_plus/features/services/presentation/widgets/responsive_text.dart';
import 'package:knowticed_plus/features/services/sv6_services_requests/presentation/ui/widgets/service_header_widget.dart';
import 'package:knowticed_plus/features/services/presentation/widgets/show_requests_shimmer.dart';
import 'package:knowticed_plus/generated/l10n.dart';

class RequestServicesDetails extends StatelessWidget {
  const RequestServicesDetails({required this.requestModel, super.key});

  /// The service being looked at.
  final ServicesHistoryModel requestModel;

  @override
  Widget build(BuildContext context) {
    final manager = ServicesManagerCubit.get(context);
    return BlocProvider(
      create: (context) => NewRequestCubit(
        manager: manager,
        notifications: context.read<ServicesNotificationService>(),
        requester: manager.hasEmployeeEntity ? manager.employeeEntity : null,
      ),
      child: _RequestServicesDetailsView(requestModel: requestModel),
    );
  }
}

class _RequestServicesDetailsView extends StatefulWidget {
  const _RequestServicesDetailsView({required this.requestModel});

  final ServicesHistoryModel requestModel;

  @override
  State<_RequestServicesDetailsView> createState() =>
      _RequestServicesDetailsViewState();
}

class _RequestServicesDetailsViewState
    extends State<_RequestServicesDetailsView> {
  late final Future<Map<String, dynamic>?> _provider;

  ServicesHistoryModel get _model => widget.requestModel;

  @override
  void initState() {
    super.initState();
    // Read once; a Future created in build() would refire on every rebuild.
    _provider = context
        .read<CreateServicesRepository>()
        .selectServiceProvider(_model.currentId)
        .catchError((Object _) => null);
  }

  @override
  Widget build(BuildContext context) {
    return SlideInContent(
      from: SlideFrom.bottom,
      child: Scaffold(
        body: SafeArea(
          child: SideFrameMasterServices(
            titleText: FormatHelper.capitalize(S.of(context).services),
            onFirstTap: () => navigateTo(context, LayoutScreenServices()),
            secondTitle: FormatHelper.capitalize(S.of(context).serviceRequests),
            onSecondTap: () => Navigator.pop(context),
            thirdTitle: FormatHelper.capitalize(
              context.svcPick(
                _model.currentServiceNameEnglish,
                _model.currentServiceNameArabic,
              ),
            ),
            // The frame already scrolls this child on a phone; see
            // `SideFrameScrollableBody`.
            child: SideFrameScrollableBody(
              physics: const ClampingScrollPhysics(),
              child: Column(
                children: [
                  Row(
                    children: [
                      Text(
                        FormatHelper.capitalize(S.of(context).serviceDetails),
                        style: StyleText.fontSize16Weight600.copyWith(
                          color: AppColors.blackButton,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 4.sp),
                  _buildDetailsCard(context),
                  SizedBox(height: 20.sp),
                  _buildActions(context),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDetailsCard(BuildContext context) {
    final lightMode = Theme.of(context).brightness == Brightness.light;
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8.r),
        color: AppColors.card,
      ),
      child: Column(
        children: [
          ServiceHeaderWidget(requestModel: _model),
          SizedBox(height: 18.sp),
          FutureBuilder<Map<String, dynamic>?>(
            future: _provider,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return _buildProviderShimmer(context);
              }
              final provider = snapshot.data;
              if (provider == null) {
                return Center(
                  child: Text(
                    S.of(context).Noproviderdatafound,
                    style: StyleText.fontSize14Weight400.copyWith(
                      color: AppColors.secondaryText,
                    ),
                  ),
                );
              }
              return buildProviderServiceDetailsServices(
                context: context,
                owningDepartment: _model.currentDepartmentRequester,
                durationUnit: FormatHelper.capitalize(
                  context.svcDurationUnit(
                    _model.currentSelectedDurationUnit,
                    num.tryParse(_model.currentDurationOfServices) ?? 0,
                  ),
                ),
                provider: provider,
                requestModel: _model,
              );
            },
          ),
          SizedBox(height: 20.h),
          if (_model.currentApprovalCycle.isNotEmpty) ...[
            Row(
              children: [
                Text(
                  '${S.of(context).approvalCycle}: ',
                  style: StyleText.fontSize14Weight400.copyWith(
                    color:
                        lightMode ? AppColors.secondaryText : AppColors.white,
                  ),
                ),
              ],
            ),
            SizedBox(height: 12.h),
            ApprovalCycleWidgetServices(
              approvalCycle: _model.currentApprovalCycle,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildProviderShimmer(BuildContext context) {
    final isMobile = ContextExtension(context).isPhone;
    Widget column(List<double> widths) => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (var i = 0; i < widths.length; i++) ...[
              if (i > 0) SizedBox(height: 10.h),
              masterShimmerPlaceholder(
                context: context,
                width: widths[i],
                height: 20,
              ),
            ],
          ],
        );
    return Row(
      children: [
        column(const [200, 150, 180]),
        if (!isMobile) ...[
          SizedBox(width: MediaQuery.sizeOf(context).width * .05),
          column(const [160, 140, 180]),
        ],
      ],
    );
  }

  Widget _buildActions(BuildContext context) {
    return Row(
      children: [
        customButton(
          title: FormatHelper.capitalize(S.of(context).back),
          function: () => Navigator.pop(context),
          textStyle: StyleText.fontSize16Weight500.copyWith(
            color: AppColors.onSecondaryAction,
          ),
          width: 150.sp,
          height: 38.sp,
          radius: 8.r,
          color: AppColors.secondaryAction,
        ),
        const Spacer(),
        customButton(
          title: FormatHelper.capitalize(S.of(context).requestService),
          function: () => RequestServiceDialogs.run(context, _model),
          textStyle: StyleText.fontSize16Weight500.copyWith(
            color: AppColors.textButton,
          ),
          width: 150.sp,
          height: 38.sp,
          radius: 8.r,
          color: AppColors.primary,
        ),
      ],
    );
  }
}

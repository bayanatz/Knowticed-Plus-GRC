/// Module: services / sv10_services_provider / presentation / ui / widgets
///
///*************************** FILE INFO ****************************///
/// File Name: request_details_content.dart
/// Purpose: The body of the provider's request page: the service and its
///          description, the assigned provider, the requester and the
///          approval cycle. Moved out of the page (Provider rule 6).
/// Author: Amr Mesbah
/// Created At: 22/10/2026
library;

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:knowticed_plus/core/custom/helpers/custom_svg.dart';
import 'package:knowticed_plus/core/extensions/context_extensions.dart';
import 'package:knowticed_plus/core/helper/format_title.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/features/services/data/models/service_employee_model.dart';
import 'package:knowticed_plus/features/services/data/models/services_history_model.dart';
import 'package:knowticed_plus/features/services/helpers/services_text.dart';
import 'package:knowticed_plus/features/services/presentation/navigation/services_navigation.dart';
import 'package:knowticed_plus/features/services/presentation/widgets/provider_details.dart';
import 'package:knowticed_plus/features/services/sv10_services_provider/presentation/ui/widgets/employee_details_dialogs_and_sections.dart';
import 'package:knowticed_plus/generated/l10n.dart';

/// Class Name: [RequestDetailsContent]
///
/// Purpose: Everything about the request below the page header.
class RequestDetailsContent extends StatelessWidget {
  const RequestDetailsContent({
    required this.request,
    required this.displayCycle,
    required this.currentState,
    super.key,
  });

  final ServicesHistoryModel request;

  /// The approval cycle as shown (see ProviderRequestRules.displayCycle).
  final List<ServiceEmployeeModel> displayCycle;

  /// The request's status.
  final String currentState;

  bool _isTabletLandscape(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    return size.width >= 600 &&
        MediaQuery.orientationOf(context) == Orientation.landscape;
  }

  /// SVC-PROV-07: the provider the request is ASSIGNED to.
  ServiceEmployeeModel? get _assignedProvider {
    final providers = request.currentProviderServices;
    if (providers.isEmpty) return null;
    final assigned = request.currentAssignedProviderEmail.trim().toLowerCase();
    for (final p in providers) {
      if ((p.email ?? '').trim().toLowerCase() == assigned) return p;
    }
    return providers.first;
  }

  Widget _description(BuildContext context, bool isMobile) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            CustomSvgImage.natural(
              assetPath:
                  'assets/icons_assets/main_icons_assets/ic_file_document_description.svg',
              width: isMobile ? 16.w : 14.sp,
              height: isMobile ? 16.h : 14.sp,
              color: AppColors.secondaryText,
              fit: isMobile ? BoxFit.scaleDown : BoxFit.fill,
            ),
            SizedBox(width: 3.sp),
            Text(
              '${S.of(context).serviceDescription}:',
              style: (isMobile
                      ? StyleText.fontSize12Weight400
                      : StyleText.fontSize14Weight400)
                  .copyWith(color: AppColors.secondaryText),
            ),
          ],
        ),
        SizedBox(height: 5.h),
        Text(
          FormatHelper.capitalize(
            context.svcPick(
              request.currentServiceDescriptionEnglish,
              request.currentServiceDescriptionArabic,
            ),
          ),
          style: isMobile
              ? StyleText.fontSize10Weight400.copyWith(
                  wordSpacing: -1.sp,
                  color: AppColors.blackButton,
                )
              : StyleText.fontSize13Weight500.copyWith(
                  color: AppColors.blackButton,
                ),
          textAlign: TextAlign.start,
          softWrap: true,
          overflow: isMobile ? TextOverflow.visible : TextOverflow.clip,
        ),
      ],
    );
  }

  Widget _serviceHeader(BuildContext context, bool isMobile) {
    final landscape = _isTabletLandscape(context);
    final box = isMobile ? 40.sp : (landscape ? 100.sp : 80.sp);
    final icon = isMobile ? 20.sp : (landscape ? 48.sp : 40.sp);
    return Row(
      crossAxisAlignment:
          isMobile ? CrossAxisAlignment.center : CrossAxisAlignment.start,
      children: [
        Container(
          width: box,
          height: box,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8.r),
            color: AppColors.background,
          ),
          child: Center(
            child: CustomSvgImage.natural(
              assetPath:
                  'assets/icons_assets/main_icons_assets/ic_module_support_headset.svg',
              color: AppColors.secondaryText,
              width: icon,
              height: icon,
            ),
          ),
        ),
        SizedBox(width: 10.w),
        Flexible(
          child: isMobile
              ? Text(
                  context.svcPick(
                    request.currentServiceNameEnglish,
                    request.currentServiceNameArabic,
                  ),
                  style: StyleText.fontSize14Weight400.copyWith(
                    color: AppColors.blackButton,
                  ),
                )
              : _description(context, isMobile),
        ),
      ],
    );
  }

  Widget _providerSection(BuildContext context) {
    final provider = _assignedProvider;
    if (provider == null) {
      return Center(child: Text(S.of(context).Noproviderdatafound));
    }
    return buildProviderDetailsSectionMaster(
      // Opened by route: no import of the provider picker's page.
      onTap: () => context.svcOpenProviderPicker(request),
      table: true,
      context: context,
      duration: request.currentDurationOfServices,
      durationUnit: request.currentSelectedDurationUnit,
      approvalCycle: request.currentApprovalCycle,
      model: provider,
      state: currentState,
    );
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = ContextExtension(context).isPhone;
    final lightMode = Theme.of(context).brightness == Brightness.light;
    return Container(
      padding: EdgeInsets.all(15.sp),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8.r),
        color: AppColors.card,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _serviceHeader(context, isMobile),
          SizedBox(height: 20.h),
          if (isMobile) ...[
            _description(context, isMobile),
            SizedBox(height: 20.sp),
          ],
          _providerSection(context),
          SizedBox(height: 29.sp),
          buildRequesterDetailsSection(
            context: context,
            lightMode: lightMode,
            isTabletLandscape: _isTabletLandscape(context),
            // SVC-PROV-05: from the request, in the reader's language.
            firstNameRequester: context.svcPick(
              request.currentFirstNameRequester,
              request.currentFirstNameRequesterArabic,
            ),
            lastNameRequester: context.svcPick(
              request.currentLastNameRequester,
              request.currentLastNameRequesterArabic,
            ),
            jobTitleRequester: context.svcPick(
              request.currentJobTitleRequester,
              request.currentJobTitleRequesterArabic,
            ),
            departmentName: context.svcDepartmentName(
              request.currentDepartmentRequester,
            ),
          ),
          SizedBox(height: 20.h),
          if (request.currentApprovalCycle.isNotEmpty) ...[
            buildApprovalCycleHeaderSection(
              context: context,
              lightMode: lightMode,
            ),
            SizedBox(height: 15.h),
            buildApprovalCycleContentSection(
              context: context,
              isMobile: isMobile,
              displayCycle: displayCycle,
            ),
          ],
        ],
      ),
    );
  }
}

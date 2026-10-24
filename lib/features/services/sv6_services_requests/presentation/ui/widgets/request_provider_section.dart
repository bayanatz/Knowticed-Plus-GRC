/// Module: services / sv6_services_requests / presentation / ui / widgets
///
///*************************** FILE INFO ****************************///
/// File Name: request_provider_section.dart
/// Purpose: The provider block of the "My request" details page. The
///          provider is resolved once by MyRequestDetailsCubit; this widget
///          shows a shimmer while it loads and the details afterwards.
/// Author: Amr Mesbah
/// Created at: 06/10/2026
library;

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:knowticed_plus/features/services/data/models/service_employee_model.dart';
import 'package:knowticed_plus/features/services/data/models/services_history_model.dart';
import 'package:knowticed_plus/features/services/sv5_service_details/presentation/ui/widgets/info_text.dart';
import 'package:knowticed_plus/features/services/presentation/widgets/provider_details.dart';
import 'package:knowticed_plus/features/services/sv6_services_requests/presentation/ui/widgets/show_request_details_shimmer.dart';
import 'package:knowticed_plus/generated/l10n.dart';

class RequestProviderSection extends StatelessWidget {
  final ServicesHistoryModel model;
  final ServiceEmployeeModel? provider;
  final bool isLoading;
  final bool isMobile;
  final String duration;
  final String durationUnit;

  const RequestProviderSection({
    super.key,
    required this.model,
    required this.provider,
    required this.isLoading,
    required this.isMobile,
    required this.duration,
    required this.durationUnit,
  });

  Widget _shimmerColumn(BuildContext context, List<double> widths) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (var i = 0; i < widths.length; i++) ...[
          if (i > 0) SizedBox(height: 10.h),
          shimmerPlaceholder(context, width: widths[i], height: 20),
        ],
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Row(
        children: [
          _shimmerColumn(context, const [200, 150, 180]),
          if (!isMobile) ...[
            SizedBox(
              width: !isTabletLandscape(context)
                  ? MediaQuery.sizeOf(context).width * .05
                  : MediaQuery.sizeOf(context).width * .1,
            ),
            _shimmerColumn(context, const [160, 140, 180]),
          ],
        ],
      );
    }

    final resolved = provider;
    if (resolved == null) {
      return Center(child: Text(S.of(context).Noproviderdatafound));
    }

    return buildProviderDetailsSectionMaster(
      context: context,
      duration: duration,
      durationUnit: durationUnit,
      approvalCycle: model.currentApprovalCycle,
      model: resolved,
      state: model.currentState.isNotEmpty ? model.currentState : 'pending',
    );
  }
}

/// Module: services / sv6_services_requests / presentation / ui / widgets
///
///*************************** FILE INFO ****************************///
/// File Name: services_grid_widget.dart
/// Purpose: The grid of request-able services on the "Service requests"
///          page. The provider shown on a card is the assigned one from the
///          service; when the service has none, RequestServicesCubit looks it
///          up once and caches it.
/// Author: Amr Mesbah
/// Created at: 06/10/2026
library;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:knowticed_plus/core/custom/layout/custom_grid_view.dart';
import 'package:knowticed_plus/core/custom/layout/custom_gridview_with_animation.dart';
import 'package:knowticed_plus/core/custom/navigation/custom_navigate.dart';
import 'package:knowticed_plus/features/services/data/models/service_employee_model.dart';
import 'package:knowticed_plus/features/services/data/models/services_history_model.dart';
import 'package:knowticed_plus/features/services/helpers/services_text.dart';
import 'package:knowticed_plus/features/services/sv6_services_requests/presentation/controller/request_services_cubit.dart';
import 'package:knowticed_plus/features/services/sv6_services_requests/presentation/ui/pages/request_services_details_toggle.dart';
import 'package:knowticed_plus/features/services/sv6_services_requests/presentation/ui/widgets/service_card_metrics.dart';
import 'package:knowticed_plus/features/services/sv6_services_requests/presentation/ui/widgets/service_lookup_cache.dart';
import 'package:knowticed_plus/features/services/sv6_services_requests/presentation/ui/widgets/show_requests_service_card.dart';
import 'package:knowticed_plus/generated/l10n.dart';

class ServicesGridWidget extends StatelessWidget {
  final List<ServicesHistoryModel> services;

  const ServicesGridWidget({required this.services, super.key});

  /// The provider a request would be assigned to: the assigned one when
  /// set, else the first of the service's providers.
  ServiceEmployeeModel? _modelProvider(ServicesHistoryModel model) {
    final providers = model.currentProviderServices;
    if (providers.isEmpty) return null;
    final assigned = model.currentAssignedProviderEmail.toLowerCase().trim();
    if (assigned.isEmpty) return providers.first;
    return providers.firstWhere(
      (p) => (p.email?.toLowerCase().trim() ?? '') == assigned,
      orElse: () => providers.first,
    );
  }

  Widget _card(
    BuildContext context,
    ServicesHistoryModel model, {
    required String providerName,
    required String providerTitle,
  }) {
    return CustomServiceCard(
      serviceName: context.svcPick(
        model.currentServiceNameEnglish,
        model.currentServiceNameArabic,
      ),
      owningDepartment: context.svcDepartmentName(
        model.currentDepartmentRequester,
      ),
      serviceProvider: providerName.isEmpty ? '-' : providerName,
      jobTitle: providerTitle.isEmpty ? '-' : providerTitle,
      durationOfServices: context.svcDuration(
        model.currentDurationOfServices,
        model.currentSelectedDurationUnit,
      ),
      approval: model.currentApprovalCycle.isEmpty
          ? S.of(context).sm_doesnTNeedApproval
          : S.of(context).sm_needApproval,
      model: model,
    );
  }

  Widget _buildItem(BuildContext context, ServicesHistoryModel model) {
    final provider = _modelProvider(model);
    if (provider != null) {
      return _card(
        context,
        model,
        providerName: context.svcPick(
          '${provider.firstName ?? ''} ${provider.lastName ?? ''}',
          '${provider.firstNameInArabic ?? ''} ${provider.lastNameInArabic ?? ''}',
        ),
        providerTitle: context.svcPick(provider.title, provider.titleInArabic),
      );
    }

    final cubit = context.read<RequestServicesCubit>();
    return FutureBuilder<Map<String, dynamic>?>(
      // Memoised: a fresh Future would refire on every rebuild.
      future: ServiceLookupCache.provider(
        model.currentId,
        () => cubit.getCachedServiceProvider(model.currentId),
      ),
      builder: (context, snapshot) {
        final done = snapshot.connectionState == ConnectionState.done;
        final data = snapshot.data;
        String field(String key) => data?[key]?.toString() ?? '';
        return _card(
          context,
          model,
          providerName: !done
              ? '...'
              : context.svcPick(
                  '${field('firstName')} ${field('lastName')}',
                  '${field('firstNameInArabic')} ${field('lastNameInArabic')}',
                ),
          providerTitle: !done
              ? '...'
              : context.svcPick(field('title'), field('titleInArabic')),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedCustomGridView(
      itemCount: services.length,
      crossAxisCount: CrossAxisCountHelperResponsive
          .getCrossAxisCountForDefaultTabletResponsive(
        context,
      ),
      mainAxisExtent: ServiceCardMetrics.requestCardExtent(context),
      mainAxisSpacing: 15.sp,
      crossAxisSpacing: 15.sp,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      animationDuration: const Duration(milliseconds: 800),
      staggerDelay: const Duration(milliseconds: 300),
      curve: Curves.easeOutCubic,
      itemBuilder: (context, index) {
        final model = services[index];
        return GestureDetector(
          onTap: () => navigateTo(
            context,
            RequestServicesDetailsToggle(requestModel: model),
          ),
          child: _buildItem(context, model),
        );
      },
    );
  }
}

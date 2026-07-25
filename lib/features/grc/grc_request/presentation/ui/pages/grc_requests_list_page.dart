/// Module: GRC Request Management
/// Description: Module-scoped list of GRC approval requests — All/Approved/
///              Pending/Rejected count tabs, search, and a card grid that
///              navigates to GrcRequestDetailsPage.
/// Author: Mohamed Magdy Abdelkhalek
/// Date: 2026-07-25
/// Dependencies: flutter_bloc, get_it, GrcRequestCubit, GRCModuleEntity

import 'package:demo_app/core/enums/approval_status.dart';
import 'package:demo_app/core/theme/app_colors.dart';
import 'package:demo_app/core/theme/app_theme.dart';
import 'package:demo_app/core/custom/35-custom_search_widget_custom.dart';
import 'package:demo_app/features/grc/grc_request/domain/entities/grc_request_entity.dart';
import 'package:demo_app/features/grc/grc_request/domain/entities/grc_request_type.dart';
import 'package:demo_app/features/grc/grc_request/presentation/controller/grc_request_cubit.dart';
import 'package:demo_app/features/grc/grc_request/presentation/ui/pages/grc_request_details_page.dart';
import 'package:demo_app/features/grc/module/domain/entities/grc_module_entity.dart';
import 'package:demo_app/features/grc/policy/presentation/ui/widgets/policy_details_widget/grc_owner_badge.dart';
import 'package:demo_app/features/home/core_widgets/main_widget/pagination_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:get_it/get_it.dart';
import 'package:intl/intl.dart';

class GrcRequestsListPage extends StatelessWidget {
  final GRCModuleEntity module;

  const GrcRequestsListPage({super.key, required this.module});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<GrcRequestCubit>(
      create: (_) => GetIt.instance<GrcRequestCubit>()
        ..getRequestsForModule(module.moduleId),
      child: _GrcRequestsListBody(module: module),
    );
  }
}

class _GrcRequestsListBody extends StatefulWidget {
  final GRCModuleEntity module;

  const _GrcRequestsListBody({required this.module});

  @override
  State<_GrcRequestsListBody> createState() => _GrcRequestsListBodyState();
}

class _GrcRequestsListBodyState extends State<_GrcRequestsListBody> {
  ApprovalStatus _selectedFilter = ApprovalStatus.all;
  String _searchQuery = '';
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<GrcRequestEntity> _applyFilters(List<GrcRequestEntity> requests) {
    var filtered = requests;
    if (_selectedFilter != ApprovalStatus.all) {
      filtered = filtered.where((r) => r.status == _selectedFilter).toList();
    }
    if (_searchQuery.isNotEmpty) {
      final q = _searchQuery.toLowerCase();
      filtered = filtered
          .where((r) =>
              (r.newChampionEmail ?? '').toLowerCase().contains(q) ||
              (r.currentChampionEmail ?? '').toLowerCase().contains(q) ||
              r.requestedBy.toLowerCase().contains(q))
          .toList();
    }
    return filtered;
  }

  Widget _countChip(String label, int count, ApprovalStatus status, Color color) {
    final selected = _selectedFilter == status;
    return GestureDetector(
      onTap: () => setState(() => _selectedFilter = status),
      child: Container(
        margin: EdgeInsets.only(right: 8.w),
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
        decoration: BoxDecoration(
          color: selected ? AppColors.primary : AppColors.card,
          borderRadius: BorderRadius.circular(8.r),
          border: Border.all(color: selected ? AppColors.primary : AppColors.border),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('$count',
                style: StyleText.fontSize14Weight600.copyWith(
                    color: selected ? Colors.black : AppColors.text)),
            SizedBox(width: 6.w),
            Text(label, style: StyleText.fontSize14Weight500.copyWith(color: color)),
          ],
        ),
      ),
    );
  }

  Widget _statusPill(ApprovalStatus status) {
    final Color color;
    switch (status) {
      case ApprovalStatus.approved:
        color = Colors.green;
        break;
      case ApprovalStatus.rejected:
        color = Colors.red;
        break;
      default:
        color = Colors.orange;
    }
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
      decoration: BoxDecoration(
        border: Border.all(color: color),
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Text(status.getName,
          style: StyleText.fontSize12Weight500.copyWith(color: color)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('d MMM yyyy');
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              PaginationAppBar(
                screensTitles: [widget.module.moduleNameEn, 'Requests'.tr],
              ),
              SizedBox(height: 16.h),
              BlocBuilder<GrcRequestCubit, GrcRequestState>(
                builder: (context, state) {
                  final requests =
                      state is GrcRequestListLoaded ? state.requests : <GrcRequestEntity>[];
                  final counts = {
                    for (final s in [
                      ApprovalStatus.all,
                      ApprovalStatus.approved,
                      ApprovalStatus.pending,
                      ApprovalStatus.rejected,
                    ])
                      s: s == ApprovalStatus.all
                          ? requests.length
                          : requests.where((r) => r.status == s).length,
                  };
                  final filtered = _applyFilters(requests);

                  return Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            _countChip('All', counts[ApprovalStatus.all]!,
                                ApprovalStatus.all, AppColors.text),
                            _countChip('Approved', counts[ApprovalStatus.approved]!,
                                ApprovalStatus.approved, Colors.green),
                            _countChip('Pending', counts[ApprovalStatus.pending]!,
                                ApprovalStatus.pending, Colors.orange),
                            _countChip('Rejected', counts[ApprovalStatus.rejected]!,
                                ApprovalStatus.rejected, Colors.red),
                          ],
                        ),
                        SizedBox(height: 16.h),
                        AppSearchTextField(
                          onChanged: (v) => setState(() => _searchQuery = v),
                          hintText: 'Search'.tr,
                          controller: _searchController,
                        ),
                        SizedBox(height: 16.h),
                        Expanded(
                          child: filtered.isEmpty
                              ? Center(child: Text('No requests found'.tr))
                              : GridView.builder(
                                  gridDelegate:
                                      const SliverGridDelegateWithMaxCrossAxisExtent(
                                    maxCrossAxisExtent: 420,
                                    mainAxisExtent: 220,
                                    crossAxisSpacing: 16,
                                    mainAxisSpacing: 16,
                                  ),
                                  itemCount: filtered.length,
                                  itemBuilder: (context, index) {
                                    final request = filtered[index];
                                    return GestureDetector(
                                      onTap: () {
                                        if (request.type !=
                                            GrcRequestType.reassignChampion) {
                                          return;
                                        }
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (_) => GrcRequestDetailsPage(
                                              module: widget.module,
                                              request: request,
                                            ),
                                          ),
                                        ).then((_) => context
                                            .read<GrcRequestCubit>()
                                            .getRequestsForModule(widget.module.moduleId));
                                      },
                                      child: Container(
                                        padding: EdgeInsets.all(16.r),
                                        decoration: BoxDecoration(
                                          color: AppColors.card,
                                          borderRadius: BorderRadius.circular(8.r),
                                          boxShadow: [
                                            BoxShadow(
                                                color: AppColors.dropShadow,
                                                blurRadius: 4,
                                                offset: const Offset(0, 2)),
                                          ],
                                        ),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.spaceBetween,
                                              children: [
                                                Expanded(
                                                  child: Text(
                                                    '${'Request Type'.tr}: ${request.type.value}',
                                                    style: StyleText.fontSize14Weight600
                                                        .copyWith(color: AppColors.text),
                                                  ),
                                                ),
                                                Text(
                                                  '${'Request Date'.tr}: ${dateFormat.format(request.requestDate)}',
                                                  style: StyleText.fontSize12Weight400
                                                      .copyWith(
                                                          color: AppColors.secondaryText),
                                                ),
                                              ],
                                            ),
                                            SizedBox(height: 8.h),
                                            GrcOwnerBadge(
                                              ownerEmails: widget.module.moduleOwners,
                                              label: 'Department Manager:'.tr,
                                            ),
                                            SizedBox(height: 8.h),
                                            Expanded(
                                              child: Text(
                                                '${'Request Note'.tr}: ${request.note}',
                                                maxLines: 3,
                                                overflow: TextOverflow.ellipsis,
                                                style: StyleText.fontSize12Weight400
                                                    .copyWith(color: AppColors.text),
                                              ),
                                            ),
                                            Align(
                                              alignment: Alignment.centerRight,
                                              child: _statusPill(request.status),
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  },
                                ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

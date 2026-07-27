/// Module: GRC Request Management
/// Description: Module-scoped list of GRC approval requests — All/Approved/
///              Pending/Rejected count tabs, search, and a card grid that
///              navigates to GrcRequestDetailsPage.
/// Author: Mohamed Magdy Abdelkhalek
/// Date: 2026-07-25
/// Dependencies: flutter_bloc, get_it, GrcRequestCubit, GRCModuleEntity
library;

import 'package:demo_app/core/enums/approval_status.dart';
import 'package:demo_app/core/theme/app_colors.dart';
import 'package:demo_app/core/theme/app_theme.dart';
import 'package:demo_app/core/custom/8-custom_filter_app.dart';
import 'package:demo_app/core/custom/11_custom_confirm_diaolog.dart';
import 'package:demo_app/core/custom/16-custom_card_styles.dart';
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

  /// When set, the list only shows requests whose `requestedBy` matches
  /// this email (the "My Requests" view) instead of every request in the
  /// module, and eligible pending requests get a Cancel action.
  final String? onlyRequestedBy;

  /// When set, the list only shows requests of this type — e.g. opening
  /// "Requests" from the Control Owners tab should only show Reassign
  /// Control Owner requests, not Champion ones sharing the same module.
  final GrcRequestType? typeFilter;

  const GrcRequestsListPage({
    super.key,
    required this.module,
    this.onlyRequestedBy,
    this.typeFilter,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider<GrcRequestCubit>(
      create: (_) => GetIt.instance<GrcRequestCubit>()
        ..getRequestsForModule(module.moduleId),
      child: _GrcRequestsListBody(
        module: module,
        onlyRequestedBy: onlyRequestedBy,
        typeFilter: typeFilter,
      ),
    );
  }
}

class _GrcRequestsListBody extends StatefulWidget {
  final GRCModuleEntity module;
  final String? onlyRequestedBy;
  final GrcRequestType? typeFilter;

  const _GrcRequestsListBody({
    required this.module,
    this.onlyRequestedBy,
    this.typeFilter,
  });

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

  List<GrcRequestEntity> _scopeRequests(List<GrcRequestEntity> requests) {
    var scoped = requests;
    if (widget.typeFilter != null) {
      scoped = scoped.where((r) => r.type == widget.typeFilter).toList();
    }
    if (widget.onlyRequestedBy != null) {
      scoped =
          scoped.where((r) => r.requestedBy == widget.onlyRequestedBy).toList();
    } else {
      // Canceled requests are only relevant to the requester, so keep them
      // out of the module-wide "Requests" view — they still show up in
      // "My Requests".
      scoped =
          scoped.where((r) => r.status != ApprovalStatus.canceled).toList();
    }
    return scoped;
  }

  bool _canCancel(GrcRequestEntity request) {
    return widget.onlyRequestedBy != null &&
        request.status == ApprovalStatus.pending &&
        request.startDate != null &&
        request.startDate!.isAfter(DateTime.now());
  }

  void _onCancel(BuildContext context, GrcRequestEntity request) {
    showConfirmDialog(
      context: context,
      title: 'Cancel Request'.tr,
      subtitle: 'Are you sure you want to cancel this request?'.tr,
      cancelLabel: 'No'.tr,
      confirmLabel: 'Yes'.tr,
      onConfirm: () {
        context.read<GrcRequestCubit>().cancelRequest(
              moduleId: widget.module.moduleId,
              requestId: request.id,
            );
      },
    );
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
              (r.newOwnerEmail ?? '').toLowerCase().contains(q) ||
              (r.currentOwnerEmail ?? '').toLowerCase().contains(q) ||
              r.requestedBy.toLowerCase().contains(q))
          .toList();
    }
    return filtered;
  }

  Widget _statusPill(ApprovalStatus status) {
    final color = status.color;
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

  /// Per-status counts (All/Approved/Pending/Rejected) shown on the filter
  /// chips, computed from the scoped (but not search/status-filtered)
  /// request list.
  Map<ApprovalStatus, int> _buildStatusCounts(
      List<GrcRequestEntity> requests) {
    return {
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
  }

  Widget _buildRequestCard(
    BuildContext context,
    GrcRequestEntity request,
    DateFormat dateFormat,
  ) {
    return GestureDetector(
      onTap: () {
        if (!request.type.isReassignment) {
          return;
        }
        final requestCubit = context.read<GrcRequestCubit>();
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => BlocProvider<GrcRequestCubit>.value(
              value: requestCubit,
              child: GrcRequestDetailsPage(
                module: widget.module,
                request: request,
              ),
            ),
          ),
        );
        // No post-navigation refetch needed: the details page shares this
        // same GrcRequestCubit instance, so its approve/reject actions emit
        // state this page's own BlocConsumer (still mounted underneath the
        // pushed route) already listens to and refetches from below.
      },
      child: Container(
        padding: EdgeInsets.all(16.r),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: CardStyles.radius(),
          boxShadow: CardStyles.shadow,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    '${'Request Type'.tr}: ${request.type.value}',
                    style: StyleText.fontSize12Weight600
                        .copyWith(color: AppColors.text),
                  ),
                ),
                Text(
                  '${'Request Date'.tr}: ${dateFormat.format(request.requestDate)}',
                  style: StyleText.fontSize12Weight400
                      .copyWith(color: AppColors.secondaryText),
                ),
              ],
            ),
            SizedBox(height: 15.h),
            GrcOwnerBadge(
              ownerEmails: widget.module.moduleOwners,
              label: 'Department Manager:'.tr,
            ),
            SizedBox(height: 15.h),
            Expanded(
              child: Text(
                '${'Request Note'.tr}: ${request.note}',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style:
                    StyleText.fontSize12Weight400.copyWith(color: AppColors.text),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (_canCancel(request)) ...[
                  GestureDetector(
                    onTap: () => _onCancel(context, request),
                    child: Container(
                      padding:
                          EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
                      decoration: BoxDecoration(
                        border: Border.all(color: AppColors.red),
                        borderRadius: BorderRadius.circular(20.r),
                      ),
                      child: Text(
                        'Cancel'.tr,
                        style: StyleText.fontSize12Weight500
                            .copyWith(color: AppColors.red),
                      ),
                    ),
                  ),
                  SizedBox(width: 8.w),
                ],
                _statusPill(request.status),
              ],
            ),
          ],
        ),
      ),
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
                screensTitles: [
                  widget.module.moduleNameEn,
                  widget.onlyRequestedBy != null
                      ? 'My Requests'.tr
                      : 'Requests'.tr,
                ],
              ),
              SizedBox(height: 16.h),
              BlocConsumer<GrcRequestCubit, GrcRequestState>(
                listener: (context, state) {
                  // cancelRequest (like approve/reject) emits
                  // GrcRequestActionSuccess, not GrcRequestListLoaded — refetch
                  // so the grid reflects the new status instead of going blank.
                  if (state is GrcRequestActionSuccess) {
                    context
                        .read<GrcRequestCubit>()
                        .getRequestsForModule(widget.module.moduleId);
                  }
                },
                builder: (context, state) {
                  final requests = _scopeRequests(state is GrcRequestListLoaded
                      ? state.requests
                      : <GrcRequestEntity>[]);
                  final counts = _buildStatusCounts(requests);
                  final filtered = _applyFilters(requests);

                  return Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        StatusChipFilter(
                          selectedKey: _selectedFilter.name,
                          onSelected: (key) => setState(() => _selectedFilter =
                              ApprovalStatus.values.byName(key)),
                          items: [
                            StatusChipItem(
                              key: ApprovalStatus.all.name,
                              label: 'All'.tr,
                              count: counts[ApprovalStatus.all]!,
                            ),
                            StatusChipItem(
                              key: ApprovalStatus.approved.name,
                              label: 'Approved'.tr,
                              count: counts[ApprovalStatus.approved]!,
                              labelColor: ApprovalStatus.approved.color,
                            ),
                            StatusChipItem(
                              key: ApprovalStatus.pending.name,
                              label: 'Pending'.tr,
                              count: counts[ApprovalStatus.pending]!,
                              labelColor: ApprovalStatus.pending.color,
                            ),
                            StatusChipItem(
                              key: ApprovalStatus.rejected.name,
                              label: 'Rejected'.tr,
                              count: counts[ApprovalStatus.rejected]!,
                              labelColor: ApprovalStatus.rejected.color,
                            ),
                          ],
                        ),
                        SizedBox(height: 16.h),
                        Row(
                          children: [
                            AppSearchTextField(
                              onChanged: (v) =>
                                  setState(() => _searchQuery = v),
                              hintText: 'Search'.tr,
                              controller: _searchController,
                            ),
                          ],
                        ),
                        SizedBox(height: 16.h),
                        Expanded(
                          child: filtered.isEmpty
                              ? Center(child: Text('No requests found'.tr))
                              : GridView.builder(
                                  gridDelegate:
                                      const SliverGridDelegateWithMaxCrossAxisExtent(
                                    maxCrossAxisExtent: 800,
                                    mainAxisExtent: 220,
                                    crossAxisSpacing: 16,
                                    mainAxisSpacing: 16,
                                  ),
                                  itemCount: filtered.length,
                                  itemBuilder: (context, index) =>
                                      _buildRequestCard(
                                    context,
                                    filtered[index],
                                    dateFormat,
                                  ),
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

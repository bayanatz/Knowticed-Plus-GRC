import 'package:knowticed_plus/core/custom/navigation/custom_side_frame_master.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get_it/get_it.dart';
import 'package:knowticed_plus/core/custom/inputs/custom_search_widget_custom.dart';
import 'package:knowticed_plus/core/extensions/context_extensions.dart';
import 'package:knowticed_plus/features/grc/grc12_my_audit/domain/entities/my_audit_item.dart';
import 'package:knowticed_plus/features/grc/grc12_my_audit/domain/entities/my_audit_tab.dart';
import 'package:knowticed_plus/features/grc/grc12_my_audit/presentation/controller/my_audit_cubit.dart';
import 'package:knowticed_plus/features/grc/grc12_my_audit/presentation/ui/pages/my_audit_details_page.dart';
import 'package:knowticed_plus/features/grc/grc12_my_audit/presentation/ui/widgets/my_audit_card.dart';
import 'package:knowticed_plus/features/grc/grc11_module/domain/entities/grc_module_entity.dart';
import 'package:knowticed_plus/features/grc/helpers/grc_assignment_lookup.dart';
import 'package:knowticed_plus/core/custom/navigation/filter_bar_item.dart';
import 'package:knowticed_plus/generated/l10n.dart';
import 'package:knowticed_plus/features/grc/helpers/grc_l10n.dart';
import 'package:knowticed_plus/core/custom/feedback/circle_progress.dart';

/// The 6 tabs shown on the list page, in the order the user specified.
/// `null` represents "All".
const List<MyAuditTab?> _tabOrder = [
  null,
  MyAuditTab.outstanding,
  MyAuditTab.pending,
  MyAuditTab.scored,
  MyAuditTab.rejected,
  MyAuditTab.overdue,
];

class MyAuditsListPage extends StatelessWidget {
  final GRCModuleEntity module;

  /// One-shot: open this control's item once the list loads. Set when a
  /// notification's View lands here (GrcNotificationOpener, 22/10/2026).
  final String? focusControlId;

  const MyAuditsListPage({
    super.key,
    required this.module,
    this.focusControlId,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider<MyAuditCubit>(
      create: (_) => GetIt.instance<MyAuditCubit>()
        ..getMyAudits(
            moduleId: module.moduleId, ownerEmail: currentGrcUserEmail()),
      child: _MyAuditsListBody(
        module: module,
        focusControlId: focusControlId,
      ),
    );
  }
}

class _MyAuditsListBody extends StatefulWidget {
  final GRCModuleEntity module;
  final String? focusControlId;

  const _MyAuditsListBody({required this.module, this.focusControlId});

  @override
  State<_MyAuditsListBody> createState() => _MyAuditsListBodyState();
}

class _MyAuditsListBodyState extends State<_MyAuditsListBody> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  int _selectedTabIndex = 0;
  bool _focusHandled = false;

  /// Opens [MyAuditsListPage.focusControlId]'s item the first time the list
  /// arrives; a missing item just leaves the list showing.
  void _focusOnce(List<MyAuditItem> items) {
    final String? id = widget.focusControlId;
    if (_focusHandled || id == null) return;
    _focusHandled = true;
    final MyAuditItem? item =
        items.where((i) => i.control.id == id).firstOrNull;
    if (item == null) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _openDetails(context, item);
    });
  }

  void _openDetails(BuildContext context, MyAuditItem item) {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => BlocProvider.value(
          value: context.read<MyAuditCubit>(),
          child: MyAuditDetailsPage(
            item: item,
            module: widget.module,
          ),
        ),
        transitionsBuilder: (_, animation, __, child) =>
            FadeTransition(opacity: animation, child: child),
        transitionDuration: const Duration(milliseconds: 300),
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<MyAuditItem> _filter(List<MyAuditItem> items, bool isArabic) {
    final tab = _tabOrder[_selectedTabIndex];
    final byTab = tab == null ? items : items.where((i) => i.tab == tab);
    final query = _searchQuery.trim().toLowerCase();
    if (query.isEmpty) return byTab.toList();
    return byTab.where((i) {
      final name =
          isArabic ? i.control.controlsNameAr : i.control.controlsNameEn;
      final policyName =
          isArabic ? i.policy.policyNameAr : i.policy.policyNameEn;
      return name.toLowerCase().contains(query) ||
          policyName.toLowerCase().contains(query);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final isArabic = context.isArabic;
    // The frame owns the Scaffold, SafeArea, breadcrumb and side padding.
    return SideFrameMasterServices(
      titleText: S.of(context).grc,
      onFirstTap: () => popFrameRoutes(context, 2),
      secondTitle: widget.module.localizedName(isArabic: isArabic),
      onSecondTap: () => popFrameRoutes(context, 1),
      thirdTitle: S.of(context).myAudits,
      // The list is an Expanded, which needs a bounded height.
      child: SideFrameBoundedBody(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: BlocBuilder<MyAuditCubit, MyAuditState>(
                builder: (context, state) {
                  if (state is MyAuditFailure) {
                    return Center(child: Text(state.message));
                  }
                  if (state is! MyAuditListLoaded) {
                    return const Center(child: CircleProgressMaster.inline());
                  }
                  final allItems = state.items;
                  _focusOnce(allItems);
                  final filtered = _filter(allItems, isArabic);
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ScrollConfiguration(
                        behavior: ScrollConfiguration.of(context)
                            .copyWith(scrollbars: false),
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            spacing: 30.sp,
                            children: [
                              for (var i = 0; i < _tabOrder.length; i++)
                                FilterBarItem(
                                  title: _tabOrder[i] == null
                                      ? S.of(context).all
                                      : grcTr(context, _tabOrder[i]!.label),
                                  numberOfItems: _tabOrder[i] == null
                                      ? allItems.length
                                      : allItems
                                          .where((e) => e.tab == _tabOrder[i])
                                          .length,
                                  color: _tabOrder[i] == null
                                      ? null
                                      : MyAuditTabStyle.of(_tabOrder[i]!).color,
                                  isSelected: _selectedTabIndex == i,
                                  onTap: () =>
                                      setState(() => _selectedTabIndex = i),
                                ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(height: 15.h),
                      Row(
                        children: [
                          AppSearchTextField(
                            controller: _searchController,
                            onChanged: (v) => setState(() => _searchQuery = v),
                            hintText: S.of(context).search,
                          ),
                        ],
                      ),
                      SizedBox(height: 15.h),
                      Expanded(
                        child: filtered.isEmpty
                            ? Center(
                                child: Text(S.of(context).noAuditsInThisStatus))
                            : GridView.builder(
                                gridDelegate:
                                    SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 2,
                                  crossAxisSpacing: 12.w,
                                  mainAxisSpacing: 12.h,
                                  mainAxisExtent: 140.sp,
                                ),
                                itemCount: filtered.length,
                                itemBuilder: (context, index) {
                                  final item = filtered[index];
                                  return MyAuditCard(
                                    item: item,
                                    isArabic: isArabic,
                                    onTap: () => _openDetails(context, item),
                                  );
                                },
                              ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

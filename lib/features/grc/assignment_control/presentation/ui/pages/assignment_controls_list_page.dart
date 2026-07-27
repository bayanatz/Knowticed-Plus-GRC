// lib/features/grc/assignment_control/presentation/ui/pages/assignment_controls_list_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get_utils/src/extensions/internacionalization.dart';
import 'package:get_it/get_it.dart';
import 'package:demo_app/core/custom/35-custom_search_widget_custom.dart';
import 'package:demo_app/core/extension/context_extensions.dart';
import 'package:demo_app/features/grc/assignment_control/domain/entities/assignment_control_item.dart';
import 'package:demo_app/features/grc/assignment_control/domain/entities/assignment_control_tab.dart';
import 'package:demo_app/features/grc/assignment_control/presentation/controller/assignment_control_cubit.dart';
import 'package:demo_app/features/grc/assignment_control/presentation/ui/pages/assignment_control_details_page.dart';
import 'package:demo_app/features/grc/assignment_control/presentation/ui/widgets/assignment_control_card.dart';
import 'package:demo_app/features/grc/module/domain/entities/grc_module_entity.dart';
import 'package:demo_app/features/grc/shared/helpers/grc_assignment_lookup.dart';
import 'package:demo_app/features/home/core_widgets/main_widget/pagination_app_bar.dart';
import 'package:demo_app/features/roles/widgets/filter_bar_item.dart';

/// The 7 tabs shown on the list page, in the order the design calls for.
/// `null` represents "All" (every item regardless of tab).
const List<AssignmentControlTab?> _tabOrder = [
  null,
  AssignmentControlTab.approved,
  AssignmentControlTab.submitted,
  AssignmentControlTab.pending,
  AssignmentControlTab.inReview,
  AssignmentControlTab.rejected,
  AssignmentControlTab.overdue,
];

class AssignmentControlsListPage extends StatelessWidget {
  final GRCModuleEntity module;

  const AssignmentControlsListPage({super.key, required this.module});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<AssignmentControlCubit>(
      create: (_) => GetIt.instance<AssignmentControlCubit>()
        ..getMyAssignmentControls(
          moduleId: module.moduleId,
          championEmail: currentGrcUserEmail(),
        ),
      child: _AssignmentControlsListBody(module: module),
    );
  }
}

class _AssignmentControlsListBody extends StatefulWidget {
  final GRCModuleEntity module;

  const _AssignmentControlsListBody({required this.module});

  @override
  State<_AssignmentControlsListBody> createState() =>
      _AssignmentControlsListBodyState();
}

class _AssignmentControlsListBodyState
    extends State<_AssignmentControlsListBody> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  int _selectedTabIndex = 0;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<AssignmentControlItem> _filter(
    List<AssignmentControlItem> items,
    bool isArabic,
  ) {
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
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              PaginationAppBar(
                screensTitles: ['GRC'.tr, 'Assignment Controls'.tr],
              ),
              SizedBox(height: 15.h),
              Expanded(
                child:
                    BlocBuilder<AssignmentControlCubit, AssignmentControlState>(
                  builder: (context, state) {
                    if (state is AssignmentControlFailure) {
                      return Center(child: Text(state.message));
                    }
                    if (state is! AssignmentControlListLoaded) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    final allItems = state.items;
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
                                        ? 'All'.tr
                                        : _tabOrder[i]!.label.tr,
                                    numberOfItems: _tabOrder[i] == null
                                        ? allItems.length
                                        : allItems
                                            .where((e) => e.tab == _tabOrder[i])
                                            .length,
                                    color: _tabOrder[i] == null
                                        ? null
                                        : AssignmentControlTabStyle.of(
                                                _tabOrder[i]!)
                                            .color,
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
                              onChanged: (v) =>
                                  setState(() => _searchQuery = v),
                              hintText: 'Search'.tr,
                            ),
                          ],
                        ),
                        SizedBox(height: 15.h),
                        Expanded(
                          child: filtered.isEmpty
                              ? Center(
                                  child: Text('No controls in this status'.tr))
                              : GridView.builder(
                                  gridDelegate:
                                      SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 2,
                                    crossAxisSpacing: 12.w,
                                    mainAxisSpacing: 12.h,
                                    mainAxisExtent: 118.h,
                                  ),
                                  itemCount: filtered.length,
                                  itemBuilder: (context, index) {
                                    final item = filtered[index];
                                    return AssignmentControlCard(
                                      item: item,
                                      isArabic: isArabic,
                                      onTap: () => Navigator.push(
                                        context,
                                        PageRouteBuilder(
                                          pageBuilder: (_, __, ___) =>
                                              BlocProvider.value(
                                            value: context
                                                .read<AssignmentControlCubit>(),
                                            child: AssignmentControlDetailsPage(
                                              item: item,
                                              module: widget.module,
                                            ),
                                          ),
                                          transitionsBuilder:
                                              (_, animation, __, child) =>
                                                  FadeTransition(
                                                      opacity: animation,
                                                      child: child),
                                          transitionDuration:
                                              const Duration(milliseconds: 300),
                                        ),
                                      ),
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
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get_utils/src/extensions/internacionalization.dart';
import 'package:get_it/get_it.dart';
import 'package:demo_app/core/custom/35-custom_search_widget_custom.dart';
import 'package:demo_app/core/extension/context_extensions.dart';
import 'package:demo_app/features/grc/my_audit/domain/entities/my_audit_item.dart';
import 'package:demo_app/features/grc/my_audit/domain/entities/my_audit_tab.dart';
import 'package:demo_app/features/grc/my_audit/presentation/controller/my_audit_cubit.dart';
import 'package:demo_app/features/grc/my_audit/presentation/ui/pages/my_audit_details_page.dart';
import 'package:demo_app/features/grc/my_audit/presentation/ui/widgets/my_audit_card.dart';
import 'package:demo_app/features/grc/module/domain/entities/grc_module_entity.dart';
import 'package:demo_app/features/grc/shared/helpers/grc_assignment_lookup.dart';
import 'package:demo_app/features/home/core_widgets/main_widget/pagination_app_bar.dart';
import 'package:demo_app/features/roles/widgets/filter_bar_item.dart';

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

  const MyAuditsListPage({super.key, required this.module});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<MyAuditCubit>(
      create: (_) => GetIt.instance<MyAuditCubit>()
        ..getMyAudits(moduleId: module.moduleId, ownerEmail: currentGrcUserEmail()),
      child: _MyAuditsListBody(module: module),
    );
  }
}

class _MyAuditsListBody extends StatefulWidget {
  final GRCModuleEntity module;

  const _MyAuditsListBody({required this.module});

  @override
  State<_MyAuditsListBody> createState() => _MyAuditsListBodyState();
}

class _MyAuditsListBodyState extends State<_MyAuditsListBody> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  int _selectedTabIndex = 0;

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
      final name = isArabic ? i.control.controlsNameAr : i.control.controlsNameEn;
      final policyName = isArabic ? i.policy.policyNameAr : i.policy.policyNameEn;
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
                screensTitles: [
                  'GRC'.tr,
                  widget.module.localizedName(isArabic: isArabic),
                  'My Audits'.tr,
                ],
              ),
              SizedBox(height: 15.h),
              Expanded(
                child: BlocBuilder<MyAuditCubit, MyAuditState>(
                  builder: (context, state) {
                    if (state is MyAuditFailure) {
                      return Center(child: Text(state.message));
                    }
                    if (state is! MyAuditListLoaded) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    final allItems = state.items;
                    final filtered = _filter(allItems, isArabic);
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ScrollConfiguration(
                          behavior:
                              ScrollConfiguration.of(context).copyWith(scrollbars: false),
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
                                        : MyAuditTabStyle.of(_tabOrder[i]!).color,
                                    isSelected: _selectedTabIndex == i,
                                    onTap: () => setState(() => _selectedTabIndex = i),
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
                              hintText: 'Search'.tr,
                            ),
                          ],
                        ),
                        SizedBox(height: 15.h),
                        Expanded(
                          child: filtered.isEmpty
                              ? Center(child: Text('No audits in this status'.tr))
                              : GridView.builder(
                                  gridDelegate:
                                      SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 2,
                                    crossAxisSpacing: 12.w,
                                    mainAxisSpacing: 12.h,
                                    mainAxisExtent: 150.h,
                                  ),
                                  itemCount: filtered.length,
                                  itemBuilder: (context, index) {
                                    final item = filtered[index];
                                    return MyAuditCard(
                                      item: item,
                                      isArabic: isArabic,
                                      onTap: () => Navigator.push(
                                        context,
                                        PageRouteBuilder(
                                          pageBuilder: (_, __, ___) => BlocProvider.value(
                                            value: context.read<MyAuditCubit>(),
                                            child: MyAuditDetailsPage(
                                              item: item,
                                              module: widget.module,
                                            ),
                                          ),
                                          transitionsBuilder:
                                              (_, animation, __, child) =>
                                                  FadeTransition(
                                                      opacity: animation, child: child),
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

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get_utils/src/extensions/internacionalization.dart';
import 'package:get_it/get_it.dart';
import 'package:demo_app/core/custom/35-custom_search_widget_custom.dart';
import 'package:demo_app/core/extension/context_extensions.dart';
import 'package:demo_app/features/grc/approval/domain/entities/approval_item.dart';
import 'package:demo_app/features/grc/approval/presentation/controller/approval_cubit.dart';
import 'package:demo_app/features/grc/approval/presentation/ui/pages/approval_details_page.dart';
import 'package:demo_app/features/grc/approval/presentation/ui/widgets/approval_card.dart';
import 'package:demo_app/features/grc/module/domain/entities/grc_module_entity.dart';
import 'package:demo_app/features/grc/shared/helpers/grc_assignment_lookup.dart';
import 'package:demo_app/features/home/core_widgets/main_widget/pagination_app_bar.dart';
import 'package:demo_app/features/roles/widgets/filter_bar_item.dart';

class ApprovalsListPage extends StatelessWidget {
  final GRCModuleEntity module;

  const ApprovalsListPage({super.key, required this.module});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<ApprovalCubit>(
      create: (_) => GetIt.instance<ApprovalCubit>()
        ..getMyApprovals(
          moduleId: module.moduleId,
          managerEmail: currentGrcUserEmail(),
        ),
      child: _ApprovalsListBody(module: module),
    );
  }
}

class _ApprovalsListBody extends StatefulWidget {
  final GRCModuleEntity module;

  const _ApprovalsListBody({required this.module});

  @override
  State<_ApprovalsListBody> createState() => _ApprovalsListBodyState();
}

class _ApprovalsListBodyState extends State<_ApprovalsListBody> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<ApprovalItem> _filter(List<ApprovalItem> items, bool isArabic) {
    final query = _searchQuery.trim().toLowerCase();
    if (query.isEmpty) return items;
    return items.where((i) {
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
                screensTitles: ['GRC'.tr, 'Approvals'.tr],
              ),
              SizedBox(height: 15.h),
              Expanded(
                child: BlocBuilder<ApprovalCubit, ApprovalState>(
                  builder: (context, state) {
                    if (state is ApprovalFailure) {
                      return Center(child: Text(state.message));
                    }
                    if (state is! ApprovalListLoaded) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    final filtered = _filter(state.items, isArabic);
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
                                FilterBarItem(
                                  title: 'Pending'.tr,
                                  numberOfItems: state.items.length,
                                  isSelected: true,
                                  onTap: () {},
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
                              ? Center(child: Text('No pending approvals'.tr))
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
                                    return ApprovalCard(
                                      item: item,
                                      isArabic: isArabic,
                                      onTap: () => Navigator.push(
                                        context,
                                        PageRouteBuilder(
                                          pageBuilder: (_, __, ___) => BlocProvider.value(
                                            value: context.read<ApprovalCubit>(),
                                            child: ApprovalDetailsPage(
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

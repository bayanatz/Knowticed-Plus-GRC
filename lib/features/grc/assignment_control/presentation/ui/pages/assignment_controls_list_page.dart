// lib/features/grc/assignment_control/presentation/ui/pages/assignment_controls_list_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get_utils/src/extensions/internacionalization.dart';
import 'package:get_it/get_it.dart';
import 'package:demo_app/core/custom/10-custom_tabs.dart';
import 'package:demo_app/core/extension/context_extensions.dart';
import 'package:demo_app/features/grc/assignment_control/domain/entities/assignment_control_item.dart';
import 'package:demo_app/features/grc/assignment_control/domain/entities/assignment_control_tab.dart';
import 'package:demo_app/features/grc/assignment_control/presentation/controller/assignment_control_cubit.dart';
import 'package:demo_app/features/grc/assignment_control/presentation/ui/pages/assignment_control_details_page.dart';
import 'package:demo_app/features/grc/assignment_control/presentation/ui/widgets/assignment_control_card.dart';
import 'package:demo_app/features/grc/module/domain/entities/grc_module_entity.dart';
import 'package:demo_app/features/grc/shared/helpers/grc_assignment_lookup.dart';
import 'package:demo_app/features/home/core_widgets/main_widget/pagination_app_bar.dart';

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
  static const _tabValues = AssignmentControlTab.values;

  int _selectedTab = 0;

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
                  'Assignment Controls'.tr,
                ],
              ),
              SizedBox(height: 15.h),
              CustomTabs(
                tabs: _tabValues.map((t) => t.label.tr).toList(),
                selectedValue: _selectedTab,
                onChanged: (v) => setState(() => _selectedTab = v),
              ),
              SizedBox(height: 15.h),
              Expanded(
                child: BlocBuilder<AssignmentControlCubit, AssignmentControlState>(
                  builder: (context, state) {
                    if (state is AssignmentControlFailure) {
                      return Center(child: Text(state.message));
                    }
                    if (state is! AssignmentControlListLoaded) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    final filtered = state.items
                        .where((i) => i.tab == _tabValues[_selectedTab])
                        .toList();
                    if (filtered.isEmpty) {
                      return Center(child: Text('No controls in this status'.tr));
                    }
                    return ListView.separated(
                      itemCount: filtered.length,
                      separatorBuilder: (_, __) => SizedBox(height: 10.h),
                      itemBuilder: (context, index) {
                        final item = filtered[index];
                        return AssignmentControlCard(
                          item: item,
                          isArabic: isArabic,
                          onTap: () => Navigator.push(
                            context,
                            PageRouteBuilder(
                              pageBuilder: (_, __, ___) => BlocProvider.value(
                                value: context.read<AssignmentControlCubit>(),
                                child: AssignmentControlDetailsPage(
                                  item: item,
                                  module: widget.module,
                                ),
                              ),
                              transitionsBuilder: (_, animation, __, child) =>
                                  FadeTransition(opacity: animation, child: child),
                              transitionDuration: const Duration(milliseconds: 300),
                            ),
                          ),
                        );
                      },
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

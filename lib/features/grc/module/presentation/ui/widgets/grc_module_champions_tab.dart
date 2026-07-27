/// ************************* FILE INFO *************************** ///
/// File Name: grc_module_champions_tab.dart
/// Purpose: Control Champions tab body for GrcModuleDetailsPage. Renders the
///          champion request buttons, search, add/bulk-upload action, and the
///          champion list for a single GRC Module.
/// Author: Mohamed Magdy Abdelkhalek
/// Created At: 27/7/2026
library;

import 'package:demo_app/core/custom/35-custom_search_widget_custom.dart';
import 'package:demo_app/core/custom/6_custom_button_with_svg.dart';
import 'package:demo_app/core/theme/app_colors.dart';
import 'package:demo_app/core/theme/app_theme.dart';
import 'package:demo_app/features/grc/control/presentation/ui/pages/assignee_bulk_upload/assignee_bulk_upload_page.dart';
import 'package:demo_app/features/grc/control_champion/domain/entities/champion_entity.dart';
import 'package:demo_app/features/grc/control_champion/presentation/controller/champion_cubit.dart';
import 'package:demo_app/features/grc/control_champion/presentation/ui/pages/add_champion_page.dart';
import 'package:demo_app/features/grc/control_champion/presentation/ui/pages/control_champion_details_page.dart';
import 'package:demo_app/features/grc/grc_request/domain/entities/grc_request_type.dart';
import 'package:demo_app/features/grc/grc_request/presentation/ui/pages/grc_requests_list_page.dart';
import 'package:demo_app/features/grc/module/domain/entities/grc_module_entity.dart';
import 'package:demo_app/features/grc/module/presentation/ui/widgets/grc_module_person_card.dart';
import 'package:demo_app/features/grc/shared/helpers/grc_assignment_lookup.dart';
import 'package:demo_app/features/home/core_widgets/main_widget/custom_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get_utils/src/extensions/internacionalization.dart';

/// class name: [GrcModuleChampionsTab]
///
/// purpose: Control Champions tab for a single [GRCModuleEntity]. Reads the
///          provided [ChampionCubit] from the widget tree and owns its own
///          search state.
///
/// authors: Mohamed Magdy Abdelkhalek
///
/// created at: 27/7/2026
class GrcModuleChampionsTab extends StatefulWidget {
  final GRCModuleEntity module;

  const GrcModuleChampionsTab({super.key, required this.module});

  @override
  State<GrcModuleChampionsTab> createState() => _GrcModuleChampionsTabState();
}

class _GrcModuleChampionsTabState extends State<GrcModuleChampionsTab> {
  final _championSearchController = TextEditingController();
  final GlobalKey _addChampionButtonKey = GlobalKey();
  String _championSearchQuery = '';

  @override
  void dispose() {
    _championSearchController.dispose();
    super.dispose();
  }

  Future<void> _showChampionCreationMenu(BuildContext context) async {
    final buttonBox =
        _addChampionButtonKey.currentContext?.findRenderObject() as RenderBox?;
    if (buttonBox == null) return;
    final overlayBox =
        Overlay.of(context).context.findRenderObject() as RenderBox;

    final position = RelativeRect.fromRect(
      Rect.fromPoints(
        buttonBox.localToGlobal(Offset(0, buttonBox.size.height),
            ancestor: overlayBox),
        buttonBox.localToGlobal(buttonBox.size.bottomRight(Offset.zero),
            ancestor: overlayBox),
      ),
      Offset.zero & overlayBox.size,
    );

    final choice = await showMenu<String>(
      context: context,
      position: position,
      items: [
        PopupMenuItem(value: 'add', child: Text('Add Champion'.tr)),
        PopupMenuItem(value: 'bulk', child: Text('Bulk Upload'.tr)),
      ],
    );

    if (!context.mounted) return;
    if (choice == 'add') {
      await _openAddChampion(context);
    } else if (choice == 'bulk') {
      await _openChampionBulkUpload(context);
    }
  }

  Future<void> _openAddChampion(BuildContext context) async {
    final result = await Navigator.push<bool>(
      context,
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => AddChampionPage(
          moduleId: widget.module.moduleId,
          moduleNameEn: widget.module.moduleNameEn,
          moduleNameAr: widget.module.moduleNameAr,
        ),
        transitionsBuilder: (_, animation, __, child) =>
            FadeTransition(opacity: animation, child: child),
        transitionDuration: const Duration(milliseconds: 300),
      ),
    );
    if (result == true && context.mounted) {
      context
          .read<ChampionCubit>()
          .getAllChampions(moduleId: widget.module.moduleId);
    }
  }

  Future<void> _openChampionBulkUpload(BuildContext context) async {
    final championCubit = context.read<ChampionCubit>();
    final result = await Navigator.push<bool>(
      context,
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => AssigneeBulkUploadPage(
          moduleId: widget.module.moduleId,
          assigneeLabel: 'Control Champion'.tr,
          createAssignee: ({
            required moduleId,
            required email,
            required assigningControls,
            required editorId,
          }) {
            return championCubit.createChampion(
              moduleId: moduleId,
              championEmail: email,
              assigningControls: assigningControls,
            );
          },
        ),
        transitionsBuilder: (_, animation, __, child) =>
            FadeTransition(opacity: animation, child: child),
        transitionDuration: const Duration(milliseconds: 300),
      ),
    );
    if (result == true && context.mounted) {
      context
          .read<ChampionCubit>()
          .getAllChampions(moduleId: widget.module.moduleId);
    }
  }

  List<ChampionEntity> _applyChampionSearch(
      BuildContext context, List<ChampionEntity> champions) {
    if (_championSearchQuery.isEmpty) return champions;
    final q = _championSearchQuery.toLowerCase();
    return champions
        .where((c) =>
            employeeDisplayName(context, c.championEmail)
                .toLowerCase()
                .contains(q) ||
            c.championEmail.toLowerCase().contains(q))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final isTablet = MediaQuery.of(context).size.shortestSide >= 600;

    return BlocBuilder<ChampionCubit, ChampionState>(
      builder: (context, state) {
        final champions =
            state is ChampionListLoaded ? state.champions : <ChampionEntity>[];
        final filtered = _applyChampionSearch(context, champions);

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                CustomButton(
                  buttonText: 'My Requests'.tr,
                  width: 110.w,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => GrcRequestsListPage(
                          module: widget.module,
                          onlyRequestedBy: currentGrcUserEmail(),
                          typeFilter: GrcRequestType.reassignChampion,
                        ),
                      ),
                    );
                  },
                ),
                CustomButton(
                  buttonText: 'Requests'.tr,
                  width: 110.w,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => GrcRequestsListPage(
                          module: widget.module,
                          typeFilter: GrcRequestType.reassignChampion,
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
            SizedBox(height: 15.h),
            if (isTablet)
              Row(
                spacing: 10.w,
                children: [
                  AppSearchTextField(
                    onChanged: (v) => setState(() => _championSearchQuery = v),
                    hintText: "Search".tr,
                    controller: _championSearchController,
                  ),
                  Container(
                    key: _addChampionButtonKey,
                    child: customButtonWithSvg(
                      colorBorder: AppColors.primary,
                      space: 10.w,
                      widthImage: 16.w,
                      heightImage: 16.h,
                      function: () => _showChampionCreationMenu(context),
                      title: 'Champion',
                      textStyle: StyleText.fontSize14Weight500
                          .copyWith(color: AppColors.textButton),
                      image:
                          'assets/icons_assets/database_builder_assets/plus_head.svg',
                      color: AppColors.primary,
                      svgColor: AppColors.textButton,
                    ),
                  ),
                ],
              )
            else
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  AppSearchTextField(
                    onChanged: (v) => setState(() => _championSearchQuery = v),
                    hintText: "Search".tr,
                    controller: _championSearchController,
                  ),
                  SizedBox(height: 8.h),
                  Container(
                    key: _addChampionButtonKey,
                    child: customButtonWithSvg(
                      colorBorder: AppColors.primary,
                      space: 10.w,
                      radius: 8.r,
                      widthImage: 16.w,
                      heightImage: 16.h,
                      function: () => _showChampionCreationMenu(context),
                      title: 'Champion',
                      textStyle: StyleText.fontSize14Weight500
                          .copyWith(color: AppColors.textButton),
                      image: 'assets/icons/add.svg',
                      color: AppColors.primary,
                      width: double.infinity,
                      height: 36.h,
                      svgColor: AppColors.textButton,
                    ),
                  ),
                ],
              ),
            SizedBox(height: 15.h),
            Expanded(child: _buildChampionList(context, state, filtered)),
          ],
        );
      },
    );
  }

  Widget _buildChampionList(
    BuildContext context,
    ChampionState state,
    List<ChampionEntity> champions,
  ) {
    if (state is ChampionLoading) {
      return Center(child: CircularProgressIndicator(color: AppColors.primary));
    }
    if (state is ChampionFailure) {
      return Center(
        child: Text(
          state.message,
          style: StyleText.fontSize14Weight500.copyWith(color: AppColors.red),
          textAlign: TextAlign.center,
        ),
      );
    }
    if (champions.isEmpty) {
      return Center(
        child: Text(
          'No Control Champions found'.tr,
          style: StyleText.fontSize14Weight500
              .copyWith(color: AppColors.secondaryText),
        ),
      );
    }
    return ScrollConfiguration(
      behavior: ScrollConfiguration.of(context).copyWith(scrollbars: false),
      child: ListView.separated(
        itemCount: champions.length,
        separatorBuilder: (_, __) => SizedBox(height: 10.h),
        itemBuilder: (_, index) {
          final champion = champions[index];
          return GrcModulePersonCard(
            email: champion.championEmail,
            onTap: () async {
              await Navigator.push(
                context,
                PageRouteBuilder(
                  pageBuilder: (_, __, ___) => ControlChampionDetailsPage(
                    champion: champion,
                    module: widget.module,
                  ),
                  transitionsBuilder: (_, animation, __, child) =>
                      FadeTransition(opacity: animation, child: child),
                  transitionDuration: const Duration(milliseconds: 300),
                ),
              );
              if (context.mounted) {
                context
                    .read<ChampionCubit>()
                    .getAllChampions(moduleId: widget.module.moduleId);
              }
            },
          );
        },
      ),
    );
  }
}

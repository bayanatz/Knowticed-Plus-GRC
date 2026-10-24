import 'package:knowticed_plus/core/extensions/context_extensions.dart'
    show kpIsPhoneLayout;
import 'package:knowticed_plus/core/theme/app_animations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:knowticed_plus/core/custom/inputs/custom_search_widget_custom.dart';
import 'package:knowticed_plus/features/qiyas/qy1_admin/create_control_champion/presentation/controller/qiyas_create_champion_controller_cubit.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';

import 'package:knowticed_plus/features/qiyas/qiyas_get_it.dart';
import 'package:knowticed_plus/features/qiyas/helpers/helper/qiyas_control_card.dart';
import 'package:knowticed_plus/features/qiyas/qy1_admin/create_control_champion/presentation/ui/widgets/champion_documentation_date_text_field.dart';
import 'package:knowticed_plus/features/qiyas/qy1_admin/create_control_champion/presentation/ui/widgets/champion_nav_down_buttons.dart';
import 'package:knowticed_plus/features/qiyas/qy1_admin/create_control_core/presentation/controller/control_core_cubit.dart';
import 'package:knowticed_plus/core/theme/haptic_controller.dart';
import 'package:knowticed_plus/core/custom/dialogs/custom_filter_frame.dart';

class AssignEvidenceToChampionDialog {
  void show(BuildContext context, {Future<void> Function()? onSuccess}) {
    showAppDialog(
        context: context,
        builder: (BuildContext context) {
          return Dialog(
            child: Content(onSuccess: onSuccess),
          );
        });
  }
}

class Content extends StatefulWidget {
  const Content({super.key, this.onSuccess});

  final Future<void> Function()? onSuccess;

  @override
  State<Content> createState() => _ContentState();
}

class _ContentState extends State<Content> {
  TextEditingController searchController = TextEditingController();
  late QiyasCreateChampionControllerCubit controller;
  late bool isTablet;

  @override
  void initState() {
    super.initState();
    debugPrint('🟢 INIT: Dialog initialized');
    controller = sl<QiyasCreateChampionControllerCubit>();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      debugPrint(
          '🟢 POST_FRAME: Calling searchByName("") with removeChampions: false');
      controller.searchByName("", removeChampions: false);
    });
  }

  @override
  Widget build(BuildContext context) {
    isTablet = !kpIsPhoneLayout(context);
    debugPrint('🔵 BUILD: Dialog is rebuilding');

    return Form(
      key: controller.formKey,
      child: BlocProvider<ControlCoreCubit>.value(
        value: controller,
        child: Directionality(
          textDirection: TextDirection.rtl,
          child: Container(
            height: 600.h,
            width: isTablet ? 722.sp : 300.sp,
            padding: EdgeInsets.all(15.sp),
            decoration: BoxDecoration(
              color: AppColors.card,
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Column(
              spacing: 15.sp,
              mainAxisSize: MainAxisSize.min,
              children: [
                /// Title row
                // 22/10/2026 — Owner: one dialog header everywhere (30 circle · 16 icon · 18/500 title) — was a hand-rolled 15./19./19. row.
                CustomDialogHeader(
                    title: 'تعيين سفير',
                    icon:
                        'assets/icons_assets/main_icons_assets/ic_user_profile.svg'),

                /// Date field
                Row(
                  spacing: 15.sp,
                  children: [
                    ChampionDocumentationDateTextField(index: 0),
                    if (isTablet) Expanded(child: Container()),
                  ],
                ),

                /// Search bar
                Row(
                  children: [
                    AppSearchTextField(
                      hintText: "بحث",
                      fillColor: AppColors.background,
                      controller: searchController,
                      onChanged: (value) {
                        debugPrint('🔍 SEARCH: User typed: "$value"');
                        controller.searchByName(value, removeChampions: false);
                      },
                    ),
                  ],
                ),

                /// Employee grid
                Expanded(
                  child: BlocBuilder<ControlCoreCubit, ControlCoreState>(
                    bloc: controller,
                    buildWhen: (_, currentState) {
                      return currentState is OwnerDataChanged ||
                          currentState is VisionsDataChanged;
                    },
                    builder: (context, state) {
                      return _championsBuilder(context);
                    },
                  ),
                ),

                /// Bottom buttons
                ChampionNavDownButtons(onSuccessCallback: widget.onSuccess),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _championsBuilder(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final crossAxisCount = width < 600
        ? 1
        : width < 1024
            ? 2
            : 3;
    final itemCount = controller.showEmployees.length;

    if (itemCount == 0) {
      return Center(
        child: Text(
          'لا يوجد موظفين',
          style: StyleText.fontSize14Weight500,
        ),
      );
    }

    return GridView.builder(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        mainAxisExtent: 72.sp,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
        crossAxisCount: crossAxisCount,
      ),
      itemCount: itemCount,
      itemBuilder: (context, index) {
        final employee = controller.showEmployees[index];

        return InkWell(
          onTap: () {
            HapticController.low(); // list row: on the tap (X-117)
            controller.toggleChecked(index);
          },
          child: QiyasControlCard(
            index: index,
            onTap: () {
              controller.toggleChecked(index);
            },
            person: employee,
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    debugPrint('🔴 DISPOSE: Dialog is being disposed');
    super.dispose();
  }
}

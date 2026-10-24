/// ***************************** FILE INFO ***************************** ///
/// File Name: qiyas_create_control_champion.dart
/// Purpose: Creates a form for adding a new "Digital Transformation Ambassador" with associated fields for vision, topic, criteria, and additional notes.
/// Author: Abdelrahman Sobhy
/// Created At: Apr/21/2025
/// Description: This screen allows the user to assign employees as champions and input details related to their digital transformation role.
///              It supports different screen orientations and devices (desktop, portrait, etc.) and includes grid display for employees with
///              search functionality and dynamic form fields.
/// ********************************************************************* ///
library;

import 'package:knowticed_plus/core/extensions/context_extensions.dart'
    show kpIsPhoneLayout;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:knowticed_plus/core/helper/pagination_app_bar.dart';
import 'package:knowticed_plus/features/qiyas/qy1_admin/create_control_champion/presentation/ui/widgets/add_new_visions.dart';
import 'package:knowticed_plus/features/qiyas/qy1_admin/create_control_champion/presentation/controller/qiyas_create_champion_controller_cubit.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';

import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/features/qiyas/qiyas_get_it.dart';
import 'package:knowticed_plus/features/qiyas/helpers/helper/qiyas_control_card.dart';
import 'package:knowticed_plus/features/qiyas/qy1_admin/bulk_upload/presentation/controller/qiyas_bulk_visions_controller.dart';
import 'package:knowticed_plus/features/qiyas/qy1_admin/create_control_core/presentation/controller/control_core_cubit.dart';
import 'package:knowticed_plus/features/qiyas/qy1_admin/create_control_champion/presentation/ui/widgets/champion_nav_down_buttons.dart';
import 'package:knowticed_plus/core/custom/inputs/custom_search_widget_custom.dart';
import 'package:knowticed_plus/core/custom/layout/cross_axis_count_helper.dart';
import 'package:knowticed_plus/core/theme/haptic_controller.dart';

class QiyasCreateControlChampion extends StatefulWidget {
  const QiyasCreateControlChampion({super.key});

  @override
  State<QiyasCreateControlChampion> createState() =>
      _QiyasCreateControlChampionState();
}

class _QiyasCreateControlChampionState
    extends State<QiyasCreateControlChampion> {
  QiyasBulkVisionsController qiyasBulkVisionsController =
      Get.put(QiyasBulkVisionsController());
  TextEditingController searchController = TextEditingController();
  late QiyasCreateChampionControllerCubit controller;

  @override
  Widget build(BuildContext context) {
    controller =
        context.read<ControlCoreCubit>() as QiyasCreateChampionControllerCubit;
    controller.clearAllControllers();
    controller.searchByName(searchController.text);

    bool isTablet = !kpIsPhoneLayout(context);
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: EdgeInsetsDirectional.only(
              start: isTablet ? 30.sp : 15.sp, end: 15.sp),
          child: Directionality(
            textDirection: TextDirection.rtl,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                PaginationAppBar(screensTitles: [
                  'قياس التحول الرقمي',
                  'إضافة سفير جديد',
                ]),
                Expanded(
                    child: SingleChildScrollView(
                        child: Column(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          color: AppColors.card),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 15, vertical: 15),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(bottom: 30),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(bottom: 10),
                                    child: Text(
                                      "سفير التحول الرقمي",
                                      style: StyleText.fontSize18Weight500,
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(bottom: 15),
                                    child: Row(
                                      children: [
                                        AppSearchTextField(
                                          fillColor: AppColors.background,
                                          controller: searchController,
                                          onChanged: (value) {
                                            controller.searchByName(value);
                                          },
                                        ),
                                      ],
                                    ),
                                  ),
                                  BlocBuilder<ControlCoreCubit,
                                      ControlCoreState>(
                                    bloc: sl<
                                        QiyasCreateChampionControllerCubit>(),
                                    buildWhen: (_, currentState) {
                                      return currentState is OwnerDataChanged ||
                                          currentState is VisionsDataChanged;
                                    },
                                    builder: (context, state) {
                                      return _championsBuilder(context);
                                    },
                                  )
                                ],
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(bottom: 10),
                              child: Text(
                                "تعيين المنظور",
                                style: StyleText.fontSize16Weight500,
                              ),
                            ),
                            SizedBox(height: 10.sp),
                            BlocBuilder<ControlCoreCubit, ControlCoreState>(
                                bloc: sl<QiyasCreateChampionControllerCubit>(),
                                buildWhen: (_, currentState) {
                                  return currentState is VisionsDataChanged;
                                },
                                builder: (context, state) {
                                  return AddNewVisions(isWithNote: true);
                                }),
                          ],
                        ),
                      ),
                    ),
                    ChampionNavDownButtons()
                  ],
                )))
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _championsBuilder(BuildContext context) {
    return GridView.builder(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          mainAxisExtent: 75.sp,
          crossAxisSpacing: 8,
          mainAxisSpacing: 8,
          crossAxisCount:
              CrossAxisCountHelper.getCrossAxisCountForDefaultTablet2(context),
        ),
        itemCount: (controller.selectedPerson != null)
            ? 1
            : controller.showEmployees.length,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemBuilder: (context, index) {
          if (controller.selectedPerson != null) {
            index =
                controller.showEmployees.indexOf(controller.selectedPerson!);
          }

          return InkWell(
            onTap: () {
              HapticController.low(); // list row: on the tap (X-117)
              controller.toggleChecked(index);
            },
            child: QiyasControlCard(
              index: index,
              onTap: null,
              person: controller.showEmployees[index],
            ),
          );
        });
  }
}

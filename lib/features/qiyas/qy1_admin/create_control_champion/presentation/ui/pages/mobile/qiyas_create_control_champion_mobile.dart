/// ***************************** FILE INFO ***************************** ///
/// File Name: qiyas_create_control_champion_mobile.dart
/// Purpose: Creates a mobile ui for adding a new "Digital Transformation Ambassador".
/// Author: Abdelrahman Sobhy
/// Created At: Apr/21/2025
/// Description: This screen allows adding a new champion, including their vision, topic,
///              criteria, and additional notes. It displays a list of employees to
///              assign as champions and includes form fields for additional details.
/// ********************************************************************* ///
library;

import 'package:flutter/material.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:knowticed_plus/features/qiyas/helpers/helper/page_screen_toplevel.dart';
import 'package:knowticed_plus/features/qiyas/helpers/helper/qiyas_control_card.dart';
import 'package:knowticed_plus/features/qiyas/qy1_admin/create_control_champion/presentation/controller/qiyas_create_champion_controller_cubit.dart';

import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/features/qiyas/qy1_admin/bulk_upload/presentation/controller/qiyas_bulk_visions_controller.dart';
import 'package:knowticed_plus/features/qiyas/qy1_admin/create_control_core/presentation/controller/control_core_cubit.dart';
import 'package:knowticed_plus/features/qiyas/qy1_admin/create_control_champion/presentation/ui/widgets/add_new_visions.dart';
import 'package:knowticed_plus/features/qiyas/qy1_admin/create_control_champion/presentation/ui/widgets/champion_nav_down_buttons.dart';
import 'package:knowticed_plus/core/custom/inputs/custom_search_widget_custom.dart';
import 'package:knowticed_plus/core/custom/layout/cross_axis_count_helper.dart';
import 'package:knowticed_plus/core/theme/haptic_controller.dart';

class QiyasCreateControlChampionMobile extends StatefulWidget {
  const QiyasCreateControlChampionMobile({super.key});

  @override
  State<QiyasCreateControlChampionMobile> createState() =>
      _QiyasCreateControlChampionMobileState();
}

class _QiyasCreateControlChampionMobileState
    extends State<QiyasCreateControlChampionMobile> {
  QiyasBulkVisionsController qiyasBulkVisionsController =
      Get.put(QiyasBulkVisionsController());
  TextEditingController searchController = TextEditingController();
  late QiyasCreateChampionControllerCubit controller;
  @override
  Widget build(BuildContext context) {
    controller =
        context.read<ControlCoreCubit>() as QiyasCreateChampionControllerCubit;
    controller.clearAllControllers();

    return Directionality(
      textDirection: TextDirection.rtl,
      child: PageScreenTopLevel(
        title: "إضافة سفير جديد",
        hasBackArrow: true,
        hasScroll: true,
        isQiyasMode: true,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 5),
            child: Container(
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: AppColors.card),
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
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
                              style: StyleText.fontSize16Weight400.copyWith(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                  color: AppColors.text),
                            ),
                          ),
                          Row(
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
                          SizedBox(height: 10.sp),
                          BlocBuilder<ControlCoreCubit, ControlCoreState>(
                              bloc: controller,
                              buildWhen: (_, currentState) {
                                return currentState is OwnerDataChanged;
                              },
                              builder: (context, state) {
                                debugPrint(" champion list update");
                                return _championsBuilder(context);
                              })
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Text(
                        "تعيين المنظور",
                        style: StyleText.fontSize16Weight400.copyWith(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: AppColors.text),
                      ),
                    ),
                    AddNewVisions(isWithNote: true),
                  ],
                ),
              ),
            ),
          ),
          ChampionNavDownButtons()
        ],
      ),
    );
  }

  Widget _championsBuilder(BuildContext context) {
    return GridView.builder(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          mainAxisExtent: 72.sp,
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

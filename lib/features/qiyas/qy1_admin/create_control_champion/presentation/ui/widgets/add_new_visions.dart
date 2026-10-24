import 'package:knowticed_plus/core/extensions/context_extensions.dart'
    show kpIsPhoneLayout;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:knowticed_plus/features/qiyas/qy1_admin/create_control_champion/presentation/controller/qiyas_create_champion_controller_cubit.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';

import 'package:knowticed_plus/features/qiyas/qiyas_get_it.dart';
import 'package:knowticed_plus/core/custom/buttons/custom_button.dart';
import 'package:knowticed_plus/features/qiyas/qy1_admin/create_control_core/presentation/controller/control_core_cubit.dart';
import 'package:knowticed_plus/features/qiyas/qy1_admin/create_control_champion/presentation/ui/widgets/champion_additional_note_text_field.dart';
import 'package:knowticed_plus/features/qiyas/qy1_admin/create_control_champion/presentation/ui/widgets/champion_criterion_text_field.dart';
import 'package:knowticed_plus/features/qiyas/qy1_admin/create_control_champion/presentation/ui/widgets/champion_document_text_field.dart';
import 'package:knowticed_plus/features/qiyas/qy1_admin/create_control_champion/presentation/ui/widgets/champion_documentation_date_text_field.dart';
import 'package:knowticed_plus/features/qiyas/qy1_admin/create_control_champion/presentation/ui/widgets/champion_topic_text_field.dart';
import 'package:knowticed_plus/features/qiyas/qy1_admin/create_control_champion/presentation/ui/widgets/champion_vision_text_field.dart';
import 'package:knowticed_plus/core/theme/haptic_controller.dart';

class AddNewVisions extends StatelessWidget {
  AddNewVisions({required this.isWithNote, super.key});
  final bool isWithNote;
  final QiyasCreateChampionControllerCubit controller = sl();

  @override
  Widget build(BuildContext context) {
    bool isTablet = !kpIsPhoneLayout(context);
    return BlocBuilder<ControlCoreCubit, ControlCoreState>(
        bloc: controller,
        buildWhen: (_, currentState) {
          return currentState is VisionsDataChanged;
        },
        builder: (context, state) {
          return Form(
            key: controller.formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (isTablet)
                  _buildTabletLayout(context)
                else
                  _buildMobileLayout(),
                SizedBox(height: 8.sp),
              ],
            ),
          );
        });
  }

  Widget _buildTabletLayout(BuildContext context) {
    bool isPortrait =
        MediaQuery.of(context).orientation == Orientation.portrait;

    return Column(
      children: [
        for (int index = 0;
            index < controller.visionControllersList.length;
            index++)
          Column(
            spacing: 15.sp,
            children: [
              /// ===== Remove button for duplicated sections =====
              if (index > 0) _buildRemoveButton(index),

              if (index == 0)
                Row(
                  children: [
                    customButton(
                        width: isPortrait ? 115.w : 125.w,
                        function: () {
                          controller.duplicateTextFields();
                        },
                        title: "منظور"),
                  ],
                ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ChampionDocumentationDateTextField(index: index),
                  const SizedBox(width: 15),
                  ChampionVisionTextField(index: index),
                ],
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ChampionTopicTextField(index: index),
                  const SizedBox(width: 15),
                  ChampionCriterionTextField(index: index),
                ],
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ChampionDocumentTextField(index: index),
                ],
              ),
              if (isWithNote) ChampionAdditionalNoteTextField(index: index),
              if (index != controller.duplicationIndex - 1)
                SizedBox(height: 30.sp),
            ],
          )
      ],
    );
  }

  Widget _buildMobileLayout() {
    return Column(
      children: [
        for (int index = 0;
            index < controller.visionControllersList.length;
            index++)
          Column(
            spacing: 15.sp,
            children: [
              /// ===== Remove button for duplicated sections =====
              if (index > 0) _buildRemoveButton(index),

              /// ===== Add button only on first section =====
              if (index == 0)
                Row(
                  children: [
                    customButton(
                        width: 140.w,
                        function: () {
                          controller.duplicateTextFields();
                        },
                        title: "منظور"),
                  ],
                ),

              Row(children: [ChampionVisionTextField(index: index)]),
              Row(children: [ChampionTopicTextField(index: index)]),
              Row(children: [ChampionCriterionTextField(index: index)]),
              Row(children: [ChampionDocumentTextField(index: index)]),
              Row(children: [ChampionDocumentationDateTextField(index: index)]),
              if (isWithNote) ChampionAdditionalNoteTextField(index: index),
              if (index != controller.duplicationIndex - 1)
                SizedBox(height: 30.sp),
            ],
          ),
      ],
    );
  }

  Widget _buildRemoveButton(int index) {
    return Column(
      children: [
        InkWell(
          onTapDown: (_) => HapticController.high(),
          onTap: () {
            controller.removeDuplicatedFields(index);
          },
          splashColor: Colors.transparent,
          hoverColor: Colors.transparent,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('المنظور',
                  style: StyleText.fontSize18Weight500
                      .copyWith(color: AppColors.text)),
              SvgPicture.asset(
                'assets/icons_assets/main_icons_assets/ic_delete_trash_red.svg',
                colorFilter: ColorFilter.mode(AppColors.red, BlendMode.srcIn),
                width: 12.sp,
                height: 12.sp,
              ),
            ],
          ),
        ),
        SizedBox(height: 5.sp),
      ],
    );
  }
}

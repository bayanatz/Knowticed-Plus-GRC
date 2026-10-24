import 'package:knowticed_plus/core/theme/app_animations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:knowticed_plus/features/qiyas/qy1_admin/create_control_champion/presentation/ui/widgets/old_visions.dart';
import 'package:knowticed_plus/features/qiyas/qy1_admin/create_control_champion/presentation/controller/qiyas_create_champion_controller_cubit.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';

import 'package:knowticed_plus/features/qiyas/qiyas_get_it.dart';
import 'package:knowticed_plus/features/qiyas/qy1_admin/create_control_core/presentation/controller/control_core_cubit.dart';
import 'package:knowticed_plus/features/qiyas/qy1_admin/create_control_champion/presentation/ui/widgets/add_new_visions.dart';
import 'package:knowticed_plus/features/qiyas/qy1_admin/create_control_champion/presentation/ui/widgets/edit_champion_actions.dart';
import 'package:knowticed_plus/core/custom/dialogs/custom_filter_frame.dart';

class EditChampionDialog {
  void show(BuildContext context) {
    showAppDialog(
        context: context,
        builder: (BuildContext context) {
          return Dialog(
            child: Content(),
          );
        });
  }
}

class Content extends StatelessWidget {
  const Content({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<ControlCoreCubit>.value(
      value: sl<QiyasCreateChampionControllerCubit>(),
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: Container(
          width: 665.sp,
          padding: EdgeInsets.all(15.sp),
          decoration: BoxDecoration(
            color: AppColors.card,
            borderRadius: BorderRadius.circular(8.r),
          ),
          child: SingleChildScrollView(
            child: Column(
              spacing: 25.sp,
              mainAxisSize: MainAxisSize.min,
              children: [
                // 22/10/2026 — Owner: one dialog header everywhere (30 circle · 16 icon · 18/500 title) — was a hand-rolled 15./19./19. row.
                CustomDialogHeader(
                    title: 'تعديل المنظور',
                    icon:
                        'assets/icons_assets/main_icons_assets/ic_action_edit.svg'),
                OldVisions(),
                AddNewVisions(isWithNote: false),
                EditChampionActions()
              ],
            ),
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:knowticed_plus/features/qiyas/qiyas_get_it.dart';
import 'package:knowticed_plus/features/messaging/helpers/messaging_app_bar.dart';
import 'package:knowticed_plus/features/qiyas/qy1_admin/create_control_champion/presentation/ui/widgets/add_new_visions.dart';
import 'package:knowticed_plus/features/qiyas/qy1_admin/create_control_champion/presentation/ui/widgets/old_visions.dart';
import 'package:knowticed_plus/features/qiyas/qy1_admin/create_control_champion/presentation/controller/qiyas_create_champion_controller_cubit.dart';
import 'package:knowticed_plus/features/qiyas/qy1_admin/create_control_core/presentation/controller/control_core_cubit.dart';

import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/features/qiyas/qy1_admin/create_control_champion/presentation/ui/widgets/edit_champion_actions.dart';

class EditChampionPage extends StatelessWidget {
  const EditChampionPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<ControlCoreCubit>.value(
      value: sl<QiyasCreateChampionControllerCubit>(),
      child: Scaffold(
        body: Directionality(
          textDirection: TextDirection.rtl,
          child: SafeArea(
              child: Padding(
            padding: EdgeInsetsDirectional.symmetric(horizontal: 15.sp),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CustomAppBar(hideLeading: false, title: 'تعديل المنظور '),
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      spacing: 15.sp,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            color: AppColors.card,
                            borderRadius: BorderRadius.circular(8.r),
                          ),
                          padding: EdgeInsets.all(15.sp),
                          child: OldVisions(),
                        ),
                        Container(
                          decoration: BoxDecoration(
                            color: AppColors.card,
                            borderRadius: BorderRadius.circular(8.r),
                          ),
                          padding: EdgeInsets.all(15.sp),
                          child: AddNewVisions(isWithNote: true),
                        ),
                        EditChampionActions(),
                        SizedBox(height: 15.sp)
                      ],
                    ),
                  ),
                )
              ],
            ),
          )),
        ),
      ),
    );
  }
}

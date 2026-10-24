/// ***************************** FILE INFO ***************************** ///
/// File Name: qiyas_control_champion_card.dart
/// Purpose: Displays a list of control champion cards for the Qiyas module.
///          Each card represents an employee with their photo, name, department, and title.
///          Users can tap on a card to navigate to a detailed view of the control champion's information.
/// Author: Abdelrahman Sobhy
/// Created At: Apr/21/2025
/// Description: This widget builds a grid of control champion cards where each card shows the photo, name, department,
///              and title of an employee. Depending on the device (pages, desktop, or mobile), the layout adapts to
///              provide an optimized viewing experience. Users can tap a card to navigate to either a mobile or pages
///              screen with detailed information about the control champion. The card also features a button to send a message.
/// ********************************************************************* ///
library;

import 'package:knowticed_plus/core/extensions/context_extensions.dart'
    show kpIsPhoneLayout;
import 'package:knowticed_plus/core/custom/feedback/custom_empty_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:knowticed_plus/core/extensions/screen_fraction_extension.dart';
import 'package:knowticed_plus/core/custom/layout/cross_axis_count_helper.dart';
import 'package:knowticed_plus/features/qiyas/qy1_admin/create_control_core/presentation/controller/control_core_cubit.dart';

import 'package:knowticed_plus/features/qiyas/qiyas_get_it.dart';
import 'package:knowticed_plus/features/qiyas/qy1_admin/create_control_champion/presentation/ui/pages/champion_details_screen.dart';
import 'package:knowticed_plus/features/qiyas/qy1_admin/create_control_champion/presentation/controller/qiyas_create_champion_controller_cubit.dart';
import 'package:knowticed_plus/features/qiyas/qy1_admin/home/presentation/ui/widgets/tablet/employee_overview.dart';
import 'package:knowticed_plus/core/theme/haptic_controller.dart';

class QiyasControlChampionCard extends StatelessWidget {
  const QiyasControlChampionCard({super.key});

  @override
  Widget build(BuildContext context) {
    bool isTablet = !kpIsPhoneLayout(context);

    return BlocBuilder<ControlCoreCubit, ControlCoreState>(
        buildWhen: (_, currentState) {
      return currentState is OwnersDataLoaded;
    }, builder: (context, state) {
      QiyasCreateChampionControllerCubit controller = context
          .read<ControlCoreCubit>() as QiyasCreateChampionControllerCubit;

      var listEmployee =
          controller.getEmployeesFromEmails(controller.filteredUniqueEmployees);

      if (listEmployee.isEmpty) {
        return Center(
          child: CustomEmptyState(
            lottiePath:
                'assets/lottie_assets/main_lottie_assets/lot_empty_state.json',
            size: 300,
            verticalPadding: 0,
          ),
        );
      }

      return Padding(
        padding: EdgeInsets.symmetric(vertical: 0.02.h),
        child: GridView.builder(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount:
                CrossAxisCountHelper.getCrossAxisCountForDefaultTablet2(
                    context),
            mainAxisExtent: 80.sp,
            crossAxisSpacing: 15.sp,
            mainAxisSpacing: isTablet ? 15.sp : 10.sp,
          ),
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: listEmployee.length,
          itemBuilder: (context, index) {
            return GestureDetector(
              onTap: () {
                HapticController.low(); // list row: on the tap (X-117)
                controller.personDetails = listEmployee[index];
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => BlocProvider.value(
                              value: sl<QiyasCreateChampionControllerCubit>()
                                  as ControlCoreCubit,
                              child: ChampionDetailsScreen(),
                            )));
              },
              child: EmployeeOverview(
                personEntity: listEmployee[index],
              ),
            );
          },
        ),
      );
    });
  }
}

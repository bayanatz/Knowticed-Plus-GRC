///************************* FILE INFO ****************************///
/// File: user_access_container.dart
/// Purpose: Contains the ui for user access container roles_module screen.
/// Author: Mohamed Elrashidy
/// Refactored at: 28/1/2025
import 'package:demo_app/core/helper/employees/presentation/controller/employee_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import 'package:demo_app/core/theme/app_font_size.dart';
import 'package:demo_app/core/custom/circle_progress.dart';
import 'package:demo_app/features/roles/account_status/controller/account_status_cubit.dart';

import 'package:lottie/lottie.dart';

import 'package:demo_app/features/roles/account_status/controller/account_status_state.dart';
import 'package:demo_app/features/roles/account_status/ui/widgets/accounts_status_row.dart';
import 'package:demo_app/features/roles/account_status/ui/widgets/custom_user_access_container.dart';
import 'package:demo_app/features/roles/account_status/ui/widgets/search_and_filter.dart';

class UserAccessHomePage extends StatefulWidget {
  @override
  State<UserAccessHomePage> createState() => _UserAccessHomePageState();
}

EmployeeController addEmployeeController = Get.find();

class _UserAccessHomePageState extends State<UserAccessHomePage> {
  late AccountStatusCubit controller;

  @override
  void initState() {
    controller = context.read<AccountStatusCubit>();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      controller.getAccountsStatusEntities();
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    bool isPortrait = MediaQuery.of(context).orientation == Orientation.portrait;

    return BlocBuilder<AccountStatusCubit, AccountStatusState>(
      buildWhen: (_, __) => true,
      builder: (context, state) {
        if (controller.filteredSortedSelectedEntities == null) {
          return Center(child: CircleProgressMaster());
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AccountsStatusRow(),
            SizedBox(height: 20.sp),
            SearchAndFilter(),
            SizedBox(height: 20.sp),
            controller.filteredSortedSelectedEntities!.isEmpty
                ? noMembers(isPortrait, context)
                : Expanded(
              child: ListView.separated(
                // ✅ Use ListView.separated instead of SingleChildScrollView + Column
                itemCount: controller.filteredSortedSelectedEntities!.length,
                padding: EdgeInsets.only(bottom: 20.sp),
                separatorBuilder: (context, index) => SizedBox(height: 10.sp),
                itemBuilder: (context, index) {
                  return CustomUserAccessContainer(
                    accountStatusEntity: controller.filteredSortedSelectedEntities![index],
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }

  Center noMembers(bool isPortrait, BuildContext context) {
    return Center(
      child: SizedBox(
        height: (isPortrait ? 0.62.h : 0.48.h),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Lottie.asset(
              "assets/lottie/empty.json",
              width: 300.w,
              height: 300.h,
              fit: BoxFit.fill,
            ),
          ],
        ),
      ),
    );
  }
}
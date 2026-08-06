///************************* FILE INFO ****************************///
/// File: user_access_container.dart
/// Purpose: Contains the ui for user access container roles_module screen.
/// Author: Amr Mesbah
/// Refactored at: 28/1/2025
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import 'package:grc_module/core/theme/app_font_size.dart';
import 'package:grc_module/core/custom/circle_progress.dart';
import 'package:grc_module/features/roles/r3_user_access/presentation/controller/user_access_cubit.dart';

import 'package:lottie/lottie.dart';

import 'package:grc_module/features/roles/r3_user_access/presentation/controller/user_access_state.dart';
import 'package:grc_module/features/roles/r3_user_access/presentation/ui/widgets/user_access_status_row.dart';
import 'package:grc_module/features/roles/r3_user_access/presentation/ui/widgets/search_and_filter.dart';
import 'package:grc_module/core/custom/19-Custom_Employee_Card.dart';
import 'package:grc_module/core/extension/context_extensions.dart';
import 'package:grc_module/features/settings/main_controller/presentation/controller/employee_controller.dart';
import 'package:grc_module/features/roles/r4_active_directory/presentation/controller/main_core_department_cubit.dart';

class UserAccessHomePage extends StatefulWidget {
  @override
  State<UserAccessHomePage> createState() => _UserAccessHomePageState();
}

EmployeeController addEmployeeController = Get.find();

class _UserAccessHomePageState extends State<UserAccessHomePage> {
  late UserAccessCubit controller;

  @override
  void initState() {
    controller = context.read<UserAccessCubit>();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      controller.getAccountsStatusEntities();
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    bool isPortrait = MediaQuery.of(context).orientation == Orientation.portrait;

    return BlocBuilder<UserAccessCubit, UserAccessState>(
      buildWhen: (_, __) => true,
      builder: (context, state) {
        if (controller.filteredSortedSelectedEntities == null) {
          return Center(child: CircleProgressMaster());
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            UserAccessStatusRow(),
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
                  final entity =
                      controller.filteredSortedSelectedEntities![index];
                  final isArabic = context.isArabic;
                  return PersonChipCard(
                    width: double.infinity,
                    name: isArabic ? entity.arabicName : entity.englishName,
                    subtitle1: entity.departmentName(
                      isArabic,
                      context.read<MainCoreDepartmentCubit>(),
                    ),
                    subtitle2: entity.jobTitle(isArabic),
                    avatar: _avatarOf(entity.photoUrl),
                    showCheckBox: false,
                    trailing: Container(
                      width: 12.r,
                      height: 12.r,
                      decoration: BoxDecoration(
                        color: entity.status.color,
                        shape: BoxShape.circle,
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }

  /// [photoUrl] is either a remote URL or a bundled asset path
  /// (see UserAccessEntity.fromEmployeeModelHistory).
  ImageProvider? _avatarOf(String? photoUrl) {
    if (photoUrl == null || photoUrl.isEmpty) return null;
    return photoUrl.startsWith('assets/')
        ? AssetImage(photoUrl)
        : NetworkImage(photoUrl);
  }

  Center noMembers(bool isPortrait, BuildContext context) {
    return Center(
      child: SizedBox(
        height: (isPortrait ? 0.62.h : 0.48.h),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Lottie.asset(
              "assets/lottie_assets/notification_lottie_assets/empty.json",
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
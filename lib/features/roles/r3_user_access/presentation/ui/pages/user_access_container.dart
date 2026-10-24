/// Module: roles / r3_user_access / presentation / ui / pages
///
///************************* FILE INFO ****************************///
/// File: user_access_container.dart
/// Purpose: Contains the ui for user access container roles_module screen.
/// Author: Amr Mesbah
/// Refactored at: 28/1/2025
/// Updated: 22/10/2026 - The account a notification asked for is outlined at
///          the top; a locked one opens the Unlock dialog (owner: View opens
///          the record, not the module).
library;

import 'package:knowticed_plus/core/custom/feedback/custom_empty_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/extensions/screen_fraction_extension.dart';
import 'package:knowticed_plus/core/custom/feedback/circle_progress.dart';
import 'package:knowticed_plus/features/roles/r3_user_access/presentation/controller/user_access_cubit.dart';

import 'package:knowticed_plus/features/roles/r3_user_access/presentation/controller/user_access_state.dart';
import 'package:knowticed_plus/features/roles/r3_user_access/presentation/ui/widgets/user_access_status_row.dart';
import 'package:knowticed_plus/features/roles/r3_user_access/presentation/ui/widgets/search_and_filter.dart';
import 'package:knowticed_plus/features/roles/r3_user_access/presentation/ui/widgets/user_access_card.dart';
import 'package:knowticed_plus/features/roles/r3_user_access/presentation/ui/widgets/user_access_dialogs.dart';
import 'package:knowticed_plus/features/roles/r3_user_access/domain/entities/user_access_entity.dart';
import 'package:knowticed_plus/features/roles/r4_active_directory/presentation/controller/main_core_department_cubit.dart';

// REMOVED 12/8/2026: `EmployeeController addEmployeeController = Get.find();`
// — an unused top-level global that ran a service-locator lookup at import
// time (GetX standing rule + dead code).

class UserAccessHomePage extends StatefulWidget {
  const UserAccessHomePage({super.key});

  @override
  State<UserAccessHomePage> createState() => _UserAccessHomePageState();
}

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
  void dispose() {
    // The notification's account belongs to this visit only.
    controller.clearFocus();
    super.dispose();
  }

  /// Opens the Unlock dialog for the notification's account when it is still
  /// locked — an unlock request lands where the admin can act on it.
  void _promptUnlockIfAsked() {
    final UserAccessEntity? entity = controller.takeAccountToUnlock();
    if (entity == null) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      UserAccessDialogs.showUnlock(
        context: context,
        entity: entity,
        controller: controller,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    bool isPortrait =
        MediaQuery.of(context).orientation == Orientation.portrait;

    // Was a bare BlocBuilder. `UserAccessError` was emitted by the cubit but
    // nothing in the feature listened for it, so a failed load or a failed
    // activate/deactivate write could never reach the user (§16). The listener
    // surfaces it; the builder still renders the list.
    return BlocConsumer<UserAccessCubit, UserAccessState>(
      listenWhen: (_, current) =>
          current is UserAccessError || current is UserAccessLoaded,
      listener: (context, state) {
        if (state is UserAccessLoaded) {
          _promptUnlockIfAsked();
          return;
        }
        if (state is! UserAccessError) return;
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(
            SnackBar(
              backgroundColor: AppColors.red,
              behavior: SnackBarBehavior.floating,
              duration: const Duration(seconds: 4),
              content: Text(
                state.message,
                style: TextStyle(color: AppColors.white),
              ),
            ),
          );
      },
      buildWhen: (_, __) => true,
      builder: (context, state) {
        if (state is UserAccessLoading) {
          return Center(child: CircleProgressMaster());
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            UserAccessStatusRow(),
            SizedBox(height: 20.sp),
            SearchAndFilter(),
            SizedBox(height: 20.sp),
            controller.filteredSortedSelectedEntities.isEmpty
                ? noMembers(isPortrait, context)
                : Expanded(
                    child: ListView.separated(
                      // ✅ Use ListView.separated instead of SingleChildScrollView + Column
                      itemCount:
                          controller.filteredSortedSelectedEntities.length,
                      padding: EdgeInsets.only(bottom: 20.sp),
                      separatorBuilder: (context, index) =>
                          SizedBox(height: 10.sp),
                      itemBuilder: (context, index) {
                        final entity =
                            controller.filteredSortedSelectedEntities[index];
                        final Widget card = UserAccessCard(
                          key: ValueKey(entity.employeeId),
                          entity: entity,
                          controller: controller,
                          departments: context.read<MainCoreDepartmentCubit>(),
                        );
                        if (!controller.isFocused(entity)) return card;
                        // The notification's account: outlined in the
                        // primary colour, outside the card's status border.
                        return DecoratedBox(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(11.r),
                            border: Border.all(
                              color: AppColors.primary,
                              width: 2,
                            ),
                          ),
                          child: Padding(
                            padding: EdgeInsets.all(3.sp),
                            child: card,
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

  Center noMembers(bool isPortrait, BuildContext context) {
    return Center(
      child: SizedBox(
        height: (isPortrait ? 0.62.h : 0.48.h),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CustomEmptyState(
              lottiePath:
                  "assets/lottie_assets/main_lottie_assets/lot_empty_state.json",
              size: 300,
              verticalPadding: 0,
            ),
          ],
        ),
      ),
    );
  }
}

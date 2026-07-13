part of '../pages/employee_details.dart';

extension EmployeeDetailsMethods2 on _RoleEmployeeDetailsPageState {
  Widget _buildContent() {
    final lightMode = Theme.of(context).brightness == Brightness.light;
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';
    final isTablet = context.isTablet;
    final isMobile = context.isPhone;
    final isLandscape = context.isLandscape;

    return SafeArea(
      child: SideFrameMasterServices(
        titleText: 'Platform Controls and Management'.tr,
        onFirstTap: () => Navigator.pop(context),
        secondTitle: S.of(context).employeeDetails,
        child: SingleChildScrollView(
          physics: const ClampingScrollPhysics(),
          child: Column(
            children: [
              // ── Edit / Delete buttons ────────────────────────────────────
              Row(
                children: [
                  const Spacer(),
                  if (Get.find<MainCoreEmployeeController>().isHasPermission(
                    module: Modules.roles,
                    section: RolePermissionsSections.userManagement,
                    permission: UserManagement.editAccess,
                  ))
                    customButtonWithImage(
                      title: context.isPhone ? '' : S.of(context).edit,
                      function: () async {
                        final result = await showEditUserAccessDialog(
                          context: context,
                          userPermission: widget.userPermission,
                        );

                        if (result == null || result is! Map<String, dynamic>)
                          return;
                        if (!mounted) return;

                        final nav = Navigator.of(context);
                        final rootNav =
                        Navigator.of(context, rootNavigator: true);
                        final messenger = ScaffoldMessenger.of(context);
                        final userMgmtCubit =
                        context.read<UserManagementAccessCubit>();
                        final currentUserEmail =
                        Get.find<MainCoreEmployeeController>()
                            .employeeEntity!
                            .email!;

                        rootNav.push(PageRouteBuilder(
                          opaque: false,
                          barrierDismissible: false,
                          barrierColor: Colors.black38,
                          pageBuilder: (_, __, ___) => WillPopScope(
                            onWillPop: () async => false,
                            child: Center(
                              child: CircularProgressIndicator(
                                  color: AppColors.primary),
                            ),
                          ),
                        ));

                        try {
                          final String selectedRole = result['role'] ?? '';
                          final DateTime accessGranted =
                          result['accessGranted'];
                          final DateTime accessRevoked =
                          result['accessRevoked'];

                          final String startDateStr = DateFormat(
                              Constants.userAccessDateFormat)
                              .format(accessGranted);
                          final String endDateStr =
                          DateFormat(Constants.userAccessDateFormat)
                              .format(accessRevoked);

                          final updateResult = await userMgmtCubit.repository
                              .updateUserPermission(
                            employeeId: widget.userPermission.employeeId,
                            currentUserEmail: currentUserEmail,
                            accessName: selectedRole,
                            accessBegin: startDateStr,
                            accessEnd: endDateStr,
                          );

                          if (updateResult.isLeft()) {
                            final errMsg = updateResult.fold(
                                    (l) => l.errMessage, (r) => 'Unknown error');
                            throw Exception(errMsg);
                          }

                          rootNav.pop();

                          Get.find<MainCoreEmployeeController>()
                              .getAllNewEmployees()
                              .ignore();
                          try {
                            userMgmtCubit.getUserAccess();
                          } catch (_) {}

                          if (!mounted) return;
                          showDialog(
                            context: context,
                            barrierDismissible: false,
                            builder: (dialogCtx) {
                              Future.delayed(const Duration(seconds: 2), () {
                                if (Navigator.of(dialogCtx,
                                    rootNavigator: true)
                                    .canPop()) {
                                  Navigator.of(dialogCtx, rootNavigator: true)
                                      .pop();
                                }
                                nav.pop(true);
                              });
                              return ConfirmationDialog(
                                lottiePath: 'assets/lottie/approved.json',
                                title: 'Access Updated'.tr,
                                message:
                                'User access has been successfully updated'
                                    .tr,
                              );
                            },
                          );
                        } catch (e) {
                          rootNav.pop();
                          messenger.showSnackBar(SnackBar(
                            content: Text(
                                'Failed to update access: ${e.toString()}'),
                            backgroundColor: Colors.red,
                            duration: const Duration(seconds: 3),
                          ));
                        }
                      },
                      textStyle: StyleText.fontSize16Weight500.copyWith(
                        color: AppColors.textButton,
                      ),
                      width: context.isPhone ? 38.sp : 135.sp,
                      height: 38.sp,
                      space: context.isPhone ? 0 : 8.sp,
                      radius: 8.r,
                      color: AppColors.primary,
                      image: 'assets/edit.svg',
                      svgColor: AppColors.textButton,
                      widthImage: 15.sp,
                      heightImage: 15.sp,
                      colorBorder: Colors.transparent,
                    ),

                  if (Get.find<MainCoreEmployeeController>().isHasPermission(
                    module: Modules.roles,
                    section: RolePermissionsSections.userManagement,
                    permission: UserManagement.removeAccess,
                  ))
                    SizedBox(width: 15.sp),

                  if (Get.find<MainCoreEmployeeController>().isHasPermission(
                    module: Modules.roles,
                    section: RolePermissionsSections.userManagement,
                    permission: UserManagement.removeAccess,
                  ))
                    customButtonWithImage(
                      title: context.isPhone ? "" : S.of(context).delete,
                      function: () async {
                        final confirmed = await CustomConfirmationDialog.show(
                          context: context,
                          title: S.of(context).remove_access,
                          message: S.of(context).remove_access_confirmation,
                          lottieAsset: 'assets/lottie/delete.json',
                          confirmText: S.of(context).yes,
                          cancelText: S.of(context).no,
                          confirmButtonColor: AppColors.primary,
                        );

                        if (!confirmed) return;
                        if (!mounted) return;

                        showDialog(
                          context: context,
                          barrierDismissible: false,
                          builder: (dialogContext) => WillPopScope(
                            onWillPop: () async => false,
                            child: Center(
                              child: CircularProgressIndicator(
                                  color: AppColors.primary),
                            ),
                          ),
                        );

                        try {
                          final success = await _removeUserAccess(
                              employeeId: widget.userPermission.employeeId);

                          if (mounted) {
                            Navigator.of(context, rootNavigator: true).pop();
                          }

                          if (success) {
                            await employeeController.getAllNewEmployees();
                            await Future.delayed(
                                const Duration(milliseconds: 300));

                            if (!mounted) return;

                            _showTimedSuccessDialog(
                              context: context,
                              lottiePath: 'assets/lottie/approved.json',
                              title: S.of(context).access_removed,
                              message: S.of(context).access_removed_success,
                              seconds: 3,
                              onAfterDismiss: () {
                                if (!mounted) return;
                                try {
                                  context
                                      .read<UserManagementAccessCubit>()
                                      .getUserAccess();
                                } catch (e) {
                                }
                                Navigator.of(context).pop(true);
                              },
                            );
                          } else {
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: const Text(
                                      'Failed to remove user access. Please try again.'),
                                  backgroundColor: Colors.red,
                                  duration: const Duration(seconds: 3),
                                ),
                              );
                            }
                          }
                        } catch (e) {
                          if (mounted) {
                            Navigator.of(context, rootNavigator: true).pop();
                          }
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content:
                                Text('An error occurred: ${e.toString()}'),
                                backgroundColor: Colors.red,
                                duration: const Duration(seconds: 3),
                              ),
                            );
                          }
                        }
                      },
                      textStyle: StyleText.fontSize16Weight500.copyWith(
                        color: AppColors.white,
                      ),
                      width: context.isPhone ? 38.sp : 135.sp,
                      height: 38.sp,
                      space: context.isPhone ? 0 : 8.sp,
                      radius: 8.r,
                      color: const Color(0xffDF1C1C),
                      image: "assets/icons_assets/main_icons_assets/delete_person.svg",
                      svgColor: Colors.white,
                      widthImage: 15.sp,
                      heightImage: 15.sp,
                      colorBorder: Colors.transparent,
                    ),
                ],
              ),

              // ── Employee Details title ────────────────────────────────────
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Text(
                    S.of(context).employeeDetails,
                    style: StyleText.fontSize16Weight500.copyWith(
                      color: AppColors.text,
                    ),
                  ),
                ],
              ),

              SizedBox(height: 8.sp),

              _buildEmployeeHeader(
                  lightMode, isArabic, isMobile, isTablet, isLandscape),

              SizedBox(height: 16.sp),

              // ── Info container ────────────────────────────────────────────
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8.r),
                  color: AppColors.card,
                ),
                child: Padding(
                  padding: EdgeInsets.all(15.sp),
                  child: Column(
                    children: [
                      // ── Row 1: access grantor | supervisor | access granted ──
                      Row(
                        children: [
                          AccessGrantorWidget(
                            title: S.of(context).access_grantor,
                            name: widget.userPermission.grantorName.isNotEmpty
                                ? widget.userPermission.grantorName
                                : '-',
                          ),
                          SizedBox(width: 10.w),
                          AccessGrantorWidget(
                            title: S.of(context).supervisor,
                            name: _getSupervisorName(),
                          ),
                          SizedBox(width: 10.w),
                          AccessGrantorWidget(
                            title: S.of(context).access_granted,
                            name: _formatDate(
                              widget.userPermission.startDate,
                              isArabic,
                            ),
                          ),
                          SizedBox(width: 10.w),
                          AccessGrantorWidget(
                            title: S.of(context).access_revoked,
                            name: _formatDate(
                              widget.userPermission.endDate,
                              isArabic,
                            ),
                          ),
                          SizedBox(width: 10.w),
                          AccessGrantorWidget(
                            title: S.of(context).last_login,
                            name: _formatDate(
                              currentEmployeeEntity?.lastLogin,
                              isArabic,
                            ),
                          ),
                          SizedBox(width: 10.w),
                          AccessGrantorWidget(
                            title: S.of(context).total_modules,
                            name: _getTotalModules(),
                          ),
                        ],
                      ),



                      SizedBox(height: 16.h),

                      _buildPermissionsSection(lightMode),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  Color _getStatusColor(String statusName) {
    final normalizedStatus = statusName.toLowerCase().replaceAll(' ', '');
    switch (normalizedStatus) {
      case 'active':        return const Color(0xFF4BB609);
      case 'inactive':      return const Color(0xFFDF1C1C);
      case 'scheduled':     return const Color(0xFFFF814A);
      case 'expiringsoon':  return const Color(0xFF991010);
      default:              return AppColors.text;
    }
  }
  Widget _buildPermissionsSection(bool lightMode) {
    if (!_permissionsLoaded) {
      return Container(
        decoration: BoxDecoration(
          color: lightMode
              ? AppColors.white
              : AppColors.chatBackground,
          borderRadius: BorderRadius.circular(8.r),
        ),
        child: Center(
          child: Padding(
            padding: EdgeInsets.all(20.sp),
            child: CircularProgressIndicator(color: AppColors.primary),
          ),
        ),
      );
    }

    if (_modulePermissions.isEmpty) {
      return Container(
        decoration: BoxDecoration(
          color: lightMode
              ? AppColors.white
              : AppColors.chatBackground,
          borderRadius: BorderRadius.circular(8.r),
        ),
        child: Center(
          child: Padding(
            padding: EdgeInsets.all(20.sp),
            child: Text(
              'No permissions found'.tr,
              style: AppTextStyles.font14BlackCairoRegular.copyWith(
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color:
        lightMode ? AppColors.white : AppColors.chatBackground,
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            spacing: 10.sp,
            children: [
              for (String moduleString in activeModuleStrings)
                _buildModulePermissionRow(
                  lightMode: lightMode,
                  moduleString: moduleString,
                ),
            ],
          ),
        ],
      ),
    );
  }
}

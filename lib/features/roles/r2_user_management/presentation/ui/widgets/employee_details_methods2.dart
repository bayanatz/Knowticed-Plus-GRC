part of '../pages/employee_details.dart';

extension EmployeeDetailsMethods2 on _RoleEmployeeDetailsPageState {
  Widget _buildContent() {
    final lightMode = Theme.of(context).brightness == Brightness.light;
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';
    final isTablet = ContextExtension(context).isTablet;
    final isMobile = ContextExtension(context).isPhone;
    final isLandscape = ContextExtension(context).isLandscape;

    return SafeArea(
      child: SideFrameMasterServices(
        titleText: S.current.platformControlsAndManagement,
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
                    customButtonWithSvg(
                      title: ContextExtension(context).isPhone ? '' : S.of(context).edit,
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
                          await CustomDialogManager.showSuccess(
                            context: context,
                            lottiePath:
                                'assets/lottie_assets/main_lottie_assets/approved.json',
                            title: S.of(context).accessUpdated,
                            subtitle:
                                'User access has been successfully updated',
                          );
                          nav.pop(true);
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
                      space: ContextExtension(context).isPhone ? 0 : 8.sp,
                      color: AppColors.primary,
                      image: 'assets/icons_assets/main_icons_assets/edit_pencil_square.svg',
                      svgColor: AppColors.textButton,
                      widthImage: 15.sp,
                      heightImage: 15.sp,
                      colorBorder: Colors.transparent,),

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
                    customButtonWithSvg(
                      title: ContextExtension(context).isPhone ? "" : S.of(context).delete,
                      function: () async {
                        await CustomDialogManager.showDialogFlow(
                          context: context,
                          confirmLottie:
                              'assets/lottie_assets/roles_lottie_assets/delete.json',
                          confirmTitle: S.of(context).remove_access,
                          confirmSubtitle:
                              S.of(context).remove_access_confirmation,
                          confirmYesText: S.of(context).yes,
                          confirmNoText: S.of(context).no,
                          onConfirm: () async {
                            if (!mounted) return false;

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
                                Navigator.of(context, rootNavigator: true)
                                    .pop();
                              }

                              if (success) {
                                await employeeController.getAllNewEmployees();
                                await Future.delayed(
                                    const Duration(milliseconds: 300));

                                if (!mounted) return false;
                                return true;
                              }

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
                              return false;
                            } catch (e) {
                              if (mounted) {
                                Navigator.of(context, rootNavigator: true)
                                    .pop();
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
                              return false;
                            }
                          },
                          successLottie:
                              'assets/lottie_assets/main_lottie_assets/approved.json',
                          successTitle: S.of(context).access_removed,
                          successSubtitle: S.of(context).access_removed_success,
                          onSuccessComplete: () {
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
                      },
                      textStyle: StyleText.fontSize16Weight500.copyWith(
                        color: AppColors.white,
                      ),
                      space: ContextExtension(context).isPhone ? 0 : 8.sp,
                      color: const Color(0xffDF1C1C),
                      image: "assets/icons_assets/main_icons_assets/minus_circle_red.svg",
                      svgColor: Colors.white,
                      widthImage: 15.sp,
                      heightImage: 15.sp,
                      colorBorder: Colors.transparent,),
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
              S.current.noPermissionsFound,
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

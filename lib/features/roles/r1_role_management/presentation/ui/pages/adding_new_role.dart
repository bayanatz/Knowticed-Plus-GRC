import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:grc_module/core/custom/5-custom_button.dart';
import 'package:grc_module/core/custom/32-custom_svg.dart';
import 'package:grc_module/core/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_switch/flutter_switch.dart';
import 'package:get/get.dart';
import 'package:grc_module/core/custom/2-custom_textfield.dart';
import 'package:grc_module/core/custom/circle_progress.dart';
import 'package:grc_module/core/helper/main_helper/pagination_app_bar.dart';
// REMOVED_MODULE: import 'package:grc_module/features/external/knowledge_hub_module/core/theming/new_theme.dart';
import 'package:grc_module/core/helper/role/modules_enum.dart';

import 'package:grc_module/core/theme/haptic_controller.dart';
import 'package:grc_module/core/custom/57_custom_dialog_manager.dart';
import 'package:grc_module/core/network/api_constants.dart';
import 'package:grc_module/generated/l10n.dart';
import 'package:grc_module/core/theme/app_colors.dart';
import 'package:grc_module/core/theme/app_text_styles.dart';
import 'package:grc_module/features/roles/r1_role_management/data/models/role_model.dart';
import 'package:grc_module/features/roles/r1_role_management/presentation/controller/role_cubit.dart';
import 'package:grc_module/features/roles/r1_role_management/presentation/controller/modules_cubit.dart';
import 'package:grc_module/features/roles/r1_role_management/presentation/ui/widgets/role_image_editor.dart';
import './role_permission_switches.dart';
import 'package:flutter/services.dart';
import 'package:grc_module/features/roles/r5_system_logs/role_log_service.dart';
import 'package:grc_module/core/extension/context_extensions.dart';

part '../widgets/adding_new_role_methods1.dart';

class AddingNewRole extends StatefulWidget {
  AddingNewRole({super.key});

  @override
  State<AddingNewRole> createState() => _AddingNewRoleState();
}

class _AddingNewRoleState extends State<AddingNewRole> {
  late RoleCubit controller;

  @override
  void initState() {
    super.initState();

    Future.microtask(() {
      final controller = context.read<RoleCubit>();

      if (!controller.isEditing && controller.selectedRole == null) {
        controller.initAddingRoleController();
      }
    });
    RoleLogService.log(RoleLogService.pageAddNewRole);
  }

  GlobalKey<FormState> formKey = GlobalKey<FormState>();







  final HapticController hapticController = Get.put(HapticController());

  @override
  Widget build(BuildContext context) {
    bool isTablet = MediaQuery.of(context).size.width > 600;
    bool isArabic = Get.locale?.languageCode == 'ar';
    controller = context.read<RoleCubit>();
    var isMobile = ContextExtension(context).isPhone;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Form(
          key: formKey,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: isMobile ? 0 : 15.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                PaginationAppBar(
                  screensTitles: (controller.isEditing)
                      ? [
                    S.of(context).platformControlsAndManagement,
                    S.of(context).roleDetails,
                    S.of(context).editingRole,
                  ]
                      : [
                    S.of(context).platformControlsAndManagement,
                    S.of(context).addingNewRole,
                  ],
                ),
                Expanded(
                  child: Container(
                    padding: EdgeInsets.all(15.sp),
                    decoration: BoxDecoration(
                      color: AppColors.field,
                      borderRadius: BorderRadius.circular(8.sp),
                    ),
                    child: SingleChildScrollView(
                      physics: const ClampingScrollPhysics(),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [

                          // ── STATUS SWITCH ──────────────────────────────
                          BlocBuilder<RoleCubit, RoleState>(
                            buildWhen: (_, state) =>
                            state is RoleModuleSelected ||
                                state is RoleSelected,
                            builder: (context, state) {
                              return Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  Text(
                                    S.of(context).active,
                                    style: StyleText.fontSize16Weight400.copyWith(
                                      color: AppColors.text,
                                    ),
                                  ),
                                  SizedBox(width: 10.sp),
                                  Transform(
                                    alignment: Alignment.center,
                                    transform: isArabic
                                        ? Matrix4.rotationY(3.14159)
                                        : Matrix4.identity(),
                                    child: FlutterSwitch(
                                      width: 38.sp,
                                      height: 22.sp,
                                      padding: 3.sp,
                                      borderRadius: 20.sp,
                                      toggleSize: 16.sp,
                                      activeColor: AppColors.secondaryPrimary,
                                      inactiveColor:
                                      Colors.grey.withOpacity(.16),
                                      // ✅ reads from cubit
                                      value: controller.isActive,
                                      onToggle: (newValue) async {
                                        // Confirm → apply → success, all handled
                                        // by the shared CustomDialogManager flow.
                                        await _showStatusConfirmDialog(
                                            context, newValue);
                                      },
                                    ),
                                  ),
                                ],
                              );
                            },
                          ),

                          SizedBox(height: 15.sp),
                          RoleImageEditor(),
                          SizedBox(height: 15.sp),

                          // ── NAME FIELDS ────────────────────────────────
                          if (isMobile)
                            Column(
                              children: isArabic
                                  ? [
                                _buildArabicNameField(),
                                SizedBox(height: 15.sp),
                                _buildEnglishNameField(),
                              ]
                                  : [
                                _buildEnglishNameField(),
                                SizedBox(height: 15.sp),
                                _buildArabicNameField(),
                              ],
                            )
                          else
                            Row(
                              children: isArabic
                                  ? [
                                Expanded(child: _buildArabicNameField()),
                                SizedBox(width: 20.sp),
                                Expanded(child: _buildEnglishNameField()),
                              ]
                                  : [
                                Expanded(child: _buildEnglishNameField()),
                                SizedBox(width: 20.sp),
                                Expanded(child: _buildArabicNameField()),
                              ],
                            ),

                          SizedBox(height: 15.sp),

                          // ── DESCRIPTION FIELDS ─────────────────────────
                          if (isArabic) ...[
                            _buildArabicDescriptionField(),
                            SizedBox(height: 15.sp),
                            _buildEnglishDescriptionField(),
                          ] else ...[
                            _buildEnglishDescriptionField(),
                            SizedBox(height: 15.sp),
                            _buildArabicDescriptionField(),
                          ],

                          SizedBox(height: 15.sp),

                          Text(
                            S.of(context).selectModules,
                            style: AppTextStyles.font16BlackRegularCairo,
                          ),

                          SizedBox(height: 15.sp),

                          // ── MODULE GRID ────────────────────────────────
                          FutureBuilder<List<String>>(
                            future: _getAllowedModulesForRoleCreation(),
                            builder: (context, snapshot) {
                              if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return const Center(
                                  child: Padding(
                                    padding: EdgeInsets.all(20),
                                    child: CircleProgressMaster(),
                                  ),
                                );
                              }

                              if (snapshot.hasError) {
                                return Container(
                                  padding: const EdgeInsets.all(20),
                                  child: Text(
                                    "Error loading modules: ${snapshot.error}",
                                    style: const TextStyle(
                                        color: Colors.red, fontSize: 16),
                                    textAlign: TextAlign.center,
                                  ),
                                );
                              }

                              List<String> allowedModuleNames =
                                  snapshot.data ?? [];

                              if (allowedModuleNames.isEmpty) {
                                return Container(
                                  padding: const EdgeInsets.all(20),
                                  child: const Text(
                                    "No modules available. Please contact your administrator.",
                                    style: TextStyle(
                                        color: Colors.orange, fontSize: 16),
                                    textAlign: TextAlign.center,
                                  ),
                                );
                              }

                              List<Modules> activeModules = [];
                              for (var moduleName in allowedModuleNames) {
                                try {
                                  activeModules
                                      .add(_stringToModuleEnum(moduleName));
                                } catch (e) {
                                  // skip unknown modules
                                }
                              }

                              return BlocBuilder<RoleCubit, RoleState>(
                                buildWhen: (_, state) =>
                                state is RoleModuleSelected,
                                builder: (context, state) {
                                  return GridView.builder(
                                    physics:
                                    const NeverScrollableScrollPhysics(),
                                    shrinkWrap: true,
                                    itemCount: activeModules.length,
                                    gridDelegate:
                                    SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount: isTablet ? 14 : 4,
                                      mainAxisSpacing: 10.sp,
                                      crossAxisSpacing: 10.sp,
                                      mainAxisExtent: 55.w,
                                      childAspectRatio: 1,
                                    ),
                                    itemBuilder: (_, index) {
                                      return _moduleItem(
                                          activeModules[index], context);
                                    },
                                  );
                                },
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                SizedBox(height: 20.sp),

                BlocBuilder<RoleCubit, RoleState>(
                  buildWhen: (_, state) => state is RoleModuleSelected,
                  builder: (context, state) {
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        customButton(
                          width: isTablet ? 135 : 120,
                          function: () => Navigator.of(context).pop(),
                          title: S.of(context).discard,
                          color: AppColors.secondaryButton,
                          textStyle: AppTextStyles.font16BlackRegularCairo,
                        ),
                        customButton(
                          width: isTablet ? 135 : 120,
                          function: () => _onNextPressed(context),
                          title: S.of(context).next,
                          color: AppColors.primary,
                        ),
                      ],
                    );
                  },
                ),

                SizedBox(height: 20.sp),
              ],
            ),
          ),
        ),
      ),
    );
  }








}

// ════════════════════════════════════════════════════════════════
// DIALOG — matches StatusChangeDialog from services exactly
// ════════════════════════════════════════════════════════════════


/// Module: messaging / groups / presentation/ui/pages/tablet/create_group_page_tablet.dart
/// ************************* FILE INFO *************************** ///
/// File Name: create_group_page_tablet.dart
/// Purpose: Create group page tablet — messaging Groups sub-feature.
/// Author: Knowticed Team
/// Created At: 11/10/2025

// Date: 16/9/2024
// By: Mohamed Ashraf
// Last update: 28/4/2026
// Objectives: This file is responsible for providing the create group page used in the community feature.

import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:grc_module/core/custom/32-custom_svg.dart';
import 'package:grc_module/core/custom/cross_axis_count_helper.dart';
import 'package:grc_module/core/custom/default_dialog.dart';
import 'package:grc_module/core/custom/messaging_custom_button.dart';
import 'package:grc_module/core/helper/main_helper/pagination_app_bar.dart';
import 'package:grc_module/features/messaging/m2_connections/presentation/controller/connections_controller.dart';
import 'package:grc_module/features/messaging/m3_groups/presentation/controller/groups_controller.dart';

import 'package:grc_module/core/custom/35-custom_search_widget_custom.dart';

import 'package:grc_module/core/helper/main_helper/get_dialog_helper.dart';
import 'package:grc_module/core/helper/message_module/main_helper/localized_text_helper.dart';
import 'package:grc_module/core/helper/main_helper/spacing_helper.dart';
import 'package:grc_module/core/theme/app_colors.dart';
import 'package:grc_module/core/theme/app_text_styles.dart';

import '../../widgets/person_state_view.dart';
import '../../widgets/switch_button/switch_button_title.dart';
import '../../widgets/switch_button/switch_button_title_subTitle.dart';
import '../../widgets/department_dropdown.dart';
import '../../widgets/group_image_editor.dart';
import 'package:grc_module/core/custom/2-custom_textfield.dart';
import 'package:grc_module/core/extension/context_extensions.dart';
import 'package:grc_module/core/helper/role/validator.dart';
import 'package:grc_module/core/custom/5-custom_button.dart';

part './create_group_page_tablet.sections.dart';


/// Regex: matches Arabic letters, Arabic digits, spaces, and common punctuation
final _arabicRegex = RegExp(
  r'^[\u0600-\u06FF\u0750-\u077F\u08A0-\u08FF\uFB50-\uFDFF\uFE70-\uFEFF'
  r'0-9\u0660-\u0669'
  r'\s'
  r'.,!?؟،؛:()\-'
  r']*$',
);

/// Regex: matches English/Latin letters, digits, spaces, and common punctuation
final _englishRegex = RegExp(
  r'^[a-zA-Z0-9\s.,!?;:()\-]*$',
);

/// Returns true if [text] contains any Arabic character
bool _containsArabic(String text) {
  return RegExp(
    r'[\u0600-\u06FF\u0750-\u077F\u08A0-\u08FF\uFB50-\uFDFF\uFE70-\uFEFF]',
  ).hasMatch(text);
}

/// Returns true if [text] contains any English/Latin character
bool _containsEnglish(String text) {
  return RegExp(r'[a-zA-Z]').hasMatch(text);
}

/// Allows only Arabic letters, Arabic numbers, spaces, and common punctuation
class ArabicOnlyFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
    ) {
    if (_arabicRegex.hasMatch(newValue.text)) {
      return newValue;
    }
    return oldValue;
  }
}

class CreateGroupPageTablet extends StatefulWidget {
  const CreateGroupPageTablet({super.key});

  @override
  State<CreateGroupPageTablet> createState() => _CreateGroupPageTabletState();
}

class _CreateGroupPageTabletState extends State<CreateGroupPageTablet> with _CreateGroupPageTabletSections {
  // ---- fields & helpers moved to _CreateGroupPageTabletSections (create_group_page_tablet.sections.dart) ----


  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final connectionsCubit = context.read<ConnectionsCubit>();
      context.read<GroupsCubit>().getMembers(
        connectionsCubit: connectionsCubit,
      );
    });
  }


  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    final isTablet = ContextExtension(context).isTablett;
    final isAr = context.isArabic;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
            padding:
            EdgeInsets.symmetric(horizontal: isTablet ? 24.w : 16.w),
            child: BlocBuilder<GroupsCubit, GroupsState>(
              builder: (context, state) {
                final controller = context.read<GroupsCubit>();

                WidgetsBinding.instance.addPostFrameCallback((_) {
                  _validateForm(controller);
                });

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    PaginationAppBar(
                      screensTitles: [
                        isAr ? 'الرسائل' : 'Messages',
                        isAr ? 'إنشاء مجموعة' : 'Creating Group',
                      ],
                    ),
                    Expanded(
                      child: Container(
                        padding: EdgeInsets.all(8.sp),
                        decoration: BoxDecoration(
                          color: AppColors.field,
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                        child: Form(
                          key: controller.newGroupFormKey,
                          child: SingleChildScrollView(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                GroupImageEditor(),
                                verticalSpace(16),

                                // ── Group Name EN + AR (order respects locale) ──
                                isAr
                                    ? Row(
                                  spacing: 12.w,
                                  children: [
                                    Expanded(
                                      child: _buildArField(
                                        label: 'اسم المجموعة',
                                        controller: controller
                                            .groupNameArController,
                                        hintText: 'أدخل هنا',
                                        maxLength: 100,
                                        validationLabel: 'اسم المجموعة',
                                        cubit: controller,
                                        langError: _nameArLangError,
                                        height: 36,
                                        isInRow: true,
                                      ),
                                    ),
                                    Expanded(
                                      child: _buildEnField(
                                        label: 'Group Name',
                                        controller: controller
                                            .groupNameController,
                                        hintText: 'Text Here',
                                        maxLength: 100,
                                        validationLabel: 'Group Name',
                                        cubit: controller,
                                        langError: _nameEnLangError,
                                        height: 36,
                                        isInRow: true,
                                      ),
                                    ),
                                  ],
                                )
                                    : Row(
                                  spacing: 12.w,
                                  children: [
                                    Expanded(
                                      child: _buildEnField(
                                        label: 'Group Name',
                                        controller: controller
                                            .groupNameController,
                                        hintText: 'Text Here',
                                        maxLength: 100,
                                        validationLabel: 'Group Name',
                                        cubit: controller,
                                        langError: _nameEnLangError,
                                        height: 36,
                                        showCounter: false,
                                        isInRow: true,
                                      ),
                                    ),
                                    Expanded(
                                      child: _buildArField(
                                        label: 'اسم المجموعة',
                                        controller: controller
                                            .groupNameArController,
                                        hintText: 'أدخل هنا',
                                        maxLength: 100,
                                        validationLabel: 'اسم المجموعة',
                                        cubit: controller,
                                        langError: _nameArLangError,
                                        height: 36,
                                        isInRow: true,
                                      ),
                                    ),
                                  ],
                                ),


                                // ── Description (order respects locale) ──
                                if (isAr) ...[
                                  _buildArField(
                                    label: 'الوصف',
                                    controller:
                                    controller.groupDescriptionArController,
                                    hintText: 'اكتب هنا',
                                    maxLength: 500,
                                    validationLabel: 'الوصف',
                                    cubit: controller,
                                    langError: _descArLangError,
                                    maxLines: 3,
                                    showCounter: true,
                                  ),
                                  verticalSpace(8),
                                  _buildEnField(
                                    label: 'Description',
                                    controller:
                                    controller.groupDescriptionController,
                                    hintText: 'Text Here',
                                    maxLength: 500,
                                    validationLabel: 'Description',
                                    cubit: controller,
                                    langError: _descEnLangError,
                                    maxLines: 3,
                                    showCounter: true,
                                  ),
                                ]
                                else ...[
                                  _buildEnField(
                                    label: 'Description',
                                    controller:
                                    controller.groupDescriptionController,
                                    hintText: 'Text Here',
                                    maxLength: 500,
                                    validationLabel: 'Description',
                                    cubit: controller,
                                    langError: _descEnLangError,
                                    maxLines: 3,
                                    showCounter: true,
                                  ),
                                  verticalSpace(8),
                                  _buildArField(
                                    label: 'الوصف',
                                    controller:
                                    controller.groupDescriptionArController,
                                    hintText: 'اكتب هنا',
                                    maxLength: 500,
                                    validationLabel: 'الوصف',
                                    cubit: controller,
                                    langError: _descArLangError,
                                    maxLines: 3,
                                    showCounter: true,
                                  ),
                                ],

                                verticalSpace(16),

                                // ── Toggles ──────────────────────────────────
                                Row(
                                  spacing: 20.sp,
                                  children: [
                                    Expanded(
                                      child: SwitchButtonTitleSubTitle(
                                        title: isAr ? 'خاص' : 'Private',
                                        subTitle: isAr
                                            ? 'يسمح للمستخدمين بالعرض أو المشاركة بدعوة'
                                            : 'Allows Users To Either View Or Participate By Joining With An Invitation',
                                        value:
                                        controller.isMakePrivateEnabled,
                                        onChanged:
                                        controller.onChangedMakePrivate,
                                      ),
                                    ),
                                    if (isTablet)
                                      Expanded(
                                        child: SwitchButtonTitle(
                                          title: isAr
                                              ? 'الرسائل المختفية'
                                              : 'Disappearing messages',
                                          value: controller
                                              .isDisappearingMessagesEnabled,
                                          onChanged: controller
                                              .onChangedDisappearingMessages,
                                        ),
                                      ),
                                  ],
                                ),
                                verticalSpace(8),
                                Row(
                                  spacing: 20.sp,
                                  children: [
                                    Expanded(
                                      child: SwitchButtonTitleSubTitle(
                                        title: isAr
                                            ? 'المشرفين فقط'
                                            : 'Admin Only',
                                        subTitle: isAr
                                            ? 'فقط المشرفون يمكنهم مشاركة المحتوى'
                                            : 'Only Admins Can Share Content',
                                        value: controller.isAdminEnabled,
                                        onChanged:
                                        controller.onChangedAdmin,
                                      ),
                                    ),
                                    if (isTablet)
                                      Expanded(
                                        child: SwitchButtonTitle(
                                          title: isAr
                                              ? 'كتم الإشعارات'
                                              : 'Mute notifications',
                                          value: controller.isMuteEnabled,
                                          onChanged:
                                          controller.onChangMuteMessages,
                                        ),
                                      ),
                                  ],
                                ),
                                if (!isTablet) ...[
                                  verticalSpace(8),
                                  SwitchButtonTitle(
                                    title: isAr
                                        ? 'الرسائل المختفية'
                                        : 'Disappearing messages',
                                    value: controller
                                        .isDisappearingMessagesEnabled,
                                    onChanged:
                                    controller.onChangedDisappearingMessages,
                                  ),
                                  verticalSpace(8),
                                  SwitchButtonTitle(
                                    title: isAr
                                        ? 'كتم الإشعارات'
                                        : 'Mute notifications',
                                    value: controller.isMuteEnabled,
                                    onChanged:
                                    controller.onChangMuteMessages,
                                  ),
                                ],

                                verticalSpace(16),

                                // ── Add Member ────────────────────────────────
                                Text(
                                  isAr ? 'إضافة عضو' : 'Add Member',
                                  style: isTablet
                                      ? AppTextStyles.font16BlackMediumCairo
                                      : AppTextStyles.font14BlackCairo,
                                ),
                                verticalSpace(8),
                                Row(
                                  children: [
                                    Expanded(
                                      child: AppSearchTextField(

                                        onChanged: (value) {
                                          controller
                                              .searchMembers(value.trim());
                                        },
                                        fillColor: AppColors.background,
                                        controller: searchController,
                                      ),
                                    ),
                                    horizontalSpace(8),
                                    DepartmentDropdown(),
                                  ],
                                ),
                                verticalSpace(6),

                                // ── Selected members chips ────────────────────
                                if (controller.selectedMembers.isNotEmpty)
                                  SingleChildScrollView(
                                    scrollDirection: Axis.horizontal,
                                    child: Row(
                                      children: controller.selectedMembers
                                          .map((member) {
                                        return Padding(
                                          padding: EdgeInsets.symmetric(
                                            horizontal: 5.w),
                                          child: Stack(
                                            alignment: Alignment.topRight,
                                            children: [
                                              ClipRRect(
                                                borderRadius:
                                                BorderRadius.circular(25),
                                                child: CustomSvgImage(
                                                  assetPath:
                                                  "assets/icons_assets/main_icons_assets/assets_male.svg",
                                                  width: 30.w,
                                                  height: 30.h,
                                                  fit: BoxFit.fill,
                                                ),
                                              ),
                                              GestureDetector(
                                                onTap: () => controller
                                                    .removeSelectedMember(
                                                    member),
                                                child: Stack(
                                                  children: [
                                                    const CircleAvatar(
                                                      backgroundColor:
                                                      AppColors.transparent,
                                                      radius: 7,
                                                    ),
                                                    Padding(
                                                      padding:
                                                      const EdgeInsets.only(
                                                        top: 0,
                                                        left: 0.5,
                                                        right: 0),
                                                      child: CircleAvatar(
                                                        radius: 9,
                                                        backgroundColor:
                                                        AppColors.transparent,
                                                        child: Icon(
                                                          Icons.cancel_rounded,
                                                          color:
                                                          AppColors.red,
                                                          size: 22,
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                        );
                                      }).toList(),
                                    ),
                                  ),
                                const SizedBox(height: 10),

                                // ── Members grid ──────────────────────────────
                                controller.filteredMembers.isEmpty
                                    ? Center(
                                  child: Padding(
                                    padding: EdgeInsets.symmetric(
                                      vertical: 24.h),
                                    child: Text(
                                      isAr
                                          ? 'لا يوجد أعضاء'
                                          : 'No members found',
                                      style:
                                      AppTextStyles.font14BlackCairo,
                                    ),
                                  ),
                                )
                                    : GridView.builder(
                                  physics:
                                  const NeverScrollableScrollPhysics(),
                                  shrinkWrap: true,
                                  gridDelegate:
                                  SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: CrossAxisCountHelper
                                        .getCrossAxisCountForDefaultTablet2(
                                        context),
                                    mainAxisExtent: 75.sp,
                                    mainAxisSpacing: 10,
                                    crossAxisSpacing: 10,
                                    childAspectRatio:
                                    ContextExtension(context).isPhone ? 1.5 : 1.2,
                                  ),
                                  itemCount:
                                  controller.filteredMembers.length,
                                  itemBuilder: (context, index) {
                                    final member = controller
                                        .filteredMembers[index];
                                    return PersonStateView(
                                      color: AppColors.background,
                                      person: member,
                                      onTap: () {
                                        controller
                                            .toggleSelection(member);
                                      },
                                    );
                                  },
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),

                    // ── Bottom action buttons ─────────────────────────────────
                    verticalSpace(8),
                    Row(
                      children: [
                        customButton(
                          color: Theme.of(context).brightness == Brightness.light ? AppColors.colorGrey : AppColors.colorGreyDark,
                          title: isAr ? 'تجاهل' : 'Discard',
                          textStyle: AppTextStyles.font14BlackCairoMedium.copyWith(
                            color: Theme.of(context).brightness == Brightness.light ? AppColors.colorBlack : AppColors.colorWhite
                          ),
                          function: () => Navigator.of(context).pop(),
                        ),
                        const Spacer(),
                        Opacity(
                          opacity: _isFormValid ? 1.0 : 0.5,
                          child: IgnorePointer(
                            ignoring: !_isFormValid,
                            child: customButton(
                              title: isAr ? 'إنشاء' : 'Create',
                              function: () {
                                if (_isFormValid &&
                                    controller
                                        .selectedMembers.isNotEmpty) {
                                  GetDialogHelper.generalDialog(
                                    context: context,
                                    child: DefaultDialog(
                                      width: 500.w,
                                      title: isAr
                                          ? 'إنشاء مجموعة جديدة'
                                          : 'Creating New Group',
                                      subTitle: isAr
                                          ? 'هل أنت متأكد من إنشاء هذه المجموعة؟'
                                          : 'Are You Sure You Want To Create This Group?',
                                      autoClose: false,
                                      lottieAsset:
                                      'assets/lottie_assets/main_lottie_assets/assets_lottie_successful.json',
                                      showButtons: true,
                                      onConfirm: () {
                                        controller.createGroup(context);
                                      },
                                    ),
                                  );
                                }
                              },
                                   ),
                          ),
                        ),
                      ],
                    ),
                    verticalSpace(16),
                  ],
                );
              },
            ),
          ),
      ),
    );
  }
}

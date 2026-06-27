// ignore_for_file: must_be_immutable, prefer_const_declarations, unused_local_variable, deprecated_member_use, duplicate_ignore, no_leading_underscores_for_local_identifiers, unrelated_type_equality_checks, sdk_version_since, use_build_context_synchronously


import 'dart:io';
import 'package:demo_app/core/custom/2-custom_textfield.dart';
import 'package:flutter/material.dart';
import 'package:demo_app/features/settings/core_widgets/main_widget/custom_svg.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';


import 'package:demo_app/core/theme/app_font_size.dart';
// REMOVED_MODULE: import 'package:demo_app/features/external/inventory_module/core/text_field.dart';
import 'package:demo_app/core/theme/app_colors.dart';
// REMOVED_MODULE: import 'package:demo_app/features/external/knowledge_hub_module/core/custom_validated_text_field_master.dart';
// REMOVED_MODULE: import 'package:demo_app/features/external/services_mangment_module/core/new_theme.dart';
import 'package:demo_app/core/helper/main_helper/format_helper.dart';
import '../../../../../../generated/l10n.dart';
import '../../../controller/settings_controller.dart';
import '../settings_header.dart';

class Skills extends StatefulWidget {
  Skills({super.key});

  @override
  State<Skills> createState() => _SkillsState();
}

class _SkillsState extends State<Skills> {
  SettingsController settingsController = Get.find();

  @override
  void initState() {
    super.initState();
    print("🟢 ========== SKILLS WIDGET INIT ==========");
    print("🟢 Total skills count: ${settingsController.socialController.skillsControllers.length}");

    // Print all existing skills
    for (int i = 0; i < settingsController.socialController.skillsControllers.length; i++) {
      print("🟢 Skill [$i]: ${settingsController.socialController.skillsControllers[i].text}");
    }
    print("🟢 ==========================================");
  }

  // ✅ DELETE SKILL FUNCTION - Using controller's method
  void _deleteSkill(int index) {
    print("🔴 ========== DELETE SKILL TRIGGERED ==========");
    print("🔴 Deleting skill at index: $index");
    print("🔴 Current skills count BEFORE delete: ${settingsController.socialController.skillsControllers.length}");
    print("🔴 Skill to delete: ${settingsController.socialController.skillsControllers[index].text}");

    setState(() {
      // ✅ USE CONTROLLER'S REMOVE METHOD
      settingsController.socialController.removeSkillField(index);

      print("🔴 Skills count AFTER delete: ${settingsController.socialController.skillsControllers.length}");
      print("🔴 Remaining skills:");
      for (int i = 0; i < settingsController.socialController.skillsControllers.length; i++) {
        print("🔴   [$i]: ${settingsController.socialController.skillsControllers[i].text}");
      }
    });

    print("🔴 ==============================================");
  }

  // ✅ ADD NEW SKILL FUNCTION - Using controller's method
  void _addNewSkill() {
    print("🟡 ========== ADD NEW SKILL TRIGGERED ==========");
    print("🟡 Current skills count BEFORE add: ${settingsController.socialController.skillsControllers.length}");

    setState(() {
      // ✅ USE CONTROLLER'S ADD METHOD
      settingsController.socialController.addSkillField();

      print("🟡 Skills count AFTER add: ${settingsController.socialController.skillsControllers.length}");
      print("🟡 New empty skill added at index: ${settingsController.socialController.skillsControllers.length - 1}");
    });

    print("🟡 ===============================================");
  }

  @override
  Widget build(BuildContext context) {
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';
    bool isTablet = MediaQuery.of(context).size.width > 600;
    bool isDesktop = Platform.isLinux || Platform.isMacOS || Platform.isWindows;
    bool isPortrait = MediaQuery.of(context).orientation == Orientation.portrait;
    var lightMode = Theme.of(context).brightness == Brightness.light;
    var isMobile = context.isPhone;

    print("🔵 ========== SKILLS WIDGET BUILD ==========");
    print("🔵 Building Skills widget with ${settingsController.socialController.skillsControllers.length} skills");

    return Container(
      decoration: !isTablet
          ? BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: AppColors.card,
      )
          : null,
      padding: EdgeInsets.only(
        top: 15.sp,
        right: 0.sp,
        left: 0.sp,
        bottom: isMobile ? 15.sp : 0.sp,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ✅ HEADER WITH SVG ICON
          SettingsHeader(
            imagePath: 'assets/new_scalse.svg',
            text: FormatHelper.capitalize('Skills'.tr),
          ),

          SizedBox(height: 10.sp),

          // ✅ LIST OF SKILLS WITH DELETE BUTTONS
          Container(
            width: 270.w,
            child: ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: settingsController.socialController.skillsControllers.length,
              separatorBuilder: (context, index) {
                print("🔹 Building separator after skill $index");
                return SizedBox(height: 10.sp);
              },
              itemBuilder: (context, index) {
                print("🔹 Building skill field at index: $index");
                print("🔹 Skill value: ${settingsController.socialController.skillsControllers[index].text}");

                return Row(
                  children: [
                    // ✅ SKILL TEXT FIELD
                    Expanded(
                      child: CustomTextField(
                        hint: FormatHelper.capitalize(S.of(context).enterSkill),
                        controller: settingsController.socialController.skillsControllers[index],
                        maxLines: 1,
                        maxLength: 100,
                        enabled: true,
                        textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
                        textAlign: TextAlign.start,
                        onChanged: (value) {
                          print("✏️ Skill [$index] changed to: $value");

                          // ✅ Update the skillss list and skillsFields
                          if (index < settingsController.socialController.skillss.length) {
                            settingsController.socialController.skillss[index] = value.trim();
                          }

                          // Update skillsFields if it exists
                          if (index < settingsController.socialController.skillsFields.length) {
                            settingsController.socialController.skillsFields[index]['skillName']?.text = value.trim();
                          }

                          settingsController.socialController.changeSkill = true;
                          setState(() {});
                        },
                        fillColor: lightMode
                            ? const Color(0xFFF6F6F6)
                            : AppColors.colorBlack,
                        label: '',
                      ),
                    ),

                    SizedBox(width: 8.sp),

                    // ✅ DELETE BUTTON (Show only if more than 1 skill)
                    if (settingsController.socialController.skillsControllers.length > 1)
                      InkWell(
                        onTap: () {
                          print("🗑️ Delete button clicked for skill $index");
                          _deleteSkill(index);
                        },
                        child: Container(
                          padding: EdgeInsets.all(6.sp),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(4.r),
                          ),
                          child: CustomSvg(
                            assetPath: "assets/removed.svg",
                            width: 15.sp,
                            fit: BoxFit.fill,
                            height: 15.sp,
                          )
                        ),
                      ),
                  ],
                );
              },
            ),
          ),

          SizedBox(height: 10.sp),

          // ✅ BLACK "MORE" BUTTON
          GestureDetector(
            onTap: () {
              print("➕ Black More button clicked!");
              _addNewSkill();
            },
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 20.sp, vertical: 10.sp),
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(4.r),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.add,
                    color: Colors.white,
                    size: 18.sp,
                  ),
                  SizedBox(width: 8.sp),
                  Text(
                    S.of(context).more,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    print("🔴 ========== SKILLS WIDGET DISPOSE ==========");
    print("🔴 Disposing Skills widget");
    print("🔴 ============================================");
    super.dispose();
  }
}
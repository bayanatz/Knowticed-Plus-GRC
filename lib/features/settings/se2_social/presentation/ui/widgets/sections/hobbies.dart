// ignore_for_file: must_be_immutable, prefer_const_declarations, unused_local_variable, deprecated_member_use, duplicate_ignore, no_leading_underscores_for_local_identifiers, unrelated_type_equality_checks, sdk_version_since, use_build_context_synchronously


import 'dart:io';
import 'package:grc_module/core/custom/2-custom_textfield.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:grc_module/core/theme/haptic_controller.dart';


import 'package:grc_module/core/theme/app_font_size.dart';
// REMOVED_MODULE: import 'package:grc_module/core/helper/inventory_module/core/text_field.dart';
import 'package:grc_module/core/theme/app_colors.dart';
// REMOVED_MODULE: import 'package:grc_module/core/helper/knowledge_hub_module/core/custom_validated_text_field_master.dart';
// REMOVED_MODULE: import 'package:grc_module/features/external/services_mangment_module/core/new_theme.dart';
import 'package:grc_module/core/helper/main_helper/format_title.dart';
import 'package:grc_module/generated/l10n.dart';
import 'package:grc_module/features/settings/main_controller/presentation/controller/settings_controller.dart';
import 'package:grc_module/features/settings/main_controller/presentation/ui/widgets/shared/settings_header.dart';

import 'package:grc_module/core/custom/32-custom_svg.dart';
import 'package:grc_module/core/extension/context_extensions.dart';
class Hobbies extends StatefulWidget {
  Hobbies({super.key});

  @override
  State<Hobbies> createState() => _HobbiesState();
}

class _HobbiesState extends State<Hobbies> {
  SettingsController settingsController = Get.find();
  final HapticController hapticController = Get.find<HapticController>();

  @override
  void initState() {
    super.initState();
    print("🟢 ========== HOBBIES WIDGET INIT ==========");
    print("🟢 Total hobbies count: ${settingsController.socialController.hobbiesControllers.length}");

    // Print all existing hobbies
    for (int i = 0; i < settingsController.socialController.hobbiesControllers.length; i++) {
      print("🟢 Hobby [$i]: ${settingsController.socialController.hobbiesControllers[i].text}");
    }
    print("🟢 ==========================================");
  }

  // ✅ DELETE HOBBY FUNCTION - Using controller's method
  void _deleteHobby(int index) {
    print("🔴 ========== DELETE HOBBY TRIGGERED ==========");
    print("🔴 Deleting hobby at index: $index");
    print("🔴 Current hobbies count BEFORE delete: ${settingsController.socialController.hobbiesControllers.length}");
    print("🔴 Hobby to delete: ${settingsController.socialController.hobbiesControllers[index].text}");

    setState(() {
      // ✅ USE CONTROLLER'S REMOVE METHOD
      settingsController.socialController.removeHobbyField(index);

      print("🔴 Hobbies count AFTER delete: ${settingsController.socialController.hobbiesControllers.length}");
      print("🔴 Remaining hobbies:");
      for (int i = 0; i < settingsController.socialController.hobbiesControllers.length; i++) {
        print("🔴   [$i]: ${settingsController.socialController.hobbiesControllers[i].text}");
      }
    });

    print("🔴 ==============================================");
  }

  // ✅ ADD NEW HOBBY FUNCTION - Using controller's method
  void _addNewHobby() {
    print("🟡 ========== ADD NEW HOBBY TRIGGERED ==========");
    print("🟡 Current hobbies count BEFORE add: ${settingsController.socialController.hobbiesControllers.length}");

    // Trigger haptic feedback
    hapticController.triggerHapticFeedback(
      vibration: VibrateType.lightImpact,
      hapticFeedback: HapticFeedback.lightImpact,
    );

    setState(() {
      // ✅ USE CONTROLLER'S ADD METHOD
      settingsController.socialController.addHobbyField();

      print("🟡 Hobbies count AFTER add: ${settingsController.socialController.hobbiesControllers.length}");
      print("🟡 New empty hobby added at index: ${settingsController.socialController.hobbiesControllers.length - 1}");
    });

    print("🟡 ===============================================");
  }

  // ✅ UPDATE HOBBY FUNCTION
  void _updateHobby(int index, String value) {
    try {
      print("✏️ ========== UPDATE HOBBY ==========");
      print("✏️ Updating hobby at index $index");
      print("✏️ New value: $value");

      // Ensure the hobbiess list is large enough
      while (settingsController.socialController.hobbiess.length <= index) {
        settingsController.socialController.hobbiess.add('');
      }

      settingsController.socialController.hobbiess[index] = value.trim();
      settingsController.socialController.changeHobby = true;

      print("✏️ All hobbies: ${settingsController.socialController.hobbiess}");
      print("✏️ ====================================");
    } catch (e) {
      print("❌ Error updating hobby: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';
    bool isTablet = MediaQuery.of(context).size.width > 600;
    bool isDesktop = Platform.isLinux || Platform.isMacOS || Platform.isWindows;
    bool isPortrait = MediaQuery.of(context).orientation == Orientation.portrait;
    var lightMode = Theme.of(context).brightness == Brightness.light;
    var isMobile = ContextExtension(context).isPhone;

    print("🔵 ========== HOBBIES WIDGET BUILD ==========");
    print("🔵 Building Hobbies widget with ${settingsController.socialController.hobbiesControllers.length} hobbies");

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
            imagePath: 'assets/icons_assets/settings_assets/hobbies_interests.svg',
            text: FormatHelper.capitalize(S.of(context).hobbies),
          ),

          SizedBox(height: 10.sp),

          // ✅ LIST OF HOBBIES WITH DELETE BUTTONS
          Container(
            width: 270.w,
            child: ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: settingsController.socialController.hobbiesControllers.length,
              separatorBuilder: (context, index) {
                print("🔹 Building separator after hobby $index");
                return SizedBox(height: 10.sp);
              },
              itemBuilder: (context, index) {
                print("🔹 Building hobby field at index: $index");
                print("🔹 Hobby value: ${settingsController.socialController.hobbiesControllers[index].text}");

                return Row(
                  children: [
                    // ✅ HOBBY TEXT FIELD
                    Expanded(
                      child: CustomTextField(
                        hint: FormatHelper.capitalize(
                          isArabic ? 'اكتب الهواية' : S.of(context).enterHobby,
                        ),
                        controller: settingsController.socialController.hobbiesControllers[index],
                        maxLines: 1,
                        maxLength: 100,
                        enabled: true,
                        textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
                        textAlign: TextAlign.start,
                        onChanged: (value) {
                          print("✏️ Hobby [$index] changed to: $value");
                          _updateHobby(index, value);
                          setState(() {});
                        },
                        fillColor: lightMode
                            ? const Color(0xFFF6F6F6)
                            : AppColors.colorBlack,
                        label: '',
                      ),
                    ),

                    SizedBox(width: 8.sp),

                    // ✅ DELETE BUTTON (Show only if more than 1 hobby)
                    if (settingsController.socialController.hobbiesControllers.length > 1)
                      InkWell(
                        onTap: () {
                          print("🗑️ Delete button clicked for hobby $index");
                          _deleteHobby(index);
                        },
                        child: Container(
                          padding: EdgeInsets.all(6.sp),
                          decoration: BoxDecoration(

                            borderRadius: BorderRadius.circular(4.r),
                          ),
                          child: CustomSvgImage(
                            assetPath: "assets/icons_assets/main_icons_assets/document_remove_badge_red.svg",
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
              _addNewHobby();
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
    print("🔴 ========== HOBBIES WIDGET DISPOSE ==========");
    print("🔴 Disposing Hobbies widget");
    print("🔴 ============================================");
    super.dispose();
  }
}
/// Module: settings/main_controller
///
///*************************** FILE INFO ****************************///
/// File Name: settings_layout.dart
/// Description: The settings menu, and — on tablet — the detail pane beside it.
/// Author: Amr Mesbah
/// Created at: 10/11/2024
/// Updated: 11/8/2026 - CR-SKEL-SEMAIN-N16: the four inline MaterialPageRoutes
///          are gone; destinations are named routes resolved through
///          `AppPages`. Unused locals and the unused onboarding import removed.
/// Updated: 31/8/2026 - Row order now follows the Figma settings frame: the
///          "App Customization" card was folded into the card above it, and a
///          Notification switch was added. Haptic Feedback, Watermark and
///          Comments and Feedbacks became permission-gated, so nine of the
///          eleven SettingsPermissions now hide a row here.
/// Updated: 2/9/2026 - The menu now matches the Figma settings frame exactly,
///          in both grouping and row text order. Three cards instead of two:
///          (1) Personal Information, Health Insurance, Social Information,
///          Requests; (2) Company Information, Home Layout, Branding and Theme,
///          WaterMark; (3) Language, Comments and Feedbacks, About This App,
///          Privacy Statement, Terms and Conditions. No row was added or
///          removed and every index, route and permission gate is unchanged —
///          only position. The cards are separated by 7.h so the grouping is
///          visible rather than reading as one flat list.
/// Updated: 9/10/2026 - Health Insurance and Social Information re-enabled
///          (hidden since 28/9/2026). Social follows the role's
///          Share_Social_Information switch; Health is always listed.
library;

import 'package:knowticed_plus/core/custom/helpers/custom_svg.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:flutter/material.dart';
import 'package:knowticed_plus/core/custom/helpers/normalized_stroke_svg.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:knowticed_plus/core/helper/access/main_core_employee_controller.dart';
import 'package:knowticed_plus/core/helper/biometric_controller.dart';
import 'package:knowticed_plus/core/helper/device_policy_controller.dart';
import 'package:knowticed_plus/features/settings/helpers/notification_controller.dart';
import 'package:knowticed_plus/core/helper/format_title.dart';

// ADDED 8/9/2026 for StyleText, used by the mobile page title below.
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/core/theme/theme_controller.dart';
import 'package:knowticed_plus/features/settings/presentation/ui/widgets/restart_widget.dart';
import 'package:knowticed_plus/features/settings/presentation/controller/settings_controller.dart';
import 'package:knowticed_plus/generated/l10n.dart';

import 'package:knowticed_plus/core/theme/haptic_controller.dart';
import 'package:knowticed_plus/features/settings/presentation/ui/widgets/custom_cards.dart';
import 'package:knowticed_plus/features/settings/presentation/ui/widgets/restricted_location_countries.dart';
import 'package:knowticed_plus/features/settings/se7_app_info/presentation/ui/pages/language_screen.dart';
import 'package:knowticed_plus/features/settings/se7_app_info/presentation/ui/pages/terms_and_conditions.dart';
import 'package:knowticed_plus/features/settings/presentation/ui/widgets/settings_appbar.dart';
import 'package:knowticed_plus/features/settings/se3_company/presentation/ui/pages/employee_branding_screen.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/helper/access/modules_enum.dart';
import 'package:knowticed_plus/features/roles/r1_role_management/domain/enums/settings/settings_permissions.dart';
import 'package:knowticed_plus/features/roles/r1_role_management/domain/enums/settings/settings_permissions_sections.dart';
// ADDED 9/10/2026 — gates the re-enabled Social Information row.
import 'package:knowticed_plus/features/roles/r1_role_management/domain/enums/settings/social_permissions.dart';
import 'package:knowticed_plus/features/settings/se3_company/presentation/ui/widgets/sections/company_info.dart';
import 'package:knowticed_plus/features/settings/se7_app_info/presentation/ui/pages/about_this_app_screen.dart';
import 'package:knowticed_plus/features/settings/se7_app_info/presentation/ui/pages/comments_and_feedback_screen.dart';
import 'package:knowticed_plus/features/settings/se7_app_info/presentation/ui/pages/privacy_statement.dart';
import 'package:knowticed_plus/features/settings/se6_requests/presentation/ui/pages/request_page.dart';
import 'package:knowticed_plus/features/settings/se2_social/presentation/ui/pages/social_screen.dart';
import 'package:knowticed_plus/features/settings/se3_company/presentation/ui/pages/company_info_screen.dart';
// REMOVED 31/8/2026 — watermark_screen.dart import. WatermarkScreen is no
// longer built inline here; it is reached only through Routes.settingsWatermark.
import 'package:knowticed_plus/features/settings/se8_watermark/presentation/ui/widgets/watermark_layer.dart';
import 'package:knowticed_plus/features/settings/se1_profile/presentation/ui/pages/personal_info_screen.dart';
import 'package:knowticed_plus/features/settings/se4_health_insurance/presentation/ui/pages/settings_health_insurance.dart';
import 'package:knowticed_plus/core/extensions/context_extensions.dart';
import 'package:knowticed_plus/core/routes/app_routes.dart';
import 'package:knowticed_plus/core/routes/get_pages.dart';

part '../widgets/settings_layout/settings_layout_builders.dart';
part '../widgets/settings_layout/settings_layout_sections.dart';

class SettingsLayout extends StatefulWidget {
  const SettingsLayout({super.key});

  @override
  State<SettingsLayout> createState() => _SettingsLayoutState();
}

class _SettingsLayoutState extends State<SettingsLayout> {
  final SettingsController settingsController = Get.find();

  final ThemeController themeController = Get.find();

  /// Function Name: [_open]
  ///
  /// Purpose: Push a settings destination by name.
  ///
  /// Parameters:
  /// - [routeName]: a `Routes.settingsX` constant.
  ///
  /// The page builders live in `core/network/message_module/routes` (§14).
  /// This also works inside the tablet pane's nested Navigator, which resolves
  /// the same table via `AppPages.maybeRoute`.
  void _open(BuildContext context, String routeName) {
    Navigator.of(context).push(AppPages.route(routeName));
  }

  String _getEmployeeName() {
    final mainCoreEmployeeController = Get.find<MainCoreEmployeeController>();

    if (mainCoreEmployeeController.employeeEntity == null) return '';

    final isEnglish = Get.locale.toString().contains('en');

    final employee = mainCoreEmployeeController.employeeEntity;

    // In Arabic an account with no Arabic name used to show NO name here (the
    // profile block beside the avatar was blank). Fall back to the English
    // name, as the top header does.
    String pick(String? preferred, String? other) =>
        (preferred?.trim().isNotEmpty ?? false) ? preferred! : (other ?? '');

    final firstName = isEnglish
        ? pick(employee?.firstName, employee?.firstNameInArabic).capitalize
        : pick(employee?.firstNameInArabic, employee?.firstName).capitalize;

    final lastName = isEnglish
        ? pick(employee?.lastName, employee?.lastNameInArabic).capitalize
        : pick(employee?.lastNameInArabic, employee?.lastName).capitalize;

    return "$firstName $lastName".trim();
  }

  /// FIXED 13/8/2026: this build read `settingsController.selectedContainerIndex`
  /// (for the row highlight, and at the bottom of this file to choose the
  /// content pane) but subscribed to nothing, so the pane never changed when a
  /// menu row was tapped on tablet/desktop. `CustomCard` calls
  /// `SettingsScreenState.setSelectedContainerIndex`, whose `setState` rebuilds
  /// *that* State — not this one, which sits inside the nested Navigator's
  /// route and is therefore not on its rebuild path.
  ///
  /// The cubit now emits on selection (see `SettingsController`), and this
  /// BlocBuilder is what turns that emit into a rebuild. The body is unchanged
  /// and lives in [_buildContent].
  @override
  Widget build(BuildContext context) {
    // ADDED 25/8/2026 — the settings shell is stamped as a whole, which covers
    // the destination list AND every right-hand panel embedded in it on
    // desktop and tablet. The pushed routes are stamped separately, in
    // get_pages.dart. Between those two places, every settings destination is
    // covered without wrapping any of them individually.
    // `module: Modules.settings` ADDED 2/9/2026, alongside the Settings tile in
    // the watermark module grid. Without it this layer stamps unconditionally
    // and that tile controls nothing.
    return WatermarkLayer(
      module: Modules.settings,
      child: BlocBuilder<SettingsController, SettingsState>(
        bloc: settingsController,
        builder: (BuildContext context, SettingsState state) =>
            _buildContent(context),
      ),
    );
  }
}

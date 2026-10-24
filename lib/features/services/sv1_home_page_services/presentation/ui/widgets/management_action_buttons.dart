/// Module: services / sv1_home_page_services / presentation / ui / widgets
///
///*************************** FILE INFO ****************************///
/// File Name: management_action_buttons.dart
/// Purpose: Search field + Create / Bulk-upload action buttons row for the
///          services management screen (permission-aware). Extracted from
///          ManagementWidget.
/// Author: Amr Mesbah
/// Created At: 18/10/2026
library;

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:knowticed_plus/core/custom/dialogs/custom_pop_up.dart';
import 'package:knowticed_plus/features/services/helpers/services_module_access.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/custom/inputs/custom_search_widget_custom.dart';
import 'package:knowticed_plus/core/custom/navigation/custom_navigate.dart';
import 'package:knowticed_plus/generated/l10n.dart';
import 'package:knowticed_plus/features/services/sv4_bulk_upload_services/presentation/ui/pages/create_new_services_toggle.dart';
import 'package:knowticed_plus/features/services/sv4_bulk_upload_services/presentation/ui/pages/upload_file_toggle.dart';
import 'package:knowticed_plus/features/services/sv5_service_details/presentation/ui/widgets/info_text.dart';

class ManagementActionButtons extends StatelessWidget {
  final bool isMobile;
  final TextEditingController searchController;

  const ManagementActionButtons({
    super.key,
    required this.isMobile,
    required this.searchController,
  });

  @override
  Widget build(BuildContext context) {
    // The popup is two independently-gated actions behind one button, so the
    // button itself only exists while the role may reach at least one of them —
    // otherwise it opens onto an empty menu.
    final bool canCreate = ServicesModuleAccess.canCreateService;
    final bool canBulkUpload = ServicesModuleAccess.canBulkUpload;

    return Row(
      children: [
        AppSearchTextField(controller: searchController, onChanged: (_) {}),
        if (canCreate || canBulkUpload) ...[
          SizedBox(width: 10.sp),

          // Create and Bulk Upload (Popup Menu)
          _buildPopupMenuButton(
            context,
            canCreate: canCreate,
            canBulkUpload: canBulkUpload,
          ),
        ],
      ],
    );
  }

  Widget _buildPopupMenuButton(
    BuildContext context, {
    required bool canCreate,
    required bool canBulkUpload,
  }) {
    return CustomPopupMenuButton(
      height: 38,
      width: isMobile ? 38 : (isTabletLandscape(context) ? 175 : 175),
      title: isMobile ? "" : S.of(context).createService,
      iconPath:
          "assets/icons_assets/main_icons_assets/ic_comms_customer_service.svg",
      backgroundColor: AppColors.primary,
      iconColor: AppColors.textButton,
      onSelected: (value) {
        // Second gate: `options` already hides what the role may not do, but a
        // value can only arrive here from an option we drew, and re-checking
        // costs nothing.
        if (value == 'addServices' && canCreate) {
          navigateTo(context, CreateNewServicesLayout());
        } else if (value == 'bulkUpload' && canBulkUpload) {
          navigateTo(context, ToggleUploadFile());
        }
      },
      options: [
        if (canCreate)
          PopupOption(value: 'addServices', label: S.of(context).addService),
        if (canBulkUpload)
          PopupOption(value: 'bulkUpload', label: S.of(context).bulkUpload),
      ],
    );
  }
}

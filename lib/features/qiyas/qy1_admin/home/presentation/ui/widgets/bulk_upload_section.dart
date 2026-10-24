import 'package:flutter/material.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:knowticed_plus/features/qiyas/qy1_admin/bulk_upload/presentation/controller/qiyas_bulk_visions_controller.dart';
import 'package:knowticed_plus/core/helper/access/main_core_employee_controller.dart';
import 'package:knowticed_plus/core/helper/access/modules_enum.dart';
import 'package:knowticed_plus/features/roles/r1_role_management/domain/enums/qiyas/qiyas_permissions.dart';
import 'package:knowticed_plus/features/roles/r1_role_management/domain/enums/qiyas/qiyas_permissions_sections.dart';
import 'package:page_transition/page_transition.dart';

import 'package:knowticed_plus/features/qiyas/helpers/data_grc/feature/module_owner_grc/core/enums/csv_status.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/features/qiyas/qy1_admin/bulk_upload/presentation/ui/tablet/qiyas_bulk_visions.dart';
import 'package:knowticed_plus/core/custom/buttons/custom_button_with_svg.dart';

class BulkUploadSection extends StatelessWidget {
  BulkUploadSection({super.key});
  final MainCoreEmployeeController mainCoreEmployeeController = Get.find();
  final QiyasBulkVisionsController qiyasBulkVisionsController = Get.find();
  @override
  Widget build(BuildContext context) {
    if (mainCoreEmployeeController.isHasPermission(
        module: Modules.qiyas,
        permission: QiyasPermissions.bulkUpload,
        section: QiyasPermissionsSections.qiyasPermissions)) {
      return Container(
        height: 300.h,
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SvgPicture.asset(
                  'assets/icons_assets/main_icons_assets/ic_cloud_upload.svg'),
              const SizedBox(height: 25),
              Directionality(
                textDirection: TextDirection.ltr,
                // Sizes to its label (min 215) — the fixed 215 overflowed by
                // ~23 px with the Arabic label (17/10/2026).
                child: ConstrainedBox(
                  constraints: const BoxConstraints(minWidth: 215),
                  child: IntrinsicWidth(
                    child: customButtonWithSvg(
                      title: "رفع المناظير و المحاور",
                      image:
                          "assets/icons_assets/qiyas_assets/ic_action_bulk_upload.svg",
                      function: () {
                        qiyasBulkVisionsController.pickFile().then((_) {
                          if (!context.mounted) return;
                          Navigator.push(
                            context,
                            PageTransition(
                                type: PageTransitionType.fade,
                                child: const QiyasBulkVisions(
                                    status: CsvStatus.policy)),
                          );
                        });
                      },
                      color: AppColors.primary,
                      colorBorder: AppColors.transparent,
                      widthImage: 20.sp,
                      heightImage: 20.sp,
                      svgColor: AppColors.textButton,
                      textStyle: StyleText.fontSize16Weight400.copyWith(
                          color: AppColors.textButton,
                          fontWeight: FontWeight.w400),
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
      );
    }
    return Container();
  }
}

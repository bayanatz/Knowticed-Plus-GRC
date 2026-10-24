/// Module: services / sv5_service_details / presentation / ui / widgets
///
///*************************** FILE INFO ****************************///
/// File Name: service_header_widget.dart
/// Purpose: Service header widget — declares ServiceHeaderWidget.
/// Author: Amr Mesbah
/// Created At: 18/10/2026
library;

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:knowticed_plus/core/custom/feedback/circle_progress.dart';
import 'package:knowticed_plus/features/services/data/models/services_history_model.dart';
import 'package:knowticed_plus/features/services/presentation/controller/services_manager_cubit.dart';
import 'package:knowticed_plus/features/services/sv1_home_page_services/presentation/ui/pages/home_page_services_toggle.dart';
import 'package:knowticed_plus/features/services/sv5_service_details/presentation/ui/widgets/service_details_dialogs.dart';
import 'package:knowticed_plus/generated/l10n.dart';

import 'package:knowticed_plus/core/helper/format_title.dart';

import 'package:knowticed_plus/core/custom/navigation/custom_navigate.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/custom/buttons/custom_delete_icon.dart';
import 'package:knowticed_plus/core/custom/buttons/custom_edit_icon.dart';
import 'package:knowticed_plus/features/services/helpers/services_module_access.dart';

import 'package:knowticed_plus/core/theme/app_theme.dart';

import 'package:knowticed_plus/features/services/sv4_bulk_upload_services/presentation/ui/pages/create_new_services_toggle.dart';
import 'package:knowticed_plus/core/extensions/context_extensions.dart';

import 'package:knowticed_plus/features/services/helpers/constants/services_lottie.dart';

class ServiceHeaderWidget extends StatelessWidget {
  final ServicesHistoryModel createServicesModel;

  const ServiceHeaderWidget({required this.createServicesModel, super.key});

  @override
  Widget build(BuildContext context) {
    final isMobile = ContextExtension(context).isPhone;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Padding(
          padding: EdgeInsets.only(top: 20.h),
          child: Text(
            FormatHelper.capitalize(S.of(context).serviceDetails),
            style: isMobile
                ? StyleText.fontSize16Weight600.copyWith(
                    color: AppColors.blackButton,
                  )
                : StyleText.fontSize20Weight600.copyWith(
                    color: AppColors.blackButton,
                  ),
          ),
        ),
        const Spacer(),

        // Edit Button
        if (ServicesModuleAccess.canEditService)
          CustomEditIcon(
            color: AppColors.primary,
            borderColor: AppColors.transparent,
            svgColor: AppColors.textButton,
            title: isMobile ? "" : FormatHelper.capitalize(S.of(context).Edit),
            textStyle: StyleText.fontSize16Weight500.copyWith(
              color: AppColors.textButton,
            ),
            onTap: () async {
              // W01: no try/catch in a StatelessWidget build callback (§11.2);
              // the cubit owns error handling for the load.
              // SVC-HOME-09: the debug routine that read every document in
              // CreateServices on each tap is gone; one read of this service.
              // The cubit is captured before the await, so no context is
              // used across it.
              final managerCubit = ServicesManagerCubit.get(context);
              showLoadingIndicator();
              final model = await managerCubit.getDocToEdit(
                createServicesModel.currentId,
              );
              hideLoadingIndicator();

              if (model != null) {
                if (!context.mounted) return;
                navigateTo(
                  context,
                  CreateNewServicesLayout(
                    editingModel: model,
                    docId: model.currentId,
                  ),
                );
              } else {
                if (!context.mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(S.of(context).failedToLoadServiceData),
                    duration: Duration(seconds: 3),
                  ),
                );
              }
            },
          ),

        // Gutter belongs to the pair, not to the page — with Edit hidden it
        // would otherwise leave a 15.w hole against the Delete button.
        if (ServicesModuleAccess.canEditService &&
            ServicesModuleAccess.canDeleteService)
          SizedBox(width: 15.w),

        // Delete Button
        if (ServicesModuleAccess.canDeleteService)
          CustomDeleteIcon(
            color: AppColors.red,
            borderColor: AppColors.transparent,
            svgColor: AppColors.white,
            title:
                isMobile ? "" : FormatHelper.capitalize(S.of(context).Delete),
            textStyle: StyleText.fontSize16Weight500.copyWith(
              color: AppColors.white,
            ),
            onTap: () {
              showConfirmationDialogServicesDetails(
                lottiePath: ServicesLottie.warning,
                title: S.of(context).deleteServices,
                message: S.of(context).AreYouSureDeleteThisService,
                onConfirm: () async {
                  // SVC-HOME-21: success is shown only when the delete
                  // really happened; the cubit reloads the list once.
                  final deleted = await ServicesManagerCubit.get(context)
                      .deleteService(createServicesModel.currentId);
                  if (!context.mounted) return;

                  if (!deleted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(S.of(context).svcServiceDeleteFailed),
                        backgroundColor: AppColors.red,
                        duration: const Duration(seconds: 3),
                      ),
                    );
                    return;
                  }

                  await showSuccessDialogServicesDetails(
                    lottiePath: ServicesLottie.approved,
                    subtitle: S.of(context).servicesDeleteDone,
                    title: S.of(context).deleteServices,
                    context: context,
                  );
                  if (!context.mounted) return;
                  // Replace the details page: the deleted service must not
                  // stay in the back stack.
                  Navigator.of(context)
                      .pushReplacement(appSlideRoute(LayoutScreenServices()));
                },
                context: context,
              );
            },
          ),
      ],
    );
  }
}

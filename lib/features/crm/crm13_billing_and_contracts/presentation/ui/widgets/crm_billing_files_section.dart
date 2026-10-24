// ****************** FILE INFO ******************
// File Name: crm_billing_files_section.dart
// Purpose: Reusable Files upload section for Billing & Contracts details and edit screens
// Author: Mohand Adel
// Created At: 06/10/2026

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:knowticed_plus/core/constants/app_assets.dart';
import 'package:knowticed_plus/core/custom/cards/custom_uploaded_document_card.dart';
import 'package:knowticed_plus/core/custom/layout/custom_responsive_fields.dart';
import 'package:knowticed_plus/core/custom/buttons/custom_button_with_svg.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/features/crm/presentation/ui/widgets/crm_section_card.dart';
import 'package:knowticed_plus/generated/l10n.dart';

class CrmBillingFilesSection extends StatelessWidget {
  final VoidCallback? onLogoUpload;
  final VoidCallback? onDigitalSealUpload;
  final VoidCallback? onWatermarkUpload;
  final VoidCallback? onSignatureUpload;
  final VoidCallback? onLogoRemove;
  final VoidCallback? onDigitalSealRemove;
  final VoidCallback? onWatermarkRemove;
  final VoidCallback? onSignatureRemove;
  final String logoUrl;
  final String digitalSealUrl;
  final String watermarkUrl;
  final String signatureUrl;

  const CrmBillingFilesSection({
    super.key,
    this.onLogoUpload,
    this.onDigitalSealUpload,
    this.onWatermarkUpload,
    this.onSignatureUpload,
    this.onLogoRemove,
    this.onDigitalSealRemove,
    this.onWatermarkRemove,
    this.onSignatureRemove,
    this.logoUrl = '',
    this.digitalSealUrl = '',
    this.watermarkUrl = '',
    this.signatureUrl = '',
  });

  @override
  Widget build(BuildContext context) {
    return CrmSectionCard(
      title: S.current.crmFiles,
      showHideToggle: false,
      child: Column(
        children: <Widget>[
          buildResponsiveFields(
            context: context,
            left: _buildUploadField(
              label: S.current.crmLogo,
              fileUrl: logoUrl,
              onTap: onLogoUpload,
              onRemove: onLogoRemove,
            ),
            right: _buildUploadField(
              label: S.current.crmDigitalSeal,
              fileUrl: digitalSealUrl,
              onTap: onDigitalSealUpload,
              onRemove: onDigitalSealRemove,
            ),
          ),
          SizedBox(height: 12.sp),
          buildResponsiveFields(
            context: context,
            left: _buildUploadField(
              label: S.current.crmWatermark,
              fileUrl: watermarkUrl,
              onTap: onWatermarkUpload,
              onRemove: onWatermarkRemove,
            ),
            right: _buildUploadField(
              label: S.current.crmSignature,
              fileUrl: signatureUrl,
              onTap: onSignatureUpload,
              onRemove: onSignatureRemove,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUploadField({
    required String label,
    required String fileUrl,
    VoidCallback? onTap,
    VoidCallback? onRemove,
  }) {
    if (fileUrl.trim().isNotEmpty) {
      return LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          return ProductWarrantyCard(
            title: label,
            fileName: _fileNameFromUrl(fileUrl),
            width: constraints.maxWidth,
            onTapFile: onTap,
            onRemove: onRemove,
          );
        },
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: StyleText.fontSize12Weight500.copyWith(
            color: AppColors.black,
          ),
        ),
        SizedBox(height: 6.sp),
        LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
            return customButtonWithSvg(
              title: S.current.crmUpload,
              image: AppAssets.upload,
              color: AppColors.primary,
              colorBorder: AppColors.transparent,
              widthImage: 16.sp,
              heightImage: 16.sp,
              fixedWidth: constraints.maxWidth,
              fixedHeight: 38.sp,
              textStyle: StyleText.fontSize14Weight600.copyWith(
                color: AppColors.blackButton,
              ),
              svgColor: AppColors.black,
              function: onTap ?? () {},
            );
          },
        ),
      ],
    );
  }

  String _fileNameFromUrl(String fileUrl) {
    final Uri? uri = Uri.tryParse(fileUrl);
    final String encodedPath = uri?.pathSegments.last ?? fileUrl;
    final String path = Uri.decodeComponent(encodedPath);
    final String name = path.split('/').last;
    return name.replaceFirst(RegExp(r'^\d+_'), '');
  }
}

// ****************** FILE INFO ******************
// File Name: crm_request_decision_details_section.dart
// Purpose: Section card displaying Approved Details or Reject Details (Date, Time, Approver info card, and Reason) matching Figma design
// Author: Mohand Adel
// Created At: 31/08/2026

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:knowticed_plus/core/constants/app_assets.dart';
import 'package:knowticed_plus/core/custom/inputs/custom_textfield.dart';
import 'package:knowticed_plus/core/custom/buttons/custom_button_with_svg.dart';
import 'package:knowticed_plus/core/custom/layout/custom_responsive_fields.dart';
import 'package:knowticed_plus/features/crm/presentation/ui/widgets/crm_control_dialogs.dart';
import 'package:knowticed_plus/core/helper/format_title.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/features/crm/crm6_deals/data/models/crm_deal_request_model.dart';
import 'package:knowticed_plus/features/crm/presentation/ui/widgets/crm_section_card.dart';

class CrmRequestDecisionDetailsSection extends StatelessWidget {
  final CrmDealRequestModel request;

  const CrmRequestDecisionDetailsSection({
    super.key,
    required this.request,
  });

  @override
  Widget build(BuildContext context) {
    final bool isReject = request.status == CrmRequestStatus.reject;
    final String titleEn = isReject ? 'Reject Details' : 'Approved Details';
    final String titleAr = isReject ? 'تفاصيل الرفض' : 'تفاصيل الاعتماد';

    return CrmSectionCard(
      title: FormatHelper.localizedString(
        englishName: titleEn,
        arabicName: titleAr,
      ),
      showHideToggle: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          // Row 1: Date & Time
          buildResponsiveFields(
            context: context,
            left: CustomTextField(
              label: 'Date',
              initialValue: request.approvalDate.isNotEmpty
                  ? request.approvalDate
                  : '7/7/2026',
              readOnly: true,
              fillColor: AppColors.background,
            ),
            right: CustomTextField(
              label: 'Time',
              initialValue: request.approvalTime.isNotEmpty
                  ? request.approvalTime
                  : '11:30 am',
              readOnly: true,
              fillColor: AppColors.background,
            ),
          ),

          SizedBox(height: 16.sp),

          // By Label
          Text(
            'By',
            style: StyleText.fontSize12Weight400.copyWith(
              color: AppColors.black,
              fontWeight: FontWeight.w600,
            ),
          ),

          SizedBox(height: 8.sp),

          // Approver / Rejector Info Card
          _buildUserInfoCard(context),

          // If Reject: Show Reason input field
          if (isReject) ...<Widget>[
            SizedBox(height: 16.sp),
            CustomTextField(
              label: 'Reason',
              hint: 'Description',
              initialValue:
                  request.rejectReason.isNotEmpty ? request.rejectReason : null,
              readOnly: true,
              fillColor: AppColors.background,
              maxLines: 3,
              minLines: 3,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildUserInfoCard(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 14.sp, vertical: 12.sp),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Row(
        children: <Widget>[
          // Avatar
          ClipRRect(
            borderRadius: BorderRadius.circular(20.r),
            child: Container(
              width: 40.sp,
              height: 40.sp,
              color: const Color(0xFFE2E8F0),
              child: Image.asset(
                AppAssets.male,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Icon(
                  Icons.person,
                  size: 24.sp,
                  color: AppColors.darkGrey,
                ),
              ),
            ),
          ),

          SizedBox(width: 12.sp),

          // User info row
          Expanded(
            child: Wrap(
              spacing: 16.sp,
              runSpacing: 4.sp,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: <Widget>[
                Text(
                  request.approverName.isNotEmpty
                      ? request.approverName
                      : 'Amro Handousa',
                  style: StyleText.fontSize14Weight500.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.black,
                  ),
                ),
                Text(
                  'Job Title: ${request.approverRole.isNotEmpty ? request.approverRole : 'Engineer'}',
                  style: StyleText.fontSize10Weight400
                      .copyWith(color: AppColors.fullBlack)
                      .copyWith(
                        color: AppColors.darkGrey,
                      ),
                ),
                Text(
                  'Department: ${request.approverDepartment.isNotEmpty ? request.approverDepartment : 'IT'}',
                  style: StyleText.fontSize10Weight400
                      .copyWith(color: AppColors.fullBlack)
                      .copyWith(
                        color: AppColors.darkGrey,
                      ),
                ),
                Text(
                  'Phone: ${request.approverPhone.isNotEmpty ? request.approverPhone : '011587964555'}',
                  style: StyleText.fontSize10Weight400
                      .copyWith(color: AppColors.fullBlack)
                      .copyWith(
                        color: AppColors.darkGrey,
                      ),
                ),
                Text(
                  'Email: ${request.approverEmail.isNotEmpty ? request.approverEmail : 'Amr@gmail.com'}',
                  style: StyleText.fontSize10Weight400
                      .copyWith(color: AppColors.fullBlack)
                      .copyWith(
                        color: AppColors.darkGrey,
                      ),
                ),
              ],
            ),
          ),

          SizedBox(width: 8.sp),

          // Message Button
          customButtonWithSvg(
            title: FormatHelper.localizedString(
              englishName: 'Message',
              arabicName: 'رسالة',
            ),
            image: AppAssets.message,
            widthImage: 14.sp,
            heightImage: 14.sp,
            colorBorder: Colors.transparent,
            color: AppColors.primary,
            textStyle: StyleText.fontSize14Weight500.copyWith(
              fontWeight: FontWeight.bold,
              color: AppColors.blackButton,
            ),
            function: () {
              CrmControlDialogs.showSuccessDialog(
                context: context,
                title: 'Start Conversation',
                subtitle: 'Opening chat with ${request.approverName}...',
              );
            },
          ),
        ],
      ),
    );
  }
}

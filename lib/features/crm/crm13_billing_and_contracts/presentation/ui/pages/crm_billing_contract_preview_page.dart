// ****************** FILE INFO ******************
// File Name: crm_billing_contract_preview_page.dart
// Purpose: Preview page for Billing and Contract control documents
// Author: Mohand Adel
// Created At: 07/10/2026

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:knowticed_plus/core/custom/buttons/custom_button.dart';
import 'package:knowticed_plus/core/custom/navigation/custom_side_frame_master.dart';
import 'package:knowticed_plus/features/crm/helpers/crm_navigation_helper.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/features/crm/crm13_billing_and_contracts/data/models/crm_billing_contract_model.dart';
import 'package:knowticed_plus/features/crm/crm13_billing_and_contracts/presentation/ui/widgets/crm_billing_contract_document_preview.dart';
import 'package:knowticed_plus/features/crm/presentation/ui/widgets/crm_section_card.dart';
import 'package:knowticed_plus/generated/l10n.dart';

class CrmBillingContractPreviewPage extends StatelessWidget {
  final CrmBillingContractModel item;

  const CrmBillingContractPreviewPage({
    super.key,
    required this.item,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SideFrameMasterServices(
        titleText: S.current.crm,
        secondTitle: S.current.crmSectionControls,
        thirdTitle: S.current.crmControlBillingAndContracts,
        fourthTitle: S.current.crmPreview,
        onFirstTap: () => CrmNavigationHelper.popToDashboard(context),
        onSecondTap: () => CrmNavigationHelper.pop(context),
        onThirdTap: () => CrmNavigationHelper.pop(context),
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              CrmSectionCard(
                title: 'PDF Preview',
                showHideToggle: false,
                padding: EdgeInsets.zero,
                child: CrmBillingContractDocumentPreview(item: item),
              ),
              SizedBox(height: 16.sp),
              Row(
                textDirection: TextDirection
                    .ltr, // X-73: Cancel left, action right in both languages

                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  SizedBox(
                    width: 120.sp,
                    height: 40.sp,
                    child: customButton(
                      title: S.current.crmDiscard,
                      color: AppColors.disabledGrey,
                      textStyle: StyleText.fontSize14Weight600.copyWith(
                        color: AppColors.blackButton,
                      ),
                      function: () => CrmNavigationHelper.pop(context),
                    ),
                  ),
                  SizedBox(
                    width: 140.sp,
                    height: 40.sp,
                    child: customButton(
                      title: S.current.save,
                      color: AppColors.primary,
                      textStyle: StyleText.fontSize14Weight600.copyWith(
                        color: AppColors.blackButton,
                      ),
                      function: () => CrmNavigationHelper.pop(context, 'save'),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 32.sp),
            ],
          ),
        ),
      ),
    );
  }
}

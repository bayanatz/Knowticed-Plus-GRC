// ****************** FILE INFO ******************
// File Name: crm_request_pdf_preview_section.dart
// Purpose: PDF Preview Section card and document invoice canvas for Request Details page
// Author: Mohand Adel
// Created At: 31/08/2026

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:knowticed_plus/core/constants/app_assets.dart';
import 'package:knowticed_plus/core/custom/helpers/custom_svg.dart';
import 'package:knowticed_plus/core/custom/buttons/custom_button_with_svg.dart';
import 'package:knowticed_plus/core/helper/format_title.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/features/crm/presentation/ui/widgets/crm_section_card.dart';

class CrmRequestPdfPreviewSection extends StatelessWidget {
  final String quoteNo;
  final VoidCallback onDownload;

  const CrmRequestPdfPreviewSection({
    super.key,
    required this.quoteNo,
    required this.onDownload,
  });

  @override
  Widget build(BuildContext context) {
    return CrmSectionCard(
      title: FormatHelper.localizedString(
        englishName: 'PDF Preview',
        arabicName: 'معاينة ملف PDF',
      ),
      showHideToggle: true,
      trailing: customButtonWithSvg(
        title: FormatHelper.localizedString(
          englishName: 'Download',
          arabicName: 'تحميل',
        ),
        image: AppAssets.download,
        widthImage: 14.sp,
        heightImage: 14.sp,
        color: AppColors.primary,
        colorBorder: Colors.transparent,
        textStyle: StyleText.fontSize14Weight500.copyWith(
          fontWeight: FontWeight.bold,
          color: AppColors.blackButton,
        ),
        function: onDownload,
      ),
      child: _buildPdfInvoicePreview(context),
    );
  }

  Widget _buildPdfInvoicePreview(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(24.sp),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          // Header Logo
          Container(
            width: 60.sp,
            height: 60.sp,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Color(0xFFFEF9C3),
            ),
            padding: EdgeInsets.all(10.sp),
            child: CustomSvgImage(
              assetPath: AppAssets.logo,
              width: 40.sp,
              height: 40.sp,
            ),
          ),

          SizedBox(height: 18.sp),

          // TO vs QUOTEINFO
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    'TO:',
                    style: StyleText.fontSize14Weight500.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 4.sp),
                  Text('CLIENT NAME: Spa Care Center',
                      style: StyleText.fontSize12Weight400),
                  Text('CLIENT EMAIL: contact@spacare.com',
                      style: StyleText.fontSize12Weight400),
                  Text('CLIENT PHONE: +20 100 123 4567',
                      style: StyleText.fontSize12Weight400),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    'QUOTEINFO:',
                    style: StyleText.fontSize14Weight500.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 4.sp),
                  Text('QUOTE NO: ${quoteNo.isNotEmpty ? quoteNo : '01-19302'}',
                      style: StyleText.fontSize12Weight400),
                  Text('DATE: 7 Jun 2026',
                      style: StyleText.fontSize12Weight400),
                  Text('VALID UNTIL: 14 Jun 2026',
                      style: StyleText.fontSize12Weight400),
                ],
              ),
            ],
          ),

          SizedBox(height: 20.sp),

          // Product Table with Gold Header Bar
          Table(
            columnWidths: const <int, TableColumnWidth>{
              0: FlexColumnWidth(2.0),
              1: FlexColumnWidth(1.0),
              2: FlexColumnWidth(1.2),
              3: FlexColumnWidth(1.2),
              4: FlexColumnWidth(1.2),
              5: FlexColumnWidth(1.2),
            },
            children: <TableRow>[
              TableRow(
                decoration: const BoxDecoration(
                  color: Color(0xFFE8B931),
                ),
                children: <Widget>[
                  _buildPdfTableHeader('PRODUCT'),
                  _buildPdfTableHeader('QTY'),
                  _buildPdfTableHeader('PRICE'),
                  _buildPdfTableHeader('DISCOUNT'),
                  _buildPdfTableHeader('TAX'),
                  _buildPdfTableHeader('TOTAL'),
                ],
              ),
              TableRow(
                children: <Widget>[
                  _buildPdfTableCell('Z'),
                  _buildPdfTableCell('3'),
                  _buildPdfTableCell('\$500'),
                  _buildPdfTableCell('3%'),
                  _buildPdfTableCell('\$50'),
                  _buildPdfTableCell('\$100'),
                ],
              ),
            ],
          ),

          SizedBox(height: 16.sp),

          // Subtotal & Total
          Align(
            alignment: Alignment.centerRight,
            child: SizedBox(
              width: 220.sp,
              child: Column(
                children: <Widget>[
                  _buildPdfSummaryRow('SUBTOTAL', '\$100'),
                  SizedBox(height: 4.sp),
                  _buildPdfSummaryRow('Tax 10%', '\$105'),
                  SizedBox(height: 6.sp),
                  Container(
                    padding:
                        EdgeInsets.symmetric(horizontal: 10.sp, vertical: 6.sp),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE8B931),
                      borderRadius: BorderRadius.circular(4.r),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Text('TOTAL',
                            style: StyleText.fontSize12Weight400
                                .copyWith(fontWeight: FontWeight.bold)),
                        Text('\$550',
                            style: StyleText.fontSize12Weight400
                                .copyWith(fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          SizedBox(height: 20.sp),

          // Payment Info & Contact Info
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text('PAYMENT INFO:',
                      style: StyleText.fontSize12Weight400
                          .copyWith(fontWeight: FontWeight.bold)),
                  SizedBox(height: 2.sp),
                  Text('FIRST PAYMENT ATTEMPT: -',
                      style: StyleText.fontSize10Weight400
                          .copyWith(color: AppColors.fullBlack)),
                  Text('SUCCESSFUL PAYMENT DATE: -',
                      style: StyleText.fontSize10Weight400
                          .copyWith(color: AppColors.fullBlack)),
                  Text('PAYMENT METHOD: Bank Transfer',
                      style: StyleText.fontSize10Weight400
                          .copyWith(color: AppColors.fullBlack)),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text('CONTACT INFO:',
                      style: StyleText.fontSize12Weight400
                          .copyWith(fontWeight: FontWeight.bold)),
                  SizedBox(height: 2.sp),
                  Text('EMAIL: info@knowticed.com',
                      style: StyleText.fontSize10Weight400
                          .copyWith(color: AppColors.fullBlack)),
                  Text('PHONE: +20 100 000 0000',
                      style: StyleText.fontSize10Weight400
                          .copyWith(color: AppColors.fullBlack)),
                ],
              ),
            ],
          ),

          SizedBox(height: 16.sp),

          // Notes
          Text('NOTES:',
              style: StyleText.fontSize12Weight400
                  .copyWith(fontWeight: FontWeight.bold)),
          SizedBox(height: 2.sp),
          Text('• All prices are inclusive of agreed commercial terms.',
              style: StyleText.fontSize10Weight400
                  .copyWith(color: AppColors.fullBlack)),
          Text('• Deliverables will be provided per milestone schedule.',
              style: StyleText.fontSize10Weight400
                  .copyWith(color: AppColors.fullBlack)),

          SizedBox(height: 24.sp),

          // Thank you footer
          Align(
            alignment: Alignment.centerRight,
            child: Text(
              'THANK YOU FOR USING SPA CARE TIME!',
              style: StyleText.fontSize12Weight400.copyWith(
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPdfTableHeader(String title) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 8.sp, vertical: 8.sp),
      child: Text(
        title,
        style: StyleText.fontSize12Weight400.copyWith(
          fontWeight: FontWeight.bold,
          color: AppColors.black,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildPdfTableCell(String value) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 8.sp, vertical: 10.sp),
      child: Text(
        value,
        style: StyleText.fontSize12Weight400,
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildPdfSummaryRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        Text(label, style: StyleText.fontSize12Weight400),
        Text(value,
            style: StyleText.fontSize12Weight400
                .copyWith(fontWeight: FontWeight.w600)),
      ],
    );
  }
}

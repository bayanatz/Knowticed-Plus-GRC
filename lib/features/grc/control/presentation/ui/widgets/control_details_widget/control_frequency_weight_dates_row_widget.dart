/// Module: GRC Policy Management
/// Description: Frequency/Weight/Start Date/End Date read-only info row for
///              the Control Details page, extracted from
///              ControlDetailsPage.
/// Author: Mohamed Magdy Abdelkhalek
/// Date: 2026-07-21
/// Dependencies: flutter, CardStyles
/// Revision History: 2026-07-21 - Initial creation (inline in
///                                control_details_page.dart)
///                   2026-07-28 - Split out into its own widget file
library;

/// ************************* FILE INFO *************************** ///
/// File Name: control_frequency_weight_dates_row_widget.dart
/// Purpose: Contains ControlFrequencyWeightDatesRowWidget, the four-column
///          read-only row showing Frequency, Control Weight, Start Date,
///          and End Date.
/// Author: Mohamed Magdy Abdelkhalek
/// Created At: 28/7/2026

import 'package:demo_app/core/custom/16-custom_card_styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get_utils/src/extensions/internacionalization.dart';
import 'package:intl/intl.dart' hide TextDirection;

/// class name: [ControlFrequencyWeightDatesRowWidget]
///
/// purpose: renders the read-only Frequency / Control Weight / Start Date /
///          End Date four-column row.
///
/// authors: Mohamed Magdy Abdelkhalek
///
/// created at: 28/7/2026
class ControlFrequencyWeightDatesRowWidget extends StatelessWidget {
  final String frequency;
  final double weight;
  final DateTime startDate;
  final DateTime endDate;
  final DateFormat dateFormat;

  const ControlFrequencyWeightDatesRowWidget({
    super.key,
    required this.frequency,
    required this.weight,
    required this.startDate,
    required this.endDate,
    required this.dateFormat,
  });

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8.h),
      child: Text.rich(
        TextSpan(
          text: '$label ',
          style: CardStyles.label(14),
          children: [TextSpan(text: value, style: CardStyles.value(14))],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: _infoRow('Frequency:'.tr, frequency)),
        Expanded(
          child: _infoRow(
            'Control Weight:'.tr,
            weight.toStringAsFixed(0),
          ),
        ),
        Expanded(
          child: _infoRow(
            'Start Date:'.tr,
            dateFormat.format(startDate),
          ),
        ),
        Expanded(
          child: _infoRow('End Date:'.tr, dateFormat.format(endDate)),
        ),
      ],
    );
  }
}

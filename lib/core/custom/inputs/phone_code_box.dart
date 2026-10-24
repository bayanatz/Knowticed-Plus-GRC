/// Module: core / custom / inputs
///
/// The ONE country-code box beside a phone number: a read-only field showing
/// the flag and the dial code ("🇪🇬 +20"), 100 wide, opening the country
/// picker on tap. Every edit page uses it, so the box looks the same on
/// Personal Information, Emergency Contact and the section requests (Moataz
/// 23/10/2026: "the flags are not consistent").
library;

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:knowticed_plus/core/custom/inputs/custom_textfield.dart';
import 'package:knowticed_plus/features/settings/se1_profile/data/utils/phone_country_lookup.dart';

class PhoneCodeBox extends StatelessWidget {
  const PhoneCodeBox({
    super.key,
    required this.codeOrDialCode,
    required this.onTap,
    this.height,
    this.fillColor,
  });

  /// ISO code ("EG") or dial code ("20" / "+20").
  final String codeOrDialCode;
  final VoidCallback onTap;
  final double? height;
  final Color? fillColor;

  /// Width of the box, the same on every page.
  static double get width => 100.sp;

  @override
  Widget build(BuildContext context) {
    final bool isArabic = Localizations.localeOf(context).languageCode == 'ar';
    final String text = PhoneCountryLookup.flagAndCode(codeOrDialCode);
    return SizedBox(
      width: width,
      child: CustomTextField(
        key: ValueKey<String>('dial_$text'),
        height: height,
        initialValue: text,
        hint: text,
        readOnly: true,
        fillColor: fillColor,
        borderRadius: BorderRadius.circular(4.r),
        textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
        textAlign: isArabic ? TextAlign.right : TextAlign.left,
        onTap: onTap,
      ),
    );
  }
}

/// Module: settings/se2_social
///
///*************************** FILE INFO ****************************///
/// File Name: bio.dart
/// Purpose: The Bio card of the social settings page.
/// Author: Amr Mesbah
/// Created at: 13/11/2024
/// Updated: 11/8/2026 - CR-SKEL-SE2-N05/N07/N19: the TextEditingController is
///          owned by this State instead of by SocialController, which also
///          fixes the listener that was attached to a controller-owned field
///          and never removed; the unused `isDesktop` / `isPortrait` /
///          `lightMode` locals and the commented REMOVED_MODULE imports are
///          gone.
/// Updated: 21/10/2026 (Moataz) - two fields, English and Arabic. There was
///          one field, always saved as the English bio — even when the app
///          was in Arabic — and the Arabic bio could not be edited at all.
library;

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:knowticed_plus/core/extensions/context_extensions.dart';
import 'package:knowticed_plus/core/helper/format_title.dart';
import 'package:knowticed_plus/core/custom/inputs/custom_textfield.dart';
import 'package:knowticed_plus/features/settings/presentation/ui/widgets/settings_header.dart';
import 'package:knowticed_plus/generated/l10n.dart';

class Bio extends StatefulWidget {
  const Bio({
    super.key,
    required this.bio,
    required this.bioInArabic,
    required this.onChanged,
    required this.onArabicChanged,
  });

  /// The stored bio. Comes down from the page's `BlocBuilder`, so a reload
  /// after saving re-seeds the field; it is not read from a global.
  final String bio;

  final String bioInArabic;

  final ValueChanged<String> onChanged;
  final ValueChanged<String> onArabicChanged;

  @override
  State<Bio> createState() => _BioState();
}

class _BioState extends State<Bio> {
  late final TextEditingController _controller;
  late final TextEditingController _arabicController;

  @override
  void initState() {
    super.initState();
    // Capitalized once, at seed time. The old widget did this in a post-frame
    // callback and then called setState, so every open cost an extra rebuild.
    _controller = TextEditingController(text: _seed(widget.bio));
    // Arabic has no capitals, so it is seeded as stored.
    _arabicController = TextEditingController(text: widget.bioInArabic);
  }

  static String _seed(String value) =>
      value.isEmpty ? '' : FormatHelper.capitalize(value);

  @override
  void didUpdateWidget(covariant Bio oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Only re-seed when the *stored* value changed — i.e. after a save. Doing
    // it on every rebuild would fight the user's cursor.
    if (oldWidget.bio != widget.bio &&
        _controller.text.trim() != widget.bio.trim()) {
      _controller.text = _seed(widget.bio);
    }
    if (oldWidget.bioInArabic != widget.bioInArabic &&
        _arabicController.text.trim() != widget.bioInArabic.trim()) {
      _arabicController.text = widget.bioInArabic;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _arabicController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool isMobile = ContextExtension(context).isPhone;

    final Widget english = CustomTextField(
      // The language name is written in its own language (Moataz 23/10/2026:
      // "don't translate it, it's called English").
      label: 'English',
      hint: FormatHelper.capitalize(S.of(context).shareSomethingAboutYourself),
      controller: _controller,
      maxLines: 3,
      maxLength: 500,
      enabled: true,
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.start,
      onChanged: widget.onChanged,
    );
    final Widget arabic = CustomTextField(
      label: 'العربية',
      hint: FormatHelper.capitalize(S.of(context).shareSomethingAboutYourself),
      controller: _arabicController,
      maxLines: 3,
      maxLength: 500,
      enabled: true,
      textDirection: TextDirection.rtl,
      textAlign: TextAlign.start,
      onChanged: widget.onArabicChanged,
    );

    return Container(
      // D-223 (21/10/2026): the phone page draws ONE box around Bio +
      // Academic History + Skills + Hobbies; this section no longer paints
      // its own card.
      decoration: null,
      // Mobile only: no horizontal padding on the CARD, because SettingsHeader
      // already applies 16.sp of its own on phone — the two stacked, so the
      // Bio icon sat at 30.sp while its field sat at 16.sp. Each child is
      // padded instead, which is what academic_history.dart does.
      padding: EdgeInsets.only(
        top: 16.sp,
        right: isMobile ? 0.sp : 16.sp,
        left: isMobile ? 0.sp : 16.sp,
        bottom: isMobile ? 16.sp : 0.sp,
      ),
      child: Column(
        children: <Widget>[
          SettingsHeader(
            imagePath: 'assets/icons_assets/settings_assets/ic_hr_bio.svg',
            text: FormatHelper.capitalize(S.of(context).bio),
          ),
          SizedBox(height: isMobile ? 16.sp : 16.h),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: isMobile ? 16.sp : 0.sp),
            // 21/10/2026 (Moataz): a long text takes the full width — English
            // on one row, Arabic on the next, on every device.
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                // English box: label on the left, counter on the right;
                // Arabic box: label on the right, counter on the left — in
                // both app languages.
                Directionality(
                    textDirection: TextDirection.ltr, child: english),
                SizedBox(height: 12.sp),
                Directionality(textDirection: TextDirection.rtl, child: arabic),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

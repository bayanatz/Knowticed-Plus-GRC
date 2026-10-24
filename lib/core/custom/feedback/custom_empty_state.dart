/// Module: core / custom
///
///*************************** FILE INFO ****************************///
/// File Name: custom_empty_state.dart
/// Purpose: Declares `CustomEmptyState`.
/// Author: Knowticed Plus team
/// Created at: 16/8/2026
///
/// The app's ONE empty state.
///
/// By default: the `lottie_empty` animation, no words — the animation carries
/// "there is nothing here", so most lists need no sentence.
///
/// 17/10/2026 (D-58 "a fitting illustration per list"; owner: CRM keeps each
/// page's own picture): a page may pass its own [svgPath] (or [lottiePath])
/// and, where its Figma shows words, a [title] / [subtitle]. This replaced
/// four identical CRM copies (Products, Services, Deals, Activity) and the
/// Services request list's own widget.
///
/// EMPTY IS NOT AN ERROR
/// ---------------------
/// Do not reach for this when a read FAILED. "There is nothing here" and "we
/// could not find out what is here" are different facts, and the screens that
/// tell them apart (the Database Builder list, the access table) keep their
/// own error branch with its retry.
library;

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lottie/lottie.dart';

import 'package:knowticed_plus/core/constants/app_assets.dart';
import 'package:knowticed_plus/core/custom/helpers/custom_svg.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';

class CustomEmptyState extends StatelessWidget {
  const CustomEmptyState({
    super.key,
    this.size,
    this.height,
    this.verticalPadding,
    this.svgPath,
    this.lottiePath,
    this.title,
    this.subtitle,
  });

  /// Width and height of the picture. Defaults to 250 for the animation and
  /// 140 for a page's own SVG.
  final double? size;

  /// Owner 21/10/2026: height of a non-square [svgPath] picture (then [size]
  /// is its width). Defaults to [size] — square, as before.
  final double? height;

  /// Space above and below. Defaults to 24 (48 when there is a title).
  final double? verticalPadding;

  /// The page's own illustration (D-58). Wins over [lottiePath].
  final String? svgPath;

  /// Another animation instead of the shared `lottie_empty`.
  final String? lottiePath;

  /// Optional words, only where the page's design shows them.
  final String? title;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    final bool hasText =
        (title?.isNotEmpty ?? false) || (subtitle?.isNotEmpty ?? false);
    final String? svg = svgPath;
    final Widget picture = svg != null
        ? CustomSvgImage(
            assetPath: svg,
            width: (size ?? 140).sp,
            height: (height ?? size ?? 140).sp,
          )
        : Lottie.asset(
            lottiePath ?? AppAssets.lottieEmpty,
            width: (size ?? 250).r,
            height: (size ?? 250).r,
            // Loops. A one-shot animation that has finished looks like a
            // static illustration that failed to load.
            repeat: true,
          );

    return Padding(
      padding: EdgeInsets.symmetric(
        vertical: (verticalPadding ?? (hasText ? 48 : 24)).h,
      ),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            picture,
            if (title?.isNotEmpty ?? false) ...<Widget>[
              SizedBox(height: 16.sp),
              Text(
                title!,
                textAlign: TextAlign.center,
                style: StyleText.fontSize16Weight600
                    .copyWith(color: AppColors.text),
              ),
            ],
            if (subtitle?.isNotEmpty ?? false) ...<Widget>[
              SizedBox(height: 6.sp),
              Text(
                subtitle!,
                textAlign: TextAlign.center,
                style: StyleText.fontSize12Weight400
                    .copyWith(color: AppColors.grey),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

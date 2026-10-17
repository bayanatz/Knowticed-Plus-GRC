/// Module: home/h3_app_drawer
///
///*************************** FILE INFO ****************************///
/// File Name: drawer_logo_container.dart
/// Purpose: Company logo shown at the top of the app drawer.
/// Author: Knowticed Plus team
/// Created at: 11/8/2026
///
/// Extracted from the 586-line `custom_drawer.dart`, which had no
/// `presentation/ui/widgets/` folder at all.
library;

import 'package:grc_module/core/custom/helpers/custom_svg.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';

class DrawerLogoContainer extends StatelessWidget {
  const DrawerLogoContainer({super.key, this.logoUrl});

  /// Remote logo URL for the tenant, or `null` to fall back to the bundled
  /// Knowticed asset. Read from `GetStorage` by the caller so this widget
  /// stays free of storage dependencies.
  final String? logoUrl;

  @override
  Widget build(BuildContext context) {
    final bool lightMode = Theme.of(context).brightness == Brightness.light;

    // FIXED 17/10/2026 (D-03 diagonal cut): the logo was sized in `.w`
    // (80.w circle) inside a `.sp` sidebar (90.sp), so on a landscape iPad it
    // was wider than its own column and pushed into the corner. It is now a
    // 90.sp square — same width as the sidebar and same height as the app
    // bar — with the SAME inset on every side, so the top and side gaps match
    // and the logo sits level with the header row.
    final double box = 90.sp;
    final double inset = 15.sp;
    final double logo = box - inset * 2;

    return SizedBox(
      width: box,
      height: box,
      child: Padding(
        padding: EdgeInsets.all(inset),
        child: logoUrl == null
            ? CustomSvgImage.natural(
                assetPath: lightMode
                    ? "assets/icons_assets/main_icons_assets/logo_knowticed.svg"
                    : "assets/icons_assets/main_icons_assets/logo_knowticed_dark.svg",
                width: logo,
                height: logo,
                fit: BoxFit.contain,
              )
            : SvgPicture.network(
                logoUrl!,
                width: logo,
                height: logo,
                fit: BoxFit.contain,
              ),
      ),
    );
  }
}

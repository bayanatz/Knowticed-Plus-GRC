import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:demo_app/core/theme/app_font_size.dart';

class SwitchColumn extends StatelessWidget {
  const SwitchColumn({
    super.key,
    required this.title,
  });
  final String title;

  @override
  Widget build(BuildContext context) {
    bool isTablet = MediaQuery.of(context).size.shortestSide > 600;

    return Row(
      children: [
        Text(
          title.tr.capitalize as String,
          style: AppFontStyle.cairoRegularStyle.copyWith(
            fontSize: isTablet
                ? FontConstants.fontSize014.w
                : FontConstants.fontSize018.h,
            fontWeight: FontWeight.w600,
            color: Theme.of(context).colorScheme.inverseSurface,
          ),
        ),
        SizedBox(
            // width: 6,
            ),
        IconButton(
          onPressed: () {},
          tooltip: '\nYou Can Chat with Team through \nProject Board\n',
          padding: EdgeInsets.zero,
          icon: SvgPicture.asset(
            'assets/icons_assets/main_icons_assets/svg_pdf_icon.svg',
            width: 16,
          ),
        )
      ],
    );
  }
}

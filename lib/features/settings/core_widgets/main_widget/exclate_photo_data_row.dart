import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:demo_app/core/theme/app_font_size.dart';

class ExcalatePhotoDataRow extends StatefulWidget {
  const ExcalatePhotoDataRow({super.key, required this.photoUrl, required this.space, required this.title});
  final String photoUrl;
  final String title;
  final String space;
  @override
  State<ExcalatePhotoDataRow> createState() => _ExcalatePhotoDataRowState();
}

class _ExcalatePhotoDataRowState extends State<ExcalatePhotoDataRow> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 0.02.h),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: widget.photoUrl.startsWith('assets/')
                ? Image.asset(widget.photoUrl)
                : Image.network(widget.photoUrl),
          ),
          Padding(
            padding: EdgeInsets.only(
              left: Get.locale.toString().contains('en') ? 0.02.w : 0,
              right: Get.locale.toString().contains('en') ? 0 : 0.02.w,
            ),
            // ignore: deprecated_member_use
            child: SvgPicture.asset("assets/images/expand.svg", color: Theme.of(context).colorScheme.scrim),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/cupertino.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';

class TableTextInfo extends StatelessWidget {
  final String text;
  final double width;
  final Color? color;

  const TableTextInfo({
    super.key,
    required this.text,
    required this.width,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
        width: width.sp,
        padding: EdgeInsetsDirectional.only(end: 10.sp),
        child: Text(text,
            style: StyleText.fontSize14Weight400.copyWith(
              height: 1.3,
              color: color,
            )));
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:knowticed_plus/generated/l10n.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_animations.dart';

class ProductRequestTableWidget extends StatelessWidget {
  final List<Map<String, dynamic>> data;
  final String locale; //

  const ProductRequestTableWidget({
    super.key,
    required this.data,
    required this.locale,
  });

  @override
  Widget build(BuildContext context) {
    var themeMode = Theme.of(context).brightness == Brightness.light;

    return AnimatedSizeWrap(
      // Tables animate their size (rows added / removed / filtered).
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Container(
          width: 1500.sp,
          // margin: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: themeMode ? AppColors.background : AppColors.background,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(8.r),
              topRight: Radius.circular(8.r),
            ),
          ),
          child: Column(
            children: [
              // Header
              Container(
                padding:
                    EdgeInsets.symmetric(vertical: 10.sp, horizontal: 8.sp),
                decoration: BoxDecoration(
                  color: themeMode ? Color(0xff2D2D2D) : AppColors.background,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(8.r),
                    topRight: Radius.circular(8.r),
                  ),
                ),
                child: Row(
                  children: [
                    _HeaderCell(S.of(context).assetId, flex: 4),
                    _HeaderCell(S.of(context).assetsName, flex: 4),
                    _HeaderCell(S.of(context).category, flex: 4),
                    _HeaderCell(S.of(context).subcategory, flex: 4),
                    _HeaderCell(S.of(context).model, flex: 4),
                    _HeaderCell(S.of(context).brand, flex: 4),
                    _HeaderCell(S.of(context).receivedDate, flex: 5),
                    _HeaderCell(S.of(context).returnDate, flex: 5),
                    _HeaderCell(S.of(context).quantity, flex: 4),
                    _HeaderCell(S.of(context).maintenanceFrequency, flex: 6),
                    _HeaderCell(S.of(context).nextScheduledDate, flex: 6),
                    _HeaderCell(S.of(context).expectedLifetime, flex: 6),
                    _HeaderCell(S.of(context).status, flex: 4),
                  ],
                ),
              ),
              // Rows
              ...List.generate(data.length, (index) {
                final item = data[index];
                return Container(
                  padding: EdgeInsets.symmetric(
                    vertical: 10.sp,
                    horizontal: 8.sp,
                  ),
                  decoration: BoxDecoration(
                    color: themeMode
                        ? (index % 2 == 0
                            ? const Color(0xFFF5F5F5)
                            : Colors.white)
                        : AppColors.chatBackground,
                    border:
                        Border(bottom: BorderSide(color: Colors.transparent)),
                  ),
                  child: Row(
                    children: [
                      _Cell('${item['assetId']}', flex: 4),
                      _Cell('${item['assetName'][locale]}', flex: 4),
                      _Cell('${item['category'][locale]}', flex: 4),
                      _Cell('${item['subcategory'][locale]}', flex: 4),
                      _Cell('${item['model']}', flex: 4),
                      _Cell('${item['brand']}', flex: 4),
                      _Cell('${item['receivedDate']}', flex: 5),
                      _Cell('${item['returnDate']}', flex: 5),
                      _Cell('${item['quantity']}', flex: 4),
                      _Cell('${item['maintenanceFrequency']}', flex: 6),
                      _Cell('${item['nextScheduledDate']}', flex: 6),
                      _Cell('${item['expectedLifetime']}', flex: 6),
                      _Cell('${item['status'][locale]}', flex: 4),
                    ],
                  ),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }
}

class _HeaderCell extends StatelessWidget {
  final String text;
  final int flex;
  const _HeaderCell(this.text, {required this.flex});

  @override
  Widget build(BuildContext context) {
    var themeMode = Theme.of(context).brightness == Brightness.light;

    return Expanded(
      flex: flex,
      child: Text(
        text,
        style: StyleText.fontSize10Weight500.copyWith(
          color: themeMode ? AppColors.white : AppColors.black,
        ),
      ),
    );
  }
}

class _Cell extends StatelessWidget {
  final String text;
  final int flex;
  final bool isBold;

  const _Cell(this.text, {required this.flex}) : isBold = true;

  @override
  Widget build(BuildContext context) {
    var themeMode = Theme.of(context).brightness == Brightness.light;

    return Expanded(
      flex: flex,
      child: Text(
        text,
        style: StyleText.fontSize12Weight500.copyWith(
          color: themeMode ? AppColors.blackButton : AppColors.white,
        ),
      ),
    );
  }
}

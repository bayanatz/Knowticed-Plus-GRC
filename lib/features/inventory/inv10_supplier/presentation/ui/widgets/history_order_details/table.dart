import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_animations.dart';

class ProductTableWidget extends StatelessWidget {
  final List<Map<String, dynamic>> data;
  final String locale; //

  const ProductTableWidget({
    super.key,
    required this.data,
    required this.locale,
  });

  @override
  Widget build(BuildContext context) {
    var themeMode = Theme.of(context).brightness == Brightness.light;

    return AnimatedSizeWrap(
      // Tables animate their size (rows added / removed / filtered).
      child: Container(
        width: 900.sp,
        margin: const EdgeInsets.all(16),
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
              padding: EdgeInsets.symmetric(vertical: 10.sp, horizontal: 8.sp),
              decoration: BoxDecoration(
                color: themeMode ? AppColors.background : AppColors.background,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(8.r),
                  topRight: Radius.circular(8.r),
                ),
              ),
              child: Row(
                children: [
                  const _HeaderCell('NO.', flex: 1),
                  _HeaderCell(
                    locale == 'ar' ? 'تفاصيل المنتج' : 'PRODUCT DETAILS',
                    flex: 5,
                  ),
                  _HeaderCell(locale == 'ar' ? 'الكمية' : 'QUANTITY', flex: 2),
                  _HeaderCell(
                    locale == 'ar' ? 'سعر الوحدة' : 'UNIT PRICE',
                    flex: 2,
                  ),
                  _HeaderCell(locale == 'ar' ? 'الضريبة' : 'VAT', flex: 2),
                  _HeaderCell(locale == 'ar' ? 'المبلغ' : 'AMOUNT', flex: 2),
                  _HeaderCell(
                    locale == 'ar' ? 'المبلغ النهائي' : 'FINAL AMOUNT',
                    flex: 2,
                  ),
                ],
              ),
            ),
            // Rows
            ...List.generate(data.length, (index) {
              final item = data[index];
              return Container(
                padding:
                    EdgeInsets.symmetric(vertical: 10.sp, horizontal: 8.sp),
                decoration: BoxDecoration(
                  color: themeMode ? AppColors.white : AppColors.chatBackground,
                  border: Border(
                    bottom: BorderSide(
                      color: themeMode ? AppColors.grey : AppColors.grey,
                    ),
                  ),
                ),
                child: Row(
                  children: [
                    _Cell('${index + 1}', flex: 1, isBold: false),
                    Expanded(
                      flex: 5,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item['productName'][locale],
                            style: StyleText.fontSize12Weight500.copyWith(
                              color: themeMode
                                  ? AppColors.blackButton
                                  : AppColors.white,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            item['category'][locale],
                            style: StyleText.fontSize12Weight500.copyWith(
                              color: themeMode
                                  ? AppColors.secondaryText
                                  : AppColors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Quantity Column
                    Expanded(
                      flex: 2,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${item['quantity']}',
                            style: StyleText.fontSize12Weight500.copyWith(
                              color: themeMode
                                  ? AppColors.blackButton
                                  : AppColors.white,
                            ),
                          ),
                          SizedBox(height: 4.sp),
                          Text(
                            item['unit'][locale],
                            style: StyleText.fontSize12Weight400.copyWith(
                              color: themeMode
                                  ? AppColors.secondaryText
                                  : AppColors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),

                    _Cell('${item['unitPrice']}', flex: 2),
                    _Cell('${item['vat']}', flex: 2),
                    _Cell('${item['amount']}', flex: 2),
                    _Cell('${item['finalAmount']}', flex: 2),
                  ],
                ),
              );
            }),
          ],
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
          color: themeMode ? AppColors.blackButton : AppColors.white,
        ),
      ),
    );
  }
}

class _Cell extends StatelessWidget {
  final String text;
  final int flex;
  final bool isBold;

  const _Cell(this.text, {required this.flex, this.isBold = true});

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

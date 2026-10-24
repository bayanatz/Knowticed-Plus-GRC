/// Module: form_builder_module/f6_result
///
/// FILE INFO
/// File Name   : address_analytics_table_builder.dart
/// Description: Extension methods of `AddressAnalyticsEntity`.
/// Author: Amr Mesbah
/// Created at: 06/10/2026
/// Objective   : Presentation-layer builder for the address-analytics table.
///               The Material DataRow/DataColumn construction was moved here
///               out of domain/entity/address_analytics_entity.dart so the
///               domain layer stays UI-free (§3).
library;

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/core/constants/app_assets.dart';
import 'package:knowticed_plus/core/custom/helpers/custom_svg.dart';

import 'package:knowticed_plus/features/form_builder/fb5_result/domain/entities/address_analytics_entity.dart';

/// Builds the rows and columns of the address analytics table.
extension AddressAnalyticsTableBuilder on AddressAnalyticsEntity {
  /// Method Name: [dataCells]
  ///
  /// Purpose: one striped table row per person (avatar + address parts).
  ///
  /// Returns: the rows of the address table.
  List<DataRow> dataCells() {
    List<DataRow> rows = [];
    for (int tableIndex = 0;
        tableIndex < addressTableList!.length;
        tableIndex++) {
      List<DataCell> cells = [];
      for (int rowIndex = 0;
          rowIndex < addressTableList![tableIndex].length;
          rowIndex++) {
        cells.add(DataCell((rowIndex == 0)
            ? Row(
                children: [
                  _avatar(images![tableIndex]),
                  SizedBox(width: 8.sp),
                  Text(
                    addressTableList![tableIndex][rowIndex],
                    style: StyleText.fontSize12Weight500
                        .copyWith(color: AppColors.fullBlack),
                  )
                ],
              )
            : Text(
                addressTableList![tableIndex][rowIndex],
                style: StyleText.fontSize12Weight500
                    .copyWith(color: AppColors.fullBlack),
              )));
      }
      rows.add(DataRow(
        cells: cells,
        color: WidgetStatePropertyAll(
          tableIndex % 2 == 0 ? AppColors.evenRowColor : AppColors.oddRowColor,
        ),
      ));
    }
    return rows;
  }

  /// Large-screen bug report p.9 ("this is not the default image"): the
  /// person's PNG placeholder sat on CircleAvatar's yellow theme fill. A real
  /// photo is still shown; otherwise the same default avatar SVG the
  /// response cards above the table use.
  Widget _avatar(String image) {
    final double size = 32.r;
    if (image.startsWith('http')) {
      return CircleAvatar(
        radius: size / 2,
        backgroundColor: AppColors.transparent,
        backgroundImage: NetworkImage(image),
      );
    }
    final String svg = image == AppAssets.female
        ? 'assets/icons_assets/main_icons_assets/ic_user_avatar_female.png'
        : 'assets/icons_assets/main_icons_assets/ic_user_avatar_male.png';
    return ClipOval(
      child: CustomSvgImage(
        assetPath: svg,
        width: size,
        height: size,
        fit: BoxFit.cover,
      ),
    );
  }

  /// Method Name: [dataColumns]
  ///
  /// Purpose: the address table's header cells.
  ///
  /// Returns: the header cells.
  List<DataColumn> dataColumns() {
    List<DataColumn> columns = [];
    for (int headerIndex = 0;
        headerIndex < headerItems!.length;
        headerIndex++) {
      columns.add(DataColumn(
          label: Text(
        headerItems![headerIndex],
        style: StyleText.fontSize16Weight400.copyWith(color: AppColors.white),
      )));
    }
    return columns;
  }
}

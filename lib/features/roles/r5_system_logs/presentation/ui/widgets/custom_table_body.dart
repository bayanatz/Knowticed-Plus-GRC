/// ************************ FILE INFO ******************** ///
/// FILE NAME: custom_table_body.dart
/// PURPOSE: this file contains the custom table body.
/// Author: Amr Mesbah
/// REFACTORED AT: 2/2/2025

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:grc_module/core/theme/app_font_size.dart';

class CustomTableBody extends StatefulWidget {
  final String text;
  final Color? textColor;

  CustomTableBody({ required this.text, this.textColor});
  @override
  _CustomTableBodyState createState() => _CustomTableBodyState();
}

class _CustomTableBodyState extends State<CustomTableBody> {
  @override
  Widget build(BuildContext context) {
    bool isPortrait =
        MediaQuery.of(context).orientation == Orientation.portrait;
    TextStyle tableDataTextStyle = AppFontStyle.cairoRegularStyle.copyWith(
      fontSize: isPortrait
          ? FontConstants.fontSize015.h
          : FontConstants.fontSize022.h,
      fontWeight: FontWeight.w500,
    );

    return Container(
      width: isPortrait ? 0.2.w : 0.17.w,
      padding: const EdgeInsets.symmetric(horizontal: 5),
      child: Row(
        children: [
          Expanded(
            child: Text(
              widget.text,
              textAlign: TextAlign.center,
              style: tableDataTextStyle.copyWith(
                color: widget.textColor ?? Theme.of(context).colorScheme.inverseSurface,
                height: 1.3,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

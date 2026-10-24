// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';

class TextHeaderData {
  String columnName;
  FocusNode focusNode;
  bool? hasErrorIcon;
  String? errorTitle;
  String? errorSubTitle;
  TextHeaderData({
    required this.columnName,
    required this.focusNode,
    this.hasErrorIcon = false,
    this.errorTitle = '',
    this.errorSubTitle,
  });
}

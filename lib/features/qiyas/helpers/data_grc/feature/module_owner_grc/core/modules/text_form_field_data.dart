// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';

class TextFormFieldData {
  Color border;
  TextEditingController textFormFieldControllers;
  GlobalKey<FormFieldState> fieldKeys;
  FocusNode focusNode;
  bool? hasErrorIcon;
  String? errorTitle;
  String? errorSubTitle;
  TextFormFieldData({
    required this.border,
    required this.textFormFieldControllers,
    required this.fieldKeys,
    required this.focusNode,
    this.hasErrorIcon = false,
    this.errorTitle = '',
    this.errorSubTitle,
  });
}

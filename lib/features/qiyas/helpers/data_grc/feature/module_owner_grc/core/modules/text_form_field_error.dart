// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';

class TextFormFieldError {
  GlobalKey<FormFieldState>? formFieldKey;
  FocusNode focusNode;
  int rowIndex;
  int columnIndex;

  TextFormFieldError({
    this.formFieldKey,
    required this.focusNode,
    required this.rowIndex,
    required this.columnIndex,
  });
}

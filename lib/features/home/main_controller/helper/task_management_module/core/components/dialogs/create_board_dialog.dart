import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:grc_module/generated/l10n.dart';
class CreateBoardDialog extends StatelessWidget {
  final ValueChanged<String?>? dropDownValueState;
  const CreateBoardDialog({super.key, this.dropDownValueState});
  @override
  Widget build(BuildContext context) => AlertDialog(title: Text(S.current.createBoard));
}

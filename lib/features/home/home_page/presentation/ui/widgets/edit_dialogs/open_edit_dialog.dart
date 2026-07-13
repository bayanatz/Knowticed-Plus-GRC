import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:demo_app/features/home/home_page/presentation/ui/widgets/standard_container.dart';
import 'package:demo_app/features/home/home_page/data_source/models/group_message_model.dart';
import 'package:demo_app/features/home/home_page/data_source/models/home_component_model.dart';
import 'package:demo_app/features/home/home_page/presentation/controller/home_cubit.dart';

import 'package:demo_app/features/home/home_page/data_source/models/direct_message_model.dart';
import 'package:demo_app/features/home/home_page/domain/enum/home_components.dart';
import 'package:demo_app/features/home/home_page/presentation/ui/widgets/edit_dialogs/direct_messasge_dialog.dart';
import 'package:demo_app/features/home/home_page/presentation/ui/widgets/edit_dialogs/groups_dialog.dart';

class OpenEditDialog {
  show({required BuildContext context, required HomeComponentModel model}) {
    bool isTablet = MediaQuery.of(context).size.width >= 600;
    return showDialog(
        context: context,
        builder: (dialogContext) {
          return BlocProvider<AppHomeCubit>.value(
            value: context.read<AppHomeCubit>(),
            child: Dialog(
                backgroundColor: Colors.transparent,
                child: Container(
                    margin: EdgeInsets.symmetric(
                        vertical: 50.sp, horizontal: isTablet ? 100.sp : 20.sp),
                    child:
                        StandardContainer(child: _getChild(model, context)))),
          );
        });
  }

  Widget _getChild(HomeComponentModel model, BuildContext context) {
    switch (model.component) {
      case HomeComponents.directMessage:
        return DirectMessageDialog(
            model: model as DirectMessageModel,
            onSave: () {
              _onSave(context, model);
            });
      case HomeComponents.groupMessage:
        return GroupsDialog(
            model: model as GroupMessageModel,
            onSave: () {
              _onSave(context, model);
            });
      default:
        return const SizedBox();
    }
  }

  _onSave(BuildContext context, HomeComponentModel model) {
    context.read<AppHomeCubit>().editComponent(model);
    Navigator.pop(context);
  }
}

import 'package:flutter/material.dart';
import 'package:demo_app/core/theme/app_font_size.dart';

import 'package:demo_app/core/theme/app_colors.dart';
import 'package:demo_app/core/helper/task_management_module/core/components/sort_option_widget.dart';
import 'package:demo_app/core/helper/task_management_module/core/components/tasks_components/custom_task_container_mobile.dart';

enum CheckList {
  Dates,
  Members,
}

void checkListSettingsMenu({
  required BuildContext context,
  required Offset iconPosition,
  required VoidCallback onSetDates,
  required VoidCallback onAssignMembers,
}) async {
  final List<CheckList> sortOptions = [
    CheckList.Dates,
    CheckList.Members,
  ];

  final RenderBox overlay =
      Overlay.of(context).context.findRenderObject() as RenderBox;
  final double menuOffsetX = iconPosition.dx - (-9.0);
  final double menuOffsetY = iconPosition.dy - (-7.0);

  final RelativeRect position = RelativeRect.fromLTRB(
    menuOffsetX,
    menuOffsetY,
    overlay.size.width - menuOffsetX,
    overlay.size.height,
  );

  selectedOption = await showMenu(
    elevation: 0,
    shadowColor: Colors.transparent,
    color: Theme.of(context).colorScheme.onPrimary,
    context: context,
    constraints: BoxConstraints(
      maxWidth: 0.35.w,
      minHeight: 0.0.h,
    ),
    position: position,
    shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(
          color: AppColors.signOut,
        )),
    items: sortOptions.map((option) {
      return CustomPopupMenuItem<CheckList>(
        first: option.index == 0,
        last: option.index == sortOptions.length - 1,
        color: Theme.of(context).colorScheme.onPrimary,
        value: option,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            _getSortOptionLabel(option, context),
          ],
        ),
      );
    }).toList(),
  );

  // Execute the corresponding function based on the selected option
  if (selectedOption != null) {
    switch (selectedOption!) {
      case CheckList.Dates:
        onSetDates(); // Call the Set Dates function
        break;
      case CheckList.Members:
        onAssignMembers(); // Call the Assign Members function
        break;
    }
  }
}

CheckList? selectedOption;
Widget _getSortOptionLabel(CheckList option, BuildContext context) {
  switch (option) {
    case CheckList.Dates:
      return const SortOptionWidget(
        iconAddress: 'assets/icons_assets/main_icons_assets/move_mobile.svg',
        text: "Set Dates",
        hasImage: false,
      );
    case CheckList.Members:
      return const SortOptionWidget(
        iconAddress: 'assets/icons_assets/main_icons_assets/delete_mob.svg',
        iconColor: Color(0xFF797979),
        text: "Assign Members",
        hasImage: false,
      );
  }
}

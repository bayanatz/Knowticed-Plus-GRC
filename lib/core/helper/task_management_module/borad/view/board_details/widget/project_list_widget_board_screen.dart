import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:demo_app/core/helper/task_management_module/core/components/project_screen/project_screen.dart';
import 'package:demo_app/core/helper/task_management_module/core/components/tasks_components/custom_project_screen_header.dart';
import 'package:demo_app/core/helper/task_management_module/task/data/model/board_model/board_model.dart';
import 'package:page_transition/page_transition.dart';

import 'package:demo_app/core/helper/task_management_module/core/components/custom_drawer.dart';
import 'package:demo_app/core/helper/task_management_module/core/components/tasks_components/custom_task_container.dart';
import 'package:demo_app/core/helper/task_management_module/core/constant/enum.dart';

class ProjectListWidget extends StatelessWidget {
  final List<BoardModel> boardModel;

  const ProjectListWidget({
    super.key,
    required this.boardModel,
  });

  @override
  Widget build(BuildContext context) {
    bool isPortrait =
        MediaQuery.of(context).orientation == Orientation.portrait;
    int crossAxisCount = isPortrait ? 2 : 3;

    return GridView.builder(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: boardModel.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        childAspectRatio: isPortrait ? 1.7 : 2.3,
      ),
      itemBuilder: (context, index) => _buildProjectItem(context, index),
    );
  }

  Widget _buildProjectItem(BuildContext context, int index) {
    return CustomTaskContainer(
      board: boardModel[index],
      onPressed: () {
        hapticController.triggerHapticFeedback(
          vibration: VibrateType.mediumImpact,
          hapticFeedback: HapticFeedback.mediumImpact,
        );
        _navigateToProjectScreen(context, index);
      },
    );
  }

  void _navigateToProjectScreen(BuildContext context, int index) {
    Navigator.pushReplacement(
      context,
      PageTransition(
        type: PageTransitionType.fade,
        child: CustomDrawer(
          initialIndex: 1,
          screens: [
            Container(),
            ProjectScreen(
              boardModel: boardModel[index],
              projectName:
                  boardModel[index].boardName?.boardgName?.last ?? "Unknown",
            ),
          ],
        ),
      ),
    );
  }
}

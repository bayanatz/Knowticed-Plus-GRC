import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:demo_app/core/helper/task_management_module/core/components/tasks_components/custom_task_container.dart';
import 'package:demo_app/core/helper/task_management_module/task/data/model/board_model/board_model.dart';
import 'package:demo_app/core/theme/app_colors.dart';

class CustomBoardDetails extends StatefulWidget {
  final BoardModel board;
  const CustomBoardDetails({super.key, required this.board});

  @override
  State<CustomBoardDetails> createState() => _CustomBoardDetailsState();
}

bool showContainer = false;

class _CustomBoardDetailsState extends State<CustomBoardDetails> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            showContainer
                ? Text(
                    'Board Details'.tr,
                    style: TextStyle(
                      fontSize: 16,
                      // height: 1.5,
                      fontWeight: FontWeight.w600,
                      color: AppColors.dark,
                    ),
                  )
                : SizedBox.shrink(),
            Spacer(),
            GestureDetector(
              onTap: () {
                setState(() {
                  showContainer = !showContainer;
                });
              },
              child: Text(
                showContainer ? 'Expanded'.tr : 'Hide'.tr,
                style: TextStyle(
                  fontSize: 14,
                  // height: 1.5,
                  fontWeight: FontWeight.w500,
                  color: AppColors.blue,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
          ],
        ),
        SizedBox(
          height: 10,
        ),
        showContainer
            ? SizedBox.shrink()
            : CustomTaskContainer(
                onBoardDetails: true,
                board: widget.board,
              ),
      ],
    );
  }
}

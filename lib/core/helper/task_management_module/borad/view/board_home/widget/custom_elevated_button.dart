import 'package:flutter/material.dart';
import 'package:demo_app/core/helper/task_management_module/borad/view/board_create/create_board_screen.dart';
import 'package:demo_app/core/theme/app_colors.dart';

class CustomElevatedButton extends StatelessWidget {
  final Widget? child;
  final EdgeInsetsGeometry? padding;
  final Color? backgroundColor;
  const CustomElevatedButton(
      {super.key, this.child, this.padding, this.backgroundColor});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        foregroundColor: AppColors.colorBlack,
        backgroundColor: backgroundColor,
        elevation: 0,
        padding: padding,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      onPressed: () {
        Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => CreateBoardScreenMobile(),
            ));
      },
      child: child,
    );
  }
}

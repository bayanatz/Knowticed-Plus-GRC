// custom_sidebar.dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:demo_app/core/theme/app_colors.dart';

import 'package:demo_app/core/custom/32-custom_svg.dart';
import '../../category/presentation/screens/to_do_list/home_screen.dart';
import '../utilties/images.dart';

class CustomSidebar extends StatelessWidget {
  const CustomSidebar({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 80,
      color: AppColors.white,
      child: Column(
        children: [
          const SizedBox(height: 20),
          _buildSidebarItem(
            icon: Images.toDoWhiteIcon,
            onTap: () {
              // Navigate to ToDo screen
              Navigator.pushReplacementNamed(context, ToDoListScreen.routeName);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSidebarItem({
    required String icon,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        width: 45.w,
        height: 45.h,
        decoration: BoxDecoration(
          color: AppColors.secondaryPrimary,
          borderRadius: BorderRadius.circular(14),
        ),
        child: CustomSvg(
          assetPath: icon,
          width: 19.w,
          height: 24.h,
        ),
      ),
    );
  }
}

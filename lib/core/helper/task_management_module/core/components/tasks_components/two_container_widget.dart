import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:demo_app/core/theme/app_font_size.dart';
import 'package:demo_app/core/theme/app_colors.dart';

class TwoContainersWidget extends StatefulWidget {
  final void Function(int index) onContainerTap;

  const TwoContainersWidget({super.key, required this.onContainerTap});

  @override
  _TwoContainersWidgetState createState() => _TwoContainersWidgetState();
}

class _TwoContainersWidgetState extends State<TwoContainersWidget> {
  // Track the selected container (0 for the first container, 1 for the second)
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    bool isPortrait =
        MediaQuery.of(context).orientation == Orientation.portrait;
    bool isTablet = MediaQuery.of(context).size.width > 600;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildContainer(
          index: 0,
          text: 'Start Date',
          svgPath: 'assets/icons_assets/main_icons_assets/icons_calendar.svg',
          isSelected: _selectedIndex == 0,
          onTap: () => _handleContainerTap(0),
        ),
        SizedBox(width: 0.02.w),
        _buildContainer(
          index: 1,
          text: 'End Date',
          svgPath: 'assets/icons_assets/main_icons_assets/icons_calendar.svg',
          isSelected: _selectedIndex == 1,
          onTap: () => _handleContainerTap(1),
        ),
      ],
    );
  }

  // Method to build each container
  Widget _buildContainer({
    required int index,
    required String text,
    required String svgPath,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    bool isTablet = MediaQuery.of(context).size.shortestSide > 600;
    bool isPortrait =
        MediaQuery.of(context).orientation == Orientation.portrait;
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding:
              EdgeInsets.symmetric(vertical: isPortrait ? 0.002.h : 0.005.h),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.lightPrimary : Colors.transparent,
            border: Border.all(
              color: isSelected ? Colors.transparent : Colors.grey,
              width: 1.0,
            ),
            borderRadius: BorderRadius.circular(8.0),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SvgPicture.asset(
                svgPath,
                height: isPortrait ? 0.02.h : 0.03.h,
                color: isSelected ? AppColors.textButton : Colors.grey,
              ),
              SizedBox(width: 0.01.w),
              Text(text,
                  style: AppFontStyle.cairoRegularStyle.copyWith(
                      fontSize: isTablet
                          ? isPortrait
                              ? FontConstants.fontSize024.w
                              : FontConstants.fontSize014.w
                          : FontConstants.fontSize038.w,
                      fontWeight: FontWeight.w400,
                      color: isSelected
                          ? AppColors.textButton
                          : Theme.of(context).colorScheme.inverseSurface,
                      height: 2)),
            ],
          ),
        ),
      ),
    );
  }

  void _handleContainerTap(int index) {
    setState(() {
      _selectedIndex = index;
    });
    widget.onContainerTap(index);
  }
}

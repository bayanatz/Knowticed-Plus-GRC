// Date Created :20/November/2023
// Developer Name : Bassem Mohamed
//App Version : Version 2
// Date of Last Edit :4/March/2024
// Objectives: this is a widget to customize the fikter if the messages
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:demo_app/core/helper/task_management_module/borad/controller/board_controller.dart';
import 'package:demo_app/core/helper/task_management_module/core/constant/enum.dart';
import 'package:demo_app/core/theme/app_font_size.dart';import 'package:demo_app/core/theme/app_colors.dart';
import 'package:demo_app/core/haptic/haptic_controller.dart';

// ignore: must_be_immutable
class UpperFilters extends StatefulWidget {
  UpperFilters({
    super.key,
    required this.selectedIndex,
    required this.selectedDepartmentState,
    required this.selectedIndexState,
    required this.filterTitles,
    this.cardFilter = false,
  });
  int selectedIndex;
  ValueChanged<String> selectedDepartmentState;
  ValueChanged<int> selectedIndexState;
  List<String> filterTitles;
  bool cardFilter;

  @override
  State<UpperFilters> createState() => _UpperFiltersState();
}

class _UpperFiltersState extends State<UpperFilters> {
  final TextStyle unselectedStyle = AppFontStyle.cairoRegularStyle.copyWith(
    fontSize: FontConstants.fontSize032.h,
    color: AppColors.colorGrey,
    fontWeight: FontWeight.w400,
  );
  final TextStyle selectedStyle = AppFontStyle.cairoRegularStyle.copyWith(
    color: AppColors.lightPrimary,
    /*Theme.of(context).colorScheme.onInverseSurface,*/
    fontWeight: FontWeight.w800,
    fontSize: FontConstants.fontSize032.h,
  );

  final HapticController hapticController = Get.put(HapticController());
  Widget filterItems(String title, int index) {
    return GestureDetector(
      onTap: () {
        hapticController.triggerHapticFeedback(
            vibration: VibrateType.lightImpact,
            hapticFeedback: HapticFeedback.lightImpact);
        setState(() {
          widget.selectedIndex = index;
          widget.selectedDepartmentState(title);
          widget.selectedIndexState(index);
        });
      },
      child: SizedBox(
          height: 35,
          child: Align(
            alignment: Alignment.center,
            child: Text(
              title.tr,
              style: widget.selectedIndex == index
                  ? TextStyle(
                      fontSize: 14,
                      height: 1.5,
                      fontWeight: FontWeight.w600,
                      color: Color(0xff2D2D2D),
                    )
                  : TextStyle(
                      height: 1.5,
                      fontSize: FontConstants.fontSize016.h,
                      fontWeight: FontWeight.w600,
                      color: Color(0xff8D8D8D),
                    ),
            ),
          )),
    );
  }

  BoardController boardController = Get.find();
  String getNameOfDepartment(String index) {
    switch (index) {
      case '0':
        return "All".tr;
      case '1':
        return "Executive".tr;
      case '2':
        return "Operations".tr;
      case '3':
        return "Finance".tr;
      case '4':
        return "Information Technology".tr;
      case '5':
        return "Human Resources".tr;
      case '6':
        return "Marketing".tr;
      case '7':
        return "Sales".tr;
      case '8':
        return "Data Management".tr;
      case '9':
        return "Compliance & Legal".tr;
      case '10':
        return "Customer Support".tr;
      default:
        return "None".tr;
    }
  }

  String getNumberOfBoards(int index) {
    return boardController.allBoards
        .where((e) =>
            getNameOfDepartment(e.boardDeparment!.boardgDepartment!.last)
                .toLowerCase() ==
            widget.filterTitles[index].toLowerCase())
        .length
        .toString();
  }

  String getNumberOfCards(int index) {
    return boardController.filterCards
        .where(
          (e) =>
              e.cardStatus!.cardStatus!.last.toLowerCase() ==
              widget.filterTitles[index].toLowerCase(),
        )
        .length
        .toString();
  }

  Widget selectedContainer(int index) {
    return Container(
        width: 35,
        height: 35,
        alignment: Alignment.bottomCenter,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(4),
          color: widget.selectedIndex == index
              ? AppColors.signOut
              : AppColors.colorWhite,
        ),
        child: Align(
          alignment: Alignment.center,
          child: Center(
            child: Text(
              index == 0
                  ? widget.cardFilter
                      ? getNumberOfCards(0).tr.tr
                      : '${boardController.allBoards.length}'.tr
                  : widget.cardFilter
                      ? getNumberOfCards(index).tr
                      : getNumberOfBoards(index).tr,
              style: widget.selectedIndex == index
                  ? TextStyle(
                      fontSize: 14,
                      height: 1.5,
                      fontWeight: FontWeight.w600,
                      color: Color(0xff2D2D2D),
                    )
                  : TextStyle(
                      height: 1.5,
                      fontSize: FontConstants.fontSize016.h,
                      fontWeight: FontWeight.w600,
                      color: Color(0xff8D8D8D),
                    ),
            ),
          ),
        ));
  }

  Widget belowSpacer() {
    return SizedBox(
      width: 15,
    );
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 35,
      width: double.infinity,
      child: ListView.builder(
        shrinkWrap: true,
        scrollDirection: Axis.horizontal,
        itemBuilder: (context, index) {
          return Row(
            // mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              selectedContainer(index),
              belowSpacer(),
              filterItems(widget.filterTitles[index], index),
              SizedBox(
                width: 30.h,
              )
            ],
          );
        },
        itemCount: widget.filterTitles.length,
      ),
    );
  }
}

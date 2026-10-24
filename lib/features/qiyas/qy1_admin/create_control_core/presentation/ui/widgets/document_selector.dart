import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:knowticed_plus/features/qiyas/qy1_admin/create_control_core/presentation/controller/control_core_cubit.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';

import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/haptic_controller.dart';

class DocumentSelector extends StatefulWidget {
  const DocumentSelector({
    super.key,
    this.selectedColor,
    this.unselectedColor,
  });

  final Color? selectedColor;
  final Color? unselectedColor;

  @override
  State<DocumentSelector> createState() => _DocumentSelectorState();
}

class _DocumentSelectorState extends State<DocumentSelector> {
  late ControlCoreCubit controller;

  @override
  void initState() {
    super.initState();
    controller = context.read<ControlCoreCubit>();
    controller.selectVision(null);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 10.sp,
      children: [
        _visionSection(),
        if (controller.selectedVision != null) _topicSection(),
        if (controller.selectedTopic != null) _criteriaSection(),
        if (controller.selectedCriterion != null) _documentSection(),
      ],
    );
  }

  Widget _visionSection() {
    return _valuesWrapper(
      values: controller.getSelectedChampionAllowedVisions(),
      title: 'المنظور',
      onTap: controller.selectVision,
      onRemove: (_) => controller.selectVision(null),
      selectedValue: controller.selectedVision,
      selectedColor: widget.selectedColor,
      unselectedColor: widget.unselectedColor,
    );
  }

  Widget _topicSection() {
    return _valuesWrapper(
      values: controller.getVisionAllowedTopics(),
      title: 'المحاور',
      onTap: controller.selectTopic,
      onRemove: (_) => controller.selectTopic(null),
      selectedValue: controller.selectedTopic,
      selectedColor: widget.selectedColor,
      unselectedColor: widget.unselectedColor,
    );
  }

  Widget _criteriaSection() {
    return _valuesWrapper(
      values: controller.getTopicAllowedCriteria(),
      title: 'المعيار',
      onTap: controller.selectCriterion,
      onRemove: (_) => controller.selectCriterion(null),
      selectedValue: controller.selectedCriterion,
      selectedColor: widget.selectedColor,
      unselectedColor: widget.unselectedColor,
    );
  }

  Widget _documentSection() {
    return _valuesWrapper(
      values: controller.getCriterionAllowedDocuments(),
      title: 'المستندات',
      onTap: controller.selectDocument,
      onRemove: (_) => controller.selectDocument(null),
      selectedValue: controller.selectedDocument,
      selectedColor: widget.selectedColor,
      unselectedColor: widget.unselectedColor,
    );
  }

  Widget _valuesWrapper({
    required List<String> values,
    required String title,
    required Function(String?) onTap, // ← String? instead of String
    required Function(String)? onRemove, // ← add this
    required String? selectedValue,
    Color? selectedColor,
    Color? unselectedColor,
  }) {
    final activeColor = selectedColor ?? AppColors.primary;
    final inactiveColor = unselectedColor ?? AppColors.background;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 8.sp,
      children: [
        Text(title, style: StyleText.fontSize16Weight400),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            spacing: 10.sp,
            children: [
              for (String value in values)
                InkWell(
                  onTap: () {
                    HapticController.low(); // list row: on the tap (X-117)
                    onTap(value);
                    setState(() {});
                  },
                  splashColor: Colors.transparent,
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8.sp),
                          color: value == selectedValue
                              ? activeColor
                              : inactiveColor,
                        ),
                        padding: EdgeInsets.symmetric(
                            horizontal: 10.sp, vertical: 10.sp),
                        child: Text(
                          value,
                          style: StyleText.fontSize16Weight500.copyWith(
                            color: value == selectedValue
                                ? AppColors.textButton
                                : AppColors.text,
                          ),
                        ),
                      ),

                      // ← Red remove icon, only on selected item
                      if (value == selectedValue && onRemove != null)
                        Positioned(
                          top: -6.sp,
                          left: -6.sp,
                          child: GestureDetector(
                            onTapDown: (_) => HapticController.high(),
                            onTap: () {
                              onRemove(value);
                              setState(() {});
                            },
                            child: Container(
                              width: 18.sp,
                              height: 18.sp,
                              decoration: const BoxDecoration(
                                color: Colors.red,
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.remove,
                                color: Colors.white,
                                size: 12.sp,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                )
            ],
          ),
        )
      ],
    );
  }
}

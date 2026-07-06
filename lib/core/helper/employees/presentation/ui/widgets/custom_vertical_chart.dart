// ignore_for_file: unrelated_type_equality_checks, sized_box_for_whitespace, unused_local_variable
import 'package:demo_app/features/onboarding/presentation/ui/pages/onboarding.dart';
import 'package:demo_app/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:demo_app/core/helper/employees/widgets/custom_chart_data.dart';
import 'package:demo_app/core/helper/employees/widgets/custom_chart_values.dart';


import 'package:demo_app/core/theme/app_font_size.dart';
import 'package:demo_app/core/theme/theme_controller.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

//Date Created :5/September/2023
// Developer Name : Mazen shabaan
//App Version : Version Mobile
// Date of Last Edit :28/Novmember/2023 by Bassem
// Objectives: this class created to Customize the chart widget in the employee screen

class CustomVerticalChart extends StatefulWidget {
  final String title;
  final String innerTitle;
  final String imagePath;
  final List<String> texts;
  final List<String> values;
  final double width;
  final double height;
  final double textSizeTexts;
  final double textSizeValues;
  final bool isTransparent;
  final bool detailsProgress;
  final bool isSmall;
  final bool isHorizontal;

  const CustomVerticalChart({
    required this.title,
    required this.innerTitle,
    required this.imagePath,
    required this.texts,
    required this.values,
    required this.width,
    this.height = 0.300,
    this.textSizeTexts = 0.023,
    this.textSizeValues = 0.021,
    this.isSmall = false,
    this.detailsProgress = false,
    this.isTransparent = false,
    this.isHorizontal = false,
    Key? key,
  }) : super(key: key);

  @override
  State<CustomVerticalChart> createState() => _CustomVerticalChartState();
}

class _CustomVerticalChartState extends State<CustomVerticalChart> {
  int calculateSum(List<String>? values) {
    int sum = 0;
    if (values != null) {
      for (int i = 0; i < values.length; i++) {
        sum += int.parse(values[i]);
      }
    }
    return sum;
  }

  final List<Color> customColors = [
    AppColors.signOut,
    AppColors.colorGrey,
    AppColors.lightPrimary,
    AppColors.colorGreydark,
    AppColors.colorLightGrey,
    AppColors.colorWhiteDark,
    AppColors.greyDark,
    AppColors.colorDarkGrey,
  ];
  //AppColors.colorGreydark,

  final List<String> period = [
    'Weekly'.tr,
    'Monthly'.tr,
    'Yearly'.tr,
  ];

  String? selectedPeriod = 'Monthly'.tr;

  @override
  Widget build(BuildContext context) {
    int totalSum = calculateSum(widget.values);
    // String simplifiedSum = simplifyNumber(totalSum);

    bool isPortrait =
        MediaQuery.of(context).orientation == Orientation.portrait;
    final ThemeController themeController = Get.put(ThemeController());
    List<ChartData> data = [];
    for (int i = 0; i < widget.values.length; i++) {
      data.add(ChartData(widget.texts[i], double.parse(widget.values[i])));
    }
    bool isTablet = MediaQuery.of(context).size.shortestSide > 600;
    return Container(
      width: widget.width,
      height: widget.height.h,
      decoration: BoxDecoration(
        color: widget.isTransparent && isTablet == false
            ? Theme.of(context).colorScheme.inversePrimary
            : Theme.of(context).colorScheme.inversePrimary,
        borderRadius: BorderRadius.circular(9),
        boxShadow: themeController.currentTheme == AppColors.lightTheme
            ? [
                if (widget.isTransparent == false)
                  BoxShadow(
                    color: AppColors.colorGrey.withOpacity(0.2),
                    blurRadius: 18,
                  ),
              ]
            : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Padding(
            padding: EdgeInsets.only(
                bottom: 0.02.h,
                top: 0.01.h,
                right: isPortrait ? 0.015.h : 0.02.h,
                left: isPortrait ? 0.015.h : 0.02.h),
            child: Row(
              children: [
                CircleAvatar(
                  backgroundColor: AppColors.bubbleColor,
                  radius: isTablet
                      ? isPortrait
                          ? 0.015.h
                          : 0.02.h
                      : 0.015.h,
                  child: SvgPicture.asset(
                    widget.imagePath,
                    height: isTablet ? (isPortrait? 0.02.h : 0.025.h) : 0.02.h,
                    color: AppColors.textButton,
                  ),
                ),
                /* SvgPicture.asset(
                  widget.imagePath,
                  height: 0.04.h,
                ),*/
                SizedBox(width: 0.01.h),
                Text(
                  widget.title.tr,
                  style: AppFontStyle.cairoRegularStyle.copyWith(
                      fontSize: isPortrait
                          ? FontConstants.fontSize018.h
                          : FontConstants.fontSize022.h,
                      color:
                          themeController.currentTheme == AppColors.lightTheme
                              ? AppColors.colorBlack
                              : AppColors.colorWhiteDark,
                      fontWeight: FontWeight.w600,
                      height: isPortrait ? 1.8 : 0.002.h),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                  //   color: Colors.amber,
                  height: isPortrait ? 0.17.h : 0.2.h,
                  width: isPortrait ? 0.19.h : 0.22.h,
                  child: SfCircularChart(
                    annotations: <CircularChartAnnotation>[
                      CircularChartAnnotation(
                        widget: Container(
                          alignment: Alignment.center,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                "${totalSum}",
                                style: AppFontStyle.cairoRegularStyle.copyWith(
                                  fontSize: isPortrait
                                      ? FontConstants.fontSize020.h
                                      : FontConstants.fontSize024.h,
                                  color: Theme.of(context)
                                      .colorScheme
                                      .secondaryContainer,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                              Padding(
                                padding: EdgeInsets.only(top: 0.01.h),
                                child: Text(
                                  widget.innerTitle.tr,
                                  style:
                                      AppFontStyle.cairoRegularStyle.copyWith(
                                    fontSize: isPortrait
                                        ? FontConstants.fontSize021.h
                                        : FontConstants.fontSize025.h,
                                    color: Theme.of(context)
                                        .colorScheme
                                        .tertiaryContainer,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    ],
                    series: <CircularSeries>[
                      DoughnutSeries<ChartData, String>(
                        dataSource: data,
                        xValueMapper: (ChartData info, _) => info.text,
                        yValueMapper: (ChartData info, _) => info.values,
                        pointColorMapper: (ChartData info, int index) {
                          if (index >= 0 && index < customColors.length) {
                            return customColors[index];
                          }
                          return Colors.grey;
                        },
                        dataLabelSettings: DataLabelSettings(
                          isVisible: false,
                          labelPosition: ChartDataLabelPosition.inside,
                          textStyle: AppFontStyle.cairoRegularStyle.copyWith(
                            fontSize: FontConstants.fontSize016.h,
                            color: Theme.of(context)
                                .colorScheme
                                .secondaryContainer,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        radius: '100%',
                        innerRadius: '80%',
                        explodeOffset: isTablet ? '0%' : '3%',
                        explode: false,
                        explodeAll: false,
                      )
                    ],
                    tooltipBehavior: TooltipBehavior(
                      enable: true,
                    ),
                  )),
              Padding(
                padding: EdgeInsets.only(top: isPortrait ? 0.02.h : 0.02.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            for (int i = 0; i < widget.values.length; i++)
                              Padding(
                                padding: EdgeInsets.only(bottom: 0.015.h),
                                child: Row(
                                  children: [
                                    Container(
                                 //     color:Colors.amber,
                                      child: CustomChartDataRow(
                                          isSmall: widget.isSmall,
                                          dataColor: customColors[i],
                                          textData: widget.texts[i],
                                          isHorizontal: widget.isHorizontal),
                                    ),
                                    isTablet
                                        ? isPortrait
                                            ? SizedBox(
                                                width: 0.1.w,
                                              )
                                            : const SizedBox.shrink()
                                        : SizedBox(
                                            width: 0.35.w,
                                          ),
                                    CustomChartDataValues(
                                      valueText: widget.values[i],
                                      detailsProgress: widget.detailsProgress,
                                      isHorizontal: widget.isHorizontal,
                                      isSmall: widget.isSmall,
                                    )
                                  ],
                                ),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              )
            ],
          ),
        ],
      ),
    );
  }
}

class ChartData {
  ChartData(this.text, this.values);

  final String text;
  final double values;
}

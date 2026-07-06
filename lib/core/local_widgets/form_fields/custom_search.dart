import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:demo_app/core/theme/app_colors.dart';
import 'package:demo_app/core/theme/app_text_styles.dart';


class CustomSearchFiled2 extends StatefulWidget {
  final Color? fillColor;
  final String hint;
  final bool isBorded;
  final TextStyle? hintStyle;
  final TextInputType keyBoardType;
  final Function(String)? onChanged;
  final EdgeInsets? padding;
  final TextEditingController? controller;

  const CustomSearchFiled2({
    Key? key,
    required this.fillColor,
    required this.hint,
     this.hintStyle,
    required this.keyBoardType,
    this.controller,
    this.padding,
    this.isBorded = false,
    this.onChanged,
  }) : super(key: key);

  @override
  _CustomSearchFiledState createState() => _CustomSearchFiledState();
}

class _CustomSearchFiledState extends State<CustomSearchFiled2> {
  String search_text = '';
  TextEditingController textEditingController = TextEditingController();
  @override
  initState() {
    super.initState();
    textEditingController = widget.controller ?? TextEditingController();
  }

  void onSearchTextChanged(String searchText) {
    setState(() {
      search_text = searchText;
    });
    widget.onChanged?.call(searchText);
  }

  void clearSearchText() {
    setState(() {
      search_text = '';
      textEditingController.clear(); // Clear the text field
    });
    widget.onChanged?.call('');
  }

  @override
  Widget build(BuildContext context) {
    bool orientation =
        MediaQuery.of(context).orientation == Orientation.portrait;
    bool isTablet = MediaQuery.of(context).size.shortestSide > 600;

    return Container(
        width: 1.w,
        height: isTablet ? null : 50.h,
        child: Padding(
          padding: widget.padding ?? EdgeInsets.zero,
          child: TextFormField(
            cursorColor: AppColors.primary,
            textAlignVertical: TextAlignVertical.bottom,
            controller: textEditingController,
            onChanged: onSearchTextChanged,
            decoration: InputDecoration(
            hoverColor: Colors.transparent,
              filled: true,
              fillColor: widget.fillColor?? AppColors.secondaryPrimary,
              hintText: widget.hint.tr,
              hintStyle: (widget.hintStyle?? AppTextStyles.font12SecondaryBlackCairoRegular).copyWith(
                color:AppColors.mediumGrey,
                    height:1.4
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.0),
                borderSide: BorderSide(
                  color: AppColors.border
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.0),
                borderSide: BorderSide(
                  color: widget.isBorded?
                  AppColors.border: Colors.transparent,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.0),
                borderSide: BorderSide(color: AppColors.primary),
              ),
              prefixIcon: Padding(
                padding: EdgeInsets.all(isTablet ? 8.0 : 10.sp),
                child: SvgPicture.asset(
                  'assets/icons_assets/main_icons_assets/images_search.svg',
                  height: orientation ? 15.h : 20.h,
                ),
              ),
              suffixIcon: search_text.isNotEmpty
                  ? IconButton(
                onPressed: clearSearchText,
                icon: Icon(
                  Icons.clear,
                  size: 20.h,
                  color: AppColors.primary
                ),
              )
                  : null,
              isDense: true,
            ),
            keyboardType: widget.keyBoardType,
            style:isTablet?AppTextStyles.font16BlackRegularCairo : AppTextStyles.font14BlackCairoRegular
            ),

        ),
    );
  }
}

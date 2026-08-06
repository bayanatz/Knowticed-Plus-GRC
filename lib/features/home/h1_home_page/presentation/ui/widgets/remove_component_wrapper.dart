import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';

import 'package:grc_module/core/theme/app_colors.dart';
import 'package:grc_module/features/home/h1_home_page/data_source/models/home_component_model.dart';
import 'package:grc_module/features/home/h1_home_page/presentation/controller/home_cubit.dart';

class RemoveComponentWrapper extends StatelessWidget {
  RemoveComponentWrapper(
      {required this.component, required this.model, super.key});
  Widget component;
  HomeComponentModel model;
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Stack(children: [
        Padding(
          padding: EdgeInsetsDirectional.only(top: 12.sp, end: 12.sp),
          child: component,
        ),
        Positioned(
          top: 0,
          bottom: 0,
          left: 0,
          right: 0,
          child: Container(
            color: Colors.transparent,
          ),
        ),
        PositionedDirectional(
            top: 0,
            end: 0,
            child: InkWell(
              splashColor: Colors.transparent,
              hoverColor: Colors.transparent,
              onTap: () {
                context.read<AppHomeCubit>().removeComponent(model);
              },
              child: Container(
                width: 20.sp,
                height: 20.sp,
                padding: EdgeInsets.all(4.sp),
                child: SvgPicture.asset(
                  'assets/icons_assets/main_icons_assets/minus_circle_red.svg',
                  color: AppColors.text,
                ),
                decoration: BoxDecoration(
                    shape: BoxShape.circle, color: AppColors.greyIcon),
              ),
            ))
      ]),
    );
  }
}

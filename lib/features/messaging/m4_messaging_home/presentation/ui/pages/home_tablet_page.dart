/// Module: messaging / home / presentation/ui/pages/home_tablet_page.dart
/// ************************* FILE INFO *************************** ///
/// File Name: home_tablet_page.dart
/// Purpose: Home tablet page — messaging Home sub-feature.
/// Author: Knowticed Team
/// Created At: 11/10/2025

// Date: 1/9/2024
// By: Youssef Ashraf , Nada Mohammed
// Last update: 1/9/2024
// Objectives: This file is responsible for providing the home tablet page used in the messaging feature.

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:grc_module/features/messaging/m2_connections/presentation/ui/pages/community_tablet_layout.dart';
import 'package:grc_module/features/messaging/m2_connections/presentation/controller/community_controller.dart';

import 'package:grc_module/core/theme/app_colors.dart';
import 'package:grc_module/core/helper/main_helper/custom_app_bar.dart';
import '../widgets/category_filter.dart';
import 'package:grc_module/generated/l10n.dart';

class HomeTabletPage extends StatefulWidget {
  const HomeTabletPage({super.key});

  @override
  State<HomeTabletPage> createState() => _HomeTabletPageState();
}

class _HomeTabletPageState extends State<HomeTabletPage> {


  // home_tablet_page.dart
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // ✅ Guard before accessing tabController
      final cubit = context.read<CommunityCubit>();
      if (cubit.isTabControllerInitialized) {
        cubit.tabController.animateTo(0);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CommunityCubit, CommunityState>(
      builder: (context, state) {
        return Scaffold(
          backgroundColor: AppColors.background,
          resizeToAvoidBottomInset: false,
          body: SafeArea(
            child: Padding(
              padding: EdgeInsetsDirectional.only(start: 16.0.w, end: 16.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CustomAppBar(
                    title: S.of(context).messages,
                    centerTitle: false,
                    hideLeading: true,
                  ),
                  const CategoryFilter(),
                   Expanded(child: HomeTabletLayout()),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
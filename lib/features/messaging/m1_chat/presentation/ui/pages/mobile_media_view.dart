/// Module: messaging/m1_chat
///
///*************************** FILE INFO ****************************///
/// File Name: mobile_media_view.dart
/// Description: `MobileMediaView` page.
/// Author: Amr Mesbah
/// Created at: 06/10/2026
library;

import 'package:knowticed_plus/core/custom/helpers/custom_svg.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';

import 'package:knowticed_plus/features/messaging/helpers/constants/messaging_assets.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/features/messaging/helpers/messaging_app_bar.dart';

import 'package:knowticed_plus/features/messaging/m1_chat/data/models/media/doc_info_model.dart';
import 'package:knowticed_plus/features/messaging/m1_chat/data/models/media/link_model.dart';
import 'package:knowticed_plus/features/messaging/m1_chat/data/models/media/media_model.dart';
import 'package:knowticed_plus/features/messaging/m1_chat/presentation/controller/media_controller.dart';

import 'package:knowticed_plus/generated/l10n.dart';
import 'package:knowticed_plus/core/extensions/context_extensions.dart';
import 'package:knowticed_plus/core/custom/cards/image_grid_card.dart';
import 'package:knowticed_plus/core/custom/feedback/circle_progress.dart';
import 'package:knowticed_plus/core/theme/haptic_controller.dart';

part '../widgets/media/media_tabbar.dart';
part '../widgets/media/cards/link_card.dart';
part '../widgets/media/cards/docs_card.dart';
part '../widgets/media/cards/filter_card.dart';

//Youssef Ashraf
///Media page when user click on media section from chat profile view or from chat menu
class MobileMediaView extends StatelessWidget {
  final String recieverName;
  final MediaModel model;

  const MobileMediaView({
    required this.recieverName,
    required this.model,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final isTablet = ContextExtension(context).isTablett;

    return SafeArea(
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: ContextExtension(context).isTablett ? 24.w : 16.w,
          ),
          child: BlocBuilder<MediaCubit, MediaState>(
            builder: (context, state) {
              if (state is! MediaLoaded) {
                return const Center(child: CircleProgressMaster.inline());
              }

              final mediaCubit = context.read<MediaCubit>();
              final selectedMediaTab = state.selectedMediaTab;

              return Column(
                children: [
                  CustomAppBar(
                    subtitle: 'Leader',
                    textStyle: StyleText.fontSize18Weight500,
                    title: recieverName,
                  ),
                  SizedBox(
                    height: ContextExtension(context).isTablett ? 40.h : 24.h,
                  ),
                  const MediaTabbar(),
                  if ((model.images == null || model.images!.isEmpty) &&
                      selectedMediaTab == S.of(context).media)
                    Expanded(
                      child: Column(
                        children: [
                          const Spacer(),
                          LottieBuilder.asset(
                            AppAssets.media,
                            width: 170.w,
                            height: 170.h,
                            frameRate: const FrameRate(120),
                          ),
                          SizedBox(height: 8.h),
                          Text(
                            S.of(context).noMedia,
                            style: StyleText.fontSize18Weight600,
                          ),
                        ],
                      ),
                    ),
                  if ((model.links == null || model.links!.isEmpty) &&
                      selectedMediaTab == S.of(context).links)
                    Expanded(
                      child: Column(
                        children: [
                          const Spacer(),
                          LottieBuilder.asset(
                            AppAssets.links,
                            width: 170.w,
                            height: 170.h,
                            frameRate: const FrameRate(120),
                          ),
                          SizedBox(height: 8.h),
                          Text(
                            S.of(context).noLinks,
                            style: StyleText.fontSize18Weight600,
                          ),
                        ],
                      ),
                    ),
                  if ((model.pdfs == null || model.pdfs!.isEmpty) &&
                      selectedMediaTab == S.of(context).documents)
                    Expanded(
                      child: Column(
                        children: [
                          const Spacer(),
                          LottieBuilder.asset(
                            AppAssets.docs,
                            width: 170.w,
                            height: 170.h,
                            frameRate: const FrameRate(120),
                          ),
                          SizedBox(height: 8.h),
                          Text(
                            S.of(context).noDocs,
                            style: StyleText.fontSize18Weight600,
                          ),
                        ],
                      ),
                    ),
                  Expanded(
                    child: Column(
                      children: [
                        SizedBox(
                          height:
                              ContextExtension(context).isTablett ? 32.h : 24.h,
                        ),
                        Expanded(
                          child: Padding(
                            padding: EdgeInsets.only(
                              bottom: isTablet ? 24.w : 16.w,
                            ),
                            child: SingleChildScrollView(
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 500),
                                child: Column(
                                  children: mediaCubit
                                          .filterDates(
                                        model: model,
                                        tab: selectedMediaTab,
                                      )
                                          ?.map((sortedDateLabel) {
                                        return Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              sortedDateLabel,
                                              style: ContextExtension(context)
                                                      .isTablett
                                                  ? StyleText
                                                      .fontSize23Weight500
                                                      .copyWith(
                                                      color: AppColors.darkGrey,
                                                    )
                                                  : StyleText
                                                      .fontSize16Weight500
                                                      .copyWith(
                                                      color: AppColors.darkGrey,
                                                    ),
                                            ),
                                            SizedBox(
                                              height: ContextExtension(context)
                                                      .isTablett
                                                  ? 24.h
                                                  : 16.h,
                                            ),
                                            StaggeredGrid.count(
                                              mainAxisSpacing: 16.h,
                                              crossAxisSpacing:
                                                  isTablet ? 16.w : 8.w,
                                              crossAxisCount:
                                                  selectedMediaTab ==
                                                          S.of(context).media
                                                      ? isTablet
                                                          ? 5
                                                          : 4
                                                      : 1,
                                              children: mediaCubit
                                                      .filterTabs(
                                                    model: model,
                                                    sortedDateLabel:
                                                        sortedDateLabel,
                                                    tab: selectedMediaTab,
                                                  )
                                                      ?.map((obj) {
                                                    return FilterCard(
                                                      tab: selectedMediaTab,
                                                      obj: obj,
                                                    );
                                                  }).toList() ??
                                                  [],
                                            ),
                                            SizedBox(
                                              height: ContextExtension(context)
                                                      .isTablett
                                                  ? 40.h
                                                  : 24.h,
                                            ),
                                          ],
                                        );
                                      }).toList() ??
                                      [],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

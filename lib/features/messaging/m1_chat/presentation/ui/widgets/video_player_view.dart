/// Module: messaging / chat / presentation/ui/widgets/video_player_view.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:grc_module/features/messaging/m1_chat/presentation/controller/message_controller.dart';


import 'package:video_player/video_player.dart';

import 'package:grc_module/core/constants/message_module/app_assets.dart';
import 'package:grc_module/core/theme/app_colors.dart';
import 'package:grc_module/core/theme/app_text_styles.dart';
import '../../../data/models/message/video_message_model.dart';
import 'package:grc_module/core/extension/context_extensions.dart';

//Youssef Ashraf
/// Video Player full View
class VideoPlayerView extends StatefulWidget {
  final VideoMessageModel model;

  const VideoPlayerView({super.key, required this.model});

  @override
  State<VideoPlayerView> createState() => _VideoPlayerViewState();
}

class _VideoPlayerViewState extends State<VideoPlayerView> {
  @override
  void initState() {
    super.initState();
    // Initialize video listener when widget is created
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<MessageCubit>().videoListener(widget.model);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: PopScope(
          onPopInvoked: (didPop) {
            if (didPop) {
              widget.model.playerController
                ..seekTo(Duration.zero)
                ..pause();

              final cubit = context.read<MessageCubit>();
              // Reset progress and slide changing states
              // Note: You may need to add these methods to MessageCubit
              // or handle this differently based on your state management
            }
          },
          child: BlocBuilder<MessageCubit, MessageState>(
            builder: (context, state) {
              final cubit = context.read<MessageCubit>();

              // Extract state values
              final progressShown = state is MessageLoaded
                  ? state.progressShown
                  : true;
              final isPlaying = state is MessageLoaded
                  ? state.isPlaying
                  : false;
              final videoDuration = state is MessageLoaded
                  ? state.videoDuration
                  : '';
              final bufferedVideo = state is MessageLoaded
                  ? state.bufferedVideo
                  : 0.0;
              final slideChanging = state is MessageLoaded
                  ? state.slideChanging
                  : false;

              return GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () {
                  cubit.showProgress();
                },
                child: SizedBox(
                  height: double.infinity,
                  width: double.infinity,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Hero(
                        tag: 'video${widget.model.id}',
                        child: AspectRatio(
                          aspectRatio: widget.model.playerController.value.aspectRatio,
                          child: VideoPlayer(
                            widget.model.playerController,
                          ),
                        ),
                      ),
                      Visibility(
                        visible: progressShown,
                        child: GestureDetector(
                          onTap: () {
                            cubit.playVideo(widget.model);
                          },
                          child: CircleAvatar(
                            backgroundColor: AppColors.grey.withOpacity(0.3),
                            child: SvgPicture.asset(
                              isPlaying
                                  ? AppAssets.pause
                                  : AppAssets.play,
                              color: AppColors.white,
                            ),
                          ),
                        ),
                      ),
                      Visibility(
                        visible: progressShown,
                        child: Positioned(
                          left: 8.w,
                          right: 8.w,
                          bottom: 25.h,
                          child: Row(
                            children: [
                              Text(
                                videoDuration,
                                style: ContextExtension(context).isTablett
                                    ? AppTextStyles.font23WhiteBoldCairo
                                    : AppTextStyles.font16WhiteBoldCairo,
                              ),
                              Expanded(
                                  child: Slider(
                                    min: 0,
                                    max: widget.model.playerController.value.duration
                                        .inMilliseconds
                                        .toDouble(),
                                    thumbColor: AppColors.primary,
                                    activeColor: AppColors.primary,
                                    inactiveColor: AppColors.darkGrey,
                                    value: bufferedVideo,
                                    onChangeStart: (value) {
                                      // Set slide changing to true
                                      // You may need to add this method to MessageCubit
                                    },
                                    onChangeEnd: (value) {
                                      // Set slide changing to false
                                      // You may need to add this method to MessageCubit
                                    },
                                    onChanged: (value) {
                                      widget.model.playerController.seekTo(
                                        Duration(
                                          milliseconds: value.toInt(),
                                        ),
                                      );
                                    },
                                  )),
                              Text(
                                widget.model.duration,
                                style: ContextExtension(context).isTablett
                                    ? AppTextStyles.font23WhiteBoldCairo
                                    : AppTextStyles.font16WhiteBoldCairo,
                              ),
                            ],
                          ),
                        ),
                      ),
                      Align(
                        alignment: Alignment.topRight,
                        child: IconButton(
                          icon: Icon(
                            Icons.close,
                            color: AppColors.inverseBase,
                            size: ContextExtension(context).isTablett ? 32.w : 24.w,
                          ),
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
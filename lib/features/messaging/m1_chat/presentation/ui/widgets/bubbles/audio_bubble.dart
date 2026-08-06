/// Module: messaging / chat / presentation/ui/widgets/bubbles/audio_bubble.dart
// By: Youssef Ashraf, Nada Mohamed
// Last update: 28/8/2024
// Objectives: This file is responsible for providing a widget that represents a audio bubble in the direct messaging view.

part of '../../pages/chat_mobile_view.dart';

class AudioBubble extends StatelessWidget {
  final MessageEntity messageModel;
  final bool isGroup;
  final int index;

  const AudioBubble({
    super.key,
    required this.messageModel,
    required this.isGroup,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    var isMe = messageModel.isMe;
    var isTablet = ContextExtension(context).isTablett;
    final masterChatCubit = context.read<MasterChatCubit>();

    return BlocBuilder<MasterChatCubit, MasterChatState>(
      bloc: masterChatCubit,
      builder: (context, state) {
        return DefaultBubble(
          index: index,
          messageModel: messageModel,
          isGroup: isGroup,
          hideSeen: true,
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  GestureDetector(
                    onTap: () {
                      masterChatCubit.recordAndAudioCubit
                          .startPlayingAudio(messageModel.audio!);
                    },
                    child: SvgPicture.asset(
                      messageModel.audio!.isCurrentPlaying
                          ? AppAssets.pause
                          : AppAssets.play,
                      color: AppColors.icon,
                      width: ContextExtension(context).isTablett ? 32.w : 24.w,
                    ),
                  ),
                  Expanded(
                    child: AudioFileWaveforms(
                      margin: EdgeInsets.zero,
                      playerController: messageModel.audio!.playerController,
                      enableSeekGesture: true,
                      waveformType: WaveformType.fitWidth,
                      playerWaveStyle: PlayerWaveStyle(
                        spacing: AudioRecordService.audioWavesSpacing,
                        waveThickness: 2,
                        fixedWaveColor:
                        isMe ? AppColors.white : AppColors.primary,
                        liveWaveColor: AppColors.black,
                      ),
                      size: Size(isTablet ? 328.w : 146.w, 30.h),
                    ),
                  ),
                ],
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // if not audio loaded, and is an audio voice message
                  if (messageModel.audio!.duration != Duration.zero)
                    Padding(
                      padding: EdgeInsetsDirectional.only(start: 2.w),
                      child: messageModel.audio!.isCurrentPlaying
                          ? TimerCountdown(
                        colonsTextStyle:
                        AppTextStyles.font12BlackCairo.copyWith(
                          color: AppColors.textButton,
                        ),
                        spacerWidth: 0,
                        timeTextStyle:
                        AppTextStyles.font12BlackCairo.copyWith(
                          color: AppColors.textButton,
                        ),
                        enableDescriptions: false,
                        format: messageModel.audio!.countDownTimerFormat,
                        endTime: DateTime.now().add(
                          messageModel.audio!.rate == Speeds.speed_1.name
                              ? messageModel.audio!.duration
                              : messageModel.audio!.speedUpDuration!,
                        ),
                      )
                          : Text(
                        messageModel.audio!.formattedDuration,
                        style: AppTextStyles.font12BlackCairo.copyWith(
                          color: AppColors.textButton,
                        ),
                      ),
                    ),
                  Padding(
                    padding: EdgeInsetsDirectional.only(
                      start: messageModel.audio!.duration != Duration.zero
                          ? 15.w
                          : 4.w,
                    ),
                    child: GestureDetector(
                      onTap: () {
                        masterChatCubit.recordAndAudioCubit
                            .updateAudioSpeed(audio: messageModel.audio!);
                      },
                      child: Text(
                        messageModel.audio!.rate,
                        style: AppTextStyles.font10BlackCairoRegular
                            .copyWith(color: AppColors.textButton),
                      ),
                    ),
                  ),
                  const Spacer(),
                  if (messageModel.isStarred)
                    Padding(
                      padding: EdgeInsetsDirectional.only(
                        end: 4.w,
                        bottom: 2.h,
                      ),
                      child: Icon(
                        Icons.star,
                        color: !isMe
                            ? AppColors.primary
                            : AppTheme.contrastGreyColor(),
                        size: isTablet ? 18.r : 12.r,
                      ),
                    ),
                  Text(
                    DateTimeHelper.formatTime(messageModel.time.toDate()),
                    style: AppTextStyles.font8SecondaryBlackCairo.copyWith(
                      color: !isMe
                          ? AppColors.inverseBase
                          : AppTheme.contrastGreyColor(),
                    ),
                  ),
                  horizontalSpace(4),
                  if (isMe)
                    Icon(
                      messageModel.isSeen ? Icons.done_all : Icons.done,
                      color: /*messageModel.isRead
                          ? AppColors.blue
                          :*/
                      AppColors.secondaryBlack,
                      size: ContextExtension(context).isTablet ? 18.sp : 16.sp,
                    ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
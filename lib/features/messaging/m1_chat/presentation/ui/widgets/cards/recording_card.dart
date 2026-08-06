part of '../../pages/chat_mobile_view.dart';

//Youssef Ashraf

///The card that shows while recording voice note
class RecordingCard extends StatelessWidget {
  const RecordingCard({super.key});

  @override
  Widget build(BuildContext context) {
    // DI via Bloc — MasterChatCubit is provided by ChatMobileView (§3).
    final controller = context.read<MasterChatCubit>();
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      height: 31.h,
      decoration: BoxDecoration(
        color: ContextExtension(context).isTablett ? AppColors.background : AppColors.chatField,
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Row(
        children: [
          BlocBuilder<RecordAndAudioCubit, RecordAndAudioState>(
            bloc: controller.recordAndAudioCubit,
            builder: (context, state) {
              return Text(
                "${state.elapsedMinutes.toString().padLeft(2, '0')}:${state.elapsedSeconds.toString().padLeft(2, '0')}",
                style: AppTextStyles.font12SecondaryBlackCairoMedium,
              );
            },
          ),
          const Spacer(),
          Text(
            S.of(context).swipeLeftToCancel,
            style: AppTextStyles.font12SecondaryBlackCairoMedium.copyWith(
              color: AppColors.red,
            ),
          ),
        ],
      ),
    );
  }
}
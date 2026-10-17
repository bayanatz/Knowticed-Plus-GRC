part of '../../pages/chat_mobile_view.dart';

//Youssef Ashraf
///The card that shows while user selecting messages to be forwarded
class SelectForwardMsgsCard extends StatelessWidget {
  final int selectedMsgsCount;

  const SelectForwardMsgsCard({super.key, required this.selectedMsgsCount});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MessageCubit, MessageState>(
      builder: (context, state) {
        if (state is! MessageLoaded) {
          return const SizedBox();
        }

        final messageCubit = context.read<MessageCubit>();

        return Container(
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          height: ContextExtension(context).isTablet ? 100.h : 80.h,
          decoration: BoxDecoration(
            color: AppTheme.isDark
                ? AppColors.background
                : ContextExtension(context).isPhone
                    ? AppColors.white
                    : AppColors.card,
            borderRadius: BorderRadius.only(
              topRight: Radius.circular(16.r),
              topLeft: Radius.circular(16.r),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () {
                  HapticController.low(); // list row: on the tap (X-117)
                  messageCubit.toggleSelectMessages(false);
                },
                child: Icon(
                  Icons.close,
                  color: AppTheme.isDark ? AppColors.white : null,
                  size: 24.w,
                ),
              ),
              Text(
                '$selectedMsgsCount ${S.of(context).selected}',
                style: StyleText.fontSize18Weight500.copyWith(
                  color: AppTheme.isDark ? AppColors.white : null,
                ),
              ),
              GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () {
                  HapticController.low(); // list row: on the tap (X-117)
                  if (selectedMsgsCount == 0) {
                    return;
                  }
                  if (ContextExtension(context).isTablett) {
                    GetDialogHelper.generalDialog(
                      child: AllChatViewTablet(
                        message: state.selectedForwardMessages,
                      ),
                      context: context,
                    );
                  } else {
                    Navigator.pushNamed(
                      context,
                      Routes.allChatsViewMobile,
                      arguments: {
                        'forwardMessage': state.selectedForwardMessages,
                      },
                    );
                  }
                },
                child: CustomSvgImage.natural(
                  assetPath: AppAssets.forward,
                  width: 24.w,
                  height: 24.h,
                  color: AppTheme.isDark ? AppColors.white : null,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

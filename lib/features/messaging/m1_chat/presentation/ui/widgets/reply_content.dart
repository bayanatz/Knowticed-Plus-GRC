/// Module: messaging / chat / presentation/ui/widgets/reply_content.dart
part of '../pages/chat_mobile_view.dart';

//Youssef Ashraf
///Reply section inside Bubble
class ReplyContent extends StatelessWidget {
  final MessageEntity model;
  final BoxConstraints? constraints;
  final Color? color;
  final EdgeInsetsGeometry? padding;

  const ReplyContent({
    this.constraints,
    super.key,
    required this.model,
    this.color,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding ?? EdgeInsets.zero,
      child: Column(
        children: [
          Container(
            width: double.infinity,
            constraints: constraints ??
                BoxConstraints(
                  maxHeight: 60.h,
                  minHeight: 40.h,
                ),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8.r),
              color: color ?? AppColors.background,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Flexible(
                  child: model.messageType == MessageTypes.cameraImage
                      ? Stack(
                    fit: StackFit.expand,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8.r),
                        child: Image.network(
                          model.mediaLink!,
                          fit: BoxFit.cover,
                        ),
                      ),
                      Container()
                    ],
                  )
                      : Padding(
                    padding: EdgeInsetsDirectional.only(
                      start: 8.w,
                      top: 4.h,
                    ),
                    child: Text(
                      _getDecryptedContent(context),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 2,
                      style: AppTextStyles.font14BlackCairoRegular
                          .copyWith(color: AppColors.text),
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            height: 5.h,
          ),
        ],
      ),
    );
  }

  /// Decrypt the replied message content using MasterChatCubit
  String _getDecryptedContent(BuildContext context) {
    final content = model.messageContent ?? '';
    if (content.isEmpty) return content;
    // Decrypt + error handling live in MasterChatCubit; UI never catches (§11.2).
    return context.read<MasterChatCubit>().decryptMessage(content);
  }
}
/// Module: messaging / chat / presentation/ui/widgets/bubbles/doc_bubble.dart
// By: Youssef Ashraf
// Last update: 8/9/2024
// Objectives: This file is responsible for providing a widget that represents a Doc bubble in the direct messaging view.

part of '../../pages/chat_mobile_view.dart';

class DocBubble extends StatelessWidget {
  final MessageEntity messageModel;
  final bool isGroup;
  final int index;

  const DocBubble({
    super.key,
    required this.messageModel,
    required this.isGroup,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    var isMe = messageModel.isMe;
    final masterChatCubit = context.read<MasterChatCubit>();

    return BlocBuilder<MasterChatCubit, MasterChatState>(
      bloc: masterChatCubit,
      builder: (context, state) {
        return DefaultBubble(
          index: index,
          isGroup: isGroup,
          messageModel: messageModel,
          content: /*messageModel.docMessageModel!.firstPageBytes != null
              ? */
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              InkWell(
                onTap: () {
                  //   if (messageModel.docMessageModel.messageType == MessageTypes.doc) {
                  Get.toNamed(
                    Routes.docView,
                    arguments: {
                      'docMessageModel': messageModel.docMessageModel!
                    },
                  );
                },
                child: Container(
                    padding: EdgeInsets.all(8.sp),
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: /*isTablet ? AppColors.background :*/
                      AppColors.field,
                      borderRadius: BorderRadius.circular(4.r),
                    ),
                    child: Row(
                      spacing: 8.sp,
                      children: [
                        Container(
                            width: 40.sp,
                            height: 40.sp,
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(4.r),
                                image: DecorationImage(
                                    image: appImageProvider(FileTypes.getFileIcon(
                                        messageModel
                                            .docMessageModel!.docPath!))))),
                        Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              spacing: 2.sp,
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                        child: Text(
                                          messageModel.docMessageModel!.fileName!,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: AppTextStyles.font14BlackCairoMedium
                                              .copyWith(fontWeight: FontWeight.w600),
                                        )),
                                  ],
                                ),
                                /* Text(
                                messageModel.docMessageModel!.totalPages.toString() +
                                    ' Pages'.tr +
                                    ' - ' +
                                    (messageModel.docMessageModel!.totalSize! / 1024)
                                        .toStringAsFixed(2) +
                                    ' KB' +
                                    '.${FileHandler.getFileExtension(messageModel.docMessageModel!)}',
                                style: AppTextStyles
                                    .font12SecondaryBlackCairoRegular)*/
                              ],
                            ))
                      ],
                    )),
              )
              /*     GestureDetector(
                onTap: () {
                  Get.toNamed(
                    Routes.docView,
                    arguments: {
                      'docMessageModel': messageModel.docMessageModel!
                    },
                  );
                },
                child: Image.memory(
                  messageModel.docMessageModel!.firstPage!,
                  fit: BoxFit.cover,
                  height: 100.h,
                  width: double.infinity,
                ),
              ),
              Text(
                messageModel.docMessageModel!.fileName!,
                style: isMe
                    ? AppTextStyles.font14BlackCairoRegular
                        .copyWith(color: AppColors.textButton)
                    : AppTextStyles.font14BlackCairoRegular,
                softWrap: true,
              ),
              Wrap(
                children: [
                  Text(
                    '${messageModel.docMessageModel!.totalPages} ${'pages'.tr} • ',
                    style: AppTextStyles.font12InputColorCairo
                        .copyWith(color: AppTheme.contrastGreyColor()),
                  ),
                  horizontalSpace(2),
                  Text(
                    '${messageModel.docMessageModel!.totalSize.toStringAsFixed(2)} ${'MB'.tr} • ',
                    style: AppTextStyles.font12InputColorCairo
                        .copyWith(color: AppTheme.contrastGreyColor()),
                  ),
                  horizontalSpace(2),
                  Text(
                    messageModel.docMessageModel!.extension,
                    style: AppTextStyles.font12InputColorCairo
                        .copyWith(color: AppTheme.contrastGreyColor()),
                  ),
                ],
              ),
              SizedBox(
                height: 10.h,
              ),*/
            ],
          )
          /*         : LinearProgressIndicator(
                  color: AppColors.base,
                  backgroundColor: AppColors.inverseBase,
                )*/
          ,
        );
      },
    );
  }
}
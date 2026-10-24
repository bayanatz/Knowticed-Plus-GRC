/// Module: messaging / chat / presentation/ui/widgets/bubbles/message_bubble.dart
// Date: 6/8/2024
// By: Nada Mohammed
// Last update: 28/8/2024
// Objectives: This file is responsible for providing a widget that represents a message bubble in the direct messaging view.

part of '../../pages/chat_mobile_view.dart';

class MessageBubble extends StatelessWidget {
  final MessageEntity messageModel;
  final bool isGroup;
  final int index;

  const MessageBubble({
    super.key,
    required this.messageModel,
    required this.isGroup,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    var isMe = messageModel.isMe;

    return DefaultBubble(
      index: index,
      isGroup: isGroup,
      messageModel: messageModel,
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsetsDirectional.only(
              bottom: 8.h,
            ),
            child: Text.rich(
              _withMentions(
                context,
                messageModel.messageContent!,
                (isMe
                        ? StyleText.fontSize14Weight400.copyWith(
                            color: AppColors.textButton,
                          )
                        : StyleText.fontSize14Weight400)
                    .copyWith(height: 1.3),
              ),
              softWrap: true,
            ),
          ),
        ],
      ),
    );
  }

  /// Mentions (Figma "Mention", node 741:15786): the stored token
  /// `@name.surname_company.com` becomes `@Name Surname`, in blue.
  ///
  /// FIXED 18/10/2026: GetGroupChatMessageUseCase replaced the tokens BEFORE
  /// the text was decrypted, i.e. on cipher text, so it never matched and a
  /// mention showed as a raw id. It is resolved here, on the plain text.
  TextSpan _withMentions(BuildContext context, String text, TextStyle style) {
    final side = context.read<MasterChatCubit>().state.otherConnectionSide;
    if (side is! GroupEntity || !text.contains('@')) {
      return TextSpan(text: text, style: style);
    }
    final Map<String, String> names = <String, String>{
      for (final MemberEntity m in side.members)
        '@${m.memberId.replaceAll('@', '_')}':
            '@${LocalizedTextHelper.formatString(
          secondaryLanguageText: m.secondaryLanguageName,
          primaryLanguageText: m.primaryLanguageName,
        )}',
    };
    final List<String> keys = names.keys.toList()
      ..sort((String a, String b) => b.length.compareTo(a.length));
    if (keys.isEmpty) return TextSpan(text: text, style: style);
    final RegExp token = RegExp(keys.map(RegExp.escape).join('|'));
    final List<InlineSpan> spans = <InlineSpan>[];
    int at = 0;
    for (final RegExpMatch m in token.allMatches(text)) {
      if (m.start > at) spans.add(TextSpan(text: text.substring(at, m.start)));
      spans.add(TextSpan(
        text: names[m.group(0)],
        style: style.copyWith(
          color: AppColors.blue,
          fontWeight: FontWeight.w500,
        ),
      ));
      at = m.end;
    }
    if (at < text.length) spans.add(TextSpan(text: text.substring(at)));
    return TextSpan(style: style, children: spans);
  }
}

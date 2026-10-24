/// Module: messaging / chat / presentation/ui/widgets/cards/select_forward_msgs_card.dart
///
/// REBUILT 18/10/2026 (owner + Figma "2 Selected", node 686:32114): Forward
/// puts the chat in SELECTION mode and this bar replaces the composer —
/// ✕ (leave selection) · "N Selected" · forward arrow. The arrow opens the
/// people picker (ForwardMessageDialog, multi-select of the standard person
/// card) and forwards every ticked message to every picked person.
///
/// Reads MasterChatCubit — the live chat cubit. The old card read the legacy
/// MessageCubit / ForwardMessageCubit, whose selection was never filled by the
/// real chat, so it always said "0 Selected" and its arrow did nothing.
part of '../../pages/chat_mobile_view.dart';

class ForwardSelectionBar extends StatelessWidget {
  const ForwardSelectionBar({super.key});

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<MasterChatCubit>();
    final int count = cubit.selectedMessageIds.length;

    return Container(
      height: 38.sp,
      padding: EdgeInsetsDirectional.symmetric(horizontal: 10.sp),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Row(
        children: [
          _BarIcon(
            onTap: () => cubit.toggleSelectMessages(false),
            child: Icon(Icons.close, size: 20.sp, color: AppColors.text),
          ),
          Expanded(
            child: Text(
              '${LocalizedNumber.of(context, count)} ${S.of(context).selected}',
              textAlign: TextAlign.center,
              style: StyleText.fontSize14Weight500,
            ),
          ),
          Opacity(
            opacity: count == 0 ? 0.4 : 1,
            child: _BarIcon(
              onTap: count == 0 ? null : () => _pickPeople(context, cubit),
              child: CustomSvgImage.natural(
                assetPath: AppAssets.forward,
                width: 20.sp,
                height: 20.sp,
                color: AppColors.text,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _pickPeople(BuildContext context, MasterChatCubit cubit) {
    // ConnectionsCubit is owned by GetX (see the Forward menu item); the
    // signed-in user is left out — forwarding to yourself is not a chat.
    if (!Get.isRegistered<ConnectionsCubit>() &&
        !Get.isPrepared<ConnectionsCubit>()) {
      return;
    }
    final ConnectionsCubit connections = Get.find<ConnectionsCubit>();
    final String me = connections.currentUser.userId.toLowerCase();
    final List<SingleConnectionEntity> people = connections.connections
        .where((SingleConnectionEntity c) => c.userId.toLowerCase() != me)
        .toList();
    if (people.isEmpty) return;
    ForwardMessageDialog.show(
      context: context,
      connections: people,
      onSend: cubit.forwardSelectedMessages,
    );
  }
}

class _BarIcon extends StatelessWidget {
  const _BarIcon({required this.child, required this.onTap});

  final Widget child;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap == null
          ? null
          : () {
              HapticController.low();
              onTap!();
            },
      child: SizedBox.square(dimension: 30.sp, child: Center(child: child)),
    );
  }
}

/// Module: messaging / chat / presentation/ui/widgets/dialogs/schedule_message_dialog.dart
/// Description: Schedule Message dialog (Figma 6799:16821): message, optional
///          attachment, date and time → Apply stores it with
///          ScheduledMessagesService, which sends it when due.
/// Author: Amr Mesbah
/// Created at: 30/9/2026
library;

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:knowticed_plus/core/custom/buttons/custom_button_with_svg.dart';
import 'package:knowticed_plus/generated/l10n.dart';
import 'package:knowticed_plus/core/custom/dialogs/custom_dialog_manager.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/features/messaging/m1_chat/presentation/controller/main_controllers/master_chat_cubit.dart';
import 'package:knowticed_plus/features/messaging/m1_chat/presentation/ui/widgets/dialogs/chat_dialog_widgets.dart';
import 'package:knowticed_plus/core/theme/app_animations.dart';
import 'package:knowticed_plus/core/theme/haptic_controller.dart';

class _ScheduleRequest {
  const _ScheduleRequest(this.text, this.attachmentPath, this.sendAt);
  final String text;
  final String? attachmentPath;
  final DateTime sendAt;
}

Future<void> showScheduleMessageDialog(
  BuildContext context,
  MasterChatCubit cubit,
) async {
  final bool isAr = chatDialogIsAr(context);
  final _ScheduleRequest? req = await showChatDialog<_ScheduleRequest>(
    context: context,
    width: 550.w,
    radius: 4,
    child: const _ScheduleMessageDialog(),
  );
  if (req == null || !context.mounted) return;

  final bool ok = await CustomDialogManager.runWithLoading<bool>(
    context,
    () => cubit.scheduleMessage(
      text: req.text,
      attachmentPath: req.attachmentPath,
      sendAt: req.sendAt,
    ),
  );
  chatDialogToast(
    ok
        ? (isAr ? 'تمت جدولة الرسالة' : 'Message scheduled')
        : (isAr ? 'تعذر جدولة الرسالة' : 'Could not schedule the message'),
  );
}

class _ScheduleMessageDialog extends StatefulWidget {
  const _ScheduleMessageDialog();

  @override
  State<_ScheduleMessageDialog> createState() => _ScheduleMessageDialogState();
}

class _ScheduleMessageDialogState extends State<_ScheduleMessageDialog> {
  final TextEditingController _message = TextEditingController();
  String? _attachmentPath;
  DateTime? _date;
  TimeOfDay? _time;

  @override
  void dispose() {
    _message.dispose();
    super.dispose();
  }

  Future<void> _pickAttachment() async {
    try {
      final FilePickerResult? result = await FilePicker.platform.pickFiles();
      final String? path = result?.files.single.path;
      if (path != null) setState(() => _attachmentPath = path);
    } catch (e) {
      debugPrint('Ignored error: $e');
    }
  }

  void _apply() {
    final bool isAr = chatDialogIsAr(context);
    final String text = _message.text.trim();
    if (text.isEmpty && _attachmentPath == null) {
      chatDialogToast(
        isAr
            ? 'اكتب رسالة أو أرفق ملفاً'
            : 'Write a message or upload an attachment',
      );
      return;
    }
    final DateTime? sendAt = combineDateTime(_date, _time);
    if (sendAt == null) {
      chatDialogToast(
        isAr ? 'اختر التاريخ والوقت' : 'Choose the date and time',
      );
      return;
    }
    if (!sendAt.isAfter(DateTime.now())) {
      chatDialogToast(
        isAr ? 'اختر وقتاً في المستقبل' : 'Choose a time in the future',
      );
      return;
    }
    Navigator.of(context).pop(_ScheduleRequest(text, _attachmentPath, sendAt));
  }

  @override
  Widget build(BuildContext context) {
    final S s = S.of(context);
    final String? fileName = _attachmentPath?.split('/').last.split('\\').last;
    // CHANGED 20/10/2026 (owner): the app's dialog — circle header, field
    // colours, the app's date picker, "Choose Time", the attachment button at
    // the right edge in line with the fields, Cancel / Apply at the edges.
    return Padding(
      padding: EdgeInsets.all(16.r),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ChatDialogTitle(
            s.scheduleMessage,
            icon: 'assets/icons_assets/main_icons_assets/ic_time_calendar.svg',
          ),
          SizedBox(height: 16.h),
          ChatFieldLabel(s.message),
          ChatTextField(
            controller: _message,
            hint: s.textHere,
            maxLines: 3,
          ),
          SizedBox(height: 12.h),
          Row(
            children: [
              Expanded(
                child: Text(
                  fileName ?? s.uploadAttachment,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: StyleText.fontSize14Weight500.copyWith(
                    color: fileName == null
                        ? AppColors.text
                        : AppColors.secondaryBlack,
                  ),
                ),
              ),
              if (fileName != null)
                GestureDetector(
                  onTapDown: (_) => HapticController.high(),
                  onTap: () => setState(() => _attachmentPath = null),
                  child: Padding(
                    padding: EdgeInsetsDirectional.symmetric(horizontal: 8.sp),
                    child: Icon(
                      Icons.close,
                      size: 16.r,
                      color: AppColors.secondaryBlack,
                    ),
                  ),
                ),
              ShrinkOnTap(
                child: customButtonWithSvg(
                  title: s.uploadAttachment,
                  function: _pickAttachment,
                  textStyle: StyleText.fontSize14Weight500
                      .copyWith(color: AppColors.textButton),
                  color: AppColors.primary,
                  colorBorder: AppColors.primary,
                  image:
                      'assets/icons_assets/main_icons_assets/ic_action_upload.svg',
                  svgColor: AppColors.textButton,
                  widthImage: 16.sp,
                  heightImage: 16.sp,
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    ChatFieldLabel(s.date),
                    ChatDateField(
                      value: _date,
                      onPicked: (d) => setState(() => _date = d),
                    ),
                  ],
                ),
              ),
              SizedBox(width: 16.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    ChatFieldLabel(s.time),
                    ChatTimeField(
                      value: _time,
                      onPicked: (t) => setState(() => _time = t),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 20.h),
          ChatDialogButtons(
            primaryLabel: s.apply,
            onPrimary: _apply,
          ),
        ],
      ),
    );
  }
}

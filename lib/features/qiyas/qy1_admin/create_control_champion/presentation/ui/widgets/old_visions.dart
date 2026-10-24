import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:knowticed_plus/features/qiyas/qy1_admin/create_control_champion/presentation/controller/qiyas_create_champion_controller_cubit.dart';
import 'package:knowticed_plus/features/qiyas/qy1_admin/create_control_core/presentation/controller/control_core_cubit.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';

import 'package:knowticed_plus/features/qiyas/qiyas_get_it.dart';
import 'package:knowticed_plus/features/qiyas/helpers/helper/bubble_text.dart';
import 'package:knowticed_plus/core/custom/dialogs/custom_dialog_manager.dart';

class OldVisions extends StatelessWidget {
  OldVisions({super.key});

  final QiyasCreateChampionControllerCubit controllerCubit = sl();
  final List<String> visions = [];
  final List<String> topics = [];
  final List<String> criteria = [];
  final List<String> documents = [];

  /// Shared delete-confirmation flow for every bubble in this widget.
  void _confirmRemove(
    BuildContext context, {
    required String title,
    required String subtitle,
    required VoidCallback onConfirmed,
  }) {
    CustomDialogManager.showDialogFlow(
      context: context,
      confirmLottie:
          "assets/lottie_assets/qiyas_lottie_assets/lot_action_delete_images.json",
      confirmTitle: title,
      confirmSubtitle: subtitle,
      confirmYesText: "نعم",
      confirmNoText: "لا",
      onConfirm: () async {
        onConfirmed();
        return true;
      },
      successLottie:
          "assets/lottie_assets/main_lottie_assets/lot_status_success.json",
      successTitle: title,
      successSubtitle: "تمت العملية بنجاح",
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<QiyasCreateChampionControllerCubit, ControlCoreState>(
      bloc: controllerCubit,
      buildWhen: (_, __) {
        return true;
      },
      builder: (context, state) {
        visions
          ..clear()
          ..addAll(controllerCubit.getUserUniqueVisions());
        topics
          ..clear()
          ..addAll(controllerCubit.getUserUniqueTopics());
        criteria
          ..clear()
          ..addAll(controllerCubit.getUserUniqueCriteria());
        documents
          ..clear()
          ..addAll(controllerCubit.getUserUniqueDocuments());
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [Text('النمظور', style: StyleText.fontSize14Weight500)],
            ),
            SizedBox(height: 8.sp),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                spacing: 10.sp,
                children: [
                  for (int visionIndex = 0;
                      visionIndex < visions.length;
                      visionIndex++)
                    BubbleText(
                      text: visions[visionIndex],
                      onTap: () => _confirmRemove(
                        context,
                        title: "حذف المنظور",
                        subtitle: "هل انت متاكد من انك تريد حذف المنظور؟",
                        onConfirmed: () => controllerCubit.removeSelectedVision(
                            text: visions[visionIndex], isVision: true),
                      ),
                    ),
                ],
              ),
            ),
            SizedBox(height: 20.sp),
            Row(
              children: [
                Text('المحاور ', style: StyleText.fontSize14Weight500)
              ],
            ),
            SizedBox(height: 8.sp),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                spacing: 10.sp,
                children: [
                  for (int topicIndex = 0;
                      topicIndex < topics.length;
                      topicIndex++)
                    BubbleText(
                      text: topics[topicIndex],
                      onTap: () => _confirmRemove(
                        context,
                        title: "حذف المحور",
                        subtitle: "هل انت متاكد من انك تريد حذف المحور؟",
                        onConfirmed: () => controllerCubit.removeSelectedVision(
                            text: topics[topicIndex], isTopic: true),
                      ),
                    ),
                ],
              ),
            ),
            SizedBox(height: 20.sp),
            Row(
              children: [
                Text('المعيار ', style: StyleText.fontSize14Weight500)
              ],
            ),
            SizedBox(height: 8.sp),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                spacing: 10.sp,
                children: [
                  for (int criterionIndex = 0;
                      criterionIndex < criteria.length;
                      criterionIndex++)
                    BubbleText(
                      text: criteria[criterionIndex],
                      onTap: () => _confirmRemove(
                        context,
                        title: "حذف المعيار",
                        subtitle: "هل انت متاكد من انك تريد حذف المعيار؟",
                        onConfirmed: () => controllerCubit.removeSelectedVision(
                            text: criteria[criterionIndex], isCriterion: true),
                      ),
                    ),
                ],
              ),
            ),
            SizedBox(height: 20.sp),
            Row(
              children: [
                Text('المستندات', style: StyleText.fontSize14Weight500)
              ],
            ),
            SizedBox(height: 8.sp),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                spacing: 10.sp,
                children: [
                  for (int documentIndex = 0;
                      documentIndex < documents.length;
                      documentIndex++)
                    BubbleText(
                      text: documents[documentIndex],
                      onTap: () => _confirmRemove(
                        context,
                        title: "حذف المستند",
                        subtitle: "هل انت متاكد من انك تريد حذف المستند؟",
                        onConfirmed: () => controllerCubit.removeSelectedVision(
                            text: documents[documentIndex], isDocument: true),
                      ),
                    ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}

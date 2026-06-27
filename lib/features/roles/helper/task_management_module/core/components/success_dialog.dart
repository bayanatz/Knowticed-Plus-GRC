import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:demo_app/features/roles/core_widgets/dialogs/response_dialog.dart';

/// Success/result dialog.
///
/// Used as a widget — `SuccessDialog(title:, subtitle:, lottieAsset:)` — and
/// rendered via demo_app's [ResponseDialog]. The static [show] helper is kept
/// for callers that just need a quick success alert.
class SuccessDialog extends StatelessWidget {
  const SuccessDialog({
    super.key,
    required this.title,
    required this.subtitle,
    required this.lottieAsset,
  });

  final String title;
  final String subtitle;
  final String lottieAsset;

  static void show(BuildContext context, {String? message}) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Success'.tr),
        content: message != null ? Text(message) : null,
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('OK'.tr),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ResponseDialog(
      title: title,
      subtitle: subtitle,
      lottieAsset: lottieAsset,
    );
  }
}

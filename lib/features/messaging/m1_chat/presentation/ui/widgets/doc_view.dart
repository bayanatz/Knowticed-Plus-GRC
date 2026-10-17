/// Module: messaging / chat / presentation/ui/widgets/doc_view.dart
library;

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:pdfx/pdfx.dart';

import 'package:grc_module/core/theme/app_colors.dart';
import 'package:grc_module/core/extensions/context_extensions.dart';
import 'package:grc_module/features/messaging/m1_chat/data/models/message/doc_message_model.dart';
import 'package:grc_module/core/theme/haptic_controller.dart';

//Youssef Ashraf
class DocView extends StatelessWidget {
  final DocMessageModel model;
  const DocView({super.key, required this.model});

  @override
  Widget build(BuildContext context) {
    final pdfController =
        PdfController(document: PdfDocument.openFile(model.docPath));

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Stack(
          children: [
            PdfView(
              controller: pdfController,
              renderer: (page) =>
                  page.render(width: page.width, height: page.height),
            ),
            Align(
              alignment: Alignment.topRight,
              child: IconButton(
                icon: Icon(
                  Icons.close,
                  color: AppColors.secondaryBlack,
                  size: ContextExtension(context).isTablett ? 32.w : 24.w,
                ),
                onPressed: () {
                  HapticController.low();
                  Get.back();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

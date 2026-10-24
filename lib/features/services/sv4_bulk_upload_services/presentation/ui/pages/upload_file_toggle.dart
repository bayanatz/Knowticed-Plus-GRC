/// Module: services / sv4_bulk_upload_services / presentation / ui / pages
///
///*************************** FILE INFO ****************************///
/// File Name: upload_file_toggle.dart
/// Purpose: toggle in All Platform of this screen
/// Author: Amr Mesbah
/// Created At: 18/10/2026
library;

import 'package:flutter/material.dart';
import 'package:knowticed_plus/features/services/sv4_bulk_upload_services/presentation/ui/pages/upload_file.dart';

class ToggleUploadFile extends StatelessWidget {
  const ToggleUploadFile({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constrain) {
          if (constrain.maxWidth >= 1200) {
            return UploadFileTablet(); // Desktop
          } else if (constrain.maxWidth >= 900) {
            return UploadFileTablet(); // Horizontal tablet
          } else if (constrain.maxWidth >= 600) {
            return UploadFileTablet(); // // tablet
          } else {
            return Center(child: Text("// mobile")); // mobile
          }
        },
      ),
    );
  }
}

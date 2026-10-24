/// Module: services / sv4_bulk_upload_services / presentation / ui / pages
///
///*************************** FILE INFO ****************************///
/// File Name: create_new_services_toggle.dart
/// Purpose: toggle in All Platform of this screen
/// Author: Amr Mesbah
/// Created At: 18/10/2026
library;

import 'package:flutter/material.dart';
import 'package:knowticed_plus/features/services/data/models/services_history_model.dart';
// ✅ UPDATED: Import the new refactored screen instead of the old one
import 'package:knowticed_plus/features/services/sv4_bulk_upload_services/presentation/ui/pages/create_new_services.dart'; // Remove this if no longer needed
import 'package:knowticed_plus/core/extensions/context_extensions.dart';

class CreateNewServicesLayout extends StatelessWidget {
  final ServicesHistoryModel? editingModel;
  final String? docId;

  const CreateNewServicesLayout({super.key, this.editingModel, this.docId});

  @override
  Widget build(BuildContext context) {
    ContextExtension(context).isTablet;
    ContextExtension(context).isLandscape;

    return Scaffold(
      body: Builder(
        builder: (context) {
          // ✅ SIMPLIFIED: All conditions return the same new screen
          // You can simplify this since all branches are identical
          return CreateServiceScreen(editingModel: editingModel, docId: docId);
        },
      ),
    );
  }
}

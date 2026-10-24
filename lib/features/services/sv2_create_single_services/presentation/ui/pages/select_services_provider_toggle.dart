/// Module: services / sv2_create_single_services / presentation / ui / pages
///
///*************************** FILE INFO ****************************///
/// File Name: select_services_provider_toggle.dart
/// Purpose: toggle in All Platform of this screen Created by: Amr Mesbah Last
///          Update: 6/2/2026
/// Author: Amr Mesbah
/// Created At: 18/10/2026
library;

import 'package:flutter/material.dart';
import 'package:knowticed_plus/features/services/sv2_create_single_services/presentation/ui/pages/select_services_provider.dart';

import 'package:knowticed_plus/features/services/data/models/services_history_model.dart';
import 'package:knowticed_plus/core/extensions/context_extensions.dart';

class ServicesProviderLayout extends StatelessWidget {
  final ServicesHistoryModel? editingModel;
  final String? docId;
  final ServicesHistoryModel? editProvider;

  const ServicesProviderLayout({
    super.key,
    this.editingModel,
    this.docId,
    this.editProvider,
  });

  @override
  Widget build(BuildContext context) {
    final isTablet = ContextExtension(context).isTablet;
    final isLandscape = ContextExtension(context).isLandscape;

    // Determine which widget to show based on device type
    final Widget child;

    if (isTablet && isLandscape) {
      // Tablet Landscape
      child = SelectServicesProviderPage(
        editingModel: editingModel,
        docId: docId,
        editProvider: editProvider,
      );
    } else if (isTablet && !isLandscape) {
      // Tablet Portrait
      child = SelectServicesProviderPage(
        editingModel: editingModel,
        docId: docId,
        editProvider: editProvider,
      );
    } else if (!isTablet && isLandscape) {
      // Phone Landscape
      child = SelectServicesProviderPage(
        editingModel: editingModel,
        docId: docId,
        editProvider: editProvider,
      );
    } else {
      // Phone Portrait
      child = SelectServicesProviderPage(
        editingModel: editingModel,
        docId: docId,
        editProvider: editProvider,
      );
    }

    return Scaffold(body: child);
  }
}

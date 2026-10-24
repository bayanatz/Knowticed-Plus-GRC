/// Module: services / sv2_create_single_services / presentation / ui / pages
///
///*************************** FILE INFO ****************************///
/// File Name: sla_screen_page_toggle.dart
/// Purpose: toggle in All Platform of this screen Created by: Amr Mesbah Last
///          Update: 30/8/2025
/// Author: Amr Mesbah
/// Created At: 18/10/2026
library;

import 'package:flutter/material.dart';
import 'package:knowticed_plus/features/services/sv2_create_single_services/presentation/ui/pages/sla_screen_page.dart';

import 'package:knowticed_plus/features/services/data/models/services_history_model.dart';
import 'package:knowticed_plus/features/services/sv2_create_single_services/presentation/ui/pages/sla_screen_mobile.dart';
import 'package:knowticed_plus/core/extensions/context_extensions.dart';

class ToggleSlaScreen extends StatelessWidget {
  final ServicesHistoryModel? editingModel;

  const ToggleSlaScreen({super.key, this.editingModel});

  @override
  Widget build(BuildContext context) {
    final isTablet = ContextExtension(context).isTablet;
    final isLandscape = ContextExtension(context).isLandscape;
    return Scaffold(
      body: Builder(
        builder: (context) {
          if (isTablet && isLandscape) {
            return SlaScreenPageTablet(editingModel: editingModel); // tablet
          } else if (isTablet && !isLandscape) {
            return SlaScreenPageTablet(editingModel: editingModel); // tablet
          } else if (!isTablet && isLandscape) {
            return SlaScreenMobile(editingModel: editingModel); // mobile
          } else {
            return SlaScreenMobile(editingModel: editingModel); // mobile
          }
        },
      ),
    );
  }
}

/*
return Scaffold(
body: LayoutBuilder(
builder: (context, constrain) {
if (constrain.maxWidth >= 1200) {
return SlaScreenFullScreen(); // Desktop
} else if (constrain.maxWidth >= 900) {
return SlaScreenDesktop(); // Horizontal tablet
} else if (constrain.maxWidth >= 600) {
return SlaScreenPageTablet(editingModel: editingModel); // tablet
} else {
return SlaScreenMobile(editingModel: editingModel); // mobile
}
},
),
);
 */

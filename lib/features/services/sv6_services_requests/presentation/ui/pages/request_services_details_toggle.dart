/// Module: services / sv6_services_requests / presentation / ui / pages
///
///*************************** FILE INFO ****************************///
/// File Name: request_services_details_toggle.dart
/// Purpose: Picks the phone, tablet or desktop layout of the service request
///          details page.
/// Author: Amr Mesbah
/// Created at: 06/10/2026
library;

import 'package:flutter/material.dart';
import 'package:knowticed_plus/features/services/data/models/services_history_model.dart';
import 'package:knowticed_plus/features/services/sv6_services_requests/presentation/ui/pages/request_details.dart';
import 'package:knowticed_plus/core/extensions/context_extensions.dart';

class RequestServicesDetailsToggle extends StatelessWidget {
  const RequestServicesDetailsToggle({required this.requestModel, super.key});
  final ServicesHistoryModel requestModel;

  @override
  Widget build(BuildContext context) {
    final isTablet = ContextExtension(context).isTablet;
    final isLandscape = ContextExtension(context).isLandscape;
    return Scaffold(
      body: Builder(
        builder: (context) {
          if (isTablet && isLandscape) {
            return RequestServicesDetails(requestModel: requestModel);
          } else if (isTablet && !isLandscape) {
            return RequestServicesDetails(requestModel: requestModel);
          } else if (!isTablet && isLandscape) {
            return RequestServicesDetails(requestModel: requestModel);
          } else {
            return RequestServicesDetails(requestModel: requestModel);
          }
        },
      ),
    );
  }
}

/*
return Scaffold(
body: LayoutBuilder(
builder: (context, constrain){

if (constrain.maxWidth >= 1200) {
return RequestServicesDetailsFullScreen(requestModel:requestModel); // Desktop
} else if (constrain.maxWidth >= 900) {
return RequestServicesDetailsDesktop(requestModel:requestModel ,); // Horizontal tablet
} else if (constrain.maxWidth >= 600) {
return RequestServicesDetailsTablet(requestModel: requestModel,); // // tablet
} else {
return RequestServicesDetailsMobile(requestModel: requestModel); // mobile
}


}),
);

 */

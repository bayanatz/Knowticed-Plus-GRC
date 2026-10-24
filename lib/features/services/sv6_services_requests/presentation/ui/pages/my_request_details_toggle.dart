/// Module: services / sv6_services_requests / presentation / ui / pages
///
///*************************** FILE INFO ****************************///
/// File Name: my_request_details_toggle.dart
/// Purpose: Picks the phone, tablet or desktop layout of the "My request"
///          details page.
/// Author: Amr Mesbah
/// Created at: 30/08/2025
library;

import 'package:flutter/material.dart';
import 'package:knowticed_plus/features/services/data/models/services_history_model.dart';
import 'package:knowticed_plus/features/services/sv6_services_requests/presentation/ui/pages/my_request_details.dart';
import 'package:knowticed_plus/core/extensions/context_extensions.dart';

class MyRequestDetailsServicesToggle extends StatelessWidget {
  const MyRequestDetailsServicesToggle({
    required this.myRequestDetailsModel,
    super.key,
  });

  final ServicesHistoryModel myRequestDetailsModel;

  @override
  Widget build(BuildContext context) {
    final isTablet = ContextExtension(context).isTablet;
    final isLandscape = ContextExtension(context).isLandscape;

    return Scaffold(
      body: isTablet
          ? (isLandscape
              // Tablet • Landscape
              ? MyRequestDetails(myRequestDetailsModel: myRequestDetailsModel)
              // Tablet • Portrait
              : MyRequestDetails(
                  myRequestDetailsModel: myRequestDetailsModel,
                ))
          : (isLandscape
              // Phone • Landscape
              ? MyRequestDetails(myRequestDetailsModel: myRequestDetailsModel)
              // Phone • Portrait
              : MyRequestDetails(
                  myRequestDetailsModel: myRequestDetailsModel,
                )),
    );
  }
}

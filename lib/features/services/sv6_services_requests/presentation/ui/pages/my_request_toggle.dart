/// Module: services / sv6_services_requests / presentation / ui / pages
///
///*************************** FILE INFO ****************************///
/// File Name: my_request_toggle.dart
/// Purpose: Picks the phone, tablet or desktop layout of the "My requests"
///          page.
/// Author: Amr Mesbah
/// Created at: 30/08/2025
library;

import 'package:flutter/material.dart';
import 'package:knowticed_plus/features/services/sv6_services_requests/presentation/ui/pages/my_request.dart';
import 'package:knowticed_plus/core/extensions/context_extensions.dart';

class MyRequestServicesToggle extends StatelessWidget {
  const MyRequestServicesToggle({super.key});

  @override
  Widget build(BuildContext context) {
    final isTablet = ContextExtension(context).isTablet;
    final isLandscape = ContextExtension(context).isLandscape;
    return Scaffold(
      body: Builder(
        builder: (context) {
          if (isTablet && isLandscape) {
            return MyRequestServices(); // Or tablet Landscape
          } else if (isTablet && !isLandscape) {
            return const MyRequestServices();
          } else if (!isTablet && isLandscape) {
            return MyRequestServices();
          } else {
            return MyRequestServices();
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
return MyRequestServicesFullScreen(); // Desktop
} else if (constrain.maxWidth >= 900) {
return MyRequestServicesDesktop(); // Horizontal tablet
} else if (constrain.maxWidth >= 600) {
return MyRequestServicesTablet(); // // tablet
} else {
return MyRequestServicesMobile();  // mobile
}

}),
);
 */

/// Module: services / sv6_services_requests / presentation / ui / pages
///
///*************************** FILE INFO ****************************///
/// File Name: request_services_toggle.dart
/// Purpose: Picks the phone, tablet or desktop layout of the "Service
///          requests" page.
/// Author: Amr Mesbah
/// Created at: 30/08/2025
library;

import 'package:flutter/material.dart';
import 'package:knowticed_plus/features/services/sv6_services_requests/presentation/ui/pages/request_services.dart';
import 'package:knowticed_plus/core/extensions/context_extensions.dart';

class RequestServicesToggle extends StatelessWidget {
  const RequestServicesToggle({super.key});

  @override
  Widget build(BuildContext context) {
    final isTablet = ContextExtension(context).isTablet;
    final isLandscape = ContextExtension(context).isLandscape;
    return Scaffold(
      body: Builder(
        builder: (context) {
          if (isTablet && isLandscape) {
            return RequestServicesPage(); // Or tablet Landscape
          } else if (isTablet && !isLandscape) {
            return const RequestServicesPage();
          } else if (!isTablet && isLandscape) {
            return RequestServicesPage();
          } else {
            return RequestServicesPage();
          }
        },
      ),
    );
  }
}

/*
return Scaffold(
body: Builder(
builder: (context) {
final width = MediaQuery.of(context).size.width;
final orientation = MediaQuery.of(context).orientation;

if (width >= 1200) {
return RequestServicesDesktop();
} else if (width >= 900 && orientation == Orientation.landscape) {
return RequestServicesDesktop(); // Responsive tablet landscape
} else if (width >= 600 && orientation == Orientation.portrait) {
return RequestServicesTablet();
} else {
return RequestServicesMobile();
}
},
),
);
 */

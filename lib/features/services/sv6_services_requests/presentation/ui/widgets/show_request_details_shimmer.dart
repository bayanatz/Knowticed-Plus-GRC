/// Module: services / sv6_services_requests / presentation / ui / widgets
///
///*************************** FILE INFO ****************************///
/// File Name: show_request_details_shimmer.dart
/// Purpose: Shimmer placeholder bar used while the "My request" provider block
///          loads.
/// Author: Amr Mesbah
/// Created at: 06/10/2026
library;

import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

import 'package:knowticed_plus/core/theme/app_colors.dart';

Widget shimmerPlaceholder(
  BuildContext context, {
  double width = double.infinity,
  double height = 20,
}) {
  return Shimmer.fromColors(
    baseColor: Theme.of(context).brightness == Brightness.light
        ? AppColors.white
        : AppColors.background,
    highlightColor: AppColors.chatBackground,
    direction: ShimmerDirection.ltr,
    child: Container(
      width: width,
      height: height,
      decoration: BoxDecoration(color: AppColors.card),
    ),
  );
}

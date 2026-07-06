// ******************* FILE INFO *******************
// File Name: services_colors
// Description: Named colour constants for services dashboards (§12 — no raw
//   Color(0xFF…) literals inside widgets).
// Module: core / constants / services_management
// *************************************************

import 'package:flutter/material.dart';

/// Named colours used by the services admin-dashboard widgets. Centralising
/// them keeps raw hex literals out of the widget tree (§12).
class ServicesColors {
  const ServicesColors._();

  // Pie-chart palette (gold -> dark red gradient).
  static const Color chartGold = Color(0xFFFFD700);
  static const Color chartOrange = Color(0xFFFF9500);
  static const Color chartAmber = Color(0xFFD4780A);
  static const Color chartBrown = Color(0xFF8B5200);
  static const Color chartDarkRed = Color(0xFF730606);

  // Table backgrounds (light / dark).
  static const Color tableLightBackground = Color(0xFFF7F8FA);
  static const Color tableDarkBackground = Color(0xFF1E1F24);

  // Disabled / neutral button background.
  static const Color disabledButton = Color(0xFFCCCCCCCC);

  // Mobile-dashboard chart palette (master mobile).
  static const Color chartGreen = Color(0xFF378309);
  static const Color chartYellow = Color(0xFFFFCC00);
  static const Color chartCrimson = Color(0xFF950E0E);
  static const Color chartGoldDeep = Color(0xFFE5C100);
  static const Color chartGoldPale = Color(0xFFE3D38C);
  static const Color chartGoldBright = Color(0xFFFFDE59);
  static const Color chartOlive = Color(0xFFA18A2D);
  static const Color chartAmberDeep = Color(0xFFE5B800);
  static const Color chartGreyOlive = Color(0xFF807B69);
  static const Color chartGrey = Color(0xFF8D8D8D);
  static const Color chartLightGrey = Color(0xFFCACACA);
  static const Color chartTaupe = Color(0xFF6B5650);
  static const Color chartMocha = Color(0xFF795548);
}

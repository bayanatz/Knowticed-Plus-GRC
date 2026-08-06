import 'dart:io';

import 'package:flutter/material.dart';

abstract class IconSizeHelper {
  static double getIconSize(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    bool isDesktop = Platform.isLinux || Platform.isMacOS || Platform.isWindows;

    if (isDesktop && screenHeight >= 611 && screenHeight < 810) {
      return 1;
    } else if (isDesktop && screenHeight >= 810 && screenHeight < 900) {
      return 1.2;
    } else if (isDesktop && screenHeight >= 900 && screenHeight < 950) {
      return 1.2;
    } else if (isDesktop && screenHeight >= 950 && screenHeight < 1000) {
      return 1.4;
    } else if (isDesktop && screenHeight >= 1000) {
      return 1.4;
    }

    return 1.3;
  }

}
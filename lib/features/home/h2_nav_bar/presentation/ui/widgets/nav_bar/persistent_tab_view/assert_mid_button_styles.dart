/// Module: home/h2_nav_bar
///
///*************************** FILE INFO ****************************///
/// File Name: assert_mid_button_styles.dart
/// Description: `assertMidButtonStyles()` — split out of `persistent_tab_view.dart`.
/// Author: Amr Mesbah
/// Created at: 11/10/2026

part of '../persistent_tab_view.dart';

// Split from persistent_tab_view.dart to keep every file under 700 lines.

//asserts

bool assertMidButtonStyles(final NavBarStyle navBarStyle, final int itemCount) {
  if (navBarStyle == NavBarStyle.style15 ||
      navBarStyle == NavBarStyle.style16 ||
      navBarStyle == NavBarStyle.style17 ||
      navBarStyle == NavBarStyle.style18) {
    if (itemCount % 2 != 0) {
      return true;
    } else {
      return false;
    }
  }
  return true;
}

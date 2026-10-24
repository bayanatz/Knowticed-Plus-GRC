/// Module: home/h2_nav_bar
///
///*************************** FILE INFO ****************************///
/// File Name: persistent_tab_view_base.dart
/// Description: `PersistentTabViewBase` widget — split out of `persistent_tab_view.dart`.
/// Author: Amr Mesbah
/// Created at: 11/10/2026

part of '../persistent_tab_view.dart';

// Split from persistent_tab_view.dart to keep every file under 700 lines.

class PersistentTabViewBase extends StatefulWidget {
  const PersistentTabViewBase({
    super.key,
    this.screens,
    this.controller,
    this.floatingActionButton,
    this.margin,
    this.confineInSafeArea,
    this.handleAndroidBackButtonPress,
    this.bottomScreenMargin,
    this.resizeToAvoidBottomInset,
    this.stateManagement,
    this.screenTransitionAnimation,
    this.hideNavigationBar,
    this.context,
    this.items,
    this.backgroundColor,
    this.onItemSelected,
    this.decoration,
    this.padding,
    this.navBarStyle,
    this.neumorphicProperties,
    this.navBarHeight,
    this.customWidget,
    this.itemCount,
    this.popAllScreensOnTapOfSelectedTab,
    this.popAllScreensOnTapAnyTabs,
    this.popActionScreens,
    this.onWillPop,
    this.hideNavigationBarWhenKeyboardShows,
    this.itemAnimationProperties,
    this.isCustomWidget,
    this.selectedTabScreenContext,
    this.routeAndNavigatorSettings,
  });

  ///List of persistent bottom navigation bar items to be displayed in the navigation bar.
  final List<PersistentBottomNavBarItem>? items;

  ///Screens that will be displayed on tapping of persistent bottom navigation bar items.
  final List<Widget>? screens;

  ///Controller for persistent bottom navigation bar. Will be declared if left empty.
  final PersistentTabController? controller;

  ///Background color of bottom navigation bar. `white` by default.
  final Color? backgroundColor;

  ///Callback when page or tab change is detected.
  final ValueChanged<int>? onItemSelected;

  ///Specifies the curve properties of the NavBar.
  final NavBarDecoration? decoration;

  ///`padding` for the persistent navigation bar content. Accepts `NavBarPadding` instead of `EdgeInsets`.
  ///
  ///`USE WITH CAUTION, MAY CAUSE LAYOUT ISSUES`.
  final NavBarPadding? padding;

  ///Style for persistent bottom navigation bar. Accepts `NavBarStyle` to determine the theme.
  final NavBarStyle? navBarStyle;

  ///Style the `neumorphic` navigation bar item.
  ///
  ///Works only with style `neumorphic`.
  final NeumorphicProperties? neumorphicProperties;

  ///A custom widget which is displayed at the bottom right of the display at all times.
  final Widget? floatingActionButton;

  ///Specifies the navBarHeight
  ///
  ///Defaults to `kBottomNavigationBarHeight` which is `56.0`.
  final double? navBarHeight;

  ///The margin around the navigation bar.
  final EdgeInsets? margin;

  ///Custom navigation bar widget. To be only used when `navBarStyle` is set to `NavBarStyle.custom`.
  final Widget? customWidget;

  ///If using `custom` navBarStyle, define this instead of the `items` property
  final int? itemCount;

  ///Will confine the NavBar's items in the safe area defined by the device.
  final bool? confineInSafeArea;

  ///Handles android back button actions. Defaults to `true`.
  ///
  ///Action based on scenarios:
  ///1. If the you are on the first tab with all screens popped of the given tab, the app will close.
  ///2. If you are on another tab with all screens popped of that given tab, you will be switched to first tab.
  ///3. If there are screens pushed on the selected tab, a screen will pop on a respective back button press.
  final bool? handleAndroidBackButtonPress;

  ///Bottom margin of the screen.
  final double? bottomScreenMargin;

  ///If an already selected tab is pressed/tapped again, all the screens pushed on that particular tab will pop until the first screen in the stack. Defaults to `true`.
  final bool? popAllScreensOnTapOfSelectedTab;

  ///All the screens pushed on that particular tab will pop until the first screen in the stack, whether the tab is already selected or not. Defaults to `false`.
  final bool? popAllScreensOnTapAnyTabs;

  ///If set all pop until to first screen else set once pop once
  final PopActionScreensType? popActionScreens;

  final bool? resizeToAvoidBottomInset;

  ///Preserves the state of each tab's screen. `true` by default.
  final bool? stateManagement;

  ///If you want to perform a custom action on Android when exiting the app, you can write your logic here.
  final Future<bool> Function(BuildContext)? onWillPop;

  ///Screen transition animation properties when switching tabs.
  final ScreenTransitionAnimation? screenTransitionAnimation;

  final bool? hideNavigationBarWhenKeyboardShows;

  ///This controls the animation properties of the items of the NavBar.
  final ItemAnimationProperties? itemAnimationProperties;

  ///Hides the navigation bar with an transition animation. Use it in conjuction with [Provider](https://pub.dev/packages/provider) for better results.
  final bool? hideNavigationBar;

  ///Define navigation bar route name and settings here.
  ///
  ///If you want to programmatically pop to initial screen on a specific use this route name when popping.
  final CustomWidgetRouteAndNavigatorSettings? routeAndNavigatorSettings;

  final bool? isCustomWidget;

  final BuildContext? context;

  final Function(BuildContext)? selectedTabScreenContext;

  @override
  State<PersistentTabView> createState() => _PersistentTabViewState();
}

import 'dart:math';
import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:demo_app/core/helper/data_grc_module/feature/nav_bar_package.dart/animation.dart';
import 'package:demo_app/core/helper/data_grc_module/feature/nav_bar_package.dart/nav_bar_package.dart';
import 'package:demo_app/core/helper/data_grc_module/feature/nav_bar_package.dart/styles.dart';
import 'package:demo_app/core/helper/data_grc_module/feature/nav_bar_package.dart/utiles.dart';

class ScreenTransitionAnimation {
  const ScreenTransitionAnimation({
    this.animateTabTransition = false,
    this.duration = const Duration(milliseconds: 200),
    this.curve = Curves.ease,
  });
  final bool animateTabTransition;
  final Duration duration;
  final Curve curve;
}

class ItemAnimationProperties {
  const ItemAnimationProperties({this.duration, this.curve});
  final Duration? duration;
  final Curve? curve;
}

class NavBarEssentials {
  const NavBarEssentials({
    required this.items,
    this.selectedIndex,
    this.previousIndex,
    this.backgroundColor,
    this.popScreensOnTapOfSelectedTab,
    this.popAllScreensOnTapAnyTabs,
    this.itemAnimationProperties,
    this.navBarHeight = 0.0,
    this.onItemSelected,
    this.padding,
    this.selectedScreenBuildContext,
  });

  final int? selectedIndex;
  final int? previousIndex;
  final Color? backgroundColor;
  final List<PersistentBottomNavBarItem>? items;
  final ValueChanged<int>? onItemSelected;
  final double? navBarHeight;
  final NavBarPadding? padding;
  final bool? popScreensOnTapOfSelectedTab;
  final bool? popAllScreensOnTapAnyTabs;
  final ItemAnimationProperties? itemAnimationProperties;
  final BuildContext? selectedScreenBuildContext;

  NavBarEssentials copyWith({
    final int? selectedIndex,
    final int? previousIndex,
    final double? iconSize,
    final Color? backgroundColor,
    final List<PersistentBottomNavBarItem>? items,
    final ValueChanged<int>? onItemSelected,
    final double? navBarHeight,
    final NavBarPadding? padding,
    final Function(int)? popAllScreensForTheSelectedTab,
    final bool? popScreensOnTapOfSelectedTab,
    final ItemAnimationProperties? itemAnimationProperties,
  }) =>
      NavBarEssentials(
        selectedIndex: selectedIndex ?? this.selectedIndex,
        previousIndex: previousIndex ?? this.previousIndex,
        backgroundColor: backgroundColor ?? this.backgroundColor,
        items: items ?? this.items,
        onItemSelected: onItemSelected ?? this.onItemSelected,
        navBarHeight: navBarHeight ?? this.navBarHeight,
        padding: padding ?? this.padding,
        popScreensOnTapOfSelectedTab:
            popScreensOnTapOfSelectedTab ?? this.popScreensOnTapOfSelectedTab,
        itemAnimationProperties:
            itemAnimationProperties ?? this.itemAnimationProperties,
      );
}

class NavBarPadding {
  const NavBarPadding.only({this.top, this.bottom, this.right, this.left});

  const NavBarPadding.symmetric(
      {final double? horizontal, final double? vertical})
      : top = vertical,
        bottom = vertical,
        right = horizontal,
        left = horizontal;

  const NavBarPadding.all(final double? value)
      : top = value,
        bottom = value,
        right = value,
        left = value;

  const NavBarPadding.fromLTRB(this.top, this.bottom, this.right, this.left);
  final double? top;
  final double? bottom;
  final double? right;
  final double? left;
}

class NeumorphicProperties {
  const NeumorphicProperties({
    this.bevel = 12.0,
    this.borderRadius = 15.0,
    this.border,
    this.shape = BoxShape.rectangle,
    this.curveType = CurveType.concave,
    this.showSubtitleText = false,
  });
  final double bevel;
  final double borderRadius;
  final BoxBorder? border;
  final BoxShape shape;
  final CurveType curveType;
  final bool showSubtitleText;
}

enum PageTransitionAnimation {
  cupertino,
  slideRight,
  scale,
  rotate,
  sizeUp,
  fade,
  scaleRotate,
  slideUp
}

Widget _slideRightRoute(
        final BuildContext context,
        final Animation<double> animation,
        final Animation<double> secondaryAnimation,
        final Widget? child) =>
    SlideTransition(
        position: Tween<Offset>(begin: const Offset(-1, 0), end: Offset.zero)
            .animate(animation),
        child: child);

Widget _slideUp(final BuildContext context, final Animation<double> animation,
        final Animation<double> secondaryAnimation, final Widget? child) =>
    SlideTransition(
        position: Tween<Offset>(begin: const Offset(0, 1), end: Offset.zero)
            .animate(animation),
        child: child);

Widget _scaleRoute(
        final BuildContext context,
        final Animation<double> animation,
        final Animation<double> secondaryAnimation,
        final Widget? child) =>
    ScaleTransition(
        scale: Tween<double>(begin: 0, end: 1).animate(
            CurvedAnimation(parent: animation, curve: Curves.fastOutSlowIn)),
        child: child);

Widget _rotationRoute(
        final BuildContext context,
        final Animation<double> animation,
        final Animation<double> secondaryAnimation,
        final Widget? child) =>
    RotationTransition(
        turns: Tween<double>(begin: 0, end: 1)
            .animate(CurvedAnimation(parent: animation, curve: Curves.linear)),
        child: child);

Widget _sizeRoute(final BuildContext context, final Animation<double> animation,
        final Animation<double> secondaryAnimation, final Widget? child) =>
    Align(
      child: SizeTransition(sizeFactor: animation, child: child),
    );

Widget _fadeRoute(final BuildContext context, final Animation<double> animation,
        final Animation<double> secondaryAnimation, final Widget? child) =>
    FadeTransition(opacity: animation, child: child);

Widget _scaleRotate(
        final BuildContext context,
        final Animation<double> animation,
        final Animation<double> secondaryAnimation,
        final Widget? child) =>
    ScaleTransition(
        scale: Tween<double>(begin: 0, end: 1).animate(
            CurvedAnimation(parent: animation, curve: Curves.fastOutSlowIn)),
        child: RotationTransition(
            turns: Tween<double>(begin: 0, end: 1).animate(
                CurvedAnimation(parent: animation, curve: Curves.linear)),
            child: child));

class _AnimatedPageRoute extends PageRouteBuilder {
  _AnimatedPageRoute(
      {this.exitPage,
      this.enterPage,
      this.transitionAnimation,
      this.routeSettings})
      : super(
          settings: routeSettings,
          pageBuilder:
              (final context, final animation, final secondaryAnimation) =>
                  enterPage!,
          transitionsBuilder: (final context, final animation,
                  final secondaryAnimation, final child) =>
              Stack(
            children: <Widget>[
              _getAnimation(context, animation, secondaryAnimation, exitPage,
                  transitionAnimation!),
              _getAnimation(context, animation, secondaryAnimation, enterPage,
                  transitionAnimation)
            ],
          ),
        );
  final Widget? enterPage;
  final Widget? exitPage;
  final PageTransitionAnimation? transitionAnimation;
  final RouteSettings? routeSettings;
}

class _SinglePageRoute extends PageRouteBuilder<dynamic> {
  _SinglePageRoute({this.page, this.transitionAnimation, this.routeSettings})
      : super(
            settings: routeSettings,
            pageBuilder:
                (final context, final animation, final secondaryAnimation) =>
                    page!,
            transitionsBuilder: (final context, final animation,
                    final secondaryAnimation, final child) =>
                _getAnimation(context, animation, secondaryAnimation, child,
                    transitionAnimation!));
  final Widget? page;
  final PageTransitionAnimation? transitionAnimation;
  final RouteSettings? routeSettings;
}

Widget _getAnimation(
  final BuildContext context,
  final Animation<double> animation,
  final Animation<double> secondaryAnimation,
  final Widget? child,
  final PageTransitionAnimation transitionAnimation,
) {
  switch (transitionAnimation) {
    case PageTransitionAnimation.cupertino:
      break;
    case PageTransitionAnimation.slideRight:
      return _slideRightRoute(context, animation, secondaryAnimation, child);
    case PageTransitionAnimation.scale:
      return _scaleRoute(context, animation, secondaryAnimation, child);
    case PageTransitionAnimation.rotate:
      return _rotationRoute(context, animation, secondaryAnimation, child);
    case PageTransitionAnimation.sizeUp:
      return _sizeRoute(context, animation, secondaryAnimation, child);
    case PageTransitionAnimation.fade:
      return _fadeRoute(context, animation, secondaryAnimation, child);
    case PageTransitionAnimation.scaleRotate:
      return _scaleRotate(context, animation, secondaryAnimation, child);
    case PageTransitionAnimation.slideUp:
      return _slideUp(context, animation, secondaryAnimation, child);
  }
  return Container();
}

Route<dynamic> getPageRoute(final PageTransitionAnimation transitionAnimation,
    {final RouteSettings? settings,
    final Widget? enterPage,
    final Widget? exitPage}) {
  switch (transitionAnimation) {
    case PageTransitionAnimation.cupertino:
      return settings == null
          ? CupertinoPageRoute(builder: (final context) => enterPage!)
          : CupertinoPageRoute(
              settings: settings, builder: (final context) => enterPage!);
    default:
      return exitPage == null
          ? _SinglePageRoute(
              page: enterPage,
              transitionAnimation: transitionAnimation,
              routeSettings: settings)
          : _AnimatedPageRoute(
              enterPage: enterPage,
              exitPage: exitPage,
              transitionAnimation: transitionAnimation,
              routeSettings: settings);
  }
}

///An item widget for the `PersistentTabView`.
class PersistentBottomNavBarItem {
  PersistentBottomNavBarItem(
      {required this.icon,
      this.inactiveIcon,
      this.title,
      this.contentPadding = 5.0,
      this.activeColorPrimary = CupertinoColors.activeBlue,
      this.activeColorSecondary,
      this.inactiveColorPrimary,
      this.inactiveColorSecondary = CupertinoColors.systemGrey,
      this.opacity = 1.0,
      this.filter,
      this.textStyle,
      this.iconSize = 26.0,
      this.onSelectedTabPressWhenNoScreensPushed,
      this.routeAndNavigatorSettings = const RouteAndNavigatorSettings(),
      this.onPressed})
      : assert(opacity >= 0 && opacity <= 1.0,
            "Opacity cannot be greater than 1 and less than 0");

  ///Icon for the bar item.
  final Widget icon;

  ///In-Active icon for the bar item.
  final Widget? inactiveIcon;

  ///Title for the bar item. Might not appear is some `styles`.
  final String? title;

  ///Color for the current selected item in the navigation bar. If `activeColorSecondary` property is empty, this will act in its place (recommended). `cupertino activeBlue` by default.
  final Color activeColorPrimary;

  ///Color for the unselected item(s) in the navigation bar.
  final Color? inactiveColorPrimary;

  ///Color for the item's `icon` and `title`. In most styles, declaring the the `activeColorPrimary` will be enough. But in some styles like `style7`, this might come help in differentiating the colors.
  final Color? activeColorSecondary;

  ///Color for the item's `inactiveIcon` and `title`. In most styles, declaring the the `inactiveColorPrimary` will be enough. But in some styles like `style7`, this might come help in differentiating the colors.
  final Color inactiveColorSecondary;

  ///Padding of the navigation bar item. Applies on all sides. `5.0` by default.
  ///
  ///`USE WITH CAUTION, MAY BREAK THE NAV BAR`.
  final double contentPadding;

  ///Enables and controls the transparency effect of the entire NavBar when this tab is selected.
  ///
  ///`Warning: Screen will cover the entire extent of the display`
  final double opacity;

  ///If you want custom behavior on a press of a NavBar item like display a modal screen, you can declare your logic here.
  ///
  ///NOTE: This will override the default tab switiching behavior for this particular item.
  final Function(BuildContext?)? onPressed;

  ///Use it when you want to run some code when user presses the NavBar when on the initial screen of that respective tab. The inspiration was taken from the native iOS navigation bar behavior where when performing similar operation, you taken to the top of the list.
  ///
  ///NOTE: This feature is experimental at the moment and might not work as intended for some.
  final VoidCallback? onSelectedTabPressWhenNoScreensPushed;

  ///Filter used when `opacity < 1.0`. Can be used to create 'frosted glass' effect.
  ///
  ///By default -> `ImageFilter.blur(sigmaX: 3.0, sigmaY: 3.0)`.
  final ImageFilter? filter;

  ///`TextStyle` of the title's text.
  final TextStyle? textStyle;

  final double iconSize;

  final RouteAndNavigatorSettings routeAndNavigatorSettings;
}

enum NavBarStyle {
  style1,
  style2,
  style3,
  style4,
  style5,
  style6,
  style7,
  style8,
  style9,
  style10,
  style11,
  style12,
  style13,
  style14,
  style15,
  style16,
  style17,
  style18,
  style19,
  neumorphic,
  simple,
}

enum PopActionScreensType { once, all }

class NavBarDecoration {
  const NavBarDecoration({
    this.border,
    this.gradient,
    this.borderRadius,
    this.colorBehindNavBar = CupertinoColors.black,
    this.boxShadow,
    this.adjustScreenBottomPaddingOnCurve = true,
  });

  ///Defines the curve radius of the corners of the NavBar.
  final BorderRadius? borderRadius;

  /// Color for the container which holds the bottom NavBar.
  ///
  /// When you increase the `navBarCurveRadius`, the `bottomScreenPadding` will automatically adjust to avoid layout issues. But if you want a fixed `bottomScreenPadding`, then you might want to set the color of your choice to avoid black edges at the corners of the NavBar.
  final Color colorBehindNavBar;

  final Gradient? gradient;

  final BoxBorder? border;

  final List<BoxShadow>? boxShadow;

  ///If enabled, the screen's bottom padding will be adjusted accordingly to the amount of curve applied.
  final bool adjustScreenBottomPaddingOnCurve;
}

class PersistentBottomNavBar extends StatelessWidget {
  const PersistentBottomNavBar({
    final Key? key,
    this.margin,
    this.confineToSafeArea,
    this.customNavBarWidget,
    this.hideNavigationBar,
    this.onAnimationComplete,
    this.neumorphicProperties = const NeumorphicProperties(),
    this.navBarEssentials,
    this.navBarDecoration,
    this.navBarStyle,
    this.isCustomWidget = false,
  }) : super(key: key);

  final NavBarEssentials? navBarEssentials;
  final EdgeInsets? margin;
  final NavBarDecoration? navBarDecoration;
  final NavBarStyle? navBarStyle;
  final NeumorphicProperties? neumorphicProperties;
  final Widget? customNavBarWidget;
  final bool? confineToSafeArea;
  final bool? hideNavigationBar;
  final Function(bool, bool)? onAnimationComplete;
  final bool? isCustomWidget;

  Padding _navBarWidget() => Padding(
        padding: margin!,
        child: isCustomWidget!
            ? margin!.bottom > 0
                ? SafeArea(
                    top: false,
                    bottom: navBarEssentials!.navBarHeight == 0.0 ||
                            (hideNavigationBar ?? false)
                        ? false
                        : confineToSafeArea ?? true,
                    child: Container(
                      color: navBarEssentials!.backgroundColor,
                      height: navBarEssentials!.navBarHeight,
                      child: customNavBarWidget,
                    ),
                  )
                : Container(
                    color: navBarEssentials!.backgroundColor,
                    child: SafeArea(
                        top: false,
                        bottom: navBarEssentials!.navBarHeight == 0.0 ||
                                (hideNavigationBar ?? false)
                            ? false
                            : confineToSafeArea ?? true,
                        child: SizedBox(
                            height: navBarEssentials!.navBarHeight,
                            child: customNavBarWidget)),
                  )
            : navBarStyle == NavBarStyle.style19
                ? margin!.bottom > 0
                    ? SafeArea(
                        top: false,
                        right: false,
                        left: false,
                        bottom: navBarEssentials!.navBarHeight == 0.0 ||
                                (hideNavigationBar ?? false)
                            ? false
                            : confineToSafeArea ?? true,
                        child: getNavBarStyle(),
                      )
                    : DecoratedBox(
                        decoration: PersistentBottomNavigationBarUtilFunctions
                            .getNavBarDecoration(
                          decoration: navBarDecoration,
                          color: navBarEssentials!.backgroundColor,
                          opacity: navBarEssentials!
                              .items![navBarEssentials!.selectedIndex!].opacity,
                        ),
                        child: SafeArea(
                          top: false,
                          right: false,
                          left: false,
                          bottom: navBarEssentials!.navBarHeight == 0.0 ||
                                  (hideNavigationBar ?? false)
                              ? false
                              : confineToSafeArea ?? true,
                          child: getNavBarStyle(),
                        ),
                      )
                : navBarStyle == NavBarStyle.style15 ||
                        navBarStyle == NavBarStyle.style16
                    ? margin!.bottom > 0
                        ? SafeArea(
                            top: false,
                            right: false,
                            left: false,
                            bottom: navBarEssentials!.navBarHeight == 0.0 ||
                                    (hideNavigationBar ?? false)
                                ? false
                                : confineToSafeArea ?? true,
                            child: DecoratedBox(
                              decoration:
                                  PersistentBottomNavigationBarUtilFunctions
                                      .getNavBarDecoration(
                                decoration: navBarDecoration,
                                color: navBarEssentials!.backgroundColor,
                                opacity: navBarEssentials!
                                    .items![navBarEssentials!.selectedIndex!]
                                    .opacity,
                              ),
                              child: getNavBarStyle(),
                            ),
                          )
                        : DecoratedBox(
                            decoration:
                                PersistentBottomNavigationBarUtilFunctions
                                    .getNavBarDecoration(
                              decoration: navBarDecoration,
                              color: navBarEssentials!.backgroundColor,
                              opacity: navBarEssentials!
                                  .items![navBarEssentials!.selectedIndex!]
                                  .opacity,
                            ),
                            child: SafeArea(
                              top: false,
                              right: false,
                              left: false,
                              bottom: navBarEssentials!.navBarHeight == 0.0 ||
                                      (hideNavigationBar ?? false)
                                  ? false
                                  : confineToSafeArea ?? true,
                              child: getNavBarStyle(),
                            ),
                          )
                    : DecoratedBox(
                        decoration: PersistentBottomNavigationBarUtilFunctions
                            .getNavBarDecoration(
                          decoration: navBarDecoration,
                          showBorder: false,
                          color: navBarEssentials!.backgroundColor,
                          opacity: navBarEssentials!
                              .items![navBarEssentials!.selectedIndex!].opacity,
                        ),
                        child: ClipRRect(
                          borderRadius: navBarDecoration!.borderRadius ??
                              BorderRadius.zero,
                          child: BackdropFilter(
                            filter: navBarEssentials!
                                    .items![navBarEssentials!.selectedIndex!]
                                    .filter ??
                                ImageFilter.blur(sigmaX: 3, sigmaY: 3),
                            child: DecoratedBox(
                              decoration:
                                  PersistentBottomNavigationBarUtilFunctions
                                      .getNavBarDecoration(
                                showOpacity: false,
                                decoration: navBarDecoration,
                                color: navBarEssentials!.backgroundColor,
                                opacity: navBarEssentials!
                                    .items![navBarEssentials!.selectedIndex!]
                                    .opacity,
                              ),
                              child: SafeArea(
                                top: false,
                                right: false,
                                left: false,
                                bottom: navBarEssentials!.navBarHeight == 0.0 ||
                                        (hideNavigationBar ?? false)
                                    ? false
                                    : confineToSafeArea ?? true,
                                child: getNavBarStyle(),
                              ),
                            ),
                          ),
                        ),
                      ),
      );

  @override
  Widget build(final BuildContext context) => hideNavigationBar == null
      ? _navBarWidget()
      : OffsetAnimation(
          hideNavigationBar: hideNavigationBar,
          navBarHeight: navBarEssentials!.navBarHeight,
          onAnimationComplete: (final isAnimating, final isComplete) {
            onAnimationComplete!(isAnimating, isComplete);
          },
          child: _navBarWidget(),
        );

  PersistentBottomNavBar copyWith(
          {final int? selectedIndex,
          final double? iconSize,
          final int? previousIndex,
          final Color? backgroundColor,
          final Duration? animationDuration,
          final List<PersistentBottomNavBarItem>? items,
          final ValueChanged<int>? onItemSelected,
          final double? navBarHeight,
          final EdgeInsets? margin,
          final NavBarStyle? navBarStyle,
          final double? horizontalPadding,
          final NeumorphicProperties? neumorphicProperties,
          final Widget? customNavBarWidget,
          final Function(int)? popAllScreensForTheSelectedTab,
          final bool? popScreensOnTapOfSelectedTab,
          final NavBarDecoration? navBarDecoration,
          final NavBarEssentials? navBarEssentials,
          final bool? confineToSafeArea,
          final ItemAnimationProperties? itemAnimationProperties,
          final Function? onAnimationComplete,
          final bool? hideNavigationBar,
          final bool? isCustomWidget,
          final EdgeInsets? padding}) =>
      PersistentBottomNavBar(
          confineToSafeArea: confineToSafeArea ?? this.confineToSafeArea,
          margin: margin ?? this.margin,
          neumorphicProperties:
              neumorphicProperties ?? this.neumorphicProperties,
          navBarStyle: navBarStyle ?? this.navBarStyle,
          hideNavigationBar: hideNavigationBar ?? this.hideNavigationBar,
          customNavBarWidget: customNavBarWidget ?? this.customNavBarWidget,
          onAnimationComplete:
              onAnimationComplete as dynamic Function(bool, bool)? ??
                  this.onAnimationComplete,
          navBarEssentials: navBarEssentials ?? this.navBarEssentials,
          isCustomWidget: isCustomWidget ?? this.isCustomWidget,
          navBarDecoration: navBarDecoration ?? this.navBarDecoration);

  bool opaque(final int? index) => navBarEssentials!.items == null
      ? true
      : !(navBarEssentials!.items![index!].opacity < 1.0);

  Widget getNavBarStyle() {
    if (isCustomWidget!) {
      return customNavBarWidget ?? const SizedBox.shrink();
    } else {
      switch (navBarStyle) {
        case NavBarStyle.style1:
          return BottomNavStyle1(
            navBarEssentials: navBarEssentials,
          );
        case NavBarStyle.style2:
          return BottomNavStyle2(
            navBarEssentials: navBarEssentials,
          );
        case NavBarStyle.style3:
          return BottomNavStyle3(
            navBarEssentials: navBarEssentials,
          );
        case NavBarStyle.style4:
          return BottomNavStyle4(
            navBarEssentials: navBarEssentials,
          );
        case NavBarStyle.style5:
          return BottomNavStyle5(
            navBarEssentials: navBarEssentials,
          );
        case NavBarStyle.style6:
          return BottomNavStyle6(
            navBarEssentials: navBarEssentials,
          );
        case NavBarStyle.style7:
          return BottomNavStyle7(
            navBarEssentials: navBarEssentials,
          );
        case NavBarStyle.style8:
          return BottomNavStyle8(
            navBarEssentials: navBarEssentials,
          );
        case NavBarStyle.style9:
          return BottomNavStyle9(
            navBarEssentials: navBarEssentials,
          );
        case NavBarStyle.style10:
          return BottomNavStyle10(
            navBarEssentials: navBarEssentials,
          );
        case NavBarStyle.style11:
          return BottomNavStyle11(
            navBarEssentials: navBarEssentials,
          );
        case NavBarStyle.style12:
          return BottomNavStyle12(
            navBarEssentials: navBarEssentials,
          );
        case NavBarStyle.style13:
          return BottomNavStyle13(
            navBarEssentials: navBarEssentials,
          );
        case NavBarStyle.style14:
          return BottomNavStyle14(
            navBarEssentials: navBarEssentials,
          );
        case NavBarStyle.style15:
          return BottomNavStyle15(
            navBarEssentials: navBarEssentials,
            navBarDecoration: navBarDecoration,
          );
        case NavBarStyle.style16:
          return BottomNavStyle16(
            navBarEssentials: navBarEssentials,
            navBarDecoration: navBarDecoration,
          );
        case NavBarStyle.style17:
          return BottomNavStyle17(
            navBarEssentials: navBarEssentials,
            navBarDecoration: navBarDecoration,
          );
        case NavBarStyle.style18:
          return BottomNavStyle18(
            navBarEssentials: navBarEssentials,
            navBarDecoration: navBarDecoration,
          );
        case NavBarStyle.style19:
          return BottomNavStyle19(
            navBarEssentials: navBarEssentials,
          );
        case NavBarStyle.neumorphic:
          return NeumorphicBottomNavBar(
            navBarEssentials: navBarEssentials,
            neumorphicProperties: neumorphicProperties,
          );
        default:
          return BottomNavSimple(
            navBarEssentials: navBarEssentials,
          );
      }
    }
  }
}

///Navigation bar controller for `PersistentTabView`.
class PersistentTabController extends ChangeNotifier {
  PersistentTabController({final int initialIndex = 0})
      : _index = initialIndex,
        assert(initialIndex >= 0, "Value cannot be less than zero");

  bool _isDisposed = false;
  int get index => _index;
  int _index;

  set index(final int value) {
    assert(value >= 0, "Value cannot be less than zero");
    if (_index == value) {
      return;
    }
    _index = value;
    notifyListeners();
  }

  void jumpToTab(final int value) {
    assert(value >= 0, "Value cannot be less than zero");
    if (_index == value) {
      return;
    }
    _index = value;
    notifyListeners();
  }

  @override
  void dispose() {
    _isDisposed = true;
    super.dispose();
  }
}

class PersistentTabScaffold extends StatefulWidget {
  PersistentTabScaffold({
    required this.tabBar,
    required this.tabBuilder,
    final Key? key,
    this.controller,
    this.backgroundColor,
    this.resizeToAvoidBottomInset = true,
    this.bottomScreenMargin,
    this.stateManagement,
    this.screenTransitionAnimation,
    this.hideNavigationBarWhenKeyboardShows,
    this.itemCount,
    this.animatePadding = false,
  })  : assert(
            controller == null || controller.index < itemCount!,
            "The PersistentTabController's current index ${controller.index} is "
            "out of bounds for the tab bar with ${tabBar.navBarEssentials!.items!.length} tabs"),
        super(key: key);

  final PersistentBottomNavBar tabBar;

  final PersistentTabController? controller;

  final IndexedWidgetBuilder tabBuilder;

  final Color? backgroundColor;

  final bool resizeToAvoidBottomInset;

  final int? itemCount;

  final double? bottomScreenMargin;

  final bool? stateManagement;

  final ScreenTransitionAnimation? screenTransitionAnimation;

  final bool? hideNavigationBarWhenKeyboardShows;

  final bool animatePadding;

  @override
  _PersistentTabScaffoldState createState() => _PersistentTabScaffoldState();
}

class _PersistentTabScaffoldState extends State<PersistentTabScaffold> {
  PersistentTabController? _controller;
  int? _selectedIndex;
  late bool _isTapAction;

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.controller!.index;
    _isTapAction = false;
    _updateTabController();
  }

  void _updateTabController({final bool shouldDisposeOldController = false}) {
    final PersistentTabController newController = widget.controller ??
        PersistentTabController(
            initialIndex: widget.tabBar.navBarEssentials!.selectedIndex!);

    if (newController == _controller) {
      return;
    }

    if (shouldDisposeOldController) {
      _controller?.dispose();
    } else if (_controller?._isDisposed == false) {
      _controller!.removeListener(_onCurrentIndexChange);
    }

    newController.addListener(_onCurrentIndexChange);
    _controller = newController;
  }

  void _onCurrentIndexChange() {
    assert(
        _controller!.index >= 0 && _controller!.index < widget.itemCount!,
        "The $runtimeType's current index ${_controller!.index} is "
        "out of bounds for the tab bar with ${widget.itemCount} tabs");
    setState(() {});
  }

  @override
  void didUpdateWidget(final PersistentTabScaffold oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.controller != oldWidget.controller) {
      _updateTabController(
          shouldDisposeOldController: oldWidget.controller == null);
    } else if (_controller!.index >= widget.itemCount!) {
      _controller!.index = widget.itemCount! - 1;
    }
  }

  @override
  Widget build(final BuildContext context) {
    final MediaQueryData existingMediaQuery = MediaQuery.of(context);
    MediaQueryData newMediaQuery = MediaQuery.of(context);
    if (_isTapAction) {
      _isTapAction = false;
    } else {
      _selectedIndex = widget.tabBar.navBarEssentials!.selectedIndex;
    }
    Widget content = _TabSwitchingView(
      currentTabIndex: _controller!.index,
      tabCount: widget.itemCount,
      tabBuilder: widget.tabBuilder,
      stateManagement: widget.stateManagement,
      screenTransitionAnimation: widget.screenTransitionAnimation,
      backgroundColor: widget.tabBar.navBarEssentials!.backgroundColor,
    );
    double contentPadding = 0;

    if (widget.resizeToAvoidBottomInset) {
      newMediaQuery = newMediaQuery.removeViewInsets(removeBottom: true);
    }

    if (!widget.tabBar.opaque(_selectedIndex)) {
      contentPadding = 0.0;
    } else if (widget
            .tabBar.navBarDecoration!.adjustScreenBottomPaddingOnCurve &&
        widget.tabBar.navBarDecoration!.borderRadius != BorderRadius.zero) {
      final double bottomPadding = widget.bottomScreenMargin ??
          widget.tabBar.navBarEssentials!.navBarHeight! -
              (widget.tabBar.navBarDecoration!.borderRadius != null
                  ? min(
                      widget.tabBar.navBarEssentials!.navBarHeight!,
                      max(
                              widget.tabBar.navBarDecoration!.borderRadius!
                                  .topRight.y,
                              widget.tabBar.navBarDecoration!.borderRadius!
                                  .topLeft.y) +
                          (widget.tabBar.navBarDecoration?.border != null
                              ? widget.tabBar.navBarDecoration!.border!
                                  .dimensions.vertical
                              : 0.0))
                  : 0.0);
      contentPadding = bottomPadding;
    } else {
      if (!widget.resizeToAvoidBottomInset ||
          widget.tabBar.navBarEssentials!.navBarHeight! >
              existingMediaQuery.viewInsets.bottom) {
        final double bottomPadding = widget.bottomScreenMargin ??
            widget.tabBar.navBarEssentials!.navBarHeight! +
                (widget.tabBar.navBarDecoration?.border != null
                    ? widget
                        .tabBar.navBarDecoration!.border!.dimensions.vertical
                    : 0.0);
        contentPadding = bottomPadding;
      }
    }

    if (widget.tabBar.hideNavigationBar != null) {
      content = MediaQuery(
        data: newMediaQuery,
        child: AnimatedContainer(
          duration: Duration(
              milliseconds:
                  widget.animatePadding || widget.tabBar.hideNavigationBar!
                      ? widget.tabBar.hideNavigationBar!
                          ? 200
                          : 400
                      : 0),
          curve:
              widget.tabBar.hideNavigationBar! ? Curves.linear : Curves.easeIn,
          color: widget.tabBar.navBarDecoration!.colorBehindNavBar,
          padding: EdgeInsets.only(bottom: contentPadding),
          child: content,
        ),
      );
    } else {
      content = MediaQuery(
        data: newMediaQuery,
        child: Container(
          color: widget.tabBar.navBarDecoration!.colorBehindNavBar,
          padding: EdgeInsets.only(bottom: contentPadding),
          child: content,
        ),
      );
    }

    return DecoratedBox(
      decoration:
          widget.tabBar.navBarDecoration!.borderRadius != BorderRadius.zero
              ? BoxDecoration(
                  color: CupertinoColors.black.withOpacity(0),
                  borderRadius: widget.tabBar.navBarDecoration!.borderRadius,
                )
              : BoxDecoration(color: CupertinoColors.black.withOpacity(1)),
      child: Stack(
        children: <Widget>[
          content,
          MediaQuery(
            data: existingMediaQuery.copyWith(textScaleFactor: 1),
            child: Align(
              alignment: Alignment.bottomCenter,
              child: widget.tabBar.copyWith(
                selectedIndex: _controller!.index,
                onItemSelected: (final newIndex) {
                  _controller!.index = newIndex;
                  if (widget.tabBar.navBarEssentials!.onItemSelected != null) {
                    setState(() {
                      _selectedIndex = newIndex;
                      _isTapAction = true;
                      widget.tabBar.navBarEssentials!.onItemSelected!(newIndex);
                    });
                  }
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    if (widget.controller == null) {
      _controller?.dispose();
    } else if (_controller?._isDisposed == false) {
      _controller!.removeListener(_onCurrentIndexChange);
    }

    super.dispose();
  }
}

class _TabSwitchingView extends StatefulWidget {
  const _TabSwitchingView({
    required this.currentTabIndex,
    required this.tabCount,
    required this.stateManagement,
    required this.tabBuilder,
    required this.screenTransitionAnimation,
    required this.backgroundColor,
  }) : assert(tabCount != null && tabCount > 0,
            "tabCount must not be null and less than 1");

  final int currentTabIndex;
  final int? tabCount;
  final IndexedWidgetBuilder tabBuilder;
  final bool? stateManagement;
  final ScreenTransitionAnimation? screenTransitionAnimation;
  final Color? backgroundColor;

  @override
  _TabSwitchingViewState createState() => _TabSwitchingViewState();
}

class _TabSwitchingViewState extends State<_TabSwitchingView>
    with TickerProviderStateMixin {
  final List<bool> shouldBuildTab = <bool>[];
  final List<FocusScopeNode> tabFocusNodes = <FocusScopeNode>[];
  final List<FocusScopeNode> discardedNodes = <FocusScopeNode>[];
  late List<AnimationController?> _animationControllers;
  late List<Animation<double>?> _animations;
  int? _tabCount;
  int? _lastIndex;
  bool _animationCompletionIndex = false;
  bool? _showAnimation;
  double? _animationValue;
  Curve? _animationCurve;
  Key? key;

  @override
  void initState() {
    super.initState();
    shouldBuildTab.addAll(List<bool>.filled(widget.tabCount!, false));
    _lastIndex = widget.currentTabIndex;
    _tabCount = widget.tabCount;
    _animationCompletionIndex = false;
    _showAnimation = widget.screenTransitionAnimation!.animateTabTransition;

    if (!widget.stateManagement!) {
      key = UniqueKey();
    }

    _initAnimationControllers();
  }

  void _initAnimationControllers() {
    if (widget.screenTransitionAnimation!.animateTabTransition) {
      _animationControllers =
          List<AnimationController?>.filled(widget.tabCount!, null);
      _animations = List<Animation<double>?>.filled(widget.tabCount!, null);
      _animationCurve = widget.screenTransitionAnimation!.curve;
      for (int i = 0; i < widget.tabCount!; ++i) {
        _animationControllers[i] = AnimationController(
            vsync: this, duration: widget.screenTransitionAnimation!.duration);
        _animations[i] = Tween(begin: 0.toDouble(), end: 0.toDouble())
            .chain(CurveTween(curve: widget.screenTransitionAnimation!.curve))
            .animate(_animationControllers[i]!);
      }

      for (int i = 0; i < widget.tabCount!; ++i) {
        _animationControllers[i]!.addListener(() {
          if (_animationControllers[i]!.isCompleted &&
              _animationCompletionIndex) {
            setState(() {
              if (!widget.stateManagement!) {
                key = UniqueKey();
              }
              _lastIndex = widget.currentTabIndex;
            });
            _animationCompletionIndex = false;
          }
        });
      }
    }
  }

  void _focusActiveTab() {
    if (widget.screenTransitionAnimation!.animateTabTransition) {
      _newPageAnimation();
    }
    if (tabFocusNodes.length != widget.tabCount) {
      if (tabFocusNodes.length > widget.tabCount!) {
        discardedNodes.addAll(tabFocusNodes.sublist(widget.tabCount!));
        tabFocusNodes.removeRange(widget.tabCount!, tabFocusNodes.length);
      } else {
        tabFocusNodes.addAll(
          List<FocusScopeNode>.generate(
            widget.tabCount! - tabFocusNodes.length,
            (final index) => FocusScopeNode(
                debugLabel:
                    "$CupertinoTabScaffold Tab ${index + tabFocusNodes.length}"),
          ),
        );
      }
    }
    FocusScope.of(context).setFirstFocus(tabFocusNodes[widget.currentTabIndex]);
    if (widget.screenTransitionAnimation!.animateTabTransition) {
      _lastPageAnimation();
    }
  }

  void _lastPageAnimation() {
    if (_lastIndex! > widget.currentTabIndex &&
        !_animationControllers[_lastIndex!]!.isAnimating) {
      _animationControllers[_lastIndex!]!.reset();
      _animations[_lastIndex!] =
          Tween(begin: 0.toDouble(), end: _animationValue)
              .chain(CurveTween(curve: widget.screenTransitionAnimation!.curve))
              .animate(_animationControllers[_lastIndex!]!);
      _animationControllers[_lastIndex!]!.forward();
    } else if (_lastIndex! < widget.currentTabIndex &&
        !_animationControllers[_lastIndex!]!.isAnimating) {
      _animationControllers[_lastIndex!]!.reset();
      _animations[_lastIndex!] =
          Tween(begin: 0.toDouble(), end: -_animationValue!)
              .chain(CurveTween(curve: widget.screenTransitionAnimation!.curve))
              .animate(_animationControllers[_lastIndex!]!);
      _animationControllers[_lastIndex!]!.forward();
    }
  }

  void _newPageAnimation() {
    if (_lastIndex! > widget.currentTabIndex &&
        !_animationControllers[widget.currentTabIndex]!.isAnimating) {
      _animationControllers[widget.currentTabIndex]!.reset();
      _animations[widget.currentTabIndex] =
          Tween(begin: -_animationValue!, end: 0.toDouble())
              .chain(CurveTween(curve: widget.screenTransitionAnimation!.curve))
              .animate(_animationControllers[widget.currentTabIndex]!);
      _animationControllers[widget.currentTabIndex]!.forward();
      _animationCompletionIndex = true;
    } else if (_lastIndex! < widget.currentTabIndex &&
        !_animationControllers[widget.currentTabIndex]!.isAnimating) {
      _animationControllers[widget.currentTabIndex]!.reset();
      _animations[widget.currentTabIndex] =
          Tween(begin: _animationValue, end: 0.toDouble())
              .chain(CurveTween(curve: widget.screenTransitionAnimation!.curve))
              .animate(_animationControllers[widget.currentTabIndex]!);
      _animationControllers[widget.currentTabIndex]!.forward();
      _animationCompletionIndex = true;
    }
  }

  DecoratedBox _buildScreens() => DecoratedBox(
        decoration: const BoxDecoration(color: CupertinoColors.black),
        child: Stack(
          fit: StackFit.expand,
          children: List<Widget>.generate(widget.tabCount!, (final index) {
            final bool active = index == widget.currentTabIndex ||
                (widget.screenTransitionAnimation!.animateTabTransition &&
                    index == _lastIndex);
            shouldBuildTab[index] = active || shouldBuildTab[index];

            return Offstage(
              offstage: !active,
              child: TickerMode(
                enabled: active,
                child: FocusScope(
                  node: tabFocusNodes[index],
                  child: Builder(
                      builder: (final context) => shouldBuildTab[index]
                          ? (widget.screenTransitionAnimation!
                                  .animateTabTransition
                              ? AnimatedBuilder(
                                  animation: _animations[index]!,
                                  builder: (final context, final child) =>
                                      Transform.translate(
                                    offset:
                                        Offset(_animations[index]!.value, 0),
                                    child: widget.tabBuilder(context, index),
                                  ),
                                )
                              : widget.tabBuilder(context, index))
                          : Container()),
                ),
              ),
            );
          }),
        ),
      );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _focusActiveTab();
  }

  @override
  void didUpdateWidget(final _TabSwitchingView oldWidget) {
    super.didUpdateWidget(oldWidget);
    final int lengthDiff = widget.tabCount! - shouldBuildTab.length;
    if (lengthDiff > 0) {
      shouldBuildTab.addAll(List<bool>.filled(lengthDiff, false));
    } else if (lengthDiff < 0) {
      shouldBuildTab.removeRange(widget.tabCount!, shouldBuildTab.length);
    }
    _focusActiveTab();
  }

  @override
  void dispose() {
    for (final FocusScopeNode focusScopeNode in tabFocusNodes) {
      focusScopeNode.dispose();
    }
    for (final FocusScopeNode focusScopeNode in discardedNodes) {
      focusScopeNode.dispose();
    }
    if (widget.screenTransitionAnimation!.animateTabTransition) {
      for (final AnimationController? controller in _animationControllers) {
        controller!.dispose();
      }
    }
    super.dispose();
  }

  @override
  Widget build(final BuildContext context) {
    _animationValue = MediaQuery.of(context).size.width;
    if (_tabCount != widget.tabCount) {
      _tabCount = widget.tabCount;
      _initAnimationControllers();
    }
    if (widget.screenTransitionAnimation!.animateTabTransition &&
            _animationControllers.first!.duration !=
                widget.screenTransitionAnimation!.duration ||
        _animationCurve != widget.screenTransitionAnimation!.curve) {
      _initAnimationControllers();
    }
    if (_showAnimation !=
        widget.screenTransitionAnimation!.animateTabTransition) {
      _showAnimation = widget.screenTransitionAnimation!.animateTabTransition;
      key = UniqueKey();
    }
    return Container(
      color: widget.backgroundColor,
      child: widget.stateManagement!
          ? _buildScreens()
          : KeyedSubtree(
              key: key,
              child: _buildScreens(),
            ),
    );
  }
}

class RouteAndNavigatorSettings {
  const RouteAndNavigatorSettings({
    this.defaultTitle,
    this.routes,
    this.onGenerateRoute,
    this.onUnknownRoute,
    this.initialRoute,
    this.navigatorObservers = const <NavigatorObserver>[],
    this.navigatorKey,
  });
  final String? defaultTitle;

  final Map<String, WidgetBuilder>? routes;

  final RouteFactory? onGenerateRoute;

  final RouteFactory? onUnknownRoute;

  final String? initialRoute;

  final List<NavigatorObserver> navigatorObservers;

  final GlobalKey<NavigatorState>? navigatorKey;

  RouteAndNavigatorSettings copyWith({
    final String? defaultTitle,
    final Map<String, WidgetBuilder>? routes,
    final RouteFactory? onGenerateRoute,
    final RouteFactory? onUnknownRoute,
    final String? initialRoute,
    final List<NavigatorObserver>? navigatorObservers,
    final GlobalKey<NavigatorState>? navigatorKeys,
  }) =>
      RouteAndNavigatorSettings(
        defaultTitle: defaultTitle ?? this.defaultTitle,
        routes: routes ?? this.routes,
        onGenerateRoute: onGenerateRoute ?? this.onGenerateRoute,
        onUnknownRoute: onUnknownRoute ?? this.onUnknownRoute,
        initialRoute: initialRoute ?? this.initialRoute,
        navigatorObservers: navigatorObservers ?? this.navigatorObservers,
        navigatorKey: navigatorKey ?? navigatorKey,
      );
}

class CustomWidgetRouteAndNavigatorSettings {
  const CustomWidgetRouteAndNavigatorSettings({
    this.defaultTitle,
    this.routes,
    this.onGenerateRoute,
    this.onUnknownRoute,
    this.initialRoute,
    this.navigatorObservers = const <NavigatorObserver>[],
    this.navigatorKeys,
  });
  final String? defaultTitle;

  final Map<String, WidgetBuilder>? routes;

  final RouteFactory? onGenerateRoute;

  final RouteFactory? onUnknownRoute;

  final String? initialRoute;

  final List<NavigatorObserver> navigatorObservers;

  final List<GlobalKey<NavigatorState>>? navigatorKeys;

  CustomWidgetRouteAndNavigatorSettings copyWith({
    final String? defaultTitle,
    final Map<String, WidgetBuilder>? routes,
    final RouteFactory? onGenerateRoute,
    final RouteFactory? onUnknownRoute,
    final String? initialRoute,
    final List<NavigatorObserver>? navigatorObservers,
    final List<GlobalKey<NavigatorState>>? navigatorKeys,
  }) =>
      CustomWidgetRouteAndNavigatorSettings(
        defaultTitle: defaultTitle ?? this.defaultTitle,
        routes: routes ?? this.routes,
        onGenerateRoute: onGenerateRoute ?? this.onGenerateRoute,
        onUnknownRoute: onUnknownRoute ?? this.onUnknownRoute,
        initialRoute: initialRoute ?? this.initialRoute,
        navigatorObservers: navigatorObservers ?? this.navigatorObservers,
        navigatorKeys: navigatorKeys ?? this.navigatorKeys,
      );
}

class CustomTabView extends StatefulWidget {
  const CustomTabView({
    final Key? key,
    this.builder,
    this.routeAndNavigatorSettings,
  }) : super(key: key);
  final WidgetBuilder? builder;
  final RouteAndNavigatorSettings? routeAndNavigatorSettings;

  @override
  _CustomTabViewState createState() => _CustomTabViewState();
}

class _CustomTabViewState extends State<CustomTabView> {
  final HeroController _heroController =
      CupertinoApp.createCupertinoHeroController();
  late List<NavigatorObserver?> _navigatorObservers;

  @override
  void initState() {
    super.initState();
    _updateObservers();
  }

  @override
  void didUpdateWidget(final CustomTabView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.routeAndNavigatorSettings!.navigatorKey !=
            oldWidget.routeAndNavigatorSettings!.navigatorKey ||
        widget.routeAndNavigatorSettings!.navigatorObservers !=
            oldWidget.routeAndNavigatorSettings!.navigatorObservers) {
      _updateObservers();
    }
  }

  void _updateObservers() {
    _navigatorObservers = List<NavigatorObserver>.from(
        widget.routeAndNavigatorSettings!.navigatorObservers)
      ..add(_heroController);
  }

  @override
  Widget build(final BuildContext context) => Navigator(
        key: widget.routeAndNavigatorSettings!.navigatorKey,
        onGenerateRoute: _onGenerateRoute,
        onUnknownRoute: _onUnknownRoute,
        observers: _navigatorObservers as List<NavigatorObserver>,
      );

  Route<dynamic>? _onGenerateRoute(final RouteSettings settings) {
    final String? name = settings.name;
    WidgetBuilder? routeBuilder;
    //String title;
    if (name == Navigator.defaultRouteName && widget.builder != null) {
      routeBuilder = widget.builder;
      //title = widget.defaultTitle;
    } else if (widget.routeAndNavigatorSettings!.routes != null) {
      routeBuilder = widget.routeAndNavigatorSettings!.routes![name!];
    }
    if (routeBuilder != null) {
      return PageRouteBuilder(
        pageBuilder:
            (final context, final animation, final secondaryAnimation) =>
                routeBuilder!(context),
        transitionsBuilder: (final context, final animation,
                final secondaryAnimation, final child) =>
            child,
        settings: RouteSettings(
            name: widget.routeAndNavigatorSettings!.initialRoute ??
                "/9f580fc5-c252-45d0-af25-9429992db112"),
      );
    }
    if (widget.routeAndNavigatorSettings!.onGenerateRoute != null) {
      return widget.routeAndNavigatorSettings!.onGenerateRoute!(settings);
    }
    return null;
  }

  Route<dynamic>? _onUnknownRoute(final RouteSettings settings) {
    assert(() {
      if (widget.routeAndNavigatorSettings!.onUnknownRoute == null) {
        throw FlutterError(
            "Could not find a generator for route $settings in the $runtimeType.\n"
            "Generators for routes are searched for in the following order:\n"
            ' 1. For the "/" route, the "builder" property, if non-null, is used.\n'
            ' 2. Otherwise, the "routes" table is used, if it has an entry for '
            "the route.\n"
            " 3. Otherwise, onGenerateRoute is called. It should return a "
            'non-null value for any valid route not handled by "builder" and "routes".\n'
            " 4. Finally if all else fails onUnknownRoute is called.\n"
            "Unfortunately, onUnknownRoute was not set.");
      }
      return true;
    }(), "");
    final Route<dynamic>? result =
        widget.routeAndNavigatorSettings!.onUnknownRoute!(settings);
    assert(() {
      if (result == null) {
        throw FlutterError("The onUnknownRoute callback returned null.\n"
            "When the $runtimeType requested the route $settings from its "
            "onUnknownRoute callback, the callback returned null. Such callbacks "
            "must never return null.");
      }
      return true;
    }(), "");
    return result;
  }
}

class NeumorphicBottomNavBar extends StatelessWidget {
  const NeumorphicBottomNavBar({
    final Key? key,
    this.navBarEssentials,
    this.neumorphicProperties = const NeumorphicProperties(),
  }) : super(key: key);
  final NavBarEssentials? navBarEssentials;
  final NeumorphicProperties? neumorphicProperties;

  Widget _getNavItem(final PersistentBottomNavBarItem item,
          final bool isSelected, final double? height) =>
      neumorphicProperties != null && neumorphicProperties!.showSubtitleText
          ? Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Expanded(
                  child: IconTheme(
                    data: IconThemeData(
                        size: item.iconSize,
                        color: isSelected
                            ? (item.activeColorSecondary ??
                                item.activeColorPrimary)
                            : item.inactiveColorPrimary ??
                                item.activeColorPrimary),
                    child:
                        isSelected ? item.icon : item.inactiveIcon ?? item.icon,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 15),
                  child: Material(
                    type: MaterialType.transparency,
                    child: FittedBox(
                        child: Text(
                      item.title!,
                      style: item.textStyle != null
                          ? (item.textStyle!.apply(
                              color: isSelected
                                  ? (item.activeColorSecondary ??
                                      item.activeColorPrimary)
                                  : item.inactiveColorPrimary))
                          : TextStyle(
                              color: isSelected
                                  ? (item.activeColorSecondary ??
                                      item.activeColorPrimary)
                                  : item.inactiveColorPrimary ??
                                      item.activeColorPrimary,
                              fontWeight: FontWeight.w400,
                              fontSize: 12),
                    )),
                  ),
                )
              ],
            )
          : IconTheme(
              data: IconThemeData(
                  size: item.iconSize,
                  color: isSelected
                      ? (item.activeColorSecondary ?? item.activeColorPrimary)
                      : item.inactiveColorPrimary ?? item.activeColorPrimary),
              child: isSelected ? item.icon : item.inactiveIcon ?? item.icon,
            );

  Widget _buildItem(
          final BuildContext context,
          final PersistentBottomNavBarItem item,
          final bool isSelected,
          final double? height) =>
      navBarEssentials!.navBarHeight == 0
          ? const SizedBox.shrink()
          : PersistentBottomNavigationBarUtilFunctions.opaque(
                  navBarEssentials!.items!, navBarEssentials!.selectedIndex)
              ? NeumorphicContainer(
                  decoration: NeumorphicDecoration(
                    borderRadius: BorderRadius.circular(
                        neumorphicProperties == null
                            ? 15.0
                            : neumorphicProperties!.borderRadius),
                    color: navBarEssentials!.backgroundColor,
                    border: neumorphicProperties == null
                        ? null
                        : neumorphicProperties!.border,
                    shape: neumorphicProperties == null
                        ? BoxShape.rectangle
                        : neumorphicProperties!.shape,
                  ),
                  bevel: neumorphicProperties == null
                      ? 12.0
                      : neumorphicProperties!.bevel,
                  curveType: isSelected
                      ? CurveType.emboss
                      : neumorphicProperties == null
                          ? CurveType.concave
                          : neumorphicProperties!.curveType,
                  height: height! + 20,
                  width: 60,
                  padding: const EdgeInsets.all(6),
                  child: _getNavItem(item, isSelected, height),
                )
              : Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                    color: PersistentBottomNavigationBarUtilFunctions
                        .getBackgroundColor(
                            context,
                            navBarEssentials!.items,
                            navBarEssentials!.backgroundColor,
                            navBarEssentials!.selectedIndex),
                  ),
                  height: height! + 20,
                  width: 60,
                  padding: const EdgeInsets.all(6),
                  child: _getNavItem(item, isSelected, height),
                );

  @override
  Widget build(final BuildContext context) => Container(
        width: double.infinity,
        height: navBarEssentials!.navBarHeight,
        padding: EdgeInsets.only(
            left: navBarEssentials!.padding?.left ??
                MediaQuery.of(context).size.width * 0.04,
            right: navBarEssentials!.padding?.right ??
                MediaQuery.of(context).size.width * 0.04,
            top: navBarEssentials!.padding?.top ??
                navBarEssentials!.navBarHeight! * 0.15,
            bottom: navBarEssentials!.padding?.bottom ??
                navBarEssentials!.navBarHeight! * 0.12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: navBarEssentials!.items!.map((final item) {
            final int index = navBarEssentials!.items!.indexOf(item);
            return Flexible(
              child: GestureDetector(
                onTap: () {
                  if (navBarEssentials!.items![index].onPressed != null) {
                    navBarEssentials!.items![index].onPressed!(
                        navBarEssentials!.selectedScreenBuildContext);
                  } else {
                    navBarEssentials!.onItemSelected!(index);
                  }
                },
                child: _buildItem(
                    context,
                    item,
                    navBarEssentials!.selectedIndex == index,
                    navBarEssentials!.navBarHeight),
              ),
            );
          }).toList(),
        ),
      );
}

class BottomNavSimple extends StatelessWidget {
  const BottomNavSimple({
    final Key? key,
    this.navBarEssentials = const NavBarEssentials(items: null),
  }) : super(key: key);
  final NavBarEssentials? navBarEssentials;

  Widget _buildItem(final PersistentBottomNavBarItem item,
          final bool isSelected, final double? height) =>
      navBarEssentials!.navBarHeight == 0
          ? const SizedBox.shrink()
          : AnimatedContainer(
              width: 150,
              height: height,
              duration: const Duration(milliseconds: 1000),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 1000),
                alignment: Alignment.center,
                height: height,
                child: ListView(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  scrollDirection: Axis.horizontal,
                  children: <Widget>[
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Expanded(
                          child: IconTheme(
                            data: IconThemeData(
                                size: item.iconSize,
                                color: isSelected
                                    ? (item.activeColorSecondary ??
                                        item.activeColorPrimary)
                                    : item.inactiveColorPrimary ??
                                        item.activeColorPrimary),
                            child: isSelected
                                ? item.icon
                                : item.inactiveIcon ?? item.icon,
                          ),
                        ),
                        if (item.title == null)
                          const SizedBox.shrink()
                        else
                          Padding(
                            padding: const EdgeInsets.only(top: 15),
                            child: Material(
                              type: MaterialType.transparency,
                              child: FittedBox(
                                  child: Text(
                                item.title!,
                                style: item.textStyle != null
                                    ? (item.textStyle!.apply(
                                        color: isSelected
                                            ? (item.activeColorSecondary ??
                                                item.activeColorPrimary)
                                            : item.inactiveColorPrimary))
                                    : TextStyle(
                                        color: isSelected
                                            ? (item.activeColorSecondary ??
                                                item.activeColorPrimary)
                                            : item.inactiveColorPrimary,
                                        fontWeight: FontWeight.w400,
                                        fontSize: 12),
                              )),
                            ),
                          )
                      ],
                    )
                  ],
                ),
              ),
            );

  @override
  Widget build(final BuildContext context) => Container(
        width: double.infinity,
        height: navBarEssentials!.navBarHeight,
        padding: EdgeInsets.only(
            left: navBarEssentials!.padding?.left ??
                MediaQuery.of(context).size.width * 0.04,
            right: navBarEssentials!.padding?.right ??
                MediaQuery.of(context).size.width * 0.04,
            top: navBarEssentials!.padding?.top ??
                navBarEssentials!.navBarHeight! * 0.15,
            bottom: navBarEssentials!.padding?.bottom ??
                navBarEssentials!.navBarHeight! * 0.12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: navBarEssentials!.items!.map((final item) {
            final int index = navBarEssentials!.items!.indexOf(item);
            return Flexible(
              child: GestureDetector(
                onTap: () {
                  if (navBarEssentials!.items![index].onPressed != null) {
                    navBarEssentials!.items![index].onPressed!(
                        navBarEssentials!.selectedScreenBuildContext);
                  } else {
                    navBarEssentials!.onItemSelected!(index);
                  }
                },
                child: _buildItem(
                    item,
                    navBarEssentials!.selectedIndex == index,
                    navBarEssentials!.navBarHeight),
              ),
            );
          }).toList(),
        ),
      );
}

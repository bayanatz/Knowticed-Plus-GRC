import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:demo_app/core/helper/data_grc_module/feature/nav_bar_package.dart/model.dart';
import 'package:demo_app/core/helper/data_grc_module/feature/nav_bar_package.dart/paint.dart';

class BottomNavStyle1 extends StatelessWidget {
  const BottomNavStyle1({
    final Key? key,
    this.navBarEssentials = const NavBarEssentials(items: null),
  }) : super(key: key);
  final NavBarEssentials? navBarEssentials;

  Widget _buildItem(final PersistentBottomNavBarItem item,
          final bool isSelected, final double? height) =>
      navBarEssentials!.navBarHeight == 0
          ? const SizedBox.shrink()
          : AnimatedContainer(
              width: isSelected ? 120 : 50,
              height: height! / 1.6,
              duration: navBarEssentials!.itemAnimationProperties?.duration ??
                  const Duration(milliseconds: 400),
              curve: navBarEssentials!.itemAnimationProperties?.curve ??
                  Curves.ease,
              padding: EdgeInsets.all(item.contentPadding),
              decoration: BoxDecoration(
                color: isSelected
                    ? item.activeColorPrimary.withOpacity(0.2)
                    : navBarEssentials!.backgroundColor!.withOpacity(0),
                borderRadius: const BorderRadius.all(Radius.circular(50)),
              ),
              child: Container(
                alignment: Alignment.center,
                height: height / 1.6,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Flexible(
                      child: Padding(
                        padding: EdgeInsets.only(
                            right: item.title == null ? 0.0 : 8),
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
                    ),
                    if (item.title == null)
                      const SizedBox.shrink()
                    else
                      isSelected
                          ? Flexible(
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
                                          color: item.activeColorSecondary ??
                                              item.activeColorPrimary,
                                          fontWeight: FontWeight.w400,
                                          fontSize: 12),
                                )),
                              ),
                            )
                          : const SizedBox.shrink()
                  ],
                ),
              ),
            );

  @override
  Widget build(final BuildContext context) => Container(
      width: double.infinity,
      height: navBarEssentials!.navBarHeight,
      padding: navBarEssentials!.padding == null
          ? EdgeInsets.symmetric(
              horizontal: MediaQuery.of(context).size.width * 0.07,
              vertical: navBarEssentials!.navBarHeight! * 0.15,
            )
          : EdgeInsets.only(
              top: navBarEssentials!.padding?.top ??
                  navBarEssentials!.navBarHeight! * 0.15,
              left: navBarEssentials!.padding?.left ??
                  MediaQuery.of(context).size.width * 0.07,
              right: navBarEssentials!.padding?.right ??
                  MediaQuery.of(context).size.width * 0.07,
              bottom: navBarEssentials!.padding?.bottom ??
                  navBarEssentials!.navBarHeight! * 0.15),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: navBarEssentials!.items!.map((final item) {
          final int index = navBarEssentials!.items!.indexOf(item);
          return Flexible(
            flex: navBarEssentials!.selectedIndex == index ? 2 : 1,
            child: GestureDetector(
              onTap: () {
                if (navBarEssentials!.items![index].onPressed != null) {
                  navBarEssentials!.items![index]
                      .onPressed!(navBarEssentials!.selectedScreenBuildContext);
                } else {
                  navBarEssentials!.onItemSelected!(index);
                }
              },
              child: _buildItem(item, navBarEssentials!.selectedIndex == index,
                  navBarEssentials!.navBarHeight),
            ),
          );
        }).toList(),
      ));
}

class BottomNavStyle10 extends StatelessWidget {
  const BottomNavStyle10({
    final Key? key,
    this.navBarEssentials,
  }) : super(key: key);
  final NavBarEssentials? navBarEssentials;

  Widget _buildItem(final PersistentBottomNavBarItem item,
          final bool isSelected, final double? height) =>
      navBarEssentials!.navBarHeight == 0
          ? const SizedBox.shrink()
          : AnimatedContainer(
              width: isSelected ? 120 : 50,
              height: height! / 1.5,
              duration: navBarEssentials!.itemAnimationProperties?.duration ??
                  const Duration(milliseconds: 400),
              curve: navBarEssentials!.itemAnimationProperties?.curve ??
                  Curves.ease,
              padding: EdgeInsets.all(item.contentPadding),
              decoration: isSelected
                  ? BoxDecoration(
                      color: isSelected
                          ? item.activeColorPrimary
                          : navBarEssentials!.backgroundColor!.withOpacity(0),
                      borderRadius: const BorderRadius.all(Radius.circular(10)),
                    )
                  : BoxDecoration(
                      color: isSelected
                          ? item.activeColorPrimary
                          : navBarEssentials!.backgroundColor!.withOpacity(0),
                      borderRadius: const BorderRadius.all(Radius.circular(10)),
                    ),
              child: Container(
                alignment: Alignment.center,
                height: height / 1.5,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.only(right: 8),
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
                      isSelected
                          ? Flexible(
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
                                          color: item.activeColorSecondary ??
                                              item.activeColorPrimary,
                                          fontWeight: FontWeight.w400,
                                          fontSize: 12),
                                )),
                              ),
                            )
                          : const SizedBox.shrink()
                  ],
                ),
              ),
            );

  @override
  Widget build(final BuildContext context) => Container(
        width: double.infinity,
        height: navBarEssentials!.navBarHeight,
        padding: EdgeInsets.only(
            top: navBarEssentials!.padding?.top ??
                navBarEssentials!.navBarHeight! * 0.15,
            left: navBarEssentials!.padding?.left ??
                MediaQuery.of(context).size.width * 0.07,
            right: navBarEssentials!.padding?.right ??
                MediaQuery.of(context).size.width * 0.07,
            bottom: navBarEssentials!.padding?.bottom ??
                navBarEssentials!.navBarHeight! * 0.15),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: navBarEssentials!.items!.map((final item) {
            final int index = navBarEssentials!.items!.indexOf(item);
            return Flexible(
              flex: navBarEssentials!.selectedIndex == index ? 2 : 1,
              child: GestureDetector(
                onTap: () {
                  if (navBarEssentials!.items![index].onPressed != null) {
                    navBarEssentials!.items![index].onPressed!(
                        navBarEssentials!.selectedScreenBuildContext);
                  } else {
                    navBarEssentials!.onItemSelected!(index);
                  }
                },
                child: Container(
                  color: Colors.transparent,
                  child: _buildItem(
                      item,
                      navBarEssentials!.selectedIndex == index,
                      navBarEssentials!.navBarHeight),
                ),
              ),
            );
          }).toList(),
        ),
      );
}

class BottomNavStyle11 extends StatefulWidget {
  const BottomNavStyle11({
    final Key? key,
    this.navBarEssentials = const NavBarEssentials(items: null),
  }) : super(key: key);
  final NavBarEssentials? navBarEssentials;

  @override
  _BottomNavStyle11State createState() => _BottomNavStyle11State();
}

class _BottomNavStyle11State extends State<BottomNavStyle11>
    with TickerProviderStateMixin {
  late List<AnimationController> _animationControllerList;
  late List<Animation<Offset>> _animationList;

  int? _lastSelectedIndex;
  int? _selectedIndex;

  @override
  void initState() {
    super.initState();
    _lastSelectedIndex = 0;
    _selectedIndex = 0;
    _animationControllerList = List<AnimationController>.empty(growable: true);
    _animationList = List<Animation<Offset>>.empty(growable: true);

    for (int i = 0; i < widget.navBarEssentials!.items!.length; ++i) {
      _animationControllerList.add(AnimationController(
          duration:
              widget.navBarEssentials!.itemAnimationProperties?.duration ??
                  const Duration(milliseconds: 400),
          vsync: this));
      _animationList.add(Tween(
              begin: Offset(0, widget.navBarEssentials!.navBarHeight!),
              end: Offset.zero)
          .chain(CurveTween(
              curve: widget.navBarEssentials!.itemAnimationProperties?.curve ??
                  Curves.ease))
          .animate(_animationControllerList[i]));
    }

    WidgetsBinding.instance.addPostFrameCallback((final _) {
      _animationControllerList[_selectedIndex!].forward();
    });
  }

  Widget _buildItem(final PersistentBottomNavBarItem item,
          final bool isSelected, final double? height, final int itemIndex) =>
      widget.navBarEssentials!.navBarHeight == 0
          ? const SizedBox.shrink()
          : AnimatedBuilder(
              animation: _animationList[itemIndex],
              builder: (final context, final child) => SizedBox(
                width: 150,
                height: height,
                child: Container(
                  alignment: Alignment.center,
                  height: height,
                  child: Column(
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
                        Transform.translate(
                          offset: _animationList[itemIndex].value,
                          child: Padding(
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
                                ),
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            );

  @override
  void dispose() {
    for (int i = 0; i < widget.navBarEssentials!.items!.length; ++i) {
      _animationControllerList[i].dispose();
    }
    super.dispose();
  }

  @override
  Widget build(final BuildContext context) {
    if (widget.navBarEssentials!.items!.length !=
        _animationControllerList.length) {
      _animationControllerList =
          List<AnimationController>.empty(growable: true);
      _animationList = List<Animation<Offset>>.empty(growable: true);

      for (int i = 0; i < widget.navBarEssentials!.items!.length; ++i) {
        _animationControllerList.add(AnimationController(
            duration:
                widget.navBarEssentials!.itemAnimationProperties?.duration ??
                    const Duration(milliseconds: 400),
            vsync: this));
        _animationList.add(Tween(
                begin: Offset(0, widget.navBarEssentials!.navBarHeight!),
                end: Offset.zero)
            .chain(CurveTween(
                curve:
                    widget.navBarEssentials!.itemAnimationProperties?.curve ??
                        Curves.ease))
            .animate(_animationControllerList[i]));
      }
    }
    if (widget.navBarEssentials!.selectedIndex != _selectedIndex) {
      _lastSelectedIndex = _selectedIndex;
      _selectedIndex = widget.navBarEssentials!.selectedIndex;
      _animationControllerList[_selectedIndex!].forward();
      _animationControllerList[_lastSelectedIndex!].reverse();
    }
    return Container(
      width: double.infinity,
      height: widget.navBarEssentials!.navBarHeight,
      padding: EdgeInsets.only(
          left: widget.navBarEssentials!.padding?.left ??
              MediaQuery.of(context).size.width * 0.04,
          right: widget.navBarEssentials!.padding?.right ??
              MediaQuery.of(context).size.width * 0.04,
          top: widget.navBarEssentials!.padding?.top ??
              widget.navBarEssentials!.navBarHeight! * 0.15,
          bottom: widget.navBarEssentials!.padding?.bottom ??
              widget.navBarEssentials!.navBarHeight! * 0.12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: widget.navBarEssentials!.items!.map((final item) {
          final int index = widget.navBarEssentials!.items!.indexOf(item);
          return Expanded(
            child: GestureDetector(
              onTap: () {
                if (widget.navBarEssentials!.items![index].onPressed != null) {
                  widget.navBarEssentials!.items![index].onPressed!(
                      widget.navBarEssentials!.selectedScreenBuildContext);
                } else {
                  if (index != _selectedIndex) {
                    _lastSelectedIndex = _selectedIndex;
                    _selectedIndex = index;
                    _animationControllerList[_selectedIndex!].forward();
                    _animationControllerList[_lastSelectedIndex!].reverse();
                  }
                  widget.navBarEssentials!.onItemSelected!(index);
                }
              },
              child: Container(
                color: Colors.transparent,
                child: _buildItem(
                    item,
                    widget.navBarEssentials!.selectedIndex == index,
                    widget.navBarEssentials!.navBarHeight,
                    index),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class BottomNavStyle12 extends StatefulWidget {
  const BottomNavStyle12({
    final Key? key,
    this.navBarEssentials = const NavBarEssentials(items: null),
  }) : super(key: key);
  final NavBarEssentials? navBarEssentials;

  @override
  _BottomNavStyle12State createState() => _BottomNavStyle12State();
}

class _BottomNavStyle12State extends State<BottomNavStyle12>
    with TickerProviderStateMixin {
  late List<AnimationController> _animationControllerList;
  late List<Animation<Offset>> _animationList;

  int? _lastSelectedIndex;
  int? _selectedIndex;

  @override
  void initState() {
    super.initState();
    _lastSelectedIndex = 0;
    _selectedIndex = 0;
    _animationControllerList = List<AnimationController>.empty(growable: true);
    _animationList = List<Animation<Offset>>.empty(growable: true);

    for (int i = 0; i < widget.navBarEssentials!.items!.length; ++i) {
      _animationControllerList.add(AnimationController(
          duration:
              widget.navBarEssentials!.itemAnimationProperties?.duration ??
                  const Duration(milliseconds: 400),
          vsync: this));
      _animationList.add(Tween(
              begin: Offset(0, widget.navBarEssentials!.navBarHeight!),
              end: Offset.zero)
          .chain(CurveTween(
              curve: widget.navBarEssentials!.itemAnimationProperties?.curve ??
                  Curves.ease))
          .animate(_animationControllerList[i]));
    }

    WidgetsBinding.instance.addPostFrameCallback((final _) {
      _animationControllerList[_selectedIndex!].forward();
    });
  }

  Widget _buildItem(final PersistentBottomNavBarItem item,
          final bool isSelected, final double? height, final int itemIndex) =>
      widget.navBarEssentials!.navBarHeight == 0
          ? const SizedBox.shrink()
          : AnimatedBuilder(
              animation: _animationList[itemIndex],
              builder: (final context, final child) => SizedBox(
                width: 150,
                height: height,
                child: Container(
                  alignment: Alignment.center,
                  height: height,
                  child: Column(
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
                        Transform.translate(
                          offset: _animationList[itemIndex].value,
                          child: AnimatedContainer(
                            duration: widget.navBarEssentials!
                                    .itemAnimationProperties?.duration ??
                                const Duration(milliseconds: 400),
                            height: 5,
                            width: 5,
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(100),
                                color: isSelected
                                    ? (item.activeColorSecondary ??
                                        item.activeColorPrimary)
                                    : Colors.transparent),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            );

  @override
  void dispose() {
    for (int i = 0; i < widget.navBarEssentials!.items!.length; ++i) {
      _animationControllerList[i].dispose();
    }
    super.dispose();
  }

  @override
  Widget build(final BuildContext context) {
    if (widget.navBarEssentials!.items!.length !=
        _animationControllerList.length) {
      _animationControllerList =
          List<AnimationController>.empty(growable: true);
      _animationList = List<Animation<Offset>>.empty(growable: true);

      for (int i = 0; i < widget.navBarEssentials!.items!.length; ++i) {
        _animationControllerList.add(AnimationController(
            duration:
                widget.navBarEssentials!.itemAnimationProperties?.duration ??
                    const Duration(milliseconds: 400),
            vsync: this));
        _animationList.add(Tween(
                begin: Offset(0, widget.navBarEssentials!.navBarHeight!),
                end: Offset.zero)
            .chain(CurveTween(
                curve:
                    widget.navBarEssentials!.itemAnimationProperties?.curve ??
                        Curves.ease))
            .animate(_animationControllerList[i]));
      }
    }
    if (widget.navBarEssentials!.selectedIndex != _selectedIndex) {
      _lastSelectedIndex = _selectedIndex;
      _selectedIndex = widget.navBarEssentials!.selectedIndex;
      _animationControllerList[_selectedIndex!].forward();
      _animationControllerList[_lastSelectedIndex!].reverse();
    }
    return Container(
      width: double.infinity,
      height: widget.navBarEssentials!.navBarHeight,
      padding: EdgeInsets.only(
          left: widget.navBarEssentials!.padding?.left ??
              MediaQuery.of(context).size.width * 0.04,
          right: widget.navBarEssentials!.padding?.right ??
              MediaQuery.of(context).size.width * 0.04,
          top: widget.navBarEssentials!.padding?.top ??
              widget.navBarEssentials!.navBarHeight! * 0.15,
          bottom: widget.navBarEssentials!.padding?.bottom ??
              widget.navBarEssentials!.navBarHeight! * 0.12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: widget.navBarEssentials!.items!.map((final item) {
          final int index = widget.navBarEssentials!.items!.indexOf(item);
          return Expanded(
            child: GestureDetector(
              onTap: () {
                if (widget.navBarEssentials!.items![index].onPressed != null) {
                  widget.navBarEssentials!.items![index].onPressed!(
                      widget.navBarEssentials!.selectedScreenBuildContext);
                } else {
                  if (index != _selectedIndex) {
                    _lastSelectedIndex = _selectedIndex;
                    _selectedIndex = index;
                    _animationControllerList[_selectedIndex!].forward();
                    _animationControllerList[_lastSelectedIndex!].reverse();
                  }
                  widget.navBarEssentials!.onItemSelected!(index);
                }
              },
              child: Container(
                color: Colors.transparent,
                child: _buildItem(
                    item,
                    widget.navBarEssentials!.selectedIndex == index,
                    widget.navBarEssentials!.navBarHeight,
                    index),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class BottomNavStyle13 extends StatefulWidget {
  const BottomNavStyle13({
    final Key? key,
    this.navBarEssentials = const NavBarEssentials(items: null),
  }) : super(key: key);
  final NavBarEssentials? navBarEssentials;

  @override
  _BottomNavStyle13State createState() => _BottomNavStyle13State();
}

class _BottomNavStyle13State extends State<BottomNavStyle13>
    with TickerProviderStateMixin {
  late List<AnimationController> _animationControllerList;
  late List<Animation<Offset>> _animationList;

  int? _lastSelectedIndex;
  int? _selectedIndex;

  @override
  void initState() {
    super.initState();
    _lastSelectedIndex = 0;
    _selectedIndex = 0;
    _animationControllerList = List<AnimationController>.empty(growable: true);
    _animationList = List<Animation<Offset>>.empty(growable: true);

    for (int i = 0; i < widget.navBarEssentials!.items!.length; ++i) {
      _animationControllerList.add(AnimationController(
          duration:
              widget.navBarEssentials!.itemAnimationProperties?.duration ??
                  const Duration(milliseconds: 400),
          vsync: this));
      _animationList.add(Tween(
              begin: Offset(0, widget.navBarEssentials!.navBarHeight! / 1.5),
              end: Offset.zero)
          .chain(CurveTween(
              curve: widget.navBarEssentials!.itemAnimationProperties?.curve ??
                  Curves.ease))
          .animate(_animationControllerList[i]));
    }

    WidgetsBinding.instance.addPostFrameCallback((final _) {
      _animationControllerList[_selectedIndex!].forward();
    });
  }

  Widget _buildItem(final PersistentBottomNavBarItem item,
      final bool isSelected, final double? height, final int itemIndex) {
    final double itemWidth = (MediaQuery.of(context).size.width -
            ((widget.navBarEssentials!.padding?.left ??
                    MediaQuery.of(context).size.width * 0.05) +
                (widget.navBarEssentials!.padding?.right ??
                    MediaQuery.of(context).size.width * 0.05))) /
        widget.navBarEssentials!.items!.length;
    return widget.navBarEssentials!.navBarHeight == 0
        ? const SizedBox.shrink()
        : AnimatedBuilder(
            animation: _animationList[itemIndex],
            builder: (final context, final child) => SizedBox(
              width: 150,
              height: height,
              child: Container(
                alignment: Alignment.center,
                height: height,
                child: Column(
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
                      Transform.translate(
                        offset: _animationList[itemIndex].value,
                        child: AnimatedContainer(
                          duration: widget.navBarEssentials!
                                  .itemAnimationProperties?.duration ??
                              const Duration(milliseconds: 400),
                          height: 5,
                          width: itemWidth * 0.8,
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(100),
                              color: isSelected
                                  ? (item.activeColorSecondary ??
                                      item.activeColorPrimary)
                                  : Colors.transparent),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          );
  }

  @override
  void dispose() {
    for (int i = 0; i < widget.navBarEssentials!.items!.length; ++i) {
      _animationControllerList[i].dispose();
    }
    super.dispose();
  }

  @override
  Widget build(final BuildContext context) {
    if (widget.navBarEssentials!.items!.length !=
        _animationControllerList.length) {
      _animationControllerList =
          List<AnimationController>.empty(growable: true);
      _animationList = List<Animation<Offset>>.empty(growable: true);

      for (int i = 0; i < widget.navBarEssentials!.items!.length; ++i) {
        _animationControllerList.add(AnimationController(
            duration:
                widget.navBarEssentials!.itemAnimationProperties?.duration ??
                    const Duration(milliseconds: 400),
            vsync: this));
        _animationList.add(Tween(
                begin: Offset(0, widget.navBarEssentials!.navBarHeight! / 2.0),
                end: Offset.zero)
            .chain(CurveTween(
                curve:
                    widget.navBarEssentials!.itemAnimationProperties?.curve ??
                        Curves.ease))
            .animate(_animationControllerList[i]));
      }
    }
    if (widget.navBarEssentials!.selectedIndex != _selectedIndex) {
      _lastSelectedIndex = _selectedIndex;
      _selectedIndex = widget.navBarEssentials!.selectedIndex;
      _animationControllerList[_selectedIndex!].forward();
      _animationControllerList[_lastSelectedIndex!].reverse();
    }
    return Container(
      width: double.infinity,
      height: widget.navBarEssentials!.navBarHeight,
      padding: EdgeInsets.only(
          left: widget.navBarEssentials!.padding?.left ??
              MediaQuery.of(context).size.width * 0.04,
          right: widget.navBarEssentials!.padding?.right ??
              MediaQuery.of(context).size.width * 0.04,
          top: widget.navBarEssentials!.padding?.top ??
              widget.navBarEssentials!.navBarHeight! * 0.15,
          bottom: widget.navBarEssentials!.padding?.bottom ??
              widget.navBarEssentials!.navBarHeight! * 0.12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: widget.navBarEssentials!.items!.map((final item) {
          final int index = widget.navBarEssentials!.items!.indexOf(item);
          return Expanded(
            child: GestureDetector(
              onTap: () {
                if (widget.navBarEssentials!.items![index].onPressed != null) {
                  widget.navBarEssentials!.items![index].onPressed!(
                      widget.navBarEssentials!.selectedScreenBuildContext);
                } else {
                  if (index != _selectedIndex) {
                    _lastSelectedIndex = _selectedIndex;
                    _selectedIndex = index;
                    _animationControllerList[_selectedIndex!].forward();
                    _animationControllerList[_lastSelectedIndex!].reverse();
                  }
                  widget.navBarEssentials!.onItemSelected!(index);
                }
              },
              child: Container(
                color: Colors.transparent,
                child: _buildItem(
                    item,
                    widget.navBarEssentials!.selectedIndex == index,
                    widget.navBarEssentials!.navBarHeight,
                    index),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class BottomNavStyle14 extends StatefulWidget {
  const BottomNavStyle14({
    final Key? key,
    this.navBarEssentials = const NavBarEssentials(items: null),
  }) : super(key: key);
  final NavBarEssentials? navBarEssentials;

  @override
  _BottomNavStyle14State createState() => _BottomNavStyle14State();
}

class _BottomNavStyle14State extends State<BottomNavStyle14>
    with TickerProviderStateMixin {
  late List<AnimationController> _animationControllerList;
  late List<Animation<Offset>> _animationList;

  int? _lastSelectedIndex;
  int? _selectedIndex;

  @override
  void initState() {
    super.initState();
    _lastSelectedIndex = 0;
    _selectedIndex = 0;
    _animationControllerList = List<AnimationController>.empty(growable: true);
    _animationList = List<Animation<Offset>>.empty(growable: true);

    for (int i = 0; i < widget.navBarEssentials!.items!.length; ++i) {
      _animationControllerList.add(AnimationController(
          duration:
              widget.navBarEssentials!.itemAnimationProperties?.duration ??
                  const Duration(milliseconds: 400),
          vsync: this));
      _animationList.add(Tween(
              begin: Offset(0, widget.navBarEssentials!.navBarHeight! / 1.5),
              end: Offset.zero)
          .chain(CurveTween(
              curve: widget.navBarEssentials!.itemAnimationProperties?.curve ??
                  Curves.ease))
          .animate(_animationControllerList[i]));
    }

    WidgetsBinding.instance.addPostFrameCallback((final _) {
      _animationControllerList[_selectedIndex!].forward();
    });
  }

  Widget _buildItem(final PersistentBottomNavBarItem item,
      final bool isSelected, final double? height, final int itemIndex) {
    final double itemWidth = (MediaQuery.of(context).size.width -
            ((widget.navBarEssentials!.padding?.left ??
                    MediaQuery.of(context).size.width * 0.05) +
                (widget.navBarEssentials!.padding?.right ??
                    MediaQuery.of(context).size.width * 0.05))) /
        widget.navBarEssentials!.items!.length;
    return widget.navBarEssentials!.navBarHeight == 0
        ? const SizedBox.shrink()
        : AnimatedBuilder(
            animation: _animationList[itemIndex],
            builder: (final context, final child) => SizedBox(
              width: 150,
              height: height,
              child: Container(
                alignment: Alignment.center,
                height: height,
                child: Column(
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
                        padding: const EdgeInsets.only(top: 12, bottom: 2),
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
                            ),
                          ),
                        ),
                      ),
                    Transform.translate(
                      offset: _animationList[itemIndex].value,
                      child: AnimatedContainer(
                        duration: widget.navBarEssentials!
                                .itemAnimationProperties?.duration ??
                            const Duration(milliseconds: 400),
                        height: 5,
                        width: itemWidth * 0.8,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(100),
                            color: isSelected
                                ? (item.activeColorSecondary ??
                                    item.activeColorPrimary)
                                : Colors.transparent),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
  }

  @override
  void dispose() {
    for (int i = 0; i < widget.navBarEssentials!.items!.length; ++i) {
      _animationControllerList[i].dispose();
    }
    super.dispose();
  }

  @override
  Widget build(final BuildContext context) {
    if (widget.navBarEssentials!.items!.length !=
        _animationControllerList.length) {
      _animationControllerList =
          List<AnimationController>.empty(growable: true);
      _animationList = List<Animation<Offset>>.empty(growable: true);

      for (int i = 0; i < widget.navBarEssentials!.items!.length; ++i) {
        _animationControllerList.add(AnimationController(
            duration:
                widget.navBarEssentials!.itemAnimationProperties?.duration ??
                    const Duration(milliseconds: 400),
            vsync: this));
        _animationList.add(Tween(
                begin: Offset(0, widget.navBarEssentials!.navBarHeight! / 2.0),
                end: Offset.zero)
            .chain(CurveTween(
                curve:
                    widget.navBarEssentials!.itemAnimationProperties?.curve ??
                        Curves.ease))
            .animate(_animationControllerList[i]));
      }
    }
    if (widget.navBarEssentials!.selectedIndex != _selectedIndex) {
      _lastSelectedIndex = _selectedIndex;
      _selectedIndex = widget.navBarEssentials!.selectedIndex;
      _animationControllerList[_selectedIndex!].forward();
      _animationControllerList[_lastSelectedIndex!].reverse();
    }
    return Container(
      width: double.infinity,
      height: widget.navBarEssentials!.navBarHeight,
      padding: EdgeInsets.only(
          left: widget.navBarEssentials!.padding?.left ??
              MediaQuery.of(context).size.width * 0.04,
          right: widget.navBarEssentials!.padding?.right ??
              MediaQuery.of(context).size.width * 0.04,
          top: widget.navBarEssentials!.padding?.top ??
              widget.navBarEssentials!.navBarHeight! * 0.12,
          bottom: widget.navBarEssentials!.padding?.bottom ??
              widget.navBarEssentials!.navBarHeight! * 0.03),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: widget.navBarEssentials!.items!.map((final item) {
          final int index = widget.navBarEssentials!.items!.indexOf(item);
          return Expanded(
            child: GestureDetector(
              onTap: () {
                if (widget.navBarEssentials!.items![index].onPressed != null) {
                  widget.navBarEssentials!.items![index].onPressed!(
                      widget.navBarEssentials!.selectedScreenBuildContext);
                } else {
                  if (index != _selectedIndex) {
                    _lastSelectedIndex = _selectedIndex;
                    _selectedIndex = index;
                    _animationControllerList[_selectedIndex!].forward();
                    _animationControllerList[_lastSelectedIndex!].reverse();
                  }
                  widget.navBarEssentials!.onItemSelected!(index);
                }
              },
              child: Container(
                color: Colors.transparent,
                child: _buildItem(
                    item,
                    widget.navBarEssentials!.selectedIndex == index,
                    widget.navBarEssentials!.navBarHeight,
                    index),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class BottomNavStyle15 extends StatelessWidget {
  const BottomNavStyle15({
    final Key? key,
    this.navBarEssentials = const NavBarEssentials(items: null),
    this.navBarDecoration = const NavBarDecoration(),
  }) : super(key: key);
  final NavBarEssentials? navBarEssentials;
  final NavBarDecoration? navBarDecoration;

  Widget _buildItem(
          final BuildContext context,
          final PersistentBottomNavBarItem item,
          final bool isSelected,
          final double? height) =>
      navBarEssentials!.navBarHeight == 0
          ? const SizedBox.shrink()
          : Container(
              width: 150,
              height: height,
              color: Colors.transparent,
              padding: EdgeInsets.only(
                  top: navBarEssentials!.padding?.top ??
                      navBarEssentials!.navBarHeight! * 0.15,
                  bottom: navBarEssentials!.padding?.bottom ??
                      navBarEssentials!.navBarHeight! * 0.12),
              child: Container(
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

  Widget _buildMiddleItem(final PersistentBottomNavBarItem item,
          final bool isSelected, final double? height) =>
      navBarEssentials!.navBarHeight == 0
          ? const SizedBox.shrink()
          : Padding(
              padding: EdgeInsets.only(
                  top: navBarEssentials!.padding?.top ?? 0.0,
                  bottom: navBarEssentials!.padding?.bottom ?? 0.0),
              child: Stack(
                children: <Widget>[
                  Transform.translate(
                    offset: const Offset(0, -23),
                    child: Center(
                      child: Container(
                        width: 150,
                        height: height,
                        margin: const EdgeInsets.only(top: 2),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: item.activeColorPrimary,
                          border:
                              Border.all(color: Colors.transparent, width: 5),
                          boxShadow: navBarDecoration!.boxShadow,
                        ),
                        child: Container(
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
                                          color: item.activeColorSecondary ??
                                              item.activeColorPrimary),
                                      child: isSelected
                                          ? item.icon
                                          : item.inactiveIcon ?? item.icon,
                                    ),
                                  ),
                                ],
                              )
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  if (item.title == null)
                    const SizedBox.shrink()
                  else
                    Padding(
                      padding: const EdgeInsets.only(bottom: 5),
                      child: Align(
                        alignment: Alignment.bottomCenter,
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
                                        ? (item.activeColorPrimary)
                                        : item.inactiveColorPrimary,
                                    fontWeight: FontWeight.w400,
                                    fontSize: 12),
                          )),
                        ),
                      ),
                    )
                ],
              ),
            );

  @override
  Widget build(final BuildContext context) {
    final midIndex = (navBarEssentials!.items!.length / 2).floor();
    return SizedBox(
      width: double.infinity,
      height: navBarEssentials!.navBarHeight,
      child: Stack(
        children: <Widget>[
          ClipRRect(
            borderRadius: navBarDecoration!.borderRadius ?? BorderRadius.zero,
            child: BackdropFilter(
              filter: navBarEssentials!
                      .items![navBarEssentials!.selectedIndex!].filter ??
                  ImageFilter.blur(sigmaX: 0.5, sigmaY: 0.5),
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
                      child: index == midIndex
                          ? Container(width: 150, color: Colors.transparent)
                          : _buildItem(
                              context,
                              item,
                              navBarEssentials!.selectedIndex == index,
                              navBarEssentials!.navBarHeight),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
          if (navBarEssentials!.navBarHeight == 0)
            const SizedBox.shrink()
          else
            Center(
              child: GestureDetector(
                  onTap: () {
                    if (navBarEssentials!.items![midIndex].onPressed != null) {
                      navBarEssentials!.items![midIndex].onPressed!(
                          navBarEssentials!.selectedScreenBuildContext);
                    } else {
                      navBarEssentials!.onItemSelected!(midIndex);
                    }
                  },
                  child: _buildMiddleItem(
                      navBarEssentials!.items![midIndex],
                      navBarEssentials!.selectedIndex == midIndex,
                      navBarEssentials!.navBarHeight)),
            )
        ],
      ),
    );
  }
}

class BottomNavStyle16 extends StatelessWidget {
  const BottomNavStyle16({
    final Key? key,
    this.navBarEssentials = const NavBarEssentials(items: null),
    this.navBarDecoration = const NavBarDecoration(),
  }) : super(key: key);
  final NavBarEssentials? navBarEssentials;
  final NavBarDecoration? navBarDecoration;

  Widget _buildItem(final PersistentBottomNavBarItem item,
          final bool isSelected, final double? height) =>
      navBarEssentials!.navBarHeight == 0
          ? const SizedBox.shrink()
          : Container(
              width: 150,
              height: height,
              padding: EdgeInsets.only(
                  top: navBarEssentials!.padding?.top ??
                      navBarEssentials!.navBarHeight! * 0.15,
                  bottom: navBarEssentials!.padding?.bottom ??
                      navBarEssentials!.navBarHeight! * 0.12),
              child: Container(
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

  Widget _buildMiddleItem(
          final BuildContext context,
          final PersistentBottomNavBarItem item,
          final bool isSelected,
          final double? height) =>
      navBarEssentials!.navBarHeight == 0
          ? const SizedBox.shrink()
          : Padding(
              padding: EdgeInsets.only(
                  top: navBarEssentials!.padding?.top ?? 0.0,
                  bottom: navBarEssentials!.padding?.bottom ?? 0.0),
              child: Stack(
                children: <Widget>[
                  Transform.translate(
                    offset: const Offset(0, -23),
                    child: Center(
                      child: Container(
                        width: height! - 5.0,
                        height: height - 5.0,
                        margin:
                            const EdgeInsets.only(top: 2, left: 6, right: 6),
                        decoration: BoxDecoration(
                          color: item.activeColorPrimary,
                          border:
                              Border.all(color: Colors.transparent, width: 5),
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: navBarDecoration!.boxShadow,
                        ),
                        child: Container(
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
                                        color: item.activeColorSecondary ??
                                            item.activeColorPrimary,
                                      ),
                                      child: isSelected
                                          ? item.icon
                                          : item.inactiveIcon ?? item.icon,
                                    ),
                                  ),
                                ],
                              )
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  if (item.title == null)
                    const SizedBox.shrink()
                  else
                    Padding(
                      padding: const EdgeInsets.only(bottom: 5),
                      child: Align(
                        alignment: Alignment.bottomCenter,
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
                                        ? (item.activeColorPrimary)
                                        : item.inactiveColorPrimary,
                                    fontWeight: FontWeight.w400,
                                    fontSize: 12),
                          )),
                        ),
                      ),
                    )
                ],
              ),
            );

  @override
  Widget build(final BuildContext context) {
    final midIndex = (navBarEssentials!.items!.length / 2).floor();
    return SizedBox(
      width: double.infinity,
      height: navBarEssentials!.navBarHeight,
      child: Stack(
        children: <Widget>[
          ClipRRect(
            borderRadius: navBarDecoration!.borderRadius ?? BorderRadius.zero,
            child: BackdropFilter(
              filter: navBarEssentials!
                      .items![navBarEssentials!.selectedIndex!].filter ??
                  ImageFilter.blur(sigmaX: 0.5, sigmaY: 0.5),
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
                      child: index == midIndex
                          ? Container(width: 150, color: Colors.transparent)
                          : _buildItem(
                              item,
                              navBarEssentials!.selectedIndex == index,
                              navBarEssentials!.navBarHeight),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
          if (navBarEssentials!.navBarHeight == 0)
            const SizedBox.shrink()
          else
            Center(
              child: GestureDetector(
                  onTap: () {
                    if (navBarEssentials!.items![midIndex].onPressed != null) {
                      navBarEssentials!.items![midIndex].onPressed!(
                          navBarEssentials!.selectedScreenBuildContext);
                    } else {
                      navBarEssentials!.onItemSelected!(midIndex);
                    }
                  },
                  child: _buildMiddleItem(
                      context,
                      navBarEssentials!.items![midIndex],
                      navBarEssentials!.selectedIndex == midIndex,
                      navBarEssentials!.navBarHeight)),
            )
        ],
      ),
    );
  }
}

class BottomNavStyle17 extends StatelessWidget {
  const BottomNavStyle17({
    final Key? key,
    this.navBarEssentials = const NavBarEssentials(items: null),
    this.navBarDecoration = const NavBarDecoration(),
  }) : super(key: key);
  final NavBarEssentials? navBarEssentials;
  final NavBarDecoration? navBarDecoration;

  Widget _buildItem(final PersistentBottomNavBarItem item,
          final bool isSelected, final double? height) =>
      navBarEssentials!.navBarHeight == 0
          ? const SizedBox.shrink()
          : Container(
              width: 150,
              height: height,
              padding: EdgeInsets.only(
                  top: navBarEssentials!.padding?.top ??
                      navBarEssentials!.navBarHeight! * 0.15,
                  bottom: navBarEssentials!.padding?.bottom ??
                      navBarEssentials!.navBarHeight! * 0.12),
              child: Container(
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

  Widget _buildMiddleItem(final PersistentBottomNavBarItem item,
          final bool isSelected, final double? height) =>
      navBarEssentials!.navBarHeight == 0
          ? const SizedBox.shrink()
          : Container(
              width: 150,
              height: height,
              margin: EdgeInsets.only(
                  top: navBarEssentials!.padding?.top ??
                      navBarEssentials!.navBarHeight! * 0.06,
                  bottom: navBarEssentials!.padding?.bottom ??
                      navBarEssentials!.navBarHeight! * 0.06),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: item.activeColorPrimary,
                border: Border.all(color: Colors.transparent, width: 5),
              ),
              child: Container(
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
                      ],
                    )
                  ],
                ),
              ),
            );

  @override
  Widget build(final BuildContext context) {
    final midIndex = (navBarEssentials!.items!.length / 2).floor();
    return ClipRRect(
      borderRadius: navBarDecoration!.borderRadius ?? BorderRadius.zero,
      child: Stack(
        children: <Widget>[
          SizedBox(
            width: double.infinity,
            height: navBarEssentials!.navBarHeight,
            child: Stack(
              fit: StackFit.expand,
              children: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: navBarEssentials!.items!.map((final item) {
                    final int index = navBarEssentials!.items!.indexOf(item);
                    return Flexible(
                      child: GestureDetector(
                        onTap: () {
                          if (navBarEssentials!.items![index].onPressed !=
                              null) {
                            navBarEssentials!.items![index].onPressed!(
                                navBarEssentials!.selectedScreenBuildContext);
                          } else {
                            navBarEssentials!.onItemSelected!(index);
                          }
                        },
                        child: index == midIndex
                            ? Opacity(
                                opacity: 0,
                                child: _buildMiddleItem(
                                    item,
                                    navBarEssentials!.selectedIndex == index,
                                    navBarEssentials!.navBarHeight))
                            : _buildItem(
                                item,
                                navBarEssentials!.selectedIndex == index,
                                navBarEssentials!.navBarHeight),
                      ),
                    );
                  }).toList(),
                ),
                Center(
                  child: GestureDetector(
                      onTap: () {
                        if (navBarEssentials!.items![midIndex].onPressed !=
                            null) {
                          navBarEssentials!.items![midIndex].onPressed!(
                              navBarEssentials!.selectedScreenBuildContext);
                        } else {
                          navBarEssentials!.onItemSelected!(midIndex);
                        }
                      },
                      child: _buildMiddleItem(
                          navBarEssentials!.items![midIndex],
                          navBarEssentials!.selectedIndex == midIndex,
                          navBarEssentials!.navBarHeight)),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class BottomNavStyle18 extends StatelessWidget {
  const BottomNavStyle18({
    final Key? key,
    this.navBarEssentials = const NavBarEssentials(items: null),
    this.navBarDecoration = const NavBarDecoration(),
  }) : super(key: key);
  final NavBarEssentials? navBarEssentials;
  final NavBarDecoration? navBarDecoration;

  Widget _buildItem(final PersistentBottomNavBarItem item,
          final bool isSelected, final double? height) =>
      navBarEssentials!.navBarHeight == 0
          ? const SizedBox.shrink()
          : Container(
              width: 150,
              height: height,
              padding: EdgeInsets.only(
                  top: navBarEssentials!.padding?.top ??
                      navBarEssentials!.navBarHeight! * 0.15,
                  bottom: navBarEssentials!.padding?.bottom ??
                      navBarEssentials!.navBarHeight! * 0.12),
              child: Container(
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

  Widget _buildMiddleItem(
          final BuildContext context,
          final PersistentBottomNavBarItem item,
          final bool isSelected,
          final double? height) =>
      navBarEssentials!.navBarHeight == 0
          ? const SizedBox.shrink()
          : Container(
              width: MediaQuery.of(context).size.width / 5.0,
              margin: EdgeInsets.only(
                  top: navBarEssentials!.padding?.top ??
                      navBarEssentials!.navBarHeight! * 0.1,
                  bottom: navBarEssentials!.padding?.bottom ??
                      navBarEssentials!.navBarHeight! * 0.1,
                  left: 10,
                  right: 10),
              decoration: BoxDecoration(
                color: item.activeColorPrimary,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.transparent, width: 5),
              ),
              child: Container(
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
                      ],
                    )
                  ],
                ),
              ),
            );

  @override
  Widget build(final BuildContext context) {
    final midIndex = (navBarEssentials!.items!.length / 2).floor();
    return ClipRRect(
      borderRadius: navBarDecoration!.borderRadius ?? BorderRadius.zero,
      child: Stack(
        children: <Widget>[
          SizedBox(
            width: double.infinity,
            height: navBarEssentials!.navBarHeight,
            child: Stack(
              fit: StackFit.expand,
              children: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: navBarEssentials!.items!.map((final item) {
                    final int index = navBarEssentials!.items!.indexOf(item);
                    return index != midIndex
                        ? Flexible(
                            child: GestureDetector(
                              onTap: () {
                                if (navBarEssentials!.items![index].onPressed !=
                                    null) {
                                  navBarEssentials!.items![index].onPressed!(
                                      navBarEssentials!
                                          .selectedScreenBuildContext);
                                } else {
                                  navBarEssentials!.onItemSelected!(index);
                                }
                              },
                              child: index == midIndex
                                  ? Opacity(
                                      opacity: 0,
                                      child: _buildMiddleItem(
                                          context,
                                          item,
                                          navBarEssentials!.selectedIndex ==
                                              index,
                                          navBarEssentials!.navBarHeight))
                                  : _buildItem(
                                      item,
                                      navBarEssentials!.selectedIndex == index,
                                      navBarEssentials!.navBarHeight),
                            ),
                          )
                        : GestureDetector(
                            onTap: () {
                              if (navBarEssentials!.items![index].onPressed !=
                                  null) {
                                navBarEssentials!.items![index].onPressed!(
                                    navBarEssentials!
                                        .selectedScreenBuildContext);
                              } else {
                                navBarEssentials!.onItemSelected!(index);
                              }
                            },
                            child: index == midIndex
                                ? Opacity(
                                    opacity: 0,
                                    child: _buildMiddleItem(
                                        context,
                                        item,
                                        navBarEssentials!.selectedIndex ==
                                            index,
                                        navBarEssentials!.navBarHeight))
                                : _buildItem(
                                    item,
                                    navBarEssentials!.selectedIndex == index,
                                    navBarEssentials!.navBarHeight),
                          );
                  }).toList(),
                ),
                Center(
                  child: GestureDetector(
                      onTap: () {
                        if (navBarEssentials!.items![midIndex].onPressed !=
                            null) {
                          navBarEssentials!.items![midIndex].onPressed!(
                              navBarEssentials!.selectedScreenBuildContext);
                        } else {
                          navBarEssentials!.onItemSelected!(midIndex);
                        }
                      },
                      child: _buildMiddleItem(
                          context,
                          navBarEssentials!.items![midIndex],
                          navBarEssentials!.selectedIndex == midIndex,
                          navBarEssentials!.navBarHeight)),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class BottomNavStyle19 extends StatelessWidget {
  const BottomNavStyle19({
    final Key? key,
    this.navBarEssentials = const NavBarEssentials(items: null),
  }) : super(key: key);
  final NavBarEssentials? navBarEssentials;

  Widget _buildItem(final PersistentBottomNavBarItem item,
          final bool isSelected, final double? height) =>
      navBarEssentials!.navBarHeight == 0
          ? const SizedBox.shrink()
          : SizedBox(
              width: 150,
              height: height,
              child: Center(
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
            );

  @override
  Widget build(final BuildContext context) {
    final padding = EdgeInsets.only(
      left: navBarEssentials!.padding?.left ??
          MediaQuery.of(context).size.width * 0.05,
      right: navBarEssentials!.padding?.right ??
          MediaQuery.of(context).size.width * 0.05,
      top: navBarEssentials!.padding?.top ??
          navBarEssentials!.navBarHeight! * 0.06,
      bottom: navBarEssentials!.padding?.bottom ??
          navBarEssentials!.navBarHeight! * 0.16,
    );
    final double itemWidth = (MediaQuery.of(context).size.width -
            ((navBarEssentials!.padding?.left ??
                    MediaQuery.of(context).size.width * 0.05) +
                (navBarEssentials!.padding?.right ??
                    MediaQuery.of(context).size.width * 0.05))) /
        navBarEssentials!.items!.length;
    return SizedBox(
      width: double.infinity,
      height: navBarEssentials!.navBarHeight,
      child: Stack(
        children: [
          Transform.translate(
            offset: const Offset(0, -20),
            child: CurvedBazier(
              color: navBarEssentials?.backgroundColor?.withOpacity(
                      navBarEssentials!
                          .items![navBarEssentials!.selectedIndex!].opacity) ??
                  Colors.white,
              index: navBarEssentials?.selectedIndex ?? 0,
              numberOfTabItems: navBarEssentials?.items?.length ?? 0,
              padding: padding,
            ),
          ),
          Padding(
            padding: padding,
            child: Stack(
              children: [
                Row(
                  children: [
                    AnimatedContainer(
                      duration:
                          navBarEssentials!.itemAnimationProperties!.duration ??
                              const Duration(milliseconds: 300),
                      curve: navBarEssentials!.itemAnimationProperties!.curve ??
                          Curves.ease,
                      color: Colors.transparent,
                      width: navBarEssentials!.selectedIndex == 0
                          ? 0
                          : itemWidth * navBarEssentials!.selectedIndex!,
                      height: 4,
                    ),
                    Flexible(
                      child: Transform.translate(
                        offset: const Offset(0, -5),
                        child: Transform.scale(
                          scale: 1.6,
                          child: AnimatedContainer(
                            duration: navBarEssentials!
                                    .itemAnimationProperties!.duration ??
                                const Duration(milliseconds: 300),
                            curve: navBarEssentials!
                                    .itemAnimationProperties!.curve ??
                                Curves.ease,
                            width: itemWidth,
                            height: itemWidth,
                            alignment: Alignment.center,
                            child: Container(
                              height: itemWidth,
                              width: itemWidth,
                              decoration: BoxDecoration(
                                color: navBarEssentials?.backgroundColor
                                        ?.withOpacity(navBarEssentials!
                                            .items![navBarEssentials!
                                                .selectedIndex!]
                                            .opacity) ??
                                    Colors.white,
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: navBarEssentials!.items!.map((final item) {
                    final int index = navBarEssentials!.items!.indexOf(item);
                    return Expanded(
                      child: GestureDetector(
                        onTap: () {
                          if (navBarEssentials!.items![index].onPressed !=
                              null) {
                            navBarEssentials!.items![index].onPressed!(
                                navBarEssentials!.selectedScreenBuildContext);
                          } else {
                            navBarEssentials!.onItemSelected!(index);
                          }
                        },
                        child: _buildItem(
                          item,
                          navBarEssentials!.selectedIndex == index,
                          (navBarEssentials!.navBarHeight ??
                                  kBottomNavigationBarHeight) -
                              20,
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class BottomNavStyle2 extends StatelessWidget {
  const BottomNavStyle2({
    final Key? key,
    this.navBarEssentials = const NavBarEssentials(items: null),
  }) : super(key: key);
  final NavBarEssentials? navBarEssentials;

  Widget _buildItem(final PersistentBottomNavBarItem item,
          final bool isSelected, final double? height) =>
      navBarEssentials!.navBarHeight == 0
          ? const SizedBox.shrink()
          : SizedBox(
              width: 150,
              height: height! / 1,
              child: Container(
                alignment: Alignment.center,
                height: height / 1,
                child: Column(
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
                            isSelected ? item.title! : " ",
                            style: item.textStyle != null
                                ? (item.textStyle!.apply(
                                    color: isSelected
                                        ? (item.activeColorSecondary ??
                                            item.activeColorPrimary)
                                        : item.inactiveColorPrimary))
                                : TextStyle(
                                    color: item.activeColorSecondary ??
                                        item.activeColorPrimary,
                                    fontWeight: FontWeight.w400,
                                    fontSize: 12),
                          )),
                        ),
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
                MediaQuery.of(context).size.width * 0.05,
            right: navBarEssentials!.padding?.right ??
                MediaQuery.of(context).size.width * 0.05,
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
                child: Container(
                  color: Colors.transparent,
                  child: _buildItem(
                      item,
                      navBarEssentials!.selectedIndex == index,
                      navBarEssentials!.navBarHeight),
                ),
              ),
            );
          }).toList(),
        ),
      );
}

class BottomNavStyle3 extends StatelessWidget {
  const BottomNavStyle3({
    final Key? key,
    this.navBarEssentials = const NavBarEssentials(items: null),
  }) : super(key: key);
  final NavBarEssentials? navBarEssentials;

  Widget _buildItem(final PersistentBottomNavBarItem item,
          final bool isSelected, final double? height) =>
      navBarEssentials!.navBarHeight == 0
          ? const SizedBox.shrink()
          : AnimatedContainer(
              width: 100,
              height: height! / 1.0,
              duration: navBarEssentials!.itemAnimationProperties?.duration ??
                  const Duration(milliseconds: 1000),
              curve: navBarEssentials!.itemAnimationProperties?.curve ??
                  Curves.ease,
              alignment: Alignment.center,
              child: AnimatedContainer(
                duration: navBarEssentials!.itemAnimationProperties?.duration ??
                    const Duration(milliseconds: 1000),
                curve: navBarEssentials!.itemAnimationProperties?.curve ??
                    Curves.ease,
                alignment: Alignment.center,
                height: height / 1.0,
                child: Column(
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
                          child: DefaultTextStyle.merge(
                            style: TextStyle(
                                color: item.textStyle != null
                                    ? item.textStyle!.apply(
                                            color: isSelected
                                                ? (item.activeColorSecondary ??
                                                    item.activeColorPrimary)
                                                : item.inactiveColorPrimary)
                                        as Color?
                                    : isSelected
                                        ? (item.activeColorSecondary ??
                                            item.activeColorPrimary)
                                        : item.inactiveColorPrimary,
                                fontWeight: FontWeight.w400,
                                fontSize: 12),
                            child: FittedBox(child: Text(item.title!)),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            );

  @override
  Widget build(final BuildContext context) {
    final Color selectedItemActiveColor = navBarEssentials!
        .items![navBarEssentials!.selectedIndex!].activeColorPrimary;
    final double itemWidth = (MediaQuery.of(context).size.width -
            ((navBarEssentials!.padding?.left ??
                    MediaQuery.of(context).size.width * 0.05) +
                (navBarEssentials!.padding?.right ??
                    MediaQuery.of(context).size.width * 0.05))) /
        navBarEssentials!.items!.length;
    return Container(
      width: double.infinity,
      height: navBarEssentials!.navBarHeight,
      padding: EdgeInsets.only(
          top: navBarEssentials!.padding?.top ?? 0.0,
          left: navBarEssentials!.padding?.left ??
              MediaQuery.of(context).size.width * 0.05,
          right: navBarEssentials!.padding?.right ??
              MediaQuery.of(context).size.width * 0.05,
          bottom: navBarEssentials!.padding?.bottom ??
              navBarEssentials!.navBarHeight! * 0.1),
      child: Column(
        children: <Widget>[
          Row(
            children: <Widget>[
              AnimatedContainer(
                duration: navBarEssentials!.itemAnimationProperties?.duration ??
                    const Duration(milliseconds: 300),
                curve: navBarEssentials!.itemAnimationProperties?.curve ??
                    Curves.ease,
                color: Colors.transparent,
                width: navBarEssentials!.selectedIndex == 0
                    ? MediaQuery.of(context).size.width * 0.0
                    : itemWidth * navBarEssentials!.selectedIndex!,
                height: 4,
              ),
              Flexible(
                child: AnimatedContainer(
                  duration:
                      navBarEssentials!.itemAnimationProperties?.duration ??
                          const Duration(milliseconds: 300),
                  curve: navBarEssentials!.itemAnimationProperties?.curve ??
                      Curves.ease,
                  width: itemWidth,
                  height: 4,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: selectedItemActiveColor,
                    borderRadius: BorderRadius.circular(100),
                  ),
                ),
              )
            ],
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(top: 5),
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
                      child: Container(
                        color: Colors.transparent,
                        child: _buildItem(
                            item,
                            navBarEssentials!.selectedIndex == index,
                            navBarEssentials!.navBarHeight),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class BottomNavStyle4 extends StatelessWidget {
  const BottomNavStyle4({
    final Key? key,
    this.navBarEssentials = const NavBarEssentials(items: null),
  }) : super(key: key);
  final NavBarEssentials? navBarEssentials;

  Widget _buildItem(final PersistentBottomNavBarItem item,
          final bool isSelected, final double? height) =>
      navBarEssentials!.navBarHeight == 0
          ? const SizedBox.shrink()
          : AnimatedContainer(
              width: 100,
              height: height,
              duration: navBarEssentials!.itemAnimationProperties!.duration ??
                  const Duration(milliseconds: 1000),
              curve: navBarEssentials!.itemAnimationProperties!.curve ??
                  Curves.ease,
              child: AnimatedContainer(
                alignment: Alignment.center,
                duration: navBarEssentials!.itemAnimationProperties!.duration ??
                    const Duration(milliseconds: 1000),
                curve: navBarEssentials!.itemAnimationProperties!.curve ??
                    Curves.ease,
                height: height! / 1.6,
                child: Column(
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
                          child: DefaultTextStyle.merge(
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
                            child: FittedBox(
                                child: Text(isSelected ? item.title! : " ")),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            );

  @override
  Widget build(final BuildContext context) {
    final Color selectedItemActiveColor = navBarEssentials!
        .items![navBarEssentials!.selectedIndex!].activeColorPrimary;
    final double itemWidth = (MediaQuery.of(context).size.width -
            ((navBarEssentials!.padding?.left ??
                    MediaQuery.of(context).size.width * 0.05) +
                (navBarEssentials!.padding?.right ??
                    MediaQuery.of(context).size.width * 0.05))) /
        navBarEssentials!.items!.length;
    return Container(
      width: double.infinity,
      height: navBarEssentials!.navBarHeight,
      padding: EdgeInsets.only(
          top: navBarEssentials!.padding?.top ?? 0.0,
          left: navBarEssentials!.padding?.left ??
              MediaQuery.of(context).size.width * 0.05,
          right: navBarEssentials!.padding?.right ??
              MediaQuery.of(context).size.width * 0.05,
          bottom: navBarEssentials!.padding?.bottom ??
              navBarEssentials!.navBarHeight! * 0.1),
      child: Column(
        children: <Widget>[
          Row(
            children: <Widget>[
              AnimatedContainer(
                duration: navBarEssentials!.itemAnimationProperties!.duration ??
                    const Duration(milliseconds: 300),
                curve: navBarEssentials!.itemAnimationProperties!.curve ??
                    Curves.ease,
                color: Colors.transparent,
                width: navBarEssentials!.selectedIndex == 0
                    ? MediaQuery.of(context).size.width * 0.0
                    : itemWidth * navBarEssentials!.selectedIndex!,
                height: 4,
              ),
              Flexible(
                child: AnimatedContainer(
                  duration:
                      navBarEssentials!.itemAnimationProperties!.duration ??
                          const Duration(milliseconds: 300),
                  curve: navBarEssentials!.itemAnimationProperties!.curve ??
                      Curves.ease,
                  width: itemWidth,
                  height: 4,
                  alignment: Alignment.center,
                  child: Container(
                    height: 4,
                    width: itemWidth,
                    decoration: BoxDecoration(
                      color: selectedItemActiveColor,
                      borderRadius: BorderRadius.circular(100),
                    ),
                  ),
                ),
              )
            ],
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(top: 5),
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
                      child: Container(
                        color: Colors.transparent,
                        child: _buildItem(
                            item,
                            navBarEssentials!.selectedIndex == index,
                            navBarEssentials!.navBarHeight),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class BottomNavStyle5 extends StatelessWidget {
  const BottomNavStyle5({
    final Key? key,
    this.navBarEssentials = const NavBarEssentials(items: null),
  }) : super(key: key);
  final NavBarEssentials? navBarEssentials;

  Widget _buildItem(final PersistentBottomNavBarItem item,
          final bool isSelected, final double? height) =>
      navBarEssentials!.navBarHeight == 0
          ? const SizedBox.shrink()
          : SizedBox(
              width: 150,
              height: height! / 1,
              child: Container(
                alignment: Alignment.center,
                height: height / 1,
                child: Column(
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
                    Container(
                      height: 5,
                      width: 5,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(100),
                          color: isSelected
                              ? (item.activeColorSecondary ??
                                  item.activeColorPrimary)
                              : Colors.transparent),
                    ),
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
                MediaQuery.of(context).size.width * 0.05,
            right: navBarEssentials!.padding?.right ??
                MediaQuery.of(context).size.width * 0.05,
            top: navBarEssentials!.padding?.top ??
                navBarEssentials!.navBarHeight! * 0.06,
            bottom: navBarEssentials!.padding?.bottom ??
                navBarEssentials!.navBarHeight! * 0.16),
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
                child: Container(
                  color: Colors.transparent,
                  child: _buildItem(
                      item,
                      navBarEssentials!.selectedIndex == index,
                      navBarEssentials!.navBarHeight),
                ),
              ),
            );
          }).toList(),
        ),
      );
}

class BottomNavStyle6 extends StatefulWidget {
  const BottomNavStyle6({
    final Key? key,
    this.navBarEssentials = const NavBarEssentials(items: null),
  }) : super(key: key);
  final NavBarEssentials? navBarEssentials;

  @override
  _BottomNavStyle6State createState() => _BottomNavStyle6State();
}

class _BottomNavStyle6State extends State<BottomNavStyle6>
    with TickerProviderStateMixin {
  late List<AnimationController> _animationControllerList;
  late List<Animation<double>> _animationList;

  int? _lastSelectedIndex;
  int? _selectedIndex;

  @override
  void initState() {
    super.initState();
    _lastSelectedIndex = 0;
    _selectedIndex = 0;
    _animationControllerList = List<AnimationController>.empty(growable: true);
    _animationList = List<Animation<double>>.empty(growable: true);

    for (int i = 0; i < widget.navBarEssentials!.items!.length; ++i) {
      _animationControllerList.add(AnimationController(
          duration:
              widget.navBarEssentials!.itemAnimationProperties?.duration ??
                  const Duration(milliseconds: 400),
          vsync: this));
      _animationList.add(Tween(begin: 0.95, end: 1.18)
          .chain(CurveTween(
              curve: widget.navBarEssentials!.itemAnimationProperties?.curve ??
                  Curves.ease))
          .animate(_animationControllerList[i]));
    }

    WidgetsBinding.instance.addPostFrameCallback((final _) {
      _animationControllerList[_selectedIndex!].forward();
    });
  }

  Widget _buildItem(final PersistentBottomNavBarItem item,
          final bool isSelected, final double? height, final int itemIndex) =>
      widget.navBarEssentials!.navBarHeight == 0
          ? const SizedBox.shrink()
          : AnimatedBuilder(
              animation: _animationList[itemIndex],
              builder: (final context, final child) => Transform.scale(
                scale: _animationList[itemIndex].value,
                child: SizedBox(
                  width: 150,
                  height: height,
                  child: Container(
                    alignment: Alignment.center,
                    height: height,
                    child: Column(
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
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            );

  @override
  void dispose() {
    for (int i = 0; i < widget.navBarEssentials!.items!.length; ++i) {
      _animationControllerList[i].dispose();
    }
    super.dispose();
  }

  @override
  Widget build(final BuildContext context) {
    if (widget.navBarEssentials!.items!.length !=
        _animationControllerList.length) {
      _animationControllerList =
          List<AnimationController>.empty(growable: true);
      _animationList = List<Animation<double>>.empty(growable: true);

      for (int i = 0; i < widget.navBarEssentials!.items!.length; ++i) {
        _animationControllerList.add(AnimationController(
            duration:
                widget.navBarEssentials!.itemAnimationProperties?.duration ??
                    const Duration(milliseconds: 400),
            vsync: this));
        _animationList.add(Tween(begin: 0.95, end: 1.18)
            .chain(CurveTween(
                curve:
                    widget.navBarEssentials!.itemAnimationProperties?.curve ??
                        Curves.ease))
            .animate(_animationControllerList[i]));
      }
    }
    if (widget.navBarEssentials!.selectedIndex != _selectedIndex) {
      _lastSelectedIndex = _selectedIndex;
      _selectedIndex = widget.navBarEssentials!.selectedIndex;
      _animationControllerList[_selectedIndex!].forward();
      _animationControllerList[_lastSelectedIndex!].reverse();
    }
    return Container(
      width: double.infinity,
      height: widget.navBarEssentials!.navBarHeight,
      padding: EdgeInsets.only(
          left: widget.navBarEssentials!.padding?.left ??
              MediaQuery.of(context).size.width * 0.04,
          right: widget.navBarEssentials!.padding?.right ??
              MediaQuery.of(context).size.width * 0.04,
          top: widget.navBarEssentials!.padding?.top ??
              widget.navBarEssentials!.navBarHeight! * 0.15,
          bottom: widget.navBarEssentials!.padding?.bottom ??
              widget.navBarEssentials!.navBarHeight! * 0.12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: widget.navBarEssentials!.items!.map((final item) {
          final int index = widget.navBarEssentials!.items!.indexOf(item);
          return Expanded(
            child: GestureDetector(
              onTap: () {
                if (widget.navBarEssentials!.items![index].onPressed != null) {
                  widget.navBarEssentials!.items![index].onPressed!(
                      widget.navBarEssentials!.selectedScreenBuildContext);
                } else {
                  if (index != _selectedIndex) {
                    _lastSelectedIndex = _selectedIndex;
                    _selectedIndex = index;
                    _animationControllerList[_selectedIndex!].forward();
                    _animationControllerList[_lastSelectedIndex!].reverse();
                  }
                  widget.navBarEssentials!.onItemSelected!(index);
                }
              },
              child: Container(
                color: Colors.transparent,
                child: _buildItem(
                    item,
                    widget.navBarEssentials!.selectedIndex == index,
                    widget.navBarEssentials!.navBarHeight,
                    index),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class BottomNavStyle7 extends StatelessWidget {
  const BottomNavStyle7({
    final Key? key,
    this.navBarEssentials = const NavBarEssentials(items: null),
  }) : super(key: key);
  final NavBarEssentials? navBarEssentials;

  Widget _buildItem(final PersistentBottomNavBarItem item,
          final bool isSelected, final double? height) =>
      navBarEssentials!.navBarHeight == 0
          ? const SizedBox.shrink()
          : AnimatedContainer(
              width: isSelected ? 120 : 50,
              height: height! / 1.6,
              duration: navBarEssentials!.itemAnimationProperties?.duration ??
                  const Duration(milliseconds: 400),
              curve: navBarEssentials!.itemAnimationProperties?.curve ??
                  Curves.ease,
              padding: EdgeInsets.all(item.contentPadding),
              decoration: isSelected
                  ? BoxDecoration(
                      color: isSelected
                          ? item.activeColorPrimary
                          : navBarEssentials!.backgroundColor!.withOpacity(0),
                      borderRadius:
                          const BorderRadius.all(Radius.circular(100)),
                    )
                  : BoxDecoration(
                      color: isSelected
                          ? item.activeColorPrimary
                          : navBarEssentials!.backgroundColor!.withOpacity(0),
                      borderRadius:
                          const BorderRadius.all(Radius.circular(100)),
                    ),
              child: Container(
                alignment: Alignment.center,
                height: height / 1.6,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.only(right: 8),
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
                      isSelected
                          ? Flexible(
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
                                          color: item.activeColorSecondary ??
                                              item.activeColorPrimary,
                                          fontWeight: FontWeight.w400,
                                          fontSize: 12),
                                )),
                              ),
                            )
                          : const SizedBox.shrink()
                  ],
                ),
              ),
            );

  @override
  Widget build(final BuildContext context) => Container(
        width: double.infinity,
        height: navBarEssentials!.navBarHeight,
        padding: EdgeInsets.only(
            top: navBarEssentials!.padding?.top ??
                navBarEssentials!.navBarHeight! * 0.15,
            left: navBarEssentials!.padding?.left ??
                MediaQuery.of(context).size.width * 0.07,
            right: navBarEssentials!.padding?.right ??
                MediaQuery.of(context).size.width * 0.07,
            bottom: navBarEssentials!.padding?.bottom ??
                navBarEssentials!.navBarHeight! * 0.15),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: navBarEssentials!.items!.map((final item) {
            final int index = navBarEssentials!.items!.indexOf(item);
            return Flexible(
              flex: navBarEssentials!.selectedIndex == index ? 2 : 1,
              child: GestureDetector(
                onTap: () {
                  if (navBarEssentials!.items![index].onPressed != null) {
                    navBarEssentials!.items![index].onPressed!(
                        navBarEssentials!.selectedScreenBuildContext);
                  } else {
                    navBarEssentials!.onItemSelected!(index);
                  }
                },
                child: Container(
                  color: Colors.transparent,
                  child: _buildItem(
                      item,
                      navBarEssentials!.selectedIndex == index,
                      navBarEssentials!.navBarHeight),
                ),
              ),
            );
          }).toList(),
        ),
      );
}

class BottomNavStyle8 extends StatefulWidget {
  const BottomNavStyle8({
    final Key? key,
    this.navBarEssentials = const NavBarEssentials(items: null),
  }) : super(key: key);
  final NavBarEssentials? navBarEssentials;

  @override
  _BottomNavStyle8State createState() => _BottomNavStyle8State();
}

class _BottomNavStyle8State extends State<BottomNavStyle8>
    with TickerProviderStateMixin {
  late List<AnimationController> _animationControllerList;
  late List<Animation<double>> _animationList;

  int? _lastSelectedIndex;
  int? _selectedIndex;

  @override
  void initState() {
    super.initState();
    _lastSelectedIndex = 0;
    _selectedIndex = 0;
    _animationControllerList = List<AnimationController>.empty(growable: true);
    _animationList = List<Animation<double>>.empty(growable: true);

    for (int i = 0; i < widget.navBarEssentials!.items!.length; ++i) {
      _animationControllerList.add(AnimationController(
          duration:
              widget.navBarEssentials!.itemAnimationProperties?.duration ??
                  const Duration(milliseconds: 400),
          vsync: this));
      _animationList.add(Tween(begin: 0.95, end: 1.2)
          .chain(CurveTween(
              curve: widget.navBarEssentials!.itemAnimationProperties?.curve ??
                  Curves.ease))
          .animate(_animationControllerList[i]));
    }

    WidgetsBinding.instance.addPostFrameCallback((final _) {
      _animationControllerList[_selectedIndex!].forward();
    });
  }

  Widget _buildItem(final PersistentBottomNavBarItem item,
          final bool isSelected, final double? height, final int itemIndex) =>
      widget.navBarEssentials!.navBarHeight == 0
          ? const SizedBox.shrink()
          : Container(
              alignment: Alignment.center,
              height: height,
              width: double.maxFinite,
              child: Column(
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
                    AnimatedBuilder(
                      animation: _animationList[itemIndex],
                      builder: (final context, final child) => Transform.scale(
                        scale: _animationList[itemIndex].value,
                        child: Padding(
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
                              ),
                            ),
                          ),
                        ),
                      ),
                    )
                ],
              ),
            );

  @override
  void dispose() {
    for (int i = 0; i < widget.navBarEssentials!.items!.length; ++i) {
      _animationControllerList[i].dispose();
    }
    super.dispose();
  }

  @override
  Widget build(final BuildContext context) {
    if (widget.navBarEssentials!.items!.length !=
        _animationControllerList.length) {
      _animationControllerList =
          List<AnimationController>.empty(growable: true);
      _animationList = List<Animation<double>>.empty(growable: true);

      for (int i = 0; i < widget.navBarEssentials!.items!.length; ++i) {
        _animationControllerList.add(AnimationController(
            duration:
                widget.navBarEssentials!.itemAnimationProperties?.duration ??
                    const Duration(milliseconds: 400),
            vsync: this));
        _animationList.add(Tween(begin: 0.95, end: 1.18)
            .chain(CurveTween(
                curve:
                    widget.navBarEssentials!.itemAnimationProperties?.curve ??
                        Curves.ease))
            .animate(_animationControllerList[i]));
      }
    }
    if (widget.navBarEssentials!.selectedIndex != _selectedIndex) {
      _lastSelectedIndex = _selectedIndex;
      _selectedIndex = widget.navBarEssentials!.selectedIndex;
      _animationControllerList[_selectedIndex!].forward();
      _animationControllerList[_lastSelectedIndex!].reverse();
    }
    return Container(
      width: double.infinity,
      height: widget.navBarEssentials!.navBarHeight,
      padding: EdgeInsets.only(
          left: widget.navBarEssentials!.padding?.left ??
              MediaQuery.of(context).size.width * 0.04,
          right: widget.navBarEssentials!.padding?.right ??
              MediaQuery.of(context).size.width * 0.04,
          top: widget.navBarEssentials!.padding?.top ??
              widget.navBarEssentials!.navBarHeight! * 0.15,
          bottom: widget.navBarEssentials!.padding?.bottom ??
              widget.navBarEssentials!.navBarHeight! * 0.12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: widget.navBarEssentials!.items!.map((final item) {
          final int index = widget.navBarEssentials!.items!.indexOf(item);
          return Expanded(
            child: GestureDetector(
              onTap: () {
                if (widget.navBarEssentials!.items![index].onPressed != null) {
                  widget.navBarEssentials!.items![index].onPressed!(
                      widget.navBarEssentials!.selectedScreenBuildContext);
                } else {
                  if (index != _selectedIndex) {
                    _lastSelectedIndex = _selectedIndex;
                    _selectedIndex = index;
                    _animationControllerList[_selectedIndex!].forward();
                    _animationControllerList[_lastSelectedIndex!].reverse();
                  }
                  widget.navBarEssentials!.onItemSelected!(index);
                }
              },
              child: Container(
                color: Colors.transparent,
                child: _buildItem(
                    item,
                    widget.navBarEssentials!.selectedIndex == index,
                    widget.navBarEssentials!.navBarHeight,
                    index),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class BottomNavStyle9 extends StatelessWidget {
  const BottomNavStyle9({
    final Key? key,
    this.navBarEssentials = const NavBarEssentials(items: null),
  }) : super(key: key);
  final NavBarEssentials? navBarEssentials;

  Widget _buildItem(final PersistentBottomNavBarItem item,
          final bool isSelected, final double? height) =>
      navBarEssentials!.navBarHeight == 0
          ? const SizedBox.shrink()
          : AnimatedContainer(
              width: isSelected ? 120 : 50,
              height: height! / 1.5,
              duration: navBarEssentials!.itemAnimationProperties?.duration ??
                  const Duration(milliseconds: 400),
              curve: navBarEssentials!.itemAnimationProperties?.curve ??
                  Curves.ease,
              padding: EdgeInsets.all(item.contentPadding),
              decoration: BoxDecoration(
                color: isSelected
                    ? item.activeColorPrimary.withOpacity(0.15)
                    : navBarEssentials!.backgroundColor!.withOpacity(0),
                borderRadius: const BorderRadius.all(Radius.circular(10)),
              ),
              child: Container(
                alignment: Alignment.center,
                height: height / 1.6,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.only(right: 8),
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
                      isSelected
                          ? Flexible(
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
                                            color: item.activeColorSecondary ??
                                                item.activeColorPrimary,
                                            fontWeight: FontWeight.w400,
                                            fontSize: 12),
                                  ),
                                ),
                              ),
                            )
                          : const SizedBox.shrink()
                  ],
                ),
              ),
            );

  @override
  Widget build(final BuildContext context) => Container(
        width: double.infinity,
        height: navBarEssentials!.navBarHeight,
        padding: EdgeInsets.only(
            top: navBarEssentials!.padding?.top ??
                navBarEssentials!.navBarHeight! * 0.15,
            left: navBarEssentials!.padding?.left ??
                MediaQuery.of(context).size.width * 0.07,
            right: navBarEssentials!.padding?.right ??
                MediaQuery.of(context).size.width * 0.07,
            bottom: navBarEssentials!.padding?.bottom ??
                navBarEssentials!.navBarHeight! * 0.15),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: navBarEssentials!.items!.map((final item) {
            final int index = navBarEssentials!.items!.indexOf(item);
            return Flexible(
              flex: navBarEssentials!.selectedIndex == index ? 2 : 1,
              child: GestureDetector(
                onTap: () {
                  if (navBarEssentials!.items![index].onPressed != null) {
                    navBarEssentials!.items![index].onPressed!(
                        navBarEssentials!.selectedScreenBuildContext);
                  } else {
                    navBarEssentials!.onItemSelected!(index);
                  }
                },
                child: Container(
                  color: Colors.transparent,
                  child: _buildItem(
                      item,
                      navBarEssentials!.selectedIndex == index,
                      navBarEssentials!.navBarHeight),
                ),
              ),
            );
          }).toList(),
        ),
      );
}

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';

import 'package:demo_app/core/theme/app_colors.dart';
import 'package:demo_app/core/theme/app_text_styles.dart';

// ========== 1. CUSTOM BUTTON ==========
class _CustomButton extends StatefulWidget {
  const _CustomButton({
    required this.title,
    required this.function,
    this.width,
    this.height,
    this.radius = 8,
    this.color,
    this.textColor,
    this.borderColor,
    this.textStyle,
  });

  final String title;
  final VoidCallback function;
  final double? width;
  final double? height;
  final double radius;
  final Color? color;
  final Color? textColor;
  final Color? borderColor;
  final TextStyle? textStyle;

  @override
  State<_CustomButton> createState() => _CustomButtonState();
}

class _CustomButtonState extends State<_CustomButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _pressAnimation;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    _pressAnimation = Tween<double>(begin: 0.0, end: 1.5).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _onTapDown(TapDownDetails details) async {
    print('🔽 Button pressed - starting animation');
    if (!mounted) return;
    setState(() => _isPressed = true);
    await _controller.forward();
    print('✅ Press animation completed');
  }

  Future<void> _onTapUp(TapUpDetails details) async {
    print('🔼 Button released - reversing animation');
    if (!mounted) return;

    HapticFeedback.mediumImpact();
    await _controller.reverse();

    print('✅ Release animation completed');
    if (!mounted) return;

    setState(() => _isPressed = false);

    // Small delay to ensure animation is visible before navigation
    await Future.delayed(const Duration(milliseconds: 50));

    print('🚀 Executing button function');
    widget.function();
  }

  void _onTapCancel() {
    print('❌ Button tap cancelled');
    if (!mounted) return;
    setState(() => _isPressed = false);
    _controller.reverse();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Get.isDarkMode;

    return GestureDetector(
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Transform.translate(
              offset: Offset(0, _pressAnimation.value),
              child: Container(
                width: widget.width,
                height: widget.height,
                decoration: BoxDecoration(
                  color: widget.color ?? AppColors.primary,
                  borderRadius: BorderRadius.circular(widget.radius),
                  border: Border.all(
                    color: widget.borderColor ?? Colors.transparent,
                  ),
                ),
                child: Center(
                  child: Text(
                    widget.title,
                    style: widget.textStyle ??
                        TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: widget.textColor ??
                              (isDark ? Colors.white : Colors.black),
                        ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

Widget customButton({
  required String title,
  required VoidCallback function,
  double? width,
  double? height,
  double radius = 8,
  Color? color,
  Color? textColor,
  Color? borderColor,
  TextStyle? textStyle,
}) {
  return _CustomButton(
    title: title,
    function: function,
    width: width,
    height: height,
    radius: radius,
    color: color,
    textColor: textColor,
    borderColor: borderColor,
    textStyle: textStyle,
  );
}

// ========== 2. CUSTOM BUTTON WITH ICON ==========
class _CustomButtonWithIcon extends StatefulWidget {
  const _CustomButtonWithIcon({
    required this.title,
    required this.function,
    required this.textStyle,
    required this.width,
    required this.height,
    required this.space,
    required this.radius,
    required this.color,
    required this.icon,
    required this.iconColor,
    required this.iconSize,
  });

  final String title;
  final VoidCallback function;
  final TextStyle textStyle;
  final double width;
  final double height;
  final double space;
  final double radius;
  final Color color;
  final IconData icon;
  final Color iconColor;
  final double iconSize;

  @override
  State<_CustomButtonWithIcon> createState() => _CustomButtonWithIconState();
}

class _CustomButtonWithIconState extends State<_CustomButtonWithIcon>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _pressAnimation;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    _pressAnimation = Tween<double>(begin: 0.0, end: 1.5).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _onTapDown(TapDownDetails details) async {
    print('🔽 Icon Button pressed - starting animation');
    if (!mounted) return;
    setState(() => _isPressed = true);
    await _controller.forward();
    print('✅ Icon Press animation completed');
  }

  Future<void> _onTapUp(TapUpDetails details) async {
    print('🔼 Icon Button released - reversing animation');
    if (!mounted) return;

    HapticFeedback.mediumImpact();
    await _controller.reverse();

    print('✅ Icon Release animation completed');
    if (!mounted) return;

    setState(() => _isPressed = false);

    // Small delay to ensure animation is visible before navigation
    await Future.delayed(const Duration(milliseconds: 50));

    print('🚀 Executing icon button function');
    widget.function();
  }

  void _onTapCancel() {
    print('❌ Icon Button tap cancelled');
    if (!mounted) return;
    setState(() => _isPressed = false);
    _controller.reverse();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Transform.translate(
              offset: Offset(0, _pressAnimation.value),
              child: Container(
                width: widget.width,
                height: widget.height,
                decoration: BoxDecoration(
                  color: widget.color,
                  borderRadius: BorderRadius.circular(widget.radius),
                  boxShadow: _isPressed
                      ? []
                      : [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(widget.icon,
                        size: widget.iconSize, color: widget.iconColor),
                    SizedBox(width: widget.space),
                    Text(widget.title, style: widget.textStyle),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

Widget customButtonWithIcon({
  required String title,
  required VoidCallback function,
  required TextStyle textStyle,
  required double width,
  required double height,
  required double space,
  required double radius,
  required Color color,
  required IconData icon,
  required Color iconColor,
  required double iconSize,
}) {
  return _CustomButtonWithIcon(
    title: title,
    function: function,
    textStyle: textStyle,
    width: width,
    height: height,
    space: space,
    radius: radius,
    color: color,
    icon: icon,
    iconColor: iconColor,
    iconSize: iconSize,
  );
}

// ========== 3. CUSTOM BUTTON WITH IMAGE ==========
class _CustomButtonWithImage extends StatefulWidget {
  const _CustomButtonWithImage({
    required this.title,
    required this.function,
    required this.textStyle,
    this.width,
    required this.height,
    required this.space,
    required this.radius,
    required this.color,
    required this.image,
    required this.widthImage,
    required this.heightImage,
    required this.colorBorder,
    this.svgColor,
    this.padding,
  });

  final String title;
  final VoidCallback function;
  final TextStyle textStyle;
  final double? width;
  final double height;
  final double space;
  final double radius;
  final Color color;
  final String image;
  final double widthImage;
  final double heightImage;
  final Color colorBorder;
  final Color? svgColor;
  final EdgeInsets? padding;

  @override
  State<_CustomButtonWithImage> createState() => _CustomButtonWithImageState();
}

class _CustomButtonWithImageState extends State<_CustomButtonWithImage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _pressAnimation;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    _pressAnimation = Tween<double>(begin: 0.0, end: 1.5).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _onTapDown(TapDownDetails details) async {
    print('🔽 Image Button pressed - starting animation');
    if (!mounted) return;
    setState(() => _isPressed = true);
    await _controller.forward();
    print('✅ Image Press animation completed');
  }

  Future<void> _onTapUp(TapUpDetails details) async {
    print('🔼 Image Button released - reversing animation');
    if (!mounted) return;

    HapticFeedback.mediumImpact();
    await _controller.reverse();

    print('✅ Image Release animation completed');
    if (!mounted) return;

    setState(() => _isPressed = false);

    // Small delay to ensure animation is visible before navigation
    await Future.delayed(const Duration(milliseconds: 50));

    print('🚀 Executing image button function');
    widget.function();
  }

  void _onTapCancel() {
    print('❌ Image Button tap cancelled');
    if (!mounted) return;
    setState(() => _isPressed = false);
    _controller.reverse();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Transform.translate(
              offset: Offset(0, _pressAnimation.value),
              child: Container(
                width: widget.width,
                height: widget.height,
                decoration: BoxDecoration(
                  color: widget.color,
                  border: Border.all(color: widget.colorBorder),
                  borderRadius: BorderRadius.circular(widget.radius),
                ),
                child: widget.title.trim().isEmpty
                    ? Center(
                  child: SvgPicture.asset(
                    widget.image,
                    height: widget.heightImage,
                    width: widget.widthImage,
                    color: widget.svgColor ??
                        AppColors.textButton,
                    fit: BoxFit.scaleDown,
                  ),
                )
                    : Padding(
                  padding: widget.padding ?? EdgeInsets.zero,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SvgPicture.asset(
                        widget.image,
                        height: widget.heightImage,
                        width: widget.widthImage,
                        color: widget.svgColor,
                        fit: BoxFit.fill,
                      ),
                      SizedBox(width: widget.space),
                      Text(widget.title, style: widget.textStyle),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

Widget customButtonWithImage({
  required String title,
  required VoidCallback function,
  required TextStyle textStyle,
  double? width,
  required double height,
  required double space,
  required double radius,
  required Color color,
  required String image,
  required double widthImage,
  required double heightImage,
  required Color colorBorder,
  Color? svgColor,
  EdgeInsets? padding,
}) {
  return _CustomButtonWithImage(
    title: title,
    function: function,
    textStyle: textStyle,
    width: width,
    height: height,
    space: space,
    radius: radius,
    color: color,
    image: image,
    widthImage: widthImage,
    heightImage: heightImage,
    colorBorder: colorBorder,
    svgColor: svgColor,
    padding: padding,
  );
}
import 'package:flutter/material.dart';
import 'package:knowticed_plus/features/qiyas/helpers/helper/row_title.dart';
import 'package:knowticed_plus/core/extensions/screen_fraction_extension.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';

class PageScreenTopLevel extends StatefulWidget {
  const PageScreenTopLevel({
    super.key,
    required this.children,
    this.hasScroll = true,
    this.besideAppBarWidget,
    this.hasBackArrow = false,
    this.isQiyasMode = false,
    required this.title,
    this.functions,
    this.scrum = false,
    this.titles,
  });
  final List<Widget> children;
  final bool hasScroll;
  final bool hasBackArrow;
  final bool isQiyasMode;
  final String title;
  final Widget? besideAppBarWidget;
  final bool scrum;
  final List<String>? titles;
  final List<Function()>? functions;

  @override
  State<PageScreenTopLevel> createState() => _PageScreenTopLevelState();
}

class _PageScreenTopLevelState extends State<PageScreenTopLevel> {
  @override
  Widget build(BuildContext context) {
    bool orientation =
        MediaQuery.of(context).orientation == Orientation.portrait;
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        resizeToAvoidBottomInset: true,
        body: SafeArea(
            child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
                child: Padding(
              padding: EdgeInsets.only(
                  top: orientation ? 15 : 30,
                  left: orientation ? 15 : 30,
                  right: orientation ? 15 : 30),
              child: widget.hasScroll
                  ? SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              children: [
                                widget.besideAppBarWidget ??
                                    const SizedBox.shrink(),
                                SingleChildScrollView(
                                  scrollDirection: Axis.horizontal,
                                  child: titleRow(
                                      scrum: widget.scrum,
                                      functions: widget.functions,
                                      titles: widget.titles,
                                      isQiyasMode: widget.isQiyasMode,
                                      context,
                                      orientation,
                                      widget.title, () {
                                    Navigator.pop(context);
                                  }, hasArrow: widget.hasBackArrow),
                                ),
                                widget.isQiyasMode
                                    ? const SizedBox(
                                        width: 800,
                                      )
                                    : const SizedBox.shrink()
                              ],
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.only(top: 0.015.h),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: widget.children,
                            ),
                          ),
                        ],
                      ),
                    )
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Flexible(
                          fit: FlexFit.loose,
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Row(
                              children: [
                                titleRow(
                                    scrum: widget.scrum,
                                    functions: widget.functions,
                                    titles: widget.titles,
                                    context,
                                    orientation,
                                    widget.title, () {
                                  Navigator.pop(context);
                                }, hasArrow: widget.hasBackArrow),
                                widget.besideAppBarWidget ??
                                    const SizedBox.shrink()
                              ],
                            ),
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.only(top: 0.015.h),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: widget.children,
                          ),
                        ),
                      ],
                    ),
            ))
          ],
        )),
      ),
    );
  }
}

/// Module: core/custom
///
///*************************** FILE INFO ****************************///
/// File Name: preview_all_custom_page_builders.dart
/// Description: UI builder methods of `_PreviewAllCustomPageState` — split out of `preview.dart`.
/// Author: Amr Mesbah
/// Created at: 11/10/2026

part of '../preview.dart';

// Split from preview.dart to keep every file under 700 lines.

extension _PreviewAllCustomPageStateBuilders on _PreviewAllCustomPageState {
  Widget _buildView(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
            widget.keepOrRemove ? 'Keep or remove' : 'Custom Widgets Preview'),
        backgroundColor: AppColors.card,
        foregroundColor: AppColors.text,
        elevation: 0,
      ),
      body: ListView(
        padding: EdgeInsets.all(16.sp),
        children: widget.keepOrRemove
            ? _keepOrRemoveSections(context)
            : [
                Padding(
                  padding: EdgeInsets.only(bottom: 16.h),
                  child: customButton(
                    title: '🗑 Keep or remove — unused & duplicates',
                    function: () => Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) =>
                            const PreviewAllCustomPage(keepOrRemove: true),
                      ),
                    ),
                  ),
                ),
                ..._inputAndDialogSections(context),
                ..._cardAndChartSections(),
                ..._helperAndMiscSections(context),
              ],
      ),
    );
  }
}

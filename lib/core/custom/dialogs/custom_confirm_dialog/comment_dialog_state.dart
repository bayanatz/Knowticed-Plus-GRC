/// Module: core/custom
///
///*************************** FILE INFO ****************************///
/// File Name: comment_dialog_state.dart
/// Description: State and UI of the `_CommentDialog` widget — split out of `11-custom_confirm_dialog.dart`.
/// Author: Amr Mesbah
/// Created at: 11/10/2026

part of '../custom_confirm_dialog.dart';

// Split from 11-custom_confirm_dialog.dart to keep every file under 700 lines.

class _CommentDialogState extends State<_CommentDialog> {
  final TextEditingController _controller = TextEditingController();
  bool _submitted = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleSubmit() {
    setState(() => _submitted = true);
    if (_controller.text.trim().isEmpty) return;
    Navigator.of(context).pop();
    widget.onSubmit?.call(_controller.text.trim());
  }

  @override
  Widget build(BuildContext context) {
    return _DialogShell(
      width: 539.w,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header row ──
          Row(
            children: [
              _TitleIcon(assetPath: widget.titleIconAsset),
              SizedBox(width: 8.w),
              Expanded(
                child: Text(
                  widget.title,
                  style: StyleText.fontSize14Weight600.copyWith(
                    color: AppColors.text,
                  ),
                ),
              ),
              // GestureDetector(
              //   onTap: () => Navigator.of(context).pop(),
              //   child: Icon(Icons.close, size: 18.r, color: AppColors.text),
              // ),
            ],
          ),
          SizedBox(height: 16.h),

          // ── Text field ──
          CustomTextField(
            label: widget.fieldLabel,
            hint: widget.hint,
            controller: _controller,
            maxLines: 5,
            // Default field fill (page colour) so the box shows on the
            // card-coloured dialog — it was card on card, invisible.
            maxLength: widget.maxLength,
            required: _submitted,
            textDirection: widget.textDirection,
            onChanged: (_) => setState(() {}),
          ),

          SizedBox(height: 16.h),

          // ── Discard (left) · Submit (right), same size — X-73 ──
          Row(
            // Yellow always on the RIGHT edge, Discard / Cancel on the LEFT
            // (X-73, final 15 Oct) — in Arabic too, so the row is not mirrored.
            textDirection: TextDirection.ltr,
            children: [
              _secondaryBtn(
                label: widget.discardLabel,
                haptic: HapticController.high, // Cancel is always HIGH
                onTap: () {
                  Navigator.of(context).pop();
                  widget.onDiscard?.call();
                },
                width: 120.w,
              ),
              const Spacer(),
              _primaryBtn(
                label: widget.submitLabel,
                haptic: HapticController.medium, // submit
                onTap: _handleSubmit,
                width: 120.w,
              ),
            ],
          ),
          SizedBox(height: 4.h),
        ],
      ),
    );
  }
}

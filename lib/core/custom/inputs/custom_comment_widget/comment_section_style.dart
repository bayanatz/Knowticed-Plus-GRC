/// Module: core/custom
///
///*************************** FILE INFO ****************************///
/// File Name: comment_section_style.dart
/// Description: `CommentSectionStyle` — split out of `36-custom_comment_widget.dart`.
/// Author: Amr Mesbah
/// Created at: 11/10/2026

part of '../custom_comment_widget.dart';

// Split from 36-custom_comment_widget.dart to keep every file under 700 lines.

/// Styling class for customization
class CommentSectionStyle {
  final BoxDecoration containerDecoration;
  final EdgeInsets containerPadding;
  final BoxDecoration commentItemDecoration;
  final TextStyle userNameStyle;
  final TextStyle dateStyle;
  final TextStyle commentTextStyle;
  final TextStyle hintStyle;
  final TextStyle emptyStateStyle;
  final TextStyle expandButtonStyle;
  final Color avatarColor;
  final TextStyle avatarTextStyle;
  final Color inputFillColor;
  final InputBorder inputBorder;
  final InputBorder inputFocusedBorder;
  final BoxDecoration sendButtonDecoration;
  final Color sendIconColor;
  final Color attachIconColor;
  final BoxDecoration fileChipDecoration;
  final Color fileIconColor;
  final TextStyle fileNameStyle;

  CommentSectionStyle({
    BoxDecoration? containerDecoration,
    EdgeInsets? containerPadding,
    BoxDecoration? commentItemDecoration,
    TextStyle? userNameStyle,
    TextStyle? dateStyle,
    TextStyle? commentTextStyle,
    TextStyle? hintStyle,
    TextStyle? emptyStateStyle,
    TextStyle? expandButtonStyle,
    Color? avatarColor,
    TextStyle? avatarTextStyle,
    Color? inputFillColor,
    InputBorder? inputBorder,
    InputBorder? inputFocusedBorder,
    BoxDecoration? sendButtonDecoration,
    Color? sendIconColor,
    Color? attachIconColor,
    BoxDecoration? fileChipDecoration,
    Color? fileIconColor,
    TextStyle? fileNameStyle,
  })  : containerDecoration = containerDecoration ??
            BoxDecoration(
              color: AppColors.card,
              borderRadius: BorderRadius.circular(8),
            ),
        containerPadding = containerPadding ?? EdgeInsets.all(15),
        commentItemDecoration = commentItemDecoration ?? BoxDecoration(),
        userNameStyle = userNameStyle ??
            StyleText.fontSize14Weight700.copyWith(color: AppColors.text),
        dateStyle = dateStyle ??
            StyleText.fontSize11Weight400.copyWith(
              color: AppColors.secondaryText,
            ),
        commentTextStyle = commentTextStyle ??
            StyleText.fontSize13Weight400.copyWith(color: AppColors.text),
        hintStyle = hintStyle ??
            StyleText.fontSize12Weight400.copyWith(
              color: AppColors.secondaryText,
            ),
        emptyStateStyle = emptyStateStyle ??
            StyleText.fontSize14Weight400.copyWith(
              color: AppColors.secondaryText,
            ),
        expandButtonStyle = expandButtonStyle ??
            StyleText.fontSize12Weight400.copyWith(
              color: AppColors.primary,
              decoration: TextDecoration.underline,
            ),
        avatarColor = avatarColor ?? AppColors.blue,
        avatarTextStyle = avatarTextStyle ??
            StyleText.fontSize14Weight700.copyWith(color: AppColors.white),
        inputFillColor = inputFillColor ?? AppColors.card,
        inputBorder = inputBorder ??
            OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: AppColors.card),
            ),
        inputFocusedBorder = inputFocusedBorder ??
            OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: AppColors.primary, width: 1.5),
            ),
        sendButtonDecoration = sendButtonDecoration ??
            BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(8),
            ),
        sendIconColor = sendIconColor ?? AppColors.white,
        attachIconColor = attachIconColor ?? AppColors.secondaryText,
        // Item 177 (21/10/2026, Moataz: "why is it blue"): the attachment
        // card is the same soft bubble as a text comment — blue is for links
        // only.
        fileChipDecoration = fileChipDecoration ??
            BoxDecoration(
              color: AppColors.background,
              // The same 8 as the text bubble beside it (CardStyles.radius).
              borderRadius: BorderRadius.circular(8),
            ),
        fileIconColor = fileIconColor ?? AppColors.secondaryPrimary,
        fileNameStyle = fileNameStyle ??
            StyleText.fontSize12Weight500.copyWith(color: AppColors.text);
}

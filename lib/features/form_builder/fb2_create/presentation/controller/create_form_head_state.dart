/// Module: form_builder_module/f2_create
///
///*************************** FILE INFO ****************************///
/// File Name: create_form_head_state.dart
/// Description: `CreateFormHeadState` and its states: the header of the
///              form being created or edited, as plain values (the text
///              controllers live in the widgets).
/// Author: Amr Mesbah
/// Created at: 06/10/2026
/// Updated: 19/10/2026 - Plain values instead of TextEditingControllers.
library;

import 'package:equatable/equatable.dart';

abstract class CreateFormHeadState extends Equatable {
  @override
  List<Object?> get props => [];
}

class CreateFormHeadInitial extends CreateFormHeadState {}

class CreateFormHeadLoading extends CreateFormHeadState {}

/// The header of the form being created or edited.
class CreateFormHeadLoaded extends CreateFormHeadState {
  final String title;
  final String description;
  final String arTitle;
  final String arDescription;
  final String horizontalPadding;
  final String verticalPadding;
  final String watermarkOpacity;
  final String watermarkSize;

  final String? cover;
  final String? watermark;
  final String? accessManagement;
  final String? orientation;

  /// Bumped when the cubit replaces the texts itself (open a form, "Fill
  /// demo data"), so the text fields copy the new values in. Typing does
  /// not bump it.
  final int fieldsVersion;

  CreateFormHeadLoaded({
    this.title = '',
    this.description = '',
    this.arTitle = '',
    this.arDescription = '',
    this.horizontalPadding = '',
    this.verticalPadding = '',
    this.watermarkOpacity = '',
    this.watermarkSize = '',
    this.cover,
    this.watermark,
    this.accessManagement,
    this.orientation,
    this.fieldsVersion = 0,
  });

  /// Method Name: [copyWith]
  ///
  /// Purpose: a copy with the given values changed.
  ///
  /// Parameters:
  /// - [title]: the new value (null keeps the current one).
  /// - [description]: the new value (null keeps the current one).
  /// - [arTitle]: the new value (null keeps the current one).
  /// - [arDescription]: the new value (null keeps the current one).
  /// - [horizontalPadding]: the new value (null keeps the current one).
  /// - [verticalPadding]: the new value (null keeps the current one).
  /// - [watermarkOpacity]: the new value (null keeps the current one).
  /// - [watermarkSize]: the new value (null keeps the current one).
  /// - [cover]: the new value (null keeps the current one).
  /// - [watermark]: the new value (null keeps the current one).
  /// - [accessManagement]: the new value (null keeps the current one).
  /// - [orientation]: the new value (null keeps the current one).
  /// - [clearCover]: true sets the value to null.
  /// - [clearWatermark]: true sets the value to null.
  ///
  /// Returns: the copy.
  CreateFormHeadLoaded copyWith({
    String? title,
    String? description,
    String? arTitle,
    String? arDescription,
    String? horizontalPadding,
    String? verticalPadding,
    String? watermarkOpacity,
    String? watermarkSize,
    String? cover,
    String? watermark,
    String? accessManagement,
    String? orientation,
    bool clearCover = false,
    bool clearWatermark = false,
  }) {
    return CreateFormHeadLoaded(
      title: title ?? this.title,
      description: description ?? this.description,
      arTitle: arTitle ?? this.arTitle,
      arDescription: arDescription ?? this.arDescription,
      horizontalPadding: horizontalPadding ?? this.horizontalPadding,
      verticalPadding: verticalPadding ?? this.verticalPadding,
      watermarkOpacity: watermarkOpacity ?? this.watermarkOpacity,
      watermarkSize: watermarkSize ?? this.watermarkSize,
      cover: clearCover ? null : (cover ?? this.cover),
      watermark: clearWatermark ? null : (watermark ?? this.watermark),
      accessManagement: accessManagement ?? this.accessManagement,
      orientation: orientation ?? this.orientation,
      fieldsVersion: fieldsVersion,
    );
  }

  /// A copy whose texts must be copied into the text fields.
  CreateFormHeadLoaded copyWithFieldsVersion(int version) =>
      CreateFormHeadLoaded(
        title: title,
        description: description,
        arTitle: arTitle,
        arDescription: arDescription,
        horizontalPadding: horizontalPadding,
        verticalPadding: verticalPadding,
        watermarkOpacity: watermarkOpacity,
        watermarkSize: watermarkSize,
        cover: cover,
        watermark: watermark,
        accessManagement: accessManagement,
        orientation: orientation,
        fieldsVersion: version,
      );

  @override
  List<Object?> get props => [
    title,
    description,
    arTitle,
    arDescription,
    horizontalPadding,
    verticalPadding,
    watermarkOpacity,
    watermarkSize,
    cover,
    watermark,
    accessManagement,
    orientation,
    fieldsVersion,
  ];
}

class CreateFormHeadError extends CreateFormHeadState {
  final String message;

  CreateFormHeadError(this.message);

  @override
  List<Object?> get props => [message];
}

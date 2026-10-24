/// Module: form_builder_module/f6_result
///
///*************************** FILE INFO ****************************///
/// File Name: upload_media_state.dart
/// Description: `UploadMediaState` state, `UploadMediaInitial` state, `UploadMediaLoaded` state.
/// Author: Amr Mesbah
/// Created at: 06/10/2026
library;

import 'package:equatable/equatable.dart';
import 'package:knowticed_plus/features/form_builder/fb1_home/domain/entities/form_entity.dart';
import 'package:knowticed_plus/features/form_builder/fb5_result/domain/entities/user_grid_item.dart';

/// Base state of UploadMediaCubit.
abstract class UploadMediaState extends Equatable {
  @override
  List<Object?> get props => [];
}

/// Before UploadMediaCubit.initialize.
class UploadMediaInitial extends UploadMediaState {}

/// The Uploaded Documents page with its people and filters.
class UploadMediaLoaded extends UploadMediaState {
  final FormEntity? formEntity;
  final List<UserGridItem> userGridItems;
  final List<UserGridItem> filteredUserGridItems;
  final List<String> mediaType;

  /// The picked department's ID; null means all departments (FB-RESULT-04).
  final String? departmentType;

  /// One of [ResultConstants.employeeFilter].
  final String employeeType;

  /// The text typed in the search box.
  final String searchQuery;
  final bool isHasMedia;

  /// Bumped when a person's selection changed in place, so the page rebuilds.
  final int revision;

  UploadMediaLoaded({
    this.formEntity,
    required this.userGridItems,
    required this.filteredUserGridItems,
    required this.mediaType,
    this.departmentType,
    required this.employeeType,
    this.searchQuery = '',
    required this.isHasMedia,
    this.revision = 0,
  });

  /// Method Name: [copyWith]
  ///
  /// Purpose: a copy with the given fields changed.
  ///
  /// Returns: the new object.
  UploadMediaLoaded copyWith({
    FormEntity? formEntity,
    List<UserGridItem>? userGridItems,
    List<UserGridItem>? filteredUserGridItems,
    List<String>? mediaType,
    String? departmentType,
    bool clearDepartmentType = false,
    String? employeeType,
    bool? isHasMedia,
    String? searchQuery,
    int? revision,
  }) {
    return UploadMediaLoaded(
      formEntity: formEntity ?? this.formEntity,
      userGridItems: userGridItems ?? this.userGridItems,
      filteredUserGridItems:
          filteredUserGridItems ?? this.filteredUserGridItems,
      mediaType: mediaType ?? this.mediaType,
      departmentType:
          clearDepartmentType ? null : (departmentType ?? this.departmentType),
      employeeType: employeeType ?? this.employeeType,
      searchQuery: searchQuery ?? this.searchQuery,
      isHasMedia: isHasMedia ?? this.isHasMedia,
      revision: revision ?? this.revision,
    );
  }

  @override
  List<Object?> get props => [
        formEntity,
        userGridItems,
        filteredUserGridItems,
        mediaType,
        departmentType,
        employeeType,
        isHasMedia,
        searchQuery,
        revision,
      ];
}

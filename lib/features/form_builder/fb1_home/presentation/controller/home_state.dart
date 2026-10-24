/// Module: form_builder_module/f1_home
///
///*************************** FILE INFO ****************************///
/// File Name: home_state.dart
/// Description: `HomeState` state, `HomeInitial` state, `HomeLoading` state and 2 more.
/// Author: Amr Mesbah
/// Created at: 06/10/2026
library;

import 'package:equatable/equatable.dart';
import 'package:knowticed_plus/features/form_builder/fb1_home/domain/entities/form_entity.dart';
import 'package:knowticed_plus/features/form_builder/fb1_home/domain/enums/form_state.dart';

abstract class HomeState extends Equatable {
  @override
  List<Object?> get props => [];
}

class HomeInitial extends HomeState {}

class HomeLoading extends HomeState {}

class HomeLoaded extends HomeState {
  final List<FormEntity> publishForms;
  final List<FormEntity> draftForms;
  final List<FormEntity> deletedForms;
  final List<FormEntity> requestedForms;
  final List<FormEntity> submissionForms;
  final List<FormEntity> shownForms;
  final FormStatus selectedTab;
  final String? currentDropDownValue;
  final String? currentDateValue;

  /// Bumped by every emit from HomeCubit._emitLoadedState (bug p.7, Sort did
  /// nothing). sortForms() reorders the SAME list instances this state holds,
  /// so the previous state already "contained" the new order and Equatable
  /// judged the two states equal — the emit was dropped and neither the list
  /// nor the Sort button's active colour rebuilt. The counter makes each
  /// sort/filter pass a distinct state.
  final int revision;

  HomeLoaded({
    required this.publishForms,
    required this.draftForms,
    required this.deletedForms,
    required this.requestedForms,
    required this.submissionForms,
    required this.shownForms,
    required this.selectedTab,
    this.currentDropDownValue,
    this.currentDateValue,
    this.revision = 0,
  });

  @override
  List<Object?> get props => [
        publishForms,
        draftForms,
        deletedForms,
        requestedForms,
        submissionForms,
        shownForms,
        selectedTab,
        currentDropDownValue,
        currentDateValue,
        revision,
      ];
}

class HomeError extends HomeState {
  final String message;

  HomeError(this.message);

  @override
  List<Object?> get props => [message];
}

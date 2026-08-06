///*************************** FILE INFO ****************************///
/// File Name: home_state.dart
/// Purpose: State management for home screen
/// Author: Amr Mesbah
/// Created at: 20/9/2025

import 'package:grc_module/features/home/h1_home_page/presentation/ui/widgets/icon_selector_dialog_widget.dart';
import 'package:grc_module/features/home/h1_home_page/presentation/controller/home_cubit.dart';

abstract class HomeState {}

class HomeInitial extends HomeState {}

class HomeLoading extends HomeState {}

class HomeLoaded extends HomeState {}

class HomeEditingComponent extends HomeState {}

class HomeIconsUpdated extends HomeState {
  final List<HeaderIconItem> icons;
  HomeIconsUpdated(this.icons);
}

class HomeError extends HomeState {
  final String message;
  HomeError(this.message);
}
class HomePreviewModeChanged extends HomeState {
  final PreviewMode mode;
  HomePreviewModeChanged(this.mode);
}
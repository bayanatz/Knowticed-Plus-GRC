part of './app_drawer_cubit.dart';

sealed class AppDrawerState {
  const AppDrawerState();
}

final class AppDrawerInitial extends AppDrawerState {
  const AppDrawerInitial();
}

final class AppDrawerLoaded extends AppDrawerState {
  final List<Modules> allowedDrawerModules;
  final int selectedIndex;
  final bool isLoadingModules;

  const AppDrawerLoaded({
    required this.allowedDrawerModules,
    required this.selectedIndex,
    required this.isLoadingModules,
  });
}

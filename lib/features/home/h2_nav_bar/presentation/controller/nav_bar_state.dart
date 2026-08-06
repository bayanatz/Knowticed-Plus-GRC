part of './nav_bar_cubit.dart';

sealed class NavBarState {
  const NavBarState();
}

final class NavBarInitial extends NavBarState {
  const NavBarInitial();
}

final class NavBarLoaded extends NavBarState {
  final List<Modules> navBarModules;
  final List<Modules> moreListModules;
  final bool isLoadingModules;

  const NavBarLoaded({
    required this.navBarModules,
    required this.moreListModules,
    required this.isLoadingModules,
  });
}

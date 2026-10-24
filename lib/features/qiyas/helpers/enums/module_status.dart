enum ModuleStatus {
  all,
  active,
  inactive,
  removed;

  String get displayName {
    switch (this) {
      case all:
        return 'All';
      case active:
        return 'Active';
      case inactive:
        return 'Inactive';
      case removed:
        return 'Removed';
    }
  }
}

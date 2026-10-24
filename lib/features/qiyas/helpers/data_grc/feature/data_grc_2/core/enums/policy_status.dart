enum PolicyStatus {
  active,
  deactivated,
  expired,
  draft;

  String get displayName {
    switch (this) {
      case active:
        return 'Active';
      case deactivated:
        return 'Inactive';
      case expired:
        return 'Expired';
      case draft:
        return 'Draft';
    }
  }
}

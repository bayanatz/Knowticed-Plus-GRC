enum NewControlStatus {
  active,
  inactive,
  expired,
  draft;

  String get displayName {
    switch (this) {
      case active:
        return 'Active';
      case inactive:
        return 'Inactive';
      case expired:
        return 'Expired';
      case draft:
        return 'Draft';
    }
  }
}

enum SortingMethods {
  ascending,
  descending,
  creationDate,
  lastUpdate;

  String get displayName {
    switch (this) {
      case ascending:
        return 'ASC';
      case descending:
        return 'DES';
      case creationDate:
        return 'Creation Date';
      case lastUpdate:
        return 'Last Update';
    }
  }
}

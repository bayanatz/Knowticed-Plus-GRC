/// Chart Orientation Enum
/// Used to determine if a chart should be displayed as horizontal or vertical
enum ChartOrientation {
  horizontal,
  vertical;

  /// Convert enum to string for Firestore storage
  String toFirestore() {
    return name; // Returns 'horizontal' or 'vertical'
  }

  /// Create enum from Firestore string
  static ChartOrientation fromFirestore(String value) {
    switch (value.toLowerCase()) {
      case 'horizontal':
        return ChartOrientation.horizontal;
      case 'vertical':
        return ChartOrientation.vertical;
      default:
        return ChartOrientation.vertical; // Default fallback
    }
  }
}
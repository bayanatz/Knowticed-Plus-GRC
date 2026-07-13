import 'package:demo_app/features/home/home_page/presentation/ui/pages/dashboard_view_data/chart_orientation_enum.dart';

/// Model representing a chart configuration
class ChartConfig {
  final String id;
  final String nameEnglish;
  final String nameArabic;
  final ChartOrientation defaultOrientation;

  const ChartConfig({
    required this.id,
    required this.nameEnglish,
    required this.nameArabic,
    required this.defaultOrientation,
  });

  /// Convert to map for Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'id': id,
      'nameEnglish': nameEnglish,
      'nameArabic': nameArabic,
      'orientation': defaultOrientation.toFirestore(),
      'updatedAt': DateTime.now().millisecondsSinceEpoch,
    };
  }

  /// Create from Firestore document
  factory ChartConfig.fromFirestore(Map<String, dynamic> data) {
    return ChartConfig(
      id: data['id'] ?? '',
      nameEnglish: data['nameEnglish'] ?? '',
      nameArabic: data['nameArabic'] ?? '',
      defaultOrientation: ChartOrientation.fromFirestore(
        data['orientation'] ?? 'vertical',
      ),
    );
  }

  ChartConfig copyWith({
    String? id,
    String? nameEnglish,
    String? nameArabic,
    ChartOrientation? defaultOrientation,
  }) {
    return ChartConfig(
      id: id ?? this.id,
      nameEnglish: nameEnglish ?? this.nameEnglish,
      nameArabic: nameArabic ?? this.nameArabic,
      defaultOrientation: defaultOrientation ?? this.defaultOrientation,
    );
  }
}
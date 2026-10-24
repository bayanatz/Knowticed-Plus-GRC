/// Module: notification
///
///*************************** FILE INFO ****************************///
/// File Name: notification_model.dart
/// Purpose: A notification as rendered in the inbox.
/// Author: Knowticed Plus team
/// Created at: 2026
/// Updated: 12/8/2026 - Added the standard header (Docs).
library;

import 'package:cloud_firestore/cloud_firestore.dart';

class NotificationTemplateModel {
  final String id;
  final String module; // 'services', 'qiyas', 'inventory', etc.
  final String eventType; // 'request_submitted', 'request_approved', etc.
  final bool isEnabled;
  final List<String>
      selectedNotificationTypes; // ["email", "push"] - stores which types are selected
  final String subjectEnglish;
  final String subjectArabic;
  final String bodyEnglish;
  final String bodyArabic;

  /// Owner 22/10/2026 (Notification Control): Push keeps its OWN text —
  /// Title + Description (150) — next to the Email Subject + Body (500).
  /// Empty means "not edited yet": the push falls back to the email text,
  /// so every template saved before this keeps sending exactly what it did.
  /// Read them through [pushTitleEn] / [pushTitleAr] / [pushBodyEn] /
  /// [pushBodyAr], which apply that fallback.
  final String pushTitleEnglish;
  final String pushTitleArabic;
  final String pushBodyEnglish;
  final String pushBodyArabic;
  final DateTime createdAt;
  final DateTime updatedAt;

  NotificationTemplateModel({
    required this.id,
    required this.module,
    required this.eventType,
    required this.isEnabled,
    required this.selectedNotificationTypes,
    required this.subjectEnglish,
    required this.subjectArabic,
    required this.bodyEnglish,
    required this.bodyArabic,
    this.pushTitleEnglish = '',
    this.pushTitleArabic = '',
    this.pushBodyEnglish = '',
    this.pushBodyArabic = '',
    required this.createdAt,
    required this.updatedAt,
  });

  // Helper methods to check notification types
  bool get hasEmail => selectedNotificationTypes.contains('email');
  bool get hasPush => selectedNotificationTypes.contains('push');

  // Push text with the fallback to the email text (see [pushTitleEnglish]).
  String get pushTitleEn =>
      pushTitleEnglish.trim().isEmpty ? subjectEnglish : pushTitleEnglish;
  String get pushTitleAr =>
      pushTitleArabic.trim().isEmpty ? subjectArabic : pushTitleArabic;
  String get pushBodyEn => pushBodyEnglish.trim().isEmpty
      ? shortPushText(bodyEnglish)
      : pushBodyEnglish;
  String get pushBodyAr => pushBodyArabic.trim().isEmpty
      ? shortPushText(bodyArabic)
      : pushBodyArabic;

  /// Push Description limit (Figma 0/150).
  static const int pushBodyMaxLength = 150;

  /// Owner 22/10/2026 ("make the limitation okay"): the default push text is
  /// the message's first sentence. If that is over 150, it is cut at
  /// the last whole word (never inside a `{{variable}}`) and ends with "…".
  static String shortPushText(String body) {
    // Always the first sentence — in BOTH languages, even when the whole
    // message would fit — so the English and Arabic push say the same thing.
    final String text = body.trim();
    final Match? first = RegExp(r'^(.+?[.!?؟])(\s|$)').firstMatch(text);
    final String sentence = first?.group(1) ?? text;
    if (sentence.length <= pushBodyMaxLength) return sentence;
    String cut = sentence.substring(0, pushBodyMaxLength - 1);
    final int open = cut.lastIndexOf('{{');
    if (open > cut.lastIndexOf('}}')) cut = cut.substring(0, open);
    final int space = cut.lastIndexOf(' ');
    if (space > 0) cut = cut.substring(0, space);
    return '${cut.trimRight()}…';
  }

  // Convert to Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'id': id,
      'module': module,
      'eventType': eventType,
      'isEnabled': isEnabled,
      'selectedNotificationTypes': selectedNotificationTypes,
      'subjectEnglish': subjectEnglish,
      'subjectArabic': subjectArabic,
      'bodyEnglish': bodyEnglish,
      'bodyArabic': bodyArabic,
      'pushTitleEnglish': pushTitleEnglish,
      'pushTitleArabic': pushTitleArabic,
      'pushBodyEnglish': pushBodyEnglish,
      'pushBodyArabic': pushBodyArabic,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  // Create from Firestore
  factory NotificationTemplateModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return NotificationTemplateModel(
      id: data['id'] ?? doc.id,
      module: data['module'] ?? '',
      eventType: data['eventType'] ?? '',
      isEnabled: data['isEnabled'] ?? true,
      selectedNotificationTypes:
          List<String>.from(data['selectedNotificationTypes'] ?? []),
      subjectEnglish: data['subjectEnglish'] ?? '',
      subjectArabic: data['subjectArabic'] ?? '',
      bodyEnglish: data['bodyEnglish'] ?? '',
      bodyArabic: data['bodyArabic'] ?? '',
      pushTitleEnglish: data['pushTitleEnglish'] ?? '',
      pushTitleArabic: data['pushTitleArabic'] ?? '',
      pushBodyEnglish: data['pushBodyEnglish'] ?? '',
      pushBodyArabic: data['pushBodyArabic'] ?? '',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  // Create default template
  factory NotificationTemplateModel.createDefault({
    required String module,
    required String eventType,
    List<String>? selectedNotificationTypes,
  }) {
    return NotificationTemplateModel(
      id: '${module}_$eventType',
      module: module,
      eventType: eventType,
      isEnabled: true,
      selectedNotificationTypes: selectedNotificationTypes ?? [],
      subjectEnglish: '',
      subjectArabic: '',
      bodyEnglish: '',
      bodyArabic: '',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }

  NotificationTemplateModel copyWith({
    String? id,
    String? module,
    String? eventType,
    bool? isEnabled,
    List<String>? selectedNotificationTypes,
    String? subjectEnglish,
    String? subjectArabic,
    String? bodyEnglish,
    String? bodyArabic,
    String? pushTitleEnglish,
    String? pushTitleArabic,
    String? pushBodyEnglish,
    String? pushBodyArabic,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return NotificationTemplateModel(
      id: id ?? this.id,
      module: module ?? this.module,
      eventType: eventType ?? this.eventType,
      isEnabled: isEnabled ?? this.isEnabled,
      selectedNotificationTypes:
          selectedNotificationTypes ?? this.selectedNotificationTypes,
      subjectEnglish: subjectEnglish ?? this.subjectEnglish,
      subjectArabic: subjectArabic ?? this.subjectArabic,
      bodyEnglish: bodyEnglish ?? this.bodyEnglish,
      bodyArabic: bodyArabic ?? this.bodyArabic,
      pushTitleEnglish: pushTitleEnglish ?? this.pushTitleEnglish,
      pushTitleArabic: pushTitleArabic ?? this.pushTitleArabic,
      pushBodyEnglish: pushBodyEnglish ?? this.pushBodyEnglish,
      pushBodyArabic: pushBodyArabic ?? this.pushBodyArabic,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

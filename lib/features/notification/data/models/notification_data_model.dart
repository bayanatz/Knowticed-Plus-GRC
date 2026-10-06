/// Module: notification
///
///*************************** FILE INFO ****************************///
/// File Name: notification_data_model.dart
/// Purpose: A stored notification.
/// Author: Knowticed Plus team
/// Created at: 2026
/// Updated: 12/8/2026 - Added the standard header (Docs).

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:grc_module/core/enums/app_module.dart';
import 'package:grc_module/features/notification/domain/enums/settings_module/settings_events.dart';

class NotificationModelSystem {
  final String? id; // Document ID in Firestore
  /// ⚠️ ALWAYS ENGLISH. See the language note above [titleFor].
  final String title;

  /// ⚠️ ALWAYS ENGLISH. See the language note above [titleFor].
  final String body;

  /// The Arabic rendering of [title]. Empty for a document written before
  /// 30/8/2026, or when no Arabic template text exists.
  final String titleAr;

  /// The Arabic rendering of [body]. Empty for a document written before
  /// 30/8/2026, or when no Arabic template text exists.
  final String bodyAr;
  final String nameOfModule; // e.g., 'services', 'inventory', etc.
  final String senderEmail;
  final String receiverEmail;
  final String nameOfPage; // Widget name or page identifier
  final bool isPinned;
  final int timestamp; // Timestamp in milliseconds
  final bool isRead; // Track if notification has been read
  final bool isClean; // Track if notification has been read

  NotificationModelSystem({
    this.id,
    required this.title,
    required this.body,
    this.titleAr = '',
    this.bodyAr = '',
    required this.nameOfModule,
    required this.senderEmail,
    required this.receiverEmail,
    required this.nameOfPage,
    this.isPinned = false,
    int? timestamp,
    this.isRead = false,
    this.isClean = false,
  }) : timestamp = timestamp ?? DateTime.now().millisecondsSinceEpoch;

  /// ══════════════════════════════════════════════════════════════════
  ///  READER'S LANGUAGE, NOT THE SENDER'S           ADDED 30/8/2026
  ///
  ///  A notification used to be stored in ONE language, chosen by the person
  ///  who triggered it: every send path passes `isArabic` down from the
  ///  acting user's app, and `AppNotificationSender.sendFromTemplate` used it
  ///  to pick which half of the bilingual template to bake into [title] and
  ///  [body]. So an approver working in Arabic sent Arabic text to an English
  ///  reader, permanently — the stored document had no other language in it to
  ///  fall back to.
  ///
  ///  Both renderings are now stored: [title] / [body] are ALWAYS English,
  ///  [titleAr] / [bodyAr] carry the Arabic, and the language is chosen when
  ///  the card is BUILT, from the viewer's own locale. Switching the app to
  ///  Arabic re-renders the whole inbox in Arabic, including notifications
  ///  that were already sitting in it.
  ///
  ///  Documents written before this date have empty [titleAr] / [bodyAr] and
  ///  fall back to [title] / [body] — which for those rows is whatever
  ///  language the sender happened to be using. That is the old behaviour,
  ///  preserved rather than blanked; it corrects itself as new notifications
  ///  arrive.
  /// ══════════════════════════════════════════════════════════════════

  /// The title as the VIEWER should see it.
  ///
  /// [isArabic] is the reader's locale, not the sender's. Falls back to the
  /// English text whenever the Arabic rendering is absent.
  String titleFor(bool isArabic) =>
      isArabic && titleAr.trim().isNotEmpty ? titleAr : title;

  /// The body as the VIEWER should see it, with the reason clause stripped —
  /// the language-aware counterpart of [displayBody].
  String displayBodyFor(bool isArabic) => stripReason(
        isArabic && bodyAr.trim().isNotEmpty ? bodyAr : body,
      );

  /// Everything a search box should match against: both languages, so typing
  /// an Arabic word finds a notification whose card is currently rendered in
  /// English and the other way round.
  String get searchText =>
      '$title $body $titleAr $bodyAr'.toLowerCase();

  /// The body as a CARD should show it. ADDED 26/8/2026.
  ///
  /// Notifications are written with a trailing or inline "Reason: …" clause —
  /// "…has been cancelled.\nReason: r", "…has been rejected. Reason: rejected.
  /// Please review…". The reason is whatever free text the approver typed, it
  /// is frequently a single throwaway character, and it is not wanted on the
  /// cards in any module.
  ///
  /// Stripped on READ, not on write: every stored notification already carries
  /// the clause, so filtering at the point of display fixes the existing inbox
  /// as well as new arrivals, and [body] stays intact for anything that needs
  /// the raw text.
  ///
  /// Kept for callers that genuinely want the English text. Cards use
  /// [displayBodyFor] instead, so the reader's locale decides.
  String get displayBody => stripReason(body);

  /// English and Arabic labels a reason clause can start with. Matched
  /// case-insensitively; the colon is required, so ordinary prose ("for that
  /// reason we…") is left alone.
  static const List<String> _reasonLabels = ['reason:', 'السبب:'];

  /// [source] with any reason clause removed.
  ///
  /// A clause ends at whichever comes first: the end of its sentence (a full
  /// stop followed by a space, a newline or the end of the text), the end of
  /// its line, or the end of the text. That is what keeps the mid-sentence
  /// case — "rejected. Reason: rejected. Please review…" — from eating the
  /// rest of the message along with the clause.
  ///
  /// Deliberately a plain scan rather than a regex: the two forms differ in
  /// where they terminate, and the pattern that covers both is far harder to
  /// read than this loop.
  static String stripReason(String source) {
    String result = source;

    for (final String label in _reasonLabels) {
      while (true) {
        final int start = result.toLowerCase().indexOf(label);
        if (start < 0) break;

        int end = result.length;
        for (int i = start + label.length; i < result.length; i++) {
          final String ch = result[i];
          if (ch == '\n' || ch == '\r') {
            end = i;
            break;
          }
          final bool endsSentence = ch == '.' &&
              (i + 1 == result.length ||
                  result[i + 1] == ' ' ||
                  result[i + 1] == '\n' ||
                  result[i + 1] == '\r');
          if (endsSentence) {
            end = i + 1;
            break;
          }
        }

        result = result.substring(0, start) + result.substring(end);
      }
    }

    // Cutting a clause out of the middle leaves a double space behind it, and
    // cutting one off the end leaves a dangling blank line.
    return result
        .replaceAll(RegExp(r'[ \t]{2,}'), ' ')
        .replaceAll(RegExp(r'[\r\n][ \t]*[\r\n]+'), '\n')
        .trim();
  }

  // Convert NotificationModel to Map for Firestore
  //
  // FIXED 25/8/2026 — `Reciver_Email` is written lower-cased.
  //
  // Every read of this collection filters on
  // `.where('Reciver_Email', isEqualTo: receiverEmail.toLowerCase())` —
  // `FirestoreNotificationService` does it in all eight of its queries,
  // including the stream the inbox is built on. This map stored the address
  // exactly as it arrived, and it arrives from the `Email` history list in
  // `Employees_Info`, which holds whatever case the record was created with.
  //
  // So a notification addressed to `Khalid.AlFarsi@…` was written under that
  // spelling while the inbox looked for `khalid.alfarsi@…`. It never matched:
  // the document existed in Firestore, the push was delivered, and the
  // notification page showed nothing — for every module, not only Settings.
  //
  // Firestore has no case-insensitive query, so the fix belongs on the write
  // side. `Sender_Email` is deliberately left alone: it is displayed, and
  // matched against the employee directory by `notification_page.dart`
  // (`isKnownEmployee`), so it must keep the spelling the directory holds.
  //
  // ⚠️ Documents written before this date keep their original spelling and
  // stay invisible to their recipient. A one-off backfill lower-casing
  // `Reciver_Email` across the collection is the only way to recover those.
  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'body': body,
      // ADDED 30/8/2026 — the Arabic half. Written alongside the English one
      // so the reader's locale, not the sender's, picks the language.
      'title_ar': titleAr,
      'body_ar': bodyAr,
      'Name_of_module': nameOfModule,
      'Sender_Email': senderEmail,
      'Reciver_Email': receiverEmail.trim().toLowerCase(),
      'name_of_page': nameOfPage,
      'Pin': isPinned,
      'timestamp': timestamp,
      'isRead': isRead,
      'isClean': isClean,
    };
  }

  /// ADDED 21/9/2026 — change-request notifications written before they
  /// moved to User Management still say `settings`; re-file them on read so
  /// the module chip, the count and the card icon all agree with new ones.
  static String _fileUnder(String storedModule, String title) {
    if (storedModule.trim().toLowerCase() == AppModule.settings.key &&
        SettingsNotificationEvent.isChangeRequestTitle(title)) {
      return AppModule.userManagement.key;
    }
    return storedModule;
  }

  // Create NotificationModel from Firestore DocumentSnapshot
  factory NotificationModelSystem.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return NotificationModelSystem(
      id: doc.id,
      title: data['title'] ?? '',
      body: data['body'] ?? '',
      titleAr: data['title_ar'] ?? '',
      bodyAr: data['body_ar'] ?? '',
      nameOfModule: _fileUnder(data['Name_of_module'] ?? '', data['title'] ?? ''),
      senderEmail: data['Sender_Email'] ?? '',
      receiverEmail: data['Reciver_Email'] ?? '',
      nameOfPage: data['name_of_page'] ?? '',
      isPinned: data['Pin'] ?? false,
      timestamp: data['timestamp'] ?? DateTime.now().millisecondsSinceEpoch,
      isRead: data['isRead'] ?? false,
      isClean: data['isClean'] ?? false,
    );
  }

  // Create NotificationModel from Map
  factory NotificationModelSystem.fromMap(Map<String, dynamic> map, {String? id}) {
    return NotificationModelSystem(
      id: id,
      title: map['title'] ?? '',
      body: map['body'] ?? '',
      titleAr: map['title_ar'] ?? '',
      bodyAr: map['body_ar'] ?? '',
      nameOfModule: _fileUnder(map['Name_of_module'] ?? '', map['title'] ?? ''),
      senderEmail: map['Sender_Email'] ?? '',
      receiverEmail: map['Reciver_Email'] ?? '',
      nameOfPage: map['name_of_page'] ?? '',
      isPinned: map['Pin'] ?? false,
      timestamp: map['timestamp'] ?? DateTime.now().millisecondsSinceEpoch,
      isRead: map['isRead'] ?? false,
      isClean: map['isClean'] ?? false,
    );
  }

  // Copy with method for updating specific fields
  NotificationModelSystem copyWith({
    String? id,
    String? title,
    String? body,
    String? titleAr,
    String? bodyAr,
    String? nameOfModule,
    String? senderEmail,
    String? receiverEmail,
    String? nameOfPage,
    bool? isPinned,
    int? timestamp,
    bool? isRead,
    bool? isClean,
  }) {
    return NotificationModelSystem(
      id: id ?? this.id,
      title: title ?? this.title,
      body: body ?? this.body,
      titleAr: titleAr ?? this.titleAr,
      bodyAr: bodyAr ?? this.bodyAr,
      nameOfModule: nameOfModule ?? this.nameOfModule,
      senderEmail: senderEmail ?? this.senderEmail,
      receiverEmail: receiverEmail ?? this.receiverEmail,
      nameOfPage: nameOfPage ?? this.nameOfPage,
      isPinned: isPinned ?? this.isPinned,
      timestamp: timestamp ?? this.timestamp,
      isRead: isRead ?? this.isRead,
      isClean: isClean ?? this.isClean,
    );
  }

  @override
  String toString() {
    return 'NotificationModel(id: $id, title: $title, module: $nameOfModule, sender: $senderEmail, receiver: $receiverEmail, pinned: $isPinned, read: $isRead)';
  }
}
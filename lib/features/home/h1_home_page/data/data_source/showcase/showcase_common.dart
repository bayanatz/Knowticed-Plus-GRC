/// Module: home/h1_home_page / data / data_source / showcase
///
///*************************** FILE INFO ****************************///
/// File Name: showcase_common.dart
/// Purpose: Shared pieces of the owner-only showcase seeder: bilingual text
///          pairs, the people the records name, and spread-over-the-year
///          dates (1 Jan 2026 → today).
/// Author: Knowticed Plus team
/// Created at: 21/10/2026
///
/// Every showcase document uses a FIXED id that starts with `showcase_`, so
/// running the seeder again overwrites the same records instead of adding
/// copies, and nothing else in the tenant is touched or deleted.
library;

import 'package:cloud_firestore/cloud_firestore.dart';

/// One piece of text in both languages.
class Bi {
  const Bi(this.en, this.ar);

  final String en;
  final String ar;

  String of(bool isArabic) => isArabic ? ar : en;
}

/// A person the showcase records refer to (requester, reviewer, author…).
class ShowcasePerson {
  const ShowcasePerson(
      this.nameEn, this.nameAr, this.email, this.titleEn, this.titleAr,
      {this.id = ''});

  final String nameEn;
  final String nameAr;
  final String email;
  final String titleEn;
  final String titleAr;

  /// Employee document id (empty for the built-in fallback people).
  final String id;

  String name(bool isArabic) => isArabic ? nameAr : nameEn;
}

abstract final class ShowcaseCommon {
  /// Prefix of every showcase document id.
  static const String idPrefix = 'showcase_';

  /// Fixed id: `showcase_<area>_<nn>`.
  static String id(String area, int n) =>
      '$idPrefix${area}_${n.toString().padLeft(2, '0')}';

  /// The company's real employees, set by the seeder before it writes, so
  /// requesters, reviewers and commenters resolve to real profiles. Falls
  /// back to [_fallbackPeople] when the employee list is not loaded.
  static List<ShowcasePerson> people = _fallbackPeople;

  static const List<ShowcasePerson> _fallbackPeople = <ShowcasePerson>[
    ShowcasePerson(
        'Khalid Al-Otaibi',
        'خالد العتيبي',
        'khalid.otaibi@bayanatz.com',
        'Director of Data Governance',
        'مدير حوكمة البيانات'),
    ShowcasePerson(
        'Noura Al-Qahtani',
        'نورة القحطاني',
        'noura.qahtani@bayanatz.com',
        'Data Quality Lead',
        'قائدة جودة البيانات'),
    ShowcasePerson(
        'Faisal Al-Harbi',
        'فيصل الحربي',
        'faisal.harbi@bayanatz.com',
        'Risk & Compliance Manager',
        'مدير المخاطر والامتثال'),
    ShowcasePerson('Reem Al-Shehri', 'ريم الشهري', 'reem.shehri@bayanatz.com',
        'Knowledge Management Specialist', 'أخصائية إدارة المعرفة'),
    ShowcasePerson(
        'Abdullah Al-Ghamdi',
        'عبدالله الغامدي',
        'abdullah.ghamdi@bayanatz.com',
        'Service Desk Supervisor',
        'مشرف مكتب الخدمات'),
    ShowcasePerson('Sara Al-Dosari', 'سارة الدوسري', 'sara.dosari@bayanatz.com',
        'Business Analyst', 'محللة أعمال'),
    ShowcasePerson('Omar Al-Zahrani', 'عمر الزهراني',
        'omar.zahrani@bayanatz.com', 'Data Engineer', 'مهندس بيانات'),
    ShowcasePerson('Lama Al-Mutairi', 'لمى المطيري',
        'lama.mutairi@bayanatz.com', 'Internal Auditor', 'مدققة داخلية'),
  ];

  static ShowcasePerson person(int i) => people[i % people.length];

  /// The [i]-th of [count] dates spread evenly from 1 Jan of [now]'s year to
  /// [now] minus [endGap], at office hours (8:00–15:59).
  static DateTime spread(int i, int count, DateTime now,
      {Duration endGap = const Duration(days: 1)}) {
    final DateTime start = DateTime(now.year);
    final DateTime end = now.subtract(endGap);
    final int span = end.difference(start).inMinutes;
    final int step = count <= 1 ? 0 : span ~/ (count - 1);
    final DateTime d = start.add(Duration(minutes: step * i));
    return DateTime(d.year, d.month, d.day, 8 + (i * 3) % 8, (i * 17) % 60);
  }

  /// Function Name: [addThread]
  ///
  /// Purpose: Adds a comment thread in the shape `UniversalCommentSection`
  /// writes (`Comment_Id`, `Comment_Text`, `Commenter_Id` = email,
  /// `Comment_Date`, no file), one comment per entry of [lines], spoken in
  /// turn by [speakers] (indexes into [people]), a few hours apart from
  /// [start]. Returns the time of the last comment.
  static DateTime addThread({
    required WriteBatch batch,
    required FirebaseFirestore firestore,
    required String collectionPath,
    required Map<String, dynamic> filterFields,
    required String threadKey,
    required List<Bi> lines,
    required List<int> speakers,
    required DateTime start,
    required bool isArabic,
  }) {
    DateTime at = start;
    for (int i = 0; i < lines.length; i++) {
      at = at.add(Duration(hours: 2 + (i * 5) % 19, minutes: (i * 23) % 60));
      final ShowcasePerson who = person(speakers[i % speakers.length]);
      final String commentId = '$idPrefix${threadKey}_c$i';
      batch.set(
        firestore.collection(collectionPath).doc(commentId),
        <String, dynamic>{
          ...filterFields,
          'Comment_Id': commentId,
          'Comment_Text': lines[i].of(isArabic),
          'Commenter_Id': who.email,
          'Comment_Date': Timestamp.fromDate(at),
          'Comment_Link': null,
          'File_Name': null,
          'File_Size': null,
        },
      );
    }
    return at;
  }
}

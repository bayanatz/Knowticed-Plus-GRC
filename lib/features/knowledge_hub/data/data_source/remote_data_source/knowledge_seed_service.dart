/// Module: knowledge_hub/data/data_source/remote_data_source
///
///*************************** FILE INFO ****************************///
/// File Name: knowledge_seed_service.dart
/// Description: Creates one sample knowledge document for EVERY status the
///              module knows about, in a single Firestore batch, so every
///              screen (Home, Submissions tabs, Approvals, Dashboard) has
///              data to show.
/// Author: Amr Mesbah
/// Created at: 11/10/2026
library;

import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:intl/intl.dart';
import 'package:knowticed_plus/core/network/api_constants.dart';
import 'package:knowticed_plus/core/network/get_base_url.dart';

import 'package:knowticed_plus/features/knowledge_hub/data/models/approval_model.dart';
import 'package:knowticed_plus/features/knowledge_hub/data/models/create_knowledge_new_model.dart';
import 'package:knowticed_plus/features/knowledge_hub/helpers/kh_log.dart';
import 'package:knowticed_plus/generated/intl/messages_all.dart';
import 'package:knowticed_plus/generated/l10n.dart';

/// One sample document: the status HISTORY it went through (oldest first,
/// with how many days ago each step happened) plus what the approval record
/// should say, if it has one.
class _SeedSpec {
  /// The sample's state label, from the translation files.
  final String Function(S s) label;
  final List<String> statuses;
  final List<int> daysAgo; // parallel to [statuses]
  final List<String> statusReasons; // parallel to [statuses]
  final bool schedule;
  final int? startInDays; // relative to today (negative = past)
  final int? endInDays;
  final String? approvalStatus;
  final String? rejectionReason;
  final String? approvalJustification;

  const _SeedSpec({
    required this.label,
    required this.statuses,
    required this.daysAgo,
    this.statusReasons = const [],
    this.schedule = false,
    this.startInDays,
    this.endInDays,
    this.approvalStatus,
    this.rejectionReason,
    this.approvalJustification,
  });

  String get labelEn => _inLanguage('en', label);
  String get labelAr => _inLanguage('ar', label);
}

/// One real sample file bundled in assets/sample_knowledge/.
class _SeedFile {
  final String extension;
  final String docType; // must match the keys of the create screen dropdown
  final String contentType;

  /// The sample file's label, from the translation files.
  final String Function(S s) label;

  const _SeedFile(this.extension, this.docType, this.contentType, this.label);

  String get labelEn => _inLanguage('en', label);
  String get labelAr => _inLanguage('ar', label);

  String get assetPath =>
      'assets/knowledge_hub_demo_files/demo_file.$extension';
}

/// [pick] read in [languageCode], whatever language the app is shown in.
///
/// The seed writes every sample in BOTH languages, so the text comes from the
/// translation files of each language in turn (rule 14: no text in code).
String _inLanguage(String languageCode, String Function(S s) pick) {
  initializeMessages(languageCode); // loads that language's messages once
  return Intl.withLocale(languageCode, () => pick(S.current));
}

class KnowledgeSeedService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  /// Download URLs of files already uploaded during this app session.
  static final Map<String, String> _uploadedUrls = {};

  /// Every file type the module can show, each with a real sample file.
  static final List<_SeedFile> _files = [
    _SeedFile('pdf', 'Policy', 'application/pdf', (s) => s.khSeedFilePdf),
    _SeedFile('doc', 'Letter', 'application/msword', (s) => s.khSeedFileDoc),
    _SeedFile(
      'docx',
      'Guidelines',
      'application/vnd.openxmlformats-officedocument.wordprocessingml.document',
      (s) => s.khSeedFileDocx,
    ),
    _SeedFile(
      'xls',
      'Report',
      'application/vnd.ms-excel',
      (s) => s.khSeedFileXls,
    ),
    _SeedFile(
      'xlsx',
      'Report',
      'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
      (s) => s.khSeedFileXlsx,
    ),
    _SeedFile('csv', 'Form', 'text/csv', (s) => s.khSeedFileCsv),
    _SeedFile(
      'ppt',
      'Presentation',
      'application/vnd.ms-powerpoint',
      (s) => s.khSeedFilePpt,
    ),
    _SeedFile(
      'pptx',
      'Presentation',
      'application/vnd.openxmlformats-officedocument.presentationml.presentation',
      (s) => s.khSeedFilePptx,
    ),
    _SeedFile('txt', 'Mandate', 'text/plain', (s) => s.khSeedFileTxt),
    _SeedFile('png', 'Frame Work', 'image/png', (s) => s.khSeedFilePng),
    _SeedFile('jpg', 'Booklet', 'image/jpeg', (s) => s.khSeedFileJpg),
    _SeedFile('gif', 'Other', 'image/gif', (s) => s.khSeedFileGif),
    _SeedFile('webp', 'Booklet', 'image/webp', (s) => s.khSeedFileWebp),
    _SeedFile('mp4', 'Video', 'video/mp4', (s) => s.khSeedFileMp4),
    _SeedFile('mov', 'Video', 'video/quicktime', (s) => s.khSeedFileMov),
    _SeedFile('webm', 'WorkShop', 'video/webm', (s) => s.khSeedFileWebm),
    _SeedFile('mp3', 'Recording', 'audio/mpeg', (s) => s.khSeedFileMp3),
  ];

  /// Uploads the bundled sample once per type to a fixed Storage path and
  /// returns its URL + size. Re-uses the existing object if already there.
  Future<(String url, int size)> _ensureUploaded(_SeedFile f) async {
    final bytes = (await rootBundle.load(f.assetPath)).buffer.asUint8List();
    final cached = _uploadedUrls[f.extension];
    if (cached != null) return (cached, bytes.length);

    final ref = _storage.ref(
      '${getBaseUrl(FirebaseCollections.knowledgeHubRoot)}/knowledge_documents/seed_samples/sample.${f.extension}',
    );
    String url;
    try {
      url = await ref.getDownloadURL(); // already uploaded earlier
    } catch (_) {
      await ref.putData(bytes, SettableMetadata(contentType: f.contentType));
      url = await ref.getDownloadURL();
      khLog('🌱 [SEED] uploaded sample.${f.extension} (${bytes.length} bytes)');
    }
    _uploadedUrls[f.extension] = url;
    return (url, bytes.length);
  }

  /// Every status in the module, in the order they appear in the workflow.
  static final List<_SeedSpec> _specs = [
    _SeedSpec(
      label: (s) => s.khSeedStatePublished,
      statuses: ['published'],
      daysAgo: [12],
    ),
    _SeedSpec(
      label: (s) => s.khSeedStatePublishedAfterApproval,
      statuses: ['pending_approval', 'published'],
      daysAgo: [20, 18],
      approvalStatus: 'approved',
      approvalJustification: 'Content reviewed and accurate.',
    ),
    _SeedSpec(
      label: (s) => s.khSeedStatePublishedScheduledWindow,
      statuses: ['pending_approval', 'approved', 'published'],
      daysAgo: [9, 8, 5],
      schedule: true,
      startInDays: -5,
      endInDays: 30,
      approvalStatus: 'approved',
      approvalJustification: 'Approved for the scheduled period.',
    ),
    _SeedSpec(
      label: (s) => s.khSeedStatePendingApproval,
      statuses: ['pending_approval'],
      daysAgo: [1],
    ),
    _SeedSpec(
      label: (s) => s.khSeedStateApprovedPublishesLater,
      statuses: ['pending_approval', 'approved'],
      daysAgo: [3, 2],
      schedule: true,
      startInDays: 3,
      endInDays: 33,
      approvalStatus: 'approved',
      approvalJustification: 'Approved — goes live on its start date.',
    ),
    _SeedSpec(
      label: (s) => s.khSeedStateScheduled,
      statuses: ['scheduled'],
      daysAgo: [2],
      schedule: true,
      startInDays: 7,
      endInDays: 37,
    ),
    _SeedSpec(
      label: (s) => s.khSeedStateRejected,
      statuses: ['pending_approval', 'rejected'],
      daysAgo: [6, 4],
      statusReasons: ['', 'Missing the department signature.'],
      approvalStatus: 'rejected',
      rejectionReason: 'Missing the department signature.',
    ),
    _SeedSpec(
      label: (s) => s.khSeedStateRemoved,
      statuses: ['published', 'removed'],
      daysAgo: [25, 3],
      statusReasons: ['', 'Superseded by a newer version.'],
    ),
    _SeedSpec(
      label: (s) => s.khSeedStateArchived,
      statuses: ['published', 'archived'],
      daysAgo: [60, 2],
      schedule: true,
      startInDays: -60,
      endInDays: -2,
    ),
  ];

  /// How many documents one call creates.
  static int get documentsPerRun => _files.length;

  /// Writes one document per status (plus Approvals records where the real
  /// flow would have created one). Returns the number of knowledge documents
  /// created, or throws on failure — the batch is all-or-nothing.
  Future<int> seedAllStates({
    required String createdByEmail,
    required String owningDepartment,
  }) async {
    final knowledgeCol = _firestore.collection(
      getBaseUrl(FirebaseCollections.createKnowledge),
    );
    final approvalsCol = _firestore.collection(
      getBaseUrl(FirebaseCollections.knowledgeApprovals),
    );

    final now = DateTime.now();
    // Short tag so each batch is easy to tell apart (and search for).
    final runTag =
        '${now.month.toString().padLeft(2, '0')}'
        '${now.day.toString().padLeft(2, '0')}-'
        '${now.hour.toString().padLeft(2, '0')}'
        '${now.minute.toString().padLeft(2, '0')}'
        '${now.second.toString().padLeft(2, '0')}';

    // Upload (or reuse) every sample file BEFORE writing any document, so a
    // failed upload never leaves documents pointing at nothing.
    final uploads = <(String, int)>[];
    for (final f in _files) {
      uploads.add(await _ensureUploaded(f));
    }

    final batch = _firestore.batch();

    // One document per file type; statuses cycle so every status is covered
    // (17 files over 9 status scenarios → each status gets at least one).
    for (var i = 0; i < _files.length; i++) {
      final file = _files[i];
      final spec = _specs[i % _specs.length];
      final (documentUrl, documentSize) = uploads[i];
      // Document ID == knowledgeId, so lookups by either one find it.
      final ref = knowledgeCol.doc();
      final knowledgeId = ref.id;

      final timestamps = spec.daysAgo
          .map(
            (d) => now
                .subtract(Duration(days: d, minutes: i))
                .millisecondsSinceEpoch,
          )
          .toList();

      final reasons = List<String>.generate(
        spec.statuses.length,
        (idx) => idx < spec.statusReasons.length ? spec.statusReasons[idx] : '',
      );

      DateTime? start;
      DateTime? end;
      if (spec.schedule) {
        final today = DateTime(now.year, now.month, now.day, 9);
        start = today.add(Duration(days: spec.startInDays ?? 0));
        end = DateTime(
          today.year,
          today.month,
          today.day,
          17,
        ).add(Duration(days: spec.endInDays ?? 30));
      }

      final createdAt = DateTime.fromMillisecondsSinceEpoch(timestamps.first);
      final fileName =
          'sample_${file.extension}_${spec.statuses.last}_$runTag.${file.extension}';

      final model = CreateKnowledgeModel(
        firestoreDocumentId: knowledgeId,
        timestamps: timestamps,
        knowledgeId: [knowledgeId],
        knowledgeImage: [''],
        nameEnglish: ['${file.labelEn} — ${spec.labelEn} ($runTag)'],
        nameArabic: ['${file.labelAr} — ${spec.labelAr} ($runTag)'],
        descriptionEnglish: [
          _inLanguage(
            'en',
            (s) => s.khSeedDescription(file.extension, spec.statuses.last),
          ),
        ],
        descriptionArabic: [
          _inLanguage(
            'ar',
            (s) => s.khSeedDescription(file.extension, spec.labelAr),
          ),
        ],
        knowledgeDocumentType: [file.docType],
        owningDepartment: [owningDepartment],
        limitedDepartments: [jsonEncode(<String>[])],
        schedulePublishing: [spec.schedule],
        startDateTime: start != null ? [Timestamp.fromDate(start)] : [],
        endDateTime: end != null ? [Timestamp.fromDate(end)] : [],
        startTime: [spec.schedule ? '09:00' : ''],
        endTime: [spec.schedule ? '17:00' : ''],
        imageUrl: [''],
        documentUrl: [documentUrl],
        documentFileName: [fileName],
        documentExtension: [file.extension],
        documentSize: [documentSize],
        createdByEmail: [createdByEmail],
        timeStamp: [createdAt.toIso8601String()],
        status: List<String>.from(spec.statuses),
        statusReason: reasons,
      );

      batch.set(ref, model.toJson());

      if (spec.approvalStatus != null) {
        final approval = ApprovalModel(
          timestamps: [timestamps.last],
          knowledgeId: [knowledgeId],
          status: [spec.approvalStatus!],
          rejectionReason: [spec.rejectionReason ?? ''],
          approvalJustification: [spec.approvalJustification ?? ''],
        );
        batch.set(approvalsCol.doc(knowledgeId), approval.toJson());
      }
    }

    await batch.commit();
    khLog(
      '🌱 [SEED] Created ${_files.length} sample knowledge documents '
      '(run $runTag) for $createdByEmail / $owningDepartment',
    );
    return _files.length;
  }
}

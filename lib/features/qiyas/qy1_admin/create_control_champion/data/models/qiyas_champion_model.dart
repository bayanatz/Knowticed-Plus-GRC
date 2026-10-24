/// ***************************** FILE INFO ***************************** ///
/// File Name: qiyas_champion_model.dart
/// Purpose: Defines the data model for Qiyas Champion in Firestore.
/// Author: Abdelrahman Sobhy
/// Created At: Apr/21/2025
/// Description: This file contains the `QiyasChampionFirestore` class, which represents the structure of the Qiyas Champion data
///              stored in Firestore. The class includes various fields such as `timeStamp`, `controlChampion`, `visions`, `topics`,
///              `criteria`, `documentSubmissionDate`, and `additionalNote`. It provides methods for converting between Firestore data
///              and the `QiyasChampionFirestore` model, including `toMap`, `fromMap`, and `toJson`. The class also includes
///              overrides for `toString`, `==` operator, and `hashCode` to support proper comparison and string representation.
/// ********************************************************************* ///
library;

import 'package:flutter/foundation.dart';
import 'package:knowticed_plus/core/network/get_base_url.dart';
import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:knowticed_plus/features/qiyas/qy1_admin/create_control_champion/domain/entities/late_unit_enum.dart';

class QiyasChampionModel {
  List<Timestamp> timeStamp;
  String controlChampion;
  String criteriaId;
  String document;
  List<Timestamp> documentSubmissionDate;
  List<String> additionalNote;
  String status;
  String id;
  int lateUnitMultiplier;
  LateUnitEnum lateUnit;

  QiyasChampionModel(
      {required this.id,
      required this.timeStamp,
      required this.controlChampion,
      required this.criteriaId,
      required this.document,
      required this.documentSubmissionDate,
      required this.additionalNote,
      required this.status,
      required this.lateUnit,
      required this.lateUnitMultiplier});

  static const String timeStampKey = 'Timestamp';
  static const String controlChampionKey = 'Champion';
  static const String visionsKey = 'Vision';
  static const String topicsKey = 'Topic';
  static const String criteriaKey = 'Criteria_Id';
  static const String documentKey = 'Document';
  static const String documentSubmissionDateKey = 'Deadline';
  static const String additionalNoteKey = 'Notes';
  static const String statusKey = 'status';
  static const String idKey = 'Id';
  static const String lateUnitMultiplierKey = 'Late_Unit_Multiplier';
  static const String lateUnitKey = 'Late_Unit';

  Map<String, dynamic> toMap() {
    return {
      idKey: id,
      timeStampKey: timeStamp,
      controlChampionKey: controlChampion,
      criteriaKey: criteriaId,
      documentKey: document,
      documentSubmissionDateKey: documentSubmissionDate,
      additionalNoteKey: additionalNote,
      statusKey: status,
      lateUnitMultiplierKey: lateUnitMultiplier,
      lateUnitKey: lateUnit.name,
    };
  }

  factory QiyasChampionModel.fromMap(Map<String, dynamic> map) {
    return QiyasChampionModel(
      lateUnit: LateUnitEnum.values.firstWhere(
          (e) => e.name == map[lateUnitKey],
          orElse: () => LateUnitEnum.hour),
      lateUnitMultiplier: map[lateUnitMultiplierKey] ?? 0,
      id: map[idKey] ?? '',
      timeStamp: List<Timestamp>.from(map[timeStampKey]?.map((x) => x)),
      controlChampion: map[controlChampionKey] ?? '',
      criteriaId: map[criteriaKey] ?? '',
      document: map[documentKey] ?? '',
      documentSubmissionDate:
          List<Timestamp>.from(map[documentSubmissionDateKey]),
      additionalNote: List<String>.from(map[additionalNoteKey]),
      status: map[statusKey] ?? '',
    );
  }
}

// Assuming you have this enum defined somewhere

class QiyasChampionHistoryModel {
  final String id;
  final List<int> timestamps;
  final List<String> controlChampion;
  final List<String> criteriaId;
  final List<String> document;
  final List<Timestamp> documentSubmissionDate;
  final List<String> additionalNote;
  final List<String> status;
  final List<int> lateUnitMultiplier;
  final List<String> lateUnit;

  QiyasChampionHistoryModel({
    required this.id,
    required this.timestamps,
    required this.controlChampion,
    required this.criteriaId,
    required this.document,
    required this.documentSubmissionDate,
    required this.additionalNote,
    required this.status,
    required this.lateUnitMultiplier,
    required this.lateUnit,
  });

  // Constants for database keys
  static const String kIdKey = 'Id';
  static const String kTimestampsKey = 'timestamps';
  static const String kTimestampKey =
      'Timestamp'; // Old key for backward compatibility
  static const String kControlChampionKey = 'Champion';
  static const String kVisionsKey = 'Vision';
  static const String kTopicsKey = 'Topic';
  static const String kCriteriaKey = 'Criteria_Id';
  static const String kDocumentKey = 'Document';
  static const String kDocumentSubmissionDateKey = 'Deadline';
  static const String kAdditionalNoteKey = 'Notes';
  static const String kStatusKey = 'status';
  static const String kLateUnitMultiplierKey = 'Late_Unit_Multiplier';
  static const String kLateUnitKey = 'Late_Unit';

  // Helper getters for current (latest) values
  String get currentControlChampion =>
      controlChampion.isNotEmpty ? controlChampion.last : '';
  String get currentCriteriaId => criteriaId.isNotEmpty ? criteriaId.last : '';
  String get currentDocument => document.isNotEmpty ? document.last : '';
  Timestamp get currentDocumentSubmissionDate =>
      documentSubmissionDate.isNotEmpty
          ? documentSubmissionDate.last
          : Timestamp.now();
  String get currentAdditionalNote =>
      additionalNote.isNotEmpty ? additionalNote.last : '';
  String get currentStatus => status.isNotEmpty ? status.last : '';
  int get currentLateUnitMultiplier =>
      lateUnitMultiplier.isNotEmpty ? lateUnitMultiplier.last : 0;
  LateUnitEnum get currentLateUnit => lateUnit.isNotEmpty
      ? LateUnitEnum.values.firstWhere((e) => e.name == lateUnit.last,
          orElse: () => LateUnitEnum.hour)
      : LateUnitEnum.hour;
  int? get currentTimestamp => timestamps.isNotEmpty ? timestamps.last : null;

  // Convert to legacy QiyasChampionModel
  QiyasChampionModel toLegacyModel() {
    return QiyasChampionModel(
      id: id,
      timeStamp: timestamps
          .map((t) => Timestamp.fromMillisecondsSinceEpoch(t))
          .toList(),
      controlChampion: currentControlChampion,
      criteriaId: currentCriteriaId,
      document: currentDocument,
      documentSubmissionDate: documentSubmissionDate,
      additionalNote: additionalNote,
      status: currentStatus,
      lateUnit: currentLateUnit,
      lateUnitMultiplier: currentLateUnitMultiplier,
    );
  }

  // Parse from Firestore map
  factory QiyasChampionHistoryModel.fromMap(Map<String, dynamic> map) {
    try {
      debugPrint("\n=== QiyasChampionHistoryModel.fromMap DEBUG ===");
      //  print("Available keys: ${map.keys.toList()}");

      // Handle timestamps - check if it's the old Timestamp field or new timestamps field
      List<int> sharedTimestamps;
      if (map.containsKey(kTimestampsKey)) {
        sharedTimestamps = (map[kTimestampsKey] as List<dynamic>?)
                ?.map((e) => e is int ? e : (e as num).toInt())
                .toList() ??
            [DateTime.now().millisecondsSinceEpoch];
      } else if (map.containsKey(kTimestampKey)) {
        // Convert old Timestamp format to timestamps
        var oldTimestamps = map[kTimestampKey];
        if (oldTimestamps is List) {
          sharedTimestamps = oldTimestamps.map((e) {
            if (e is Timestamp) return e.millisecondsSinceEpoch;
            if (e is int) return e;
            return DateTime.now().millisecondsSinceEpoch;
          }).toList();
        } else {
          sharedTimestamps = [DateTime.now().millisecondsSinceEpoch];
        }
      } else {
        sharedTimestamps = [DateTime.now().millisecondsSinceEpoch];
      }

      debugPrint("Timestamps count: ${sharedTimestamps.length}");
      debugPrint("=====================================\n");

      return QiyasChampionHistoryModel(
        id: map[kIdKey] ?? map['_documentId'] ?? '',
        timestamps: sharedTimestamps,
        controlChampion: _parseListSafely(map[kControlChampionKey]),
        criteriaId: _parseListSafely(map[kCriteriaKey]),
        document: _parseListSafely(map[kDocumentKey]),
        documentSubmissionDate:
            _parseTimestampList(map[kDocumentSubmissionDateKey]),
        additionalNote: _parseListSafely(map[kAdditionalNoteKey]),
        status: _parseListSafely(map[kStatusKey]),
        lateUnitMultiplier: _parseIntList(map[kLateUnitMultiplierKey]),
        lateUnit: _parseListSafely(map[kLateUnitKey]),
      );
    } catch (e, stack) {
      debugPrint("❌ ERROR parsing QiyasChampionHistoryModel: $e");
      debugPrint("Stacktrace:\n$stack");
      rethrow;
    }
  }

  // Helper method to parse lists safely
  static List<String> _parseListSafely(dynamic value) {
    if (value == null) return [];
    if (value is List) return value.map((e) => e?.toString() ?? '').toList();
    return [value.toString()];
  }

  // Helper method to parse int lists
  static List<int> _parseIntList(dynamic value) {
    if (value == null) return [0];
    if (value is List) {
      return value.map((e) {
        if (e is int) return e;
        if (e is num) return e.toInt();
        return int.tryParse(e.toString()) ?? 0;
      }).toList();
    }
    if (value is int) return [value];
    if (value is num) return [value.toInt()];
    return [int.tryParse(value.toString()) ?? 0];
  }

  // Helper method to parse Timestamp lists
  static List<Timestamp> _parseTimestampList(dynamic value) {
    if (value == null) return [Timestamp.now()];
    if (value is List) {
      return value.map((e) {
        if (e is Timestamp) return e;
        if (e is int) return Timestamp.fromMillisecondsSinceEpoch(e);
        if (e is Map && e.containsKey('_seconds')) {
          return Timestamp(e['_seconds'], e['_nanoseconds'] ?? 0);
        }
        return Timestamp.now();
      }).toList();
    }
    if (value is Timestamp) return [value];
    if (value is int) return [Timestamp.fromMillisecondsSinceEpoch(value)];
    return [Timestamp.now()];
  }

  // Convert to Firestore map
  Map<String, dynamic> toMap() {
    return {
      kIdKey: id,
      kTimestampsKey: timestamps,
      kControlChampionKey: controlChampion,
      kCriteriaKey: criteriaId,
      kDocumentKey: document,
      kDocumentSubmissionDateKey:
          documentSubmissionDate.map((t) => t.millisecondsSinceEpoch).toList(),
      kAdditionalNoteKey: additionalNote,
      kStatusKey: status,
      kLateUnitMultiplierKey: lateUnitMultiplier,
      kLateUnitKey: lateUnit,
    };
  }

  String toJson() => json.encode(toMap());

  factory QiyasChampionHistoryModel.fromJson(String source) =>
      QiyasChampionHistoryModel.fromMap(json.decode(source));

  // CopyWith method that synchronizes ALL fields
  QiyasChampionHistoryModel copyWith({
    String? controlChampion,
    String? criteriaId,
    String? document,
    Timestamp? documentSubmissionDate,
    String? additionalNote,
    String? status,
    int? lateUnitMultiplier,
    LateUnitEnum? lateUnit,
  }) {
    debugPrint("\n=== QiyasChampionHistoryModel.copyWith DEBUG ===");

    // Add new timestamp for this update
    final newTimestamps = List<int>.from(timestamps)
      ..add(DateTime.now().millisecondsSinceEpoch);

    debugPrint(
        "Creating synchronized update at index ${newTimestamps.length - 1}");
    debugPrint("Edited fields:");
    if (controlChampion != null) {
      debugPrint("  - controlChampion: '$controlChampion'");
    }
    if (criteriaId != null) debugPrint("  - criteriaId: '$criteriaId'");
    if (document != null) debugPrint("  - document: '$document'");
    if (documentSubmissionDate != null) {
      debugPrint("  - documentSubmissionDate");
    }
    if (additionalNote != null) debugPrint("  - additionalNote");
    if (status != null) debugPrint("  - status: '$status'");
    if (lateUnitMultiplier != null) {
      debugPrint("  - lateUnitMultiplier: $lateUnitMultiplier");
    }
    if (lateUnit != null) debugPrint("  - lateUnit: $lateUnit");

    // ALL fields get updated - edited values OR current values repeated
    final result = QiyasChampionHistoryModel(
      id: id,
      timestamps: newTimestamps,
      controlChampion: List<String>.from(this.controlChampion)
        ..add(controlChampion ?? currentControlChampion),
      criteriaId: List<String>.from(this.criteriaId)
        ..add(criteriaId ?? currentCriteriaId),
      document: List<String>.from(this.document)
        ..add(document ?? currentDocument),
      documentSubmissionDate: List<Timestamp>.from(this.documentSubmissionDate)
        ..add(documentSubmissionDate ?? currentDocumentSubmissionDate),
      additionalNote: List<String>.from(this.additionalNote)
        ..add(additionalNote ?? currentAdditionalNote),
      status: List<String>.from(this.status)..add(status ?? currentStatus),
      lateUnitMultiplier: List<int>.from(this.lateUnitMultiplier)
        ..add(lateUnitMultiplier ?? currentLateUnitMultiplier),
      lateUnit: List<String>.from(this.lateUnit)
        ..add(lateUnit?.name ?? currentLateUnit.name),
    );

    debugPrint(
        "✓ All arrays now have ${result.timestamps.length} entries (synchronized)");
    debugPrint("  - controlChampion length: ${result.controlChampion.length}");
    debugPrint("  - criteriaId length: ${result.criteriaId.length}");
    debugPrint("  - document length: ${result.document.length}");
    debugPrint(
        "  - documentSubmissionDate length: ${result.documentSubmissionDate.length}");
    debugPrint("  - additionalNote length: ${result.additionalNote.length}");
    debugPrint("  - status length: ${result.status.length}");
    debugPrint(
        "  - lateUnitMultiplier length: ${result.lateUnitMultiplier.length}");
    debugPrint("  - lateUnit length: ${result.lateUnit.length}");
    debugPrint("=====================================\n");

    return result;
  }

  // Factory constructor for creating new qiyas champions
  factory QiyasChampionHistoryModel.createNew({
    required String id,
    String controlChampion = '',
    String criteriaId = '',
    String document = '',
    Timestamp? documentSubmissionDate,
    String additionalNote = '',
    String status = '',
    int lateUnitMultiplier = 0,
    LateUnitEnum lateUnit = LateUnitEnum.hour,
  }) {
    return QiyasChampionHistoryModel(
      id: id,
      timestamps: [DateTime.now().millisecondsSinceEpoch],
      controlChampion: [controlChampion],
      criteriaId: [criteriaId],
      document: [document],
      documentSubmissionDate: [documentSubmissionDate ?? Timestamp.now()],
      additionalNote: [additionalNote],
      status: [status],
      lateUnitMultiplier: [lateUnitMultiplier],
      lateUnit: [lateUnit.name],
    );
  }

  // Generate next qiyas champion ID
  static Future<String> generateNextId() async {
    try {
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection(getBaseUrl('Qiyas_Champions'))
          .orderBy(kIdKey, descending: true)
          .limit(1)
          .get();

      if (snapshot.docs.isEmpty) {
        return "QC001";
      }

      String lastId = snapshot.docs.first.get(kIdKey) ?? snapshot.docs.first.id;
      String numericPart = lastId.replaceAll(RegExp(r'[^0-9]'), '');
      int nextNumber = int.parse(numericPart.isEmpty ? '0' : numericPart) + 1;
      return "QC${nextNumber.toString().padLeft(3, '0')}";
    } catch (e) {
      debugPrint('Error generating qiyas champion ID: $e');
      return "QC${DateTime.now().millisecondsSinceEpoch}";
    }
  }

  // Get history at a specific index
  QiyasChampionSnapshot? getSnapshotAt(int index) {
    if (index < 0 || index >= timestamps.length) return null;

    return QiyasChampionSnapshot(
      timestamp: timestamps[index],
      controlChampion:
          index < controlChampion.length ? controlChampion[index] : '',
      criteriaId: index < criteriaId.length ? criteriaId[index] : '',
      document: index < document.length ? document[index] : '',
      documentSubmissionDate: index < documentSubmissionDate.length
          ? documentSubmissionDate[index]
          : Timestamp.now(),
      additionalNote:
          index < additionalNote.length ? additionalNote[index] : '',
      status: index < status.length ? status[index] : '',
      lateUnitMultiplier:
          index < lateUnitMultiplier.length ? lateUnitMultiplier[index] : 0,
      lateUnit:
          index < lateUnit.length ? lateUnit[index] : LateUnitEnum.hour.name,
    );
  }

  // Get all history snapshots
  List<QiyasChampionSnapshot> getAllSnapshots() {
    return List.generate(timestamps.length, (index) => getSnapshotAt(index)!);
  }
}

// Helper class for representing a snapshot in time
class QiyasChampionSnapshot {
  final int timestamp;
  final String controlChampion;
  final String criteriaId;
  final String document;
  final Timestamp documentSubmissionDate;
  final String additionalNote;
  final String status;
  final int lateUnitMultiplier;
  final String lateUnit;

  QiyasChampionSnapshot({
    required this.timestamp,
    required this.controlChampion,
    required this.criteriaId,
    required this.document,
    required this.documentSubmissionDate,
    required this.additionalNote,
    required this.status,
    required this.lateUnitMultiplier,
    required this.lateUnit,
  });

  DateTime get dateTime => DateTime.fromMillisecondsSinceEpoch(timestamp);

  LateUnitEnum get lateUnitEnum => LateUnitEnum.values.firstWhere(
        (e) => e.name == lateUnit,
        orElse: () => LateUnitEnum.hour,
      );

  Map<String, dynamic> toMap() {
    return {
      'timestamp': timestamp,
      'dateTime': dateTime.toIso8601String(),
      'controlChampion': controlChampion,
      'criteriaId': criteriaId,
      'document': document,
      'documentSubmissionDate':
          documentSubmissionDate.toDate().toIso8601String(),
      'additionalNote': additionalNote,
      'status': status,
      'lateUnitMultiplier': lateUnitMultiplier,
      'lateUnit': lateUnit,
    };
  }
}

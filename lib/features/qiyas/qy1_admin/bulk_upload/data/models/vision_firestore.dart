/// ***************************** FILE INFO ***************************** ///
/// File Name: vision_firestore.dart
/// Purpose: Defines the model for storing and handling vision data in Firestore.
/// Author: Abdelrahman Sobhy
/// Created At: Apr/21/2025
/// Description: This file defines the `VisionFirestore` class, which represents a vision object in Firestore.
///              It includes methods for serializing and deserializing data between Firestore and Flutter,
///              as well as methods for deep copying and comparing vision instances. It is used for mapping
///              vision data between Firestore documents and the Flutter application.
/// ********************************************************************* ///
library;

import 'package:flutter/foundation.dart';
import 'package:knowticed_plus/core/network/get_base_url.dart';
import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';

class VisionModel {
  List<Timestamp> timeStamp;
  List<String> visionName;
  List<String> topicNumber;
  List<String> topicName;
  List<String> criterionNumber;
  List<String> criterionName;
  List<String> goals;
  List<String> appRequirements;
  List<String> evidenceDocuments;
  List<String> ordersDecisionsAndCirculars;
  List<String> scope;
  List<String> description = [];
  String id;

  VisionModel(
      {required this.timeStamp,
      required this.visionName,
      required this.topicNumber,
      required this.topicName,
      required this.criterionNumber,
      required this.criterionName,
      required this.goals,
      required this.appRequirements,
      required this.evidenceDocuments,
      required this.ordersDecisionsAndCirculars,
      required this.scope,
      required this.id,
      required this.description});

  static const String timestampKey = 'TimeStamp';
  static const String visionNameKey = 'Vision_Name';
  static const String topicNumberKey = 'Topic_Number';
  static const String topicNameKey = 'Topic_Name';
  static const String criterionNumberKey = 'Criterion_Number';
  static const String criterionNameKey = 'Criterion_Name';
  static const String goalsKey = 'Goals';
  static const String appRequirementsKey = 'App_Requirements';
  static const String evidenceDocumentsKey = 'Evidence_Documents';
  static const String ordersDecisionsAndCircularsKey =
      'Orders_Decisions_And_Circulars';
  static const String scopeKey = 'Scope';
  static const String idKey = 'Id';
  static const String descriptionKey = 'Description';

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      timestampKey: timeStamp,
      visionNameKey: visionName,
      topicNumberKey: topicNumber,
      topicNameKey: topicName,
      criterionNumberKey: criterionNumber,
      criterionNameKey: criterionName,
      goalsKey: goals,
      appRequirementsKey: appRequirements,
      evidenceDocumentsKey: evidenceDocuments,
      ordersDecisionsAndCircularsKey: ordersDecisionsAndCirculars,
      scopeKey: scope,
      idKey: id,
      descriptionKey: description,
    };
  }

  factory VisionModel.fromMap(Map<String, dynamic> map) {
    return VisionModel(
      id: map[idKey],
      timeStamp: List<Timestamp>.from(map[timestampKey] as List<dynamic>),
      visionName: List<String>.from(map[visionNameKey] as List<dynamic>),
      topicNumber: List<String>.from(map[topicNumberKey] as List<dynamic>),
      topicName: List<String>.from(map[topicNameKey] as List<dynamic>),
      criterionNumber:
          List<String>.from(map[criterionNumberKey] as List<dynamic>),
      criterionName: List<String>.from(map[criterionNameKey] as List<dynamic>),
      goals: List<String>.from(map[goalsKey] as List<dynamic>),
      appRequirements:
          List<String>.from(map[appRequirementsKey] as List<dynamic>),
      description: List<String>.from(map[descriptionKey] as List<dynamic>),
      evidenceDocuments:
          List<String>.from(map[evidenceDocumentsKey] as List<dynamic>),
      ordersDecisionsAndCirculars: List<String>.from(
          map[ordersDecisionsAndCircularsKey] as List<dynamic>),
      scope: List<String>.from(map[scopeKey] as List<dynamic>),
    );
  }
}

class VisionHistoryModel {
  final String id;
  final List<int> timestamps;
  final List<String> visionName;
  final List<String> topicNumber;
  final List<String> topicName;
  final List<String> criterionNumber;
  final List<String> criterionName;
  final List<String> goals;
  final List<String> appRequirements;
  final List<String> evidenceDocuments;
  final List<String> ordersDecisionsAndCirculars;
  final List<String> scope;
  final List<String> description;

  VisionHistoryModel({
    required this.id,
    required this.timestamps,
    required this.visionName,
    required this.topicNumber,
    required this.topicName,
    required this.criterionNumber,
    required this.criterionName,
    required this.goals,
    required this.appRequirements,
    required this.evidenceDocuments,
    required this.ordersDecisionsAndCirculars,
    required this.scope,
    required this.description,
  });

  // Constants for database keys
  static const String kIdKey = 'Id';
  static const String kTimestampsKey = 'timestamps';
  static const String kVisionNameKey = 'Vision_Name';
  static const String kTopicNumberKey = 'Topic_Number';
  static const String kTopicNameKey = 'Topic_Name';
  static const String kCriterionNumberKey = 'Criterion_Number';
  static const String kCriterionNameKey = 'Criterion_Name';
  static const String kGoalsKey = 'Goals';
  static const String kAppRequirementsKey = 'App_Requirements';
  static const String kEvidenceDocumentsKey = 'Evidence_Documents';
  static const String kOrdersDecisionsCircularsKey =
      'Orders_Decisions_And_Circulars';
  static const String kScopeKey = 'Scope';
  static const String kDescriptionKey = 'Description';

  // Helper getters for current (latest) values
  String get currentVisionName => visionName.isNotEmpty ? visionName.last : '';
  String get currentTopicNumber =>
      topicNumber.isNotEmpty ? topicNumber.last : '';
  String get currentTopicName => topicName.isNotEmpty ? topicName.last : '';
  String get currentCriterionNumber =>
      criterionNumber.isNotEmpty ? criterionNumber.last : '';
  String get currentCriterionName =>
      criterionName.isNotEmpty ? criterionName.last : '';
  String get currentGoals => goals.isNotEmpty ? goals.last : '';
  String get currentAppRequirements =>
      appRequirements.isNotEmpty ? appRequirements.last : '';
  String get currentEvidenceDocuments =>
      evidenceDocuments.isNotEmpty ? evidenceDocuments.last : '';
  String get currentOrdersDecisionsAndCirculars =>
      ordersDecisionsAndCirculars.isNotEmpty
          ? ordersDecisionsAndCirculars.last
          : '';
  String get currentScope => scope.isNotEmpty ? scope.last : '';
  String get currentDescription =>
      description.isNotEmpty ? description.last : '';
  int? get currentTimestamp => timestamps.isNotEmpty ? timestamps.last : null;

  // Convert to legacy VisionModel
  VisionModel toLegacyModel() {
    return VisionModel(
      id: id,
      timeStamp: timestamps
          .map((t) => Timestamp.fromMillisecondsSinceEpoch(t))
          .toList(),
      visionName: visionName,
      topicNumber: topicNumber,
      topicName: topicName,
      criterionNumber: criterionNumber,
      criterionName: criterionName,
      goals: goals,
      appRequirements: appRequirements,
      evidenceDocuments: evidenceDocuments,
      ordersDecisionsAndCirculars: ordersDecisionsAndCirculars,
      scope: scope,
      description: description,
    );
  }

  // Parse from Firestore map
  factory VisionHistoryModel.fromMap(Map<String, dynamic> map) {
    try {
      // print("\n=== VisionHistoryModel.fromMap DEBUG ===");
      // print("Available keys: ${map.keys.toList()}");

      // Handle timestamps - check if it's the old TimeStamp field or new timestamps field
      List<int> sharedTimestamps;
      if (map.containsKey(kTimestampsKey)) {
        sharedTimestamps = (map[kTimestampsKey] as List<dynamic>?)
                ?.map((e) => e is int ? e : (e as num).toInt())
                .toList() ??
            [DateTime.now().millisecondsSinceEpoch];
      } else if (map.containsKey('TimeStamp')) {
        // Convert old TimeStamp format to timestamps
        var oldTimestamps = map['TimeStamp'];
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

      return VisionHistoryModel(
        id: map[kIdKey] ?? map['_documentId'] ?? '',
        timestamps: sharedTimestamps,
        visionName: _parseListSafely(map[kVisionNameKey]),
        topicNumber: _parseListSafely(map[kTopicNumberKey]),
        topicName: _parseListSafely(map[kTopicNameKey]),
        criterionNumber: _parseListSafely(map[kCriterionNumberKey]),
        criterionName: _parseListSafely(map[kCriterionNameKey]),
        goals: _parseListSafely(map[kGoalsKey]),
        appRequirements: _parseListSafely(map[kAppRequirementsKey]),
        evidenceDocuments: _parseListSafely(map[kEvidenceDocumentsKey]),
        ordersDecisionsAndCirculars:
            _parseListSafely(map[kOrdersDecisionsCircularsKey]),
        scope: _parseListSafely(map[kScopeKey]),
        description: _parseListSafely(map[kDescriptionKey]),
      );
    } catch (e, stack) {
      debugPrint("❌ ERROR parsing VisionHistoryModel: $e");
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

  // Convert to Firestore map
  Map<String, dynamic> toMap() {
    return {
      kIdKey: id,
      kTimestampsKey: timestamps,
      kVisionNameKey: visionName,
      kTopicNumberKey: topicNumber,
      kTopicNameKey: topicName,
      kCriterionNumberKey: criterionNumber,
      kCriterionNameKey: criterionName,
      kGoalsKey: goals,
      kAppRequirementsKey: appRequirements,
      kEvidenceDocumentsKey: evidenceDocuments,
      kOrdersDecisionsCircularsKey: ordersDecisionsAndCirculars,
      kScopeKey: scope,
      kDescriptionKey: description,
    };
  }

  String toJson() => json.encode(toMap());

  factory VisionHistoryModel.fromJson(String source) =>
      VisionHistoryModel.fromMap(json.decode(source));

  // CopyWith method that synchronizes ALL fields
  VisionHistoryModel copyWith({
    String? visionName,
    String? topicNumber,
    String? topicName,
    String? criterionNumber,
    String? criterionName,
    String? goals,
    String? appRequirements,
    String? evidenceDocuments,
    String? ordersDecisionsAndCirculars,
    String? scope,
    String? description,
  }) {
    debugPrint("\n=== VisionHistoryModel.copyWith DEBUG ===");

    // Add new timestamp for this update
    final newTimestamps = List<int>.from(timestamps)
      ..add(DateTime.now().millisecondsSinceEpoch);

    debugPrint(
        "Creating synchronized update at index ${newTimestamps.length - 1}");
    debugPrint("Edited fields:");
    if (visionName != null) debugPrint("  - visionName: '$visionName'");
    if (topicNumber != null) debugPrint("  - topicNumber: '$topicNumber'");
    if (topicName != null) debugPrint("  - topicName: '$topicName'");
    if (criterionNumber != null) {
      debugPrint("  - criterionNumber: '$criterionNumber'");
    }
    if (criterionName != null) {
      debugPrint("  - criterionName: '$criterionName'");
    }
    if (goals != null) debugPrint("  - goals");
    if (appRequirements != null) debugPrint("  - appRequirements");
    if (evidenceDocuments != null) debugPrint("  - evidenceDocuments");
    if (ordersDecisionsAndCirculars != null) {
      debugPrint("  - ordersDecisionsAndCirculars");
    }
    if (scope != null) debugPrint("  - scope");
    if (description != null) debugPrint("  - description");

    // ALL fields get updated - edited values OR current values repeated
    final result = VisionHistoryModel(
      id: id,
      timestamps: newTimestamps,
      visionName: List<String>.from(this.visionName)
        ..add(visionName ?? currentVisionName),
      topicNumber: List<String>.from(this.topicNumber)
        ..add(topicNumber ?? currentTopicNumber),
      topicName: List<String>.from(this.topicName)
        ..add(topicName ?? currentTopicName),
      criterionNumber: List<String>.from(this.criterionNumber)
        ..add(criterionNumber ?? currentCriterionNumber),
      criterionName: List<String>.from(this.criterionName)
        ..add(criterionName ?? currentCriterionName),
      goals: List<String>.from(this.goals)..add(goals ?? currentGoals),
      appRequirements: List<String>.from(this.appRequirements)
        ..add(appRequirements ?? currentAppRequirements),
      evidenceDocuments: List<String>.from(this.evidenceDocuments)
        ..add(evidenceDocuments ?? currentEvidenceDocuments),
      ordersDecisionsAndCirculars: List<String>.from(
          this.ordersDecisionsAndCirculars)
        ..add(
            ordersDecisionsAndCirculars ?? currentOrdersDecisionsAndCirculars),
      scope: List<String>.from(this.scope)..add(scope ?? currentScope),
      description: List<String>.from(this.description)
        ..add(description ?? currentDescription),
    );

    debugPrint(
        "✓ All arrays now have ${result.timestamps.length} entries (synchronized)");
    debugPrint("  - visionName length: ${result.visionName.length}");
    debugPrint("  - topicNumber length: ${result.topicNumber.length}");
    debugPrint("  - topicName length: ${result.topicName.length}");
    debugPrint("  - criterionNumber length: ${result.criterionNumber.length}");
    debugPrint("  - criterionName length: ${result.criterionName.length}");
    debugPrint("  - goals length: ${result.goals.length}");
    debugPrint("  - appRequirements length: ${result.appRequirements.length}");
    debugPrint(
        "  - evidenceDocuments length: ${result.evidenceDocuments.length}");
    debugPrint(
        "  - ordersDecisionsAndCirculars length: ${result.ordersDecisionsAndCirculars.length}");
    debugPrint("  - scope length: ${result.scope.length}");
    debugPrint("  - description length: ${result.description.length}");
    debugPrint("=====================================\n");

    return result;
  }

  // Factory constructor for creating new visions
  factory VisionHistoryModel.createNew({
    required String id,
    String visionName = '',
    String topicNumber = '',
    String topicName = '',
    String criterionNumber = '',
    String criterionName = '',
    String goals = '',
    String appRequirements = '',
    String evidenceDocuments = '',
    String ordersDecisionsAndCirculars = '',
    String scope = '',
    String description = '',
  }) {
    return VisionHistoryModel(
      id: id,
      timestamps: [DateTime.now().millisecondsSinceEpoch],
      visionName: [visionName],
      topicNumber: [topicNumber],
      topicName: [topicName],
      criterionNumber: [criterionNumber],
      criterionName: [criterionName],
      goals: [goals],
      appRequirements: [appRequirements],
      evidenceDocuments: [evidenceDocuments],
      ordersDecisionsAndCirculars: [ordersDecisionsAndCirculars],
      scope: [scope],
      description: [description],
    );
  }

  // Generate next vision ID
  static Future<String> generateNextVisionId() async {
    try {
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection(getBaseUrl('Visions'))
          .orderBy(kIdKey, descending: true)
          .limit(1)
          .get();

      if (snapshot.docs.isEmpty) {
        return "VIS001";
      }

      String lastId = snapshot.docs.first.get(kIdKey) ?? snapshot.docs.first.id;
      String numericPart = lastId.replaceAll(RegExp(r'[^0-9]'), '');
      int nextNumber = int.parse(numericPart.isEmpty ? '0' : numericPart) + 1;
      return "VIS${nextNumber.toString().padLeft(3, '0')}";
    } catch (e) {
      debugPrint('Error generating vision ID: $e');
      return "VIS${DateTime.now().millisecondsSinceEpoch}";
    }
  }

  // Get history at a specific index
  VisionSnapshot? getSnapshotAt(int index) {
    if (index < 0 || index >= timestamps.length) return null;

    return VisionSnapshot(
      timestamp: timestamps[index],
      visionName: index < visionName.length ? visionName[index] : '',
      topicNumber: index < topicNumber.length ? topicNumber[index] : '',
      topicName: index < topicName.length ? topicName[index] : '',
      criterionNumber:
          index < criterionNumber.length ? criterionNumber[index] : '',
      criterionName: index < criterionName.length ? criterionName[index] : '',
      goals: index < goals.length ? goals[index] : '',
      appRequirements:
          index < appRequirements.length ? appRequirements[index] : '',
      evidenceDocuments:
          index < evidenceDocuments.length ? evidenceDocuments[index] : '',
      ordersDecisionsAndCirculars: index < ordersDecisionsAndCirculars.length
          ? ordersDecisionsAndCirculars[index]
          : '',
      scope: index < scope.length ? scope[index] : '',
      description: index < description.length ? description[index] : '',
    );
  }

  // Get all history snapshots
  List<VisionSnapshot> getAllSnapshots() {
    return List.generate(timestamps.length, (index) => getSnapshotAt(index)!);
  }
}

// Helper class for representing a snapshot in time
class VisionSnapshot {
  final int timestamp;
  final String visionName;
  final String topicNumber;
  final String topicName;
  final String criterionNumber;
  final String criterionName;
  final String goals;
  final String appRequirements;
  final String evidenceDocuments;
  final String ordersDecisionsAndCirculars;
  final String scope;
  final String description;

  VisionSnapshot({
    required this.timestamp,
    required this.visionName,
    required this.topicNumber,
    required this.topicName,
    required this.criterionNumber,
    required this.criterionName,
    required this.goals,
    required this.appRequirements,
    required this.evidenceDocuments,
    required this.ordersDecisionsAndCirculars,
    required this.scope,
    required this.description,
  });

  DateTime get dateTime => DateTime.fromMillisecondsSinceEpoch(timestamp);

  Map<String, dynamic> toMap() {
    return {
      'timestamp': timestamp,
      'dateTime': dateTime.toIso8601String(),
      'visionName': visionName,
      'topicNumber': topicNumber,
      'topicName': topicName,
      'criterionNumber': criterionNumber,
      'criterionName': criterionName,
      'goals': goals,
      'appRequirements': appRequirements,
      'evidenceDocuments': evidenceDocuments,
      'ordersDecisionsAndCirculars': ordersDecisionsAndCirculars,
      'scope': scope,
      'description': description,
    };
  }
}

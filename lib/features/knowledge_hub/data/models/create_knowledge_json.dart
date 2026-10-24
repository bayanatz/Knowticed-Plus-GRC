/// Module: knowledge_hub/data/models
/// ************************* FILE INFO *************************** ///
/// File Name: create_knowledge_json.dart
/// Description: Reading and writing `CreateKnowledgeModel` as Firestore JSON.
/// Author: Amr Mesbah
/// Created at: 15/10/2026
library;

import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:knowticed_plus/features/knowledge_hub/data/models/create_knowledge_new_model.dart';

typedef _K = CreateKnowledgeKeys;

class CreateKnowledgeJson {
  const CreateKnowledgeJson._();

  /// Every value is read defensively, so a malformed field becomes an empty
  /// or default entry instead of an exception.
  static CreateKnowledgeModel fromJson(
    Map<String, dynamic> json, [
    String? docId,
  ]) {
    final List<int> timestamps = _list<int>(json[_K.timestamps], _int);
    return CreateKnowledgeModel(
      firestoreDocumentId: docId,
      timestamps: timestamps.isEmpty
          ? [DateTime.now().millisecondsSinceEpoch]
          : timestamps,
      knowledgeId: _list(json[_K.knowledgeId], _string),
      knowledgeImage: _list(json[_K.knowledgeImage], _string),
      nameEnglish: _list(json[_K.nameEnglish], _string),
      nameArabic: _list(json[_K.nameArabic], _string),
      descriptionEnglish: _list(json[_K.descriptionEnglish], _string),
      descriptionArabic: _list(json[_K.descriptionArabic], _string),
      knowledgeDocumentType: _list(json[_K.knowledgeDocumentType], _string),
      owningDepartment: _list(json[_K.owningDepartment], _string),
      limitedDepartments: _list(json[_K.limitedDepartments], _jsonArray),
      schedulePublishing: _list(json[_K.schedulePublishing], (v) => v == true),
      startDateTime: _list(json[_K.startDateTime], _timestamp),
      endDateTime: _list(json[_K.endDateTime], _timestamp),
      startTime: _list(json[_K.startTime], _string),
      endTime: _list(json[_K.endTime], _string),
      imageUrl: _list(json[_K.imageUrl], _string),
      documentUrl: _list(json[_K.documentUrl], _string),
      documentFileName: _list(json[_K.documentFileName], _string),
      timeStamp: _list(json[_K.timeStamp], _string),
      documentExtension: _list(json[_K.documentExtension], _string),
      documentSize: _list(json[_K.documentSize], _int),
      status: _list(json[_K.status], _string),
      createdByEmail: _list(json[_K.createdByEmail], _string),
      statusReason: _list(json[_K.statusReason], _string),
      editedByEmail: _list(json[_K.editedByEmail], _string),
      pendingEdit: json[_K.pendingEdit] is Map
          ? Map<String, dynamic>.from(json[_K.pendingEdit] as Map)
          : null,
    );
  }

  static Map<String, dynamic> toJson(CreateKnowledgeModel m) => {
    _K.timestamps: m.timestamps,
    _K.knowledgeId: m.knowledgeId,
    _K.knowledgeImage: m.knowledgeImage,
    _K.nameEnglish: m.nameEnglish,
    _K.nameArabic: m.nameArabic,
    _K.descriptionEnglish: m.descriptionEnglish,
    _K.descriptionArabic: m.descriptionArabic,
    _K.knowledgeDocumentType: m.knowledgeDocumentType,
    _K.owningDepartment: m.owningDepartment,
    _K.limitedDepartments: m.limitedDepartments,
    _K.schedulePublishing: m.schedulePublishing,
    _K.startDateTime: m.startDateTime
        .map((v) => v.millisecondsSinceEpoch)
        .toList(),
    _K.endDateTime: m.endDateTime.map((v) => v.millisecondsSinceEpoch).toList(),
    _K.startTime: m.startTime,
    _K.endTime: m.endTime,
    _K.imageUrl: m.imageUrl,
    _K.documentUrl: m.documentUrl,
    _K.documentFileName: m.documentFileName,
    _K.timeStamp: m.timeStamp,
    _K.documentExtension: m.documentExtension,
    _K.documentSize: m.documentSize,
    _K.createdByEmail: m.createdByEmail,
    _K.status: m.status,
    _K.statusReason: m.statusReason,
    _K.editedByEmail: m.editedByEmail,
    ...m.visibilityFields,
  };

  /// A list field, in any of its stored forms: a list, a legacy
  /// `{values: [...]}` / `{value: ...}` map, or a single value.
  static List<T> _list<T>(dynamic value, T Function(dynamic) read) {
    if (value == null) return <T>[];
    if (value is List) return value.map(read).toList();
    if (value is Map && value['values'] is List) {
      return (value['values'] as List).map(read).toList();
    }
    if (value is Map && value.containsKey('value')) {
      return [read(value['value'])];
    }
    return [read(value)];
  }

  static String _string(dynamic v) => v == null ? '' : v.toString();

  static int _int(dynamic v) =>
      v is int ? v : (v is num ? v.toInt() : int.tryParse('$v') ?? 0);

  static String _jsonArray(dynamic v) {
    if (v is String) return v;
    if (v is List) return jsonEncode(v);
    return '[]';
  }

  static Timestamp _timestamp(dynamic v) {
    if (v is Timestamp) return v;
    if (v is int) return Timestamp.fromMillisecondsSinceEpoch(v);
    if (v is DateTime) return Timestamp.fromDate(v);
    final DateTime? parsed = v is String ? DateTime.tryParse(v) : null;
    return parsed == null ? Timestamp.now() : Timestamp.fromDate(parsed);
  }
}

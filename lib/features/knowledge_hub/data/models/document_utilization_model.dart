/// Module: knowledge_hub/data/models
///
///*************************** FILE INFO ****************************///
/// File Name: document_utilization_model.dart
/// Description: `DocumentUtilizationModel` data model.
/// Author: Amr Mesbah
/// Created at: 06/10/2026
library;

/// Module: knowledge_hub / core/data/models/document_utilization_model.dart
/// ************************* FILE INFO *************************** ///
/// File Name: document_utilization_model.dart
/// Purpose: Contains the model class to track document utilization actions.
/// Author: Youssef Khaled
/// Created At: 10/23/2025
/// Updated: Refactored from ActionOnFileModel

class DocumentUtilizationModel {
  /// Firestore key of the employee who acted (KH-CREATE-14: always the
  /// employee ID).
  static const String keyEmployeeId = 'employeeId';

  /// The key rows used before KH-CREATE-14. It held an e-mail on some screens
  /// and an employee ID on others; read only as a fallback.
  static const String keyLegacyUserId = 'userId';

  // Core fields
  final List<String> timestamp;
  final List<String> fileId;
  final List<String> typeOfAction;

  /// The employee ID of whoever viewed / downloaded / exported the file.
  final List<String> employeeId;

  DocumentUtilizationModel({
    required this.timestamp,
    required this.fileId,
    required this.typeOfAction,
    required this.employeeId,
  });

  // ✅ Helper getters for current (latest) values
  String get currentTimestamp => timestamp.isNotEmpty ? timestamp.last : '';
  String get currentFileId => fileId.isNotEmpty ? fileId.last : '';
  String get currentTypeOfAction =>
      typeOfAction.isNotEmpty ? typeOfAction.last : '';
  String get currentEmployeeId => employeeId.isNotEmpty ? employeeId.last : '';

  // ✅ Get value at specific index
  String? getTimestampAt(int index) =>
      index < timestamp.length ? timestamp[index] : null;
  String? getFileIdAt(int index) =>
      index < fileId.length ? fileId[index] : null;
  String? getTypeOfActionAt(int index) =>
      index < typeOfAction.length ? typeOfAction[index] : null;
  String? getEmployeeIdAt(int index) =>
      index < employeeId.length ? employeeId[index] : null;

  // Factory: Create from JSON
  factory DocumentUtilizationModel.fromJson(Map<String, dynamic> json) {
    return DocumentUtilizationModel(
      timestamp: _parseList<String>(
        json['timestamp'],
        (v) => v?.toString() ?? '',
      ),
      fileId: _parseList<String>(json['fileId'], (v) => v?.toString() ?? ''),
      typeOfAction: _parseList<String>(
        json['typeOfAction'],
        (v) => v?.toString() ?? '',
      ),
      employeeId: _parseList<String>(
        json[keyEmployeeId] ?? json[keyLegacyUserId],
        (v) => v?.toString() ?? '',
      ),
    );
  }

  // Helper: Parse list (handles multiple legacy formats)
  static List<T> _parseList<T>(
    dynamic value,
    T Function(dynamic) deserializer,
  ) {
    // If it's already a list
    if (value is List) {
      return value.map((e) => deserializer(e)).toList();
    }

    // Legacy format with FieldHistory: {timestamps: [...], values: [...]}
    if (value is Map<String, dynamic> && value.containsKey('values')) {
      final values = value['values'];
      if (values is List) {
        return values.map((e) => deserializer(e)).toList();
      }
    }

    // Legacy format: {value: ..., timestamp: ...}
    if (value is Map<String, dynamic> && value.containsKey('value')) {
      return [deserializer(value['value'])];
    }

    // Simple value
    return [deserializer(value)];
  }

  // Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'timestamp': timestamp,
      'fileId': fileId,
      'typeOfAction': typeOfAction,
      keyEmployeeId: employeeId,
    };
  }

  // Factory: Create with initial values
  factory DocumentUtilizationModel.createNew({
    required String timestamp,
    required String fileId,
    required String typeOfAction,
    required String employeeId,
  }) {
    return DocumentUtilizationModel(
      timestamp: [timestamp],
      fileId: [fileId],
      typeOfAction: [typeOfAction],
      employeeId: [employeeId],
    );
  }

  // copyWith method - adds new values to the lists
  DocumentUtilizationModel copyWith({
    String? timestamp,
    String? fileId,
    String? typeOfAction,
    String? employeeId,
  }) {
    return DocumentUtilizationModel(
      timestamp: timestamp != null
          ? (List<String>.from(this.timestamp)..add(timestamp))
          : this.timestamp,
      fileId: fileId != null
          ? (List<String>.from(this.fileId)..add(fileId))
          : this.fileId,
      typeOfAction: typeOfAction != null
          ? (List<String>.from(this.typeOfAction)..add(typeOfAction))
          : this.typeOfAction,
      employeeId: employeeId != null
          ? (List<String>.from(this.employeeId)..add(employeeId))
          : this.employeeId,
    );
  }
}

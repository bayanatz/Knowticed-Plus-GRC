import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:knowticed_plus/features/inventory/domain/models/product_model.dart';

class TimestampedValue<T> {
  final T value;
  final int timestamp;

  TimestampedValue({
    required this.value,
    required this.timestamp,
  });

  factory TimestampedValue.fromJson(Map<String, dynamic> json) {
    return TimestampedValue(
      value: json['value'],
      timestamp: json['timestamp'] ?? DateTime.now().millisecondsSinceEpoch,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'value': value,
      'timestamp': timestamp,
    };
  }

  // Helper method to create a new timestamped value
  static TimestampedValue<T> create<T>(T value) {
    return TimestampedValue(
      value: value,
      timestamp: DateTime.now().millisecondsSinceEpoch,
    );
  }
}

class StorageLocation {
  final TimestampedValue<String> id;
  final TimestampedValue<String> storageImage;
  final TimestampedValue<String> name;
  final TimestampedValue<String> country;
  final TimestampedValue<String> stateOrProvince;
  final TimestampedValue<String> city;
  final TimestampedValue<String> postalCode;
  final TimestampedValue<String> branchName;
  final TimestampedValue<String> status;
  final TimestampedValue<String> area;
  final TimestampedValue<String> createdBy;
  final TimestampedValue<DateTime> dateAdded;
  final TimestampedValue<String> locationType;
  final TimestampedValue<String> assignedDepartment;
  final TimestampedValue<String> accessLevel;
  final TimestampedValue<int> storageCapacity;
  final TimestampedValue<String> capacityUnit;
  final TimestampedValue<String> conditionOfStorage;
  final TimestampedValue<String> equipmentAvailable;
  final TimestampedValue<String> additionalNote;
  final TimestampedValue<List<EmployeeEntityModel>> employee;

  StorageLocation({
    required this.id,
    required this.storageImage,
    required this.name,
    required this.country,
    required this.stateOrProvince,
    required this.city,
    required this.postalCode,
    required this.branchName,
    required this.area,
    required this.status,
    required this.createdBy,
    required this.dateAdded,
    required this.locationType,
    required this.assignedDepartment,
    required this.accessLevel,
    required this.storageCapacity,
    required this.capacityUnit,
    required this.conditionOfStorage,
    required this.equipmentAvailable,
    required this.additionalNote,
    required this.employee,
  });

  // Create StorageLocation from JSON
  factory StorageLocation.fromJson(Map<String, dynamic> json) {
    return StorageLocation(
      id: TimestampedValue.fromJson(json['id'] ??
          {'value': '', 'timestamp': DateTime.now().millisecondsSinceEpoch}),
      storageImage: TimestampedValue.fromJson(json['storageImage'] ??
          {'value': '', 'timestamp': DateTime.now().millisecondsSinceEpoch}),
      name: TimestampedValue.fromJson(json['name'] ??
          {'value': '', 'timestamp': DateTime.now().millisecondsSinceEpoch}),
      country: TimestampedValue.fromJson(json['country'] ??
          {'value': '', 'timestamp': DateTime.now().millisecondsSinceEpoch}),
      stateOrProvince: TimestampedValue.fromJson(json['stateOrProvince'] ??
          {'value': '', 'timestamp': DateTime.now().millisecondsSinceEpoch}),
      city: TimestampedValue.fromJson(json['city'] ??
          {'value': '', 'timestamp': DateTime.now().millisecondsSinceEpoch}),
      postalCode: TimestampedValue.fromJson(json['postalCode'] ??
          {'value': '', 'timestamp': DateTime.now().millisecondsSinceEpoch}),
      branchName: TimestampedValue.fromJson(json['branchName'] ??
          {'value': '', 'timestamp': DateTime.now().millisecondsSinceEpoch}),
      status: TimestampedValue.fromJson(json['status'] ??
          {'value': '', 'timestamp': DateTime.now().millisecondsSinceEpoch}),
      area: TimestampedValue.fromJson(json['area'] ??
          {'value': '', 'timestamp': DateTime.now().millisecondsSinceEpoch}),
      createdBy: TimestampedValue.fromJson(json['createdBy'] ??
          {'value': '', 'timestamp': DateTime.now().millisecondsSinceEpoch}),
      dateAdded: _parseDateAddedFromJson(json['dateAdded']),
      locationType: TimestampedValue.fromJson(json['locationType'] ??
          {'value': '', 'timestamp': DateTime.now().millisecondsSinceEpoch}),
      assignedDepartment: TimestampedValue.fromJson(
          json['assignedDepartment'] ??
              {
                'value': '',
                'timestamp': DateTime.now().millisecondsSinceEpoch
              }),
      accessLevel: TimestampedValue.fromJson(json['accessLevel'] ??
          {'value': '', 'timestamp': DateTime.now().millisecondsSinceEpoch}),
      storageCapacity: TimestampedValue.fromJson(json['storageCapacity'] ??
          {'value': 0, 'timestamp': DateTime.now().millisecondsSinceEpoch}),
      capacityUnit: TimestampedValue.fromJson(json['capacityUnit'] ??
          {'value': '', 'timestamp': DateTime.now().millisecondsSinceEpoch}),
      conditionOfStorage: TimestampedValue.fromJson(
          json['conditionOfStorage'] ??
              {
                'value': '',
                'timestamp': DateTime.now().millisecondsSinceEpoch
              }),
      equipmentAvailable: TimestampedValue.fromJson(
          json['equipmentAvailable'] ??
              {
                'value': '',
                'timestamp': DateTime.now().millisecondsSinceEpoch
              }),
      additionalNote: TimestampedValue.fromJson(json['additionalNote'] ??
          {'value': '', 'timestamp': DateTime.now().millisecondsSinceEpoch}),
      employee: _parseEmployeeFromJson(json['employee']),
    );
  }

  // Helper method to parse dateAdded with proper timestamp handling
  static TimestampedValue<DateTime> _parseDateAddedFromJson(
      dynamic dateAddedJson) {
    if (dateAddedJson is Map<String, dynamic>) {
      // Already in timestamped format
      dynamic value = dateAddedJson['value'];
      DateTime dateValue;

      if (value is Timestamp) {
        dateValue = value.toDate();
      } else if (value is String) {
        dateValue = DateTime.parse(value);
      } else if (value is DateTime) {
        dateValue = value;
      } else {
        dateValue = DateTime.now();
      }

      return TimestampedValue(
        value: dateValue,
        timestamp:
            dateAddedJson['timestamp'] ?? DateTime.now().millisecondsSinceEpoch,
      );
    } else {
      // Legacy format - convert to timestamped
      DateTime dateValue;
      if (dateAddedJson is Timestamp) {
        dateValue = dateAddedJson.toDate();
      } else if (dateAddedJson is String) {
        dateValue = DateTime.parse(dateAddedJson);
      } else if (dateAddedJson is DateTime) {
        dateValue = dateAddedJson;
      } else {
        dateValue = DateTime.now();
      }

      return TimestampedValue.create(dateValue);
    }
  }

  // Helper method to parse employee list with proper timestamp handling
  static TimestampedValue<List<EmployeeEntityModel>> _parseEmployeeFromJson(
      dynamic employeeJson) {
    if (employeeJson is Map<String, dynamic>) {
      // Already in timestamped format
      List<EmployeeEntityModel> employeeList = [];

      if (employeeJson['value'] is List) {
        employeeList = (employeeJson['value'] as List)
            .map((item) => EmployeeEntityModel.fromJson(item))
            .toList();
      }

      return TimestampedValue(
        value: employeeList,
        timestamp:
            employeeJson['timestamp'] ?? DateTime.now().millisecondsSinceEpoch,
      );
    } else {
      // Legacy format - convert to timestamped
      List<EmployeeEntityModel> employeeList = [];

      if (employeeJson is List) {
        employeeList = employeeJson
            .map((item) => EmployeeEntityModel.fromJson(item))
            .toList();
      }

      return TimestampedValue.create(employeeList);
    }
  }

  // Convert StorageLocation to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id.toJson(),
      'name': name.toJson(),
      'storageImage': storageImage.toJson(),
      'country': country.toJson(),
      'stateOrProvince': stateOrProvince.toJson(),
      'city': city.toJson(),
      'postalCode': postalCode.toJson(),
      'branchName': branchName.toJson(),
      'area': area.toJson(),
      'status': status.toJson(),
      'createdBy': createdBy.toJson(),
      'dateAdded': {
        'value': Timestamp.fromDate(
            dateAdded.value), // Convert DateTime to Firestore Timestamp
        'timestamp': dateAdded.timestamp,
      },
      'locationType': locationType.toJson(),
      'assignedDepartment': assignedDepartment.toJson(),
      'accessLevel': accessLevel.toJson(),
      'storageCapacity': storageCapacity.toJson(),
      'capacityUnit': capacityUnit.toJson(),
      'conditionOfStorage': conditionOfStorage.toJson(),
      'equipmentAvailable': equipmentAvailable.toJson(),
      'additionalNote': additionalNote.toJson(),
      'employee': {
        'value': employee.value.map((emp) => emp.toJson()).toList(),
        'timestamp': employee.timestamp,
      },
    };
  }

  // Helper method to get Firestore-compatible JSON (for saving to Firestore)
  Map<String, dynamic> toFirestoreJson() {
    return {
      'id': id.toJson(),
      'name': name.toJson(),
      'storageImage': storageImage.toJson(),
      'country': country.toJson(),
      'stateOrProvince': stateOrProvince.toJson(),
      'city': city.toJson(),
      'postalCode': postalCode.toJson(),
      'branchName': branchName.toJson(),
      'area': area.toJson(),
      'status': status.toJson(),
      'createdBy': createdBy.toJson(),
      'dateAdded': {
        'value': Timestamp.fromDate(dateAdded.value),
        'timestamp': dateAdded.timestamp,
      },
      'assignedDepartment': assignedDepartment.toJson(),
      'locationType': locationType.toJson(),
      'accessLevel': accessLevel.toJson(),
      'storageCapacity': storageCapacity.toJson(),
      'capacityUnit': capacityUnit.toJson(),
      'conditionOfStorage': conditionOfStorage.toJson(),
      'equipmentAvailable': equipmentAvailable.toJson(),
      'additionalNote': additionalNote.toJson(),
      'employee': {
        'value': employee.value.map((emp) => emp.toJson()).toList(),
        'timestamp': employee.timestamp,
      },
    };
  }

  // Helper method to create a copy with updated values while preserving other timestamps
  StorageLocation copyWith({
    TimestampedValue<String>? id,
    TimestampedValue<String>? storageImage,
    TimestampedValue<String>? name,
    TimestampedValue<String>? country,
    TimestampedValue<String>? stateOrProvince,
    TimestampedValue<String>? city,
    TimestampedValue<String>? postalCode,
    TimestampedValue<String>? branchName,
    TimestampedValue<String>? area,
    TimestampedValue<String>? status,
    TimestampedValue<String>? createdBy,
    TimestampedValue<DateTime>? dateAdded,
    TimestampedValue<String>? locationType,
    TimestampedValue<String>? assignedDepartment,
    TimestampedValue<String>? accessLevel,
    TimestampedValue<int>? storageCapacity,
    TimestampedValue<String>? capacityUnit,
    TimestampedValue<String>? conditionOfStorage,
    TimestampedValue<String>? equipmentAvailable,
    TimestampedValue<String>? additionalNote,
    TimestampedValue<List<EmployeeEntityModel>>? employee,
  }) {
    return StorageLocation(
      id: id ?? this.id,
      storageImage: name ?? this.storageImage,
      name: name ?? this.name,
      country: country ?? this.country,
      stateOrProvince: stateOrProvince ?? this.stateOrProvince,
      city: city ?? this.city,
      postalCode: postalCode ?? this.postalCode,
      branchName: branchName ?? this.branchName,
      area: area ?? this.area,
      status: status ?? this.status,
      createdBy: createdBy ?? this.createdBy,
      dateAdded: dateAdded ?? this.dateAdded,
      assignedDepartment: assignedDepartment ?? this.assignedDepartment,
      locationType: locationType ?? this.locationType,
      accessLevel: accessLevel ?? this.accessLevel,
      storageCapacity: storageCapacity ?? this.storageCapacity,
      capacityUnit: capacityUnit ?? this.capacityUnit,
      conditionOfStorage: conditionOfStorage ?? this.conditionOfStorage,
      equipmentAvailable: equipmentAvailable ?? this.equipmentAvailable,
      additionalNote: additionalNote ?? this.additionalNote,
      employee: employee ?? this.employee,
    );
  }
}

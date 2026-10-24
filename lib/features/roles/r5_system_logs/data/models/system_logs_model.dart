/// Module: roles / r5_system_logs / data / models
///
///*********************** FILE INFO ********************///
/// FILE NAME: system_logs_model.dart
/// Purpose: to have the model of the system logs.
/// Author: Amr Mesbah
/// Created At: 29/1/2025
library;

import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:knowticed_plus/core/helper/access/modules_enum.dart';
import 'package:knowticed_plus/core/helper/format_title.dart';

class SystemLogsModel {
  final String? userEmail;
  final String? firstName;
  final String? middleName;
  final String? lastName;
  final String? firstNameInArabic;
  final String? middleNameInArabic;
  final String? lastNameInArabic;
  final String? country;
  final String? city;
  final String? role;
  final String? lat;
  final String? long;
  final String? action;
  final Modules? module;
  final Timestamp? timestamp;

  static const String kUserEmail = 'User_Email';
  static const String kFirstName = 'First_Name';
  static const String kMiddleName = 'Middle_Name';
  static const String kLastName = 'Last_Name';
  static const String kFirstNameArabic = 'First_Name_Arabic';
  static const String kMiddleNameArabic = 'Middle_Name_Arabic';
  static const String kLastNameArabic = 'Last_Name_Arabic';
  static const String kCountry = 'Country';
  static const String kCity = 'City';
  static const String kRole = 'Role';
  static const String kLat = 'Lat';
  static const String kLong = 'Long';
  static const String kAction = 'Action';
  static const String kTimestamp = 'Timestamp';
  static const String kModule = 'Module';
  const SystemLogsModel(
      {this.userEmail,
      this.firstName,
      this.middleName,
      this.lastName,
      this.country,
      this.firstNameInArabic,
      this.middleNameInArabic,
      this.lastNameInArabic,
      this.city,
      this.role,
      this.lat,
      this.long,
      this.action,
      this.timestamp,
      this.module});

  /// Was a generative named constructor that assigned to each field in its
  /// body. The fields are `final` now (§10), so this is a factory that builds
  /// the instance in one shot — same parsing, same output.
  factory SystemLogsModel.fromMap(dynamic json) {
    return SystemLogsModel(
      userEmail: FormatHelper.capitalize(json[kUserEmail]),
      firstName: FormatHelper.capitalize(json[kFirstName]),
      middleName: FormatHelper.capitalize(json[kMiddleName]),
      lastName: FormatHelper.capitalize(json[kLastName]),
      firstNameInArabic: json[kFirstNameArabic],
      middleNameInArabic: json[kMiddleNameArabic],
      lastNameInArabic: json[kLastNameArabic],
      country: FormatHelper.capitalize(json[kCountry]),
      city: FormatHelper.capitalize(json[kCity]),
      role: FormatHelper.capitalize(json[kRole]),
      lat: json[kLat],
      long: json[kLong],
      action: FormatHelper.capitalize(json[kAction]),
      timestamp: json[kTimestamp],
      module: json[kModule] != null
          ? Modules.values.firstWhere((e) => e.name == json[kModule])
          : null,
    );
  }

  /// When the log was recorded, as a plain [DateTime].
  ///
  /// Added so `SystemLogsController` can sort without importing
  /// `cloud_firestore` — the Firestore `Timestamp` type stays inside `data/`
  /// (§3 layer boundary).
  DateTime? get loggedAt => timestamp?.toDate();

  /// Function Name: [copyWith]
  ///
  /// Purpose: Produce a modified copy — the model is immutable (§10).
  ///
  /// Returns: [SystemLogsModel]
  SystemLogsModel copyWith({
    String? userEmail,
    String? firstName,
    String? middleName,
    String? lastName,
    String? firstNameInArabic,
    String? middleNameInArabic,
    String? lastNameInArabic,
    String? country,
    String? city,
    String? role,
    String? lat,
    String? long,
    String? action,
    Modules? module,
    Timestamp? timestamp,
  }) {
    return SystemLogsModel(
      userEmail: userEmail ?? this.userEmail,
      firstName: firstName ?? this.firstName,
      middleName: middleName ?? this.middleName,
      lastName: lastName ?? this.lastName,
      firstNameInArabic: firstNameInArabic ?? this.firstNameInArabic,
      middleNameInArabic: middleNameInArabic ?? this.middleNameInArabic,
      lastNameInArabic: lastNameInArabic ?? this.lastNameInArabic,
      country: country ?? this.country,
      city: city ?? this.city,
      role: role ?? this.role,
      lat: lat ?? this.lat,
      long: long ?? this.long,
      action: action ?? this.action,
      module: module ?? this.module,
      timestamp: timestamp ?? this.timestamp,
    );
  }

  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{};

    map[kUserEmail] = userEmail;
    map[kFirstName] = firstName;
    map[kMiddleName] = middleName;
    map[kLastName] = lastName;
    map[kFirstNameArabic] = firstNameInArabic;
    map[kMiddleNameArabic] = middleNameInArabic;
    map[kLastNameArabic] = lastNameInArabic;
    map[kCountry] = country;
    map[kCity] = city;
    map[kRole] = role;
    map[kLat] = lat;
    map[kLong] = long;
    map[kAction] = action;
    map[kTimestamp] = timestamp;
    map[kModule] = module?.name;

    return map;
  }
}

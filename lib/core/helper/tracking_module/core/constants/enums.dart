// Date: 29/9/2024
// By: Youssef Ashraf, Nada Mohammed, Mohammed Ashraf
// Last update: 29/9/2024

import 'dart:ui';



import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:demo_app/core/theme/app_colors.dart';

enum RequiredOptionalStatus {
  required,
  optional,
}

extension RequiredOptionalStatusExtension on RequiredOptionalStatus {
  String get getName {
    switch (this) {
      case RequiredOptionalStatus.required:
        return 'required';
      case RequiredOptionalStatus.optional:
        return 'optional';
    }
  }
}

List<RequiredOptionalStatus> requiredOptionalStatusList = [
  RequiredOptionalStatus.required,
  RequiredOptionalStatus.optional,
];

enum TimeFilter {
  day,
  week,
  month,
  year,
  custom,
}

extension GetName on TimeFilter {
  String get getName {
    switch (this) {
      case TimeFilter.day:
        return 'Day';
      case TimeFilter.week:
        return 'Week';
      case TimeFilter.month:
        return 'Month';
      case TimeFilter.year:
        return 'Year';
      case TimeFilter.custom:
        return 'Custom';
    }
  }
}

enum AverageFilter {
  min,
  max,
}

extension AverageFilterExtension on AverageFilter {
  String get getName {
    switch (this) {
      case AverageFilter.min:
        return 'Min';
      case AverageFilter.max:
        return 'Max';
    }
  }
}

enum UserPosition {
  hr,
  manager,
  employee,
}

extension PositionExtension on UserPosition {
  String get name {
    switch (this) {
      case UserPosition.hr:
        return 'HR';
      case UserPosition.manager:
        return 'Manager';
      case UserPosition.employee:
        return 'Employee';
    }
  }
}

enum DepartmentFilter {
  employee,
  manager,
  hr,
}

extension DepartmentFilterExtension on DepartmentFilter {
  String get getName {
    switch (this) {
      case DepartmentFilter.employee:
        return 'Software';
      case DepartmentFilter.manager:
        return 'Marketing';
      case DepartmentFilter.hr:
        return 'HR';
    }
  }
}

String capitalize(String input) {
  if (input.isEmpty) {
    return "";
  }

  List<String> words = input.split(" ");
  words = words.map((word) {
    if (word.isNotEmpty) {
      return word[0].toUpperCase() + word.substring(1).toLowerCase();
    } else {
      return "";
    }
  }).toList();

  return words.join(" ");
}

enum AttendanceStatus {
  absent,
  present,
  late,
  excused,
}

extension GetColor on AttendanceStatus {
  Color get getColor {
    switch (this) {
      case AttendanceStatus.absent:
        return AppColors.red;
      case AttendanceStatus.present:
        return AppColors.green;
      case AttendanceStatus.late:
        return AppColors.white;
      case AttendanceStatus.excused:
        return AppColors.darkGrey;
    }
  }
}

extension GetAttendanceName on AttendanceStatus {
  String get getName {
    switch (this) {
      case AttendanceStatus.absent:
        return 'Absent';
      case AttendanceStatus.present:
        return 'Present';
      case AttendanceStatus.late:
        return 'Late';
      case AttendanceStatus.excused:
        return 'Excused';
    }
  }
}

enum SortFilter {
  totalTime,
  date,
}

extension SortFilterExtension on SortFilter {
  String get getName {
    switch (this) {
      case SortFilter.totalTime:
        return 'Total Time';
      case SortFilter.date:
        return 'Date';
    }
  }
}

// list for all the sort filters names
List<String> sortFilterListStrings = [
  SortFilter.totalTime.getName,
  SortFilter.date.getName,
];

enum RequestStatus {
  pending,
  approved,
  rejected,
}

extension GetNameColor on RequestStatus {
  Color get getColor {
    switch (this) {
      case RequestStatus.approved:
        return AppColors.green;
      case RequestStatus.pending:
        return AppColors.grey;
      case RequestStatus.rejected:
        return AppColors.red;
    }
  }
}

extension GetStatusName on RequestStatus {
  String get getName {
    switch (this) {
      case RequestStatus.approved:
        return 'Approved';
      case RequestStatus.pending:
        return 'Pending';
      case RequestStatus.rejected:
        return 'Rejected';
    }
  }
}

enum LocationAccuracy2 {
  low,
  medium,
  high,
}

enum AllowPeriodTime {
  mins,
  hours,
}

extension GetAllowPeriodTimeName on AllowPeriodTime {
  String get getName {
    switch (this) {
      case AllowPeriodTime.mins:
        return 'Mins';
      case AllowPeriodTime.hours:
        return 'Hrs';
    }
  }
}

extension GeLocationAccuracyName on LocationAccuracy2 {
  String get getName {
    switch (this) {
      case LocationAccuracy2.medium:
        return 'medium';
      case LocationAccuracy2.high:
        return 'high';
      case LocationAccuracy2.low:
        return 'low';
    }
  }
}

List<String> locationAccuracyList = [
  LocationAccuracy2.low.getName.tr,
  LocationAccuracy2.medium.getName.tr,
  LocationAccuracy2.high.getName.tr,
];

List<String> locationAllowPeriodTimeList = [
  AllowPeriodTime.mins.getName.tr,
  AllowPeriodTime.hours.getName.tr,
];

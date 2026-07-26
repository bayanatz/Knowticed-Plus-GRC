/// Module: GRC Request Management
/// Description: Firestore model for a GRC approval request. Unlike
///              ChampionModel/PolicyModel, this is NOT a history list — a
///              request is a single decided event (create, then optionally
///              approve/reject once), so its status/decision fields are
///              plain mutable values, not append-only revision lists.
///              Firestore path: GRC Modules/{Module_ID}/Champion Requests/{Request_ID}.
/// Author: Mohamed Magdy Abdelkhalek
/// Date: 2026-07-25
/// Dependencies: AssigningControlModel, GrcRequestEntity, GrcRequestType, ApprovalStatus, intl

import 'package:intl/intl.dart';
import 'package:demo_app/core/enums/approval_status.dart';
import 'package:demo_app/features/grc/control/data/models/assigning_control_model.dart';
import 'package:demo_app/features/grc/grc_request/domain/entities/grc_request_entity.dart';
import 'package:demo_app/features/grc/grc_request/domain/entities/grc_request_type.dart';

final DateFormat _requestDateFormat = DateFormat('d MMM yyyy', 'en');

class GrcRequestModel {
  final String id;
  final String moduleId;
  final String type; // GrcRequestType.value
  final String status; // 'pending' | 'approved' | 'rejected'
  final String requestedBy;
  final DateTime requestDate;
  final String note;

  final String? rejectionReason;
  final String? decidedBy;
  final DateTime? decisionDate;

  final String? currentChampionEmail;
  final String? newChampionEmail;
  final String? currentOwnerEmail;
  final String? newOwnerEmail;
  final List<AssigningControlModel>? controls;
  final DateTime? startDate;
  final DateTime? endDate;

  final DateTime? appliedAt;

  const GrcRequestModel({
    required this.id,
    required this.moduleId,
    required this.type,
    required this.status,
    required this.requestedBy,
    required this.requestDate,
    required this.note,
    this.rejectionReason,
    this.decidedBy,
    this.decisionDate,
    this.currentChampionEmail,
    this.newChampionEmail,
    this.currentOwnerEmail,
    this.newOwnerEmail,
    this.controls,
    this.startDate,
    this.endDate,
    this.appliedAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'Request_ID': id,
      'Module_ID': moduleId,
      'Type': type,
      'Status': status,
      'Requested_By': requestedBy,
      'Request_Date': _requestDateFormat.format(requestDate),
      'Note': note,
      'Rejection_Reason': rejectionReason,
      'Decided_By': decidedBy,
      'Decision_Date':
          decisionDate != null ? _requestDateFormat.format(decisionDate!) : null,
      'Current_Champion_Email': currentChampionEmail,
      'New_Champion_Email': newChampionEmail,
      'Current_Owner_Email': currentOwnerEmail,
      'New_Owner_Email': newOwnerEmail,
      'Controls': controls?.map((c) => c.toJson()).toList(),
      'Start_Date': startDate != null ? _requestDateFormat.format(startDate!) : null,
      'End_Date': endDate != null ? _requestDateFormat.format(endDate!) : null,
      'Applied_At': appliedAt != null ? _requestDateFormat.format(appliedAt!) : null,
    };
  }

  factory GrcRequestModel.fromJson(Map<String, dynamic> json) {
    final decisionDateRaw = json['Decision_Date'] as String?;
    final startDateRaw = json['Start_Date'] as String?;
    final endDateRaw = json['End_Date'] as String?;
    final appliedAtRaw = json['Applied_At'] as String?;
    return GrcRequestModel(
      id: json['Request_ID'] as String,
      moduleId: json['Module_ID'] as String,
      type: json['Type'] as String,
      status: json['Status'] as String,
      requestedBy: json['Requested_By'] as String,
      requestDate: _requestDateFormat.parse(json['Request_Date'] as String),
      note: json['Note'] as String? ?? '',
      rejectionReason: json['Rejection_Reason'] as String?,
      decidedBy: json['Decided_By'] as String?,
      decisionDate:
          decisionDateRaw != null ? _requestDateFormat.parse(decisionDateRaw) : null,
      currentChampionEmail: json['Current_Champion_Email'] as String?,
      newChampionEmail: json['New_Champion_Email'] as String?,
      currentOwnerEmail: json['Current_Owner_Email'] as String?,
      newOwnerEmail: json['New_Owner_Email'] as String?,
      controls: (json['Controls'] as List?)
          ?.map((c) => AssigningControlModel.fromJson(c as Map<String, dynamic>))
          .toList(),
      startDate: startDateRaw != null ? _requestDateFormat.parse(startDateRaw) : null,
      endDate: endDateRaw != null ? _requestDateFormat.parse(endDateRaw) : null,
      appliedAt: appliedAtRaw != null ? _requestDateFormat.parse(appliedAtRaw) : null,
    );
  }

  GrcRequestEntity toEntity() {
    return GrcRequestEntity(
      id: id,
      moduleId: moduleId,
      type: GrcRequestType.fromString(type),
      status: ApprovalStatus.values.firstWhere(
        (s) => s.name == status,
        orElse: () => ApprovalStatus.pending,
      ),
      requestedBy: requestedBy,
      requestDate: requestDate,
      note: note,
      rejectionReason: rejectionReason,
      decidedBy: decidedBy,
      decisionDate: decisionDate,
      currentChampionEmail: currentChampionEmail,
      newChampionEmail: newChampionEmail,
      currentOwnerEmail: currentOwnerEmail,
      newOwnerEmail: newOwnerEmail,
      controls: controls?.map((c) => c.toEntity()).toList(),
      startDate: startDate,
      endDate: endDate,
      appliedAt: appliedAt,
    );
  }
}

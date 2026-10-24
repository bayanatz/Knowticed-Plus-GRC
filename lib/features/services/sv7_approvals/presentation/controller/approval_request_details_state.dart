/// Module: services / sv7_approvals / presentation / controller
///
///*************************** FILE INFO ****************************///
/// File Name: approval_request_details_state.dart
/// Purpose: State of the approval details page: the request's saved status
///          and comments, the requester (from the request) and the parent
///          service's details.
/// Author: Amr Mesbah
/// Created at: 02/07/2026
library;

import 'package:equatable/equatable.dart';

class ApprovalRequestDetailsData extends Equatable {
  final String? currentState;
  final String? cancelReason;
  final String rejectCommentText;
  final String approveCommentText;
  final String saveIdUser;

  final String? serviceNameEnglish;
  final String? serviceNameArabic;
  final String? serviceDescriptionEnglish;
  final String? serviceDescriptionArabic;
  final String? serviceDuration;
  final String? serviceDurationUnit;
  final String? owningDepartment;

  final String? requesterFirstNameEn;
  final String? requesterLastNameEn;
  final String? requesterJobTitleEn;
  final String? requesterDepartment;
  final String? requesterFirstNameAr;
  final String? requesterLastNameAr;
  final String? requesterJobTitleAr;

  const ApprovalRequestDetailsData({
    this.currentState,
    this.cancelReason,
    this.rejectCommentText = '',
    this.approveCommentText = '',
    this.saveIdUser = '',
    this.serviceNameEnglish,
    this.serviceNameArabic,
    this.serviceDescriptionEnglish,
    this.serviceDescriptionArabic,
    this.serviceDuration,
    this.serviceDurationUnit,
    this.owningDepartment,
    this.requesterFirstNameEn,
    this.requesterLastNameEn,
    this.requesterJobTitleEn,
    this.requesterDepartment,
    this.requesterFirstNameAr,
    this.requesterLastNameAr,
    this.requesterJobTitleAr,
  });

  ApprovalRequestDetailsData copyWith({
    String? currentState,
    String? cancelReason,
    String? rejectCommentText,
    String? approveCommentText,
    String? saveIdUser,
    String? serviceNameEnglish,
    String? serviceNameArabic,
    String? serviceDescriptionEnglish,
    String? serviceDescriptionArabic,
    String? serviceDuration,
    String? serviceDurationUnit,
    String? owningDepartment,
    String? requesterFirstNameEn,
    String? requesterLastNameEn,
    String? requesterJobTitleEn,
    String? requesterDepartment,
    String? requesterFirstNameAr,
    String? requesterLastNameAr,
    String? requesterJobTitleAr,
  }) {
    return ApprovalRequestDetailsData(
      currentState: currentState ?? this.currentState,
      cancelReason: cancelReason ?? this.cancelReason,
      rejectCommentText: rejectCommentText ?? this.rejectCommentText,
      approveCommentText: approveCommentText ?? this.approveCommentText,
      saveIdUser: saveIdUser ?? this.saveIdUser,
      serviceNameEnglish: serviceNameEnglish ?? this.serviceNameEnglish,
      serviceNameArabic: serviceNameArabic ?? this.serviceNameArabic,
      serviceDescriptionEnglish:
          serviceDescriptionEnglish ?? this.serviceDescriptionEnglish,
      serviceDescriptionArabic:
          serviceDescriptionArabic ?? this.serviceDescriptionArabic,
      serviceDuration: serviceDuration ?? this.serviceDuration,
      serviceDurationUnit: serviceDurationUnit ?? this.serviceDurationUnit,
      owningDepartment: owningDepartment ?? this.owningDepartment,
      requesterFirstNameEn: requesterFirstNameEn ?? this.requesterFirstNameEn,
      requesterLastNameEn: requesterLastNameEn ?? this.requesterLastNameEn,
      requesterJobTitleEn: requesterJobTitleEn ?? this.requesterJobTitleEn,
      requesterDepartment: requesterDepartment ?? this.requesterDepartment,
      requesterFirstNameAr: requesterFirstNameAr ?? this.requesterFirstNameAr,
      requesterLastNameAr: requesterLastNameAr ?? this.requesterLastNameAr,
      requesterJobTitleAr: requesterJobTitleAr ?? this.requesterJobTitleAr,
    );
  }

  @override
  List<Object?> get props => [
        currentState,
        cancelReason,
        rejectCommentText,
        approveCommentText,
        saveIdUser,
        serviceNameEnglish,
        serviceNameArabic,
        serviceDescriptionEnglish,
        serviceDescriptionArabic,
        serviceDuration,
        serviceDurationUnit,
        owningDepartment,
        requesterFirstNameEn,
        requesterLastNameEn,
        requesterJobTitleEn,
        requesterDepartment,
        requesterFirstNameAr,
        requesterLastNameAr,
        requesterJobTitleAr,
      ];
}

abstract class ApprovalRequestDetailsState extends Equatable {
  const ApprovalRequestDetailsState();

  /// The page data, whatever the state.
  ApprovalRequestDetailsData get data => const ApprovalRequestDetailsData();

  @override
  List<Object?> get props => [];
}

class ApprovalRequestDetailsLoading extends ApprovalRequestDetailsState {
  const ApprovalRequestDetailsLoading();
}

class ApprovalRequestDetailsLoaded extends ApprovalRequestDetailsState {
  @override
  final ApprovalRequestDetailsData data;

  const ApprovalRequestDetailsLoaded(this.data);

  @override
  List<Object?> get props => [data];
}

/// Emitted while an approve/reject mutation is in flight — carries the last
/// loaded data so the UI doesn't flicker back to a loading state.
class ApprovalRequestDetailsSubmitting extends ApprovalRequestDetailsState {
  @override
  final ApprovalRequestDetailsData data;

  const ApprovalRequestDetailsSubmitting(this.data);

  @override
  List<Object?> get props => [data];
}

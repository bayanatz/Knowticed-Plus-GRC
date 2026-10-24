/// Module: services / sv6_services_requests / presentation / controller
///
///*************************** FILE INFO ****************************///
/// File Name: my_request_details_state.dart
/// Purpose: State of the "My request" details page: the request's saved
///          status and comments, the parent service's details (both
///          languages) and the resolved provider.
/// Author: Amr Mesbah
/// Created at: 02/07/2026
library;

import 'package:equatable/equatable.dart';
import 'package:knowticed_plus/features/services/data/models/service_employee_model.dart';

class MyRequestDetailsData extends Equatable {
  final String? currentState;
  final String? cancelReason;
  final String rejectCommentText;
  final String approveCommentText;

  final String serviceNameEnglish;
  final String serviceNameArabic;
  final String descriptionEnglish;
  final String descriptionArabic;
  final String duration;
  final String durationUnit;
  final bool isLoadingServiceDetails;

  /// The request's provider; null while loading or when there is none.
  final ServiceEmployeeModel? provider;
  final bool isLoadingProvider;

  const MyRequestDetailsData({
    this.currentState,
    this.cancelReason,
    this.rejectCommentText = '',
    this.approveCommentText = '',
    this.serviceNameEnglish = '',
    this.serviceNameArabic = '',
    this.descriptionEnglish = '',
    this.descriptionArabic = '',
    this.duration = '',
    this.durationUnit = '',
    this.isLoadingServiceDetails = true,
    this.provider,
    this.isLoadingProvider = true,
  });

  MyRequestDetailsData copyWith({
    String? currentState,
    String? cancelReason,
    String? rejectCommentText,
    String? approveCommentText,
    String? serviceNameEnglish,
    String? serviceNameArabic,
    String? descriptionEnglish,
    String? descriptionArabic,
    String? duration,
    String? durationUnit,
    bool? isLoadingServiceDetails,
    ServiceEmployeeModel? provider,
    bool? isLoadingProvider,
  }) {
    return MyRequestDetailsData(
      currentState: currentState ?? this.currentState,
      cancelReason: cancelReason ?? this.cancelReason,
      rejectCommentText: rejectCommentText ?? this.rejectCommentText,
      approveCommentText: approveCommentText ?? this.approveCommentText,
      serviceNameEnglish: serviceNameEnglish ?? this.serviceNameEnglish,
      serviceNameArabic: serviceNameArabic ?? this.serviceNameArabic,
      descriptionEnglish: descriptionEnglish ?? this.descriptionEnglish,
      descriptionArabic: descriptionArabic ?? this.descriptionArabic,
      duration: duration ?? this.duration,
      durationUnit: durationUnit ?? this.durationUnit,
      isLoadingServiceDetails:
          isLoadingServiceDetails ?? this.isLoadingServiceDetails,
      provider: provider ?? this.provider,
      isLoadingProvider: isLoadingProvider ?? this.isLoadingProvider,
    );
  }

  @override
  List<Object?> get props => [
        currentState,
        cancelReason,
        rejectCommentText,
        approveCommentText,
        serviceNameEnglish,
        serviceNameArabic,
        descriptionEnglish,
        descriptionArabic,
        duration,
        durationUnit,
        isLoadingServiceDetails,
        provider,
        isLoadingProvider,
      ];
}

abstract class MyRequestDetailsState extends Equatable {
  const MyRequestDetailsState();

  /// The page data, whatever the state.
  MyRequestDetailsData get data => const MyRequestDetailsData();

  @override
  List<Object?> get props => [];
}

class MyRequestDetailsLoading extends MyRequestDetailsState {
  const MyRequestDetailsLoading();
}

class MyRequestDetailsLoaded extends MyRequestDetailsState {
  @override
  final MyRequestDetailsData data;

  const MyRequestDetailsLoaded(this.data);

  @override
  List<Object?> get props => [data];
}

class MyRequestDetailsCancelling extends MyRequestDetailsState {
  @override
  final MyRequestDetailsData data;

  const MyRequestDetailsCancelling(this.data);

  @override
  List<Object?> get props => [data];
}

/// The cancellation was not saved; the page shows the translated error.
class MyRequestDetailsCancelError extends MyRequestDetailsState {
  @override
  final MyRequestDetailsData data;

  const MyRequestDetailsCancelError(this.data);

  @override
  List<Object?> get props => [data];
}

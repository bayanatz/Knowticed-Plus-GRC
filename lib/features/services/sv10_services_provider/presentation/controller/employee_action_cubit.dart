/// Module: services / sv10_services_provider / presentation / controller
///
///*************************** FILE INFO ****************************///
/// File Name: employee_action_cubit.dart
/// Purpose: A provider's status change on the request page (approved → in
///          progress → done): saves it through the repository and tells the
///          requester, in the requester's language, through the shared
///          ServicesNotificationService.
/// Author: Knowticed Team
/// Created At: 02/07/2026
/// Revision History:
///   - 18/10/2026: SVC-PROV-06/12/20.
///   - 22/10/2026 (Amr Mesbah): no Firestore here (the transaction is
///     CreateServicesRepository.advanceRequestState); the repository and the
///     notification service are injected (no ServicesManagerCubit, no
///     services created here); unused fetchLatestState removed; the result
///     is a state the page listens to (no try/catch in the page).
library;

import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:knowticed_plus/features/services/data/data_source/remote_data_source/services_notification_service.dart';
import 'package:knowticed_plus/features/services/data/models/services_history_model.dart';
import 'package:knowticed_plus/features/services/data/utils/request_status.dart';
import 'package:knowticed_plus/features/services/domain/base_repository/service_repository.dart';
import 'package:knowticed_plus/features/services/domain/entities/status_change_refused.dart';
import 'package:knowticed_plus/features/services/helpers/services_log.dart';
import 'package:knowticed_plus/features/services/sv10_services_provider/presentation/controller/employee_action_state.dart';

class EmployeeActionCubit extends Cubit<EmployeeActionState> {
  // B5 FIX: guard against emit-after-close (StateError) when the user
  // navigates away mid-await.
  @override
  void emit(EmployeeActionState state) {
    if (isClosed) return;
    super.emit(state);
  }

  final CreateServicesRepository repository;
  final ServicesNotificationService notifications;

  /// The signed-in provider (the notification's sender).
  final String senderEmail;

  EmployeeActionCubit({
    required this.repository,
    required this.notifications,
    required this.senderEmail,
  }) : super(const EmployeeActionIdle());

  /// The requester's language from their user record; English when it
  /// cannot be read (SVC-PROV-20).
  Future<bool> _requesterIsArabic(String requesterEmail) async {
    try {
      final data = await repository.getUserByEmail(requesterEmail);
      return (data?['languageCode'] ?? 'en') == 'ar';
    } catch (e) {
      svcLog('Requester language lookup failed, using English: $e');
      return false;
    }
  }

  /// Function Name: [changeStatus]
  ///
  /// Purpose: Moves [request] to [newState], then notifies the requester.
  /// Emits [EmployeeActionSaved], [EmployeeActionRefused] (not allowed from
  /// the current status) or [EmployeeActionFailed].
  Future<void> changeStatus({
    required ServicesHistoryModel request,
    required String newState,
  }) async {
    emit(const EmployeeActionBusy());
    final target = newState.toLowerCase();
    try {
      await repository.advanceRequestState(
        requestId: request.currentId,
        newState: target,
      );
    } on StatusChangeRefused catch (e) {
      svcLog('Status change refused: $e');
      emit(const EmployeeActionRefused());
      return;
    } catch (e) {
      emit(EmployeeActionFailed('Error updating state: $e'));
      return;
    }

    // SVC-PROV-12: the requester's language; a failed send is reported, the
    // status stays saved.
    var notified = true;
    final requesterEmail = request.currentEmailRequester;
    if (requesterEmail.isNotEmpty &&
        (target == RequestStatus.inProgress || target == RequestStatus.done)) {
      final arabic = await _requesterIsArabic(requesterEmail);
      final serviceName = arabic && request.currentServiceNameArabic.isNotEmpty
          ? request.currentServiceNameArabic
          : request.currentServiceNameEnglish;
      try {
        notified = await notifications.notifyRequesterOfProgress(
          requestId: request.currentId,
          isDone: target == RequestStatus.done,
          senderEmail: senderEmail,
          requesterEmail: requesterEmail,
          serviceName: serviceName,
          isArabic: arabic,
        );
      } catch (e) {
        svcLog('Status notification to $requesterEmail failed: $e');
        notified = false;
      }
    }

    emit(EmployeeActionSaved(newState: target, notificationFailed: !notified));
  }
}

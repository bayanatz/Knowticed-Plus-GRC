part of 'policy_cubit.dart';

/// ************************* FILE INFO *************************** ///
/// File Name: policy_state.dart
/// Purpose: Contains all sealed state classes emitted by [PolicyCubit].
/// Author: Mohamed Magdy Abdelkhalek
/// Created At: 5/7/2026
/// Revision History: 2026-07-14 - Added PolicyActionPartialSuccess
///                   2026-07-28 - Removed PolicyControlActionSuccess/
///                                PolicyControlsListLoaded/
///                                PolicyControlDeleted — moved to
///                                ControlState (ControlCubit extraction)

sealed class PolicyState {}

/// State emitted before any action has been requested.
final class PolicyInitial extends PolicyState {}

/// State emitted while any async operation is in progress.
final class PolicyLoading extends PolicyState {}

/// State emitted when the full list of policies has been loaded successfully.
final class PolicyListLoaded extends PolicyState {
  final List<PolicyEntity> policies;

  PolicyListLoaded(this.policies);
}

/// State emitted when a single policy has been loaded successfully.
final class PolicySingleLoaded extends PolicyState {
  final PolicyEntity policy;

  PolicySingleLoaded(this.policy);
}

/// State emitted when a create / update / delete / restore action completes
/// successfully. [policy] holds the entity that was affected.
final class PolicyActionSuccess extends PolicyState {
  final PolicyEntity policy;

  PolicyActionSuccess(this.policy);
}

/// State emitted when a Policy was created successfully but one or more of
/// its initial Controls failed to be created. The Policy already exists in
/// Firestore at this point (Policy + Controls creation is not
/// transactional), so this is surfaced distinctly from [PolicyActionSuccess]
/// instead of silently dropping the failed controls.
final class PolicyActionPartialSuccess extends PolicyState {
  final PolicyEntity policy;
  final List<({PendingControlInput input, String message})> failedControls;

  PolicyActionPartialSuccess(this.policy, this.failedControls);
}

/// State emitted when any operation fails.
final class PolicyFailure extends PolicyState {
  final String message;

  PolicyFailure(this.message);
}

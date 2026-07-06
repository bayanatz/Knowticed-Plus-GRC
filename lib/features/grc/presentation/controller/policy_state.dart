part of 'policy_cubit.dart';

/// ************************* FILE INFO *************************** ///
/// File Name: policy_state.dart
/// Purpose: Contains all sealed state classes emitted by [PolicyCubit].
/// Author: Mohamed Magdy Abdelkhalek
/// Created At: 5/7/2026

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

/// State emitted when any operation fails.
final class PolicyFailure extends PolicyState {
  final String message;

  PolicyFailure(this.message);
}

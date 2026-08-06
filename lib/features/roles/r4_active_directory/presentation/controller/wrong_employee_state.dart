part of './wrong_employee_cubit.dart';

@immutable
sealed class WrongEmployeeState {}

final class WrongEmployeeInitial extends WrongEmployeeState {}

final class WrongEmployeeLoading extends WrongEmployeeState {}

/// Emitted after the wrong-employee list is (re)loaded or a record is written.
///
/// A fresh instance is created on every emit so Cubit's equality check does not
/// deduplicate consecutive refreshes.
final class WrongEmployeeUpdated extends WrongEmployeeState {}

class WrongEmployeeError extends WrongEmployeeState {
  final String message;
  WrongEmployeeError(this.message);
}

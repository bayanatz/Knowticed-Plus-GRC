/// Module: core
///
///*************************** FILE INFO ****************************///
/// File Name: failure_model.dart
/// Purpose: Declares `Failure`.
/// Author: Knowticed Plus team
/// Updated: 11/8/2026 - Added the standard module + FILE INFO header.
library;

/// Base Failure class for error handling
abstract class Failure {
  final String message;

  /// Backward compatibility getter
  String get errMessage => message;

  const Failure({required this.message});

  @override
  String toString() => message;
}

/// Feature-specific failures (business logic errors)
class FeatureFailure extends Failure {
  const FeatureFailure(String message) : super(message: message);
}

/// Firebase/Database failures
class FirebaseFailure extends Failure {
  const FirebaseFailure(String message) : super(message: message);
}

/// Validation failures (form/input errors)
class ValidationError extends Failure {
  const ValidationError(String message) : super(message: message);
}

/// Network failures (API/connectivity errors)
class NetworkFailure extends Failure {
  const NetworkFailure(String message) : super(message: message);
}

/// Server failures. ADDED 17/10/2026 from Messaging's duplicate Failure
/// file (one Failure type for the whole app).
class ServerFailure extends Failure {
  const ServerFailure(String message) : super(message: message);
}

/// Someone else changed the record after this screen read it, so the write was
/// refused rather than overwrite their change (DB-TABLE-01, DB-DETAILS-04).
class ConflictFailure extends Failure {
  const ConflictFailure(String message) : super(message: message);
}

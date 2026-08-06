// Youssef Ashraf
///abstract class for general Failures
abstract class Failure {
  final String errMessage;

  const Failure(this.errMessage);
}

// Server failure
class ServerFailure extends Failure {
  const ServerFailure(String message) : super(message);
}


// cach, audio etc...
class FeatureFailure extends Failure {
  FeatureFailure(super.errMessage);
}

class FirebaseFailure extends Failure {

  FirebaseFailure(super.errMessage);
}

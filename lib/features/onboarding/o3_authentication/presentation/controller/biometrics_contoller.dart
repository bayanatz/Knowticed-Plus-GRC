import 'package:local_auth/local_auth.dart';

Future<bool> checkBiometrics() async {
  var localAuth = LocalAuthentication();
  try {
    bool canCheckBiometrics = await localAuth.canCheckBiometrics;
    return canCheckBiometrics;
  } catch (e) {
    print("Error checking biometrics: $e");
    return false;
  }
}

Future<bool> authenticate() async {
  var localAuth = LocalAuthentication();
  try {
    bool canCheckBiometrics = await checkBiometrics();
    List<BiometricType> availableBiometrics =
        await localAuth.getAvailableBiometrics();
    if (availableBiometrics.isEmpty || !canCheckBiometrics) {
      return false;
    } else if (availableBiometrics.contains(BiometricType.face)) {
      return await localAuth.authenticate(
        localizedReason: 'Authenticate to access the app',
        options: const AuthenticationOptions(
          useErrorDialogs: true,
          stickyAuth: true,
          biometricOnly: true,
        ),
      );
    } else {
      return await localAuth.authenticate(
        localizedReason: 'Authenticate to access the app',
        options: const AuthenticationOptions(
          useErrorDialogs: true,
          stickyAuth: true,
        ),
      );
    }
  } catch (e) {
    print("Error authenticating with biometrics: $e");
    return false;
  }
}

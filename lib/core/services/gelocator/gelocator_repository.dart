/// **************************** FILE INFO ******************** ///
/// FILE NAME: gelocator_repository.dart
/// Purpose: provide location services to the app.
/// Author: Amr Mesbah
/// Created at: 2/2/2025

import 'package:geolocator/geolocator.dart';

abstract class GelocatorRepository{

  /// Method Name: [getCurrentLocation]
  ///
  /// Description: this method will return the current location of the user.
  ///
  /// Return Value: [Future<[Position]?>] the current location of the user.
 static Future<Position?> getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return null;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return null;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return null;
    }

    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    return position;
  }

}
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

class GoogleMapViewModel {
  // A Completer for the GoogleMapController, which is used to interact with the Google Map widget.
  Completer<GoogleMapController> controller = Completer();

  // A method to load the current user's coordinates as a LatLng object.
  Future<LatLng> loadCurrentUserCoordinates() async {
    try {
      // Check if GPS is enabled before attempting to fetch the location.
      await _checkGpsEnabled();
    } catch (ex) {
      // Handle exceptions related to disabled location services and print debug information.
      debugPrint(ex.toString());
      throw Exception('Location services are disabled.');
    }

    Position? position;
    try {
      // Fetch the user's current location using Geolocator with a timeout.
      position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.best,
        timeLimit: const Duration(seconds: 5),
      );
    } on TimeoutException catch (ex) {
      // Handle timeout exceptions by printing debug information and using the last known position.
      debugPrint(ex.toString());
      position = await Geolocator.getLastKnownPosition();
    }

    if (position == null) {
      // If the position is still null, it indicates a failed location capture.
      throw Exception('Location capture failed. You might need to enable internet.');
    }

    // Return the user's coordinates as a LatLng object.
    return LatLng(position.latitude, position.longitude);
  }

  // A private method to check if GPS is enabled and obtain necessary permissions.
  Future<void> _checkGpsEnabled() async {
    bool serviceEnabled;

    // Test if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Location services are not enabled; prompt the user to enable them.
      final locationOpened = await Geolocator.openLocationSettings();
      serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!locationOpened || !serviceEnabled) {
        throw Exception('Location services are disabled.');
      }
    }

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      // If location permissions are denied, request the user's permission.
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw Exception('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // If permissions are denied forever, prompt the user to open app settings.
      final openPermSettings = await Geolocator.openAppSettings();
      if (!openPermSettings) {
        throw Exception(
          'Location permissions are permanently denied, we cannot request permissions.',
        );
      }
    }

    if (permission == LocationPermission.unableToDetermine) {
      // Handle cases where location permissions are unable to be determined.
      throw Exception('Unable to determine location permissions. Retry a few seconds later.');
    }
  }
}

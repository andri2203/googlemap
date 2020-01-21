import 'dart:async';

import 'package:flutter/services.dart';
import 'package:location/location.dart';
import 'package:mustika_pratiwi/dataModels/user_location.dart';

class LocationServices {
  // Location
  UserLocation _currentLocation;
  Location location = new Location();
  // Subscribe LOcation
  StreamController<UserLocation> _locationController =
      StreamController<UserLocation>.broadcast();

  String error;

  LocationServices() {
    location.requestPermission().then((granted) {
      if (granted) {
        location.onLocationChanged().listen((locationData) {
          if (locationData != null) {
            _locationController.add(UserLocation(
              latitude: locationData.latitude,
              longitude: locationData.longitude,
            ));
          } else {
            _locationController.add(UserLocation(
              latitude: 5.8913102,
              longitude: 95.3223092,
            ));
          }
        });
      }
    });
  }

  Stream<UserLocation> get locationStream => _locationController.stream;

  Future<UserLocation> getLocatoin() async {
    try {
      var userLocation = await location.getLocation();
      _currentLocation = UserLocation(
        latitude: userLocation.latitude,
        longitude: userLocation.longitude,
      );
    } on PlatformException catch (e) {
      if (e.code == 'PERMISSION_DENIED') {
        error = 'Permission denied $e';
      } else if (e.code == 'PERMISSION_DEMIED_NEVER_ASK') {
        error = 'Permission denied - Could not find location $e';
      }
      _currentLocation = null;
    }

    return _currentLocation;
  }
}

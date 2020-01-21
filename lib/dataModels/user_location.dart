import 'package:geolocator/geolocator.dart';

class UserLocation {
  final double latitude;
  final double longitude;

  List<Placemark> placemark;
  String address;

  UserLocation({this.latitude, this.longitude});
}

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:mustika_pratiwi/dataModels/user_location.dart';
import 'package:mustika_pratiwi/main.dart';
import 'package:provider/provider.dart';

class Peta extends StatefulWidget {
  @override
  _PetaState createState() => _PetaState();
}

class _PetaState extends State<Peta> {
  // Google
  Completer<GoogleMapController> _controller = Completer();
  GoogleMapController mapController;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var userLocation = Provider.of<UserLocation>(context);

    return userLocation == null
        ? new Container(
            child: new Center(
              child: new FlatButton(
                child: new Container(
                  child: new Column(
                    children: <Widget>[
                      new Padding(
                        padding: EdgeInsets.only(top: 20.0),
                        child: new CircularProgressIndicator(
                          semanticsLabel:
                              "Anda sebelumnya menonaktifkan GPS. Ketuk layar untuk mendapatkan peta.",
                        ),
                      ),
                    ],
                  ),
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => MyApp(),
                    ),
                  );
                },
              ),
            ),
          )
        : new Container(
            child: new GoogleMap(
              onMapCreated: _onMapCreated,
              mapType: MapType.normal,
              initialCameraPosition: CameraPosition(
                target: LatLng(userLocation.latitude, userLocation.longitude),
                zoom: 14.4746,
              ),
              markers: {
                Marker(
                  markerId: MarkerId(
                      "${userLocation.latitude}, ${userLocation.longitude}"),
                  position:
                      LatLng(userLocation.latitude, userLocation.longitude),
                  icon: BitmapDescriptor.defaultMarker,
                ),
              },
              mapToolbarEnabled: true,
              indoorViewEnabled: true,
              scrollGesturesEnabled: true,
              tiltGesturesEnabled: true,
              rotateGesturesEnabled: true,
              myLocationEnabled: true,
              zoomGesturesEnabled: true,
              trafficEnabled: true,
            ),
          );
  }

  void _onMapCreated(GoogleMapController controller) {
    _controller.complete(controller);
  }
}

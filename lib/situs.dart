import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';

class Situs extends StatefulWidget {
  @override
  _SitusState createState() => _SitusState();
}

class _SitusState extends State<Situs> {
  final String url =
      "https://sejarahsabang.000webhostapp.com/api.php?table=tb_lokasi";
  List data;
  List<Placemark> placemark;

  @override
  void initState() {
    super.initState();
    this.getData();
  }

  Future<String> getData() async {
    var respon = await http.get(
      Uri.encodeFull(url),
      headers: {"Accept": "application/json"},
    );

    setState(() {
      var convertData = json.decode(respon.body);
      data = convertData['result'];
    });

    return "Success";
  }

  void getAddress(BuildContext context, double latitude, double longitude,
      List data, int index) async {
    placemark =
        await Geolocator().placemarkFromCoordinates(latitude, longitude);

    return showDialog(
      context: context,
      builder: (context) {
        return new AlertDialog(
          title: new Text("${data[index]['lokasi']}"),
          content: new Text("${placemark[0].thoroughfare}" +
              ", " +
              "${placemark[0].subLocality}" +
              ", " +
              "${placemark[0].locality}" +
              ", " +
              "${placemark[0].subAdministrativeArea}" +
              ", " +
              "${placemark[0].administrativeArea}" +
              ", " +
              "${placemark[0].country}"),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return data == null
        ? new Container(
            child: new Center(
              child: CircularProgressIndicator(),
            ),
          )
        : new ListView.builder(
            itemCount: data == null ? 0 : data.length,
            itemBuilder: (BuildContext context, int i) {
              return new Container(
                child: new Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    new Card(
                      child: new Container(
                        child: new Column(
                          children: <Widget>[
                            new Padding(
                              padding: const EdgeInsets.all(1.0),
                              child: new FlatButton(
                                child: new Text(
                                  "${data[i]['lokasi']}",
                                  style: TextStyle(
                                    fontSize: 20.0,
                                  ),
                                ),
                                onPressed: () {
                                  getAddress(
                                    context,
                                    double.parse(data[i]['latitude']),
                                    double.parse(data[i]['longitude']),
                                    data,
                                    i,
                                  );
                                },
                              ),
                            ),
                            new Container(
                              padding: EdgeInsets.only(
                                  left: 5.0, top: 0.0, right: 5.0, bottom: 5.0),
                              height: 250,
                              child: new GoogleMap(
                                zoomGesturesEnabled: false,
                                initialCameraPosition: CameraPosition(
                                  target: LatLng(
                                    double.parse(data[i]['latitude']),
                                    double.parse(data[i]['longitude']),
                                  ),
                                  zoom: 16.0,
                                ),
                                markers: {
                                  Marker(
                                      markerId: MarkerId(
                                          "${data[i]['latitude']},${data[i]['longitude']}"),
                                      position: LatLng(
                                        double.parse(data[i]['latitude']),
                                        double.parse(data[i]['longitude']),
                                      ),
                                      icon: BitmapDescriptor.defaultMarker),
                                },
                                mapType: MapType.normal,
                              ),
                            ),
                          ],
                        ),
                        height: 300.0,
                      ),
                    ),
                  ],
                ),
                padding: EdgeInsets.only(
                    top: 10.0, left: 10.0, right: 10.0, bottom: 10.0),
              );
            },
          );
  }
}

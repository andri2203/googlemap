import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:mustika_pratiwi/dataModels/database.dart';

// Import Halaman Untuk TabView
import './pengaturan.dart';

void main() => runApp(new MaterialApp(
      title: "Sejarah Sabang",
      home: MyApp(),
      // Routes
      routes: <String, WidgetBuilder>{
        '/pengaturan': (BuildContext context) => new Pengaturan(),
      },
      debugShowCheckedModeBanner: false,
    ));

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with SingleTickerProviderStateMixin {
  Completer<GoogleMapController> _controller = Completer();
  LatLng latLng = LatLng(5.8252959, 95.3072574);
  double zoom = 14.447;
  Location location = new Location();
  Database database = new Database();
  Set<Marker> markers = {};
  AsyncSnapshot snapState;
  ConnectionState connectionState;

  @override
  void initState() {
    setState(() {
      markers.add(
        Marker(
          markerId: MarkerId("MyLocation"),
          position: latLng,
          icon: BitmapDescriptor.defaultMarker,
          infoWindow: InfoWindow(title: "Sabang"),
        ),
      );
    });
    super.initState();
    this.fetchMarker();
  }

  Future fetchMarker() async {
    final connect = await database.connect;

    var result = await connect.query("SELECT * FROM tb_lokasi");

    if (result != null) {
      result.forEach((row) {
        setState(() {
          markers.add(
            Marker(
              markerId: MarkerId(row["id_lokasi"].toString()),
              position: LatLng(
                double.parse(row["latitude"]),
                double.parse(row["longitude"]),
              ),
              icon: BitmapDescriptor.defaultMarker,
              infoWindow: InfoWindow(title: row["lokasi"]),
            ),
          );
        });
      });
    }
  }

  getLocation() async {
    final GoogleMapController controller = await _controller.future;

    try {
      var data = await location.getLocation();
      controller.animateCamera(CameraUpdate.newCameraPosition(
        CameraPosition(
          target: LatLng(data.latitude, data.longitude),
          zoom: zoom,
        ),
      ));
      setState(() {
        latLng = LatLng(data.latitude, data.longitude);
        markers.add(
          Marker(
            markerId: MarkerId("MyLocation"),
            position: LatLng(data.latitude, data.longitude),
            icon: BitmapDescriptor.defaultMarker,
            infoWindow: InfoWindow(title: "Lokasi Saya"),
          ),
        );
      });
    } on PlatformException catch (e) {
      if (e.code == "PERMISSION_DENIED") {
        print(e);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: new AppBar(
        title: new Text("Sejarah Sabang"),
        centerTitle: true,
        actions: <Widget>[
          new IconButton(
            alignment: Alignment.center,
            icon: new Icon(
              Icons.person_pin_circle,
              size: 20,
            ),
            onPressed: () => getLocation(),
          ),
        ],
      ),
      drawer: new Drawer(
        child: new ListView(
          children: <Widget>[
            new UserAccountsDrawerHeader(
              accountName: new Text("Sejarah Sabang"),
              accountEmail: new Text("Informasi Situs Sejarah Kota Sabang"),
              currentAccountPicture: new CircleAvatar(
                backgroundImage: AssetImage('img/logo-sabang.png'),
                backgroundColor: Colors.white,
              ),
              decoration: new BoxDecoration(
                image: new DecorationImage(
                    image: AssetImage(
                      'img/header.jpg',
                    ),
                    fit: BoxFit.cover),
              ),
            ),
            new ListTile(
              title: new Text("Panduan"),
              trailing: new Icon(Icons.more_horiz),
              onTap: () {
                //
              },
            ),
            new ListTile(
              title: new Text("Setting"),
              trailing: new Icon(Icons.settings),
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => Pengaturan(),
                    ));
              },
            )
          ],
        ),
      ),
      body: new Stack(
        children: <Widget>[
          petaGoogleMap(context),
          DetailLokasi(
            database: database,
            controller: _controller,
          ),
        ],
      ),
    );
  }

  Widget petaGoogleMap(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height,
      child: new GoogleMap(
        onMapCreated: (GoogleMapController controller) {
          _controller.complete(controller);
        },
        mapType: MapType.normal,
        initialCameraPosition: CameraPosition(
          target: latLng,
          zoom: zoom,
        ),
        padding: const EdgeInsets.only(bottom: 150.0),
        markers: markers,
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
}

class DetailLokasi extends StatelessWidget {
  final Database database;
  final Completer<GoogleMapController> controller;

  DetailLokasi({this.database, this.controller});

  Future<Map> fetchMarker() async {
    final connect = await database.connect;

    var result = await connect.query("SELECT * FROM tb_lokasi");

    await connect.close();

    return result.toList().asMap();
  }

  Future<void> goToTarget(double lat, double long) async {
    final GoogleMapController control = await controller.future;
    control.animateCamera(CameraUpdate.newCameraPosition(
      CameraPosition(
        target: LatLng(lat, long),
        zoom: 15,
        tilt: 50.0,
        bearing: 45.0,
      ),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.bottomLeft,
      child: new Container(
        margin: EdgeInsets.symmetric(vertical: 10.0),
        height: 150.0,
        child: new FutureBuilder<Map>(
          future: database.getData(),
          builder: (context, snapshot) {
            if (snapshot.data != null) {
              print(snapshot.connectionState);
              return boxes(snapshot.data);
            }

            print(snapshot.connectionState);
            return Center(child: CircularProgressIndicator());
          },
        ),
      ),
    );
  }

  Widget boxes(Map data) {
    return new ListView.builder(
      scrollDirection: Axis.horizontal,
      itemCount: data.length,
      itemBuilder: (context, int i) {
        Uint8List image = Base64Decoder().convert(data[i]["gambar"].toString());
        SizedBox(width: 10.0);
        return new Padding(
          padding: const EdgeInsets.all(8.0),
          child: new GestureDetector(
            onTap: () {
              goToTarget(
                double.parse(data[i]["latitude"]),
                double.parse(data[i]["longitude"]),
              );
            },
            child: new Container(
              child: new Material(
                color: Colors.white,
                elevation: 14.0,
                borderRadius: new BorderRadius.circular(24.0),
                shadowColor: Color(0x802196F3),
                child: new Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    new Container(
                      height: 200,
                      width: 180,
                      child: new ClipRRect(
                        borderRadius: new BorderRadius.circular(24.0),
                        child: new Image(
                          fit: BoxFit.fitHeight,
                          image: MemoryImage(image),
                        ),
                      ),
                    ),
                    new Container(
                      child: new Padding(
                        padding: const EdgeInsets.all(4.0),
                        child: new Column(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: <Widget>[
                            new Padding(
                              padding: const EdgeInsets.only(left: 8.0),
                              child: new Container(
                                  child: new Text(
                                data[i]["lokasi"].toString(),
                                softWrap: true,
                                style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 24.0,
                                    fontWeight: FontWeight.bold),
                              )),
                            ),
                            new SizedBox(height: 5.0),
                            new Container(
                              width: MediaQuery.of(context).size.width * 0.4,
                              child: new Center(
                                  child: new Text(
                                data[i]["deskripsi"].toString(),
                                textAlign: TextAlign.justify,
                                softWrap: true,
                                style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 12.0,
                                    fontStyle: FontStyle.italic),
                              )),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

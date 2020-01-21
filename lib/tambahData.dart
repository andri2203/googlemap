import 'dart:convert';
import 'dart:io';
import 'dart:math' as Math;

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import 'package:location/location.dart';

import 'package:path_provider/path_provider.dart';
import 'package:image/image.dart' as Img;
import 'package:mustika_pratiwi/dataModels/database.dart';

class TambahLokasi extends StatefulWidget {
  @override
  _TambahLokasiState createState() => _TambahLokasiState();
}

class _TambahLokasiState extends State<TambahLokasi> {
  // Text Controller
  TextEditingController lokasi = new TextEditingController();
  TextEditingController latitude = new TextEditingController();
  TextEditingController longitude = new TextEditingController();
  TextEditingController deskripsi = new TextEditingController();
  Database database = new Database();

  // Location
  Location location = new Location();
  File img;
  String msg = "";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: new AppBar(
        title: new Text("Tambah Lokasi"),
        centerTitle: true,
      ),
      body: new Container(
        padding: EdgeInsets.all(15.0),
        child: new Card(
          elevation: 15.0,
          child: new Container(
            padding: EdgeInsets.all(10.0),
            child: new SingleChildScrollView(
              child: new Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisSize: MainAxisSize.max,
                children: <Widget>[
                  new Padding(
                    padding: EdgeInsets.only(
                      top: 5.0,
                      bottom: 10.0,
                    ),
                    child: new Text(
                      "Form Tambah Lokasi",
                      style: TextStyle(
                        fontSize: 20.0,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  new Padding(
                    padding: EdgeInsets.only(
                      top: 5.0,
                      bottom: 10.0,
                    ),
                    child: new Text(
                      msg,
                      style: TextStyle(fontSize: 12.0, color: Colors.green),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  form(context),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget form(BuildContext context) {
    return Container(
      child: new Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          new Padding(
            padding: EdgeInsets.only(bottom: 5.0),
            child: new Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                img == null
                    ? new Image.asset("img/no-images.jpg", fit: BoxFit.cover)
                    : new Image.file(img, fit: BoxFit.cover),
                new Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: <Widget>[
                    new RaisedButton(
                      child: new Icon(Icons.image),
                      onPressed: () {
                        getImage(ImageSource.gallery);
                      },
                    ),
                    new RaisedButton(
                      child: new Icon(Icons.camera_alt),
                      onPressed: () {
                        getImage(ImageSource.camera);
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
          new Padding(
            padding: EdgeInsets.only(bottom: 10.0),
            child: new TextField(
              controller: lokasi,
              decoration: InputDecoration(hintText: "Nama Lokasi"),
            ),
          ),
          new Align(
            alignment: Alignment.center,
            child: new RaisedButton(
              color: Colors.blue,
              child: new Text("Dapatkan Lokasi"),
              onPressed: () {
                getLocation();
              },
            ),
          ),
          new Padding(
            padding: EdgeInsets.only(bottom: 10.0),
            child: new TextField(
              decoration: InputDecoration(hintText: "Latitude"),
              controller: latitude,
              readOnly: true,
            ),
          ),
          new Padding(
            padding: EdgeInsets.only(bottom: 10.0),
            child: new TextField(
              decoration: InputDecoration(
                hintText: "Longitude",
              ),
              controller: longitude,
              readOnly: true,
            ),
          ),
          new Padding(
            padding: EdgeInsets.only(bottom: 10.0),
            child: new TextField(
              maxLines: null,
              controller: deskripsi,
              decoration: InputDecoration(
                hintText: "Deskripsi",
              ),
              keyboardType: TextInputType.multiline,
            ),
          ),
          new Align(
            alignment: Alignment.centerRight,
            child: new RaisedButton(
              color: Colors.blue,
              child: new Text("Tambah"),
              onPressed: () {
                post();
              },
            ),
          ),
        ],
      ),
    );
  }

  Future getImage(ImageSource source) async {
    var imageFile = await ImagePicker.pickImage(source: source);

    final tempDir = await getTemporaryDirectory();
    final path = tempDir.path;

    Img.Image image = Img.decodeImage(imageFile.readAsBytesSync());
    Img.Image rotate = Img.copyRotate(image, 90 * Math.pi / 180);
    Img.Image newImage = Img.copyResize(
      source == ImageSource.camera ? rotate : image,
      width: 500,
    );

    int rand = new Math.Random().nextInt(100000);

    var compressImg = new File("$path/img_$rand.jpg")
      ..writeAsBytesSync(Img.encodeJpg(newImage, quality: 85));

    setState(() {
      img = compressImg;
    });
  }

  void getLocation() async {
    var currentLocation = await location.getLocation();

    setState(() {
      latitude.text = currentLocation.latitude.toString();
      longitude.text = currentLocation.longitude.toString();
    });
  }

  void post() async {
    final conn = await database.connect;

    List<int> bytes = img.readAsBytesSync();
    String gambar = base64Encode(bytes);

    var query = await conn.query(
        "INSERT INTO tb_lokasi (lokasi, latitude, longitude, deskripsi, gambar) VALUES (?, ?, ?, ?, ?)",
        [lokasi.text, latitude.text, longitude.text, deskripsi.text, gambar]);

    if (query != null) {
      print("Success");
    } else {
      print("Failed");
    }

    setState(() {
      msg = "Data Berhasil di Tambah";
      lokasi.text = '';
      latitude.text = '';
      longitude.text = '';
      deskripsi.text = '';
      img = null;
    });

    await conn.close();
  }
}

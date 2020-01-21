import 'package:flutter/material.dart';
import 'package:location/location.dart';
import 'package:mustika_pratiwi/dataModels/database.dart';
import 'package:mustika_pratiwi/listData.dart';

class Update extends StatefulWidget {
  final int idLokasi;
  final String _lokasi;
  final String _deskripsi;
  final double _latitude;
  final double _longitude;

  Update(this.idLokasi, this._lokasi, this._deskripsi, this._latitude,
      this._longitude);

  @override
  _UpdateState createState() =>
      _UpdateState(idLokasi, _lokasi, _deskripsi, _latitude, _longitude);
}

class _UpdateState extends State<Update> {
  final int idLokasi;
  final String _lokasi;
  final String _deskripsi;
  final double _latitude;
  final double _longitude;

  _UpdateState(this.idLokasi, this._lokasi, this._deskripsi, this._latitude,
      this._longitude);
  // Text Controller
  TextEditingController lokasi = new TextEditingController();
  TextEditingController latitude = new TextEditingController();
  TextEditingController longitude = new TextEditingController();
  TextEditingController deskripsi = new TextEditingController();
  Database database = new Database();

  // Location
  Location location = new Location();
  String msg = "";

  // init
  @override
  void initState() {
    setState(() {
      lokasi.text = widget._lokasi;
      latitude.text = widget._latitude.toString();
      longitude.text = widget._longitude.toString();
      deskripsi.text = widget._deskripsi;
    });
    super.initState();
  }

  // Build Widget
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: new Scaffold(
        appBar: new AppBar(
          leading: new IconButton(
            icon: new Icon(Icons.arrow_back),
            onPressed: () =>
                Navigator.of(context).pushReplacement(MaterialPageRoute(
              builder: (_) => ListLokasi(),
            )),
          ),
          title: new Text(_lokasi),
          centerTitle: true,
        ),
        body: Container(
          padding: const EdgeInsets.all(10.0),
          child: form(context),
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
              child: new Text("Ubah Lokasi"),
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
              child: new Text("Update"),
              onPressed: () {
                post();
              },
            ),
          ),
        ],
      ),
    );
  }

  // Atribute

  void getLocation() async {
    var currentLocation = await location.getLocation();

    setState(() {
      latitude.text = currentLocation.latitude.toString();
      longitude.text = currentLocation.longitude.toString();
    });
  }

  void post() async {
    final conn = await database.connect;

    var query = await conn.query(
        // "INSERT INTO tb_lokasi (lokasi, latitude, longitude, deskripsi) VALUES (?, ?, ?, ?, ?)",
        "UPDATE tb_lokasi SET lokasi=?, latitude=?, longitude=?, deskripsi=? WHERE id_lokasi=?",
        [
          lokasi.text,
          latitude.text,
          longitude.text,
          deskripsi.text,
          widget.idLokasi
        ]);

    if (query != null) {
      print("Success");
      setState(() {
        msg = "Data Berhasil di Tambah";
        lokasi.text = '';
        latitude.text = '';
        longitude.text = '';
        deskripsi.text = '';
      });
      Navigator.of(context).pushReplacement(MaterialPageRoute(
        builder: (_) => ListLokasi(),
      ));
    } else {
      print("Failed");
    }

    await conn.close();
  }
}

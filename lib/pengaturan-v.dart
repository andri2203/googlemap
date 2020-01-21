import 'package:flutter/material.dart';
import './tambahData.dart';
import './listData.dart';

class PengaturanView extends StatefulWidget {
  final String nama;

  PengaturanView({this.nama});

  @override
  _PengaturanViewState createState() => _PengaturanViewState(nama: nama);
}

class _PengaturanViewState extends State<PengaturanView> {
  final String nama;

  _PengaturanViewState({this.nama});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: new AppBar(
        title: Row(
          children: <Widget>[
            new Text("Pengaturan"),
            new Padding(
              padding: EdgeInsets.only(left: 5),
              child: new Icon(
                Icons.settings,
                size: 20.0,
              ),
            )
          ],
        ),
        centerTitle: true,
        elevation: 5.0,
      ),
      body: new Container(
        padding: EdgeInsets.all(15.0),
        child: new Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            new Card(
              elevation: 10.0,
              child: Container(
                padding: EdgeInsets.all(10.0),
                child: new Text(
                  "Selamat Datang $nama",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            new Padding(
              padding: EdgeInsets.only(
                top: 5.0,
                bottom: 5.0,
              ),
              child: new Divider(
                color: Colors.black38,
              ),
            ),
            new Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisAlignment: MainAxisAlignment.start,
              textDirection: TextDirection.ltr,
              children: <Widget>[
                new RaisedButton(
                  color: Colors.blue[100],
                  hoverColor: Colors.blue[400],
                  elevation: 10.0,
                  hoverElevation: 5.0,
                  child: new Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      new Padding(
                        padding: EdgeInsets.only(
                          top: 5.0,
                          bottom: 5.0,
                        ),
                        child: new Text("Tambah Lokasi"),
                      ),
                      new Icon(Icons.add_location),
                    ],
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => TambahLokasi(),
                      ),
                    );
                  },
                ),
                new RaisedButton(
                  color: Colors.blue[100],
                  hoverColor: Colors.blue[400],
                  elevation: 10.0,
                  hoverElevation: 5.0,
                  child: new Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      new Padding(
                        padding: EdgeInsets.only(
                          top: 5.0,
                          bottom: 5.0,
                        ),
                        child: new Text("Daftar Lokasi"),
                      ),
                      new Icon(Icons.location_on),
                    ],
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ListLokasi(),
                      ),
                    );
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

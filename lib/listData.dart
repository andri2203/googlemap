import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:mustika_pratiwi/dataModels/database.dart';
import 'package:mustika_pratiwi/update.dart';
import 'package:mustika_pratiwi/updateImg.dart';

class ListLokasi extends StatefulWidget {
  @override
  _ListLokasiState createState() => _ListLokasiState();
}

class _ListLokasiState extends State<ListLokasi> {
  List data;
  double size = 20;
  Database database = new Database();

  @override
  void initState() {
    super.initState();
  }

  Future delete(int idLokasi) async {
    final connect = await database.connect;

    await connect.query("DELETE FROM tb_lokasi WHERE id_lokasi=?", [idLokasi]);

    await connect.close();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: new AppBar(
        title: new Text("Daftar Lokasi"),
        centerTitle: true,
      ),
      body: new Container(
        padding: EdgeInsets.all(5.0),
        child: new FutureBuilder<Map>(
          future: database.getData(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              return Padding(
                padding: const EdgeInsets.all(5.0),
                child: viewData(context, snapshot.data),
              );
            }

            return Center(child: CircularProgressIndicator());
          },
        ),
      ),
    );
  }

  Widget viewData(BuildContext context, Map data) {
    return new Container(
      padding: EdgeInsets.all(5.0),
      child: new ListView.builder(
        itemCount: data.length,
        itemBuilder: (context, int i) {
          Uint8List image =
              Base64Decoder().convert(data[i]["gambar"].toString());

          return new Card(
            elevation: 5.0,
            child: new Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                new Padding(
                  padding: const EdgeInsets.all(5.0),
                  child: new Text(
                    data[i]["lokasi"],
                    textAlign: TextAlign.center,
                    style:
                        TextStyle(fontSize: 20.0, fontStyle: FontStyle.normal),
                  ),
                ),
                new Image.memory(
                  image,
                  fit: BoxFit.fitWidth,
                ),
                new Padding(
                  padding: EdgeInsets.only(top: 5.0),
                  child: new Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: <Widget>[
                      new FlatButton(
                        child: new Icon(Icons.camera,
                            size: size, color: Colors.blue),
                        onPressed: () {
                          Navigator.of(context).push(MaterialPageRoute(
                            builder: (_) => UpdateImg(
                              int.parse(data[i]["id_lokasi"].toString()),
                            ),
                          ));
                        },
                      ),
                      new FlatButton(
                        child: new Icon(Icons.edit,
                            size: size, color: Colors.green),
                        onPressed: () {
                          Navigator.of(context).push(MaterialPageRoute(
                            builder: (context) => Update(
                              int.parse(data[i]["id_lokasi"].toString()),
                              data[i]["lokasi"].toString(),
                              data[i]["deskripsi"].toString(),
                              double.parse(data[i]["latitude"].toString()),
                              double.parse(data[i]["longitude"].toString()),
                            ),
                          ));
                        },
                      ),
                      new FlatButton(
                        child: new Icon(Icons.delete,
                            size: size, color: Colors.red),
                        onPressed: () {
                          return showDialog(
                              context: context,
                              builder: (_) {
                                return new AlertDialog(
                                  title: new Text("Yakin Ingin Menghapus?"),
                                  actions: <Widget>[
                                    new Align(
                                      alignment: Alignment.centerRight,
                                      child: new FlatButton(
                                        child: new Text("OK",
                                            style:
                                                TextStyle(color: Colors.blue)),
                                        onPressed: () {
                                          delete(data[i]["id_lokasi"]);
                                          setState(() {
                                            database = new Database();
                                          });
                                          Navigator.of(context).pop();
                                        },
                                      ),
                                    ),
                                    new Align(
                                      alignment: Alignment.centerLeft,
                                      child: new FlatButton(
                                        child: new Text("Cencel",
                                            style:
                                                TextStyle(color: Colors.blue)),
                                        onPressed: () {
                                          Navigator.of(context).pop();
                                        },
                                      ),
                                    ),
                                  ],
                                );
                              });
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

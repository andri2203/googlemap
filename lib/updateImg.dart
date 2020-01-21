import 'dart:convert';
import 'dart:io';
import 'dart:math' as Math;

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import 'package:path_provider/path_provider.dart';
import 'package:image/image.dart' as Img;
import 'package:mustika_pratiwi/dataModels/database.dart';

import 'listData.dart';

class UpdateImg extends StatefulWidget {
  final int idLokasi;

  UpdateImg(this.idLokasi);
  @override
  _UpdateImgState createState() => _UpdateImgState();
}

class _UpdateImgState extends State<UpdateImg> {
  int idLokasi;
  Database database = new Database();
  File img;

  @override
  void initState() {
    setState(() {
      idLokasi = widget.idLokasi;
    });
    super.initState();
  }

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
          title: new Text("Update Gambar"),
          centerTitle: true,
        ),
        body: Container(
          padding: const EdgeInsets.all(10.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              new Padding(
                padding: EdgeInsets.only(bottom: 5.0),
                child: new Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    img == null
                        ? new Image.asset("img/no-images.jpg",
                            fit: BoxFit.cover)
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
              ),
            ],
          ),
        ),
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

  void post() async {
    final conn = await database.connect;

    List<int> bytes = img.readAsBytesSync();
    String gambar = base64Encode(bytes);

    var query = await conn.query(
        "UPDATE tb_lokasi SET gambar=? WHERE id_lokasi=?", [gambar, idLokasi]);

    if (query != null) {
      print("Success");
      Navigator.of(context).pushReplacement(MaterialPageRoute(
        builder: (_) => ListLokasi(),
      ));
    } else {
      print("Failed");
    }

    setState(() {
      img = null;
    });

    await conn.close();
  }
}

import 'package:flutter/material.dart';
import 'package:mustika_pratiwi/dataModels/database.dart';

import './pengaturan-v.dart';

class Pengaturan extends StatefulWidget {
  @override
  _PengaturanState createState() => _PengaturanState();
}

class _PengaturanState extends State<Pengaturan> {
  TextEditingController usernameControl = new TextEditingController();
  TextEditingController passwordControl = new TextEditingController();
  Database database = new Database();

  Map map;

  String msg = '';
  bool isLoading = false;

  @override
  void initState() {
    super.initState();

    if (isLoading == true) {
      print(map);
    }
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: Center(
          child: Row(
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
        ),
      ),
      body: new Container(
        padding: EdgeInsets.all(15.0),
        alignment: Alignment.center,
        child: new Card(
          elevation: 15.0,
          child: isLoading != true
              ? formLogin(context)
              : new CircularProgressIndicator(),
        ),
      ),
    );
  }

  Widget formLogin(BuildContext context) {
    return new Container(
      padding: EdgeInsets.all(10.0),
      child: new Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        verticalDirection: VerticalDirection.down,
        children: <Widget>[
          new Padding(
            padding: EdgeInsets.only(top: 10.0, bottom: 10.0),
            child: new Text(
              "Mohon Login",
              style: TextStyle(
                fontSize: 21.0,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          new Container(
            child: msg == ''
                ? new Text(
                    "Akses Pengaturan hanya diperbolehkan untuk admin.",
                    textAlign: TextAlign.center,
                  )
                : Text(
                    msg,
                    style: TextStyle(
                      color: Colors.red,
                    ),
                  ),
            padding: EdgeInsets.only(
              bottom: 10.0,
            ),
          ),
          // Form Login
          new Padding(
            padding: EdgeInsets.only(bottom: 10.0),
            child: new TextFormField(
              controller: usernameControl,
              decoration: InputDecoration(
                hintText: 'Username',
              ),
            ),
          ),
          new Padding(
            padding: EdgeInsets.only(bottom: 10.0),
            child: new TextFormField(
              controller: passwordControl,
              obscureText: true,
              decoration: InputDecoration(
                hintText: 'Password',
              ),
              keyboardType: TextInputType.visiblePassword,
            ),
          ),
          new Align(
            alignment: Alignment.centerRight,
            child: new RaisedButton(
              color: Colors.blue,
              child: new Text("Login"),
              onPressed: () {
                login();
              },
            ),
          ),
        ],
      ),
    );
  }

  void login() async {
    final conn = await database.connect;

    var result = await conn
        .query("SELECT * FROM user WHERE username = ? AND password = md5(?)", [
      usernameControl.text,
      passwordControl.text,
    ]);

    setState(() {
      isLoading = true;
      map = result.toList().asMap();
    });

    Map data = result.toList().asMap();

    if (data[0] != null) {
      Navigator.pushReplacement(
        context,
        new MaterialPageRoute(
          builder: (_) => PengaturanView(
            nama: data[0]['nama'],
          ),
        ),
      );
    } else {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: new Text(
              "Login Gagal!!",
              textAlign: TextAlign.center,
            ),
            content: new Text("Username atau Password salah"),
            actions: <Widget>[
              new FlatButton(
                child: new Text("OK"),
                onPressed: () {
                  setState(() {
                    usernameControl.text = "";
                    passwordControl.text = "";
                    isLoading = false;
                  });
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
    }

    await conn.close();
  }
}

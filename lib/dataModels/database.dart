import 'package:mysql1/mysql1.dart' as mysqli;

class Database {
  final connect = mysqli.MySqlConnection.connect(
    mysqli.ConnectionSettings(
      host: "remotemysql.com",
      port: 3306,
      user: "AEP0E80mY9",
      password: "LBZEkwwKSr",
      db: "AEP0E80mY9",
    ),
  );

  Future<Map> getData() async {
    final con = await connect;

    var result = await con.query("SELECT * FROM tb_lokasi");

    return result.toList().asMap();
  }
}

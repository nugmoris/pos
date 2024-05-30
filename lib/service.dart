import 'dart:convert';

import 'package:http/http.dart' as http;

class ApiService {
  static const root = "http://128.199.154.103/tuing_pos";
  static const action = "LOGIN";

  static Future<dynamic> login(String username, String password) async {
    final url = '$root/api.php?action=$action&user1=$username&pass1=$password';
    //print(url);

    final response = await http.get(Uri.parse(url));
    // print('1');
    // print(response.statusCode.toString());

    if (response.statusCode == 200) {
      //  print('2......');
      try {
        final jsonResponse = jsonDecode(response.body);
        //  print(jsonResponse); // Tambahkan ini untuk melihat isi respons JSON

        // Memeriksa apakah JSON adalah list dan memiliki setidaknya satu elemen
        if (jsonResponse is List && jsonResponse.isNotEmpty) {
          final user = jsonResponse[0]; // Mengakses elemen pertama dalam list
          final varnmuser = user['username'];
          final varbagian = user['bagian'];
          //   print('Username: $varnmuser, Bagian: $varbagian');
          return varbagian;
        } else {
          //   print('JSON tidak memiliki format yang diharapkan');
          throw Exception('Format JSON tidak valid');
        }
      } catch (e) {
        //   print('Error parsing JSON: $e');
        throw Exception('Error parsing JSON');
      }
    } else {
      // print('Gagal login. Status code: ${response.statusCode}');
      throw Exception('Failed to login');
    }
  }

  static Future<dynamic> login2(String username, String password) async {
    final url = '$root/api.php?action=LOGIN2';

    final Map<String, String> jsonData = {
      'user1': username,
      'pass1': password,
    };
    print(url);
    final response = await http.post(
      Uri.parse(url),
      body: jsonEncode(jsonData),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      try {
        final jsonResponse = jsonDecode(response.body);

        if (jsonResponse is List && jsonResponse.isNotEmpty) {
          final user = jsonResponse[0];
          final varnmuser = user['username'];
          final varbagian = user['bagian'];
          return varbagian;
        } else {
          throw Exception('Format JSON tidak valid');
        }
      } catch (e) {
        throw Exception('Error parsing JSON');
      }
    } else {
      throw Exception('Failed to login');
    }
  }

  static Future<Map<String, dynamic>> crbarang(
      String username, String cari1) async {
    final url = '$root/api.php?action=CRBARANG&user1=$username&cari1=$cari1';

    final response = await http.get(Uri.parse(url));

    //print(response.statusCode.toString());

    if (response.statusCode == 200) {
      try {
        final jsonResponse = jsonDecode(response.body);

        if (jsonResponse is List && jsonResponse.isNotEmpty) {
          final user = jsonResponse[0]; // Mengakses elemen pertama dalam list
          final varnmbarang = user['nama'];
          final hargajual = user['nhargajual'];
          //print(varnmbarang);
          return {'nama': varnmbarang, 'hargaJual': hargajual};
        } else {
          //print('JSON tidak memiliki format yang diharapkan');
          throw Exception('Format JSON tidak valid');
        }
      } catch (e) {
        //   print('Error parsing JSON: $e');
        throw Exception('Error parsing JSON');
      }
    } else {
      //print('Barang tidak ketemu. Status code: ${response.statusCode}');
      return {'nama': 'barang tidak ada', 'hargaJual': null};
    }
  }

  static Future<List<Map<String, dynamic>>> inputtrans(
      String kdbarang,
      String nqty,
      String nrp,
      String user,
      String kdcust,
      String ntop,
      String keth,
      String kdsales,
      String notrans) async {
    final url =
        '$root/api.php?action=INPUTJL&lks1=01&kdbarang1=$kdbarang&nqty1=$nqty&nrp1=$nrp&user1=$user&kdcust1=$kdcust&ntop1=$ntop&keth1=$keth&kdsales1=$kdsales&notrans1=$notrans';
    print(url);
    var response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      List<dynamic> jsonData = jsonDecode(response.body);
      print(jsonData);
      return List<Map<String, dynamic>>.from(jsonData);
    } else {
      throw Exception('Failed to fetch report data');
    }
  }

  static Future<List<Map<String, dynamic>>> bayarjual(
    String nojual1,
    String nrp1,
    String user1,
    String lks1,
  ) async {
    final url =
        '$root/api.php?action=BAYARJL&nojual1=$nojual1&nrp1=$nrp1&user1=$user1&lks1=$lks1';
    //print(url);
    var response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      List<dynamic> jsonData = jsonDecode(response.body);
      //print(jsonData);
      return List<Map<String, dynamic>>.from(jsonData);
    } else {
      throw Exception('Failed to fetch report data');
    }
  }

  static Future<List<Map<String, dynamic>>> lapjual(
    String tgl1,
    String tgl2,
    String kondisi1,
  ) async {
    final url =
        '$root/api.php?action=LAPJUAL&tgl1=$tgl1&tgl2=$tgl2&kondisi1=$kondisi1';
    var response = await http.get(Uri.parse(url));
    print(url);
    if (response.statusCode == 200) {
      List<dynamic> jsonData = jsonDecode(response.body);
      //print(jsonData);
      return List<Map<String, dynamic>>.from(jsonData);
    } else {
      throw Exception('Failed to fetch report data');
    }
  }

  static Future<String> gantiPassword(
      String varpbuser, String oldPassword, String newPassword) async {
    final url =
        '$root/api.php?action=GANTIPWD&pbuser1=$varpbuser&passlama=$oldPassword&passbaru=$newPassword';
    final response = await http.post(Uri.parse(url));

    if (response.statusCode == 200) {
      try {
        final jsonResponse = json.decode(response.body);
        final hasil = jsonResponse[0]['@hasil'];

        if (hasil == 'Gagal, password lama salah') {
          return 'Password Lama Anda Salah';
        } else if (hasil == 'Sukses') {
          return 'Ganti Password Berhasil';
        }
      } catch (e) {
        print('Error parsing JSON: $e');
      }
    }

    return 'Terjadi kesalahan';
  }
}

class Jenis {
  final String kdjenis;
  final String nama;
  Jenis({required this.kdjenis, required this.nama});
}

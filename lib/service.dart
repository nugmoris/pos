import 'dart:convert';

import 'package:http/http.dart' as http;

class ApiService {
  static const root = "http://128.199.154.103/tuing_pos";
  static const action = "LOGIN";

  static Future<Map<String, String>> login2(String username, String password, String alamatmac) async {
    final url = '$root/api.php?action=LOGIN2';

    final Map<String, String> jsonData = {
      'user1': username,
      'pass1': password,
      'alamatmac': alamatmac,
    };
    print(url);
    print(jsonData);
    final response = await http.post(
      Uri.parse(url),
      body: jsonEncode(jsonData),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      try {
        final jsonResponse = jsonDecode(response.body);
        print(jsonResponse);
        if (jsonResponse is List && jsonResponse.isNotEmpty) {
          final user = jsonResponse[0];
          final varbagian = user['bagian'];
          final varlks = user['lks'];
          final varnmlok = user['nmlok'];
          final varsaldokas = user['saldokas'];

          return {
            'bagian': varbagian,
            'lks': varlks,
            'nmlok': varnmlok,
            'saldokas': varsaldokas,
          };
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

  static Future<String> gantiPassword(String varpbuser, String oldPassword, String newPassword) async {
    // final url = '$root/api.php?action=GANTIPWD&pbuser1=$varpbuser&passlama=$oldPassword&passbaru=$newPassword';
    final url = '$root/api.php?action=GANTIPWD';
    final Map<String, String> jsonData = {
      'pbuser1': varpbuser,
      'passlama': oldPassword,
      'passbaru': newPassword,
    };
    // print(url);
    final response = await http.post(
      Uri.parse(url),
      body: jsonEncode(jsonData),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      try {
        final jsonResponse = json.decode(response.body);
        final hasil = jsonResponse[0]['@hasil'];
        //  print(hasil);
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

  static Future<Map<String, dynamic>> cekversi() async {
    final url = '$root/api.php?action=CEKVERSI';
    // print(url);
    final response = await http.get(Uri.parse(url)); // Fetch the response from the API

    if (response.statusCode == 200) {
      try {
        final jsonResponse = jsonDecode(response.body);

        if (jsonResponse is List && jsonResponse.isNotEmpty) {
          final versiku = jsonResponse[0]; // Access the first element in the list
          final varversi = versiku['cketerangan2']; // Corrected variable name

          return {'versiku': varversi};
        } else {
          throw Exception('Format JSON tidak valid');
        }
      } catch (e) {
        throw Exception('Error parsing JSON');
      }
    } else {
      return {'ket': 'Tidak ketemu'};
    }
  }

  static Future<Map<String, dynamic>> serverupdate() async {
    final url = '$root/api.php?action=SERVERUPDATE';

    final response = await http.get(Uri.parse(url)); // Fetch the response from the API

    if (response.statusCode == 200) {
      try {
        final jsonResponse = jsonDecode(response.body);

        if (jsonResponse is List && jsonResponse.isNotEmpty) {
          final serverupdate = jsonResponse[0]; // Access the first element in the list
          final varserverupdate = serverupdate['cketerangan2']; // Corrected variable name

          return {'serverupdate': varserverupdate};
        } else {
          throw Exception('Format JSON tidak valid');
        }
      } catch (e) {
        throw Exception('Error parsing JSON');
      }
    } else {
      return {'ket': 'Tidak ketemu'};
    }
  }

  static Future<Map<String, dynamic>> crbarang(String username, String cari1) async {
    final url = '$root/api.php?action=CRBARANG&user1=$username&cari1=$cari1';

    final response = await http.get(Uri.parse(url));

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

  static Future<List<Map<String, dynamic>>> crbarang2(String username, String cari1, String kondisi1) async {
    final url = '$root/api.php?action=CRBARANG2';
    final Map<String, String> jsonData = {
      'user1': username,
      'cari1': cari1,
      'kondisi1': kondisi1,
    };

    var response = await http.post(Uri.parse(url), body: jsonEncode(jsonData), headers: {'Content-Type': 'application/json'});
    if (response.statusCode == 200) {
      List<dynamic> jsonData = jsonDecode(response.body);
      print(jsonData);
      return List<Map<String, dynamic>>.from(jsonData);
    } else {
      throw Exception('Failed to fetch report data');
    }
  }

  static Future<List<Map<String, dynamic>>> crcust(String username, String cari1, String kondisi1) async {
    final url = '$root/api.php?action=CARICUST';
    final Map<String, String> jsonData = {
      'user1': username,
      'cari1': cari1,
      'kondisi1': kondisi1,
    };

    var response = await http.post(Uri.parse(url), body: jsonEncode(jsonData), headers: {'Content-Type': 'application/json'});
    if (response.statusCode == 200) {
      List<dynamic> jsonData = jsonDecode(response.body);
      //  print(jsonData);
      return List<Map<String, dynamic>>.from(jsonData);
    } else {
      throw Exception('Failed to fetch report data');
    }
  }

  static Future<List<Map<String, dynamic>>> inputtrans2(String kdbarang, String nqty, String nrp, String user, String kdcust, String ntop,
      String keth, String kdsales, String notrans, String lks1) async {
    final url = '$root/api.php?action=INPUTJL2';
    final Map<String, String> jsonData = {
      'lks1': lks1,
      'kdbarang1': kdbarang,
      'nqty1': nqty,
      'nrp1': nrp,
      'user1': user,
      'kdcust1': kdcust,
      'ntop1': ntop,
      'keth1': keth,
      'kdsales1': kdsales,
      'notrans1': notrans,
    };
    print(url);
    print(jsonData);
    var response = await http.post(Uri.parse(url), body: jsonEncode(jsonData), headers: {'Content-Type': 'application/json'});
    if (response.statusCode == 200) {
      List<dynamic> jsonData = jsonDecode(response.body);
      //  print(jsonData);
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
    String kdgl1,
  ) async {
    // final url = '$root/api.php?action=BAYARJL&nojual1=$nojual1&nrp1=$nrp1&user1=$user1&lks1=$lks1';
    final url = '$root/api.php?action=BAYARJL';
    final Map<String, String> jsonData = {
      'lks1': lks1,
      'nojual1': nojual1,
      'kdgl1': kdgl1,
      'nrp1': nrp1,
      'user1': user1,
    };
    var response = await http.post(Uri.parse(url), body: jsonEncode(jsonData), headers: {'Content-Type': 'application/json'});

    if (response.statusCode == 200) {
      List<dynamic> jsonData = jsonDecode(response.body);
      print(jsonData);
      return List<Map<String, dynamic>>.from(jsonData);
    } else {
      throw Exception('Failed to fetch report data');
    }
  }

  static Future<List<Map<String, dynamic>>> lapjual(String tgl1, String tgl2, String kondisi1, String lks1) async {
    final url = '$root/api.php?action=LAPJUAL&tgl1=$tgl1&tgl2=$tgl2&kondisi1=$kondisi1&lks1=$lks1';
    var response = await http.get(Uri.parse(url));
    print(url);
    if (response.statusCode == 200) {
      List<dynamic> jsonData = jsonDecode(response.body);
      print(jsonData);
      return List<Map<String, dynamic>>.from(jsonData);
    } else {
      throw Exception('Failed to fetch report data');
    }
  }

  static Future<List<Map<String, dynamic>>> lapjualperno(String user1, String notran1) async {
    final url = '$root/api.php?action=LAPJUALPERNO';
    final Map<String, String> jsonData = {
      'user1': user1,
      'notran1': notran1,
    };
    var response = await http.post(Uri.parse(url), body: jsonEncode(jsonData), headers: {'Content-Type': 'application/json'});
    if (response.statusCode == 200) {
      List<dynamic> jsonData = jsonDecode(response.body);
      return List<Map<String, dynamic>>.from(jsonData);
    } else {
      throw Exception('Failed to fetch report data');
    }
  }

  static Future<List<Map<String, dynamic>>> jenisbarang(String user1) async {
    final url = '$root/api.php?action=JENISBARANG';
    final Map<String, String> jsonData = {
      'user1': user1,
    };
    var response = await http.post(Uri.parse(url), body: jsonEncode(jsonData), headers: {'Content-Type': 'application/json'});
    if (response.statusCode == 200) {
      List<dynamic> jsonData = jsonDecode(response.body);
      return List<Map<String, dynamic>>.from(jsonData);
    } else {
      throw Exception('Failed to fetch report data');
    }
  }

  static Future<List<Map<String, dynamic>>> lapstok(String user1, String lks1, String jenis1, String cari1, String kondisi1) async {
    final url = '$root/api.php?action=LAPSTOK';
    final Map<String, String> jsonData = {
      'user1': user1,
      'lks1': lks1,
      'jenis1': jenis1,
      'cari1': cari1,
      'kondisi1': kondisi1,
    };
    print(url);
    print(jsonData);
    var response = await http.post(Uri.parse(url), body: jsonEncode(jsonData), headers: {'Content-Type': 'application/json'});
    if (response.statusCode == 200) {
      List<dynamic> jsonData = jsonDecode(response.body);
      return List<Map<String, dynamic>>.from(jsonData);
    } else {
      throw Exception('Failed to fetch report data');
    }
  }

  static Future<List<Map<String, dynamic>>> daftarharga(String user1, String lks1, String jenis1, String cari1, String kondisi1) async {
    final url = '$root/api.php?action=DAFTARHARGA';
    final Map<String, String> jsonData = {
      'user1': user1,
      'lks1': lks1,
      'jenis1': jenis1,
      'cari1': cari1,
      'kondisi1': kondisi1,
    };
    print(url);
    print(jsonData);
    var response = await http.post(Uri.parse(url), body: jsonEncode(jsonData), headers: {'Content-Type': 'application/json'});
    if (response.statusCode == 200) {
      List<dynamic> jsonData = jsonDecode(response.body);
      return List<Map<String, dynamic>>.from(jsonData);
    } else {
      throw Exception('Failed to fetch report data');
    }
  }

  static Future<List<Map<String, dynamic>>> kirabayar(String user1, String lks1) async {
    final url = '$root/api.php?action=KIRABAYAR';
    final Map<String, String> jsonData = {
      'user1': user1,
      'lks1': lks1,
    };
    var response = await http.post(Uri.parse(url), body: jsonEncode(jsonData), headers: {'Content-Type': 'application/json'});
    if (response.statusCode == 200) {
      List<dynamic> jsonData = jsonDecode(response.body);
      return List<Map<String, dynamic>>.from(jsonData);
    } else {
      throw Exception('Failed to fetch report data');
    }
  }
}

class Jenis {
  final String kdjenis;
  final String nama;
  Jenis({required this.kdjenis, required this.nama});
}

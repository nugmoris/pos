import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

class ApiService {
  //static const root = "http://128.199.154.103/tuing_pos";
  //static const root = "http://103.80.96.26/tuing_pos";
  static const root = "http://103.80.96.26/pos_coba";

  static const action = "LOGIN";

  static Future<List<Map<String, dynamic>>> carijualnow(String tgl1,
      String tgl2, String kondisi1, String lks1, String cari1) async {
    final url = '$root/api.php?action=CARIJUALNOW';
    final Map<String, String> jsonData = {
      'tgl1': tgl1,
      'tgl2': tgl2,
      'kondisi1': kondisi1,
      'lks1': lks1,
      'cari1': cari1
    };

    var response = await http.post(Uri.parse(url),
        body: jsonEncode(jsonData),
        headers: {'Content-Type': 'application/json'});
    //print(jsonData);
    if (response.statusCode == 200) {
      List<dynamic> jsonData = jsonDecode(response.body);

      return List<Map<String, dynamic>>.from(jsonData);
    } else {
      throw Exception('Failed to fetch report data');
    }
  }

  static Future<Map<String, String>> login2(String username, String password,
      String alamatmac, String myversion1) async {
    final url = '$root/api.php?action=LOGIN3';
    print(url);
    final Map<String, String> jsonData = {
      'user1': username,
      'pass1': password,
      'alamatmac': alamatmac,
      'versi': myversion1,
    };
    print('Login1');
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
          print('Login2');
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

  static Future<String> gantiPassword(
      String varpbuser, String oldPassword, String newPassword) async {
    // final url = '$root/api.php?action=GANTIPWD&pbuser1=$varpbuser&passlama=$oldPassword&passbaru=$newPassword';
    final url = '$root/api.php?action=GANTIPWD';
    final Map<String, String> jsonData = {
      'pbuser1': varpbuser,
      'passlama': oldPassword,
      'passbaru': newPassword,
    };

    final response = await http.post(
      Uri.parse(url),
      body: jsonEncode(jsonData),
      headers: {'Content-Type': 'application/json'},
    );

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

  static Future<Map<String, dynamic>> cekversi() async {
    final url = '$root/api.php?action=CEKVERSI';

    final response =
        await http.get(Uri.parse(url)); // Fetch the response from the API

    if (response.statusCode == 200) {
      try {
        final jsonResponse = jsonDecode(response.body);

        if (jsonResponse is List && jsonResponse.isNotEmpty) {
          final versiku =
              jsonResponse[0]; // Access the first element in the list
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

    final response =
        await http.get(Uri.parse(url)); // Fetch the response from the API

    if (response.statusCode == 200) {
      try {
        final jsonResponse = jsonDecode(response.body);

        if (jsonResponse is List && jsonResponse.isNotEmpty) {
          final serverupdate =
              jsonResponse[0]; // Access the first element in the list
          final varserverupdate =
              serverupdate['cketerangan2']; // Corrected variable name

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

  static Future<Map<String, dynamic>> crbarang(
      String user1, String cari1, String kondisi1) async {
    final url =
        '$root/api.php?action=CRBARANG&user1=$user1&cari1=$cari1&kondisi1=1';

    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      try {
        final jsonResponse = jsonDecode(response.body);

        if (jsonResponse is List && jsonResponse.isNotEmpty) {
          final user = jsonResponse[0]; // Mengakses elemen pertama dalam list
          final varnmbarang = user['nama'];
          final hargajual = user['nhargajual'];

          return {'nama': varnmbarang, 'hargaJual': hargajual};
        } else {
          throw Exception('Format JSON tidak valid');
        }
      } catch (e) {
        throw Exception('Error parsing JSON');
      }
    } else {
      return {'nama': 'barang tidak ada', 'hargaJual': null};
    }
  }

  static Future<List<Map<String, dynamic>>> crbarang2(
      String username, String cari1, String kondisi1) async {
    final url = '$root/api.php?action=CRBARANG2';
    final Map<String, String> jsonData = {
      'user1': username,
      'cari1': cari1,
      'kondisi1': kondisi1,
    };

    var response = await http.post(Uri.parse(url),
        body: jsonEncode(jsonData),
        headers: {'Content-Type': 'application/json'});
    if (response.statusCode == 200) {
      List<dynamic> jsonData = jsonDecode(response.body);

      return List<Map<String, dynamic>>.from(jsonData);
    } else {
      throw Exception('Failed to fetch report data');
    }
  }

  static Future<List<Map<String, dynamic>>> crbarang3(
      String username, String cari1, String kondisi1) async {
    final url = '$root/api.php?action=CRBARANG3';
    final Map<String, String> jsonData = {
      'user1': username,
      'cari1': cari1,
      'kondisi1': kondisi1,
    };

    var response3 = await http.post(Uri.parse(url),
        body: jsonEncode(jsonData),
        headers: {'Content-Type': 'application/json'});
    if (response3.statusCode == 200) {
      List<dynamic> jsonData = jsonDecode(response3.body);

      return List<Map<String, dynamic>>.from(jsonData);
    } else {
      throw Exception('Failed to fetch report data');
    }
  }

  static Future<List<Map<String, dynamic>>> crcust(
      String username, String cari1, String kondisi1) async {
    final url = '$root/api.php?action=CARICUST';
    final Map<String, String> jsonData = {
      'user1': username,
      'cari1': cari1,
      'kondisi1': kondisi1,
    };

    var response = await http.post(Uri.parse(url),
        body: jsonEncode(jsonData),
        headers: {'Content-Type': 'application/json'});
    if (response.statusCode == 200) {
      List<dynamic> jsonData = jsonDecode(response.body);

      return List<Map<String, dynamic>>.from(jsonData);
    } else {
      throw Exception('Failed to fetch report data');
    }
  }

  static Future<List<Map<String, dynamic>>> inputtrans2(
      String kdbarang,
      String nqty,
      String nrp,
      String user,
      String kdcust,
      String ntop,
      String keth,
      String kdsales,
      String notrans,
      String lks1) async {
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

    var response = await http.post(Uri.parse(url),
        body: jsonEncode(jsonData),
        headers: {'Content-Type': 'application/json'});
    if (response.statusCode == 200) {
      List<dynamic> jsonData = jsonDecode(response.body);

      return List<Map<String, dynamic>>.from(jsonData);
    } else {
      throw Exception('Failed to fetch report data');
    }
  }

  static Future<List<Map<String, dynamic>>> inputtrans3(
      String kdbarang,
      String nqty,
      String nrp,
      String user,
      String kdcust,
      String ntop,
      String keth,
      String kdsales,
      String notrans,
      String lks1,
      String lmatang) async {
    final url = '$root/api.php?action=INPUTJL3';
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
      'lmatang1': lmatang,
    };

    var response = await http.post(Uri.parse(url),
        body: jsonEncode(jsonData),
        headers: {'Content-Type': 'application/json'});
    if (response.statusCode == 200) {
      List<dynamic> jsonData = jsonDecode(response.body);

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
    String asal,
  ) async {
    final url = '$root/api.php?action=BAYARJL2';
    final Map<String, String> jsonData = {
      'lks1': lks1,
      'nojual1': nojual1,
      'kdgl1': kdgl1,
      'nrp1': nrp1,
      'user1': user1,
      'asal1': asal,
    };

    var response = await http.post(Uri.parse(url),
        body: jsonEncode(jsonData),
        headers: {'Content-Type': 'application/json'});

    if (response.statusCode == 200) {
      List<dynamic> jsonData = jsonDecode(response.body);

      return List<Map<String, dynamic>>.from(jsonData);
    } else {
      throw Exception('Failed to fetch report data');
    }
  }

  static Future<List<Map<String, dynamic>>> lapjualx(
      String tgl1, String tgl2, String kondisi1, String lks1) async {
    final url =
        '$root/api.php?action=LAPJUALX&tgl1=$tgl1&tgl2=$tgl2&kondisi1=$kondisi1&lks1=$lks1';

    var response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      List<dynamic> jsonData = jsonDecode(response.body);

      return List<Map<String, dynamic>>.from(jsonData);
    } else {
      throw Exception('Failed to fetch report data');
    }
  }

  static Future<List<Map<String, dynamic>>> lapjual(
      String tgl1, String tgl2, String kondisi1, String lks1) async {
    final url = '$root/api.php?action=LAPJUAL';
    final Map<String, String> jsonData = {
      'tgl1': tgl1,
      'tgl2': tgl2,
      'kondisi1': kondisi1,
      'lks1': lks1,
    };
    var response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      List<dynamic> jsonData = jsonDecode(response.body);

      return List<Map<String, dynamic>>.from(jsonData);
    } else {
      throw Exception('Failed to fetch report data');
    }
  }

  static Future<List<Map<String, dynamic>>> lapjualperno(
      String user1, String notran1) async {
    final url = '$root/api.php?action=LAPJUALPERNO';
    final Map<String, String> jsonData = {
      'user1': user1,
      'notran1': notran1,
    };
    var response = await http.post(Uri.parse(url),
        body: jsonEncode(jsonData),
        headers: {'Content-Type': 'application/json'});
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
    var response = await http.post(Uri.parse(url),
        body: jsonEncode(jsonData),
        headers: {'Content-Type': 'application/json'});
    if (response.statusCode == 200) {
      List<dynamic> jsonData = jsonDecode(response.body);
      return List<Map<String, dynamic>>.from(jsonData);
    } else {
      throw Exception('Failed to fetch report data');
    }
  }

  static Future<List<Map<String, dynamic>>> lapstok(String user1, String lks1,
      String jenis1, String cari1, String kondisi1) async {
    final url = '$root/api.php?action=LAPSTOK';
    final Map<String, String> jsonData = {
      'user1': user1,
      'lks1': lks1,
      'jenis1': jenis1,
      'cari1': cari1,
      'kondisi1': kondisi1,
    };

    var response = await http.post(Uri.parse(url),
        body: jsonEncode(jsonData),
        headers: {'Content-Type': 'application/json'});
    if (response.statusCode == 200) {
      List<dynamic> jsonData = jsonDecode(response.body);
      return List<Map<String, dynamic>>.from(jsonData);
    } else {
      throw Exception('Failed to fetch report data');
    }
  }

  static Future<List<Map<String, dynamic>>> daftarharga(String user1,
      String lks1, String jenis1, String cari1, String kondisi1) async {
    final url = '$root/api.php?action=DAFTARHARGA';
    final Map<String, String> jsonData = {
      'user1': user1,
      'lks1': lks1,
      'jenis1': jenis1,
      'cari1': cari1,
      'kondisi1': kondisi1,
    };

    var response = await http.post(Uri.parse(url),
        body: jsonEncode(jsonData),
        headers: {'Content-Type': 'application/json'});
    if (response.statusCode == 200) {
      List<dynamic> jsonData = jsonDecode(response.body);
      return List<Map<String, dynamic>>.from(jsonData);
    } else {
      throw Exception('Failed to fetch report data');
    }
  }

  static Future<List<Map<String, dynamic>>> lapkascb(
      String tgl1, String user1, String lks1) async {
    final url = '$root/api.php?action=LAPKASCB';
    final Map<String, String> jsonData = {
      'user1': user1,
      'lks1': lks1,
      'tgl1': tgl1,
    };

    var response = await http.post(Uri.parse(url),
        body: jsonEncode(jsonData),
        headers: {'Content-Type': 'application/json'});

    if (response.statusCode == 200) {
      List<dynamic> jsonData = jsonDecode(response.body);

      return List<Map<String, dynamic>>.from(jsonData);
    } else {
      throw Exception('Failed to fetch report data');
    }
  }

  static Future<List<Map<String, dynamic>>> lapkascb2(
      String tgl1, String user1, String lks1, String kdgl1) async {
    final url = '$root/api.php?action=LAPKASCB2';
    final Map<String, String> jsonData = {
      'user1': user1,
      'lks1': lks1,
      'tgl1': tgl1,
      'kdgl1': kdgl1,
    };

    var response = await http.post(Uri.parse(url),
        body: jsonEncode(jsonData),
        headers: {'Content-Type': 'application/json'});

    if (response.statusCode == 200) {
      List<dynamic> jsonData = jsonDecode(response.body);

      return List<Map<String, dynamic>>.from(jsonData);
    } else {
      throw Exception('Failed to fetch report data');
    }
  }

  static Future<List<Map<String, dynamic>>> setorkascb(
      String user1, String lks1, String nrp1, String ket1) async {
    final url = '$root/api.php?action=SETOR';
    final Map<String, String> jsonData = {
      'user1': user1,
      'lks1': lks1,
      'nrp1': nrp1,
      'ket1': ket1,
    };

    final response = await http.post(
      Uri.parse(url),
      body: jsonEncode(jsonData),
      headers: {'Content-Type': 'application/json'},
    );

    // debugPrint('response.body: ${response.body}');

    if (response.statusCode == 200) {
      try {
        var decoded = jsonDecode(response.body);
        if (decoded is List) {
          return List<Map<String, dynamic>>.from(decoded);
        } else {
          throw Exception('Unexpected JSON format: not a list');
        }
      } catch (e) {
        throw Exception('Failed to parse server response');
      }
    } else {
      throw Exception('HTTP error: ${response.statusCode}');
    }
  }

  static Future<List<Map<String, dynamic>>> setorkascb2(
      String user1, String lks1, String nrp1, String ket1, String sisa1) async {
    final url = '$root/api.php?action=SETOR';
    final Map<String, String> jsonData = {
      'user1': user1,
      'lks1': lks1,
      'nrp1': nrp1,
      'ket1': ket1,
      'sisa1': sisa1,
    };

    final response = await http.post(
      Uri.parse(url),
      body: jsonEncode(jsonData),
      headers: {'Content-Type': 'application/json'},
    );

    // debugPrint('response.body: ${response.body}');

    if (response.statusCode == 200) {
      try {
        var decoded = jsonDecode(response.body);
        if (decoded is List) {
          return List<Map<String, dynamic>>.from(decoded);
        } else {
          throw Exception('Unexpected JSON format: not a list');
        }
      } catch (e) {
        throw Exception('Failed to parse server response');
      }
    } else {
      throw Exception('HTTP error: ${response.statusCode}');
    }
  }

  static Future<List<Map<String, dynamic>>> lihatsldkas(
      String user1, String lks1) async {
    final url = '$root/api.php?action=LIHATSLDKAS';
    final Map<String, String> jsonData = {
      'user1': user1,
      'lks1': lks1,
    };
    var response = await http.post(Uri.parse(url),
        body: jsonEncode(jsonData),
        headers: {'Content-Type': 'application/json'});

    if (response.statusCode == 200) {
      List<dynamic> jsonData = jsonDecode(response.body);
      print('hasil json : $jsonData');
      return List<Map<String, dynamic>>.from(jsonData);
    } else {
      throw Exception('Failed to fetch report data');
    }
  }

  static Future<List<Map<String, dynamic>>> carijual(
      String user1, String cari1, String kondisi1, String caritgl1) async {
    final url = '$root/api.php?action=CARIJUAL';

    final Map<String, String> jsonData = {
      'user1': user1,
      'cari1': cari1,
      'kondisi1': kondisi1,
      'caritgl1': caritgl1,
    };
    var response = await http.post(Uri.parse(url),
        body: jsonEncode(jsonData),
        headers: {'Content-Type': 'application/json'});

    if (response.statusCode == 200) {
      List<dynamic> jsonData = jsonDecode(response.body);

      return List<Map<String, dynamic>>.from(jsonData);
    } else {
      throw Exception('Failed to fetch report data');
    }
  }

  static Future<List<Map<String, dynamic>>> returjual(
      String notrans1,
      String lks1,
      String kdbarang1,
      String nqty1,
      String nrp1,
      String nojual1,
      String ket1,
      String user1) async {
    final url = '$root/api.php?action=RETJL';
    final Map<String, String> jsonData = {
      'notrans1': notrans1,
      'lks1': lks1,
      'kdbarang1': kdbarang1,
      'nqty1': nqty1,
      'nrp1': nrp1,
      'nojual1': nojual1,
      'ket1': ket1,
      'user1': user1,
    };
    print(url);
    print(jsonData);
    var response = await http.post(Uri.parse(url),
        body: jsonEncode(jsonData),
        headers: {'Content-Type': 'application/json'});

    if (response.statusCode == 200) {
      List<dynamic> jsonData = jsonDecode(response.body);

      return List<Map<String, dynamic>>.from(jsonData);
    } else {
      throw Exception('Failed to fetch report data');
    }
  }

  static Future<List<Map<String, dynamic>>> cariretjual(
      String user1, String lks1, String kondisi1, String cari1) async {
    final url = '$root/api.php?action=CARIRETJL';
    final Map<String, String> jsonData = {
      'user1': user1,
      'lks1': lks1,
      'kondisi1': kondisi1,
      'cari1': cari1,
    };

    var response = await http.post(Uri.parse(url),
        body: jsonEncode(jsonData),
        headers: {'Content-Type': 'application/json'});

    if (response.statusCode == 200) {
      List<dynamic> jsonData = jsonDecode(response.body);

      return List<Map<String, dynamic>>.from(jsonData);
    } else {
      throw Exception('Failed to fetch report data');
    }
  }

  static Future<List<Map<String, dynamic>>> lapjualkary(
      String user1,
      String lks1,
      String tgl1,
      String tgl2,
      String kdcust1,
      String kondisi1,
      String kondisi2,
      String kdbarang1) async {
    final url = '$root/api.php?action=LAPJUALKARY';

    final Map<String, String> jsonData = {
      'user1': user1,
      'lks1': lks1,
      'tgl1': tgl1,
      'tgl2': tgl2,
      'kdcust1': kdcust1,
      'kondisi1': kondisi1,
      'kondisi2': kondisi2,
      'kdbarang1': kdbarang1,
    };
    var response = await http.post(Uri.parse(url),
        body: jsonEncode(jsonData),
        headers: {'Content-Type': 'application/json'});

    if (response.statusCode == 200) {
      List<dynamic> jsonData = jsonDecode(response.body);

      return List<Map<String, dynamic>>.from(jsonData);
    } else {
      throw Exception('Failed to fetch report data');
    }
  }

  static Future<List<Map<String, dynamic>>> kirabayar(
      String user1, String lks1) async {
    final url = '$root/api.php?action=KIRABAYAR';
    final Map<String, String> jsonData = {
      'user1': user1,
      'lks1': lks1,
    };
    var response = await http.post(Uri.parse(url),
        body: jsonEncode(jsonData),
        headers: {'Content-Type': 'application/json'});
    if (response.statusCode == 200) {
      List<dynamic> jsonData = jsonDecode(response.body);
      return List<Map<String, dynamic>>.from(jsonData);
    } else {
      throw Exception('Failed to fetch report data');
    }
  }

  static Future<List<Map<String, dynamic>>> lapdaftarsetor(String user1,
      String lks1, String tgl1, String tgl2, String kondisi1) async {
    final url = '$root/api.php?action=DAFTARSETOR';

    final Map<String, String> jsonData = {
      'user1': user1.trim(),
      'lks1': lks1.trim(),
      'tgl1': DateFormat('yyyy-MM-dd')
          .format(DateTime.parse(tgl1)), // Formatting the date
      'tgl2': DateFormat('yyyy-MM-dd')
          .format(DateTime.parse(tgl2)), // Formatting the date
      'kondisi1': kondisi1.trim(),
    };

    var response = await http.post(
      Uri.parse(url),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(jsonData),
    );

    if (response.statusCode == 200) {
      List<dynamic> jsonData = jsonDecode(response.body);

      return List<Map<String, dynamic>>.from(jsonData);
    } else {
      throw Exception('Failed to fetch report data');
    }
  }

  static Future<List<Map<String, dynamic>>> lapdaftarblmbyr(
      String user1, String lks1, String tgl1, String tgl2) async {
    final url = '$root/api.php?action=DAFTARBLMBYR';

    final Map<String, String> jsonData = {
      'user1': user1.trim(),
      'lks1': lks1.trim(),
      'tgl1': DateFormat('yyyy-MM-dd')
          .format(DateTime.parse(tgl1)), // Formatting the date
      'tgl2': DateFormat('yyyy-MM-dd')
          .format(DateTime.parse(tgl2)), // Formatting the date
    };

    var response = await http.post(
      Uri.parse(url),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(jsonData),
    );

    if (response.statusCode == 200) {
      List<dynamic> jsonData = jsonDecode(response.body);

      return List<Map<String, dynamic>>.from(jsonData);
    } else {
      throw Exception('Failed to fetch report data');
    }
  }

  static Future<List<Map<String, dynamic>>> hapustran(
      String user, String urut1) async {
    final url = '$root/api.php?action=HAPUSJUAL';

    final Map<String, String> jsonData = {
      'user1': user,
      'urut1': urut1,
    };
    print(url);
    print(jsonData);

    var response = await http.post(Uri.parse(url),
        body: jsonEncode(jsonData),
        headers: {'Content-Type': 'application/json'});
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

import 'dart:convert';

import 'package:http/http.dart' as http;

class ApiService {
  static const root = "http://localhost/API_POS";

  static const _LOGIN_ACTION = "LOGIN";

  static Future<dynamic> login(String username, String password) async {
    final url = root +
        '/api.php?action=$_LOGIN_ACTION&username1=$username&password1=$password';
    // print(url);
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      final jsonResponse = jsonDecode(response.body);
      final bagian = jsonResponse['bagian'];
      final varpbuser = jsonResponse['userku'];
      final varniksales = jsonResponse['niksales'];
      final varkdsales = jsonResponse['kdsales'];
      final varnmuser = jsonResponse['nama'];

      return jsonResponse;
    } else {
      throw Exception('Failed to login.gAGAL LOGIN');
    }
  }

  static Future<String> gantiPassword(
      String varpbuser, String oldPassword, String newPassword) async {
    final url =
        '$root/api.php?action=GANTIPWD&pbuser1=$varpbuser&passlama=$oldPassword&passbaru=$newPassword';
    final response = await http.post(Uri.parse(url));

    if (response.statusCode == 200) {
      final jsonResponse = json.decode(response.body);
      final hasil = jsonResponse[0]['@hasil'];

      if (hasil == 'Gagal, password lama salah') {
        return 'Password Lama Anda Salah';
      } else if (hasil == 'Sukses') {
        return 'Ganti Password Berhasil';
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

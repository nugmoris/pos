import 'dart:convert';

import 'package:http/http.dart' as http;

class ApiService {
  //  static const root = "http://103.80.96.26/tuing_pos";
  static const root = "http://103.80.96.26/pos_copy";
  //  static const root = "http://103.80.96.26/pos_coba";
  static const action = "LOGIN";

  // Cache untuk menyimpan data sementara
  static Map<String, dynamic> _cache = {};
  static Duration _cacheTimeout = Duration(minutes: 5);

  // Method untuk mengambil data dengan pagination
  static Future<Map<String, dynamic>> lapjualpanjangPaginated(
    String tgl1,
    String tgl2,
    String kondisi1,
    String lks1,
    int page,
    int limit,
  ) async {
    final url = '$root/api.php?action=LAPJUALPANJANGPAGINATED'
        '&tgl1=$tgl1&tgl2=$tgl2&kondisi1=$kondisi1&lks1=$lks1'
        '&page=$page&limit=$limit';

    var response = await http.get(Uri.parse(url));
    print('lapjualpanjangpaginated');
    print(url);
    print('Response body JSON: ${response.body}');
    if (response.statusCode == 200) {
      Map<String, dynamic> jsonData = jsonDecode(response.body);
      print('Response body JSON: ${response.body}');
      print('Parsed JSON: $jsonData');
      print('Grand Total (from JSON): ${jsonData['grandTotal']}');

      return {
        'data': List<Map<String, dynamic>>.from(jsonData['data']),
        'total': jsonData['total'],
        'grandTotal': jsonData['grandTotal'], // ← Tambahkan ini
        'hasMore': jsonData['hasMore'],
        'currentPage': page,
      };
    } else {
      throw Exception('Failed to fetch report data');
      print('coba2');
    }
  }

  // Method untuk mengambil ringkasan data
  static Future<Map<String, dynamic>> lapjualsummary(
    String tgl1,
    String tgl2,
    String lks1,
  ) async {
    final cacheKey = 'summary_${tgl1}_${tgl2}_$lks1';
    print('lapjualsummary');
    // Cek cache terlebih dahulu
    if (_cache.containsKey(cacheKey)) {
      final cachedData = _cache[cacheKey];
      if (DateTime.now()
              .difference(cachedData['timestamp'])
              .compareTo(_cacheTimeout) <
          0) {
        return cachedData['data'];
      }
    }

    final url = '$root/api.php?action=LAPJUALSUMMARY'
        '&tgl1=$tgl1&tgl2=$tgl2&lks1=$lks1';
    print(url);
    var response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      Map<String, dynamic> jsonData = jsonDecode(response.body);

      // Simpan ke cache
      _cache[cacheKey] = {
        'data': jsonData,
        'timestamp': DateTime.now(),
      };

      return jsonData;
    } else {
      throw Exception('Failed to fetch summary data');
    }
  }

  // Method untuk mengambil data dengan filter tanggal yang lebih cerdas
  static Future<List<Map<String, dynamic>>> lapjualpanjangOptimized(
      String tgl1, String tgl2, String kondisi1, String lks1,
      {int? limit}) async {
    final url = '$root/api.php?action=LAPJUALPANJANGOPTIMIZED'
        '&tgl1=$tgl1&tgl2=$tgl2&kondisi1=$kondisi1&lks1=$lks1'
        '${limit != null ? '&limit=$limit' : ''}';

    var response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      List<dynamic> jsonData = jsonDecode(response.body);
      return List<Map<String, dynamic>>.from(jsonData);
    } else {
      throw Exception('Failed to fetch report data');
    }
  }

  // Method untuk export data
  static Future<String> exportLapjual(
    String tgl1,
    String tgl2,
    String kondisi1,
    String lks1,
    String format, // 'excel' atau 'pdf'
  ) async {
    final url = '$root/api.php?action=EXPORTLAPJUAL'
        '&tgl1=$tgl1&tgl2=$tgl2&kondisi1=$kondisi1&lks1=$lks1&format=$format';

    var response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      Map<String, dynamic> jsonData = jsonDecode(response.body);
      return jsonData['download_url'];
    } else {
      throw Exception('Failed to export data');
    }
  }

  // Method untuk mengambil statistik harian
  static Future<List<Map<String, dynamic>>> getStatistikHarian(
    String tgl1,
    String tgl2,
    String lks1,
  ) async {
    final url = '$root/api.php?action=STATISTIKHARIAN'
        '&tgl1=$tgl1&tgl2=$tgl2&lks1=$lks1';

    var response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      List<dynamic> jsonData = jsonDecode(response.body);
      return List<Map<String, dynamic>>.from(jsonData);
    } else {
      throw Exception('Failed to fetch statistics');
    }
  }

  // Method original untuk backward compatibility
  static Future<List<Map<String, dynamic>>> lapjualpanjang(
      String tgl1, String tgl2, String kondisi1, String lks1) async {
    final url = '$root/api.php?action=LAPJUALPANJANG'
        '&tgl1=$tgl1&tgl2=$tgl2&kondisi1=$kondisi1&lks1=$lks1';

    var response = await http.get(Uri.parse(url));
    print('lapjualpanjang');
    if (response.statusCode == 200) {
      List<dynamic> jsonData = jsonDecode(response.body);
      return List<Map<String, dynamic>>.from(jsonData);
    } else {
      throw Exception('Failed to fetch report data');
    }
  }

  // Method untuk clear cache
  static void clearCache() {
    _cache.clear();
  }

  // Method untuk login (existing)
  static Future<Map<String, String>> login2(String username, String password,
      String alamatmac, String myversion1) async {
    final url = '$root/api.php?action=LOGIN3';

    var response = await http.post(
      Uri.parse(url),
      body: jsonEncode({
        'username': username,
        'password': password,
        'alamatmac': alamatmac,
        'myversion1': myversion1,
      }),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      Map<String, dynamic> jsonData = jsonDecode(response.body);
      return Map<String, String>.from(jsonData);
    } else {
      throw Exception('Failed to login');
    }
  }
}

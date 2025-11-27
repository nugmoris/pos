import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pos/login.dart';

//import 'package:ota_update/ota_update.dart';

import 'daftablmbyr.dart';
import 'daftarharga.dart';
import 'daftarsetor.dart';
import 'home.dart';
import 'jual2.dart';
import 'lapkas.dart';
import 'laporan.dart';
import 'lapstok.dart';
import 'penjkary.dart';
import 'returjual.dart';
import 'service.dart';
import 'setor.dart';

// Define myversion variable
String myversion1 = 'POS30';
String currentVersion = '';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // currentVersion = await getCurrentVersion(); // Dihapus agar tidak error timeout
  // await checkAndUpdateApp(); // Dihapus agar tidak error timeout
  runApp(ProviderScope(child: MyApp()));
}

Future<String> getCurrentVersion() async {
  final result1 = await ApiService.cekversi();

  final version = result1['versiku'] ?? ''; // Access the 'versiku' key directly

  return version;
}

Future<String> getserverupdate() async {
  final result2 = await ApiService.serverupdate();
  final serverupdate = result2['serverupdate'];
  return serverupdate
      .toString(); // Convert serverupdate to a String before returning
}

Future<void> checkAndUpdateApp() async {
  if (currentVersion != myversion1) {
    final serverUpdateUrlx = await getserverupdate();
    final apkUrl = '$serverUpdateUrlx/$currentVersion.apk';
    // Tampilkan dialog konfirmasi update
    // Karena belum ada context di sini, update akan dicek ulang di halaman LoginPage
  }
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'My App',
      theme: ThemeData(
        primarySwatch: Colors.grey,
      ),
      initialRoute: '/',
      routes: {
        // '/login': (context) => LoginPage(),
        '/': (context) =>
            LoginPage(myversion1: myversion1, currentVersion: currentVersion),
        '/login': (context) =>
            LoginPage(myversion1: myversion1, currentVersion: currentVersion),
        '/home': (context) {
          final args =
              ModalRoute.of(context)?.settings.arguments as List<dynamic>?;
          final varpbuser =
              args?.isNotEmpty == true ? args![0] as String? : null;
          final varbagian =
              args?.isNotEmpty == true ? args![1] as String? : null;
          final varlks = args?.isNotEmpty == true ? args![2] as String? : null;
          final varnmlok =
              args?.isNotEmpty == true ? args![3] as String? : null;
          final varsaldokas =
              args?.isNotEmpty == true ? args![4] as String? : null;

          return HomeSalesPage(varpbuser!, varbagian!, varlks!, varnmlok!,
              myversion1!, currentVersion!);
        },
        '/jual': (context) {
          final args =
              ModalRoute.of(context)?.settings.arguments as List<dynamic>?;
          final varpbuser =
              args?.isNotEmpty == true ? args![0] as String? : null;
          final varbagian =
              args?.isNotEmpty == true ? args![1] as String? : null;
          final varlks = args?.isNotEmpty == true ? args![2] as String? : null;
          final varnmlok =
              args?.isNotEmpty == true ? args![3] as String? : null;
          final varsaldokas =
              args?.isNotEmpty == true ? args![4] as String? : null;
          return JualPage2(
              varpbuser!, varbagian!, varlks!, varnmlok!, varsaldokas!);
        },
        '/lapjual': (context) {
          final args =
              ModalRoute.of(context)?.settings.arguments as List<dynamic>?;
          final varpbuser =
              args?.isNotEmpty == true ? args![0] as String? : null;
          final varbagian =
              args?.isNotEmpty == true ? args![1] as String? : null;
          final varlks = args?.isNotEmpty == true ? args![2] as String? : null;
          final varnmlok =
              args?.isNotEmpty == true ? args![3] as String? : null;

          return LapPage(varpbuser!, varbagian!, varlks!, varnmlok!);
        },

        '/returjual': (context) {
          final args =
              ModalRoute.of(context)?.settings.arguments as List<dynamic>?;
          final varpbuser =
              args?.isNotEmpty == true ? args![0] as String? : null;
          final varbagian =
              args?.isNotEmpty == true ? args![1] as String? : null;
          final varlks = args?.isNotEmpty == true ? args![2] as String? : null;
          final varnmlok =
              args?.isNotEmpty == true ? args![3] as String? : null;
          final varsaldokas =
              args?.isNotEmpty == true ? args![4] as String? : null;
          return ReturJualPage(
              varpbuser!, varbagian!, varlks!, varnmlok!, varsaldokas!);
        },

        '/daftarsetor': (context) {
          final args =
              ModalRoute.of(context)?.settings.arguments as List<dynamic>?;
          final varpbuser =
              args?.isNotEmpty == true ? args![0] as String? : null;
          final varbagian =
              args?.isNotEmpty == true ? args![1] as String? : null;
          final varlks = args?.isNotEmpty == true ? args![2] as String? : null;
          final varnmlok =
              args?.isNotEmpty == true ? args![3] as String? : null;

          return DaftarSetorPage(varpbuser!, varbagian!, varlks!, varnmlok!);
        },

        '/daftarblmlunas': (context) {
          final args =
              ModalRoute.of(context)?.settings.arguments as List<dynamic>?;
          final varpbuser =
              args?.isNotEmpty == true ? args![0] as String? : null;
          final varbagian =
              args?.isNotEmpty == true ? args![1] as String? : null;
          final varlks = args?.isNotEmpty == true ? args![2] as String? : null;
          final varnmlok =
              args?.isNotEmpty == true ? args![3] as String? : null;

          return DaftarBlmByrPage(varpbuser!, varbagian!, varlks!, varnmlok!);
        },

        '/lapstok': (context) {
          final args =
              ModalRoute.of(context)?.settings.arguments as List<dynamic>?;
          final varpbuser =
              args?.isNotEmpty == true ? args![0] as String? : null;
          final varbagian =
              args?.isNotEmpty == true ? args![1] as String? : null;
          final varlks = args?.isNotEmpty == true ? args![2] as String? : null;
          final varnmlok =
              args?.isNotEmpty == true ? args![3] as String? : null;

          return LapStok(varpbuser!, varbagian!, varlks!, varnmlok!);
        },
        '/daftarharga': (context) {
          final args =
              ModalRoute.of(context)?.settings.arguments as List<dynamic>?;
          final varpbuser =
              args?.isNotEmpty == true ? args![0] as String? : null;
          final varbagian =
              args?.isNotEmpty == true ? args![1] as String? : null;
          final varlks = args?.isNotEmpty == true ? args![2] as String? : null;
          final varnmlok =
              args?.isNotEmpty == true ? args![3] as String? : null;

          return DaftarHarga(varpbuser!, varbagian!, varlks!, varnmlok!);
        },

        '/lapkas': (context) {
          final args =
              ModalRoute.of(context)?.settings.arguments as List<dynamic>?;
          final varpbuser =
              args?.isNotEmpty == true ? args![0] as String? : null;
          final varbagian =
              args?.isNotEmpty == true ? args![1] as String? : null;
          final varlks = args?.isNotEmpty == true ? args![2] as String? : null;
          final varnmlok =
              args?.isNotEmpty == true ? args![3] as String? : null;

          return LapKas(varpbuser!, varbagian!, varlks!, varnmlok!);
        },

        '/setor': (context) {
          final args =
              ModalRoute.of(context)?.settings.arguments as List<dynamic>?;
          final varpbuser =
              args?.isNotEmpty == true ? args![0] as String? : null;
          final varbagian =
              args?.isNotEmpty == true ? args![1] as String? : null;
          final varlks = args?.isNotEmpty == true ? args![2] as String? : null;
          final varnmlok =
              args?.isNotEmpty == true ? args![3] as String? : null;

          return Setor(varpbuser!, varbagian!, varlks!, varnmlok!);
        },

        '/penjkary': (context) {
          final args =
              ModalRoute.of(context)?.settings.arguments as List<dynamic>?;
          final varpbuser =
              args?.isNotEmpty == true ? args![0] as String? : null;
          final varbagian =
              args?.isNotEmpty == true ? args![1] as String? : null;
          final varlks = args?.isNotEmpty == true ? args![2] as String? : null;
          final varnmlok =
              args?.isNotEmpty == true ? args![3] as String? : null;

          return Penjkary(varpbuser!, varbagian!, varlks!, varnmlok!);
        },
      },
    );
  }
}

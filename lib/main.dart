import 'package:flutter/material.dart';
import 'package:ota_update/ota_update.dart';

import 'daftarharga.dart';
import 'home.dart';
import 'jual.dart';
import 'lapkas.dart';
import 'laporan.dart';
import 'lapstok.dart';
import 'login.dart';
import 'penjkary.dart';
import 'service.dart';
import 'setor.dart';

// Define myversion variable
String myversion = 'POS1';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  tryOtaUpdateIfNeeded();
  runApp(MyApp());
}

Future<String> getCurrentVersion() async {
  final result1 = await ApiService.cekversi();

  final version = result1['versiku']; // Access the 'versiku' key directly
  return version;
}

Future<String> getserverupdate() async {
  final result2 = await ApiService.serverupdate();
  final serverupdate = result2['serverupdate'];

  return serverupdate.toString(); // Convert serverupdate to a String before returning
}

void tryOtaUpdateIfNeeded() async {
  final currentVersion = await getCurrentVersion();
  if (currentVersion != myversion) {
    final serverUpdateUrlx = await getserverupdate();
    final serverupdateUrl = '$serverUpdateUrlx/$currentVersion.apk';
    tryOtaUpdate(serverupdateUrl); // Memanggil tryOtaUpdate() dengan serverUpdateUrl
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
        '/': (context) => LoginPage(),
        '/login': (context) => LoginPage(),
        // '/lapjual': (context) => LapPage(),
        '/home': (context) {
          final args = ModalRoute.of(context)?.settings.arguments as List<dynamic>?;
          final varpbuser = args?.isNotEmpty == true ? args![0] as String? : null;
          final varbagian = args?.isNotEmpty == true ? args![1] as String? : null;
          final varlks = args?.isNotEmpty == true ? args![2] as String? : null;
          final varnmlok = args?.isNotEmpty == true ? args![3] as String? : null;
          final varsaldokas = args?.isNotEmpty == true ? args![4] as String? : null;

          return HomeSalesPage(varpbuser!, varbagian!, varlks!, varnmlok!, varsaldokas!);
        },
        '/jual': (context) {
          final args = ModalRoute.of(context)?.settings.arguments as List<dynamic>?;
          final varpbuser = args?.isNotEmpty == true ? args![0] as String? : null;
          final varbagian = args?.isNotEmpty == true ? args![1] as String? : null;
          final varlks = args?.isNotEmpty == true ? args![2] as String? : null;
          final varnmlok = args?.isNotEmpty == true ? args![3] as String? : null;

          return JualPage(varpbuser!, varbagian!, varlks!, varnmlok!);
        },
        '/lapjual': (context) {
          final args = ModalRoute.of(context)?.settings.arguments as List<dynamic>?;
          final varpbuser = args?.isNotEmpty == true ? args![0] as String? : null;
          final varbagian = args?.isNotEmpty == true ? args![1] as String? : null;
          final varlks = args?.isNotEmpty == true ? args![2] as String? : null;
          final varnmlok = args?.isNotEmpty == true ? args![3] as String? : null;

          return LapPage(varpbuser!, varbagian!, varlks!, varnmlok!);
        },

        '/lapstok': (context) {
          final args = ModalRoute.of(context)?.settings.arguments as List<dynamic>?;
          final varpbuser = args?.isNotEmpty == true ? args![0] as String? : null;
          final varbagian = args?.isNotEmpty == true ? args![1] as String? : null;
          final varlks = args?.isNotEmpty == true ? args![2] as String? : null;
          final varnmlok = args?.isNotEmpty == true ? args![3] as String? : null;

          return LapStok(varpbuser!, varbagian!, varlks!, varnmlok!);
        },
        '/daftarharga': (context) {
          final args = ModalRoute.of(context)?.settings.arguments as List<dynamic>?;
          final varpbuser = args?.isNotEmpty == true ? args![0] as String? : null;
          final varbagian = args?.isNotEmpty == true ? args![1] as String? : null;
          final varlks = args?.isNotEmpty == true ? args![2] as String? : null;
          final varnmlok = args?.isNotEmpty == true ? args![3] as String? : null;

          return DaftarHarga(varpbuser!, varbagian!, varlks!, varnmlok!);
        },

        '/lapkas': (context) {
          final args = ModalRoute.of(context)?.settings.arguments as List<dynamic>?;
          final varpbuser = args?.isNotEmpty == true ? args![0] as String? : null;
          final varbagian = args?.isNotEmpty == true ? args![1] as String? : null;
          final varlks = args?.isNotEmpty == true ? args![2] as String? : null;
          final varnmlok = args?.isNotEmpty == true ? args![3] as String? : null;

          return LapKas(varpbuser!, varbagian!, varlks!, varnmlok!);
        },

        '/setor': (context) {
          final args = ModalRoute.of(context)?.settings.arguments as List<dynamic>?;
          final varpbuser = args?.isNotEmpty == true ? args![0] as String? : null;
          final varbagian = args?.isNotEmpty == true ? args![1] as String? : null;
          final varlks = args?.isNotEmpty == true ? args![2] as String? : null;
          final varnmlok = args?.isNotEmpty == true ? args![3] as String? : null;

          return Setor(varpbuser!, varbagian!, varlks!, varnmlok!);
        },

        '/penjkary': (context) {
          final args = ModalRoute.of(context)?.settings.arguments as List<dynamic>?;
          final varpbuser = args?.isNotEmpty == true ? args![0] as String? : null;
          final varbagian = args?.isNotEmpty == true ? args![1] as String? : null;
          final varlks = args?.isNotEmpty == true ? args![2] as String? : null;
          final varnmlok = args?.isNotEmpty == true ? args![3] as String? : null;

          return Penjkary(varpbuser!, varbagian!, varlks!, varnmlok!);
        },
      },
    );
  }
}

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // print("Building HomePage");
    return Container(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: SingleChildScrollView(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(height: 590.0),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      backgroundColor: Colors.red, // Warna latar belakang
                    ),
                    onPressed: () {
                      Navigator.pushNamed(context, '/login');
                    },
                    child: Text('Login', style: TextStyle(color: Colors.white)),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

void tryOtaUpdate(String serverUpdateUrl) async {
  try {
    // print('ABI Platform: ${await OtaUpdate().getAbi()}');
    // print('bla..bla..bla  ');
    final lokupdateku = '$serverUpdateUrl';
    //  print(lokupdateku);
    OtaUpdate()
        .execute(
      lokupdateku, // Menggunakan serverUpdateUrl sebagai URL
      destinationFilename: 'pos1.apk',
    )
        .listen((OtaEvent event) {
      // Handle OTA update events here
    });
    // print(myversion);
    // print('menjalankan otaupdate');
  } catch (e) {
    print('Failed to make OTA update. Details: $e');
  }
}

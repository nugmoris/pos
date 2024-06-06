import 'package:flutter/material.dart';
import 'package:ota_update/ota_update.dart';

import 'jual.dart';
import 'laporan.dart';
import 'login.dart';
import 'service.dart';

// Define myversion variable
String myversion = 'POS2';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  tryOtaUpdateIfNeeded();
  runApp(MyApp());
}

Future<String> getCurrentVersion() async {
  final result1 = await ApiService.cekversi();
  // print(result1.toString());
  final version = result1['versiku']; // Access the 'versiku' key directly

  return version;
}

Future<String> getserverupdate() async {
  final result2 = await ApiService.serverupdate();
  final serverupdate = result2['serverupdate'];
  //print('serverupdate : $serverupdate');
  return serverupdate
      .toString(); // Convert serverupdate to a String before returning
}

void tryOtaUpdateIfNeeded() async {
  final currentVersion = await getCurrentVersion();
  if (currentVersion != myversion) {
    final serverUpdateUrlx = await getserverupdate();
    final serverupdateUrl = '$serverUpdateUrlx/$currentVersion.apk';
    //print('ini lokasi update');
    // print(serverupdateUrl); // Mendapatkan nilai serverupdate
    tryOtaUpdate(
        serverupdateUrl); // Memanggil tryOtaUpdate() dengan serverUpdateUrl
    //print('update');
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
        '/jual': (context) => JualPage(),
        '/lapjual': (context) => LapPage(),

        // '/jual': (context) {
        //   final args = ModalRoute.of(context)?.settings.arguments
        //       as Map<String, String>?;
        //   final bagian = args?['bagian'];

        //   return JualPage(bagian!);
        // },
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

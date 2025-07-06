import 'dart:io';

import 'package:android_id/android_id.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:open_file_plus/open_file_plus.dart';
import 'package:pos/main.dart' show getCurrentVersion, getserverupdate;
import 'package:pos/utils/textisi.dart';
import 'package:pos/var_provider.dart';

import 'service.dart';

class LoginPage extends ConsumerStatefulWidget {
  final String myversion1;
  final String? currentVersion;

  LoginPage({required this.myversion1, this.currentVersion});

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  TextEditingController _usernameController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();
  String _error = '';
  String alamatmac = '';
  String nmdevice = '';

  static const _androidIdPlugin = AndroidId();
  String? _androidId = 'Unknown';

  @override
  void initState() {
    super.initState();
    _initAndroidId();
    getDeviceInfo();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      String? serverVersion = widget.currentVersion;
      if (serverVersion == null || serverVersion.isEmpty) {
        serverVersion = await getCurrentVersion();
      }
      // print('Versi lokal: \\${widget.myversion1}\\, versi server: \\${serverVersion}\\');
      if (serverVersion != widget.myversion1) {
        _checkUpdateIfNeeded(serverVersion ?? '');
      }
    });
  }

  Future<void> _initAndroidId() async {
    final String? androidId = await _androidIdPlugin.getId();
    setState(() => _androidId = androidId);
  }

  void getDeviceInfo() async {
    // Optional: Implementasikan jika diperlukan
  }

  Future<void> login() async {
    final varpbuser = _usernameController.text;
    final password = _passwordController.text;
    alamatmac = _androidId ?? 'Unknown';
    print('Login $varpbuser - $password');
    try {
      final result = await ApiService.login2(
          varpbuser, password, alamatmac, widget.currentVersion ?? '');

      if (result.isNotEmpty) {
        final varbagian = result['bagian'];
        final varlks = result['lks'] as String?;
        final varnmlok = result['nmlok'];
        final varsaldokas = result['saldokas'];

        if (varbagian == 'sales') {
          try {
            // Konversi varsaldokas ke double
            final saldoKas = double.parse(varsaldokas ?? '0.0');

            // Perbarui nilai saldoKas di provider
            ref.read(saldoProvider.notifier).state = saldoKas;

            // print('Saldo kas login: $saldoKas');
          } catch (e) {
            // print('Gagal mengonversi saldoKas: $e');
          }
          //  print('Saldo kas login: $varsaldokas');

          Navigator.pushNamed(context, '/home',
              arguments: [varpbuser, varbagian, varlks, varnmlok, varsaldokas]);
        } else if (varbagian == 'Error') {
          setState(() {
            _error = 'Login gagal..User/password salah/tidak aktif';
          });
        }
      } else {
        setState(() {
          _error = 'Login failed';
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Tidak konek ke server';
      });
    }
  }

  Future<void> _checkUpdateIfNeeded(String serverVersion) async {
    print('Memanggil dialog update untuk versi: ' + serverVersion);
    final serverUpdateUrlx = await getserverupdate();
    final apkUrl = '$serverUpdateUrlx/$serverVersion.apk';
    final confirm = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text('Update Tersedia'),
        content: Text(
            'Versi terbaru aplikasi tersedia. Apakah Anda ingin mengunduh dan menginstal versi terbaru?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text('Update'),
          ),
        ],
      ),
    );
    print('Hasil konfirmasi update: $confirm');
    if (confirm == true) {
      await _downloadAndInstallApk(apkUrl, serverVersion);
    }
  }

  Future<void> _downloadAndInstallApk(
      String apkUrl, String serverVersion) async {
    print('Mulai download APK dari: $apkUrl');
    final downloadDir = Directory('/storage/emulated/0/Download');
    final apkPath = '${downloadDir.path}/$serverVersion.apk';
    print('APK akan disimpan di: $apkPath');
    final dio = Dio();
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text('Mengunduh Update'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Sedang mengunduh file APK...'),
          ],
        ),
      ),
    );
    try {
      await dio.download(apkUrl, apkPath);
      print('Download selesai');
      Navigator.of(context).pop(); // Tutup dialog loading

      final result = await OpenFile.open(apkPath);
      print('OpenFile result: ${result.message}');

      print('Perintah install APK sudah dipanggil');
    } catch (e) {
      print('Error download/install: $e');
      Navigator.of(context).pop();
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Gagal Update'),
          content: Text('Gagal mengunduh atau menginstal APK: $e'),
          actions: [
            TextButton(
                onPressed: () => Navigator.of(context).pop(), child: Text('OK'))
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.lock_outline_rounded,
              size: 62.0,
            ),
            SizedBox(height: 8),
            Text(
              "Hallo Silahkan Login.. ! ",
              style: TextStyle(color: Colors.grey[700], fontSize: 16),
            ),
            SizedBox(height: 20),
            TextIsi(
                controller: _usernameController,
                hintText: 'Username',
                labeltextku: 'Username',
                obsecuretext: false),
            SizedBox(height: 20),
            TextIsi(
                controller: _passwordController,
                hintText: 'Password',
                labeltextku: 'Password',
                obsecuretext: true),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: login,
              child: Text('Login'),
            ),
            Text(_error, style: TextStyle(color: Colors.red)),
            Text(
              "---Koperasi Kasih----",
              style: TextStyle(color: Colors.grey[700], fontSize: 16),
            ),
            SizedBox(height: 10),
            Text(
              " (versi ${widget.myversion1} / ${widget.currentVersion})",
              style: TextStyle(color: Colors.grey[700], fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }
}

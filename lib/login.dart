import 'dart:io';

import 'package:android_id/android_id.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:open_file/open_file.dart';
import 'package:pos/main.dart';
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
  bool _isLoading = false;
  bool _obscurePassword = true;

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
        _checkUpdateIfNeeded(serverVersion);
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
    if (_isLoading) return;
    
    final varpbuser = _usernameController.text.trim();
    final password = _passwordController.text.trim();
    
    if (varpbuser.isEmpty || password.isEmpty) {
      setState(() {
        _error = 'Username dan password harus diisi';
      });
      return;
    }
    
    setState(() {
      _isLoading = true;
      _error = '';
    });
    
    alamatmac = _androidId ?? 'Unknown';
    // print('Login $varpbuser - $password');
    try {
      final result = await ApiService.login2(
          varpbuser, password, alamatmac, widget.myversion1);

      if (result.isNotEmpty) {
        final varbagian = result['bagian'];
        final varlks = result['lks'];
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
            _isLoading = false;
          });
        }
      } else {
        setState(() {
          _error = 'Login failed';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Tidak konek ke server';
        _isLoading = false;
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
    final size = MediaQuery.of(context).size;
    
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF667EEA),
              Color(0xFF764BA2),
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Logo/Icon Section
                  Container(
                    padding: EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.lock_outline_rounded,
                      size: 64.0,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 32),
                  
                  // Welcome Text
                  Text(
                    "Selamat Datang",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    "Silakan login untuk melanjutkan",
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: 16,
                    ),
                  ),
                  SizedBox(height: 48),
                  
                  // Login Card
                  Container(
                    width: size.width > 400 ? 400 : size.width,
                    padding: EdgeInsets.all(32),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 20,
                          offset: Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Username Field
                        TextField(
                          controller: _usernameController,
                          decoration: InputDecoration(
                            labelText: 'Username',
                            hintText: 'Masukkan username',
                            prefixIcon: Icon(Icons.person_outline, color: Color(0xFF667EEA)),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(color: Colors.grey.shade300),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(color: Colors.grey.shade300),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(color: Color(0xFF667EEA), width: 2),
                            ),
                            filled: true,
                            fillColor: Colors.grey.shade50,
                            contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                          ),
                          textInputAction: TextInputAction.next,
                        ),
                        SizedBox(height: 20),
                        
                        // Password Field
                        TextField(
                          controller: _passwordController,
                          obscureText: _obscurePassword,
                          decoration: InputDecoration(
                            labelText: 'Password',
                            hintText: 'Masukkan password',
                            prefixIcon: Icon(Icons.lock_outline, color: Color(0xFF667EEA)),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                                color: Colors.grey.shade600,
                              ),
                              onPressed: () {
                                setState(() {
                                  _obscurePassword = !_obscurePassword;
                                });
                              },
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(color: Colors.grey.shade300),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(color: Colors.grey.shade300),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(color: Color(0xFF667EEA), width: 2),
                            ),
                            filled: true,
                            fillColor: Colors.grey.shade50,
                            contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                          ),
                          textInputAction: TextInputAction.done,
                          onSubmitted: (_) => login(),
                        ),
                        SizedBox(height: 24),
                        
                        // Error Message
                        if (_error.isNotEmpty)
                          Container(
                            padding: EdgeInsets.all(12),
                            margin: EdgeInsets.only(bottom: 16),
                            decoration: BoxDecoration(
                              color: Colors.red.shade50,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.red.shade200),
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.error_outline, color: Colors.red.shade700, size: 20),
                                SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    _error,
                                    style: TextStyle(
                                      color: Colors.red.shade700,
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        
                        // Login Button
                        Container(
                          height: 56,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            gradient: LinearGradient(
                              colors: [
                                Color(0xFF667EEA),
                                Color(0xFF764BA2),
                              ],
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Color(0xFF667EEA).withOpacity(0.4),
                                blurRadius: 12,
                                offset: Offset(0, 6),
                              ),
                            ],
                          ),
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : login,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.transparent,
                              shadowColor: Colors.transparent,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: _isLoading
                                ? SizedBox(
                                    height: 24,
                                    width: 24,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                    ),
                                  )
                                : Text(
                                    'Login',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 32),
                  
                  // Footer
                  Column(
                    children: [
                      Text(
                        "Koperasi Kasih",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 1,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        "Versi ${widget.myversion1}${widget.currentVersion != null ? ' / ${widget.currentVersion}' : ''}",
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.8),
                          fontSize: 12,
                        ),
                      ),
                    ],
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

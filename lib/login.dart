import 'package:android_id/android_id.dart';
import 'package:flutter/material.dart';
import 'package:pos/utils/textisi.dart';

import 'service.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  TextEditingController _usernameController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();
  String _error = '';
  String alamatmac = '';
  String nmdevice = '';

  void getDeviceInfo() async {}
  static const _androidIdPlugin = AndroidId();
  String? _androidId = 'Unknown';

  @override
  void initState() {
    super.initState();
    _initAndroidId();
    getDeviceInfo();
  }

  Future<void> _initAndroidId() async {
    final String? androidId = await _androidIdPlugin.getId();
    setState(() => _androidId = androidId);
  }

  Future<void> login() async {
    final varpbuser = _usernameController.text;
    final password = _passwordController.text;
    alamatmac = _androidId ?? 'Unknown';
    try {
      final result = await ApiService.login2(varpbuser, password, alamatmac);

      if (result.isNotEmpty) {
        final varbagian = result['bagian'];
        final varlks = result['lks'];
        final varnmlok = result['nmlok'];
        final varsaldokas = result['saldokas'];
        if (varbagian == 'sales') {
          Navigator.pushNamed(context, '/home', arguments: [varpbuser, varbagian, varlks, varnmlok, varsaldokas]);
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
              "Silahkan Login ! (ver 1.0.2)",
              style: TextStyle(color: Colors.grey[700], fontSize: 16),
            ),
            SizedBox(height: 20),
            TextIsi(controller: _usernameController, hintText: 'Username', labeltextku: 'Username', obsecuretext: false),
            SizedBox(height: 20),
            TextIsi(controller: _passwordController, hintText: 'Password', labeltextku: 'Password', obsecuretext: true),
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
          ],
        ),
      ),
    );
  }
}

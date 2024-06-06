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

  Future<void> login() async {
    final username = _usernameController.text;
    final password = _passwordController.text;

    try {
      final bagian = await ApiService.login2(username, password);
      //print('wooii..1');
      //print(bagian); // Cetak bagian untuk memastikan nilai yang diterima

      if (bagian.isNotEmpty) {
        if (bagian == 'sales') {
          Navigator.pushNamed(context, '/jual');
        } else if (bagian == 'Error') {
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
              "Silahkan Loginnn ! (ver 1.0.2)",
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
          ],
        ),
      ),
    );
  }
}

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

  //static const _androidIdPlugin = AndroidId();

  void initState() {
    super.initState();
  }

  Future<void> login() async {
    final username = _usernameController.text;
    final password = _passwordController.text;

    try {
      final response = await ApiService.login(username, password);
      if (response.isNotEmpty) {
        final jabatan = response[0]['jabatan'];
        final varpbuser = response[0]['user'];
        final varidagen1 = response[0]['idagen'];
        final varidsubagen1 = response[0]['idsubagen'];
        final versiapp = response[0]['versiapp'];
        final varhutagen = response[0]['hutagen'];
        final varhutSA = response[0]['hutang'];
        final maxhutang = response[0]['maxhutang'];
        final batashutlogin = response[0]['batashutlogin'];
        //print(versiapp);
        if (versiapp != 'ver09') {
          setState(() {
            _error = 'Login gagal.Anda harus update versi terbaru';
          });
        } else if (jabatan == 'Agen') {
          Navigator.pushReplacementNamed(context, '/pengumuman', arguments: [
            varpbuser,
            jabatan,
            varhutSA,
            varhutagen,
            varidagen1,
            varidsubagen1,
            maxhutang,
            batashutlogin
          ]);
        } else if (jabatan == 'SubAgen') {
          Navigator.pushReplacementNamed(context, '/pengumuman', arguments: [
            varpbuser,
            jabatan,
            varhutSA,
            varhutagen,
            varidagen1,
            varidsubagen1,
            maxhutang,
            batashutlogin
          ]);
        } else if (jabatan == 'Error') {
          setState(() {
            _error = 'Login gagal..User/password salah/tidak aktif';
          });
        } else if (jabatan == 'HPBEDA') {
          setState(() {
            _error = 'Login gagal..Device Berbeda dari Biasanya';
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
            // Image.asset(
            //   'utils/logo_foreground.png',
            //   width: 100,
            //   height: 100,
            // ),

            SizedBox(height: 20),

            //wellcomback you've been missed
            Text(
              "Silahkan Login ! (ver 1.0.1)",
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

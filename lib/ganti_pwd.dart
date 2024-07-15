import 'package:flutter/material.dart';

import 'service.dart';

class GantiPwdPage extends StatefulWidget {
  final String varpbuser;

  GantiPwdPage(this.varpbuser);

  @override
  _GantiPwdPageState createState() => _GantiPwdPageState();
}

class _GantiPwdPageState extends State<GantiPwdPage> {
  final _formKey = GlobalKey<FormState>();
  final _oldPwdController = TextEditingController();
  final _newPwdController = TextEditingController();
  final _confirmPwdController = TextEditingController();

  Future<void> _gantiPassword() async {
    final result = await ApiService.gantiPassword(widget.varpbuser, _oldPwdController.text, _newPwdController.text);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: result == 'Ganti Password Berhasil' ? Text('Sukses') : Text('Error'),
          content: Text(result),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                if (result == 'Ganti Password Berhasil') {
                  Navigator.pushReplacementNamed(context, '/login');
                }
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    _oldPwdController.dispose();
    _newPwdController.dispose();
    _confirmPwdController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final varpbuser = widget.varpbuser;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue[700],
        title: Text('Ganti Password', style: TextStyle(color: Colors.white)),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Ganti password user $varpbuser'),
              SizedBox(height: 16.0),
              TextFormField(
                controller: _oldPwdController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'Password Lama',
                ),
                validator: (value) {
                  if (value?.isEmpty ?? true) {
                    return 'Masukkan password lama';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16.0),
              TextFormField(
                controller: _newPwdController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'Password Baru',
                ),
                validator: (value) {
                  if (value?.isEmpty ?? true) {
                    return 'Masukkan password baru';
                  }

                  if ((value?.length ?? 0) > 30) {
                    return 'Password baru maksimal 30 karakter';
                    // Lakukan tindakan yang diperlukan jika panjang string melebihi 30 karakter
                  }

                  return null;
                },
              ),
              SizedBox(height: 16.0),
              TextFormField(
                controller: _confirmPwdController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'Ulangi Password Baru',
                ),
                validator: (value) {
                  if (value?.isEmpty ?? true) {
                    return 'Ulangi password baru';
                  }
                  if (value != _newPwdController.text) {
                    return 'Password harus sama';
                  }
                  return null;
                },
              ),
              SizedBox(height: 24.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: Text('Cancel'),
                  ),
                  SizedBox(width: 16.0),
                  ElevatedButton(
                    onPressed: () {
                      if (_formKey.currentState?.validate() ?? false) {
                        _gantiPassword();
                      }
                    },
                    child: Text('Simpan'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

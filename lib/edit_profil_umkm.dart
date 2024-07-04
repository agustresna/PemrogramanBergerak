import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'setting.dart';

class EditProfilUmkmPage extends StatefulWidget {
  const EditProfilUmkmPage({super.key});

  @override
  _EditProfilUmkmPageState createState() => _EditProfilUmkmPageState();
}

class _EditProfilUmkmPageState extends State<EditProfilUmkmPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _namaUmkmController = TextEditingController();
  final TextEditingController _namaPemilikController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _nomorController = TextEditingController();
  String _message = '';

  @override
  void initState() {
    super.initState();
    _getUmkmDetails();
  }

  Future<void> _getUmkmDetails() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String id = prefs.getInt('id').toString();
    String apiUrl = '${AppSetting.baseUrl}/umkm.php';

    try {
      var response = await http.get(Uri.parse(apiUrl));
      if (response.statusCode == 200) {
        List<dynamic> jsonResponse = jsonDecode(response.body);

        setState(() {
          var umkm = jsonResponse.firstWhere((umkm) => umkm['id'] == id);
          _namaUmkmController.text = umkm['nama_umkm'];
          _namaPemilikController.text = umkm['nama_pemilik'];
          _emailController.text = umkm['email'];
          _passwordController.text = umkm['password'];
          _nomorController.text = umkm['nomor_hp'];
        });
      } else {
        print('Gagal mengambil detail UMKM: ${response.statusCode}');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  Future<void> _editProfilUmkm() async {
    if (_formKey.currentState!.validate()) {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String id = prefs.getInt('id').toString();
      String apiUrl = '${AppSetting.baseUrl}/umkm.php';

      Map<String, String> headers = {'Content-Type': 'application/json'};
      Map<String, dynamic> body = {
        'id': id,
        'nama_umkm': _namaUmkmController.text,
        'nama_pemilik': _namaPemilikController.text,
        'email': _emailController.text,
        'password': _passwordController.text,
        'nomor_hp': _nomorController.text,
      };

      try {
        var response = await http.put(Uri.parse(apiUrl),
            headers: headers, body: jsonEncode(body));

        if (response.statusCode == 200) {
          Map<String, dynamic> jsonResponse = jsonDecode(response.body);

          setState(() {
            _message = jsonResponse['message'];
          });

          if (jsonResponse['status'] == 'success') {
            showDialog(
              context: context,
              builder: (context) => AlertDialog(
                title: const Text('Sukses'),
                content: Text(_message),
                actions: <Widget>[
                  TextButton(
                    onPressed: () async {
                      SharedPreferences prefs =
                          await SharedPreferences.getInstance();
                      await prefs.setString(
                          'nama_umkm', _namaUmkmController.text);
                      await prefs.setString(
                          'nama_pemilik', _namaPemilikController.text);
                      await prefs.setString('email', _emailController.text);
                      Navigator.of(context).pop();
                      Navigator.of(context)
                          .pop(); // Kembali ke halaman sebelumnya
                    },
                    child: const Text('OK'),
                  ),
                ],
              ),
            );
          }
        } else {
          setState(() {
            _message = 'Gagal mengedit profil UMKM. Silakan coba lagi.';
          });
        }
      } catch (e) {
        print('Error: $e');
        setState(() {
          _message = 'Terjadi kesalahan. Silakan coba lagi nanti.';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profil UMKM'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              TextFormField(
                controller: _namaUmkmController,
                decoration: const InputDecoration(
                  labelText: 'Nama UMKM',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Nama UMKM tidak boleh kosong';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20.0),
              TextFormField(
                controller: _namaPemilikController,
                decoration: const InputDecoration(
                  labelText: 'Nama Pemilik',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Nama pemilik tidak boleh kosong';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20.0),
              TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  labelText: 'Email',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Email tidak boleh kosong';
                  }
                  if (!value.contains('@')) {
                    return 'Email tidak valid';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20.0),
              TextFormField(
                controller: _passwordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Password',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Password tidak boleh kosong';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20.0),
              TextFormField(
                controller: _nomorController,
                decoration: const InputDecoration(
                  labelText: 'Nomor Hp',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Nomor Hp tidak boleh kosong';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20.0),
              ElevatedButton(
                onPressed: () {
                  _editProfilUmkm();
                },
                child: const Text('Simpan Perubahan'),
              ),
              const SizedBox(height: 20.0),
              Text(_message, style: const TextStyle(color: Colors.red)),
            ],
          ),
        ),
      ),
    );
  }
}

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:umkm/setting.dart';

class TambahUmkmPage extends StatefulWidget {
  const TambahUmkmPage({super.key});

  @override
  _TambahUmkmPageState createState() => _TambahUmkmPageState();
}

class _TambahUmkmPageState extends State<TambahUmkmPage> {
  final TextEditingController _namaUmkmController = TextEditingController();
  final TextEditingController _namaPemilikController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _nomorController = TextEditingController();
  String _message = '';
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  Future<void> _tambahUmkm() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    String apiUrl = '${AppSetting.baseUrl}/umkm.php';

    Map<String, String> headers = {'Content-Type': 'application/json'};
    Map<String, String> body = {
      'nama_umkm': _namaUmkmController.text,
      'nama_pemilik': _namaPemilikController.text,
      'email': _emailController.text,
      'password': _passwordController.text,
      'nomor_hp': _nomorController.text,
    };

    try {
      var response = await http.post(Uri.parse(apiUrl),
          headers: headers, body: jsonEncode(body));
      print(response.body);
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
                  onPressed: () {
                    Navigator.of(context).pop();
                    Navigator.of(context).pop();
                  },
                  child: const Text('OK'),
                ),
              ],
            ),
          );
        }
      } else {
        setState(() {
          _message = 'Gagal menambahkan UMKM. Silakan coba lagi.';
        });
      }
    } catch (e) {
      print('Error: $e');
      setState(() {
        _message = 'Terjadi kesalahan. Silakan coba lagi nanti.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tambah UMKM'),
      ),
      body: SingleChildScrollView(
        child: Padding(
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
                      return 'Nama UMKM harus diisi';
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
                      return 'Nama Pemilik harus diisi';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20.0),
                TextFormField(
                  controller: _emailController,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Email harus diisi';
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
                      return 'Password harus diisi';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: _nomorController,
                  decoration: const InputDecoration(
                    labelText: 'Nomor HP',
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Nomor HP harus diisi';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20.0),
                ElevatedButton(
                  onPressed: () {
                    _tambahUmkm();
                  },
                  child: const Text('Tambah UMKM'),
                ),
                const SizedBox(height: 20.0),
                Text(_message, style: const TextStyle(color: Colors.red)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:umkm/setting.dart';

class EditUmkmPage extends StatefulWidget {
  final String umkmId;

  const EditUmkmPage({super.key, required this.umkmId});

  @override
  _EditUmkmPageState createState() => _EditUmkmPageState();
}

class _EditUmkmPageState extends State<EditUmkmPage> {
  final TextEditingController _namaUmkmController = TextEditingController();
  final TextEditingController _namaPemilikController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  String _message = '';

  @override
  void initState() {
    super.initState();
    fetchUmkmDetails();
  }

  Future<void> fetchUmkmDetails() async {
    String apiUrl = '${AppSetting.baseUrl}/umkm.php';

    try {
      var response = await http.get(Uri.parse(apiUrl));

      if (response.statusCode == 200) {
        List<dynamic> jsonResponse = jsonDecode(response.body);

        var umkm =
            jsonResponse.firstWhere((umkm) => umkm['id'] == widget.umkmId);

        setState(() {
          _namaUmkmController.text = umkm['nama_umkm'];
          _namaPemilikController.text = umkm['nama_pemilik'];
          _emailController.text = umkm['email'];
          _passwordController.text = umkm['password'];
        });
      } else {
        setState(() {
          _message = 'Gagal mengambil data UMKM. Silakan coba lagi.';
        });
      }
    } catch (e) {
      print('Error: $e');
      setState(() {
        _message = 'Terjadi kesalahan. Silakan coba lagi nanti.';
      });
    }
  }

  Future<void> _updateUmkm() async {
    String apiUrl = '${AppSetting.baseUrl}/umkm.php';

    if (_namaUmkmController.text.isEmpty ||
        _namaPemilikController.text.isEmpty ||
        _emailController.text.isEmpty ||
        _passwordController.text.isEmpty) {
      setState(() {
        _message = 'Semua kolom harus diisi';
      });
      return;
    }

    Map<String, String> headers = {'Content-Type': 'application/json'};
    Map<String, dynamic> body = {
      'id': widget.umkmId.toString(),
      'nama_umkm': _namaUmkmController.text,
      'nama_pemilik': _namaPemilikController.text,
      'email': _emailController.text,
      'password': _passwordController.text,
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
          _message = 'Gagal mengupdate UMKM. Silakan coba lagi.';
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
        title: const Text('Edit UMKM'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              TextField(
                controller: _namaUmkmController,
                decoration: const InputDecoration(
                  labelText: 'Nama UMKM',
                ),
              ),
              const SizedBox(height: 20.0),
              TextField(
                controller: _namaPemilikController,
                decoration: const InputDecoration(
                  labelText: 'Nama Pemilik',
                ),
              ),
              const SizedBox(height: 20.0),
              TextField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: 'Email',
                ),
              ),
              const SizedBox(height: 20.0),
              TextField(
                controller: _passwordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Password',
                ),
              ),
              const SizedBox(height: 20.0),
              ElevatedButton(
                onPressed: () {
                  _updateUmkm();
                },
                child: const Text('Update UMKM'),
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

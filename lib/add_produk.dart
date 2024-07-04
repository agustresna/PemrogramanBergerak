import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'setting.dart';

class AddProdukPage extends StatefulWidget {
  final String idUmkm;

  const AddProdukPage({super.key, required this.idUmkm});

  @override
  _AddProdukPageState createState() => _AddProdukPageState();
}

class _AddProdukPageState extends State<AddProdukPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _namaProdukController = TextEditingController();
  final TextEditingController _hargaController = TextEditingController();
  final TextEditingController _stokController = TextEditingController();
  String _message = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tambah Produk'),
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
                controller: _namaProdukController,
                decoration: const InputDecoration(
                  labelText: 'Nama Produk',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Nama produk tidak boleh kosong';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20.0),
              TextFormField(
                controller: _hargaController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Harga',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Harga tidak boleh kosong';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20.0),
              TextFormField(
                controller: _stokController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Stok',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Stok tidak boleh kosong';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20.0),
              ElevatedButton(
                onPressed: () {
                  _addProduk();
                },
                child: const Text('Tambah Produk'),
              ),
              const SizedBox(height: 20.0),
              Text(_message, style: const TextStyle(color: Colors.red)),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _addProduk() async {
    if (_formKey.currentState!.validate()) {
      String apiUrl = '${AppSetting.baseUrl}/produk.php';

      Map<String, String> headers = {'Content-Type': 'application/json'};
      Map<String, dynamic> body = {
        'id_umkm': widget.idUmkm,
        'nama_produk': _namaProdukController.text,
        'harga': _hargaController.text,
        'stok': _stokController.text,
      };

      try {
        var response = await http.post(Uri.parse(apiUrl),
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
            _message = 'Gagal menambahkan produk. Silakan coba lagi.';
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
}

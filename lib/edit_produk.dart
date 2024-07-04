import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'setting.dart';

class EditProdukPage extends StatefulWidget {
  final String produkId;

  const EditProdukPage({super.key, required this.produkId});

  @override
  _EditProdukPageState createState() => _EditProdukPageState();
}

class _EditProdukPageState extends State<EditProdukPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _namaProdukController = TextEditingController();
  final TextEditingController _hargaController = TextEditingController();
  final TextEditingController _stokController = TextEditingController();
  String _message = '';

  @override
  void initState() {
    super.initState();
    _fetchProdukDetails();
  }

  Future<void> _fetchProdukDetails() async {
    String apiUrl = '${AppSetting.baseUrl}/produk.php?id=${widget.produkId}';

    try {
      var response = await http.get(Uri.parse(apiUrl));
      print('Response: ${response.body}');
      if (response.statusCode == 200) {
        List<dynamic> jsonResponse = jsonDecode(response.body);

        var produk = jsonResponse.first;
        setState(() {
          _namaProdukController.text = produk['nama_produk'];
          _hargaController.text = produk['harga'];
          _stokController.text = produk['stok'].toString();
        });
      } else {
        print('Gagal mengambil detail produk: ${response.statusCode}');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  Future<void> _editProduk() async {
    if (_formKey.currentState!.validate()) {
      String apiUrl = '${AppSetting.baseUrl}/produk.php';
      String idUmkm;
      SharedPreferences prefs = await SharedPreferences.getInstance();
      idUmkm = prefs.getInt('id').toString();

      Map<String, String> headers = {'Content-Type': 'application/json'};
      Map<String, dynamic> body = {
        'id': widget.produkId,
        'id_umkm': idUmkm,
        'nama_produk': _namaProdukController.text,
        'harga': _hargaController.text,
        'stok': _stokController.text,
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
            _message = 'Gagal mengedit produk. Silakan coba lagi.';
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
        title: const Text('Edit Produk'),
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
                  _editProduk();
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

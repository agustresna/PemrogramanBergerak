import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'add_produk.dart';
import 'edit_profil_umkm.dart';

import 'edit_produk.dart';
import 'setting.dart';

class UmkmPage extends StatefulWidget {
  const UmkmPage({super.key});

  @override
  State<UmkmPage> createState() => _UmkmPageState();
}

class _UmkmPageState extends State<UmkmPage> {
  String id = '';
  String role = '';
  String namaUmkm = '';
  String namaPemilik = '';
  String email = '';
  String gambar = '';
  String nomorTelepon = '';
  List<Produk> produkList = [];

  void _getUmkmDetails() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      id = prefs.getInt('id').toString();
      role = prefs.getString('role').toString();
      namaUmkm = prefs.getString('nama_umkm').toString();
      namaPemilik = prefs.getString('nama_pemilik').toString();
      email = prefs.getString('email').toString();
      gambar = prefs.getString('gambar').toString();
      nomorTelepon = prefs.getString('nohp').toString();
    });

    _fetchProdukList(); // Ensure to fetch products after updating details
  }

  Future<void> _fetchProdukList() async {
    String apiUrl = '${AppSetting.baseUrl}/produk.php?id_umkm=$id';

    try {
      var response = await http.get(Uri.parse(apiUrl));
      if (response.statusCode == 200) {
        List<dynamic> jsonResponse = jsonDecode(response.body);

        setState(() {
          produkList =
              jsonResponse.map((data) => Produk.fromJson(data)).toList();
        });
      } else {
        print('Gagal mengambil data produk: ${response.statusCode}');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  @override
  void initState() {
    super.initState();
    _getUmkmDetails();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _fetchProdukList();
    _getUmkmDetails();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          iconTheme: const IconThemeData(color: Colors.white),
          backgroundColor: Colors.purple,
          title: Text(namaUmkm, style: const TextStyle(color: Colors.white)),
          actions: [
            IconButton(
              icon: const Icon(Icons.person, color: Colors.white),
              onPressed: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const EditProfilUmkmPage()),
                ).then((_) {
                  _getUmkmDetails();
                });
              },
            ),
            IconButton(
              icon: const Icon(Icons.logout, color: Colors.white),
              onPressed: () async {
                SharedPreferences prefs = await SharedPreferences.getInstance();
                await prefs.clear();
                Navigator.of(context)
                    .pushNamedAndRemoveUntil('/', (route) => false);
              },
            ),
          ],
        ),
        body: ListView.builder(
          itemCount: produkList.length,
          itemBuilder: (context, index) {
            return ListTile(
              title: Text(produkList[index].namaProduk),
              subtitle: Text(
                  'Harga: ${formatRupiah(produkList[index].harga)}\nStok: ${produkList[index].stok}'),
              trailing: IconButton(
                icon: const Icon(Icons.delete, color: Colors.redAccent),
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: const Text('Konfirmasi'),
                        content: const Text(
                            'Apakah Anda yakin ingin menghapus produk ini?'),
                        actions: <Widget>[
                          TextButton(
                            child: const Text('Batal'),
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                          ),
                          TextButton(
                            child: const Text('Hapus'),
                            onPressed: () {
                              _deleteProduk(produkList[index].id);
                              Navigator.of(context).pop();
                            },
                          ),
                        ],
                      );
                    },
                  );
                },
              ),
              onTap: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => EditProdukPage(
                      produkId: produkList[index].id,
                    ),
                  ),
                );
                _fetchProdukList();
              },
            );
          },
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () async {
            await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => AddProdukPage(idUmkm: id),
              ),
            );
            _fetchProdukList();
          },
          child: const Icon(Icons.add),
        ));
  }

  formatRupiah(String harga) {
    final numberFormat = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp');
    return numberFormat.format(num.parse(harga));
  }

  Future<void> _deleteProduk(String produkId) async {
    String apiUrl = '${AppSetting.baseUrl}/produk.php';

    try {
      var response = await http.delete(Uri.parse(apiUrl),
          headers: <String, String>{'Content-Type': 'application/json'},
          body: jsonEncode(<String, String>{'id': produkId}));

      if (response.statusCode == 200) {
        _fetchProdukList();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Produk berhasil dihapus'),
          ),
        );
      } else {
        print('Gagal menghapus produk: ${response.statusCode}');
      }
    } catch (e) {
      print('Error: $e');
    }
  }
}

class Produk {
  final String id;
  final String idUmkm;
  final String namaProduk;
  final String harga;
  final String stok;

  Produk({
    required this.id,
    required this.idUmkm,
    required this.namaProduk,
    required this.harga,
    required this.stok,
  });

  factory Produk.fromJson(Map<String, dynamic> json) {
    return Produk(
      id: json['id'].toString(),
      idUmkm: json['id_umkm'].toString(),
      namaProduk: json['nama_produk'].toString(),
      harga: json['harga'].toString(),
      stok: json['stok'].toString(),
    );
  }
}

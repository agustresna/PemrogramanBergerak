import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:umkm/models/produk.dart';
import 'package:url_launcher/url_launcher_string.dart';

import 'setting.dart';

class ProdukPage extends StatefulWidget {
  final String idUmkm;
  final String nomor;

  const ProdukPage({super.key, required this.idUmkm, required this.nomor});

  @override
  _ProdukPageState createState() => _ProdukPageState();
}

class _ProdukPageState extends State<ProdukPage> {
  List<Produk> produkList = [];
  String searchQuery = '';
  @override
  void initState() {
    super.initState();
    _fetchProdukList();
  }


  Future<void> _launchUrl() async {
    if (!await launchUrl(Uri.parse('https://wa.me/${widget.nomor}'))) {
      throw Exception('Could not launch wa');
    }
  }

  Future<void> _fetchProdukList() async {
    String apiUrl = '${AppSetting.baseUrl}/produk.php?id_umkm=${widget.idUmkm}';

    try {
      var response = await http.get(Uri.parse(apiUrl));
      if (response.statusCode == 200) {
        List<dynamic> jsonResponse = jsonDecode(response.body);
        setState(() {
          produkList =
              jsonResponse.map((data) => Produk.fromJson(data)).toList();
        });
      } else {
        print('Gagal mengambil data Produk: ${response.statusCode}');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  void _performSearch(String query) {
    setState(() {
      searchQuery = query;
    });
  }

  String formatRupiah(String harga) {
    final numberFormat = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp');
    return numberFormat.format(num.parse(harga));
  }

  @override
  Widget build(BuildContext context) {
    List<Produk> filteredProdukList = produkList.where((produk) {
      String namaProduk = produk.namaProduk.toLowerCase();
      return namaProduk.contains(searchQuery.toLowerCase());
    }).toList();

    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        backgroundColor: Colors.purple,
        centerTitle: true,
        title: const Text(
          'Daftar Produk',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              showSearch(
                  context: context,
                  delegate: _ProdukSearch(filteredProdukList));
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView.builder(
          itemCount: filteredProdukList.length,
          itemBuilder: (context, index) {
            return Card(
              child: ListTile(
                title: Text(
                  filteredProdukList[index].namaProduk,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
                subtitle: Text(
                    'Harga: ${formatRupiah(filteredProdukList[index].harga)}'),
                trailing: Text(
                  'Stok: ${filteredProdukList[index].stok}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
                onTap: () {
                  // Implement onTap functionality
                },
              ),
            );
          },
        ),
      ),
      floatingActionButton: widget.nomor != null
          ? FloatingActionButton(
              onPressed: () {
                _launchUrl();
              },
              backgroundColor: Colors.purple,
              child: const Icon(Icons.phone, color: Colors.white, size: 30.0),
            )
          : null,
    );
  }
}

class _ProdukSearch extends SearchDelegate<Produk> {
  final List<Produk> produkList;

  _ProdukSearch(this.produkList);

  @override
  String get searchFieldLabel => 'Cari Produk';

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () {
        Navigator.pop(context);
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    List<Produk> filteredList = produkList.where((produk) {
      String namaProduk = produk.namaProduk.toLowerCase();
      return namaProduk.contains(query.toLowerCase());
    }).toList();

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: ListView.builder(
        itemCount: filteredList.length,
        itemBuilder: (context, index) {
          return Card(
            child: ListTile(
              title: Text(filteredList[index].namaProduk),
              subtitle: Text('Harga: ${filteredList[index].harga}'),
              trailing: Text(
                'Stok: ${filteredList[index].stok}',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),
              onTap: () {
                close(context, filteredList[index]);
              },
            ),
          );
        },
      ),
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    List<Produk> suggestionList = query.isEmpty
        ? []
        : produkList.where((produk) {
            String namaProduk = produk.namaProduk.toLowerCase();
            return namaProduk.contains(query.toLowerCase());
          }).toList();

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: ListView.builder(
        itemCount: suggestionList.length,
        itemBuilder: (context, index) {
          return Card(
            child: ListTile(
              title: Text(suggestionList[index].namaProduk),
              subtitle: Text('Harga: ${suggestionList[index].harga}'),
              trailing: Text(
                'Stok: ${suggestionList[index].stok}',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),
              onTap: () {
                close(context, suggestionList[index]);
              },
            ),
          );
        },
      ),
    );
  }
}

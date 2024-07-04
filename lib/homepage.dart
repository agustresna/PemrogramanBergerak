import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:umkm/list_produk.dart';
import 'package:umkm/login.dart';
import 'package:umkm/models/umkm_data.dart';

import 'setting.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Umkm> umkmList = [];
  String searchQuery = '';

  Future<void> _fetchUmkmList() async {
    String apiUrl = '${AppSetting.baseUrl}/umkm.php';

    try {
      var response = await http.get(Uri.parse(apiUrl));
      if (response.statusCode == 200) {
        List<dynamic> jsonResponse = jsonDecode(response.body);

        setState(() {
          umkmList = jsonResponse.map((data) => Umkm.fromJson(data)).toList();
        });
      } else {
        print('Gagal mengambil data UMKM: ${response.statusCode}');
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

  @override
  void initState() {
    super.initState();
    _fetchUmkmList();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _fetchUmkmList();
  }

  @override
  Widget build(BuildContext context) {
    List<Umkm> filteredUmkmList = umkmList.where((umkm) {
      String namaUmkm = umkm.namaUmkm.toLowerCase();
      String namaPemilik = umkm.namaPemilik.toLowerCase();
      String query = searchQuery.toLowerCase();

      return namaUmkm.contains(query) || namaPemilik.contains(query);
    }).toList();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.purple,
        title: const Text('Daftar UMKM',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            )),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: () {
              _fetchUmkmList();
            },
          ),
          IconButton(
            icon: const Icon(Icons.search, color: Colors.white),
            onPressed: () {
              showSearch(
                  context: context, delegate: _UmkmSearch(filteredUmkmList));
            },
          ),
          IconButton(
            icon: const Icon(Icons.person, color: Colors.white),
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const LoginPage()),
              ).then((_) {
                _fetchUmkmList(); // Panggil kembali untuk memperbarui data
              });
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView.builder(
          itemCount: filteredUmkmList.length,
          itemBuilder: (context, index) {
            return Card(
              child: ListTile(
                title: Text(filteredUmkmList[index].namaUmkm,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    )),
                subtitle: Text(filteredUmkmList[index].namaPemilik),
                trailing: IconButton(
                  icon: const Icon(Icons.navigate_next,
                      color: Colors.purple, size: 40.0),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => ProdukPage(
                                idUmkm: filteredUmkmList[index].id,
                                nomor: filteredUmkmList[index].nomor,
                              )),
                    ).then((_) {
                      _fetchUmkmList();
                    });
                  },
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => ProdukPage(
                              idUmkm: filteredUmkmList[index].id,
                              nomor: filteredUmkmList[index].nomor,
                            )),
                  ).then((_) {
                    _fetchUmkmList();
                  });
                },
              ),
            );
          },
        ),
      ),
    );
  }
}

class _UmkmSearch extends SearchDelegate<Umkm> {
  final List<Umkm> umkmList;

  _UmkmSearch(this.umkmList);

  @override
  String get searchFieldLabel => 'Cari UMKM';

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
    List<Umkm> filteredList = umkmList.where((umkm) {
      String namaUmkm = umkm.namaUmkm.toLowerCase();
      String namaPemilik = umkm.namaPemilik.toLowerCase();
      String queryLowerCase = query.toLowerCase();

      return namaUmkm.contains(queryLowerCase) ||
          namaPemilik.contains(queryLowerCase);
    }).toList();

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: ListView.builder(
        itemCount: filteredList.length,
        itemBuilder: (context, index) {
          return Card(
            child: ListTile(
              title: Text(filteredList[index].namaUmkm),
              subtitle: Text(filteredList[index].namaPemilik),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => ProdukPage(
                            idUmkm: filteredList[index].id,
                            nomor: filteredList[index].nomor,
                          )),
                );
              },
            ),
          );
        },
      ),
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    List<Umkm> suggestionList = query.isEmpty
        ? []
        : umkmList.where((umkm) {
            String namaUmkm = umkm.namaUmkm.toLowerCase();
            String namaPemilik = umkm.namaPemilik.toLowerCase();
            String queryLowerCase = query.toLowerCase();

            return namaUmkm.contains(queryLowerCase) ||
                namaPemilik.contains(queryLowerCase);
          }).toList();

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: ListView.builder(
        itemCount: suggestionList.length,
        itemBuilder: (context, index) {
          return Card(
            child: ListTile(
                title: Text(suggestionList[index].namaUmkm,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    )),
                subtitle: Text(suggestionList[index].namaPemilik),
                trailing: IconButton(
                  icon: const Icon(Icons.navigate_next,
                      color: Colors.purple, size: 40.0),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => ProdukPage(
                                idUmkm: suggestionList[index].id,
                                nomor: suggestionList[index].nomor,
                              )),
                    );
                  },
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => ProdukPage(
                              idUmkm: suggestionList[index].id,
                              nomor: suggestionList[index].nomor,
                            )),
                  );
                }),
          );
        },
      ),
    );
  }
}

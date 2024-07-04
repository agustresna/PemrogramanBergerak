import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:umkm/edit_umkm.dart';
import 'package:umkm/tambah_umkm.dart';
import 'models/umkm_models.dart';
import 'setting.dart';

class AdminHomePage extends StatefulWidget {
  const AdminHomePage({super.key});

  @override
  _AdminHomePageState createState() => _AdminHomePageState();
}

class _AdminHomePageState extends State<AdminHomePage> {
  List<Umkm> umkmList = [];

  @override
  void initState() {
    super.initState();
    _fetchUmkm();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _fetchUmkm();
  }

  Future<void> _fetchUmkm() async {
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

  Future<void> _deleteUmkm(String umkmId) async {
    String apiUrl = '${AppSetting.baseUrl}/umkm.php';

    try {
      var response = await http.delete(Uri.parse(apiUrl),
          headers: <String, String>{'Content-Type': 'application/json'},
          body: jsonEncode(<String, String>{'id': umkmId}));

      if (response.statusCode == 200) {
        _fetchUmkm();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('UMKM berhasil dihapus'),
          ),
        );
      } else {
        print('Gagal menghapus UMKM: ${response.statusCode}');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        backgroundColor: Colors.purple,
        title: const Text('Admin Dashboard',
            style: TextStyle(color: Colors.white)),
        actions: [
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
        itemCount: umkmList.length,
        itemBuilder: (context, index) {
          return ListTile(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => EditUmkmPage(
                    umkmId: umkmList[index].id,
                  ),
                ),
              ).then((_) {
                _fetchUmkm();
              });
            },
            title: Text(umkmList[index].namaUmkm),
            subtitle: Text('Pemilik: ${umkmList[index].namaPemilik}\n'
                'Nomor: ${umkmList[index].nomor}'),
            trailing: IconButton(
              icon: const Icon(Icons.delete, color: Colors.red, size: 24.0),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: const Text('Konfirmasi'),
                      content: const Text(
                          'Apakah Anda yakin ingin menghapus UMKM ini?'),
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
                            Navigator.of(context).pop();
                            _deleteUmkm(umkmList[index].id);
                          },
                        ),
                      ],
                    );
                  },
                );
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const TambahUmkmPage()),
          ).then((_) {
            _fetchUmkm();
          });
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'setting.dart';

List<bool> isSelected = [true, false];
bool _loginAsAdmin = true;

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  String _message = '';

  Future<void> _login() async {
    String apiUrl = _loginAsAdmin
        ? '${AppSetting.baseUrl}/login.php'
        : '${AppSetting.baseUrl}/umkm_login.php';

    Map<String, String> headers = {'Content-Type': 'application/json'};
    Map<String, String> body = {
      'email': _emailController.text,
      'password': _passwordController.text,
    };

    if (_loginAsAdmin) {
      try {
        var response = await http.post(Uri.parse(apiUrl),
            headers: headers, body: jsonEncode(body));

        if (response.statusCode == 200) {
          Map<String, dynamic> jsonResponse = jsonDecode(response.body);

          setState(() {
            _message = jsonResponse['message'];
          });

          if (jsonResponse['status'] == 'success') {
            SharedPreferences prefs = await SharedPreferences.getInstance();
            await prefs.setInt('id', jsonResponse['user_id']);
            await prefs.setString('role', 'admin');
            if (_loginAsAdmin) {
              Navigator.pushReplacementNamed(context, '/admin_home');
            } else {
              // Handle navigation for UMK login
            }
          }
        } else {
          setState(() {
            _message = 'Gagal melakukan login. Silakan coba lagi.';
          });
        }
      } catch (e) {
        print('Error: $e');
        setState(() {
          _message = 'Terjadi kesalahan. Silakan coba lagi nanti.';
        });
      }
    } else {
      try {
        var response = await http.post(Uri.parse(apiUrl),
            headers: headers, body: jsonEncode(body));

        if (response.statusCode == 200) {
          Map<String, dynamic> jsonResponse = jsonDecode(response.body);

          setState(() {
            _message = jsonResponse['message'];
          });

          if (jsonResponse['status'] == 'success') {
            SharedPreferences prefs = await SharedPreferences.getInstance();
            await prefs.setInt('id', jsonResponse['user_id']);
            await prefs.setString('role', 'umkm');
            await prefs.setString('nama_umkm', jsonResponse['nama_umkm']);
            await prefs.setString('nama_pemilik', jsonResponse['nama_pemilik']);
            await prefs.setString('email', jsonResponse['email']);
            Navigator.pushReplacementNamed(context, '/umkm_home');
          }
        } else {
          setState(() {
            _message = 'Gagal melakukan login. Silakan coba lagi.';
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

  _cekLogin() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String role = prefs.getString('role') ?? '';
    String id = prefs.getInt('id').toString() ?? '';
    if (role == 'admin' && id.isNotEmpty) {
      setState(() {
        isSelected = [true, false];
        _loginAsAdmin = true;
      });
      Navigator.pushReplacementNamed(context, '/admin_home');
    } else if (role == 'umkm' && id.isNotEmpty) {
      setState(() {
        isSelected = [true, false];
        _loginAsAdmin = false;
      });
      Navigator.pushReplacementNamed(context, '/umkm_home');
    }
  }

  @override
  void initState() {
    setState(() {
      isSelected = [true, false];
      _loginAsAdmin = true;
    });
    _cekLogin();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Login Page'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Center(
              child: ToggleButtonClass(),
            ),
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
                _login();
              },
              child: const Text('Login'),
            ),
            const SizedBox(height: 20.0),
            Text(_message, style: const TextStyle(color: Colors.red)),
          ],
        ),
      ),
    );
  }
}

class ToggleButtonClass extends StatefulWidget {
  const ToggleButtonClass({super.key});

  @override
  State<ToggleButtonClass> createState() => _ToggleButtonClassState();
}

class _ToggleButtonClassState extends State<ToggleButtonClass> {
  @override
  Widget build(BuildContext context) {
    return ToggleButtons(
      borderRadius: BorderRadius.circular(30),
      fillColor: Colors.blue,
      selectedColor: Colors.white,
      color: Colors.black,
      isSelected: isSelected,
      onPressed: (int index) {
        setState(() {
          for (int buttonIndex = 0;
              buttonIndex < isSelected.length;
              buttonIndex++) {
            if (buttonIndex == index) {
              isSelected[buttonIndex] = true;
              _loginAsAdmin = buttonIndex == 0;
            } else {
              isSelected[buttonIndex] = false;
            }
          }
        });
      },
      children: const <Widget>[
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.0),
          child: Text('ADMIN'),
        ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.0),
          child: Text('UMKM'),
        ),
      ],
    );
  }
}

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RegisterScreen extends StatefulWidget {
  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passController = TextEditingController();

  void _register() async {
    if (_nameController.text.isEmpty || _emailController.text.isEmpty) return;

    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_name', _nameController.text);
    await prefs.setString('user_email', _emailController.text);
    await prefs.setString('user_pass', _passController.text);

    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Daftar Berhasil!")));
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        padding: EdgeInsets.all(30),
        child: Column(
          children: [
            SizedBox(height: 50),
            Icon(Icons.account_balance_wallet, size: 60, color: Color(0xFF6C63FF)),
            Text("Buat Akun Baru", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            Text("Mulai kelola keuanganmu!", style: TextStyle(color: Colors.grey)),
            SizedBox(height: 30),
            _input("Nama Lengkap", Icons.person_outline, controller: _nameController),
            _input("Email Kampus", Icons.email_outlined, controller: _emailController),
            _input("Password", Icons.lock_outline, controller: _passController, isPass: true),
            _input("Konfirmasi Password", Icons.lock_outline, isPass: true),
            SizedBox(height: 20),
            SizedBox(
              width: double.infinity, height: 55,
              child: ElevatedButton(
                onPressed: _register,
                style: ElevatedButton.styleFrom(backgroundColor: Color(0xFF6C63FF), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))),
                child: Text("Daftar Sekarang", style: TextStyle(color: Colors.white, fontSize: 16)),
              ),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("Sudah punya akun? Masuk di sini", style: TextStyle(color: Color(0xFF6C63FF))),
            )
          ],
        ),
      ),
    );
  }

  Widget _input(String label, IconData icon, {bool isPass = false, TextEditingController? controller}) {
    return Container(
      margin: EdgeInsets.only(bottom: 15),
      child: TextField(
        controller: controller,
        obscureText: isPass,
        decoration: InputDecoration(
          prefixIcon: Icon(icon), labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
        ),
      ),
    );
  }
}
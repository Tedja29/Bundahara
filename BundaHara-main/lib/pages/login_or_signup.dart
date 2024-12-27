import 'package:flutter/material.dart';
import 'package:testing_bolo/pages/signup_page.dart';
import 'login_page.dart';

class LoginAndSignUp extends StatefulWidget {
  const LoginAndSignUp({super.key});

  @override
  State<LoginAndSignUp> createState() => _LoginAndSignUpState();
}

class _LoginAndSignUpState extends State<LoginAndSignUp> {
  // Ubah nilai awal menjadi true agar halaman Login tampil pertama
  bool showLoginPage = true;

  // Fungsi untuk toggle antara Login dan Sign Up
  void togglePage() {
    setState(() {
      showLoginPage = !showLoginPage;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Jika showLoginPage bernilai true, tampilkan halaman Login
    if (showLoginPage) {
      return LoginPage(
        onPressed: togglePage,
      );
    }
    // Jika false, tampilkan halaman Sign Up
    else {
      return SignUp(
        onPressed: togglePage,
      );
    }
  }
}

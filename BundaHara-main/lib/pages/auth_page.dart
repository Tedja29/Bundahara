import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'home_page.dart';
import 'login_or_signup.dart';

class AuthPage extends StatelessWidget {
  const AuthPage({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (BuildContext context, AsyncSnapshot<User?> snapshot) {
        // Tampilkan indikator loading saat menunggu status autentikasi
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        // Jika pengguna sudah login, arahkan ke halaman HomePage
        if (snapshot.hasData) {
          return const HomePage();
        }

        // Jika pengguna belum login, arahkan ke halaman Login
        return const LoginAndSignUp();
      },
    );
  }
}

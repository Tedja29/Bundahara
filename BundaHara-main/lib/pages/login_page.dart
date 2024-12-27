import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class LoginPage extends StatefulWidget {
  final void Function()? onPressed;

  const LoginPage({super.key, required this.onPressed});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  bool isLoading = false;
  bool _obscuredPassword = true;
  final TextEditingController _email = TextEditingController();
  final TextEditingController _password = TextEditingController();

  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Fungsi untuk login menggunakan email dan password
  Future<void> signInWithEmailAndPassword() async {
    if (!_formKey.currentState!.validate()) return;

    try {
      if (mounted) {
        setState(() {
          isLoading = true;
        });
      }

      // Login menggunakan email dan password
      await _auth.signInWithEmailAndPassword(
        email: _email.text.trim(),
        password: _password.text.trim(),
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Login berhasil!'),
          ),
        );

        // Setelah login berhasil, arahkan pengguna ke halaman utama (Home)
        Navigator.pushReplacementNamed(context, '/home');
      }
    } on FirebaseAuthException catch (e) {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
        handleFirebaseAuthError(e);
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
      print("Error: $e");
    }
  }

  void handleFirebaseAuthError(FirebaseAuthException e) {
    if (e.code == 'user-not-found') {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text("Email Tidak Terdaftar"),
          content: const Text(
              "Akun dengan email ini tidak ditemukan. Silakan daftar terlebih dahulu."),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text("OK"),
            ),
          ],
        ),
      );
    } else if (e.code == 'wrong-password') {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text("Password Salah"),
          content: const Text("Password yang Anda masukkan salah."),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text("OK"),
            ),
          ],
        ),
      );
    } else if (e.code == 'too-many-requests') {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text("Terlalu Banyak Percobaan"),
          content: const Text(
              "Terlalu banyak percobaan login. Silakan coba lagi nanti."),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text("OK"),
            ),
          ],
        ),
      );
    } else {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text("Kesalahan"),
          content: Text(e.message ?? 'Kesalahan tidak diketahui.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text("OK"),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Center(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Logo Section
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.asset(
                          "assets/wallet.png",
                          width: 80,
                          height: 80,
                        ),
                        const SizedBox(width: 10), // Jarak antara ikon dan teks
                        const Text(
                          "BundaHara",
                          style: TextStyle(
                            fontSize: 35,
                            fontWeight: FontWeight.bold,
                            color: Color.fromARGB(255, 20, 179, 55),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),

                    // Email Input
                    TextFormField(
                      controller: _email,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Email harus diisi";
                        }
                        if (!RegExp(
                                r"^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$")
                            .hasMatch(value)) {
                          return "Masukkan email yang valid";
                        }
                        return null;
                      },
                      decoration: InputDecoration(
                        labelText: "Email",
                        prefixIcon: const Icon(Icons.email),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Password Input
                    TextFormField(
                      controller: _password,
                      obscureText: _obscuredPassword,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Password harus diisi";
                        }
                        return null;
                      },
                      decoration: InputDecoration(
                        labelText: "Password",
                        prefixIcon: const Icon(Icons.lock),
                        suffixIcon: IconButton(
                          icon: Icon(_obscuredPassword
                              ? Icons.visibility
                              : Icons.visibility_off),
                          onPressed: () {
                            setState(() {
                              _obscuredPassword = !_obscuredPassword;
                            });
                          },
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Login Button
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16.0),
                        backgroundColor: const Color(0xFF2D8ACF),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                      ),
                      onPressed: isLoading
                          ? null
                          : () {
                              if (_formKey.currentState!.validate()) {
                                signInWithEmailAndPassword();
                              }
                            },
                      child: isLoading
                          ? const CircularProgressIndicator(
                              color: Colors.white,
                            )
                          : const Text(
                              "Login",
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.white,
                              ),
                            ),
                    ),
                    const SizedBox(height: 16),

                    // Switch to Sign Up
                    TextButton(
                      onPressed: widget.onPressed,
                      child: const Text(
                        "Belum punya akun? SignUp",
                        style: TextStyle(
                          fontSize: 14,
                          color: Color(0xFF2D8ACF),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

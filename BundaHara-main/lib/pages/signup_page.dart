import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class SignUp extends StatefulWidget {
  final void Function()? onPressed;
  const SignUp({super.key, required this.onPressed});

  @override
  State<SignUp> createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  final _formKey = GlobalKey<FormState>();
  bool isLoading = false;
  bool _obscuredPassword = true;

  final TextEditingController _email = TextEditingController();
  final TextEditingController _password = TextEditingController();
  final TextEditingController _name = TextEditingController();
  final TextEditingController _birthDate = TextEditingController();
  final TextEditingController _gender = TextEditingController();
  final TextEditingController _phoneNumber = TextEditingController();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> createUserWithEmailAndPassword() async {
    if (!_formKey.currentState!.validate()) return;

    try {
      if (mounted) {
        setState(() {
          isLoading = true;
        });
      }

      // Membuat pengguna dengan email dan password
      UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: _email.text.trim(),
        password: _password.text.trim(),
      );

      User? user = userCredential.user;

      if (user != null) {
        // Simpan data pengguna ke Firestore
        await _firestore.collection('users').doc(user.uid).set({
          'name': _name.text.trim(),
          'birthDate': _birthDate.text.trim(),
          'gender': _gender.text.trim(),
          'phoneNumber': _phoneNumber.text.trim(),
          'email': _email.text.trim(),
          'uid': user.uid,
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content:
                  Text('Akun berhasil dibuat! Mengarahkan ke halaman login...'),
            ),
          );
        }

        // Tunggu sebelum kembali ke halaman login
        await Future.delayed(const Duration(seconds: 2));

        if (mounted) {
          Navigator.pop(context);
        }
      }
    } on FirebaseAuthException catch (e) {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }

      String errorMessage = '';
      if (e.code == 'weak-password') {
        errorMessage = "Password terlalu lemah.";
      } else if (e.code == 'email-already-in-use') {
        errorMessage = "Email sudah digunakan.";
      }

      if (mounted && errorMessage.isNotEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(errorMessage)),
        );
      }
    } catch (e) {
      print("Error: $e"); // Tambahkan log untuk memeriksa error
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Terjadi kesalahan, coba lagi nanti.")),
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
                    const SizedBox(height: 16),
                    const Text(
                      "",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2D8ACF),
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Name Input
                    _buildTextField(
                      controller: _name,
                      label: "Nama",
                      icon: Icons.person,
                      validator: (value) => value == null || value.isEmpty
                          ? "Nama wajib diisi"
                          : null,
                    ),

                    const SizedBox(height: 16),

                    // Birth Date Input
                    TextFormField(
                      controller: _birthDate,
                      readOnly: true,
                      onTap: () async {
                        DateTime? date = await showDatePicker(
                          context: context,
                          initialDate: DateTime.now(),
                          firstDate: DateTime(1900),
                          lastDate: DateTime.now(),
                        );
                        if (date != null) {
                          _birthDate.text =
                              "${date.year}-${date.month}-${date.day}";
                        }
                      },
                      validator: (value) => value == null || value.isEmpty
                          ? "Tanggal lahir wajib diisi"
                          : null,
                      decoration: InputDecoration(
                        labelText: "Tanggal Lahir",
                        prefixIcon: const Icon(Icons.calendar_today),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Gender Input
                    _buildTextField(
                      controller: _gender,
                      label: "Jenis Kelamin",
                      icon: Icons.person_outline,
                      validator: (value) => value == null || value.isEmpty
                          ? "Jenis kelamin wajib diisi"
                          : null,
                    ),

                    const SizedBox(height: 16),

                    // Phone Number Input
                    _buildTextField(
                      controller: _phoneNumber,
                      label: "Nomor Telepon",
                      icon: Icons.phone,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Nomor telepon wajib diisi";
                        }
                        if (!RegExp(r'^\d+$').hasMatch(value)) {
                          return "Masukkan nomor telepon yang valid";
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Email Input
                    _buildTextField(
                      controller: _email,
                      label: "Email",
                      icon: Icons.email,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Email wajib diisi";
                        }
                        if (!RegExp(
                                r"^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$")
                            .hasMatch(value)) {
                          return "Masukkan alamat email yang valid";
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Password Input
                    TextFormField(
                      controller: _password,
                      obscureText: _obscuredPassword,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Password wajib diisi";
                        }
                        if (value.length < 6) {
                          return "Password minimal 6 karakter";
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

                    // Sign Up Button
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
                                createUserWithEmailAndPassword();
                              }
                            },
                      child: isLoading
                          ? const CircularProgressIndicator(
                              color: Colors.white,
                            )
                          : const Text(
                              "SignUp",
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.white,
                              ),
                            ),
                    ),
                    const SizedBox(height: 16),

                    // Switch to Login
                    TextButton(
                      onPressed: widget.onPressed,
                      child: const Text(
                        "Sudah punya akun? Login",
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

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
        ),
      ),
    );
  }
}

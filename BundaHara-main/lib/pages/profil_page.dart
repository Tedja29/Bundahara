import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  Future<Map<String, dynamic>> _fetchUserData() async {
    // Mendapatkan UID pengguna yang sedang login
    final User? user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      throw Exception("Pengguna tidak ditemukan. Silakan login kembali.");
    }

    // Ambil data pengguna dari Firestore berdasarkan UID
    final DocumentSnapshot<Map<String, dynamic>> snapshot =
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();

    if (!snapshot.exists || snapshot.data() == null) {
      throw Exception("Data pengguna tidak ditemukan.");
    }

    return snapshot.data()!;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Profil Saya"),
        backgroundColor: const Color(0xFF1549A7),
        titleTextStyle: const TextStyle(
          color: Colors.white, // Mengubah warna teks menjadi putih
          fontSize: 20, // Ukuran font (opsional)
          fontWeight: FontWeight.bold, // Ketebalan font (opsional)
        ),
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _fetchUserData(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          } else if (snapshot.hasError) {
            return Center(
              child: Text("Terjadi kesalahan: ${snapshot.error}"),
            );
          } else if (!snapshot.hasData) {
            return const Center(
              child: Text("Data pengguna tidak tersedia."),
            );
          }

          // Data pengguna berhasil diambil
          final userData = snapshot.data!;
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                // Logo dan Teks di Atas Profil
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(
                      "assets/wallet.png",
                      width: 80,
                      height: 80,
                    ),
                    const SizedBox(width: 5), // Jarak antara ikon dan teks
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
                const SizedBox(height: 32), // Jarak antara logo dan profil

                // Bagian Foto Profil
                Center(
                  child: CircleAvatar(
                    radius: 50,
                    backgroundColor: Colors.grey.shade300,
                    child:
                        const Icon(Icons.person, size: 60, color: Colors.white),
                  ),
                ),
                const SizedBox(height: 16),

                // Menampilkan Nama
                buildProfileField("Nama", userData['name'] ?? "-"),
                const SizedBox(height: 10),

                // Menampilkan Email
                buildProfileField("Email", userData['email'] ?? "-"),
                const SizedBox(height: 10),

                // Menampilkan Tanggal Lahir
                buildProfileField(
                    "Tanggal Lahir", userData['birthDate'] ?? "-"),
                const SizedBox(height: 10),

                // Menampilkan Jenis Kelamin
                buildProfileField("Jenis Kelamin", userData['gender'] ?? "-"),
                const SizedBox(height: 10),

                // Menampilkan Nomor Handphone
                buildProfileField(
                    "No. Handphone", userData['phoneNumber'] ?? "-"),
                const SizedBox(height: 20),

                // Tombol Logout
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                  ),
                  onPressed: () async {
                    await FirebaseAuth.instance.signOut();
                    Navigator.popUntil(context, (route) => route.isFirst);
                  },
                  child: const Text("Logout"),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // Fungsi untuk membuat field profil
  Widget buildProfileField(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            color: Colors.black,
          ),
        ),
        const Divider(color: Colors.grey),
      ],
    );
  }
}

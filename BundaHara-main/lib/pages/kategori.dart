import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:testing_bolo/pages/add_kategori.dart';
import 'package:testing_bolo/pages/auth_page.dart';

class Kategori extends StatefulWidget {
  const Kategori({super.key});

  @override
  State<Kategori> createState() => _KategoriState();
}

class _KategoriState extends State<Kategori> {
  final userId = FirebaseAuth.instance.currentUser?.uid;

  final CollectionReference _itemsCollection =
      FirebaseFirestore.instance.collection('kategoriMasuk');
  final CollectionReference _otherCollection =
      FirebaseFirestore.instance.collection('kategoriKeluar');

  Future<void> _showDeleteConfirmationDialog(
      String itemId, CollectionReference collection) async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Konfirmasi Penghapusan'),
          content: const Text('Anda yakin ingin menghapus item ini?'),
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
                collection.doc(itemId).delete();
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Kategori Anda'),
          centerTitle: true,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (context) => const AuthPage()),
              );
            },
          ),
        ),
        body: userId == null
            ? const Center(child: Text('Pengguna tidak ditemukan.'))
            : StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collectionGroup('kategori')
                    .where('uid', isEqualTo: userId)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return const Center(
                      child: Text('Tidak ada kategori tersedia.'),
                    );
                  }

                  List<QueryDocumentSnapshot> data = snapshot.data!.docs;

                  return ListView.builder(
                    padding: const EdgeInsets.all(12.0),
                    itemCount: data.length,
                    itemBuilder: (context, index) {
                      final doc = data[index];
                      final isMasuk = doc.data().toString().contains('masuk');
                      final itemName = isMasuk
                          ? doc['masuk']
                          : doc['keluar']; // Pilih berdasarkan kategori

                      return Card(
                        child: ListTile(
                          tileColor: isMasuk
                              ? const Color(0xFF4296F0)
                              : const Color(0xFFF96D75),
                          title: Text(
                            itemName,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          subtitle: Text(
                            'Tipe: ${isMasuk ? "Pemasukan" : "Pengeluaran"}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w300,
                            ),
                          ),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete, color: Colors.white),
                            onPressed: () {
                              _showDeleteConfirmationDialog(
                                  doc.id,
                                  isMasuk
                                      ? _itemsCollection
                                      : _otherCollection);
                            },
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
        floatingActionButton: FloatingActionButton(
          child: const Icon(Icons.add),
          onPressed: () {
            Navigator.of(context)
                .push(
              MaterialPageRoute(builder: (context) => const AddKategori()),
            )
                .whenComplete(() {
              setState(() {});
            });
          },
        ),
      ),
    );
  }
}

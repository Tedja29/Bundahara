// ignore_for_file: prefer_typing_uninitialized_variables

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:testing_bolo/pages/auth_page.dart';

class MinTransaction extends StatefulWidget {
  const MinTransaction({super.key});

  @override
  State<MinTransaction> createState() => _MinTransactionState();
}

class _MinTransactionState extends State<MinTransaction> {
  final userId = FirebaseAuth.instance.currentUser?.uid;
  bool isLoading = false;

  final controllerJumlah = TextEditingController();

  DateTime sdate = DateTime.now();
  List<String> months = [
    "Januari",
    "Februari",
    "Maret",
    "April",
    "Mei",
    "Juni",
    "Juli",
    "Agustus",
    "September",
    "Oktober",
    "November",
    "Desember"
  ];

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<String> _dropdownItems = [];
  String? _selectedItem;

  @override
  void initState() {
    super.initState();
    _loadDataFromFirestore();
  }

  Future<void> _loadDataFromFirestore() async {
    try {
      QuerySnapshot querySnapshot = await _firestore
          .collection('kategoriKeluar')
          .where('uid', isEqualTo: userId)
          .get();

      List<String> items = [];
      for (QueryDocumentSnapshot doc in querySnapshot.docs) {
        if (doc['keluar'] != null) {
          items.add(doc['keluar']);
        }
      }

      setState(() {
        _dropdownItems = items;
      });
    } catch (e) {
      print('Error loading data from Firestore: $e');
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: sdate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );

    if (picked != null && picked != sdate) {
      setState(() {
        sdate = picked;
      });
    }
  }

  Future<void> _saveToFirestore() async {
    if (controllerJumlah.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Harap masukkan jumlah pengeluaran")),
      );
      return;
    }

    // Pastikan kategori memiliki nilai default jika tidak dipilih
    if (_dropdownItems.isEmpty) {
      _selectedItem = "Tidak ada data";
    } else if (_selectedItem == null) {
      _selectedItem =
          _dropdownItems.first; // Gunakan item pertama sebagai default
    }

    try {
      Timestamp timestamp = Timestamp.fromDate(sdate);

      await _firestore.collection('pengeluaran').doc().set({
        'tanggal': timestamp,
        'jumlah': int.parse(controllerJumlah.text),
        'kategori': _selectedItem!,
        'uid': userId,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Data berhasil disimpan!")),
      );

      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const AuthPage()),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Padding(
          padding: const EdgeInsets.all(0.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                width: double.infinity,
                height: 140,
                decoration: const ShapeDecoration(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(40),
                      bottomRight: Radius.circular(40),
                    ),
                  ),
                  color: Color(0xFFF96D75),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.arrow_back,
                              size: 32.0, color: Colors.white),
                          onPressed: () {
                            Navigator.of(context).pushReplacement(
                              MaterialPageRoute(
                                builder: (context) => const AuthPage(),
                              ),
                            );
                          },
                        ),
                        const Text(
                          'Tambah Pengeluaran',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontFamily: 'Nunito',
                            fontWeight: FontWeight.w600,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.all(8),
                      child: TextFormField(
                        textAlign: TextAlign.right,
                        controller: controllerJumlah,
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          hintText: "Rp",
                          hintStyle: TextStyle(
                            color: Color.fromARGB(115, 255, 255, 255),
                            fontSize: 24,
                            fontFamily: 'Nunito',
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontFamily: 'Nunito',
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 30),
              Container(
                child: Column(
                  children: [
                    Container(
                      width: 350,
                      height: 120,
                      decoration: ShapeDecoration(
                        color: const Color.fromARGB(255, 240, 240, 240),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(14),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'Kategori',
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 16,
                                    fontFamily: 'Nunito',
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                                DropdownButton<String>(
                                  iconSize: 12,
                                  hint: const Text("Pilih Kategori"),
                                  value: _selectedItem,
                                  onChanged: (newValue) {
                                    setState(() {
                                      _selectedItem =
                                          newValue ?? "Tidak ada data";
                                    });
                                  },
                                  items: _dropdownItems.isEmpty
                                      ? [
                                          const DropdownMenuItem<String>(
                                            value: "Tidak ada data",
                                            child: Text("Tidak ada data"),
                                          )
                                        ]
                                      : _dropdownItems.map((String item) {
                                          return DropdownMenuItem<String>(
                                            value: item,
                                            child: Text(item),
                                          );
                                        }).toList(),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'Tanggal',
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 16,
                                    fontFamily: 'Nunito',
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                                TextButton(
                                  onPressed: () => _selectDate(context),
                                  child: Text(
                                    "${sdate.day} ${months[sdate.month - 1]} ${sdate.year}",
                                    style: const TextStyle(
                                      color: Colors.black,
                                      fontSize: 12,
                                      fontFamily: 'Nunito',
                                      fontWeight: FontWeight.w300,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: _saveToFirestore,
          child: isLoading
              ? const Center(
                  child: CircularProgressIndicator(color: Colors.white),
                )
              : const Icon(Icons.add),
        ),
      ),
    );
  }
}

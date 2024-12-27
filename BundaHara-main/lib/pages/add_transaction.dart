import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:testing_bolo/pages/auth_page.dart';

class AddTransaction extends StatefulWidget {
  const AddTransaction({Key? key}) : super(key: key);

  @override
  State<AddTransaction> createState() => _AddTransactionState();
}

class _AddTransactionState extends State<AddTransaction> {
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
    _checkLoginStatus(); // Cek apakah pengguna sudah login
    _loadDataFromFirestore(); // Muat data kategori dari Firestore
  }

  void _checkLoginStatus() {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      // Jika pengguna belum login, arahkan ke halaman login
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const AuthPage()),
      );
    }
  }

  Future<void> _loadDataFromFirestore() async {
    try {
      QuerySnapshot querySnapshot = await _firestore
          .collection('kategoriMasuk')
          .where('uid', isEqualTo: userId)
          .get();
      List<String> items = [];
      for (QueryDocumentSnapshot doc in querySnapshot.docs) {
        items.add(doc['masuk']);
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
    if (userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Pengguna belum login.")),
      );
      return;
    }

    try {
      String jumlahText = controllerJumlah.text.trim();
      if (jumlahText.isEmpty) {
        throw FormatException("Jumlah tidak boleh kosong.");
      }

      int jumlah = int.parse(jumlahText);
      Timestamp timestamp = Timestamp.fromDate(sdate);

      await _firestore.collection('pemasukan').add({
        'tanggal': timestamp,
        'jumlah': jumlah,
        'kategori': _selectedItem ?? "Tidak ada kategori",
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
        SnackBar(content: Text("Error: ${e.toString()}")),
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
                  color: Color(0xFF4296F0),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                          icon: const Icon(
                            Icons.arrow_back,
                            size: 32.0,
                            color: Colors.white,
                          ),
                          onPressed: () {
                            Navigator.of(context).pushReplacement(
                              MaterialPageRoute(
                                builder: (context) => const AuthPage(),
                              ),
                            );
                          },
                        ),
                        const Text(
                          'Tambah Pemasukan',
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
                        inputFormatters: <TextInputFormatter>[
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
                                  hint: const Text("Pilih kategori"),
                                  value: _selectedItem,
                                  onChanged: (newValue) {
                                    setState(() {
                                      _selectedItem = newValue;
                                    });
                                  },
                                  items: _dropdownItems.map((String item) {
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

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:testing_bolo/pages/min_transaction.dart';
import 'package:testing_bolo/pages/add_transaction.dart';
import 'package:testing_bolo/pages/kategori.dart';
import 'package:testing_bolo/pages/profil_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final user = FirebaseAuth.instance.currentUser;
  final userId = FirebaseAuth.instance.currentUser?.uid;

  int hasilAkhir = 0;

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

  @override
  void initState() {
    super.initState();
    saldoSaya(); // Hitung hasil saat layar pertama kali dimuat
  }

  Future<void> saldoSaya() async {
    // Pastikan user sudah login
    final userId = FirebaseAuth.instance.currentUser?.uid;

    if (userId == null) {
      print("Pengguna tidak terautentikasi");
      return; // Keluar lebih awal jika pengguna belum login
    }

    try {
      // Mendapatkan data dari koleksi pemasukan
      QuerySnapshot collection1Snapshot = await FirebaseFirestore.instance
          .collection('pemasukan')
          .where('uid', isEqualTo: userId)
          .get();

      // Mendapatkan data dari koleksi pengeluaran
      QuerySnapshot collection2Snapshot = await FirebaseFirestore.instance
          .collection('pengeluaran')
          .where('uid', isEqualTo: userId)
          .get();

      // Menghitung jumlah dari field pemasukan
      int totalCollection1 = 0;
      for (QueryDocumentSnapshot doc in collection1Snapshot.docs) {
        totalCollection1 += doc['jumlah'] as int;
      }

      // Menghitung jumlah dari field pengeluaran
      int totalCollection2 = 0;
      for (QueryDocumentSnapshot doc in collection2Snapshot.docs) {
        totalCollection2 += doc['jumlah'] as int;
      }

      // Mengurangkan pengeluaran dari pemasukan
      setState(() {
        hasilAkhir = totalCollection1 - totalCollection2;
      });
    } catch (e) {
      // Menangani error jika ada masalah saat mengambil data
      print("Error: $e");
    }
  }

  final CollectionReference _itemsCollection =
      FirebaseFirestore.instance.collection('pemasukan');
  final CollectionReference _otherCollection =
      FirebaseFirestore.instance.collection('pengeluaran');

  _showDeleteConfirmationDialog(String itemId) {
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
                _deleteItem(itemId);
                _deleteOtherItem(itemId);
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _deleteItem(String itemId) {
    return _itemsCollection.doc(itemId).delete();
  }

  Future<void> _deleteOtherItem(String itemId) {
    return _otherCollection.doc(itemId).delete();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Material(
        child: Column(
          children: <Widget>[
            Container(
              color: const Color(0xFF4296F0),
              child: Column(
                children: <Widget>[
                  const SizedBox(
                    height: 10,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const ProfilePage()),
                          );
                        },
                        child: Container(
                          width: 46,
                          height: 46,
                          decoration: const ShapeDecoration(
                            image: DecorationImage(
                              image: AssetImage('assets/face.png'),
                              fit: BoxFit
                                  .cover, // Agar gambar menyesuaikan ukuran container
                            ),
                            color: Color.fromARGB(255, 255, 255, 255),
                            shape: OvalBorder(),
                          ),
                        ),
                      ),
                      Container(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Text(
                                  "Hello",
                                  textAlign: TextAlign.left,
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 10,
                                    fontFamily: 'Nunito',
                                    fontWeight: FontWeight.w300,
                                    height: 0,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(
                              height: 12,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Text(
                                  user!.email.toString(),
                                  textAlign: TextAlign.left,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontFamily: 'Nunito',
                                    fontWeight: FontWeight.w500,
                                    height: 0,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: () async {
                          await FirebaseAuth.instance.signOut();
                        },
                        icon: const Icon(Icons.logout),
                        color: Colors.white,
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                ],
              ),
            ),
            Container(
              color: const Color(0xFF4296F0),
              width: double.infinity,
              height: 200,
              child: Container(
                width: double.infinity,
                height: 200,
                decoration: const ShapeDecoration(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(40),
                      topRight: Radius.circular(40),
                    ),
                  ),
                  color: Colors.white,
                ),
                child: Column(
                  children: [
                    const SizedBox(
                      height: 30,
                    ),
                    Container(
                      width: 350,
                      height: 160,
                      decoration: ShapeDecoration(
                        color: const Color.fromARGB(255, 240, 240, 240),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        shadows: const [
                          BoxShadow(
                            color: Color(0x3F000000),
                            blurRadius: 4,
                            offset: Offset(0, 4),
                            spreadRadius: 0,
                          )
                        ],
                      ),
                      child: Container(
                        padding: const EdgeInsets.all(18),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  "Saldo Saya",
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 18,
                                    fontFamily: 'Nunito',
                                    fontWeight: FontWeight.w600,
                                    height: 0,
                                  ),
                                ),
                                Text(
                                  'Rp $hasilAkhir',
                                  textAlign: TextAlign.right,
                                  style: const TextStyle(
                                    color: Colors.black,
                                    fontSize: 18,
                                    fontFamily: 'Nunito',
                                    fontWeight: FontWeight.w600,
                                    height: 0,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(
                              height: 15,
                            ),
                            Row(
                              children: [
                                Text(
                                  '${sdate.day} ${months[sdate.month - 1]} ${sdate.year}',
                                  style: const TextStyle(
                                    color: Colors.black,
                                    fontSize: 10,
                                    fontFamily: 'Nunito',
                                    fontWeight: FontWeight.w300,
                                    height: 0,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(
                              height: 20,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                FloatingActionButton(
                                  heroTag: null,
                                  onPressed: () {
                                    Navigator.of(context)
                                        .push(
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            const AddTransaction(),
                                      ),
                                    )
                                        .whenComplete(() {
                                      setState(() {});
                                    });
                                  },
                                  backgroundColor: const Color(0xFF4296F0),
                                  shape: const RoundedRectangleBorder(
                                      borderRadius: BorderRadius.all(
                                          Radius.circular(12))),
                                  child: Image.asset(
                                    "assets/pemasukan.png",
                                    width: 30.0,
                                  ),
                                ),
                                FloatingActionButton(
                                  heroTag: null,
                                  onPressed: () {
                                    Navigator.of(context)
                                        .push(
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            const MinTransaction(),
                                      ),
                                    )
                                        .whenComplete(() {
                                      setState(() {});
                                    });
                                  },
                                  backgroundColor: const Color(0xFFF96D75),
                                  shape: const RoundedRectangleBorder(
                                      borderRadius: BorderRadius.all(
                                          Radius.circular(12))),
                                  child: Image.asset(
                                    "assets/pengeluaran.png",
                                    width: 30.0,
                                  ),
                                ),
                                FloatingActionButton(
                                  // heroTag: null,
                                  onPressed: () {
                                    Navigator.of(context)
                                        .push(
                                      MaterialPageRoute(
                                        builder: (context) => const Kategori(),
                                      ),
                                    )
                                        .whenComplete(() {
                                      setState(() {});
                                    });
                                  },

                                  backgroundColor: const Color(0xFF4296F0),
                                  shape: const RoundedRectangleBorder(
                                      borderRadius: BorderRadius.all(
                                          Radius.circular(12))),
                                  child: Image.asset(
                                    "assets/kategori.png",
                                    width: 30.0,
                                  ),
                                ),
                                /*FloatingActionButton(
                                  heroTag: null,
                                  onPressed: () {
                                    Navigator.of(context)
                                        .push(
                                      MaterialPageRoute(
                                        builder: (context) => Grafik(),
                                      ),
                                    )
                                        .whenComplete(() {
                                      setState(() {});
                                    });
                                  },
                                  backgroundColor: Color(0xFFF96D75),
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(32.0)),
                                  child: Image.asset(
                                    "assets/grafik.png",
                                    width: 30.0,
                                  ),
                                ),*/
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Container(
              color: Colors.white,
              padding: const EdgeInsets.all(8),
              alignment: Alignment.topLeft,
              child: const Text(
                "Daftar Transaksi",
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 20,
                  fontFamily: 'Nunito',
                  fontWeight: FontWeight.w600,
                  height: 0,
                ),
                textAlign: TextAlign.left,
              ),
            ),
            Container(
              child: Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: StreamBuilder<QuerySnapshot>(
                    stream: _itemsCollection
                        .where('uid', isEqualTo: userId)
                        .snapshots(),
                    builder: (context, itemSnapshot) {
                      if (!itemSnapshot.hasData) {
                        return const CircularProgressIndicator();
                      }

                      List<QueryDocumentSnapshot> items =
                          itemSnapshot.data!.docs;

                      return StreamBuilder<QuerySnapshot>(
                        stream: _otherCollection
                            .where('uid', isEqualTo: userId)
                            .snapshots(),
                        builder: (context, otherSnapshot) {
                          if (!otherSnapshot.hasData) {
                            return const CircularProgressIndicator();
                          }

                          List<QueryDocumentSnapshot> otherItems =
                              otherSnapshot.data!.docs;

                          return ListView.builder(
                            itemCount: items.length + otherItems.length,
                            itemBuilder: (BuildContext context, int index) {
                              if (index < items.length) {
                                int itemPrice = items[index]['jumlah'];
                                String itemDescription =
                                    items[index]['kategori'];
                                Timestamp itemTimestamp =
                                    items[index]['tanggal'];

                                return ListTile(
                                  shape: RoundedRectangleBorder(
                                      borderRadius:
                                          BorderRadius.circular(10.0)),
                                  tileColor: const Color(0xFF4296F0),
                                  //Ini Teks Title Jumlah
                                  title: Text('$itemPrice'),
                                  titleTextStyle: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontFamily: 'Nunito',
                                    fontWeight: FontWeight.w500,
                                    height: 0,
                                  ),
                                  //Ini Subtitle Kategori
                                  subtitle: Text(itemDescription),
                                  subtitleTextStyle: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 14,
                                    fontFamily: 'Nunito',
                                    fontWeight: FontWeight.w200,
                                    height: 0,
                                  ),
                                  //Ini Tanggal
                                  trailing: Text(
                                    DateFormat('dd MMMM yyyy').format(
                                      itemTimestamp.toDate(),
                                    ),
                                  ),
                                  leadingAndTrailingTextStyle: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontFamily: 'Nunito',
                                    fontWeight: FontWeight.w200,
                                    height: 0,
                                  ),
                                  onTap: () {
                                    _showDeleteConfirmationDialog(
                                        items[index].id);
                                  },
                                );
                              } else {
                                int otherIndex = index - items.length;

                                String otherItemDescription =
                                    otherItems[otherIndex]['kategori'];
                                int otherItemPrice =
                                    otherItems[otherIndex]['jumlah'];
                                Timestamp otherItemTimestamp =
                                    otherItems[otherIndex]['tanggal'];

                                return ListTile(
                                  shape: RoundedRectangleBorder(
                                      borderRadius:
                                          BorderRadius.circular(10.0)),
                                  tileColor: const Color(0xFFF96D75),
                                  //Ini Jumlah
                                  title: Text('$otherItemPrice'),
                                  titleTextStyle: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontFamily: 'Nunito',
                                    fontWeight: FontWeight.w500,
                                    height: 0,
                                  ),
                                  //Ini Kategori
                                  subtitle: Text(otherItemDescription),
                                  subtitleTextStyle: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 14,
                                    fontFamily: 'Nunito',
                                    fontWeight: FontWeight.w200,
                                    height: 0,
                                  ),
                                  //Ini Tanggal
                                  trailing: Text(
                                    DateFormat('dd MMMM yyyy').format(
                                      otherItemTimestamp.toDate(),
                                    ),
                                  ),
                                  leadingAndTrailingTextStyle: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontFamily: 'Nunito',
                                    fontWeight: FontWeight.w200,
                                    height: 0,
                                  ),
                                  onTap: () {
                                    _showDeleteConfirmationDialog(
                                        otherItems[otherIndex].id);
                                  },
                                );
                              }
                            },
                          );
                        },
                      );
                    },
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

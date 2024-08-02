import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import 'ganti_pwd.dart';
import 'login.dart';
import 'utils/tombol.dart'; // Tambahkan ini

class HomeSalesPage extends StatefulWidget {
  final String varpbuser;
  final String varbagian;
  final String varlks;
  final String varnmlok;
  final String varsaldokas;
  final String myversion1;
  final String currentVersion;

  HomeSalesPage(this.varpbuser, this.varbagian, this.varlks, this.varnmlok, this.varsaldokas, this.myversion1, this.currentVersion);

  @override
  State<HomeSalesPage> createState() => _HomeSalesPageState();
}

class _HomeSalesPageState extends State<HomeSalesPage> {
  late double saldokasku;
  void lapPenjualanFunction() {
    Navigator.pushNamed(context, '/lapjual', arguments: [widget.varpbuser, widget.varbagian, widget.varlks, widget.varnmlok]);

    print("Lap. Penjualan clicked");
    // Tambahkan fungsi lain yang Anda inginkan
  }

  void stockFunction() {
    Navigator.pushNamed(context, '/lapstok', arguments: [widget.varpbuser, widget.varbagian, widget.varlks, widget.varnmlok]);
    print("Stock clicked");
    // Tambahkan fungsi lain yang Anda inginkan
  }

  void daftarHargaFunction() {
    Navigator.pushNamed(context, '/daftarharga', arguments: [widget.varpbuser, widget.varbagian, widget.varlks, widget.varnmlok]);

    print("Daftar Harga clicked");
    // Tambahkan fungsi lain yang Anda inginkan
  }

  void penjualanFunction() {
    print("Penjualan clicked");
    Navigator.pushNamed(context, '/jual', arguments: [widget.varpbuser, widget.varbagian, widget.varlks, widget.varnmlok]);
    // Tambahkan fungsi lain yang Anda inginkan
  }

  void setorFunction() {
    Navigator.pushNamed(context, '/setor', arguments: [widget.varpbuser, widget.varbagian, widget.varlks, widget.varnmlok]);

    print("Setor clicked");
    // Tambahkan fungsi lain yang Anda inginkan
  }

  void penjKaryawanFunction() {
    Navigator.pushNamed(context, '/penjkary', arguments: [widget.varpbuser, widget.varbagian, widget.varlks, widget.varnmlok]);

    print("Penj. Karyawan clicked");
    // Tambahkan fungsi lain yang Anda inginkan
  }

  void laporanFunction() {
    Navigator.pushNamed(context, '/lapkas', arguments: [widget.varpbuser, widget.varbagian, widget.varlks, widget.varnmlok]);

    print("Laporan clicked");
    // Tambahkan fungsi lain yang Anda inginkan
  }

  @override
  void initState() {
    super.initState();
    saldokasku = double.tryParse(widget.varsaldokas.replaceAll(',', '')) ?? 0.0;
  }

  Widget build(BuildContext context) {
    final numberFormat = NumberFormat.decimalPattern('id_ID');
    return Scaffold(
      backgroundColor: Colors.white.withOpacity(0.96),
      bottomNavigationBar: BottomNavigationBar(
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: ""),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: ""),
          BottomNavigationBarItem(icon: Icon(Icons.cable), label: ""),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
            scrollDirection: Axis.vertical,
            child: Column(
              children: [
                // Baris pertama
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      GestureDetector(
                        onTap: () {
                          showMenu(
                            color: Colors.white70,
                            context: context,
                            position: RelativeRect.fromLTRB(0.0, 0.0, 0.0, 0.0), // Ubah nilai ini
                            items: [
                              PopupMenuItem(
                                child: ListTile(
                                  title: Text('Ganti Password'),
                                  onTap: () {
                                    Navigator.pop(context); // Menutup menu sebelum menjalankan navigasi
                                    Future.delayed(Duration(milliseconds: 10), () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => GantiPwdPage(widget.varpbuser),
                                        ),
                                      );
                                    });
                                  },
                                ),
                              ),
                              PopupMenuItem(
                                child: ListTile(
                                  title: Text('Logout'),
                                  onTap: () {
                                    Navigator.pushAndRemoveUntil(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => LoginPage(myversion1: widget.myversion1, currentVersion: widget.currentVersion),
                                      ),
                                      (route) => false,
                                    );
                                  },
                                ),
                              ),
                            ],
                          );
                        },
                        child: Container(
                          child: Column(
                            children: [
                              Icon(
                                Icons.menu,
                                color: Colors.blue[700],
                              ),
                              Text(
                                '${widget.myversion1} / ${widget.currentVersion}',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.blue[700],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Container(
                        width: 250,
                        height: 50,
                        color: Colors.transparent,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Koperasi Kasih',
                              style: GoogleFonts.leagueSpartan(
                                color: Colors.blue[700],
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            Text(
                              widget.varnmlok,
                              style: GoogleFonts.quicksand(
                                color: Colors.blue[700],
                                fontSize: 18,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ), // Kotak untuk logo (sementara)
                      ),
                      GestureDetector(
                        // onTap: () {
                        //   showMenu(
                        //     color: Colors.white70,
                        //     context: context,
                        //     position: RelativeRect.fromLTRB(10.0, 80.0, 0.0, 0.0), // Ubah nilai ini
                        //     items: [
                        //       PopupMenuItem(
                        //         child: ListTile(
                        //           title: Text('Ganti Password'),
                        //           onTap: () {
                        //             Navigator.pop(context); // Menutup menu sebelum menjalankan navigasi
                        //             Future.delayed(Duration(milliseconds: 10), () {
                        //               Navigator.push(
                        //                 context,
                        //                 MaterialPageRoute(
                        //                   builder: (context) => GantiPwdPage(widget.varpbuser),
                        //                 ),
                        //               );
                        //             });
                        //           },
                        //         ),
                        //       ),
                        //       PopupMenuItem(
                        //         child: ListTile(
                        //           title: Text('Logout'),
                        //           onTap: () {
                        //             Navigator.pushAndRemoveUntil(
                        //               context,
                        //               MaterialPageRoute(
                        //                 builder: (context) => LoginPage(),
                        //               ),
                        //               (route) => false,
                        //             );
                        //           },
                        //         ),
                        //       ),
                        //     ],
                        //   );
                        // },
                        child: Container(
                          child: Column(
                            children: [
                              Icon(
                                Icons.person,
                                color: Colors.blue[700],
                              ),
                              Text(
                                widget.varpbuser,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.blue[700],
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    ],
                  ),
                ),
                // Baris kedua
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 20),
                  child: Row(
                    children: [
                      Container(
                        width: MediaQuery.of(context).size.width - 10, // Mengurangi padding kiri dan kanan
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.transparent,
                          borderRadius: BorderRadius.circular(20),
                          image: DecorationImage(
                            image: AssetImage('assets/biru2.png'),
                            fit: BoxFit.cover,
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start, // Aligns content to the left
                          children: [
                            Text(
                              'Saldo Kas',
                              style: TextStyle(
                                color: Colors.white,
                              ),
                              textAlign: TextAlign.left, // Align text to the left
                            ),
                            Text(
                              numberFormat.format(saldokasku),
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 50, // Larger font size
                                fontWeight: FontWeight.bold, // Bold font
                              ),
                              textAlign: TextAlign.left, // Align text to the left
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                // Baris ketiga
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      TombolWidget(
                        icon: Icons.list,
                        text: 'Lap. Penjualan',
                        onTap: lapPenjualanFunction,
                      ),
                      TombolWidget(
                        icon: Icons.checklist,
                        text: 'Stock',
                        onTap: stockFunction,
                      ),
                      TombolWidget(
                        icon: Icons.price_check_sharp,
                        text: 'Daftar Harga',
                        onTap: daftarHargaFunction,
                      ),
                    ],
                  ),
                ),
                //Baris keempat
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  child: GestureDetector(
                    onTap: penjualanFunction,
                    child: Column(children: [
                      Container(
                        padding: const EdgeInsets.all(30),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(80),
                        ),
                        child: Column(
                          children: [
                            Icon(Icons.local_grocery_store, size: 100, color: Colors.blue[700]),
                            Text('Penjualan', style: TextStyle(color: Colors.blue[700])),
                          ],
                        ),
                      ),
                    ]),
                  ),
                ),
                //Baris kelima
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      TombolWidget(
                        icon: Icons.monetization_on,
                        text: 'Setor',
                        onTap: setorFunction,
                      ),
                      TombolWidget(
                        icon: Icons.emoji_people,
                        text: 'Penj. Karyawan',
                        onTap: penjKaryawanFunction,
                      ),
                      TombolWidget(
                        icon: Icons.library_books,
                        text: 'Laporan Kas',
                        onTap: laporanFunction,
                      ),
                    ],
                  ),
                ),
              ],
            )),
      ),
    );
  }
}

import 'package:flutter/cupertino.dart';
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
  String varsaldokas;
  final String myversion1;
  final String currentVersion;

  HomeSalesPage(this.varpbuser, this.varbagian, this.varlks, this.varnmlok, this.varsaldokas, this.myversion1, this.currentVersion);

  @override
  State<HomeSalesPage> createState() => _HomeSalesPageState();
}

class _HomeSalesPageState extends State<HomeSalesPage> {
  late double saldokasku;
  final NumberFormat numberFormat = NumberFormat.decimalPattern('id_ID'); // Format number

  @override
  void initState() {
    super.initState();
    // Inisialisasi saldo kas dengan menghilangkan karakter non-numerik dan memastikan nilai positif
    saldokasku = double.tryParse(widget.varsaldokas.replaceAll(',', '').replaceAll('-', '')) ?? 0.0;
    // Jika saldo kas bisa negatif, maka periksa dan atur
    if (double.tryParse(widget.varsaldokas.replaceAll(',', '')) != null) {
      saldokasku = double.tryParse(widget.varsaldokas.replaceAll(',', ''))!;
    }
  }

  void lapPenjualanFunction() {
    Navigator.pushNamed(context, '/lapjual', arguments: [widget.varpbuser, widget.varbagian, widget.varlks, widget.varnmlok]);
    print("Lap. Penjualan clicked");
  }

  void stockFunction() {
    Navigator.pushNamed(context, '/lapstok', arguments: [widget.varpbuser, widget.varbagian, widget.varlks, widget.varnmlok]);
    print("Stock clicked");
  }

  void daftarHargaFunction() {
    Navigator.pushNamed(context, '/daftarharga', arguments: [widget.varpbuser, widget.varbagian, widget.varlks, widget.varnmlok]);
    print("Daftar Harga clicked");
  }

  void penjualanFunction() {
    print("Penjualan clicked");
  }

  void setorFunction() {
    Navigator.pushNamed(context, '/setor', arguments: [widget.varpbuser, widget.varbagian, widget.varlks, widget.varnmlok]);
    print("Setor clicked");
  }

  void penjKaryawanFunction() {
    Navigator.pushNamed(context, '/penjkary', arguments: [widget.varpbuser, widget.varbagian, widget.varlks, widget.varnmlok]);
    print("Penj. Karyawan clicked");
  }

  void lapsetor() {
    Navigator.pushNamed(context, '/daftarsetor', arguments: [widget.varpbuser, widget.varbagian, widget.varlks, widget.varnmlok]);
    print("Lap. Daftar Setor clicked");
  }

  void julablmlunas() {
    Navigator.pushNamed(context, '/daftarblmlunas', arguments: [widget.varpbuser, widget.varbagian, widget.varlks, widget.varnmlok]);
  }

  void laporanFunction() {
    Navigator.pushNamed(context, '/lapkas', arguments: [widget.varpbuser, widget.varbagian, widget.varlks, widget.varnmlok]);
    print("Laporan clicked");
  }

  void returjual() {
    Navigator.pushNamed(context, '/returjual', arguments: [widget.varpbuser, widget.varbagian, widget.varlks, widget.varnmlok, widget.varsaldokas]);
    print("Retur Penjualan diklik");
  }

  @override
  Widget build(BuildContext context) {
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
                //header
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    GestureDetector(
                      onTap: () {
                        showMenu(
                          color: Colors.white70,
                          context: context,
                          position: RelativeRect.fromLTRB(0.0, 0.0, 0.0, 0.0),
                          items: [
                            PopupMenuItem(
                              child: ListTile(
                                title: Text('Ganti Password'),
                                onTap: () {
                                  Navigator.pop(context);
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
                                fontSize: 10,
                                color: Colors.blue[700],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Container(
                      width: 250,
                      height: 60,
                      color: Colors.transparent,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          //Nama Company
                          Text(
                            'Koperasi Kasih',
                            style: GoogleFonts.leagueSpartan(
                              color: Colors.blue[700],
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          // Nama Lokasi
                          Text(
                            widget.varnmlok,
                            style: GoogleFonts.quicksand(
                              color: Colors.blue[700],
                              fontSize: 16,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                    GestureDetector(
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
              // Saldo kas
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 20),
                child: Row(
                  children: [
                    Container(
                      width: MediaQuery.of(context).size.width - 10,
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
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Saldo Kas',
                            style: TextStyle(
                              color: Colors.white,
                            ),
                            textAlign: TextAlign.left,
                          ),
                          Text(
                            // Jika saldo negatif, tambahkan tanda minus pada format
                            widget.varsaldokas.contains('-') ? numberFormat.format(-saldokasku) : numberFormat.format(saldokasku),
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 50,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.left,
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
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      TombolWidget(
                        icon: Icons.list,
                        text: 'Lap. Penjualan',
                        onTap: lapPenjualanFunction,
                      ),
                      SizedBox(width: 10),
                      TombolWidget(
                        icon: Icons.checklist,
                        text: 'Stock',
                        onTap: stockFunction,
                      ),
                      SizedBox(width: 10),
                      TombolWidget(
                        icon: Icons.price_check_sharp,
                        text: 'Daftar Harga',
                        onTap: daftarHargaFunction,
                      ),
                      SizedBox(width: 10),
                      TombolWidget(
                        icon: CupertinoIcons.cart_fill_badge_minus,
                        text: 'Retur Penjualan',
                        onTap: returjual,
                      ),
                      SizedBox(width: 10),
                    ],
                  ),
                ),
              ),
              // Baris keempat
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 20),
                child: GestureDetector(
                  onTap: () async {
                    final updatedSaldo = await Navigator.pushNamed(
                      context,
                      '/jual',
                      arguments: [
                        widget.varpbuser,
                        widget.varbagian,
                        widget.varlks,
                        widget.varnmlok,
                        widget.varsaldokas,
                      ],
                    );
                    print('update saldo $updatedSaldo');
                    if (updatedSaldo != null) {
                      setState(() {
                        widget.varsaldokas = updatedSaldo as String;
                        // Update saldo kas dengan nilai yang diterima
                        saldokasku = double.tryParse(widget.varsaldokas.replaceAll(',', '').replaceAll('-', '')) ?? 0.0;
                      });
                    }
                  },
                  child: Container(
                    padding: EdgeInsets.all(15), // Ukuran besar padding untuk icon
                    decoration: BoxDecoration(
                      color: Colors.blue[700], // Warna latar belakang ikon
                      shape: BoxShape.circle, // Bentuk ikon
                    ),
                    child: Icon(
                      CupertinoIcons.cart_fill_badge_plus, // Ganti dengan ikon yang diinginkan
                      color: Colors.white, // Warna ikon
                      size: 80, // Ukuran ikon
                    ),
                  ),
                ),
              ),

              // Baris kelima
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 20),
                child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        TombolWidget(
                          icon: Icons.monetization_on,
                          text: 'Setor',
                          onTap: setorFunction,
                        ),
                        SizedBox(width: 10),
                        TombolWidget(
                          icon: Icons.emoji_people,
                          text: 'Penj. Karyawan',
                          onTap: penjKaryawanFunction,
                        ),
                        SizedBox(width: 10),
                        TombolWidget(
                          icon: Icons.library_books,
                          text: 'Laporan Kas',
                          onTap: laporanFunction,
                        ),
                        SizedBox(width: 10),
                        TombolWidget(
                          icon: Icons.list_alt_sharp,
                          text: 'Daftar Setoran',
                          onTap: lapsetor,
                        ),
                        SizedBox(width: 10),
                        TombolWidget(
                          icon: Icons.question_mark,
                          text: 'Penjualan blm Lunas',
                          onTap: julablmlunas,
                        ),
                      ],
                    )),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

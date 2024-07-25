import 'package:barcode_scan2/barcode_scan2.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pos/item_search_popup.dart';

import 'bayarjual.dart';
import 'customer_search_popup.dart';
import 'report.dart';
import 'service.dart';
import 'transaction_search_popup.dart';

class JualPage extends StatefulWidget {
  final String varpbuser;
  final String varbagian;
  final String varlks;
  final String varnmlok;

  JualPage(this.varpbuser, this.varbagian, this.varlks, this.varnmlok);
  @override
  State<JualPage> createState() => _JualPageState();
}

class _JualPageState extends State<JualPage> {
  String barcodeResult = "";
  TextEditingController barcodeController = TextEditingController();
  TextEditingController namaController = TextEditingController();
  TextEditingController hargaController = TextEditingController();
  TextEditingController jumlahController = TextEditingController();
  TextEditingController subttlController = TextEditingController();
  TextEditingController diskonController = TextEditingController();
  TextEditingController totalController = TextEditingController();
  TextEditingController notransController = TextEditingController();
  TextEditingController kdcustController = TextEditingController();
  TextEditingController nmcustController = TextEditingController();

  // Tambahkan variabel untuk menyimpan data transaksi
  List<Map<String, dynamic>> transaksiData = [];
  final NumberFormat currencyFormat = NumberFormat("#,##0", "en_US");
  double totbayar = 0.0;

  // String hrsbayar = '0';
  double hrsbayar = 0.0;

  @override
  void initState() {
    super.initState();
    jumlahController.addListener(_updateSubtotalAndTotal);
    notransController.text = 'Transaksi Baru';
    kdcustController.text = '01';
    nmcustController.text = 'Customer Umum';

    // Inisialisasi printer Bluetooth
  }

  @override
  void dispose() {
    jumlahController.removeListener(_updateSubtotalAndTotal);
    jumlahController.dispose();
    barcodeController.dispose();
    namaController.dispose();
    hargaController.dispose();
    subttlController.dispose();
    totalController.dispose();
    diskonController.dispose();
    notransController.dispose();
    kdcustController.dispose();
    nmcustController.dispose();
    super.dispose();
  }

  void _updateSubtotalAndTotal() {
    if (hargaController.text.isNotEmpty && jumlahController.text.isNotEmpty) {
      final formatter = NumberFormat("#,###");
      int hargaJual = int.tryParse(hargaController.text.replaceAll(',', '')) ?? 0;
      int jumlah = int.tryParse(jumlahController.text) ?? 0;
      int subtotal = hargaJual * jumlah;
      int diskon = int.tryParse(diskonController.text.replaceAll(',', '')) ?? 0;
      int total = subtotal - diskon;

      setState(() {
        subttlController.text = formatter.format(subtotal);
        totalController.text = formatter.format(total);
      });
    }
  }

  void printData() async {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ReportPage(
          reportData: transaksiData,
          varpbuser: widget.varpbuser,
          varnotrans: notransController.text,
        ),
      ),
    );
    print('transaksiData: $transaksiData');
  }

  // Pastikan untuk memanggil fungsi ini ketika mempersiapkan halaman atau setelah scan barcode
  void prepareTransaction() {
    // Contoh sederhana untuk mengatur No Trans, ganti dengan logika yang sesuai
    if (notransController.text.isEmpty) {
      notransController.text = "NT-${DateTime.now().millisecondsSinceEpoch}";
    }
  }

  void input() async {
    try {
      //  print('inputtrans2');
      // print('Barcode: ${barcodeController.text}');
      // print('Jumlah: ${jumlahController.text}');
      // print('Harga: ${hargaController.text.replaceAll(',', '')}'); // Hapus koma
      // print('No Trans: ${notransController.text}');

      if (barcodeController.text.isNotEmpty &&
          jumlahController.text.isNotEmpty &&
          hargaController.text.isNotEmpty &&
          notransController.text.isNotEmpty) {
        var result = await ApiService.inputtrans2(
            barcodeController.text,
            jumlahController.text,
            hargaController.text.replaceAll(',', ''), // Hapus koma sebelum mengirim ke API
            widget.varpbuser,
            kdcustController.text, //kdcust
            "01", //ntop
            "keth", //keth
            "01", //kdsales
            notransController.text,
            widget.varlks //notrans
            );
        // print('input2');

        setState(() {
          transaksiData =
              result.map((item) => {'nama': item['nama'], 'harga': item['nrp'], 'jumlah': item['nqty'], 'subtotal': item['subtotal']}).toList();

          // Perbarui notransController dengan notrans dari respons API
          if (result.isNotEmpty && result[0].containsKey('notrans')) {
            notransController.text = result[0]['notrans'];
          }

          // Mengatur ulang nilai controller setelah menambahkan data ke tabel
          barcodeController.clear();
          namaController.clear();
          kdcustController.text = '01';
          nmcustController.text = 'Customer Umum';
          hargaController.text = '0';
          jumlahController.text = '0';
          subttlController.text = '0';
          diskonController.text = '0';
          totalController.text = '0';
          totbayar = 0.0;
        });
      }
    } catch (e) {
      print('Error saat input transaksi: $e');
    }
  }

  Future<void> scanBarcode() async {
    try {
      var result = await BarcodeScanner.scan();
      setState(() {
        barcodeResult = result.rawContent;
        barcodeController.text = barcodeResult;
        print('barcode');
      });
      fetchProductDetails();
    } catch (e) {
      setState(() {
        barcodeResult = 'Kesalahan dalam memindai barcode: $e';
        barcodeController.text = barcodeResult;
      });
    }
  }

  void searchTransactions() {
    // print('serachTrans');
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return TransactionSearchPopup(
          varpbuser: widget.varpbuser,
          varlks: widget.varlks, // Menambahkan varlks disini
          onTransactionSelected: (notrans, nbayar) {
            onTransactionSelected(notrans, nbayar);
          },
        );
      },
    );
  }

  void onTransactionSelected(String notran, String nbayar) async {
    try {
      List<Map<String, dynamic>> result = await ApiService.lapjualperno(widget.varpbuser, notran);

      if (result.isNotEmpty) {
        setState(() {
          notransController.text = result[0]['notrans'] ?? '';
          kdcustController.text = result[0]['kdcust'] ?? '';
          nmcustController.text = result[0]['nmcust'] ?? '';
          totbayar = double.parse(nbayar.replaceAll(',', ''));
          //nbayar;
          print(totbayar);
          transaksiData =
              result.map((item) => {'nama': item['nmbarang'], 'harga': item['nrp'], 'jumlah': item['nqty'], 'subtotal': item['subtotal']}).toList();
        });
      }
    } catch (e) {
      print('Error fetching transaction details: $e');
    }
  }

  Future<void> fetchProductDetails() async {
    try {
      var details = await ApiService.crbarang(widget.varpbuser, barcodeResult, '1');
      print('proses cari kode barang 2');
      final formatter = NumberFormat("#,###");

      setState(() {
        namaController.text = details['nama'];
        hargaController.text = formatter.format(int.parse(details['hargaJual']));
        jumlahController.text = '1';
        subttlController.text = formatter.format(int.parse(details['hargaJual']) * int.parse(jumlahController.text));
        diskonController.text = '0';
        totalController.text =
            formatter.format((int.parse(details['hargaJual']) * int.parse(jumlahController.text) - int.parse(diskonController.text)));
      });
    } catch (e) {
      setState(() {
        print('Error fetching product details: $e');
        namaController.text = 'Gagal memuat data';
        hargaController.text = 'Gagal memuat data';
        subttlController.text = '0';
        jumlahController.text = '1';
        diskonController.text = '0';
        totalController.text = '0';
      });
    }
  }

  // Widget untuk menampilkan data transaksi dengan kemampuan scroll horizontal
  Widget buildTransaksiTable() {
    final formatter = NumberFormat("#,###", "id_ID"); // Menggunakan locale Indonesia

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: DataTable(
          columns: const [
            DataColumn(label: Text('Nama Barang')),
            DataColumn(label: Text('Harga')),
            DataColumn(label: Text('Jumlah')),
            DataColumn(label: Text('Subtotal')),
          ],
          rows: transaksiData.map((data) {
            return DataRow(cells: [
              DataCell(Text(data['nama'] ?? 'Nama tidak tersedia')),
              DataCell(Text(formatter.format(int.parse(data['harga'].toString())))),
              DataCell(Text(data['jumlah'].toString())),
              DataCell(Text(formatter.format(int.parse(data['subtotal'].toString())))),
            ]);
          }).toList(),
        ),
      ),
    );
  }

  String calculateGrandTotal() {
    final formatter = NumberFormat("#,###", "id_ID"); // Menggunakan locale Indonesia
    int total = transaksiData.fold(0, (sum, item) {
      int subtotal = int.tryParse(item['subtotal'].toString()) ?? 0;
      return sum + subtotal;
    });

    return formatter.format(total); // Format total dengan pemisah ribuan dan kembalikan sebagai String
  }

  String hitungbayar() {
    final formatter = NumberFormat("#,###", "id_ID"); // Menggunakan locale Indonesia
    int total = transaksiData.fold(0, (sum, item) {
      int totbayar = int.tryParse(item['nbayar'].toString()) ?? 0;
      return sum + totbayar;
    });

    return formatter.format(total); // Format total dengan pemisah ribuan dan kembalikan sebagai String
  }

  void clearTransactionData() {
    setState(() {
      transaksiData.clear(); // Mengosongkan list transaksiData
    });
  }

  void showPaymentDialog() async {
    print("Isi transaksiData: $transaksiData");

    String grandTotal = calculateGrandTotal(); // Mengambil nilai Grand Total

    // Menunggu nilai yang dikembalikan dari bayarjual.dart
    final paymentValue = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return PaymentDialog(
          notrans: notransController.text,
          grandTotal: grandTotal,
          totbayar: currencyFormat.format(totbayar),
          username: widget.varpbuser,
          varlks: widget.varlks,
        );
      },
    );

// Pastikan paymentValue tidak null dan lakukan update yang diperlukan
    if (paymentValue != null) {
      setState(() {
        double bayar = double.tryParse(paymentValue) ?? 0.0;

        // Pastikan totbayar adalah String sebelum melakukan replaceAll
        String totbayarString = totbayar.toString();
        double currentTotbayar = double.tryParse(totbayarString.replaceAll(',', '')) ?? 0.0;

        // Tambahkan bayar ke currentTotbayar jika diperlukan
        currentTotbayar = bayar;

        final formatter = NumberFormat("#,###");
        print(currentTotbayar.runtimeType);
        //totbayar = formatter.format(currentTotbayar);
        totbayar = currentTotbayar;
      });
    }
  }

  void caribrgmanual() async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return ItemSearchPopup(
          varpbuser: widget.varpbuser,
          onItemSelected: (kode, nama, nhargajual) {
            setState(() {
              final formatter = NumberFormat("#,###");
              barcodeController.text = kode;
              namaController.text = nama;
              //hargaController.text = nhargajual;
              hargaController.text = formatter.format(int.parse(nhargajual));
              jumlahController.text = '1';
              //subttlController.text = nhargajual;
              subttlController.text = formatter.format(int.parse(nhargajual));
            });
          },
        );
      },
    );
  }

  void _searchCustomer() async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return CustomerSearchPopup(
          varpbuser: widget.varpbuser,
          onCustomerSelected: (kode, nama) {
            setState(() {
              kdcustController.text = kode;
              nmcustController.text = nama;
            });
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.grey[700],
          title: const Text("Penjualan...."),
        ),
        body: SafeArea(
            child: SingleChildScrollView(
          child: Column(children: [
            SizedBox(height: 10),
            TextField(
              readOnly: true,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'No. Transaksi',
              ),
              controller: notransController,
            ),
            Divider(
              color: Colors.black, // Warna garis
              thickness: 2, // Ketebalan garis
              indent: 10, // Jarak dari awal garis ke tepi kiri
              endIndent: 10, // Jarak dari akhir garis ke tepi kanan
            ),
            SizedBox(height: 10),

            Row(
              children: [
                SizedBox(height: 20),
                Expanded(
                  flex: 2,
                  child: TextField(
                    readOnly: true,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Kode Customer',
                    ),
                    controller: kdcustController,
                  ),
                ),
                SizedBox(width: 5),
                IconButton(
                  icon: Icon(Icons.search),
                  onPressed: _searchCustomer,
                ),
              ],
            ),
            SizedBox(height: 5),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                nmcustController.text,
                style: TextStyle(
                  fontSize: 16.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Divider(
              color: Colors.black, // Warna garis
              thickness: 2, // Ketebalan garis
              indent: 10, // Jarak dari awal garis ke tepi kiri
              endIndent: 10, // Jarak dari akhir garis ke tepi kanan
            ),
            SizedBox(height: 5),
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: TextField(
                    readOnly: true,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Kode',
                    ),
                    controller: barcodeController,
                  ),
                ),
                SizedBox(width: 5),
                IconButton(
                  icon: Icon(Icons.camera_alt),
                  onPressed: scanBarcode,
                ),
                IconButton(
                  icon: Icon(Icons.search),
                  onPressed: caribrgmanual, // Panggil fungsi pencarian
                ),
                IconButton(
                  icon: Icon(Icons.refresh),
                  onPressed: () {
                    barcodeController.clear();
                    namaController.clear();
                    hargaController.text = '0';
                    jumlahController.text = '0';
                    subttlController.text = '0';
                    diskonController.text = '0';
                    totalController.text = '0';
                    notransController.text = 'baru';
                    kdcustController.text = '01';
                    nmcustController.text = 'Customer Umum';
                    totbayar = 0.0;
                    clearTransactionData(); // Mengosongkan transaksiData
                  },
                ),
              ],
            ),
            SizedBox(height: 10),
            TextField(
              readOnly: true,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Nama Barang',
              ),
              controller: namaController,
            ),
            SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  flex: 2, // Memberi lebih banyak ruang untuk harga jual
                  child: TextField(
                    readOnly: true,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Harga Jual',
                    ),
                    controller: hargaController,
                  ),
                ),
                SizedBox(width: 10), // Menambahkan sedikit ruang antar TextField
                Expanded(
                  flex: 1, // Memberi lebih sedikit ruang untuk QTY
                  child: TextField(
                    keyboardType: TextInputType.number, // Keyboard numerik untuk QTY
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'QTY',
                    ),
                    controller: jumlahController,
                  ),
                ),
              ],
            ),
            SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                    flex: 2,
                    child: TextField(
                      readOnly: true,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: 'Sub Total',
                      ),
                      controller: subttlController,
                    )),
                SizedBox(width: 5),
                Expanded(
                    flex: 1,
                    child: TextField(
                      keyboardType: TextInputType.number, // Keyboard numerik untuk Diskon
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: 'Diskon',
                      ),
                      controller: diskonController,
                    )),
              ],
            ),
            SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: TextField(
                    readOnly: true,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Total',
                    ),
                    controller: totalController,
                  ),
                ),
                SizedBox(width: 5),
                Expanded(
                    child: Container(
                  decoration: BoxDecoration(
                    color: Colors.grey[500], // Warna abu-abu
                    shape: BoxShape.circle, // Bentuk lingkaran
                  ),
                  child: IconButton(
                    onPressed: input,
                    icon: Icon(Icons.add),
                    color: Colors.black, // Warna ikon
                  ),
                )),
              ],
            ),
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              // Bagian A
              Expanded(
                child: Text(
                  'Grand Total : ${calculateGrandTotal()}',
                  textAlign: TextAlign.left, // Menyelaraskan teks ke kiri
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ),
            ]),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Bagian A
                Expanded(
                  child: Text(
                    'Total Bayar : ${currencyFormat.format(totbayar)}',
                    textAlign: TextAlign.left, // Menyelaraskan teks ke kiri
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ),

                // Bagian B
                Expanded(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      IconButton(
                        icon: Icon(Icons.payment),
                        onPressed: !transaksiData.any((item) => item['llunas'] == '1') ? showPaymentDialog : null,
                      ),
                      IconButton(
                        icon: Icon(Icons.print),
                        onPressed: printData,
                      ),
                      IconButton(
                        icon: Icon(Icons.search),
                        onPressed: searchTransactions, // Panggil fungsi pencarian
                      ),
                      // IconButton(
                      //   icon: Icon(Icons.book),
                      //   onPressed: () {
                      //     Navigator.pushNamed(context, '/lapjual');
                      //   }, // Tambahkan fungsi
                      // ),
                    ],
                  ),
                ),
              ],
            ),
            Divider(
              color: Colors.black, // Warna garis
              thickness: 2, // Ketebalan garis
              indent: 10, // Jarak dari awal garis ke tepi kiri
              endIndent: 10, // Jarak dari akhir garis ke tepi kanan
            ),
            buildTransaksiTable(), // Tambahkan widget tabel di UI
          ]),
        )));
  }
}

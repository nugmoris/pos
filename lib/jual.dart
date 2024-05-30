import 'package:barcode_scan2/barcode_scan2.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'report.dart';
import 'service.dart';

class JualPage extends StatefulWidget {
  const JualPage({super.key});
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

  // Tambahkan variabel untuk menyimpan data transaksi
  List<Map<String, dynamic>> transaksiData = [];

  @override
  void initState() {
    super.initState();
    jumlahController.addListener(_updateSubtotalAndTotal);
    notransController.text = 'notrans';
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
    super.dispose();
  }

  void _updateSubtotalAndTotal() {
    if (hargaController.text.isNotEmpty && jumlahController.text.isNotEmpty) {
      final formatter = NumberFormat("#,###");
      int hargaJual =
          int.tryParse(hargaController.text.replaceAll(',', '')) ?? 0;
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
          varpbuser: "username",
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
      print('input1');
      print('Barcode: ${barcodeController.text}');
      print('Jumlah: ${jumlahController.text}');
      print('Harga: ${hargaController.text.replaceAll(',', '')}'); // Hapus koma
      print('No Trans: ${notransController.text}');

      if (barcodeController.text.isNotEmpty &&
          jumlahController.text.isNotEmpty &&
          hargaController.text.isNotEmpty &&
          notransController.text.isNotEmpty) {
        var result = await ApiService.inputtrans(
          barcodeController.text,
          jumlahController.text,
          hargaController.text
              .replaceAll(',', ''), // Hapus koma sebelum mengirim ke API
          "username",
          "01",
          "01",
          "keth",
          "01",
          notransController.text,
        );
        print('input2');

        setState(() {
          transaksiData = result
              .map((item) => {
                    'nama': item['nama'],
                    'harga': item['nrp'],
                    'jumlah': item['nqty'],
                    'subtotal': item['subtotal']
                  })
              .toList();

          // Perbarui notransController dengan notrans dari respons API
          if (result.isNotEmpty && result[0].containsKey('notrans')) {
            notransController.text = result[0]['notrans'];
          }

          // Mengatur ulang nilai controller setelah menambahkan data ke tabel
          barcodeController.clear();
          namaController.clear();
          hargaController.text = '0';
          jumlahController.text = '0';
          subttlController.text = '0';
          diskonController.text = '0';
          totalController.text = '0';
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
      });
      fetchProductDetails();
    } catch (e) {
      setState(() {
        barcodeResult = 'Kesalahan dalam memindai barcode: $e';
        barcodeController.text = barcodeResult;
      });
    }
  }

  void searchTransactions() async {
    try {
      // Ambil tanggal hari ini
      String today = DateFormat('yyyy-MM-dd').format(DateTime.now());

      // Panggil API untuk mengambil laporan penjualan
      List<Map<String, dynamic>> result =
          await ApiService.lapjual(today, today, "1");

      // Tampilkan hasil dalam bentuk dialog
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Hasil Pencarian'),
            content: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: SingleChildScrollView(
                scrollDirection: Axis.vertical,
                child: DataTable(
                  columns: const [
                    DataColumn(label: Text('No Transaksi')),
                    DataColumn(label: Text('Total')),
                  ],
                  rows: result.map((data) {
                    return DataRow(cells: [
                      DataCell(Text(data['notrans'])),
                      DataCell(Text(data['tot'])),
                    ]);
                  }).toList(),
                ),
              ),
            ),
            actions: <Widget>[
              TextButton(
                child: Text('Tutup'),
                onPressed: () {
                  Navigator.of(context).pop(); // Tutup dialog
                },
              ),
            ],
          );
        },
      );
    } catch (e) {
      print('Error fetching transaction data: $e');
    }
  }

  Future<void> fetchProductDetails() async {
    try {
      var details = await ApiService.crbarang("username", barcodeResult);
      final formatter = NumberFormat("#,###");

      setState(() {
        namaController.text = details['nama'];
        hargaController.text =
            formatter.format(int.parse(details['hargaJual']));
        jumlahController.text = '1';
        subttlController.text = formatter.format(
            int.parse(details['hargaJual']) * int.parse(jumlahController.text));
        diskonController.text = '0';
        totalController.text = formatter.format(
            (int.parse(details['hargaJual']) *
                    int.parse(jumlahController.text) -
                int.parse(diskonController.text)));
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
    final formatter =
        NumberFormat("#,###", "id_ID"); // Menggunakan locale Indonesia

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
              DataCell(
                  Text(formatter.format(int.parse(data['harga'].toString())))),
              DataCell(Text(data['jumlah'].toString())),
              DataCell(Text(
                  formatter.format(int.parse(data['subtotal'].toString())))),
            ]);
          }).toList(),
        ),
      ),
    );
  }

  String calculateGrandTotal() {
    final formatter =
        NumberFormat("#,###", "id_ID"); // Menggunakan locale Indonesia
    int total = transaksiData.fold(0, (sum, item) {
      int subtotal = int.tryParse(item['subtotal'].toString()) ?? 0;
      return sum + subtotal;
    });

    return formatter.format(
        total); // Format total dengan pemisah ribuan dan kembalikan sebagai String
  }

  void clearTransactionData() {
    setState(() {
      transaksiData.clear(); // Mengosongkan list transaksiData
    });
  }

  void showPaymentDialog() {
    print("Isi transaksiData: $transaksiData");
    //  bool isPaymentEnabled = transaksiData.any((item) => item['llunas'] == '0');
    //  print("isPaymentEnabled: $isPaymentEnabled");

    TextEditingController paymentController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        String grandTotal =
            calculateGrandTotal(); // Mengambil nilai Grand Total
        return AlertDialog(
          title: Text('Pembayaran'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('No Transaksi: ${notransController.text}'),
                Text(
                    'Tanggal: ${DateFormat('dd-MM-yyyy').format(DateTime.now())}'),
                Text(
                  'Grand Total: $grandTotal',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                TextField(
                  controller: paymentController,
                  decoration: InputDecoration(
                    labelText: 'Nilai Bayar',
                    hintText: 'Masukkan jumlah pembayaran',
                  ),
                  keyboardType: TextInputType.number,
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Batal'),
              onPressed: () {
                Navigator.of(context).pop(); // Tutup dialog
              },
            ),
            TextButton(
                child: Text('Bayar'),
                onPressed: () async {
                  // Logika pembayaran atau validasi bisa ditambahkan di sini
                  try {
                    var paymentData = await ApiService.bayarjual(
                        notransController.text,
                        grandTotal.replaceAll(",",
                            ""), // Menggunakan Grand Total sebagai nrp, menghapus koma untuk format angka
                        "username", // Sesuaikan dengan data yang diperlukan
                        "01" // Sesuaikan dengan data yang diperlukan
                        );
                    print('Pembayaran berhasil: $paymentData');
                    Navigator.of(context).pop(); // Tutup dialog setelah bayar
                    setState(() {
                      // Update UI atau state jika diperlukan
                    });
                  } catch (e) {
                    print('Error saat melakukan pembayaran: $e');
                  }
                }
                // Tombol akan dinonaktifkan jika semua transaksi lunas
                ),
          ],
        );
      },
    );
  }

  // Fungsi untuk mencari dan terhubung ke printer Bluetooth

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text("Penjualan"),
        ),
        body: SafeArea(
            child: SingleChildScrollView(
          child: Column(children: [
            TextField(
              readOnly: true,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'No. Transaksi',
              ),
              controller: notransController,
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
                SizedBox(
                    width: 10), // Menambahkan sedikit ruang antar TextField
                Expanded(
                  flex: 1, // Memberi lebih sedikit ruang untuk QTY
                  child: TextField(
                    keyboardType:
                        TextInputType.number, // Keyboard numerik untuk QTY
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
                      keyboardType:
                          TextInputType.number, // Keyboard numerik untuk Diskon
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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Bagian A
                Expanded(
                  child: Text(
                    'Grand Total: ${calculateGrandTotal()}',
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
                        onPressed:
                            !transaksiData.any((item) => item['llunas'] == '1')
                                ? showPaymentDialog
                                : null,
                      ),
                      IconButton(
                        icon: Icon(Icons.print),
                        onPressed: printData,
                      ),
                      IconButton(
                        icon: Icon(Icons.search),
                        onPressed:
                            searchTransactions, // Panggil fungsi pencarian
                      ),
                      IconButton(
                        icon: Icon(Icons.report_off_rounded),
                        onPressed: () {
                          Navigator.pushNamed(context, '/lapjual');
                        }, // Tambahkan fungsi
                      ),
                    ],
                  ),
                ),
              ],
            ),
            buildTransaksiTable(), // Tambahkan widget tabel di UI
          ]),
        )));
  }
}

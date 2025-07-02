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
  final String varsaldokas;

  JualPage(this.varpbuser, this.varbagian, this.varlks, this.varnmlok,
      this.varsaldokas);
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
  TextEditingController totbayarku = TextEditingController();

  // Tambahkan variabel untuk menyimpan data transaksi
  List<Map<String, dynamic>> transaksiData = [];
  final NumberFormat currencyFormat = NumberFormat("#,##0", "en_US");
  double totbayar = 0.0;

  String nmbarang1 = '';
  String lmatang = '0';
  String nhargamatang1 = '0';
  String nhargajual1 = '0';
  bool matang = false; // This should be set based on your search result
  bool isChecked = false; // To track the state of the checkbox
  double hrsbayar = 0.0;
  double saldokasku = 0.0;
  //double totbayarController = 0.0;
  String varsaldokas = '0';
  String urut = '0';
  bool isProcessing = false;

  @override
  void initState() {
    super.initState();
    jumlahController.addListener(_updateSubtotalAndTotal);
    notransController.text = 'Transaksi Baru';
    kdcustController.text = '01';
    nmcustController.text = 'Customer Umum';
    // totBayarController = 0.0;
    totbayarku.text = '0';
    saldokasku = double.tryParse(widget.varsaldokas.replaceAll(',', '')) ?? 0.0;
  }

  @override
  void dispose() {
    jumlahController.removeListener(_updateSubtotalAndTotal);
    //jumlahFocusNode.dispose();
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
    // totBayarController.dispose();
    super.dispose();
  }

  void updateSaldo(double payment) {
    setState(() {
      saldokasku += payment;
    });
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
    if (isProcessing) return; // jika masih proses, abaikan klik
    setState(() {
      isProcessing = true;
    });

    try {
      if (barcodeController.text.isNotEmpty &&
          jumlahController.text.isNotEmpty &&
          hargaController.text.isNotEmpty &&
          notransController.text.isNotEmpty) {
        // Cek apakah barcode dan jumlah yang sama sudah ada
        bool isDuplicate = transaksiData.any((item) =>
            item['nama'] == namaController.text &&
            item['harga'].toString().replaceAll(',', '') ==
                hargaController.text.replaceAll(',', '') &&
            item['jumlah'].toString() == jumlahController.text);

        if (isDuplicate) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text("Barang dengan jumlah yang sama sudah diinput")),
          );
          return;
        }

        var result = await ApiService.inputtrans3(
            barcodeController.text,
            jumlahController.text,
            hargaController.text.replaceAll(',', ''),
            widget.varpbuser,
            kdcustController.text,
            "01",
            "keth",
            "01",
            notransController.text,
            widget.varlks,
            isChecked ? '1' : '0');

        setState(() {
          transaksiData = result
              .map((item) => {
                    'nama': item['nama'],
                    'harga': item['nrp'],
                    'jumlah': item['nqty'],
                    'subtotal': item['subtotal'],
                    'llunas': item['llunas'],
                    'urut': item['urut']
                  })
              .toList();

          if (result.isNotEmpty && result[0].containsKey('notrans')) {
            notransController.text = result[0]['notrans'];
          }

          barcodeController.clear();
          namaController.clear();
          kdcustController.text = '01';
          hargaController.text = '0';
          jumlahController.text = '0';
          subttlController.text = '0';
          diskonController.text = '0';
          totalController.text = '0';
          isChecked = false;
          lmatang = '0';
        });
      }
    } catch (e) {
      print('Error saat input transaksi: $e');
    } finally {
      setState(() {
        isProcessing = false;
      });
    }
  }

  void hapus(String urut) async {
    print('hapus : $urut');
    try {
      if (urut.isNotEmpty) {
        var result = await ApiService.hapustran(
          widget.varpbuser,
          urut,
        );
        setState(() {
          transaksiData = result
              .map((item) => {
                    'nama': item['nama'],
                    'harga': item['nrp'],
                    'jumlah': item['nqty'],
                    'subtotal': item['subtotal'],
                    'llunas': item['llunas'],
                    'urut': item['urut']
                  })
              .toList();
        });
      }
    } catch (e) {
      print('Error saat hapus transaksi: $e');
    }
  }

  Future<void> scanBarcode() async {
    try {
      var result = await BarcodeScanner.scan();
      setState(() {
        barcodeResult = result.rawContent;
        barcodeController.text = barcodeResult;
        print('proses scan barcode 1');
      });
      fetchhasilscan();
      print('proses scan barcode 2');
    } catch (e) {
      setState(() {
        barcodeResult = 'Kesalahan dalam memindai barcode: $e';
        barcodeController.text = barcodeResult;
      });
    }
  }

  void fetchhasilscan() async {
    try {
      List<Map<String, dynamic>> result =
          await ApiService.crbarang3(widget.varpbuser, barcodeResult, '1');
      print(result);
      setState(() {
        if (result.isNotEmpty) {
          final item = result[0];
          // Set namaController dengan nama barang
          namaController.text = item['nama'];

          // Cek apakah barang matang atau tidak
          if (item['lmatang'] == '1') {
            // Jika matang, set harga dengan harga matang
            hargaController.text = item['nhargajual'].toString();

            matang = true;

            // isChecked = true; // Centang checkbox secara otomatis
          } else {
            // Jika tidak matang, set harga dengan harga jual asli
            hargaController.text = item['nhargajual'].toString();
            matang = false;

            //isChecked = false; // Checkbox tidak dicentang
          }

          //hargaController.text = formatter.format(int.parse(nhargajual));
          jumlahController.text = '';
          // subttlController.text = formatter.format(int.parse(nhargajual));
          lmatang = lmatang;
          nhargamatang1 = item['nhargamatang'];
          nhargajual1 = item['nhargajual'];
          // jumlahController.text = '0';
          // diskonController.text = '0';
          // subttlController.text = hargaController.text * int.parse(jumlahController.text);
        }
      });
    } catch (e) {
      print('Error fetching item data: $e');
    }
  }

  void searchTransactions() {
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
      List<Map<String, dynamic>> result =
          await ApiService.lapjualperno(widget.varpbuser, notran);

      if (result.isNotEmpty) {
        setState(() {
          notransController.text = result[0]['notrans'] ?? '';
          kdcustController.text = result[0]['kdcust'] ?? '';
          nmcustController.text = result[0]['nmcust'] ?? '';
          totbayar = double.parse(nbayar.replaceAll(',', ''));
          totbayarku.text = nbayar;

          transaksiData = result
              .map((item) => {
                    'nama': item['nmbarang'],
                    'harga': item['nrp'],
                    'jumlah': item['nqty'],
                    'subtotal': item['subtotal'],
                    'llunas': item['llunas'],
                    'urut': item['urut']
                  })
              .toList();
        });
      }
    } catch (e) {
      print('Error fetching transaction details: $e');
    }
  }

  Future<void> fetchProductDetails() async {
    try {
      var details =
          await ApiService.crbarang3(widget.varpbuser, barcodeResult, '1');
      print('proses cari kode barang 3');
      final formatter = NumberFormat("#,###");

      setState(() {
        jumlahController.text = '0';
        diskonController.text = '0';
      });
    } catch (e) {
      setState(() {
        print('Error fetching product details: $e');
        namaController.text = 'Gagal memuat data';
        hargaController.text = 'Gagal memuat data';
        subttlController.text = '0';
        jumlahController.text = '0';
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
            // DataColumn(label: Text('urut')),
            DataColumn(label: Text(' ')),
          ],
          rows: transaksiData.map((data) {
            return DataRow(cells: [
              DataCell(Text(data['nama'] ?? 'Nama tidak tersedia')),
              DataCell(
                  Text(formatter.format(int.parse(data['harga'].toString())))),
              DataCell(Text(data['jumlah'].toString())),
              DataCell(Text(
                  formatter.format(int.parse(data['subtotal'].toString())))),
              // DataCell(Text(data['llunas'].toString())),
              // DataCell(Text(data['urut'])),
              DataCell(
                Align(
                  alignment: Alignment.centerRight,
                  child: Visibility(
                    visible: data['llunas'] == '0',
                    child: RawMaterialButton(
                      onPressed: () {
                        hapus(data['urut'].toString());
                        print('proses del1 ');
                      },
                      elevation: 2.0,
                      fillColor: Colors.white70, // Warna latar belakang tombol
                      shape: CircleBorder(), // Membuat bentuk lingkaran
                      padding: const EdgeInsets.all(15.0), // Ukuran tombol
                      child: Icon(
                        Icons.delete,
                        color: Colors.red[400], // Warna ikon dalam tombol
                        size: 20.0,
                      ),
                    ),
                  ),
                ),
              )
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

  String hitungbayar() {
    final formatter =
        NumberFormat("#,###", "id_ID"); // Menggunakan locale Indonesia
    int total = transaksiData.fold(0, (sum, item) {
      int totbayar = int.tryParse(item['nbayar'].toString()) ?? 0;
      return sum + totbayar;
    });

    return formatter.format(
        total); // Format total dengan pemisah ribuan dan kembalikan sebagai String
  }

  void clearTransactionData() {
    setState(() {
      transaksiData.clear(); // Mengosongkan list transaksiData
    });
  }

  void showPaymentDialog() async {
    String grandTotal = calculateGrandTotal(); // Mengambil nilai Grand Total
    int totbayarInt = int.tryParse(totbayarku.text) ?? 0;
    // Menunggu nilai yang dikembalikan dari bayarjual.dart
    final paymentValue = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return PaymentDialog(
          asal: 'jual',
          notrans: notransController.text,
          grandTotal: grandTotal,
          totbayar: currencyFormat.format(totbayar),
          username: widget.varpbuser,
          varlks: widget.varlks,
          // varsaldokas: widget.varsaldokas,
          vartotalbyr: currencyFormat.format(totbayarInt),
          onPaymentSuccess: (updatedVarsaldokas, updatedVartotalbyr) {
            setState(() {
              varsaldokas = updatedVarsaldokas;
              totbayarku.text = updatedVartotalbyr;
            });
          },
        );
      },
    );

// Pastikan paymentValue tidak null dan lakukan update yang diperlukan
    if (paymentValue != null) {
      setState(() {
        double bayar = double.tryParse(paymentValue) ?? 0.0;
        // Pastikan totbayar adalah String sebelum melakukan replaceAll
        String totbayarString = totbayar.toString();
        double currentTotbayar =
            double.tryParse(totbayarString.replaceAll(',', '')) ?? 0.0;
        // Tambahkan bayar ke currentTotbayar jika diperlukan
        currentTotbayar = bayar;
        final formatter = NumberFormat("#,###");
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
          onItemSelected: (kode, nama, nhargajual, lmatang, nhargamatang) {
            setState(() {
              final formatter = NumberFormat("#,###");
              barcodeController.text = kode;
              namaController.text = nama;
              hargaController.text = formatter.format(int.parse(nhargajual));
              jumlahController.text = '';
              subttlController.text = formatter.format(int.parse(nhargajual));
              lmatang = lmatang;
              nhargamatang1 = nhargamatang;
              // nhargamatang1 = formatter.format(int.parse(nhargamatang));
              //nhargajual1 = nhargajual;
              nhargajual1 = formatter.format(int.parse(nhargajual));
              matang = lmatang == '1' ? true : false;
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
          title: Text("Penjualan"),
          leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.pop(context, varsaldokas.toString());
              print('saldo yang dikembalikan ke home $varsaldokas');
            },
          ),
        ),
        body: SafeArea(
            child: SingleChildScrollView(
          child: Column(children: [
            SizedBox(height: 5),
            Text(
              notransController.text,
              style: TextStyle(
                fontSize: 16.0,
                fontWeight: FontWeight.bold,
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
                IconButton(
                  icon: Icon(Icons.search),
                  onPressed: _searchCustomer,
                ),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    kdcustController.text,
                    style: TextStyle(
                      fontSize: 16.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                SizedBox(
                  width: 5,
                ),
                Text(
                  ' - ',
                  style: TextStyle(
                    fontSize: 16.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
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
                SizedBox(width: 5),
              ],
            ),
            SizedBox(height: 5),

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
                    totbayarku.text = '0';
                    matang = false;
                    clearTransactionData(); // Mengosongkan transaksiData
                  },
                ),
              ],
            ),
            SizedBox(height: 5),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                namaController.text,
                style: TextStyle(
                  fontSize: 16.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            SizedBox(height: 5),
            Visibility(
                visible:
                    matang == true, // Tampilkan checkbox hanya jika lmatang = 1
                child: Row(
                  children: [
                    Checkbox(
                      value: isChecked,
                      onChanged: (bool? value) {
                        setState(() {
                          isChecked = value ?? false;
                          if (isChecked) {
                            namaController.text += ' Siap Saji';

                            hargaController.text =
                                nhargamatang1; // Menggunakan harga matang
                          } else {
                            namaController.text = namaController.text
                                .replaceAll(' Siap Saji', '');
                            hargaController.text = nhargajual1;
                          }
                        });
                      },
                    ),
                    Text('Siap saji'),
                  ],
                )),

            SizedBox(height: 5),
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
                    //  focusNode: jumlahFocusNode,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'QTY',
                    ),
                    controller: jumlahController,
                  ),
                ),
              ],
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
                    onPressed: isProcessing ? null : input,
                    icon: Icon(Icons.add),
                    color: Colors.black,
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
                  child: TextField(
                    controller: totbayarku,
                    decoration: InputDecoration(
                      labelText: 'Total Bayar',
                    ),
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

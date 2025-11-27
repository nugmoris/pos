import 'package:barcode_scan2/barcode_scan2.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pos/item_search_popup.dart';

import 'bayarjual.dart';
import 'customer_search_popup.dart';
import 'report.dart';
import 'service.dart';
import 'transaction_search_popup.dart';

class JualPage2 extends StatefulWidget {
  final String varpbuser;
  final String varbagian;
  final String varlks;
  final String varnmlok;
  final String varsaldokas;

  JualPage2(this.varpbuser, this.varbagian, this.varlks, this.varnmlok,
      this.varsaldokas);
  @override
  State<JualPage2> createState() => _JualPage2State();
}

class _JualPage2State extends State<JualPage2> {
  String barcodeResult = "";
  TextEditingController barcodeController = TextEditingController();
  TextEditingController namaController = TextEditingController();
  TextEditingController kodecontroller = TextEditingController();
  TextEditingController hargaController = TextEditingController();
  TextEditingController jumlahController = TextEditingController();
  TextEditingController subttlController = TextEditingController();
  TextEditingController diskonController = TextEditingController();
  TextEditingController totalController = TextEditingController();
  TextEditingController notransController = TextEditingController();
  TextEditingController kdcustController = TextEditingController();
  TextEditingController nmcustController = TextEditingController();
  TextEditingController totbayarku = TextEditingController();

  // List untuk menyimpan item lokal sebelum disimpan ke server
  List<Map<String, dynamic>> localItems = [];

  // List untuk menampilkan data transaksi dari server (setelah simpan)
  List<Map<String, dynamic>> transaksiData = [];

  final NumberFormat currencyFormat = NumberFormat("#,##0", "en_US");
  double totbayar = 0.0;

  String nmbarang1 = '';
  String lmatang = '0';
  String nhargamatang1 = '0';
  String nhargajual1 = '0';
  bool matang = false;
  bool isChecked = false;
  double hrsbayar = 0.0;
  double saldokasku = 0.0;
  String varsaldokas = '0';
  String urut = '0';
  bool isProcessing = false;
  bool isSaved = false; // Flag untuk menandai apakah transaksi sudah disimpan

  @override
  void initState() {
    super.initState();
    jumlahController.addListener(_updateSubtotalAndTotal);
    notransController.text = 'Transaksi Baru';
    kdcustController.text = '01';
    nmcustController.text = 'Customer Umum';
    totbayarku.text = '0';
    saldokasku = double.tryParse(widget.varsaldokas.replaceAll(',', '')) ?? 0.0;
  }

  @override
  void dispose() {
    jumlahController.removeListener(_updateSubtotalAndTotal);
    jumlahController.dispose();
    barcodeController.dispose();
    namaController.dispose();
    kodecontroller.dispose();
    hargaController.dispose();
    subttlController.dispose();
    totalController.dispose();
    diskonController.dispose();
    notransController.dispose();
    kdcustController.dispose();
    nmcustController.dispose();
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
  }

  // Tambah item ke list lokal
  void addItemToLocal() {
    if (barcodeController.text.isEmpty ||
        jumlahController.text.isEmpty ||
        hargaController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Lengkapi data barang terlebih dahulu")),
      );
      return;
    }

    // Cek duplikat
    bool isDuplicate = localItems.any((item) =>
        item['kdbarang'] == barcodeController.text &&
        item['nrp'].toString() == hargaController.text.replaceAll(',', '') &&
        item['lmatang'] == (isChecked ? '1' : '0'));

    if (isDuplicate) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Barang dengan harga yang sama sudah diinput")),
      );
      return;
    }

    setState(() {
      int qty = int.tryParse(jumlahController.text) ?? 0;
      int harga = int.tryParse(hargaController.text.replaceAll(',', '')) ?? 0;

      localItems.add({
        'kdbarang': kodecontroller.text,
        'nama': namaController.text,
        'nqty': qty,
        'nrp': harga,
        'lmatang': isChecked ? '1' : '0',
        'subtotal': qty * harga,
      });

      // Clear form
      barcodeController.clear();
      kodecontroller.clear();
      ;
      namaController.clear();
      hargaController.text = '0';
      jumlahController.text = '0';
      subttlController.text = '0';
      diskonController.text = '0';
      totalController.text = '0';
      isChecked = false;
      lmatang = '0';
    });
  }

  // Hapus item dari list lokal
  void deleteLocalItem(int index) {
    setState(() {
      localItems.removeAt(index);
    });
  }

  // Simpan semua item ke server
  void saveToServer() async {
    if (isProcessing) return;

    if (localItems.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Tidak ada item untuk disimpan")),
      );
      return;
    }

    setState(() {
      isProcessing = true;
    });

    try {
      // Konversi localItems ke format yang dibutuhkan API
      List<Map<String, dynamic>> itemsForApi = localItems.map((item) {
        return {
          'kdbarang': item['kdbarang'],
          'nqty': item['nqty'],
          'nrp': item['nrp'],
          'lmatang': item['lmatang'],
        };
      }).toList();

      // Panggil API dengan format JSON
      var result = await ApiService.inputJualJson(
        widget.varlks,
        kdcustController.text,
        widget.varpbuser,
        'Input Penjualan', // keterangan
        1, // ntop
        '01', // kdsales
        notransController.text == 'Transaksi Baru - 2'
            ? ''
            : notransController.text,
        itemsForApi,
      );

      if (result.isNotEmpty) {
        setState(() {
          // Update transaksiData dengan hasil dari server
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

          // Update notrans
          if (result[0].containsKey('notrans')) {
            notransController.text = result[0]['notrans'];
          }

          // Clear local items setelah berhasil disimpan
          localItems.clear();
          isSaved = true;
        });

        // Langsung tampilkan dialog pembayaran
        showPaymentDialog();
      }
    } catch (e) {
      print('Error saat simpan transaksi: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Gagal menyimpan transaksi: $e")),
      );
    } finally {
      setState(() {
        isProcessing = false;
      });
    }
  }

  // Hapus item dari server (untuk transaksi yang sudah disimpan)
  void hapus(String urut) async {
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
      });
      fetchhasilscan();
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
          await ApiService.crbarang3(widget.varpbuser, barcodeResult, '4');
      setState(() {
        if (result.isNotEmpty) {
          final item = result[0];
          namaController.text = item['nama'];
          kodecontroller.text = item['kode'];
          if (item['lmatang'] == '1') {
            hargaController.text = item['nhargajual'].toString();
            matang = true;
          } else {
            hargaController.text = item['nhargajual'].toString();
            matang = false;
          }

          jumlahController.text = '';
          lmatang = lmatang;
          nhargamatang1 = item['nhargamatang'];
          nhargajual1 = item['nhargajual'];
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
          varlks: widget.varlks,
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
          isSaved = true; // Transaksi dari server sudah tersimpan

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

  void showPaymentDialog() async {
    String grandTotal = calculateGrandTotal();
    int totbayarInt = int.tryParse(totbayarku.text.replaceAll(',', '')) ?? 0;

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

    if (paymentValue != null) {
      setState(() {
        double bayar = double.tryParse(paymentValue) ?? 0.0;
        String totbayarString = totbayar.toString();
        double currentTotbayar =
            double.tryParse(totbayarString.replaceAll(',', '')) ?? 0.0;
        currentTotbayar = bayar;
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
          onItemSelected:
              (kode, nama, nhargajual, lmatang, nhargamatang, kodebarcode) {
            setState(() {
              final formatter = NumberFormat("#,###");
              barcodeController.text = kodebarcode;
              namaController.text = nama;
              kodecontroller.text = kode;
              hargaController.text = formatter.format(int.parse(nhargajual));
              jumlahController.text = '';
              subttlController.text = formatter.format(int.parse(nhargajual));
              lmatang = lmatang;
              nhargamatang1 = nhargamatang;
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

  // Widget untuk menampilkan local items (belum disimpan)
  Widget buildLocalItemsTable() {
    final formatter = NumberFormat("#,###", "id_ID");

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            'Item Belum Disimpan:',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
        ),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: DataTable(
            columns: const [
              DataColumn(label: Text('Nama Barang')),
              DataColumn(label: Text('Harga')),
              DataColumn(label: Text('Jumlah')),
              DataColumn(label: Text('Subtotal')),
              DataColumn(label: Text(' ')),
            ],
            rows: localItems.asMap().entries.map((entry) {
              int index = entry.key;
              Map<String, dynamic> data = entry.value;
              return DataRow(cells: [
                DataCell(Text(data['nama'] ?? 'Nama tidak tersedia')),
                DataCell(Text(formatter.format(data['nrp']))),
                DataCell(Text(data['nqty'].toString())),
                DataCell(Text(formatter.format(data['subtotal']))),
                DataCell(
                  IconButton(
                    icon: Icon(Icons.delete, color: Colors.red),
                    onPressed: () => deleteLocalItem(index),
                  ),
                ),
              ]);
            }).toList(),
          ),
        ),
      ],
    );
  }

  // Widget untuk menampilkan data transaksi dari server (sudah disimpan)
  Widget buildTransaksiTable() {
    final formatter = NumberFormat("#,###", "id_ID");

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            'Item Tersimpan:',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
        ),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: SingleChildScrollView(
            scrollDirection: Axis.vertical,
            child: DataTable(
              columns: const [
                DataColumn(label: Text('Nama Barang')),
                DataColumn(label: Text('Harga')),
                DataColumn(label: Text('Jumlah')),
                DataColumn(label: Text('Subtotal')),
                DataColumn(label: Text(' ')),
              ],
              rows: transaksiData.map((data) {
                return DataRow(cells: [
                  DataCell(Text(data['nama'] ?? 'Nama tidak tersedia')),
                  DataCell(Text(
                      formatter.format(int.parse(data['harga'].toString())))),
                  DataCell(Text(data['jumlah'].toString())),
                  DataCell(Text(formatter
                      .format(int.parse(data['subtotal'].toString())))),
                  DataCell(
                    Align(
                      alignment: Alignment.centerRight,
                      child: Visibility(
                        visible: data['llunas'] == '0',
                        child: RawMaterialButton(
                          onPressed: () {
                            hapus(data['urut'].toString());
                          },
                          elevation: 2.0,
                          fillColor: Colors.white70,
                          shape: CircleBorder(),
                          padding: const EdgeInsets.all(15.0),
                          child: Icon(
                            Icons.delete,
                            color: Colors.red[400],
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
        ),
      ],
    );
  }

  String calculateGrandTotal() {
    final formatter = NumberFormat("#,###", "id_ID");
    int total = 0;

    // Hitung dari local items jika belum disimpan
    if (!isSaved && localItems.isNotEmpty) {
      total = localItems.fold(0, (sum, item) {
        int subtotal = item['subtotal'] ?? 0;
        return sum + subtotal;
      });
    } else {
      // Hitung dari transaksiData jika sudah disimpan
      total = transaksiData.fold(0, (sum, item) {
        int subtotal = int.tryParse(item['subtotal'].toString()) ?? 0;
        return sum + subtotal;
      });
    }

    return formatter.format(total);
  }

  void clearTransactionData() {
    setState(() {
      transaksiData.clear();
      localItems.clear();
      isSaved = false;
      notransController.text = 'Transaksi Baru';
    });
  }

  @override
  Widget build(BuildContext context) {
    final bool isTransactionPaid =
        transaksiData.any((item) => item['llunas'] == '1');
    return Scaffold(
        appBar: AppBar(
          title: Text("Penjualan (Batch 2)"),
          leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.pop(context, varsaldokas.toString());
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
              color: Colors.black,
              thickness: 2,
              indent: 10,
              endIndent: 10,
            ),
            SizedBox(height: 5),
            Row(
              children: [
                IconButton(
                  icon: Icon(Icons.search),
                  onPressed: (isProcessing || isTransactionPaid)
                      ? null
                      : _searchCustomer,
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
                SizedBox(width: 5),
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
              color: Colors.black,
              thickness: 2,
              indent: 10,
              endIndent: 10,
            ),
            SizedBox(height: 5),
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: TextField(
                    readOnly: isSaved,
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
                  onPressed:
                      (isProcessing || isTransactionPaid) ? null : scanBarcode,
                ),
                IconButton(
                  icon: Icon(Icons.search),
                  onPressed: (isProcessing || isTransactionPaid)
                      ? null
                      : caribrgmanual,
                ),
                IconButton(
                  icon: Icon(Icons.refresh),
                  onPressed: isProcessing
                      ? null
                      : () {
                          barcodeController.clear();
                          namaController.clear();
                          kodecontroller.clear();
                          hargaController.text = '0';
                          jumlahController.text = '0';
                          subttlController.text = '0';
                          diskonController.text = '0';
                          totalController.text = '0';
                          notransController.text = 'Transaksi Baru';
                          kdcustController.text = '01';
                          nmcustController.text = 'Customer Umum';
                          totbayar = 0.0;
                          totbayarku.text = '0';
                          matang = false;
                          clearTransactionData();
                        },
                ),
              ],
            ),
            SizedBox(height: 5),
            Align(
              alignment: Alignment.centerLeft,
              child: Row(
                children: [
                  Text(
                    kodecontroller.text.isEmpty
                        ? ''
                        : '${kodecontroller.text} - ',
                    style: TextStyle(
                      fontSize: 16.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    namaController.text,
                    style: TextStyle(
                      fontSize: 16.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 5),
            Visibility(
                visible: matang == true,
                child: Row(
                  children: [
                    Checkbox(
                      value: isChecked,
                      onChanged: isSaved
                          ? null
                          : (bool? value) {
                              setState(() {
                                isChecked = value ?? false;
                                if (isChecked) {
                                  namaController.text += ' Siap Saji';
                                  hargaController.text = nhargamatang1;
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
                  flex: 2,
                  child: TextField(
                    readOnly: true,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Harga Jual',
                    ),
                    controller: hargaController,
                  ),
                ),
                SizedBox(width: 10),
                Expanded(
                  flex: 1,
                  child: TextField(
                    readOnly: isSaved,
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
                    color: isSaved ? Colors.grey[300] : Colors.grey[500],
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    onPressed: (isProcessing || isTransactionPaid)
                        ? null
                        : addItemToLocal,
                    icon: Icon(Icons.add),
                    color: Colors.black,
                  ),
                )),
              ],
            ),
            SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    'Grand Total : ${calculateGrandTotal()}',
                    textAlign: TextAlign.left,
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: TextField(
                    controller: totbayarku,
                    decoration: InputDecoration(
                      labelText: 'Total Bayar',
                    ),
                    readOnly: true,
                  ),
                ),
                Expanded(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      // Tombol Simpan (hanya muncul jika belum disimpan dan ada item lokal)
                      if (!isSaved && localItems.isNotEmpty)
                        IconButton(
                          icon: Icon(Icons.save),
                          onPressed: isProcessing ? null : saveToServer,
                          tooltip: 'Simpan',
                        ),
                      // Tombol Bayar (hanya muncul jika sudah disimpan dan belum lunas)
                      if (isSaved)
                        IconButton(
                          icon: Icon(Icons.payment),
                          onPressed: !transaksiData
                                  .any((item) => item['llunas'] == '1')
                              ? showPaymentDialog
                              : null,
                          tooltip: 'Bayar',
                        ),
                      IconButton(
                        icon: Icon(Icons.print),
                        onPressed: isSaved ? printData : null,
                        tooltip: 'Print',
                      ),
                      IconButton(
                        icon: Icon(Icons.search),
                        onPressed: isProcessing ? null : searchTransactions,
                        tooltip: 'Cari Transaksi',
                      ),
                    ],
                  ),
                ),
              ],
            ),
            Divider(
              color: Colors.black,
              thickness: 2,
              indent: 10,
              endIndent: 10,
            ),
            // Tampilkan local items jika belum disimpan
            if (!isSaved && localItems.isNotEmpty) buildLocalItemsTable(),
            // Tampilkan transaksi dari server jika sudah disimpan
            if (isSaved && transaksiData.isNotEmpty) buildTransaksiTable(),
          ]),
        )));
  }
}

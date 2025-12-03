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
  TextEditingController dppController = TextEditingController();
  TextEditingController ppnController = TextEditingController();
  TextEditingController hargaController = TextEditingController();
  TextEditingController jumlahController = TextEditingController();
  TextEditingController subttlController = TextEditingController();
  TextEditingController diskonController = TextEditingController();
  TextEditingController totalController = TextEditingController();
  TextEditingController notransController = TextEditingController();
  TextEditingController kdcustController = TextEditingController();
  TextEditingController nmcustController = TextEditingController();
  TextEditingController totbayarku = TextEditingController();

  List<Map<String, dynamic>> localItems = [];
  List<Map<String, dynamic>> transaksiData = [];

  final NumberFormat currencyFormat = NumberFormat("#,##0", "en_US");
  double totbayar = 0.0;

  String nmbarang1 = '';
  String lmatang = '0';
  String nhargamatang1 = '0';
  String nhargajual1 = '0';
  String dppmatang1 = '0';
  String ppnmatang1 = '0';
  String dppnormal1 = '0';
  String ppnnormal1 = '0';

  bool matang = false;
  bool isChecked = false;
  double hrsbayar = 0.0;
  double saldokasku = 0.0;
  String varsaldokas = '0';
  String urut = '0';
  bool isProcessing = false;
  bool isSaved = false;

  @override
  void initState() {
    super.initState();
    jumlahController.addListener(_updateSubtotalAndTotal);
    notransController.text = 'Transaksi Baru';
    kdcustController.text = '01';
    nmcustController.text = 'Customer Umum';
    totbayarku.text = '0';
    dppController.text = _formatNumber(0);
    ppnController.text = _formatNumber(0);
    saldokasku = double.tryParse(widget.varsaldokas.replaceAll(',', '')) ?? 0.0;
  }

  @override
  void dispose() {
    jumlahController.removeListener(_updateSubtotalAndTotal);
    jumlahController.dispose();
    barcodeController.dispose();
    namaController.dispose();
    kodecontroller.dispose();
    dppController.dispose();
    ppnController.dispose();
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

  String _formatNumber(dynamic value) {
    final formatter = NumberFormat("#,###");
    if (value == null) return '0';
    final sanitized = value.toString().replaceAll(',', '');
    final number = double.tryParse(sanitized) ?? 0;
    return formatter.format(number);
  }

  double _parseToDouble(dynamic value) {
    if (value == null) return 0;
    if (value is num) return value.toDouble();
    return double.tryParse(value.toString().replaceAll(',', '')) ?? 0;
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

  void addItemToLocal() {
    if (barcodeController.text.isEmpty ||
        jumlahController.text.isEmpty ||
        hargaController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Lengkapi data barang terlebih dahulu"),
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
      return;
    }

    bool isDuplicate = localItems.any((item) =>
        item['kdbarang'] == barcodeController.text &&
        item['nrp'].toString() == hargaController.text.replaceAll(',', '') &&
        item['lmatang'] == (isChecked ? '1' : '0'));

    if (isDuplicate) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Barang dengan harga yang sama sudah diinput"),
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
      return;
    }

    setState(() {
      int qty = int.tryParse(jumlahController.text) ?? 0;
      int harga = int.tryParse(hargaController.text.replaceAll(',', '')) ?? 0;
      int dpp = int.tryParse(dppController.text.replaceAll(',', '')) ?? 0;
      int ppn = int.tryParse(ppnController.text.replaceAll(',', '')) ?? 0;

      localItems.add({
        'kdbarang': kodecontroller.text,
        'nama': namaController.text,
        'nqty': qty,
        'nrp': harga,
        'lmatang': isChecked ? '1' : '0',
        'dpp': dpp,
        'ppn': ppn,
        'ndpp': dpp,
        'nppn': ppn,
        'subtotal': qty * harga,
      });

      barcodeController.clear();
      kodecontroller.clear();
      namaController.clear();
      hargaController.text = _formatNumber(0);
      jumlahController.text = '0';
      subttlController.text = _formatNumber(0);
      diskonController.text = '0';
      totalController.text = _formatNumber(0);
      dppController.text = _formatNumber(0);
      ppnController.text = _formatNumber(0);
      isChecked = false;
      lmatang = '0';
    });
  }

  void deleteLocalItem(int index) {
    setState(() {
      localItems.removeAt(index);
    });
  }

  void saveToServer() async {
    if (isProcessing) return;
    print('jual2.saveToServer');
    if (localItems.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Tidak ada item untuk disimpan"),
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
      return;
    }

    setState(() {
      isProcessing = true;
    });

    try {
      List<Map<String, dynamic>> itemsForApi = localItems.map((item) {
        return {
          'kdbarang': item['kdbarang'],
          'nqty': item['nqty'],
          'nrp': item['nrp'],
          'lmatang': item['lmatang'],
          'ndpp': item['ndpp'] ?? item['dpp'] ?? 0,
          'nppn': item['nppn'] ?? item['ppn'] ?? 0,
        };
      }).toList();

      var result = await ApiService.inputJualJson(
        widget.varlks,
        kdcustController.text,
        widget.varpbuser,
        'Input Penjualan',
        1,
        '01',
        notransController.text == 'Transaksi Baru - 2'
            ? ''
            : notransController.text,
        itemsForApi,
      );

      if (result.isNotEmpty) {
        setState(() {
          transaksiData = result
              .map((item) => {
                    'nama': item['nama'],
                    'harga': item['nrp'],
                    'jumlah': item['nqty'],
                    'subtotal': item['subtotal'],
                    'dpp': item['dpp'] ?? item['ndpp'] ?? 0,
                    'ppn': item['ppn'] ?? item['nppn'] ?? 0,
                    'llunas': item['llunas'],
                    'urut': item['urut']
                  })
              .toList();

          if (result[0].containsKey('notrans')) {
            notransController.text = result[0]['notrans'];
          }

          localItems.clear();
          isSaved = true;
        });

        showPaymentDialog();
      }
    } catch (e) {
      print('Error saat simpan transaksi: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Gagal menyimpan transaksi: $e"),
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    } finally {
      setState(() {
        isProcessing = false;
      });
    }
  }

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
                    'dpp': item['dpp'] ?? item['ndpp'] ?? 0,
                    'ppn': item['ppn'] ?? item['nppn'] ?? 0,
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
          await ApiService.crbarang3(widget.varpbuser, barcodeResult, '1');
      setState(() {
        if (result.isNotEmpty) {
          final item = result[0];
          namaController.text = item['nama'];
          kodecontroller.text = item['kode'];
          dppController.text = _formatNumber(item['dpp']);
          ppnController.text = _formatNumber(item['ppn']);
          if (item['lmatang'] == '1') {
            hargaController.text = _formatNumber(item['nhargajual']);
            matang = true;
          } else {
            hargaController.text = _formatNumber(item['nhargajual']);
            matang = false;
          }

          jumlahController.text = '';
          lmatang = lmatang;
          nhargamatang1 = item['nhargamatang'];
          nhargajual1 = item['nhargajual'];
          dppmatang1 = item['dppmatang'] ?? '0';
          ppnmatang1 = item['ppnmatang'] ?? '0';
          dppnormal1 = item['dpp'] ?? '0';
          ppnnormal1 = item['ppn'] ?? '0';
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
          isSaved = true;

          transaksiData = result
              .map((item) => {
                    'nama': item['nmbarang'],
                    'harga': item['nrp'],
                    'jumlah': item['nqty'],
                    'subtotal': item['subtotal'],
                    'dpp': item['dpp'] ?? item['ndpp'] ?? 0,
                    'ppn': item['ppn'] ?? item['nppn'] ?? 0,
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
          onItemSelected: (kode, nama, nhargajual, lmatang, nhargamatang,
              kodebarcode, dpp, ppn, dppmatang, ppnmatang) {
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
              dppmatang1 = dppmatang;
              ppnmatang1 = ppnmatang;

              nhargajual1 = nhargajual;
              dppnormal1 = dpp;
              ppnnormal1 = ppn;
              matang = lmatang == '1' ? true : false;
              dppController.text = _formatNumber(dpp);
              ppnController.text = _formatNumber(ppn);
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

  Widget buildLocalItemsTable() {
    final formatter = NumberFormat("#,###", "id_ID");

    return Card(
      margin: EdgeInsets.all(12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
            ),
            child: Row(
              children: [
                Icon(Icons.shopping_cart_outlined,
                    color: Colors.blue.shade700, size: 20),
                SizedBox(width: 8),
                Text(
                  'Item Belum Disimpan',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                    color: Colors.blue.shade900,
                  ),
                ),
              ],
            ),
          ),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              headingRowColor: MaterialStateProperty.all(Colors.grey.shade100),
              columns: const [
                DataColumn(
                    label: Text('Nama Barang',
                        style: TextStyle(fontWeight: FontWeight.w600))),
                DataColumn(
                    label: Text('Harga',
                        style: TextStyle(fontWeight: FontWeight.w600))),
                DataColumn(
                    label: Text('Jumlah',
                        style: TextStyle(fontWeight: FontWeight.w600))),
                DataColumn(
                    label: Text('DPP',
                        style: TextStyle(fontWeight: FontWeight.w600))),
                DataColumn(
                    label: Text('PPN',
                        style: TextStyle(fontWeight: FontWeight.w600))),
                DataColumn(
                    label: Text('Subtotal',
                        style: TextStyle(fontWeight: FontWeight.w600))),
                DataColumn(label: Text(' ')),
              ],
              rows: localItems.asMap().entries.map((entry) {
                int index = entry.key;
                Map<String, dynamic> data = entry.value;
                return DataRow(cells: [
                  DataCell(Text(data['nama'] ?? 'Nama tidak tersedia')),
                  DataCell(Text(formatter.format(data['nrp']))),
                  DataCell(Text(data['nqty'].toString())),
                  DataCell(Text(formatter
                      .format((data['dpp'] ?? 0) * (data['nqty'] ?? 0)))),
                  DataCell(Text(formatter
                      .format((data['ppn'] ?? 0) * (data['nqty'] ?? 0)))),
                  DataCell(Text(formatter.format(data['subtotal']))),
                  DataCell(
                    IconButton(
                      icon: Icon(Icons.delete_outline,
                          color: Colors.red.shade400),
                      onPressed: () => deleteLocalItem(index),
                    ),
                  ),
                ]);
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildTransaksiTable() {
    final formatter = NumberFormat("#,###", "id_ID");

    return Card(
      margin: EdgeInsets.all(12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.green.shade50,
              borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
            ),
            child: Row(
              children: [
                Icon(Icons.check_circle_outline,
                    color: Colors.green.shade700, size: 20),
                SizedBox(width: 8),
                Text(
                  'Item Tersimpan',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                    color: Colors.green.shade900,
                  ),
                ),
              ],
            ),
          ),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: DataTable(
                headingRowColor:
                    MaterialStateProperty.all(Colors.grey.shade100),
                columns: const [
                  DataColumn(
                      label: Text('Nama Barang',
                          style: TextStyle(fontWeight: FontWeight.w600))),
                  DataColumn(
                      label: Text('Harga',
                          style: TextStyle(fontWeight: FontWeight.w600))),
                  DataColumn(
                      label: Text('Jumlah',
                          style: TextStyle(fontWeight: FontWeight.w600))),
                  DataColumn(
                      label: Text('DPP',
                          style: TextStyle(fontWeight: FontWeight.w600))),
                  DataColumn(
                      label: Text('PPN',
                          style: TextStyle(fontWeight: FontWeight.w600))),
                  DataColumn(
                      label: Text('Subtotal',
                          style: TextStyle(fontWeight: FontWeight.w600))),
                  DataColumn(label: Text(' ')),
                ],
                rows: transaksiData.map((data) {
                  return DataRow(cells: [
                    DataCell(Text(data['nama'] ?? 'Nama tidak tersedia')),
                    DataCell(Text(
                        formatter.format(int.parse(data['harga'].toString())))),
                    DataCell(Text(data['jumlah'].toString())),
                    DataCell(Text(formatter.format(_parseToDouble(data['dpp']) *
                        (int.tryParse(data['jumlah'].toString()) ?? 0)))),
                    DataCell(Text(formatter.format(_parseToDouble(data['ppn']) *
                        (int.tryParse(data['jumlah'].toString()) ?? 0)))),
                    DataCell(Text(formatter
                        .format(int.parse(data['subtotal'].toString())))),
                    DataCell(
                      Align(
                        alignment: Alignment.centerRight,
                        child: Visibility(
                          visible: data['llunas'] == '0',
                          child: IconButton(
                            icon: Icon(Icons.delete_outline,
                                color: Colors.red.shade400),
                            onPressed: () {
                              hapus(data['urut'].toString());
                            },
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
      ),
    );
  }

  String calculateGrandTotal() {
    final formatter = NumberFormat("#,###", "id_ID");
    int total = 0;

    if (!isSaved && localItems.isNotEmpty) {
      total = localItems.fold(0, (sum, item) {
        int subtotal = item['subtotal'] ?? 0;
        return sum + subtotal;
      });
    } else {
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
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        title: Text(
          "Penjualan (PPN)",
          style: TextStyle(
            color: Colors.grey.shade800,
            fontWeight: FontWeight.w600,
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.grey.shade800),
          onPressed: () {
            Navigator.pop(context, varsaldokas.toString());
          },
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Header Card - Transaction Info
              Container(
                margin: EdgeInsets.all(12),
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Icon(Icons.receipt_long,
                            color: Colors.blue.shade600, size: 20),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            notransController.text,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey.shade800,
                            ),
                          ),
                        ),
                      ],
                    ),
                    Divider(height: 24),
                    Row(
                      children: [
                        Material(
                          color: Colors.blue.shade50,
                          borderRadius: BorderRadius.circular(8),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(8),
                            onTap: (isProcessing || isTransactionPaid)
                                ? null
                                : _searchCustomer,
                            child: Padding(
                              padding: EdgeInsets.all(8),
                              child: Icon(
                                Icons.search,
                                size: 20,
                                color: (isProcessing || isTransactionPaid)
                                    ? Colors.grey
                                    : Colors.blue.shade700,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Customer',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                '${kdcustController.text} - ${nmcustController.text}',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.grey.shade800,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Item Input Card
              Container(
                margin: EdgeInsets.symmetric(horizontal: 12),
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Barcode Input Row
                    Row(
                      children: [
                        Expanded(
                          flex: 2,
                          child: TextField(
                            readOnly: isSaved,
                            controller: barcodeController,
                            decoration: InputDecoration(
                              labelText: 'Kode Barang',
                              labelStyle: TextStyle(fontSize: 14),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide:
                                    BorderSide(color: Colors.grey.shade300),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide(
                                    color: Colors.blue.shade400, width: 2),
                              ),
                              contentPadding: EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 14),
                            ),
                          ),
                        ),
                        SizedBox(width: 8),
                        Material(
                          color: (isProcessing || isTransactionPaid)
                              ? Colors.grey.shade200
                              : Colors.blue.shade50,
                          borderRadius: BorderRadius.circular(8),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(8),
                            onTap: (isProcessing || isTransactionPaid)
                                ? null
                                : scanBarcode,
                            child: Padding(
                              padding: EdgeInsets.all(12),
                              child: Icon(
                                Icons.qr_code_scanner,
                                color: (isProcessing || isTransactionPaid)
                                    ? Colors.grey
                                    : Colors.blue.shade700,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: 8),
                        Material(
                          color: (isProcessing || isTransactionPaid)
                              ? Colors.grey.shade200
                              : Colors.green.shade50,
                          borderRadius: BorderRadius.circular(8),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(8),
                            onTap: (isProcessing || isTransactionPaid)
                                ? null
                                : caribrgmanual,
                            child: Padding(
                              padding: EdgeInsets.all(12),
                              child: Icon(
                                Icons.search,
                                color: (isProcessing || isTransactionPaid)
                                    ? Colors.grey
                                    : Colors.green.shade700,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: 8),
                        Material(
                          color: isProcessing
                              ? Colors.grey.shade200
                              : Colors.orange.shade50,
                          borderRadius: BorderRadius.circular(8),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(8),
                            onTap: isProcessing
                                ? null
                                : () {
                                    barcodeController.clear();
                                    namaController.clear();
                                    kodecontroller.clear();
                                    hargaController.text = _formatNumber(0);
                                    jumlahController.text = '0';
                                    subttlController.text = _formatNumber(0);
                                    diskonController.text = '0';
                                    totalController.text = _formatNumber(0);
                                    dppController.text = _formatNumber(0);
                                    ppnController.text = _formatNumber(0);
                                    notransController.text = 'Transaksi Baru';
                                    kdcustController.text = '01';
                                    nmcustController.text = 'Customer Umum';
                                    totbayar = 0.0;
                                    totbayarku.text = '0';
                                    matang = false;
                                    clearTransactionData();
                                  },
                            child: Padding(
                              padding: EdgeInsets.all(12),
                              child: Icon(
                                Icons.refresh,
                                color: isProcessing
                                    ? Colors.grey
                                    : Colors.orange.shade700,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 16),

                    // Item Name Display
                    if (namaController.text.isNotEmpty)
                      Container(
                        padding: EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.blue.shade50,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.inventory_2_outlined,
                                color: Colors.blue.shade700, size: 18),
                            SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                kodecontroller.text.isEmpty
                                    ? namaController.text
                                    : '${kodecontroller.text} - ${namaController.text}',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.blue.shade900,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                    if (namaController.text.isNotEmpty) SizedBox(height: 16),

                    // Checkbox Siap Saji
                    if (matang)
                      Container(
                        margin: EdgeInsets.only(bottom: 16),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(8),
                            onTap: isSaved
                                ? null
                                : () {
                                    setState(() {
                                      isChecked = !isChecked;
                                      if (isChecked) {
                                        namaController.text += ' Siap Saji';
                                        hargaController.text =
                                            _formatNumber(nhargamatang1);
                                        dppController.text =
                                            _formatNumber(dppmatang1);
                                        ppnController.text =
                                            _formatNumber(ppnmatang1);
                                      } else {
                                        namaController.text = namaController
                                            .text
                                            .replaceAll(' Siap Saji', '');
                                        hargaController.text =
                                            _formatNumber(nhargajual1);
                                        dppController.text =
                                            _formatNumber(dppnormal1);
                                        ppnController.text =
                                            _formatNumber(ppnnormal1);
                                      }
                                    });
                                    WidgetsBinding.instance
                                        .addPostFrameCallback((_) {
                                      _updateSubtotalAndTotal();
                                    });
                                  },
                            child: Padding(
                              padding: EdgeInsets.symmetric(vertical: 8),
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
                                                namaController.text +=
                                                    ' Siap Saji';
                                                hargaController.text =
                                                    _formatNumber(
                                                        nhargamatang1);
                                                dppController.text =
                                                    _formatNumber(dppmatang1);
                                                ppnController.text =
                                                    _formatNumber(ppnmatang1);
                                              } else {
                                                namaController.text =
                                                    namaController
                                                        .text
                                                        .replaceAll(
                                                            ' Siap Saji', '');
                                                hargaController.text =
                                                    _formatNumber(nhargajual1);
                                                dppController.text =
                                                    _formatNumber(dppnormal1);
                                                ppnController.text =
                                                    _formatNumber(ppnnormal1);
                                              }
                                            });
                                            WidgetsBinding.instance
                                                .addPostFrameCallback((_) {
                                              _updateSubtotalAndTotal();
                                            });
                                          },
                                  ),
                                  Text(
                                    'Siap Saji',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),

                    // Price & Quantity Row
                    Row(
                      children: [
                        Expanded(
                          flex: 2,
                          child: TextField(
                            readOnly: true,
                            controller: hargaController,
                            decoration: InputDecoration(
                              labelText: 'Harga Jual',
                              labelStyle: TextStyle(fontSize: 14),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide:
                                    BorderSide(color: Colors.grey.shade300),
                              ),
                              filled: true,
                              fillColor: Colors.grey.shade50,
                              contentPadding: EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 14),
                            ),
                          ),
                        ),
                        SizedBox(width: 12),
                        Expanded(
                          flex: 1,
                          child: TextField(
                            readOnly: isSaved,
                            controller: jumlahController,
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              labelText: 'QTY',
                              labelStyle: TextStyle(fontSize: 14),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide:
                                    BorderSide(color: Colors.grey.shade300),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide(
                                    color: Colors.blue.shade400, width: 2),
                              ),
                              contentPadding: EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 14),
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 12),

                    // DPP & PPN Row
                    Row(
                      children: [
                        Expanded(
                          flex: 2,
                          child: TextField(
                            readOnly: true,
                            controller: dppController,
                            decoration: InputDecoration(
                              labelText: 'DPP',
                              labelStyle: TextStyle(fontSize: 14),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide:
                                    BorderSide(color: Colors.grey.shade300),
                              ),
                              filled: true,
                              fillColor: Colors.grey.shade50,
                              contentPadding: EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 14),
                            ),
                          ),
                        ),
                        SizedBox(width: 12),
                        Expanded(
                          flex: 1,
                          child: TextField(
                            readOnly: true,
                            controller: ppnController,
                            decoration: InputDecoration(
                              labelText: 'PPN',
                              labelStyle: TextStyle(fontSize: 14),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide:
                                    BorderSide(color: Colors.grey.shade300),
                              ),
                              filled: true,
                              fillColor: Colors.grey.shade50,
                              contentPadding: EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 14),
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 12),

                    // Total & Add Button Row
                    Row(
                      children: [
                        Expanded(
                          flex: 2,
                          child: TextField(
                            readOnly: true,
                            controller: totalController,
                            decoration: InputDecoration(
                              labelText: 'Total',
                              labelStyle: TextStyle(fontSize: 14),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide:
                                    BorderSide(color: Colors.grey.shade300),
                              ),
                              filled: true,
                              fillColor: Colors.grey.shade50,
                              contentPadding: EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 14),
                            ),
                          ),
                        ),
                        SizedBox(width: 12),
                        Material(
                          color: (isProcessing || isTransactionPaid)
                              ? Colors.grey.shade200
                              : Colors.blue.shade600,
                          borderRadius: BorderRadius.circular(8),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(8),
                            onTap: (isProcessing || isTransactionPaid)
                                ? null
                                : addItemToLocal,
                            child: Container(
                              padding: EdgeInsets.all(14),
                              child: Icon(
                                Icons.add,
                                color: (isProcessing || isTransactionPaid)
                                    ? Colors.grey
                                    : Colors.white,
                                size: 24,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              SizedBox(height: 16),

              // Grand Total & Actions Card
              Container(
                margin: EdgeInsets.symmetric(horizontal: 12),
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Grand Total',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey.shade700,
                          ),
                        ),
                        Text(
                          calculateGrandTotal(),
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue.shade700,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 12),
                    TextField(
                      controller: totbayarku,
                      readOnly: true,
                      decoration: InputDecoration(
                        labelText: 'Total Bayar',
                        labelStyle: TextStyle(fontSize: 14),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        filled: true,
                        fillColor: Colors.grey.shade50,
                        contentPadding:
                            EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                      ),
                    ),
                    SizedBox(height: 16),

                    // Action Buttons
                    Row(
                      children: [
                        if (!isSaved && localItems.isNotEmpty)
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: isProcessing ? null : saveToServer,
                              icon: Icon(Icons.save, size: 18),
                              label: Text('Simpan'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blue.shade600,
                                foregroundColor: Colors.white,
                                padding: EdgeInsets.symmetric(vertical: 14),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                elevation: 0,
                              ),
                            ),
                          ),
                        if (isSaved) ...[
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: !transaksiData
                                      .any((item) => item['llunas'] == '1')
                                  ? showPaymentDialog
                                  : null,
                              icon: Icon(Icons.payment, size: 18),
                              label: Text('Bayar'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green.shade600,
                                foregroundColor: Colors.white,
                                padding: EdgeInsets.symmetric(vertical: 14),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                elevation: 0,
                              ),
                            ),
                          ),
                          SizedBox(width: 8),
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: isSaved ? printData : null,
                              icon: Icon(Icons.print, size: 18),
                              label: Text('Print'),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: Colors.blue.shade700,
                                padding: EdgeInsets.symmetric(vertical: 14),
                                side: BorderSide(color: Colors.blue.shade300),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                            ),
                          ),
                        ],
                        SizedBox(width: 8),
                        Material(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(8),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(8),
                            onTap: isProcessing ? null : searchTransactions,
                            child: Padding(
                              padding: EdgeInsets.all(14),
                              child: Icon(
                                Icons.search,
                                color: Colors.grey.shade700,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              SizedBox(height: 16),

              // Tables
              if (!isSaved && localItems.isNotEmpty) buildLocalItemsTable(),
              if (isSaved && transaksiData.isNotEmpty) buildTransaksiTable(),
              SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}

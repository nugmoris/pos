import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pos/carijual.dart';

import 'bayarjual.dart';
import 'search_popup.dart';
import 'service.dart';

class ReturJualPage extends StatefulWidget {
  final String varpbuser;
  final String varbagian;
  final String varlks;
  final String varnmlok;
  final String varsaldokas;

  ReturJualPage(this.varpbuser, this.varbagian, this.varlks, this.varnmlok,
      this.varsaldokas);

  @override
  _ReturJualPageState createState() => _ReturJualPageState();
}

class _ReturJualPageState extends State<ReturJualPage> {
  TextEditingController notransController =
      TextEditingController(text: 'RJL-Baru');
  TextEditingController nqtyreturController = TextEditingController();
  TextEditingController nrpreturController = TextEditingController();
  TextEditingController keteranganController = TextEditingController();
  TextEditingController nqtyjualController = TextEditingController();
  TextEditingController nrpjualController = TextEditingController();
  TextEditingController nsubttljualController = TextEditingController();
  TextEditingController tglreturcontroller = TextEditingController();
  TextEditingController totbayarku = TextEditingController();
  String varsaldokas = '0';
  String nojual = '';
  String nmcustomer = '';
  String tgljual = '';
  String kdbarang = '';
  String nmbarang = '';
  String nqtyjual = '';
  String nrpjual = '';
  String nsubtotal = '';
  String nsubtotalret = '';
  String nbayar = '';
  final NumberFormat currencyFormat = NumberFormat("#,##0", "en_US");
  double totbayar = 0.0;
  double saldokasku = 0.0;
  List<Map<String, dynamic>> transaksiData = [];

  void initState() {
    super.initState();
    totbayarku.text = '0';
    saldokasku = double.tryParse(widget.varsaldokas.replaceAll(',', '')) ?? 0.0;
  }

  // void calculateSubtotalRetur() {
  //   setState(() {
  //     // Jika kosong, isi dengan 0
  //     if (nqtyreturController.text.isEmpty) {
  //       nqtyreturController.text = '0';
  //     }
  //     if (nrpreturController.text.isEmpty) {
  //       nrpreturController.text = '0';
  //     }

  //     double nqtyretur = double.tryParse(nqtyreturController.text) ?? 0;
  //     double nrpretur = double.tryParse(nrpreturController.text) ?? 0;
  //     nsubtotalret = (nqtyretur * nrpretur).toStringAsFixed(2);
  //   });
  // }

  void showPaymentDialog() async {
    String grandTotal = calculateGrandTotal(); // Mengambil nilai Grand Total
    int totbayarInt = int.tryParse(totbayarku.text) ?? 0;

    // Menunggu nilai yang dikembalikan dari bayarjual.dart
    final paymentValue = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return PaymentDialog(
          asal: 'retur',
          notrans: notransController.text,
          grandTotal: grandTotal,
          totbayar: currencyFormat.format(totbayarInt),
          username: widget.varpbuser,
          varlks: widget.varlks,
          // varsaldokas: widget.varsaldokas,
          vartotalbyr: currencyFormat.format(totbayarInt),
          onPaymentSuccess: (updatedVarsaldokas, updatedVartotalbyr) {
            setState(() {
              varsaldokas = updatedVarsaldokas;
              totbayarku.text = updatedVartotalbyr;
              print('totbayar = $updatedVartotalbyr');
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

  void openSearchPopup() {
    showDialog(
      context: context,
      builder: (context) {
        return SearchPopup(
          varpbuser: widget.varpbuser,
          varlks: widget.varlks,
          onItemSelected: (notrans, nbayar) {
            onItemSelected(notrans, nbayar);
          },
        );
      },
    );
  }

  void onItemSelected(String notrans, String nbayar) async {
    try {
      List<Map<String, dynamic>> result = await ApiService.cariretjual(
        widget.varpbuser,
        widget.varlks,
        '3',
        notrans,
      );

      if (result.isNotEmpty) {
        setState(() {
          notransController.text = result[0]['notrans'] ?? '';
          totbayarku.text = nbayar;
          transaksiData = result
              .map((item) => {
                    'kdbarang': item['kdbarang'],
                    'nmbarang': item['nmbarang'],
                    'nrpretur': item['nrp'],
                    'nqtyretur': item['nqty'],
                    'nsubtotal': item['nsubttl'],
                    'llunas': item['llunas'],
                    'notrans': item['notrans'],
                    'nojual': item['nojual'],
                    'nsubttl': item['nsubttl'],
                  })
              .toList();
        });
      }
    } catch (e) {
      print('Error fetching transaction details: $e');
    }
  }

  void updateNotrans() {
    setState(() {
      notransController.text = 'RJL-Baru';
      nojual = '';
      nmcustomer = '';
      tgljual = '';
      kdbarang = '';
      nmbarang = '';
      nqtyjual = '';
      nrpjual = '';
      nsubtotal = '';
      //nmbarangController.clear();
      nqtyreturController.clear();
      nrpreturController.clear();
      nqtyjualController.clear();
      nrpjualController.clear();
      nsubttljualController.clear();
      nsubtotalret = '';
      keteranganController.clear();
      transaksiData.clear();
      tglreturcontroller.clear();
    });
  }

  void calculateSubtotalRetur() {
    setState(() {
      double nqtyretur = double.tryParse(nqtyreturController.text) ?? 0;
      double nrpretur = double.tryParse(nrpreturController.text) ?? 0;
      nsubtotalret = (nqtyretur * nrpretur).toStringAsFixed(2);
    });
  }

  Future<void> searchTransaction() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => CarijualPage(widget.varpbuser)),
    );
    print('void searchTransaction');
    if (result != null) {
      setState(() {
        nojual = result['notrans'] ?? '';
        nmcustomer = result['nmcust'] ?? '';
        tgljual = result['tgljual']?.toString() ?? '';
        kdbarang = result['kdbarang'] ?? '';
        nmbarang = result['nmbarang'] ?? '';
        nqtyjual = result['nqty']?.toString() ?? '';
        final formatter = NumberFormat("#,###");
        nrpjualController.text = formatter.format(int.parse(result['nrp']));
        nqtyjualController.text = result['nqty'];

        nsubttljualController.text =
            formatter.format(int.parse(result['subttl']));
        nrpjual = result['nrp']?.toString() ?? '';
        nsubtotal = result['subttl']?.toString() ?? '';

        calculateGrandTotal();
      });
    }
  }

  Future<void> addRetur() async {
    // Pastikan nilai tidak kosong
    if (nqtyreturController.text.isEmpty) {
      nqtyreturController.text = '0';
    }
    if (nrpreturController.text.isEmpty) {
      nrpreturController.text = '0';
    }

    final response = await ApiService.returjual(
      notransController.text,
      widget.varlks,
      kdbarang,
      nqtyreturController.text,
      nrpreturController.text,
      nojual,
      keteranganController.text,
      widget.varpbuser,
    );

    setState(() {
      if (response.isNotEmpty) {
        notransController.text = response.first['notrans'] ?? 'RJL-Baru';
        // Pastikan untuk membersihkan dan menambahkan data baru ke transaksiData
        transaksiData.clear();
        transaksiData.addAll(response);
        kdbarang = '';
        nmbarang = '';
        nqtyjual = '';
        nrpjual = '';
        nsubtotal = '';
        keteranganController.clear();
        nqtyjualController.clear();
        nrpjualController.clear();
        nsubttljualController.clear();
        nqtyreturController.clear();
        nrpreturController.clear();
        nsubttljualController.clear();
        tglreturcontroller.clear();
        nsubtotalret = '';
        calculateGrandTotal();
      }
    });
  }

  String calculateGrandTotal() {
    final formatter = NumberFormat("#,###", "id_ID");

    int total = transaksiData.fold(0, (sum, detail) {
      // Ambil subtotal dari transaksiData dan pastikan itu bisa diparsing menjadi int
      int subtotal = int.tryParse(detail['nsubttl'].toString()) ?? 0;
      return sum + subtotal;
    });

    return formatter.format(total); // Format total
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Retur Penjualan'),
      ),
      body: SafeArea(
          child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: TextField(
                    readOnly: true,
                    controller: notransController,
                    decoration: InputDecoration(labelText: 'No. Transaksi'),
                  ),
                ),
                SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    readOnly: true,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Tanggal Retur',
                    ),
                    style: TextStyle(
                      color: Colors.blue[900],
                      fontWeight:
                          FontWeight.bold, // Ubah warna font menjadi biru
                    ),
                    controller: tglreturcontroller,
                  ),
                ),
                SizedBox(width: 8),
                IconButton(
                  icon: Icon(Icons.refresh),
                  onPressed: updateNotrans,
                ),
              ],
            ),
            Divider(
              color: Colors.black, // Warna garis
              thickness: 2, // Ketebalan garis
              indent: 10, // Jarak dari awal garis ke tepi kiri
              endIndent: 10, // Jarak dari akhir garis ke tepi kanan
            ),
            Row(
              children: [
                IconButton(
                  icon: Icon(Icons.search),
                  onPressed: searchTransaction,
                ),
                SizedBox(width: 8),
                Text('No. Jual: $nojual'),
              ],
            ),
            SizedBox(height: 8),
            Text('$nmcustomer - $tgljual'),
            SizedBox(height: 15),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                '$kdbarang - $nmbarang',
                style: TextStyle(
                  fontSize: 16.0,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue[900],
                ),
              ),
            ),
            SizedBox(height: 15),
            Row(
              children: [
                Expanded(
                  flex: 3, // Memberi lebih banyak ruang untuk harga jual
                  child: TextField(
                    readOnly: true,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Harga Jual',
                    ),
                    style: TextStyle(
                      color: Colors.blue[900],
                      fontWeight:
                          FontWeight.bold, // Ubah warna font menjadi biru
                    ),
                    controller: nrpjualController,
                  ),
                ),
                SizedBox(width: 5), // Menambahkan sedikit ruang antar TextField
                Expanded(
                  flex: 1, // Memberi lebih sedikit ruang untuk QTY
                  child: TextField(
                    readOnly: true,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'QTY',
                    ),
                    style: TextStyle(
                      color: Colors.blue[900],
                      fontWeight:
                          FontWeight.bold, // Ubah warna font menjadi biru
                    ),
                    controller: nqtyjualController,
                  ),
                ),
                SizedBox(width: 5),
                Expanded(
                  flex: 3, // Memberi lebih sedikit ruang untuk QTY
                  child: TextField(
                    //  focusNode: jumlahFocusNode,
                    readOnly: true,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Sub Total',
                    ),
                    style: TextStyle(
                      color: Colors.blue[900],
                      fontWeight:
                          FontWeight.bold, // Ubah warna font menjadi biru
                    ),
                    controller: nsubttljualController,
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: nqtyreturController,
                    decoration: InputDecoration(labelText: 'Qty Retur'),
                    keyboardType: TextInputType.number,
                    onChanged: (value) => calculateSubtotalRetur(),
                  ),
                ),
                SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: nrpreturController,
                    decoration: InputDecoration(labelText: 'Harga Retur'),
                    keyboardType: TextInputType.number,
                    onChanged: (value) => calculateSubtotalRetur(),
                  ),
                ),
              ],
            ),
            SizedBox(height: 8),
            Text('Subtotal: $nsubtotalret'),
            TextField(
              controller: keteranganController,
              decoration: InputDecoration(labelText: 'Keterangan'),
            ),
            SizedBox(height: 16),
            Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
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
                Expanded(
                    child: Row(
                  children: [
                    IconButton(
                      icon: Icon(Icons.add),
                      onPressed: addRetur,
                    ),
                    IconButton(
                      icon: Icon(Icons.payment),
                      onPressed: () {
                        //    !transaksiData.any((item) => item['llunas'] == '1') ? showPaymentDialog : null;
                        if (!transaksiData
                            .any((item) => item['llunas'] == '1')) {
                          showPaymentDialog();
                        }
                      },
                    ),
                    IconButton(
                        icon: Icon(Icons.search), onPressed: openSearchPopup),
                  ],
                )),
              ],
            ),
            Divider(
              color: Colors.black, // Warna garis
              thickness: 2, // Ketebalan garis
              indent: 10, // Jarak dari awal garis ke tepi kiri
              endIndent: 10, // Jarak dari akhir garis ke tepi kanan
            ),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                columns: [
                  DataColumn(label: Text('Kode Barang')),
                  DataColumn(label: Text('Nama Barang')),
                  DataColumn(label: Text('Qty Retur')),
                  DataColumn(label: Text('Harga Retur')),
                  DataColumn(label: Text('Subtotal')),
                  DataColumn(label: Text('No. Transaksi')),
                  DataColumn(label: Text('No. Penjualan')),
                ],
                rows: transaksiData.map((detail) {
                  return DataRow(
                    cells: [
                      DataCell(Text(detail['kdbarang'] ?? '')),
                      DataCell(Text(detail['nmbarang'] ?? '')),
                      DataCell(Text(detail['nqtyretur'].toString() ?? '')),
                      DataCell(Text(detail['nrpretur'].toString() ?? '')),
                      DataCell(Text(detail['nsubtotal'].toString() ?? '')),
                      DataCell(Text(detail['notrans'] ?? '')),
                      DataCell(Text(detail['nojual'] ?? '')),
                    ],
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      )),
    );
  }
}

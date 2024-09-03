import 'package:flutter/material.dart';
import 'package:pos/carijual.dart';

import 'service.dart';

class ReturJualPage extends StatefulWidget {
  final String varpbuser;
  final String varbagian;
  final String varlks;
  final String varnmlok;

  ReturJualPage(this.varpbuser, this.varbagian, this.varlks, this.varnmlok);

  @override
  _ReturJualPageState createState() => _ReturJualPageState();
}

class _ReturJualPageState extends State<ReturJualPage> {
  TextEditingController notransController = TextEditingController(text: 'RJL-Baru');
  TextEditingController nqtyreturController = TextEditingController();
  TextEditingController nrpreturController = TextEditingController();
  TextEditingController keteranganController = TextEditingController();

  String nojual = '';
  String nmcustomer = '';
  String tgljual = '';
  String kdbarang = '';
  String nmbarang = '';
  String nqtyjual = '';
  String nrpjual = '';
  String nsubtotal = '';
  String nsubtotalret = '';

  List<Map<String, dynamic>> returDetail = [];

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
      nqtyreturController.clear();
      nrpreturController.clear();
      nsubtotalret = '';
      keteranganController.clear();
      returDetail.clear();
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

    if (result != null) {
      setState(() {
        nojual = result['notrans'] ?? '';
        nmcustomer = result['nmcust'] ?? '';
        tgljual = result['tgl'] ?? '';
        kdbarang = result['kdbarang'] ?? '';
        nmbarang = result['nmbarang'] ?? '';
        nqtyjual = result['nqty']?.toString() ?? '';
        nrpjual = result['nrp']?.toString() ?? '';
        nsubtotal = result['subttl']?.toString() ?? '';
      });
    }
  }

  Future<void> addRetur() async {
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
        returDetail.addAll(response);
        kdbarang = '';
        nmbarang = '';
        nqtyjual = '';
        nrpjual = '';
        nsubtotal = '';
        nqtyreturController.clear();
        nrpreturController.clear();
        nsubtotalret = '';
      }
    });
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
                    controller: notransController,
                    decoration: InputDecoration(labelText: 'No. Transaksi'),
                  ),
                ),
                SizedBox(width: 8),
                Text('Tgl Transaksi: ${DateTime.now().toString().split(' ')[0]}'),
                SizedBox(width: 8),
                IconButton(
                  icon: Icon(Icons.refresh),
                  onPressed: updateNotrans,
                ),
              ],
            ),
            Divider(),
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
            // Text('Tgl Jual: $tgljual'),
            SizedBox(height: 8),
            Text('Barang: $kdbarang - $nmbarang'),
            //Text('Nama Barang: $nmbarang'),
            SizedBox(height: 8),
            Text('$nqtyjual pcs x Rp $nrpjual = Rp $nsubtotal'),
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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                IconButton(
                  icon: Icon(Icons.add),
                  onPressed: addRetur,
                ),
                IconButton(
                  icon: Icon(Icons.payment),
                  onPressed: () {
                    // Implementasikan logika pembayaran di sini
                  },
                ),
                IconButton(
                  icon: Icon(Icons.search),
                  onPressed: () {
                    // Implementasikan logika pencarian tambahan jika diperlukan
                  },
                ),
              ],
            ),
            Divider(),
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
                ],
                rows: returDetail.map((detail) {
                  return DataRow(
                    cells: [
                      DataCell(Text(detail['kdbarang'] ?? '')),
                      DataCell(Text(detail['nmbarang'] ?? '')),
                      DataCell(Text(detail['nqtyretur']?.toString() ?? '')),
                      DataCell(Text(detail['nrpretur']?.toString() ?? '')),
                      DataCell(Text(detail['nsubtotal']?.toString() ?? '')),
                      DataCell(Text(detail['notrans'] ?? '')),
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

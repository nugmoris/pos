import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'customer_search_popup.dart';
import 'item_search_popup.dart';
import 'service.dart';

class Penjkary extends StatefulWidget {
  final String varpbuser;
  final String varbagian;
  final String varlks;
  final String varnmlok;

  Penjkary(this.varpbuser, this.varbagian, this.varlks, this.varnmlok);

  @override
  State<Penjkary> createState() => _PenjkaryState();
}

class _PenjkaryState extends State<Penjkary> {
  TextEditingController tgl1Controller = TextEditingController();
  TextEditingController tgl2Controller = TextEditingController();
  TextEditingController kodeCustomerController = TextEditingController();
  TextEditingController namaCustomerController = TextEditingController();
  TextEditingController kodeBarangController = TextEditingController();
  TextEditingController namaBarangController = TextEditingController();

  bool semuaKaryawan = true;
  bool semuaBarang = true;

  List<Map<String, dynamic>> laporanPenjualan = [];
  double grandTotal = 0.0;

  @override
  void initState() {
    super.initState();
    tgl1Controller.text = DateFormat('yyyy-MM-dd').format(DateTime.now());
    tgl2Controller.text = DateFormat('yyyy-MM-dd').format(DateTime.now());
  }

  void _prosesLaporan() async {
    try {
      String tgl1 = tgl1Controller.text;
      String tgl2 = tgl2Controller.text;
      String kdcust = kodeCustomerController.text;
      String kdbarang = kodeBarangController.text;

      String kondisi1 = semuaKaryawan ? "1" : "2";
      String kondisi2 = semuaBarang ? "1" : "2";

      List<Map<String, dynamic>> result = await ApiService.lapjualkary(
        widget.varpbuser,
        widget.varlks,
        tgl1,
        tgl2,
        kdcust,
        kondisi1,
        kondisi2,
        kdbarang,
      );

      setState(() {
        laporanPenjualan = result;
        grandTotal = result.fold(0.0, (sum, item) => sum + double.parse(item['subtotal']));
      });
    } catch (e) {
      print('Error fetching report data: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Laporan Penjualan Karyawan'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            //Text('Laporan Penjualan Karyawan', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            Text(widget.varnmlok, style: TextStyle(fontSize: 16)),
            SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: tgl1Controller,
                    decoration: InputDecoration(labelText: 'Tanggal Awal'),
                    readOnly: true,
                    onTap: () async {
                      DateTime? picked = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime(2000),
                        lastDate: DateTime(2101),
                      );
                      if (picked != null) {
                        setState(() {
                          tgl1Controller.text = DateFormat('yyyy-MM-dd').format(picked);
                        });
                      }
                    },
                  ),
                ),
                SizedBox(width: 10),
                Expanded(
                  child: TextField(
                    controller: tgl2Controller,
                    decoration: InputDecoration(labelText: 'Tanggal Akhir'),
                    readOnly: true,
                    onTap: () async {
                      DateTime? picked = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime(2000),
                        lastDate: DateTime(2101),
                      );
                      if (picked != null) {
                        setState(() {
                          tgl2Controller.text = DateFormat('yyyy-MM-dd').format(picked);
                        });
                      }
                    },
                  ),
                ),
              ],
            ),
            SizedBox(height: 10),
            Row(
              children: [
                Checkbox(
                  value: semuaKaryawan,
                  onChanged: (bool? value) {
                    setState(() {
                      semuaKaryawan = value ?? false;
                      namaCustomerController.text = "";
                    });
                  },
                ),
                Text('Semua Karyawan'),
                SizedBox(width: 10),
                IconButton(
                  icon: Icon(Icons.search),
                  onPressed: semuaKaryawan
                      ? null
                      : () async {
                          final result = await showDialog(
                            context: context,
                            builder: (context) {
                              return CustomerSearchPopup(
                                varpbuser: widget.varpbuser,
                                onCustomerSelected: (kode, nama) {
                                  setState(() {
                                    kodeCustomerController.text = kode;
                                    namaCustomerController.text = nama;
                                  });
                                },
                              );
                            },
                          );
                        },
                ),
                Expanded(
                  child: TextField(
                    controller: namaCustomerController,
                    decoration: InputDecoration(labelText: 'Nama Customer'),
                    readOnly: true,
                  ),
                ),
              ],
            ),
            Row(
              children: [
                Checkbox(
                  value: semuaBarang,
                  onChanged: (bool? value) {
                    setState(() {
                      semuaBarang = value ?? false;
                      namaBarangController.text = '';
                    });
                  },
                ),
                Text('Semua Barang'),
                SizedBox(width: 10),
                IconButton(
                  icon: Icon(Icons.search),
                  onPressed: semuaBarang
                      ? null
                      : () async {
                          final result = await showDialog(
                            context: context,
                            builder: (context) {
                              return ItemSearchPopup(
                                varpbuser: widget.varpbuser,
                                onItemSelected: (kode, nama, harga) {
                                  setState(() {
                                    kodeBarangController.text = kode;
                                    namaBarangController.text = nama;
                                  });
                                },
                              );
                            },
                          );
                        },
                ),
                Expanded(
                  child: TextField(
                    controller: namaBarangController,
                    decoration: InputDecoration(labelText: 'Nama Barang'),
                    readOnly: true,
                  ),
                ),
              ],
            ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: _prosesLaporan,
              child: Text('Proses'),
            ),
            SizedBox(height: 20),
            laporanPenjualan.isNotEmpty
                ? Expanded(
                    child: SingleChildScrollView(
                      scrollDirection: Axis.vertical,
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: DataTable(
                          columns: [
                            DataColumn(label: Text('No Trans')),
                            DataColumn(label: Text('Tanggal')),
                            DataColumn(label: Text('Customer')),
                            DataColumn(label: Text('Nama Barang')),
                            DataColumn(label: Text('Qty')),
                            DataColumn(label: Text('NRP')),
                            DataColumn(label: Text('Subtotal')),
                          ],
                          rows: laporanPenjualan.map((data) {
                            return DataRow(
                              cells: [
                                DataCell(Text(data['notrans'])),
                                DataCell(Text(data['tgl'])),
                                DataCell(Text(data['nmcust'])),
                                DataCell(Text(data['nmbarang'])),
                                DataCell(Text(data['nqty'])),
                                DataCell(Text(NumberFormat.currency(locale: 'id', symbol: '').format(int.parse(data['nrp'])))),
                                DataCell(Text(NumberFormat.currency(locale: 'id', symbol: '').format(int.parse(data['subtotal'])))),
                              ],
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                  )
                : Text('Tidak ada data'),
            SizedBox(height: 20),
            Text(
              'Grand Total: ${NumberFormat.currency(locale: 'id', symbol: '').format(grandTotal)}',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}

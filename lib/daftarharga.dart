import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'service.dart';

class DaftarHarga extends StatefulWidget {
  final String varpbuser;
  final String varbagian;
  final String varlks;
  final String varnmlok;
  DaftarHarga(this.varpbuser, this.varbagian, this.varlks, this.varnmlok);

  @override
  State<DaftarHarga> createState() => _DaftarHargaState();
}

class _DaftarHargaState extends State<DaftarHarga> {
  String? selectedJenis;
  TextEditingController cariController = TextEditingController();
  List<Map<String, dynamic>> jenisBarangList = [];
  List<Map<String, dynamic>> DaftarHargaList = [];
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchJenisBarang();
  }

  Future<void> _fetchJenisBarang() async {
    try {
      final List<Map<String, dynamic>> data = await ApiService.jenisbarang(widget.varpbuser);
      setState(() {
        jenisBarangList = data;
      });
    } catch (e) {
      print('Error fetching jenis barang: $e');
    }
  }

  Future<void> _fetchDaftarHarga() async {
    setState(() {
      isLoading = true;
    });
    try {
      final kondisi = cariController.text.isEmpty ? '1' : '2';
      final List<Map<String, dynamic>> data = await ApiService.daftarharga(
        widget.varpbuser,
        widget.varlks,
        selectedJenis ?? '00',
        cariController.text,
        kondisi,
      );
      setState(() {
        DaftarHargaList = data;
        isLoading = false;
      });
    } catch (e) {
      print('Error fetching daftar harga: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  String formatCurrency(dynamic amount) {
    final formatter = NumberFormat('#,##0', 'en_US');
    if (amount is String) {
      amount = int.tryParse(amount) ?? 0;
    }
    return formatter.format(amount);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Daftar Harga'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            DropdownButton<String>(
              hint: Text('Pilih Jenis Barang'),
              value: selectedJenis,
              isExpanded: true,
              items: jenisBarangList.map((item) {
                return DropdownMenuItem<String>(
                  value: item['kode'],
                  child: Text(item['nama']),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  selectedJenis = value;
                });
              },
            ),
            SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: cariController,
                    decoration: InputDecoration(
                      labelText: 'Cari',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                SizedBox(width: 10),
                ElevatedButton(
                  onPressed: _fetchDaftarHarga,
                  child: Text('Tampilkan'),
                ),
              ],
            ),
            SizedBox(height: 20),
            Expanded(
              child: isLoading
                  ? Center(child: CircularProgressIndicator())
                  : SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: SingleChildScrollView(
                        scrollDirection: Axis.vertical,
                        child: DataTable(
                          columnSpacing: 10.0, // Set column spacing
                          columns: const [
                            DataColumn(label: Text('Jenis Barang')),
                            DataColumn(label: Text('Nama Barang')),
                            DataColumn(label: Text('Harga')),
                          ],
                          rows: DaftarHargaList.map((item) {
                            return DataRow(cells: [
                              DataCell(
                                Container(
                                  width: 100, // Adjust the width as needed
                                  child: Text(item['nmjenis'] ?? ''),
                                ),
                              ),
                              DataCell(
                                Container(
                                  width: 150, // Adjust the width as needed
                                  child: Text(item['nama'] ?? ''),
                                ),
                              ),
                              DataCell(
                                Container(
                                  width: 80, // Adjust the width as needed
                                  child: Text(formatCurrency(item['nhargajual'] ?? 0)),
                                ),
                              ),
                            ]);
                          }).toList(),
                        ),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

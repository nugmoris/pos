import 'package:flutter/material.dart';

import 'service.dart';

class LapStok extends StatefulWidget {
  final String varpbuser;
  final String varbagian;
  final String varlks;
  final String varnmlok;
  LapStok(this.varpbuser, this.varbagian, this.varlks, this.varnmlok);

  @override
  State<LapStok> createState() => _LapStokState();
}

class _LapStokState extends State<LapStok> {
  String? selectedJenis;
  TextEditingController cariController = TextEditingController();
  List<Map<String, dynamic>> jenisBarangList = [];
  List<Map<String, dynamic>> lapstokList = [];
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

  Future<void> _fetchLapStok() async {
    setState(() {
      isLoading = true;
    });
    try {
      final kondisi = cariController.text.isEmpty ? '1' : '2';
      final List<Map<String, dynamic>> data = await ApiService.lapstok(
        widget.varpbuser,
        widget.varlks,
        selectedJenis ?? '00',
        cariController.text,
        kondisi,
      );
      setState(() {
        lapstokList = data;
        isLoading = false;
      });
    } catch (e) {
      print('Error fetching lap stok: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Laporan Stok'),
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
                  onPressed: _fetchLapStok,
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
                          columns: const [
                            DataColumn(label: Text('Jenis Barang')),
                            DataColumn(label: Text('Nama Barang')),
                            DataColumn(label: Text('Qty')),
                          ],
                          rows: lapstokList.map((item) {
                            return DataRow(cells: [
                              DataCell(Text(item['nmjenis'] ?? '')),
                              DataCell(Text(item['nama'] ?? '')),
                              DataCell(Text(item['nqty'] ?? '')),
                            ]);
                          }).toList(),
                        ),
                      )),
            ),
          ],
        ),
      ),
    );
  }
}

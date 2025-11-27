import 'package:flutter/material.dart';

import 'service.dart';

class CarijualPage extends StatefulWidget {
  final String varpbuser;

  CarijualPage(this.varpbuser);

  @override
  _CarijualPageState createState() => _CarijualPageState();
}

class _CarijualPageState extends State<CarijualPage> {
  TextEditingController searchController = TextEditingController();
  List<Map<String, dynamic>> searchResults = [];

  Future<void> searchTransactions() async {
    print('searchTransactions 1 di dalam carijual.dart');
    final response = await ApiService.carijual(
        widget.varpbuser, searchController.text, '4', '2024-01-01');
    print('searchTransactions 2 di dalam carijual.dart');
    setState(() {
      searchResults = response;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Cari Transaksi'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: searchController,
              decoration: InputDecoration(labelText: 'Cari Transaksi'),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: searchTransactions,
              child: Text('Cari'),
            ),
            SizedBox(height: 16),
            if (searchResults.isNotEmpty)
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.vertical, // Scroll vertikal
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal, // Scroll horizontal
                    child: DataTable(
                      columns: [
                        DataColumn(label: Text('No Transaksi')),
                        DataColumn(label: Text('Customer')),
                        DataColumn(label: Text('Tanggal')),
                        DataColumn(label: Text('Kode Barang')),
                        DataColumn(label: Text('Nama Barang')),
                        DataColumn(label: Text('Qty')),
                        DataColumn(label: Text('Harga')),
                        DataColumn(label: Text('Subtotal')),
                      ],
                      rows: searchResults.map((result) {
                        return DataRow(
                          cells: [
                            DataCell(Text(result['notrans'] ?? '')),
                            DataCell(Text(result['nmcust'] ?? '')),
                            DataCell(Text(result['tgl'] ?? '')),
                            DataCell(Text(result['kdbarang'] ?? '')),
                            DataCell(Text(result['nmbarang'] ?? '')),
                            DataCell(Text(result['nqty']?.toString() ?? '')),
                            DataCell(Text(result['nrp']?.toString() ?? '')),
                            DataCell(Text(result['subttl']?.toString() ?? '')),
                          ],
                          onSelectChanged: (selected) {
                            if (selected != null && selected) {
                              Navigator.pop(context, {
                                'notrans': result['notrans'],
                                'nmcust': result['nmcust'],
                                'kdbarang': result['kdbarang'],
                                'nmbarang': result['nmbarang'],
                                'nqty': result['nqty'],
                                'nrp': result['nrp'],
                                'subttl': result['subttl'],
                                'tgljual': result['tgl'],
                              });
                            }
                          },
                        );
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

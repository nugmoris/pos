import 'package:flutter/material.dart';

import 'service.dart';

class ItemSearchPopup extends StatefulWidget {
  final String varpbuser;
  final Function(String, String, String) onItemSelected;

  ItemSearchPopup({required this.varpbuser, required this.onItemSelected});

  @override
  _ItemSearchPopupState createState() => _ItemSearchPopupState();
}

class _ItemSearchPopupState extends State<ItemSearchPopup> {
  TextEditingController searchController = TextEditingController();
  List<Map<String, dynamic>> searchResults = [];

  void initState() {
    super.initState();
    _searchInitialItems();
  }

  void _searchInitialItems() async {
    try {
      List<Map<String, dynamic>> result = await ApiService.crbarang2(widget.varpbuser, '', '2');
      setState(() {
        searchResults = result;
      });
    } catch (e) {
      print('Error fetching initial item data: $e');
    }
  }

  void _searchItems() async {
    try {
      List<Map<String, dynamic>> result = await ApiService.crbarang2(widget.varpbuser, searchController.text, '3');
      setState(() {
        searchResults = result;
      });
    } catch (e) {
      print('Error fetching item data: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Cari Barang'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: searchController,
              decoration: InputDecoration(
                labelText: 'Masukkan kata kunci',
              ),
            ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: _searchItems,
              child: Text('Cari'),
            ),
            SizedBox(height: 10),
            searchResults.isNotEmpty
                ? SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: DataTable(
                      columns: [
                        DataColumn(label: Text('Nama')),
                        DataColumn(label: Text('Harga')),
                      ],
                      rows: searchResults.map((data) {
                        return DataRow(
                          cells: [
                            DataCell(
                              Text(data['nama']),
                              onTap: () {
                                widget.onItemSelected(data['kode'], data['nama'], data['nhargajual']);
                                Navigator.of(context).pop();
                              },
                            ),
                            DataCell(
                              Text(
                                data['nhargajual'] ?? '0',
                              ),
                              onTap: () {
                                widget.onItemSelected(data['kode'], data['nama'], data['nhargajual']);
                                Navigator.of(context).pop();
                              },
                            ),
                          ],
                        );
                      }).toList(),
                    ),
                  )
                : Text('Tidak ada hasil'),
          ],
        ),
      ),
      actions: <Widget>[
        TextButton(
          child: Text('Tutup'),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ],
    );
  }
}

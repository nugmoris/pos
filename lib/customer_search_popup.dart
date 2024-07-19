import 'package:flutter/material.dart';

import 'service.dart';

class CustomerSearchPopup extends StatefulWidget {
  final String varpbuser;
  final Function(String, String) onCustomerSelected;

  CustomerSearchPopup({required this.varpbuser, required this.onCustomerSelected});

  @override
  _CustomerSearchPopupState createState() => _CustomerSearchPopupState();
}

class _CustomerSearchPopupState extends State<CustomerSearchPopup> {
  TextEditingController searchController = TextEditingController();
  List<Map<String, dynamic>> searchResults = [];
  void initState() {
    super.initState();
    // Panggil _searchCustomer saat halaman ini diload
    _searchInitialCustomer();
  }

  void _searchInitialCustomer() async {
    try {
      List<Map<String, dynamic>> result = await ApiService.crcust(widget.varpbuser, '', '1');
      setState(() {
        searchResults = result;
      });
    } catch (e) {
      print('Error fetching initial customer data: $e');
    }
  }

  void _searchCustomer() async {
    try {
      List<Map<String, dynamic>> result = await ApiService.crcust(widget.varpbuser, searchController.text, '2');
      setState(() {
        searchResults = result;
      });
    } catch (e) {
      print('Error fetching customer data: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Cari Customer'),
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
              onPressed: _searchCustomer,
              child: Text('Cari'),
            ),
            SizedBox(height: 10),
            searchResults.isNotEmpty
                ? SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: DataTable(
                      columns: [
                        DataColumn(label: Text('Kode')),
                        DataColumn(label: Text('Nama')),
                      ],
                      rows: searchResults.map((data) {
                        return DataRow(
                          cells: [
                            DataCell(
                              Text(data['kode']),
                              onTap: () {
                                widget.onCustomerSelected(data['kode'], data['nama']);
                                Navigator.of(context).pop();
                              },
                            ),
                            DataCell(
                              Text(data['nama']),
                              onTap: () {
                                widget.onCustomerSelected(data['kode'], data['nama']);
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

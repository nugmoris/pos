import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'service.dart';

class TransactionSearchPopup extends StatefulWidget {
  final String varpbuser;
  final String varlks;
  final Function(String, String) onTransactionSelected;

  TransactionSearchPopup({
    required this.varpbuser,
    required this.varlks,
    required this.onTransactionSelected,
  });

  @override
  _TransactionSearchPopupState createState() => _TransactionSearchPopupState();
}

class _TransactionSearchPopupState extends State<TransactionSearchPopup> {
  List<Map<String, dynamic>> searchResults = [];
  final NumberFormat currencyFormat = NumberFormat("#,##0", "en_US");
  final TextEditingController _cariController = TextEditingController();
  late String today;

  @override
  void initState() {
    super.initState();
    today = DateFormat('yyyy-MM-dd').format(DateTime.now());
    _searchTransactions("1", ""); // pencarian awal kosong
  }

  void _searchTransactions(String kondisi1, String cari1) async {
    try {
      List<Map<String, dynamic>> result = await ApiService.carijualnow(
          today, today, kondisi1, widget.varlks, cari1);
      // print('coba cari');
      setState(() {
        searchResults = result;
      });
    } catch (e) {
      print('Error fetching transaction data: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Pencarian Transaksi'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 🔍 Kolom pencarian
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _cariController,
                  decoration: InputDecoration(
                    hintText: 'Cari no transaksi...',
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              SizedBox(width: 8),
              ElevatedButton(
                onPressed: () {
                  String cari1 = _cariController.text.trim();
                  _searchTransactions("2", cari1);
                },
                child: Text('Cari'),
              ),
            ],
          ),
          SizedBox(height: 16),

          // 📋 Hasil pencarian
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: SingleChildScrollView(
                scrollDirection: Axis.vertical,
                child: DataTable(
                  columns: const [
                    DataColumn(label: Text('No Transaksi')),
                    DataColumn(label: Text('Customer')),
                    DataColumn(label: Text('Total')),
                    DataColumn(label: Text('Terbayar')),
                  ],
                  rows: searchResults.map((data) {
                    return DataRow(
                      cells: [
                        DataCell(Text(data['notrans'] ?? ''), onTap: () {
                          widget.onTransactionSelected(
                              data['notrans'] ?? '', data['nbayar'] ?? '0');
                          Navigator.of(context).pop();
                        }),
                        DataCell(Text(data['nmcust'] ?? ''), onTap: () {
                          widget.onTransactionSelected(
                              data['notrans'] ?? '', data['nbayar'] ?? '0');
                          Navigator.of(context).pop();
                        }),
                        DataCell(
                          Text(currencyFormat
                              .format(int.tryParse(data['tot'] ?? '0') ?? 0)),
                          onTap: () {
                            widget.onTransactionSelected(
                                data['notrans'] ?? '', data['nbayar'] ?? '0');
                            Navigator.of(context).pop();
                          },
                        ),
                        DataCell(
                          Text(currencyFormat.format(
                              int.tryParse(data['nbayar'] ?? '0') ?? 0)),
                          onTap: () {
                            widget.onTransactionSelected(
                                data['notrans'] ?? '', data['nbayar'] ?? '0');
                            Navigator.of(context).pop();
                          },
                        ),
                      ],
                    );
                  }).toList(),
                ),
              ),
            ),
          ),
        ],
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

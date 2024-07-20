import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'service.dart';

class TransactionSearchPopup extends StatefulWidget {
  final String varpbuser;
  final Function(String, String) onTransactionSelected; // Mengubah parameter

  TransactionSearchPopup({required this.varpbuser, required this.onTransactionSelected});

  @override
  _TransactionSearchPopupState createState() => _TransactionSearchPopupState();
}

class _TransactionSearchPopupState extends State<TransactionSearchPopup> {
  List<Map<String, dynamic>> searchResults = [];
  final NumberFormat currencyFormat = NumberFormat("#,##0", "en_US");

  @override
  void initState() {
    super.initState();
    _searchTransactions();
  }

  void _searchTransactions() async {
    try {
      String today = DateFormat('yyyy-MM-dd').format(DateTime.now());
      List<Map<String, dynamic>> result = await ApiService.lapjual(today, today, "1");
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
      title: Text('Hasil Pencarian'),
      content: SingleChildScrollView(
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
                  DataCell(Text(data['notrans']), onTap: () {
                    widget.onTransactionSelected(data['notrans'], data['nbayar']); // Mengirim notrans dan nbayar
                    Navigator.of(context).pop();
                  }),
                  DataCell(Text(data['nmcust']), onTap: () {
                    widget.onTransactionSelected(data['notrans'], data['nbayar']); // Mengirim notrans dan nbayar
                    Navigator.of(context).pop();
                  }),
                  DataCell(Text(currencyFormat.format(int.parse(data['tot']))), onTap: () {
                    widget.onTransactionSelected(data['notrans'], data['nbayar']); // Mengirim notrans dan nbayar
                    Navigator.of(context).pop();
                  }),
                  DataCell(Text(currencyFormat.format(int.parse(data['nbayar']))), onTap: () {
                    widget.onTransactionSelected(data['notrans'], data['nbayar']); // Mengirim notrans dan nbayar
                    Navigator.of(context).pop();
                  }),
                ],
              );
            }).toList(),
          ),
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

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'service.dart'; // Pastikan untuk mengimpor file service.dart

class LapKas extends StatefulWidget {
  final String varpbuser;
  final String varbagian;
  final String varlks;
  final String varnmlok;

  LapKas(this.varpbuser, this.varbagian, this.varlks, this.varnmlok);

  @override
  State<LapKas> createState() => _LapKasState();
}

class _LapKasState extends State<LapKas> {
  DateTime selectedDate = DateTime.now();
  List<Map<String, dynamic>> reportData = [];
  bool isLoading = false;

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  String formatNumber(String number) {
    return NumberFormat('#,##0.00', 'en_US').format(double.parse(number));
  }

  Future<void> fetchReport() async {
    setState(() {
      isLoading = true;
    });

    try {
      List<Map<String, dynamic>> data = await ApiService.lapkascb(
        DateFormat('yyyy-MM-dd').format(selectedDate),
        widget.varpbuser,
        widget.varlks,
      );
      setState(() {
        reportData = data;
      });
    } catch (e) {
      print("Failed to fetch report data: $e");
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Lap Kas Cabang'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text('Laporan Kas ${widget.varnmlok} tanggal ${DateFormat('yyyy-MM-dd').format(selectedDate)}'),
            SizedBox(height: 16.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton(
                  onPressed: () => _selectDate(context),
                  child: Text('Pilih Tanggal'),
                ),
                ElevatedButton(
                  onPressed: fetchReport,
                  child: Text('Tampilkan'),
                ),
              ],
            ),
            SizedBox(height: 16.0),
            isLoading
                ? CircularProgressIndicator()
                : Expanded(
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: DataTable(
                        columns: const [
                          DataColumn(label: Text('No Trans')),
                          DataColumn(label: Text('Tanggal')),
                          DataColumn(label: Text('Dari')),
                          DataColumn(label: Text('Debet')),
                          DataColumn(label: Text('Kredit')),
                          DataColumn(label: Text('Saldo')),
                        ],
                        rows: reportData.map((data) {
                          return DataRow(
                            cells: [
                              DataCell(Text(data['notrans'] ?? '')),
                              DataCell(Text(data['tgl'] ?? '')),
                              DataCell(Text(data['dari'] ?? '')),
                              DataCell(Text(formatNumber(data['ndebet'] ?? '0.00'))),
                              DataCell(Text(formatNumber(data['nkredit'] ?? '0.00'))),
                              DataCell(Text(formatNumber(data['saldo'] ?? '0.00'))),
                            ],
                          );
                        }).toList(),
                      ),
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}

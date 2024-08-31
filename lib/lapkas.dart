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
  List<Map<String, dynamic>> kirabayarData = [];
  String? selectedKdgl;

  @override
  void initState() {
    super.initState();
    fetchKirabayarData();
  }

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

  Future<void> fetchKirabayarData() async {
    try {
      List<Map<String, dynamic>> data = await ApiService.kirabayar(
        widget.varpbuser,
        widget.varlks,
      );
      setState(() {
        kirabayarData = data;
      });
    } catch (e) {
      print("Failed to fetch kirabayar data: $e");
    }
  }

  Future<void> fetchReport() async {
    setState(() {
      isLoading = true;
    });

    try {
      List<Map<String, dynamic>> data = await ApiService.lapkascb2(
        DateFormat('yyyy-MM-dd').format(selectedDate),
        widget.varpbuser,
        widget.varlks,
        selectedKdgl ?? '',
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
            DropdownButton<String>(
              hint: Text("Pilih Kdgl"),
              value: selectedKdgl,
              onChanged: (String? newValue) {
                setState(() {
                  selectedKdgl = newValue;
                });
              },
              items: kirabayarData.map<DropdownMenuItem<String>>((Map<String, dynamic> value) {
                return DropdownMenuItem<String>(
                  value: value['kdgl'],
                  child: Text('${value['nmkira']} (${value['kdgl']})'),
                );
              }).toList(),
            ),
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
                      scrollDirection: Axis.vertical,
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
                            DataColumn(label: Text('Waktu Input')),
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
                                DataCell(Text(data['tgl'] ?? '')),
                              ],
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

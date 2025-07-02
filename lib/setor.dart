import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // For thousand separator formatting

import 'service.dart'; // Assuming the ApiService is defined here

class Setor extends StatefulWidget {
  final String varpbuser;
  final String varbagian;
  final String varlks;
  final String varnmlok;

  Setor(this.varpbuser, this.varbagian, this.varlks, this.varnmlok);

  @override
  State<Setor> createState() => _SetorState();
}

class _SetorState extends State<Setor> {
  final TextEditingController _nilaiSetorController = TextEditingController();
  final TextEditingController _nilaisisa = TextEditingController();
  final TextEditingController _ketSetorController = TextEditingController();
  double saldoKas = 0; // Initial saldo kas
  List<Map<String, dynamic>> hasilApi = [];
  bool isProsesButtonVisible = true;
  bool isProcessing = false; // Tambahan untuk disable tombol saat proses

  @override
  void initState() {
    super.initState();
    _fetchSaldoKas();
  }

  Future<void> _fetchSaldoKas() async {
    try {
      List<Map<String, dynamic>> result =
          await ApiService.lihatsldkas(widget.varpbuser, widget.varlks);
      if (result.isNotEmpty) {
        setState(() {
          saldoKas = double.parse(result[0]['@saldokas']);
        });
      }
    } catch (e) {
      print('Failed to fetch saldo kas: $e');
    }
  }

  void _isiNilaiSetor() {
    setState(() {
      _nilaiSetorController.text = saldoKas.toString();
      _nilaisisa.text = saldoKas.toString();
    });
  }

  Future<void> _prosesSetor() async {
    setState(() {
      isProcessing = true;
    });

    try {
      List<Map<String, dynamic>> result = await ApiService.setorkascb(
          widget.varpbuser,
          widget.varlks,
          _nilaiSetorController.text,
          _ketSetorController.text);
      setState(() {
        hasilApi = result;
        isProsesButtonVisible = false;
        _nilaiSetorController.clear();
        _ketSetorController.clear();
        saldoKas = 0;
        _nilaisisa.clear();
      });
    } catch (e) {
      print('Failed to fetch report data: $e');
    } finally {
      setState(() {
        isProcessing = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    String formattedSaldoKas = NumberFormat.decimalPattern().format(saldoKas);
    return Scaffold(
      appBar: AppBar(
        title: Text('Setor Kas Cabang'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Lokasi: ${widget.varnmlok}'),
              SizedBox(height: 5),
              Text(
                  'Tanggal: ${DateFormat('yyyy-MM-dd').format(DateTime.now())}'),
              SizedBox(height: 10),
              TextField(
                controller: _ketSetorController,
                decoration: InputDecoration(
                  labelText: 'Keterangan',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 20),
              Row(
                children: [
                  Text('Saldo Kas: $formattedSaldoKas'),
                  SizedBox(width: 10),
                  GestureDetector(
                    onTap: _isiNilaiSetor,
                    child: Icon(Icons.add_circle_outline, color: Colors.blue),
                  ),
                ],
              ),
              SizedBox(height: 20),
              TextField(
                controller: _nilaiSetorController,
                decoration: InputDecoration(
                  labelText: 'Nilai Setor',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
              ),
              SizedBox(height: 20),
              TextField(
                controller: _nilaisisa,
                decoration: InputDecoration(
                  labelText: 'Saldo yang disisakan',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
              ),
              SizedBox(height: 20),
              if (isProsesButtonVisible)
                ElevatedButton(
                  onPressed: (isProcessing) ? null : _prosesSetor,
                  child: isProcessing
                      ? SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.white))
                      : Text('Proses'),
                ),
              SizedBox(height: 20),
              hasilApi.isNotEmpty
                  ? Expanded(
                      child: SingleChildScrollView(
                        scrollDirection: Axis.vertical,
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: DataTable(
                            columns: [
                              DataColumn(label: Text('No Trans')),
                              DataColumn(label: Text('Ket')),
                              DataColumn(label: Text('N Debet')),
                              DataColumn(label: Text('N Kredit')),
                              DataColumn(label: Text('N Saldo')),
                            ],
                            rows: hasilApi.map((data) {
                              try {
                                return DataRow(cells: [
                                  DataCell(
                                      Text(data['notrans']?.toString() ?? '-')),
                                  DataCell(
                                      Text(data['ket']?.toString() ?? '-')),
                                  DataCell(Text(NumberFormat.decimalPattern()
                                      .format(double.tryParse(
                                              data['ndebet'].toString()) ??
                                          0))),
                                  DataCell(Text(NumberFormat.decimalPattern()
                                      .format(double.tryParse(
                                              data['nkredit'].toString()) ??
                                          0))),
                                  DataCell(Text(NumberFormat.decimalPattern()
                                      .format(double.tryParse(
                                              data['saldo'].toString()) ??
                                          0))),
                                ]);
                              } catch (e) {
                                print('Error parsing row: $e');
                                return DataRow(cells: [
                                  DataCell(Text('Error')),
                                  DataCell(Text('')),
                                  DataCell(Text('')),
                                  DataCell(Text('')),
                                  DataCell(Text('')),
                                ]);
                              }
                            }).toList(),
                          ),
                        ),
                      ),
                    )
                  : Text('No data available'),
            ],
          ),
        ),
      ),
    );
  }
}

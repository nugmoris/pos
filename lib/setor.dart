import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'service.dart';

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
  final TextEditingController _nsisaController = TextEditingController();
  double saldoKas = 0;
  List<Map<String, dynamic>> hasilApi = [];
  bool isProsesButtonVisible = true;
  bool isProcessing = false;
  bool isInputValid = false;

  @override
  void initState() {
    super.initState();
    _fetchSaldoKas();
    _nilaiSetorController.addListener(() {
      final nilai = double.tryParse(_nilaiSetorController.text) ?? 0;
      setState(() {
        isInputValid = nilai > 0;
      });
    });
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
      setState(() {
        double nilaiSetor = double.tryParse(_nilaiSetorController.text) ?? 0;
        double sisaSetor = double.tryParse(_nilaisisa.text) ?? 0;

        saldoKas = sisaSetor;

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white),
                SizedBox(width: 12),
                Text('Setor berhasil diproses!'),
              ],
            ),
            backgroundColor: Colors.green[600],
            behavior: SnackBarBehavior.floating,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            duration: Duration(seconds: 2),
          ),
        );
      });

      final fastResponse = await ApiService.setorkasFast(
        widget.varpbuser,
        widget.varlks,
        _nilaiSetorController.text.isEmpty ? "0" : _nilaiSetorController.text,
        _ketSetorController.text,
        _nilaisisa.text.isEmpty ? "0" : _nilaisisa.text,
      );

      String notrans = "";
      if (fastResponse is List && fastResponse.isNotEmpty) {
        notrans = fastResponse[0]['notrans'] ?? "";
      }

      if (notrans.isNotEmpty) {
        await ApiService.updateSetorCalculation(
            widget.varpbuser, widget.varlks, notrans);
      }

      setState(() {
        _nilaiSetorController.clear();
        _ketSetorController.clear();
        _nsisaController.clear();
        _nilaisisa.clear();
        isProcessing = false;
      });

      _fetchCompleteSetorData();
    } catch (e) {
      setState(() {
        isProcessing = false;
        isProsesButtonVisible = true;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.error, color: Colors.white),
              SizedBox(width: 12),
              Text('Gagal memproses setor: $e'),
            ],
          ),
          backgroundColor: Colors.red[600],
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );

      _fetchSaldoKas();
    }
  }

  Future<void> _fetchCompleteSetorData() async {
    try {
      List<Map<String, dynamic>> result = await ApiService.getSetorHistory(
        widget.varpbuser,
        widget.varlks,
      );

      setState(() {
        hasilApi = result;
      });

      _fetchSaldoKas();
    } catch (e) {
      print('Background fetch failed: $e');
    }
  }

  @override
  void dispose() {
    _nilaiSetorController.dispose();
    _nilaisisa.dispose();
    _ketSetorController.dispose();
    _nsisaController.dispose();
    super.dispose();
  }

  Widget _buildInfoCard() {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Color(0xFF6366F1).withOpacity(0.3),
            blurRadius: 12,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.location_on, color: Colors.white70, size: 18),
              SizedBox(width: 8),
              Text(
                widget.varnmlok,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          SizedBox(height: 12),
          Row(
            children: [
              Icon(Icons.calendar_today, color: Colors.white70, size: 18),
              SizedBox(width: 8),
              Text(
                DateFormat('dd MMMM yyyy').format(DateTime.now()),
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSaldoCard() {
    String formattedSaldoKas = NumberFormat.decimalPattern().format(saldoKas);
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Saldo Kas Saat Ini',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(height: 8),
              Text(
                'Rp $formattedSaldoKas',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1F2937),
                ),
              ),
            ],
          ),
          GestureDetector(
            onTap: _isiNilaiSetor,
            child: Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Color(0xFF6366F1).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.add_circle_outline,
                color: Color(0xFF6366F1),
                size: 28,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputCard() {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Form Setor Kas',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1F2937),
            ),
          ),
          SizedBox(height: 20),
          TextField(
            controller: _ketSetorController,
            decoration: InputDecoration(
              labelText: 'Keterangan',
              labelStyle: TextStyle(color: Colors.grey[600]),
              prefixIcon:
                  Icon(Icons.note_alt_outlined, color: Color(0xFF6366F1)),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey[300]!),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Color(0xFF6366F1), width: 2),
              ),
              filled: true,
              fillColor: Colors.grey[50],
            ),
          ),
          SizedBox(height: 16),
          TextField(
            controller: _nilaiSetorController,
            decoration: InputDecoration(
              labelText: 'Nilai Setor',
              labelStyle: TextStyle(color: Colors.grey[600]),
              prefixIcon:
                  Icon(Icons.payments_outlined, color: Color(0xFF6366F1)),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey[300]!),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Color(0xFF6366F1), width: 2),
              ),
              filled: true,
              fillColor: Colors.grey[50],
            ),
            keyboardType: TextInputType.number,
          ),
          SizedBox(height: 16),
          TextField(
            controller: _nilaisisa,
            decoration: InputDecoration(
              labelText: 'Saldo yang disisakan',
              labelStyle: TextStyle(color: Colors.grey[600]),
              prefixIcon: Icon(Icons.account_balance_wallet_outlined,
                  color: Color(0xFF6366F1)),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey[300]!),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Color(0xFF6366F1), width: 2),
              ),
              filled: true,
              fillColor: Colors.grey[50],
            ),
            keyboardType: TextInputType.number,
          ),
          SizedBox(height: 24),
          if (isProsesButtonVisible)
            SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton(
                onPressed:
                    (!isInputValid || isProcessing) ? null : _prosesSetor,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF6366F1),
                  disabledBackgroundColor: Colors.grey[300],
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                  shadowColor: Colors.transparent,
                ),
                child: isProcessing
                    ? SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          color: Colors.white,
                        ),
                      )
                    : Text(
                        'Proses Setor',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildHistoryCard() {
    if (hasilApi.isEmpty) {
      return Container(
        padding: EdgeInsets.all(40),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Center(
          child: Column(
            children: [
              CircularProgressIndicator(
                color: Color(0xFF6366F1),
                strokeWidth: 3,
              ),
              SizedBox(height: 16),
              Text(
                'Memuat data terbaru...',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.history, color: Color(0xFF6366F1), size: 24),
              SizedBox(width: 12),
              Text(
                '10 Setoran Terakhir',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1F2937),
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
          SizedBox(
            height: 300,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                headingRowColor: MaterialStateProperty.all(Color(0xFFF3F4F6)),
                headingRowHeight: 48,
                dataRowHeight: 56,
                columnSpacing: 24,
                horizontalMargin: 16,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey[200]!),
                  borderRadius: BorderRadius.circular(12),
                ),
                columns: [
                  DataColumn(
                    label: Text(
                      'No Trans',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF374151),
                      ),
                    ),
                  ),
                  DataColumn(
                    label: Text(
                      'Dari',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF374151),
                      ),
                    ),
                  ),
                  DataColumn(
                    label: Text(
                      'Ket',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF374151),
                      ),
                    ),
                  ),
                  DataColumn(
                    label: Text(
                      'Nominal Setor',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF374151),
                      ),
                    ),
                  ),
                  DataColumn(
                    label: Text(
                      'Disisakan',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF374151),
                      ),
                    ),
                  ),
                  DataColumn(
                    label: Text(
                      'Waktu',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF374151),
                      ),
                    ),
                  ),
                  DataColumn(
                    label: Text(
                      'Saldo by System',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF374151),
                      ),
                    ),
                  ),
                  DataColumn(
                    label: Text(
                      'Selisih',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF374151),
                      ),
                    ),
                  ),
                ],
                rows: hasilApi.asMap().entries.map((entry) {
                  int index = entry.key;
                  Map<String, dynamic> data = entry.value;

                  try {
                    return DataRow(
                      color: MaterialStateProperty.all(
                        index % 2 == 0 ? Colors.white : Color(0xFFFAFAFA),
                      ),
                      cells: [
                        DataCell(Text(
                          data['notrans']?.toString() ?? '-',
                          style: TextStyle(color: Color(0xFF6B7280)),
                        )),
                        DataCell(Text(
                          data['dari']?.toString() ?? '-',
                          style: TextStyle(color: Color(0xFF6B7280)),
                        )),
                        DataCell(Text(
                          data['ket']?.toString() ?? '-',
                          style: TextStyle(color: Color(0xFF6B7280)),
                        )),
                        DataCell(Text(
                          NumberFormat.decimalPattern().format(
                              double.tryParse(data['nrp'].toString()) ?? 0),
                          style: TextStyle(
                            color: Color(0xFF059669),
                            fontWeight: FontWeight.w500,
                          ),
                        )),
                        DataCell(Text(
                          NumberFormat.decimalPattern().format(double.tryParse(
                                  data['nrpsaldosisa'].toString()) ??
                              0),
                          style: TextStyle(color: Color(0xFF6B7280)),
                        )),
                        DataCell(Text(
                          data['waktuinput']?.toString() ?? '-',
                          style: TextStyle(color: Color(0xFF6B7280)),
                        )),
                        DataCell(Text(
                          NumberFormat.decimalPattern().format(double.tryParse(
                                  data['nrpsaldosystem'].toString()) ??
                              0),
                          style: TextStyle(color: Color(0xFF6B7280)),
                        )),
                        DataCell(Text(
                          NumberFormat.decimalPattern().format(
                              double.tryParse(data['nrpselisih'].toString()) ??
                                  0),
                          style: TextStyle(
                            color: Color(0xFFDC2626),
                            fontWeight: FontWeight.w500,
                          ),
                        )),
                      ],
                    );
                  } catch (e) {
                    return DataRow(cells: [
                      DataCell(
                          Text('Error', style: TextStyle(color: Colors.red))),
                      DataCell(Text('')),
                      DataCell(Text('')),
                      DataCell(Text('')),
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
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF9FAFB),
      appBar: AppBar(
        title: Text(
          'Setor Kas Cabang',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        backgroundColor: Color(0xFF6366F1),
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              _buildInfoCard(),
              SizedBox(height: 20),
              _buildSaldoCard(),
              SizedBox(height: 20),
              _buildInputCard(),
              SizedBox(height: 20),
              if (hasilApi.isNotEmpty || isProcessing) _buildHistoryCard(),
            ],
          ),
        ),
      ),
    );
  }
}

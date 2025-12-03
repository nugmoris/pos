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
    final String formattedDate = DateFormat('yyyy-MM-dd').format(selectedDate);

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFFDE68A), Color(0xFFFECACA)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(formattedDate),
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(28),
                      topRight: Radius.circular(28),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 20,
                        offset: Offset(0, -8),
                      )
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        _buildFilterCard(formattedDate),
                        SizedBox(height: 16),
                        _buildStatChips(),
                        SizedBox(height: 16),
                        Expanded(child: _buildDataSection()),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(String formattedDate) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: Colors.white,
            child: Icon(Icons.account_balance_wallet_rounded,
                color: Color(0xFFB45309)),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Laporan Kas Cabang',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1F2937),
                  ),
                ),
                Text(
                  '${widget.varnmlok} • $formattedDate',
                  style: TextStyle(color: Color(0xFF6B7280)),
                ),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              widget.varpbuser,
              style: TextStyle(
                color: Color(0xFFB45309),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterCard(String formattedDate) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Color(0xFFFEF3C7),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Parameter Laporan',
            style: TextStyle(
              fontWeight: FontWeight.w700,
              color: Color(0xFF92400E),
            ),
          ),
          SizedBox(height: 12),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                GestureDetector(
                  onTap: () => _selectDate(context),
                  child: Container(
                    width: 180,
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.calendar_today_rounded,
                            size: 18, color: Color(0xFFF97316)),
                        SizedBox(width: 10),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'TANGGAL',
                              style: TextStyle(
                                fontSize: 11,
                                letterSpacing: 0.8,
                                color: Color(0xFF9CA3AF),
                              ),
                            ),
                            Text(
                              formattedDate,
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF1F2937),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(width: 12),
                Container(
                  width: 250,
                  child: DropdownButtonFormField<String>(
                    value: selectedKdgl,
                    decoration: InputDecoration(
                      labelText: 'Kode GL',
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(18),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding:
                          EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                    ),
                    isExpanded: true,
                    menuMaxHeight: 300,
                    items: kirabayarData.map<DropdownMenuItem<String>>(
                        (Map<String, dynamic> val) {
                      return DropdownMenuItem<String>(
                        value: val['kdgl'],
                        child: Text(
                          '${val['nmkira']} (${val['kdgl']})',
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        selectedKdgl = value;
                      });
                    },
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 16),
          Align(
            alignment: Alignment.centerRight,
            child: ElevatedButton.icon(
              onPressed: fetchReport,
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFFEA580C),
                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              icon: Icon(
                Icons.summarize_outlined,
                color: Colors.white,
              ),
              label: Text(
                'Tampilkan',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatChips() {
    double totalDebet = reportData.fold(
        0,
        (sum, item) =>
            sum + (double.tryParse(item['ndebet']?.toString() ?? '0') ?? 0));
    double totalKredit = reportData.fold(
        0,
        (sum, item) =>
            sum + (double.tryParse(item['nkredit']?.toString() ?? '0') ?? 0));
    double saldoAkhir = reportData.isNotEmpty
        ? double.tryParse(reportData.last['saldo']?.toString() ?? '0') ?? 0
        : 0;

    Widget buildChip(String label, double value, Color color) {
      return Expanded(
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          margin: EdgeInsets.only(right: 12),
          decoration: BoxDecoration(
            color: color.withOpacity(0.12),
            borderRadius: BorderRadius.circular(18),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: color,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 4),
              Text(
                'Rp ${formatNumber(value.toString())}',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF111827),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Row(
      children: [
        buildChip('Total Debet', totalDebet, Color(0xFF047857)),
        buildChip('Total Kredit', totalKredit, Color(0xFFB91C1C)),
        buildChip('Saldo Akhir', saldoAkhir, Color(0xFF4338CA)),
      ],
    );
  }

  Widget _buildDataSection() {
    if (isLoading) {
      return Center(child: CircularProgressIndicator());
    }

    if (reportData.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.receipt_long_outlined,
                size: 56, color: Color(0xFFFCD34D)),
            SizedBox(height: 12),
            Text(
              'Belum ada data untuk parameter ini',
              style: TextStyle(
                color: Color(0xFF6B7280),
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Color(0xFFE5E7EB)),
        borderRadius: BorderRadius.circular(24),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: SingleChildScrollView(
            child: DataTable(
              headingRowColor: MaterialStateProperty.all(Color(0xFFF3F4F6)),
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
    );
  }
}

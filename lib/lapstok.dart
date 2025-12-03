import 'package:flutter/material.dart';

import 'service.dart';

class LapStok extends StatefulWidget {
  final String varpbuser;
  final String varbagian;
  final String varlks;
  final String varnmlok;
  LapStok(this.varpbuser, this.varbagian, this.varlks, this.varnmlok);

  @override
  State<LapStok> createState() => _LapStokState();
}

class _LapStokState extends State<LapStok> {
  String? selectedJenis;
  TextEditingController cariController = TextEditingController();
  List<Map<String, dynamic>> jenisBarangList = [];
  List<Map<String, dynamic>> lapstokList = [];
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchJenisBarang();
  }

  Future<void> _fetchJenisBarang() async {
    try {
      final List<Map<String, dynamic>> data =
          await ApiService.jenisbarang(widget.varpbuser);
      setState(() {
        jenisBarangList = data;
      });
    } catch (e) {
      print('Error fetching jenis barang: $e');
    }
  }

  Future<void> _fetchLapStok() async {
    setState(() {
      isLoading = true;
    });
    try {
      final kondisi = cariController.text.isEmpty ? '1' : '2';
      final List<Map<String, dynamic>> data = await ApiService.lapstok(
        widget.varpbuser,
        widget.varlks,
        selectedJenis ?? '00',
        cariController.text,
        kondisi,
      );
      setState(() {
        lapstokList = data;
        isLoading = false;
      });
    } catch (e) {
      print('Error fetching lap stok: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFE0EAFC), Color(0xFFCFDEF3)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(),
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
                        _buildFilterCard(),
                        SizedBox(height: 16),
                        _buildInfoRow(),
                        SizedBox(height: 16),
                        Expanded(child: _buildResultTable()),
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

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: Colors.white,
            child: Icon(Icons.inventory_2_rounded, color: Color(0xFF2563EB)),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Laporan Stok',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1F2937),
                  ),
                ),
                Text(
                  widget.varnmlok,
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
                color: Color(0xFF2563EB),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterCard() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Filter Data',
            style: TextStyle(
              fontWeight: FontWeight.w700,
              color: Color(0xFF0F172A),
            ),
          ),
          SizedBox(height: 12),
          DropdownButtonFormField<String>(
            value: selectedJenis,
            decoration: InputDecoration(
              labelText: 'Jenis Barang',
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(18),
                borderSide: BorderSide.none,
              ),
            ),
            items: jenisBarangList.map((item) {
              return DropdownMenuItem<String>(
                value: item['kode'],
                child: Text(item['nama']),
              );
            }).toList(),
            onChanged: (value) {
              setState(() {
                selectedJenis = value;
              });
            },
          ),
          SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: cariController,
                  decoration: InputDecoration(
                    hintText: 'Cari nama / kode barang...',
                    prefixIcon: Icon(Icons.search, color: Color(0xFF94A3B8)),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(18),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),
              SizedBox(width: 12),
              ElevatedButton(
                onPressed: _fetchLapStok,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF2563EB),
                  padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                ),
                child: Text(
                  'Tampilkan',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow() {
    final totalItems = lapstokList.length;
    final totalQty = lapstokList.fold<int>(
        0, (sum, item) => sum + (int.tryParse(item['nqty'].toString()) ?? 0));

    Widget infoCard(String label, String value, IconData icon, Color color) {
      return Expanded(
        child: Container(
          padding: EdgeInsets.all(16),
          margin: EdgeInsets.only(right: 12),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(18),
          ),
          child: Row(
            children: [
              CircleAvatar(
                backgroundColor: Colors.white,
                foregroundColor: color,
                child: Icon(icon),
              ),
              SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      color: color,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    value,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    }

    return Row(
      children: [
        infoCard(
            'Total Item', '$totalItems', Icons.list_alt, Color(0xFF0EA5E9)),
        infoCard(
            'Total Qty', '$totalQty', Icons.numbers_rounded, Color(0xFF22C55E)),
      ],
    );
  }

  Widget _buildResultTable() {
    if (isLoading) {
      return Center(child: CircularProgressIndicator());
    }

    if (lapstokList.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inventory_outlined, size: 56, color: Color(0xFF93C5FD)),
            SizedBox(height: 12),
            Text(
              'Belum ada data stok',
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
        border: Border.all(color: Color(0xFFE2E8F0)),
        borderRadius: BorderRadius.circular(24),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: SingleChildScrollView(
            child: DataTable(
              headingRowColor: MaterialStateProperty.all(Color(0xFFF8FAFC)),
              columns: const [
                DataColumn(label: Text('Jenis Barang')),
                DataColumn(label: Text('Nama Barang')),
                DataColumn(label: Text('Qty')),
              ],
              rows: lapstokList.map((item) {
                return DataRow(cells: [
                  DataCell(Text(item['nmjenis'] ?? '')),
                  DataCell(SizedBox(
                      width: 200,
                      child: Text(item['nama'] ?? '',
                          overflow: TextOverflow.ellipsis))),
                  DataCell(Text(item['nqty'] ?? '')),
                ]);
              }).toList(),
            ),
          ),
        ),
      ),
    );
  }
}

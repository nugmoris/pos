import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'service.dart';

class DaftarHarga extends StatefulWidget {
  final String varpbuser;
  final String varbagian;
  final String varlks;
  final String varnmlok;
  DaftarHarga(this.varpbuser, this.varbagian, this.varlks, this.varnmlok);

  @override
  State<DaftarHarga> createState() => _DaftarHargaState();
}

class _DaftarHargaState extends State<DaftarHarga> {
  String? selectedJenis;
  TextEditingController cariController = TextEditingController();
  List<Map<String, dynamic>> jenisBarangList = [];
  List<Map<String, dynamic>> DaftarHargaList = [];
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

  Future<void> _fetchDaftarHarga() async {
    setState(() {
      isLoading = true;
    });
    try {
      final kondisi = cariController.text.isEmpty ? '1' : '2';
      final List<Map<String, dynamic>> data = await ApiService.daftarharga(
        widget.varpbuser,
        widget.varlks,
        selectedJenis ?? '00',
        cariController.text,
        kondisi,
      );
      setState(() {
        DaftarHargaList = data;
        isLoading = false;
      });
    } catch (e) {
      print('Error fetching daftar harga: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  String formatCurrency(dynamic amount) {
    final formatter = NumberFormat('#,##0', 'en_US');
    if (amount is String) {
      amount = int.tryParse(amount) ?? 0;
    }
    return formatter.format(amount);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFEEF2FF), Color(0xFFE0EAFC)],
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
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      children: [
                        _buildFilterCard(),
                        SizedBox(height: 20),
                        Expanded(child: _buildResultArea()),
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
            child: Icon(Icons.local_offer_rounded, color: Color(0xFF4C1D95)),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Daftar Harga',
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
                color: Color(0xFF4338CA),
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
        color: Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Color(0xFFE5E7EB)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Filter Data',
            style: TextStyle(
              fontWeight: FontWeight.w700,
              color: Color(0xFF111827),
            ),
          ),
          SizedBox(height: 16),
          DropdownButtonFormField<String>(
            initialValue: selectedJenis,
            decoration: InputDecoration(
              labelText: 'Jenis Barang',
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
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
          SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: cariController,
                  decoration: InputDecoration(
                    hintText: 'Cari nama barang...',
                    prefixIcon: Icon(Icons.search, color: Color(0xFF9CA3AF)),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),
              SizedBox(width: 12),
              ElevatedButton(
                onPressed: _fetchDaftarHarga,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF4338CA),
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: Text(
                  'Tampilkan',
                  style: TextStyle(
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildResultArea() {
    if (isLoading) {
      return Center(child: CircularProgressIndicator());
    }

    if (DaftarHargaList.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inventory_2_outlined,
                size: 56, color: Color(0xFFCBD5F5)),
            SizedBox(height: 12),
            Text(
              'Belum ada data',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: Color(0xFF6B7280),
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Color(0xFFE5E7EB)),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: SingleChildScrollView(
            child: DataTable(
              headingRowColor: WidgetStateProperty.all(Color(0xFFF3F4F6)),
              columnSpacing: 32,
              columns: const [
                DataColumn(label: Text('Jenis Barang')),
                DataColumn(label: Text('Nama Barang')),
                DataColumn(label: Text('Harga')),
              ],
              rows: DaftarHargaList.map((item) {
                return DataRow(cells: [
                  DataCell(Text(item['nmjenis'] ?? '')),
                  DataCell(
                    SizedBox(
                      width: 180,
                      child: Text(
                        item['nama'] ?? '',
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                  DataCell(
                    Text(
                      'Rp ${formatCurrency(item['nhargajual'] ?? 0)}',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                ]);
              }).toList(),
            ),
          ),
        ),
      ),
    );
  }
}

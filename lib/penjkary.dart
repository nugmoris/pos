import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import 'customer_search_popup.dart';
import 'item_search_popup.dart';
import 'service.dart';

class Penjkary extends StatefulWidget {
  final String varpbuser;
  final String varbagian;
  final String varlks;
  final String varnmlok;

  Penjkary(this.varpbuser, this.varbagian, this.varlks, this.varnmlok);

  @override
  State<Penjkary> createState() => _PenjkaryState();
}

class _PenjkaryState extends State<Penjkary> {
  TextEditingController tgl1Controller = TextEditingController();
  TextEditingController tgl2Controller = TextEditingController();
  TextEditingController kodeCustomerController = TextEditingController();
  TextEditingController namaCustomerController = TextEditingController();
  TextEditingController kodeBarangController = TextEditingController();
  TextEditingController namaBarangController = TextEditingController();

  bool semuaKaryawan = true;
  bool semuaBarang = true;
  bool isLoading = false;

  List<Map<String, dynamic>> laporanPenjualan = [];
  double grandTotal = 0.0;

  @override
  void initState() {
    super.initState();
    tgl1Controller.text = DateFormat('yyyy-MM-dd').format(DateTime.now());
    tgl2Controller.text = DateFormat('yyyy-MM-dd').format(DateTime.now());
  }

  void _prosesLaporan() async {
    setState(() {
      isLoading = true;
    });

    try {
      String tgl1 = tgl1Controller.text;
      String tgl2 = tgl2Controller.text;
      String kdcust = kodeCustomerController.text;
      String kdbarang = kodeBarangController.text;

      String kondisi1 = semuaKaryawan ? "1" : "2";
      String kondisi2 = semuaBarang ? "1" : "2";

      List<Map<String, dynamic>> result = await ApiService.lapjualkary(
        widget.varpbuser,
        widget.varlks,
        tgl1,
        tgl2,
        kdcust,
        kondisi1,
        kondisi2,
        kdbarang,
      );

      setState(() {
        laporanPenjualan = result;
        grandTotal = result.fold(
            0.0, (sum, item) => sum + double.parse(item['subtotal']));
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Color(0xFF1A1A1A)),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Penjualan Karyawan',
              style: GoogleFonts.plusJakartaSans(
                color: Color(0xFF1A1A1A),
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              widget.varnmlok,
              style: GoogleFonts.plusJakartaSans(
                color: Color(0xFF6B7280),
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          // Filter Section
          Container(
            color: Colors.white,
            padding: EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Date Range
                Row(
                  children: [
                    Expanded(
                      child: _buildDateField(
                        controller: tgl1Controller,
                        label: 'Tanggal Awal',
                        icon: Icons.calendar_today,
                      ),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: _buildDateField(
                        controller: tgl2Controller,
                        label: 'Tanggal Akhir',
                        icon: Icons.event,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16),

                // Karyawan Filter
                _buildFilterSection(
                  title: 'Karyawan',
                  isChecked: semuaKaryawan,
                  onCheckChanged: (value) {
                    setState(() {
                      semuaKaryawan = value ?? false;
                      namaCustomerController.text = "";
                      kodeCustomerController.text = "";
                    });
                  },
                  controller: namaCustomerController,
                  onSearchPressed: semuaKaryawan
                      ? null
                      : () async {
                          await showDialog(
                            context: context,
                            builder: (context) {
                              return CustomerSearchPopup(
                                varpbuser: widget.varpbuser,
                                onCustomerSelected: (kode, nama) {
                                  setState(() {
                                    kodeCustomerController.text = kode;
                                    namaCustomerController.text = nama;
                                  });
                                },
                              );
                            },
                          );
                        },
                ),
                SizedBox(height: 16),

                // Barang Filter
                _buildFilterSection(
                  title: 'Barang',
                  isChecked: semuaBarang,
                  onCheckChanged: (value) {
                    setState(() {
                      semuaBarang = value ?? false;
                      namaBarangController.text = '';
                      kodeBarangController.text = '';
                    });
                  },
                  controller: namaBarangController,
                  onSearchPressed: semuaBarang
                      ? null
                      : () async {
                          await showDialog(
                            context: context,
                            builder: (context) {
                              return ItemSearchPopup(
                                varpbuser: widget.varpbuser,
                                onItemSelected: (kode,
                                    nama,
                                    harga,
                                    lmatang,
                                    nhargamatang,
                                    kodebarcode,
                                    ndpp,
                                    nppn,
                                    ndppmatang,
                                    nppnmatang) {
                                  setState(() {
                                    kodeBarangController.text = kode;
                                    namaBarangController.text = nama;
                                  });
                                },
                              );
                            },
                          );
                        },
                ),
                SizedBox(height: 20),

                // Process Button
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: isLoading ? null : _prosesLaporan,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF3B82F6),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    child: isLoading
                        ? SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.assessment,
                                size: 20,
                                color: Colors.white,
                              ),
                              SizedBox(width: 8),
                              Text(
                                'Proses Laporan',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                  ),
                ),
              ],
            ),
          ),

          // Results Section
          Expanded(
            child: laporanPenjualan.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.description_outlined,
                          size: 80,
                          color: Color(0xFFD1D5DB),
                        ),
                        SizedBox(height: 16),
                        Text(
                          'Belum ada data',
                          style: GoogleFonts.plusJakartaSans(
                            color: Color(0xFF6B7280),
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Klik "Proses Laporan" untuk menampilkan data',
                          style: GoogleFonts.plusJakartaSans(
                            color: Color(0xFF9CA3AF),
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  )
                : Column(
                    children: [
                      // Grand Total Card
                      Container(
                        margin: EdgeInsets.all(16),
                        padding: EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Color(0xFF10B981), Color(0xFF059669)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Color(0xFF10B981).withOpacity(0.3),
                              blurRadius: 12,
                              offset: Offset(0, 6),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(
                                Icons.monetization_on,
                                color: Colors.white,
                                size: 24,
                              ),
                            ),
                            SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Grand Total',
                                    style: GoogleFonts.plusJakartaSans(
                                      color: Colors.white.withOpacity(0.9),
                                      fontSize: 13,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  SizedBox(height: 4),
                                  Text(
                                    'Rp ${NumberFormat.currency(locale: 'id', symbol: '', decimalDigits: 0).format(grandTotal)}',
                                    style: GoogleFonts.plusJakartaSans(
                                      color: Colors.white,
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: -0.5,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Data Table
                      Expanded(
                        child: Container(
                          margin: EdgeInsets.symmetric(horizontal: 16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Color(0xFF1A1A1A).withOpacity(0.04),
                                blurRadius: 10,
                                offset: Offset(0, 4),
                              ),
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(16),
                            child: SingleChildScrollView(
                              scrollDirection: Axis.vertical,
                              child: SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: DataTable(
                                  headingRowColor: MaterialStateProperty.all(
                                      Color(0xFFF3F4F6)),
                                  headingTextStyle: GoogleFonts.plusJakartaSans(
                                    color: Color(0xFF1A1A1A),
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  dataTextStyle: GoogleFonts.plusJakartaSans(
                                    color: Color(0xFF374151),
                                    fontSize: 13,
                                  ),
                                  columns: [
                                    DataColumn(label: Text('No Trans')),
                                    DataColumn(label: Text('Tanggal')),
                                    DataColumn(label: Text('Customer')),
                                    DataColumn(label: Text('Nama Barang')),
                                    DataColumn(label: Text('Qty')),
                                    DataColumn(label: Text('Harga')),
                                    DataColumn(label: Text('Subtotal')),
                                  ],
                                  rows: laporanPenjualan.map((data) {
                                    return DataRow(
                                      cells: [
                                        DataCell(Text(data['notrans'])),
                                        DataCell(Text(data['tgl'])),
                                        DataCell(
                                          Container(
                                            constraints:
                                                BoxConstraints(maxWidth: 150),
                                            child: Text(
                                              data['nmcust'],
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        ),
                                        DataCell(
                                          Container(
                                            constraints:
                                                BoxConstraints(maxWidth: 200),
                                            child: Text(
                                              data['nmbarang'],
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        ),
                                        DataCell(Text(data['nqty'])),
                                        DataCell(
                                          Text(
                                            NumberFormat.currency(
                                              locale: 'id',
                                              symbol: '',
                                              decimalDigits: 0,
                                            ).format(int.parse(data['nrp'])),
                                          ),
                                        ),
                                        DataCell(
                                          Text(
                                            NumberFormat.currency(
                                              locale: 'id',
                                              symbol: '',
                                              decimalDigits: 0,
                                            ).format(
                                                int.parse(data['subtotal'])),
                                            style: GoogleFonts.plusJakartaSans(
                                              fontWeight: FontWeight.w600,
                                              color: Color(0xFF10B981),
                                            ),
                                          ),
                                        ),
                                      ],
                                    );
                                  }).toList(),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 16),
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
  }) {
    return GestureDetector(
      onTap: () async {
        DateTime? picked = await showDatePicker(
          context: context,
          initialDate: DateTime.now(),
          firstDate: DateTime(2000),
          lastDate: DateTime(2101),
          builder: (context, child) {
            return Theme(
              data: Theme.of(context).copyWith(
                colorScheme: ColorScheme.light(
                  primary: Color(0xFF3B82F6),
                ),
              ),
              child: child!,
            );
          },
        );
        if (picked != null) {
          setState(() {
            controller.text = DateFormat('yyyy-MM-dd').format(picked);
          });
        }
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Color(0xFFF3F4F6),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(icon, color: Color(0xFF3B82F6), size: 20),
            SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: GoogleFonts.plusJakartaSans(
                      color: Color(0xFF6B7280),
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(height: 2),
                  Text(
                    controller.text,
                    style: GoogleFonts.plusJakartaSans(
                      color: Color(0xFF1A1A1A),
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterSection({
    required String title,
    required bool isChecked,
    required Function(bool?) onCheckChanged,
    required TextEditingController controller,
    required VoidCallback? onSearchPressed,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            SizedBox(
              height: 24,
              width: 24,
              child: Checkbox(
                value: isChecked,
                onChanged: onCheckChanged,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4),
                ),
                activeColor: Color(0xFF3B82F6),
              ),
            ),
            SizedBox(width: 8),
            Text(
              'Semua $title',
              style: GoogleFonts.plusJakartaSans(
                color: Color(0xFF1A1A1A),
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        SizedBox(height: 8),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          decoration: BoxDecoration(
            color: Color(0xFFF3F4F6),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: controller,
                  readOnly: true,
                  decoration: InputDecoration(
                    hintText: isChecked ? 'Semua $title' : 'Pilih $title',
                    hintStyle: GoogleFonts.plusJakartaSans(
                      color: Color(0xFF9CA3AF),
                      fontSize: 14,
                    ),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(vertical: 12),
                  ),
                  style: GoogleFonts.plusJakartaSans(
                    color: Color(0xFF1A1A1A),
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              IconButton(
                icon: Icon(
                  Icons.search,
                  color: isChecked ? Color(0xFFD1D5DB) : Color(0xFF3B82F6),
                ),
                onPressed: onSearchPressed,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pos/carijual.dart';

import 'bayarjual.dart';
import 'search_popup.dart';
import 'service.dart';

class ReturJualPage extends StatefulWidget {
  final String varpbuser;
  final String varbagian;
  final String varlks;
  final String varnmlok;
  final String varsaldokas;

  ReturJualPage(this.varpbuser, this.varbagian, this.varlks, this.varnmlok,
      this.varsaldokas);

  @override
  _ReturJualPageState createState() => _ReturJualPageState();
}

class _ReturJualPageState extends State<ReturJualPage> {
  TextEditingController notransController =
      TextEditingController(text: 'RJL-Baru');
  TextEditingController nqtyreturController = TextEditingController();
  TextEditingController nrpreturController = TextEditingController();
  TextEditingController keteranganController = TextEditingController();
  TextEditingController nqtyjualController = TextEditingController();
  TextEditingController nrpjualController = TextEditingController();
  TextEditingController nsubttljualController = TextEditingController();
  TextEditingController tglreturcontroller = TextEditingController();
  TextEditingController totbayarku = TextEditingController();
  String varsaldokas = '0';
  String nojual = '';
  String nmcustomer = '';
  String tgljual = '';
  String kdbarang = '';
  String nmbarang = '';
  String nqtyjual = '';
  String nrpjual = '';
  String nsubtotal = '';
  String nsubtotalret = '';
  String nbayar = '';
  final NumberFormat currencyFormat = NumberFormat("#,##0", "en_US");
  double totbayar = 0.0;
  double saldokasku = 0.0;
  List<Map<String, dynamic>> transaksiData = [];

  void initState() {
    super.initState();
    totbayarku.text = '0';
    saldokasku = double.tryParse(widget.varsaldokas.replaceAll(',', '')) ?? 0.0;
  }

  void showPaymentDialog() async {
    String grandTotal = calculateGrandTotal();
    int totbayarInt = int.tryParse(totbayarku.text) ?? 0;

    final paymentValue = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return PaymentDialog(
          asal: 'retur',
          notrans: notransController.text,
          grandTotal: grandTotal,
          totbayar: currencyFormat.format(totbayarInt),
          username: widget.varpbuser,
          varlks: widget.varlks,
          vartotalbyr: currencyFormat.format(totbayarInt),
          onPaymentSuccess: (updatedVarsaldokas, updatedVartotalbyr) {
            setState(() {
              varsaldokas = updatedVarsaldokas;
              totbayarku.text = updatedVartotalbyr;
              print('totbayar = $updatedVartotalbyr');
            });
          },
        );
      },
    );

    if (paymentValue != null) {
      setState(() {
        double bayar = double.tryParse(paymentValue) ?? 0.0;
        String totbayarString = totbayar.toString();
        double currentTotbayar =
            double.tryParse(totbayarString.replaceAll(',', '')) ?? 0.0;
        currentTotbayar = bayar;
        final formatter = NumberFormat("#,###");
        totbayar = currentTotbayar;
      });
    }
  }

  void openSearchPopup() {
    showDialog(
      context: context,
      builder: (context) {
        return SearchPopup(
          varpbuser: widget.varpbuser,
          varlks: widget.varlks,
          onItemSelected: (notrans, nbayar) {
            onItemSelected(notrans, nbayar);
          },
        );
      },
    );
  }

  void onItemSelected(String notrans, String nbayar) async {
    try {
      List<Map<String, dynamic>> result = await ApiService.cariretjual(
        widget.varpbuser,
        widget.varlks,
        '3',
        notrans,
      );

      if (result.isNotEmpty) {
        setState(() {
          notransController.text = result[0]['notrans'] ?? '';
          totbayarku.text = nbayar;
          transaksiData = result
              .map((item) => {
                    'kdbarang': item['kdbarang'],
                    'nmbarang': item['nmbarang'],
                    'nrpretur': item['nrpretur'],
                    'nqtyretur': item['nqtyretur'],
                    'nsubtotal': item['nsubtotal'],
                    'llunas': item['llunas'],
                    'notrans': item['notrans'],
                    'nojual': item['nojual'],
                    'nsubttl': item['nsubttl'],
                  })
              .toList();
        });
      }
    } catch (e) {
      print('Error fetching transaction details: $e');
    }
  }

  void updateNotrans() {
    setState(() {
      notransController.text = 'RJL-Baru';
      nojual = '';
      nmcustomer = '';
      tgljual = '';
      kdbarang = '';
      nmbarang = '';
      nqtyjual = '';
      nrpjual = '';
      nsubtotal = '';
      nqtyreturController.clear();
      nrpreturController.clear();
      nqtyjualController.clear();
      nrpjualController.clear();
      nsubttljualController.clear();
      nsubtotalret = '';
      keteranganController.clear();
      transaksiData.clear();
      tglreturcontroller.clear();
    });
  }

  void calculateSubtotalRetur() {
    setState(() {
      double nqtyretur = double.tryParse(nqtyreturController.text) ?? 0;
      double nrpretur = double.tryParse(nrpreturController.text) ?? 0;
      nsubtotalret = (nqtyretur * nrpretur).toStringAsFixed(2);
    });
  }

  Future<void> searchTransaction() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => CarijualPage(widget.varpbuser)),
    );
    print('void searchTransaction');
    if (result != null) {
      setState(() {
        nojual = result['notrans'] ?? '';
        nmcustomer = result['nmcust'] ?? '';
        tgljual = result['tgljual']?.toString() ?? '';
        kdbarang = result['kdbarang'] ?? '';
        nmbarang = result['nmbarang'] ?? '';
        nqtyjual = result['nqty']?.toString() ?? '';
        final formatter = NumberFormat("#,###");
        nrpjualController.text = formatter.format(int.parse(result['nrp']));
        nqtyjualController.text = result['nqty'];

        nsubttljualController.text =
            formatter.format(int.parse(result['subttl']));
        nrpjual = result['nrp']?.toString() ?? '';
        nsubtotal = result['subttl']?.toString() ?? '';

        calculateGrandTotal();
      });
    }
  }

  Future<void> addRetur() async {
    if (nqtyreturController.text.isEmpty) {
      nqtyreturController.text = '0';
    }
    if (nrpreturController.text.isEmpty) {
      nrpreturController.text = '0';
    }

    final response = await ApiService.returjual(
      notransController.text,
      widget.varlks,
      kdbarang,
      nqtyreturController.text,
      nrpreturController.text,
      nojual,
      keteranganController.text,
      widget.varpbuser,
    );

    setState(() {
      if (response.isNotEmpty) {
        notransController.text = response.first['notrans'] ?? 'RJL-Baru';
        transaksiData.clear();
        transaksiData.addAll(response);
        kdbarang = '';
        nmbarang = '';
        nqtyjual = '';
        nrpjual = '';
        nsubtotal = '';
        keteranganController.clear();
        nqtyjualController.clear();
        nrpjualController.clear();
        nsubttljualController.clear();
        nqtyreturController.clear();
        nrpreturController.clear();
        nsubttljualController.clear();
        tglreturcontroller.clear();
        nsubtotalret = '';
        calculateGrandTotal();
      }
    });
  }

  String calculateGrandTotal() {
    final formatter = NumberFormat("#,###", "id_ID");

    int total = transaksiData.fold(0, (sum, detail) {
      int subtotal = int.tryParse(detail['nsubttl'].toString()) ?? 0;
      return sum + subtotal;
    });

    return formatter.format(total);
  }

  Widget _buildModernTextField({
    required TextEditingController controller,
    required String label,
    bool readOnly = false,
    TextInputType? keyboardType,
    Function(String)? onChanged,
    IconData? prefixIcon,
    Color? textColor,
    FontWeight? fontWeight,
  }) {
    return TextField(
      controller: controller,
      readOnly: readOnly,
      keyboardType: keyboardType,
      onChanged: onChanged,
      style: TextStyle(
        color: textColor ?? Color(0xFF1F2937),
        fontWeight: fontWeight ?? FontWeight.normal,
        fontSize: 14,
      ),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(
          color: Colors.grey[600],
          fontSize: 14,
        ),
        prefixIcon: prefixIcon != null
            ? Icon(prefixIcon, color: Color(0xFF6366F1), size: 20)
            : null,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Color(0xFF6366F1), width: 2),
        ),
        filled: true,
        fillColor: readOnly ? Colors.grey[50] : Colors.white,
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required VoidCallback onPressed,
    required Color color,
    String? tooltip,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: IconButton(
        icon: Icon(icon, color: color),
        onPressed: onPressed,
        tooltip: tooltip,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF9FAFB),
      appBar: AppBar(
        title: Text(
          'Retur Penjualan',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        backgroundColor: Color(0xFFEF4444),
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Card Header Transaksi
                Container(
                  padding: EdgeInsets.all(16),
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
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: _buildModernTextField(
                              controller: notransController,
                              label: 'No. Transaksi',
                              readOnly: true,
                              prefixIcon: Icons.receipt_long,
                              textColor: Color(0xFFEF4444),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(width: 12),
                          Expanded(
                            child: _buildModernTextField(
                              controller: tglreturcontroller,
                              label: 'Tanggal Retur',
                              readOnly: true,
                              prefixIcon: Icons.calendar_today,
                              textColor: Color(0xFF6366F1),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(width: 8),
                          _buildActionButton(
                            icon: Icons.refresh,
                            onPressed: updateNotrans,
                            color: Color(0xFF10B981),
                            tooltip: 'Reset',
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 16),

                // Card Info Penjualan
                Container(
                  padding: EdgeInsets.all(16),
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
                          _buildActionButton(
                            icon: Icons.search,
                            onPressed: searchTransaction,
                            color: Color(0xFF6366F1),
                            tooltip: 'Cari Transaksi',
                          ),
                          SizedBox(width: 12),
                          Text(
                            'No. Jual: ',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                          ),
                          Text(
                            nojual,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1F2937),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 12),
                      if (nmcustomer.isNotEmpty)
                        Container(
                          padding: EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Color(0xFFF3F4F6),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.person_outline,
                                  size: 18, color: Colors.grey[700]),
                              SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  '$nmcustomer - $tgljual',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Color(0xFF374151),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      if (kdbarang.isNotEmpty) ...[
                        SizedBox(height: 12),
                        Container(
                          padding: EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Color(0xFF6366F1).withOpacity(0.1),
                                Color(0xFF8B5CF6).withOpacity(0.1)
                              ],
                            ),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.inventory_2_outlined,
                                  size: 18, color: Color(0xFF6366F1)),
                              SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  '$kdbarang - $nmbarang',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF6366F1),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                      SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            flex: 3,
                            child: _buildModernTextField(
                              controller: nrpjualController,
                              label: 'Harga Jual',
                              readOnly: true,
                              textColor: Color(0xFF6366F1),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(width: 8),
                          Expanded(
                            flex: 1,
                            child: _buildModernTextField(
                              controller: nqtyjualController,
                              label: 'QTY',
                              readOnly: true,
                              textColor: Color(0xFF6366F1),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(width: 8),
                          Expanded(
                            flex: 3,
                            child: _buildModernTextField(
                              controller: nsubttljualController,
                              label: 'Sub Total',
                              readOnly: true,
                              textColor: Color(0xFF6366F1),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 16),

                // Card Input Retur
                Container(
                  padding: EdgeInsets.all(16),
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
                        'Form Retur',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1F2937),
                        ),
                      ),
                      SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: _buildModernTextField(
                              controller: nqtyreturController,
                              label: 'Qty Retur',
                              keyboardType: TextInputType.number,
                              onChanged: (value) => calculateSubtotalRetur(),
                              prefixIcon: Icons.shopping_cart_outlined,
                            ),
                          ),
                          SizedBox(width: 12),
                          Expanded(
                            child: _buildModernTextField(
                              controller: nrpreturController,
                              label: 'Harga Retur',
                              keyboardType: TextInputType.number,
                              onChanged: (value) => calculateSubtotalRetur(),
                              prefixIcon: Icons.payments_outlined,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 12),
                      Container(
                        padding: EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Color(0xFFFEF3C7),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Color(0xFFF59E0B)),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Subtotal Retur:',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF92400E),
                              ),
                            ),
                            Text(
                              nsubtotalret,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF92400E),
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 16),
                      _buildModernTextField(
                        controller: keteranganController,
                        label: 'Keterangan',
                        prefixIcon: Icons.note_alt_outlined,
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 16),

                // Card Summary & Actions
                Container(
                  padding: EdgeInsets.all(16),
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
                    children: [
                      Container(
                        padding: EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Color(0xFFEF4444), Color(0xFFDC2626)],
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Grand Total:',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                            Text(
                              calculateGrandTotal(),
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: _buildModernTextField(
                              controller: totbayarku,
                              label: 'Total Bayar',
                              prefixIcon: Icons.account_balance_wallet,
                            ),
                          ),
                          SizedBox(width: 12),
                          _buildActionButton(
                            icon: Icons.add_circle,
                            onPressed: addRetur,
                            color: Color(0xFF10B981),
                            tooltip: 'Tambah',
                          ),
                          SizedBox(width: 8),
                          _buildActionButton(
                            icon: Icons.search,
                            onPressed: openSearchPopup,
                            color: Color(0xFF6366F1),
                            tooltip: 'Cari',
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 16),

                // Card Data Table
                if (transaksiData.isNotEmpty)
                  Container(
                    padding: EdgeInsets.all(16),
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
                            Icon(Icons.list_alt,
                                color: Color(0xFFEF4444), size: 24),
                            SizedBox(width: 12),
                            Text(
                              'Daftar Retur',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF1F2937),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 16),
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: DataTable(
                            headingRowColor:
                                WidgetStateProperty.all(Color(0xFFF3F4F6)),
                            headingRowHeight: 48,
                            dataRowHeight: 56,
                            columnSpacing: 16,
                            horizontalMargin: 12,
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey[200]!),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            columns: [
                              DataColumn(
                                label: Text(
                                  'Kode Barang',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF374151),
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                              DataColumn(
                                label: Text(
                                  'Nama Barang',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF374151),
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                              DataColumn(
                                label: Text(
                                  'Qty Retur',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF374151),
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                              DataColumn(
                                label: Text(
                                  'Harga Retur',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF374151),
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                              DataColumn(
                                label: Text(
                                  'Subtotal',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF374151),
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                              DataColumn(
                                label: Text(
                                  'No. Transaksi',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF374151),
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                              DataColumn(
                                label: Text(
                                  'No. Penjualan',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF374151),
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                            ],
                            rows: transaksiData.asMap().entries.map((entry) {
                              int index = entry.key;
                              Map<String, dynamic> detail = entry.value;

                              return DataRow(
                                color: WidgetStateProperty.all(
                                  index % 2 == 0
                                      ? Colors.white
                                      : Color(0xFFFAFAFA),
                                ),
                                cells: [
                                  DataCell(Text(
                                    detail['kdbarang'] ?? '',
                                    style: TextStyle(
                                      color: Color(0xFF6B7280),
                                      fontSize: 13,
                                    ),
                                  )),
                                  DataCell(Text(
                                    detail['nmbarang'] ?? '',
                                    style: TextStyle(
                                      color: Color(0xFF6B7280),
                                      fontSize: 13,
                                    ),
                                  )),
                                  DataCell(Text(
                                    detail['nqtyretur'].toString() ?? '',
                                    style: TextStyle(
                                      color: Color(0xFF059669),
                                      fontWeight: FontWeight.w500,
                                      fontSize: 13,
                                    ),
                                  )),
                                  DataCell(Text(
                                    detail['nrpretur'].toString() ?? '',
                                    style: TextStyle(
                                      color: Color(0xFF6B7280),
                                      fontSize: 13,
                                    ),
                                  )),
                                  DataCell(Text(
                                    detail['nsubtotal'].toString() ?? '',
                                    style: TextStyle(
                                      color: Color(0xFFEF4444),
                                      fontWeight: FontWeight.w600,
                                      fontSize: 13,
                                    ),
                                  )),
                                  DataCell(Text(
                                    detail['notrans'] ?? '',
                                    style: TextStyle(
                                      color: Color(0xFF6B7280),
                                      fontSize: 13,
                                    ),
                                  )),
                                  DataCell(Text(
                                    detail['nojual'] ?? '',
                                    style: TextStyle(
                                      color: Color(0xFF6B7280),
                                      fontSize: 13,
                                    ),
                                  )),
                                ],
                              );
                            }).toList(),
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

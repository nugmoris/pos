import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import 'service.dart';
import 'var_provider.dart';

class PaymentDialog extends ConsumerStatefulWidget {
  final String notrans;
  final String grandTotal;
  final String totbayar;
  final String username;
  final String varlks;
  final String vartotalbyr;
  final String asal;
  final void Function(String, String) onPaymentSuccess;

  PaymentDialog({
    required this.asal,
    required this.notrans,
    required this.grandTotal,
    required this.totbayar,
    required this.username,
    required this.varlks,
    required this.vartotalbyr,
    required this.onPaymentSuccess,
  });

  @override
  _PaymentDialogState createState() => _PaymentDialogState();
}

class _PaymentDialogState extends ConsumerState<PaymentDialog> {
  TextEditingController jmluangController = TextEditingController();
  TextEditingController kembaliController = TextEditingController();
  TextEditingController paymentController = TextEditingController();
  bool isProcessing = false;
  List<Map<String, dynamic>> kirabayarData = [];
  String? selectedKira;
  String? selectedKdgl;
  final NumberFormat formatter = NumberFormat("#,###", "id_ID");

  @override
  void initState() {
    super.initState();
    _fetchKirabayarData();
    jmluangController.addListener(_updatePaymentFields);
  }

  @override
  void dispose() {
    jmluangController.removeListener(_updatePaymentFields);
    jmluangController.dispose();
    kembaliController.dispose();
    paymentController.dispose();
    super.dispose();
  }

  Future<void> _fetchKirabayarData() async {
    try {
      List<Map<String, dynamic>> data =
          await ApiService.kirabayar(widget.username, widget.varlks);
      setState(() {
        kirabayarData = data;
        if (kirabayarData.isNotEmpty) {
          selectedKira = kirabayarData[0]['nmkira'];
          selectedKdgl = kirabayarData[0]['kdgl'];
        }
      });
    } catch (e) {
      print('Failed to fetch kirabayar data: $e');
    }
  }

  void _updatePaymentFields() {
    String grandTotalClean =
        widget.grandTotal.replaceAll(RegExp(r'[^0-9]'), '');
    String totbayarClean = widget.vartotalbyr.replaceAll(RegExp(r'[^0-9]'), '');
    int grandTotalInt = int.tryParse(grandTotalClean) ?? 0;
    int totbayarInt = int.tryParse(totbayarClean) ?? 0;
    int hrsbayarInt = grandTotalInt - totbayarInt;
    int jmluangInt =
        int.tryParse(jmluangController.text.replaceAll(',', '')) ?? 0;
    if (jmluangInt >= hrsbayarInt) {
      kembaliController.text = formatter.format(jmluangInt - hrsbayarInt);
      paymentController.text = formatter.format(hrsbayarInt);
    } else {
      kembaliController.text = '0';
      paymentController.text = formatter.format(jmluangInt);
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    String grandTotalClean =
        widget.grandTotal.replaceAll(RegExp(r'[^0-9]'), '');
    String totbayarClean = widget.vartotalbyr.replaceAll(RegExp(r'[^0-9]'), '');
    int grandTotalInt = int.tryParse(grandTotalClean) ?? 0;
    int totbayarInt = int.tryParse(totbayarClean) ?? 0;
    int hrsbayarInt = grandTotalInt - totbayarInt;
    final saldoKas = ref.watch(saldoProvider);
    String hrsbayar = formatter.format(hrsbayarInt);

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
      ),
      elevation: 0,
      backgroundColor: Colors.transparent,
      child: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.85,
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header (Fixed)
            Container(
              padding: EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF3B82F6), Color(0xFF1D4ED8)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(24),
                  topRight: Radius.circular(24),
                ),
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
                      Icons.payment,
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
                          'Pembayaran',
                          style: GoogleFonts.plusJakartaSans(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'No: ${widget.notrans}',
                          style: GoogleFonts.plusJakartaSans(
                            color: Colors.white.withOpacity(0.9),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Content (Scrollable)
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: EdgeInsets.all(24),
                  child: Column(
                    children: [
                      // Summary Cards
                      _buildSummaryCard(
                        'Total Tagihan',
                        'Rp ${widget.grandTotal}',
                        Icons.receipt_long,
                        Color(0xFF3B82F6),
                      ),
                      SizedBox(height: 12),
                      _buildSummaryCard(
                        'Sudah Dibayar',
                        'Rp ${widget.vartotalbyr}',
                        Icons.check_circle_outline,
                        Color(0xFF10B981),
                      ),
                      SizedBox(height: 12),
                      _buildSummaryCard(
                        'Sisa Tagihan',
                        'Rp $hrsbayar',
                        Icons.error_outline,
                        Color(0xFFEF4444),
                        trailing: IconButton(
                          icon:
                              Icon(Icons.add_circle, color: Color(0xFF3B82F6)),
                          onPressed: () {
                            jmluangController.text =
                                formatter.format(hrsbayarInt);
                            kembaliController.text = '0';
                            paymentController.text =
                                formatter.format(hrsbayarInt);
                          },
                          tooltip: 'Isi otomatis',
                        ),
                      ),

                      SizedBox(height: 24),

                      // Input Jumlah Uang
                      Container(
                        decoration: BoxDecoration(
                          color: Color(0xFFF3F4F6),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: TextField(
                          controller: jmluangController,
                          decoration: InputDecoration(
                            labelText: 'Jumlah Uang',
                            labelStyle: GoogleFonts.plusJakartaSans(
                              color: Color(0xFF6B7280),
                              fontWeight: FontWeight.w500,
                            ),
                            prefixIcon: Icon(Icons.payments_outlined,
                                color: Color(0xFF3B82F6)),
                            prefixText: 'Rp ',
                            prefixStyle: GoogleFonts.plusJakartaSans(
                              color: Color(0xFF1A1A1A),
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                            ),
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.all(20),
                          ),
                          keyboardType: TextInputType.number,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF1A1A1A),
                          ),
                        ),
                      ),

                      SizedBox(height: 16),

                      // Kembalian dan Nilai Bayar
                      Row(
                        children: [
                          Expanded(
                            child: Container(
                              padding: EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Color(0xFFFEF2F2),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: Color(0xFFEF4444).withOpacity(0.2),
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Kembalian',
                                    style: GoogleFonts.plusJakartaSans(
                                      color: Color(0xFFEF4444),
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  SizedBox(height: 4),
                                  Text(
                                    kembaliController.text.isEmpty
                                        ? '0'
                                        : kembaliController.text,
                                    style: GoogleFonts.plusJakartaSans(
                                      color: Color(0xFFEF4444),
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          SizedBox(width: 12),
                          Expanded(
                            child: Container(
                              padding: EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Color(0xFFECFDF5),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: Color(0xFF10B981).withOpacity(0.2),
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Nilai Bayar',
                                    style: GoogleFonts.plusJakartaSans(
                                      color: Color(0xFF10B981),
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  SizedBox(height: 4),
                                  Text(
                                    paymentController.text.isEmpty
                                        ? '0'
                                        : paymentController.text,
                                    style: GoogleFonts.plusJakartaSans(
                                      color: Color(0xFF10B981),
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),

                      SizedBox(height: 24),

                      // Dropdown Dibayar Ke
                      Container(
                        padding:
                            EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                        decoration: BoxDecoration(
                          color: Color(0xFFF3F4F6),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.account_balance_wallet_outlined,
                                color: Color(0xFF6B7280)),
                            SizedBox(width: 12),
                            Expanded(
                              child: DropdownButton<String>(
                                hint: Text("Pilih Akun Pembayaran",
                                    style: GoogleFonts.plusJakartaSans()),
                                value: selectedKira,
                                isExpanded: true,
                                underline: SizedBox(),
                                style: GoogleFonts.plusJakartaSans(
                                  color: Color(0xFF1A1A1A),
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                                items: kirabayarData.map((kira) {
                                  return DropdownMenuItem<String>(
                                    value: kira['nmkira'],
                                    child: Text(kira['nmkira']),
                                  );
                                }).toList(),
                                onChanged: (value) {
                                  setState(() {
                                    selectedKira = value;
                                    selectedKdgl = kirabayarData.firstWhere(
                                        (kira) =>
                                            kira['nmkira'] == value)['kdgl'];
                                  });
                                },
                              ),
                            ),
                          ],
                        ),
                      ),

                      if (selectedKdgl != null)
                        Padding(
                          padding: EdgeInsets.only(top: 8, left: 4),
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              'Kode: $selectedKdgl',
                              style: GoogleFonts.plusJakartaSans(
                                color: Color(0xFF6B7280),
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),

            // Action Buttons (Fixed at bottom)
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Color(0xFFF9FAFB),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(24),
                  bottomRight: Radius.circular(24),
                ),
              ),
              child: Row(
                children: [
                  // Tombol Piutang/Batal
                  Expanded(
                    child: Container(
                      height: 52,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Color(0xFFF59E0B), Color(0xFFD97706)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: [
                          BoxShadow(
                            color: Color(0xFFF59E0B).withOpacity(0.3),
                            blurRadius: 8,
                            offset: Offset(0, 4),
                          ),
                        ],
                      ),
                      child: ElevatedButton(
                        onPressed: isProcessing
                            ? null
                            : () {
                                Navigator.of(context).pop();
                              },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shadowColor: Colors.transparent,
                          padding:
                              EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.schedule, size: 14),
                                SizedBox(width: 3),
                                Text(
                                  'Piutang /',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                            Text(
                              'Batal bayar',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 10),
                  // Tombol Bayar
                  Expanded(
                    flex: 2,
                    child: Container(
                      height: 52,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors:
                              (paymentController.text == '0' || isProcessing)
                                  ? [Color(0xFFD1D5DB), Color(0xFF9CA3AF)]
                                  : [Color(0xFF10B981), Color(0xFF059669)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(14),
                        boxShadow:
                            (paymentController.text != '0' && !isProcessing)
                                ? [
                                    BoxShadow(
                                      color: Color(0xFF10B981).withOpacity(0.4),
                                      blurRadius: 12,
                                      offset: Offset(0, 6),
                                    ),
                                  ]
                                : [],
                      ),
                      child: ElevatedButton(
                        onPressed: (paymentController.text == '0' ||
                                isProcessing)
                            ? null
                            : () async {
                                setState(() {
                                  isProcessing = true;
                                });
                                try {
                                  int paymentInt = int.tryParse(
                                          paymentController.text.replaceAll(
                                              RegExp(r'[^\d]'), '')) ??
                                      0;
                                  int totalbyrdulu = int.tryParse(widget
                                          .totbayar
                                          .replaceAll(RegExp(r'[^\d]'), '')) ??
                                      0;

                                  var paymentData = await ApiService.bayarjual(
                                    widget.notrans,
                                    paymentInt.toString(),
                                    widget.username,
                                    widget.varlks,
                                    selectedKdgl!,
                                    widget.asal,
                                  );

                                  // Perbarui saldo berdasarkan asal
                                  if (widget.asal == 'jual') {
                                    ref.read(saldoProvider.notifier).state +=
                                        paymentInt;
                                  } else if (widget.asal == 'retur') {
                                    ref.read(saldoProvider.notifier).state -=
                                        paymentInt;
                                  }

                                  Navigator.of(context).pop();
                                  widget.onPaymentSuccess(saldoKas.toString(),
                                      (totalbyrdulu + paymentInt).toString());
                                } catch (e) {
                                  print('Error saat melakukan pembayaran: $e');
                                } finally {
                                  setState(() {
                                    isProcessing = false;
                                  });
                                }
                              },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shadowColor: Colors.transparent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: isProcessing
                            ? SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.white),
                                ),
                              )
                            : Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.check_circle, size: 20),
                                  SizedBox(width: 6),
                                  Text(
                                    'Bayar',
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                      ),
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

  Widget _buildSummaryCard(
      String label, String value, IconData icon, Color color,
      {Widget? trailing}) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: color.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: GoogleFonts.plusJakartaSans(
                    color: Color(0xFF6B7280),
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  value,
                  style: GoogleFonts.plusJakartaSans(
                    color: Color(0xFF1A1A1A),
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          if (trailing != null) trailing,
        ],
      ),
    );
  }
}

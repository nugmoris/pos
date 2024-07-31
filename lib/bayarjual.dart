import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'service.dart';

class PaymentDialog extends StatefulWidget {
  final String notrans;
  final String grandTotal;
  final String totbayar;
  final String username;
  final String varlks;

  PaymentDialog({
    required this.notrans,
    required this.grandTotal,
    required this.totbayar,
    required this.username,
    required this.varlks,
  });

  @override
  _PaymentDialogState createState() => _PaymentDialogState();
}

class _PaymentDialogState extends State<PaymentDialog> {
  TextEditingController jmluangController = TextEditingController();
  TextEditingController kembaliController = TextEditingController();
  TextEditingController paymentController = TextEditingController();

  List<Map<String, dynamic>> kirabayarData = [];
  String? selectedKira;
  String? selectedKdgl;

  final NumberFormat formatter = NumberFormat("#,###", "id_ID");

  @override
  void initState() {
    super.initState();
    _fetchKirabayarData();

    // Add listener to jmluangController
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
      List<Map<String, dynamic>> data = await ApiService.kirabayar(widget.username, widget.varlks);
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
    String grandTotalClean = widget.grandTotal.replaceAll(RegExp(r'[^0-9]'), '');
    String totbayarClean = widget.totbayar.replaceAll(RegExp(r'[^0-9]'), '');

    int grandTotalInt = int.tryParse(grandTotalClean) ?? 0;
    int totbayarInt = int.tryParse(totbayarClean) ?? 0;
    int hrsbayarInt = grandTotalInt - totbayarInt;

    int jmluangInt = int.tryParse(jmluangController.text.replaceAll(',', '')) ?? 0;

    if (jmluangInt >= hrsbayarInt) {
      kembaliController.text = formatter.format(jmluangInt - hrsbayarInt);
      paymentController.text = formatter.format(hrsbayarInt);
    } else {
      kembaliController.text = '0';
      paymentController.text = formatter.format(jmluangInt);
    }
  }

  @override
  Widget build(BuildContext context) {
    String grandTotalClean = widget.grandTotal.replaceAll(RegExp(r'[^0-9]'), '');
    String totbayarClean = widget.totbayar.replaceAll(RegExp(r'[^0-9]'), '');

    int grandTotalInt = int.tryParse(grandTotalClean) ?? 0;
    int totbayarInt = int.tryParse(totbayarClean) ?? 0;
    int hrsbayarInt = grandTotalInt - totbayarInt;
    String hrsbayar = formatter.format(hrsbayarInt);

    return AlertDialog(
      title: Text('Pembayaran'),
      content: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            Table(
              columnWidths: {
                0: FlexColumnWidth(2),
                1: FixedColumnWidth(7),
                2: FlexColumnWidth(5),
              },
              children: [
                TableRow(
                  children: [
                    Text('No '),
                    Text(': '),
                    Text(widget.notrans),
                  ],
                ),
                TableRow(
                  children: [
                    Text('Tgl'),
                    Text(': '),
                    Text(DateFormat('dd-MM-yyyy').format(DateTime.now())),
                  ],
                ),
                TableRow(
                  children: [
                    Text(
                      'Total',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    Text(': '),
                    Text(
                      'Rp. ${widget.grandTotal}',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                  ],
                ),
                TableRow(
                  children: [
                    Text(
                      'Terbyr',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    Text(': '),
                    Text(
                      'Rp. ${widget.totbayar}',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                  ],
                ),
                TableRow(
                  children: [
                    Text(
                      'Kurang',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    Text(': '),
                    Row(
                      children: <Widget>[
                        Text(
                          'Rp. $hrsbayar',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        SizedBox(width: 8),
                        GestureDetector(
                          onTap: () {
                            paymentController.text = formatter.format(hrsbayarInt);
                            jmluangController.text = formatter.format(hrsbayarInt);
                            kembaliController.text = '0';
                          },
                          child: Icon(Icons.add_circle_outline, color: Colors.blue),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(height: 16),
            TextField(
              controller: jmluangController,
              decoration: InputDecoration(
                labelText: 'Jumlah Uang Rp',
                hintText: 'Jumlah Uang Rp',
              ),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: kembaliController,
              decoration: InputDecoration(
                labelText: 'Kembalian',
                hintText: 'Kembalian',
              ),
              keyboardType: TextInputType.number,
              readOnly: true,
            ),
            TextField(
              controller: paymentController,
              decoration: InputDecoration(
                labelText: 'Nilai Bayar',
                hintText: 'Masukkan jumlah pembayaran',
              ),
              keyboardType: TextInputType.number,
            ),
            Divider(
              color: Colors.black,
              thickness: 2,
              indent: 10,
              endIndent: 10,
            ),
            Text(
              'Dibayar ke :',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            DropdownButton<String>(
              hint: Text("Pilih Kira"),
              value: selectedKira,
              isExpanded: true,
              items: kirabayarData.map((kira) {
                return DropdownMenuItem<String>(
                  value: kira['nmkira'],
                  child: Text(kira['nmkira']),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  selectedKira = value;
                  selectedKdgl = kirabayarData.firstWhere((kira) => kira['nmkira'] == value)['kdgl'];
                });
              },
            ),
            if (selectedKdgl != null)
              Align(
                alignment: Alignment.centerLeft,
                child: Text('Kode : $selectedKdgl'),
              ),
            Divider(
              color: Colors.black,
              thickness: 2,
              indent: 10,
              endIndent: 10,
            ),
          ],
        ),
      ),
      actions: <Widget>[
        TextButton(
          child: Text('Batal'),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        TextButton(
          child: Text('Bayar'),
          onPressed: () async {
            print(paymentController.text.replaceAll(',', ''));
            if (selectedKdgl != null && paymentController.text.isNotEmpty) {
              try {
                var paymentData = await ApiService.bayarjual(
                  widget.notrans,
                  paymentController.text.replaceAll('.', ''),
                  widget.username,
                  widget.varlks,
                  selectedKdgl!,
                );
                print('Pembayaran berhasil: $paymentData');
                Navigator.of(context).pop(paymentData[0]['totbyr']);
              } catch (e) {
                print('Error saat melakukan pembayaran: $e');
              }
            } else {
              print('Mohon lengkapi semua data sebelum melakukan pembayaran.');
            }
          },
        ),
      ],
    );
  }
}

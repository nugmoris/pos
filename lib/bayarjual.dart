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
  TextEditingController paymentController = TextEditingController();
  List<Map<String, dynamic>> kirabayarData = [];
  String? selectedKira;
  String? selectedKdgl;

  @override
  void initState() {
    super.initState();
    _fetchKirabayarData();
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

  @override
  Widget build(BuildContext context) {
    // Menghitung kekurangan pembayaran (hrsbayar)
    final formatter = NumberFormat("#,###", "id_ID"); // Menggunakan locale Indonesia
    String grandTotalClean = widget.grandTotal.replaceAll(RegExp(r'[^0-9]'), ''); // Menghapus semua karakter non-digit
    String totbayarClean = widget.totbayar.replaceAll(RegExp(r'[^0-9]'), ''); // Menghapus semua karakter non-digit

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
                0: FlexColumnWidth(2), // Lebar kolom pertama (label)
                1: FixedColumnWidth(7), // Lebar kolom kedua (titik dua)
                2: FlexColumnWidth(5), // Lebar kolom ketiga (nilai)
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
                      'Terbayar',
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
                            paymentController.text = hrsbayarInt.toString();
                          },
                          child: Icon(Icons.add_circle_outline, color: Colors.blue),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(height: 16), // Jarak antara TextField dan ComboBox
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
            SizedBox(height: 16), // Memberikan sedikit jarak antara tabel dan TextField
            TextField(
              controller: paymentController,
              decoration: InputDecoration(
                labelText: 'Nilai Bayar',
                hintText: 'Masukkan jumlah pembayaran',
              ),
              keyboardType: TextInputType.number,
            ),
          ],
        ),
      ),
      actions: <Widget>[
        TextButton(
          child: Text('Batal'),
          onPressed: () {
            Navigator.of(context).pop(); // Tutup dialog
          },
        ),
        TextButton(
          child: Text('Bayar'),
          onPressed: () async {
            if (selectedKdgl != null && paymentController.text.isNotEmpty) {
              try {
                var paymentData = await ApiService.bayarjual(
                  widget.notrans,
                  paymentController.text,
                  widget.username,
                  widget.varlks,
                  selectedKdgl!,
                );
                print('Pembayaran berhasil: $paymentData');
                Navigator.of(context).pop(paymentData[0]['totbyr']); // Mengembalikan nilai totbyr
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

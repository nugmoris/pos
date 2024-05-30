import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'service.dart';

class LapPage extends StatefulWidget {
  @override
  _LapPageState createState() => _LapPageState();
}

class _LapPageState extends State<LapPage> {
  final NumberFormat numberFormat = NumberFormat.decimalPattern('en');

  DateTime? selectedDate1;
  DateTime? selectedDate2;
  String selectedServer = 'ALL';
  num nominalTotal = 0;
  num nominalMenangTotal = 0;

  Future<List<Map<String, dynamic>>> _fetchData() async {
    try {
      final List<Map<String, dynamic>> data = await ApiService.lapjual(
          selectedDate1?.toString() ?? '',
          selectedDate2?.toString() ?? '',
          '2');
      return data;
    } catch (e) {
      //print('Error fetching data: $e');
      return [];
    }
  }

  Future<void> _selectDate1(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: selectedDate1 ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (pickedDate != null && pickedDate != selectedDate1) {
      setState(() {
        selectedDate1 = pickedDate;
      });
    }
  }

  Future<void> _selectDate2(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: selectedDate2 ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (pickedDate != null && pickedDate != selectedDate2) {
      setState(() {
        selectedDate2 = pickedDate;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Laporan'),
      ),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(16.0),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () => _selectDate1(context),
                        child: AbsorbPointer(
                          child: TextField(
                            decoration: InputDecoration(
                              labelText: 'Dari Tgl',
                              suffixIcon: Icon(Icons.calendar_today),
                            ),
                            controller: TextEditingController(
                              text:
                                  selectedDate1?.toString().split(' ')[0] ?? '',
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 10),
                    Expanded(
                      child: GestureDetector(
                        onTap: () => _selectDate2(context),
                        child: AbsorbPointer(
                          child: TextField(
                            decoration: InputDecoration(
                              labelText: 'Sampai Tgl',
                              suffixIcon: Icon(Icons.calendar_today),
                            ),
                            controller: TextEditingController(
                              text:
                                  selectedDate2?.toString().split(' ')[0] ?? '',
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 10),
                Row(
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          _fetchData(); // Panggil fungsi _fetchData() saat tombol Tampilkan diklik
                        });
                      },
                      child: Text('Tampilkan'),
                    ),
                    SizedBox(width: 10),
                    ElevatedButton(
                      onPressed: () {},
                      child: Text('Cetak'),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: FutureBuilder<List<Map<String, dynamic>>>(
              future: _fetchData(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error fetching data'));
                } else {
                  final data = snapshot.data!;
                  nominalTotal = 0;
                  nominalMenangTotal = 0;
                  data.forEach((item) {
                    nominalTotal += int.parse(item['subttl'] ?? '0');
                  });
                  final numberFormat = NumberFormat.decimalPattern('id_ID');

                  return Column(
                    children: [
                      Text(
                        'Total: ${numberFormat.format(nominalTotal)}',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      Expanded(
                        child: ListView.builder(
                          itemCount: data.length,
                          itemBuilder: (context, index) {
                            final item = data[index];
                            final nrp = numberFormat.parse(item['nrp'] ?? '0');
                            final subttl =
                                numberFormat.parse(item['subttl'] ?? '0');

                            return Container(
                              child: Card(
                                child: ListTile(
                                  title: Text(item['notrans']),
                                  subtitle: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text('Tanggal: ${item['tgl']}'),
                                      Text('kode: ${item['kdbarang']}'),
                                      Text('Nama: ${item['nama']}'),
                                      Text(
                                          'Nominal: Rp.${numberFormat.format(nrp)}'),
                                      Text('Qty: ${item['nqty']}'),
                                      Text(
                                          'Subttl: Rp.${numberFormat.format(subttl)}'),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}

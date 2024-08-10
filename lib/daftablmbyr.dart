import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'service.dart';

class DaftarBlmByrPage extends StatefulWidget {
  final String varpbuser;
  final String varbagian;
  final String varlks;
  final String varnmlok;

  DaftarBlmByrPage(this.varpbuser, this.varbagian, this.varlks, this.varnmlok);

  @override
  _DaftarBlmByrPageState createState() => _DaftarBlmByrPageState();
}

class _DaftarBlmByrPageState extends State<DaftarBlmByrPage> {
  final NumberFormat numberFormat = NumberFormat.decimalPattern('en');
  final DateFormat dateFormat = DateFormat('yyyy-MM-dd'); // Date format to show only the date

  DateTime? selectedDate1;
  DateTime? selectedDate2;
  String selectedServer = 'ALL';
  num nominalTotal = 0;
  List<Map<String, dynamic>> data = [];

  Future<void> _fetchData() async {
    try {
      final List<Map<String, dynamic>> fetchedData = await ApiService.lapdaftarblmbyr(
        widget.varpbuser,
        widget.varlks,
        selectedDate1?.toString() ?? '',
        selectedDate2?.toString() ?? '',
      );

      setState(() {
        data = fetchedData;
        nominalTotal = data.fold(0, (sum, item) => sum + int.parse(item['subttl'] ?? '0'));
      });
    } catch (e) {
      print('Error fetching data: $e');
      setState(() {
        data = [];
      });
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
  void initState() {
    super.initState();
    selectedDate1 = DateTime.now();
    selectedDate2 = DateTime.now();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Penjualan Belum Terbayar'),
      ),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(16.0),
            child: Column(
              children: [
                Text(
                  widget.varnmlok,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
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
                              text: selectedDate1?.toString().split(' ')[0] ?? '',
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
                              text: selectedDate2?.toString().split(' ')[0] ?? '',
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 10),
                SizedBox(height: 10),
                Row(
                  children: [
                    ElevatedButton(
                      onPressed: _fetchData,
                      child: Text('Tampilkan'),
                    ),
                    SizedBox(width: 10),
                    // ElevatedButton(
                    //   onPressed: () {},
                    //   child: Text('Cetak'),
                    // ),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: data.isNotEmpty
                ? SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: SingleChildScrollView(
                      child: DataTable(
                        columns: [
                          DataColumn(label: Text('Notrans')),
                          DataColumn(label: Text('Tanggal')),
                          DataColumn(label: Text('Nama ')),
                          DataColumn(label: Text('Item')),
                          DataColumn(label: Text('QTy')),
                          DataColumn(label: Text('Harga')),
                          DataColumn(label: Text('Subtotal')),
                        ],
                        rows: _buildDataRows(),
                      ),
                    ),
                  )
                : Center(child: Text('No data available')),
          ),
        ],
      ),
    );
  }

  List<DataRow> _buildDataRows() {
    List<DataRow> rows = [];
    String? lastNotrans;

    for (var item in data) {
      bool isNewTransaction = item['notrans'] != lastNotrans;

      rows.add(DataRow(cells: [
        DataCell(Text(isNewTransaction ? item['notrans'] ?? '' : '')), // notrans
        // DataCell(Text(dateFormat.format(DateTime.parse(item['dtgl'] ?? '')))), // dtgl
        DataCell(Text(isNewTransaction ? item['tgl'] ?? '' : '')), // dtgl
        DataCell(Text(isNewTransaction ? item['nmcust'] ?? '' : '')),
        DataCell(Text(item['nmbarang'] ?? '')),
        DataCell(Text(numberFormat.format(int.parse(item['nqty'] ?? '0')))),
        DataCell(Text(numberFormat.format(int.parse(item['nrp'] ?? '0')))), // nominal
        DataCell(Text(numberFormat.format(int.parse(item['subttl'] ?? '0')))),
      ]));

      lastNotrans = item['notrans'];
    }

    return rows;
  }
}

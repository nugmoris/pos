import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'service.dart';

class LapPage extends StatefulWidget {
  final String varpbuser;
  final String varbagian;
  final String varlks;
  final String varnmlok;
  LapPage(this.varpbuser, this.varbagian, this.varlks, this.varnmlok);
  @override
  _LapPageState createState() => _LapPageState();
}

class _LapPageState extends State<LapPage> {
  final NumberFormat numberFormat = NumberFormat.decimalPattern('en');
  final DateFormat dateFormat = DateFormat('yyyy-MM-dd'); // Date format to show only the date

  DateTime? selectedDate1;
  DateTime? selectedDate2;
  String selectedServer = 'ALL';
  num nominalTotal = 0;
  List<Map<String, dynamic>> data = [];

  Future<void> _fetchData() async {
    try {
      final List<Map<String, dynamic>> fetchedData = await ApiService.lapjualx(
        selectedDate1?.toString() ?? '',
        selectedDate2?.toString() ?? '',
        '2',
        widget.varlks,
      );
      print('cetak lap penjualan');
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
        title: Text('Laporan'),
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
                          DataColumn(label: Text('No Trans')),
                          DataColumn(label: Text('Tanggal')),
                          DataColumn(label: Text('Nama Customer')),
                          DataColumn(label: Text('Nama Barang')),
                          DataColumn(label: Text('Qty')),
                          DataColumn(label: Text('Harga')),
                          DataColumn(label: Text('Subttl')),
                          DataColumn(label: Text('Total')),
                          DataColumn(label: Text('Waktu Input')),
                        ],
                        rows: _buildDataRows(),
                      ),
                    ),
                  )
                : Center(child: Text('No data available')),
          ),
          Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              'Grand Total: ${numberFormat.format(nominalTotal)}',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }

  List<DataRow> _buildDataRows() {
    List<DataRow> rows = [];
    String? lastNotrans;
    num subttlTotal = 0;

    for (var i = 0; i < data.length; i++) {
      var item = data[i];
      bool isNewTransaction = item['notrans'] != lastNotrans;

      if (isNewTransaction) {
        subttlTotal =
            data.where((element) => element['notrans'] == item['notrans']).fold(0, (sum, element) => sum + int.parse(element['subttl'] ?? '0'));
      }

      // Periksa apakah nqty kurang dari 0
      bool isQtyNegative = int.tryParse(item['nqty'] ?? '0')! < 0;

      // Atur warna teks berdasarkan kondisi
      TextStyle textStyle = TextStyle(color: isQtyNegative ? Colors.red : Colors.black);

      rows.add(DataRow(cells: [
        DataCell(Text(isNewTransaction ? item['notrans'] ?? '' : '', style: textStyle)),
        DataCell(Text(isNewTransaction ? dateFormat.format(DateTime.parse(item['tgl'])) : '', style: textStyle)),
        DataCell(Text(isNewTransaction ? item['nmcust'] ?? '' : '', style: textStyle)),
        DataCell(Text(item['nmbarang'] ?? '', style: textStyle)),
        DataCell(Text(item['nqty'] ?? '', style: textStyle)),
        DataCell(Text(numberFormat.format(int.parse(item['nrp'] ?? '0')), style: textStyle)),
        DataCell(Text(numberFormat.format(int.parse(item['subttl'] ?? '0')), style: textStyle)),
        DataCell(Text(isNewTransaction ? numberFormat.format(subttlTotal) : '', style: textStyle)),
        DataCell(Text(item['tgl'] ?? '', style: textStyle)),
      ]));

      lastNotrans = item['notrans'];
    }

    return rows;
  }
}

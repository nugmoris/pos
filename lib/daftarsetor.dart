import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'service.dart';

class DaftarSetorPage extends StatefulWidget {
  final String varpbuser;
  final String varbagian;
  final String varlks;
  final String varnmlok;

  DaftarSetorPage(this.varpbuser, this.varbagian, this.varlks, this.varnmlok);

  @override
  _DaftarSetorPageState createState() => _DaftarSetorPageState();
}

class _DaftarSetorPageState extends State<DaftarSetorPage> {
  final NumberFormat numberFormat = NumberFormat.decimalPattern('en');
  final DateFormat dateFormat = DateFormat('yyyy-MM-dd'); // Date format to show only the date

  DateTime? selectedDate1;
  DateTime? selectedDate2;
  String selectedServer = 'ALL';
  num nominalTotal = 0;
  List<Map<String, dynamic>> data = [];

  String selectedOption = '1';

  Future<void> _fetchData() async {
    try {
      final List<Map<String, dynamic>> fetchedData = await ApiService.lapdaftarsetor(
        widget.varpbuser,
        widget.varlks,
        selectedDate1?.toString() ?? '',
        selectedDate2?.toString() ?? '',
        selectedOption,
      );
      print('cetak daftar setor');
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
                    Text('Pilih Opsi:'),
                    SizedBox(width: 10),
                    Expanded(
                      child: DropdownButton<String>(
                        value: selectedOption,
                        onChanged: (String? newValue) {
                          setState(() {
                            selectedOption = newValue!;
                          });
                        },
                        items: <String>['1', '2'].map<DropdownMenuItem<String>>((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(
                              value == '1' ? 'Setoran dari ${widget.varpbuser}' : 'Setoran dari ${widget.varnmlok}',
                            ),
                          );
                        }).toList(),
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
                          DataColumn(label: Text('Tanggal')),
                          DataColumn(label: Text('No Trans')),
                          DataColumn(label: Text('Nominal')),
                          DataColumn(label: Text('User')),
                          DataColumn(label: Text('Lokasi')),
                          DataColumn(label: Text('Keterangan')),
                          DataColumn(label: Text('Waktu Input')),
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
        DataCell(Text(dateFormat.format(DateTime.parse(item['dtgl'] ?? '')))), // dtgl
        DataCell(Text(isNewTransaction ? item['notrans'] ?? '' : '')), // notrans
        DataCell(Text(numberFormat.format(int.parse(item['nrp'] ?? '0')))), // nominal
        DataCell(Text(isNewTransaction ? item['user'] ?? '' : '')), // user
        DataCell(Text(isNewTransaction ? item['nmlok'] ?? '' : '')), // nmlok
        DataCell(Text(item['ket'] ?? '')),
        DataCell(Text(item['waktuinput'] ?? '')),
      ]));

      lastNotrans = item['notrans'];
    }

    return rows;
  }
}

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'service_pagination.dart';

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
  final DateFormat dateFormat = DateFormat('yyyy-MM-dd');
  final ScrollController _scrollController = ScrollController();

  DateTime? selectedDate1;
  DateTime? selectedDate2;
  num nominalTotal = 0;
  num grandNominalTotal = 0;

  List<Map<String, dynamic>> data = [];

  // Pagination variables
  int currentPage = 1;
  int itemsPerPage = 50;
  bool isLoading = false;
  bool hasMoreData = true;

  // Summary variables
  Map<String, dynamic>? summaryData;
  String selectedViewMode = 'summary'; // 'summary' or 'detail'

  @override
  void initState() {
    super.initState();
    selectedDate1 = DateTime.now();
    selectedDate2 = DateTime.now();
    _scrollController.addListener(_scrollListener);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollListener() {
    if (_scrollController.position.pixels ==
        _scrollController.position.maxScrollExtent) {
      if (selectedViewMode == 'detail' && hasMoreData && !isLoading) {
        _loadMoreData();
      }
    }
  }

  Future<void> _fetchSummary() async {
    setState(() {
      isLoading = true;
    });

    try {
      final summary = await ApiService.lapjualsummary(
        selectedDate1?.toString() ?? '',
        selectedDate2?.toString() ?? '',
        widget.varlks,
      );

      setState(() {
        summaryData = summary;
        isLoading = false;
      });
    } catch (e) {
      print('Error fetching summary: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _fetchData({bool reset = true}) async {
    if (reset) {
      setState(() {
        data = [];
        currentPage = 1;
        hasMoreData = true;
        isLoading = true;
      });
    }

    try {
      final fetchedData = await ApiService.lapjualpanjangPaginated(
        selectedDate1?.toString() ?? '',
        selectedDate2?.toString() ?? '',
        '2',
        widget.varlks,
        currentPage,
        itemsPerPage,
      );
      print('Fetched detail data: ${fetchedData['data'].length} rows');
      print('Page Total: ${fetchedData['total']}');
      print('Grand Total All Pages: ${fetchedData['grandTotal']}');

      setState(() {
        if (reset) {
          data = fetchedData['data'];
          nominalTotal = fetchedData['total']; // total halaman saat ini
          grandNominalTotal =
              fetchedData['grandTotal'] ?? 0; // total semua data
        } else {
          data.addAll(fetchedData['data']);
        }

        hasMoreData = fetchedData['hasMore'];
        isLoading = false;
      });
    } catch (e) {
      print('Error fetching data: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _loadMoreData() async {
    if (isLoading || !hasMoreData) return;

    setState(() {
      isLoading = true;
      currentPage++;
    });

    await _fetchData(reset: false);
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

  void _showDateRangeWarning() {
    if (selectedDate1 != null && selectedDate2 != null) {
      int daysDiff = selectedDate2!.difference(selectedDate1!).inDays;
      if (daysDiff > 30) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('Peringatan'),
            content: Text('Rentang tanggal terlalu besar ($daysDiff hari). '
                'Disarankan maksimal 30 hari untuk performa optimal.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('OK'),
              ),
            ],
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Laporan'),
        actions: [
          ToggleButtons(
            isSelected: [
              selectedViewMode == 'summary',
              selectedViewMode == 'detail'
            ],
            onPressed: (index) {
              setState(() {
                selectedViewMode = index == 0 ? 'summary' : 'detail';
              });
            },
            children: [
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 12),
                child: Text('Ringkasan'),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 12),
                child: Text('Detail'),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          _buildFilterSection(),
          Expanded(
            child: selectedViewMode == 'summary'
                ? _buildSummaryView()
                : _buildDetailView(),
          ),
          if (selectedViewMode == 'summary' && summaryData != null)
            _buildSummaryFooter(),
          if (selectedViewMode == 'detail' && data.isNotEmpty)
            _buildDetailFooter(),
        ],
      ),
    );
  }

  Widget _buildFilterSection() {
    return Padding(
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
          SizedBox(height: 10),
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
                        border: OutlineInputBorder(),
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
                        border: OutlineInputBorder(),
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
              ElevatedButton.icon(
                onPressed: () {
                  _showDateRangeWarning();
                  if (selectedViewMode == 'summary') {
                    _fetchSummary();
                  } else {
                    _fetchData();
                  }
                },
                icon: Icon(Icons.search),
                label: Text('Tampilkan'),
              ),
              SizedBox(width: 10),
              // ElevatedButton.icon(
              //   onPressed: () {
              //     // Export functionality
              //   },
              //   icon: Icon(Icons.download),
              //   label: Text('Export'),
              // ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryView() {
    if (isLoading) {
      return Center(child: CircularProgressIndicator());
    }

    if (summaryData == null) {
      return Center(child: Text('Pilih tanggal dan tekan Tampilkan'));
    }

    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Card(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Ringkasan Penjualan',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 10),
                  _buildSummaryItem(
                    'Total Transaksi',
                    summaryData!['total_transaksi'].toString(),
                  ),
                  _buildSummaryItem(
                    'Total Penjualan',
                    //   'Rp ${numberFormat.format(summaryData!['total_penjualan'])}',
                    'Rp ${numberFormat.format(num.tryParse(summaryData!['total_penjualan'].toString()) ?? 0)}',
                  ),
                  _buildSummaryItem(
                    'Rata-rata per Transaksi',
                    // 'Rp ${numberFormat.format(summaryData!['rata_rata'])}',
                    'Rp ${numberFormat.format(num.tryParse(summaryData!['rata_rata'].toString()) ?? 0)}',
                  ),
                  _buildSummaryItem(
                    'Customer Terbanyak',
                    summaryData!['top_customer'] ?? '',
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: 16),
          Card(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Top 10 Barang Terlaris',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 10),
                  ...summaryData!['top_barang'].map<Widget>((item) {
                    return ListTile(
                      title: Text(item['nama']),
                      subtitle: Text('Qty: ${item['qty']}'),
                      // trailing:
                      //Text('Rp ${numberFormat.format(item['total'])}'),
                      //  Text(
                      //      'Rp ${numberFormat.format(num.tryParse(summaryData!['total'].toString()) ?? 0)}'),
                      trailing: Text(
                        'Rp ${numberFormat.format(num.tryParse(item['total'].toString()) ?? 0)}',
                      ),
                    );
                  }).toList(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryItem(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(
            value,
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailView() {
    if (isLoading && data.isEmpty) {
      return Center(child: CircularProgressIndicator());
    }

    if (data.isEmpty) {
      return Center(child: Text('Pilih tanggal dan tekan Tampilkan'));
    }

    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            controller: _scrollController,
            scrollDirection: Axis.horizontal,
            child: SingleChildScrollView(
              child: DataTable(
                columns: [
                  DataColumn(label: Text('No Trans')),
                  DataColumn(label: Text('Tanggal')),
                  DataColumn(label: Text('Customer')),
                  DataColumn(label: Text('Barang')),
                  DataColumn(label: Text('Qty')),
                  DataColumn(label: Text('Harga')),
                  DataColumn(label: Text('Subtotal')),
                  DataColumn(label: Text('Total')),
                  DataColumn(label: Text('Waktu')),
                  DataColumn(label: Text('Ket')),
                ],
                rows: _buildDataRows(),
              ),
            ),
          ),
        ),
        if (isLoading && data.isNotEmpty)
          Padding(
            padding: EdgeInsets.all(8),
            child: CircularProgressIndicator(),
          ),
        if (!hasMoreData && data.isNotEmpty)
          Padding(
            padding: EdgeInsets.all(8),
            child: Text('Semua data telah ditampilkan'),
          ),
      ],
    );
  }

  Widget _buildSummaryFooter() {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: Colors.grey.shade300)),
      ),
      child: Text(
        // 'Grand Total: Rp ${numberFormat.format(summaryData!['total_penjualan'])}',
        'Grand Total: Rp ${numberFormat.format(num.tryParse(summaryData!['total_penjualan'].toString()) ?? 0)}',
        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
      ),
    );
  }

  Widget _buildDetailFooter() {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: Colors.grey.shade300)),
      ),
      child: Text(
        'Grand Total: Rp ${numberFormat.format(grandNominalTotal)}',
        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
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
        subttlTotal = data
            .where((element) => element['notrans'] == item['notrans'])
            .fold<num>(
                0,
                (sum, element) =>
                    sum + (num.tryParse(element['subttl'].toString()) ?? 0));
      }

      num qty = num.tryParse(item['nqty'].toString()) ?? 0;
      TextStyle textStyle = TextStyle(
        color: qty < 0 ? Colors.red : Colors.black,
        fontSize: 12,
      );

      rows.add(DataRow(cells: [
        DataCell(Text(isNewTransaction ? item['notrans'] ?? '' : '',
            style: textStyle)),
        DataCell(Text(
            isNewTransaction
                ? dateFormat.format(
                    DateTime.tryParse(item['tgl'] ?? '') ?? DateTime(2000))
                : '',
            style: textStyle)),
        DataCell(Text(isNewTransaction ? item['nmcust'] ?? '' : '',
            style: textStyle)),
        DataCell(Text(item['nmbarang'] ?? '', style: textStyle)),
        DataCell(Text(item['nqty'] ?? '', style: textStyle)),
        DataCell(Text(
            numberFormat.format(num.tryParse(item['nrp'].toString()) ?? 0),
            style: textStyle)),
        DataCell(Text(
            numberFormat.format(num.tryParse(item['subttl'].toString()) ?? 0),
            style: textStyle)),
        DataCell(Text(isNewTransaction ? numberFormat.format(subttlTotal) : '',
            style: textStyle)),
        DataCell(Text(item['tgl'] ?? '', style: textStyle)),
        DataCell(Text(item['lretur'] == '1' ? 'Retur' : '', style: textStyle)),
      ]));

      lastNotrans = item['notrans'];
    }

    return rows;
  }
}

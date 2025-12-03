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
      // print('Fetched detail data: ${fetchedData['data'].length} rows');
      // print('Page Total: ${fetchedData['total']}');
      // print('Grand Total All Pages: ${fetchedData['grandTotal']}');

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
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFEEF2FF), Color(0xFFE0EAFC)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(),
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(28),
                      topRight: Radius.circular(28),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 20,
                        offset: Offset(0, -8),
                      )
                    ],
                  ),
                  child: Column(
                    children: [
                      _buildViewSwitcher(),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                          child: Column(
                            children: [
                              _buildFilterSection(),
                              SizedBox(height: 16),
                              Expanded(
                                child: AnimatedSwitcher(
                                  duration: Duration(milliseconds: 300),
                                  child: selectedViewMode == 'summary'
                                      ? _buildSummaryView()
                                      : _buildDetailView(),
                                ),
                              ),
                              if (selectedViewMode == 'summary' &&
                                  summaryData != null)
                                _buildSummaryFooter(),
                              if (selectedViewMode == 'detail' &&
                                  data.isNotEmpty)
                                _buildDetailFooter(),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: Colors.white,
            child: Icon(Icons.bar_chart_rounded, color: Color(0xFF4C1D95)),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Dashboard Laporan',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1F2937),
                  ),
                ),
                Text(
                  widget.varnmlok,
                  style: TextStyle(
                    color: Color(0xFF4B5563),
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.8),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              widget.varpbuser,
              style: TextStyle(
                color: Color(0xFF4338CA),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildViewSwitcher() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
      child: Container(
        decoration: BoxDecoration(
          color: Color(0xFFF3F4F6),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            _buildSwitcherButton('Ringkasan', selectedViewMode == 'summary',
                () {
              setState(() => selectedViewMode = 'summary');
            }),
            _buildSwitcherButton('Detail', selectedViewMode == 'detail', () {
              setState(() => selectedViewMode = 'detail');
            }),
          ],
        ),
      ),
    );
  }

  Expanded _buildSwitcherButton(
      String label, bool isActive, VoidCallback onTap) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: Duration(milliseconds: 200),
          padding: EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isActive ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(16),
            boxShadow: isActive
                ? [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.08),
                      blurRadius: 12,
                      offset: Offset(0, 6),
                    )
                  ]
                : [],
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: isActive ? Color(0xFF4338CA) : Color(0xFF9CA3AF),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFilterSection() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Color(0xFFE5E7EB)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Filter Periode',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: Color(0xFF374151),
            ),
          ),
          SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildDateField(
                  label: 'Dari',
                  value: selectedDate1,
                  onTap: () => _selectDate1(context),
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: _buildDateField(
                  label: 'Sampai',
                  value: selectedDate2,
                  onTap: () => _selectDate2(context),
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    _showDateRangeWarning();
                    if (selectedViewMode == 'summary') {
                      _fetchSummary();
                    } else {
                      _fetchData();
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 14),
                    backgroundColor: Color(0xFF4338CA),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  icon: Icon(
                    Icons.bar_chart_rounded,
                    size: 18,
                    color: Colors.white,
                  ),
                  label:
                      Text('Tampilkan', style: TextStyle(color: Colors.white)),
                ),
              ),
              SizedBox(width: 12),
              OutlinedButton(
                onPressed: () {
                  setState(() {
                    selectedDate1 = DateTime.now();
                    selectedDate2 = DateTime.now();
                  });
                },
                style: OutlinedButton.styleFrom(
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                  side: BorderSide(color: Color(0xFF4338CA)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: Text(
                  'Reset',
                  style: TextStyle(color: Color(0xFF4338CA)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDateField({
    required String label,
    required DateTime? value,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Color(0xFFE5E7EB)),
        ),
        child: Row(
          children: [
            Icon(Icons.calendar_today_rounded,
                size: 18, color: Color(0xFF9CA3AF)),
            SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label.toUpperCase(),
                    style: TextStyle(
                      fontSize: 11,
                      letterSpacing: 0.8,
                      color: Color(0xFF9CA3AF),
                    ),
                  ),
                  Text(
                    value != null ? dateFormat.format(value) : '-',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1F2937),
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

  Widget _buildSummaryView() {
    if (isLoading) {
      return Center(child: CircularProgressIndicator());
    }

    if (summaryData == null) {
      return Center(child: Text('Pilih tanggal dan tekan Tampilkan'));
    }

    return SingleChildScrollView(
      padding: EdgeInsets.only(bottom: 16),
      child: Column(
        children: [
          GridView.count(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            childAspectRatio: 1.6,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            crossAxisCount: MediaQuery.of(context).size.width > 600 ? 4 : 2,
            children: [
              _buildStatCard(
                label: 'Total Transaksi',
                value: summaryData!['total_transaksi'].toString(),
                icon: Icons.receipt_long,
                color: Color(0xFF4C1D95),
              ),
              _buildStatCard(
                label: 'Total Penjualan',
                value:
                    'Rp ${numberFormat.format(num.tryParse(summaryData!['total_penjualan'].toString()) ?? 0)}',
                icon: Icons.payments_rounded,
                color: Color(0xFF2563EB),
              ),
              _buildStatCard(
                label: 'Rata-rata/Transaksi',
                value:
                    'Rp ${numberFormat.format(num.tryParse(summaryData!['rata_rata'].toString()) ?? 0)}',
                icon: Icons.trending_up,
                color: Color(0xFF059669),
              ),
              _buildStatCard(
                label: 'Customer Terbanyak',
                value: summaryData!['top_customer'] ?? '-',
                icon: Icons.people_alt_rounded,
                color: Color(0xFFF97316),
              ),
            ],
          ),
          SizedBox(height: 16),
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Color(0xFFE5E7EB)),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Top 10 Barang Terlaris',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF1F2937),
                        ),
                      ),
                      Icon(Icons.bar_chart, color: Color(0xFF4338CA)),
                    ],
                  ),
                  SizedBox(height: 12),
                  ...summaryData!['top_barang'].map<Widget>((item) {
                    return Container(
                      margin: EdgeInsets.only(bottom: 10),
                      padding:
                          EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                      decoration: BoxDecoration(
                        color: Color(0xFFF9FAFB),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item['nama'],
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF111827),
                                  ),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  'Qty: ${item['qty']}',
                                  style: TextStyle(
                                    color: Color(0xFF6B7280),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Text(
                            'Rp ${numberFormat.format(num.tryParse(item['total'].toString()) ?? 0)}',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF111827),
                            ),
                          ),
                        ],
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

  Widget _buildStatCard({
    required String label,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Color(0xFFE5E7EB)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: color),
          ),
          Spacer(),
          Text(
            label,
            style: TextStyle(
              color: Color(0xFF6B7280),
              fontSize: 12,
            ),
          ),
          SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: Color(0xFF111827),
            ),
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
          child: Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Color(0xFFE5E7EB)),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: SingleChildScrollView(
                controller: _scrollController,
                scrollDirection: Axis.horizontal,
                child: SingleChildScrollView(
                  child: DataTable(
                    headingRowColor: MaterialStateProperty.all(
                      Color(0xFFF3F4F6),
                    ),
                    columns: [
                      DataColumn(label: Text('No Trans')),
                      DataColumn(label: Text('Tanggal')),
                      DataColumn(label: Text('Customer')),
                      DataColumn(label: Text('Barang')),
                      DataColumn(label: Text('Qty')),
                      DataColumn(label: Text('Harga')),
                      DataColumn(label: Text('Subtotal')),
                      DataColumn(label: Text('Total')),
                      DataColumn(label: Text('Waktu Input')),
                      DataColumn(label: Text('Ket')),
                    ],
                    rows: _buildDataRows(),
                  ),
                ),
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
        DataCell(Text(item['waktuinput'] ?? '', style: textStyle)),
        DataCell(Text(item['lretur'] == '1' ? 'Retur' : '', style: textStyle)),
      ]));

      lastNotrans = item['notrans'];
    }

    return rows;
  }
}

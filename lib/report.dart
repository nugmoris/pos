import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:bluetooth_print_plus/bluetooth_print_plus.dart';
import 'package:flutter/material.dart' as material;
import 'package:intl/intl.dart';

class ReportPage extends material.StatefulWidget {
  final List<Map<String, dynamic>> reportData;
  final String varpbuser;
  final String varnotrans;

  const ReportPage({
    material.Key? key,
    required this.reportData,
    required this.varpbuser,
    required this.varnotrans,
  }) : super(key: key);

  @override
  material.State<ReportPage> createState() => _ReportPageState();
}

class _ReportPageState extends material.State<ReportPage> {
  List<BluetoothDevice> _devices = [];
  BluetoothDevice? _selectedDevice;
  bool _isConnected = false;
  bool _isScanning = false;
  bool _isPrinting = false;

  // Subscriptions
  late StreamSubscription<List<BluetoothDevice>> _scanResultsSubscription;
  late StreamSubscription<ConnectState> _connectStateSubscription;

  // Variabel untuk laporan
  String currentDate = DateFormat('yyyy-MM-dd').format(DateTime.now());
  final NumberFormat numberFormat = NumberFormat.decimalPattern('id_ID');
  int totalNrpku = 0;
  double totalDppku = 0;
  double totalPpnku = 0;

  @override
  void initState() {
    super.initState();
    _calculateTotals();
    _listenBluetooth();
  }

  void _calculateTotals() {
    totalNrpku = 0;
    totalDppku = 0;
    totalPpnku = 0;
    for (int i = 0; i < widget.reportData.length; i++) {
      final item = widget.reportData[i];
      final subtotal = item['subtotal'];
      if (subtotal is int) {
        totalNrpku += subtotal;
      } else if (subtotal is String) {
        totalNrpku += int.tryParse(subtotal) ?? 0;
      } else if (subtotal is num) {
        totalNrpku += subtotal.toInt();
      }

      final qty = int.tryParse(item['jumlah']?.toString() ?? '0') ?? 0;
      totalDppku += _parseToDouble(item['dpp']) * qty;
      totalPpnku += _parseToDouble(item['ppn']) * qty;
    }
  }

  double _parseToDouble(dynamic value) {
    if (value == null) return 0;
    if (value is num) return value.toDouble();
    return double.tryParse(value.toString().replaceAll(',', '')) ?? 0;
  }

  void _listenBluetooth() {
    _scanResultsSubscription = BluetoothPrintPlus.scanResults.listen((devices) {
      if (mounted) {
        setState(() {
          _devices = devices;
        });
      }
    });
    _connectStateSubscription = BluetoothPrintPlus.connectState.listen((state) {
      if (mounted) {
        setState(() {
          _isConnected = state == ConnectState.connected;
        });
      }
    });
  }

  Future<void> _startScan() async {
    setState(() => _isScanning = true);
    await BluetoothPrintPlus.startScan(timeout: const Duration(seconds: 15));
    setState(() => _isScanning = false);
  }

  Future<void> _printReceipt() async {
    if (_selectedDevice == null || !_isConnected) {
      material.ScaffoldMessenger.of(context).showSnackBar(
        material.SnackBar(
            content: material.Text('Harap sambungkan printer terlebih dahulu')),
      );
      return;
    }
    setState(() => _isPrinting = true);
    try {
      List<int> bytes = [];

      // Helper function to add text to the bytes list
      void addText(String text) {
        bytes.addAll(utf8.encode(text));
      }

      // Helper function to add raw ESC/POS command
      void addCommand(List<int> command) {
        bytes.addAll(command);
      }

      // Center and Bold for header
      addCommand([0x1B, 0x61, 0x01]); // Center
      addCommand([0x1B, 0x45, 0x01]); // Bold on
      addText('KOPERASI KASIH\n');
      addText('RS MARDI RAHAYU\n');
      addCommand([0x1B, 0x45, 0x00]); // Bold off
      addText('${widget.varnotrans} - $currentDate\n');
      addText('\n');

      // Left align for items
      addCommand([0x1B, 0x61, 0x00]); // Left

      for (final item in widget.reportData) {
        final nmbarang = item['nama'];
        final int nqty = int.tryParse(item['jumlah'] ?? '0') ?? 0;
        final int harga = int.tryParse(item['harga'] ?? '0') ?? 0;
        final int subtotal = int.tryParse(item['subtotal'] ?? '0') ?? 0;

        addCommand([0x1B, 0x45, 0x01]); // Bold on
        addText('$nmbarang\n');
        addCommand([0x1B, 0x45, 0x00]); // Bold off
        addText(
            '${numberFormat.format(nqty)} x Rp.${numberFormat.format(harga)} = Rp.${numberFormat.format(subtotal)}\n');
      }

      // Center for separator
      addCommand([0x1B, 0x61, 0x01]); // Center
      addText('----------------------------\n');

      // Right for tax breakdown & total
      addCommand([0x1B, 0x61, 0x02]); // Right
      addText('DPP : Rp.${numberFormat.format(totalDppku.round())}\n');
      addText('PPN : Rp.${numberFormat.format(totalPpnku.round())}\n');
      addCommand([0x1B, 0x45, 0x01]); // Bold on
      addText('Total: Rp.${numberFormat.format(totalNrpku)}\n');
      addCommand([0x1B, 0x45, 0x00]); // Bold off

      // Center for footer
      addCommand([0x1B, 0x61, 0x01]); // Center
      addText('----------------------------\n');
      addText('\n');
      addText('Terima kasih sudah berbelanja\n');
      addText('Barang yang sudah dibeli, tidak\n');
      addText('dapat ditukar / dikembalikan\n');
      addText('\n\n\n');

      BluetoothPrintPlus.write(Uint8List.fromList(bytes));
      material.ScaffoldMessenger.of(context).showSnackBar(
        material.SnackBar(content: material.Text('Nota berhasil dicetak')),
      );
    } catch (e) {
      print('Print error: $e');
      if (mounted) {
        material.ScaffoldMessenger.of(context).showSnackBar(
          material.SnackBar(content: material.Text('Gagal mencetak: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isPrinting = false);
      }
    }
  }

  @override
  void dispose() {
    _scanResultsSubscription.cancel();
    _connectStateSubscription.cancel();
    super.dispose();
  }

  @override
  material.Widget build(material.BuildContext context) {
    return material.Scaffold(
      appBar: material.AppBar(
        title: const material.Text('Cetak Nota'),
      ),
      body: material.Padding(
        padding: const material.EdgeInsets.all(16.0),
        child: material.Column(
          children: [
            // Bagian tampilan laporan
            material.Expanded(
              child: material.SingleChildScrollView(
                child: material.Column(
                  crossAxisAlignment: material.CrossAxisAlignment.start,
                  children: [
                    material.Text('Tanggal: $currentDate',
                        style: const material.TextStyle(fontSize: 16)),
                    material.Text('No. Transaksi: ${widget.varnotrans}',
                        style: const material.TextStyle(fontSize: 16)),
                    const material.SizedBox(height: 16),
                    const material.Divider(),
                    ...widget.reportData.map((item) {
                      final int nqty = int.tryParse(item['jumlah'] ?? '0') ?? 0;
                      final int harga = int.tryParse(item['harga'] ?? '0') ?? 0;
                      final int subtotal =
                          int.tryParse(item['subtotal'] ?? '0') ?? 0;
                      return material.Padding(
                        padding:
                            const material.EdgeInsets.symmetric(vertical: 8.0),
                        child: material.Column(
                          crossAxisAlignment: material.CrossAxisAlignment.start,
                          children: [
                            material.Text(
                              item['nama'],
                              style: const material.TextStyle(
                                fontWeight: material.FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            const material.SizedBox(height: 4),
                            material.Row(
                              mainAxisAlignment:
                                  material.MainAxisAlignment.spaceBetween,
                              children: [
                                material.Text(
                                    '${numberFormat.format(nqty)} x Rp.${numberFormat.format(harga)}'),
                                material.Text(
                                    'Rp.${numberFormat.format(subtotal)}'),
                              ],
                            ),
                            const material.Divider(),
                          ],
                        ),
                      );
                    }).toList(),
                    material.Align(
                      alignment: material.Alignment.centerRight,
                      child: material.Column(
                        crossAxisAlignment: material.CrossAxisAlignment.end,
                        children: [
                          material.Text(
                              'DPP: Rp.${numberFormat.format(totalDppku.round())}'),
                          material.Text(
                              'PPN: Rp.${numberFormat.format(totalPpnku.round())}'),
                          const material.SizedBox(height: 4),
                          material.Text(
                            'Total: Rp.${numberFormat.format(totalNrpku)}',
                            style: const material.TextStyle(
                              fontWeight: material.FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Bagian kontrol printer
            material.Column(
              children: [
                const material.SizedBox(height: 16),
                _isScanning
                    ? const material.CircularProgressIndicator()
                    : material.ElevatedButton(
                        onPressed: _startScan,
                        child: const material.Text('Scan Printer'),
                      ),
                if (_devices.isNotEmpty)
                  material.DropdownButton<String>(
                    value: _selectedDevice?.address,
                    items: _devices
                        .map((device) => material.DropdownMenuItem<String>(
                              value: device.address,
                              child: material.Text(
                                  "${device.name} (${device.address})"),
                            ))
                        .toList(),
                    onChanged: (address) {
                      setState(() {
                        _selectedDevice =
                            _devices.firstWhere((d) => d.address == address);
                      });
                    },
                    hint: const material.Text('Pilih Printer'),
                    isExpanded: true,
                  ),
                const material.SizedBox(height: 8),
                material.Row(
                  mainAxisAlignment: material.MainAxisAlignment.spaceEvenly,
                  children: [
                    material.ElevatedButton(
                      onPressed: _isConnected
                          ? null
                          : () async {
                              if (_selectedDevice != null) {
                                await BluetoothPrintPlus.connect(
                                    _selectedDevice!);
                              } else {
                                material.ScaffoldMessenger.of(context)
                                    .showSnackBar(
                                  material.SnackBar(
                                      content: material.Text(
                                          'Pilih printer terlebih dahulu')),
                                );
                              }
                            },
                      child: const material.Text('Connect'),
                    ),
                    material.ElevatedButton(
                      onPressed: _isConnected
                          ? () async {
                              await BluetoothPrintPlus.disconnect();
                            }
                          : null,
                      child: const material.Text('Disconnect'),
                    ),
                  ],
                ),
                const material.SizedBox(height: 16),
                material.ElevatedButton(
                  onPressed:
                      _isConnected && !_isPrinting ? _printReceipt : null,
                  style: material.ElevatedButton.styleFrom(
                    minimumSize: const material.Size(double.infinity, 50),
                  ),
                  child: material.Text(
                      _isPrinting ? 'Sedang Mencetak...' : 'Cetak Nota'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

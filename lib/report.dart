import 'package:blue_thermal_printer/blue_thermal_printer.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ReportPage extends StatefulWidget {
  final List<Map<String, dynamic>> reportData;
  final String varpbuser;
  final String varnotrans;

  ReportPage({
    required this.reportData,
    required this.varpbuser,
    required this.varnotrans,
  });

  @override
  State<ReportPage> createState() => _ReportPageState();
}

class _ReportPageState extends State<ReportPage> {
  List<BluetoothDevice> devices = [];
  bool isPrinterConnected = false;
  bool isPrinting = false;
  BluetoothDevice? selectedDevice;
  BlueThermalPrinter printer = BlueThermalPrinter.instance;

  String currentDate = DateFormat('yyyy-MM-dd').format(DateTime.now());
  final numberFormat = NumberFormat.decimalPattern('id_ID');
  int totalNrpku = 0;
  String totalShowData = '';
  String barshowdata = '';
  String cetakanke = ' ';

  @override
  void initState() {
    super.initState();
    getDevices();
    checkPrinterConnection();

    // Hitung total nrp saat initState untuk memastikan hanya dihitung sekali
    for (int i = 0; i < widget.reportData.length; i++) {
      var nrp = widget.reportData[i]['subtotal'];
      if (nrp is int) {
        totalNrpku += nrp;
      } else if (nrp is String) {
        totalNrpku += int.tryParse(nrp) ?? 0;
      }
    }

    // Gabungkan karakter 'showdata' menjadi satu string
    List<String> showDataList = [];
    for (int i = 0; i < widget.reportData.length; i++) {
      showDataList.add(widget.reportData[i]['nama'] as String);
    }
    totalShowData = showDataList.join('');
    barshowdata = widget.varnotrans + '-' + totalShowData;

    setState(() {
      isPrinting = false;
      print("Awal isPrinting: $isPrinting");
    });
  }

  void getDevices() async {
    devices = await printer.getBondedDevices();
    setState(() {});
  }

  void checkPrinterConnection() async {
    bool isConnected = await printer.isConnected ?? false;
    setState(() {
      isPrinterConnected = isConnected;
    });
  }

  String padLeftWithSpaces(String input, int width) {
    if (input.length >= width) {
      return input;
    } else {
      return ' ' * (width - input.length) + input;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Cetak Nota'),
      ),
      body: Container(
        child: Column(
          children: [
            Expanded(
              flex: 3,
              child: SingleChildScrollView(
                child: Column(
                  children: <Widget>[
                    Text(currentDate),
                    Text(widget.varnotrans),
                    ListView.builder(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      itemCount: widget.reportData.length,
                      itemBuilder: (context, index) {
                        final numberFormat = NumberFormat.decimalPattern('id_ID');
                        final nrp = numberFormat.parse(widget.reportData[index]['subtotal'] ?? '0');
                        final nqty = numberFormat.parse(widget.reportData[index]['jumlah'] ?? '0');
                        final nharga = numberFormat.parse(widget.reportData[index]['harga'] ?? '0');

                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          child: Table(
                            // border: TableBorder.all(),
                            columnWidths: {
                              0: FlexColumnWidth(1),
                              1: FlexColumnWidth(0.2),
                              2: FlexColumnWidth(1),
                              3: FlexColumnWidth(0.2),
                              4: FlexColumnWidth(1),
                            },
                            children: [
                              TableRow(
                                children: [
                                  TableCell(
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Text(
                                        widget.reportData[index]['nama'],
                                        style: TextStyle(
                                          fontSize: 16.0,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ),
                                  TableCell(child: Container()),
                                  TableCell(child: Container()),
                                  TableCell(child: Container()),
                                  TableCell(child: Container()),
                                ],
                              ),
                              TableRow(
                                children: [
                                  TableCell(
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Align(
                                        alignment: Alignment.centerRight,
                                        child: Text('${numberFormat.format(nqty)}'),
                                      ),
                                    ),
                                  ),
                                  TableCell(
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Text('x'),
                                    ),
                                  ),
                                  TableCell(
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Text('Rp.${numberFormat.format(nharga)}'),
                                    ),
                                  ),
                                  TableCell(
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Text('='),
                                    ),
                                  ),
                                  TableCell(
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Text('Rp.${numberFormat.format(nrp)}'),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                    Divider(),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        'Total: Rp.${numberFormat.format(totalNrpku)}',
                        style: TextStyle(
                          fontSize: 18.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              flex: 1,
              child: Column(
                children: [
                  Center(
                    child: Row(
                      children: [
                        isPrinterConnected ? Icon(Icons.check_circle, color: Colors.green) : Icon(Icons.cancel, color: Colors.red),
                        SizedBox(width: 10),
                        DropdownButton<BluetoothDevice>(
                          value: selectedDevice,
                          hint: const Text('Pilih Printer'),
                          onChanged: (device) {
                            setState(() {
                              selectedDevice = device;
                            });
                          },
                          items: devices
                              .map((e) => DropdownMenuItem(
                                    child: Text(e.name!),
                                    value: e,
                                  ))
                              .toList(),
                        ),
                      ],
                    ),
                  ),
                  Row(
                    children: [
                      Container(
                        width: 25,
                        height: 10,
                      ),
                      ElevatedButton(
                        onPressed: () async {
                          if (!(await printer.isConnected)!) {
                            printer.connect(selectedDevice!);
                            setState(() {
                              isPrinterConnected = true;
                            });
                          }
                        },
                        child: const Text('Connect'),
                      ),
                      Container(
                        width: 5,
                        height: 10,
                      ),
                      ElevatedButton(
                        onPressed: () {
                          printer.disconnect();
                          setState(() {
                            isPrinterConnected = false;
                          });
                        },
                        child: const Text('Disconnect'),
                      ),
                      Container(
                        width: 5,
                        height: 10,
                      ),
                      ElevatedButton(
                        onPressed: isPrinting
                            ? null
                            : () async {
                                print("Tombol Diklik - isPrinting: $isPrinting");

                                try {
                                  // Code untuk proses cetak kupon
                                  printer.printNewLine();
                                  String jmlcetak = '1';
                                  String waktutrans = 'xxx';

                                  printer.printCustom('Kop. Kasih', 1, 1);
                                  printer.printCustom('${widget.varnotrans} - $currentDate', 1, 1);

                                  printer.printNewLine();

                                  for (int i = 0; i < widget.reportData.length; i++) {
                                    final data = widget.reportData[i];
                                    final nmbarang = data['nama'];
                                    final int nqty = int.tryParse(data['jumlah'] ?? '0') ?? 0;
                                    final int harga = int.tryParse(data['harga'] ?? '0') ?? 0;
                                    final int subtotal = int.tryParse(data['subtotal'] ?? '0') ?? 0;

                                    final nrp = numberFormat.parse(data['nrp'] ?? '0');

                                    String qtyStr = padLeftWithSpaces('${numberFormat.format(nqty)}', 4); // Lebar tetap 5 untuk qty
                                    String hargaStr = padLeftWithSpaces('Rp.${numberFormat.format(harga)}', 9); // Lebar tetap 12 untuk harga
                                    String subtotalStr =
                                        padLeftWithSpaces('Rp.${numberFormat.format(subtotal)}', 12); // Lebar tetap 12 untuk subtotal

                                    printer.printCustom('$nmbarang', 0, 0);
                                    printer.printCustom('$qtyStr x $hargaStr = $subtotalStr', 0, 0);
                                  }
                                  printer.printCustom('--------------------', 0, 1);
                                  //printer.printCustom('Total  : Rp.${numberFormat.format(totalNrpku)}', 0, 0);
                                  printer.printCustom(padLeftWithSpaces('Total  : Rp.${numberFormat.format(totalNrpku)}', 32), 0, 0);

                                  // printer.printNewLine();
                                  printer.printCustom('--------------------', 0, 1);
                                  printer.printNewLine();
                                } finally {
                                  setState(() {
                                    isPrinting = true;
                                  });
                                }
                              },
                        child: Text(
                          isPrinting ? 'Cetak Nota' : 'Cetak Nota',
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

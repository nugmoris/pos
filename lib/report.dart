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

    // Hitung total nrp saat initState untuk memastikan hanya dihitung sekali
    for (int i = 0; i < widget.reportData.length; i++) {
      var nrp = widget.reportData[i]['subtotal'];
      if (nrp is int) {
        totalNrpku += nrp;
      } else if (nrp is String) {
        // Jika nrp adalah String, konversi ke int sebelum ditambahkan
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
                    Text(widget.varpbuser + ':' + widget.varnotrans),
                    ListView.builder(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      itemCount: widget.reportData.length,
                      itemBuilder: (context, index) {
                        final numberFormat =
                            NumberFormat.decimalPattern('id_ID');
                        final nrp = numberFormat
                            .parse(widget.reportData[index]['nrp'] ?? '0');
                        final nqty = numberFormat
                            .parse(widget.reportData[index]['nqty'] ?? '0');

                        return ListTile(
                          title: Text(widget.reportData[index]['nama']),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('nama:'),
                              Text(widget.reportData[index]['nama']),
                              Text('subtotal: Rp.${numberFormat.format(nrp)}'),
                              Text('nqty: Rp.${numberFormat.format(nqty)}'),
                            ],
                          ),
                        );
                      },
                    ),
                    Divider(),

                    // Text('Total  : Rp.${numberFormat.format(subtotal)}'),

                    // Tampilkan QR code untuk totalShowData
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
                          // Tampilkan centang hijau atau silang merah berdasarkan status koneksi printer
                          isPrinterConnected
                              ? Icon(Icons.check_circle, color: Colors.green)
                              : Icon(Icons.cancel, color: Colors.red),
                          SizedBox(height: 10),
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
                                  .toList()),
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
                              //print('Menghubungi printer');
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
                            //print('Memutus printer');
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
                                  print(
                                      "Tombol Diklik - isPrinting: $isPrinting");

                                  try {
                                    // Code untuk proses cetak kupon
                                    printer.printNewLine();
                                    String jmlcetak = '1';
                                    // String jmlcetak =
                                    //     widget.reportData[0]['lcetak'];
                                    String waktutrans = 'xxx';

                                    for (int i = 0;
                                        i < widget.reportData.length;
                                        i++) {
                                      final data = widget.reportData[i];
                                      final nmbarang = data['nama'];
                                      final int nqty =
                                          int.tryParse(data['jumlah'] ?? '0') ??
                                              0;
                                      final int harga =
                                          int.tryParse(data['harga'] ?? '0') ??
                                              0;
                                      final int subtotal = int.tryParse(
                                              data['subtotal'] ?? '0') ??
                                          0;

                                      final nrp = numberFormat
                                          .parse(data['nrp'] ?? '0');

                                      printer.printCustom(
                                          '$nmbarang : $nqty x ${numberFormat.format(harga)} = Rp.${numberFormat.format(subtotal)}',
                                          0,
                                          0);
                                    }
                                    printer.printCustom(
                                        '--------------------', 0, 1);
                                    printer.printCustom(
                                        'Total  : Rp.${numberFormat.format(totalNrpku)}',
                                        0,
                                        0);

                                    printer.printNewLine();
                                    printer.printCustom(
                                        '--------------------', 0, 1);
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
                ))
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';

// Import your ApiService
import 'service.dart';

class SearchPopup extends StatefulWidget {
  final String varpbuser;
  final String varlks;
  final Function(String) onItemSelected; // Callback untuk mengirim data yang dipilih

  SearchPopup({
    required this.varpbuser,
    required this.varlks,
    required this.onItemSelected,
  });

  @override
  _SearchPopupState createState() => _SearchPopupState();
}

class _SearchPopupState extends State<SearchPopup> {
  TextEditingController tcariController = TextEditingController();
  List<dynamic> searchResults = [];

  void initState() {
    super.initState();
    _searchInitialTrans();
  }

  void _searchInitialTrans() async {
    var result = await ApiService.cariretjual(
      widget.varpbuser,
      widget.varlks,
      '1',
      ' ',
    );

    setState(() {
      searchResults = result;
      print('hasil search $searchResults');
    });
  }

  // Function to fetch data from API
  void searchRetur() async {
    var result = await ApiService.cariretjual(
      widget.varpbuser,
      widget.varlks,
      '2',
      tcariController.text,
    );

    setState(() {
      searchResults = result;
      //print(searchResults);
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
        title: Text('Cari Retur'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: tcariController,
                decoration: InputDecoration(
                  labelText: 'Cari Retur',
                ),
              ),
              ElevatedButton(
                onPressed: searchRetur,
                child: Text('Cari'),
              ),
              SizedBox(height: 20),
              searchResults.isNotEmpty
                  ? SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: DataTable(
                        columns: [
                          DataColumn(label: Text('No Retur')),
                          DataColumn(label: Text('Tanggal')),
                          DataColumn(label: Text('No Jual')),
                          DataColumn(label: Text('Nama Barang')),
                        ],
                        rows: searchResults.map((data) {
                          return DataRow(
                            cells: [
                              //notrans, tanggal, nojual,nmbarang,nqty,nrpnsubttl,cketerangan,llunas,lbayar
                              DataCell(
                                Text(data['notrans']),
                                onTap: () {
                                  widget.onItemSelected(
                                    data['notrans'],
                                  );
                                  Navigator.of(context).pop();
                                },
                              ),
                              DataCell(
                                Text(data['tanggal']),
                                onTap: () {
                                  widget.onItemSelected(data['notrans']);
                                  Navigator.of(context).pop();
                                },
                              ),
                              DataCell(
                                Text(data['nojual']),
                                onTap: () {
                                  widget.onItemSelected(data['notrans']);
                                  Navigator.of(context).pop();
                                },
                              ),
                              DataCell(
                                Text(data['nmbarang']),
                                onTap: () {
                                  widget.onItemSelected(data['notrans']);
                                  Navigator.of(context).pop();
                                },
                              ),
                            ],
                          );
                        }).toList(),
                      ),
                    )
                  : Text('Tidak ada hasil'),
            ],
          ),
        ));
  }
}

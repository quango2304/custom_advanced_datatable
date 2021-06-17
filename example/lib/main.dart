import 'dart:convert';

import 'package:advanced_datatable/advancedDataTableSource.dart';
import 'package:advanced_datatable/datatable.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'company_contact.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Advanced DataTable Demo'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key? key, this.title}) : super(key: key);
  final String? title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  var rowsPerPage = AdvancedPaginatedDataTable.defaultRowsPerPage;
  final source = ExampleSource();
  var sortIndex = 0;
  var sortAsc = true;

  DataRow? getRow(int index) {
    final contact = source.lastDetails!.rows[index];
    return DataRow(cells: [
      DataCell(Text(contact.id.toString())),
      DataCell(Text(contact.companyName)),
      DataCell(Text(contact.firstName)),
      DataCell(Text(contact.lastName)),
      DataCell(Text(contact.phone)),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title!),
      ),
      body: SingleChildScrollView(
        child: AdvancedPaginatedDataTable(
          getRow: getRow,
          addEmptyRows: false,
          source: source,
          sortAscending: sortAsc,
          sortColumnIndex: sortIndex,
          showFirstLastButtons: true,
          rowsPerPage: rowsPerPage,
          availableRowsPerPage: [10, 20, 30, 50],
          onRowsPerPageChanged: (newRowsPerPage) {
            if (newRowsPerPage != null) {
              setState(() {
                rowsPerPage = newRowsPerPage;
              });
            }
          },
          columns: [
            DataColumn(label: Text('ID'), numeric: true, onSort: setSort),
            DataColumn(label: Text('Company'), onSort: setSort),
            DataColumn(label: Text('First name'), onSort: setSort),
            DataColumn(label: Text('Last name'), onSort: setSort),
            DataColumn(label: Text('Phone'), onSort: setSort),
          ],
        ),
      ),
    );
  }

  void setSort(int i, bool asc) => setState(() {
        sortIndex = i;
        sortAsc = asc;
      });
}

class ExampleSource extends AdvancedDataTableSource<CompanyContact> {
  @override
  int get selectedRowCount => 0;

  @override
  Future<RemoteDataSourceDetails<CompanyContact>> getNextPage(
      NextPageRequest pageRequest) async {
    //the remote data source has to support the pagaing and sorting
    final queryParameter = <String, dynamic>{
      'offset': pageRequest.offset.toString(),
      'pageSize': pageRequest.pageSize.toString(),
      'sortIndex': ((pageRequest.columnSortIndex ?? 0) + 1).toString(),
      'sortAsc': ((pageRequest.sortAscending ?? true) ? 1 : 0).toString(),
    };

    final requestUri = Uri.https(
      'example.devowl.de',
      '',
      queryParameter,
    );

    final response = await http.get(requestUri);
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return RemoteDataSourceDetails(
        data['totalRows'],
        (data['rows'] as List<dynamic>)
            .map((json) => CompanyContact.fromJson(json))
            .toList(),
      );
    } else {
      throw Exception('Unable to query remote server');
    }
  }
}

import 'dart:async';

import 'package:flutter/material.dart';

typedef LoadPageCallback = Future<RemoteDataSourceDetails<F>> Function<F>(
    int pagesize, int offset);

abstract class AdvancedDataTableSource<T> extends DataTableSource {
  bool get initialRequestCompleted => lastDetails == null ? false : true;
  RemoteDataSourceDetails<T>? lastDetails;
  final StreamController<bool> _refreshStream = StreamController.broadcast();
  Stream get refreshStream => _refreshStream.stream;
  Future<RemoteDataSourceDetails<T>> getNextPage(NextPageRequest pageRequest);

  @override
  int get rowCount => lastDetails?.totalRows ?? 0;

  void refresh() {
    _refreshStream.add(true);
  }

  @override
  DataRow? getRow(int index) => null;

  @override
  bool get isRowCountApproximate => false;

  Future<int> loadNextPage(int pageSize, int offset, int? columnSortIndex,
      bool? sortAscending) async {
    try {
      lastDetails = await getNextPage(
        NextPageRequest(
          pageSize,
          offset,
          columnSortIndex: columnSortIndex,
          sortAscending: sortAscending,
        ),
      );
      return lastDetails?.totalRows ?? 0;
    } catch (error) {
      return Future.error(error);
    }
  }
}

class NextPageRequest {
  final int pageSize;
  final int offset;
  final int? columnSortIndex;
  final bool? sortAscending;

  NextPageRequest(this.pageSize, this.offset,
      {this.columnSortIndex, this.sortAscending});
}

class RemoteDataSourceDetails<T> {
  final int totalRows;
  final List<T> rows;

  RemoteDataSourceDetails(this.totalRows, this.rows);
}

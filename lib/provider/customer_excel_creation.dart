import 'package:excel/excel.dart';

import '../firebase/datamodel/datamodel.dart';

class CustomerExcel {
  final List<CustomerDataModel> customerDataList;
  CustomerExcel({required this.customerDataList});
  Future<List<int>?> createCustomerExcel() async {
    List<int>? resultData;

    var excel = Excel.createExcel();
    var sheet = excel['Sheet1'];

    sheet.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: 0)).value =
        const TextCellValue('Name');
    sheet.cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: 0)).value =
        const TextCellValue('Mobile');
    sheet.cell(CellIndex.indexByColumnRow(columnIndex: 2, rowIndex: 0)).value =
        const TextCellValue('Email');
    sheet.cell(CellIndex.indexByColumnRow(columnIndex: 3, rowIndex: 0)).value =
        const TextCellValue('City');
    sheet.cell(CellIndex.indexByColumnRow(columnIndex: 4, rowIndex: 0)).value =
        const TextCellValue('State');
    sheet.cell(CellIndex.indexByColumnRow(columnIndex: 5, rowIndex: 0)).value =
        const TextCellValue('Address');

    for (var i = 0; i < customerDataList.length; i++) {
      sheet
          .cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: (i + 1)))
          .value = TextCellValue(customerDataList[i].customerName ?? "");
      sheet
          .cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: (i + 1)))
          .value = TextCellValue(customerDataList[i].mobileNo ?? "");
      sheet
          .cell(CellIndex.indexByColumnRow(columnIndex: 2, rowIndex: (i + 1)))
          .value = TextCellValue(customerDataList[i].email ?? "");
      sheet
          .cell(CellIndex.indexByColumnRow(columnIndex: 3, rowIndex: (i + 1)))
          .value = TextCellValue(customerDataList[i].city ?? "");
      sheet
          .cell(CellIndex.indexByColumnRow(columnIndex: 4, rowIndex: (i + 1)))
          .value = TextCellValue(customerDataList[i].state ?? "");
      sheet
          .cell(CellIndex.indexByColumnRow(columnIndex: 5, rowIndex: (i + 1)))
          .value = TextCellValue(customerDataList[i].address ?? "");
    }

    resultData = excel.save();

    return resultData;
  }
}

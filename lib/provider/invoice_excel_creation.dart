import 'package:excel/excel.dart';
import 'package:intl/intl.dart';

import '../firebase/datamodel/invoice_model.dart';

class InvoiceExcel {
  final List<InvoiceModel> inviceData;

  InvoiceExcel({required this.inviceData});

  Future<List<int>?> createInvoiceExcel() async {
    List<int>? resultData;

    var excel = Excel.createExcel();
    var sheet = excel['Sheet1'];

    sheet.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: 0)).value =
        const TextCellValue('S.No');

    sheet.cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: 0)).value =
        const TextCellValue('Invoice Number');

    sheet.cell(CellIndex.indexByColumnRow(columnIndex: 2, rowIndex: 0)).value =
        const TextCellValue('Customer Name');
    sheet.cell(CellIndex.indexByColumnRow(columnIndex: 3, rowIndex: 0)).value =
        const TextCellValue('Customer Address');
    sheet.cell(CellIndex.indexByColumnRow(columnIndex: 4, rowIndex: 0)).value =
        const TextCellValue('Invoice Date');
    sheet.cell(CellIndex.indexByColumnRow(columnIndex: 5, rowIndex: 0)).value =
        const TextCellValue('Total Amount');

    for (var i = 0; i < inviceData.length; i++) {
      sheet
          .cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: (i + 1)))
          .value = TextCellValue((i + 1).toString());
      sheet
          .cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: (i + 1)))
          .value = TextCellValue(inviceData[i].billNo!);
      sheet
          .cell(CellIndex.indexByColumnRow(columnIndex: 2, rowIndex: (i + 1)))
          .value = TextCellValue(inviceData[i].partyName ?? "");
      sheet
          .cell(CellIndex.indexByColumnRow(columnIndex: 3, rowIndex: (i + 1)))
          .value = TextCellValue(inviceData[i].address ?? "");
      sheet
          .cell(CellIndex.indexByColumnRow(columnIndex: 4, rowIndex: (i + 1)))
          .value = TextCellValue(DateFormat(
              'dd-MM-yyyy hh:mm a')
          .format(inviceData[i].biilDate!));
      sheet
          .cell(CellIndex.indexByColumnRow(columnIndex: 5, rowIndex: (i + 1)))
          .value = TextCellValue(inviceData[i].totalBillAmount ?? "");
    }

    resultData = excel.save();

    return resultData;
  }
}

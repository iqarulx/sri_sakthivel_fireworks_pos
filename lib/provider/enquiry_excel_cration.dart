import 'package:excel/excel.dart';
import 'package:intl/intl.dart';

import '../firebase/datamodel/datamodel.dart';

class EnquiryExcel {
  final List<EstimateDataModel> enquiryData;
  final bool isEstimate;

  EnquiryExcel({required this.enquiryData, required this.isEstimate});

  Future<List<int>?> createCustomerExcel() async {
    List<int>? resultData;

    var excel = Excel.createExcel();
    var sheet = excel['Sheet1'];

    sheet.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: 0)).value =
        const TextCellValue('S.No');
    if (isEstimate) {
      sheet
          .cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: 0))
          .value = const TextCellValue('Estimate ID');
    } else {
      sheet
          .cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: 0))
          .value = const TextCellValue('Enquiry ID');
    }

    sheet.cell(CellIndex.indexByColumnRow(columnIndex: 2, rowIndex: 0)).value =
        const TextCellValue('Customer Name');
    sheet.cell(CellIndex.indexByColumnRow(columnIndex: 3, rowIndex: 0)).value =
        const TextCellValue('Customer Address');
    sheet.cell(CellIndex.indexByColumnRow(columnIndex: 4, rowIndex: 0)).value =
        const TextCellValue('Enquiry Date');
    sheet.cell(CellIndex.indexByColumnRow(columnIndex: 5, rowIndex: 0)).value =
        const TextCellValue('Total Amount');

    for (var i = 0; i < enquiryData.length; i++) {
      sheet
          .cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: (i + 1)))
          .value = TextCellValue((i + 1).toString());
      if (isEstimate) {
        sheet
            .cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: (i + 1)))
            .value = TextCellValue(enquiryData[i].estimateid!);
      } else {
        sheet
            .cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: (i + 1)))
            .value = TextCellValue(enquiryData[i].enquiryid!);
      }
      sheet
          .cell(CellIndex.indexByColumnRow(columnIndex: 2, rowIndex: (i + 1)))
          .value = TextCellValue(enquiryData[i].customer != null &&
              enquiryData[i].customer!.customerName != null
          ? enquiryData[i].customer!.customerName!
          : "");
      sheet
          .cell(CellIndex.indexByColumnRow(columnIndex: 3, rowIndex: (i + 1)))
          .value = TextCellValue(enquiryData[i].customer != null &&
              enquiryData[i].customer!.address != null
          ? enquiryData[i].customer!.address!
          : "");
      sheet
          .cell(CellIndex.indexByColumnRow(columnIndex: 4, rowIndex: (i + 1)))
          .value = TextCellValue(DateFormat(
              'dd-MM-yyyy hh:mm a')
          .format(enquiryData[i].createddate!));
      sheet
          .cell(CellIndex.indexByColumnRow(columnIndex: 5, rowIndex: (i + 1)))
          .value = TextCellValue(enquiryData[
              i]
          .price!
          .total!
          .toStringAsFixed(2));
    }

    resultData = excel.save();

    return resultData;
  }
}

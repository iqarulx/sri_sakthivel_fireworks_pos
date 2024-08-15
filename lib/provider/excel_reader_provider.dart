import 'dart:io';

import 'package:excel/excel.dart';

import '../firebase/datamodel/datamodel.dart';

class ExcelReaderProvider {
  Future<List<ExcelCategoryClass>?> readExcelData({required File file}) async {
    List<ExcelCategoryClass>? exceldata = [];
    try {
      var bytes = file.readAsBytesSync();
      var excel = Excel.decodeBytes(bytes);

      for (var table in excel.tables.keys) {
        if (excel.tables[table]!.maxColumns == 4 &&
            excel.tables[table]!.rows[0][0] == null &&
            excel.tables[table]!.rows[0][2] == null &&
            excel.tables[table]!.rows[0][3] == null) {
          for (var row in excel.tables[table]!.rows) {
            if (row[0] == null &&
                row[1] == null &&
                row[2] == null &&
                row[3] == null) {
              continue;
            } else if (row[0] == null && row[2] == null && row[3] == null) {
              exceldata.add(
                ExcelCategoryClass(
                  categoryname: row[1]!.value.toString(),
                  product: [],
                ),
              );
              // log("row1 - ${row[1]!.value.toString()}");
            } else {
              exceldata[exceldata.length - 1].product.add(
                    ExcelProductClass(
                      productno: row[0]!.value.toString(),
                      productname: row[1]!.value.toString(),
                      content: row[2]!.value.toString(),
                      price: row[3]!.value.toString(),
                      discountlock:
                          "0", //row[4] == null ? "" : row[4]!.value.toString(),
                      qrcode:
                          "1", // row[5] == null ? "" : row[5]!.value.toString()
                    ),
                  );
            }
          }

          break;
        } else {
          throw "Excel Data is Not Correct";
        }
      }
    } catch (e) {
      throw e.toString();
    }
    return exceldata;
  }
}

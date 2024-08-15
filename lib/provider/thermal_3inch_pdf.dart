import 'dart:developer';

import 'package:esc_pos_printer_new/esc_pos_printer_new.dart';
import 'package:esc_pos_utils_new/esc_pos_utils_new.dart';
import 'package:intl/intl.dart';

import '../firebase/datamodel/datamodel.dart';

class Termal3InchPDF {
  final EstimateDataModel estimateData;
  final ProfileModel companyInfo;
  Termal3InchPDF({
    required this.estimateData,
    required this.companyInfo,
  });
  void printDemoReceipt(NetworkPrinter printer) async {
    try {
      // var pdftmpfile = await pdffile();
      // printer.textEncoded(pdftmpfile);
      // printer.row([
      //   PosColumn(text: 'Change', width: 8, styles: PosStyles(align: PosAlign.right, width: PosTextSize.size2)),
      //   PosColumn(text: '\$4.03', width: 4, styles: PosStyles(align: PosAlign.right, width: PosTextSize.size2)),
      // ]);
      // printer.text('889  Watson Lane', styles: PosStyles(align: PosAlign.center));
      // printer.text('SriSoftwarez Crackers', styles: const PosStyles(align: PosAlign.center, bold: true));

      printer.setStyles(const PosStyles(align: PosAlign.center));
      printer.text(companyInfo.companyName ?? "", styles: const PosStyles(align: PosAlign.center, bold: true));
      printer.text(
        companyInfo.address ?? "",
        styles: const PosStyles(
          align: PosAlign.center,
        ),
      );
      printer.text(
        companyInfo.contact!["mobile_no"].toString(),
        styles: const PosStyles(
          align: PosAlign.center,
        ),
      );
      printer.setStyles(const PosStyles(align: PosAlign.left));
      printer.feed(1);
      printer.row(
        [
          PosColumn(
            text: 'NO:${estimateData.enquiryid}',
            width: 5,
            styles: const PosStyles(align: PosAlign.left),
          ),
          PosColumn(
            text: 'Date: ${DateFormat('dd-MM-yyyy hh:mm a').format(estimateData.createddate!)}',
            width: 7,
            styles: const PosStyles(align: PosAlign.right),
          ),
        ],
      );
      printer.feed(1);
      printer.setStyles(const PosStyles.defaults());
      printer.text(
        'Bill To:\n\n${estimateData.customer!.customerName ?? ""}\n${estimateData.customer!.address ?? ""},${estimateData.customer!.city ?? ""},${estimateData.customer!.state ?? ""}, ${estimateData.customer!.mobileNo ?? ""}',
        styles: const PosStyles(
          align: PosAlign.center,
          height: PosTextSize.size1,
          width: PosTextSize.size1,
        ),
      );
      printer.feed(1);
      printer.hr();
      printer.row(
        [
          PosColumn(
            text: 'Product',
            width: 5,
            styles: const PosStyles(
              align: PosAlign.left,
              height: PosTextSize.size1,
              width: PosTextSize.size1,
            ),
          ),
          PosColumn(
            text: 'Qty',
            width: 1,
            styles: const PosStyles(
              align: PosAlign.center,
              height: PosTextSize.size1,
              width: PosTextSize.size1,
            ),
          ),
          PosColumn(
            text: 'Rate',
            width: 3,
            styles: const PosStyles(
              align: PosAlign.right,
              height: PosTextSize.size1,
              width: PosTextSize.size1,
            ),
          ),
          PosColumn(
            text: 'Amount',
            width: 3,
            styles: const PosStyles(
              align: PosAlign.right,
              height: PosTextSize.size1,
              width: PosTextSize.size1,
            ),
          ),
        ],
      );

      printer.hr();
      for (int i = 0; i < estimateData.products!.length; i++) {
        printer.row(
          [
            PosColumn(
              text: estimateData.products![i].productName ?? "",
              width: 5,
              styles: const PosStyles(
                align: PosAlign.left,
                height: PosTextSize.size1,
                width: PosTextSize.size1,
              ),
            ),
            PosColumn(
              text: estimateData.products![i].qty != null ? estimateData.products![i].qty.toString() : "",
              width: 1,
              styles: const PosStyles(
                align: PosAlign.center,
                height: PosTextSize.size1,
                width: PosTextSize.size1,
              ),
            ),
            PosColumn(
              text: estimateData.products![i].price != null ? estimateData.products![i].price!.toStringAsFixed(2) : "",
              width: 3,
              styles: const PosStyles(
                align: PosAlign.right,
                height: PosTextSize.size1,
                width: PosTextSize.size1,
              ),
            ),
            PosColumn(
              text: estimateData.products![i].qty != null && estimateData.products![i].price != null
                  ? (double.parse(estimateData.products![i].qty.toString()) * estimateData.products![i].price!)
                      .toStringAsFixed(2)
                  : "",
              width: 3,
              styles: const PosStyles(
                align: PosAlign.right,
                height: PosTextSize.size1,
                width: PosTextSize.size1,
              ),
            ),
          ],
        );
      }
      printer.hr();
      calculationTableView3Inch(printer, "Subtotal", estimateData.price!.subTotal!.toStringAsFixed(2));
      estimateData.price!.discount != 0
          ? calculationTableView3Inch(
              printer,
              "Discount (${estimateData.price!.discount}${estimateData.price!.discountsys})",
              estimateData.price!.discountValue!.toStringAsFixed(2))
          : null;
      estimateData.price!.extraDiscount != 0
          ? calculationTableView3Inch(
              printer,
              "Extra Discount (${estimateData.price!.extraDiscount}${estimateData.price!.extraDiscountsys})",
              estimateData.price!.extraDiscountValue!.toStringAsFixed(2))
          : null;
      estimateData.price!.package != 0
          ? calculationTableView3Inch(
              printer,
              "Package Charges (${estimateData.price!.package}${estimateData.price!.packagesys})",
              estimateData.price!.packageValue!.toStringAsFixed(2))
          : null;

      printer.hr();
      calculationTableView3Inch(printer, "Total", estimateData.price!.total!.toStringAsFixed(2));

      printer.hr();
      printer.row(
        [
          PosColumn(
            text: 'No Product : ${estimateData.products!.length}',
            width: 7,
            styles: const PosStyles(align: PosAlign.left),
          ),
          PosColumn(
            text: 'No QTY : ${getItems()}',
            width: 5,
            styles: const PosStyles(align: PosAlign.right),
          ),
        ],
      );

      printer.feed(0);
      printer.cut();
    } catch (e) {
      log(e.toString());
    }
  }

  calculationTableView3Inch(NetworkPrinter printer, String title, String value) {
    return printer.row(
      [
        PosColumn(
          text: title,
          width: 9,
          styles: PosStyles(align: PosAlign.right, bold: title.toLowerCase() == "total" ? true : false),
        ),
        PosColumn(
          text: value,
          width: 3,
          styles: PosStyles(align: PosAlign.right, bold: title.toLowerCase() == "total" ? true : false),
        ),
      ],
    );
  }

  String getItems() {
    String count = "0";
    int tmpcount = 0;
    for (var element in estimateData.products!) {
      tmpcount += element.qty!;
    }
    count = tmpcount.toString();
    return count;
  }
}

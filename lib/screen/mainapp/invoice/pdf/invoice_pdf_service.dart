import 'dart:typed_data';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:sri_sakthivel_fireworks_pos/firebase/datamodel/datamodel.dart';

import '../../../../firebase/datamodel/invoice_model.dart';
import 'number_to_word.dart';

class InvoicePDFService {
  final String title;
  final InvoiceModel invoice;
  final String total;
  final ProfileModel companyDoc;
  InvoicePDFService({required this.title, required this.invoice, required this.total, required this.companyDoc});

  String totalQty() {
    String total = "0";
    int count = 0;
    for (var element in invoice.listingProducts!) {
      count += element.qty!;
    }
    total = count.toString();
    return total;
  }

  String subTotal() {
    String total = "0.00";
    double count = 0.00;
    for (var element in invoice.listingProducts!) {
      count += element.total!;
    }
    total = count.toStringAsFixed(2);
    return total;
  }

  Future<Uint8List> showA4PDf() async {
    var pdf = pw.Document();

    final companyLogo = companyDoc.companyLogo != null
        ? await networkImage(
            companyDoc.companyLogo!,
          )
        : null;

    pdf.addPage(
      pw.MultiPage(
        margin: const pw.EdgeInsets.all(10),
        pageFormat: PdfPageFormat.a4,
        footer: (context) {
          return pw.Container(
            margin: const pw.EdgeInsets.only(top: 5, bottom: 3),
            child: pw.Center(
              child: pw.Text(
                "Page ${context.pageNumber}/${context.pagesCount}",
                style: const pw.TextStyle(fontSize: 8),
              ),
            ),
          );
        },
        header: (context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Row(
                children: [
                  pw.Expanded(
                    child: pw.SizedBox(),
                  ),
                  pw.Expanded(
                    child: pw.Center(
                      child: pw.Text(
                        "Bill of Supply",
                        textAlign: pw.TextAlign.center,
                        style: pw.TextStyle(
                          fontWeight: pw.FontWeight.bold,
                          fontSize: 10,
                        ),
                      ),
                    ),
                  ),
                  pw.Expanded(
                    child: pw.Text(
                      title,
                      textAlign: pw.TextAlign.right,
                      style: pw.TextStyle(
                        fontWeight: pw.FontWeight.bold,
                        fontSize: 10,
                        fontStyle: pw.FontStyle.italic,
                      ),
                    ),
                  ),
                ],
              ),
              pw.SizedBox(height: 5),
              pw.Table(
                columnWidths: {
                  0: const pw.FlexColumnWidth(1),
                  1: const pw.FlexColumnWidth(1),
                  2: const pw.FlexColumnWidth(1),
                },
                border: pw.TableBorder.symmetric(outside: const pw.BorderSide()),
                children: [
                  pw.TableRow(
                    verticalAlignment: pw.TableCellVerticalAlignment.middle,
                    children: [
                      pw.Padding(
                        padding: const pw.EdgeInsets.symmetric(horizontal: 15),
                        child: pw.SizedBox(
                          height: 50,
                          width: 50,
                          child: companyLogo != null ? pw.Image(companyLogo) : pw.SizedBox(),
                        ),
                      ),
                      pw.Column(
                        children: [
                          pw.SizedBox(height: 5),
                          pw.Center(
                            child: pw.Text(
                              companyDoc.companyName ?? "",
                              style: pw.TextStyle(
                                fontWeight: pw.FontWeight.bold,
                                fontSize: 11,
                              ),
                            ),
                          ),
                          pw.SizedBox(height: 5),
                          pw.Center(
                            child: pw.Text(
                              companyDoc.address ?? "",
                              style: const pw.TextStyle(
                                fontSize: 10,
                              ),
                            ),
                          ),
                          pw.Center(
                            child: pw.Text(
                              companyDoc.city ?? "",
                              style: const pw.TextStyle(
                                fontSize: 10,
                              ),
                            ),
                          ),
                          pw.Center(
                            child: pw.Text(
                              "${companyDoc.state ?? ""} - ${companyDoc.pincode ?? ""}",
                              style: const pw.TextStyle(
                                fontSize: 10,
                              ),
                            ),
                          ),
                          pw.Center(
                            child: pw.Text(
                              "${companyDoc.contact!["mobile"]} ${companyDoc.contact!["phone"]}",
                              style: const pw.TextStyle(
                                fontSize: 10,
                              ),
                            ),
                          ),
                          companyDoc.gstno != null && companyDoc.gstno!.isNotEmpty
                              ? pw.Center(
                                  child: pw.Text(
                                    "GST NO: ${companyDoc.gstno ?? ""}",
                                    style: const pw.TextStyle(
                                      fontSize: 10,
                                    ),
                                  ),
                                )
                              : pw.SizedBox(),
                          pw.SizedBox(height: 5),
                        ],
                      ),
                      pw.SizedBox(),
                    ],
                  ),
                ],
              ),
              context.pageNumber == 1
                  ? pw.Table(
                      columnWidths: {
                        0: const pw.FlexColumnWidth(1),
                        1: const pw.FlexColumnWidth(1),
                        2: const pw.FlexColumnWidth(1),
                      },
                      border: pw.TableBorder.all(),
                      children: [
                        pw.TableRow(
                          children: [
                            pw.Column(
                              crossAxisAlignment: pw.CrossAxisAlignment.start,
                              children: [
                                pw.Padding(
                                  padding: const pw.EdgeInsets.all(5),
                                  child: pw.Text(
                                    "Buyer",
                                    style: pw.TextStyle(
                                      fontWeight: pw.FontWeight.bold,
                                      fontSize: 10,
                                    ),
                                  ),
                                ),
                                pw.Padding(
                                  padding: const pw.EdgeInsets.only(left: 15, bottom: 10),
                                  child: pw.Column(
                                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                                    children: [
                                      pw.Text(
                                        invoice.partyName ?? "",
                                        style: pw.TextStyle(
                                          fontWeight: pw.FontWeight.bold,
                                          fontSize: 10,
                                        ),
                                      ),
                                      pw.Text(
                                        invoice.address ?? "",
                                        style: const pw.TextStyle(
                                          fontSize: 10,
                                        ),
                                      ),
                                      pw.Text(
                                        invoice.phoneNumber ?? "",
                                        style: const pw.TextStyle(
                                          fontSize: 10,
                                        ),
                                      ),
                                    ],
                                  ),
                                )
                              ],
                            ),
                            pw.Column(
                              crossAxisAlignment: pw.CrossAxisAlignment.start,
                              children: [
                                pw.Padding(
                                  padding: const pw.EdgeInsets.all(5),
                                  child: pw.Text(
                                    "Delivery Address",
                                    style: pw.TextStyle(
                                      fontWeight: pw.FontWeight.bold,
                                      fontSize: 10,
                                    ),
                                  ),
                                ),
                                pw.Padding(
                                  padding: const pw.EdgeInsets.only(left: 15, bottom: 10),
                                  child: pw.Column(
                                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                                    children: [
                                      pw.Text(
                                        invoice.deliveryaddress ?? "",
                                        style: const pw.TextStyle(
                                          fontSize: 10,
                                        ),
                                      ),
                                    ],
                                  ),
                                )
                              ],
                            ),
                            pw.Column(
                              crossAxisAlignment: pw.CrossAxisAlignment.start,
                              children: [
                                pw.Padding(
                                  padding: const pw.EdgeInsets.all(5),
                                  child: pw.Text(
                                    "Transport Details",
                                    style: pw.TextStyle(
                                      fontWeight: pw.FontWeight.bold,
                                      fontSize: 10,
                                    ),
                                  ),
                                ),
                                pw.Padding(
                                  padding: const pw.EdgeInsets.only(left: 15, bottom: 10),
                                  child: pw.Column(
                                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                                    children: [
                                      pw.Text(
                                        invoice.transportName ?? "",
                                        style: const pw.TextStyle(
                                          fontSize: 10,
                                        ),
                                      ),
                                      pw.Text(
                                        invoice.transportNumber ?? "",
                                        style: const pw.TextStyle(
                                          fontSize: 10,
                                        ),
                                      ),
                                    ],
                                  ),
                                )
                              ],
                            ),
                          ],
                        ),
                      ],
                    )
                  : pw.SizedBox(),
              context.pageNumber == 1
                  ? pw.Table(
                      columnWidths: {
                        0: const pw.FlexColumnWidth(1),
                        1: const pw.FlexColumnWidth(1),
                      },
                      border: pw.TableBorder.symmetric(
                        outside: const pw.BorderSide(),
                      ),
                      children: [
                        pw.TableRow(
                          children: [
                            pw.Padding(
                              padding: const pw.EdgeInsets.all(5),
                              child: pw.Text(
                                "Invoice No: ${invoice.billNo ?? ""}",
                                textAlign: pw.TextAlign.left,
                                style: pw.TextStyle(
                                  fontWeight: pw.FontWeight.bold,
                                  fontSize: 10,
                                ),
                              ),
                            ),
                            pw.Padding(
                              padding: const pw.EdgeInsets.all(5),
                              child: pw.Text(
                                "Date: ${DateFormat("dd-MM-yyyy").format(invoice.biilDate!)}",
                                textAlign: pw.TextAlign.right,
                                style: pw.TextStyle(
                                  fontWeight: pw.FontWeight.bold,
                                  fontSize: 10,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    )
                  : pw.SizedBox(),
              pw.Table(
                columnWidths: {
                  0: const pw.FlexColumnWidth(1.3),
                  1: const pw.FlexColumnWidth(6),
                  2: const pw.FlexColumnWidth(2.5),
                  3: const pw.FlexColumnWidth(2),
                  4: const pw.FlexColumnWidth(3),
                  5: const pw.FlexColumnWidth(3),
                },
                border: pw.TableBorder.all(),
                children: [
                  pw.TableRow(
                    children: [
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(3),
                        child: pw.Center(
                          child: pw.Text(
                            "S.NO",
                            textAlign: pw.TextAlign.center,
                            style: pw.TextStyle(
                              fontWeight: pw.FontWeight.bold,
                              fontSize: 10,
                            ),
                          ),
                        ),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(3),
                        child: pw.Center(
                          child: pw.Text(
                            "PRODUCTS",
                            textAlign: pw.TextAlign.center,
                            style: pw.TextStyle(
                              fontWeight: pw.FontWeight.bold,
                              fontSize: 10,
                            ),
                          ),
                        ),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(3),
                        child: pw.Center(
                          child: pw.Text(
                            "UNIT",
                            textAlign: pw.TextAlign.center,
                            style: pw.TextStyle(
                              fontWeight: pw.FontWeight.bold,
                              fontSize: 10,
                            ),
                          ),
                        ),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(3),
                        child: pw.Center(
                          child: pw.Text(
                            "QTY",
                            textAlign: pw.TextAlign.center,
                            style: pw.TextStyle(
                              fontWeight: pw.FontWeight.bold,
                              fontSize: 10,
                            ),
                          ),
                        ),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(3),
                        child: pw.Center(
                          child: pw.Text(
                            "RATE/QTY",
                            textAlign: pw.TextAlign.center,
                            style: pw.TextStyle(
                              fontWeight: pw.FontWeight.bold,
                              fontSize: 10,
                            ),
                          ),
                        ),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(3),
                        child: pw.Center(
                          child: pw.Text(
                            "AMOUNT",
                            textAlign: pw.TextAlign.center,
                            style: pw.TextStyle(
                              fontWeight: pw.FontWeight.bold,
                              fontSize: 10,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          );
        },
        build: (pw.Context context) {
          return [
            pw.Table(
              columnWidths: {
                0: const pw.FlexColumnWidth(1.3),
                1: const pw.FlexColumnWidth(6),
                2: const pw.FlexColumnWidth(2.5),
                3: const pw.FlexColumnWidth(2),
                4: const pw.FlexColumnWidth(3),
                5: const pw.FlexColumnWidth(3),
              },
              border: pw.TableBorder.all(),
              children: [
                for (int i = 0; i < invoice.listingProducts!.length; i++)
                  pw.TableRow(
                    children: [
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(3),
                        child: pw.Center(
                          child: pw.Text(
                            (i + 1).toString(),
                            textAlign: pw.TextAlign.center,
                            style: const pw.TextStyle(
                              fontSize: 10,
                            ),
                          ),
                        ),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(3),
                        child: pw.Text(
                          invoice.listingProducts?[i].productName ?? "",
                          textAlign: pw.TextAlign.left,
                          style: const pw.TextStyle(
                            fontSize: 10,
                          ),
                        ),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(3),
                        child: pw.Center(
                          child: pw.Text(
                            invoice.listingProducts?[i].unit ?? "",
                            textAlign: pw.TextAlign.center,
                            style: const pw.TextStyle(
                              fontSize: 10,
                            ),
                          ),
                        ),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(3),
                        child: pw.Center(
                          child: pw.Text(
                            invoice.listingProducts?[i].qty.toString() ?? "",
                            textAlign: pw.TextAlign.center,
                            style: const pw.TextStyle(
                              fontSize: 10,
                            ),
                          ),
                        ),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(3),
                        child: pw.Center(
                          child: pw.Text(
                            double.parse(invoice.listingProducts?[i].rate.toString() ?? "0").toStringAsFixed(2),
                            textAlign: pw.TextAlign.center,
                            style: const pw.TextStyle(
                              fontSize: 10,
                            ),
                          ),
                        ),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(3),
                        child: pw.Text(
                          double.parse(invoice.listingProducts?[i].total.toString() ?? "0").toStringAsFixed(2),
                          textAlign: pw.TextAlign.right,
                          style: pw.TextStyle(
                            fontWeight: pw.FontWeight.bold,
                            fontSize: 10,
                          ),
                        ),
                      ),
                    ],
                  ),
              ],
            ),
            // pw.Table(
            //   defaultVerticalAlignment: pw.TableCellVerticalAlignment.full,
            //   columnWidths: {
            //     0: const pw.FlexColumnWidth(1.3),
            //     1: const pw.FlexColumnWidth(6),
            //     2: const pw.FlexColumnWidth(2.5),
            //     3: const pw.FlexColumnWidth(2),
            //     4: const pw.FlexColumnWidth(3),
            //     5: const pw.FlexColumnWidth(3),
            //   },
            //   border: pw.TableBorder.all(),
            //   children: [
            //     pw.TableRow(
            //       children: [
            //         pw.Container(
            //           child: pw.Column(mainAxisSize: pw.MainAxisSize.max),
            //         ),
            //         pw.Container(
            //           child: pw.Expanded(
            //             child: pw.SizedBox(),
            //           ),
            //         ),
            //         pw.Container(
            //           child: pw.Expanded(
            //             child: pw.SizedBox(),
            //           ),
            //         ),
            //         pw.Container(
            //           child: pw.Expanded(
            //             child: pw.SizedBox(),
            //           ),
            //         ),
            //         pw.Container(
            //           child: pw.Expanded(
            //             child: pw.SizedBox(),
            //           ),
            //         ),
            //         pw.Container(
            //           child: pw.Expanded(
            //             child: pw.SizedBox(),
            //           ),
            //         ),
            //       ],
            //     ),
            //   ],
            // ),
            // pw.Table(
            //   border: pw.TableBorder.all(),
            //   children: [
            //     pw.TableRow(
            //       children: [
            //         pw.Container(
            //           height: 50,
            //         ),
            //         pw.Container(
            //           height: 50,
            //         ),
            //         pw.Container(
            //           height: 50,
            //         ),
            //         // ...add other children here
            //       ],
            //     ),
            //   ],
            // ),

            pw.Expanded(
              child: pw.Container(
                decoration: pw.BoxDecoration(
                  border: pw.TableBorder.all(),
                ),
                child: pw.Row(
                  children: [
                    pw.Container(
                      width: 42,
                      decoration: const pw.BoxDecoration(
                        border: pw.Border(
                          right: pw.BorderSide(),
                        ),
                      ),
                    ),
                    pw.Container(
                      width: 194,
                      decoration: const pw.BoxDecoration(
                        border: pw.Border(
                          right: pw.BorderSide(),
                        ),
                      ),
                    ),
                    pw.Container(
                      width: 80.7,
                      decoration: const pw.BoxDecoration(
                        border: pw.Border(
                          right: pw.BorderSide(),
                        ),
                      ),
                    ),
                    pw.Container(
                      width: 64.7,
                      decoration: const pw.BoxDecoration(
                        border: pw.Border(
                          right: pw.BorderSide(),
                        ),
                      ),
                    ),
                    pw.Container(
                      width: 97,
                      decoration: const pw.BoxDecoration(
                        border: pw.Border(
                          right: pw.BorderSide(),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            pw.Container(
              child: pw.Column(
                mainAxisSize: pw.MainAxisSize.min,
                children: [
                  pw.Table(
                    columnWidths: {
                      0: const pw.FlexColumnWidth(1.3),
                      1: const pw.FlexColumnWidth(6),
                      2: const pw.FlexColumnWidth(2.5),
                      3: const pw.FlexColumnWidth(2),
                      4: const pw.FlexColumnWidth(3),
                      5: const pw.FlexColumnWidth(3),
                    },
                    border: pw.TableBorder.all(),
                    children: [
                      pw.TableRow(
                        children: [
                          pw.Padding(
                            padding: const pw.EdgeInsets.all(3),
                            child: pw.Center(
                              child: pw.Text(
                                "",
                                textAlign: pw.TextAlign.center,
                                style: const pw.TextStyle(
                                  fontSize: 10,
                                ),
                              ),
                            ),
                          ),
                          pw.Padding(
                            padding: const pw.EdgeInsets.all(3),
                            child: pw.Text(
                              "Goods Value Upto Previous Bill Rs.",
                              textAlign: pw.TextAlign.right,
                              style: const pw.TextStyle(
                                fontSize: 10,
                              ),
                            ),
                          ),
                          pw.Padding(
                            padding: const pw.EdgeInsets.all(3),
                            child: pw.Text(
                              total,
                              textAlign: pw.TextAlign.right,
                              style: const pw.TextStyle(
                                fontSize: 10,
                              ),
                            ),
                          ),
                          pw.Padding(
                            padding: const pw.EdgeInsets.all(3),
                            child: pw.Center(
                              child: pw.Text(""),
                            ),
                          ),
                          pw.Padding(
                            padding: const pw.EdgeInsets.all(3),
                            child: pw.Center(
                              child: pw.Text(""),
                            ),
                          ),
                          pw.Padding(
                            padding: const pw.EdgeInsets.all(3),
                            child: pw.Text(""),
                          ),
                        ],
                      ),
                      pw.TableRow(
                        children: [
                          pw.Padding(
                            padding: const pw.EdgeInsets.all(3),
                            child: pw.Center(
                              child: pw.Text(
                                "",
                                textAlign: pw.TextAlign.center,
                                style: const pw.TextStyle(
                                  fontSize: 10,
                                ),
                              ),
                            ),
                          ),
                          pw.Padding(
                            padding: const pw.EdgeInsets.all(3),
                            child: pw.Text(
                              "Goods Value for bill Rs.",
                              textAlign: pw.TextAlign.right,
                              style: const pw.TextStyle(
                                fontSize: 10,
                              ),
                            ),
                          ),
                          pw.Padding(
                            padding: const pw.EdgeInsets.all(3),
                            child: pw.Text(
                              invoice.price?.total?.toStringAsFixed(2) ?? "",
                              textAlign: pw.TextAlign.right,
                              style: const pw.TextStyle(
                                fontSize: 10,
                              ),
                            ),
                          ),
                          pw.Padding(
                            padding: const pw.EdgeInsets.all(3),
                            child: pw.Center(
                              child: pw.Text(""),
                            ),
                          ),
                          pw.Padding(
                            padding: const pw.EdgeInsets.all(3),
                            child: pw.Center(
                              child: pw.Text(""),
                            ),
                          ),
                          pw.Padding(
                            padding: const pw.EdgeInsets.all(3),
                            child: pw.Text(""),
                          ),
                        ],
                      ),
                      pw.TableRow(
                        children: [
                          pw.Padding(
                            padding: const pw.EdgeInsets.all(3),
                            child: pw.Center(
                              child: pw.Text(
                                "",
                                textAlign: pw.TextAlign.center,
                                style: const pw.TextStyle(
                                  fontSize: 10,
                                ),
                              ),
                            ),
                          ),
                          pw.Padding(
                            padding: const pw.EdgeInsets.all(3),
                            child: pw.Text(
                              "Total Rs.",
                              textAlign: pw.TextAlign.right,
                              style: const pw.TextStyle(
                                fontSize: 10,
                              ),
                            ),
                          ),
                          pw.Padding(
                            padding: const pw.EdgeInsets.all(3),
                            child: pw.Text(
                              (double.parse(total) + invoice.price!.total!).toStringAsFixed(2),
                              textAlign: pw.TextAlign.right,
                              style: const pw.TextStyle(
                                fontSize: 10,
                              ),
                            ),
                          ),
                          pw.Padding(
                            padding: const pw.EdgeInsets.all(3),
                            child: pw.Center(
                              child: pw.Text(""),
                            ),
                          ),
                          pw.Padding(
                            padding: const pw.EdgeInsets.all(3),
                            child: pw.Center(
                              child: pw.Text(""),
                            ),
                          ),
                          pw.Padding(
                            padding: const pw.EdgeInsets.all(3),
                            child: pw.Text(""),
                          ),
                        ],
                      ),
                    ],
                  ),
                  pw.Table(
                    columnWidths: {
                      0: const pw.FlexColumnWidth(9.8),
                      1: const pw.FlexColumnWidth(2),
                      2: const pw.FlexColumnWidth(3),
                      3: const pw.FlexColumnWidth(3),
                    },
                    border: pw.TableBorder.all(),
                    children: [
                      pw.TableRow(
                        children: [
                          pw.Padding(
                            padding: const pw.EdgeInsets.all(3),
                            child: pw.Row(
                              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                              children: [
                                pw.Text(
                                  "Total Products (${invoice.listingProducts!.length})",
                                  textAlign: pw.TextAlign.left,
                                  style: pw.TextStyle(
                                    fontWeight: pw.FontWeight.bold,
                                    fontSize: 10,
                                  ),
                                ),
                                pw.Text(
                                  "Total QTY",
                                  textAlign: pw.TextAlign.right,
                                  style: pw.TextStyle(
                                    fontWeight: pw.FontWeight.bold,
                                    fontSize: 10,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          pw.Padding(
                            padding: const pw.EdgeInsets.all(3),
                            child: pw.Center(
                              child: pw.Text(
                                totalQty(),
                                textAlign: pw.TextAlign.center,
                                style: pw.TextStyle(
                                  fontWeight: pw.FontWeight.bold,
                                  fontSize: 10,
                                ),
                              ),
                            ),
                          ),
                          pw.Padding(
                            padding: const pw.EdgeInsets.all(3),
                            child: pw.Text(
                              "Sub Total",
                              textAlign: pw.TextAlign.right,
                              style: pw.TextStyle(
                                fontWeight: pw.FontWeight.bold,
                                fontSize: 10,
                              ),
                            ),
                          ),
                          pw.Padding(
                            padding: const pw.EdgeInsets.all(3),
                            child: pw.Text(
                              // subTotal(),
                              invoice.price?.subTotal?.toStringAsFixed(2) ?? "",
                              textAlign: pw.TextAlign.right,
                              style: pw.TextStyle(
                                fontWeight: pw.FontWeight.bold,
                                fontSize: 10,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  invoice.price?.discountValue != null && invoice.price!.discountValue! > 0.0
                      ? pw.Table(
                          columnWidths: {
                            0: const pw.FlexColumnWidth(14.8),
                            1: const pw.FlexColumnWidth(3),
                          },
                          border: pw.TableBorder.all(),
                          children: [
                            pw.TableRow(
                              children: [
                                pw.Padding(
                                  padding: const pw.EdgeInsets.all(3),
                                  child: pw.Text(
                                    "Discount",
                                    textAlign: pw.TextAlign.right,
                                    style: pw.TextStyle(
                                      fontWeight: pw.FontWeight.bold,
                                      fontSize: 10,
                                    ),
                                  ),
                                ),
                                pw.Padding(
                                  padding: const pw.EdgeInsets.all(3),
                                  child: pw.Text(
                                    invoice.price?.discountValue?.toStringAsFixed(2) ?? "",
                                    textAlign: pw.TextAlign.right,
                                    style: pw.TextStyle(
                                      fontWeight: pw.FontWeight.bold,
                                      fontSize: 10,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        )
                      : pw.SizedBox(),
                  invoice.price?.extraDiscountValue != null && invoice.price!.extraDiscountValue! > 0.0
                      ? pw.Table(
                          columnWidths: {
                            0: const pw.FlexColumnWidth(14.8),
                            1: const pw.FlexColumnWidth(3),
                          },
                          border: pw.TableBorder.all(),
                          children: [
                            pw.TableRow(
                              children: [
                                pw.Padding(
                                  padding: const pw.EdgeInsets.all(3),
                                  child: pw.Text(
                                    "Extra Discount",
                                    textAlign: pw.TextAlign.right,
                                    style: pw.TextStyle(
                                      fontWeight: pw.FontWeight.bold,
                                      fontSize: 10,
                                    ),
                                  ),
                                ),
                                pw.Padding(
                                  padding: const pw.EdgeInsets.all(3),
                                  child: pw.Text(
                                    invoice.price?.extraDiscountValue?.toStringAsFixed(2) ?? "",
                                    textAlign: pw.TextAlign.right,
                                    style: pw.TextStyle(
                                      fontWeight: pw.FontWeight.bold,
                                      fontSize: 10,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        )
                      : pw.SizedBox(),
                  invoice.price?.packageValue != null && invoice.price!.packageValue! > 0.0
                      ? pw.Table(
                          columnWidths: {
                            0: const pw.FlexColumnWidth(14.8),
                            1: const pw.FlexColumnWidth(3),
                          },
                          border: pw.TableBorder.all(),
                          children: [
                            pw.TableRow(
                              children: [
                                pw.Padding(
                                  padding: const pw.EdgeInsets.all(3),
                                  child: pw.Text(
                                    "Packing Charges",
                                    textAlign: pw.TextAlign.right,
                                    style: pw.TextStyle(
                                      fontWeight: pw.FontWeight.bold,
                                      fontSize: 10,
                                    ),
                                  ),
                                ),
                                pw.Padding(
                                  padding: const pw.EdgeInsets.all(3),
                                  child: pw.Text(
                                    invoice.price?.packageValue?.toStringAsFixed(2) ?? "",
                                    textAlign: pw.TextAlign.right,
                                    style: pw.TextStyle(
                                      fontWeight: pw.FontWeight.bold,
                                      fontSize: 10,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        )
                      : pw.SizedBox(),
                  pw.Table(
                    columnWidths: {
                      0: const pw.FlexColumnWidth(14.8),
                      1: const pw.FlexColumnWidth(3),
                    },
                    border: pw.TableBorder.all(),
                    children: [
                      pw.TableRow(
                        children: [
                          pw.Padding(
                            padding: const pw.EdgeInsets.all(3),
                            child: pw.Text(
                              "Total",
                              textAlign: pw.TextAlign.right,
                              style: pw.TextStyle(
                                fontWeight: pw.FontWeight.bold,
                                fontSize: 10,
                              ),
                            ),
                          ),
                          pw.Padding(
                            padding: const pw.EdgeInsets.all(3),
                            child: pw.Text(
                              invoice.price?.total?.toStringAsFixed(2) ?? "",
                              textAlign: pw.TextAlign.right,
                              style: pw.TextStyle(
                                fontWeight: pw.FontWeight.bold,
                                fontSize: 10,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  pw.Table(
                    columnWidths: {
                      0: const pw.FlexColumnWidth(1.1),
                      1: const pw.FlexColumnWidth(5),
                    },
                    border: pw.TableBorder.all(),
                    children: [
                      pw.TableRow(
                        children: [
                          pw.Padding(
                            padding: const pw.EdgeInsets.all(3),
                            child: pw.Text(
                              "Amount(in Words)",
                              style: pw.TextStyle(
                                fontWeight: pw.FontWeight.bold,
                                fontSize: 10,
                              ),
                            ),
                          ),
                          pw.Padding(
                            padding: const pw.EdgeInsets.all(3),
                            child: pw.Text(
                              // NumberToWordsEnglish.convert(int.parse(double.parse(subTotal()).toStringAsFixed(0)))
                              //     .toString(),
                              // NumberToWordsEnglish.convert(114000),
                              AmountToWords()
                                  .convertAmountToWords(double.parse(invoice.price!.total!.toStringAsFixed(0))),
                              // NumberToWordConverter.convert(number: 100000),
                              style: pw.TextStyle(
                                fontWeight: pw.FontWeight.bold,
                                fontSize: 10,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  pw.Table(
                    defaultVerticalAlignment: pw.TableCellVerticalAlignment.bottom,
                    columnWidths: {
                      0: const pw.FlexColumnWidth(3),
                      1: const pw.FlexColumnWidth(1),
                    },
                    border: pw.TableBorder.symmetric(
                      outside: const pw.BorderSide(),
                    ),
                    children: [
                      pw.TableRow(
                        children: [
                          pw.Padding(
                            padding: const pw.EdgeInsets.all(5),
                            child: pw.Column(
                              crossAxisAlignment: pw.CrossAxisAlignment.start,
                              children: [
                                pw.Text(
                                  "Declaration",
                                  style: pw.TextStyle(
                                    fontWeight: pw.FontWeight.bold,
                                    fontSize: 9,
                                    decoration: pw.TextDecoration.underline,
                                  ),
                                ),
                                pw.SizedBox(height: 5),
                                pw.Text(
                                  "We declare that this bill shows the actual price of the goods\ndescribed and that all particulars are true and correct\nComposition dealer is not eligible to collect the taxes on supply",
                                  style: const pw.TextStyle(
                                    fontSize: 9,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          pw.Padding(
                            padding: const pw.EdgeInsets.all(5),
                            child: pw.Container(
                              alignment: pw.Alignment.bottomCenter,
                              child: pw.Text(
                                "Authorised Signatory",
                                textAlign: pw.TextAlign.center,
                                style: const pw.TextStyle(
                                  fontSize: 9,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ];
        },
      ),
    );

    return await pdf.save();
  }
}

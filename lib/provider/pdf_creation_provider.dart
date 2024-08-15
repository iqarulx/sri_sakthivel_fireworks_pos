import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:pdf/widgets.dart';
import 'package:printing/printing.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';

import '../firebase/datamodel/datamodel.dart';

import 'package:pdf/pdf.dart' as pf;
import 'package:pdf/widgets.dart' as pw;

class PdfCreationProvider {
  String companyName;
  String companyAddress;
  List<PriceListCategoryDataModel> priceList;
  PdfCreationProvider({
    required this.companyName,
    required this.companyAddress,
    required this.priceList,
  });
  Future<List<int>?> createProceList() async {
    // Return Pdf Data
    List<int>? bytes;

    // Ini New Doucument
    final PdfDocument document = PdfDocument();

    // Page Orientation
    document.pageSettings.orientation = PdfPageOrientation.portrait;
    // Page Margins
    document.pageSettings.margins.all = 20;
    // Page Size
    document.pageSettings.size = PdfPageSize.a4;
    PdfSection section = document.sections!.add();

    PdfPageTemplateElement topHeader = PdfPageTemplateElement(
      Rect.fromLTWH(0, 0, document.pageSettings.size.width + 2, 71),
    );

    // topHeader.

    PdfGrid headergrid = PdfGrid();
    headergrid.columns.add(count: 6);
    headergrid.headers.add(1);

    //Add the rows to the grid
    PdfGridRow headergridrow = headergrid.headers[0];

    PdfStringFormat headerformat = PdfStringFormat();
    headerformat.alignment = PdfTextAlignment.center;
    headerformat.lineAlignment = PdfVerticalAlignment.middle;

    headergridrow.cells[0].value = '$companyName,\n$companyAddress';
    headergridrow.cells[0].columnSpan = 6;
    headergridrow.cells[0].stringFormat = headerformat;

    // //Add rows to grid
    PdfGridRow headerrow = headergrid.rows.add();
    headerrow.cells[0].value = 'Price List';
    headerrow.cells[0].columnSpan = 6;
    headerrow.cells[0].stringFormat = headerformat;

    headerrow = headergrid.rows.add();

    headerrow.cells[0].value = 'Product Code';
    headerrow.cells[1].value = 'Product Name';
    headerrow.cells[2].value = 'Content';
    headerrow.cells[3].value = 'Qnt';
    headerrow.cells[4].value = 'Price';
    headerrow.cells[5].value = 'Amount';
    headerrow.cells[0].stringFormat = headerformat;
    headerrow.cells[1].stringFormat = headerformat;
    headerrow.cells[2].stringFormat = headerformat;
    headerrow.cells[3].stringFormat = headerformat;
    headerrow.cells[4].stringFormat = headerformat;
    headerrow.cells[5].stringFormat = headerformat;

    headergrid.draw(
      graphics: topHeader.graphics,
    );

    document.template.top = topHeader;

    // Table Creation
    PdfGrid grid = PdfGrid();
    grid.columns.add(count: 6);

    PdfStringFormat format = PdfStringFormat();
    format.alignment = PdfTextAlignment.center;
    format.lineAlignment = PdfVerticalAlignment.middle;

    PdfGridCellStyle style = PdfGridCellStyle(
      cellPadding: PdfPaddings(left: 2, right: 2, top: 2, bottom: 2),
      backgroundBrush: PdfBrushes.lightGray,
      textBrush: PdfBrushes.black,
    );

    // //Add rows to grid
    int count = 1;
    for (int i = 0; i < priceList.length; i++) {
      PdfGridRow row = grid.rows.add();
      row.cells[0].value = priceList[i].categoryName.toString();
      row.cells[0].columnSpan = 6;
      row.cells[0].stringFormat = format;
      row.cells[0].style = style;
      for (var j = 0; j < priceList[i].productModel!.length; j++) {
        var prodData = priceList[i].productModel![j];
        row = grid.rows.add();
        row.cells[0].value = '$count';
        row.cells[1].value = prodData.prodcutName;
        row.cells[2].value = prodData.content;
        row.cells[3].value = '';
        row.cells[4].value = prodData.price;
        row.cells[5].value = '';
        count++;
      }
    }

    // row = grid.rows.add();
    // row.cells[0].value = 'E02';
    // row.cells[1].value = 'Simon';
    // row.cells[2].value = '\$12,000';

    //Set the grid style
    grid.style = PdfGridStyle(
      cellPadding: PdfPaddings(left: 2, right: 2, top: 2, bottom: 2),
      textBrush: PdfBrushes.black,
    );

    //Draw the grid
    grid.draw(
      page: section.pages.add(),
    );

    //Save and dispose the PDF document
    // Directory dir = Directory('/storage/emulated/0/Download');
    bytes = await document.save();

    // File('${dir.path}/SampleOutput.pdf').writeAsBytes(await document.save());
    document.dispose();
    return bytes;
  }

  int code = 0;
  productTableList(PriceListProdcutDataModel prod, Font? font) {
    code += 1;
    return pw.Table(
      columnWidths: {
        0: const pw.FlexColumnWidth(1),
        1: const pw.FlexColumnWidth(6),
        2: const pw.FlexColumnWidth(2),
        3: const pw.FlexColumnWidth(2),
        4: const pw.FlexColumnWidth(2),
        5: const pw.FlexColumnWidth(2),
      },
      border: pw.TableBorder.all(),
      children: [
        pw.TableRow(
          children: [
            pw.Center(
              child: pw.Padding(
                padding: const pw.EdgeInsets.all(2),
                child: pw.Text(
                  "$code",
                  style: pw.TextStyle(
                    fontSize: 10,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
              ),
            ),
            pw.Center(
              child: pw.Padding(
                padding: const pw.EdgeInsets.all(2),
                child: pw.Text(
                  prod.prodcutName ?? "",
                  style: pw.TextStyle(
                    font: font,
                    fontSize: 10,
                  ),
                ),
              ),
            ),
            pw.Center(
              child: pw.Padding(
                padding: const pw.EdgeInsets.all(2),
                child: pw.Text(
                  prod.content ?? "",
                  style: const pw.TextStyle(
                    fontSize: 10,
                  ),
                ),
              ),
            ),
            pw.Center(
              child: pw.Padding(
                padding: const pw.EdgeInsets.all(2),
                child: pw.Text(
                  "",
                  style: pw.TextStyle(
                    fontSize: 10,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
              ),
            ),
            pw.Center(
              child: pw.Padding(
                padding: const pw.EdgeInsets.all(2),
                child: pw.Text(
                  prod.price ?? "",
                  style: const pw.TextStyle(
                    fontSize: 10,
                  ),
                ),
              ),
            ),
            pw.Center(
              child: pw.Padding(
                padding: const pw.EdgeInsets.all(2),
                child: pw.Text(
                  "",
                  style: pw.TextStyle(
                    fontSize: 10,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Future<Uint8List> createPriceList() async {
    final font = await PdfGoogleFonts.notoSansTamilRegular();
    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        margin: const pw.EdgeInsets.all(10),
        pageFormat: pf.PdfPageFormat.a4,
        header: (context) {
          return pw.Column(
            children: [
              pw.Table(
                border: const pw.TableBorder(
                  left: pw.BorderSide(color: pf.PdfColors.black),
                  top: pw.BorderSide(color: pf.PdfColors.black),
                  right: pw.BorderSide(color: pf.PdfColors.black),
                  bottom: pw.BorderSide(color: pf.PdfColors.black),
                ),
                children: [
                  pw.TableRow(
                    children: [
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(2),
                        child: pw.Center(
                          child: pw.Column(
                            mainAxisSize: pw.MainAxisSize.min,
                            children: [
                              pw.Text(
                                companyName,
                                style: pw.TextStyle(
                                  fontWeight: pw.FontWeight.bold,
                                  fontSize: 10,
                                ),
                              ),
                              pw.Text(
                                companyAddress,
                                textAlign: pw.TextAlign.center,
                                style: const pw.TextStyle(
                                  fontSize: 10,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              pw.Table(
                border: const pw.TableBorder(
                  left: pw.BorderSide(color: pf.PdfColors.black),
                  top: pw.BorderSide(color: pf.PdfColors.black),
                  right: pw.BorderSide(color: pf.PdfColors.black),
                  bottom: pw.BorderSide(color: pf.PdfColors.black),
                ),
                children: [
                  pw.TableRow(
                    children: [
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(2),
                        child: pw.Center(
                          child: pw.Column(
                            mainAxisSize: pw.MainAxisSize.min,
                            children: [
                              pw.Text(
                                "Price List",
                                style: pw.TextStyle(
                                  fontWeight: pw.FontWeight.bold,
                                  fontSize: 10,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              pw.Table(
                columnWidths: {
                  0: const pw.FlexColumnWidth(1),
                  1: const pw.FlexColumnWidth(6),
                  2: const pw.FlexColumnWidth(2),
                  3: const pw.FlexColumnWidth(2),
                  4: const pw.FlexColumnWidth(2),
                  5: const pw.FlexColumnWidth(2),
                },
                border: pw.TableBorder.all(),
                children: [
                  pw.TableRow(
                    children: [
                      pw.Center(
                        child: pw.Padding(
                          padding: const pw.EdgeInsets.all(2),
                          child: pw.Text(
                            "CODE",
                            style: pw.TextStyle(
                              fontSize: 10,
                              fontWeight: pw.FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      pw.Center(
                        child: pw.Padding(
                          padding: const pw.EdgeInsets.all(2),
                          child: pw.Text(
                            "PRODUCT NAME",
                            style: pw.TextStyle(
                              fontSize: 10,
                              fontWeight: pw.FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      pw.Center(
                        child: pw.Padding(
                          padding: const pw.EdgeInsets.all(2),
                          child: pw.Text(
                            "CONTENT",
                            style: pw.TextStyle(
                              fontSize: 10,
                              fontWeight: pw.FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      pw.Center(
                        child: pw.Padding(
                          padding: const pw.EdgeInsets.all(2),
                          child: pw.Text(
                            "QTY",
                            style: pw.TextStyle(
                              fontSize: 10,
                              fontWeight: pw.FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      pw.Center(
                        child: pw.Padding(
                          padding: const pw.EdgeInsets.all(2),
                          child: pw.Text(
                            "RATE",
                            style: pw.TextStyle(
                              fontSize: 10,
                              fontWeight: pw.FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      pw.Center(
                        child: pw.Padding(
                          padding: const pw.EdgeInsets.all(2),
                          child: pw.Text(
                            "AMOUNT",
                            style: pw.TextStyle(
                              fontSize: 10,
                              fontWeight: pw.FontWeight.bold,
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
        build: (context) {
          return [
            for (int i = 0; i < priceList.length; i++)
              pw.Column(
                children: [
                  pw.Table(
                    border: const pw.TableBorder(
                      left: pw.BorderSide(color: pf.PdfColors.black),
                      top: pw.BorderSide(color: pf.PdfColors.black),
                      right: pw.BorderSide(color: pf.PdfColors.black),
                      bottom: pw.BorderSide(color: pf.PdfColors.black),
                    ),
                    children: [
                      pw.TableRow(
                        decoration: const pw.BoxDecoration(color: pf.PdfColors.grey300),
                        children: [
                          pw.Padding(
                            padding: const pw.EdgeInsets.all(2),
                            child: pw.Center(
                              child: pw.Column(
                                mainAxisSize: pw.MainAxisSize.min,
                                children: [
                                  pw.Text(
                                    priceList[i].categoryName ?? "",
                                    style: pw.TextStyle(
                                      fontWeight: pw.FontWeight.bold,
                                      fontSize: 10,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  for (int j = 0; j < priceList[i].productModel!.length; j++)
                    productTableList(priceList[i].productModel![j], font),
                ],
              ),
          ];
        },
      ),
    );

    return await pdf.save();
  }
}

enum PdfType { estimate, enquiry }

class EnqueryPdfCreation {
  final EstimateDataModel estimateData;
  final PdfType type;
  final ProfileModel companyInfo;
  EnqueryPdfCreation({
    required this.estimateData,
    required this.type,
    required this.companyInfo,
  });

  Future<List<int>?> createPdfA4() async {
    List<int>? resultData;

    PdfDocument document = PdfDocument();

    document.pageSettings.size = PdfPageSize.a4;
    document.pageSettings.margins.all = 10;

    // Pdf Page Header Section Start

    // Create Header size
    PdfPageTemplateElement header = PdfPageTemplateElement(
      Rect.fromLTWH(0, 0, document.pageSettings.size.width - 2, 162),
    );

    // Grid Varable
    PdfGrid headerGrid = PdfGrid();

    // Assign Column 3
    headerGrid.columns.add(count: 7);
    headerGrid.headers.add(1);

    headerGrid.columns[0].width = 31;
    headerGrid.columns[1].width = 41;
    headerGrid.columns[3].width = 41;
    headerGrid.columns[4].width = 41.5;
    headerGrid.columns[5].width = 41.5;
    headerGrid.columns[6].width = 82.5;

    PdfGridRow titleHeader = headerGrid.headers[0];
    titleHeader.cells[0].value =
        'Estimate ID: ${type == PdfType.enquiry ? estimateData.enquiryid : estimateData.estimateid}';
    titleHeader.cells[2].value = 'Estimate';
    titleHeader.cells[5].value = 'Date: ${DateFormat('dd-MM-yyyy HH:mm a').format(estimateData.createddate!)}';

    // Header Style Start
    titleHeader.cells[0].columnSpan = 2;
    titleHeader.cells[2].columnSpan = 3;
    titleHeader.cells[5].columnSpan = 2;
    titleHeader.cells[0].style = PdfGridCellStyle(
      borders: PdfBorders(right: PdfPens.transparent),
      format: PdfStringFormat(
        alignment: PdfTextAlignment.left,
        lineAlignment: PdfVerticalAlignment.middle,
        characterSpacing: 0.2,
      ),
    );
    titleHeader.cells[2].style = PdfGridCellStyle(
      borders: PdfBorders(
        right: PdfPens.transparent,
        left: PdfPens.transparent,
      ),
      format: PdfStringFormat(
        alignment: PdfTextAlignment.center,
        lineAlignment: PdfVerticalAlignment.middle,
        characterSpacing: 0.2,
      ),
      textBrush: PdfBrushes.black,
      font: PdfStandardFont(
        PdfFontFamily.timesRoman,
        9,
        style: PdfFontStyle.bold,
      ),
    );
    titleHeader.cells[5].style = PdfGridCellStyle(
      borders: PdfBorders(left: PdfPens.transparent),
      format: PdfStringFormat(
        alignment: PdfTextAlignment.right,
        lineAlignment: PdfVerticalAlignment.middle,
        characterSpacing: 0.2,
      ),
    );
    // Header Style End

    // Header Table Rows Mobile No Mail Addresss
    PdfGridRow headerRow = headerGrid.rows.add();
    headerRow.cells[0].value = "Mobile No: +91 9942782219";
    headerRow.cells[3].value = "Email: msankar032@gmil.com";

    // Header Table Rows Mobile No Mail Addresss Style
    //  Style Start
    headerRow.cells[0].columnSpan = 3;
    headerRow.cells[3].columnSpan = 4;
    headerRow.cells[0].style = PdfGridCellStyle(
      borders: PdfBorders(
        right: PdfPens.transparent,
        bottom: PdfPens.transparent,
      ),
      format: PdfStringFormat(
        alignment: PdfTextAlignment.left,
        lineAlignment: PdfVerticalAlignment.middle,
        characterSpacing: 0.2,
      ),
    );
    headerRow.cells[3].style = PdfGridCellStyle(
      borders: PdfBorders(
        left: PdfPens.transparent,
        bottom: PdfPens.transparent,
      ),
      format: PdfStringFormat(
        alignment: PdfTextAlignment.right,
        lineAlignment: PdfVerticalAlignment.middle,
        characterSpacing: 0.2,
      ),
    );
    //  Style End

    // Header Table Rows 2 Company Name
    headerRow = headerGrid.rows.add();
    headerRow.cells[0].value = companyInfo.companyName;
    // Header Table Rows 2 Company Name Style
    //  Style Start
    headerRow.cells[0].columnSpan = 7;
    headerRow.cells[0].style = PdfGridCellStyle(
      borders: PdfBorders(
        top: PdfPens.transparent,
        bottom: PdfPens.transparent,
      ),
      format: PdfStringFormat(
        alignment: PdfTextAlignment.center,
        lineAlignment: PdfVerticalAlignment.middle,
        characterSpacing: 0.2,
      ),
      font: PdfStandardFont(
        PdfFontFamily.timesRoman,
        9,
        style: PdfFontStyle.bold,
      ),
    );
    //  Style End

    // Header Tabel Rows 3 Company Address
    headerRow = headerGrid.rows.add();
    headerRow.cells[0].value = companyInfo.address;
    // Header Table Rows 3 Company Address Style
    //  Style Start
    headerRow.cells[0].columnSpan = 7;
    headerRow.cells[0].style = PdfGridCellStyle(
      borders: PdfBorders(
        top: PdfPens.transparent,
        bottom: PdfPens.transparent,
      ),
      format: PdfStringFormat(
        alignment: PdfTextAlignment.center,
        lineAlignment: PdfVerticalAlignment.middle,
        characterSpacing: 0.2,
      ),
    );
    //  Style End

    // Header Table Rows 4 Customer Details title
    // if (pageNumber) {
    headerRow = headerGrid.rows.add();
    headerRow.cells[0].value = "Customer Details";
    // }
    // Header Table Rows 4 Customer Details title Style
    //  Style Start
    headerRow.cells[0].columnSpan = 7;
    headerRow.cells[0].style = PdfGridCellStyle(
      borders: PdfBorders(
        // top: PdfPens.transparent,
        bottom: PdfPens.transparent,
      ),
      font: PdfStandardFont(
        PdfFontFamily.timesRoman,
        9,
        style: PdfFontStyle.bold,
      ),
    );
    //  Style End

    // Header Table Rows 4 Customer Information
    headerRow = headerGrid.rows.add();
    headerRow.cells[0].value =
        "${estimateData.customer?.customerName}\n${estimateData.customer?.address},${estimateData.customer?.state},${estimateData.customer?.city},${estimateData.customer?.mobileNo}";
    // Header Table Rows 4 Customer Details title Style
    //  Style Start
    headerRow.cells[0].columnSpan = 7;
    headerRow.cells[0].style = PdfGridCellStyle(
      borders: PdfBorders(
        top: PdfPens.transparent,
        bottom: PdfPens.transparent,
      ),
    );
    //

    // Header Table Rows 5 Product Conetent Title Seaction
    headerRow = headerGrid.rows.add();
    headerRow.cells[0].value = 'S.No';
    headerRow.cells[1].value = 'Code';
    headerRow.cells[2].value = 'Product Name';
    headerRow.cells[3].value = 'Discount';
    headerRow.cells[4].value = 'QTY';
    headerRow.cells[5].value = 'Rate';
    headerRow.cells[6].value = 'Amount';

    var style = PdfGridCellStyle(
      format: PdfStringFormat(
        alignment: PdfTextAlignment.center,
        lineAlignment: PdfVerticalAlignment.middle,
        characterSpacing: 0.2,
      ),
      borders: PdfBorders(
        bottom: PdfPens.transparent,
      ),
      font: PdfStandardFont(
        PdfFontFamily.timesRoman,
        9,
        style: PdfFontStyle.bold,
      ),
    );

    headerRow.cells[0].style = style;
    headerRow.cells[1].style = style;
    headerRow.cells[2].style = style;
    headerRow.cells[3].style = style;
    headerRow.cells[4].style = style;
    headerRow.cells[5].style = style;
    headerRow.cells[6].style = style;

    headerGrid.style.cellPadding = PdfPaddings(
      left: 2,
      right: 2,
      bottom: 2,
      top: 2,
    );

    headerGrid.draw(
      graphics: header.graphics,
    );
    document.template.top = header;

    // Pdf Page Header Section End

    //Add section to the document
    PdfSection section = document.sections!.add();

    // Product Listing Table Section Start
    PdfGrid prodcutGrid = PdfGrid();

    prodcutGrid.columns.add(count: 7);

    prodcutGrid.columns[0].width = 30;
    prodcutGrid.columns[1].width = 40;
    prodcutGrid.columns[3].width = 40;
    prodcutGrid.columns[4].width = 40;
    prodcutGrid.columns[5].width = 40;
    prodcutGrid.columns[6].width = 80;
    // Product List Start
    int count = 1;
    PdfGridCellStyle centerstyle = PdfGridCellStyle(
      format: PdfStringFormat(
        alignment: PdfTextAlignment.center,
        lineAlignment: PdfVerticalAlignment.middle,
        characterSpacing: 0.2,
      ),
    );
    PdfGridCellStyle rightstyle = PdfGridCellStyle(
      format: PdfStringFormat(
        alignment: PdfTextAlignment.right,
        lineAlignment: PdfVerticalAlignment.middle,
        characterSpacing: 0.2,
      ),
    );
    for (int i = 0; i < estimateData.products!.length; i++) {
      PdfGridRow productRow = prodcutGrid.rows.add();
      productRow.cells[0].value = '$count';
      productRow.cells[1].value = '${estimateData.products![i].productCode}';
      productRow.cells[2].value = '${estimateData.products![i].productName}';
      productRow.cells[3].value = estimateData.products![i].discountLock == true ? "Yes" : "No";
      productRow.cells[4].value = '${estimateData.products![i].qty}';
      productRow.cells[5].value = '${estimateData.products![i].price}';
      productRow.cells[6].value = '${estimateData.products![i].qty! * estimateData.products![i].price!}';
      productRow.cells[0].style = centerstyle;
      productRow.cells[1].style = centerstyle;
      productRow.cells[3].style = centerstyle;
      productRow.cells[4].style = centerstyle;
      productRow.cells[5].style = rightstyle;
      productRow.cells[6].style = rightstyle;
      count++;
    }
    // Product List End
    PdfGridRow productRow = prodcutGrid.rows.add();
    productRow.cells[0].value = 'SubTotal';
    productRow.cells[6].value = '${estimateData.price!.subTotal}';
    productRow.cells[0].columnSpan = 6;
    productRow.cells[0].style = rightstyle;
    productRow.cells[6].style = rightstyle;

    productRow = prodcutGrid.rows.add();
    productRow.cells[0].value = 'Discount';
    productRow.cells[6].value = '${estimateData.price!.discountValue}';
    productRow.cells[0].columnSpan = 6;
    productRow.cells[0].style = rightstyle;
    productRow.cells[6].style = rightstyle;

    productRow = prodcutGrid.rows.add();
    productRow.cells[0].value = 'Extra Discount';
    productRow.cells[6].value = '${estimateData.price!.extraDiscountValue}';
    productRow.cells[0].columnSpan = 6;
    productRow.cells[0].style = rightstyle;
    productRow.cells[6].style = rightstyle;

    productRow = prodcutGrid.rows.add();
    productRow.cells[0].value = 'Package Charges';
    productRow.cells[6].value = '${estimateData.price!.packageValue}';
    productRow.cells[0].columnSpan = 6;
    productRow.cells[0].style = rightstyle;
    productRow.cells[6].style = rightstyle;

    productRow = prodcutGrid.rows.add();
    productRow.cells[0].value = 'Total';
    productRow.cells[6].value = '${estimateData.price!.total}';
    productRow.cells[0].columnSpan = 6;
    productRow.cells[0].style = rightstyle;
    productRow.cells[6].style = rightstyle;

    productRow = prodcutGrid.rows.add();
    productRow.cells[0].value = 'Total Items (${estimateData.products!.length})';
    productRow.cells[3].value = 'Overall Total';
    productRow.cells[6].value = '${estimateData.price!.total}';
    productRow.cells[0].columnSpan = 2;
    productRow.cells[3].columnSpan = 3;

    productRow.cells[0].style = PdfGridCellStyle(
      borders: PdfBorders(
        right: PdfPens.transparent,
      ),
    );
    productRow.cells[2].style = PdfGridCellStyle(
      borders: PdfBorders(
        left: PdfPens.transparent,
        right: PdfPens.transparent,
      ),
    );
    productRow.cells[3].style = PdfGridCellStyle(
      borders: PdfBorders(
        left: PdfPens.transparent,
      ),
      format: PdfStringFormat(
        alignment: PdfTextAlignment.right,
        lineAlignment: PdfVerticalAlignment.middle,
        characterSpacing: 0.2,
      ),
    );
    productRow.cells[6].style = rightstyle;

    prodcutGrid.style.cellPadding = PdfPaddings(
      left: 2,
      right: 2,
      bottom: 2,
      top: 2,
    );

    prodcutGrid.draw(page: section.pages.add());
    // Product Listing Table Section End

    resultData = await document.save();

    return resultData;
  }

  Future<List<int>?> createPdfA5() async {
    List<int>? resultData;

    PdfDocument document = PdfDocument();

    document.pageSettings.size = PdfPageSize.a5;
    document.pageSettings.margins.all = 10;

    // Pdf Page Header Section Start

    // Create Header size
    PdfPageTemplateElement header = PdfPageTemplateElement(
      Rect.fromLTWH(0, 0, document.pageSettings.size.width - 20, 162),
    );

    // Grid Varable
    PdfGrid headerGrid = PdfGrid();

    // Assign Column 3
    headerGrid.columns.add(count: 7);
    headerGrid.headers.add(1);

    headerGrid.columns[0].width = 30;
    headerGrid.columns[1].width = 40;
    headerGrid.columns[3].width = 40;
    headerGrid.columns[4].width = 40;
    headerGrid.columns[5].width = 40;
    headerGrid.columns[6].width = 80;

    PdfGridRow titleHeader = headerGrid.headers[0];
    titleHeader.cells[0].value =
        'Estimate ID: ${type == PdfType.enquiry ? estimateData.enquiryid : estimateData.estimateid}';
    titleHeader.cells[2].value = 'Estimate';
    titleHeader.cells[5].value = 'Date: ${DateFormat('dd-MM-yyyy HH:mm a').format(estimateData.createddate!)}';

    // Header Style Start
    titleHeader.cells[0].columnSpan = 2;
    titleHeader.cells[2].columnSpan = 3;
    titleHeader.cells[5].columnSpan = 2;
    titleHeader.cells[0].style = PdfGridCellStyle(
      borders: PdfBorders(right: PdfPens.transparent),
      format: PdfStringFormat(
        alignment: PdfTextAlignment.left,
        lineAlignment: PdfVerticalAlignment.middle,
        characterSpacing: 0.2,
      ),
    );
    titleHeader.cells[2].style = PdfGridCellStyle(
      borders: PdfBorders(
        right: PdfPens.transparent,
        left: PdfPens.transparent,
      ),
      format: PdfStringFormat(
        alignment: PdfTextAlignment.center,
        lineAlignment: PdfVerticalAlignment.middle,
        characterSpacing: 0.2,
      ),
      textBrush: PdfBrushes.black,
      font: PdfStandardFont(
        PdfFontFamily.timesRoman,
        9,
        style: PdfFontStyle.bold,
      ),
    );
    titleHeader.cells[5].style = PdfGridCellStyle(
      borders: PdfBorders(left: PdfPens.transparent),
      format: PdfStringFormat(
        alignment: PdfTextAlignment.right,
        lineAlignment: PdfVerticalAlignment.middle,
        characterSpacing: 0.2,
      ),
    );
    // Header Style End

    // Header Table Rows Mobile No Mail Addresss
    PdfGridRow headerRow = headerGrid.rows.add();
    headerRow.cells[0].value = "Mobile No: +91 9942782219";
    headerRow.cells[3].value = "Email: msankar032@gmil.com";

    // Header Table Rows Mobile No Mail Addresss Style
    //  Style Start
    headerRow.cells[0].columnSpan = 3;
    headerRow.cells[3].columnSpan = 4;
    headerRow.cells[0].style = PdfGridCellStyle(
      borders: PdfBorders(
        right: PdfPens.transparent,
        bottom: PdfPens.transparent,
      ),
      format: PdfStringFormat(
        alignment: PdfTextAlignment.left,
        lineAlignment: PdfVerticalAlignment.middle,
        characterSpacing: 0.2,
      ),
    );
    headerRow.cells[3].style = PdfGridCellStyle(
      borders: PdfBorders(
        left: PdfPens.transparent,
        bottom: PdfPens.transparent,
      ),
      format: PdfStringFormat(
        alignment: PdfTextAlignment.right,
        lineAlignment: PdfVerticalAlignment.middle,
        characterSpacing: 0.2,
      ),
    );
    //  Style End

    // Header Table Rows 2 Company Name
    headerRow = headerGrid.rows.add();
    headerRow.cells[0].value = companyInfo.companyName;
    // Header Table Rows 2 Company Name Style
    //  Style Start
    headerRow.cells[0].columnSpan = 7;
    headerRow.cells[0].style = PdfGridCellStyle(
      borders: PdfBorders(
        top: PdfPens.transparent,
        bottom: PdfPens.transparent,
      ),
      format: PdfStringFormat(
        alignment: PdfTextAlignment.center,
        lineAlignment: PdfVerticalAlignment.middle,
        characterSpacing: 0.2,
      ),
      font: PdfStandardFont(
        PdfFontFamily.timesRoman,
        9,
        style: PdfFontStyle.bold,
      ),
    );
    //  Style End

    // Header Tabel Rows 3 Company Address
    headerRow = headerGrid.rows.add();
    headerRow.cells[0].value = companyInfo.address;
    // Header Table Rows 3 Company Address Style
    //  Style Start
    headerRow.cells[0].columnSpan = 7;
    headerRow.cells[0].style = PdfGridCellStyle(
      borders: PdfBorders(
        top: PdfPens.transparent,
        bottom: PdfPens.transparent,
      ),
      format: PdfStringFormat(
        alignment: PdfTextAlignment.center,
        lineAlignment: PdfVerticalAlignment.middle,
        characterSpacing: 0.2,
      ),
    );
    //  Style End

    // Header Table Rows 4 Customer Details title
    // if (pageNumber) {
    headerRow = headerGrid.rows.add();
    headerRow.cells[0].value = "Customer Details";
    // }
    // Header Table Rows 4 Customer Details title Style
    //  Style Start
    headerRow.cells[0].columnSpan = 7;
    headerRow.cells[0].style = PdfGridCellStyle(
      borders: PdfBorders(
        // top: PdfPens.transparent,
        bottom: PdfPens.transparent,
      ),
      font: PdfStandardFont(
        PdfFontFamily.timesRoman,
        9,
        style: PdfFontStyle.bold,
      ),
    );
    //  Style End

    // Header Table Rows 4 Customer Information
    headerRow = headerGrid.rows.add();
    headerRow.cells[0].value =
        "${estimateData.customer?.customerName}\n${estimateData.customer?.address},${estimateData.customer?.state},${estimateData.customer?.city},${estimateData.customer?.mobileNo}";
    // Header Table Rows 4 Customer Details title Style
    //  Style Start
    headerRow.cells[0].columnSpan = 7;
    headerRow.cells[0].style = PdfGridCellStyle(
      borders: PdfBorders(
        top: PdfPens.transparent,
        bottom: PdfPens.transparent,
      ),
    );
    //

    // Header Table Rows 5 Product Conetent Title Seaction
    headerRow = headerGrid.rows.add();
    headerRow.cells[0].value = 'S.No';
    headerRow.cells[1].value = 'Code';
    headerRow.cells[2].value = 'Product Name';
    headerRow.cells[3].value = 'Discount';
    headerRow.cells[4].value = 'QTY';
    headerRow.cells[5].value = 'Rate';
    headerRow.cells[6].value = 'Amount';

    var style = PdfGridCellStyle(
      format: PdfStringFormat(
        alignment: PdfTextAlignment.center,
        lineAlignment: PdfVerticalAlignment.middle,
        characterSpacing: 0.2,
      ),
      borders: PdfBorders(
        bottom: PdfPens.transparent,
      ),
      font: PdfStandardFont(
        PdfFontFamily.timesRoman,
        9,
        style: PdfFontStyle.bold,
      ),
    );

    headerRow.cells[0].style = style;
    headerRow.cells[1].style = style;
    headerRow.cells[2].style = style;
    headerRow.cells[3].style = style;
    headerRow.cells[4].style = style;
    headerRow.cells[5].style = style;
    headerRow.cells[6].style = style;

    headerGrid.style.cellPadding = PdfPaddings(
      left: 2,
      right: 2,
      bottom: 2,
      top: 2,
    );

    headerGrid.draw(
      graphics: header.graphics,
    );
    document.template.top = header;

    // Pdf Page Header Section End

    //Add section to the document
    PdfSection section = document.sections!.add();

    // Product Listing Table Section Start
    PdfGrid prodcutGrid = PdfGrid();

    prodcutGrid.columns.add(count: 7);

    prodcutGrid.columns[0].width = 30;
    prodcutGrid.columns[1].width = 40;
    prodcutGrid.columns[3].width = 40;
    prodcutGrid.columns[4].width = 40;
    prodcutGrid.columns[5].width = 40;
    prodcutGrid.columns[6].width = 80;
    // Product List Start
    int count = 1;
    PdfGridCellStyle centerstyle = PdfGridCellStyle(
      format: PdfStringFormat(
        alignment: PdfTextAlignment.center,
        lineAlignment: PdfVerticalAlignment.middle,
        characterSpacing: 0.2,
      ),
    );
    PdfGridCellStyle rightstyle = PdfGridCellStyle(
      format: PdfStringFormat(
        alignment: PdfTextAlignment.right,
        lineAlignment: PdfVerticalAlignment.middle,
        characterSpacing: 0.2,
      ),
    );
    for (int i = 0; i < estimateData.products!.length; i++) {
      PdfGridRow productRow = prodcutGrid.rows.add();
      productRow.cells[0].value = '$count';
      productRow.cells[1].value = '${estimateData.products![i].productCode}';
      productRow.cells[2].value = '${estimateData.products![i].productName}';
      productRow.cells[3].value = estimateData.products![i].discountLock == true ? "Yes" : "No";
      productRow.cells[4].value = '${estimateData.products![i].qty}';
      productRow.cells[5].value = '${estimateData.products![i].price}';
      productRow.cells[6].value = '${estimateData.products![i].qty! * estimateData.products![i].price!}';
      productRow.cells[0].style = centerstyle;
      productRow.cells[1].style = centerstyle;
      productRow.cells[3].style = centerstyle;
      productRow.cells[4].style = centerstyle;
      productRow.cells[5].style = rightstyle;
      productRow.cells[6].style = rightstyle;
      count++;
    }
    // Product List End
    PdfGridRow productRow = prodcutGrid.rows.add();
    productRow.cells[0].value = 'SubTotal';
    productRow.cells[6].value = '${estimateData.price!.subTotal}';
    productRow.cells[0].columnSpan = 6;
    productRow.cells[0].style = rightstyle;
    productRow.cells[6].style = rightstyle;

    productRow = prodcutGrid.rows.add();
    productRow.cells[0].value = 'Discount';
    productRow.cells[6].value = '${estimateData.price!.discountValue}';
    productRow.cells[0].columnSpan = 6;
    productRow.cells[0].style = rightstyle;
    productRow.cells[6].style = rightstyle;

    productRow = prodcutGrid.rows.add();
    productRow.cells[0].value = 'Extra Discount';
    productRow.cells[6].value = '${estimateData.price!.extraDiscountValue}';
    productRow.cells[0].columnSpan = 6;
    productRow.cells[0].style = rightstyle;
    productRow.cells[6].style = rightstyle;

    productRow = prodcutGrid.rows.add();
    productRow.cells[0].value = 'Package Charges';
    productRow.cells[6].value = '${estimateData.price!.packageValue}';
    productRow.cells[0].columnSpan = 6;
    productRow.cells[0].style = rightstyle;
    productRow.cells[6].style = rightstyle;

    productRow = prodcutGrid.rows.add();
    productRow.cells[0].value = 'Total';
    productRow.cells[6].value = '${estimateData.price!.total}';
    productRow.cells[0].columnSpan = 6;
    productRow.cells[0].style = rightstyle;
    productRow.cells[6].style = rightstyle;

    productRow = prodcutGrid.rows.add();
    productRow.cells[0].value = 'Total Items (${estimateData.products!.length})';
    productRow.cells[3].value = 'Overall Total';
    productRow.cells[6].value = '${estimateData.price!.total}';
    productRow.cells[0].columnSpan = 2;
    productRow.cells[3].columnSpan = 3;

    productRow.cells[0].style = PdfGridCellStyle(
      borders: PdfBorders(
        right: PdfPens.transparent,
      ),
    );
    productRow.cells[2].style = PdfGridCellStyle(
      borders: PdfBorders(
        left: PdfPens.transparent,
        right: PdfPens.transparent,
      ),
    );
    productRow.cells[3].style = PdfGridCellStyle(
      borders: PdfBorders(
        left: PdfPens.transparent,
      ),
      format: PdfStringFormat(
        alignment: PdfTextAlignment.right,
        lineAlignment: PdfVerticalAlignment.middle,
        characterSpacing: 0.2,
      ),
    );
    productRow.cells[6].style = rightstyle;

    prodcutGrid.style.cellPadding = PdfPaddings(
      left: 2,
      right: 2,
      bottom: 2,
      top: 2,
    );

    prodcutGrid.draw(page: section.pages.add());
    // Product Listing Table Section End

    resultData = await document.save();

    return resultData;
  }

  List<DiscountBillModel> discountList = [];

  Future<Uint8List?> createPDFDemoA4({required pf.PdfPageFormat pageSize}) async {
    final pdf = pw.Document();

    for (var element in estimateData.products!) {
      int index = discountList.indexWhere((discountElement) => discountElement.discount == element.discount.toString());
      if (index != -1) {
        discountList[index].products!.add(element);
      } else {
        DiscountBillModel bill = DiscountBillModel();
        bill.discount = element.discount.toString();
        bill.products = [];
        bill.products!.add(element);
        discountList.add(bill);
      }
    }

    pdf.addPage(
      pw.MultiPage(
        margin: const pw.EdgeInsets.all(10),
        pageFormat: pageSize,
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
            children: [
              pw.Table(
                border: const pw.TableBorder(
                  left: pw.BorderSide(color: pf.PdfColors.black),
                  top: pw.BorderSide(color: pf.PdfColors.black),
                  right: pw.BorderSide(color: pf.PdfColors.black),
                  bottom: pw.BorderSide(color: pf.PdfColors.black),
                ),
                children: [
                  pw.TableRow(
                    children: [
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(2),
                        child: pw.Text(
                          "Estimate ID : ${estimateData.enquiryid}",
                          style: const pw.TextStyle(
                            fontSize: 10,
                          ),
                        ),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(2),
                        child: pw.Center(
                          child: pw.Text(
                            "Estimate",
                            style: pw.TextStyle(
                              fontWeight: pw.FontWeight.bold,
                              fontSize: 10,
                            ),
                          ),
                        ),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(2),
                        child: pw.Text(
                          "Date: ${DateFormat('dd-MM-yyyy HH:mm a').format(estimateData.createddate!)}",
                          textAlign: pw.TextAlign.right,
                          style: const pw.TextStyle(
                            fontSize: 10,
                          ),
                        ),
                      ),
                    ],
                  ),
                  pw.TableRow(
                    decoration: const pw.BoxDecoration(
                      border: pw.Border(
                        top: pw.BorderSide(),
                      ),
                    ),
                    children: [
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(2),
                        child: pw.Text(
                          "Phone Number : ${estimateData.customer!.mobileNo ?? ""}",
                          style: const pw.TextStyle(
                            fontSize: 10,
                          ),
                        ),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(2),
                        child: pw.Center(
                          child: pw.Column(
                            mainAxisSize: pw.MainAxisSize.min,
                            children: [
                              pw.Text(
                                "${companyInfo.companyName}",
                                style: pw.TextStyle(
                                  fontWeight: pw.FontWeight.bold,
                                  fontSize: 10,
                                ),
                              ),
                              pw.Text(
                                "${companyInfo.address}",
                                textAlign: pw.TextAlign.center,
                                style: const pw.TextStyle(
                                  fontSize: 10,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(2),
                        child: pw.Text(
                          "Email: ${estimateData.customer!.email ?? ""}",
                          textAlign: pw.TextAlign.right,
                          style: const pw.TextStyle(
                            fontSize: 10,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              pw.Table(
                border: const pw.TableBorder(
                  left: pw.BorderSide(color: pf.PdfColors.black),
                  top: pw.BorderSide(color: pf.PdfColors.black),
                  right: pw.BorderSide(color: pf.PdfColors.black),
                  bottom: pw.BorderSide(color: pf.PdfColors.black),
                ),
                children: [
                  pw.TableRow(
                    children: [
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(2),
                        child: pw.Column(
                          crossAxisAlignment: pw.CrossAxisAlignment.start,
                          mainAxisSize: pw.MainAxisSize.min,
                          children: [
                            pw.Text(
                              "Customer Details",
                              style: pw.TextStyle(
                                fontWeight: pw.FontWeight.bold,
                                fontSize: 10,
                              ),
                            ),
                            pw.SizedBox(height: 6),
                            pw.Text(
                              "${estimateData.customer!.customerName ?? ""}\n${estimateData.customer!.address ?? ""},${estimateData.customer!.city ?? ""},${estimateData.customer!.state ?? ""},${estimateData.customer!.mobileNo ?? ""}",
                              style: const pw.TextStyle(
                                fontSize: 10,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              pw.Table(
                columnWidths: {
                  0: const pw.FlexColumnWidth(1),
                  1: const pw.FlexColumnWidth(1.5),
                  2: const pw.FlexColumnWidth(6),
                  3: const pw.FlexColumnWidth(2),
                  4: const pw.FlexColumnWidth(2),
                  5: const pw.FlexColumnWidth(2),
                  6: const pw.FlexColumnWidth(3),
                },
                border: pw.TableBorder.all(),
                // border: const pw.TableBorder(
                //   left: pw.BorderSide(color: pf.PdfColors.black),
                //   top: pw.BorderSide(color: pf.PdfColors.black),
                //   right: pw.BorderSide(color: pf.PdfColors.black),
                //   bottom: pw.BorderSide(color: pf.PdfColors.black),
                // ),
                children: [
                  pw.TableRow(
                    children: [
                      pw.Center(
                        child: pw.Padding(
                          padding: const pw.EdgeInsets.all(2),
                          child: pw.Text(
                            "S.NO",
                            style: pw.TextStyle(
                              fontSize: 10,
                              fontWeight: pw.FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      pw.Center(
                        child: pw.Padding(
                          padding: const pw.EdgeInsets.all(2),
                          child: pw.Text(
                            "CODE",
                            style: pw.TextStyle(
                              fontSize: 10,
                              fontWeight: pw.FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      pw.Center(
                        child: pw.Padding(
                          padding: const pw.EdgeInsets.all(2),
                          child: pw.Text(
                            "PRODUCT NAME",
                            style: pw.TextStyle(
                              fontSize: 10,
                              fontWeight: pw.FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      pw.Center(
                        child: pw.Padding(
                          padding: const pw.EdgeInsets.all(2),
                          child: pw.Text(
                            "DISCOUNT",
                            style: pw.TextStyle(
                              fontSize: 10,
                              fontWeight: pw.FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      pw.Center(
                        child: pw.Padding(
                          padding: const pw.EdgeInsets.all(2),
                          child: pw.Text(
                            "QTY",
                            style: pw.TextStyle(
                              fontSize: 10,
                              fontWeight: pw.FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      pw.Center(
                        child: pw.Padding(
                          padding: const pw.EdgeInsets.all(2),
                          child: pw.Text(
                            "RATE",
                            style: pw.TextStyle(
                              fontSize: 10,
                              fontWeight: pw.FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      pw.Center(
                        child: pw.Padding(
                          padding: const pw.EdgeInsets.all(2),
                          child: pw.Text(
                            "AMOUNT",
                            style: pw.TextStyle(
                              fontSize: 10,
                              fontWeight: pw.FontWeight.bold,
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
            for (int j = 0; j < discountList.length; j++)
              pw.Column(
                mainAxisSize: pw.MainAxisSize.min,
                children: [
                  pw.Table(
                    border: TableBorder.symmetric(
                      outside: const pw.BorderSide(),
                    ),
                    children: [
                      pw.TableRow(
                        decoration: const BoxDecoration(color: pf.PdfColors.grey300),
                        children: [
                          pw.Padding(
                            padding: const pw.EdgeInsets.all(3),
                            child: pw.Text(
                              discountList[j].discount == null || discountList[j].discount == "null"
                                  ? "Net Rate"
                                  : "Discount : ${discountList[j].discount ?? ""}%",
                              style: pw.TextStyle(
                                font: regularFont,
                                fontSize: 8,
                                fontWeight: pw.FontWeight.normal,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  pw.Table(
                    columnWidths: {
                      0: const pw.FlexColumnWidth(1),
                      1: const pw.FlexColumnWidth(1.5),
                      2: const pw.FlexColumnWidth(6),
                      3: const pw.FlexColumnWidth(2),
                      4: const pw.FlexColumnWidth(2),
                      5: const pw.FlexColumnWidth(2),
                      6: const pw.FlexColumnWidth(3),
                    },
                    border: const TableBorder(
                      verticalInside: pw.BorderSide(),
                      left: pw.BorderSide(),
                      right: pw.BorderSide(),
                    ),
                    // border: const pw.TableBorder(
                    //   left: pw.BorderSide(color: pf.PdfColors.black),
                    //   top: pw.BorderSide(color: pf.PdfColors.black),
                    //   right: pw.BorderSide(color: pf.PdfColors.black),
                    //   bottom: pw.BorderSide(color: pf.PdfColors.black),
                    // ),
                    children: [
                      for (int i = 0; i < discountList[j].products!.length; i++) productTableListView(j, i),
                    ],
                  ),
                ],
              ),
            pw.Table(
              columnWidths: {
                0: const pw.FlexColumnWidth(14.5),
                1: const pw.FlexColumnWidth(3),
              },
              border: pw.TableBorder.all(),
              // border: const pw.TableBorder(
              //   left: pw.BorderSide(color: pf.PdfColors.black),
              //   top: pw.BorderSide(color: pf.PdfColors.black),
              //   right: pw.BorderSide(color: pf.PdfColors.black),
              //   bottom: pw.BorderSide(color: pf.PdfColors.black),
              // ),
              children: [
                calculationTableView("subtotal", estimateData.price!.subTotal.toString()),
                calculationTableView("Discount", estimateData.price!.discountValue.toString()),
                calculationTableView(
                    "Extra Discount (${estimateData.price!.extraDiscountsys}${estimateData.price!.extraDiscount})",
                    estimateData.price!.extraDiscountValue.toString()),
                calculationTableView(
                    "Package Charges (${estimateData.price!.packagesys}${estimateData.price!.package})",
                    estimateData.price!.packageValue.toString()),
                calculationTableView("Total", estimateData.price!.total.toString()),
              ],
            ),
          ];
        },
      ),
    );
    return await pdf.save();
  }

  Font? regularFont;
  Font? boldFont;
  pw.TextStyle? heading1;
  pw.TextStyle? heading2;
  pw.TextStyle? subtitle1;
  pw.TextStyle? subtitle2;
  Future<Uint8List?> create3InchPDF() async {
    final pdf = pw.Document();
    // regularFont = Font.ttf(await rootBundle.load('assets/fonts/times new roman.ttf'));
    // boldFont = await fontFromAssetBundle('assets/fonts/times new roman bold.ttf');

    heading1 = pw.TextStyle(
      font: boldFont,
      color: pf.PdfColors.black,
      fontWeight: pw.FontWeight.bold,
      fontSize: 11,
    );
    heading2 = pw.TextStyle(
      font: boldFont,
      color: pf.PdfColors.black,
      fontWeight: pw.FontWeight.bold,
      fontSize: 8,
    );
    subtitle1 = pw.TextStyle(
      font: regularFont,
      fontSize: 8,
      fontWeight: pw.FontWeight.normal,
    );
    subtitle2 = pw.TextStyle(
      font: regularFont,
      fontSize: 8,
      fontWeight: pw.FontWeight.normal,
    );

    pdf.addPage(
      pw.Page(
        pageFormat: pf.PdfPageFormat.roll80,
        margin: const pw.EdgeInsets.all(10),
        // theme: ThemeData.withFont(
        //   base: regularFont,
        // ),
        build: (context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Center(
                child: pw.Text(
                  companyInfo.companyName ?? "",
                  style: heading1,
                ),
              ),
              pw.SizedBox(height: 10),
              pw.Center(
                child: pw.Text(
                  companyInfo.address ?? "",
                  textAlign: pw.TextAlign.center,
                  style: subtitle1,
                ),
              ),
              // pw.SizedBox(height: 10),
              pw.Center(
                child: pw.Text(
                  companyInfo.contact!["mobile_no"].toString(),
                  textAlign: pw.TextAlign.center,
                  style: subtitle1,
                ),
              ),
              pw.SizedBox(height: 10),
              // pw.Center(
              //   child: pw.Text(
              //     "Date: ${DateFormat('dd-MM-yyyy HH:mm a').format(estimateData.createddate!)}",
              //     textAlign: pw.TextAlign.center,
              //     style: subtitle1,
              //   ),
              // ),
              // pw.Center(
              //   child: pw.Text(
              //     "No: ${estimateData.enquiryid}",
              //     textAlign: pw.TextAlign.center,
              //     style: subtitle1,
              //   ),
              // ),

              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text(
                    "No: ${estimateData.enquiryid}",
                    textAlign: pw.TextAlign.center,
                    style: subtitle1,
                  ),
                  pw.Text(
                    "Date: ${DateFormat('dd-MM-yyyy hh:mm a').format(estimateData.createddate!)}",
                    textAlign: pw.TextAlign.center,
                    style: subtitle1,
                  ),
                ],
              ),
              pw.SizedBox(height: 15),
              pw.Text(
                "Bill TO:\n\n${estimateData.customer!.customerName ?? ""}\n${estimateData.customer!.address ?? ""},${estimateData.customer!.city ?? ""},${estimateData.customer!.state ?? ""}, ${estimateData.customer!.mobileNo ?? ""}",
                textAlign: pw.TextAlign.left,
                style: subtitle1,
              ),
              pw.SizedBox(height: 15),
              pw.Table(
                columnWidths: {
                  0: const pw.FlexColumnWidth(2.5),
                  1: const pw.FlexColumnWidth(1),
                  2: const pw.FlexColumnWidth(1.5),
                  3: const pw.FlexColumnWidth(1.5),
                },
                // border: pw.TableBorder.all(),
                border: const pw.TableBorder(
                  // left: pw.BorderSide(color: pf.PdfColors.black),
                  top: pw.BorderSide(color: pf.PdfColors.black),
                  // right: pw.BorderSide(color: pf.PdfColors.black),
                  bottom: pw.BorderSide(color: pf.PdfColors.black),
                ),
                children: [
                  pw.TableRow(
                    children: [
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(2),
                        child: pw.Text(
                          "PRODUCT NAME",
                          textAlign: pw.TextAlign.left,
                          style: heading2,
                        ),
                      ),
                      pw.Center(
                        child: pw.Padding(
                          padding: const pw.EdgeInsets.all(2),
                          child: pw.Text(
                            "QTY",
                            style: heading2,
                          ),
                        ),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(2),
                        child: pw.Text(
                          "RATE",
                          textAlign: pw.TextAlign.right,
                          style: heading2,
                        ),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(2),
                        child: pw.Text(
                          "AMOUNT",
                          textAlign: pw.TextAlign.right,
                          style: heading2,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              pw.Table(
                columnWidths: {
                  0: const pw.FlexColumnWidth(2.5),
                  1: const pw.FlexColumnWidth(1),
                  2: const pw.FlexColumnWidth(1.5),
                  3: const pw.FlexColumnWidth(1.5),
                },
                // // border: pw.TableBorder.all(),
                // border: const pw.TableBorder(
                //   // left: pw.BorderSide(color: pf.PdfColors.black),
                //   // top: pw.BorderSide(color: pf.PdfColors.black),
                //   // right: pw.BorderSide(color: pf.PdfColors.black),
                //   bottom: pw.BorderSide(color: pf.PdfColors.black),
                // ),
                children: [
                  for (int i = 0; i < estimateData.products!.length; i++) productTableListView3Inch(i),
                ],
              ),
              pw.Table(
                columnWidths: {
                  0: const pw.FlexColumnWidth(5),
                  1: const pw.FlexColumnWidth(1.5),
                },
                // border: pw.TableBorder.all(),
                // border: const pw.TableBorder(
                //   left: pw.BorderSide(color: pf.PdfColors.black),
                //   top: pw.BorderSide(color: pf.PdfColors.black),
                //   right: pw.BorderSide(color: pf.PdfColors.black),
                //   bottom: pw.BorderSide(color: pf.PdfColors.black),
                // ),
                children: [
                  calculationTableView3Inch("Subtotal", estimateData.price!.subTotal!.toStringAsFixed(2)),
                  estimateData.price!.discount != 0
                      ? calculationTableView3Inch(
                          "Discount (${estimateData.price!.discount}${estimateData.price!.discountsys})",
                          estimateData.price!.discountValue!.toStringAsFixed(2))
                      : const pw.TableRow(children: []),
                  estimateData.price!.extraDiscount != 0
                      ? calculationTableView3Inch(
                          "Extra Discount (${estimateData.price!.extraDiscount}${estimateData.price!.extraDiscountsys})",
                          estimateData.price!.extraDiscountValue!.toStringAsFixed(2))
                      : const pw.TableRow(children: []),
                  estimateData.price!.package != 0
                      ? calculationTableView3Inch(
                          "Package Charges (${estimateData.price!.package}${estimateData.price!.packagesys})",
                          estimateData.price!.packageValue!.toStringAsFixed(2))
                      : const pw.TableRow(children: []),
                  calculationTableView3Inch("Total", estimateData.price!.total!.toStringAsFixed(2)),
                ],
              ),
              pw.SizedBox(height: 10),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text(
                    "No Product : ${estimateData.products!.length}",
                    textAlign: pw.TextAlign.center,
                    style: heading2,
                  ),
                  pw.Text(
                    "No QTY : ${getItems()}",
                    textAlign: pw.TextAlign.center,
                    style: heading2,
                  ),
                ],
              ),
              // pw.Center(
              //   child: pw.Text(
              //     "Total Items: ",
              //     style: pw.TextStyle(
              //       color: pf.PdfColors.black,
              //       fontWeight: pw.FontWeight.bold,
              //     ),
              //   ),
              // ),
              pw.SizedBox(height: 40),
            ],
          );
        },
      ),
    );
    return await pdf.save();
  }

  pw.TableRow calculationTableView(String title, String value) {
    return pw.TableRow(
      children: [
        pw.Padding(
          padding: const pw.EdgeInsets.all(2),
          child: pw.Text(
            title,
            textAlign: pw.TextAlign.right,
            style: const pw.TextStyle(
              fontSize: 10,
            ),
          ),
        ),
        pw.Padding(
          padding: const pw.EdgeInsets.all(2),
          child: pw.Text(
            value,
            textAlign: pw.TextAlign.right,
            style: const pw.TextStyle(
              fontSize: 10,
            ),
          ),
        ),
      ],
    );
  }

  pw.TableRow productTableListView(int j, int i) {
    var element = discountList[j].products![i];
    return pw.TableRow(
      children: [
        pw.Padding(
          padding: const pw.EdgeInsets.all(2),
          child: pw.Center(
            child: pw.Text(
              (i + 1).toString(),
              style: const pw.TextStyle(
                fontSize: 10,
              ),
            ),
          ),
        ),
        pw.Padding(
          padding: const pw.EdgeInsets.all(2),
          child: pw.Center(
            child: pw.Text(
              element.productCode ?? "",
              style: const pw.TextStyle(
                fontSize: 10,
              ),
            ),
          ),
        ),
        pw.Padding(
          padding: const pw.EdgeInsets.all(2),
          child: pw.Text(
            element.productName ?? "",
            style: const pw.TextStyle(
              fontSize: 10,
            ),
          ),
        ),
        pw.Padding(
          padding: const pw.EdgeInsets.all(2),
          child: pw.Center(
            child: pw.Text(
              element.discountLock != null
                  ? element.discountLock == true
                      ? "YES"
                      : "NO"
                  : "",
              style: const pw.TextStyle(
                fontSize: 10,
              ),
            ),
          ),
        ),
        pw.Padding(
          padding: const pw.EdgeInsets.all(2),
          child: pw.Center(
            child: pw.Text(
              element.qty != null ? element.qty.toString() : "",
              style: const pw.TextStyle(
                fontSize: 10,
              ),
            ),
          ),
        ),
        pw.Padding(
          padding: const pw.EdgeInsets.all(2),
          child: pw.Text(
            element.price != null ? element.price!.toStringAsFixed(2) : "",
            textAlign: pw.TextAlign.right,
            style: const pw.TextStyle(
              fontSize: 10,
            ),
          ),
        ),
        pw.Padding(
          padding: const pw.EdgeInsets.all(2),
          child: pw.Text(
            element.qty != null && element.price != null
                ? (double.parse(element.qty.toString()) * element.price!).toStringAsFixed(2)
                : "",
            textAlign: pw.TextAlign.right,
            style: const pw.TextStyle(
              fontSize: 10,
            ),
          ),
        ),
      ],
    );
  }

  pw.TableRow productTableListView3Inch(int i) {
    var element = estimateData.products![i];
    return pw.TableRow(
      decoration: const pw.BoxDecoration(
        border: pw.Border(
          bottom: pw.BorderSide(
            color: pf.PdfColors.grey400,
          ),
        ),
      ),
      children: [
        pw.Padding(
          padding: const pw.EdgeInsets.all(2),
          child: pw.Text(
            element.productName ?? "",
            style: subtitle1,
          ),
        ),
        pw.Padding(
          padding: const pw.EdgeInsets.all(2),
          child: pw.Center(
            child: pw.Text(
              element.qty != null ? element.qty.toString() : "",
              style: subtitle1,
            ),
          ),
        ),
        pw.Padding(
          padding: const pw.EdgeInsets.all(2),
          child: pw.Text(
            element.price != null ? element.price!.toStringAsFixed(2) : "",
            textAlign: pw.TextAlign.right,
            style: subtitle1,
          ),
        ),
        pw.Padding(
          padding: const pw.EdgeInsets.all(2),
          child: pw.Text(
            element.qty != null && element.price != null
                ? (double.parse(element.qty.toString()) * element.price!).toStringAsFixed(2)
                : "",
            textAlign: pw.TextAlign.right,
            style: subtitle1,
          ),
        ),
      ],
    );
  }

  pw.TableRow calculationTableView3Inch(String title, String value) {
    return pw.TableRow(
      decoration: title.toLowerCase() == "total"
          ? const pw.BoxDecoration(
              border: pw.Border(
                bottom: pw.BorderSide(
                  color: pf.PdfColors.black,
                ),
                top: pw.BorderSide(
                  color: pf.PdfColors.black,
                ),
              ),
            )
          : null,
      children: [
        pw.Padding(
          padding: const pw.EdgeInsets.all(2),
          child: pw.Text(
            title,
            textAlign: pw.TextAlign.right,
            style: subtitle2,
          ),
        ),
        pw.Padding(
          padding: const pw.EdgeInsets.all(2),
          child: pw.Text(
            value,
            textAlign: pw.TextAlign.right,
            style: subtitle2,
          ),
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

import 'dart:developer';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart';
import 'package:sri_sakthivel_fireworks_pos/firebase/datamodel/datamodel.dart';
import 'package:sri_sakthivel_fireworks_pos/firebase/firestore_provider.dart';
import 'package:sri_sakthivel_fireworks_pos/screen/mainapp/invoice/pdf/invoice_pdf_service.dart';
import 'package:sri_sakthivel_fireworks_pos/utlities/provider/localdb.dart';
import 'package:sri_sakthivel_fireworks_pos/utlities/utlities.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

import '../../../../firebase/datamodel/invoice_model.dart';
import '../../../../provider/download_file_provider.dart';
import '../../../../provider/permisstion_provider.dart';

class InvoicePdfView extends StatefulWidget {
  final String title;
  final InvoiceModel invoice;
  const InvoicePdfView({super.key, required this.title, required this.invoice});

  @override
  State<InvoicePdfView> createState() => _InvoicePdfViewState();
}

class _InvoicePdfViewState extends State<InvoicePdfView> {
  Uint8List? pdfData;

  initFn() async {
    try {
      await FireStoreProvider()
          .getLastInvoiceAmount(billDate: widget.invoice.biilDate!, billNo: widget.invoice.billNo!)
          .then((lastAmount) async {
        await LocalDbProvider().fetchInfo(type: LocalData.companyid).then((cid) async {
          log(cid);
          await FireStoreProvider().getCompanyDocInfo(cid: cid).then((result) async {
            log("its Worked");
            if (result != null && result.exists) {
              log("its Worked1");
              ProfileModel model = ProfileModel();
              model.companyName = result["company_name"].toString();
              model.address = result["address"].toString();
              model.city = result["city"].toString();
              model.state = result["state"].toString();
              model.pincode = result["pincode"].toString();
              model.contact = {
                "mobile": result["contact"]["mobile_no"].toString(),
                "phone": result["contact"]["phone_no"].toString(),
              };
              model.gstno = result["gst_no"] ?? "";
              model.companyLogo = result["company_logo"].toString();
              log(model.dataMap().toString());
              await InvoicePDFService(
                title: widget.title,
                invoice: widget.invoice,
                total: lastAmount.toStringAsFixed(2),
                companyDoc: model,
              ).showA4PDf().then((value) {
                setState(() {
                  pdfData = value;
                });
              });
            } else {
              log("No Company Data");
            }
          });
        });
      });
    } catch (e) {
      snackBarCustom(context, false, e.toString());
    }
  }

  downloadPdfData() async {
    try {
      loading(context);
      await PermissionHandler().storagePermission().then((permissionResult) async {
        if (permissionResult != null && permissionResult) {
          await DownloadFileOffline(
            fileData: pdfData!,
            fileName: "Invoie ${widget.invoice.billNo!.replaceAll("/", "-")}",
            fileext: "pdf",
          ).startDownload().then((value) {
            Navigator.pop(context);
            if (value != null && value.isNotEmpty) {
              downloadFileSnackBarCustom(context, isSuccess: true, msg: "Download Invoice", path: value);
              // snackBarCustom(context, true, "Download Enquiry 3 inch ${widget.estimateData.enquiryid}");
            } else {
              snackBarCustom(context, false, "Failed to Download");
            }
          });
        } else {
          log("Permisstion Denied");
        }
      });
    } catch (e) {
      log(e.toString());
      Navigator.pop(context);
    }
  }

  @override
  void initState() {
    initFn();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffEEEEEE),
      appBar: AppBar(
        titleSpacing: 0,
        title: const Text("PDF Bill of Supply"),
        actions: [
          pdfData != null
              ? IconButton(
                  splashRadius: 20,
                  tooltip: "Share PDF",
                  onPressed: () async {
                    await Printing.sharePdf(
                      bytes: pdfData!,
                      filename: "${widget.invoice.billNo!.toLowerCase().replaceAll("/", "-")}.pdf",
                    );
                  },
                  icon: const Icon(Icons.share),
                )
              : const SizedBox(),
          pdfData != null
              ? IconButton(
                  splashRadius: 20,
                  tooltip: "Download PDF",
                  onPressed: () {
                    downloadPdfData();
                  },
                  icon: const Icon(Icons.file_download_outlined),
                )
              : const SizedBox(),
          pdfData != null
              ? IconButton(
                  splashRadius: 20,
                  tooltip: "Print PDF",
                  onPressed: () async {
                    await Printing.layoutPdf(
                      onLayout: (_) => pdfData!,
                      format: PdfPageFormat.a4,
                    );
                    // downloadExcelData();
                  },
                  icon: const Icon(Icons.print),
                )
              : const SizedBox(),
        ],
      ),
      body: pdfData != null
          ? SfPdfViewer.memory(
              pdfData!,
            )
          : Center(
              child: Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                padding: const EdgeInsets.all(8),
                child: CircularProgressIndicator(
                  color: Theme.of(context).primaryColor,
                  strokeWidth: 2,
                ),
              ),
            ),
    );
  }
}

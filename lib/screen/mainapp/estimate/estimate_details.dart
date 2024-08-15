import 'dart:typed_data';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../firebase/datamodel/datamodel.dart';
import '../../../firebase/datamodel/invoice_model.dart';
import '../../../firebase/firestore_provider.dart';
import '../../../provider/download_file_provider.dart';
import '../../../provider/pdf_creation_provider.dart';
import '../../../utlities/provider/localdb.dart';
import '../../../utlities/utlities.dart';
import '../../ui/commenwidget.dart';
import '../../ui/sidebar.dart';
import '../billing/billing_one.dart';
import '../billing/billing_two.dart';
import '../invoice/invoice_creation.dart';
import 'print_view/print_view_estimate.dart';

class EstimateDetails extends StatefulWidget {
  final EstimateDataModel estimateData;
  const EstimateDetails({super.key, required this.estimateData});

  @override
  State<EstimateDetails> createState() => _EstimateDetailsState();
}

class _EstimateDetailsState extends State<EstimateDetails> {
  var companyData = ProfileModel();
  TableRow tableRow(String? title, String? value) {
    return TableRow(
      children: [
        Padding(
          padding: const EdgeInsets.all(3),
          child: Text(
            title ?? "",
            style: Theme.of(context).textTheme.titleSmall,
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(3),
          child: Text(
            value ?? "",
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ),
      ],
    );
  }

  String getItems() {
    String count = "0";
    int tmpcount = 0;
    for (var element in widget.estimateData.products!) {
      tmpcount += element.qty!;
    }
    count = tmpcount.toString();
    return count;
  }

  printEstimate() async {
    loading(context);
    try {
      await LocalDbProvider().fetchInfo(type: LocalData.companyid).then((cid) async {
        if (cid != null) {
          await FireStoreProvider().getCompanyDocInfo(cid: cid).then((companyInfo) {
            if (companyInfo != null) {
              setState(() {
                companyData.companyName = companyInfo["company_name"];
                companyData.address = companyInfo["address"];
              });

              Navigator.pop(context);
              Navigator.push(
                context,
                CupertinoPageRoute(
                  builder: (context) => PrintViewEstimate(
                    estimateData: widget.estimateData,
                    companyInfo: companyData,
                  ),
                ),
              );
            } else {
              Navigator.pop(context);
            }
          });
        } else {
          Navigator.pop(context);
        }
      });
    } catch (e) {
      Navigator.pop(context);
      snackBarCustom(context, false, e.toString());
    }
  }

  downloadPrintEnquiry() async {
    loading(context);
    try {
      await LocalDbProvider().fetchInfo(type: LocalData.companyid).then((cid) async {
        if (cid != null) {
          await FireStoreProvider().getCompanyDocInfo(cid: cid).then((companyInfo) async {
            if (companyInfo != null) {
              setState(() {
                companyData.companyName = companyInfo["company_name"];
                companyData.address = companyInfo["address"];
              });

              var pdf = EnqueryPdfCreation(
                estimateData: widget.estimateData,
                type: PdfType.estimate,
                companyInfo: companyData,
              );
              var dataResult = await pdf.createPdfA4();
              if (dataResult != null) {
                var data = Uint8List.fromList(dataResult);
                await DownloadFileOffline(
                        fileData: data, fileName: "Estimate ${widget.estimateData.estimateid}", fileext: "pdf")
                    .startDownload()
                    .then((value) {
                  Navigator.pop(context);
                  if (value != null && value.isNotEmpty) {
                    downloadFileSnackBarCustom(context, isSuccess: true, msg: "Download Estimate", path: value);
                    // snackBarCustom(context, true, "Download Estimate ${widget.estimateData.estimateid}");
                  } else {
                    snackBarCustom(context, false, "Failed to Download");
                  }
                });
              }
            } else {
              Navigator.pop(context);
            }
          });
        } else {
          Navigator.pop(context);
        }
      });
    } catch (e) {
      Navigator.pop(context);
      snackBarCustom(context, false, e.toString());
    }
  }

  deleteEnquery() async {
    loading(context);
    try {
      await FireStoreProvider().deleteEstimate(docID: widget.estimateData.docID!).then((value) {
        Navigator.pop(context);
        Navigator.pop(context, true);
        snackBarCustom(context, true, "Successfully Deleted");
      });
    } catch (e) {
      Navigator.pop(context);
      snackBarCustom(context, false, e.toString());
    }
  }

  duplicateEstimate() async {
    loading(context);
    try {
      await LocalDbProvider().fetchInfo(type: LocalData.companyid).then((cid) async {
        if (cid != null) {
          await FireStoreProvider().duplicateEstimate(docID: widget.estimateData.docID!, cid: cid).then((value) {
            Navigator.pop(context);
            Navigator.pop(context, true);
            snackBarCustom(context, true, "Successfully Duplicate a Estimate");
          });
        }
      });
    } catch (e) {
      Navigator.pop(context);
      throw e.toString();
    }
  }

  List<CategoryDataModel> categoryList = [];
  bool isloading = false;
  checkProductsList() async {
    if (widget.estimateData.products!.isEmpty) {
      setState(() {
        isloading = true;
      });
      await LocalDbProvider().fetchInfo(type: LocalData.companyid).then((cid) async {
        await FireStoreProvider().categoryListing(cid: cid).then((value) {
          if (value != null && value.docs.isNotEmpty) {
            for (var categorylist in value.docs) {
              CategoryDataModel model = CategoryDataModel();
              model.categoryName = categorylist["category_name"].toString();
              model.postion = categorylist["postion"];
              model.tmpcatid = categorylist.id;
              model.discount = categorylist["discount"];
              setState(() {
                categoryList.add(model);
              });
            }
          }
        });
      });
      await FireStoreProvider().getEstimateProducts(docid: widget.estimateData.docID!).then((products) {
        if (products != null && products.docs.isNotEmpty) {
          for (var product in products.docs) {
            var productDataModel = ProductDataModel();

            productDataModel.categoryid = product["category_id"];
            productDataModel.categoryName = product["category_name"];
            productDataModel.price = product["price"];
            productDataModel.productId = product["product_id"];
            productDataModel.productName = product["product_name"];
            productDataModel.qty = product["qty"];
            productDataModel.productCode = product["product_code"] ?? "";
            productDataModel.discountLock = product["discount_lock"];
            var getCategoryid = categoryList.indexWhere((elements) => elements.tmpcatid == product["category_id"]);
            productDataModel.discount = categoryList[getCategoryid].discount;
            productDataModel.docid = product.id;
            productDataModel.name = product["name"];
            productDataModel.productContent = product["product_content"];
            productDataModel.productImg = product["product_img"];
            productDataModel.qrCode = product["qr_code"];
            productDataModel.videoUrl = product["video_url"];
            setState(() {
              widget.estimateData.products!.add(productDataModel);
            });
          }
          setState(() {
            isloading = false;
          });
        }
      });
    }
  }

  @override
  void initState() {
    checkProductsList();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        title: Text(widget.estimateData.estimateid!),
        actions: [
          IconButton(
            tooltip: "Print Enquiry",
            splashRadius: 29,
            onPressed: () {
              printEstimate();
            },
            icon: const Icon(
              Icons.print,
            ),
          ),
          IconButton(
            tooltip: "Delete Estimate",
            splashRadius: 29,
            onPressed: () async {
              await confirmationDialog(
                context,
                title: "Alert",
                message: "Do you want delete Estimate?",
              ).then((value) {
                if (value != null && value == true) {
                  deleteEnquery();
                }
              });
            },
            icon: const Icon(
              Icons.delete,
            ),
          ),
          IconButton(
            tooltip: "Copy Estimate",
            splashRadius: 29,
            onPressed: () async {
              await confirmationDialog(
                context,
                title: "Alert",
                message: "Do you want Duplicate Estimate?",
              ).then((value) {
                if (value != null && value == true) {
                  duplicateEstimate();
                }
              });
            },
            icon: const Icon(
              Icons.copy,
            ),
          ),
          IconButton(
            tooltip: "Download PDF",
            splashRadius: 29,
            onPressed: () async {
              await confirmationDialog(
                context,
                title: "Alert",
                message: "Do you want Download Estimate?",
              ).then((value) {
                if (value != null && value == true) {
                  downloadPrintEnquiry();
                }
              });
            },
            icon: const Icon(
              Icons.file_download_outlined,
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: Theme.of(context).primaryColor,
        shape: RoundedRectangleBorder(
          side: BorderSide.none,
          borderRadius: BorderRadius.circular(10),
        ),
        onPressed: () async {
          await LocalDbProvider().getBillingIndex().then((value) async {
            if (value != null) {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) {
                  if (value == 1) {
                    return BillingOne(
                      isEdit: true,
                      estimateData: widget.estimateData,
                    );
                  } else {
                    return BillingTwo(
                      isEdit: true,
                      estimateData: widget.estimateData,
                    );
                  }
                }),
              );
            }
          });
        },
        label: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.edit),
            SizedBox(
              width: 10,
            ),
            Text("Edit"),
          ],
        ),
      ),
      backgroundColor: const Color(0xffEEEEEE),
      body: ListView(
        padding: const EdgeInsets.all(10),
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "Estimate Details",
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(
                  height: 10,
                ),
                Table(
                  children: [
                    tableRow("Estimate No", widget.estimateData.estimateid),
                    tableRow(
                      "Estimate Date",
                      DateFormat('dd-MM-yyyy HH:mm a').format(widget.estimateData.createddate!),
                    ),
                  ],
                ),
                Center(
                  child: TextButton(
                    onPressed: () async {
                      await confirmationDialog(
                        context,
                        title: "Alert",
                        message: "Do you want Convert the Bill of Supply?",
                      ).then((value) {
                        if (value != null && value == true) {
                          Navigator.pop(context);
                          sidebar.toggletab(13);
                          InvoiceModel model = InvoiceModel();
                          model.isEstimateConverted = true;
                          model.address = widget.estimateData.customer?.address ?? "";
                          model.deliveryaddress = widget.estimateData.customer?.address ?? "";
                          model.partyName = widget.estimateData.customer?.customerName ?? "";
                          model.phoneNumber = widget.estimateData.customer?.mobileNo ?? "";
                          model.totalBillAmount = widget.estimateData.price?.total?.toStringAsFixed(2) ?? "";

                          model.price = widget.estimateData.price;
                          model.listingProducts = [];
                          for (var element in widget.estimateData.products!) {
                            InvoiceProductModel productElement = InvoiceProductModel();
                            productElement.productID = element.productId;
                            productElement.productName = element.productName;
                            productElement.qty = element.qty;
                            productElement.rate = element.price;
                            productElement.total = element.qty!.toDouble() * element.price!;
                            productElement.unit = element.productContent;
                            productElement.discountLock = element.discountLock;
                            productElement.discount = element.discount;
                            productElement.categoryID = element.companyId;
                            model.listingProducts!.add(productElement);
                          }
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => InvoiceCreation(invoice: model),
                            ),
                          );
                        }
                      });
                    },
                    child: const Text("Convert to Bill of Supply"),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(
            height: 10,
          ),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "Price",
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(
                  height: 10,
                ),
                Table(
                  children: [
                    tableRow(
                      "Total",
                      "₹${widget.estimateData.price!.total}",
                    ),
                    tableRow(
                      "Subtotal",
                      "₹${widget.estimateData.price!.subTotal}",
                    ),
                    tableRow(
                      "Discount",
                      "₹${widget.estimateData.price!.discountValue}",
                    ),
                    tableRow(
                      "Extra Discount",
                      "₹${widget.estimateData.price!.extraDiscountValue}",
                    ),
                    tableRow(
                      "Package Charge",
                      "₹${widget.estimateData.price!.packageValue}",
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(
            height: 10,
          ),
          widget.estimateData.customer != null
              ? Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        "Customer",
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      Table(
                        children: [
                          tableRow(
                            "Customer Name",
                            widget.estimateData.customer!.customerName,
                          ),
                          tableRow(
                            "City",
                            widget.estimateData.customer!.city,
                          ),
                          tableRow(
                            "Address",
                            widget.estimateData.customer!.address,
                          ),
                          tableRow(
                            "Email",
                            widget.estimateData.customer!.email,
                          ),
                          tableRow(
                            "Mobile No",
                            widget.estimateData.customer!.mobileNo,
                          ),
                        ],
                      ),
                    ],
                  ),
                )
              : const SizedBox(),
          widget.estimateData.customer != null
              ? const SizedBox(
                  height: 10,
                )
              : const SizedBox(),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Products(${widget.estimateData.products!.length})",
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    Text(
                      "Items - ${getItems()}",
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
                const SizedBox(
                  height: 10,
                ),
                isloading == false
                    ? ListView.builder(
                        primary: false,
                        shrinkWrap: true,
                        itemCount: widget.estimateData.products!.length,
                        itemBuilder: (context, index) {
                          var product = widget.estimateData.products![index];
                          return Container(
                            margin: EdgeInsets.only(
                              bottom: widget.estimateData.products!.length - 1 != index ? 10 : 0,
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  height: 80,
                                  width: 80,
                                  decoration: BoxDecoration(
                                    color: Colors.grey.shade300,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                                const SizedBox(
                                  width: 10,
                                ),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      // Text(
                                      //   product.categoryName ?? "",
                                      //   style: Theme.of(context).textTheme.bodySmall,
                                      // ),
                                      Text(
                                        product.productName ?? "",
                                        style: Theme.of(context).textTheme.titleSmall,
                                      ),
                                      const SizedBox(height: 5),
                                      Text(
                                        "₹${product.price} / ${product.productContent}",
                                        style: Theme.of(context).textTheme.bodySmall,
                                      ),
                                      Text(
                                        "Quantity : ${product.qty}",
                                        style: Theme.of(context).textTheme.bodySmall,
                                      ),
                                      Row(
                                        children: [
                                          Expanded(
                                            child: Text(
                                              "₹${product.price! * product.qty!}",
                                              textAlign: TextAlign.right,
                                              style: Theme.of(context).textTheme.titleSmall,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      )
                    : const Center(
                        child: CircularProgressIndicator(),
                      ),
              ],
            ),
          ),
          const SizedBox(height: 80),
        ],
      ),
    );
  }
}

import 'dart:developer';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sri_sakthivel_fireworks_pos/firebase/datamodel/invoice_model.dart';
import 'package:sri_sakthivel_fireworks_pos/firebase/firestore_provider.dart';
import 'package:sri_sakthivel_fireworks_pos/provider/invoice_excel_creation.dart';
import 'package:sri_sakthivel_fireworks_pos/screen/mainapp/invoice/invoice_creation.dart';
import 'package:sri_sakthivel_fireworks_pos/screen/ui/commenwidget.dart';
import 'package:sri_sakthivel_fireworks_pos/utlities/utlities.dart';

import '../../../firebase/datamodel/datamodel.dart';
import '../../../provider/download_file_provider.dart';
import '../homelanding.dart';
import 'inovice_details.dart';
import 'invoice_filter.dart';

class InvoiceListing extends StatefulWidget {
  const InvoiceListing({super.key});

  @override
  State<InvoiceListing> createState() => _InvoiceListingState();
}

class _InvoiceListingState extends State<InvoiceListing> {
  Future? invoiceHandler;
  final _scrollController = ScrollController();

  TextEditingController search = TextEditingController();

  List<InvoiceModel> invoiceList = [];
  List<InvoiceModel> fullInvoiceList = [];
  List<InvoiceModel> tmpinvoiceList = [];

  int countItems = 10;
  int currentPage = 1;

  Future getInvoiceList() async {
    try {
      setState(() {
        countItems = 10;
        currentPage = 1;
        invoiceList.clear();
        fullInvoiceList.clear();
        tmpinvoiceList.clear();
      });
      return await FireStoreProvider().getInvoiceListing().then((value) {
        if (value.docs.isNotEmpty) {
          for (var element in value.docs) {
            InvoiceModel model = InvoiceModel();
            model.docID = element.id;
            model.partyName = element["party_name"];
            model.address = element["address"];
            model.biilDate = (element["bill_date"] as Timestamp).toDate();
            model.billNo = element["bill_no"];
            model.phoneNumber = element["phone_number"];
            model.totalBillAmount = element["total_amount"];
            model.transportName = element["transport_name"];
            model.transportNumber = element["transport_number"];
            model.listingProducts = [];
            if (element["products"] != null) {
              for (var productElement in element["products"]) {
                InvoiceProductModel models = InvoiceProductModel();
                models.productID = productElement["product_id"];
                models.productName = productElement["product_name"];
                models.qty = productElement["qty"];
                models.rate = productElement["rate"].toDouble();
                models.total = productElement["total"].toDouble();
                models.unit = productElement["unit"];
                models.categoryID = productElement["category_id"];
                models.discountLock = productElement["discount_lock"];
                models.discount = productElement["discount"];
                setState(() {
                  model.listingProducts!.add(models);
                });
              }
            }
            model.deliveryaddress = element["delivery_address"] ?? "";

            if (element.data().containsKey('price') && element["price"] != null) {
              var calcula = BillingCalCulation();
              calcula.discount = element["price"]["discount"];
              calcula.discountValue = element["price"]["discount_value"];
              calcula.discountsys = element["price"]["discount_sys"];
              calcula.extraDiscount = element["price"]["extra_discount"];
              calcula.extraDiscountValue = element["price"]["extra_discount_value"];
              calcula.extraDiscountsys = element["price"]["extra_discount_sys"];
              calcula.package = element["price"]["package"];
              calcula.packageValue = element["price"]["package_value"];
              calcula.packagesys = element["price"]["package_sys"];
              calcula.subTotal = element["price"]["sub_total"];
              calcula.total = element["price"]["total"];
              model.price = calcula;
            }
            setState(() {
              fullInvoiceList.add(model);
            });
          }
          tmpinvoiceList.addAll(fullInvoiceList);
        }
        for (var i = 0; i < 10; i++) {
          if (fullInvoiceList.length > i) {
            invoiceList.add(fullInvoiceList[i]);
          }
        }
        return invoiceList;
      });
    } catch (e) {
      log(e.toString());
      snackBarCustom(context, false, e.toString());
      throw e.toString();
    }
  }

  getProducts({required InvoiceModel invoice}) async {
    try {
      loading(context);
      if (invoice.listingProducts!.isEmpty) {
        await FireStoreProvider().getInvoiceProductListing(docID: invoice.docID!).then((value) {
          if (value.docs.isNotEmpty) {
            for (var element in value.docs) {
              InvoiceProductModel model = InvoiceProductModel();
              model.productID = element["product_id"];
              model.productName = element["product_name"];
              model.qty = element["qty"];
              model.rate = element["rate"];
              model.total = element["total"];
              model.unit = element["unit"];
              model.docID = element.id;
              model.categoryID = element["category_id"];
              model.discountLock = element["discount_lock"];
              model.discount = element["discount"];
              setState(() {
                invoice.listingProducts!.add(model);
              });
            }
            Navigator.pop(context);
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => InvoiceDetails(
                  invoice: invoice,
                ),
              ),
            ).then((value) {
              if (value != null && value) {
                setState(() {
                  invoiceHandler = getInvoiceList();
                });
              }
            });
          } else {
            Navigator.pop(context);
            snackBarCustom(context, false, "Something went Wrong");
          }
        });
      } else {
        Navigator.pop(context);
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => InvoiceDetails(
              invoice: invoice,
            ),
          ),
        ).then((value) {
          if (value != null && value) {
            setState(() {
              invoiceHandler = getInvoiceList();
            });
          }
        });
      }
    } catch (e) {
      Navigator.pop(context);
      log(e.toString());
      snackBarCustom(context, false, e.toString());
    }
  }

  searchInvoice() {
    if (search.text.isNotEmpty) {
      setState(() {
        invoiceList.clear();
      });
      log("Workeding");
      Iterable<InvoiceModel> tmpList = tmpinvoiceList.where((element) {
        if (element.partyName != null &&
            element.partyName!
                .toLowerCase()
                .replaceAll(' ', '')
                .startsWith(search.text.toLowerCase().replaceAll(' ', ''))) {
          return true;
        } else if (element.phoneNumber != null &&
            element.phoneNumber!
                .toLowerCase()
                .replaceAll(' ', '')
                .startsWith(search.text.toLowerCase().replaceAll(' ', ''))) {
          return true;
        } else if (element.phoneNumber != null &&
            element.phoneNumber!
                .toLowerCase()
                .replaceAll(' ', '')
                .contains(search.text.toLowerCase().replaceAll(' ', ''))) {
          return true;
        } else if (element.billNo != null &&
            element.billNo!.toLowerCase().replaceAll(' ', '').contains(search.text.toLowerCase().replaceAll(' ', ''))) {
          return true;
        } else {
          return false;
        }
      });
      log("is Working");
      if (tmpList.isNotEmpty) {
        for (var element in tmpList) {
          setState(() {
            invoiceList.add(element);
          });
        }
      }
    } else {
      setState(() {
        invoiceList.clear();
        invoiceList.addAll(tmpinvoiceList);
      });
    }
  }

  downloadInvoiceOverallExcel() async {
    try {
      loading(context);
      await InvoiceExcel(inviceData: invoiceList).createInvoiceExcel().then((value) async {
        if (value != null) {
          Uint8List fileData = Uint8List.fromList(value);
          await DownloadFileOffline(
            fileData: fileData,
            fileName: "Invoice Excel",
            fileext: 'xlsx',
          ).startDownload().then((value) {
            if (value != null) {
              Navigator.pop(context);
              downloadFileSnackBarCustom(
                context,
                isSuccess: true,
                msg: "Invoice Excel Download Successfully",
                path: value,
              );
              // snackBarCustom(context, true, "Enquiry Excel Download Successfully");
            }
          }).catchError((onError) {
            Navigator.pop(context);
            snackBarCustom(context, false, onError.toString());
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

  downloadOption() async {
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Download Options"),
        content: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text("PDF"),
              onTap: () {
                Navigator.pop(context, "pdf");
              },
            ),
            ListTile(
              title: const Text("Excel"),
              onTap: () {
                Navigator.pop(context, "excel");
              },
            ),
          ],
        ),
      ),
    ).then((value) {
      if (value != null) {
        if (value == "pdf") {
        } else if (value == "excel") {
          downloadInvoiceOverallExcel();
        }
      }
    });
  }

  showFilterSheet() async {
    var result = await showModalBottomSheet(
      shape: RoundedRectangleBorder(
        side: BorderSide.none,
        borderRadius: BorderRadius.circular(10),
      ),
      isScrollControlled: true,
      context: context,
      builder: (builder) {
        return const InvoiceFilter();
      },
    );
    if (result != null) {
      filtersInvoiceFun(
        result["FromDate"],
        result["ToDate"],
      );
      log(result["FromDate"].toString());
    }
  }

  filtersInvoiceFun(DateTime? fromDate, DateTime? toDate) async {
    try {
      setState(() {
        invoiceList.clear();
        countItems = 10;
        currentPage = 1;
        fullInvoiceList.clear();
        tmpinvoiceList.clear();
      });
      loading(context);
      await FireStoreProvider().filterInvoice(fromDate: fromDate!, toDate: toDate!).then((value) {
        log(value.docs.length.toString());
        if (value.docs.isNotEmpty) {
          for (var element in value.docs) {
            InvoiceModel model = InvoiceModel();
            model.docID = element.id;
            model.partyName = element["party_name"];
            model.address = element["address"];
            model.biilDate = (element["bill_date"] as Timestamp).toDate();
            model.billNo = element["bill_no"];
            model.phoneNumber = element["phone_number"];
            model.totalBillAmount = element["total_amount"];
            model.transportName = element["transport_name"];
            model.transportNumber = element["transport_number"];
            model.listingProducts = [];
            if (element["products"] != null) {
              for (var productElement in element["products"]) {
                InvoiceProductModel models = InvoiceProductModel();
                models.productID = productElement["product_id"];
                models.productName = productElement["product_name"];
                models.qty = productElement["qty"];
                models.rate = productElement["rate"].toDouble();
                models.total = productElement["total"].toDouble();
                models.unit = productElement["unit"];
                models.categoryID = productElement["category_id"];
                models.discountLock = productElement["discount_lock"];
                models.discount = productElement["discount"];
                setState(() {
                  model.listingProducts!.add(models);
                });
              }
            }
            model.deliveryaddress = element["delivery_address"] ?? "";

            if (element.data().containsKey('price') && element["price"] != null) {
              var calcula = BillingCalCulation();
              calcula.discount = element["price"]["discount"];
              calcula.discountValue = element["price"]["discount_value"];
              calcula.discountsys = element["price"]["discount_sys"];
              calcula.extraDiscount = element["price"]["extra_discount"];
              calcula.extraDiscountValue = element["price"]["extra_discount_value"];
              calcula.extraDiscountsys = element["price"]["extra_discount_sys"];
              calcula.package = element["price"]["package"];
              calcula.packageValue = element["price"]["package_value"];
              calcula.packagesys = element["price"]["package_sys"];
              calcula.subTotal = element["price"]["sub_total"];
              calcula.total = element["price"]["total"];
              model.price = calcula;
            }

            setState(() {
              fullInvoiceList.add(model);
            });
          }
          tmpinvoiceList.addAll(fullInvoiceList);
          for (var i = 0; i < 10; i++) {
            if (fullInvoiceList.length > i) {
              invoiceList.add(fullInvoiceList[i]);
            }
          }
          setState(() {});
        }
        Navigator.pop(context);
      });
    } catch (e) {
      log(e.toString());
      Navigator.pop(context);
      snackBarCustom(context, false, e.toString());
    }
  }

  void _loadMore() {
    if (_scrollController.position.pixels == _scrollController.position.maxScrollExtent) {
      setState(() {
        log(((countItems * currentPage)).toString());
        log(((countItems * currentPage) + countItems).toString());
        for (var i = (countItems * currentPage); i < ((countItems * currentPage) + countItems); i++) {
          if (fullInvoiceList.length > i) {
            invoiceList.add(fullInvoiceList[i]);
          }
        }
        currentPage += 1;
        log("its Worked");
      });
    }
  }

  @override
  void initState() {
    invoiceHandler = getInvoiceList();
    _scrollController.addListener(_loadMore);
    super.initState();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffEEEEEE),
      appBar: AppBar(
        leading: IconButton(
          splashRadius: 20,
          onPressed: () {
            homeKey.currentState!.openDrawer();
          },
          icon: const Icon(Icons.menu),
        ),
        title: Text("Bill of Supply (${invoiceList.length})"),
        actions: [
          IconButton(
            splashRadius: 20,
            tooltip: "Download Excel File",
            onPressed: () {
              downloadInvoiceOverallExcel();
              // downloadOption();
              // downloadExcelData();
            },
            icon: const Icon(Icons.file_download_outlined),
          ),
          IconButton(
            splashRadius: 20,
            tooltip: "Create New Bill of Supply",
            onPressed: () {
              // downloadExcelData();
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const InvoiceCreation(),
                ),
              ).then((value) {
                if (value != null && value) {
                  setState(() {
                    invoiceHandler = getInvoiceList();
                  });
                }
              });
            },
            icon: const Icon(Icons.add),
          ),
        ],
      ),
      body: FutureBuilder(
        future: invoiceHandler,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done && snapshot.data != null) {
            return RefreshIndicator(
              onRefresh: () async {
                setState(() {
                  invoiceHandler = getInvoiceList();
                });
              },
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                  children: [
                    SizedBox(
                      child: TextFormField(
                        controller: search,
                        keyboardType: TextInputType.text,
                        textInputAction: TextInputAction.search,
                        decoration: InputDecoration(
                          hintText: "Search Bill of Supply",
                          filled: true,
                          fillColor: Colors.white,
                          prefixIcon: const Icon(Icons.search),
                          suffixIcon: IconButton(
                            splashRadius: 20,
                            onPressed: () async {
                              await showFilterSheet();
                            },
                            icon: const Icon(Icons.filter_list),
                          ),
                        ),
                        onTapOutside: (event) {
                          FocusManager.instance.primaryFocus!.unfocus();
                        },
                        onEditingComplete: () {
                          FocusManager.instance.primaryFocus!.unfocus();
                        },
                        onChanged: (v) {
                          searchInvoice();
                        },
                      ),
                    ),
                    Expanded(
                      child: ListView.builder(
                        controller: _scrollController,
                        itemCount: invoiceList.length,
                        itemBuilder: (context, index) {
                          if (invoiceList[index].billNo == null) {
                            return const SizedBox();
                          } else {
                            return GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => InvoiceDetails(
                                      invoice: invoiceList[index],
                                    ),
                                  ),
                                ).then((value) {
                                  if (value != null && value) {
                                    setState(() {
                                      invoiceHandler = getInvoiceList();
                                    });
                                  }
                                });
                              },
                              child: Container(
                                margin: const EdgeInsets.only(top: 10),
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                  color: Colors.white,
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          invoiceList[index].billNo ?? "",
                                          style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                                                fontWeight: FontWeight.bold,
                                              ),
                                        ),
                                        Text(
                                          DateFormat('dd-MM-yyyy').format(invoiceList[index].biilDate!),
                                          style: Theme.of(context).textTheme.bodySmall,
                                        ),
                                      ],
                                    ),
                                    Row(
                                      crossAxisAlignment: CrossAxisAlignment.end,
                                      children: [
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              const SizedBox(height: 10),
                                              Text(
                                                invoiceList[index].partyName ?? "",
                                                style: Theme.of(context).textTheme.titleLarge!.copyWith(
                                                      fontWeight: FontWeight.bold,
                                                    ),
                                              ),
                                              const SizedBox(height: 5),
                                              Text(
                                                invoiceList[index].address ?? "",
                                                style: Theme.of(context).textTheme.bodyMedium,
                                              ),
                                              Text(
                                                invoiceList[index].phoneNumber ?? "",
                                                style: Theme.of(context).textTheme.bodyMedium,
                                              ),
                                            ],
                                          ),
                                        ),
                                        const SizedBox(width: 10),
                                        Text(
                                          "\u{20B9}${invoiceList[index].totalBillAmount ?? ""}",
                                          style: Theme.of(context).textTheme.titleLarge!.copyWith(
                                                fontWeight: FontWeight.bold,
                                              ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }
                        },
                      ),
                    ),
                  ],
                ),
              ),
            );
          } else {
            return futureLoading(context);
          }
        },
      ),
    );
  }
}

import 'dart:developer';
import 'dart:typed_data';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sri_sakthivel_fireworks_pos/firebase/firestore_provider.dart';
import 'package:sri_sakthivel_fireworks_pos/screen/mainapp/enquiry/enquiry_filter.dart';
import 'package:sri_sakthivel_fireworks_pos/screen/mainapp/enquiry/enquriy_details.dart';
import 'package:sri_sakthivel_fireworks_pos/screen/ui/commenwidget.dart';
import 'package:sri_sakthivel_fireworks_pos/utlities/utlities.dart';

import '../../../firebase/datamodel/datamodel.dart';
import '../../../provider/download_file_provider.dart';
import '../../../provider/enquiry_excel_cration.dart';
import '../../../utlities/provider/localdb.dart';
import '../homelanding.dart';

class EnquiryListing extends StatefulWidget {
  const EnquiryListing({super.key});

  @override
  State<EnquiryListing> createState() => _EnquiryListingState();
}

class _EnquiryListingState extends State<EnquiryListing> {
  List<EstimateDataModel> enquiryList = [];
  List<EstimateDataModel> tmpEnquiryList = [];
  TextEditingController searchForm = TextEditingController();
  Future getEnquiryInfo() async {
    try {
      setState(() {
        enquiryList.clear();
      });
      var cid = await LocalDbProvider().fetchInfo(type: LocalData.companyid);
      if (cid != null) {
        var enquiry = await FireStoreProvider().getEnquiry(cid: cid);
        if (enquiry != null && enquiry.docs.isNotEmpty) {
          log("Doc Length ${enquiry.docs.length}");
          for (var enquiryData in enquiry.docs) {
            var calcula = BillingCalCulation();
            calcula.discount = enquiryData["price"]["discount"];
            calcula.discountValue = enquiryData["price"]["discount_value"];
            calcula.discountsys = enquiryData["price"]["discount_sys"];
            calcula.extraDiscount = enquiryData["price"]["extra_discount"];
            calcula.extraDiscountValue = enquiryData["price"]["extra_discount_value"];
            calcula.extraDiscountsys = enquiryData["price"]["extra_discount_sys"];
            calcula.package = enquiryData["price"]["package"];
            calcula.packageValue = enquiryData["price"]["package_value"];
            calcula.packagesys = enquiryData["price"]["package_sys"];
            calcula.subTotal = enquiryData["price"]["sub_total"];
            calcula.total = enquiryData["price"]["total"];

            CustomerDataModel? customer = CustomerDataModel();
            if (enquiryData["customer"] != null) {
              customer.address = enquiryData["customer"]["address"] ?? "";
              customer.state = enquiryData["customer"]["state"] ?? "";
              customer.city = enquiryData["customer"]["city"] ?? "";
              customer.customerName = enquiryData["customer"]["customer_name"] ?? "";
              customer.email = enquiryData["customer"]["email"] ?? "";
              customer.mobileNo = enquiryData["customer"]["mobile_no"] ?? "";
            }

            List<ProductDataModel> tmpProducts = [];

            setState(() {
              tmpProducts.clear();
            });

            // await FireStoreProvider().getEnquiryProducts(docid: enquiryData.id).then((products) {
            //   if (products != null && products.docs.isNotEmpty) {
            //     for (var product in products.docs) {
            //       var productDataModel = ProductDataModel();
            //       productDataModel.categoryid = product["category_id"];
            //       productDataModel.categoryName = product["category_name"];
            //       productDataModel.price = product["price"];
            //       productDataModel.productId = product["product_id"];
            //       productDataModel.productName = product["product_name"];
            //       productDataModel.qty = product["qty"];
            //       productDataModel.productCode = product["product_code"] ?? "";
            //       productDataModel.discountLock = product["discount_lock"];
            //       productDataModel.docid = product.id;
            //       productDataModel.name = product["name"];
            //       productDataModel.productContent = product["product_content"];
            //       productDataModel.productImg = product["product_img"];
            //       productDataModel.qrCode = product["qr_code"];
            //       productDataModel.videoUrl = product["video_url"];
            //       setState(() {
            //         tmpProducts.add(productDataModel);
            //       });
            //     }
            //   }
            // });

            setState(() {
              enquiryList.add(
                EstimateDataModel(
                  docID: enquiryData.id,
                  createddate: DateTime.parse(
                    enquiryData["created_date"].toDate().toString(),
                  ),
                  enquiryid: enquiryData['enquiry_id'],
                  estimateid: enquiryData["estimate_id"],
                  price: calcula,
                  customer: customer,
                  products: tmpProducts,
                ),
              );
            });
          }
        }
        setState(() {
          log("enquiry Length ${enquiryList.length}");
          tmpEnquiryList.addAll(enquiryList);
          log("length ${tmpEnquiryList.length}");
        });
        return enquiry;
      }
    } catch (e) {
      log(e.toString());
      snackBarCustom(context, false, e.toString());
      return null;
    }
  }

  searchEnquiryFun(String? value) async {
    if (value != null && searchForm.text.isNotEmpty) {
      if (value.isNotEmpty) {
        setState(() {
          enquiryList.clear();
        });
        log("Workeding");
        Iterable<EstimateDataModel> tmpList = tmpEnquiryList.where((element) {
          if (element.customer != null &&
              element.customer!.customerName != null &&
              element.customer!.customerName!
                  .toLowerCase()
                  .replaceAll(' ', '')
                  .startsWith(value.toLowerCase().replaceAll(' ', ''))) {
            return true;
          } else if (element.customer != null &&
              element.customer!.mobileNo != null &&
              element.customer!.mobileNo!
                  .toLowerCase()
                  .replaceAll(' ', '')
                  .startsWith(value.toLowerCase().replaceAll(' ', ''))) {
            return true;
          } else if (element.customer != null &&
              element.customer!.city != null &&
              element.customer!.city!
                  .toLowerCase()
                  .replaceAll(' ', '')
                  .startsWith(value.toLowerCase().replaceAll(' ', ''))) {
            return true;
          } else if (element.customer != null &&
              element.customer!.state != null &&
              element.customer!.state!
                  .toLowerCase()
                  .replaceAll(' ', '')
                  .startsWith(value.toLowerCase().replaceAll(' ', ''))) {
            return true;
          } else if (element.customer != null &&
              element.enquiryid!
                  .toLowerCase()
                  .replaceAll(' ', '')
                  .startsWith(value.toLowerCase().replaceAll(' ', ''))) {
            return true;
          } else if (element.enquiryid!.toLowerCase().contains(value.toLowerCase())) {
            return true;
          } else {
            return false;
          }
        });
        log("is Working");
        if (tmpList.isNotEmpty) {
          setState(() {
            enquiryList.addAll(tmpList);
          });
        }
      }
    } else {
      log("is Worked ${tmpEnquiryList.length}");
      setState(() {
        enquiryList.clear();
        enquiryList.addAll(tmpEnquiryList);
      });
    }
  }

  filtersEnquiryFun(
    DateTime? fromDate,
    DateTime? toDate,
    String? customerID,
  ) async {
    Iterable<EstimateDataModel> tmpList = tmpEnquiryList.where((element) {
      if (fromDate == null && toDate == null && customerID != null) {
        if (element.customer!.docID == customerID) {
          return true;
        }
      } else if (fromDate != null && toDate != null) {
        if (element.createddate!.microsecondsSinceEpoch < fromDate.microsecondsSinceEpoch &&
            element.createddate!.microsecondsSinceEpoch > toDate.microsecondsSinceEpoch) {
          true;
        }
      } else if (fromDate != null && toDate != null && customerID != null) {
        if (element.createddate!.microsecondsSinceEpoch < fromDate.microsecondsSinceEpoch &&
            element.createddate!.microsecondsSinceEpoch > toDate.microsecondsSinceEpoch &&
            element.customer!.docID == customerID) {
          true;
        }
      }
      return false;
    });

    if (tmpList.isNotEmpty) {
      setState(() {
        enquiryList.addAll(tmpList);
      });
    }
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
        return const EnquiryFilter();
      },
    );
    if (result != null) {
      filtersEnquiryFun(
        result["FromDate"],
        result["ToDate"],
        result["CustomerID"],
      );
    }
  }

  downloadExcelData() async {
    try {
      loading(context);
      await EnquiryExcel(enquiryData: enquiryList, isEstimate: false).createCustomerExcel().then((value) async {
        if (value != null) {
          Uint8List fileData = Uint8List.fromList(value);
          await DownloadFileOffline(
            fileData: fileData,
            fileName: "Enquiry Excel",
            fileext: 'xlsx',
          ).startDownload().then((value) {
            if (value != null) {
              Navigator.pop(context);
              downloadFileSnackBarCustom(
                context,
                isSuccess: true,
                msg: "Enquiry Excel Download Successfully",
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

  late Future enquryHandler;

  @override
  void initState() {
    super.initState();
    enquryHandler = getEnquiryInfo();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffEEEEEE),
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            homeKey.currentState!.openDrawer();
          },
          icon: const Icon(Icons.menu),
        ),
        title: const Text("Enquiry"),
        actions: [
          IconButton(
            tooltip: "Download Excel File",
            onPressed: () {
              downloadExcelData();
            },
            icon: const Icon(Icons.file_download_outlined),
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
          var result = await showFilterSheet();
          if (result != null) {}
        },
        label: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.filter_list_outlined),
            SizedBox(
              width: 10,
            ),
            Text("Filter"),
          ],
        ),
      ),
      body: FutureBuilder(
        future: enquryHandler,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return Padding(
              padding: const EdgeInsets.all(10.0),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  height: double.infinity,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.only(
                          top: 10,
                          right: 10,
                          left: 10,
                          bottom: 5,
                        ),
                        child: InputForm(
                          controller: searchForm,
                          formName: "Search Enquiry",
                          prefixIcon: Icons.search,
                          onChanged: (value) {
                            searchEnquiryFun(value);
                          },
                        ),
                      ),
                      Expanded(
                        child: RefreshIndicator(
                          onRefresh: () async {
                            setState(() {
                              enquryHandler = getEnquiryInfo();
                            });
                          },
                          child: ListView.builder(
                            padding: const EdgeInsets.only(bottom: 70),
                            itemCount: enquiryList.length,
                            itemBuilder: (context, index) {
                              return GestureDetector(
                                onTap: () {
                                  setState(() {
                                    Navigator.push(
                                      context,
                                      CupertinoPageRoute(
                                        builder: (context) => EnquiryDetails(
                                          estimateData: enquiryList[index],
                                        ),
                                      ),
                                    ).then((value) {
                                      if (value != null && value == true) {
                                        setState(() {
                                          enquryHandler = getEnquiryInfo();
                                        });
                                      }
                                    });
                                    // crtlistview =
                                    //     orderlist[index];
                                  });
                                },
                                child: Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    border: index > 0
                                        ? const Border(
                                            top: BorderSide(
                                              width: 0.5,
                                              color: Color(0xffE0E0E0),
                                            ),
                                          )
                                        : null,
                                  ),
                                  child: Row(
                                    children: [
                                      Container(
                                        height: 40,
                                        width: 40,
                                        decoration: BoxDecoration(
                                          color: Colors.grey.shade300,
                                          shape: BoxShape.circle,
                                        ),
                                        child: Center(
                                          child: Text(
                                            "${enquiryList.length - index}",
                                            style: const TextStyle(
                                              color: Colors.grey,
                                              fontSize: 15,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(
                                        width: 10,
                                      ),
                                      Expanded(
                                        child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              "ORDERID - ${enquiryList[index].enquiryid}",
                                              style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            const SizedBox(
                                              height: 3,
                                            ),
                                            Text(
                                              "CUSTOMER - ${enquiryList[index].customer != null && enquiryList[index].customer!.customerName != null ? enquiryList[index].customer!.customerName : ""}",
                                              // "CUSTOMER - ${enquiryList[index].customer!.customerName ?? ""}",
                                              style: const TextStyle(
                                                fontSize: 13,
                                              ),
                                            ),
                                            Text(
                                              "DATE - ${DateFormat('dd-MM-yyyy hh:mm a').format(enquiryList[index].createddate!)}",
                                              style: const TextStyle(
                                                fontSize: 13,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Center(
                                        child: Text(
                                          "Rs.${enquiryList[index].price!.total}",
                                        ),
                                      ),
                                      Container(
                                        padding: const EdgeInsets.all(10),
                                        child: const Center(
                                          child: Icon(
                                            Icons.arrow_forward_ios,
                                            size: 18,
                                            color: Color(0xff6B6B6B),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          } else if (snapshot.connectionState == ConnectionState.done && snapshot.hasError) {
            return Center(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                ),
                margin: const EdgeInsets.all(20),
                padding: const EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Center(
                      child: Text(
                        "Failed",
                        style: TextStyle(
                          color: Colors.red,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 15,
                    ),
                    Text(
                      snapshot.error.toString() == "null" ? "Something went Wrong" : snapshot.error.toString(),
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.black54,
                        fontSize: 13,
                      ),
                    ),
                    Center(
                      child: TextButton.icon(
                        onPressed: () {
                          setState(() {
                            enquryHandler = getEnquiryInfo();
                          });
                        },
                        icon: const Icon(Icons.refresh),
                        label: const Text(
                          "Refresh",
                        ),
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

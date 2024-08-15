import 'dart:developer';
import 'dart:typed_data';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sri_sakthivel_fireworks_pos/screen/mainapp/estimate/estimate_details.dart';

import '../../../firebase/datamodel/datamodel.dart';
import '../../../firebase/firestore_provider.dart';
import '../../../provider/download_file_provider.dart';
import '../../../provider/enquiry_excel_cration.dart';
import '../../../utlities/provider/localdb.dart';
import '../../../utlities/utlities.dart';
import '../../ui/commenwidget.dart';
import '../homelanding.dart';

class EstimateListing extends StatefulWidget {
  const EstimateListing({super.key});

  @override
  State<EstimateListing> createState() => _EstimateListingState();
}

class _EstimateListingState extends State<EstimateListing> {
  List<EstimateDataModel> enquiryList = [];
  List<EstimateDataModel> tmpEnquiryList = [];
  TextEditingController searchForm = TextEditingController();
  Future getEnquiryInfo() async {
    try {
      setState(() {
        enquiryList.clear();
        tmpEnquiryList.clear();
      });
      var cid = await LocalDbProvider().fetchInfo(type: LocalData.companyid);
      if (cid != null) {
        var enquiry = await FireStoreProvider().getEstimate(cid: cid);
        if (enquiry != null && enquiry.docs.isNotEmpty) {
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

            var customer = CustomerDataModel();
            if (enquiryData["customer"] != null) {
              customer.address = enquiryData["customer"]["address"].toString();
              customer.state = enquiryData["customer"]["state"].toString();
              customer.city = enquiryData["customer"]["city"].toString();
              customer.customerName = enquiryData["customer"]["customer_name"].toString();
              customer.email = enquiryData["customer"]["email"].toString();
              customer.mobileNo = enquiryData["customer"]["mobile_no"].toString();
            }

            List<ProductDataModel> tmpProducts = [];

            setState(() {
              tmpProducts.clear();
            });

            // await FireStoreProvider().getEstimateProducts(docid: enquiryData.id).then((products) {
            //   if (products != null && products.docs.isNotEmpty) {
            //     for (var product in products.docs) {
            //       var productDataModel = ProductDataModel();
            //       productDataModel.categoryid = product["category_id"];
            //       productDataModel.categoryName = product["category_name"];
            //       productDataModel.price = product["price"];
            //       productDataModel.productId = product["product_id"];
            //       productDataModel.productName = product["product_name"];
            //       productDataModel.qty = product["qty"];
            //       productDataModel.productCode = product["product_code"];
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
                  enquiryid: null,
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
          tmpEnquiryList.addAll(enquiryList);
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
              element.estimateid!
                  .toLowerCase()
                  .replaceAll(' ', '')
                  .startsWith(value.toLowerCase().replaceAll(' ', ''))) {
            return true;
          } else {
            return false;
          }
        });
        log("is Working");
        if (tmpList.isNotEmpty) {
          for (var element in tmpList) {
            setState(() {
              enquiryList.add(element);
            });
          }
        }
      }
    } else {
      setState(() {
        enquiryList.clear();
        enquiryList.addAll(tmpEnquiryList);
      });
    }
  }

  downloadExcelData() async {
    try {
      loading(context);
      await EnquiryExcel(enquiryData: enquiryList, isEstimate: true).createCustomerExcel().then((value) async {
        if (value != null) {
          Uint8List fileData = Uint8List.fromList(value);
          await DownloadFileOffline(
            fileData: fileData,
            fileName: "Estimate Excel",
            fileext: 'xlsx',
          ).startDownload().then((value) {
            if (value != null && value.isNotEmpty) {
              Navigator.pop(context);
              downloadFileSnackBarCustom(
                context,
                isSuccess: true,
                msg: "Estimate Excel Download Successfully",
                path: value,
              );
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
        title: const Text("Estimate"),
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
        onPressed: () {},
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
                        formName: "Search Estimate",
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
                          itemCount: enquiryList.length,
                          itemBuilder: (context, index) {
                            return GestureDetector(
                              onTap: () {
                                setState(() {
                                  Navigator.push(
                                    context,
                                    CupertinoPageRoute(
                                      builder: (context) => EstimateDetails(
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
                                            "ESTIMATE ID - ${enquiryList[index].estimateid}",
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          const SizedBox(
                                            height: 3,
                                          ),
                                          Text(
                                            "CUSTOMER - ${enquiryList[index].customer != null && enquiryList[index].customer!.customerName != null ? enquiryList[index].customer!.customerName : ""}",
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
                    )
                  ],
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

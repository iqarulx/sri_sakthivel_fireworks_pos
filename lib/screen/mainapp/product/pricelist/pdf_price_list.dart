import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:sri_sakthivel_fireworks_pos/provider/download_file_provider.dart';
import 'package:sri_sakthivel_fireworks_pos/screen/ui/commenwidget.dart';
import 'package:sri_sakthivel_fireworks_pos/utlities/utlities.dart';
import 'package:printing/printing.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

import '../../../../firebase/datamodel/datamodel.dart';
import '../../../../firebase/firestore_provider.dart';
import '../../../../provider/pdf_creation_provider.dart';
import '../../../../utlities/provider/localdb.dart';

class PdfPriceListView extends StatefulWidget {
  const PdfPriceListView({super.key});

  @override
  State<PdfPriceListView> createState() => _PdfPriceListViewState();
}

class _PdfPriceListViewState extends State<PdfPriceListView> {
  Uint8List? data;
  List<CategoryDataModel> categoryList = [];
  List<ProductDataModel> productDataList = [];
  List<PriceListCategoryDataModel> priceList = [];

  getpriceListPdf({required String cid}) async {
    await FireStoreProvider().getCompanyDocInfo(cid: cid).then((companyInfo) async {
      if (companyInfo != null) {
        var pdf = PdfCreationProvider(
          companyName: companyInfo["company_name"],
          companyAddress: companyInfo["address"],
          priceList: priceList,
        );
        var dataResult = await pdf.createPriceList();

        setState(() {
          data = dataResult;
        });
      } else {
        // Throw Error
      }
    });
  }

  Future getCurrentPriceList() async {
    var fireStore = FireStoreProvider();
    var cid = await LocalDbProvider().fetchInfo(type: LocalData.companyid);
    if (cid != null) {
      await fireStore.categoryListing(cid: cid).then((categorylist) async {
        if (categorylist != null && categorylist.docs.isNotEmpty) {
          for (var category in categorylist.docs) {
            CategoryDataModel model = CategoryDataModel();
            model.categoryName = category["category_name"].toString();
            model.postion = category["postion"];
            model.tmpcatid = category.id;
            setState(() {
              categoryList.add(model);
            });
          }
        } else {
          // Throw Error
        }
      });
      await fireStore.productListing(cid: cid).then((productDataResult) {
        if (productDataResult != null && productDataResult.docs.isNotEmpty) {
          for (var element in productDataResult.docs) {
            ProductDataModel model = ProductDataModel();
            model.categoryid = element["category_id"] ?? "";
            // model.categoryName = element["category_name"] ?? "";
            model.categoryName = "";
            model.productName = element["product_name"] ?? "";
            model.productCode = element["product_code"] ?? "";
            model.productContent = element["product_content"] ?? "";
            model.qrCode = element["qr_code"] ?? "";
            model.price = double.parse(element["price"].toString());
            model.videoUrl = element["video_url"] ?? "";
            model.productImg = element["product_img"] ?? "";
            model.active = element["active"];
            model.productId = element.id;
            model.discountLock = element['discount_lock'];
            setState(() {
              productDataList.add(model);
            });
          }
        } else {
          // Throw Error
        }
      });

      for (var categoryElement in categoryList) {
        Iterable<ProductDataModel> dataList =
            productDataList.where((element) => element.categoryid == categoryElement.tmpcatid);
        if (dataList.isNotEmpty) {
          var catData = PriceListCategoryDataModel(
            categoryName: categoryElement.categoryName,
            productModel: [],
          );
          setState(() {
            priceList.add(catData);
          });
          for (var productElement in dataList) {
            var proData = PriceListProdcutDataModel(
              prodcutName: productElement.productName.toString(),
              content: productElement.productContent.toString(),
              price: productElement.price!.toStringAsFixed(2),
            );
            setState(() {
              priceList.last.productModel!.add(proData);
            });
          }
        }
      }
      if (priceList.isNotEmpty) {
        getpriceListPdf(cid: cid);
      }

      return priceList;
    }
  }

  // Future getPriceList() async {
  //   var fireStore = FireStoreProvider();
  //   var cid = await LocalDbProvider().fetchInfo(type: LocalData.companyid);
  //   if (cid != null) {
  //     await fireStore.categoryListing(cid: cid).then((categoryList) async {
  //       if (categoryList != null && categoryList.docs.isNotEmpty) {
  //         for (var category in categoryList.docs) {
  //           await fireStore.productBilling(cid: cid, categoryId: category.id).then(
  //             (products) {
  //               if (products != null && products.docs.isNotEmpty) {
  //                 var catData = PriceListCategoryDataModel(
  //                   categoryName: category["category_name"],
  //                   productModel: [],
  //                 );
  //                 setState(() {
  //                   priceList.add(catData);
  //                 });

  //                 for (var product in products.docs) {
  //                   var proData = PriceListProdcutDataModel(
  //                     prodcutName: product["product_name"].toString(),
  //                     content: product["product_content"].toString(),
  //                     price: double.parse(product["price"].toString()).toStringAsFixed(2),
  //                   );
  //                   setState(() {
  //                     int index = priceList.length - 1;
  //                     priceList[index == -1 ? 0 : index].productModel!.add(proData);
  //                   });
  //                 }
  //               }
  //             },
  //           );
  //         }
  //       }
  //     });
  //   }

  //   if (priceList.isNotEmpty) {
  //     getpriceListPdf();
  //   }

  //   return priceList;
  // }

  downloadPriceList() async {
    try {
      loading(context);
      if (data != null) {
        var pdfData = DownloadFileOffline(
          fileData: data!,
          fileName: "Price List",
          fileext: "pdf",
        );

        await pdfData.startDownload().then((value) {
          Navigator.pop(context);
          if (value != null) {
            downloadFileSnackBarCustom(context, isSuccess: true, msg: "Successfully Download Pdf File", path: value);
          }
        });
      } else {
        Navigator.pop(context);
        snackBarCustom(context, false, "No Product Avliable");
      }
    } catch (e) {
      Navigator.pop(context);
      snackBarCustom(context, false, e.toString());
    }
  }

  sharePDF() async {
    try {
      if (data != null) {
        await Printing.sharePdf(bytes: data!);
      } else {
        Navigator.pop(context);
        snackBarCustom(context, false, "No Product Avliable");
      }
    } catch (e) {
      Navigator.pop(context);
      snackBarCustom(context, false, e.toString());
    }
  }

  printPriceList() async {
    try {
      if (data != null) {
        await Printing.layoutPdf(
          onLayout: (_) => data!,
        );
      } else {
        Navigator.pop(context);
        snackBarCustom(context, false, "No Product Avliable");
      }
    } catch (e) {
      Navigator.pop(context);
      snackBarCustom(context, false, e.toString());
    }
  }

  late Future priceListHanler;

  @override
  void initState() {
    super.initState();

    priceListHanler = getCurrentPriceList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text("Price List"),
          actions: [
            TextButton.icon(
              style: TextButton.styleFrom(
                iconColor: Colors.white,
              ),
              onPressed: () {
                sharePDF();
              },
              icon: const Icon(
                Icons.share,
              ),
              label: const Text(
                "Share",
                style: TextStyle(color: Colors.white),
              ),
            ),
            IconButton(
              onPressed: () {
                downloadPriceList();
              },
              icon: const Icon(
                Icons.file_download_outlined,
              ),
            ),
            IconButton(
              onPressed: () {
                // getpriceListPdf();
                printPriceList();
              },
              icon: const Icon(
                Icons.print,
              ),
            ),
          ],
        ),
        backgroundColor: const Color(0xffEEEEEE),
        body: FutureBuilder(
          future: priceListHanler,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              if (data != null) {
                return SfPdfViewer.memory(
                  data!,
                );
              } else {
                return const SizedBox();
              }
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
                              priceListHanler = getCurrentPriceList();
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
        ));
  }
}

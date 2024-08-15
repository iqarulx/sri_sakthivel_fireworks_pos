import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../firebase/datamodel/datamodel.dart';
import '../../../firebase/firestore_provider.dart';
import '../../../utlities/provider/localdb.dart';
import '../../../utlities/utlities.dart';
import '../../ui/commenwidget.dart';

class SearchProductBilling extends StatefulWidget {
  const SearchProductBilling({super.key});

  @override
  State<SearchProductBilling> createState() => _SearchProductBillingState();
}

class _SearchProductBillingState extends State<SearchProductBilling> {
  List<ProductDataModel> productDataList = [];
  List<ProductDataModel> tmpProductDataList = [];
  List<CategoryDataModel> categoryList = [];

  FireStoreProvider provider = FireStoreProvider();

  Future getProductInfo() async {
    try {
      var cid = await LocalDbProvider().fetchInfo(type: LocalData.companyid);
      if (cid != null) {
        final result = await provider.productListing(cid: cid);
        final result2 = await provider.categoryListing(cid: cid);
        if (result != null && result.docs.isNotEmpty && result2 != null && result2.docs.isNotEmpty) {
          log(result.docs.length.toString());
          setState(() {
            categoryList.clear();
            productDataList.clear();
            tmpProductDataList.clear();
          });
          for (var element in result.docs) {
            log("Worked ${element.data()} ");
            ProductDataModel model = ProductDataModel();
            model.categoryid = element["category_id"] ?? "";
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

          for (var element in result2.docs) {
            log("Worked ${element.data()} ");
            CategoryDataModel model = CategoryDataModel();
            model.categoryName = element["category_name"].toString();
            model.postion = element["postion"];
            model.tmpcatid = element.id;
            setState(() {
              categoryList.add(model);
            });
          }

          for (var product in productDataList) {
            int findCategoryIndex = categoryList.indexWhere((element) => element.tmpcatid == product.categoryid);
            if (findCategoryIndex != -1) {
              setState(() {
                product.categoryName = categoryList[findCategoryIndex].categoryName;
              });
            }
          }
          setState(() {
            tmpProductDataList.addAll(productDataList);
          });

          return productDataList;
        }
      }
      return null;
    } catch (e) {
      log(e.toString());
      snackBarCustom(context, false, e.toString());
      return null;
    }
  }

  searchproduct(String searchtext) async {
    setState(() {
      productDataList.clear();

      Iterable<ProductDataModel> tmpList = tmpProductDataList.where((element) {
        if (element.productName!
            .toLowerCase()
            .replaceAll(' ', '')
            .startsWith(searchtext.toLowerCase().replaceAll(' ', ''))) {
          return true;
        } else if (element.productCode!.toLowerCase().replaceAll(' ', '').startsWith(
              searchtext.toLowerCase().replaceAll(' ', ''),
            )) {
          return true;
        } else if (element.productName!
            .toLowerCase()
            .replaceAll(' ', '')
            .contains(searchtext.toLowerCase().replaceAll(' ', ''))) {
          return true;
        } else {
          return false;
        }
      });
      for (var element in tmpList) {
        productDataList.add(element);
      }
    });
  }

  late Future productHandler;

  @override
  void initState() {
    super.initState();
    productHandler = getProductInfo();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: SafeArea(
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
          ),
          margin: const EdgeInsets.all(15),
          constraints: BoxConstraints(
            maxWidth: 600,
            maxHeight: MediaQuery.of(context).size.height * 0.85,
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Scaffold(
              appBar: AppBar(
                iconTheme: const IconThemeData(color: Colors.black),
                backgroundColor: Colors.white,
                elevation: 0,
                systemOverlayStyle: const SystemUiOverlayStyle(
                  statusBarIconBrightness: Brightness.dark,
                  statusBarColor: Colors.transparent,
                ),
                leading: IconButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  splashRadius: 20,
                  icon: const Icon(
                    Icons.close,
                    color: Colors.black,
                  ),
                ),
                titleSpacing: 0,
                title: TextFormField(
                  autofocus: true,
                  decoration: const InputDecoration(
                    hintText: "Search Product",
                    filled: true,
                    fillColor: Colors.white,
                  ),
                  onChanged: (value) {
                    searchproduct(value);
                  },
                ),
              ),
              backgroundColor: const Color(0xffEEEEEE),
              body: FutureBuilder(
                future: productHandler,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.done) {
                    return RefreshIndicator(
                      onRefresh: () async {
                        setState(() {
                          productHandler = getProductInfo();
                        });
                      },
                      child: ListView.builder(
                        padding: const EdgeInsets.only(
                          bottom: 5,
                          left: 5,
                          right: 5,
                        ),
                        itemCount: productDataList.length,
                        itemBuilder: (context, index) {
                          return Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(5),
                              color: Colors.white,
                            ),
                            margin: const EdgeInsets.only(top: 5),
                            child: ListTile(
                              onTap: () {
                                Navigator.pop(
                                  context,
                                  productDataList[index].productId,
                                );
                              },
                              leading: CircleAvatar(
                                backgroundColor: Colors.grey.shade300,
                                child: productDataList[index].productImg == null ||
                                        productDataList[index].productImg.toString().toLowerCase() == "null" ||
                                        productDataList[index].productImg.toString().isEmpty
                                    ? null
                                    : Image.network(
                                        productDataList[index].productImg!,
                                        fit: BoxFit.cover,
                                      ),
                              ),
                              title: Text(
                                productDataList[index].productName.toString(),
                              ),
                              subtitle: Text(
                                productDataList[index].categoryName.toString(),
                              ),
                            ),
                          );
                        },
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
                                    productHandler = getProductInfo();
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
            ),
          ),
        ),
      ),
    );
  }
}

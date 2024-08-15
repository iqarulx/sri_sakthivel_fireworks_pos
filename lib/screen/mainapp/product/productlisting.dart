import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:sri_sakthivel_fireworks_pos/screen/mainapp/product/excel/upload_excel.dart';
import 'package:sri_sakthivel_fireworks_pos/screen/mainapp/product/pricelist/pdf_price_list.dart';
import 'package:sri_sakthivel_fireworks_pos/screen/mainapp/product/product_detais.dart';
import 'package:sri_sakthivel_fireworks_pos/screen/ui/commenwidget.dart';
import 'package:sri_sakthivel_fireworks_pos/utlities/utlities.dart';

import '../../../firebase/datamodel/datamodel.dart';
import '../../../firebase/firestore_provider.dart';
import '../../../provider/download_file_provider.dart';
import '../../../utlities/provider/localdb.dart';
import '../homelanding.dart';

class ProductListing extends StatefulWidget {
  const ProductListing({super.key});

  @override
  State<ProductListing> createState() => _ProductListingState();
}

class _ProductListingState extends State<ProductListing> {
  List<ProductDataModel> productDataList = [];
  List<CategoryDataModel> categoryList = [];
  List<ProductDataModel> tmpProductDataList = [];

  FireStoreProvider provider = FireStoreProvider();

  Future<String?> getCategoryName({required String categoryId}) async {
    String? categoryName;
    try {
      var result = await provider.getCategorydocInfo(docid: categoryId);
      if (result!.exists) {
        categoryName = result["category_name"];
      }
    } catch (e) {
      throw e.toString();
    }
    return categoryName;
  }

  Future getProductInfo() async {
    try {
      var cid = await LocalDbProvider().fetchInfo(type: LocalData.companyid);
      if (cid != null) {
        final result = await provider.productListing(cid: cid);
        final result2 = await provider.categoryListing(cid: cid);
        if (result!.docs.isNotEmpty && result2!.docs.isNotEmpty) {
          log(result.docs.length.toString());
          setState(() {
            productDataList.clear();
            tmpProductDataList.clear();
            categorylist.clear();
          });
          for (var element in result.docs) {
            log("Worked ${element.data()} ");
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
          categorylist.add(
            const DropdownMenuItem(
              value: "all",
              child: Text(
                "Show All",
              ),
            ),
          );
          for (var element in result2.docs) {
            log("Worked ${element.data()} ");
            CategoryDataModel model = CategoryDataModel();
            model.categoryName = element["category_name"].toString();
            model.postion = element["postion"];
            model.tmpcatid = element.id;
            setState(() {
              categoryList.add(model);
            });

            categorylist.add(
              DropdownMenuItem(
                value: element.id,
                child: Text(
                  element["category_name"].toString(),
                ),
              ),
            );
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

          filter();
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

  downloadTemplate() async {
    loading(context);
    try {
      await DownloadFilesOnline(
        urlLink:
            "https://firebasestorage.googleapis.com/v0/b/srisoftpos.appspot.com/o/product_templete%2Fproduct_template.xlsx?alt=media&token=a9aa597d-9bc2-4d79-b978-476bf0942e16",
        fileName: 'Product Templete',
        fileext: 'xlsx',
      ).startDownload().then((value) {
        Navigator.pop(context);
        if (value != null) {
          snackBarCustom(context, true, "Successfully Download File");
        } else {
          snackBarCustom(context, false, "Something went Worng");
        }
      });
    } catch (e) {
      Navigator.pop(context);
      snackBarCustom(context, false, e.toString());
    }
  }

  //search Varibale
  List<DropdownMenuItem> categorylist = [];
  int crtpagelimit = 10;
  int totalrecord = 0;
  int crtpagenumber = 1;
  List<DropdownMenuItem> noofpage = [];
  List<DropdownMenuItem> pagelimit = const [
    DropdownMenuItem(
      value: 10,
      child: Text("10"),
    ),
    DropdownMenuItem(
      value: 25,
      child: Text("25"),
    ),
    DropdownMenuItem(
      value: 50,
      child: Text("50"),
    ),
    DropdownMenuItem(
      value: 100,
      child: Text("100"),
    ),
  ];
  String? category;
  TextEditingController searchform = TextEditingController();

  // Search Product Name Wish

  searchproduct(String searchtext) async {
    setState(() {
      productDataList.clear();
      category = "";
      crtpagelimit = 10;
      totalrecord = 0;
      crtpagenumber = 1;

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
        } else {
          return false;
        }
      });
      for (var element in tmpList) {
        productDataList.add(element);
      }
    });
    filter();
  }

  // Filter
  filter() async {
    setState(() {
      if (category != null && category!.isNotEmpty && searchform.text.isEmpty) {
        productDataList.clear();
        List<ProductDataModel> data;
        if (category == "all") {
          //crtpagelimit = 10;
          totalrecord = 0;
          crtpagenumber = 1;

          data = tmpProductDataList;
        } else {
          data = tmpProductDataList.where((element) => element.categoryid == category).toList();
        }

        log(data.length.toString());

        for (var element in data) {
          setState(() {
            productDataList.add(element);
          });
        }
      }
      totalrecord = productDataList.length;
      crtpagenumber = 1;
      noofpage.clear();
      var tmp = (totalrecord / crtpagelimit);
      int count = tmp.ceil();
      if (count == 0) {
        count = 1;
      }
      for (var i = 1; i < count + 1; i++) {
        noofpage.add(
          DropdownMenuItem(
            value: i,
            child: Text(
              i.toString(),
            ),
          ),
        );
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
    return Scaffold(
      backgroundColor: const Color(0xffEEEEEE),
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            homeKey.currentState!.openDrawer();
          },
          icon: const Icon(Icons.menu),
        ),
        title: const Text("Products"),
        actions: [
          IconButton(
            onPressed: () {
              // openModelBottomSheat(context);
              Navigator.push(
                context,
                CupertinoPageRoute(
                  builder: (context) => const ProductDetails(
                    title: 'Create Product',
                    edit: false,
                  ),
                ),
              ).then((value) {
                if (value != null && value == true) {
                  setState(() {
                    productHandler = getProductInfo();
                  });
                }
              });
            },
            splashRadius: 20,
            icon: const Icon(
              Icons.add,
            ),
          ),
          PopupMenuButton(
            splashRadius: 10,
            onSelected: (String item) async {
              switch (item) {
                case 'excel':
                  await Navigator.push(
                    context,
                    CupertinoPageRoute(
                      builder: (context) => const UploadExcel(),
                    ),
                  ).then((value) {
                    if (value != null && value == true) {
                      productHandler = getProductInfo();
                    }
                  });
                  break;
                case 'download':
                  downloadTemplate();
                  break;
                case 'print':
                  Navigator.push(
                    context,
                    CupertinoPageRoute(
                      builder: (context) => const PdfPriceListView(),
                    ),
                  );
                  break;
                default:
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem<String>(
                value: 'excel',
                child: ListTile(
                  minVerticalPadding: 0,
                  contentPadding: EdgeInsets.all(0),
                  leading: Icon(Icons.description_outlined),
                  title: Text("Excel Upload"),
                ),
              ),
              PopupMenuItem<String>(
                value: 'download',
                child: ListTile(
                  minVerticalPadding: 0,
                  contentPadding: const EdgeInsets.all(0),
                  leading: const Icon(Icons.file_download_outlined),
                  title: const Text("Download Template"),
                  subtitle: Text(
                    'Download Template Excel File',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ),
              ),
              PopupMenuItem<String>(
                value: 'print',
                child: ListTile(
                  minVerticalPadding: 0,
                  contentPadding: const EdgeInsets.all(0),
                  leading: const Icon(Icons.print_outlined),
                  title: const Text("Download Price List"),
                  subtitle: Text(
                    'Download Overall Product Price List',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ),
              ),
            ],
            child: const IconButton(
              disabledColor: Colors.white,
              onPressed: null,
              splashRadius: 20,
              icon: Icon(
                Icons.more_vert,
              ),
            ),
          )
        ],
      ),
      body: FutureBuilder(
        future: productHandler,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return Padding(
              padding: const EdgeInsets.only(
                top: 10,
                left: 10,
                right: 10,
              ),
              child: Container(
                height: double.infinity,
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(10),
                    topRight: Radius.circular(10),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      child: Column(
                        children: [
                          SizedBox(
                            height: 45,
                            child: TextFormField(
                              cursorColor: const Color(0xff7099c2),
                              keyboardType: TextInputType.text,
                              decoration: const InputDecoration(
                                contentPadding: EdgeInsets.symmetric(horizontal: 10),
                                hintText: "Search Product",
                                prefixIcon: Icon(
                                  Icons.search,
                                  color: Color(0xff7099c2),
                                ),
                              ),
                              onChanged: (value) {
                                setState(() {
                                  searchproduct(value);
                                });
                              },
                              onEditingComplete: () {
                                setState(() {
                                  FocusManager.instance.primaryFocus!.unfocus();
                                  searchproduct(searchform.text);
                                });
                              },
                            ),
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          Row(
                            children: [
                              Expanded(
                                flex: 5,
                                child: SizedBox(
                                  height: 45,
                                  child: DropdownButtonFormField(
                                    isExpanded: true,
                                    items: categorylist,
                                    onChanged: (v) {
                                      setState(() {
                                        category = v;
                                      });
                                      filter();
                                    },
                                    // cursorColor: const Color(0xff7099c2),
                                    decoration: const InputDecoration(
                                      contentPadding: EdgeInsets.symmetric(horizontal: 10),
                                      hintText: "Choose Category",
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(
                                width: 10,
                              ),
                              Expanded(
                                flex: 2,
                                child: SizedBox(
                                  height: 45,
                                  child: DropdownButtonFormField(
                                    value: crtpagelimit != 0 ? crtpagelimit : null,
                                    isExpanded: true,
                                    items: pagelimit,
                                    onChanged: (value) {
                                      setState(() {
                                        crtpagenumber = 0;
                                        crtpagelimit = value;
                                        filter();
                                      });
                                    },
                                    decoration: const InputDecoration(
                                      contentPadding: EdgeInsets.symmetric(horizontal: 10),
                                      hintText: "no",
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(
                                width: 10,
                              ),
                              Expanded(
                                flex: 2,
                                child: SizedBox(
                                  height: 45,
                                  child: DropdownButtonFormField(
                                    isExpanded: true,
                                    items: noofpage,
                                    value: crtpagenumber != 0 ? crtpagenumber : null,
                                    onChanged: (value) {
                                      setState(() {
                                        crtpagenumber = value;
                                      });
                                    },
                                    // cursorColor: const Color(0xff7099c2),
                                    decoration: const InputDecoration(
                                      contentPadding: EdgeInsets.symmetric(horizontal: 10),
                                      hintText: "Page",
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          )
                        ],
                      ),
                    ),
                    Expanded(
                      child: RefreshIndicator(
                        onRefresh: () async {
                          setState(() {
                            productHandler = getProductInfo();
                          });
                        },
                        child: SingleChildScrollView(
                          child: Column(
                            children: [
                              for (int index = ((crtpagelimit * crtpagenumber) - crtpagelimit);
                                  index < ((crtpagelimit * crtpagenumber));
                                  index++)
                                if (productDataList.length > index)
                                  Column(
                                    children: [
                                      ListTile(
                                        onTap: () {
                                          Navigator.push(
                                            context,
                                            CupertinoPageRoute(
                                              builder: (context) => ProductDetails(
                                                title: 'Product Details',
                                                edit: true,
                                                productData: productDataList[index],
                                              ),
                                            ),
                                          ).then((value) {
                                            if (value != null && value == true) {
                                              setState(() {
                                                productHandler = getProductInfo();
                                              });
                                            }
                                          });
                                        },
                                        leading: Container(
                                          height: 45,
                                          width: 45,
                                          decoration: BoxDecoration(
                                            color: Colors.grey.shade300,
                                            shape: BoxShape.circle,
                                            image: productDataList[index].productImg == null ||
                                                    productDataList[index].productImg.toString().toLowerCase() ==
                                                        "null" ||
                                                    productDataList[index].productImg.toString().isEmpty
                                                ? null
                                                : DecorationImage(
                                                    image: NetworkImage(
                                                      productDataList[index].productImg!,
                                                    ),
                                                    fit: BoxFit.cover,
                                                  ),
                                          ),
                                        ),
                                        title: Text(
                                          productDataList[index].productName ?? "",
                                        ),
                                        subtitle: Text("Category - ${productDataList[index].categoryName ?? ""}"),
                                        trailing: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Text(
                                              productDataList[index].price.toString(),
                                            ),
                                            const Icon(
                                              Icons.keyboard_arrow_right_outlined,
                                            ),
                                          ],
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.symmetric(horizontal: 10),
                                        child: Divider(
                                          height: 0,
                                          color: Colors.grey.shade300,
                                        ),
                                      ),
                                    ],
                                  ),
                            ],
                          ),
                        ),
                      ),
                    ),
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
    );
  }
}

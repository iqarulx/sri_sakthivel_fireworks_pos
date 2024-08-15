import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';

import '../../../firebase/datamodel/datamodel.dart';
import '../../../firebase/firestore_provider.dart';
import '../../../provider/page_provider.dart';
import '../../../utlities/provider/localdb.dart';
import '../../../utlities/utlities.dart';
import '../../../utlities/varibales.dart';
import '../../ui/commenwidget.dart';
import '../homelanding.dart';
import 'add_custom_product.dart';
import 'billing_one.dart';
import 'cart_drawer.dart';
import 'search_product.dart';

BilingPageProvider billPageProvider2 = BilingPageProvider();

class BillingTwo extends StatefulWidget {
  final bool? isEdit;
  final EstimateDataModel? enquiryData;
  final EstimateDataModel? estimateData;

  const BillingTwo({
    super.key,
    this.isEdit,
    this.enquiryData,
    this.estimateData,
  });

  @override
  State<BillingTwo> createState() => _BillingTwoState();
}

class _BillingTwoState extends State<BillingTwo> {
  List<ProductDataModel> productDataList = [];
  List<CategoryDataModel> categoryList = [];
  bool isLoading = false;
  Future getProductList() async {
    try {
      setState(() {
        isLoading = true;
        billingProductList.clear();
      });
      var storeProvider = FireStoreProvider();

      var cid = await LocalDbProvider().fetchInfo(type: LocalData.companyid);
      if (cid != null) {
        var categoryAPI = await storeProvider.categoryListing(cid: cid);
        var productAPI = await storeProvider.productListing(cid: cid);
        if (categoryAPI != null &&
            categoryAPI.docs.isNotEmpty &&
            productAPI != null &&
            productAPI.docs.isNotEmpty) {
          for (var categorylist in categoryAPI.docs) {
            CategoryDataModel model = CategoryDataModel();
            model.categoryName = categorylist["category_name"].toString();
            model.postion = categorylist["postion"];
            model.tmpcatid = categorylist.id;
            setState(() {
              categoryList.add(model);
            });
          }
          for (var product in productAPI.docs) {
            log("Worked ${product.data()} ");
            ProductDataModel productInfo = ProductDataModel();
            productInfo.categoryName = "";
            productInfo.categoryid = product["category_id"];
            productInfo.discountLock = product["discount_lock"];
            productInfo.name = product["name"];
            productInfo.productCode = product["product_code"];
            productInfo.productContent = product["product_content"];
            productInfo.qrCode = product["qr_code"];
            productInfo.videoUrl = product["video_url"];
            productInfo.productName = product["product_name"];
            productInfo.productImg = product["product_img"];
            productInfo.price = double.parse(product["price"].toString());
            productInfo.productId = product.id;
            productInfo.qty = 0;
            productInfo.qtyForm =
                TextEditingController(text: productInfo.qty.toString());
            setState(() {
              productDataList.add(productInfo);
            });
          }

          // Category & Product Merge
          for (var category in categoryList) {
            Iterable<ProductDataModel> products = productDataList
                .where((element) => element.categoryid == category.tmpcatid);
            for (var element in products) {
              setState(() {
                element.categoryName = category.categoryName;
              });
            }
            var data = BillingDataModel(
              category: category,
              products: [for (var product in products) product],
            );
            setState(() {
              billingProductList.add(data);
            });
          }

          if (widget.isEdit != null && widget.isEdit! == true) {
            if (widget.enquiryData != null) {
              for (var elements in widget.enquiryData!.products!) {
                int catId = billingProductList.indexWhere((element) =>
                    element.category!.tmpcatid == elements.categoryid);
                int proId = -1;
                if (catId != -1) {
                  proId = billingProductList[catId].products!.indexWhere(
                      (element) => element.productId == elements.productId);
                }

                if (catId != -1 && proId != -1) {
                  setState(() {
                    billingProductList[catId].products![proId].qty =
                        elements.qty;
                    billingProductList[catId].products![proId].qtyForm!.text =
                        elements.qty.toString();
                  });

                  editaddtoCart(elements);

                  /// Add to Cart Function Creation Work Pending
                } else {
                  BillingDataModel billing = BillingDataModel();

                  var category = CategoryDataModel();
                  category.categoryName = "";
                  category.tmpcatid = "";

                  billing.category = category;
                  billing.products = [];

                  setState(() {
                    billingProductList.add(billing);
                    editaddtoCart(elements);
                  });
                }
              }
              // Update Discount & Packing Charges
              setState(() {
                discountSys = widget.enquiryData!.price!.discountsys ?? "%";
                extraDiscountSys =
                    widget.enquiryData!.price!.extraDiscountsys ?? "%";
                packingChargeSys = widget.enquiryData!.price!.packagesys ?? "%";
                discountInput = widget.enquiryData!.price!.discount ?? 0;
                extraDiscountInput =
                    widget.enquiryData!.price!.extraDiscount ?? 0;
                packingChargeInput = widget.enquiryData!.price!.package ?? 0;

                customerInfo = widget.enquiryData!.customer;
              });
            } else if (widget.estimateData != null) {
              for (var elements in widget.estimateData!.products!) {
                int catId = billingProductList.indexWhere((element) =>
                    element.category!.tmpcatid == elements.categoryid);
                int proId = -1;
                if (catId != -1) {
                  proId = billingProductList[catId].products!.indexWhere(
                      (element) => element.productId == elements.productId);
                }

                if (catId != -1 && proId != -1) {
                  setState(() {
                    billingProductList[catId].products![proId].qty =
                        elements.qty;
                    billingProductList[catId].products![proId].qtyForm!.text =
                        elements.qty.toString();
                  });

                  editaddtoCart(elements);

                  /// Add to Cart Function Creation Work Pending
                } else {
                  BillingDataModel billing = BillingDataModel();

                  var category = CategoryDataModel();
                  category.categoryName = "";
                  category.tmpcatid = "";

                  billing.category = category;
                  billing.products = [];

                  setState(() {
                    billingProductList.add(billing);
                    editaddtoCart(elements);
                  });
                }
              }
              // Update Discount & Packing Charges
              setState(() {
                discountSys = widget.estimateData!.price!.discountsys ?? "%";
                extraDiscountSys =
                    widget.estimateData!.price!.extraDiscountsys ?? "%";
                packingChargeSys =
                    widget.estimateData!.price!.packagesys ?? "%";
                discountInput = widget.estimateData!.price!.discount ?? 0;
                extraDiscountInput =
                    widget.estimateData!.price!.extraDiscount ?? 0;
                packingChargeInput = widget.estimateData!.price!.package ?? 0;

                customerInfo = widget.estimateData!.customer;
              });
            }
          }

          setState(() {
            isLoading = false;
          });
          return true;
        }
      } else {
        setState(() {
          isLoading = false;
        });
        return null;
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      snackBarCustom(context, false, e.toString());
      return null;
    }
  }

  Future? billingHandler;
  int crttab = 0;

  var billingTwoKey = GlobalKey<ScaffoldState>();

  tapQty(int index) {
    var tmpProductDetails = billingProductList[crttab].products![index];

    int findCartIndex = cartDataList.indexWhere(
      (element) => element.productId == tmpProductDetails.productId,
    );

    if (findCartIndex != -1) {
      setState(() {
        cartDataList[findCartIndex].qty = cartDataList[findCartIndex].qty! + 1;
        cartDataList[findCartIndex].qtyForm!.text =
            cartDataList[findCartIndex].qty!.toString();
        tmpProductDetails.qty = tmpProductDetails.qty! + 1;
        tmpProductDetails.qtyForm!.text = tmpProductDetails.qty.toString();
      });
    } else {
      addtoCart(index);
    }
  }

  addtoCart(int index) {
    var cartDataInfo = CartDataModel();
    var tmpProductDetails = billingProductList[crttab].products![index];
    cartDataInfo.categoryId = tmpProductDetails.categoryid;
    cartDataInfo.categoryName = tmpProductDetails.categoryName;
    cartDataInfo.mrp = "500.00";
    cartDataInfo.price = tmpProductDetails.price;
    cartDataInfo.productId = tmpProductDetails.productId;
    cartDataInfo.productName = tmpProductDetails.productName;
    cartDataInfo.discountLock = tmpProductDetails.discountLock;
    cartDataInfo.productCode = tmpProductDetails.productCode;
    cartDataInfo.productContent = tmpProductDetails.productContent;
    cartDataInfo.productImg = tmpProductDetails.productImg;
    cartDataInfo.qrCode = tmpProductDetails.qrCode;
    cartDataInfo.qty = 1;
    cartDataInfo.qtyForm = TextEditingController(
      text: cartDataInfo.qty.toString(),
    );
    setState(() {
      tmpProductDetails.qty = tmpProductDetails.qty! + 1;
      tmpProductDetails.qtyForm!.text = tmpProductDetails.qty.toString();
      cartDataList.add(cartDataInfo);
    });
  }

  editaddtoCart(ProductDataModel product) {
    var cartDataInfo = CartDataModel();
    var tmpProductDetails = product;
    cartDataInfo.categoryId = tmpProductDetails.categoryid;
    cartDataInfo.categoryName = tmpProductDetails.categoryName;
    cartDataInfo.mrp = "500.00";
    cartDataInfo.price = tmpProductDetails.price;
    cartDataInfo.productId = tmpProductDetails.productId;
    cartDataInfo.productName = tmpProductDetails.productName;
    cartDataInfo.discountLock = tmpProductDetails.discountLock;
    cartDataInfo.productCode = tmpProductDetails.productCode;
    cartDataInfo.productContent = tmpProductDetails.productContent;
    cartDataInfo.productImg = tmpProductDetails.productImg;
    cartDataInfo.qrCode = tmpProductDetails.qrCode;
    cartDataInfo.qty = tmpProductDetails.qty;
    cartDataInfo.qtyForm = TextEditingController(
      text: cartDataInfo.qty.toString(),
    );
    cartDataInfo.docID = tmpProductDetails.docid;
    setState(() {
      cartDataList.add(cartDataInfo);
    });
  }

  addQty(int index) {
    var tmpProductDetails = billingProductList[crttab].products![index];
    int findCartIndex = cartDataList.indexWhere(
      (element) => element.productId == tmpProductDetails.productId,
    );
    if (findCartIndex != -1) {
      setState(() {
        //Cart Product Qty Added
        cartDataList[findCartIndex].qty = cartDataList[findCartIndex].qty! + 1;
        cartDataList[findCartIndex].qtyForm!.text =
            cartDataList[findCartIndex].qty.toString();

        // Product Qty Added
        tmpProductDetails.qty = tmpProductDetails.qty! + 1;
        tmpProductDetails.qtyForm!.text = tmpProductDetails.qty.toString();
      });
    }
  }

  lessQty(int index) {
    var tmpProductDetails = billingProductList[crttab].products![index];

    int findCartIndex = cartDataList.indexWhere(
      (element) => element.productId == tmpProductDetails.productId,
    );
    setState(() {
      if (findCartIndex != -1) {
        if (cartDataList[findCartIndex].qty == 1) {
          // Remove At Cart
          cartDataList.removeAt(findCartIndex);

          // Less Qty in Product Page
          tmpProductDetails.qty = tmpProductDetails.qty! - 1;
          tmpProductDetails.qtyForm!.text = tmpProductDetails.qty.toString();
        } else {
          // Less Qty in Cart Page
          cartDataList[findCartIndex].qty =
              cartDataList[findCartIndex].qty! - 1;
          cartDataList[findCartIndex].qtyForm!.text =
              cartDataList[findCartIndex].qty.toString();

          // Less Qty in Product Page
          tmpProductDetails.qty = tmpProductDetails.qty! - 1;
          tmpProductDetails.qtyForm!.text = tmpProductDetails.qty.toString();
        }
      }
    });
  }

  formQtyChange(int index, String? value) async {
    var tmpProductDetails = billingProductList[crttab].products![index];

    int findCartIndex = cartDataList.indexWhere(
      (element) => element.productId == tmpProductDetails.productId,
    );

    if (findCartIndex != -1) {
      // ini product variable

      if (value != null && value != "0" && value.isNotEmpty) {
        setState(() {
          //  product qrt
          tmpProductDetails.qty = int.parse(value);

          //qty Page Change
          cartDataList[findCartIndex].qty = int.parse(value);
          cartDataList[findCartIndex].qtyForm!.text =
              cartDataList[findCartIndex].qty.toString();

          // billing Page Refrace
          billPageProvider2.toggletab(true);
        });
      } else {
        setState(() {
          //  product qrt
          tmpProductDetails.qty = 1;
          tmpProductDetails.qtyForm!.text = "1";
          //qty Page Change
          cartDataList[findCartIndex].qty = 1;
          cartDataList[findCartIndex].qtyForm!.text =
              cartDataList[findCartIndex].qty.toString();
          cartDataList[findCartIndex].qtyForm!.text =
              cartDataList[findCartIndex].qty.toString();
          FocusManager.instance.primaryFocus!.unfocus();
        });
      }
    }
  }

  searchProductAlert() async {
    await showDialog(
      barrierDismissible: false,
      context: context,
      builder: (context) {
        return const SearchProductBilling();
      },
    ).then((value) {
      if (value != null && value.isNotEmpty) {
        int productIndex = -1;
        int count = 0;
        for (var products in billingProductList) {
          productIndex = products.products!
              .indexWhere((element) => element.productId == value);
          if (productIndex != -1) {
            break;
          }
          count += 1;
        }
        if (productIndex != -1) {
          var tmpProductDetails =
              billingProductList[count].products![productIndex];

          int findCartIndex = cartDataList.indexWhere(
            (element) => element.productId == tmpProductDetails.productId,
          );
          if (findCartIndex != -1) {
            setState(() {
              crttab = count;
              tmpProductDetails.qty = tmpProductDetails.qty! + 1;
              tmpProductDetails.qtyForm!.text =
                  tmpProductDetails.qty.toString();
              //qty Page Change
              cartDataList[findCartIndex].qty =
                  billingProductList[count].products![productIndex].qty;
              cartDataList[findCartIndex].qtyForm!.text =
                  cartDataList[findCartIndex].qty.toString();
            });
          } else {
            setState(() {
              crttab = count;
            });
            addtoCart(productIndex);
          }
          // showQRBox(index: productIndex, count: count);
        }
      }
    });
  }

  addCustomProductAlert() async {
    await showDialog(
      barrierDismissible: false,
      context: context,
      builder: (context) {
        return const AddCustomProduct();
      },
    );
    // ).then((value) {
    //   if (value != null && value.isNotEmpty) {
    //     int productIndex = -1;
    //     int count = 0;
    //     for (var products in billingProductList) {
    //       productIndex = products.products!
    //           .indexWhere((element) => element.productId == value);
    //       if (productIndex != -1) {
    //         break;
    //       }
    //       count += 1;
    //     }
    //     if (productIndex != -1) {
    //       showQRBox(index: productIndex, count: count);
    //     }
    //   }
    // });
  }

  @override
  void dispose() {
    super.dispose();
    customerInfo = null;
    cartDataList.clear();
    discountSys = "%";
    extraDiscountSys = "%";
    packingChargeSys = "%";
    discountInput = 0;
    extraDiscountInput = 0;
    packingChargeInput = 0;
    billPageProvider2.addListener(pageRefrce);
  }

  @override
  void initState() {
    super.initState();
    billingHandler = getProductList();
    billPageProvider2.addListener(pageRefrce);
  }

  pageRefrce() {
    if (mounted) {
      setState(() {});
    }
  }

  dialogBox() {
    return confirmationDialog(
      context,
      title: "Alert",
      message: "Do you want exit this page ?",
    );
  }

  showQRBox({required int index, required int count}) async {
    await showDialog(
      context: context,
      builder: (context) {
        return QRAlertProduct(count: count, index: index);
      },
    ).then((value) {
      if (value != null && value == true) {
        setState(() {
          crttab = count;
        });
      }
    });
  }

  scanBarCode() async {
    try {
      await FlutterBarcodeScanner.scanBarcode(
        '#ff6666',
        'Cancel',
        true,
        ScanMode.BARCODE,
      ).then((barcodeScanRes) {
        loading(context);
        barcodeScanRes = barcodeScanRes.replaceFirst(RegExp(r']C1'), '');
        if (barcodeScanRes.isNotEmpty) {
          int productIndex = -1;
          int count = 0;
          for (var products in billingProductList) {
            productIndex = products.products!
                .indexWhere((element) => element.qrCode == barcodeScanRes);
            if (productIndex != -1) {
              break;
            }
            count += 1;
          }
          log(count.toString());
          Navigator.pop(context);
          if (productIndex != -1) {
            var tmpProductDetails =
                billingProductList[count].products![productIndex];

            int findCartIndex = cartDataList.indexWhere(
              (element) => element.productId == tmpProductDetails.productId,
            );
            if (findCartIndex != -1) {
              setState(() {
                crttab = count;
                tmpProductDetails.qty = tmpProductDetails.qty! + 1;
                tmpProductDetails.qtyForm!.text =
                    tmpProductDetails.qty.toString();
                //qty Page Change
                cartDataList[findCartIndex].qty =
                    billingProductList[count].products![productIndex].qty;
                cartDataList[findCartIndex].qtyForm!.text =
                    cartDataList[findCartIndex].qty.toString();
              });
            } else {
              setState(() {
                crttab = count;
              });
              addtoCart(productIndex);
            }
            // showQRBox(index: productIndex, count: count);
            // setState(() {
            //   controller!.animateTo(
            //     count,
            //     duration: const Duration(milliseconds: 300),
            //     curve: Curves.ease,
            //   );
            //   crttab = count;
            //   if (billingProductList[count].products![productIndex].qty !=
            //           null &&
            //       billingProductList[count].products![productIndex].qty! >= 1) {
            //     log("is Worked");
            //     addQty(productIndex);
            //     // billingProductList[count].products![productIndex].qty = 10;
            //     // billingProductList[count]
            //     //     .products![productIndex]
            //     //     .qtyForm!
            //     //     .text = "10";
            //   } else {
            //     // billingProductList[count].products![productIndex].qty = 1;
            //     addtoCart(productIndex);
            //   }
            // });
          } else {
            snackBarCustom(context, false, "No Product Available");
          }
        }
        log(barcodeScanRes);
      });
    } catch (e) {
      snackBarCustom(context, false, e.toString());
    }
  }

  int getTabSize() {
    int count = 2;
    if (MediaQuery.of(context).size.width > 600) {
      count = 4;
    }
    if (MediaQuery.of(context).size.width > 800) {
      count = 6;
    }
    return count;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: billingTwoKey,
      backgroundColor: const Color(0xffEEEEEE),
      endDrawer: CartDrawer(
        isEdit: widget.isEdit,
        enquiryDocId: widget.enquiryData?.docID,
        estimateDocId: widget.estimateData?.docID,
        pageType: 2,
      ),
      appBar: AppBar(
        elevation: 0,
        leading: widget.isEdit == null || widget.isEdit == false
            ? IconButton(
                splashRadius: 20,
                onPressed: () {
                  homeKey.currentState!.openDrawer();
                },
                icon: const Icon(Icons.menu),
              )
            : null,
        title: const Text("Billing"),
        actions: isLoading == false
            ? [
                IconButton(
                  splashRadius: 20,
                  onPressed: () {
                    searchProductAlert();
                  },
                  icon: const Icon(Icons.search),
                ),
                IconButton(
                  splashRadius: 20,
                  onPressed: () {
                    addCustomProductAlert();
                  },
                  icon: const Icon(Icons.add),
                ),
                IconButton(
                  splashRadius: 20,
                  onPressed: () {
                    billingTwoKey.currentState!.openEndDrawer();
                  },
                  icon: Badge(
                    label: Text(cartDataList.length.toString()),
                    child: const Icon(Icons.shopping_cart),
                  ),
                ),
              ]
            : const [
                SizedBox(),
              ],
      ),
      floatingActionButton: isLoading == false
          ? FloatingActionButton(
              backgroundColor: Theme.of(context).primaryColor,
              onPressed: () {
                scanBarCode();
              },
              child: const Icon(
                Icons.qr_code,
              ),
            )
          : null,
      body: FutureBuilder(
        future: billingHandler,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return Row(
              children: [
                Container(
                  width: 80,
                  height: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                  ),
                  child: ListView.builder(
                    itemCount: billingProductList.length,
                    itemBuilder: (context, index) {
                      if (billingProductList[index]
                          .category!
                          .categoryName!
                          .isNotEmpty) {
                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              crttab = index;
                            });
                          },
                          child: Container(
                            height: 80,
                            width: 80,
                            decoration: BoxDecoration(
                              color: crttab == index
                                  ? Colors.grey.shade400
                                  : Colors.transparent,
                            ),
                            padding: const EdgeInsets.all(10),
                            child: Center(
                              child: Text(
                                billingProductList[index]
                                    .category!
                                    .categoryName
                                    .toString(),
                                maxLines: 3,
                                textAlign: TextAlign.center,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ),
                        );
                      } else {
                        return const SizedBox();
                      }
                    },
                  ),
                ),
                Expanded(
                  child: GridView.builder(
                    padding: const EdgeInsets.all(5),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: getTabSize(),
                      crossAxisSpacing: 5,
                      mainAxisSpacing: 5,
                      childAspectRatio: (1 / 1.35),
                    ),
                    itemCount: billingProductList[crttab].products!.length,
                    itemBuilder: (context, index) {
                      ProductDataModel tmpProductDetails =
                          billingProductList[crttab].products![index];
                      return GestureDetector(
                        onTap: () {
                          tapQty(index);
                        },
                        child: Container(
                          padding: const EdgeInsets.all(5),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(5),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(5),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: Colors.grey.shade300,
                                      borderRadius: BorderRadius.circular(5),
                                      image: tmpProductDetails.productImg !=
                                              null
                                          ? DecorationImage(
                                              image: NetworkImage(
                                                tmpProductDetails.productImg!,
                                              ),
                                              fit: BoxFit.cover,
                                            )
                                          : null,
                                    ),
                                  ),
                                ),
                                const SizedBox(
                                  height: 5,
                                ),
                                Column(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      tmpProductDetails.productName ?? "",
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyLarge!
                                          .copyWith(
                                            color: Colors.grey,
                                          ),
                                    ),
                                    Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        Text(
                                          "\u{20B9}${tmpProductDetails.price ?? ""}",
                                          style: Theme.of(context)
                                              .textTheme
                                              .titleLarge,
                                        ),
                                        const SizedBox(
                                          width: 5,
                                        ),
                                        Text(
                                          "\u{20B9}${tmpProductDetails.price ?? ""}",
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodySmall!
                                              .copyWith(
                                                decoration:
                                                    TextDecoration.lineThrough,
                                              ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                const SizedBox(
                                  height: 5,
                                ),
                                GestureDetector(
                                  onTap: () {
                                    if (tmpProductDetails.qty == 0) {
                                      addtoCart(index);
                                    }
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.only(left: 0),
                                    height: 35,
                                    width: double.infinity,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(5),
                                      border: Border.all(
                                        width: 0.5,
                                        color: Colors.grey.shade300,
                                      ),
                                    ),
                                    child: tmpProductDetails.qty == 0
                                        ? Center(
                                            child: Text(
                                              "Add To Cart",
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .titleSmall!
                                                  .copyWith(
                                                    color: Colors.blue.shade700,
                                                  ),
                                            ),
                                          )
                                        : ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(5),
                                            child: Row(
                                              children: [
                                                GestureDetector(
                                                  onTap: () {
                                                    lessQty(index);
                                                  },
                                                  child: Container(
                                                    decoration: BoxDecoration(
                                                      color:
                                                          Colors.red.shade400,
                                                    ),
                                                    height: 35,
                                                    width: 35,
                                                    child: const Center(
                                                      child: Icon(
                                                        Icons.remove_outlined,
                                                        size: 15,
                                                        color: Colors.white,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                Expanded(
                                                  child: TextFormField(
                                                    textAlign: TextAlign.center,
                                                    keyboardType:
                                                        TextInputType.number,
                                                    inputFormatters: [
                                                      LengthLimitingTextInputFormatter(
                                                        3,
                                                      ),
                                                      FilteringTextInputFormatter
                                                          .digitsOnly
                                                    ],
                                                    controller:
                                                        tmpProductDetails
                                                            .qtyForm,
                                                    decoration:
                                                        const InputDecoration(
                                                      filled: true,
                                                      fillColor:
                                                          Colors.transparent,
                                                      contentPadding:
                                                          EdgeInsets.symmetric(
                                                        horizontal: 10,
                                                      ),
                                                    ),
                                                    onChanged: (value) {
                                                      formQtyChange(
                                                          index, value);
                                                    },
                                                  ),
                                                ),
                                                GestureDetector(
                                                  onTap: () {
                                                    addQty(index);
                                                  },
                                                  child: Container(
                                                    decoration: BoxDecoration(
                                                      color:
                                                          Colors.green.shade400,
                                                    ),
                                                    height: 35,
                                                    width: 35,
                                                    child: const Center(
                                                      child: Icon(
                                                        Icons.add,
                                                        size: 15,
                                                        color: Colors.white,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            );
          } else if (snapshot.connectionState == ConnectionState.done &&
              snapshot.hasError) {
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
                      snapshot.error.toString() == "null"
                          ? "Something went Wrong"
                          : snapshot.error.toString(),
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
                            billingHandler = getProductList();
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

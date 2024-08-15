import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sri_sakthivel_fireworks_pos/firebase/firestore_provider.dart';
import 'package:sri_sakthivel_fireworks_pos/screen/mainapp/billing/add_customer_box.dart';
import 'package:sri_sakthivel_fireworks_pos/screen/mainapp/billing/billing_two.dart';
import 'package:sri_sakthivel_fireworks_pos/screen/ui/commenwidget.dart';
import 'package:sri_sakthivel_fireworks_pos/utlities/utlities.dart';

import '../../../firebase/datamodel/datamodel.dart';
import '../../../utlities/provider/localdb.dart';
import '../../../utlities/varibales.dart';
import '../../ui/sidebar.dart';
import 'billing_one.dart';
import 'customer_search.dart';

class CartDrawer extends StatefulWidget {
  final bool? isEdit;
  final String? enquiryDocId;
  final String? estimateDocId;
  final int pageType;
  final Color? backgroundColor;
  const CartDrawer({
    super.key,
    this.isEdit,
    this.enquiryDocId,
    this.estimateDocId,
    required this.pageType,
    this.backgroundColor,
  });

  @override
  State<CartDrawer> createState() => _CartDrawerState();
}

class _CartDrawerState extends State<CartDrawer> {
  String subTotal() {
    String result = "0.00";
    double tmpSubTotal = 0.00;
    for (var element in cartDataList) {
      tmpSubTotal += element.price! * element.qty!;
    }
    result = tmpSubTotal.toStringAsFixed(2);
    return result;
  }

  String discount() {
    String result = "0.00";
    double tmpDiscount = 0.00;
    for (var element in cartDataList) {
      log(element.discount.toString());
      if (element.discountLock == false && element.discount != null) {
        log(element.productName.toString());
        double total = element.price! * element.qty!;
        tmpDiscount += (total * (element.discount!.toDouble() / 100));
      }
    }

    log("subtotal : $tmpDiscount");

    // if (tmpSubTotal > discountInput) {
    //   if (discountSys == "%") {
    //     tmpDiscount = (tmpSubTotal * (discountInput / 100));
    //   } else {
    //     tmpDiscount = discountInput;
    //   }
    // }

    if (tmpDiscount.isNaN) {
      tmpDiscount = 0.00;
      log("discount is Nan");
    }

    result = tmpDiscount.toStringAsFixed(2);

    return result;
  }

  String extraDiscount() {
    String result = "0.00";
    double subTotalValue = double.parse(subTotal());
    double discountValue = double.parse(discount());
    double tmpExtraDiscount = 0.00;

    if (extraDiscountSys == "%") {
      double tmpsubtotal = (subTotalValue - discountValue);
      tmpExtraDiscount = tmpsubtotal * (extraDiscountInput / 100);
    } else {
      tmpExtraDiscount = extraDiscountInput;
    }

    if (tmpExtraDiscount.isNaN) {
      tmpExtraDiscount = 0.00;
    }
    result = tmpExtraDiscount.toStringAsFixed(2);
    return result;
  }

  String packingChareges() {
    String result = "0.00";
    double subTotalValue = double.parse(subTotal());
    double discountValue = double.parse(discount());
    double extradiscountValue = double.parse(extraDiscount());
    double tmppackingcharge = 0.00;

    if (packingChargeSys == "%") {
      double tmpsubtotal = (subTotalValue + discountValue + extradiscountValue);
      tmppackingcharge = tmpsubtotal * (packingChargeInput / 100);
    } else {
      tmppackingcharge = packingChargeInput;
    }

    if (tmppackingcharge.isNaN) {
      tmppackingcharge = 0.00;
    }
    result = tmppackingcharge.toStringAsFixed(2);
    return result;
  }

  String cartTotal() {
    String result = "0.00";
    double subTotalValue = double.parse(subTotal());
    double discountValue = double.parse(discount());
    double extradiscountValue = double.parse(extraDiscount());
    double packingChargeValue = double.parse(packingChareges());
    double tmptotal = 0.00;
    tmptotal = ((subTotalValue - discountValue) - extradiscountValue) + packingChargeValue;
    if (tmptotal.isNaN) {
      tmptotal = 0.00;
    }
    result = tmptotal.toStringAsFixed(2);
    return result;
  }

  Future<Map<String, int>> findBillingIndexs(int cartIndex) async {
    int findBillingCategoryIndex = billingProductList.indexWhere(
      (element) {
        return element.category!.tmpcatid == cartDataList[cartIndex].categoryId;
      },
    );
    if (findBillingCategoryIndex != -1) {
      // Find Product Index
      int findBillingProductIndex = billingProductList[findBillingCategoryIndex].products!.indexWhere(
        (element) {
          return element.productId == cartDataList[cartIndex].productId;
        },
      );

      if (findBillingProductIndex != -1) {
        var result = {
          "categoryIndex": findBillingCategoryIndex,
          "productIndex": findBillingProductIndex,
        };
        return result;
      }
    }
    return {
      "categoryIndex": -1,
      "productIndex": -1,
    };
  }

  addQty(int cartIndex) async {
    int findBillingCategoryIndex = -1;
    int findBillingProductIndex = -1;

    await findBillingIndexs(cartIndex).then((value) {
      findBillingCategoryIndex = value["categoryIndex"] ?? -1;
      findBillingProductIndex = value["productIndex"] ?? -1;
    });
    if (findBillingProductIndex != -1 && findBillingCategoryIndex != -1) {
      // ini product variable
      var product = billingProductList[findBillingCategoryIndex].products![findBillingProductIndex];
      setState(() {
        // add product qrt
        product.qty = product.qty! + 1;
        product.qtyForm!.text = product.qty.toString();

        // Cart Page Qty Change
        cartDataList[cartIndex].qty = cartDataList[cartIndex].qty! + 1;
        cartDataList[cartIndex].qtyForm!.text = cartDataList[cartIndex].qty.toString();

        // billing Page Refrace
        if (widget.pageType == 1) {
          billPageProvider.toggletab(true);
        } else {
          billPageProvider2.toggletab(true);
        }
      });
    }
  }

  lessQty(int cartIndex) async {
    int findBillingCategoryIndex = -1;
    int findBillingProductIndex = -1;

    await findBillingIndexs(cartIndex).then((value) async {
      findBillingCategoryIndex = value["categoryIndex"] ?? -1;
      findBillingProductIndex = value["productIndex"] ?? -1;

      if (findBillingProductIndex != -1) {
        // ini product variable
        var product = billingProductList[findBillingCategoryIndex].products![findBillingProductIndex];

        if (cartDataList[cartIndex].qty == 1) {
          await confirmationDialog(
            context,
            title: "Warning",
            message: "Do you want to delete this product?",
          ).then(
            (value) {
              setState(() {
                if (value != null && value == true) {
                  // less product qrt
                  product.qty = product.qty! - 1;
                  product.qtyForm!.text = product.qty.toString();

                  // Remove From Cart
                  cartDataList.removeAt(cartIndex);
                  // billing Page Refrace
                  if (widget.pageType == 1) {
                    billPageProvider.toggletab(true);
                  } else {
                    billPageProvider2.toggletab(true);
                  }
                }
              });
            },
          );
        } else {
          setState(() {
            // less product qrt
            product.qty = product.qty! - 1;
            product.qtyForm!.text = product.qty.toString();

            //qty Page Change
            cartDataList[cartIndex].qty = cartDataList[cartIndex].qty! - 1;
            cartDataList[cartIndex].qtyForm!.text = cartDataList[cartIndex].qty.toString();

            // billing Page Refrace
            if (widget.pageType == 1) {
              billPageProvider.toggletab(true);
            } else {
              billPageProvider2.toggletab(true);
            }
          });
        }
      }
    });
  }

  formQtyChange(int cartIndex, String? value) async {
    int findBillingCategoryIndex = -1;
    int findBillingProductIndex = -1;

    await findBillingIndexs(cartIndex).then((value) {
      findBillingCategoryIndex = value["categoryIndex"] ?? -1;
      findBillingProductIndex = value["productIndex"] ?? -1;
    });
    if (findBillingProductIndex != -1 && findBillingCategoryIndex != -1) {
      // ini product variable
      var product = billingProductList[findBillingCategoryIndex].products![findBillingProductIndex];
      if (value != null && value != "0" && value.isNotEmpty) {
        setState(() {
          // less product qrt
          product.qty = int.parse(value);
          product.qtyForm!.text = product.qty.toString();

          //qty Page Change
          cartDataList[cartIndex].qty = int.parse(value);

          // billing Page Refrace
          if (widget.pageType == 1) {
            billPageProvider.toggletab(true);
          } else {
            billPageProvider2.toggletab(true);
          }
        });
      } else {
        setState(() {
          // less product qrt
          product.qty = 1;
          product.qtyForm!.text = product.qty.toString();

          //qty Page Change
          cartDataList[cartIndex].qty = 1;
          cartDataList[cartIndex].qtyForm!.text = cartDataList[cartIndex].qty.toString();
          FocusManager.instance.primaryFocus!.unfocus();
          // billing Page Refrace
          if (widget.pageType == 1) {
            billPageProvider.toggletab(true);
          } else {
            billPageProvider2.toggletab(true);
          }
        });
      }
    }
  }

  deleteProduct(int cartIndex) async {
    int findBillingCategoryIndex = -1;
    int findBillingProductIndex = -1;

    await findBillingIndexs(cartIndex).then((value) async {
      findBillingCategoryIndex = value["categoryIndex"] ?? -1;
      findBillingProductIndex = value["productIndex"] ?? -1;

      if (findBillingCategoryIndex != -1 && findBillingProductIndex != -1) {
        var product = billingProductList[findBillingCategoryIndex].products![findBillingProductIndex];
        await confirmationDialog(
          context,
          title: "Warning",
          message: "Do you want to delete this product?",
        ).then(
          (value) {
            setState(() {
              if (value != null && value == true) {
                // less product qrt
                product.qty = 0;
                product.qtyForm!.text = product.qty.toString();

                // Remove From Cart
                cartDataList.removeAt(cartIndex);
                // billing Page Refrace
                if (widget.pageType == 1) {
                  billPageProvider.toggletab(true);
                } else {
                  billPageProvider2.toggletab(true);
                }
              }
            });
          },
        );
      }
    });
  }

  String discountCart() {
    String result = "0.00";
    double tmpSubTotal = 0.00;
    for (var element in cartDataList) {
      tmpSubTotal += element.price! * element.qty!;
    }
    result = tmpSubTotal.toStringAsFixed(2);
    return result;
  }

  convertEstimate({required String cid}) async {
    var calcul = BillingCalCulation();
    calcul.discount = discountInput;
    calcul.discountValue = double.parse(discount());
    calcul.discountsys = discountSys;
    calcul.extraDiscount = extraDiscountInput;
    calcul.extraDiscountValue = double.parse(extraDiscount());
    calcul.extraDiscountsys = extraDiscountSys;
    calcul.package = packingChargeInput;
    calcul.packageValue = double.parse(packingChareges());
    calcul.packagesys = packingChargeSys;
    calcul.subTotal = double.parse(subTotal());
    calcul.total = double.parse(cartTotal());

    var cloud = FireStoreProvider();
    await cloud
        .createNewEstimate(
      calCulation: calcul,
      cid: cid,
      productList: cartDataList,
      customerInfo: customerInfo,
    )
        .then((estimateData) async {
      if (estimateData != null && estimateData.id.isNotEmpty) {
        await cloud
            .updateEstimateId(
          cid: cid,
          docID: estimateData.id,
        )
            .then((resultFinal) async {
          if (resultFinal != null) {
            Navigator.pop(context);
            snackBarCustom(context, true, "SuccessFully Place the Order");
            setState(() {
              cartDataList.clear();
              sidebar.toggletab(9);
            });
          }
        });
      } else {
        Navigator.pop(context);
        snackBarCustom(
          context,
          false,
          "Something went Wrong Please try again",
        );
      }
    });
  }

  orderApi() async {
    await orderDialog(
      context,
      title: "Alert",
      message: "Do you want convert to Estimate",
    ).then((value) async {
      if (value != null) {
        if (value == true && customerInfo == null) {
          snackBarCustom(context, false, "Customer is Must");
        } else {
          try {
            loading(context);

            await LocalDbProvider().fetchInfo(type: LocalData.companyid).then((cid) async {
              if (cid != null) {
                if (value == true) {
                  convertEstimate(cid: cid);
                } else {
                  var calcul = BillingCalCulation();
                  calcul.discount = discountInput;
                  calcul.discountValue = double.parse(discount());
                  calcul.discountsys = discountSys;
                  calcul.extraDiscount = extraDiscountInput;
                  calcul.extraDiscountValue = double.parse(extraDiscount());
                  calcul.extraDiscountsys = extraDiscountSys;
                  calcul.package = packingChargeInput;
                  calcul.packageValue = double.parse(packingChareges());
                  calcul.packagesys = packingChargeSys;
                  calcul.subTotal = double.parse(subTotal());
                  calcul.total = double.parse(cartTotal());

                  var cloud = FireStoreProvider();
                  await cloud
                      .createNewOrder(
                    calCulation: calcul,
                    cid: cid,
                    productList: cartDataList,
                    customerInfo: customerInfo,
                  )
                      .then((enquryData) async {
                    if (enquryData != null && enquryData.id.isNotEmpty) {
                      await cloud.updateEnquiryId(cid: cid, docID: enquryData.id).then((resultFinal) {
                        if (resultFinal != null) {
                          // Successfuly Order Placed
                          Navigator.pop(context);
                          snackBarCustom(context, true, "SuccessFully Place the Order");
                          setState(() {
                            cartDataList.clear();
                            sidebar.toggletab(9);
                          });
                        }
                      });
                    } else {
                      Navigator.pop(context);
                      snackBarCustom(
                        context,
                        false,
                        "Something went Wrong Please try again",
                      );
                    }
                  });
                }
              } else {
                Navigator.pop(context);
                snackBarCustom(
                  context,
                  false,
                  "Something went Wrong Please try again",
                );
              }
            });
          } catch (e) {
            Navigator.pop(context);
            snackBarCustom(context, false, e.toString());
            log(e.toString());
          }
        }
      }
    });

    // Navigator.pop(context);
    // Navigator.push(
    //   context,
    //   CupertinoPageRoute(
    //     builder: (context) => OrderSummary(
    //       total: cartTotal(),
    //       subtotal: subTotal(),
    //       discountsys: discountSys,
    //       discountInput: discountInput.toString(),
    //       discountValue: discount(),
    //       extraDicountsys: extraDiscountSys,
    //       extraDiscountInput: extraDiscountInput.toString(),
    //       extraDiscountValue: extraDiscount(),
    //       packingChargesys: packingChargeSys,
    //       packingChargeInput: packingChargeInput.toString(),
    //       packingChargeValue: packingChareges(),
    //     ),
    //   ),
    // );
  }

  customerAlert() async {
    await showDialog(
      barrierDismissible: false,
      context: context,
      builder: (context) {
        return const CustomerSearch();
      },
    ).then((value) {
      if (value != null) {
        setState(() {
          customerInfo = value;
        });
      }
    });
  }

  customerAddAlert() async {
    await showDialog(
      barrierDismissible: false,
      context: context,
      builder: (context) {
        return const AddCustomerBox();
      },
    ).then((value) {
      if (value != null) {
        setState(() {
          customerInfo = value;
        });
      }
    });
  }

  updateEnquiryApi() async {
    try {
      loading(context);

      await LocalDbProvider().fetchInfo(type: LocalData.companyid).then((cid) async {
        if (cid != null) {
          var calcul = BillingCalCulation();
          calcul.discount = discountInput;
          calcul.discountValue = double.parse(discount());
          calcul.discountsys = discountSys;
          calcul.extraDiscount = extraDiscountInput;
          calcul.extraDiscountValue = double.parse(extraDiscount());
          calcul.extraDiscountsys = extraDiscountSys;
          calcul.package = packingChargeInput;
          calcul.packageValue = double.parse(packingChareges());
          calcul.packagesys = packingChargeSys;
          calcul.subTotal = double.parse(subTotal());
          calcul.total = double.parse(cartTotal());

          var cloud = FireStoreProvider();
          await cloud
              .updateEnquiryDetails(
            docID: widget.enquiryDocId!,
            calCulation: calcul,
            productList: cartDataList,
            customerInfo: customerInfo,
          )
              .then((value) {
            Navigator.pop(context);
            Navigator.pop(context);
            Navigator.pop(context);
            Navigator.pop(context, true);
            snackBarCustom(context, true, "SuccessFully Update the Order");
          });
        } else {
          Navigator.pop(context);
          snackBarCustom(
            context,
            false,
            "Something went Wrong Please try again",
          );
        }
      });
    } catch (e) {
      Navigator.pop(context);
      snackBarCustom(context, false, e.toString());
      log(e.toString());
    }
  }

  updateEstimateApi() async {
    try {
      log("estimate");
      loading(context);

      await LocalDbProvider().fetchInfo(type: LocalData.companyid).then((cid) async {
        if (cid != null) {
          var calcul = BillingCalCulation();
          calcul.discount = discountInput;
          calcul.discountValue = double.parse(discount());
          calcul.discountsys = discountSys;
          calcul.extraDiscount = extraDiscountInput;
          calcul.extraDiscountValue = double.parse(extraDiscount());
          calcul.extraDiscountsys = extraDiscountSys;
          calcul.package = packingChargeInput;
          calcul.packageValue = double.parse(packingChareges());
          calcul.packagesys = packingChargeSys;
          calcul.subTotal = double.parse(subTotal());
          calcul.total = double.parse(cartTotal());

          var cloud = FireStoreProvider();

          log("Estimat Doc ID - ${widget.estimateDocId}");
          await cloud
              .updateEstimateDetails(
            docID: widget.estimateDocId!,
            calCulation: calcul,
            productList: cartDataList,
            customerInfo: customerInfo,
          )
              .then((value) {
            Navigator.pop(context);
            Navigator.pop(context);
            Navigator.pop(context);
            Navigator.pop(context, true);
            snackBarCustom(context, true, "SuccessFully Update the Estimate");
          });
        } else {
          Navigator.pop(context);
          snackBarCustom(
            context,
            false,
            "Something went Wrong Please try again",
          );
        }
      });
    } catch (e) {
      Navigator.pop(context);
      snackBarCustom(context, false, e.toString());
      log(e.toString());
    }
  }

  // String eachProductTotal(int index) {
  //   String result = "0.00";
  //   double? price = cartDataList[index].price;
  //   int? qnt = cartDataList[index].qty;
  //   double tmpTotal = price! * qnt!;
  //   result = tmpTotal.toStringAsFixed(2);
  //   return result;
  // }
  String eachProductTotal(int index) {
    String result = "0.00";
    double? price = cartDataList[index].price;
    int? qnt = cartDataList[index].qty;
    double tmpTotal = cartDataList[index].discount != null
        ? (price! - (price * (cartDataList[index].discount! / 100))) * qnt!
        : price! * qnt!;
    result = tmpTotal.toStringAsFixed(2);
    return result;
  }

  String cartItemCount() {
    String result = "0";
    int count = 0;
    for (var element in cartDataList) {
      count += element.qty!;
    }
    result = count.toString();
    return result;
  }

  clearCart() {
    setState(() {
      cartDataList.clear();
    });
    for (var element in billingProductList) {
      Iterable<ProductDataModel> cartTemp = element.products!.where((element) => element.qty! > 0);
      for (var product in cartTemp) {
        setState(() {
          product.qty = 0;
          product.qtyForm!.clear();
        });
      }
    }
    setState(() {
      if (widget.pageType == 1) {
        billPageProvider.toggletab(true);
      } else {
        billPageProvider2.toggletab(true);
      }
    });
  }

  String findMrpPriceCal({required double price}) {
    String result = "0.00";
    double tmpProduct = 0.00;

    if (discountSys == "%") {
      tmpProduct = price / discountInput;
    }
    result = tmpProduct.toStringAsFixed(2);
    return result;
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: widget.backgroundColor ?? const Color(0xffEEEEEE),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.only(
              top: 5,
              left: 15,
              right: 5,
              bottom: 5,
            ),
            color: Theme.of(context).primaryColor,
            child: SafeArea(
              child: Row(
                children: [
                  Text(
                    "My Cart",
                    style: Theme.of(context).textTheme.headlineSmall!.copyWith(
                          color: Colors.white,
                        ),
                  ),
                  const SizedBox(
                    width: 5,
                  ),
                  Text(
                    "(${cartDataList.length})",
                    style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                          color: Colors.white,
                        ),
                  ),
                  const SizedBox(
                    width: 5,
                  ),
                  Text(
                    "Items-(${cartItemCount()})",
                    style: Theme.of(context).textTheme.bodySmall!.copyWith(
                          color: Colors.white,
                        ),
                  ),
                  const Spacer(),
                  TextButton(
                    onPressed: () async {
                      if (cartDataList.isNotEmpty) {
                        await confirmationDialog(context, title: "Alert", message: "Do you want clear cart ?")
                            .then((value) {
                          if (value != null && value == true) {
                            clearCart();
                          }
                        });
                      }
                    },
                    child: const Text(
                      "Clear",
                      style: TextStyle(
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              child: ListView.builder(
                primary: false,
                shrinkWrap: true,
                reverse: true,
                padding: const EdgeInsets.all(0),
                itemCount: cartDataList.length,
                itemBuilder: (context, index) {
                  return Container(
                    margin: const EdgeInsets.only(
                      top: 5,
                      left: 5,
                      right: 5,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(5),
                    ),
                    padding: const EdgeInsets.all(5),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        cartDataList[index].discountLock == true
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(5),
                                child: Banner(
                                  message: "Net Rate",
                                  location: BannerLocation.topStart,
                                  child: Container(
                                    height: 80,
                                    width: 80,
                                    decoration: BoxDecoration(
                                      color: Colors.grey.shade300,
                                      borderRadius: BorderRadius.circular(5),
                                      image: cartDataList[index].productImg != null
                                          ? DecorationImage(
                                              image: NetworkImage(
                                                cartDataList[index].productImg!,
                                              ),
                                              fit: BoxFit.cover,
                                            )
                                          : null,
                                    ),
                                  ),
                                ),
                              )
                            : Container(
                                height: 80,
                                width: 80,
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade300,
                                  borderRadius: BorderRadius.circular(5),
                                  image: cartDataList[index].productImg != null
                                      ? DecorationImage(
                                          image: NetworkImage(
                                            cartDataList[index].productImg!,
                                          ),
                                          fit: BoxFit.cover,
                                        )
                                      : null,
                                ),
                              ),
                        const SizedBox(
                          width: 10,
                        ),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          cartDataList[index].categoryName ?? "",
                                          style: Theme.of(context).textTheme.bodySmall!.copyWith(color: Colors.grey),
                                        ),
                                        const SizedBox(
                                          height: 2,
                                        ),
                                        Text(
                                          cartDataList[index].productName ?? "",
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                          style: Theme.of(context).textTheme.titleMedium,
                                        ),
                                      ],
                                    ),
                                  ),
                                  GestureDetector(
                                    onTap: () {
                                      deleteProduct(index);
                                    },
                                    child: Container(
                                      color: Colors.transparent,
                                      padding: const EdgeInsets.all(5),
                                      child: Icon(
                                        Icons.delete,
                                        color: Colors.red.shade600,
                                        size: 22,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(
                                height: 8,
                              ),
                              SizedBox(
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Container(
                                        padding: const EdgeInsets.only(left: 0),
                                        height: 30,
                                        width: double.infinity,
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: BorderRadius.circular(5),
                                          border: Border.all(
                                            width: 0.5,
                                            color: Colors.grey.shade300,
                                          ),
                                        ),
                                        child: ClipRRect(
                                          borderRadius: BorderRadius.circular(5),
                                          child: Row(
                                            children: [
                                              // const Text("1"),

                                              GestureDetector(
                                                onTap: () {
                                                  setState(() {
                                                    lessQty(index);
                                                    // tmpProductDetails.qty =
                                                    //     tmpProductDetails.qty! - 1;
                                                  });
                                                },
                                                child: Container(
                                                  decoration: BoxDecoration(
                                                    color: Colors.red.shade400,
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
                                                  keyboardType: TextInputType.number,
                                                  inputFormatters: [
                                                    LengthLimitingTextInputFormatter(
                                                      3,
                                                    ),
                                                    FilteringTextInputFormatter.digitsOnly
                                                  ],
                                                  controller: cartDataList[index].qtyForm,
                                                  decoration: const InputDecoration(
                                                    filled: true,
                                                    fillColor: Colors.transparent,
                                                    contentPadding: EdgeInsets.symmetric(
                                                      horizontal: 5,
                                                    ),
                                                  ),
                                                  onTap: () {
                                                    setState(() {
                                                      cartDataList[index].qtyForm!.clear();
                                                    });
                                                  },
                                                  onChanged: (value) {
                                                    formQtyChange(index, value);
                                                  },
                                                ),
                                              ),
                                              GestureDetector(
                                                onTap: () {
                                                  setState(() {
                                                    addQty(index);
                                                    // tmpProductDetails.qty =
                                                    //     tmpProductDetails.qty! + 1;
                                                  });
                                                },
                                                child: Container(
                                                  decoration: BoxDecoration(
                                                    color: Colors.green.shade400,
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
                                    const SizedBox(
                                      width: 10,
                                    ),
                                    Column(
                                      mainAxisSize: MainAxisSize.min,
                                      crossAxisAlignment: CrossAxisAlignment.end,
                                      children: [
                                        Text(
                                          "\u{20B9}${cartDataList[index].discount != null ? cartDataList[index].price! : ""}",
                                          style: Theme.of(context).textTheme.bodySmall!.copyWith(
                                                decoration: TextDecoration.lineThrough,
                                              ),
                                        ),
                                        const SizedBox(
                                          height: 1,
                                        ),
                                        Text(
                                          "\u{20B9}${cartDataList[index].discount != null ? (cartDataList[index].price! - (cartDataList[index].price! * (cartDataList[index].discount! / 100))).toStringAsFixed(2) : cartDataList[index].price}",
                                          style: Theme.of(context).textTheme.titleLarge,
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              // Total Product Price
                              Container(
                                alignment: Alignment.centerRight,
                                child: Text(
                                  "Total - \u{20B9}${eachProductTotal(index)}",
                                  style: Theme.of(context).textTheme.bodyMedium,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(
              top: 5,
              left: 5,
              right: 5,
            ),
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Visibility(
                    visible: customerInfo == null,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Customer",
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        GestureDetector(
                          onTap: () {
                            customerAddAlert();

                            // Navigator.push(
                            //   context,
                            //   CupertinoPageRoute(
                            //     builder: (context) => const CustomerSearch(),
                            //   ),
                            // ).then((value) {
                            //   if (value != null) {
                            //     setState(() {
                            //       customerInfo = value;
                            //     });
                            //   }
                            // });
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: Theme.of(context).primaryColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(5),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.add,
                                  color: Theme.of(context).primaryColor,
                                  size: 15,
                                ),
                                const SizedBox(
                                  width: 8,
                                ),
                                Text(
                                  "Add",
                                  style: Theme.of(context).textTheme.titleSmall!.copyWith(
                                        color: Theme.of(context).primaryColor,
                                      ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Visibility(
                    visible: customerInfo == null,
                    child: const SizedBox(
                      height: 10,
                    ),
                  ),
                  // Visibility(
                  //   visible: customerInfo == null,
                  //   child: Padding(
                  //     padding: const EdgeInsets.symmetric(
                  //       horizontal: 8,
                  //       vertical: 5,
                  //     ),
                  //     child: Center(
                  //       child: Text(
                  //         "No Customer Selected",
                  //         style: Theme.of(context)
                  //             .textTheme
                  //             .titleSmall!
                  //             .copyWith(color: Colors.grey),
                  //       ),
                  //     ),
                  //   ),
                  // ),
                  Visibility(
                    visible: customerInfo == null,
                    child: Center(
                      child: TextButton(
                        onPressed: () {
                          customerAlert();
                        },
                        child: const Text("Choose Customer"),
                      ),
                    ),
                  ),
                  customerInfo != null
                      ? Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(5),
                          ),
                          child: ListTile(
                            contentPadding: const EdgeInsets.all(0),
                            leading: Container(
                              height: 40,
                              width: 40,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.grey.shade200,
                              ),
                              child: const Center(
                                child: Icon(
                                  Icons.person,
                                  color: Colors.grey,
                                  size: 18,
                                ),
                              ),
                            ),
                            title: Text(
                              customerInfo!.customerName ?? "",
                              // style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                              //       color: Colors.black,
                              //     ),
                            ),
                            subtitle: Wrap(
                              spacing: 5,
                              runSpacing: 2,
                              children: [
                                Text(
                                  "Phone : ${customerInfo!.mobileNo ?? ""}",
                                  style: Theme.of(context).textTheme.labelMedium!.copyWith(
                                        color: Colors.grey,
                                      ),
                                ),
                                Text(
                                  "City : ${customerInfo!.city ?? ""}",
                                  style: Theme.of(context).textTheme.labelMedium!.copyWith(
                                        color: Colors.grey,
                                      ),
                                ),
                                Text(
                                  "State : ${customerInfo!.state ?? ""}",
                                  style: Theme.of(context).textTheme.labelMedium!.copyWith(
                                        color: Colors.grey,
                                      ),
                                ),
                              ],
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                GestureDetector(
                                  onTap: () async {
                                    await confirmationDialog(
                                      context,
                                      title: "Warning",
                                      message: "Do you want to remove this Customer?",
                                    ).then(
                                      (value) {
                                        if (value != null && value == true) {
                                          setState(() {
                                            customerInfo = null;
                                          });
                                        }
                                      },
                                    );
                                  },
                                  child: Container(
                                    height: 30,
                                    width: 30,
                                    decoration: const BoxDecoration(
                                      color: Colors.transparent,
                                    ),
                                    child: const Icon(
                                      Icons.delete,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                      : const SizedBox(),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(5.0),
            child: Container(
              padding: const EdgeInsets.only(
                left: 10,
                right: 10,
                top: 10,
                bottom: 5,
              ),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(5),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "Total",
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                            Text(
                              "\u{20B9}${cartTotal()}",
                              style: Theme.of(context).textTheme.titleLarge!.copyWith(
                                    color: Colors.green.shade600,
                                  ),
                            ),
                          ],
                        ),
                        const Divider(
                          height: 25,
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Sub Total",
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        Text(
                          "\u{20B9}${subTotal()}",
                          style: Theme.of(context).textTheme.bodyMedium!.copyWith(color: Colors.green.shade600),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(
                    height: 8,
                  ),
                  GestureDetector(
                    onTap: () async {
                      var result = await formDialog(
                        context,
                        title: "Discount",
                        sysmbol: discountSys,
                        value: discountInput.toString(),
                      );
                      if (result != null) {
                        setState(() {
                          discountSys = result["sys"];
                          discountInput = double.parse(result["value"]);
                        });
                      }
                      log("Discount");
                    },
                    child: Container(
                      color: Colors.transparent,
                      child: Row(
                        children: [
                          Text(
                            // "Discount - ${discountSys.toUpperCase()} $discountInput",
                            "Discount",
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                          // const SizedBox(width: 5),
                          // const Icon(
                          //   Icons.edit,
                          //   size: 15,
                          // ),
                          const Spacer(),
                          Text(
                            "\u{20B9}${discount()}",
                            style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                                  color: Colors.red.shade600,
                                ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 8,
                  ),
                  GestureDetector(
                    onTap: () async {
                      var result = await formDialog(
                        context,
                        title: "Extra Discount",
                        sysmbol: extraDiscountSys,
                        value: extraDiscountInput.toString(),
                      );
                      if (result != null) {
                        setState(() {
                          extraDiscountSys = result["sys"];
                          extraDiscountInput = double.parse(result["value"]);
                        });
                      }
                      log("Extra Discount");
                    },
                    child: Container(
                      color: Colors.transparent,
                      child: Row(
                        children: [
                          Text(
                            "Extra Discount - ${extraDiscountSys.toUpperCase()} $extraDiscountInput",
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                          const SizedBox(width: 5),
                          const Icon(
                            Icons.edit,
                            size: 15,
                          ),
                          const Spacer(),
                          Text(
                            "\u{20B9}${extraDiscount()}",
                            style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                                  color: Colors.red.shade600,
                                ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 8,
                  ),
                  GestureDetector(
                    onTap: () async {
                      var result = await formDialog(
                        context,
                        title: "Packing Charges",
                        sysmbol: packingChargeSys,
                        value: packingChargeInput.toString(),
                      );
                      if (result != null) {
                        setState(() {
                          packingChargeSys = result["sys"];
                          packingChargeInput = double.parse(result["value"]);
                        });
                      }
                      log("Packing Charges");
                    },
                    child: Container(
                      color: Colors.transparent,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Packing Charges - ${packingChargeSys.toUpperCase()} $packingChargeInput",
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                          const SizedBox(width: 5),
                          const Icon(
                            Icons.edit,
                            size: 15,
                          ),
                          const Spacer(),
                          Text(
                            "\u{20B9}${packingChareges()}",
                            style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                                  color: Colors.green.shade600,
                                ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 5,
                  ),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          side: BorderSide.none,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        elevation: 0,
                        backgroundColor: Theme.of(context).primaryColor,
                      ),
                      onPressed: cartDataList.isEmpty
                          ? null
                          : () {
                              if (widget.isEdit != null && widget.isEdit == true && widget.enquiryDocId != null) {
                                updateEnquiryApi();
                              } else if (widget.isEdit != null &&
                                  widget.isEdit == true &&
                                  widget.estimateDocId != null) {
                                updateEstimateApi();
                              } else {
                                orderApi();
                              }
                            },
                      // child: const Text("Checkout"),
                      child: const Text("Place to Order"),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sri_sakthivel_fireworks_pos/screen/mainapp/billing/billing_one.dart';
import 'package:sri_sakthivel_fireworks_pos/utlities/utlities.dart';
import 'package:sri_sakthivel_fireworks_pos/utlities/validation.dart';
import 'package:sri_sakthivel_fireworks_pos/utlities/varibales.dart';

import '../../../firebase/datamodel/datamodel.dart';
import '../../ui/commenwidget.dart';
import 'billing_two.dart';

class AddCustomProduct extends StatefulWidget {
  const AddCustomProduct({super.key});

  @override
  State<AddCustomProduct> createState() => _AddCustomProductState();
}

class _AddCustomProductState extends State<AddCustomProduct> {
  var addProductKey = GlobalKey<FormState>();
  TextEditingController productName = TextEditingController();
  TextEditingController price = TextEditingController();
  TextEditingController qnt = TextEditingController();
  String? discountLock = "yes";
  List<DropdownMenuItem<String>> discountLockList = const [
    DropdownMenuItem(
      value: "yes",
      child: Text("Yes"),
    ),
    DropdownMenuItem(
      value: "no",
      child: Text("No"),
    ),
  ];

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

  addCustomProduct() {
    try {
      if (addProductKey.currentState!.validate()) {
        log("is Worked 1");
        int categoryIndex = -1;
        categoryIndex = billingProductList.indexWhere(
          (element) => element.category!.tmpcatid == "",
        );

        if (categoryIndex == -1) {
          // Ctagory Data Listing
          BillingDataModel billing = BillingDataModel();

          var category = CategoryDataModel();
          category.categoryName = "";
          category.tmpcatid = "";

          billing.category = category;
          billing.products = [];

          billingProductList.add(billing);
        }

        // Product Data Listing
        var product = ProductDataModel();
        product.categoryid = "";
        product.categoryName = "";
        product.productId = productName.text;
        product.productName = productName.text;
        product.price = double.parse(price.text);
        product.qty = int.parse(qnt.text);
        product.qtyForm = TextEditingController(
          text: product.qty.toString(),
        );
        product.discountLock = discountLock != null
            ? discountLock == "yes"
                ? true
                : false
            : false;

        setState(() {
          log(billingProductList.length.toString());
          billingProductList[billingProductList.length - 1].products!.add(product);
          editaddtoCart(product);
          billPageProvider.toggletab(true);
          billPageProvider2.toggletab(true);
        });
        Navigator.pop(context);
        snackBarCustom(context, true, "Successfully added to Cart");
      } else {
        snackBarCustom(context, false, "Fill all the form");
      }
    } catch (e) {
      snackBarCustom(context, false, e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: SafeArea(
        child: Center(
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
            ),
            margin: EdgeInsets.only(
              left: 15,
              top: 15,
              right: 15,
              bottom: MediaQuery.of(context).viewInsets.bottom + 15,
            ),
            constraints: BoxConstraints(
              maxWidth: 600,
              maxHeight: MediaQuery.of(context).size.height * 0.8,
              // maxHeight: 300,
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Scaffold(
                resizeToAvoidBottomInset: false,
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
                  title: Text(
                    "Add Custom Product",
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                backgroundColor: Colors.white,
                // backgroundColor: const Color(0xffEEEEEE),
                body: ListView(
                  padding: const EdgeInsets.all(10),
                  children: [
                    Form(
                      key: addProductKey,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          InputForm(
                            controller: productName,
                            formName: "Product Name",
                            lableName: "Product Name",
                            keyboardType: TextInputType.text,
                            validation: (input) {
                              return FormValidation().commonValidation(
                                input: input,
                                isMandorty: true,
                                formName: "Product Name",
                                isOnlyCharter: false,
                              );
                            },
                          ),
                          InputForm(
                            controller: qnt,
                            formName: "QNT",
                            lableName: "QNT",
                            inputFormaters: [
                              FilteringTextInputFormatter.allow(
                                RegExp("[0-9]"),
                              ),
                              LengthLimitingTextInputFormatter(3),
                            ],
                            keyboardType: TextInputType.number,
                            validation: (input) {
                              if (input != null) {
                                if (input.isEmpty) {
                                  return "QNT is Must";
                                } else {
                                  return null;
                                }
                              } else {
                                return "QNT is Must";
                              }
                            },
                          ),
                          InputForm(
                            controller: price,
                            formName: "Price",
                            lableName: "Product Price",
                            keyboardType: TextInputType.number,
                          ),
                          DropDownForm(
                            onChange: (v) {
                              setState(() {
                                discountLock = v;
                              });
                            },
                            labelName: "Discount Lock",
                            value: discountLock,
                            listItems: discountLockList,
                            formName: 'Discount Lock',
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                bottomNavigationBar: BottomAppBar(
                  child: Container(
                    color: Colors.white,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          child: const Text(
                            "Cancel",
                            style: TextStyle(
                              color: Colors.red,
                            ),
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            addCustomProduct();
                          },
                          child: const Text("Add Product"),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

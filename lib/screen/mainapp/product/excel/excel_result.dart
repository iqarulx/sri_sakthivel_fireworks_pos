import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:sri_sakthivel_fireworks_pos/firebase/firestore_provider.dart';
import 'package:sri_sakthivel_fireworks_pos/screen/ui/commenwidget.dart';
import 'package:sri_sakthivel_fireworks_pos/utlities/utlities.dart';
import 'package:sri_sakthivel_fireworks_pos/utlities/varibales.dart';

import '../../../../firebase/datamodel/datamodel.dart';
import '../../../../utlities/provider/localdb.dart';

class ExcelResultUI extends StatefulWidget {
  const ExcelResultUI({super.key});

  @override
  State<ExcelResultUI> createState() => _ExcelResultUIState();
}

class _ExcelResultUIState extends State<ExcelResultUI> {
  totalProductCount() {
    int productcount = 0;
    for (var element in excelData) {
      productcount += element.product.length;
    }
    return productcount;
  }

  uploadExcel() async {
    loading(context);
    try {
      var cid = await LocalDbProvider().fetchInfo(type: LocalData.companyid);
      if (cid != null) {
        List<ProductDataModel> tmpProducts = [];
        setState(() {
          tmpProducts.clear();
        });
        for (var element in excelData) {
          for (var product in element.product) {
            var productsData = ProductDataModel();
            await FireStoreProvider()
                .excelGetCategory(
              categoryName: element.categoryname,
              cid: cid,
            )
                .then((value) {
              if (value!.isNotEmpty) {
                productsData.categoryid = value;
              }
            }).catchError((onError) {
              throw onError;
            });

            log(product.productname);
            productsData.active = true;
            productsData.categoryName = element.categoryname;
            productsData.companyId = cid; // getcompany id
            productsData.delete = false;
            productsData.discountLock = product.discountlock.toLowerCase() == "no" ? true : false;
            productsData.price = double.parse(product.price);
            productsData.productCode = product.productno;
            productsData.productContent = product.content;
            productsData.productName = product.productname;
            productsData.qrCode = product.qrcode;
            productsData.name = product.productname.replaceAll(' ', '').trim().toLowerCase();
            setState(() {
              tmpProducts.add(productsData);
            });
          }
        }
        for (var element in tmpProducts) {
          log(element.toMap().toString());
        }

        await FireStoreProvider().excelMultiProduct(productsData: tmpProducts, cid: cid).then((value) {
          if (value != null && value) {
            Navigator.pop(context);
            snackBarCustom(context, true, "Successfully Uploaded Products");
          } else {
            Navigator.pop(context);
            snackBarCustom(context, false, "Failed to Upload Products");
          }
        });
      }
    } catch (e) {
      Navigator.pop(context);
      snackBarCustom(context, false, e.toString());
    }
  }

  uploadCategoryProduct() async {
    loading(context);
    try {
      await LocalDbProvider().fetchInfo(type: LocalData.companyid).then((cid) async {
        if (cid != null) {
          await confirmationDialogNew(context, title: "Alert", message: "Do you want clear then upload product?")
              .then((productCondition) async {
            if (productCondition != null && productCondition) {
              log("All Product will be Deleted and create new Products");
              await FireStoreProvider().deleteAllProducts(cid: cid).then((productDeletedStatus) async {
                log(productDeletedStatus.toString());
                if (productDeletedStatus != null) {
                  await FireStoreProvider().deleteAllCategorys(cid: cid).then((categoryDeletedStatus) async {
                    log("All Category will be Deleted and create new Category");
                    log(categoryDeletedStatus.toString());
                    if (categoryDeletedStatus != null) {
                      List<CategoryDataModel> categoryList = [];
                      int count = 1;
                      for (var element in excelData) {
                        CategoryDataModel model = CategoryDataModel();
                        model.categoryName = element.categoryname;
                        model.name = element.categoryname.replaceAll(' ', '').toLowerCase().toString();
                        model.deleteAt = false;
                        model.postion = count;
                        model.cid = cid;
                        categoryList.add(model);
                        count += 1;
                      }
                      await FireStoreProvider()
                          .bulkCategoryCreateFn(categoryList: categoryList)
                          .then((bulkCategoryList) async {
                        if (bulkCategoryList != null) {
                          log("Category Creating");
                          await FireStoreProvider().categoryListing(cid: cid).then((categoryList) async {
                            log("Category Created");
                            if (categoryList != null) {
                              List<CategoryDataModel> liveCategoryList = [];
                              for (var category in categoryList.docs) {
                                log(category.id.toString());
                                log(category.data().toString());
                                CategoryDataModel model = CategoryDataModel();
                                model.categoryName = category["category_name"];
                                model.name = category["name"];
                                model.deleteAt = category["delete_at"];
                                model.postion = category["postion"];
                                model.cid = category["company_id"];
                                model.tmpcatid = category.id;
                                liveCategoryList.add(model);
                              }
                              var productServer = FirebaseFirestore.instance.collection('products');
                              var batch = FirebaseFirestore.instance.batch();

                              for (var categoryProducts in excelData) {
                                int count = 1;
                                for (var productElement in categoryProducts.product) {
                                  var productsData = ProductDataModel();
                                  var indexCategory = liveCategoryList.indexWhere((element) =>
                                      element.name ==
                                      categoryProducts.categoryname.replaceAll(' ', '').trim().toLowerCase());
                                  productsData.categoryid = liveCategoryList[indexCategory].tmpcatid;
                                  productsData.active = true;
                                  productsData.categoryName = categoryProducts.categoryname;
                                  productsData.companyId = cid; // getcompany id
                                  productsData.delete = false;
                                  productsData.discountLock =
                                      productElement.discountlock.toLowerCase() == "no" ? true : false;
                                  productsData.price = double.parse(productElement.price);
                                  productsData.productCode = productElement.productno;
                                  productsData.productContent = productElement.content;
                                  productsData.productName = productElement.productname;
                                  productsData.qrCode = productElement.qrcode;
                                  productsData.name =
                                      productElement.productname.replaceAll(' ', '').trim().toLowerCase();
                                  productsData.postion = count;
                                  productsData.createdDateTime = DateTime.now();
                                  DocumentReference document = productServer.doc();
                                  log(productsData.toMap().toString());
                                  batch.set(document, productsData.toMap());
                                  setState(() {
                                    count += 1;
                                  });
                                }
                              }
                              log("Product Creating");
                              await batch.commit().then((_) {
                                log("Product Created");
                                Navigator.pop(context);
                                Navigator.pop(context, true);
                                snackBarCustom(context, true, "Product Upload Successfully");
                              }).catchError((error) => throw ('Failed to execute batch write: $error'));
                            }
                          });
                        }
                      });
                    }
                  });
                }
              });
            } else if (productCondition != null && productCondition == false) {
              log("Product and Category Not Clear Product Only Update");
              Navigator.pop(context);
              checkAlreadyExcits();
            } else {
              Navigator.pop(context);
            }
          });
        }
      });
    } catch (e) {
      log(e.toString());
      Navigator.pop(context);
      snackBarCustom(context, false, e.toString());
    }
  }

  checkAlreadyExcits() async {
    try {
      loading(context);
      await LocalDbProvider().fetchInfo(type: LocalData.companyid).then((cid) async {
        if (cid != null) {
          List<CategoryDataModel> categoryDataList = [];
          List<ProductDataModel> productDataList = [];

          var categoryServer = FirebaseFirestore.instance.collection('category');
          var productServer = FirebaseFirestore.instance.collection('products');
          var batch = FirebaseFirestore.instance.batch();
          var batch2 = FirebaseFirestore.instance.batch();
          // Get Currenrt Category Data on Server
          await FireStoreProvider().categoryListing(cid: cid).then((categoryList) async {
            if (categoryList != null && categoryList.docs.isNotEmpty) {
              for (var element in categoryList.docs) {
                CategoryDataModel model = CategoryDataModel();
                model.categoryName = element["category_name"];
                model.name = element["name"];
                model.postion = element["postion"];
                model.tmpcatid = element.id;
                setState(() {
                  categoryDataList.add(model);
                });
              }
            }
          });
          // Get Current Product Data On Server
          await FireStoreProvider().productListing(cid: cid).then((productList) async {
            if (productList != null && productList.docs.isNotEmpty) {
              for (var element in productList.docs) {
                ProductDataModel model = ProductDataModel();
                model.categoryName = element["category_name"];
                model.categoryid = element["category_id"];
                model.docid = element.id;
                model.name = element["name"];
                model.productCode = element["product_code"];
                setState(() {
                  productDataList.add(model);
                });
              }
            }
          });
          // Upload Server On category

          int categoryCount = categoryDataList.length + 1;
          for (var categoryData in excelData) {
            var catName = categoryData.categoryname.replaceAll(' ', '').trim().toLowerCase();
            var catIndex = categoryDataList.indexWhere((element) => element.name == catName);
            if (catIndex > -1) {
              var documentID = categoryDataList[catIndex].tmpcatid;
              DocumentReference document = categoryServer.doc(documentID);
              Map<String, dynamic> data = {
                "category_name": categoryData.categoryname,
                "name": catName,
              };
              batch.update(document, data);
            } else {
              CategoryDataModel model = CategoryDataModel();
              model.categoryName = categoryData.categoryname;
              model.name = categoryData.categoryname.replaceAll(' ', '').toLowerCase().toString();
              model.deleteAt = false;
              model.postion = categoryCount;
              model.cid = cid;
              DocumentReference document = categoryServer.doc();
              batch.set(document, model.toMap());

              /// Insert New Category on Array
              CategoryDataModel catemodel = CategoryDataModel();
              model.categoryName = categoryData.categoryname;
              model.name = categoryData.categoryname.replaceAll(' ', '').toLowerCase().toString();
              model.postion = categoryCount;
              model.tmpcatid = document.id;
              setState(() {
                categoryDataList.add(catemodel);
              });
              setState(() {
                categoryCount += 1;
              });
            }
          }

          // // Now Again Get All Category List Data
          // await FireStoreProvider().categoryListing(cid: cid).then((categoryList) async {
          //   if (categoryList != null && categoryList.docs.isNotEmpty) {
          //     setState(() {
          //       categoryDataList.clear();
          //     });
          //     for (var element in categoryList.docs) {
          //       CategoryDataModel model = CategoryDataModel();
          //       model.categoryName = element["category_name"];
          //       model.name = element["name"];
          //       model.postion = element["postion"];
          //       model.tmpcatid = element.id;
          //       setState(() {
          //         categoryDataList.add(model);
          //       });
          //     }
          //   }
          // });

          for (var categoryProducts in excelData) {
            int count = categoryProducts.product.length + 1;
            for (var productElement in categoryProducts.product) {
              var productName = productElement.productname.replaceAll(' ', '').trim().toLowerCase();
              var productIndex = productDataList.indexWhere((element) => element.name == productName);
              if (productIndex > -1) {
                var documentID = productDataList[productIndex].docid;
                DocumentReference document = productServer.doc(documentID);
                Map<String, dynamic> data = {
                  "price": productElement.price,
                  "product_code": productElement.productno,
                  "product_content": productElement.content,
                  "product_name": productElement.productname,
                  "name": productName,
                };
                batch2.update(document, data);
              } else {
                var productsData = ProductDataModel();
                var indexCategory = categoryDataList.indexWhere((element) =>
                    element.name == categoryProducts.categoryname.replaceAll(' ', '').trim().toLowerCase());
                productsData.categoryid = categoryDataList[indexCategory].tmpcatid;
                productsData.active = true;
                productsData.categoryName = categoryProducts.categoryname;
                productsData.companyId = cid; // getcompany id
                productsData.delete = false;
                productsData.discountLock = productElement.discountlock.toLowerCase() == "no" ? true : false;
                productsData.price = double.parse(productElement.price);
                productsData.productCode = productElement.productno;
                productsData.productContent = productElement.content;
                productsData.productName = productElement.productname;
                productsData.qrCode = productElement.qrcode;
                productsData.name = productElement.productname.replaceAll(' ', '').trim().toLowerCase();
                productsData.postion = count;
                productsData.createdDateTime = DateTime.now();
                DocumentReference document = productServer.doc();
                log(productsData.toMap().toString());
                batch2.set(document, productsData.toMap());
                setState(() {
                  count += 1;
                });
              }
            }
          }

          // Upload on Product On Server
          await batch.commit().then((_) async {
            await batch2.commit().then((_) {
              log("Product Created");
              Navigator.pop(context);
              Navigator.pop(context, true);
              snackBarCustom(context, true, "Product Upload Successfully");
            }).catchError((error) => throw ('Failed to execute batch write: $error'));
          }).catchError((error) => throw ('Failed to execute batch write: $error'));
        }
      });
    } catch (e) {
      log(e.toString());
      Navigator.pop(context);
      snackBarCustom(context, false, e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(13),
        ),
        backgroundColor: Theme.of(context).primaryColor,
        onPressed: () {
          uploadCategoryProduct();
        },
        icon: const Icon(Icons.file_upload_outlined),
        label: const Text("Upload"),
      ),
      backgroundColor: Colors.transparent,
      body: Visibility(
        visible: excelData.isNotEmpty,
        child: ListView(
          padding: const EdgeInsets.all(10),
          children: [
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
              ),
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Report",
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Table(
                    border: TableBorder.all(
                      color: Colors.grey.shade100,
                    ),
                    columnWidths: const {
                      0: FlexColumnWidth(1.2),
                      1: FlexColumnWidth(5),
                      2: FlexColumnWidth(1.7),
                    },
                    children: [
                      TableRow(
                        decoration: BoxDecoration(
                          color: Theme.of(context).primaryColor,
                          borderRadius: BorderRadius.circular(3),
                        ),
                        children: const [
                          Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: 5,
                              vertical: 3,
                            ),
                            child: Center(
                              child: Text(
                                "S.NO",
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: 5,
                              vertical: 3,
                            ),
                            child: Center(
                              child: Text(
                                "Category Name",
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: 5,
                              vertical: 3,
                            ),
                            child: Center(
                              child: Text(
                                "Products",
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      for (int i = 0; i < excelData.length; i++)
                        TableRow(
                          decoration: BoxDecoration(
                            color: i.isOdd ? Colors.grey.shade300 : Colors.transparent,
                            borderRadius: BorderRadius.circular(3),
                          ),
                          children: [
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 5,
                                vertical: 3,
                              ),
                              child: Center(
                                child: Text(
                                  (i + 1).toString(),
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 5,
                                vertical: 3,
                              ),
                              child: Text(excelData[i].categoryname),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 5,
                                vertical: 3,
                              ),
                              child: Center(
                                child: Text(
                                  excelData[i].product.length.toString(),
                                ),
                              ),
                            ),
                          ],
                        ),
                      TableRow(
                        // decoration: BoxDecoration(
                        //   color: i.isOdd
                        //       ? Colors.grey.shade300
                        //       : Colors.transparent,
                        //   borderRadius: BorderRadius.circular(3),
                        // ),
                        children: [
                          const SizedBox(),
                          const Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: 5,
                              vertical: 3,
                            ),
                            child: Text(
                              "Total",
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 15,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 5,
                              vertical: 3,
                            ),
                            child: Center(
                              child: Text(
                                "${totalProductCount()}",
                                textAlign: TextAlign.end,
                                style: const TextStyle(
                                  color: Colors.black,
                                  fontSize: 15,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            for (var category in excelData)
              Container(
                margin: const EdgeInsets.only(bottom: 10),
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Theme.of(context).primaryColor.withOpacity(0.2),
                        ),
                        width: double.infinity,
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                " ${category.categoryname}",
                                style: const TextStyle(
                                  color: Colors.black,
                                  fontSize: 17,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const SizedBox(
                              width: 5,
                            ),
                            Text(
                              "Total : ${category.product.length}",
                              style: const TextStyle(
                                color: Colors.black,
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      for (int i = 0; i < category.product.length; i++)
                        Container(
                          decoration: BoxDecoration(
                            border: i > 0
                                ? const Border(
                                    top: BorderSide(
                                      width: 0.5,
                                      color: Color(0xffE0E0E0),
                                    ),
                                  )
                                : null,
                          ),
                          padding: const EdgeInsets.all(10),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      category.product[i].productname,
                                      style: const TextStyle(
                                        color: Colors.black,
                                        fontSize: 15,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(
                                      category.product[i].content,
                                      style: const TextStyle(
                                        color: Colors.black,
                                        fontSize: 15,
                                      ),
                                    ),
                                    const SizedBox(
                                      height: 3,
                                    ),
                                    Text(
                                      "Qr Code - ${category.product[i].qrcode}",
                                      style: const TextStyle(
                                        color: Colors.black,
                                        fontSize: 15,
                                      ),
                                    ),
                                    const SizedBox(
                                      height: 3,
                                    ),
                                    Text(
                                      "Discount Lock - ${category.product[i].discountlock == "1" ? "Yes" : "No"}",
                                      style: const TextStyle(
                                        color: Colors.black,
                                        fontSize: 15,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(
                                width: 10,
                              ),
                              Text(
                                "\u{20B9}${category.product[i].price}",
                                style: const TextStyle(
                                  color: Colors.black,
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(
                                width: 10,
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
              )
          ],
        ),
      ),
    );
  }
}

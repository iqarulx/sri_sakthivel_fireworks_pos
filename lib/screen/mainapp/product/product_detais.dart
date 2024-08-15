import 'dart:developer';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:sri_sakthivel_fireworks_pos/screen/ui/commenwidget.dart';
import 'package:sri_sakthivel_fireworks_pos/utlities/validation.dart';

import '../../../firebase/datamodel/datamodel.dart';
import '../../../firebase/firestorageprovider.dart';
import '../../../firebase/firestore_provider.dart';
import '../../../provider/imagepickerprovider.dart';
import '../../../utlities/provider/localdb.dart';
import '../../../utlities/utlities.dart';

class ProductDetails extends StatefulWidget {
  const ProductDetails({
    super.key,
    required this.title,
    required this.edit,
    this.productData,
  });
  final ProductDataModel? productData;
  final String title;
  final bool edit;

  @override
  State<ProductDetails> createState() => _ProductDetailsState();
}

class _ProductDetailsState extends State<ProductDetails> {
  TextEditingController categoryName = TextEditingController();
  TextEditingController productName = TextEditingController();
  TextEditingController productCode = TextEditingController();
  TextEditingController productContent = TextEditingController();
  TextEditingController qrCode = TextEditingController();
  TextEditingController price = TextEditingController();
  TextEditingController videoUrl = TextEditingController();

  String? categoryID;
  List<DropdownMenuItem<String>> categoryList = [];
  File? productImage;
  String? imageUrl;
  bool discountLock = false;
  bool active = true;

  Future getCategory() async {
    await LocalDbProvider().fetchInfo(type: LocalData.companyid).then((cid) async {
      await FireStoreProvider().categoryListing(cid: cid).then((value) {
        if (value!.docs.isNotEmpty) {
          setState(() {
            categoryList.clear();
          });
          for (var element in value.docs) {
            setState(() {
              categoryList.add(
                DropdownMenuItem(
                  value: element.id.toString(),
                  child: Text(element["category_name"].toString()),
                ),
              );
            });
          }
        }
      });
    });
  }

  var addProductKey = GlobalKey<FormState>();

  inifunc() {
    if (widget.edit) {
      setState(() {
        categoryID = widget.productData!.categoryid ?? "";
        categoryName.text = widget.productData!.categoryName ?? "";
        productName.text = widget.productData!.productName ?? "";
        productCode.text = widget.productData!.productCode ?? "";
        productContent.text = widget.productData!.productContent ?? "";
        qrCode.text = widget.productData!.qrCode ?? "";
        price.text = widget.productData!.price == null ? "" : widget.productData!.price.toString();
        videoUrl.text = widget.productData!.videoUrl ?? "";
        imageUrl = widget.productData!.productImg ?? "";
        discountLock = widget.productData!.discountLock ?? false;
        active = widget.productData!.active ?? false;
      });
    }
  }

  deleteProduct() async {
    await confirmationDialog(
      context,
      title: "Alert",
      message: "Do you want Delete this product?",
    ).then((result) async {
      if (result != null && result == true) {
        loading(context);
        try {
          await FireStoreProvider().deleteProduct(docId: widget.productData!.productId!).then((value) {
            Navigator.pop(context);
            Navigator.pop(context);
            snackBarCustom(context, true, "Product Delete Successfully");
          });
        } catch (e) {
          Navigator.pop(context);
          snackBarCustom(context, false, e.toString());
        }
      }
    });
  }

  updateProduct() async {
    loading(context);
    FocusManager.instance.primaryFocus!.unfocus();
    try {
      if (addProductKey.currentState!.validate()) {
        await LocalDbProvider().fetchInfo(type: LocalData.companyid).then((cid) async {
          if (cid != null) {
            var productData = ProductDataModel();
            productData.companyId = cid;
            productData.active = active;
            productData.categoryid = categoryID;
            productData.discountLock = discountLock; // Change Discount Lock
            productData.price = double.parse(price.text);
            productData.productCode = productCode.text;
            productData.productContent = productContent.text;
            productData.productName = productName.text;
            productData.qrCode = qrCode.text;
            productData.videoUrl = videoUrl.text;
            productData.name = productName.text.replaceAll(' ', '').trim().toLowerCase();
            log(productData.updateMap().toString());
            await FireStoreProvider()
                .updateProduct(docid: widget.productData!.productId!, product: productData)
                .then((value) async {
              if (productImage != null) {
                var downloadLink = await FireStorageProvider().uploadImage(
                  fileData: productImage!,
                  fileName: DateTime.now().millisecondsSinceEpoch.toString(),
                  filePath: 'products',
                );
                await FireStoreProvider()
                    .updateProductPic(
                  docId: widget.productData!.productId!,
                  imageLink: downloadLink.toString(),
                )
                    .then((value) {
                  Navigator.pop(context);
                  Navigator.pop(context, true);
                  snackBarCustom(context, true, "Product Update Successfully");
                });
              } else {
                Navigator.pop(context);
                Navigator.pop(context, true);
                snackBarCustom(context, true, "Product Update Successfully");
              }
            });
          } else {
            Navigator.pop(context);
            snackBarCustom(context, false, "Something went Wrong");
          }
        });
      }
    } catch (e) {
      Navigator.pop(context);
      snackBarCustom(context, false, e.toString());
    }
  }

  checkValidation() async {
    loading(context);
    FocusManager.instance.primaryFocus!.unfocus();
    try {
      if (addProductKey.currentState!.validate()) {
        await LocalDbProvider().fetchInfo(type: LocalData.companyid).then((cid) async {
          if (cid != null) {
            var productData = ProductDataModel();
            productData.companyId = cid;
            productData.active = active;
            productData.categoryid = categoryID;
            productData.delete = false;
            productData.discountLock = true; // Change Discount Lock
            productData.price = double.parse(price.text);
            productData.productCode = productCode.text;
            productData.productContent = productContent.text;
            productData.productImg = null;
            productData.productName = productName.text;
            productData.qrCode = qrCode.text;
            productData.videoUrl = videoUrl.text;
            productData.name = productName.text.replaceAll(' ', '').trim().toLowerCase();
            productData.createdDateTime = DateTime.now();

            if (productImage != null) {
              var downloadLink = await FireStorageProvider().uploadImage(
                fileData: productImage!,
                fileName: DateTime.now().millisecondsSinceEpoch.toString(),
                filePath: 'products',
              );
              productData.productImg = downloadLink;
            }

            log(productData.toMap().toString());
            await FireStoreProvider().registerProduct(productsData: productData).then((value) {
              Navigator.pop(context);
              if (value.id.isNotEmpty) {
                setState(() {
                  categoryID = null;
                  productName.clear();
                  productCode.clear();
                  productContent.clear();
                  qrCode.clear();
                  price.clear();
                  videoUrl.clear();
                  productImage = null;
                });
                Navigator.pop(context, true);
                snackBarCustom(
                  context,
                  true,
                  "Successfully Created New Product",
                );
              } else {
                snackBarCustom(context, false, "Failed to Create New Product");
              }
            });
          } else {
            Navigator.pop(context);
            snackBarCustom(context, false, "Company Details Not Fetch");
          }
        });
      } else {
        Navigator.pop(context);
      }
    } catch (e) {
      Navigator.pop(context);
      snackBarCustom(context, false, e.toString());
    }
  }

  @override
  void initState() {
    super.initState();
    getCategory();
    inifunc();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffEEEEEE),
      appBar: AppBar(
        title: Text(widget.title),
        actions: [
          widget.edit
              ? IconButton(
                  onPressed: () {
                    deleteProduct();
                  },
                  icon: const Icon(Icons.delete),
                )
              : const SizedBox(),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(10),
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Form(
              key: addProductKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: GestureDetector(
                      onTap: () async {
                        var imageResult = await FilePickerProvider().showFileDialog(context);
                        if (imageResult != null) {
                          setState(() {
                            productImage = imageResult;
                          });
                        }
                      },
                      child: Container(
                        height: 120,
                        width: 120,
                        decoration: const BoxDecoration(
                          color: Colors.transparent,
                          shape: BoxShape.circle,
                        ),
                        child: Stack(
                          children: [
                            Container(
                              width: double.infinity,
                              height: double.infinity,
                              decoration: BoxDecoration(
                                color: Colors.grey.shade300,
                                shape: BoxShape.circle,
                                image: productImage != null
                                    ? DecorationImage(
                                        image: FileImage(productImage!),
                                        fit: BoxFit.cover,
                                      )
                                    : imageUrl != null && imageUrl!.isNotEmpty
                                        ? DecorationImage(
                                            image: NetworkImage(imageUrl!),
                                            fit: BoxFit.cover,
                                          )
                                        : null,
                              ),
                            ),
                            Align(
                              alignment: Alignment.bottomRight,
                              child: Container(
                                decoration: BoxDecoration(
                                  border: Border.all(width: 2, color: Colors.white),
                                  color: Colors.yellow.shade800,
                                  shape: BoxShape.circle,
                                ),
                                padding: const EdgeInsets.all(5),
                                child: const Icon(
                                  Icons.edit,
                                  color: Colors.white,
                                  size: 18,
                                ),
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  DropDownForm(
                    onChange: (v) {
                      setState(() {
                        categoryID = v;
                        log(categoryID.toString());
                      });
                    },
                    labelName: "Category",
                    value: categoryID,
                    listItems: categoryList,
                    formName: 'Category',
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  InputForm(
                    controller: productName,
                    formName: "Product Name",
                    lableName: "Product Name",
                    validation: (input) {
                      return FormValidation().commonValidation(
                        input: input,
                        isMandorty: true,
                        formName: 'Product Name',
                        isOnlyCharter: false,
                      );
                    },
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: InputForm(
                          controller: productCode,
                          formName: "Product Code",
                          lableName: "Product Code",
                          validation: (input) {
                            return FormValidation().commonValidation(
                              input: input,
                              isMandorty: true,
                              formName: 'Product Code',
                              isOnlyCharter: false,
                            );
                          },
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: InputForm(
                          controller: productContent,
                          formName: "Product Content",
                          lableName: "Product Content",
                          validation: (input) {
                            return FormValidation().commonValidation(
                              input: input,
                              isMandorty: true,
                              formName: 'Product Content',
                              isOnlyCharter: false,
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: InputForm(
                          controller: qrCode,
                          formName: "QR Code",
                          lableName: "QR Code",
                          validation: (input) {
                            return FormValidation().commonValidation(
                              input: input,
                              isMandorty: false,
                              formName: 'QR Code',
                              isOnlyCharter: false,
                            );
                          },
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: InputForm(
                          controller: price,
                          formName: "Price",
                          lableName: "Price",
                          keyboardType: TextInputType.number,
                          validation: (input) {
                            return FormValidation().commonValidation(
                              input: input,
                              isMandorty: true,
                              formName: 'Price',
                              isOnlyCharter: false,
                            );
                          },
                        ),
                      ),
                    ],
                  ),

                  InputForm(
                    controller: videoUrl,
                    formName: "Video Url",
                    lableName: "Video Url",
                    validation: (input) {
                      return FormValidation().commonValidation(
                        input: input,
                        isMandorty: false,
                        formName: 'Video Url',
                        isOnlyCharter: false,
                      );
                    },
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              "Discount Lock",
                              style: Theme.of(context).textTheme.bodyLarge,
                            ),
                            CupertinoSwitch(
                              value: discountLock,
                              onChanged: (onChanged) {
                                setState(() {
                                  discountLock = onChanged;
                                });
                              },
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              "Active",
                              style: Theme.of(context).textTheme.bodyLarge,
                            ),
                            CupertinoSwitch(
                              value: active,
                              onChanged: (onChanged) {
                                setState(() {
                                  active = onChanged;
                                });
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  // DropDownForm(
                  //   onChange: (value) {
                  //     setState(() {
                  //       discountLock = value;
                  //     });
                  //   },
                  //   labelName: "Discount Lock",
                  //   value: discountLock,
                  //   listItems: const [
                  //     DropdownMenuItem(
                  //       value: "true",
                  //       child: Text("Yes"),
                  //     ),
                  //     DropdownMenuItem(
                  //       value: "false",
                  //       child: Text("No"),
                  //     ),
                  //   ],
                  // ),
                  const SizedBox(
                    height: 10,
                  ),

                  // DropDownForm(
                  //   onChange: (value) {
                  //     setState(() {
                  //       active = value;
                  //     });
                  //   },
                  //   labelName: "Active",
                  //   value: active,
                  //   listItems: const [
                  //     DropdownMenuItem(
                  //       value: "true",
                  //       child: Text("Yes"),
                  //     ),
                  //     DropdownMenuItem(
                  //       value: "false",
                  //       child: Text("No"),
                  //     ),
                  //   ],
                  // ),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: BottomAppBar(
          height: 65,
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: Row(
              children: [
                Expanded(
                  flex: 2,
                  child: outlinButton(
                    context,
                    onTap: () {
                      Navigator.pop(context);
                    },
                    btnName: "Cancel",
                  ),
                ),
                const SizedBox(
                  width: 10,
                ),
                Expanded(
                  flex: 4,
                  child: fillButton(
                    context,
                    onTap: () {
                      if (widget.edit) {
                        updateProduct();
                      } else {
                        checkValidation();
                      }
                    },
                    btnName: "Submit",
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

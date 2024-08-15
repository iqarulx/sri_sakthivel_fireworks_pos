import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sri_sakthivel_fireworks_pos/utlities/utlities.dart';

import '../../../firebase/datamodel/datamodel.dart';
import '../../../firebase/firestore_provider.dart';

class CategoryDiscountDetailsView extends StatefulWidget {
  final int? discount;
  final List<CategoryDataModel> categoryList;
  const CategoryDiscountDetailsView({
    super.key,
    required this.categoryList,
    this.discount,
  });

  @override
  State<CategoryDiscountDetailsView> createState() => _CategoryDiscountDetailsViewState();
}

class _CategoryDiscountDetailsViewState extends State<CategoryDiscountDetailsView> {
  TextEditingController discount = TextEditingController();
  List<CategoryDataModel> uploadCategory = [];

  addDiscount() async {
    try {
      loading(context);
      if (discount.text.isNotEmpty) {
        int count = 0;
        for (var element in widget.categoryList) {
          if (widget.discount != null) {
            if (widget.discount == element.discount) {
              if (element.discountEnable == false) {
                element.discount = null;
                uploadCategory.add(element);
                count += 1;
              } else {
                element.discount = int.parse(discount.text);
                uploadCategory.add(element);
                count += 1;
              }
            } else if (element.discount == null && element.discountEnable == true) {
              element.discount = int.parse(discount.text);
              uploadCategory.add(element);
              count += 1;
            }
          } else if (element.discountEnable == true && element.discount == null) {
            element.discount = int.parse(discount.text);
            uploadCategory.add(element);
            count += 1;
          }
        }
        if (count > 0) {
          await FireStoreProvider().categoryDiscountCreate(uploadCategory: uploadCategory).then((value) {
            Navigator.pop(context);
            Navigator.pop(context, true);
          });
        } else {
          Navigator.pop(context);
          snackBarCustom(context, false, "Please Choose Category");
        }
      } else {
        Navigator.pop(context);
        snackBarCustom(context, false, "Discount is Must");
      }
    } catch (e) {
      log(e.toString());
      Navigator.pop(context);
      snackBarCustom(context, false, e.toString());
    }
  }

  @override
  void initState() {
    if (widget.discount != null) {
      discount.text = widget.discount.toString();
    }
    super.initState();
  }

  @override
  void dispose() {
    for (var element in widget.categoryList) {
      if (element.discountEnable == true && element.discount == null) {
        element.discountEnable = false;
      }
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffEEEEEE),
      appBar: AppBar(
        title: const Text('Discount'),
      ),
      bottomNavigationBar: BottomAppBar(
        child: GestureDetector(
          onTap: () {
            addDiscount();
          },
          child: Container(
            height: 50,
            margin: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor,
              borderRadius: BorderRadius.circular(5),
            ),
            child: Center(
              child: Text(
                "Submit",
                style: Theme.of(context).textTheme.bodyLarge!.copyWith(color: Colors.white),
              ),
            ),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.only(top: 10, left: 10, right: 10),
        child: Column(
          children: [
            Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: Colors.white,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextFormField(
                    controller: discount,
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                    ],
                    decoration: const InputDecoration(
                      hintText: "Discount",
                      prefixIcon: Icon(Icons.percent, size: 18),
                    ),
                    onChanged: (value) {
                      if (value.isNotEmpty && int.parse(value) > 100) {
                        discount.clear();
                      }
                    },
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView.builder(
                shrinkWrap: true,
                primary: false,
                itemCount: widget.categoryList.length,
                itemBuilder: (context, index) {
                  var category = widget.categoryList[index];
                  if (category.discount == null || widget.discount != null) {
                    if (widget.discount == category.discount || category.discount == null) {
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            category.discountEnable = !category.discountEnable!;
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(5),
                            color: Colors.white,
                          ),
                          // padding: const EdgeInsets.all(10),
                          margin: const EdgeInsets.only(bottom: 10),
                          // decoration: BoxDecoration(
                          //   color: Colors.transparent,
                          //   borderRadius: BorderRadius.circular(5),
                          //   border: Border.all(
                          //     width: 1,
                          //     color: Colors.grey.shade300,
                          //   ),
                          // ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(category.categoryName ?? ""),
                              ),
                              CupertinoSwitch(
                                value: category.discountEnable ?? false,
                                onChanged: (onChanged) {
                                  setState(() {
                                    category.discountEnable = onChanged;
                                  });
                                },
                              ),
                            ],
                          ),
                        ),
                      );
                    } else {
                      return const SizedBox();
                    }
                  } else {
                    return const SizedBox();
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

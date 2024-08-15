import 'package:flutter/material.dart';

import '../../../firebase/datamodel/datamodel.dart';
import '../../../firebase/firestore_provider.dart';
import '../../../utlities/provider/localdb.dart';
import '../../../utlities/utlities.dart';
import '../../ui/commenwidget.dart';
import '../homelanding.dart';
import 'category_discount_details_view.dart';

class CategoryDiscountView extends StatefulWidget {
  const CategoryDiscountView({super.key});

  @override
  State<CategoryDiscountView> createState() => _CategoryDiscountViewState();
}

class _CategoryDiscountViewState extends State<CategoryDiscountView> {
  List<CategoryDataModel> categoryList = [];
  List<CategoryDiscountModel> discountCategoryList = [];

  getCategory() async {
    try {
      setState(() {
        categoryList.clear();
        discountCategoryList.clear();
      });
      var cid = await LocalDbProvider().fetchInfo(type: LocalData.companyid);
      if (cid != null) {
        FireStoreProvider provider = FireStoreProvider();
        final result = await provider.categoryListing(cid: cid);
        if (result!.docs.isNotEmpty) {
          setState(() {
            categoryList.clear();
          });
          for (var element in result.docs) {
            CategoryDataModel model = CategoryDataModel();
            model.categoryName = element["category_name"].toString();
            model.postion = element["postion"];
            model.tmpcatid = element.id;
            model.discount = element["discount"];
            model.discountEnable = element["discount"] != null ? true : false;
            setState(() {
              categoryList.add(model);
            });
          }
          for (var categoryElement in categoryList) {
            if (categoryElement.discount != null) {
              int index = discountCategoryList.indexWhere(
                (element) => element.discountValue == categoryElement.discount,
              );

              if (index == -1) {
                CategoryDiscountModel value = CategoryDiscountModel();
                value.categoryName = categoryElement.categoryName ?? "";
                value.discountValue = categoryElement.discount;
                discountCategoryList.add(value);
              } else {
                discountCategoryList[index].categoryName =
                    "${discountCategoryList[index].categoryName}, ${categoryElement.categoryName}";
              }
            }
          }
          return categoryList;
        }
      }
      return null;
    } catch (e) {
      snackBarCustom(context, false, e.toString());
      return null;
    }
  }

  Future? getDiscountHandler;

  @override
  void initState() {
    getDiscountHandler = getCategory();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffEEEEEE),
      appBar: AppBar(
        leading: IconButton(
          splashRadius: 20,
          onPressed: () {
            homeKey.currentState!.openDrawer();
          },
          icon: const Icon(Icons.menu),
        ),
        title: const Text("Discount"),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => CategoryDiscountDetailsView(categoryList: categoryList),
                ),
              ).then((value) {
                if (value != null && value) {
                  setState(() {
                    getDiscountHandler = getCategory();
                  });
                }
              });
            },
            icon: const Icon(Icons.add),
            splashRadius: 20,
          ),
        ],
      ),
      body: FutureBuilder(
        future: getDiscountHandler,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done && snapshot.data != null) {
            return RefreshIndicator(
              onRefresh: () async {
                setState(() {
                  getDiscountHandler = getCategory();
                });
              },
              child: ListView.builder(
                padding: const EdgeInsets.all(10),
                itemCount: discountCategoryList.length,
                itemBuilder: (context, index) {
                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => CategoryDiscountDetailsView(
                            categoryList: categoryList,
                            discount: discountCategoryList[index].discountValue,
                          ),
                        ),
                      ).then((value) {
                        if (value != null && value) {
                          setState(() {
                            getDiscountHandler = getCategory();
                          });
                        }
                      });
                    },
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 15),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "${discountCategoryList[index].discountValue}%",
                                  style: Theme.of(context).textTheme.titleMedium,
                                ),
                                const SizedBox(height: 5),
                                Text(
                                  "Category: ${discountCategoryList[index].categoryName}",
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: Theme.of(context).textTheme.bodySmall!.copyWith(color: Colors.grey),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 10),
                          const Icon(Icons.keyboard_arrow_right),
                        ],
                      ),
                    ),
                  );
                },
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

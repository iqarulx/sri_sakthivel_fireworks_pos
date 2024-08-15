import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:sri_sakthivel_fireworks_pos/screen/mainapp/category/product_listing_category.dart';
import 'package:sri_sakthivel_fireworks_pos/screen/ui/commenwidget.dart';

import '../../../firebase/datamodel/datamodel.dart';
import '../../../firebase/firestore_provider.dart';
import '../../../utlities/provider/localdb.dart';
import '../../../utlities/utlities.dart';
import '../homelanding.dart';

class CategoryListing extends StatefulWidget {
  const CategoryListing({super.key});

  @override
  State<CategoryListing> createState() => _CategoryListingState();
}

class _CategoryListingState extends State<CategoryListing> {
  List<CategoryDataModel> categoryList = [];
  List<CategoryDataModel> tmpCategoryList = [];
  TextEditingController searchForm = TextEditingController();

  Future getCategoryInfo() async {
    try {
      var cid = await LocalDbProvider().fetchInfo(type: LocalData.companyid);
      if (cid != null) {
        FireStoreProvider provider = FireStoreProvider();
        final result = await provider.categoryListing(cid: cid);
        if (result!.docs.isNotEmpty) {
          log("testing1");
          log(result.docs.length.toString());
          setState(() {
            categoryList.clear();
          });
          for (var element in result.docs) {
            log("Worked ${element.data()} ");
            CategoryDataModel model = CategoryDataModel();
            model.categoryName = element["category_name"].toString();
            model.postion = element["postion"];
            model.tmpcatid = element.id;
            setState(() {
              categoryList.add(model);
            });
          }
          setState(() {
            tmpCategoryList.addAll(categoryList);
          });
          return categoryList;
        }
      }
      return null;
    } catch (e) {
      snackBarCustom(context, false, e.toString());
      return null;
    }
  }

  // Future rearrangecatvalid({
  //   required int newIndex,
  //   required int oldIndex,
  //   required String categoryid,
  // }) async {
  //   loading(context);
  //   try {
  //     await LocalDbProvider()
  //         .fetchInfo(type: LocalData.companyid)
  //         .then((cid) async {
  //       if (cid != null) {
  //         log("NewIndex - $newIndex OldIndex - $oldIndex");
  //         if (newIndex > oldIndex) {
  //           await FireStoreProvider()
  //               .getcategoryLimit(
  //             startPostion: oldIndex,
  //             endPostion: newIndex,
  //             cid: cid,
  //           )
  //               .then((value) {
  //             Navigator.pop(context);
  //             log("is Worked");
  //             if (value != null && value.docs.isNotEmpty) {
  //               for (var element in value.docs) {
  //                 log(element.data().toString());
  //               }
  //             }
  //           });
  //         } else {
  //           log("is Lessthen");
  //           await FireStoreProvider()
  //               .getcategoryLimit(
  //             startPostion: newIndex,
  //             endPostion: oldIndex,
  //             cid: cid,
  //           )
  //               .then((value) {
  //             Navigator.pop(context);
  //             log("is Worked");
  //             if (value != null && value.docs.isNotEmpty) {
  //               for (var element in value.docs) {
  //                 log(element.data().toString());
  //               }
  //             }
  //           });
  //         }
  //       }
  //     });

  //     // await FireStoreProvider().
  //   } catch (e) {
  //     Navigator.pop(context);
  //     snackBarCustom(context, false, e.toString());
  //   }
  // }

  Future rearrangecatvalid({
    required int newIndex,
    required String categoryid,
  }) async {
    loading(context);
    try {
      await LocalDbProvider().fetchInfo(type: LocalData.companyid).then((cid) async {
        if (cid != null) {
          var category = FirebaseFirestore.instance.collection('category');
          var batch = FirebaseFirestore.instance.batch();
          log("Category ID $categoryid");
          await FireStoreProvider().getCategoryPostion(docID: categoryid).then((categoryInfo) async {
            if (categoryInfo != null && categoryInfo.exists) {
              int startPostion = 0;
              int endPostion = 0;
              if (newIndex > categoryInfo["postion"]) {
                setState(() {
                  startPostion = categoryInfo["postion"] + 1;
                  endPostion = newIndex;
                });
                await FireStoreProvider()
                    .getcategoryLimit(
                  startPostion: startPostion,
                  endPostion: endPostion,
                  cid: cid,
                )
                    .then((changeCategory) async {
                  if (changeCategory != null && changeCategory.docs.isNotEmpty) {
                    for (var element in changeCategory.docs) {
                      log("less");
                      log(element.data().toString());
                      DocumentReference document = category.doc(element.id);
                      batch.update(document, {
                        "postion": element["postion"] - 1,
                      });
                    }
                    await batch.commit().catchError((error) => throw ('Failed to execute batch write: $error'));
                  }
                });
              } else {
                setState(() {
                  startPostion = newIndex;
                  endPostion = categoryInfo["postion"] - 1;
                });
                await FireStoreProvider()
                    .getcategoryLimit(
                  startPostion: startPostion,
                  endPostion: endPostion,
                  cid: cid,
                )
                    .then((changeCategory) async {
                  if (changeCategory != null && changeCategory.docs.isNotEmpty) {
                    for (var element in changeCategory.docs) {
                      log("Add");
                      log(element.data().toString());
                      DocumentReference document = category.doc(element.id);
                      batch.update(document, {
                        "postion": element["postion"] + 1,
                      });
                      // await FireStoreProvider().updatePostion(
                      //   docId: element.id,
                      //   postionValue: element["postion"] + 1,
                      // );
                    }
                    await batch.commit().catchError((error) => throw ('Failed to execute batch write: $error'));
                  }
                });
              }

              await FireStoreProvider()
                  .updatePostion(
                docId: categoryid,
                postionValue: newIndex,
              )
                  .then((value) {
                Navigator.pop(context);
                snackBarCustom(context, true, "Successfully Updated");
              });
            } else {
              log("Category Id Not Found");
              Navigator.pop(context);
            }
          });
        }
      });

      // await FireStoreProvider().
    } catch (e) {
      log(e.toString());
      Navigator.pop(context);
      snackBarCustom(context, false, e.toString());
    }
  }

  searchCategoryFun(String? value) async {
    if (value != null && searchForm.text.isNotEmpty) {
      if (value.isNotEmpty) {
        log("Workeding");
        Iterable<CategoryDataModel> tmpList = tmpCategoryList.where((element) {
          return element.categoryName!
              .toLowerCase()
              .replaceAll(' ', '')
              .startsWith(value.toLowerCase().replaceAll(' ', ''));
        });
        log("is Working");
        if (tmpList.isNotEmpty) {
          setState(() {
            categoryList.clear();
          });
          for (var element in tmpList) {
            setState(() {
              categoryList.add(element);
            });
          }
        }
      }
    } else {
      setState(() {
        categoryList.clear();
        categoryList.addAll(tmpCategoryList);
      });
    }
  }

  late Future categoryHandler;

  @override
  void initState() {
    super.initState();
    categoryHandler = getCategoryInfo();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          splashRadius: 20,
          onPressed: () {
            homeKey.currentState!.openDrawer();
          },
          icon: const Icon(Icons.menu),
        ),
        title: const Text("Category"),
        actions: [
          IconButton(
            onPressed: () {
              addCategoryForm(context, isedit: false);

              // Navigator.push(
              //   context,
              //   CupertinoPageRoute(
              //     builder: (context) => const AddCustomer(),
              //   ),
              // );
            },
            splashRadius: 20,
            icon: const Icon(
              Icons.add,
            ),
          ),
        ],
      ),
      backgroundColor: const Color(0xffEEEEEE),
      body: FutureBuilder(
        future: categoryHandler,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return Padding(
              padding: const EdgeInsets.all(10),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Form(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            InputForm(
                              controller: searchForm,
                              formName: "Search",
                              prefixIcon: Icons.search,
                              onChanged: (value) {
                                searchCategoryFun(value);
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                    Expanded(
                      child: RefreshIndicator(
                        onRefresh: () async {
                          setState(() {
                            categoryHandler = getCategoryInfo();
                          });
                        },
                        child: ReorderableListView.builder(
                          buildDefaultDragHandles: false,
                          onReorder: (oldIndex, newIndex) {
                            setState(() {
                              if (searchForm.text.isEmpty) {
                                final index = newIndex > oldIndex ? newIndex - 1 : newIndex;
                                var cargory = categoryList.removeAt(oldIndex);
                                categoryList.insert(
                                  index,
                                  cargory,
                                );
                                rearrangecatvalid(
                                  newIndex: index + 1,
                                  categoryid: categoryList[index].tmpcatid!,
                                );
                              }
                            });
                          },
                          itemCount: categoryList.length,
                          itemBuilder: (context, index) {
                            return GestureDetector(
                              key: ValueKey(index),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  CupertinoPageRoute(
                                    builder: (context) => ProductListingCategory(
                                      categoryID: categoryList[index].tmpcatid!,
                                      categoryName: categoryList[index].categoryName!,
                                    ),
                                  ),
                                );
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 15,
                                  horizontal: 10,
                                ),
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  border: index > 0
                                      ? const Border(
                                          top: BorderSide(
                                            width: 0.5,
                                            color: Color(0xffE0E0E0),
                                          ),
                                        )
                                      : null,
                                ),
                                child: Row(
                                  children: [
                                    ReorderableDragStartListener(
                                      enabled: searchForm.text.isEmpty ? true : false,
                                      index: index,
                                      child: const Icon(
                                        Icons.drag_handle,
                                      ),
                                    ),
                                    const SizedBox(
                                      width: 10,
                                    ),
                                    Expanded(
                                      child: Text(
                                        categoryList[index].categoryName.toString(),
                                      ),
                                    ),
                                    GestureDetector(
                                      onTap: () async {
                                        await addCategoryForm(
                                          context,
                                          isedit: true,
                                          categoryName: categoryList[index].categoryName,
                                          docID: categoryList[index].tmpcatid,
                                        ).then((value) {
                                          if (value != null && value == true) {
                                            setState(() {
                                              categoryHandler = getCategoryInfo();
                                            });
                                          }
                                        });
                                        // Navigator.push(
                                        //   context,
                                        //   MaterialPageRoute(
                                        //     builder: (context) =>
                                        //         AddCategory(
                                        //       category: CategoryClass(
                                        //         categoryid:
                                        //             categorylist[index]
                                        //                 .categoryid,
                                        //         name: categorylist[index]
                                        //             .name,
                                        //         productList: [],
                                        //       ),
                                        //     ),
                                        //   ),
                                        // ).then((value) {
                                        //   setState(() {
                                        //     getcategorydata =
                                        //         getcategorydatafun("");
                                        //   });
                                        // });
                                      },
                                      child: Container(
                                        color: Colors.transparent,
                                        padding: const EdgeInsets.all(10),
                                        child: const Center(
                                          child: Icon(
                                            Icons.edit,
                                            size: 18,
                                            color: Color(0xff6B6B6B),
                                          ),
                                        ),
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.all(10),
                                      child: const Center(
                                        child: Icon(
                                          Icons.arrow_forward_ios,
                                          size: 18,
                                          color: Color(0xff6B6B6B),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
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
                            categoryHandler = getCategoryInfo();
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

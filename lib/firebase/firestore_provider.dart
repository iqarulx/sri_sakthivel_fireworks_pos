import 'dart:async';
import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:sri_sakthivel_fireworks_pos/firebase/datamodel/invoice_model.dart';
import 'package:sri_sakthivel_fireworks_pos/utlities/utlities.dart';

import 'datamodel/datamodel.dart';

final _instances = FirebaseFirestore.instance;

class FireStoreProvider {
  final _profile = _instances.collection('profile');
  final _admin = _instances.collection('users');
  final _staff = _instances.collection('staff');
  final _customer = _instances.collection('customer');
  final _products = _instances.collection('products');
  final _category = _instances.collection('category');
  final _enquiry = _instances.collection('enquiry');
  final _estimate = _instances.collection('estimate');
  final _invoice = _instances.collection('invoice');
  final _invoiceSettings = _instances.collection('invoice_settings');

  Future<String?> registerCompany(context,
      {required ProfileModel profileInfo}) async {
    try {
      return await _profile
          .add(profileInfo.initRegisterCompany())
          .then((value) {
        return value.id;
      });
    } catch (e) {
      snackBarCustom(context, false, e.toString());
      return null;
    }
  }

  Future<String?> initiCompanyaUpdate(context,
      {required ProfileModel profileInfo}) async {
    try {
      return await _profile.add(profileInfo.newRegisterCompany()).then((value) {
        return value.id;
      });
    } catch (e) {
      snackBarCustom(context, false, e.toString());
      return null;
    }
  }

  Future<QuerySnapshot?> getCompanyInfo({required String uid}) async {
    try {
      return await _profile.where('uid', isEqualTo: uid).get();
    } catch (e) {
      rethrow;
    }
  }

  Future<DocumentSnapshot?> getCompanyDocInfo({required String cid}) async {
    try {
      return await _profile.doc(cid).get();
    } catch (e) {
      rethrow;
    }
  }

  Future<QuerySnapshot?> getAdminInfo({required String uid}) async {
    try {
      return await _admin.where('uid', isEqualTo: uid).get();
    } catch (e) {
      rethrow;
    }
  }

  Future<QuerySnapshot?> getStaffListing({required String cid}) async {
    try {
      return await _staff
          .where('company_id', isEqualTo: cid)
          .where('delete_at', isEqualTo: false)
          .get();
    } catch (e) {
      rethrow;
    }
  }

  Future<QuerySnapshot?> getStaffInfo({
    required String uid,
    String? cid,
  }) async {
    try {
      if (cid == null) {
        return await _staff.where('uid', isEqualTo: uid).get();
      } else {
        return await _admin.where('company_id', isEqualTo: cid).get();
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<DocumentSnapshot?> getStaffdocInfo({
    required String cid,
  }) async {
    try {
      return await _staff.doc(cid).get();
    } catch (e) {
      rethrow;
    }
  }

  Future<UserType?> findWhichUserlogin({required String uid}) async {
    UserType? resultData;
    try {
      var result = await getStaffInfo(uid: uid);

      if (result != null && result.docs.isNotEmpty) {
        resultData = UserType.staff;
      } else {
        var result = await getAdminInfo(uid: uid);
        if (result != null && result.docs.isNotEmpty) {
          resultData = UserType.admin;
        } else {
          resultData = UserType.accountHolder;
        }
      }
    } catch (e) {
      rethrow;
    }
    return resultData;
  }

  Future<bool?> registerNewDevice(
    context, {
    required DeviceModel deviceData,
    required UserType type,
    required String docid,
  }) async {
    if (type == UserType.accountHolder) {
      await _admin
          .doc(docid)
          .collection('login_device')
          .add(
            deviceData.toMap(),
          )
          .then((value) {
        return true;
      });
    }
    return false;
  }

  Future<QuerySnapshot?> checkLoginDeviceInfo(
    context, {
    required String uid,
    required DeviceModel deviceData,
    required UserType type,
  }) async {
    QuerySnapshot? resultData;
    try {
      if (type == UserType.accountHolder) {
        await getCompanyInfo(uid: uid).then((value) async {
          if (value != null && value.docs.isNotEmpty) {
            resultData = await _profile
                .doc(value.docs.first.id)
                .collection('login_device')
                .where('device_id', isEqualTo: deviceData.deviceId)
                .where('device_model', isEqualTo: deviceData.modelName)
                .where('device_name', isEqualTo: deviceData.deviceName)
                .get();
          } else {
            throw "Login Credential Not Match";
          }
        }).catchError((onError) {
          throw onError;
        });
      } else if (type == UserType.admin) {
        await getAdminInfo(uid: uid).then((value) async {
          if (value != null && value.docs.isNotEmpty) {
            resultData = await _profile
                .doc(value.docs.first.id)
                .collection('login_device')
                .where('device_id', isEqualTo: deviceData.deviceId)
                .where('device_model', isEqualTo: deviceData.modelName)
                .where('device_name', isEqualTo: deviceData.deviceName)
                .get();
          } else {
            throw "Login Credential Not Match";
          }
        }).catchError((onError) {
          throw onError;
        });
      } else if (type == UserType.staff) {
        await getStaffInfo(uid: uid).then((value) async {
          if (value != null && value.docs.isNotEmpty) {
            resultData = await _profile
                .doc(value.docs.first.id)
                .collection('login_device')
                .where('device_id', isEqualTo: deviceData.deviceId)
                .where('device_model', isEqualTo: deviceData.modelName)
                .where('device_name', isEqualTo: deviceData.deviceName)
                .get();
          } else {
            throw "Login Credential Not Match";
          }
        }).catchError((onError) {
          throw onError;
        });
      }
    } catch (e) {
      rethrow;
    }
    return resultData;
  }

  Future<QuerySnapshot?> userListing({required String cid}) async {
    QuerySnapshot? resultData;

    try {
      resultData = await _admin
          .where('company_id', isEqualTo: cid)
          .orderBy('created_date_time', descending: true)
          .get();
    } catch (e) {
      rethrow;
    }
    return resultData;
  }

  Future<QuerySnapshot?> customerListing({required String cid}) async {
    QuerySnapshot? resultData;

    try {
      resultData = await _customer.where('company_id', isEqualTo: cid).get();
    } catch (e) {
      rethrow;
    }
    return resultData;
  }

  Future<QuerySnapshot?> productListing({required String cid}) async {
    QuerySnapshot? resultData;

    try {
      resultData = await _products
          .where('company_id', isEqualTo: cid)
          .where('delete_at', isEqualTo: false)
          .orderBy('created_date_time', descending: true)
          .get();
    } catch (e) {
      throw e.toString();
    }
    return resultData;
  }

  Future<QuerySnapshot?> productBilling(
      {required String cid, required String categoryId}) async {
    QuerySnapshot? resultData;

    try {
      resultData = await _products
          .where('company_id', isEqualTo: cid)
          .where('category_id', isEqualTo: categoryId)
          .orderBy('postion', descending: false)
          .get();
    } catch (e) {
      throw e.toString();
    }
    return resultData;
  }

  Future<QuerySnapshot?> findCategory(
      {required String cid, required String categoryName}) async {
    QuerySnapshot? resultData;

    try {
      resultData = await _category
          .where('company_id', isEqualTo: cid)
          .where('delete_at', isEqualTo: false)
          .where('name', isEqualTo: categoryName)
          .get();
    } catch (e) {
      throw e.toString();
    }
    return resultData;
  }

  Future<QuerySnapshot?> categoryListing({required String cid}) async {
    QuerySnapshot? resultData;

    try {
      resultData = await _category
          .where('company_id', isEqualTo: cid)
          .where('delete_at', isEqualTo: false)
          .orderBy('postion', descending: false)
          .get();
    } catch (e) {
      throw e.toString();
    }
    return resultData;
  }

  Future<DocumentSnapshot?> getCategorydocInfo({
    required String docid,
  }) async {
    try {
      return await _category.doc(docid).get();
    } catch (e) {
      rethrow;
    }
  }

  Future<QuerySnapshot?> getcategoryLimit({
    required int startPostion,
    required int endPostion,
    required String cid,
  }) async {
    QuerySnapshot? querySnapshot;
    try {
      querySnapshot = await _category
          .where('postion', isGreaterThanOrEqualTo: startPostion)
          .where('postion', isLessThanOrEqualTo: endPostion)
          .where('company_id', isEqualTo: cid)
          .orderBy('postion', descending: false)
          .get();
    } catch (e) {
      rethrow;
    }
    return querySnapshot;
  }

  Future<DocumentReference> registerUserAdmin({
    required UserAdminModel userData,
  }) async {
    DocumentReference docRef;
    try {
      docRef = await _admin.add(userData.toMap());
    } catch (e) {
      throw e.toString();
    }
    return docRef;
  }

  Future<QuerySnapshot?> checkStaffAlreadyExiest(
      {required String loginID}) async {
    QuerySnapshot? docRef;
    try {
      docRef = await _staff
          .where('user_login_id', isEqualTo: loginID)
          .where('delete_at', isEqualTo: false)
          .get();
    } catch (e) {
      throw e.toString();
    }
    return docRef;
  }

  Future<DocumentReference> registerStaff({
    required StaffDataModel staffData,
  }) async {
    DocumentReference docRef;
    try {
      docRef = await _staff.add(staffData.toCreateMap());
    } catch (e) {
      throw e.toString();
    }
    return docRef;
  }

  Future<void> updateStaff({
    required StaffDataModel staffData,
    required String docID,
  }) async {
    try {
      return await _staff.doc(docID).update(staffData.toMapUpdate());
    } catch (e) {
      throw e.toString();
    }
  }

  Future<void> updateProfileStaff({
    required StaffDataModel staffData,
    required String docID,
  }) async {
    try {
      return await _staff.doc(docID).update(staffData.totoMapUpdateImage());
    } catch (e) {
      throw e.toString();
    }
  }

  Future<bool?> updateUser({
    required String docID,
    required UserAdminModel userData,
  }) async {
    try {
      await _admin
          .doc(docID)
          .set(userData.updateMap(), SetOptions(merge: true))
          .then((value) {
        return true;
      }).catchError((onError) {
        throw onError.toString();
      });
    } catch (e) {
      throw e.toString();
    }
    return false;
  }

  Future<DocumentReference> registerCustomer({
    required CustomerDataModel customerData,
  }) async {
    DocumentReference docRef;
    try {
      docRef = await _customer.add(customerData.toMap());
    } catch (e) {
      throw e.toString();
    }
    return docRef;
  }

  Future<DocumentReference> registerProduct({
    required ProductDataModel productsData,
  }) async {
    DocumentReference docRef;
    try {
      docRef = await _products.add(productsData.toMap());
    } catch (e) {
      throw e.toString();
    }
    return docRef;
  }

  Future<bool?> excelMultiProduct({
    required List<ProductDataModel> productsData,
    required String cid,
  }) async {
    bool? result;
    var db = FirebaseFirestore.instance;
    var batch = db.batch();
    try {
      for (var element in productsData) {
        await _searchProduct(productName: element.productName!)
            .then((value) async {
          DocumentReference productDoc;
          if (value != null && value.docs.isNotEmpty) {
            productDoc = value.docs.first.reference;
            element.postion = value.docs.first["postion"];
          } else {
            productDoc = _products.doc();
            var resultData = await getLastPostionProduct(
              cid: cid,
              categoryID: element.categoryid!,
            ).catchError((onError) {
              log("demo3");
              throw onError.toString();
            });
            if (resultData != null && resultData.docs.isNotEmpty) {
              element.postion = resultData.docs.first["postion"] + 1;
            } else {
              element.postion = 1;
            }
          }
          batch.set(productDoc, element.toMap());
        });
      }
      await batch.commit().then((value) {
        result = true;
      }).catchError((onError) {
        throw onError;
      });
    } catch (e) {
      throw e.toString();
    }
    return result;
  }

  Future<DocumentSnapshot?> getProductPostion({required String docID}) async {
    DocumentSnapshot? dataResult;
    try {
      dataResult = await _products.doc(docID).get();
    } catch (e) {
      throw e.toString();
    }
    return dataResult;
  }

  Future<QuerySnapshot?> getProductLimit({
    required int startPostion,
    required int endPostion,
    required String cid,
    required String categoryID,
  }) async {
    QuerySnapshot? querySnapshot;
    try {
      querySnapshot = await _products
          .where('postion', isGreaterThanOrEqualTo: startPostion)
          .where('postion', isLessThanOrEqualTo: endPostion)
          .where('company_id', isEqualTo: cid)
          .where('category_id', isEqualTo: categoryID)
          .orderBy('postion', descending: false)
          .get();
    } catch (e) {
      rethrow;
    }
    return querySnapshot;
  }

  Future updateProductPostion({
    required String docId,
    required int postionValue,
  }) async {
    try {
      return await _products.doc(docId).update({
        "postion": postionValue,
      });
    } catch (e) {
      throw e.toString();
    }
  }

  Future<DocumentSnapshot?> getCategoryPostion({required String docID}) async {
    DocumentSnapshot? dataResult;
    try {
      dataResult = await _category.doc(docID).get();
    } catch (e) {
      throw e.toString();
    }
    return dataResult;
  }

  Future updatePostion({
    required String docId,
    required int postionValue,
  }) async {
    try {
      return await _category.doc(docId).update({
        "postion": postionValue,
      });
    } catch (e) {
      throw e.toString();
    }
  }

  Future<QuerySnapshot?> getLastPostionCategory({required String cid}) async {
    QuerySnapshot? dataResult;
    try {
      dataResult = await _category
          .where('company_id', isEqualTo: cid)
          .orderBy('postion', descending: true)
          .limit(1)
          .get();
    } catch (e) {
      throw e.toString();
    }
    return dataResult;
  }

  Future<QuerySnapshot?> getLastPostionProduct(
      {required String cid, required String categoryID}) async {
    QuerySnapshot? dataResult;
    try {
      dataResult = await _products
          .where('company_id', isEqualTo: cid)
          .where('category_id', isEqualTo: categoryID)
          .orderBy('postion', descending: true)
          .limit(1)
          .get();
    } catch (e) {
      throw e.toString();
    }
    return dataResult;
  }

  Future<String?> excelGetCategory(
      {required String cid, required String categoryName}) async {
    String? categoryId;
    try {
      await _searchCategory(categoryName: categoryName, cid: cid)
          .then((value) async {
        if (value != null && value.docs.isNotEmpty) {
          categoryId = value.docs.first.id;
        } else {
          int postion = 1;
          var resultData =
              await getLastPostionCategory(cid: cid).catchError((onError) {
            log("demo3");
            throw onError.toString();
          });
          if (resultData != null && resultData.docs.isNotEmpty) {
            postion = resultData.docs.first["postion"] + 1;
          }

          var categoryData = CategoryDataModel();
          categoryData.categoryName = categoryName;
          categoryData.cid = cid;
          categoryData.postion = postion;
          categoryData.name =
              categoryName.replaceAll(' ', '').trim().toLowerCase();
          categoryData.deleteAt = false;

          await registerCategory(categoryData: categoryData)
              .then((value) async {
            if (value.id.isNotEmpty) {
              categoryId = value.id;
            } else {
              log("New Demo");
            }
          }).catchError((onError) {
            log("Demo 5");
            throw onError;
          });
        }
      }).catchError((onError) {
        log("Demo 2 - $onError");
      });
    } catch (e) {
      throw e.toString();
    }
    return categoryId;
  }

  Future<QuerySnapshot?> _searchCategory(
      {required String categoryName, required String cid}) async {
    QuerySnapshot? resultData;
    try {
      String tmpcate = categoryName.replaceAll(' ', '').trim().toLowerCase();
      log(tmpcate);
      resultData = await _category
          .where(
            'name',
            isEqualTo: tmpcate,
          )
          .where("company_id", isEqualTo: cid)
          .get()
          .catchError((onError) {
        log("New Error");
        throw onError.toString();
      });
    } catch (e) {
      log("new${e.toString()}");
      throw e.toString();
    }
    return resultData;
  }

  Future<QuerySnapshot?> _searchProduct({required String productName}) async {
    QuerySnapshot? resultData;
    try {
      String tmpProduct = productName.replaceAll(' ', '').trim().toLowerCase();
      log(tmpProduct);
      resultData = await _products
          .where(
            'name',
            isEqualTo: tmpProduct,
          )
          .get();
    } catch (e) {
      throw e.toString();
    }
    return resultData;
  }

  Future<DocumentReference> registerCategory({
    required CategoryDataModel categoryData,
  }) async {
    DocumentReference docRef;
    try {
      docRef = await _category.add(categoryData.toMap());
    } catch (e) {
      throw e.toString();
    }
    return docRef;
  }

  Future updateCategory({
    required String docID,
    required CategoryDataModel categoryData,
  }) async {
    try {
      return await _category.doc(docID).update(categoryData.toUpdateMap());
    } catch (e) {
      throw e.toString();
    }
  }

  Future categoryDiscountCreate(
      {required List<CategoryDataModel> uploadCategory}) async {
    try {
      var batch = FirebaseFirestore.instance.batch();
      for (var element in uploadCategory) {
        var document = _category.doc(element.tmpcatid);
        batch.update(document, element.toDiscountUpdate());
      }
      return await batch.commit().catchError(
          (error) => throw ('Failed to execute batch write: $error'));
    } catch (e) {
      throw e.toString();
    }
  }

  Future deleteCategory({
    required String docID,
  }) async {
    try {
      return await _category.doc(docID).update({"delete_at": true});
    } catch (e) {
      throw e.toString();
    }
  }

  Future deleteEnquiry({
    required String docID,
  }) async {
    try {
      return await _enquiry.doc(docID).update({"delete_at": true});
    } catch (e) {
      throw e.toString();
    }
  }

  Future deleteStaff({
    required String docID,
  }) async {
    try {
      return await _staff.doc(docID).update({"delete_at": true});
    } catch (e) {
      throw e.toString();
    }
  }

  Future deleteEstimate({
    required String docID,
  }) async {
    try {
      return await _estimate.doc(docID).update({"delete_at": true});
    } catch (e) {
      throw e.toString();
    }
  }

  Future duplicateEnquiry({required String docID, required String cid}) async {
    try {
      await _enquiry.doc(docID).get().catchError((onError) {
        throw onError;
      }).then((enquiry) async {
        if (enquiry.exists && enquiry.data() != null) {
          await _enquiry
              .add(enquiry.data()!)
              .catchError((onError) => throw onError)
              .then((newEnquiry) async {
            if (newEnquiry.id.isNotEmpty) {
              await _enquiry.doc(newEnquiry.id).update({
                'enquiry_id': null,
                'created_date': DateTime.now(),
                'estimate_id': null,
              });
              await _enquiry
                  .doc(docID)
                  .collection('products')
                  .get()
                  .then((oldEnquiryProducts) async {
                if (oldEnquiryProducts.docs.isNotEmpty) {
                  for (var element in oldEnquiryProducts.docs) {
                    if (element.exists) {
                      await _enquiry
                          .doc(newEnquiry.id)
                          .collection("products")
                          .add(element.data());
                    }
                  }
                }
              });

              return await updateEnquiryId(cid: cid, docID: newEnquiry.id);
            }
          });
        }
      });
    } catch (e) {
      throw e.toString();
    }
  }

  Future duplicateEstimate({required String docID, required String cid}) async {
    try {
      await _estimate.doc(docID).get().catchError((onError) {
        throw onError;
      }).then((estimate) async {
        if (estimate.exists && estimate.data() != null) {
          await _estimate
              .add(estimate.data()!)
              .catchError((onError) => throw onError)
              .then((newEstimate) async {
            if (newEstimate.id.isNotEmpty) {
              await _estimate.doc(newEstimate.id).update({
                'created_date': DateTime.now(),
                'estimate_id': null,
              });
              await _estimate
                  .doc(docID)
                  .collection('products')
                  .get()
                  .then((oldestimateProducts) async {
                if (oldestimateProducts.docs.isNotEmpty) {
                  for (var element in oldestimateProducts.docs) {
                    if (element.exists) {
                      await _estimate
                          .doc(newEstimate.id)
                          .collection("products")
                          .add(element.data());
                    }
                  }
                }
              });

              return await updateEstimateId(cid: cid, docID: newEstimate.id);
            }
          });
        }
      });
    } catch (e) {
      throw e.toString();
    }
  }

  Future orderToConvertEstimate({
    required String cid,
    required String docID,
  }) async {
    try {
      await _enquiry.doc(docID).get().catchError((onError) {
        throw onError;
      }).then((enquiry) async {
        await _estimate
            .add(
          enquiry.data()!,
        )
            .catchError((onError) {
          throw onError;
        }).then((estimate) async {
          if (estimate.id.isNotEmpty) {
            await _enquiry
                .doc(docID)
                .collection('products')
                .get()
                .then((tmpEnquiryProducts) async {
              if (tmpEnquiryProducts.docs.isNotEmpty) {
                for (var element in tmpEnquiryProducts.docs) {
                  await _estimate
                      .doc(estimate.id)
                      .collection('products')
                      .add(element.data());
                }
              }
            });

            await updateEstimateId(cid: cid, docID: estimate.id)
                .then((value) async {
              await getEstimate(cid: cid).then((estimateInfo) async {
                if (estimateInfo != null && estimateInfo.docs.isNotEmpty) {
                  return await _enquiry.doc(docID).update(
                    {"estimate_id": estimateInfo.docs.first["estimate_id"]},
                  );
                }
              });
            });
          }
        });
      });
    } catch (e) {
      throw e.toString();
    }
  }

  Future _insertEnquryProduct({
    required List<CartDataModel> productList,
    required String docID,
  }) async {
    try {
      for (var product in productList) {
        await _enquiry.doc(docID).collection('products').add(
              product.toMap(),
            );
      }
    } catch (e) {
      throw e.toString();
    }
  }

  Future<AggregateQuerySnapshot?> _getLastId({required String cid}) async {
    AggregateQuerySnapshot? resultData;
    try {
      resultData = await _enquiry
          .where('company_id', isEqualTo: cid)
          .where('enquiry_id', isNull: false)
          .count()
          .get();
    } catch (e) {
      throw e.toString();
    }
    return resultData;
  }

  Future<DocumentSnapshot?> getEstimateId({required String docid}) async {
    DocumentSnapshot? resultData;
    try {
      resultData = await _estimate.doc(docid).get();
    } catch (e) {
      throw e.toString();
    }
    return resultData;
  }

  Future updateEnquiryEstimateId({
    required String enquirdDocId,
    required String estimateId,
  }) async {
    try {
      await getEstimateId(docid: estimateId).then((value) async {
        if (value != null && value.exists) {
          return await _enquiry.doc(enquirdDocId).update({
            'estimate_id': value["estimate_id"],
          });
        }
      });
    } catch (e) {
      throw e.toString();
    }
  }

  Future<int?> updateEnquiryId({
    required String cid,
    required String docID,
  }) async {
    int? resultValue;
    try {
      await _getLastId(cid: cid).then((count) async {
        if (count != null) {
          resultValue = count.count;
          await _enquiry.doc(docID).set(
            {
              "enquiry_id": "${DateTime.now().year}ENQ${count.count! + 1}",
            },
            SetOptions(merge: true),
          ).then((value) {
            return true;
          });
        }
      });
    } catch (e) {
      throw e.toString();
    }
    return resultValue;
  }

  Future<DocumentReference?> createNewOrder({
    required List<CartDataModel> productList,
    CustomerDataModel? customerInfo,
    required BillingCalCulation calCulation,
    required String cid,
  }) async {
    DocumentReference? resultDocument;
    try {
      var data = {
        "customer": customerInfo?.toOrderMap(),
        "price": calCulation.toMap(),
        "enquiry_id": null,
        "estimate_id": null,
        "company_id": cid,
        "created_date": DateTime.now(),
        "delete_at": false,
      };
      resultDocument = await _enquiry.add(data);
      if (resultDocument.id.isNotEmpty) {
        await _insertEnquryProduct(
          productList: productList,
          docID: resultDocument.id,
        );
      }
    } catch (e) {
      throw e.toString();
    }
    return resultDocument;
  }

  Future<QuerySnapshot?> getEnquiry({required String cid}) async {
    QuerySnapshot? resultData;

    try {
      resultData = await _enquiry
          .where('company_id', isEqualTo: cid)
          .where('delete_at', isEqualTo: false)
          .orderBy('created_date', descending: true)
          .get();
    } catch (e) {
      rethrow;
    }
    return resultData;
  }

  Future<QuerySnapshot?> getEnquiryCustomer(
      {required String cid, required String customerID}) async {
    QuerySnapshot? resultData;

    try {
      resultData = await _enquiry
          .where('company_id', isEqualTo: cid)
          .where('customer.customer_id', isEqualTo: customerID)
          .orderBy('created_date', descending: true)
          .get();
    } catch (e) {
      rethrow;
    }
    return resultData;
  }

  Future<QuerySnapshot?> getEnquiryProducts({required String docid}) async {
    QuerySnapshot? resultData;

    try {
      resultData = await _enquiry.doc(docid).collection('products').get();
    } catch (e) {
      rethrow;
    }
    return resultData;
  }

  Future<DocumentReference?> createNewEstimate({
    required List<CartDataModel> productList,
    CustomerDataModel? customerInfo,
    required BillingCalCulation calCulation,
    required String cid,
  }) async {
    DocumentReference? resultDocument;
    try {
      var data = {
        "customer": customerInfo?.toOrderMap(),
        "price": calCulation.toMap(),
        "estimate_id": null,
        "company_id": cid,
        "created_date": DateTime.now(),
        "delete_at": false,
      };
      resultDocument = await _estimate.add(data);
      if (resultDocument.id.isNotEmpty) {
        await _insertEstimateProduct(
          productList: productList,
          docID: resultDocument.id,
        );
      }
    } catch (e) {
      throw e.toString();
    }
    return resultDocument;
  }

  Future _insertEstimateProduct({
    required List<CartDataModel> productList,
    required String docID,
  }) async {
    try {
      for (var product in productList) {
        await _estimate.doc(docID).collection('products').add(
              product.toMap(),
            );
      }
    } catch (e) {
      throw e.toString();
    }
  }

  Future<int?> updateEstimateId({
    required String cid,
    required String docID,
  }) async {
    int? resultValue;
    try {
      await _getLastEstimateId(cid: cid).then((count) async {
        if (count != null) {
          resultValue = count.count;
          await _estimate.doc(docID).update(
            {
              "estimate_id": "${DateTime.now().year}EST${count.count! + 1}",
            },
          ).then((value) {
            return true;
          });
        }
      });
    } catch (e) {
      throw e.toString();
    }
    return resultValue;
  }

  Future<AggregateQuerySnapshot?> _getLastEstimateId(
      {required String cid}) async {
    AggregateQuerySnapshot? resultData;
    try {
      resultData = await _estimate
          .where('company_id', isEqualTo: cid)
          .where('estimate_id', isNull: false)
          .count()
          .get();
    } catch (e) {
      throw e.toString();
    }
    return resultData;
  }

  Future<QuerySnapshot?> getEstimate({required String cid}) async {
    QuerySnapshot? resultData;

    try {
      resultData = await _estimate
          .where('company_id', isEqualTo: cid)
          .where('delete_at', isEqualTo: false)
          .orderBy('created_date', descending: true)
          .get();
    } catch (e) {
      rethrow;
    }
    return resultData;
  }

  Future<QuerySnapshot?> getEstimateCustomer(
      {required String cid, required String customerID}) async {
    QuerySnapshot? resultData;

    try {
      resultData = await _estimate
          .where('company_id', isEqualTo: cid)
          .where('customer.customer_id', isEqualTo: customerID)
          .orderBy('created_date', descending: true)
          .get();
    } catch (e) {
      rethrow;
    }
    return resultData;
  }

  Future<QuerySnapshot?> getEstimateProducts({required String docid}) async {
    QuerySnapshot? resultData;

    try {
      resultData = await _estimate.doc(docid).collection('products').get();
    } catch (e) {
      rethrow;
    }
    return resultData;
  }

  Future<bool?> deleteAdmin({required String docID}) async {
    try {
      await _admin.doc(docID).delete().then((value) {
        return true;
      });
    } catch (e) {
      rethrow;
    }
    return null;
  }

  Future<AggregateQuerySnapshot?> getCustomerCount({
    required String cid,
  }) async {
    AggregateQuerySnapshot? result;
    try {
      result = await _customer
          .where('company_id', isEqualTo: cid)
          .where("delete_at", isEqualTo: false)
          .count()
          .get();
    } catch (e) {
      throw e.toString();
    }
    return result;
  }

  Future updateCustomer({
    required String docID,
    required CustomerDataModel customerData,
  }) async {
    try {
      return await _customer
          .doc(docID)
          .update(customerData.toUpdateMap())
          .catchError((onError) {
        throw onError.toString();
      });
    } catch (e) {
      throw e.toString();
    }
  }

  Future<AggregateQuerySnapshot?> getEnquiryCount({
    required String cid,
  }) async {
    AggregateQuerySnapshot? result;
    try {
      result = await _enquiry
          .where('company_id', isEqualTo: cid)
          .where("delete_at", isEqualTo: false)
          .count()
          .get();
    } catch (e) {
      throw e.toString();
    }
    return result;
  }

  Future<AggregateQuerySnapshot?> getEstimateCount({
    required String cid,
  }) async {
    AggregateQuerySnapshot? result;
    try {
      result = await _estimate
          .where('company_id', isEqualTo: cid)
          .where("delete_at", isEqualTo: false)
          .count()
          .get();
    } catch (e) {
      throw e.toString();
    }
    return result;
  }

  Future<AggregateQuerySnapshot?> getProductCount({
    required String cid,
  }) async {
    AggregateQuerySnapshot? result;
    try {
      result = await _products
          .where('company_id', isEqualTo: cid)
          .where("delete_at", isEqualTo: false)
          .count()
          .get();
    } catch (e) {
      throw e.toString();
    }
    return result;
  }

  Future updateCompany(
      {required String docId, required ProfileModel companyData}) async {
    try {
      await _profile
          .doc(docId)
          .update(companyData.updateCompany())
          .catchError((onError) {
        throw onError.toString();
      });
    } catch (e) {
      throw e.toString();
    }
  }

  Future updateCompanyPic(
      {required String docId, required String imageLink}) async {
    try {
      await _profile.doc(docId).update({
        "company_logo": imageLink,
      }).catchError((onError) {
        throw onError.toString();
      });
    } catch (e) {
      throw e.toString();
    }
  }

  Future updateProduct({
    required String docid,
    required ProductDataModel product,
  }) async {
    try {
      await _products.doc(docid).update(product.updateMap()).catchError(
        (onError) {
          throw onError.toString();
        },
      );
    } catch (e) {
      throw e.toString();
    }
  }

  Future updateProductPic(
      {required String docId, required String imageLink}) async {
    try {
      await _products.doc(docId).update({
        "product_img": imageLink,
      }).catchError((onError) {
        throw onError.toString();
      });
    } catch (e) {
      throw e.toString();
    }
  }

  Future deleteProduct({required String docId}) async {
    try {
      await _products.doc(docId).update({
        "delete_at": true,
      }).catchError((onError) {
        throw onError.toString();
      });
    } catch (e) {
      throw e.toString();
    }
  }

  Future updateEnquiryDetails({
    required String docID,
    required List<CartDataModel> productList,
    CustomerDataModel? customerInfo,
    required BillingCalCulation calCulation,
  }) async {
    try {
      await _enquiry
          .doc(docID)
          .update({
            "customer": customerInfo?.toOrderMap(),
            "price": calCulation.toMap(),
          })
          .catchError((onError) => throw onError)
          .then((value) async {
            return await _updateEnquryProduct(
              productList: productList,
              docID: docID,
            );
          });
    } catch (e) {
      throw e.toString();
    }
  }

  Future _updateEnquryProduct({
    required List<CartDataModel> productList,
    required String docID,
  }) async {
    try {
      for (var product in productList) {
        if (product.docID == null || product.docID!.isEmpty) {
          await _enquiry.doc(docID).collection('products').doc().set(
                product.toMap(),
              );
        } else {
          await _enquiry
              .doc(docID)
              .collection('products')
              .doc(product.docID)
              .update(
                product.toMap(),
              );
        }
      }
    } catch (e) {
      throw e.toString();
    }
  }

  // Estimate Update
  Future updateEstimateDetails({
    required String docID,
    required List<CartDataModel> productList,
    CustomerDataModel? customerInfo,
    required BillingCalCulation calCulation,
  }) async {
    try {
      await _estimate
          .doc(docID)
          .update({
            "customer": customerInfo?.toOrderMap(),
            "price": calCulation.toMap(),
          })
          .catchError((onError) => throw onError)
          .then((value) async {
            return await _updateEstimateProduct(
              productList: productList,
              docID: docID,
            );
          });
    } catch (e) {
      throw e.toString();
    }
  }

  Future _updateEstimateProduct({
    required List<CartDataModel> productList,
    required String docID,
  }) async {
    try {
      for (var product in productList) {
        log("product Doc ID ${product.docID}");
        if (product.docID == null || product.docID!.isEmpty) {
          await _estimate.doc(docID).collection('products').doc().set(
                product.toMap(),
              );
        } else {
          await _estimate
              .doc(docID)
              .collection('products')
              .doc(product.docID)
              .update(
                product.toMap(),
              );
        }
      }
    } catch (e) {
      throw e.toString();
    }
  }

  Future<QuerySnapshot?> staffLogin(
      {required String email, required String password}) async {
    QuerySnapshot? resultData;
    try {
      resultData = await _staff
          .where('user_login_id', isEqualTo: email)
          .where('password', isEqualTo: password)
          .get();
    } catch (e) {
      throw e.toString();
    }
    return resultData;
  }

  Future<QuerySnapshot?> adminLogin({
    required String email,
    required String password,
  }) async {
    QuerySnapshot? resultData;
    try {
      resultData = await _admin
          .where('user_login_id', isEqualTo: email)
          .where('password', isEqualTo: password)
          .get();
    } catch (e) {
      throw e.toString();
    }
    return resultData;
  }

  Future<String?> deleteAllProducts({required cid}) async {
    String? result;
    try {
      await _products
          .where('company_id', isEqualTo: cid)
          .get()
          .then((productsList) async {
        if (productsList.docs.isNotEmpty) {
          var batch = FirebaseFirestore.instance.batch();
          for (var element in productsList.docs) {
            var document = _products.doc(element.id);
            batch.update(document, {"delete_at": true});
          }
          await batch.commit().then((_) {
            result = 'Batch write executed successfully';
          }).catchError(
              (error) => throw ('Failed to execute batch write: $error'));
        } else {
          result = "success";
        }
      });
    } catch (e) {
      throw e.toString();
    }
    return result;
  }

  Future<String?> deleteAllCategorys({required cid}) async {
    String? result;
    try {
      await _category
          .where('company_id', isEqualTo: cid)
          .get()
          .then((categoryList) async {
        if (categoryList.docs.isNotEmpty) {
          var batch = FirebaseFirestore.instance.batch();
          for (var element in categoryList.docs) {
            var document = _category.doc(element.id);
            batch.update(document, {"delete_at": true});
          }
          await batch.commit().then((_) {
            result = 'Batch write executed successfully';
          }).catchError(
              (error) => throw ('Failed to execute batch write: $error'));
        } else {
          result = "success";
        }
      });
    } catch (e) {
      throw e.toString();
    }
    return result;
  }

  Future<String?> bulkCategoryCreateFn(
      {required List<CategoryDataModel> categoryList}) async {
    String? result;
    try {
      var batch = FirebaseFirestore.instance.batch();
      for (var element in categoryList) {
        var document = _category.doc();
        batch.set(document, element.toMap());
      }
      await batch.commit().then((_) {
        result = 'Batch write executed successfully';
      }).catchError((error) => throw ('Failed to execute batch write: $error'));
    } catch (e) {
      throw e.toString();
    }
    return result;
  }

  Map<String, String> getFinancialYear() {
    DateTime currentDate = DateTime(2024, 03, 31);
    var currentYearTwo = DateFormat("yy").format(currentDate);
    var currentYearFull = DateFormat("yyyy").format(currentDate);

    var nextyearTwo = (int.parse(currentYearTwo) + 1).toString();

    var shortYear = "$currentYearTwo - $nextyearTwo";

    String month = DateFormat("MM").format(currentDate);
    if (month == "01" || month == "02" || month == "03") {
      currentYearTwo = (int.parse(currentYearTwo) - 1).toString();
      currentYearFull = (int.parse(currentYearFull) - 1).toString();
      nextyearTwo = DateFormat("yy").format(currentDate);
      shortYear = "$currentYearTwo-$nextyearTwo";
    }

    Map<String, String> result = {
      "currentYearFull": currentYearFull,
      "fnYr": shortYear,
    };
    return result;
  }

  Future<DocumentSnapshot<Map<String, dynamic>>> getCurrentFinType(
      {required String finYear}) async {
    try {
      finYear = finYear;
      return await _invoiceSettings.doc(finYear).get();
    } catch (e) {
      rethrow;
    }
  }

  Future<QuerySnapshot<Map<String, dynamic>>> getInvoiceListing() async {
    try {
      return await _invoice
          .where("delete_at", isEqualTo: false)
          .orderBy('bill_date', descending: true)
          .get();
    } catch (e) {
      rethrow;
    }
  }

  Future<QuerySnapshot<Map<String, dynamic>>> getInvoiceProductListing(
      {required String docID}) async {
    try {
      return await _invoice.doc(docID).collection('products').get();
    } catch (e) {
      rethrow;
    }
  }

  Future<String?> getLastInvoiceNumber() async {
    String? invoiceNumber;
    try {
      var result = getFinancialYear();
      String option = "new";
      await getCurrentFinType(finYear: result["fnYr"]!).then((value) {
        if (value.id.isNotEmpty) {
          option = value["bill_type"];
        }
      });
      int queryYear = 0;
      if (option == "new") {
        queryYear = int.parse(result["currentYearFull"]!);
      } else {
        queryYear = int.parse(result["currentYearFull"]!) - 1;
      }
      log(DateFormat('dd-MM-yyyy').format(DateTime(queryYear, 04, 01)));
      await _invoice
          .where('bill_date',
              isGreaterThanOrEqualTo: DateTime(queryYear, 04, 01))
          .where('bill_date', isLessThanOrEqualTo: DateTime.now())
          .where('delete_at', isEqualTo: false)
          .get()
          .then((value) {
        var count = value.docs.where((element) => element["bill_no"] != null);
        invoiceNumber = (count.length + 1).toString();
        invoiceNumber = invoiceNumber!.length == 1
            ? "00$invoiceNumber/INV${result["fnYr"]}"
            : invoiceNumber!.length == 2
                ? "0$invoiceNumber/INV${result["fnYr"]}"
                : "$invoiceNumber/INV${result["fnYr"]}";
      });
      return invoiceNumber;
    } catch (e) {
      rethrow;
    }
  }

  Future<double> getLastInvoiceAmount(
      {required DateTime billDate, required String billNo}) async {
    try {
      var tmpYear = billNo.split('/');
      var first = "20${tmpYear[1].substring(3, 5)}";
      log(first);
      return await _invoice
          .where('bill_date',
              isGreaterThanOrEqualTo: DateTime(int.parse(first), 04, 01))
          .where('bill_date', isLessThan: billDate)
          .where('delete_at', isEqualTo: false)
          .get()
          .then((value) {
        double total = 0.0;
        for (var element in value.docs) {
          total += double.parse(element["total_amount"]);
        }

        return total;
      });
    } catch (e) {
      rethrow;
    }
  }

  Future<int> getCount() async {
    try {
      var result = getFinancialYear();
      String option = "new";
      await getCurrentFinType(finYear: result["fnYr"]!).then((value) {
        if (value.id.isNotEmpty) {
          option = value["bill_type"];
        }
      });
      int queryYear = 0;
      if (option == "new") {
        queryYear = int.parse(result["currentYearFull"]!);
      } else {
        queryYear = int.parse(result["currentYearFull"]!) - 1;
      }
      log(DateFormat('dd-MM-yyyy').format(DateTime(queryYear, 04, 01)));
      return await _invoice
          .where('bill_date',
              isGreaterThanOrEqualTo: DateTime(queryYear, 04, 01))
          .where('bill_date', isLessThanOrEqualTo: DateTime.now())
          .where('delete_at', isEqualTo: false)
          .get()
          .then((value) {
        var count = value.docs.where((element) => element["bill_no"] != null);
        return count.length;
      });
    } catch (e) {
      rethrow;
    }
  }

  // Future<String> createDoc() async {
  //   try {
  //     var year = getFinancialYear();
  //     int count = await getCount();
  //     var tmpID = "$count/INV${year["fnYr"]}";
  //     var tmpResult = _invoice.doc(tmpID);
  //     if (tmpResult.id.isNotEmpty) {
  //       return tmpResult.id;
  //     } else {
  //       return createDoc();
  //     }
  //   } catch (e) {
  //     rethrow;
  //   }
  // }

  Future<String> findLastID({required DateTime orderTime}) async {
    try {
      var result = getFinancialYear();
      String option = "new";
      await getCurrentFinType(finYear: result["fnYr"]!).then((value) {
        if (value.id.isNotEmpty) {
          option = value["bill_type"];
        }
      });
      int queryYear = 0;
      if (option == "new") {
        queryYear = int.parse(result["currentYearFull"]!);
      } else {
        queryYear = int.parse(result["currentYearFull"]!) - 1;
      }
      log(DateFormat('dd-MM-yyyy').format(DateTime(queryYear, 04, 01)));
      return await _invoice
          .where('bill_date', isLessThan: orderTime)
          .where('delete_at', isEqualTo: false)
          .orderBy('bill_date', descending: true)
          .limit(1)
          .get()
          .then((value) async {
        if (value.docs.isNotEmpty) {
          var lastCount = value.docs.first["bill_no"];
          if (lastCount == null) {
            return await findLastID(orderTime: orderTime);
          } else {
            log(lastCount);
            var countData = lastCount.toString().split("/");
            log(countData[0]);
            var invoiceNumber = (int.parse(countData[0]) + 1).toString();
            invoiceNumber = invoiceNumber.length == 1
                ? "00$invoiceNumber/INV${result["fnYr"]}"
                : invoiceNumber.length == 2
                    ? "0$invoiceNumber/INV${result["fnYr"]}"
                    : "$invoiceNumber/INV${result["fnYr"]}";

            return invoiceNumber;
          }
        } else {
          var invoiceNumber = "1";
          invoiceNumber = invoiceNumber.length == 1
              ? "00$invoiceNumber/INV${result["fnYr"]}"
              : invoiceNumber.length == 2
                  ? "0$invoiceNumber/INV${result["fnYr"]}"
                  : "$invoiceNumber/INV${result["fnYr"]}";
          return invoiceNumber;
        }
      });
    } catch (e) {
      rethrow;
    }
  }

  Future createNewInvoice({
    required InvoiceModel invoiceData,
    required List<InvoiceProductModel> cartDataList,
  }) async {
    try {
      invoiceData.createdDate = DateTime.now();
      invoiceData.biilDate = DateTime.now();
      return await _invoice
          .add(invoiceData.toCreationMap())
          .then((value) async {
        if (value.id.isNotEmpty) {
          var invoiceNumber =
              await findLastID(orderTime: invoiceData.createdDate!);
          return await _invoice
              .doc(value.id)
              .update({"bill_no": invoiceNumber});
        }
      });
    } catch (e) {
      rethrow;
    }
  }

  Future updateInvoice({
    required String docID,
    required InvoiceModel invoiceData,
    required List<InvoiceProductModel> cartDataList,
  }) async {
    try {
      return await _invoice.doc(docID).update(invoiceData.toUpdateMap());
    } catch (e) {
      rethrow;
    }
  }

  Future<QuerySnapshot<Map<String, dynamic>>> filterInvoice({
    required DateTime fromDate,
    required DateTime toDate,
  }) async {
    try {
      log("${fromDate.toString()} - ${toDate.toString()}");
      return await _invoice
          .where("bill_date",
              isGreaterThanOrEqualTo:
                  fromDate.subtract(const Duration(days: 1)))
          .where("bill_date",
              isLessThanOrEqualTo: toDate.add(const Duration(days: 1)))
          .get();
    } catch (e) {
      log(e.toString());
      rethrow;
    }
  }
}

enum UserType {
  accountHolder,
  admin,
  staff,
}

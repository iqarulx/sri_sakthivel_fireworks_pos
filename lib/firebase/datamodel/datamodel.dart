import 'package:flutter/material.dart';

class ProfileModel {
  String? username;
  String? companyLogo;
  String? companyName;
  String? address;
  String? state;
  String? city;
  String? pincode;
  String? gstno;
  int? deviceLimit;
  Map<String, dynamic>? contact;
  String? uid;
  String? userLoginId;
  bool? filled;
  String? password;
  String? companyUniqueID;

  dataMap() {
    var mapping = <String, dynamic>{};
    mapping["user_name"] = username;
    mapping["address"] = address;
    mapping["city"] = city;
    mapping["company_logo"] = companyLogo;
    mapping["company_name"] = companyName;
    mapping["contact"] = contact;
    mapping["device_limit"] = deviceLimit;
    mapping["gst_no"] = gstno;
    mapping["pincode"] = pincode;
    mapping["state"] = state;
    mapping["uid"] = uid;
    mapping["user_login_id"] = userLoginId;
    return mapping;
  }

  initRegisterCompany() {
    var mapping = <String, dynamic>{};
    mapping["company_name"] = companyName;
    mapping["uid"] = uid;
    mapping["user_login_id"] = userLoginId;
    mapping["user_name"] = username;
    mapping["info_filled"] = filled;
    mapping["password"] = password;
    return mapping;
  }

  newRegisterCompany() {
    var mapping = <String, dynamic>{};
    mapping["user_name"] = username;
    mapping["address"] = address;
    mapping["city"] = city;
    mapping["company_logo"] = companyLogo;
    mapping["company_name"] = companyName;
    mapping["contact"] = contact;
    mapping["gst_no"] = gstno;
    mapping["pincode"] = pincode;
    mapping["state"] = state;
    mapping["device_limit"] = deviceLimit;
    mapping["info_filled"] = filled;
    mapping["company_unique_id"] = companyUniqueID;
    mapping["password"] = password;
    return mapping;
  }

  updateCompany() {
    var mapping = <String, dynamic>{};
    mapping["user_name"] = username;
    mapping["company_name"] = companyName;
    mapping["address"] = address;
    mapping["pincode"] = pincode;
    mapping["contact"] = contact;
    mapping["gst_no"] = gstno;
    mapping["user_login_id"] = userLoginId;
    mapping["password"] = password;
    return mapping;
  }
}

class SideMultiMenuList {
  final int index;
  final String title;
  final IconData icon;
  SideMultiMenuList({
    required this.index,
    required this.title,
    required this.icon,
  });
}

class DeviceModel {
  String? deviceType;
  String? deviceId;
  String? deviceName;
  String? modelName;
  DateTime? lastlogin;
  toMap() {
    var mapping = <String, dynamic>{};
    mapping['device_type'] = deviceType;
    mapping['device_id'] = deviceId;
    mapping['device_name'] = deviceName;
    mapping['model_name'] = modelName;
    mapping['last_login'] = lastlogin;
    return mapping;
  }
}

class UserAdminModel {
  String? adminName;
  String? phoneNo;
  String? adminLoginId;
  String? password;
  String? companyId;
  String? uid;
  String? imageUrl;

  String? docid;
  DateTime? createdDateTime;

  UserAdminModel({
    this.adminName,
    this.phoneNo,
    this.adminLoginId,
    this.password,
    this.companyId,
    this.uid,
    this.imageUrl,
  });

  toMap() {
    var mapping = <String, dynamic>{};
    mapping["company_id"] = companyId;
    mapping["phone_no"] = phoneNo;
    mapping["uid"] = uid;
    mapping["admin_name"] = adminName;
    mapping["user_login_id"] = adminLoginId;
    mapping["password"] = password;
    mapping["image_url"] = imageUrl;
    mapping["created_date_time"] = createdDateTime;
    return mapping;
  }

  updateMap() {
    var mapping = <String, dynamic>{};
    mapping["admin_name"] = adminName;
    mapping["phone_no"] = phoneNo;
    mapping["user_login_id"] = adminLoginId;
    mapping["password"] = password;
    return mapping;
  }
}

class StaffPermissionDataModel {
  bool? product;
  bool? category;
  bool? customer;
  bool? orders;
  bool? estimate;
  bool? billofsupply;

  toMap() {
    var mapping = <String, dynamic>{};
    mapping["product"] = product;
    mapping["category"] = category;
    mapping["customer"] = customer;
    mapping["orders"] = orders;
    mapping["estimate"] = estimate;
    mapping["billofsupply"] = billofsupply;
    return mapping;
  }
}

class StaffDataModel {
  String? userName;
  String? phoneNo;
  String? userid;
  String? password;
  String? companyID;
  String? profileImg;
  StaffPermissionDataModel? permission;
  String? docID;
  bool? deleteAt;

  toCreateMap() {
    var mapping = <String, dynamic>{};
    mapping["staff_name"] = userName;
    mapping["phone_no"] = phoneNo;
    mapping["user_login_id"] = userid;
    mapping["password"] = password;
    mapping["profile_img"] = profileImg;
    mapping["company_id"] = companyID;
    mapping["permission"] = permission!.toMap();
    mapping["delete_at"] = deleteAt;
    return mapping;
  }

  totoMapUpdateImage() {
    var mapping = <String, dynamic>{};
    mapping["profile_img"] = profileImg;
    return mapping;
  }

  toMapUpdate() {
    var mapping = <String, dynamic>{};
    mapping["staff_name"] = userName;
    mapping["phone_no"] = phoneNo;
    mapping["user_login_id"] = userid;
    mapping["password"] = password;
    mapping["permission"] = permission!.toMap();
    return mapping;
  }

  toMap() {
    var mapping = <String, dynamic>{};
    mapping["staff_name"] = userName;
    mapping["phone_no"] = phoneNo;
    mapping["company_id"] = companyID;
    mapping["user_login_id"] = userid;
    return mapping;
  }
}

class CustomerDataModel {
  String? customerName;
  String? address;
  String? city;
  String? companyID;
  String? email;
  String? mobileNo;
  String? state;
  String? docID;

  toMap() {
    var mapping = <String, dynamic>{};
    mapping["address"] = address;
    mapping["city"] = city;
    mapping["company_id"] = companyID;
    mapping["email"] = email;
    mapping["mobile_no"] = mobileNo;
    mapping["customer_name"] = customerName;
    mapping["state"] = state;
    return mapping;
  }

  toOrderMap() {
    var mapping = <String, dynamic>{};
    mapping["address"] = address;
    mapping["city"] = city;
    mapping["company_id"] = companyID;
    mapping["email"] = email;
    mapping["mobile_no"] = mobileNo;
    mapping["customer_name"] = customerName;
    mapping["state"] = state;
    mapping["customer_id"] = docID;
    return mapping;
  }

  toUpdateMap() {
    var mapping = <String, dynamic>{};
    mapping["customer_name"] = customerName;
    mapping["mobile_no"] = mobileNo;
    mapping["address"] = address;
    mapping["state"] = state;
    mapping["city"] = city;
    mapping["email"] = email;
    return mapping;
  }
}

class ProductDataModel {
  String? categoryid;
  String? categoryName;
  String? productName;
  String? productCode;
  String? productContent;
  String? qrCode;
  double? price;
  String? videoUrl;
  String? productImg;
  bool? active;
  String? companyId;
  bool? discountLock;
  bool? delete;
  String? name;
  String? productId;
  TextEditingController? qtyForm;
  int? qty;
  String? docid;
  int? postion;

  int? discount;

  DateTime? createdDateTime;

  updateMap() {
    var mapping = <String, dynamic>{};
    mapping["active"] = active;
    mapping["category_id"] = categoryid;
    mapping["discount_lock"] = discountLock;
    mapping["price"] = price;
    mapping["product_code"] = productCode;
    mapping["product_content"] = productContent;
    mapping["product_name"] = productName;
    mapping["qr_code"] = qrCode;
    mapping["video_url"] = videoUrl;
    mapping["name"] = name;
    return mapping;
  }

  toMap() {
    var mapping = <String, dynamic>{};
    mapping["active"] = active;
    mapping["category_id"] = categoryid;
    mapping["category_name"] = categoryName;
    mapping["company_id"] = companyId;
    mapping["discount_lock"] = discountLock;
    mapping["price"] = price;
    mapping["product_code"] = productCode;
    mapping["product_content"] = productContent;
    mapping["product_name"] = productName;
    mapping["qr_code"] = qrCode;
    mapping["video_url"] = videoUrl;
    mapping["product_img"] = productImg;
    mapping["delete_at"] = delete;
    mapping["name"] = name;
    mapping["postion"] = postion;
    mapping["created_date_time"] = createdDateTime;
    return mapping;
  }
}

class CategoryDataModel {
  String? categoryName;
  String? name;
  int? postion;
  String? cid;
  bool? deleteAt;
  int? discount;
  String? tmpcatid;
  bool? discountEnable;

  toMap() {
    var mapping = <String, dynamic>{};
    mapping["name"] = name;
    mapping["category_name"] = categoryName;
    mapping["postion"] = postion;
    mapping["company_id"] = cid;
    mapping["delete_at"] = deleteAt;
    mapping["discount"] = discount;
    return mapping;
  }

  toDiscountUpdate() {
    var mapping = <String, dynamic>{};
    mapping["discount"] = discount;
    return mapping;
  }

  toUpdateMap() {
    var mapping = <String, dynamic>{};
    mapping["name"] = name;
    mapping["category_name"] = categoryName;
    return mapping;
  }
}

class ExcelCategoryClass {
  final String categoryname;
  final List<ExcelProductClass> product;
  ExcelCategoryClass({
    required this.categoryname,
    required this.product,
  });
}

class ExcelProductClass {
  final String productno;
  final String productname;
  final String content;
  final String price;
  final String discountlock;
  final String qrcode;
  ExcelProductClass({
    required this.productno,
    required this.productname,
    required this.content,
    required this.price,
    required this.discountlock,
    required this.qrcode,
  });
}

class BillingDataModel {
  CategoryDataModel? category;
  List<ProductDataModel>? products;
  BillingDataModel({this.category, this.products});
}

class CartDataModel {
  String? categoryId;
  String? categoryName;
  String? productName;
  String? productId;
  String? productImg;
  bool? discountLock;
  String? productCode;
  String? productContent;
  String? qrCode;
  String? videoUrl;
  double? price;
  String? mrp;
  int? qty;
  TextEditingController? qtyForm;
  String? name;
  String? docID;

  int? discount;

  toMap() {
    var mapping = <String, dynamic>{};
    mapping["category_id"] = categoryId;
    mapping["category_name"] = categoryName;
    mapping["product_name"] = productName;
    mapping["product_id"] = productId;
    mapping["product_img"] = productImg;
    mapping["price"] = price;
    mapping["mrp"] = mrp;
    mapping["qty"] = qty;
    mapping["product_code"] = productCode;
    mapping["discount_lock"] = discountLock;
    mapping["product_code"] = productCode;
    mapping["product_content"] = productContent;
    mapping["qr_code"] = qrCode;
    mapping["video_url"] = videoUrl;
    mapping["name"] = name;
    return mapping;
  }
}

class BillingCalCulation {
  double? subTotal;
  double? discount;
  String? discountsys;
  double? discountValue;
  double? extraDiscount;
  String? extraDiscountsys;
  double? extraDiscountValue;
  double? package;
  String? packagesys;
  double? packageValue;
  double? total;

  toMap() {
    var mapping = <String, dynamic>{};
    mapping["sub_total"] = subTotal;
    mapping["discount"] = discount;
    mapping["discount_sys"] = discountsys;
    mapping["discount_value"] = discountValue;
    mapping["extra_discount"] = extraDiscount;
    mapping["extra_discount_sys"] = extraDiscountsys;
    mapping["extra_discount_value"] = extraDiscountValue;
    mapping["package"] = package;
    mapping["package_sys"] = packagesys;
    mapping["package_value"] = packageValue;
    mapping["total"] = total;
    return mapping;
  }
}

class DiscountBillModel {
  List<ProductDataModel>? products;
  String? discount;
}

class EstimateDataModel {
  DateTime? createddate;
  String? enquiryid;
  String? estimateid;
  BillingCalCulation? price;
  CustomerDataModel? customer;
  List<ProductDataModel>? products;
  String? docID;

  EstimateDataModel({
    this.createddate,
    this.enquiryid,
    this.estimateid,
    this.price,
    this.customer,
    this.products,
    this.docID,
  });
}

class PriceListCategoryDataModel {
  String? categoryName;
  List<PriceListProdcutDataModel>? productModel;
  PriceListCategoryDataModel({
    required this.categoryName,
    required this.productModel,
  });
}

class PriceListProdcutDataModel {
  String? prodcutName;
  String? content;
  String? price;
  PriceListProdcutDataModel({
    required this.prodcutName,
    required this.content,
    required this.price,
  });
}

class CategoryDiscountModel {
  String? categoryName;
  int? discountValue;
}

import 'datamodel.dart';

class InvoiceModel {
  String? partyName;
  String? address;
  String? deliveryaddress;
  String? phoneNumber;
  String? transportName;
  String? transportNumber;
  String? totalBillAmount;
  String? billNo;
  DateTime? biilDate;
  DateTime? createdDate;
  BillingCalCulation? price;

  String? docID;

  List<InvoiceProductModel>? listingProducts;

  bool? isEstimateConverted;

  toCreationMap() {
    var mapping = <String, dynamic>{};
    mapping["bill_no"] = billNo;
    mapping["party_name"] = partyName;
    mapping["address"] = address;
    mapping["delivery_address"] = deliveryaddress;
    mapping["phone_number"] = phoneNumber;
    mapping["transport_name"] = transportName;
    mapping["transport_number"] = transportNumber;
    mapping["created_date"] = createdDate;
    mapping["bill_date"] = biilDate;
    mapping["delete_at"] = false;
    mapping["total_amount"] = totalBillAmount;
    mapping["price"] = price?.toMap();
    mapping["products"] = listingProducts != null
        ? [
            for (var data in listingProducts!) data.toCreateMap(),
          ]
        : null;
    return mapping;
  }

  toUpdateMap() {
    var mapping = <String, dynamic>{};
    mapping["party_name"] = partyName;
    mapping["address"] = address;
    mapping["delivery_address"] = deliveryaddress;
    mapping["phone_number"] = phoneNumber;
    mapping["transport_name"] = transportName;
    mapping["transport_number"] = transportNumber;
    mapping["total_amount"] = totalBillAmount;
    mapping["products"] = listingProducts != null
        ? [
            for (var data in listingProducts!) data.toCreateMap(),
          ]
        : null;
    return mapping;
  }
}

class InvoiceProductModel {
  String? productName;
  String? productID;
  int? qty;
  String? unit;
  double? rate;
  double? total;
  int? discount;
  bool? discountLock;
  String? categoryID;

  String? docID;

  toCreateMap() {
    var mapping = <String, dynamic>{};
    mapping["product_name"] = productName;
    mapping["product_id"] = productID;
    mapping["qty"] = qty;
    mapping["unit"] = unit;
    mapping["rate"] = rate;
    mapping["total"] = total;
    mapping["discount"] = discount;
    mapping["category_id"] = categoryID;
    mapping["discount_lock"] = discountLock;
    return mapping;
  }

  toUpdateMap() {
    var mapping = <String, dynamic>{};
    mapping["product_name"] = productName;
    mapping["product_id"] = productID;
    mapping["qty"] = qty;
    mapping["unit"] = unit;
    mapping["rate"] = rate;
    mapping["total"] = total;
    mapping["discount"] = discount;
    mapping["category_id"] = categoryID;
    mapping["discount_lock"] = discountLock;
    return mapping;
  }
}

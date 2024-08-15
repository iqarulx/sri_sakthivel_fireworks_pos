import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:sri_sakthivel_fireworks_pos/firebase/datamodel/datamodel.dart';
import 'package:sri_sakthivel_fireworks_pos/screen/mainapp/billing/customer_search.dart';

import '../../../utlities/varibales.dart';

class OrderSummary extends StatefulWidget {
  final String total;
  final String subtotal;
  final String discountsys;
  final String discountInput;
  final String discountValue;
  final String extraDicountsys;
  final String extraDiscountInput;
  final String extraDiscountValue;
  final String packingChargesys;
  final String packingChargeInput;
  final String packingChargeValue;
  const OrderSummary({
    super.key,
    required this.total,
    required this.subtotal,
    required this.discountsys,
    required this.discountInput,
    required this.discountValue,
    required this.extraDicountsys,
    required this.extraDiscountInput,
    required this.extraDiscountValue,
    required this.packingChargesys,
    required this.packingChargeInput,
    required this.packingChargeValue,
  });

  @override
  State<OrderSummary> createState() => _OrderSummaryState();
}

class _OrderSummaryState extends State<OrderSummary> {
  CustomerDataModel? customerInfo;
  String itemCount() {
    String result = "0";
    int tmpCount = 0;
    for (var element in cartDataList) {
      tmpCount += element.qty!;
    }
    if (tmpCount.isNaN) {
      tmpCount = 0;
    }
    result = tmpCount.toString();
    return result;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffEEEEEE),
      appBar: AppBar(
        title: const Text("Order Summary"),
      ),
      bottomNavigationBar: BottomAppBar(
        padding: const EdgeInsets.all(10),
        child: SizedBox(
          height: 50,
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
            onPressed: () {},
            child: const Text("Confirm to Order"),
          ),
        ),
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
            child: Column(
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
                            "\u{20B9}${widget.total}",
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
                        "\u{20B9}${widget.subtotal}",
                        style: Theme.of(context).textTheme.bodyMedium!.copyWith(color: Colors.green.shade600),
                      ),
                    ],
                  ),
                ),
                const SizedBox(
                  height: 8,
                ),
                Container(
                  color: Colors.transparent,
                  child: Row(
                    children: [
                      Text(
                        "Discount - ${widget.discountsys.toUpperCase()} ${widget.discountInput}",
                        // "Discount - % 12",
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      const SizedBox(width: 5),
                      const Spacer(),
                      Text(
                        "\u{20B9}${widget.discountValue}",
                        style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                              color: Colors.red.shade600,
                            ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(
                  height: 8,
                ),
                Container(
                  color: Colors.transparent,
                  child: Row(
                    children: [
                      Text(
                        "Extra Discount - ${widget.extraDicountsys.toUpperCase()} ${widget.extraDiscountInput}",
                        // "Extra Discount - % 5",
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      const SizedBox(width: 5),
                      const Spacer(),
                      Text(
                        "\u{20B9}${widget.extraDiscountValue}",
                        style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                              color: Colors.red.shade600,
                            ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(
                  height: 8,
                ),
                Container(
                  color: Colors.transparent,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Packing Charges - ${widget.packingChargesys.toUpperCase()} ${widget.packingChargeInput}",
                        // "Packing Charges - % 10",
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      const SizedBox(width: 5),
                      const Spacer(),
                      Text(
                        "\u{20B9}${widget.packingChargeValue}",
                        style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                              color: Colors.green.shade600,
                            ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(
            height: 10,
          ),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Customer",
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          CupertinoPageRoute(
                            builder: (context) => const CustomerSearch(),
                          ),
                        ).then((value) {
                          if (value != null) {
                            setState(() {
                              customerInfo = value;
                            });
                          }
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 15,
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
                              "Add Customer",
                              style: Theme.of(context).textTheme.titleSmall!.copyWith(
                                    color: Theme.of(context).primaryColor,
                                  ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    // IconButton(
                    //   constraints: BoxConstraints(maxWidth: 30, maxHeight: 30),
                    //   splashRadius: 20,
                    //   onPressed: () {},
                    //   padding: const EdgeInsets.all(0),
                    //   icon: const Icon(
                    //     Icons.person_add,
                    //   ),
                    // ),
                  ],
                ),
                const SizedBox(
                  height: 10,
                ),
                Visibility(
                  visible: customerInfo == null,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 20),
                    child: Center(
                      child: Text(
                        "No Customer Selected",
                        style: Theme.of(context).textTheme.headlineSmall!.copyWith(color: Colors.grey),
                      ),
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
                                "State : ${customerInfo!.address ?? ""}",
                                style: Theme.of(context).textTheme.labelMedium!.copyWith(
                                      color: Colors.grey,
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
          const SizedBox(
            height: 10,
          ),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      "Order List",
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(
                      width: 5,
                    ),
                    Text(
                      "(${cartDataList.length})",
                      style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                            color: Colors.black,
                          ),
                    ),
                    const Spacer(),
                    Text(
                      "Items(${itemCount()})",
                      style: Theme.of(context).textTheme.bodySmall!.copyWith(
                            color: Colors.grey,
                          ),
                    ),
                  ],
                ),
                const SizedBox(
                  height: 10,
                ),
                ListView.builder(
                  primary: false,
                  shrinkWrap: true,
                  reverse: true,
                  // padding: const EdgeInsets.all(0),
                  itemCount: cartDataList.length,
                  itemBuilder: (context, index) {
                    return Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(5),
                      ),
                      padding: const EdgeInsets.all(5),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
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
                                          const SizedBox(
                                            height: 8,
                                          ),
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 10,
                                              vertical: 5,
                                            ),
                                            // height: 30,
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
                                                mainAxisAlignment: MainAxisAlignment.center,
                                                children: [
                                                  Expanded(
                                                    child: Text(
                                                      "${cartDataList[index].price} X ${cartDataList[index].qty} = ${(cartDataList[index].price! * cartDataList[index].qty!).toStringAsFixed(2)}",
                                                      style: Theme.of(context).textTheme.labelMedium!.copyWith(
                                                            color: Colors.grey,
                                                          ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(
                                      width: 8,
                                    ),
                                    Column(
                                      mainAxisSize: MainAxisSize.min,
                                      crossAxisAlignment: CrossAxisAlignment.end,
                                      children: [
                                        Text(
                                          "\u{20B9}${cartDataList[index].mrp}",
                                          style: Theme.of(context).textTheme.bodySmall!.copyWith(
                                                decoration: TextDecoration.lineThrough,
                                              ),
                                        ),
                                        const SizedBox(
                                          height: 1,
                                        ),
                                        Text(
                                          "\u{20B9}${cartDataList[index].price}",
                                          style: Theme.of(context).textTheme.titleLarge,
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

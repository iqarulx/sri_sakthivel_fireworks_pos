import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../firebase/datamodel/invoice_model.dart';
import 'product_listing_dialog.dart';

class InvoiceEditAlertView extends StatefulWidget {
  final List<InvoiceProductModel> productDataList;
  final InvoiceProductModel editProduct;
  const InvoiceEditAlertView({super.key, required this.productDataList, required this.editProduct});

  @override
  State<InvoiceEditAlertView> createState() => _InvoiceEditAlertViewState();
}

class _InvoiceEditAlertViewState extends State<InvoiceEditAlertView> {
  TextEditingController productName = TextEditingController();
  TextEditingController qty = TextEditingController();
  TextEditingController unit = TextEditingController();
  TextEditingController rate = TextEditingController();
  TextEditingController amount = TextEditingController();

  InvoiceProductModel? currentProduct;

  final productFormKey = GlobalKey<FormState>();

  showProductAlert() async {
    await showDialog(
      context: context,
      builder: (context) => ProductListingDialog(productDataList: widget.productDataList),
    ).then((value) {
      if (value != null) {
        InvoiceProductModel values = (value as InvoiceProductModel);

        setState(() {
          currentProduct = value;
          productName.text = values.productName ?? "";
          rate.text = values.rate.toString();
        });
      }
    });
  }

  currentProductTotal() {
    String result = "0.00";
    double amount = 0.00;
    if (currentProduct != null && qty.text.isNotEmpty && rate.text.isNotEmpty) {
      amount = double.parse(qty.text) * double.parse(rate.text);
    }

    result = amount.toStringAsFixed(2);
    return result;
  }

  initFn() {
    setState(() {
      currentProduct = widget.editProduct;
      productName.text = widget.editProduct.productName ?? "";
      rate.text = double.parse(widget.editProduct.rate.toString()).toStringAsFixed(0);
      qty.text = widget.editProduct.qty.toString();
      unit.text = widget.editProduct.unit.toString();
    });
  }

  updateProduct() async {
    if (productFormKey.currentState!.validate()) {
      setState(() {
        widget.editProduct.productName = productName.text;
        widget.editProduct.productID = currentProduct!.productID;
        widget.editProduct.qty = int.parse(qty.text);
        widget.editProduct.rate = double.parse(rate.text);
        widget.editProduct.total = double.parse(qty.text) * double.parse(rate.text);
        widget.editProduct.unit = unit.text;
      });
      Navigator.pop(context, true);
    }
  }

  @override
  void initState() {
    initFn();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Product"),
      actions: [
        Row(
          children: [
            Expanded(
              child: GestureDetector(
                onTap: () {
                  Navigator.pop(context);
                },
                child: Container(
                  height: 50,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: const Center(
                    child: Text(
                      "Cancel",
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: GestureDetector(
                onTap: () {
                  updateProduct();
                },
                child: Container(
                  height: 50,
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor,
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: const Center(
                    child: Text(
                      "Submit",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
      content: SingleChildScrollView(
        child: Form(
          key: productFormKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Product Name",
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: TextFormField(
                            readOnly: true,
                            decoration: const InputDecoration(
                              filled: true,
                              fillColor: Color(0xffEEEEEE),
                              border: OutlineInputBorder(
                                borderSide: BorderSide.none,
                                borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(5),
                                  bottomLeft: Radius.circular(5),
                                ),
                              ),
                              suffixIcon: IconButton(
                                onPressed: null,
                                icon: Icon(Icons.arrow_drop_down_outlined),
                              ),
                              hintText: "Product Name",
                              contentPadding: EdgeInsets.symmetric(horizontal: 10),
                            ),
                            controller: productName,
                            onTap: () {
                              showProductAlert();
                            },
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return "Product Name is Must";
                              } else {
                                return null;
                              }
                            },
                          ),
                        ),
                        Container(
                          height: 48,
                          width: 48,
                          decoration: BoxDecoration(
                            color: Theme.of(context).primaryColor.withOpacity(0.8),
                            borderRadius: const BorderRadius.only(
                              topRight: Radius.circular(5),
                              bottomRight: Radius.circular(5),
                            ),
                          ),
                          child: const Center(
                            child: Icon(
                              Icons.add,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: SizedBox(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "QTY",
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                          const SizedBox(height: 8),
                          TextFormField(
                            keyboardType: TextInputType.number,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                            ],
                            decoration: const InputDecoration(
                              filled: true,
                              fillColor: Color(0xffEEEEEE),
                              border: OutlineInputBorder(
                                borderSide: BorderSide.none,
                              ),
                              hintText: "QTY",
                              contentPadding: EdgeInsets.symmetric(horizontal: 10),
                            ),
                            controller: qty,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return "QTY is Must";
                              } else {
                                return null;
                              }
                            },
                            onChanged: (value) {
                              setState(() {});
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: SizedBox(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Unit",
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                          const SizedBox(height: 8),
                          TextFormField(
                            decoration: const InputDecoration(
                              filled: true,
                              fillColor: Color(0xffEEEEEE),
                              border: OutlineInputBorder(
                                borderSide: BorderSide.none,
                              ),
                              hintText: "Unit",
                              contentPadding: EdgeInsets.symmetric(horizontal: 10),
                            ),
                            controller: unit,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return "Unit is Must";
                              } else {
                                return null;
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              SizedBox(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Rate",
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                      ],
                      decoration: const InputDecoration(
                        filled: true,
                        fillColor: Color(0xffEEEEEE),
                        border: OutlineInputBorder(
                          borderSide: BorderSide.none,
                        ),
                        hintText: "Rate",
                        contentPadding: EdgeInsets.symmetric(horizontal: 10),
                      ),
                      controller: rate,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Rate is Must";
                        } else {
                          return null;
                        }
                      },
                      onChanged: (value) {
                        setState(() {});
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              Center(
                child: Text(
                  "Total = ${currentProductTotal()}",
                  style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

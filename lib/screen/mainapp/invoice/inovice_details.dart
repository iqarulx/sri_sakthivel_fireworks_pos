import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sri_sakthivel_fireworks_pos/screen/mainapp/invoice/invoice_creation.dart';
import 'package:sri_sakthivel_fireworks_pos/screen/mainapp/invoice/pdf/invoice_pdf_view.dart';

import '../../../firebase/datamodel/invoice_model.dart';

class InvoiceDetails extends StatefulWidget {
  final InvoiceModel invoice;
  const InvoiceDetails({super.key, required this.invoice});

  @override
  State<InvoiceDetails> createState() => _InvoiceDetailsState();
}

class _InvoiceDetailsState extends State<InvoiceDetails> {
  InvoiceModel? invoice;
  openDialog() async {
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Print Options"),
        actions: [
          TextButton(
            onPressed: () {},
            child: const Text("Cancel"),
          ),
        ],
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              onTap: () {
                Navigator.pop(context, "Original");
              },
              title: const Text("Original"),
            ),
            ListTile(
              onTap: () {
                Navigator.pop(context, "Duplicate");
              },
              title: const Text("Duplicate"),
            ),
            ListTile(
              onTap: () {
                Navigator.pop(context, "Triplicate");
              },
              title: const Text("Triplicate"),
            ),
          ],
        ),
      ),
    ).then((result) {
      if (result != null) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => InvoicePdfView(
              title: result,
              invoice: widget.invoice,
            ),
          ),
        );
      }
    });
  }

  TableRow tableRow(String? title, String? value) {
    return TableRow(
      children: [
        Padding(
          padding: const EdgeInsets.all(3),
          child: Text(
            title ?? "",
            style: Theme.of(context).textTheme.titleSmall,
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(3),
          child: Text(
            value ?? "",
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ),
      ],
    );
  }

  String itemCount() {
    String result = "0";
    int count = 0;
    for (var element in invoice!.listingProducts!) {
      log(element.qty.toString());
      count += element.qty!;
    }
    result = count.toString();
    return result;
  }

  initFn() {
    invoice = widget.invoice;
  }

  @override
  void initState() {
    initFn();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffEEEEEE),
      appBar: AppBar(
        title: const Text("Bill of Supply"),
        actions: [
          IconButton(
            splashRadius: 20,
            onPressed: () {
              openDialog();
            },
            icon: const Icon(
              Icons.print,
            ),
          ),
          IconButton(
            splashRadius: 20,
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => InvoiceCreation(invoice: invoice),
                ),
              );
            },
            icon: const Icon(
              Icons.edit,
            ),
          ),
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Table(
                  children: [
                    TableRow(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(3),
                          child: Text(
                            "Invoice",
                            style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(3),
                          child: Text(invoice!.billNo ?? ""),
                        ),
                      ],
                    ),
                    TableRow(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(3),
                          child: Text(
                            "Date",
                            style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(3),
                          child: Text(
                            invoice!.biilDate != null ? DateFormat("dd-MM-yyyy").format(invoice!.biilDate!) : "",
                          ),
                        ),
                      ],
                    ),
                    TableRow(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(3),
                          child: Text(
                            "Total Amount",
                            style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(3),
                          child: Text(
                            "₹${invoice!.totalBillAmount ?? ""}",
                            style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                                  fontWeight: FontWeight.bold,
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
          Container(
            margin: const EdgeInsets.only(top: 10),
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Table(
                  children: [
                    TableRow(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(2),
                          child: Text(
                            "Party Name",
                            style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(2),
                          child: Text(invoice!.partyName ?? ""),
                        ),
                      ],
                    ),
                    TableRow(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(2),
                          child: Text(
                            "Address",
                            style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(2),
                          child: Text(invoice!.address ?? ""),
                        ),
                      ],
                    ),
                    TableRow(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(2),
                          child: Text(
                            "Delivery Address",
                            style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(2),
                          child: Text(invoice!.deliveryaddress ?? ""),
                        ),
                      ],
                    ),
                    TableRow(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(2),
                          child: Text(
                            "Transport Name",
                            style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(2),
                          child: Text(
                            invoice!.transportName ?? "",
                          ),
                        ),
                      ],
                    ),
                    TableRow(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(2),
                          child: Text(
                            "Transport Number",
                            style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(2),
                          child: Text(
                            invoice!.transportNumber ?? "",
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
          Container(
            margin: const EdgeInsets.only(top: 10),
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "Price",
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(
                  height: 10,
                ),
                Table(
                  children: [
                    tableRow(
                      "Total",
                      "₹${widget.invoice.price?.total?.toStringAsFixed(2) ?? ""}",
                    ),
                    tableRow(
                      "Discount",
                      "₹${widget.invoice.price?.discountValue?.toStringAsFixed(2) ?? ""}",
                    ),
                    tableRow(
                      "Extra Discount",
                      "₹${widget.invoice.price?.extraDiscountValue?.toStringAsFixed(2) ?? ""}",
                    ),
                    tableRow(
                      "Package Charge",
                      "₹${widget.invoice.price?.packageValue?.toStringAsFixed(2) ?? ""}",
                    ),
                  ],
                ),
              ],
            ),
          ),
          Container(
            margin: const EdgeInsets.only(top: 10),
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
                      "Products(${invoice!.listingProducts!.length})",
                      style: Theme.of(context).textTheme.titleLarge!.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    Text(
                      "Items(${itemCount()})",
                      style: Theme.of(context).textTheme.bodySmall!.copyWith(
                            color: Colors.grey,
                          ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Table(
                  columnWidths: const {
                    0: FlexColumnWidth(1.5),
                    1: FlexColumnWidth(7),
                    2: FlexColumnWidth(1.5),
                    3: FlexColumnWidth(4),
                    4: FlexColumnWidth(4),
                  },
                  children: [
                    TableRow(
                      children: [
                        Center(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 5),
                            child: Text(
                              "#",
                              style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 5),
                          child: Text(
                            "Name",
                            style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 5),
                          child: Text(
                            "qty",
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 5),
                          child: Text(
                            "Rate",
                            textAlign: TextAlign.right,
                            style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 5),
                          child: Text(
                            "Total",
                            textAlign: TextAlign.right,
                            style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                        ),
                      ],
                    ),
                    for (int index = 0; index < invoice!.listingProducts!.length; index++)
                      TableRow(
                        decoration: BoxDecoration(
                          border: invoice!.listingProducts!.length != (index + 1)
                              ? Border(
                                  bottom: BorderSide(
                                    color: Colors.grey.shade300,
                                  ),
                                )
                              : null,
                        ),
                        children: [
                          Center(
                            child: Padding(
                              padding: const EdgeInsets.all(2),
                              child: Text(
                                (index + 1).toString(),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(2),
                            child: Text(invoice!.listingProducts?[index].productName ?? ""),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(2),
                            child: Text(
                              invoice!.listingProducts![index].qty.toString(),
                              textAlign: TextAlign.center,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(2),
                            child: Text(
                              double.parse(invoice!.listingProducts![index].rate.toString()).toStringAsFixed(2),
                              textAlign: TextAlign.right,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(2),
                            child: Text(
                              double.parse(invoice!.listingProducts![index].total.toString()).toStringAsFixed(2),
                              textAlign: TextAlign.right,
                            ),
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
  }
}

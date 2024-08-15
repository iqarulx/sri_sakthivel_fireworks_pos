import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sri_sakthivel_fireworks_pos/utlities/utlities.dart';

class InvoiceFilter extends StatefulWidget {
  const InvoiceFilter({super.key});

  @override
  State<InvoiceFilter> createState() => _InvoiceFilterState();
}

class _InvoiceFilterState extends State<InvoiceFilter> {
  TextEditingController fromDate = TextEditingController();
  TextEditingController toDate = TextEditingController();

  Future<DateTime?> datePicker() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2022),
      lastDate: DateTime.now(),
    );
    return picked;
  }

  fromDatePicker() async {
    final DateTime? picked = await datePicker();
    if (picked != null) {
      setState(() {
        fromDate.text = DateFormat('yyyy-MM-dd').format(picked);
      });
    }
  }

  toDatePicker() async {
    final DateTime? picked = await datePicker();

    if (picked != null) {
      setState(() {
        toDate.text = DateFormat('yyyy-MM-dd').format(picked);
      });
    }
  }

  applyNow() {
    if (fromDate.text.isEmpty && toDate.text.isEmpty) {
      log("Choose any one Form");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Choose any one Form'),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          margin: EdgeInsets.only(
            bottom: MediaQuery.of(context).size.height - 100,
            right: 20,
            left: 20,
          ),
        ),
      );
      // snackBarCustom(context, false, "Choose any one Form");
    } else {
      log("its Worked");
      if (fromDate.text.isNotEmpty && toDate.text.isEmpty) {
        log("Choose To Date is Must");
        snackBarCustom(context, false, "Choose To Date is Must");
      } else if (fromDate.text.isEmpty && toDate.text.isNotEmpty) {
        log("its Worked");
        if (fromDate.text.isEmpty) {
          log("Choose From Date is Must");
          snackBarCustom(context, false, "Choose From Date is Must");
        }
      } else {
        log("is Woked");
        Navigator.pop(context, {
          "FromDate": DateTime.parse(fromDate.text),
          "ToDate": DateTime.parse(toDate.text),
        });
      }
    }
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 10,
        right: 10,
        top: 10,
        bottom: MediaQuery.of(context).viewInsets.bottom + 10,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Invoice Fillter",
                  style: Theme.of(context).textTheme.titleLarge!.copyWith(
                        color: Colors.black,
                      ),
                ),
                Container(
                  decoration: const BoxDecoration(
                    color: Color(0xfff1f5f9),
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    splashRadius: 20,
                    constraints: const BoxConstraints(
                      maxWidth: 40,
                      maxHeight: 40,
                      minWidth: 40,
                      minHeight: 40,
                    ),
                    padding: const EdgeInsets.all(0),
                    style: IconButton.styleFrom(
                      backgroundColor: Colors.grey,
                    ),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    icon: const Icon(Icons.close),
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(10),
            child: Form(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "From Date",
                    style: Theme.of(context).textTheme.labelLarge!.copyWith(color: Colors.black54),
                  ),
                  const SizedBox(
                    height: 8,
                  ),
                  TextFormField(
                    controller: fromDate,
                    readOnly: true,
                    decoration: const InputDecoration(
                      hintText: "Form Date",
                    ),
                    onTap: () => fromDatePicker(),
                  ),
                  const SizedBox(
                    height: 14,
                  ),
                  Text(
                    "To Date",
                    style: Theme.of(context).textTheme.labelLarge!.copyWith(color: Colors.black54),
                  ),
                  const SizedBox(
                    height: 8,
                  ),
                  TextFormField(
                    controller: toDate,
                    readOnly: true,
                    decoration: const InputDecoration(
                      hintText: "To Date",
                    ),
                    onTap: () => toDatePicker(),
                  ),
                  const SizedBox(
                    height: 22,
                  ),
                  GestureDetector(
                    onTap: () {
                      applyNow();
                    },
                    child: Container(
                      height: 48,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Theme.of(context).primaryColor,
                        borderRadius: BorderRadius.circular(100),
                      ),
                      child: Center(
                        child: Text(
                          "Apply Now",
                          style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                                color: Colors.white,
                              ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}

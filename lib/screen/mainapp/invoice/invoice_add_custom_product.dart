import 'package:flutter/material.dart';

class InvoiceAddCustomProduct extends StatefulWidget {
  const InvoiceAddCustomProduct({super.key});

  @override
  State<InvoiceAddCustomProduct> createState() => _InvoiceAddCustomProductState();
}

class _InvoiceAddCustomProductState extends State<InvoiceAddCustomProduct> {
  TextEditingController customProduct = TextEditingController();
  var formkey = GlobalKey<FormState>();
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Custom Product"),
      content: Form(
        key: formkey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
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
                  TextFormField(
                    decoration: const InputDecoration(
                      filled: true,
                      fillColor: Color(0xffEEEEEE),
                      border: OutlineInputBorder(
                        borderSide: BorderSide.none,
                      ),
                      hintText: "Product Name",
                      contentPadding: EdgeInsets.symmetric(horizontal: 10),
                    ),
                    controller: customProduct,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "Product Name is Must";
                      } else {
                        return null;
                      }
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
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
                  if (formkey.currentState!.validate()) {
                    Navigator.pop(context, customProduct.text);
                  }
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
    );
  }
}

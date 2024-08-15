import 'package:flutter/material.dart';
import 'package:sri_sakthivel_fireworks_pos/firebase/datamodel/invoice_model.dart';

class ProductListingDialog extends StatefulWidget {
  final List<InvoiceProductModel> productDataList;
  const ProductListingDialog({super.key, required this.productDataList});

  @override
  State<ProductListingDialog> createState() => _ProductListingDialogState();
}

class _ProductListingDialogState extends State<ProductListingDialog> {
  TextEditingController search = TextEditingController();

  List<InvoiceProductModel> tmpproductDataList = [];

  searchProduct() {
    if (search.text.isNotEmpty) {
      var dataList = widget.productDataList.where((element) {
        if (element.productName!
            .toLowerCase()
            .replaceAll(" ", "")
            .startsWith(search.text.toLowerCase().replaceAll(" ", ""))) {
          return true;
        } else if (element.productName!
            .toLowerCase()
            .replaceAll(" ", "")
            .contains(search.text.toLowerCase().replaceAll(" ", ""))) {
          return true;
        } else {
          return false;
        }
      });
      setState(() {
        tmpproductDataList.clear();
        tmpproductDataList.addAll(dataList);
      });
    } else {
      setState(() {
        tmpproductDataList.clear();
        tmpproductDataList.addAll(widget.productDataList);
      });
    }
  }

  @override
  void initState() {
    tmpproductDataList.addAll(widget.productDataList);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: TextFormField(
        onChanged: (value) {
          searchProduct();
        },
        decoration: const InputDecoration(
          filled: true,
          fillColor: Color(0xffEEEEEE),
          border: OutlineInputBorder(
            borderSide: BorderSide.none,
          ),
          hintText: "Search",
          contentPadding: EdgeInsets.symmetric(horizontal: 10),
          prefixIcon: Icon(Icons.search),
        ),
        controller: search,
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: const Text("Cancel"),
        ),
      ],
      content: SizedBox(
        width: double.infinity,
        height: MediaQuery.of(context).size.height * 0.5,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (int i = 0; i < tmpproductDataList.length; i++)
                GestureDetector(
                  onTap: () {
                    Navigator.pop(context, tmpproductDataList[i]);
                  },
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(5),
                      color: Colors.white,
                    ),
                    margin: const EdgeInsets.only(top: 10),
                    child: Text(tmpproductDataList[i].productName ?? ""),
                  ),
                )
            ],
          ),
        ),
        // child: ListView.builder(
        //   // shrinkWrap: true,
        //   // primary: false,
        //   // physics: const NeverScrollableScrollPhysics(),
        //   itemCount: tmpproductDataList.length,
        //   itemBuilder: (context, index) {
        //     return GestureDetector(
        //       onTap: () {
        //         Navigator.pop(context, tmpproductDataList[index]);
        //       },
        //       child: Container(
        //         padding: const EdgeInsets.all(10),
        //         decoration: BoxDecoration(borderRadius: BorderRadius.circular(5), color: Colors.white),
        //         margin: const EdgeInsets.only(top: 10),
        //         child: Text(tmpproductDataList[index].productName ?? ""),
        //       ),
        //     );
        //   },
        // ),
      ),
    );
  }
}

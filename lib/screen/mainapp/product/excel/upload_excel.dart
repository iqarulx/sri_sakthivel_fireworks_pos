import 'package:flutter/material.dart';
import 'package:sri_sakthivel_fireworks_pos/screen/mainapp/product/excel/upload_page.dart';
import 'package:sri_sakthivel_fireworks_pos/utlities/varibales.dart';

import 'excel_result.dart';

late TabController uploadExcelController;

class UploadExcel extends StatefulWidget {
  const UploadExcel({super.key});

  @override
  State<UploadExcel> createState() => _UploadExcelState();
}

class _UploadExcelState extends State<UploadExcel> with SingleTickerProviderStateMixin {
  @override
  void initState() {
    super.initState();
    excelData.clear();
    uploadExcelController = TabController(length: 2, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: const Color(0xffEEEEEE),
        appBar: AppBar(
          title: const Text("Upload Excel"),
          bottom: PreferredSize(
            preferredSize: const Size(double.infinity, 50),
            child: Container(
              alignment: Alignment.centerLeft,
              child: TabBar(
                controller: uploadExcelController,
                indicatorSize: TabBarIndicatorSize.tab,
                isScrollable: true,
                indicatorColor: Colors.white,
                tabs: const [
                  Tab(
                    text: "Upload Excel",
                  ),
                  Tab(
                    text: "View Products",
                  )
                ],
              ),
            ),
          ),
        ),
        body: TabBarView(
          controller: uploadExcelController,
          children: const [
            UploadExcelUI(),
            ExcelResultUI(),
          ],
        ),
      ),
    );
  }
}

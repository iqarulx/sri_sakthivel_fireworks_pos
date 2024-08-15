import 'dart:developer';

import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:sri_sakthivel_fireworks_pos/provider/download_file_provider.dart';
import 'package:sri_sakthivel_fireworks_pos/screen/mainapp/product/excel/upload_excel.dart';
import 'package:sri_sakthivel_fireworks_pos/utlities/utlities.dart';
import 'package:sri_sakthivel_fireworks_pos/utlities/varibales.dart';

import '../../../../provider/excel_reader_provider.dart';
import '../../../../provider/file_picker_provider.dart';

class UploadExcelUI extends StatefulWidget {
  const UploadExcelUI({super.key});

  @override
  State<UploadExcelUI> createState() => _UploadExcelUIState();
}

class _UploadExcelUIState extends State<UploadExcelUI> {
  uploadExcel() async {
    loading(context);
    try {
      await FilePickerProvider().openGalary(fileType: FileProviderType.excel).then((value) async {
        if (value != null) {
          await ExcelReaderProvider().readExcelData(file: value).then((excelResult) {
            if (excelResult != null) {
              Navigator.pop(context);
              setState(() {
                excelData.clear();
                excelData.addAll(excelResult);
                uploadExcelController.animateTo(
                  1,
                  duration: const Duration(milliseconds: 600),
                  curve: Curves.linear,
                );
              });
            } else {
              Navigator.pop(context);
            }
          });
        } else {
          Navigator.pop(context);
        }
      });
    } catch (e) {
      Navigator.pop(context);
      snackBarCustom(context, false, e.toString());
    }
  }

  downloadTemplate() async {
    loading(context);
    try {
      await DownloadFilesOnline(
        urlLink:
            "https://firebasestorage.googleapis.com/v0/b/srisoftpos.appspot.com/o/product_templete%2Fproduct_template.xlsx?alt=media&token=a9aa597d-9bc2-4d79-b978-476bf0942e16",
        fileName: 'Product Templete',
        fileext: 'xlsx',
      ).startDownload().then((value) {
        Navigator.pop(context);
        if (value != null) {
          downloadFileSnackBarCustom(context, isSuccess: true, msg: 'Successfully Download File', path: value);
          // snackBarCustom(context, true, "");
        } else {
          snackBarCustom(context, false, "Something went Worng");
        }
      });
    } catch (e) {
      log(e.toString());
      Navigator.pop(context);
      snackBarCustom(context, false, e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        Center(
          child: Padding(
            padding: const EdgeInsets.all(10.0),
            child: Container(
              constraints: const BoxConstraints(
                maxWidth: 600,
              ),
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.only(
                      left: 15,
                      top: 5,
                      bottom: 5,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Upload Excel",
                          style: Theme.of(context).textTheme.labelLarge,
                        ),
                        IconButton(
                          splashRadius: 20,
                          onPressed: () {},
                          icon: const Icon(
                            Icons.info_outline,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Divider(
                    height: 0,
                    color: Colors.grey,
                  ),
                  Padding(
                    padding: const EdgeInsets.all(15.0),
                    child: DottedBorder(
                      borderType: BorderType.RRect,
                      radius: const Radius.circular(5),
                      padding: const EdgeInsets.all(0),
                      dashPattern: const [6, 3],
                      color: Theme.of(context).primaryColor,
                      strokeWidth: 1,
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                          vertical: 50,
                          horizontal: 30,
                        ),
                        decoration: BoxDecoration(
                          color: Theme.of(context).primaryColor.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(5),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Image.network(
                              'https://icons.iconarchive.com/icons/iconsmind/outline/512/File-Excel-icon.png',
                              height: 100,
                            ),
                            const SizedBox(
                              height: 20,
                            ),
                            Text(
                              "Select a Excel file to upload",
                              textAlign: TextAlign.center,
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                            const SizedBox(
                              height: 10,
                            ),
                            Text(
                              "First download temple add modeify data to upload",
                              textAlign: TextAlign.center,
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                            const SizedBox(
                              height: 15,
                            ),
                            GestureDetector(
                              onTap: () {
                                uploadExcel();
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 15,
                                  vertical: 10,
                                ),
                                decoration: BoxDecoration(
                                  color: Theme.of(context).primaryColor,
                                  borderRadius: BorderRadius.circular(5),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(
                                      Icons.file_upload_outlined,
                                      color: Colors.white,
                                    ),
                                    const SizedBox(
                                      width: 10,
                                    ),
                                    Text(
                                      "Upload",
                                      style: Theme.of(context).textTheme.titleMedium!.copyWith(color: Colors.white),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        Center(
          child: Padding(
            padding: const EdgeInsets.only(
              left: 10,
              right: 10,
              bottom: 10,
            ),
            child: Container(
              constraints: const BoxConstraints(
                maxWidth: 600,
              ),
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.only(
                      left: 15,
                      top: 5,
                      bottom: 5,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Download Templete",
                          style: Theme.of(context).textTheme.labelLarge,
                        ),
                        IconButton(
                          splashRadius: 20,
                          onPressed: () {},
                          icon: const Icon(
                            Icons.info_outline,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Divider(
                    height: 0,
                    color: Colors.grey,
                  ),
                  Padding(
                    padding: const EdgeInsets.all(15.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ListTile(
                          onTap: () {},
                          contentPadding: const EdgeInsets.all(0),
                          leading: Container(
                            height: 60,
                            width: 60,
                            decoration: BoxDecoration(
                              color: Colors.grey.shade200,
                              borderRadius: BorderRadius.circular(5),
                            ),
                            child: Center(
                              child: Image.network(
                                'https://icons.iconarchive.com/icons/iconsmind/outline/512/File-Excel-icon.png',
                                height: 35,
                              ),
                            ),
                          ),
                          title: Text(
                            "Product Template",
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          subtitle: Text(
                            "Download Sample Product Excel File",
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                          trailing: IconButton(
                            onPressed: () {
                              downloadTemplate();
                            },
                            icon: const Icon(Icons.file_download_outlined),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

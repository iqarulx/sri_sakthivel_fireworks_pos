import 'dart:developer';
import 'dart:typed_data';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:sri_sakthivel_fireworks_pos/provider/customer_excel_creation.dart';
import 'package:sri_sakthivel_fireworks_pos/provider/download_file_provider.dart';
import 'package:sri_sakthivel_fireworks_pos/screen/mainapp/customer/add_customer.dart';
import 'package:sri_sakthivel_fireworks_pos/screen/mainapp/customer/customerdetails.dart';
import 'package:sri_sakthivel_fireworks_pos/screen/ui/commenwidget.dart';
import 'package:sri_sakthivel_fireworks_pos/utlities/utlities.dart';

import '../../../firebase/datamodel/datamodel.dart';
import '../../../firebase/firestore_provider.dart';
import '../../../utlities/provider/localdb.dart';
import '../homelanding.dart';

PageController customerListingcontroller = PageController();

class CustomerListing extends StatefulWidget {
  const CustomerListing({super.key});

  @override
  State<CustomerListing> createState() => _CustomerListingState();
}

class _CustomerListingState extends State<CustomerListing> {
  List<CustomerDataModel> customerDataList = [];
  List<CustomerDataModel> tmpCustomerDataList = [];

  TextEditingController searchForm = TextEditingController();

  Future getCustomerInfo() async {
    try {
      FireStoreProvider provider = FireStoreProvider();
      var cid = await LocalDbProvider().fetchInfo(type: LocalData.companyid);

      if (cid != null) {
        final result = await provider.customerListing(cid: cid);
        if (result!.docs.isNotEmpty) {
          log(result.docs.length.toString());
          setState(() {
            customerDataList.clear();
            tmpCustomerDataList.clear();
          });
          for (var element in result.docs) {
            log("Worked ${element.data()} ");
            CustomerDataModel model = CustomerDataModel();
            model.address = element["address"].toString();
            model.mobileNo = element["mobile_no"].toString();
            model.city = element["city"].toString();
            model.customerName = element["customer_name"].toString();
            model.email = element["email"].toString();
            model.state = element["state"]?.toString();
            model.docID = element.id;
            setState(() {
              customerDataList.add(model);
            });
          }
          setState(() {
            tmpCustomerDataList.addAll(customerDataList);
          });
          return customerDataList;
        }
      }
      return null;
    } catch (e) {
      throw e.toString();
    }
  }

  downloadExcelData() async {
    try {
      loading(context);
      await CustomerExcel(customerDataList: customerDataList).createCustomerExcel().then((value) async {
        if (value != null) {
          Uint8List fileData = Uint8List.fromList(value);
          await DownloadFileOffline(
            fileData: fileData,
            fileName: "Customer Excel",
            fileext: 'xlsx',
          ).startDownload().then((value) {
            if (value != null && value.isNotEmpty) {
              Navigator.pop(context);
              downloadFileSnackBarCustom(
                context,
                isSuccess: true,
                msg: "Customer Excel Download Successfully",
                path: value,
              );
            }
          }).catchError((onError) {
            Navigator.pop(context);
            snackBarCustom(context, false, onError.toString());
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

  searchCustomerFun(String? value) async {
    if (value != null && searchForm.text.isNotEmpty) {
      if (value.isNotEmpty) {
        log("Workeding");
        Iterable<CustomerDataModel> tmpList = tmpCustomerDataList.where((element) {
          return element.customerName!
                  .toLowerCase()
                  .replaceAll(' ', '')
                  .startsWith(value.toLowerCase().replaceAll(' ', '')) ||
              element.mobileNo!.toLowerCase().replaceAll(' ', '').startsWith(
                    value.toLowerCase().replaceAll(' ', ''),
                  );
        });
        log("is Working");
        if (tmpList.isNotEmpty) {
          setState(() {
            customerDataList.clear();
          });
          for (var element in tmpList) {
            setState(() {
              customerDataList.add(element);
            });
          }
        }
      }
    } else {
      setState(() {
        customerDataList.clear();
        customerDataList.addAll(tmpCustomerDataList);
      });
    }
  }

  late Future customerHandler;

  @override
  void initState() {
    super.initState();
    customerHandler = getCustomerInfo();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffEEEEEE),
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            homeKey.currentState!.openDrawer();
          },
          icon: const Icon(Icons.menu),
        ),
        title: const Text("Customer"),
        actions: [
          IconButton(
            onPressed: () {
              downloadExcelData();
            },
            splashRadius: 20,
            icon: const Icon(
              Icons.file_download_outlined,
            ),
          ),
          IconButton(
            onPressed: () {
              // openModelBottomSheat(context);

              Navigator.push(
                context,
                CupertinoPageRoute(
                  builder: (context) => const AddCustomer(),
                ),
              );
            },
            splashRadius: 20,
            icon: const Icon(
              Icons.add,
            ),
          ),
        ],
      ),
      body: FutureBuilder(
        future: customerHandler,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return Padding(
              padding: const EdgeInsets.all(10.0),
              child: Container(
                height: double.infinity,
                width: double.infinity,
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15),
                ),
                child: customerDataList.isNotEmpty
                    ? Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(
                            child: SearchForm(
                              controller: searchForm,
                              formName: "Search Customer",
                              prefixIcon: Icons.search,
                              onChanged: (v) {
                                log("Worked");
                                searchCustomerFun(v);
                              },
                            ),
                          ),
                          Expanded(
                            child: RefreshIndicator(
                              onRefresh: () async {
                                setState(() {
                                  customerHandler = getCustomerInfo();
                                });
                              },
                              child: ListView.builder(
                                itemCount: customerDataList.length,
                                itemBuilder: (context, index) {
                                  return Column(
                                    children: [
                                      ListTile(
                                        contentPadding: const EdgeInsets.all(0),
                                        onTap: () {
                                          Navigator.push(
                                            context,
                                            CupertinoPageRoute(
                                              builder: (context) => CustomerDetails(
                                                customeData: customerDataList[index],
                                              ),
                                            ),
                                          );
                                        },
                                        leading: Container(
                                          height: 50,
                                          width: 50,
                                          decoration: BoxDecoration(
                                            color: Colors.grey.shade200,
                                            shape: BoxShape.circle,
                                          ),
                                          child: const Center(
                                            child: Icon(
                                              Icons.person,
                                              color: Colors.grey,
                                            ),
                                          ),
                                        ),
                                        title: Text(
                                          customerDataList[index].customerName.toString(),
                                        ),
                                        subtitle: Text(
                                          customerDataList[index].mobileNo.toString(),
                                          style: TextStyle(
                                            color: Colors.grey.shade400,
                                            fontSize: 13,
                                          ),
                                        ),
                                        trailing: const Icon(Icons.chevron_right_outlined),
                                      ),
                                      Divider(
                                        height: 0,
                                        color: Colors.grey.shade300,
                                      ),
                                    ],
                                  );
                                },
                              ),
                            ),
                          ),
                        ],
                      )
                    : EmptyListPage(
                        assetsPath: 'assets/empty_list3.svg',
                        title: 'No Customer Data',
                        content:
                            'You have not create any Customer, so first you have create user using add user button below',
                        addFun: () {
                          Navigator.push(
                            context,
                            CupertinoPageRoute(
                              builder: (context) => const AddCustomer(),
                            ),
                          );
                        },
                        refreshFun: () {
                          setState(() {
                            customerHandler = getCustomerInfo();
                          });
                        },
                      ),
              ),
            );
          } else if (snapshot.connectionState == ConnectionState.done && snapshot.hasError) {
            return Center(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                ),
                margin: const EdgeInsets.all(20),
                padding: const EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Center(
                      child: Text(
                        "Failed",
                        style: TextStyle(
                          color: Colors.red,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 15,
                    ),
                    Text(
                      snapshot.error.toString() == "null" ? "Something went Wrong" : snapshot.error.toString(),
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.black54,
                        fontSize: 13,
                      ),
                    ),
                    Center(
                      child: TextButton.icon(
                        onPressed: () {
                          setState(() {
                            customerHandler = getCustomerInfo();
                          });
                        },
                        icon: const Icon(Icons.refresh),
                        label: const Text(
                          "Refresh",
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          } else {
            return futureLoading(context);
          }
        },
      ),
    );
  }
}

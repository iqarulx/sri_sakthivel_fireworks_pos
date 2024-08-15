import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../firebase/datamodel/datamodel.dart';
import '../../../firebase/firestore_provider.dart';
import '../../../utlities/provider/localdb.dart';
import '../../../utlities/utlities.dart';
import '../../../utlities/validation.dart';
import '../../../utlities/varibales.dart';
import '../../ui/commenwidget.dart';

class AddCustomerBox extends StatefulWidget {
  const AddCustomerBox({super.key});

  @override
  State<AddCustomerBox> createState() => _AddCustomerBoxState();
}

class _AddCustomerBoxState extends State<AddCustomerBox> {
  TextEditingController customerName = TextEditingController();
  TextEditingController mobileNo = TextEditingController();
  TextEditingController email = TextEditingController();
  TextEditingController address = TextEditingController();

  var addCustomerKey = GlobalKey<FormState>();

  String? city;
  String? state;
  List<DropdownMenuItem<String>> stateMenuList = [];
  List<DropdownMenuItem<String>> cityMenuList = [];

  getState() {
    setState(() {
      stateMenuList.clear();
    });
    for (var element in stateMapList.keys) {
      setState(() {
        stateMenuList.add(
          DropdownMenuItem(
            value: element,
            child: Text(
              element.toString(),
            ),
          ),
        );
      });
    }
  }

  getcity() {
    if (state != null && state!.isNotEmpty) {
      setState(() {
        cityMenuList.clear();
      });
      for (var element in stateMapList[state]!) {
        setState(() {
          cityMenuList.add(
            DropdownMenuItem(
              value: element,
              child: Text(
                element.toString(),
              ),
            ),
          );
        });
      }
    }
  }

  checkValidation() async {
    loading(context);
    FocusManager.instance.primaryFocus!.unfocus();
    try {
      if (addCustomerKey.currentState!.validate()) {
        await LocalDbProvider().fetchInfo(type: LocalData.companyid).then((cid) async {
          if (cid != null) {
            var customerData = CustomerDataModel();
            customerData.companyID = cid;
            customerData.address = address.text;
            customerData.city = city;
            customerData.customerName = customerName.text;
            customerData.email = email.text;
            customerData.mobileNo = mobileNo.text;

            await FireStoreProvider().registerCustomer(customerData: customerData).then((value) {
              Navigator.pop(context);
              if (value.id.isNotEmpty) {
                CustomerDataModel cusdata = CustomerDataModel();
                cusdata.companyID = cid;
                cusdata.address = address.text;
                cusdata.city = city;
                cusdata.customerName = customerName.text;
                cusdata.email = email.text;
                cusdata.mobileNo = mobileNo.text;
                Navigator.pop(context, cusdata);

                snackBarCustom(
                  context,
                  true,
                  "Successfully Created New Customer",
                );
              } else {
                snackBarCustom(context, false, "Failed to Create New Customer");
              }
            });
          } else {
            Navigator.pop(context);
            snackBarCustom(context, false, "Company Details Not Fetch");
          }
        });
      } else {
        Navigator.pop(context);
      }
    } catch (e) {
      Navigator.pop(context);
      snackBarCustom(context, false, e.toString());
    }
  }

  @override
  void initState() {
    super.initState();
    getState();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: SafeArea(
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
            ),
            margin: const EdgeInsets.all(15),
            constraints: BoxConstraints(
              maxWidth: 600,
              maxHeight: MediaQuery.of(context).size.height * 0.84,
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Scaffold(
                resizeToAvoidBottomInset: false,
                appBar: AppBar(
                  iconTheme: const IconThemeData(color: Colors.black),
                  backgroundColor: Colors.white,
                  elevation: 0,
                  systemOverlayStyle: const SystemUiOverlayStyle(
                    statusBarIconBrightness: Brightness.dark,
                    statusBarColor: Colors.transparent,
                  ),
                  leading: IconButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    splashRadius: 20,
                    icon: const Icon(
                      Icons.close,
                      color: Colors.black,
                    ),
                  ),
                  titleSpacing: 0,
                  title: const Text(
                    "Add New Customer",
                    style: TextStyle(
                      color: Colors.black,
                    ),
                  ),
                ),
                bottomNavigationBar: SizedBox(
                  height: 65,
                  child: BottomAppBar(
                    child: Padding(
                      padding: const EdgeInsets.all(8),
                      child: Row(
                        children: [
                          Expanded(
                            flex: 2,
                            child: outlinButton(
                              context,
                              onTap: () {
                                Navigator.pop(context);
                              },
                              btnName: "Cancel",
                            ),
                          ),
                          const SizedBox(
                            width: 10,
                          ),
                          Expanded(
                            flex: 4,
                            child: fillButton(
                              context,
                              onTap: () {
                                checkValidation();
                              },
                              btnName: "Submit",
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                body: Container(
                  height: double.infinity,
                  width: double.infinity,
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Form(
                    key: addCustomerKey,
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          InputForm(
                            controller: customerName,
                            lableName: "Name",
                            formName: "Customer Name",
                            prefixIcon: Icons.person,
                            validation: (p0) {
                              return FormValidation().commonValidation(
                                input: p0,
                                isMandorty: true,
                                formName: 'Customer Name',
                                isOnlyCharter: false,
                              );
                            },
                          ),
                          InputForm(
                            controller: mobileNo,
                            lableName: "Mobile No",
                            formName: "Mobile Number",
                            prefixIcon: Icons.phone,
                            keyboardType: TextInputType.phone,
                            validation: (p0) {
                              return FormValidation().phoneValidation(
                                input: p0.toString(),
                                isMandorty: true,
                                lableName: 'Mobile Number',
                              );
                            },
                          ),
                          InputForm(
                            controller: email,
                            lableName: "Email",
                            formName: "Email Address",
                            prefixIcon: Icons.alternate_email,
                            keyboardType: TextInputType.emailAddress,
                            validation: (p0) {
                              return FormValidation().emailValidation(
                                input: p0.toString(),
                                lableName: "Email Address",
                                isMandorty: false,
                              );
                            },
                          ),
                          InputForm(
                            controller: address,
                            lableName: "Address",
                            formName: "Address",
                            prefixIcon: Icons.place_outlined,
                            keyboardType: TextInputType.emailAddress,
                            validation: (p0) {
                              return FormValidation().commonValidation(
                                input: p0,
                                isMandorty: true,
                                formName: 'Address',
                                isOnlyCharter: false,
                              );
                            },
                          ),
                          DropDownForm(
                            onChange: (v) {
                              setState(() {
                                state = v!;
                                city = null;
                              });
                              getcity();
                            },
                            labelName: 'State',
                            value: state,
                            listItems: stateMenuList,
                            prefixIcon: Icons.map_outlined,
                            formName: "State",
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          DropDownForm(
                            onChange: (v) {
                              setState(() {
                                city = v!;
                              });
                            },
                            labelName: 'City',
                            value: city,
                            listItems: cityMenuList,
                            prefixIcon: Icons.explore_outlined,
                            formName: 'City',
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

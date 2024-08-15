import 'package:flutter/material.dart';
import 'package:sri_sakthivel_fireworks_pos/firebase/datamodel/datamodel.dart';
import 'package:sri_sakthivel_fireworks_pos/screen/ui/commenwidget.dart';
import 'package:sri_sakthivel_fireworks_pos/utlities/validation.dart';

import '../../../firebase/firestore_provider.dart';
import '../../../utlities/provider/localdb.dart';
import '../../../utlities/utlities.dart';
import '../../../utlities/varibales.dart';
import '../../ui/city_alert.dart';
import '../../ui/state_alert.dart';

class AddCustomer extends StatefulWidget {
  const AddCustomer({super.key});

  @override
  State<AddCustomer> createState() => _AddCustomerState();
}

class _AddCustomerState extends State<AddCustomer> {
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
            customerData.state = state;

            await FireStoreProvider().registerCustomer(customerData: customerData).then((value) {
              Navigator.pop(context);
              if (value.id.isNotEmpty) {
                setState(() {
                  customerName.clear();
                  mobileNo.clear();
                  email.clear();
                  address.clear();
                  state = null;
                  city = null;
                  cityMenuList.clear();
                });
                snackBarCustom(context, true, "Successfully Created New Customer");
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

  showStateAlert() async {
    await showDialog(
      context: context,
      builder: (context) {
        return const StateAlert();
      },
    ).then((value) {
      if (value != null) {
        setState(() {
          state = value;
          city = null;
        });
      }
    });
  }

  showCityAlert() async {
    if (state != null && state!.isNotEmpty) {
      await showDialog(
        context: context,
        builder: (context) {
          return CityAlert(
            state: state!,
          );
        },
      ).then((value) {
        if (value != null) {
          setState(() {
            city = value;
          });
        }
      });
    }
  }

  @override
  void initState() {
    super.initState();
    getState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Add Customer"),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(10),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Form(
            key: addCustomerKey,
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
                      isMandorty: false,
                      formName: 'Address',
                      isOnlyCharter: false,
                    );
                  },
                ),
                InputForm(
                  onTap: () {
                    showStateAlert();
                  },
                  lableName: "State",
                  controller: TextEditingController(text: state),
                  formName: "State",
                  readOnly: true,
                  prefixIcon: Icons.map_outlined,
                  validation: (input) {
                    return FormValidation().commonValidation(
                      input: input,
                      isMandorty: true,
                      formName: "State",
                      isOnlyCharter: false,
                    );
                  },
                ),
                InputForm(
                  onTap: () {
                    showCityAlert();
                  },
                  lableName: "City",
                  controller: TextEditingController(text: city),
                  formName: "City",
                  readOnly: true,
                  prefixIcon: Icons.explore_outlined,
                  validation: (input) {
                    return FormValidation().commonValidation(
                      input: input,
                      isMandorty: true,
                      formName: "City",
                      isOnlyCharter: false,
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: SizedBox(
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
      ),
    );
  }
}

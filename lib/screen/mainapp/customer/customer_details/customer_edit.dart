import 'dart:developer';

import 'package:flutter/material.dart';

import '../../../../firebase/datamodel/datamodel.dart';
import '../../../../firebase/firestore_provider.dart';
import '../../../../utlities/utlities.dart';
import '../../../../utlities/validation.dart';
import '../../../../utlities/varibales.dart';
import '../../../ui/city_alert.dart';
import '../../../ui/commenwidget.dart';
import '../../../ui/state_alert.dart';

class CustomerEdit extends StatefulWidget {
  final CustomerDataModel customeData;
  const CustomerEdit({super.key, required this.customeData});

  @override
  State<CustomerEdit> createState() => _CustomerEditState();
}

class _CustomerEditState extends State<CustomerEdit> {
  TextEditingController customerName = TextEditingController();
  TextEditingController address = TextEditingController();
  TextEditingController email = TextEditingController();
  TextEditingController mobileNo = TextEditingController();

  List<DropdownMenuItem<String>> stateMenuList = [];

  List<DropdownMenuItem<String>> cityMenuList = [];

  String? state;
  String? city;

  var customerKey = GlobalKey<FormState>();

  getcity() {
    log("state $state");
    if (state != null && state != "null" && state!.isNotEmpty) {
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

  updateCustomerForm() async {
    try {
      loading(context);
      if (customerKey.currentState!.validate()) {
        var dataPack = CustomerDataModel();
        dataPack.customerName = customerName.text;
        dataPack.mobileNo = mobileNo.text;
        dataPack.address = address.text;
        dataPack.state = state;
        dataPack.city = city;
        dataPack.email = email.text;
        await FireStoreProvider()
            .updateCustomer(
          docID: widget.customeData.docID!,
          customerData: dataPack,
        )
            .catchError((onError) {
          Navigator.pop(context);
          snackBarCustom(context, false, onError.toString());
        }).then((value) {
          Navigator.pop(context);
          snackBarCustom(
            context,
            true,
            "Successfully Update Customer Information",
          );
        });
      } else {
        Navigator.pop(context);
        snackBarCustom(context, false, "Fill the All Form");
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
    customerName.text = widget.customeData.customerName ?? "";
    city = widget.customeData.city ?? "";
    address.text = widget.customeData.address ?? "";
    email.text = widget.customeData.email ?? "";
    mobileNo.text = widget.customeData.mobileNo ?? "";

    state = widget.customeData.state ?? "";
    if (widget.customeData.city!.isNotEmpty) {
      getcity();
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10),
      child: Container(
        height: double.infinity,
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
        ),
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Form(
                      key: customerKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          InputForm(
                            controller: customerName,
                            lableName: "User Name",
                            formName: "Full Name",
                            prefixIcon: Icons.person,
                            validation: (input) {
                              return FormValidation().commonValidation(
                                input: input,
                                isMandorty: true,
                                formName: 'User Name',
                                isOnlyCharter: false,
                              );
                            },
                          ),
                          InputForm(
                            controller: mobileNo,
                            lableName: "Phone Number",
                            formName: "Phone No",
                            prefixIcon: Icons.phone,
                            keyboardType: TextInputType.phone,
                            validation: (input) {
                              return FormValidation().phoneValidation(
                                input: input.toString(),
                                isMandorty: true,
                                lableName: 'Phone Number',
                              );
                            },
                          ),
                          InputForm(
                            controller: address,
                            lableName: "Address",
                            formName: "Address",
                            prefixIcon: Icons.alternate_email_outlined,
                            keyboardType: TextInputType.text,
                            validation: (input) {
                              return FormValidation().commonValidation(
                                input: input,
                                isMandorty: true,
                                formName: "Address",
                                isOnlyCharter: false,
                              );
                            },
                          ),
                          // InputForm(
                          //   controller: city,
                          //   lableName: "City",
                          //   formName: "City",
                          //   prefixIcon: Icons.location_city,
                          //   keyboardType: TextInputType.text,
                          // ),
                          // InputForm(
                          //   controller: state,
                          //   lableName: "State",
                          //   formName: "State",
                          //   prefixIcon: Icons.location_city,
                          //   keyboardType: TextInputType.text,
                          // ),
                          InputForm(
                            onTap: () {
                              showStateAlert();
                            },
                            lableName: "State",
                            controller: TextEditingController(text: state),
                            formName: "State",
                            readOnly: true,
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
                            validation: (input) {
                              return FormValidation().commonValidation(
                                input: input,
                                isMandorty: true,
                                formName: "City",
                                isOnlyCharter: false,
                              );
                            },
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          InputForm(
                            controller: email,
                            lableName: "Customer Email",
                            formName: "Customer Email",
                            prefixIcon: Icons.alternate_email_outlined,
                            keyboardType: TextInputType.text,
                            validation: (input) {
                              return FormValidation().emailValidation(
                                input: input.toString(),
                                lableName: 'Customer Email',
                                isMandorty: false,
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                  ],
                ),
              ),
            ),
            Padding(
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
                        updateCustomerForm();
                      },
                      btnName: "Submit",
                    ),
                  ),
                ],
              ),
            ),
            // Padding(
            //   padding: const EdgeInsets.all(8.0),
            //   child: GestureDetector(
            //     onTap: () {
            //       // loginauth();
            //       // loading(context);
            //     },
            //     child: Container(
            //       decoration: BoxDecoration(
            //         borderRadius: BorderRadius.circular(5),
            //         color: Theme.of(context).primaryColor,
            //       ),
            //       padding: const EdgeInsets.symmetric(
            //         horizontal: 10,
            //         vertical: 15,
            //       ),
            //       width: double.infinity,
            //       child: const Center(
            //         child: Text(
            //           "Change",
            //           style: TextStyle(
            //             color: Colors.white,
            //             fontSize: 15,
            //             fontWeight: FontWeight.w800,
            //           ),
            //         ),
            //       ),
            //     ),
            //   ),
            // ),
          ],
        ),
      ),
    );
  }
}

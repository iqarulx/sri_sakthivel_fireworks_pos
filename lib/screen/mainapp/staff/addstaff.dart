import 'dart:io';

import 'package:flutter/material.dart';
import 'package:sri_sakthivel_fireworks_pos/firebase/firestore_provider.dart';
import 'package:sri_sakthivel_fireworks_pos/utlities/validation.dart';
import '../../../firebase/datamodel/datamodel.dart';
import '../../../firebase/firestorageprovider.dart';
import '../../../provider/imagepickerprovider.dart';
import '../../../utlities/provider/localdb.dart';
import '../../../utlities/utlities.dart';
import '../../ui/commenwidget.dart';

class AddStaff extends StatefulWidget {
  final String companyID;
  const AddStaff({super.key, required this.companyID});

  @override
  State<AddStaff> createState() => _AddStaffState();
}

class _AddStaffState extends State<AddStaff> {
  var staffKey = GlobalKey<FormState>();
  TextEditingController fullName = TextEditingController();
  TextEditingController phoneNo = TextEditingController();
  TextEditingController userid = TextEditingController();
  TextEditingController password = TextEditingController();

  bool product = false;
  bool category = false;
  bool customer = false;
  bool orders = false;
  bool estimate = false;
  bool billofSupply = false;

  File? profileImage;

  String? imageError;
  String? permissionError;

  accessAlertBox() async {
    await showDialog(
      context: context,
      builder: (context) {
        return AddPermission(
          product: product,
          category: category,
          customer: customer,
          orders: orders,
          estimate: estimate,
          billofsupply: billofSupply,
        );
      },
    ).then((value) {
      if (value != null) {
        setState(() {
          product = value["product"];
          category = value["category"];
          customer = value["customer"];
          orders = value["orders"];
          estimate = value["estimate"];
          billofSupply = value["billofsupply"];
        });
      }
    });
  }

  createStaff() async {
    loading(context);
    FocusManager.instance.primaryFocus!.unfocus();
    try {
      if (staffKey.currentState!.validate() && profileImage != null) {
        if (!product && !category && !customer && !orders && !estimate) {
          Navigator.pop(context);
          setState(() {
            permissionError = "Permission is Must";
          });
          snackBarCustom(context, false, "Permission is Must");
        } else {
          setState(() {
            imageError = null;
          });
          await LocalDbProvider().fetchInfo(type: LocalData.companyid).then((cid) async {
            if (cid != null) {
              StaffDataModel model = StaffDataModel();
              model.userName = fullName.text;
              model.phoneNo = phoneNo.text;
              model.userid = "${userid.text}@${widget.companyID}";
              model.password = password.text;
              model.companyID = cid;
              StaffPermissionDataModel permissionModel = StaffPermissionDataModel();
              permissionModel.product = product;
              permissionModel.category = category;
              permissionModel.customer = customer;
              permissionModel.orders = orders;
              permissionModel.estimate = estimate;
              permissionModel.billofsupply = billofSupply;

              model.permission = permissionModel;

              var downloadLink = await FireStorageProvider().uploadImage(
                fileData: profileImage!,
                fileName: DateTime.now().millisecondsSinceEpoch.toString(),
                filePath: 'staff',
              );
              model.profileImg = downloadLink;
              model.deleteAt = false;

              await FireStoreProvider().checkStaffAlreadyExiest(loginID: userid.text).then((staffCheck) async {
                if (staffCheck != null && staffCheck.docs.isEmpty) {
                  await FireStoreProvider().registerStaff(staffData: model).then((value) {
                    Navigator.pop(context);
                    if (value.id.isNotEmpty) {
                      setState(() {
                        profileImage = null;
                        userid.clear();
                        fullName.clear();
                        password.clear();
                        phoneNo.clear();
                        product = false;
                        category = false;
                        customer = false;
                        orders = false;
                        estimate = false;
                        billofSupply = false;
                      });
                      Navigator.pop(context, true);
                      snackBarCustom(context, true, "Successfully Created New Staff");
                    } else {
                      Navigator.pop(context);
                      snackBarCustom(context, false, "Failed to Create New Staff");
                    }
                  });
                } else {
                  Navigator.pop(context);
                  snackBarCustom(
                    context,
                    false,
                    "Staff Login ID Already Exists",
                  );
                }
              });
            } else {
              Navigator.pop(context);
              snackBarCustom(context, false, "Company Details Not Fetch");
            }
          });
        }
      } else {
        Navigator.pop(context);
        if (profileImage == null) {
          setState(() {
            imageError = "Profile Image is Must";
          });
          snackBarCustom(context, false, "Profile Image is Must");
        }
      }
    } catch (e) {
      Navigator.pop(context);
      snackBarCustom(context, false, e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      maxChildSize: 0.98,
      initialChildSize: 0.98,
      builder: (context, scrollController) {
        return ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Container(
            color: Colors.transparent, //could change this to Color(0xFF737373),
            //so you don't have to change MaterialApp canvasColor
            child: Scaffold(
              backgroundColor: Colors.white,
              appBar: AppBar(
                titleSpacing: 0,
                leading: IconButton(
                  splashRadius: 20,
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(
                    Icons.close,
                  ),
                ),
                iconTheme: const IconThemeData(
                  color: Colors.black,
                ),
                elevation: 0,
                backgroundColor: Colors.white,
                title: Text(
                  "Add New Staff",
                  style: TextStyle(
                    color: Theme.of(context).primaryColor,
                  ),
                ),
                bottom: const PreferredSize(
                  preferredSize: Size(double.infinity, 10),
                  child: Divider(
                    height: 0,
                    color: Colors.grey,
                  ),
                ),
              ),
              body: Column(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Center(
                            child: GestureDetector(
                              onTap: () async {
                                var imageResult = await FilePickerProvider().showFileDialog(context);
                                if (imageResult != null) {
                                  setState(() {
                                    profileImage = imageResult;
                                  });
                                }
                              },
                              child: SizedBox(
                                height: 90,
                                width: 90,
                                child: Stack(
                                  children: [
                                    Container(
                                      height: 90,
                                      width: 90,
                                      decoration: BoxDecoration(
                                        color: Colors.grey.shade300,
                                        shape: BoxShape.circle,
                                        image: profileImage != null
                                            ? DecorationImage(
                                                image: FileImage(profileImage!),
                                                fit: BoxFit.cover,
                                              )
                                            : null,
                                      ),
                                    ),
                                    Align(
                                      alignment: Alignment.bottomRight,
                                      child: Container(
                                        padding: const EdgeInsets.all(5),
                                        decoration: BoxDecoration(
                                          color: Colors.yellow.shade800,
                                          shape: BoxShape.circle,
                                          border: Border.all(
                                            width: 2,
                                            color: Colors.white,
                                          ),
                                        ),
                                        child: const Icon(
                                          Icons.edit,
                                          color: Colors.white,
                                          size: 15,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          Center(
                            child: Text(
                              imageError ?? "",
                              style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                                    color: Colors.red,
                                  ),
                            ),
                          ),
                          const SizedBox(
                            height: 20,
                          ),
                          Form(
                            key: staffKey,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                InputForm(
                                  controller: fullName,
                                  lableName: "Staff Name",
                                  formName: "Full Name",
                                  prefixIcon: Icons.person,
                                  validation: (input) {
                                    return FormValidation().commonValidation(
                                      input: input,
                                      isMandorty: true,
                                      formName: "Staff Name",
                                      isOnlyCharter: false,
                                    );
                                  },
                                ),
                                InputForm(
                                  controller: phoneNo,
                                  lableName: "Phone Number",
                                  formName: "Phone No",
                                  prefixIcon: Icons.phone,
                                  keyboardType: TextInputType.phone,
                                  validation: (input) {
                                    return FormValidation().phoneValidation(
                                      input: input.toString(),
                                      isMandorty: true,
                                      lableName: "Phone Number",
                                    );
                                  },
                                ),
                                const Text(
                                  "Staff Login ID",
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontWeight: FontWeight.w500,
                                    fontSize: 14,
                                  ),
                                ),
                                const SizedBox(
                                  height: 5,
                                ),
                                Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(5),
                                    color: const Color(0xfff1f5f9),
                                  ),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(5),
                                    child: Row(
                                      children: [
                                        Expanded(
                                          flex: 3,
                                          child: TextFormField(
                                            controller: userid,
                                            decoration: const InputDecoration(
                                              hintText: "User ID",
                                              prefixIcon: Icon(
                                                Icons.alternate_email_outlined,
                                                color: Color(0xff7099c2),
                                              ),
                                            ),
                                            validator: (input) {
                                              return FormValidation().commonValidation(
                                                input: input,
                                                isMandorty: true,
                                                formName: "userid",
                                                isOnlyCharter: false,
                                              );
                                            },
                                          ),
                                        ),
                                        Container(
                                          height: 55,
                                          decoration: const BoxDecoration(
                                            color: Color(0xfff1f5f9),
                                            borderRadius: BorderRadius.only(
                                              topRight: Radius.circular(5),
                                            ),
                                          ),
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 15,
                                          ),
                                          child: Center(
                                            child: Text("@${widget.companyID}"),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                const SizedBox(
                                  height: 10,
                                ),
                                InputForm(
                                  controller: password,
                                  lableName: "Passsword",
                                  formName: "Passsword",
                                  isPasswordForm: true,
                                  prefixIcon: Icons.key,
                                  keyboardType: TextInputType.visiblePassword,
                                  validation: (input) {
                                    return FormValidation().passwordValidation(
                                      input: input.toString(),
                                      minLength: 6,
                                      maxLength: 13,
                                    );
                                  },
                                ),
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      "Staff Permission",
                                      style: Theme.of(context).textTheme.bodyLarge,
                                    ),
                                    TextButton.icon(
                                      onPressed: () {
                                        accessAlertBox();
                                      },
                                      label: const Text("Add Permission"),
                                      icon: const Icon(Icons.add),
                                    ),
                                  ],
                                ),
                                if (!product &&
                                    !category &&
                                    !customer &&
                                    !orders &&
                                    !estimate &&
                                    !billofSupply &&
                                    permissionError != null)
                                  Center(
                                    child: Text(
                                      permissionError ?? "",
                                      style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                                            color: Colors.red,
                                          ),
                                    ),
                                  ),
                                Wrap(
                                  spacing: 10,
                                  runSpacing: 10,
                                  children: [
                                    // for (var i = 0;
                                    //     i < appAccessList.length;
                                    //     i++)

                                    if (product)
                                      Chip(
                                        label: const Text(
                                          "Product",
                                        ),
                                        onDeleted: () {
                                          setState(() {
                                            product = false;
                                          });
                                        },
                                      ),
                                    if (category)
                                      Chip(
                                        label: const Text(
                                          "Category",
                                        ),
                                        onDeleted: () {
                                          setState(() {
                                            category = false;
                                          });
                                        },
                                      ),
                                    if (customer)
                                      Chip(
                                        label: const Text(
                                          "Customer",
                                        ),
                                        onDeleted: () {
                                          setState(() {
                                            customer = false;
                                          });
                                        },
                                      ),
                                    if (orders)
                                      Chip(
                                        label: const Text(
                                          "Orders",
                                        ),
                                        onDeleted: () {
                                          setState(() {
                                            orders = false;
                                          });
                                        },
                                      ),
                                    if (estimate)
                                      Chip(
                                        label: const Text(
                                          "Estimate",
                                        ),
                                        onDeleted: () {
                                          setState(() {
                                            estimate = false;
                                          });
                                        },
                                      ),
                                    if (billofSupply)
                                      Chip(
                                        label: const Text(
                                          "Bill of Supply",
                                        ),
                                        onDeleted: () {
                                          setState(() {
                                            billofSupply = false;
                                          });
                                        },
                                      ),
                                    // Container(
                                    //   padding:
                                    //       const EdgeInsets.symmetric(
                                    //     horizontal: 10,
                                    //     vertical: 6,
                                    //   ),
                                    //   decoration: BoxDecoration(
                                    //     color: Colors.grey.shade300,
                                    //     borderRadius:
                                    //         BorderRadius.circular(100),
                                    //   ),
                                    //   child: Row(
                                    //     mainAxisSize: MainAxisSize.min,
                                    //     children: [
                                    //       Text(
                                    //         appAccessList[i].toString(),
                                    //         style: const TextStyle(
                                    //           color: Colors.black,
                                    //           fontSize: 13,
                                    //           fontWeight:
                                    //               FontWeight.bold,
                                    //         ),
                                    //       ),
                                    //     ],
                                    //   ),
                                    // )
                                  ],
                                ),
                                if (!product && !category && !customer && !orders && !estimate)
                                  const Center(
                                    child: Padding(
                                      padding: EdgeInsets.all(10.0),
                                      child: Text("No Permission"),
                                    ),
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
                    padding: const EdgeInsets.all(10),
                    child: fillButton(
                      context,
                      onTap: () {
                        createStaff();
                      },
                      btnName: "Submit",
                    ),
                  )
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class AddPermission extends StatefulWidget {
  final bool product;
  final bool category;
  final bool customer;
  final bool orders;
  final bool estimate;
  final bool billofsupply;
  const AddPermission({
    super.key,
    required this.product,
    required this.category,
    required this.customer,
    required this.orders,
    required this.estimate,
    required this.billofsupply,
  });

  @override
  State<AddPermission> createState() => _AddPermissionState();
}

class _AddPermissionState extends State<AddPermission> {
  bool product = false;
  bool category = false;
  bool customer = false;
  bool orders = false;
  bool estimate = false;
  bool billofsupply = false;

  initFn() {
    setState(() {
      product = widget.product;
      category = widget.category;
      customer = widget.customer;
      orders = widget.orders;
      estimate = widget.estimate;
      billofsupply = widget.billofsupply;
    });
  }

  @override
  void initState() {
    super.initState();
    initFn();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Permission"),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CheckboxListTile(
            controlAffinity: ListTileControlAffinity.leading,
            value: product,
            onChanged: (onChanged) {
              setState(() {
                product = onChanged!;
              });
            },
            title: const Text("Product"),
          ),
          CheckboxListTile(
            controlAffinity: ListTileControlAffinity.leading,
            value: category,
            onChanged: (onChanged) {
              setState(() {
                category = onChanged!;
              });
            },
            title: const Text("Category"),
          ),
          CheckboxListTile(
            controlAffinity: ListTileControlAffinity.leading,
            value: customer,
            onChanged: (onChanged) {
              setState(() {
                customer = onChanged!;
              });
            },
            title: const Text("Customer"),
          ),
          CheckboxListTile(
            controlAffinity: ListTileControlAffinity.leading,
            value: orders,
            onChanged: (onChanged) {
              setState(() {
                orders = onChanged!;
              });
            },
            title: const Text("Orders"),
          ),
          CheckboxListTile(
            controlAffinity: ListTileControlAffinity.leading,
            value: estimate,
            onChanged: (onChanged) {
              setState(() {
                estimate = onChanged!;
              });
            },
            title: const Text("Estimate"),
          ),
          CheckboxListTile(
            controlAffinity: ListTileControlAffinity.leading,
            value: billofsupply,
            onChanged: (onChanged) {
              setState(() {
                billofsupply = onChanged!;
              });
            },
            title: const Text("Bill of Supply"),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: const Text("Cancel"),
        ),
        TextButton(
          onPressed: () {
            Navigator.pop(
              context,
              {
                "product": product,
                "category": category,
                "customer": customer,
                "orders": orders,
                "estimate": estimate,
                "billofsupply": billofsupply,
              },
            );
          },
          child: const Text("Done"),
        ),
      ],
    );
  }
}

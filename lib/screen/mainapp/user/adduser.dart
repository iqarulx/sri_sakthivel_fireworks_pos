import 'dart:io';

import 'package:flutter/material.dart';
import 'package:sri_sakthivel_fireworks_pos/firebase/firestorageprovider.dart';
import 'package:sri_sakthivel_fireworks_pos/firebase/firestore_provider.dart';
import 'package:sri_sakthivel_fireworks_pos/utlities/provider/localdb.dart';
import 'package:sri_sakthivel_fireworks_pos/utlities/utlities.dart';
import 'package:sri_sakthivel_fireworks_pos/utlities/validation.dart';

import '../../../firebase/datamodel/datamodel.dart';
import '../../../provider/imagepickerprovider.dart';
import '../../ui/commenwidget.dart';

class AddUser extends StatefulWidget {
  const AddUser({super.key});

  @override
  State<AddUser> createState() => _AddUserState();
}

class _AddUserState extends State<AddUser> {
  TextEditingController name = TextEditingController();
  TextEditingController phoneNo = TextEditingController();
  TextEditingController userId = TextEditingController();
  TextEditingController password = TextEditingController();
  var addUserKey = GlobalKey<FormState>();

  String? imageError;
  String? unqiueId;

  checkValidation() async {
    loading(context);
    FocusManager.instance.primaryFocus!.unfocus();
    try {
      if (addUserKey.currentState!.validate()) {
        setState(() {
          imageError = null;
        });

        await LocalDbProvider().fetchInfo(type: LocalData.companyid).then((cid) async {
          if (cid != null) {
            var userData = UserAdminModel();
            userData.adminLoginId = "${userId.text}@$unqiueId";
            userData.adminName = name.text;
            userData.companyId = cid.toString();
            userData.password = password.text;
            userData.phoneNo = phoneNo.text;
            userData.createdDateTime = DateTime.now();
            String? downloadLink;
            if (profileImage != null) {
              downloadLink = await FireStorageProvider().uploadImage(
                fileData: profileImage!,
                fileName: DateTime.now().millisecondsSinceEpoch.toString(),
                filePath: 'users',
              );
            }

            userData.imageUrl = downloadLink;

            await FireStoreProvider().registerUserAdmin(userData: userData).then((value) {
              Navigator.pop(context);
              if (value.id.isNotEmpty) {
                setState(() {
                  profileImage = null;
                  userId.clear();
                  name.clear();
                  password.clear();
                  phoneNo.clear();
                });
                Navigator.pop(context, true);
                snackBarCustom(context, true, "Successfully Created New User");
              } else {
                snackBarCustom(context, false, "Failed to Create New User");
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

  File? profileImage;

  initFun() async {
    await LocalDbProvider()
        .fetchInfo(
      type: LocalData.companyUniqueId,
    )
        .then((value) {
      setState(() {
        unqiueId = value;
      });
    });
  }

  @override
  void initState() {
    super.initState();
    initFun();
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
                  "Add New User",
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
                            key: addUserKey,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                InputForm(
                                  controller: name,
                                  lableName: "User Name",
                                  formName: "Full Name",
                                  prefixIcon: Icons.person,
                                  validation: (p0) {
                                    return FormValidation().commonValidation(
                                      input: p0,
                                      isMandorty: true,
                                      formName: "User Name",
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
                                  validation: (p0) {
                                    return FormValidation().phoneValidation(
                                      input: p0.toString(),
                                      isMandorty: true,
                                      lableName: 'Phone Number',
                                    );
                                  },
                                ),
                                // Expanded(
                                //   child: InputForm(
                                //     controller: userId,
                                //     lableName: "User Id",
                                //     formName: "User Id",
                                //     prefixIcon:
                                //         Icons.alternate_email_outlined,
                                //     keyboardType: TextInputType.text,
                                //     validation: (p0) {
                                //       return FormValidation()
                                //           .commonValidation(
                                //         input: p0.toString(),
                                //         formName: "User ID",
                                //         isMandorty: true,
                                //         isOnlyCharter: false,
                                //       );
                                //     },
                                //   ),
                                // ),
                                const Text(
                                  "User ID",
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontWeight: FontWeight.w500,
                                    fontSize: 14,
                                  ),
                                ),
                                const SizedBox(height: 5),
                                TextFormField(
                                  controller: userId,
                                  decoration: InputDecoration(
                                    hintText: "User Id",
                                    prefixIcon: const Icon(
                                      Icons.alternate_email_outlined,
                                      color: Color(0xff7099c2),
                                    ),
                                    suffix: Text("@$unqiueId"),
                                  ),
                                  validator: (p0) {
                                    return FormValidation().commonValidation(
                                      input: p0.toString(),
                                      formName: "User ID",
                                      isMandorty: true,
                                      isOnlyCharter: false,
                                    );
                                  },
                                ),
                                const SizedBox(height: 10),
                                InputForm(
                                  controller: password,
                                  lableName: "Passsword",
                                  formName: "Passsword",
                                  isPasswordForm: true,
                                  prefixIcon: Icons.key,
                                  keyboardType: TextInputType.visiblePassword,
                                  validation: (p0) {
                                    return FormValidation().passwordValidation(
                                      input: p0.toString(),
                                      minLength: 6,
                                      maxLength: 8,
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
                    padding: const EdgeInsets.all(10.0),
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
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

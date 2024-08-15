import 'dart:io';

import 'package:flutter/material.dart';
import 'package:sri_sakthivel_fireworks_pos/firebase/firebase_auth_provider.dart';
import 'package:sri_sakthivel_fireworks_pos/firebase/firestorageprovider.dart';
import 'package:sri_sakthivel_fireworks_pos/utlities/utlities.dart';
import 'package:sri_sakthivel_fireworks_pos/utlities/validation.dart';

import '../../../firebase/datamodel/datamodel.dart';
import '../../../firebase/firestore_provider.dart';
import '../../../provider/imagepickerprovider.dart';
import '../../../utlities/provider/localdb.dart';
import '../../ui/commenwidget.dart';
import '../homelanding.dart';

class CompanyListing extends StatefulWidget {
  const CompanyListing({super.key});

  @override
  State<CompanyListing> createState() => _CompanyListingState();
}

class _CompanyListingState extends State<CompanyListing> {
  TextEditingController name = TextEditingController();
  TextEditingController companyName = TextEditingController();
  TextEditingController address = TextEditingController();
  TextEditingController pincode = TextEditingController();
  TextEditingController mobileNo = TextEditingController();
  TextEditingController phoneNo = TextEditingController();
  TextEditingController gstno = TextEditingController();
  TextEditingController userid = TextEditingController();
  TextEditingController password = TextEditingController();

  File? uploadCompanyPic;

  String? oldEmail;
  String? oldPassword;

  var companyFormKey = GlobalKey<FormState>();

  String? prfileImage;

  Future getCompanyInfo(context) async {
    try {
      FireStoreProvider provider = FireStoreProvider();
      var cid = await LocalDbProvider().fetchInfo(type: LocalData.companyid);
      if (cid != null) {
        final result = await provider.getCompanyDocInfo(cid: cid);
        if (result!.exists) {
          setState(() {
            name.text = result["user_name"].toString();
            companyName.text = result["company_name"].toString();
            address.text = result["address"].toString();
            pincode.text = result["pincode"].toString();
            mobileNo.text = result["contact"]["mobile_no"].toString();
            phoneNo.text = result["contact"]["phone_no"].toString();
            gstno.text = result["gst_no"] ?? "";
            userid.text = result["user_login_id"].toString();
            prfileImage = result["company_logo"].toString();
            password.text = result["password"].toString();
            oldEmail = result["user_login_id"].toString();
            oldPassword = result["password"].toString();
          });
          return result;
        }
      }
      return null;
    } catch (e) {
      throw e.toString();
    }
  }

  getValidation() async {
    loading(context);
    try {
      if (companyFormKey.currentState!.validate()) {
        await LocalDbProvider().fetchInfo(type: LocalData.companyid).then((cid) async {
          if (cid != null) {
            ProfileModel profileModel = ProfileModel();
            profileModel.username = name.text;
            profileModel.companyName = companyName.text;
            profileModel.address = address.text;
            profileModel.pincode = pincode.text;
            profileModel.contact = {
              "mobile_no": mobileNo.text,
              "phone_no": phoneNo.text,
            };
            if (gstno.text.isNotEmpty) {
              profileModel.gstno = gstno.text;
            }
            profileModel.userLoginId = userid.text;
            profileModel.password = password.text;
            await FireStoreProvider().updateCompany(docId: cid, companyData: profileModel).then((value) async {
              await FirebaseAuthProvider()
                  .updateUserLogin(
                email: userid.text,
                password: password.text,
                oldEmail: oldEmail ?? "",
                oldPassword: oldPassword ?? "",
              )
                  .then((value) async {
                if (uploadCompanyPic != null) {
                  await FireStorageProvider()
                      .uploadImage(
                    fileData: uploadCompanyPic!,
                    fileName: DateTime.now().millisecondsSinceEpoch.toString(),
                    filePath: "company",
                  )
                      .then((downloadLink) async {
                    if (downloadLink != null && downloadLink.isNotEmpty) {
                      await FireStoreProvider().updateCompanyPic(docId: cid, imageLink: downloadLink).then((value) {
                        Navigator.pop(context);
                        snackBarCustom(
                          context,
                          true,
                          "Successfully Updated Company Information",
                        );
                      });
                    } else {
                      // exit Loading Progroccess
                      Navigator.pop(context);
                      snackBarCustom(context, false, "Something went Wrong");
                    }
                  });
                } else {
                  Navigator.pop(context);
                  snackBarCustom(
                    context,
                    true,
                    "Successfully Updated Company Information",
                  );
                }
              });
            });
          } else {
            Navigator.pop(context);
            snackBarCustom(context, false, "Something went Wrong");
          }
        });
      } else {
        Navigator.pop(context);
        snackBarCustom(context, false, "Fill the All Required Form");
      }
    } catch (e) {
      Navigator.pop(context);
      snackBarCustom(context, false, e.toString());
    }
  }

  late Future companyHandler;
  @override
  void initState() {
    super.initState();
    companyHandler = getCompanyInfo(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffEEEEEE),
      appBar: AppBar(
        leading: IconButton(
          splashRadius: 20,
          onPressed: () {
            homeKey.currentState!.openDrawer();
          },
          icon: const Icon(Icons.menu),
        ),
        title: const Text("Company"),
      ),
      body: FutureBuilder(
        future: companyHandler,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done && snapshot.data != null) {
            return Padding(
              padding: const EdgeInsets.all(10.0),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Column(
                  children: [
                    Expanded(
                      child: ClipRRect(
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(15),
                          topRight: Radius.circular(15),
                        ),
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
                                        uploadCompanyPic = imageResult;
                                      });
                                    }
                                  },
                                  child: Container(
                                    color: Colors.transparent,
                                    height: 120,
                                    width: 120,
                                    child: Stack(
                                      children: [
                                        Container(
                                          height: 120,
                                          width: 120,
                                          decoration: BoxDecoration(
                                            color: Colors.grey.shade300,
                                            shape: BoxShape.circle,
                                            image: uploadCompanyPic != null
                                                ? DecorationImage(
                                                    image: FileImage(
                                                      uploadCompanyPic!,
                                                    ),
                                                    fit: BoxFit.cover,
                                                  )
                                                : prfileImage != null
                                                    ? DecorationImage(
                                                        image: NetworkImage(
                                                          prfileImage!,
                                                        ),
                                                        fit: BoxFit.cover,
                                                      )
                                                    : null,
                                          ),
                                        ),
                                        Align(
                                          alignment: Alignment.bottomRight,
                                          child: Container(
                                            decoration: BoxDecoration(
                                              border: Border.all(
                                                width: 2,
                                                color: Colors.white,
                                              ),
                                              color: Colors.yellow.shade600,
                                              shape: BoxShape.circle,
                                            ),
                                            padding: const EdgeInsets.all(5),
                                            child: const Icon(
                                              Icons.edit,
                                              color: Colors.white,
                                              size: 18,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(
                                height: 30,
                              ),
                              Form(
                                key: companyFormKey,
                                child: Column(
                                  children: [
                                    InputForm(
                                      controller: name,
                                      lableName: "User Name",
                                      formName: "Full Name",
                                      prefixIcon: Icons.person,
                                      validation: (input) {
                                        return FormValidation().commonValidation(
                                          input: input,
                                          isMandorty: true,
                                          formName: "Full Name",
                                          isOnlyCharter: false,
                                        );
                                      },
                                    ),
                                    InputForm(
                                      controller: companyName,
                                      lableName: "Company Name",
                                      formName: "Company Full Name",
                                      prefixIcon: Icons.business_outlined,
                                      validation: (input) {
                                        return FormValidation().commonValidation(
                                          input: input,
                                          isMandorty: true,
                                          formName: "Company Name",
                                          isOnlyCharter: false,
                                        );
                                      },
                                    ),
                                    InputForm(
                                      controller: address,
                                      lableName: "Address",
                                      formName: "Company Address",
                                      prefixIcon: Icons.place_outlined,
                                      validation: (input) {
                                        return FormValidation().commonValidation(
                                          input: input,
                                          isMandorty: true,
                                          formName: "Address",
                                          isOnlyCharter: false,
                                        );
                                      },
                                    ),
                                    InputForm(
                                      controller: pincode,
                                      lableName: "Pincode",
                                      formName: "Pincode",
                                      prefixIcon: Icons.near_me_outlined,
                                      validation: (input) {
                                        return FormValidation().pincodeValidation(
                                          input: input.toString(),
                                          isMandorty: true,
                                        );
                                      },
                                    ),
                                    InputForm(
                                      controller: mobileNo,
                                      lableName: "Mobile No",
                                      formName: "Mobile Number",
                                      prefixIcon: Icons.phone_outlined,
                                      keyboardType: TextInputType.phone,
                                      validation: (input) {
                                        return FormValidation().phoneValidation(
                                          input: input.toString(),
                                          isMandorty: true,
                                          lableName: "Mobile Number",
                                        );
                                      },
                                    ),
                                    InputForm(
                                      controller: phoneNo,
                                      lableName: "Phone No",
                                      formName: "Phone Number",
                                      prefixIcon: Icons.phone_outlined,
                                      keyboardType: TextInputType.phone,
                                      validation: (input) {
                                        return FormValidation().phoneValidation(
                                          input: input.toString(),
                                          isMandorty: false,
                                          lableName: "Phone Number",
                                        );
                                      },
                                    ),
                                    InputForm(
                                      controller: gstno,
                                      lableName: "GST No",
                                      formName: "GST Number",
                                      prefixIcon: Icons.account_balance_outlined,
                                      keyboardType: TextInputType.phone,
                                    ),
                                    InputForm(
                                      controller: userid,
                                      lableName: "User Id",
                                      formName: "User Id",
                                      prefixIcon: Icons.alternate_email_outlined,
                                      keyboardType: TextInputType.text,
                                      validation: (input) {
                                        return FormValidation().emailValidation(
                                          input: input.toString(),
                                          lableName: "Email",
                                          isMandorty: true,
                                        );
                                      },
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
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8),
                      child: fillButton(
                        context,
                        onTap: () {
                          getValidation();
                        },
                        btnName: "Change",
                      ),
                    ),
                  ],
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
                            companyHandler = getCompanyInfo(context);
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
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
        },
      ),
    );
  }
}

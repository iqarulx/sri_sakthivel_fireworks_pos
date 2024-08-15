// ignore_for_file: use_build_context_synchronously

import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sri_sakthivel_fireworks_pos/firebase/firestorageprovider.dart';
import 'package:sri_sakthivel_fireworks_pos/screen/mainapp/homelanding.dart';
import 'package:sri_sakthivel_fireworks_pos/utlities/utlities.dart';
import 'package:sri_sakthivel_fireworks_pos/utlities/validation.dart';
import 'package:sri_sakthivel_fireworks_pos/utlities/varibales.dart';

import '../../firebase/datamodel/datamodel.dart';
import '../../provider/device_info_provider.dart';
import '../../provider/imagepickerprovider.dart';
import '../../utlities/provider/localdb.dart';

class RegisterCompany extends StatefulWidget {
  final String uid;
  final String docid;
  final String companyName;
  final String username;
  final String email;
  final String password;
  const RegisterCompany({
    super.key,
    required this.uid,
    required this.docid,
    required this.companyName,
    required this.username,
    required this.email,
    required this.password,
  });

  @override
  State<RegisterCompany> createState() => _RegisterCompanyState();
}

class _RegisterCompanyState extends State<RegisterCompany> {
  TextEditingController username = TextEditingController();
  TextEditingController companyname = TextEditingController();
  TextEditingController address = TextEditingController();
  TextEditingController phoneno = TextEditingController();
  TextEditingController mobileno = TextEditingController();
  TextEditingController pincode = TextEditingController();
  TextEditingController gst = TextEditingController();
  TextEditingController companyUnquieId = TextEditingController();
  String city = "";
  String state = "";

  var companyKey = GlobalKey<FormState>();

  File? profileImage;

  registerNewCompany() async {
    /*
        1. Validation Form show error
        2. Update New Company Profile Information
        3. Upload Company profile Image
        4. get Download Link and Update Download Link
    */

    // 1. Check Form Validation
    if (companyKey.currentState!.validate()) {
      // 1.1 check Profile Image is Empty
      loading(context);
      if (profileImage != null) {
        // 2. Update New Company Profile Information

        // instance Firbase Firestore DB
        var db = FirebaseFirestore.instance;

        // set Firestore Profile Collection
        var profile = db.collection('profile');

        // update firestore Data
        ProfileModel profileModel = ProfileModel();

        // Declear Upload Variable value
        profileModel.username = username.text;
        profileModel.address = address.text;
        profileModel.city = city;
        profileModel.companyName = companyname.text;
        profileModel.deviceLimit = 2;
        profileModel.gstno = gst.text;
        profileModel.contact = {
          "mobile_no": mobileno.text,
          "phone_no": phoneno.text,
        };
        profileModel.pincode = pincode.text;
        profileModel.state = state;
        profileModel.filled = true;
        profileModel.password = widget.password;

        await profile.where("company_unique_id", isEqualTo: companyUnquieId.text).get().then((value) {
          if (value.docs.isEmpty) {
            profileModel.companyUniqueID = companyUnquieId.text;
          }
        });

        // upload Firestore Database
        await profile.doc(widget.docid).set(
              profileModel.newRegisterCompany(),
              SetOptions(merge: true),
            );
        DeviceModel deviceData = DeviceModel();
        DeviceModel? deviceInfo = await DeviceInformation().getDeviceInfo();
        if (deviceInfo != null) {
          deviceData.deviceId = deviceInfo.deviceId.toString();
          deviceData.modelName = deviceInfo.modelName.toString();
          deviceData.deviceName = deviceInfo.deviceName.toString();
          deviceData.lastlogin = DateTime.now();
          deviceData.deviceType = deviceInfo.deviceType.toString();
          await profile.doc(widget.docid).collection('login_device').add(deviceData.toMap());
        }

        // Once update Data to upload Image
        FireStorageProvider storage = FireStorageProvider();
        var downloadLink = await storage.uploadImage(
          fileData: profileImage!,
          fileName: DateTime.now().millisecondsSinceEpoch.toString(),
          filePath: 'company',
        );
        if (downloadLink != null && downloadLink.isNotEmpty) {
          await profile.doc(widget.docid).set(
            {
              "company_logo": downloadLink.toString(),
            },
            SetOptions(merge: true),
          ).then((value) async {
            LocalDbProvider localdb = LocalDbProvider();
            await localdb
                .createNewUser(
              username: username.text,
              uID: widget.uid,
              companyID: widget.docid,
              loginEmail: widget.email,
              companyUniqueId: companyUnquieId.text,
              isAdmin: true,
              prCategory: true,
              prCustomer: true,
              prEstimate: true,
              prOrder: true,
              prProduct: true,
              prBillofSupply: true,
            )
                .then((value) {
              Navigator.pop(context);
              Navigator.pop(context);
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => const HomeLanding(),
                ),
              );
            });
          });
        } else {
          // exit Loading Progroccess
          Navigator.pop(context);
        }
      } else {
        // exit Loading Progroccess
        Navigator.pop(context);
        // throw error msg on company logo is must
        snackBarCustom(context, false, "Company Profile Logo is Must");
      }
    } else {
      // throw Error Form not Valid
      snackBarCustom(context, false, "Fill Correct Form Details");
    }
  }

  List<DropdownMenuItem<String>> stateMenuList = [];
  List<DropdownMenuItem<String>> cityMenuList = [];

  getState() {
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
    if (state.isNotEmpty) {
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

  chooseImage({required ImagePickerMode mode}) async {
    ImagePickerProvider image = ImagePickerProvider();
    var file = await image.getImage(mode: mode);
    if (file != null) {
      setState(() {
        profileImage = file;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    getState();
    companyname.text = widget.companyName;
    username.text = widget.username;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: false,
        iconTheme: const IconThemeData(
          color: Colors.black,
        ),
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.dark,
        ),
        elevation: 0,
        backgroundColor: Colors.white,
        title: const Text(
          "Register Your Company",
          style: TextStyle(
            color: Colors.black,
            fontSize: 15,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(10),
        child: Center(
          child: Container(
            constraints: const BoxConstraints(
              maxWidth: 1000,
            ),
            child: Column(
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  padding: const EdgeInsets.all(10),
                  child: Form(
                    key: companyKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Company Profile",
                          style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.w600,
                            fontSize: 15,
                          ),
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        Center(
                          child: Column(
                            children: [
                              GestureDetector(
                                onTap: () async {
                                  var imageResult = await FilePickerProvider().showFileDialog(context);
                                  if (imageResult != null) {
                                    setState(() {
                                      profileImage = imageResult;
                                    });
                                  }
                                },
                                child: SizedBox(
                                  height: 80,
                                  width: 80,
                                  child: Stack(
                                    children: [
                                      Container(
                                        height: 80,
                                        width: 80,
                                        decoration: BoxDecoration(
                                          color: Colors.grey.shade300,
                                          shape: BoxShape.circle,
                                          image: profileImage == null
                                              ? null
                                              : DecorationImage(
                                                  image: FileImage(profileImage!),
                                                  fit: BoxFit.cover,
                                                ),
                                        ),
                                      ),
                                      Align(
                                        alignment: Alignment.bottomRight,
                                        child: Container(
                                          padding: const EdgeInsets.all(5),
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            color: Theme.of(context).primaryColor,
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
                            ],
                          ),
                        ),
                        const SizedBox(
                          height: 30,
                        ),
                        SizedBox(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                "Company Name",
                                style: TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.w500,
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(
                                height: 5,
                              ),
                              TextFormField(
                                controller: companyname,
                                cursorColor: Theme.of(context).primaryColor,
                                textInputAction: TextInputAction.done,
                                keyboardType: TextInputType.text,
                                decoration: const InputDecoration(
                                  fillColor: Color(0xfff1f5f9),
                                  filled: true,
                                  border: OutlineInputBorder(
                                    borderSide: BorderSide.none,
                                  ),
                                  hintText: "Company Full Name",
                                  prefixIcon: Icon(
                                    Icons.business_outlined,
                                  ),
                                ),
                                validator: (value) {
                                  if (value!.isEmpty) {
                                    return "Company Name is Must";
                                  } else {
                                    return null;
                                  }
                                },
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        SizedBox(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                "Company Unique ID",
                                style: TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.w500,
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(
                                height: 5,
                              ),
                              TextFormField(
                                controller: companyUnquieId,
                                cursorColor: Theme.of(context).primaryColor,
                                textInputAction: TextInputAction.done,
                                keyboardType: TextInputType.text,
                                decoration: const InputDecoration(
                                  fillColor: Color(0xfff1f5f9),
                                  filled: true,
                                  border: OutlineInputBorder(
                                    borderSide: BorderSide.none,
                                  ),
                                  hintText: "Company UnqiueId",
                                  prefixIcon: Icon(
                                    Icons.alternate_email_outlined,
                                  ),
                                ),
                                autovalidateMode: AutovalidateMode.onUserInteraction,
                                validator: (value) {
                                  if (value!.isEmpty) {
                                    return "Company Unqiue ID is Must";
                                  } else if (value.length < 8) {
                                    return "Company Unqiue ID should be minimum 8 characters";
                                  } else if (value.isNotEmpty && value.startsWith('@')) {
                                    return "Please Remove @ symbol";
                                  } else if (RegExp(r"(?=.*[a-z])(?=.*[A-Z])\w+").hasMatch(value)) {
                                    return "Only use lowercase";
                                  } else {
                                    return null;
                                  }
                                },
                              ),
                              const SizedBox(
                                height: 5,
                              ),
                              Text(
                                "Example: @${widget.companyName}, @${widget.companyName}0123",
                                style: Theme.of(context).textTheme.bodySmall!.copyWith(
                                      color: Colors.grey,
                                    ),
                              ),
                              const SizedBox(
                                height: 5,
                              ),
                              Text(
                                "Note: Company Unique ID is one time creation, Once Create its not changeable",
                                style: Theme.of(context).textTheme.bodySmall!.copyWith(
                                      color: Colors.grey,
                                    ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        SizedBox(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                "User Name",
                                style: TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.w500,
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(
                                height: 5,
                              ),
                              TextFormField(
                                controller: username,
                                cursorColor: Theme.of(context).primaryColor,
                                textInputAction: TextInputAction.done,
                                keyboardType: TextInputType.text,
                                decoration: const InputDecoration(
                                  fillColor: Color(0xfff1f5f9),
                                  filled: true,
                                  border: OutlineInputBorder(
                                    borderSide: BorderSide.none,
                                  ),
                                  hintText: "User Full Name",
                                  prefixIcon: Icon(
                                    Icons.business_outlined,
                                  ),
                                ),
                                validator: (value) {
                                  if (value!.isEmpty) {
                                    return "User Name is Must";
                                  } else {
                                    return null;
                                  }
                                },
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        SizedBox(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                "Address",
                                style: TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.w500,
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(
                                height: 5,
                              ),
                              TextFormField(
                                maxLines: 5,
                                controller: address,
                                cursorColor: Theme.of(context).primaryColor,
                                textInputAction: TextInputAction.done,
                                keyboardType: TextInputType.text,
                                decoration: const InputDecoration(
                                  fillColor: Color(0xfff1f5f9),
                                  filled: true,
                                  border: OutlineInputBorder(
                                    borderSide: BorderSide.none,
                                  ),
                                  hintText: "Address",
                                  prefixIcon: Padding(
                                    padding: EdgeInsets.fromLTRB(0, 0, 0, 80),
                                    child: Icon(
                                      Icons.place_outlined,
                                    ),
                                  ),
                                ),
                                validator: (value) {
                                  return FormValidation().commonValidation(
                                    input: value,
                                    isMandorty: true,
                                    formName: "Address",
                                    isOnlyCharter: false,
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        SizedBox(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                "State",
                                style: TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.w500,
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(
                                height: 5,
                              ),
                              DropdownButtonFormField<String>(
                                value: state.isEmpty ? null : state,
                                items: stateMenuList,
                                onChanged: (v) {
                                  setState(() {
                                    state = v!;
                                    city = "";
                                  });
                                  getcity();
                                },
                                decoration: const InputDecoration(
                                  fillColor: Color(0xfff1f5f9),
                                  filled: true,
                                  border: OutlineInputBorder(
                                    borderSide: BorderSide.none,
                                  ),
                                  hintText: "State",
                                  prefixIcon: Icon(
                                    Icons.map_outlined,
                                  ),
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return "State is Must";
                                  } else {
                                    return null;
                                  }
                                },
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        SizedBox(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                "City",
                                style: TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.w500,
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(
                                height: 5,
                              ),
                              DropdownButtonFormField<String>(
                                value: state.isEmpty || city.isEmpty ? null : city,
                                items: cityMenuList,
                                onChanged: (v) {
                                  setState(() {
                                    city = v!;
                                  });
                                },
                                decoration: const InputDecoration(
                                  fillColor: Color(0xfff1f5f9),
                                  filled: true,
                                  border: OutlineInputBorder(
                                    borderSide: BorderSide.none,
                                  ),
                                  hintText: "City",
                                  prefixIcon: Icon(
                                    Icons.explore_outlined,
                                  ),
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return "City is Must";
                                  } else {
                                    return null;
                                  }
                                },
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        SizedBox(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                "Pincode",
                                style: TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.w500,
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(
                                height: 5,
                              ),
                              TextFormField(
                                controller: pincode,
                                cursorColor: Theme.of(context).primaryColor,
                                textInputAction: TextInputAction.done,
                                keyboardType: TextInputType.number,
                                decoration: const InputDecoration(
                                  fillColor: Color(0xfff1f5f9),
                                  filled: true,
                                  border: OutlineInputBorder(
                                    borderSide: BorderSide.none,
                                  ),
                                  hintText: "Pincode",
                                  prefixIcon: Icon(
                                    Icons.near_me_outlined,
                                  ),
                                ),
                                validator: (value) {
                                  return FormValidation().commonValidation(
                                    input: value,
                                    isMandorty: true,
                                    formName: "Pincode",
                                    isOnlyCharter: false,
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        SizedBox(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                "Mobile No",
                                style: TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.w500,
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(
                                height: 5,
                              ),
                              TextFormField(
                                controller: mobileno,
                                cursorColor: Theme.of(context).primaryColor,
                                textInputAction: TextInputAction.done,
                                keyboardType: TextInputType.number,
                                decoration: const InputDecoration(
                                  fillColor: Color(0xfff1f5f9),
                                  filled: true,
                                  border: OutlineInputBorder(
                                    borderSide: BorderSide.none,
                                  ),
                                  hintText: "Mobile Number",
                                  prefixIcon: Icon(
                                    Icons.phone_outlined,
                                  ),
                                ),
                                validator: (value) {
                                  return FormValidation().phoneValidation(
                                    input: value!,
                                    isMandorty: true,
                                    lableName: "Mobile No",
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        SizedBox(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                "Phone No",
                                style: TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.w500,
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(
                                height: 5,
                              ),
                              TextFormField(
                                controller: phoneno,
                                cursorColor: Theme.of(context).primaryColor,
                                textInputAction: TextInputAction.done,
                                keyboardType: TextInputType.number,
                                decoration: const InputDecoration(
                                  fillColor: Color(0xfff1f5f9),
                                  filled: true,
                                  border: OutlineInputBorder(
                                    borderSide: BorderSide.none,
                                  ),
                                  hintText: "Phone Number",
                                  prefixIcon: Icon(
                                    Icons.phone_outlined,
                                  ),
                                ),
                                validator: (value) {
                                  return FormValidation().phoneValidation(
                                    input: value!,
                                    isMandorty: true,
                                    lableName: "Phone No",
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        SizedBox(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                "GST Number",
                                style: TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.w500,
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(
                                height: 5,
                              ),
                              TextFormField(
                                controller: gst,
                                cursorColor: Theme.of(context).primaryColor,
                                textInputAction: TextInputAction.done,
                                keyboardType: TextInputType.text,
                                decoration: const InputDecoration(
                                  fillColor: Color(0xfff1f5f9),
                                  filled: true,
                                  border: OutlineInputBorder(
                                    borderSide: BorderSide.none,
                                  ),
                                  hintText: "GST No",
                                  prefixIcon: Icon(
                                    Icons.account_balance_outlined,
                                  ),
                                ),
                              ),
                            ],
                          ),
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
      bottomNavigationBar: BottomAppBar(
        elevation: 0,
        padding: const EdgeInsets.all(10),
        child: SizedBox(
          width: double.infinity,
          child: Container(
            constraints: const BoxConstraints(
              maxWidth: 600,
            ),
            child: Row(
              children: [
                // Expanded(
                //   child: Container(
                //     height: 45,
                //     decoration: BoxDecoration(
                //       color: Theme.of(context).primaryColor.withOpacity(0.15),
                //       borderRadius: BorderRadius.circular(5),
                //     ),
                //     child: Center(
                //       child: Text(
                //         "Skip",
                //         style: TextStyle(
                //           color: Theme.of(context).primaryColor,
                //           fontWeight: FontWeight.w500,
                //           fontSize: 15,
                //         ),
                //       ),
                //     ),
                //   ),
                // ),
                // const SizedBox(
                //   width: 10,
                // ),
                Expanded(
                  flex: 2,
                  child: GestureDetector(
                    onTap: () {
                      registerNewCompany();
                    },
                    child: Container(
                      height: 45,
                      decoration: BoxDecoration(
                        color: Theme.of(context).primaryColor,
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: const Center(
                        child: Text(
                          "Submit",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w500,
                            fontSize: 15,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

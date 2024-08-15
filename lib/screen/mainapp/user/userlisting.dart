import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:sri_sakthivel_fireworks_pos/firebase/firestore_provider.dart';
import 'package:sri_sakthivel_fireworks_pos/screen/mainapp/user/userdetails.dart';
import 'package:sri_sakthivel_fireworks_pos/screen/ui/commenwidget.dart';
import 'package:sri_sakthivel_fireworks_pos/utlities/provider/localdb.dart';
import 'package:sri_sakthivel_fireworks_pos/utlities/varibales.dart';

import '../../../firebase/datamodel/datamodel.dart';
import '../homelanding.dart';

PageController userListingcontroller = PageController();

class UserListing extends StatefulWidget {
  const UserListing({super.key});

  @override
  State<UserListing> createState() => _UserListingState();
}

class _UserListingState extends State<UserListing> {
  List<UserAdminModel> userListData = [];
  late Future userlistingHandler;
  Future getUserInfo() async {
    try {
      FireStoreProvider provider = FireStoreProvider();
      var cid = await LocalDbProvider().fetchInfo(type: LocalData.companyid);
      log(cid.toString());
      if (cid != null) {
        final result = await provider.userListing(cid: cid);
        if (result!.docs.isNotEmpty) {
          log(result.docs.length.toString());
          setState(() {
            userListData.clear();
          });
          for (var element in result.docs) {
            var model = UserAdminModel();
            model.adminName = element["admin_name"].toString();
            model.phoneNo = element["phone_no"].toString();
            model.adminLoginId = element["user_login_id"].toString();
            model.password = element["password"].toString();
            model.imageUrl = element["image_url"];
            model.docid = element.id;
            model.uid = element["uid"].toString();
            setState(() {
              userListData.add(model);
            });
          }
          log(userListData.length.toString());
          return userListData;
        }
      }
      return null;
    } catch (e) {
      log(e.toString());
      throw e.toString();
    }
  }

  @override
  void initState() {
    super.initState();
    userlistingHandler = getUserInfo();
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
        title: const Text("Users"),
        actions: [
          IconButton(
            onPressed: () async {
              await openModelBottomSheat(context).then((result) {
                if (result != null && result == true) {
                  setState(() {
                    userlistingHandler = getUserInfo();
                  });
                }
              });
            },
            splashRadius: 20,
            icon: const Icon(
              Icons.add,
            ),
          ),
        ],
      ),
      body: FutureBuilder(
        future: userlistingHandler,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return PageView(
              physics: const NeverScrollableScrollPhysics(),
              controller: userListingcontroller,
              children: [
                Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Container(
                    height: double.infinity,
                    width: double.infinity,
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: userListData.isNotEmpty
                        ? RefreshIndicator(
                            onRefresh: () async {
                              setState(() {
                                userlistingHandler = getUserInfo();
                              });
                            },
                            child: ListView.builder(
                              itemCount: userListData.length,
                              itemBuilder: (context, index) {
                                return Column(
                                  children: [
                                    ListTile(
                                      contentPadding: const EdgeInsets.all(0),
                                      onTap: () {
                                        setState(() {
                                          adminuid = userListData[index].uid;
                                          adminDocId = userListData[index].docid;
                                          adminPagetitle = userListData[index].adminName;
                                          adminuserName.text = userListData[index].adminName ?? "";
                                          adminphoneno.text = userListData[index].phoneNo ?? "";
                                          adminuserid.text = userListData[index].adminLoginId ?? "";
                                          adminpassword.text = userListData[index].password ?? "";
                                          adminProfileImage = userListData[index].imageUrl;
                                          userListingcontroller.animateToPage(
                                            1,
                                            duration: const Duration(
                                              milliseconds: 600,
                                            ),
                                            curve: Curves.linear,
                                          );
                                        });
                                      },
                                      leading: Container(
                                        height: 50,
                                        width: 50,
                                        decoration: BoxDecoration(
                                          color: Colors.grey.shade300,
                                          shape: BoxShape.circle,
                                          image: userListData[index].imageUrl == null
                                              ? null
                                              : DecorationImage(
                                                  image: NetworkImage(
                                                    userListData[index].imageUrl!,
                                                  ),
                                                  fit: BoxFit.cover,
                                                ),
                                        ),
                                      ),
                                      title: Text(
                                        userListData[index].adminName.toString(),
                                      ),
                                      subtitle: Text(
                                        userListData[index].adminLoginId.toString(),
                                        style: TextStyle(
                                          color: Colors.grey.shade400,
                                          fontSize: 13,
                                        ),
                                      ),
                                      trailing: const Icon(
                                        Icons.chevron_right_outlined,
                                      ),
                                    ),
                                    Divider(
                                      height: 0,
                                      color: Colors.grey.shade300,
                                    ),
                                  ],
                                );
                              },
                            ),
                          )
                        : Padding(
                            padding: const EdgeInsets.all(15.0),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.all(10.0),
                                  child: AspectRatio(
                                    aspectRatio: (1 / 0.7),
                                    child: SvgPicture.asset(
                                      'assets/empty_list3.svg',
                                    ),
                                  ),
                                ),
                                const SizedBox(
                                  height: 15,
                                ),
                                Text(
                                  "No Users",
                                  style: Theme.of(context).textTheme.titleLarge!.copyWith(),
                                ),
                                const SizedBox(
                                  height: 8,
                                ),
                                Center(
                                  child: Text(
                                    "You have not create any user, so first you have create user using add user button below",
                                    textAlign: TextAlign.center,
                                    style: Theme.of(context).textTheme.bodySmall!.copyWith(color: Colors.grey),
                                  ),
                                ),
                                const SizedBox(
                                  height: 15,
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                  children: [
                                    TextButton.icon(
                                      onPressed: () {
                                        openModelBottomSheat(context);
                                      },
                                      icon: const Icon(Icons.add),
                                      label: const Text("Add User"),
                                    ),
                                    TextButton.icon(
                                      onPressed: () {
                                        setState(() {
                                          userlistingHandler = getUserInfo();
                                        });
                                      },
                                      icon: const Icon(Icons.refresh),
                                      label: const Text("Refresh"),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                  ),
                ),
                const UserDetails(),
              ],
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
                            userlistingHandler = getUserInfo();
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

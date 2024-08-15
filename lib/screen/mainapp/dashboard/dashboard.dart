import 'package:flutter/material.dart';
import 'package:sri_sakthivel_fireworks_pos/firebase/firestore_provider.dart';
import 'package:sri_sakthivel_fireworks_pos/utlities/utlities.dart';
import '../../../utlities/provider/localdb.dart';
import '../../ui/sidebar.dart';
import '../homelanding.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({super.key});

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  String? customer;
  String? enquriy;
  String? estimate;
  String? product;
  bool isAdmin = false;

  Future<void> getCustomerCount() async {
    try {
      await LocalDbProvider().fetchInfo(type: LocalData.companyid).then((cid) async {
        await FireStoreProvider().getCustomerCount(cid: cid).then((value) {
          if (value != null) {
            setState(() {
              customer = value.count.toString();
            });
          } else {
            setState(() {
              customer = "0";
            });
          }
        });
      });
    } catch (e) {
      snackBarCustom(context, false, e.toString());
    }
  }

  Future<void> getEnquiryCount() async {
    try {
      await LocalDbProvider().fetchInfo(type: LocalData.companyid).then((cid) async {
        await FireStoreProvider().getEnquiryCount(cid: cid).then((value) {
          if (value != null) {
            setState(() {
              enquriy = value.count.toString();
            });
          } else {
            setState(() {
              enquriy = "0";
            });
          }
        });
      });
    } catch (e) {
      snackBarCustom(context, false, e.toString());
    }
  }

  Future<void> getEstimateCount() async {
    try {
      await LocalDbProvider().fetchInfo(type: LocalData.companyid).then((cid) async {
        await FireStoreProvider().getEstimateCount(cid: cid).then((value) {
          if (value != null) {
            setState(() {
              estimate = value.count.toString();
            });
          } else {
            setState(() {
              estimate = "0";
            });
          }
        });
      });
    } catch (e) {
      snackBarCustom(context, false, e.toString());
    }
  }

  Future<void> getProductCount() async {
    try {
      await LocalDbProvider().fetchInfo(type: LocalData.companyid).then((cid) async {
        await FireStoreProvider().getProductCount(cid: cid).then((value) {
          if (value != null) {
            setState(() {
              product = value.count.toString();
            });
          } else {
            setState(() {
              product = "0";
            });
          }
        });
      });
    } catch (e) {
      snackBarCustom(context, false, e.toString());
    }
  }

  int getTabSize() {
    int count = 2;
    if (MediaQuery.of(context).size.width > 800) {
      setState(() {
        count = 6;
      });
    } else if (MediaQuery.of(context).size.width > 600) {
      setState(() {
        count = 4;
      });
    }
    return count;
  }

  int bilingTab = 1;

  bool prCustomer = false;
  bool prEnquiry = false;
  bool prEstimate = false;
  bool prProduct = false;

  getinfo() async {
    await LocalDbProvider().fetchInfo(type: LocalData.all).then((value) {
      if (value != null) {
        setState(() {
          bilingTab = value["billing"];
          isAdmin = value["isAdmin"];
          prCustomer = value["pr_customer"];
          prEnquiry = value["pr_order"];
          prEstimate = value["pr_estimate"];
          prProduct = value["pr_product"];
        });
      }
    });
  }

  @override
  void initState() {
    getinfo();
    super.initState();
    getCustomerCount();
    getEnquiryCount();
    getEstimateCount();
    getProductCount();
    getinfo();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
          splashRadius: 20,
          onPressed: () {
            homeKey.currentState!.openDrawer();
          },
          icon: const Icon(Icons.menu),
        ),
        title: const Text("Dashboard"),
        actions: [
          IconButton(
            onPressed: () {},
            splashRadius: 20,
            icon: const Icon(
              Icons.notifications,
            ),
          ),
        ],
      ),
      body: isAdmin == true
          ? ListView(
              padding: const EdgeInsets.all(10),
              children: [
                GridView(
                  primary: false,
                  shrinkWrap: true,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: getTabSize(),
                    mainAxisSpacing: 10,
                    crossAxisSpacing: 10,
                    childAspectRatio: (1 / 1.12),
                  ),
                  children: [
                    if (prCustomer)
                      dashboardcard(
                        title: "Customer",
                        subtitle: customer,
                        primaryColor: const Color(0xff4895ef),
                        icon: Icons.person,
                        onTap: () {
                          setState(() {
                            sidebar.toggletab(4);
                          });
                        },
                      ),
                    if (prEnquiry)
                      dashboardcard(
                        title: "Enquiry",
                        subtitle: enquriy,
                        primaryColor: const Color(0xffB284BE),
                        icon: Icons.business_outlined,
                        onTap: () {
                          setState(() {
                            sidebar.toggletab(9);
                          });
                        },
                      ),
                    if (prEstimate)
                      dashboardcard(
                        title: "Estimate",
                        subtitle: estimate,
                        primaryColor: const Color(0xff3d348b),
                        icon: Icons.business_outlined,
                        onTap: () {
                          setState(() {
                            sidebar.toggletab(10);
                          });
                        },
                      ),
                    if (prProduct)
                      dashboardcard(
                        title: "Product",
                        subtitle: product,
                        primaryColor: const Color(0xff6a994e),
                        icon: Icons.category,
                        onTap: () {
                          setState(() {
                            sidebar.toggletab(5);
                          });
                        },
                      ),
                  ],
                ),
                if (prEnquiry || prEstimate)
                  GestureDetector(
                    onTap: () {
                      sidebar.toggletab(bilingTab == 1 ? 7 : 8);
                    },
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 10, top: 10),
                      decoration: BoxDecoration(
                        color: Colors.black12,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                      child: Row(
                        children: [
                          const Text(
                            "Quick Billing",
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 15,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(
                            width: 5,
                          ),
                          // Container(
                          //   padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                          //   decoration: BoxDecoration(
                          //     color: Theme.of(context).primaryColor,
                          //     borderRadius: BorderRadius.circular(3),
                          //   ),
                          //   child: const Text(
                          //     "PRO",
                          //     style: TextStyle(
                          //       color: Colors.white,
                          //     ),
                          //   ),
                          // ),
                          const Spacer(),
                          const SizedBox(
                            width: 10,
                          ),
                          Container(
                            padding: const EdgeInsets.all(5),
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white,
                            ),
                            child: const Icon(
                              Icons.north_east_outlined,
                              size: 20,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            )
          : const SizedBox(),
    );
  }

  Widget dashboardcard({
    required String title,
    required String? subtitle,
    required Color primaryColor,
    required IconData icon,
    required void Function()? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(5),
          color: primaryColor.withOpacity(0.5),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              alignment: Alignment.centerRight,
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  color: primaryColor,
                ),
              ),
            ),
            const Spacer(),
            Text(
              title,
              style: Theme.of(context).textTheme.titleLarge,
              // style: const TextStyle(
              //   color: Colors.black,
              //   fontSize: 25,
              //   fontWeight: FontWeight.bold,
              // ),
            ),
            const SizedBox(
              height: 8,
            ),
            subtitle != null
                ? Text(
                    subtitle,
                    style: Theme.of(context).textTheme.bodyLarge,
                    // style: const TextStyle(
                    //   color: Colors.black,
                    //   fontSize: 18,
                    //   fontWeight: FontWeight.bold,
                    // ),
                  )
                : const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 1,
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}

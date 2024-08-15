import 'package:flutter/material.dart';
import 'package:sri_sakthivel_fireworks_pos/utlities/provider/localdb.dart';

import '../../homelanding.dart';

class AppSettings extends StatefulWidget {
  const AppSettings({super.key});

  @override
  State<AppSettings> createState() => _AppSettingsState();
}

class _AppSettingsState extends State<AppSettings> {
  int crtBillingTab = 1;
  initFn() async {
    await LocalDbProvider().getBillingIndex().then((value) async {
      if (value != null) {
        setState(() {
          crtBillingTab = value;
        });
      } else {
        await LocalDbProvider().changeBilling(1);
        setState(() {
          crtBillingTab = 1;
        });
      }
    });
  }

  @override
  void initState() {
    super.initState();
    initFn();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffECECEC),
      appBar: AppBar(
        leading: IconButton(
          splashRadius: 20,
          onPressed: () {
            homeKey.currentState!.openDrawer();
          },
          icon: const Icon(Icons.menu),
        ),
        title: const Text("App Settings"),
      ),
      body: ListView(
        padding: const EdgeInsets.all(10),
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Billing Page",
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                const SizedBox(
                  height: 10,
                ),
                SizedBox(
                  child: Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              crtBillingTab = 1;
                              LocalDbProvider().changeBilling(1);
                            });
                          },
                          child: Container(
                            height: 250,
                            decoration: BoxDecoration(
                              color: crtBillingTab == 1 ? Colors.grey.shade100 : Colors.transparent,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Stack(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.all(15),
                                  child: Center(
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(5),
                                      child: Image.asset(
                                        'assets/billing2.jpg',
                                        height: 240,
                                        fit: BoxFit.contain,
                                      ),
                                    ),
                                  ),
                                ),
                                Align(
                                  alignment: Alignment.topRight,
                                  child: Container(
                                    height: 25,
                                    width: 25,
                                    decoration: BoxDecoration(
                                      color: crtBillingTab == 1 ? Theme.of(context).primaryColor : Colors.grey.shade100,
                                      shape: BoxShape.circle,
                                    ),
                                    child: crtBillingTab == 1
                                        ? const Center(
                                            child: Icon(
                                              Icons.check,
                                              color: Colors.white,
                                              size: 18,
                                            ),
                                          )
                                        : null,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              crtBillingTab = 2;
                              LocalDbProvider().changeBilling(2);
                            });
                          },
                          child: Container(
                            height: 250,
                            decoration: BoxDecoration(
                              color: crtBillingTab == 2 ? Colors.grey.shade100 : Colors.transparent,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Stack(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.all(15),
                                  child: Center(
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(5),
                                      child: Image.asset(
                                        'assets/billing1.jpg',
                                        height: 240,
                                        fit: BoxFit.contain,
                                      ),
                                    ),
                                  ),
                                ),
                                Align(
                                  alignment: Alignment.topRight,
                                  child: Container(
                                    height: 25,
                                    width: 25,
                                    decoration: BoxDecoration(
                                      color: crtBillingTab == 2 ? Theme.of(context).primaryColor : Colors.grey.shade100,
                                      shape: BoxShape.circle,
                                    ),
                                    child: crtBillingTab == 2
                                        ? const Center(
                                            child: Icon(
                                              Icons.check,
                                              color: Colors.white,
                                              size: 18,
                                            ),
                                          )
                                        : null,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

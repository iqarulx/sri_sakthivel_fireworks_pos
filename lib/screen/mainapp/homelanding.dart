import 'package:flutter/material.dart';

import 'billing/app_settings/app_settings.dart';
import 'billing/billing_two.dart';
import 'category/category_listing.dart';
import 'category_discount/category_discount_view.dart';
import 'company/companylisting.dart';
import 'customer/customerlisting.dart';
import 'dashboard/dashboard.dart';
import 'enquiry/enquiry_listing.dart';
import 'estimate/estimate_listing.dart';
import 'invoice/invoice_listing.dart';
import 'product/productlisting.dart';
import 'staff/stafflistting.dart';
import 'user/userlisting.dart';
import '../ui/sidebar.dart';
import 'billing/billing_one.dart';

var homeKey = GlobalKey<ScaffoldState>();

class HomeLanding extends StatefulWidget {
  const HomeLanding({super.key});

  @override
  State<HomeLanding> createState() => _HomeLandingState();
}

class _HomeLandingState extends State<HomeLanding> {
  List<Widget> pages = const [
    Dashboard(),
    UserListing(),
    CompanyListing(),
    StaffListing(),
    CustomerListing(),
    ProductListing(),
    CategoryListing(),
    BillingOne(),
    BillingTwo(),
    EnquiryListing(),
    EstimateListing(),
    Scaffold(),
    AppSettings(),
    InvoiceListing(),
    CategoryDiscountView(),
  ];

  changeEvent() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    super.dispose();
    sidebar.addListener(changeEvent);
  }

  @override
  void initState() {
    super.initState();
    sidebar.addListener(changeEvent);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: homeKey,
      drawer: const SideBar(),
      body: pages[sidebar.crttab],
    );
  }
}

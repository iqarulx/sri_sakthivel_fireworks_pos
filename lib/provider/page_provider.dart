import 'package:flutter/material.dart';

class BilingPageProvider with ChangeNotifier {
  bool _crttab = false;
  get crttab => _crttab;

  toggletab(bool tab) {
    _crttab = tab;
    notifyListeners();
  }
}

class StaffListingPageProvider with ChangeNotifier {
  bool _crttab = false;
  get crttab => _crttab;

  toggletab(bool tab) {
    _crttab = tab;
    notifyListeners();
  }
}

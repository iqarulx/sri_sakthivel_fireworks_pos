import 'package:flutter/material.dart';

class SideBarEvent with ChangeNotifier {
  int _crttab = 0;
  get crttab => _crttab;

  toggletab(int tab) {
    _crttab = tab;
    notifyListeners();
  }
}

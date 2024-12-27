import 'package:flutter/material.dart';

class RankStateProvider extends ChangeNotifier {
  int currentTabIndex = 0;

  void setTabIndex(int index) {
    currentTabIndex = index;
    notifyListeners();
  }
}

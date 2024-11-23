import 'package:flutter/foundation.dart';

class NavigationState extends ChangeNotifier {
  int _selectedIndex = 0;
  bool _shouldOpenAddItem = false; // 追加

  int get selectedIndex => _selectedIndex;
  bool get shouldOpenAddItem => _shouldOpenAddItem; // 追加

  void setIndex(int index) {
    _selectedIndex = index;
    notifyListeners();
  }

  void setShouldOpenAddItem(bool value) {
    // 追加
    _shouldOpenAddItem = value;
    notifyListeners();
  }
}

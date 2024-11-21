import 'package:flutter/foundation.dart';

class NavigationState extends ChangeNotifier {
  int _selectedIndex = 0;
  bool _shouldOpenAddItem = false; // 追加
  bool _isTransitioning = false; // 追

  int get selectedIndex => _selectedIndex;
  bool get shouldOpenAddItem => _shouldOpenAddItem; // 追加
  bool get isTransitioning => _isTransitioning; // 追加

  void setIndex(int index) {
    _selectedIndex = index;
    notifyListeners();
  }

  void setShouldOpenAddItem(bool value) {
    // 追加
    _shouldOpenAddItem = value;
    notifyListeners();
  }

  void setTransitioning(bool value) {
    // 追加
    _isTransitioning = value;
    notifyListeners();
  }
}

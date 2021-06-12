import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'list.dart';

class MainProvider with ChangeNotifier{
  String _listId;
  String _district = districts[0];

  void openList(PageController controller, String id){
    controller.animateToPage(1, duration: Duration(milliseconds: 300), curve: Curves.easeInOut).then((_) {
      _listId = id;
      notifyListeners();
    });
  }

  void closeList(PageController controller){
    controller.animateToPage(0, duration: Duration(milliseconds: 300), curve: Curves.easeInOut).then((_) {
      _listId = null;
      _district = districts[0];
      notifyListeners();
    });
  }

  updateArea(String selectedDistrict){
    _district = selectedDistrict;
    notifyListeners();
  }

  String get listId => _listId;
  String get district => _district;
}
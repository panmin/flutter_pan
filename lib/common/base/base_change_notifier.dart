import 'package:flutter/material.dart';
import 'package:flutter_pan/common/widget/loading_state_widget.dart';

class BaseChangeNotifier extends ChangeNotifier {
  bool _dispose = false;
  LoadingSate loadingSate = LoadingSate.loading;

  @override
  void dispose() {
    super.dispose();
    _dispose = true;
  }

  @override
  void notifyListeners() {
    if (!_dispose) {
      super.notifyListeners();
    }
  }
}

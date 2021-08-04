import 'package:flutter_pan/common/base/base_change_notifier.dart';
import 'package:flutter_pan/common/widget/loading_state_widget.dart';

abstract class BaseViewModel extends BaseChangeNotifier{
  void refresh(){

  }
  void loadMore(){}

  void retry(){
    loadingSate = LoadingSate.loading;
    notifyListeners();
    refresh();
  }

  void success(){
    loadingSate = LoadingSate.done;
    notifyListeners();
  }

  void error(){
    loadingSate = LoadingSate.error;
    notifyListeners();
  }
}
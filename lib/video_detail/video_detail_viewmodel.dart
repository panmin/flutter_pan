import 'package:flutter_pan/common/base/base_viewmodel.dart';
import 'package:flutter_pan/common/http/http_manager.dart';
import 'package:flutter_pan/home/home_model.dart';

class VideoDetailViewModel extends BaseViewModel{

  String _detailId;
  VideoDetailViewModel(String detailId):_detailId = detailId;

  ItemList? currentInfo;
  List<ItemList>? listOther;

  @override
  Future refresh() async{
    var result = await HttpManager.get("https://baobab.kaiyanapp.com/api/v4/video/related?id=$_detailId");
    List<ItemList> list = [];
    result['itemList'].forEach((v) {
      list.add(ItemList.fromJson(v));
    });
    list.removeWhere((element) => element.type=="textCard");
    currentInfo = list[0];
    listOther = list.skip(1).toList();
  }
}
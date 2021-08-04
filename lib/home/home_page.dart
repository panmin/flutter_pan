import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_pan/common/base/base_pull_refresh_state.dart';
import 'package:flutter_pan/common/base/base_state.dart';
import 'package:flutter_pan/common/base/base_viewmodel.dart';
import 'package:flutter_pan/common/http/Url.dart';
import 'package:flutter_pan/common/http/http_manager.dart';
import 'package:flutter_pan/home/home_model.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends BasePullRefreshState<HomeViewModel, HomePage> {
  @override
  String? get title => "首页";

  @override
  HomeViewModel get viewModel => HomeViewModel();

  @override
  Widget getChild(HomeViewModel model) {
    return ListView.separated(
        itemBuilder: (BuildContext context, int index) {
          return Container(
            height: 100,
            child: Text(model.listModel[index].data?.title??"",style: TextStyle(fontSize: 16,color: Colors.black),),
          );
        },
        separatorBuilder: (BuildContext context, int index) {
          return SizedBox(height: 20,);
        },
        itemCount: model.listModel.length);
  }
}

class HomeViewModel extends BaseViewModel {
  List<ItemList> listModel = [];

  String nextUrl = "";

  @override
  Future refresh() async {
    var result = await HttpManager.get(Url.homeUrl);
    HomeModel homeModel = HomeModel.fromJson(result);
    var list = homeModel.issueList?[0].itemList;
    list?.removeWhere((element) => element.type == "banner2");
    nextUrl = homeModel.nextPageUrl??"";
    if (list != null) {
      listModel.clear();
      listModel.addAll(list);
    }
  }

  @override
  Future loadMore() async{
    if(nextUrl==""){
      return true;
    }else{
      var result = await HttpManager.get(nextUrl);
      HomeModel homeModel = HomeModel.fromJson(result);
      var list = homeModel.issueList?[0].itemList;
      list?.removeWhere((element) => element.type == "TextHeader");
      nextUrl = homeModel.nextPageUrl??"";
      print(nextUrl);
      if (list != null) {
        listModel.addAll(list);
      }
      return false;
    }
  }
}

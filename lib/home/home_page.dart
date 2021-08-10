import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_pan/common/base/base_pull_refresh_state.dart';
import 'package:flutter_pan/common/base/base_viewmodel.dart';
import 'package:flutter_pan/common/http/Url.dart';
import 'package:flutter_pan/common/http/http_manager.dart';
import 'package:flutter_pan/common/utils/cache_image.dart';
import 'package:flutter_pan/common/utils/date_util.dart';
import 'package:flutter_pan/common/widget/banner_widget.dart';
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
          if (index == 0) {
            return _banner(model);
          }
          var data = model.listModel[index].data;
          if(model.listModel[index].type == "textHeader"){
            return Container(
              margin: const EdgeInsets.only(top: 10),
              child: Center(child: Text(data?.text??"",style: TextStyle(fontSize: 16,fontFamily: data?.font,fontWeight: FontWeight.bold),)),
            );
          }

          return Column(
            children: [
              _ItemImage(data),
              // _author(data)
            ],
          );
        },
        separatorBuilder: (BuildContext context, int index) {
          return SizedBox(
            height: 20,
          );
        },
        itemCount: model.listModel.length);
  }

  Widget _ItemImage(Data? data){
    return Stack(
      children: [
        Container(
          height: 200,
          padding: EdgeInsets.only(left: 15, top: 15, right: 15),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: cacheImage(data?.cover?.feed ?? "",
                width: MediaQuery.of(context).size.width, height: 200),
          ),
        ),
        Positioned(
            right: 25,
            bottom: 10,
            child: Container(
              padding:
              const EdgeInsets.symmetric(vertical: 2, horizontal: 4),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(4),
                color: Colors.white38,
              ),
              child: Text(
                formatDateMsByMS((data?.duration??0)*1000),
                style: TextStyle(color: Colors.black, fontSize: 10),
              ),
            ))
      ],
    );
  }

  Widget _banner(HomeViewModel model) {
    return Container(
      height: 200,
      padding: EdgeInsets.only(left: 15, top: 15, right: 15),
      // ClipRRect:对子组件进行圆角裁剪
      child: ClipRRect(
        borderRadius: BorderRadius.circular(4),
        child: BannerWidget(banners: model.listBanner),
      ),
    );
  }
  
  Widget _author(Data? data) {
    return Row(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(40),
          child: cacheImage(data?.header),
        )
      ],
    );
  }
}

class HomeViewModel extends BaseViewModel {
  List<BannerModel> listBanner = [];
  List<ItemList> listModel = [];

  String nextUrl = "";

  @override
  Future refresh() async {
    var result = await HttpManager.get(Url.homeUrl);
    HomeModel homeModel = HomeModel.fromJson(result);
    var list = homeModel.issueList?[0].itemList;
    list?.removeWhere((element) => element.type == "banner2");
    nextUrl = (homeModel.nextPageUrl ?? "").replaceAll("http://baobab.kaiyanapp.com", "http://localhost:4500");
    if (list != null) {
      listBanner.clear();
      list.forEach((item) {
        listBanner.add(BannerModel(item.data?.cover?.feed ?? "",
            title: item.data?.title ?? "",
            desc: item.data?.description ?? "",
            routerUrl: ""));
      });
      await loadMore();
    }
  }

  @override
  Future loadMore() async {
    if (nextUrl == "") {
      return true;
    } else {
      var result = await HttpManager.get(nextUrl);
      HomeModel homeModel = HomeModel.fromJson(result);
      var list = homeModel.issueList?[0].itemList;
      // list?.removeWhere((element) => element.type == "TextHeader");
      nextUrl = (homeModel.nextPageUrl ?? "").replaceAll("http://baobab.kaiyanapp.com", "http://localhost:4500");
      print(nextUrl);
      if (list != null) {
        listModel.addAll(list);
      }
      return false;
    }
  }
}

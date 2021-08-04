import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_pan/common/base/base_state.dart';
import 'package:flutter_pan/common/base/base_viewmodel.dart';
import 'package:flutter_pan/common/widget/loading_state_widget.dart';
import 'package:flutter_pan/common/widget/provider_widget.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}
class _HomePageState extends BaseState<HomeViewModel,HomePage>{
  @override
  Widget getChild(HomeViewModel model) {
    return Text("success："+model.loadingSate.index.toString());
  }

  @override
  HomeViewModel get viewModel => HomeViewModel();

  @override
  String? get title => "首页";



}
/*class _HomePageState extends State<HomePage> {

  HomeViewModel homeViewModel = new HomeViewModel();
  @override
  void initState() {
    homeViewModel.refresh();
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: ProviderWidget(
        model: homeViewModel,
        builder: (context, HomeViewModel model, child) {
          return LoadingStateWidget(
            loadingSate: model.loadingSate,
            child: Text("success"),
          );
        },
      ),
    );
  }
}*/

class HomeViewModel extends BaseViewModel {
  @override
  void refresh(){
    // Future.delayed(Duration(seconds: 1))
    // .then((value){
    //   // success();
    //   error();
    // });
    //
    /*try {
      List<int> list = [1, 2];
      list[2].toString();
    }catch(e){
      throw e;
    }*/
    Future.delayed(
      Duration(seconds: 2)
    ).then((value){success();});
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_pan/common/base/base_viewmodel.dart';
import 'package:flutter_pan/common/widget/loading_state_widget.dart';
import 'package:flutter_pan/common/widget/provider_widget.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  HomeViewModel homeViewModel = new HomeViewModel();
  @override
  void initState() {
    homeViewModel.refresh();
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
}

class HomeViewModel extends BaseViewModel {
  @override
  void refresh(){
    Future.delayed(Duration(seconds: 5))
    .then((value){
      loadingSate = LoadingSate.done;
      notifyListeners();
    });
  }
}

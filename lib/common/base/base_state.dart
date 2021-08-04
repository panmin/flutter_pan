import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_pan/common/base/base_viewmodel.dart';
import 'package:flutter_pan/common/widget/appbar.dart';
import 'package:flutter_pan/common/widget/loading_state_widget.dart';
import 'package:flutter_pan/common/widget/provider_widget.dart';

abstract class BaseState<VM extends BaseViewModel, V extends StatefulWidget>
    extends State<V> with AutomaticKeepAliveClientMixin {
  // appBar 相关配置
  String? get title;

  bool showBack = false;
  List<Widget>? actions;
  PreferredSizeWidget? bottom;

  VM get viewModel;

  Widget getChild(VM model);

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      appBar: title == null
          ? null
          : appBar(title!,
              showBack: showBack, actions: actions, bottom: bottom),
      body: ProviderWidget<VM>(
        model: viewModel,
        onModelInit: (model) async {
          try {
            debugPrint("---start");
            await model.refresh();
            debugPrint("---end");
            model.success();
          }catch(e){
            model.error();
          }
        },
        builder: (context, VM model, child) {
          return LoadingStateWidget(
            loadingSate: model.loadingSate,
            retry: model.retry,
            child: getChild(model),
          );
        },
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}

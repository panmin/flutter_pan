import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_pan/common/base/base_state.dart';
import 'package:flutter_pan/common/base/base_viewmodel.dart';
import 'package:flutter_pan/common/widget/appbar.dart';
import 'package:flutter_pan/common/widget/loading_state_widget.dart';
import 'package:flutter_pan/common/widget/provider_widget.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

/// 带下拉刷新的State
abstract class BasePullRefreshState<VM extends BaseViewModel,
    V extends StatefulWidget> extends BaseState<VM, V> {
  RefreshController _refreshController = RefreshController();

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
        onModelInit: (vm) async {
          try {
            await vm.refresh();
            vm.success();
          } catch (e) {
            vm.error();
          }
        },
        builder: (context, VM vm, child) {
          return LoadingStateWidget(
            loadingSate: vm.loadingSate,
            retry: vm.retry,
            child: SmartRefresher(
                controller: _refreshController,
                child: getChild(vm),
                onRefresh: () async {
                  try {
                    await vm.refresh();
                    // vm.success();
                    _refreshController.refreshCompleted();
                    vm.notifyListeners();
                  } catch (e) {
                    _refreshController.refreshFailed();
                    vm.error();
                  }
                },
                onLoading: () async {
                  try {
                    var hasNoData = await vm.loadMore();
                    // vm.success();
                    if (hasNoData == true) {
                      _refreshController.loadNoData();
                    } else {
                      _refreshController.loadComplete();
                    }
                    vm.notifyListeners();
                  } catch (e) {
                    // vm.error();
                    _refreshController.loadFailed();
                  }
                },
                enablePullUp: true),
          );
        },
      ),
    );
  }
}

import 'package:flutter/material.dart';

enum LoadingSate { loading, error, done }

/// 加载状态
class LoadingStateWidget extends StatelessWidget {
  final LoadingSate loadingSate;
  final Widget child;
  final Function()? retry;

  const LoadingStateWidget(
      {Key? key,
      required this.child,
      this.loadingSate = LoadingSate.loading,
      this.retry})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (loadingSate == LoadingSate.loading) {
      return _loadingWidget;
    } else if (loadingSate == LoadingSate.error) {
      return _loadingError;
    } else {
      return child;
    }
  }

  // 加载中。。。
  Widget get _loadingWidget {
    return Center(
      child: CircularProgressIndicator(),
    );
  }

  Widget get _loadingError {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            "assets/images/ic_error.png",
            width: 100,
            height: 100,
          ),
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              "网络请求失败",
              style: TextStyle(color: Colors.grey[500], fontSize: 18),
            ),
          ),
          Container(
            padding: const EdgeInsets.only(top: 8),
            child: OutlinedButton(
                onPressed: retry,
                child: Text(
                  "点击重试",
                  style: TextStyle(color: Colors.grey[500], fontSize: 18),
                ),
                style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all(Colors.white),
                    overlayColor: MaterialStateProperty.all(Colors.black12))),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';

/// 二级闪屏
/// Flutter 加载后，在您的应用程序准备就绪之前，可能仍有一些资源需要加载
class Splash extends StatelessWidget {
  const Splash({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Icon(
          Icons.apartment_outlined,
          size: MediaQuery.of(context).size.width * 0.785,
        ),
      ),
    );
  }
}

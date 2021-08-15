import 'package:flutter/material.dart';
import 'package:flutter_pan/splash/splash.dart';
import 'package:get/get.dart';

class GetMaterialAppWidget extends StatelessWidget {
  final Widget child;

  const GetMaterialAppWidget({Key? key, required this.child}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: Future.delayed(Duration(seconds: 0)),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return MaterialApp(
              home: Splash()
            );
          } else {
            return GetMaterialApp(home: child);
          }
        });
  }
}

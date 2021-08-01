import 'package:flutter/material.dart';
import 'package:flutter_pan/splash/splash.dart';

class GetMaterialApp extends StatelessWidget {
  final Widget child;

  const GetMaterialApp({Key? key, required this.child}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: Future.delayed(Duration(seconds: 3)),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return MaterialApp(
              home: Splash()
            );
          } else {
            return MaterialApp(home: child);
          }
        });
  }
}

import 'package:flutter/material.dart';

appBar(String title,
    {bool showBack = false,
    List<Widget>? actions,
    PreferredSizeWidget? bottom}) {
  return AppBar(
    backgroundColor: Colors.white,
    leading: showBack ? BackButton(color: Colors.black) : null,
    elevation: 0,
    title: Text(title,
        style: TextStyle(
            fontSize: 18, color: Colors.black, fontWeight: FontWeight.bold)),
    centerTitle: true,
    actions: actions,
    bottom: bottom,
  );
}

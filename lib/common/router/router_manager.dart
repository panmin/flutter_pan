import 'package:flutter/material.dart';
import 'package:get/get.dart';

class RouterManager{
  static toPage(Widget page){
    Get.to(()=>page);
  }

  static back(){
    Get.back();
  }
  static dynamic arguments() {
    return Get.arguments;
  }
}
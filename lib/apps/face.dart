import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:healing_junior/index.dart';
import 'package:healing_junior/view.dart';

class FaceView extends GetView<FaceCtrl> {
  @override
  final controller = Get.put(FaceCtrl());
  final indexCtrl = Get.put(IndexCtrl());

  FaceView({super.key});
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(10),
      padding: const EdgeInsets.all(10),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: colorPrimary,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 60),
            MyTextH3(controller.welcome, colorPrimaryContainer),
            const SizedBox(height: 60),
            ElevatedButton(
              child: Text("脑电检测"),
              onPressed: () => indexCtrl.updateIndex(1),
            ),
          ],
        ),
      ),
    );
  }
}

class FaceCtrl extends GetxController {
  String welcome = "Welcome to HealingAI";
}

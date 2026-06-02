import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:healing_junior/apps/bagua.dart';
import 'package:healing_junior/apps/card_oh.dart';
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
            MyTextH3(controller.welcome, colorPrimaryContainer),
            const SizedBox(height: 80),
            ElevatedButton(
              child: Text("脑电检测"),
              onPressed: () => indexCtrl.updateIndex(1),
            ),
            const SizedBox(height: 40),
            ElevatedButton(
              child: Text("易经卡牌"),
              onPressed: () => Get.to(() => BaguaView()),
            ),
            const SizedBox(height: 40),
            ElevatedButton(
              child: Text("OH卡疗愈"),
              onPressed: () => Get.to(() => CardohView()),
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

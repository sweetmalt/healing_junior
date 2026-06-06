import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:healing_junior/apps/bagua.dart';
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
            MyTextH1(controller.welcome),
            const SizedBox(height: 80),
            ElevatedButton(
              child: MyTextH1("脑波检测"),
              onPressed: () => indexCtrl.updateIndex(2),
            ),
            const SizedBox(height: 80),
            ElevatedButton(
              child: MyTextH1("易经卡牌"),
              onPressed: () => Get.to(() => BaguaView()),
            ),
            const SizedBox(height: 80),
            ElevatedButton(
              child: MyTextH1("OH卡疗愈"),
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

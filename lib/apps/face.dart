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
            const SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
                padding: EdgeInsets.zero, // 去掉内边距，让图片铺满
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10.0), // 圆角半径
                child: Image.asset("assets/images/brain_wave_btn.jpg"),
              ),
              onPressed: () => indexCtrl.updateIndex(2),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
                padding: EdgeInsets.zero, // 去掉内边距，让图片铺满
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10.0), // 圆角半径
                child: Image.asset("assets/images/card_oh_btn.jpg"),
              ),
              onPressed: () => indexCtrl.updateIndex(1),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
                padding: EdgeInsets.zero, // 去掉内边距，让图片铺满
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10.0), // 圆角半径
                child: Image.asset("assets/images/bagua_btn.jpg"),
              ),
              onPressed: () => Get.to(() => BaguaView()),
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

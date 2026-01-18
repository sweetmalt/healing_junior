import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:healing_junior/view.dart';

class RestingView extends GetView<RestingCtrl> {
  RestingView({super.key});
  @override
  final controller = Get.put(RestingCtrl());

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(10),
      padding: const EdgeInsets.all(10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Obx(() => CircleMiniContainer("静息率", controller.rate.value, true, colorSurface)),
          Column(
            spacing: 10,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              MyTextH2("静息"),
              MyTextP2("请选择一个空气清新安静的环境，"),
              MyTextP2("请选择最舒适的坐姿或半躺姿势。"),
              MyTextP2("排除因频繁眨眼、呼吸凌乱、肢体活动等"),
              MyTextP2("激发的干扰性肌电信号。"),
              MyTextP3("静息率是表征挣脱干扰迅速回归平静状态的重要指标", colorPrimaryContainer),
            ],
          ),
        ],
      ),
    );
  }
}

class RestingCtrl extends GetxController {
  var rate = 0.5.obs;
}



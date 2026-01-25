import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:healing_junior/view.dart';

class BrainLoadView extends GetView<BrainLoadCtrl> {
  BrainLoadView({super.key});
  @override
  final controller = Get.put(BrainLoadCtrl());

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(10),
      padding: const EdgeInsets.all(10),
      child: Column(
        spacing: 10,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Obx(() => MyTextP2("末段均值 / 历史最高值 ：${controller.load.value.toInt()} / ${controller.topLoad.value.toInt()}")),
          const SizedBox(height: 20),
          Obx(() => CircleMiniContainer("大脑负载", controller.load.value / controller.topLoad.value, true, colorSurface)),
          const SizedBox(height: 20),
          Table(
            defaultVerticalAlignment: TableCellVerticalAlignment.middle,
            columnWidths: {0: FixedColumnWidth(100), 1: FixedColumnWidth(80), 2: FixedColumnWidth(240)},
            border: TableBorder.all(color: colorSecondary, width: 2, borderRadius: BorderRadius.circular(5)),
            children: [
              TableRow(children: [
                MyTextP2("  <20%"),
                MyTextP2("  流畅"),
                MyTextP2("  从从容容，游刃有余"),
              ]),
              TableRow(children: [
                MyTextP2("  20%~40%"),
                MyTextP2("  一般"),
                MyTextP2("  增加阻抗训练，注意劳逸结合"),
              ]),
              TableRow(children: [
                MyTextP2("  >40%"),
                MyTextP2("  繁重"),
                MyTextP2("  寻求疗愈支持，帮助大脑放松"),
              ]),
            ],
          ),
        ],
      ),
    );
  }
}

class BrainLoadCtrl extends GetxController {
  var load = 100000.0.obs;
  var topLoad = 200000.0.obs;
  void init(){
    load.value = 100000.0;
    topLoad.value = 200000.0;
  }
}

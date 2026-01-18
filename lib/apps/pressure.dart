import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:healing_junior/view.dart';

class PressureView extends GetView<PressureCtrl> {
  PressureView({super.key});
  @override
  final controller = Get.put(PressureCtrl());

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(10),
      padding: EdgeInsets.all(10),
      child: Obx(() => Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              PressureGauge(
                label: "${(controller.psyPresssure.value*100).toStringAsFixed(1)}%",
                value: controller.psyPresssure.value,
                maxValue: 1.0,
                width: context.width * 0.4,
              ),
              const SizedBox(height: 10),
              MyTextP2("心理压力"),
              const SizedBox(height: 20),
              Table(
                defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                columnWidths: {0: FixedColumnWidth(80), 1: FixedColumnWidth(80), 2: FixedColumnWidth(240)},
                border: TableBorder.all(color: colorSecondary, width: 2, borderRadius: BorderRadius.circular(5)),
                children: [
                  TableRow(children: [
                    MyTextP2("  <50%"),
                    MyTextP2("  轻松"),
                    MyTextP2("  从从容容，游刃有余"),
                  ]),
                  TableRow(children: [
                    MyTextP2("  50%~70%"),
                    MyTextP2("  一般"),
                    MyTextP2("  增加阻抗训练，注意劳逸结合"),
                  ]),
                  TableRow(children: [
                    MyTextP2("  >70%"),
                    MyTextP2("  较重"),
                    MyTextP2("  寻求疗愈支持，帮助大脑放松"),
                  ]),
                ],
              ),
              const SizedBox(height: 40),
              PressureGauge(
                label: "${(controller.phyPresssure.value*100).toStringAsFixed(1)}%",
                value: controller.phyPresssure.value,
                maxValue: 1.0,
                width: context.width * 0.4,
              ),
              const SizedBox(height: 10),
              MyTextP2("心脏压力"),
              const SizedBox(height: 20),
              Table(
                defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                columnWidths: {0: FixedColumnWidth(80), 1: FixedColumnWidth(80), 2: FixedColumnWidth(240)},
                border: TableBorder.all(color: colorSecondary, width: 2, borderRadius: BorderRadius.circular(5)),
                children: [
                  TableRow(children: [
                    MyTextP2("  <20%"),
                    MyTextP2("  轻松"),
                    MyTextP2("  从从容容，游刃有余"),
                  ]),
                  TableRow(children: [
                    MyTextP2("  20%~60%"),
                    MyTextP2("  一般"),
                    MyTextP2("  增加阻抗训练，注意劳逸结合"),
                  ]),
                  TableRow(children: [
                    MyTextP2("  >60%"),
                    MyTextP2("  较重"),
                    MyTextP2("  寻求疗愈支持，帮助大脑放松"),
                  ]),
                ],
              ),
              const SizedBox(height: 40),
            ],
          )),
    );
  }
}

class PressureCtrl extends GetxController {
  final RxDouble psyPresssure = 0.5.obs;
  final RxDouble phyPresssure = 0.5.obs;
  void init() {
    psyPresssure.value = 0.5;
    phyPresssure.value = 0.5;
  }
}

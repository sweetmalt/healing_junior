import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:healing_junior/view.dart';

class HrvView extends GetView<HrvCtrl> {
  HrvView({super.key});
  @override
  final HrvCtrl controller = Get.put(HrvCtrl());
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(10),
      padding: const EdgeInsets.all(10),
      child: Obx(() => Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              MyTextP1("( 心率变异性 - HRV)"),
              const SizedBox(height: 20),
              MultiColorPieChart(
                colors: [colorSurface, const Color.fromARGB(255, 160, 200, 255), Colors.grey],
                values: [
                  controller.nn50.value / controller.nnCount.value,
                  controller.nn30.value / controller.nnCount.value,
                  controller.nn10.value / controller.nnCount.value,
                ],
                labels: ["NN50","",""],
                width: context.width * 0.4,
              ),
              const SizedBox(height: 40),
              Table(
                defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                columnWidths: {0: FixedColumnWidth(20), 1: FixedColumnWidth(120), 2: FixedColumnWidth(100), 3: FixedColumnWidth(120)},
                border: TableBorder.all(color: colorSecondary, width: 1, borderRadius: BorderRadius.circular(5)),
                children: [
                  TableRow(children: [
                    Icon(Icons.circle_rounded, size: 16, color: colorPrimary),
                    MyTextP2("  NN间期值"),
                    MyTextP2("  占比"),
                    MyTextP2(" 说明"),
                  ]),
                  TableRow(children: [
                    Icon(Icons.circle_rounded, size: 16, color: colorSurface),
                    MyTextP2("  >50"),
                    MyTextP2("  ${(controller.nn50.value / controller.nnCount.value * 100).toStringAsFixed(1)}%"),
                    MyTextP2(" 占比越高越好"),
                  ]),
                  TableRow(children: [
                    Icon(Icons.circle_rounded, size: 16, color: const Color.fromARGB(255, 160, 200, 255)),
                    MyTextP2("  30~50"),
                    MyTextP2("  ${(controller.nn30.value / controller.nnCount.value * 100).toStringAsFixed(1)}%"),
                    MyTextP2(""),
                  ]),
                  TableRow(children: [
                    Icon(Icons.circle_rounded, size: 16, color: Colors.grey),
                    MyTextP2("  <30"),
                    MyTextP2("  ${(controller.nn10.value / controller.nnCount.value * 100).toStringAsFixed(1)}%"),
                    MyTextP2(" 占比越低越好"),
                  ]),
                ],
              ),
              const SizedBox(height: 20),
              MyTextP3("NN50指相邻心跳间期值之差大于50ms，是副交感神经是否强健的重要指标",colorPrimaryContainer),
              MyTextP3("（NN50占比>30%为优秀，20%~30%之间为普通，<20%较弱）",colorPrimaryContainer),
              MyTextP3("副交感神经的强健能促进深度放松与内在修复，提升心脏调节的灵活性",colorPrimaryContainer),
              const SizedBox(height: 20),
            ],
          )),
    );
  }
}

class HrvCtrl extends GetxController {
  final RxInt nn50 = 1.obs;
  final RxInt nn30 = 1.obs;
  final RxInt nn10 = 1.obs;
  final RxInt nnCount = 3.obs;
  String assess(int hr) {
    String label = '';
    if (hr < 50) {
      label = '偏低';
    } else if (hr < 65) {
      label = '优秀';
    } else if (hr < 85) {
      label = '常见';
    } else if (hr < 105) {
      label = '偏高';
    } else {
      label = '过速';
    }
    return label;
  }
}

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:healing_junior/view.dart';

class HeartRateView extends GetView<HeartRateCtrl> {
  HeartRateView({super.key});
  @override
  final HeartRateCtrl controller = Get.put(HeartRateCtrl());
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(10),
      padding: const EdgeInsets.all(10),
      child: Obx(() => Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              MyTextP1("( 心率 )"),
              PressureGauge(
                label: controller.assess(controller.heartRate.value),
                value: controller.heartRate.value.toDouble(),
                maxValue: 150.0,
                width: context.width * 0.5,
              ),
              const SizedBox(height: 10),
              MyTextP2('${controller.heartRate.value} bpm'),
              const SizedBox(height: 40),
              Table(
                defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                columnWidths: {0: FixedColumnWidth(100), 1: FixedColumnWidth(50), 2: FixedColumnWidth(300)},
                border: TableBorder.all(
                  color: colorSecondary,
                  width: 1,
                  borderRadius: BorderRadius.circular(5),
                ),
                children: [
                  TableRow(children: [
                    MyTextP2("  < 50"),
                    MyTextP2(" 偏低"),
                    MyTextP2(" 或因情绪低落所致( 运动健将例外 )"),
                  ]),
                  TableRow(children: [
                    MyTextP2("  50 ~ 65"),
                    MyTextP2(" 优秀"),
                    MyTextP2(" 最佳状态，继续保持"),
                  ]),
                  TableRow(children: [
                    MyTextP2("  65 ~ 85"),
                    MyTextP2(" 常见"),
                    MyTextP2(" 继续保持"),
                  ]),
                  TableRow(children: [
                    MyTextP2("  85 ~ 105"),
                    MyTextP2(" 偏高"),
                    MyTextP2(" 或因兴奋所致( 当下是静息状态吗？)"),
                  ]),
                  TableRow(children: [
                    MyTextP2("  > 105"),
                    MyTextP2(" 过速"),
                    MyTextP2(" 建议寻求专业帮助"),
                  ]),
                ],
              ),
            ],
          )),
    );
  }
}

class HeartRateCtrl extends GetxController {
  final RxInt heartRate = 72.obs;
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

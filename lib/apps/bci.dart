import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:healing_junior/view.dart';

class BciView extends GetView<BciCtrl> {
  BciView({super.key});
  @override
  final BciCtrl controller = Get.put(BciCtrl());
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(10),
      padding: const EdgeInsets.all(10),
      child: Obx(() => Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              MyTextP1("( 脑波能耗比 )"),
              const SizedBox(height: 20),
              Opacity(
                opacity: 0.5,
                child: MultiColorPieChart(
                  colors: colors5,
                  values: [
                    controller.delta.value / controller.total.value,
                    controller.theta.value / controller.total.value,
                    controller.alpha.value / controller.total.value,
                    controller.beta.value / controller.total.value,
                    controller.gamma.value / controller.total.value,
                  ],
                  labels: ["δ","θ","α","β","γ"],
                  width: context.width * 0.3,
                ),
              ),
              const SizedBox(height: 40),
              Table(
                defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                columnWidths: {
                  0: FixedColumnWidth(context.width * 0.8 * (controller.delta.value / controller.total.value)),
                  1: FixedColumnWidth(context.width * 0.8 * (controller.theta.value / controller.total.value)),
                  2: FixedColumnWidth(context.width * 0.8 * (controller.alpha.value / controller.total.value)),
                  3: FixedColumnWidth(context.width * 0.8 * (controller.beta.value / controller.total.value)),
                  4: FixedColumnWidth(context.width * 0.8 * (controller.gamma.value / controller.total.value)),
                },
                border: TableBorder.all(color: colorSecondary, width: 1, borderRadius: BorderRadius.circular(10)),
                children: [
                  TableRow(children: [
                    Container(
                      alignment: Alignment.center,
                      height: 20,
                      decoration: BoxDecoration(
                          color: colors5[0],
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(25),
                            bottomLeft: Radius.circular(25),
                          )),
                      child: MyTextP3(BciCtrl.labels.keys.elementAt(0), colorPrimary),
                    ),
                    Container(
                      alignment: Alignment.center,
                      height: 20,
                      decoration: BoxDecoration(color: colors5[1]),
                      child: MyTextP3(BciCtrl.labels.keys.elementAt(1), colorPrimary),
                    ),
                    Container(
                      alignment: Alignment.center,
                      height: 20,
                      decoration: BoxDecoration(color: colors5[2]),
                      child: MyTextP3(BciCtrl.labels.keys.elementAt(2), colorPrimary),
                    ),
                    Container(
                      alignment: Alignment.center,
                      height: 20,
                      decoration: BoxDecoration(color: colors5[3]),
                      child: MyTextP3(BciCtrl.labels.keys.elementAt(3), colorPrimary),
                    ),
                    Container(
                      alignment: Alignment.center,
                      height: 20,
                      decoration: BoxDecoration(
                          color: colors5[4],
                          borderRadius: BorderRadius.only(
                            topRight: Radius.circular(25),
                            bottomRight: Radius.circular(25),
                          )),
                      child: MyTextP3(BciCtrl.labels.keys.elementAt(4), colorPrimary),
                    ),
                  ]),
                ],
              ),
              const SizedBox(height: 40),
              Table(
                defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                columnWidths: {
                  0: FixedColumnWidth(40),
                  1: FixedColumnWidth(60),
                  2: FixedColumnWidth(300),
                },
                border: TableBorder.all(color: colorSecondary, width: 1, borderRadius: BorderRadius.circular(10)),
                children: [
                  TableRow(children: [
                    MyTextP3("    ${BciCtrl.labels.keys.elementAt(4)}", colors5[4]),
                    MyTextP3("    ${(controller.gamma.value / controller.total.value*100).toStringAsFixed(1)}%", colorPrimaryContainer),
                    MyTextP3("    ${BciCtrl.labels.values.elementAt(4)}", colorPrimaryContainer),
                  ]),
                  TableRow(children: [
                    MyTextP3("    ${BciCtrl.labels.keys.elementAt(3)}", colors5[3]),
                    MyTextP3("    ${(controller.beta.value / controller.total.value*100).toStringAsFixed(1)}%", colorPrimaryContainer),
                    MyTextP3("    ${BciCtrl.labels.values.elementAt(3)}", colorPrimaryContainer),
                  ]),
                  TableRow(children: [
                    MyTextP3("    ${BciCtrl.labels.keys.elementAt(2)}", colors5[2]),
                    MyTextP3("    ${(controller.alpha.value / controller.total.value*100).toStringAsFixed(1)}%", colorPrimaryContainer),
                    MyTextP3("    ${BciCtrl.labels.values.elementAt(2)}", colorPrimaryContainer),
                  ]),
                  TableRow(children: [
                    MyTextP3("    ${BciCtrl.labels.keys.elementAt(1)}", colors5[1]),
                    MyTextP3("    ${(controller.theta.value / controller.total.value*100).toStringAsFixed(1)}%", colorPrimaryContainer),
                    MyTextP3("    ${BciCtrl.labels.values.elementAt(1)}", colorPrimaryContainer),
                  ]),
                  TableRow(children: [
                    MyTextP3("    ${BciCtrl.labels.keys.elementAt(0)}", colors5[0]),
                    MyTextP3("    ${(controller.delta.value / controller.total.value*100).toStringAsFixed(1)}%", colorPrimaryContainer),
                    MyTextP3("    ${BciCtrl.labels.values.elementAt(0)}", colorPrimaryContainer),
                  ]),
                ],
              ),
            ],
          )),
    );
  }
}

class BciCtrl extends GetxController {
  final RxDouble delta = 1.0.obs;
  final RxDouble theta = 1.0.obs;
  final RxDouble alpha = 1.0.obs;
  final RxDouble beta = 1.0.obs;
  final RxDouble gamma = 1.0.obs;
  final RxDouble total = 5.0.obs;
  static const Map<String, String> labels = {
    'δ': 'Delta波 / 与深度睡眠相关',
    'θ': 'Theta波 / 与浅睡眠相关',
    'α': 'Alpha波 / 与清醒状态下的放松相关',
    'β': 'Beta波 / 与压力及紧张焦虑相关',
    'γ': 'Gamma波 / 与深度思考相关',
  };
}

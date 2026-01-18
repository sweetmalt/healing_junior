import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:healing_junior/view.dart';

class AlphaView extends GetView<BaselineCtrl> {
  AlphaView({super.key});
  @override
  final BaselineCtrl controller = Get.put(BaselineCtrl());

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(10),
      padding: EdgeInsets.all(10),
      child: Obx(() => Column(
            children: [
              MyTextP1("( α波 )"),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  MultiColorPieChart(
                    colors: [Colors.grey, const Color.fromARGB(255, 160, 200, 255)],
                    values: [
                      controller.alphaRate.value,
                      1 - controller.alphaRate.value,
                    ],
                    labels: ["α", ""],
                    width: context.width * 0.3,
                  ),
                  MultiColorPieChart(
                    colors: [colorSurface, const Color.fromARGB(255, 160, 200, 255)],
                    values: [
                      controller.alphaRealtimeRate.value,
                      1 - controller.alphaRealtimeRate.value,
                    ],
                    labels: ["α", ""],
                    width: context.width * 0.3,
                  )
                ],
              ),
              const SizedBox(height: 20),
              MyTextP2("${(controller.alphaRate.value * 100).toStringAsFixed(1)}% 基线 | 当前 ${(controller.alphaRealtimeRate.value * 100).toStringAsFixed(1)}%"),
              const SizedBox(height: 20),
              MyTextP3("α波能量占比的提升与放松度提升相关", colorPrimaryContainer),
            ],
          )),
    );
  }
}

class BetaView extends GetView<BaselineCtrl> {
  BetaView({super.key});
  @override
  final BaselineCtrl controller = Get.put(BaselineCtrl());

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(10),
      padding: EdgeInsets.all(10),
      child: Obx(() => Column(
            children: [
              MyTextP1("( β波 )"),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  MultiColorPieChart(
                    colors: [Colors.grey, const Color.fromARGB(255, 160, 200, 255)],
                    values: [
                      controller.betaRate.value,
                      1 - controller.betaRate.value,
                    ],
                    labels: ["β", ""],
                    width: context.width * 0.3,
                  ),
                  MultiColorPieChart(
                    colors: [colorSurface, const Color.fromARGB(255, 160, 200, 255)],
                    values: [
                      controller.betaRealtimeRate.value,
                      1 - controller.betaRealtimeRate.value,
                    ],
                    labels: ["β", ""],
                    width: context.width * 0.3,
                  )
                ],
              ),
              const SizedBox(height: 20),
              MyTextP2("${(controller.betaRate.value * 100).toStringAsFixed(1)}% 基线 | 当前 ${(controller.betaRealtimeRate.value * 100).toStringAsFixed(1)}%"),
              const SizedBox(height: 20),
              MyTextP3("β波能量占比的下降与紧张焦虑和用脑程度的缓解相关", colorPrimaryContainer),
            ],
          )),
    );
  }
}

class AlphaBetaView extends GetView<BaselineCtrl> {
  AlphaBetaView({super.key});
  @override
  final BaselineCtrl controller = Get.put(BaselineCtrl());

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(10),
      padding: EdgeInsets.all(10),
      child: Obx(() => Column(
            children: [
              MyTextP1("( α波 pk β波 )"),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  BarChart(controller.alphaBetaRate.value, controller.alphaBetaRealtimeRate.value, const Color.fromARGB(255, 160, 200, 255)),
                ],
              ),
              const SizedBox(height: 20),
              MyTextP2(
                  "${(controller.alphaBetaRate.value * 100).toStringAsFixed(1)}% 基线 | 当前 ${(controller.alphaBetaRealtimeRate.value * 100).toStringAsFixed(1)}%"),
              const SizedBox(height: 20),
              MyTextP3("α/β的提升与情绪稳定性和自我疗愈力增强有关", colorPrimaryContainer),
            ],
          )),
    );
  }
}

class GammaView extends GetView<BaselineCtrl> {
  GammaView({super.key});
  @override
  final BaselineCtrl controller = Get.put(BaselineCtrl());

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(10),
      padding: EdgeInsets.all(10),
      child: Obx(() => Column(
            children: [
              MyTextP1("( γ波 )"),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  MultiColorPieChart(
                    colors: [Colors.grey, const Color.fromARGB(255, 160, 200, 255)],
                    values: [
                      controller.gammaRate.value,
                      1 - controller.gammaRate.value,
                    ],
                    labels: ["γ", ""],
                    width: context.width * 0.3,
                  ),
                  MultiColorPieChart(
                    colors: [colorSurface, const Color.fromARGB(255, 160, 200, 255)],
                    values: [
                      controller.gammaRealtimeRate.value,
                      1 - controller.gammaRealtimeRate.value,
                    ],
                    labels: ["γ", ""],
                    width: context.width * 0.3,
                  )
                ],
              ),
              const SizedBox(height: 20),
              MyTextP2("${(controller.gammaRate.value * 100).toStringAsFixed(1)}% 基线 | 当前 ${(controller.gammaRealtimeRate.value * 100).toStringAsFixed(1)}%"),
              const SizedBox(height: 20),
              MyTextP3("γ波能量占比的提升与专注度提升相关", colorPrimaryContainer),
            ],
          )),
    );
  }
}

class GammaBetaView extends GetView<BaselineCtrl> {
  GammaBetaView({super.key});
  @override
  final BaselineCtrl controller = Get.put(BaselineCtrl());

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(10),
      padding: EdgeInsets.all(10),
      child: Obx(() => Column(
            children: [
              MyTextP1("( γ波 pk β波 )"),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  BarChart(controller.gammaBetaRate.value, controller.gammaBetaRealtimeRate.value, const Color.fromARGB(255, 160, 200, 255)),
                ],
              ),
              const SizedBox(height: 20),
              MyTextP2(
                  "${(controller.gammaBetaRate.value * 100).toStringAsFixed(1)}% 基线 | 当前 ${(controller.gammaBetaRealtimeRate.value * 100).toStringAsFixed(1)}%"),
              const SizedBox(height: 20),
              MyTextP3("γ/β波的提升与抗抑郁能力的提升相关", colorPrimaryContainer),
            ],
          )),
    );
  }
}

class ReaaltimeView extends GetView<BaselineCtrl> {
  ReaaltimeView({super.key});
  @override
  final BaselineCtrl controller = Get.put(BaselineCtrl());

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(10),
      padding: EdgeInsets.all(10),
      child: Obx(() => Column(
            children: [
              MyTextP1("( 心&脑 - 实时动态 )"),
              const SizedBox(height: 20),
              GridView.count(
                crossAxisCount: 2,
                physics: NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                mainAxisSpacing: 20,
                crossAxisSpacing: 20,
                children: [
                  Card(
                    child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                      Icon(Icons.access_time),
                      Text("心率"),
                      BarChart(
                        0.5,
                        controller.heartRate.value > 0 ? controller.heartRateRealtime.value / controller.heartRate.value * 0.5 : 0.5,
                        colorSurface,
                      ),
                      Text("${controller.heartRate.value} 基线 | 当前 ${controller.heartRateRealtime.value}"),
                    ]),
                  ),
                  Card(
                    child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                      Icon(Icons.access_time),
                      Text("HRV"),
                      BarChart(
                        0.5,
                        controller.hrv.value > 0 ? controller.hrvRealtime.value / controller.hrv.value * 0.5 : 0.5,
                        colorSurface,
                      ),
                      Text("${controller.hrv.value} 基线 | 当前 ${controller.hrvRealtime.value}"),
                    ]),
                  ),
                  Card(
                    child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                      Icon(Icons.access_time),
                      Text("额温"),
                      BarChart(
                        0.5,
                        controller.temperature.value > 0 ? controller.temperatureRealtime.value / controller.temperature.value * 0.5 : 0.5,
                        colorSurface,
                      ),
                      Text("${controller.temperature.value} 基线 | 当前 ${controller.temperatureRealtime.value}"),
                    ]),
                  ),
                  Card(
                    child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                      Icon(Icons.access_time),
                      Text("Delta"),
                      BarChart(
                        0.5,
                        controller.delta.value > 0 ? controller.deltaRealtime.value / controller.delta.value * 0.5 : 0.5,
                        colorSurface,
                      ),
                      Text("${controller.delta.value} 基线 | 当前 ${controller.deltaRealtime.value}"),
                    ]),
                  ),
                  Card(
                    child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                      Icon(Icons.access_time),
                      Text("Theta"),
                      BarChart(
                        0.5,
                        controller.theta.value > 0 ? controller.thetaRealtime.value / controller.theta.value * 0.5 : 0.5,
                        colorSurface,
                      ),
                      Text("${controller.theta.value} 基线 | 当前 ${controller.thetaRealtime.value}"),
                    ]),
                  ),
                  Card(
                    child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                      Icon(Icons.access_time),
                      Text("Alpha"),
                      BarChart(
                        0.5,
                        controller.alpha.value > 0 ? controller.alphaRealtime.value / controller.alpha.value * 0.5 : 0.5,
                        colorSurface,
                      ),
                      Text("${controller.alpha.value} 基线 | 当前 ${controller.alphaRealtime.value}"),
                    ]),
                  ),
                  Card(
                    child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                      Icon(Icons.access_time),
                      Text("Beta"),
                      BarChart(
                        0.5,
                        controller.beta.value > 0 ? controller.betaRealtime.value / controller.beta.value * 0.5 : 0.5,
                        colorSurface,
                      ),
                      Text("${controller.beta.value} 基线 | 当前 ${controller.betaRealtime.value}"),
                    ]),
                  ),
                  Card(
                    child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                      Icon(Icons.access_time),
                      Text("Gamma"),
                      BarChart(
                        0.5,
                        controller.gamma.value > 0 ? controller.gammaRealtime.value / controller.gamma.value * 0.5 : 0.5,
                        colorSurface,
                      ),
                      Text("${controller.gamma.value} 基线 | 当前 ${controller.gammaRealtime.value}"),
                    ]),
                  ),
                ],
              )
            ],
          )),
    );
  }
}

class BaselineView extends GetView<BaselineCtrl> {
  BaselineView({super.key});
  @override
  final BaselineCtrl controller = Get.put(BaselineCtrl());

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(10),
      padding: EdgeInsets.all(10),
      child: Obx(() => Column(
            children: [
              MyTextP1("( 心&脑 - 基线数据 )"),
              const SizedBox(height: 20),
              MyTextP2(controller.isLoaded.value ? "- 已加载，图中均为真实数据 -" : "- 待加载，图中暂为模拟数据 -"),
              const SizedBox(height: 20),
              GridView.count(
                crossAxisCount: 4,
                physics: NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                mainAxisSpacing: 20,
                crossAxisSpacing: 20,
                children: [
                  Card(
                      child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.access_time),
                      Text("心率"),
                      MyTextH2("${controller.heartRate.value}"),
                    ],
                  )),
                  Card(
                      child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.access_time),
                      Text("HRV"),
                      MyTextH2("${controller.hrv.value}"),
                    ],
                  )),
                  Card(
                      child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.access_time),
                      Text("额温"),
                      MyTextH2("${controller.temperature.value}"),
                    ],
                  )),
                  Card(
                      child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.access_time),
                      Text("Delta"),
                      MyTextH2("${controller.delta.value}"),
                    ],
                  )),
                  Card(
                      child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.access_time),
                      Text("Theta"),
                      MyTextH2("${controller.theta.value}"),
                    ],
                  )),
                  Card(
                      child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.access_time),
                      Text("Alpha"),
                      MyTextH2("${controller.alpha.value}"),
                      Text("${(controller.alphaRate.value * 100).toStringAsFixed(1)}%"),
                    ],
                  )),
                  Card(
                      child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.access_time),
                      Text("Beta"),
                      MyTextH2("${controller.beta}"),
                      Text("${(controller.betaRate.value * 100).toStringAsFixed(1)}%"),
                    ],
                  )),
                  Card(
                      child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.access_time),
                      Text("Gamma"),
                      MyTextH2("${controller.gamma}"),
                      Text("${(controller.gammaRate.value * 100).toStringAsFixed(1)}%"),
                    ],
                  )),
                ],
              )
            ],
          )),
    );
  }
}

// Map<String, dynamic> sampleData = {
//   "heartRate": [],
//   "hrv": [],
//   "temperature": [],
//   "delta": [],
//   "theta": [],
//   "alpha": [],
//   "beta": [],
//   "gamma": [],
// };

class BaselineCtrl extends GetxController {
  RxInt heartRate = 72.obs;
  RxInt hrv = 800.obs;
  RxDouble temperature = 35.5.obs;
  RxInt delta = 16000.obs;
  RxInt theta = 8000.obs;
  RxInt alpha = 3000.obs;
  RxInt beta = 2000.obs;
  RxInt gamma = 1000.obs;

  RxBool isLoaded = false.obs;

  RxInt heartRateRealtime = 72.obs;
  RxInt hrvRealtime = 800.obs;
  RxDouble temperatureRealtime = 35.5.obs;
  RxInt deltaRealtime = 16000.obs;
  RxInt thetaRealtime = 8000.obs;
  RxInt alphaRealtime = 3000.obs;
  RxInt betaRealtime = 2000.obs;
  RxInt gammaRealtime = 1000.obs;

  RxDouble alphaRate = 0.1.obs;
  RxDouble alphaRealtimeRate = 0.1.obs;

  RxDouble betaRate = 0.1.obs;
  RxDouble betaRealtimeRate = 0.1.obs;

  RxDouble alphaBetaRate = 0.1.obs;
  RxDouble alphaBetaRealtimeRate = 0.1.obs;

  RxDouble gammaRate = 0.1.obs;
  RxDouble gammaRealtimeRate = 0.1.obs;

  RxDouble gammaBetaRate = 0.1.obs;
  RxDouble gammaBetaRealtimeRate = 0.1.obs;

  ///计算items均值
  static const int max = 16;
  double median(List<double> items) {
    if (items.length != max) {
      return 0;
    }
    //将items按从小到大排序
    List<double> subItems = items..sort();
    //取中间的max-4个值
    subItems = subItems.sublist(2, max - 2);
    //计算均值
    double sum = 0;
    for (int i = 0; i < subItems.length; i++) {
      sum += subItems[i];
    }
    return sum / subItems.length;
  }

  void init() {
    heartRate.value = 72;
    hrv.value = 800;
    temperature.value = 35.5;
    delta.value = 16000;
    theta.value = 8000;
    alpha.value = 3000;
    beta.value = 2000;
    gamma.value = 1000;

    isLoaded.value = false;

    heartRateRealtime.value = 72;
    hrvRealtime.value = 800;
    temperatureRealtime.value = 35.5;
    deltaRealtime.value = 16000;
    thetaRealtime.value = 8000;
    alphaRealtime.value = 3000;
    betaRealtime.value = 2000;
    gammaRealtime.value = 1000;

    alphaRate.value = 0.1;
    alphaRealtimeRate.value = 0.1;

    betaRate.value = 0.1;
    betaRealtimeRate.value = 0.1;

    alphaBetaRate.value = 0.1;
    alphaBetaRealtimeRate.value = 0.1;

    gammaRate.value = 0.1;
    gammaRealtimeRate.value = 0.1;

    gammaBetaRate.value = 0.1;
    gammaBetaRealtimeRate.value = 0.1;
  }
}

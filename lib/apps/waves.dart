import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:healing_junior/view.dart';

class WavesButtons extends GetView<WavesCtrl> {
  @override
  final controller = Get.put(WavesCtrl());
  WavesButtons({
    super.key,
  });
  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          TextButton(
              onPressed: () {
                controller.isShowLine0.value = !controller.isShowLine0.value;
              },
              child: Text("· Delta ·", style: TextStyle(color: colorSecondary, backgroundColor: colors5[0]))),
          TextButton(
              onPressed: () {
                controller.isShowLine1.value = !controller.isShowLine1.value;
              },
              child: Text("· Theta ·", style: TextStyle(color: colorSecondary, backgroundColor: colors5[1]))),
          TextButton(
              onPressed: () {
                controller.isShowLine2.value = !controller.isShowLine2.value;
              },
              child: Text("· Alpha ·", style: TextStyle(color: colorSecondary, backgroundColor: colors5[2]))),
          TextButton(
              onPressed: () {
                controller.isShowLine3.value = !controller.isShowLine3.value;
              },
              child: Text("· Beta ·", style: TextStyle(color: colorSecondary, backgroundColor: colors5[3]))),
          TextButton(
              onPressed: () {
                controller.isShowLine4.value = !controller.isShowLine4.value;
              },
              child: Text("· Gamma ·", style: TextStyle(color: colorSecondary, backgroundColor: colors5[4]))),
        ],
      ),
    );
  }
}

class WavesView extends GetView<WavesCtrl> {
  @override
  final controller = Get.put(WavesCtrl());
  WavesView({
    super.key,
  });
  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    return Container(
      height: 320,
      alignment: Alignment.bottomRight,
      margin: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey,
            spreadRadius: 1,
            blurRadius: 3,
            offset: const Offset(0, 3),
          ),
        ],
        color: colorSecondaryContainer,
      ),
      clipBehavior: Clip.hardEdge,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        reverse: true,
        child: Obx(() => SizedBox(
            width: controller.isFlay.value ? controller.width.value : screenWidth,
            height: controller.height.value,
            child: LineChart(
                duration: Duration(seconds: 2),
                LineChartData(
                    gridData: const FlGridData(show: false, drawHorizontalLine: false, drawVerticalLine: false),
                    titlesData: FlTitlesData(
                        topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        show: true),
                    borderData: FlBorderData(show: false),
                    minY: controller.minY.value,
                    maxY: controller.maxY.value,
                    backgroundColor: Colors.black,
                    lineBarsData: [
                      LineChartBarData(
                          barWidth: 0,
                          spots: controller.dataFlSpotBaseline,
                          show: true,
                          color: Colors.black,
                          isCurved: false,
                          dotData: const FlDotData(show: true)),
                      LineChartBarData(
                          barWidth: controller.barWidthLine0.value,
                          spots: controller.dataFlSpot0,
                          show: controller.isShowLine0.value,
                          color: colors5[0],
                          isCurved: controller.isCurved.value,
                          dotData: const FlDotData(show: false)),
                      LineChartBarData(
                          barWidth: controller.barWidthLine1.value,
                          spots: controller.dataFlSpot1,
                          show: controller.isShowLine1.value,
                          color: colors5[1],
                          isCurved: controller.isCurved.value,
                          dotData: const FlDotData(show: false)),
                      LineChartBarData(
                          barWidth: controller.barWidthLine2.value,
                          spots: controller.dataFlSpot2,
                          show: controller.isShowLine2.value,
                          color: colors5[2],
                          isCurved: controller.isCurved.value,
                          dotData: const FlDotData(show: false)),
                      LineChartBarData(
                          barWidth: controller.barWidthLine3.value,
                          spots: controller.dataFlSpot3,
                          show: controller.isShowLine3.value,
                          color: colors5[3],
                          isCurved: controller.isCurved.value,
                          dotData: const FlDotData(show: false)),
                      LineChartBarData(
                          barWidth: controller.barWidthLine4.value,
                          spots: controller.dataFlSpot4,
                          show: controller.isShowLine4.value,
                          color: colors5[4],
                          isCurved: controller.isCurved.value,
                          dotData: const FlDotData(show: false)),
                    ])))),
      ),
    );
  }
}

class WavesCtrl extends GetxController {
  final RxDouble height = 300.0.obs;
  final RxDouble width = 20.0.obs;
  final RxBool isFlay = true.obs;
  final RxBool isCurved = true.obs;
  final RxDouble minY = 0.0.obs;
  final RxDouble maxY = 45.0.obs;
  RxList<FlSpot> dataFlSpotBaseline = <FlSpot>[FlSpot.nullSpot].obs;
  RxList<FlSpot> dataFlSpot0 = <FlSpot>[FlSpot.nullSpot].obs;
  RxList<FlSpot> dataFlSpot1 = <FlSpot>[FlSpot.nullSpot].obs;
  RxList<FlSpot> dataFlSpot2 = <FlSpot>[FlSpot.nullSpot].obs;
  RxList<FlSpot> dataFlSpot3 = <FlSpot>[FlSpot.nullSpot].obs;
  RxList<FlSpot> dataFlSpot4 = <FlSpot>[FlSpot.nullSpot].obs;
  final RxBool isShowLine0 = true.obs;
  final RxBool isShowLine1 = true.obs;
  final RxBool isShowLine2 = true.obs;
  final RxBool isShowLine3 = true.obs;
  final RxBool isShowLine4 = true.obs;
  final RxDouble barWidthLine0 = 1.0.obs;
  final RxDouble barWidthLine1 = 1.0.obs;
  final RxDouble barWidthLine2 = 1.0.obs;
  final RxDouble barWidthLine3 = 1.0.obs;
  final RxDouble barWidthLine4 = 1.0.obs;
  double setHeight(double h) {
    height.value = h;
    return h;
  }

  bool setIsFlay(bool f) {
    isFlay.value = f;
    return f;
  }

  bool setIsCurved(bool c) {
    isCurved.value = c;
    return c;
  }

  bool changeIsFlay() {
    isFlay.value = !isFlay.value;
    return isFlay.value;
  }

  double setBarWidth(double w, {int i = -1}) {
    if (i == 0) {
      barWidthLine0.value = w;
      return w;
    }
    if (i == 1) {
      barWidthLine1.value = w;
      return w;
    }
    if (i == 2) {
      barWidthLine2.value = w;
      return w;
    }
    if (i == 3) {
      barWidthLine3.value = w;
      return w;
    }
    if (i == 4) {
      barWidthLine4.value = w;
      return w;
    }

    barWidthLine0.value = w;
    barWidthLine1.value = w;
    barWidthLine2.value = w;
    barWidthLine3.value = w;
    barWidthLine4.value = w;
    return w;
  }

  double setMinY(double y) {
    minY.value = y;
    return y;
  }

  double setMaxY(double y) {
    maxY.value = y;
    return y;
  }

  bool addSpots(List<double> spots) {
    if (spots.length != 5) {
      return false;
    }
    double len = dataFlSpotBaseline.length.toDouble();
    if (len > 0) {
      width.value = len * 20;
    }
    dataFlSpotBaseline.add(FlSpot(len, 0.0));
    double s = 0.0;
    const double u = 40.0;
    const int b= 10000;
    s = spots[0] / b + 3.0;
    s = s > u ? u : s;
    dataFlSpot0.add(FlSpot(len, s));
    s = spots[1] / b + 11.0;
    s = s > u ? u : s;
    dataFlSpot1.add(FlSpot(len, s));
    s = spots[2] / b + 19.0;
    s = s > u ? u : s;
    dataFlSpot2.add(FlSpot(len, s));
    s = spots[3] / b + 27.0;
    s = s > u ? u : s;
    dataFlSpot3.add(FlSpot(len, s));
    s = spots[4] / b + 35.0;
    s = s > u ? u : s;
    dataFlSpot4.add(FlSpot(len, s));
    return true;
  }

  void clearSpots() {
    dataFlSpotBaseline.clear();
    dataFlSpot0.clear();
    dataFlSpot1.clear();
    dataFlSpot2.clear();
    dataFlSpot3.clear();
    dataFlSpot4.clear();
    dataFlSpotBaseline.add(FlSpot.nullSpot);
    dataFlSpot0.add(FlSpot.nullSpot);
    dataFlSpot1.add(FlSpot.nullSpot);
    dataFlSpot2.add(FlSpot.nullSpot);
    dataFlSpot3.add(FlSpot.nullSpot);
    dataFlSpot4.add(FlSpot.nullSpot);
  }
}

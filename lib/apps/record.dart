import 'dart:convert';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:healing_junior/apps/bci.dart';
import 'package:healing_junior/apps/customer.dart';
import 'package:healing_junior/apps/employee.dart';
import 'package:healing_junior/data.dart';
import 'package:healing_junior/view.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

class RecordView extends GetView<RecordCtrl> {
  RecordView({super.key});
  @override
  final controller = Get.put(RecordCtrl());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("脑电报告"),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_rounded),
          onPressed: () {
            Get.back();
          },
        ),
        actions: [
          CircularIconButton(
            icon: Icons.grading_rounded,
            onPressed: () {
              controller.init();
              showModalBottomSheet(
                  context: context,
                  showDragHandle: true,
                  useRootNavigator: true,
                  isScrollControlled: true,
                  useSafeArea: true,
                  constraints: BoxConstraints(
                    maxHeight: MediaQuery.of(context).size.height * 0.8,
                  ),
                  builder: (BuildContext context) {
                    return RecordList();
                  });
            },
          ),
          IconButton(
            icon: Icon(Icons.arrow_back_ios_rounded),
            onPressed: () {
              Get.back();
            },
          ),
        ],
      ),
      body: Record(),
    );
  }
}

class Record extends GetView<RecordCtrl> {
  Record({super.key});
  @override
  final controller = Get.put(RecordCtrl());
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(10),
      padding: EdgeInsets.all(10),
      child: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Obx(() => Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                MyTextP2("◇摘要◇"),
                Container(
                  width: MediaQuery.of(context).size.width,
                  padding: EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: colorPrimary,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: colorSecondary,
                        spreadRadius: 0,
                        blurRadius: 1,
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      MyTextP2("顾客昵称：${controller.customerCtrl.nickname.value}"),
                      MyTextP2("顾客性别：${controller.customerCtrl.sex.value}"),
                      MyTextP2("顾客年龄：${controller.customerCtrl.age.value}岁"),
                      const SizedBox(height: 10),
                      MyTextP3("• 样本数量：${controller.sampleSize.value}", colorPrimaryContainer),
                      MyTextP3("• 检测时间：${controller.recordAt.value}", colorPrimaryContainer),
                      MyTextP3("• 平均心率：${controller.heartRateAvg.value} bpm", colorPrimaryContainer),
                      MyTextP3("• 心率间期均值 - hrv：${controller.hrvAvg.value} ms", colorPrimaryContainer),
                      MyTextP3("• 平均额温：${controller.temperatureAvg.value.toStringAsFixed(1)} °C", colorPrimaryContainer),
                      MyTextP3("• δ 波 均值：${controller.deltaAvg.value}", colorPrimaryContainer),
                      MyTextP3("• θ 波 均值：${controller.thetaAvg.value}", colorPrimaryContainer),
                      MyTextP3("• α 波 均值：${controller.alphaAvg.value}", colorPrimaryContainer),
                      MyTextP3("• β 波 均值：${controller.betaAvg.value}", colorPrimaryContainer),
                      MyTextP3("• γ 波 均值：${controller.gammaAvg.value}", colorPrimaryContainer),
                    ],
                  ),
                ),
                const SizedBox(height: 40),
                MyTextP2("◇脑波能耗分布图◇"),
                const SizedBox(height: 20),
                Container(
                  decoration: BoxDecoration(
                    color: colorPrimary,
                    borderRadius: BorderRadius.circular(200),
                    boxShadow: [
                      BoxShadow(
                        color: colorSecondary,
                        spreadRadius: 0,
                        blurRadius: 1,
                      ),
                    ],
                  ),
                  alignment: Alignment.center,
                  width: 400,
                  height: 400,
                  child: PieChart(
                    PieChartData(
                      pieTouchData: PieTouchData(
                        touchCallback: (FlTouchEvent event, pieTouchResponse) {
                          if (!event.isInterestedForInteractions || pieTouchResponse == null || pieTouchResponse.touchedSection == null) {
                            controller.touchedIndex.value = -1;
                            return;
                          }
                          controller.touchedIndex.value = pieTouchResponse.touchedSection!.touchedSectionIndex;
                        },
                      ),
                      startDegreeOffset: 270,
                      borderData: FlBorderData(
                        show: false,
                      ),
                      sectionsSpace: 1,
                      centerSpaceRadius: 20,
                      sections: controller.brainwavesPieSections(),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
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
                      MyTextP3("    γ", colors5[4]),
                      MyTextP3("    ${(controller.gammaAvg.value / controller.totalAvg.value * 100).toStringAsFixed(0)}%", colorPrimaryContainer),
                      MyTextP3("    ${BciCtrl.labels.values.elementAt(4)}", colorPrimaryContainer),
                    ]),
                    TableRow(children: [
                      MyTextP3("    β", colors5[3]),
                      MyTextP3("    ${(controller.betaAvg.value / controller.totalAvg.value * 100).toStringAsFixed(0)}%", colorPrimaryContainer),
                      MyTextP3("    ${BciCtrl.labels.values.elementAt(3)}", colorPrimaryContainer),
                    ]),
                    TableRow(children: [
                      MyTextP3("    α", colors5[2]),
                      MyTextP3("    ${(controller.alphaAvg.value / controller.totalAvg.value * 100).toStringAsFixed(0)}%", colorPrimaryContainer),
                      MyTextP3("    ${BciCtrl.labels.values.elementAt(2)}", colorPrimaryContainer),
                    ]),
                    TableRow(children: [
                      MyTextP3("    θ", colors5[1]),
                      MyTextP3("    ${(controller.thetaAvg.value / controller.totalAvg.value * 100).toStringAsFixed(0)}%", colorPrimaryContainer),
                      MyTextP3("    ${BciCtrl.labels.values.elementAt(1)}", colorPrimaryContainer),
                    ]),
                    TableRow(children: [
                      MyTextP3("    δ", colors5[0]),
                      MyTextP3("    ${(controller.deltaAvg.value / controller.totalAvg.value * 100).toStringAsFixed(0)}%", colorPrimaryContainer),
                      MyTextP3("    ${BciCtrl.labels.values.elementAt(0)}", colorPrimaryContainer),
                    ]),
                  ],
                ),
                const SizedBox(height: 40),
                Container(
                  width: MediaQuery.of(context).size.width,
                  padding: EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: colorPrimary,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: colorSecondary,
                        spreadRadius: 0,
                        blurRadius: 1,
                      ),
                    ],
                  ),
                  height: 250,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      SizedBox(
                        width: 200,
                        height: 200,
                        child: PieChart(
                          PieChartData(
                            pieTouchData: PieTouchData(
                              touchCallback: (FlTouchEvent event, pieTouchResponse) {
                                if (!event.isInterestedForInteractions || pieTouchResponse == null || pieTouchResponse.touchedSection == null) {
                                  controller.touchedIndex.value = -1;
                                  return;
                                }
                                controller.touchedIndex.value = pieTouchResponse.touchedSection!.touchedSectionIndex;
                              },
                            ),
                            startDegreeOffset: 270,
                            borderData: FlBorderData(
                              show: false,
                            ),
                            sectionsSpace: 1,
                            centerSpaceRadius: 20,
                            sections: controller.brainwavesPieSectionsLeft(),
                          ),
                        ),
                      ),
                      MyTextP2("前 | 后"),
                      SizedBox(
                        width: 200,
                        height: 200,
                        child: PieChart(
                          PieChartData(
                            pieTouchData: PieTouchData(
                              touchCallback: (FlTouchEvent event, pieTouchResponse) {
                                if (!event.isInterestedForInteractions || pieTouchResponse == null || pieTouchResponse.touchedSection == null) {
                                  controller.touchedIndex.value = -1;
                                  return;
                                }
                                controller.touchedIndex.value = pieTouchResponse.touchedSection!.touchedSectionIndex;
                              },
                            ),
                            startDegreeOffset: 270,
                            borderData: FlBorderData(
                              show: false,
                            ),
                            sectionsSpace: 1,
                            centerSpaceRadius: 20,
                            sections: controller.brainwavesPieSectionsRight(),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                Table(
                  defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                  columnWidths: {
                    0: FixedColumnWidth(50),
                    1: FixedColumnWidth(90),
                    2: FixedColumnWidth(90),
                    3: FixedColumnWidth(90),
                    4: FixedColumnWidth(80),
                  },
                  border: TableBorder.all(color: colorSecondary, width: 1),
                  children: [
                    TableRow(decoration: BoxDecoration(color: colorSurface), children: [
                      MyTextP3("    脑波", colorPrimaryContainer),
                      MyTextP3("    前", colorPrimaryContainer),
                      MyTextP3("    后", colorPrimaryContainer),
                      MyTextP3("    变", colorPrimaryContainer),
                      MyTextP3("    化", colorPrimaryContainer),
                    ]),
                    TableRow(children: [
                      MyTextP3("    γ", colors5[4]),
                      MyTextP3("    ${(controller.gammaAvgLeft.value / controller.totalAvgLeft.value * 100).toStringAsFixed(2)}%", colorPrimaryContainer),
                      MyTextP3("    ${(controller.gammaAvgRight.value / controller.totalAvgRight.value * 100).toStringAsFixed(2)}%", colorPrimaryContainer),
                      MyTextP3(
                          "    ${((controller.gammaAvgRight.value / controller.totalAvgRight.value - controller.gammaAvgLeft.value / controller.totalAvgLeft.value) * 100).toStringAsFixed(2)}%",
                          colorPrimaryContainer),
                      MyTextP3(
                          "    ${(controller.gammaAvgRight.value / controller.totalAvgRight.value - controller.gammaAvgLeft.value / controller.totalAvgLeft.value) > 0 ? '升' : '降'}",
                          colorPrimaryContainer),
                    ]),
                    TableRow(children: [
                      MyTextP3("    β", colors5[3]),
                      MyTextP3("    ${(controller.betaAvgLeft.value / controller.totalAvgLeft.value * 100).toStringAsFixed(2)}%", colorPrimaryContainer),
                      MyTextP3("    ${(controller.betaAvgRight.value / controller.totalAvgRight.value * 100).toStringAsFixed(2)}%", colorPrimaryContainer),
                      MyTextP3(
                          "    ${((controller.betaAvgRight.value / controller.totalAvgRight.value - controller.betaAvgLeft.value / controller.totalAvgLeft.value) * 100).toStringAsFixed(2)}%",
                          colorPrimaryContainer),
                      MyTextP3(
                          "    ${(controller.betaAvgRight.value / controller.totalAvgRight.value - controller.betaAvgLeft.value / controller.totalAvgLeft.value) > 0 ? '升' : '降'}",
                          colorPrimaryContainer),
                    ]),
                    TableRow(children: [
                      MyTextP3("    α", colors5[2]),
                      MyTextP3("    ${(controller.alphaAvgLeft.value / controller.totalAvgLeft.value * 100).toStringAsFixed(2)}%", colorPrimaryContainer),
                      MyTextP3("    ${(controller.alphaAvgRight.value / controller.totalAvgRight.value * 100).toStringAsFixed(2)}%", colorPrimaryContainer),
                      MyTextP3(
                          "    ${((controller.alphaAvgRight.value / controller.totalAvgRight.value - controller.alphaAvgLeft.value / controller.totalAvgLeft.value) * 100).toStringAsFixed(2)}%",
                          colorPrimaryContainer),
                      MyTextP3(
                          "    ${(controller.alphaAvgRight.value / controller.totalAvgRight.value - controller.alphaAvgLeft.value / controller.totalAvgLeft.value) > 0 ? '升' : '降'}",
                          colorPrimaryContainer),
                    ]),
                    TableRow(children: [
                      MyTextP3("    θ", colors5[1]),
                      MyTextP3("    ${(controller.thetaAvgLeft.value / controller.totalAvgLeft.value * 100).toStringAsFixed(2)}%", colorPrimaryContainer),
                      MyTextP3("    ${(controller.thetaAvgRight.value / controller.totalAvgRight.value * 100).toStringAsFixed(2)}%", colorPrimaryContainer),
                      MyTextP3(
                          "    ${((controller.thetaAvgRight.value / controller.totalAvgRight.value - controller.thetaAvgLeft.value / controller.totalAvgLeft.value) * 100).toStringAsFixed(2)}%",
                          colorPrimaryContainer),
                      MyTextP3(
                          "    ${(controller.thetaAvgRight.value / controller.totalAvgRight.value - controller.thetaAvgLeft.value / controller.totalAvgLeft.value) > 0 ? '升' : '降'}",
                          colorPrimaryContainer),
                    ]),
                    TableRow(children: [
                      MyTextP3("    δ", colors5[0]),
                      MyTextP3("    ${(controller.deltaAvgLeft.value / controller.totalAvgLeft.value * 100).toStringAsFixed(2)}%", colorPrimaryContainer),
                      MyTextP3("    ${(controller.deltaAvgRight.value / controller.totalAvgRight.value * 100).toStringAsFixed(2)}%", colorPrimaryContainer),
                      MyTextP3(
                          "    ${((controller.deltaAvgRight.value / controller.totalAvgRight.value - controller.deltaAvgLeft.value / controller.totalAvgLeft.value) * 100).toStringAsFixed(2)}%",
                          colorPrimaryContainer),
                      MyTextP3(
                          "    ${(controller.deltaAvgRight.value / controller.totalAvgRight.value - controller.deltaAvgLeft.value / controller.totalAvgLeft.value) > 0 ? '升' : '降'}",
                          colorPrimaryContainer),
                    ]),
                  ],
                ),
                const SizedBox(height: 40),
                Divider(height: 1),
                const SizedBox(height: 40),
                MyTextP2("◇δ 波◇"),
                Container(
                  padding: EdgeInsets.all(20),
                  width: MediaQuery.of(context).size.width,
                  height: 160,
                  child: LineChart(
                    LineChartData(
                      minY: 0,
                      maxY: 1,
                      gridData: FlGridData(show: false),
                      titlesData: FlTitlesData(
                        topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false, interval: 0.2)),
                        bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: false, interval: 20)),
                        leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false, interval: 0.2)),
                        rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false, interval: 0.2)),
                      ),
                      borderData: FlBorderData(show: false),
                      lineBarsData: [
                        LineChartBarData(
                          spots: controller.deltaSpots.map<FlSpot>((e) => FlSpot(e.x, e.y)).toList(),
                          isCurved: false,
                          isStrokeCapRound: true,
                          isStrokeJoinRound: true,
                          color: colors5[0],
                          shadow: Shadow(
                            color: Colors.white,
                            blurRadius: 1,
                            offset: Offset(0, 3), // 阴影方向
                          ),
                          barWidth: 3,
                          dotData: FlDotData(show: false),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                MyTextP3("能耗变化趋势", colorPrimaryContainer),
                const SizedBox(height: 10),
                Table(
                  defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                  columnWidths: {
                    0: FixedColumnWidth(70),
                    1: FixedColumnWidth(70),
                    2: FixedColumnWidth(70),
                    3: FixedColumnWidth(70),
                    4: FixedColumnWidth(70),
                    5: FixedColumnWidth(70),
                    6: FixedColumnWidth(40),
                  },
                  border: TableBorder.all(color: colorSecondary, width: 1),
                  children: [
                    TableRow(decoration: BoxDecoration(color: colorSurface), children: [
                      MyTextP3("    最高", colorPrimaryContainer),
                      MyTextP3("    最低", colorPrimaryContainer),
                      MyTextP3("    均值", colorPrimaryContainer),
                      MyTextP3("    前", colorPrimaryContainer),
                      MyTextP3("    后", colorPrimaryContainer),
                      MyTextP3("    变", colorPrimaryContainer),
                      MyTextP3("    化", colorPrimaryContainer),
                    ]),
                    TableRow(children: [
                      MyTextP3("    ${controller.deltaSpotMax.value.toStringAsFixed(0)}", colorPrimaryContainer),
                      MyTextP3("    ${controller.deltaSpotMin.value.toStringAsFixed(0)}", colorPrimaryContainer),
                      MyTextP3("    ${controller.deltaAvg.value.toStringAsFixed(0)}", colorPrimaryContainer),
                      MyTextP3("    ${controller.deltaAvgLeft.value.toStringAsFixed(0)}", colorPrimaryContainer),
                      MyTextP3("    ${controller.deltaAvgRight.value.toStringAsFixed(0)}", colorPrimaryContainer),
                      MyTextP3(
                          "    ${((controller.deltaAvgRight.value - controller.deltaAvgLeft.value) / controller.deltaAvgLeft.value * 100).toStringAsFixed(1)}%",
                          colorPrimaryContainer),
                      MyTextP3("    ${(controller.deltaAvgRight.value > controller.deltaAvgLeft.value ? '升' : '降')}", colorPrimaryContainer),
                    ]),
                  ],
                ),
                const SizedBox(height: 20),
                MyTextP3("趋势显著度", colorPrimaryContainer),
                const SizedBox(height: 10),
                Table(
                  defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                  columnWidths: {
                    0: FixedColumnWidth(60),
                    1: FixedColumnWidth(120),
                    2: FixedColumnWidth(40),
                  },
                  border: TableBorder.all(color: colorSecondary, width: 1, borderRadius: BorderRadius.circular(10)),
                  children: [
                    TableRow(children: [
                      MyTextP3("    总", colorPrimaryContainer),
                      MyTextP3("    ${controller.deltaSign.value.toStringAsFixed(2)}", colorPrimaryContainer),
                      MyTextP3("    ${(controller.deltaSign.value > 0 ? '升' : '降')}", colorPrimaryContainer),
                    ]),
                    TableRow(children: [
                      MyTextP3("    前", colorPrimaryContainer),
                      MyTextP3("    ${controller.deltaSignLeft.value.toStringAsFixed(2)}", colorPrimaryContainer),
                      MyTextP3("    ${(controller.deltaSignLeft.value > 0 ? '升' : '降')}", colorPrimaryContainer),
                    ]),
                    TableRow(children: [
                      MyTextP3("    后", colorPrimaryContainer),
                      MyTextP3("    ${controller.deltaSignRight.value.toStringAsFixed(2)}", colorPrimaryContainer),
                      MyTextP3("    ${(controller.deltaSignRight.value > 0 ? '升' : '降')}", colorPrimaryContainer),
                    ]),
                  ],
                ),
                const SizedBox(height: 20),
                MyTextP3("变化活跃度", colorPrimaryContainer),
                const SizedBox(height: 10),
                Table(
                  defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                  columnWidths: {
                    0: FixedColumnWidth(60),
                    1: FixedColumnWidth(60),
                    2: FixedColumnWidth(60),
                    3: FixedColumnWidth(40),
                  },
                  border: TableBorder.all(color: colorSecondary, width: 1),
                  children: [
                    TableRow(decoration: BoxDecoration(color: colorSurface), children: [
                      MyTextP3("    前", colorPrimaryContainer),
                      MyTextP3("    后", colorPrimaryContainer),
                      MyTextP3("    变", colorPrimaryContainer),
                      MyTextP3("    化", colorPrimaryContainer),
                    ]),
                    TableRow(children: [
                      MyTextP3("    ${controller.deltaActivityLeft.value.toStringAsFixed(2)}", colorPrimaryContainer),
                      MyTextP3("    ${controller.deltaActivityRight.value.toStringAsFixed(2)}", colorPrimaryContainer),
                      MyTextP3(
                          "    ${((controller.deltaActivityRight.value - controller.deltaActivityLeft.value) / controller.deltaActivityLeft.value * 100).toStringAsFixed(1)}%",
                          colorPrimaryContainer),
                      MyTextP3("    ${(controller.deltaActivityRight.value > controller.deltaActivityLeft.value ? '升' : '降')}", colorPrimaryContainer),
                    ]),
                  ],
                ),
                const SizedBox(height: 40),
                Divider(height: 1),
                const SizedBox(height: 40),
                MyTextP2("◇θ 波◇"),
                Container(
                  padding: EdgeInsets.all(20),
                  width: MediaQuery.of(context).size.width,
                  height: 160,
                  child: LineChart(
                    LineChartData(
                      minY: 0,
                      maxY: 1,
                      gridData: FlGridData(show: false),
                      titlesData: FlTitlesData(
                        topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false, interval: 0.2)),
                        bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: false, interval: 20)),
                        leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false, interval: 0.2)),
                        rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false, interval: 0.2)),
                      ),
                      borderData: FlBorderData(show: false),
                      lineBarsData: [
                        LineChartBarData(
                          spots: controller.thetaSpots.map<FlSpot>((e) => FlSpot(e.x, e.y)).toList(),
                          isCurved: false,
                          isStrokeCapRound: true,
                          isStrokeJoinRound: true,
                          color: colors5[1],
                          shadow: Shadow(
                            color: Colors.white,
                            blurRadius: 1,
                            offset: Offset(0, 3), // 阴影方向
                          ),
                          barWidth: 3,
                          dotData: FlDotData(show: false),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                MyTextP3("能耗变化趋势", colorPrimaryContainer),
                const SizedBox(height: 10),
                Table(
                  defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                  columnWidths: {
                    0: FixedColumnWidth(70),
                    1: FixedColumnWidth(70),
                    2: FixedColumnWidth(70),
                    3: FixedColumnWidth(70),
                    4: FixedColumnWidth(70),
                    5: FixedColumnWidth(70),
                    6: FixedColumnWidth(40),
                  },
                  border: TableBorder.all(color: colorSecondary, width: 1),
                  children: [
                    TableRow(decoration: BoxDecoration(color: colorSurface), children: [
                      MyTextP3("    最高", colorPrimaryContainer),
                      MyTextP3("    最低", colorPrimaryContainer),
                      MyTextP3("    均值", colorPrimaryContainer),
                      MyTextP3("    前", colorPrimaryContainer),
                      MyTextP3("    后", colorPrimaryContainer),
                      MyTextP3("    变", colorPrimaryContainer),
                      MyTextP3("    化", colorPrimaryContainer),
                    ]),
                    TableRow(children: [
                      MyTextP3("    ${controller.thetaSpotMax.value.toStringAsFixed(0)}", colorPrimaryContainer),
                      MyTextP3("    ${controller.thetaSpotMin.value.toStringAsFixed(0)}", colorPrimaryContainer),
                      MyTextP3("    ${controller.thetaAvg.value.toStringAsFixed(0)}", colorPrimaryContainer),
                      MyTextP3("    ${controller.thetaAvgLeft.value.toStringAsFixed(0)}", colorPrimaryContainer),
                      MyTextP3("    ${controller.thetaAvgRight.value.toStringAsFixed(0)}", colorPrimaryContainer),
                      MyTextP3(
                          "    ${((controller.thetaAvgRight.value - controller.thetaAvgLeft.value) / controller.thetaAvgLeft.value * 100).toStringAsFixed(1)}%",
                          colorPrimaryContainer),
                      MyTextP3("    ${(controller.thetaAvgRight.value > controller.thetaAvgLeft.value ? '升' : '降')}", colorPrimaryContainer),
                    ]),
                  ],
                ),
                const SizedBox(height: 20),
                MyTextP3("趋势显著度", colorPrimaryContainer),
                const SizedBox(height: 10),
                Table(
                  defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                  columnWidths: {
                    0: FixedColumnWidth(60),
                    1: FixedColumnWidth(120),
                    2: FixedColumnWidth(40),
                  },
                  border: TableBorder.all(color: colorSecondary, width: 1, borderRadius: BorderRadius.circular(10)),
                  children: [
                    TableRow(children: [
                      MyTextP3("    总", colorPrimaryContainer),
                      MyTextP3("    ${controller.thetaSign.value.toStringAsFixed(2)}", colorPrimaryContainer),
                      MyTextP3("    ${(controller.thetaSign.value > 0 ? '升' : '降')}", colorPrimaryContainer),
                    ]),
                    TableRow(children: [
                      MyTextP3("    前", colorPrimaryContainer),
                      MyTextP3("    ${controller.thetaSignLeft.value.toStringAsFixed(2)}", colorPrimaryContainer),
                      MyTextP3("    ${(controller.thetaSignLeft.value > 0 ? '升' : '降')}", colorPrimaryContainer),
                    ]),
                    TableRow(children: [
                      MyTextP3("    后", colorPrimaryContainer),
                      MyTextP3("    ${controller.thetaSignRight.value.toStringAsFixed(2)}", colorPrimaryContainer),
                      MyTextP3("    ${(controller.thetaSignRight.value > 0 ? '升' : '降')}", colorPrimaryContainer),
                    ]),
                  ],
                ),
                const SizedBox(height: 20),
                MyTextP3("变化活跃度", colorPrimaryContainer),
                const SizedBox(height: 10),
                Table(
                  defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                  columnWidths: {
                    0: FixedColumnWidth(60),
                    1: FixedColumnWidth(60),
                    2: FixedColumnWidth(60),
                    3: FixedColumnWidth(40),
                  },
                  border: TableBorder.all(color: colorSecondary, width: 1),
                  children: [
                    TableRow(decoration: BoxDecoration(color: colorSurface), children: [
                      MyTextP3("    前", colorPrimaryContainer),
                      MyTextP3("    后", colorPrimaryContainer),
                      MyTextP3("    变", colorPrimaryContainer),
                      MyTextP3("    化", colorPrimaryContainer),
                    ]),
                    TableRow(children: [
                      MyTextP3("    ${controller.thetaActivityLeft.value.toStringAsFixed(2)}", colorPrimaryContainer),
                      MyTextP3("    ${controller.thetaActivityRight.value.toStringAsFixed(2)}", colorPrimaryContainer),
                      MyTextP3(
                          "    ${((controller.thetaActivityRight.value - controller.thetaActivityLeft.value) / controller.thetaActivityLeft.value * 100).toStringAsFixed(1)}%",
                          colorPrimaryContainer),
                      MyTextP3("    ${(controller.thetaActivityRight.value > controller.thetaActivityLeft.value ? '升' : '降')}", colorPrimaryContainer),
                    ]),
                  ],
                ),
                const SizedBox(height: 40),
                Divider(height: 1),
                const SizedBox(height: 40),
                MyTextP2("◇α 波◇"),
                Container(
                  padding: EdgeInsets.all(20),
                  width: MediaQuery.of(context).size.width,
                  height: 160,
                  child: LineChart(
                    LineChartData(
                      minY: 0,
                      maxY: 1,
                      gridData: FlGridData(show: false),
                      titlesData: FlTitlesData(
                        topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false, interval: 0.2)),
                        bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: false, interval: 20)),
                        leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false, interval: 0.2)),
                        rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false, interval: 0.2)),
                      ),
                      borderData: FlBorderData(show: false),
                      lineBarsData: [
                        LineChartBarData(
                          spots: controller.alphaSpots.map<FlSpot>((e) => FlSpot(e.x, e.y)).toList(),
                          isCurved: false,
                          isStrokeCapRound: true,
                          isStrokeJoinRound: true,
                          color: colors5[2],
                          shadow: Shadow(
                            color: Colors.white,
                            blurRadius: 1,
                            offset: Offset(0, 3), // 阴影方向
                          ),
                          barWidth: 3,
                          dotData: FlDotData(show: false),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                MyTextP3("能耗变化趋势", colorPrimaryContainer),
                const SizedBox(height: 10),
                Table(
                  defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                  columnWidths: {
                    0: FixedColumnWidth(70),
                    1: FixedColumnWidth(70),
                    2: FixedColumnWidth(70),
                    3: FixedColumnWidth(70),
                    4: FixedColumnWidth(70),
                    5: FixedColumnWidth(70),
                    6: FixedColumnWidth(60),
                  },
                  border: TableBorder.all(color: colorSecondary, width: 1),
                  children: [
                    TableRow(decoration: BoxDecoration(color: colorSurface), children: [
                      MyTextP3("    最高", colorPrimaryContainer),
                      MyTextP3("    最低", colorPrimaryContainer),
                      MyTextP3("    均值", colorPrimaryContainer),
                      MyTextP3("    前", colorPrimaryContainer),
                      MyTextP3("    后", colorPrimaryContainer),
                      MyTextP3("    变", colorPrimaryContainer),
                      MyTextP3("    化", colorPrimaryContainer),
                    ]),
                    TableRow(children: [
                      MyTextP3("    ${controller.alphaSpotMax.value.toStringAsFixed(0)}", colorPrimaryContainer),
                      MyTextP3("    ${controller.alphaSpotMin.value.toStringAsFixed(0)}", colorPrimaryContainer),
                      MyTextP3("    ${controller.alphaAvg.value.toStringAsFixed(0)}", colorPrimaryContainer),
                      MyTextP3("    ${controller.alphaAvgLeft.value.toStringAsFixed(0)}", colorPrimaryContainer),
                      MyTextP3("    ${controller.alphaAvgRight.value.toStringAsFixed(0)}", colorPrimaryContainer),
                      MyTextP3(
                          "    ${((controller.alphaAvgRight.value - controller.alphaAvgLeft.value) / controller.alphaAvgLeft.value * 100).toStringAsFixed(1)}%",
                          colorPrimaryContainer),
                      MyTextP3("    ${(controller.alphaAvgRight.value > controller.alphaAvgLeft.value ? '升✔' : '降')}", colorPrimaryContainer),
                    ]),
                  ],
                ),
                const SizedBox(height: 20),
                MyTextP3("趋势显著度", colorPrimaryContainer),
                const SizedBox(height: 10),
                Table(
                  defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                  columnWidths: {
                    0: FixedColumnWidth(60),
                    1: FixedColumnWidth(120),
                    2: FixedColumnWidth(60),
                  },
                  border: TableBorder.all(color: colorSecondary, width: 1, borderRadius: BorderRadius.circular(10)),
                  children: [
                    TableRow(children: [
                      MyTextP3("    总", colorPrimaryContainer),
                      MyTextP3("    ${controller.alphaSign.value.toStringAsFixed(2)}", colorPrimaryContainer),
                      MyTextP3("    ${(controller.alphaSign.value > 0 ? '升✔' : '降')}", colorPrimaryContainer),
                    ]),
                    TableRow(children: [
                      MyTextP3("    前", colorPrimaryContainer),
                      MyTextP3("    ${controller.alphaSignLeft.value.toStringAsFixed(2)}", colorPrimaryContainer),
                      MyTextP3("    ${(controller.alphaSignLeft.value > 0 ? '升✔' : '降')}", colorPrimaryContainer),
                    ]),
                    TableRow(children: [
                      MyTextP3("    后", colorPrimaryContainer),
                      MyTextP3("    ${controller.alphaSignRight.value.toStringAsFixed(2)}", colorPrimaryContainer),
                      MyTextP3("    ${(controller.alphaSignRight.value > 0 ? '升✔' : '降')}", colorPrimaryContainer),
                    ]),
                  ],
                ),
                const SizedBox(height: 20),
                MyTextP3("变化活跃度", colorPrimaryContainer),
                const SizedBox(height: 10),
                Table(
                  defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                  columnWidths: {
                    0: FixedColumnWidth(60),
                    1: FixedColumnWidth(60),
                    2: FixedColumnWidth(60),
                    3: FixedColumnWidth(60),
                  },
                  border: TableBorder.all(color: colorSecondary, width: 1),
                  children: [
                    TableRow(decoration: BoxDecoration(color: colorSurface), children: [
                      MyTextP3("    前", colorPrimaryContainer),
                      MyTextP3("    后", colorPrimaryContainer),
                      MyTextP3("    变", colorPrimaryContainer),
                      MyTextP3("    化", colorPrimaryContainer),
                    ]),
                    TableRow(children: [
                      MyTextP3("    ${controller.alphaActivityLeft.value.toStringAsFixed(2)}", colorPrimaryContainer),
                      MyTextP3("    ${controller.alphaActivityRight.value.toStringAsFixed(2)}", colorPrimaryContainer),
                      MyTextP3(
                          "    ${((controller.alphaActivityRight.value - controller.alphaActivityLeft.value) / controller.alphaActivityLeft.value * 100).toStringAsFixed(1)}%",
                          colorPrimaryContainer),
                      MyTextP3("    ${(controller.alphaActivityRight.value > controller.alphaActivityLeft.value ? '升✔' : '降')}", colorPrimaryContainer),
                    ]),
                  ],
                ),
                const SizedBox(height: 40),
                Divider(height: 1),
                const SizedBox(height: 40),
                MyTextP2("◇β 波◇"),
                Container(
                  padding: EdgeInsets.all(20),
                  width: MediaQuery.of(context).size.width,
                  height: 160,
                  child: LineChart(
                    LineChartData(
                      minY: 0,
                      maxY: 1,
                      gridData: FlGridData(show: false),
                      titlesData: FlTitlesData(
                        topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false, interval: 0.2)),
                        bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: false, interval: 20)),
                        leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false, interval: 0.2)),
                        rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false, interval: 0.2)),
                      ),
                      borderData: FlBorderData(show: false),
                      lineBarsData: [
                        LineChartBarData(
                          spots: controller.betaSpots.map<FlSpot>((e) => FlSpot(e.x, e.y)).toList(),
                          isCurved: false,
                          isStrokeCapRound: true,
                          isStrokeJoinRound: true,
                          color: colors5[3],
                          shadow: Shadow(
                            color: Colors.white,
                            blurRadius: 1,
                            offset: Offset(0, 3), // 阴影方向
                          ),
                          barWidth: 3,
                          dotData: FlDotData(show: false),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                MyTextP3("能耗变化趋势", colorPrimaryContainer),
                const SizedBox(height: 10),
                Table(
                  defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                  columnWidths: {
                    0: FixedColumnWidth(70),
                    1: FixedColumnWidth(70),
                    2: FixedColumnWidth(70),
                    3: FixedColumnWidth(70),
                    4: FixedColumnWidth(70),
                    5: FixedColumnWidth(70),
                    6: FixedColumnWidth(60),
                  },
                  border: TableBorder.all(color: colorSecondary, width: 1),
                  children: [
                    TableRow(decoration: BoxDecoration(color: colorSurface), children: [
                      MyTextP3("    最高", colorPrimaryContainer),
                      MyTextP3("    最低", colorPrimaryContainer),
                      MyTextP3("    均值", colorPrimaryContainer),
                      MyTextP3("    前", colorPrimaryContainer),
                      MyTextP3("    后", colorPrimaryContainer),
                      MyTextP3("    变", colorPrimaryContainer),
                      MyTextP3("    化", colorPrimaryContainer),
                    ]),
                    TableRow(children: [
                      MyTextP3("    ${controller.betaSpotMax.value.toStringAsFixed(0)}", colorPrimaryContainer),
                      MyTextP3("    ${controller.betaSpotMin.value.toStringAsFixed(0)}", colorPrimaryContainer),
                      MyTextP3("    ${controller.betaAvg.value.toStringAsFixed(0)}", colorPrimaryContainer),
                      MyTextP3("    ${controller.betaAvgLeft.value.toStringAsFixed(0)}", colorPrimaryContainer),
                      MyTextP3("    ${controller.betaAvgRight.value.toStringAsFixed(0)}", colorPrimaryContainer),
                      MyTextP3(
                          "    ${((controller.betaAvgRight.value - controller.betaAvgLeft.value) / controller.betaAvgLeft.value * 100).toStringAsFixed(1)}%",
                          colorPrimaryContainer),
                      MyTextP3("    ${(controller.betaAvgRight.value > controller.betaAvgLeft.value ? '升' : '降✔')}", colorPrimaryContainer),
                    ]),
                  ],
                ),
                const SizedBox(height: 20),
                MyTextP3("趋势显著度", colorPrimaryContainer),
                const SizedBox(height: 10),
                Table(
                  defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                  columnWidths: {
                    0: FixedColumnWidth(60),
                    1: FixedColumnWidth(120),
                    2: FixedColumnWidth(60),
                  },
                  border: TableBorder.all(color: colorSecondary, width: 1, borderRadius: BorderRadius.circular(10)),
                  children: [
                    TableRow(children: [
                      MyTextP3("    总", colorPrimaryContainer),
                      MyTextP3("    ${controller.betaSign.value.toStringAsFixed(2)}", colorPrimaryContainer),
                      MyTextP3("    ${(controller.betaSign.value > 0 ? '升' : '降✔')}", colorPrimaryContainer),
                    ]),
                    TableRow(children: [
                      MyTextP3("    前", colorPrimaryContainer),
                      MyTextP3("    ${controller.betaSignLeft.value.toStringAsFixed(2)}", colorPrimaryContainer),
                      MyTextP3("    ${(controller.betaSignLeft.value > 0 ? '升' : '降✔')}", colorPrimaryContainer),
                    ]),
                    TableRow(children: [
                      MyTextP3("    后", colorPrimaryContainer),
                      MyTextP3("    ${controller.betaSignRight.value.toStringAsFixed(2)}", colorPrimaryContainer),
                      MyTextP3("    ${(controller.betaSignRight.value > 0 ? '升' : '降✔')}", colorPrimaryContainer),
                    ]),
                  ],
                ),
                const SizedBox(height: 20),
                MyTextP3("变化活跃度", colorPrimaryContainer),
                const SizedBox(height: 10),
                Table(
                  defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                  columnWidths: {
                    0: FixedColumnWidth(60),
                    1: FixedColumnWidth(60),
                    2: FixedColumnWidth(60),
                    3: FixedColumnWidth(60),
                  },
                  border: TableBorder.all(color: colorSecondary, width: 1),
                  children: [
                    TableRow(decoration: BoxDecoration(color: colorSurface), children: [
                      MyTextP3("    前", colorPrimaryContainer),
                      MyTextP3("    后", colorPrimaryContainer),
                      MyTextP3("    变", colorPrimaryContainer),
                      MyTextP3("    化", colorPrimaryContainer),
                    ]),
                    TableRow(children: [
                      MyTextP3("    ${controller.betaActivityLeft.value.toStringAsFixed(2)}", colorPrimaryContainer),
                      MyTextP3("    ${controller.betaActivityRight.value.toStringAsFixed(2)}", colorPrimaryContainer),
                      MyTextP3(
                          "    ${((controller.betaActivityRight.value - controller.betaActivityLeft.value) / controller.betaActivityLeft.value * 100).toStringAsFixed(1)}%",
                          colorPrimaryContainer),
                      MyTextP3("    ${(controller.betaActivityRight.value > controller.betaActivityLeft.value ? '升' : '降✔')}", colorPrimaryContainer),
                    ]),
                  ],
                ),
                const SizedBox(height: 40),
                Divider(height: 1),
                const SizedBox(height: 40),
                MyTextP2("◇γ 波◇"),
                Container(
                  padding: EdgeInsets.all(20),
                  width: MediaQuery.of(context).size.width,
                  height: 160,
                  child: LineChart(
                    LineChartData(
                      minY: 0,
                      maxY: 1,
                      gridData: FlGridData(show: false),
                      titlesData: FlTitlesData(
                        topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false, interval: 0.2)),
                        bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: false, interval: 20)),
                        leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false, interval: 0.2)),
                        rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false, interval: 0.2)),
                      ),
                      borderData: FlBorderData(show: false),
                      lineBarsData: [
                        LineChartBarData(
                          spots: controller.gammaSpots.map<FlSpot>((e) => FlSpot(e.x, e.y)).toList(),
                          isCurved: false,
                          isStrokeCapRound: true,
                          isStrokeJoinRound: true,
                          color: colors5[4],
                          shadow: Shadow(
                            color: Colors.white,
                            blurRadius: 1,
                            offset: Offset(0, 3), // 阴影方向
                          ),
                          barWidth: 3,
                          dotData: FlDotData(show: false),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                MyTextP3("能耗变化趋势", colorPrimaryContainer),
                const SizedBox(height: 10),
                Table(
                  defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                  columnWidths: {
                    0: FixedColumnWidth(70),
                    1: FixedColumnWidth(70),
                    2: FixedColumnWidth(70),
                    3: FixedColumnWidth(70),
                    4: FixedColumnWidth(70),
                    5: FixedColumnWidth(70),
                    6: FixedColumnWidth(40),
                  },
                  border: TableBorder.all(color: colorSecondary, width: 1),
                  children: [
                    TableRow(decoration: BoxDecoration(color: colorSurface), children: [
                      MyTextP3("    最高", colorPrimaryContainer),
                      MyTextP3("    最低", colorPrimaryContainer),
                      MyTextP3("    均值", colorPrimaryContainer),
                      MyTextP3("    前", colorPrimaryContainer),
                      MyTextP3("    后", colorPrimaryContainer),
                      MyTextP3("    变", colorPrimaryContainer),
                      MyTextP3("    化", colorPrimaryContainer),
                    ]),
                    TableRow(children: [
                      MyTextP3("    ${controller.gammaSpotMax.value.toStringAsFixed(0)}", colorPrimaryContainer),
                      MyTextP3("    ${controller.gammaSpotMin.value.toStringAsFixed(0)}", colorPrimaryContainer),
                      MyTextP3("    ${controller.gammaAvg.value.toStringAsFixed(0)}", colorPrimaryContainer),
                      MyTextP3("    ${controller.gammaAvgLeft.value.toStringAsFixed(0)}", colorPrimaryContainer),
                      MyTextP3("    ${controller.gammaAvgRight.value.toStringAsFixed(0)}", colorPrimaryContainer),
                      MyTextP3(
                          "    ${((controller.gammaAvgRight.value - controller.gammaAvgLeft.value) / controller.gammaAvgLeft.value * 100).toStringAsFixed(1)}%",
                          colorPrimaryContainer),
                      MyTextP3("    ${(controller.gammaAvgRight.value > controller.gammaAvgLeft.value ? '升' : '降')}", colorPrimaryContainer),
                    ]),
                  ],
                ),
                const SizedBox(height: 20),
                MyTextP3("趋势显著度", colorPrimaryContainer),
                const SizedBox(height: 10),
                Table(
                  defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                  columnWidths: {
                    0: FixedColumnWidth(60),
                    1: FixedColumnWidth(120),
                    2: FixedColumnWidth(40),
                  },
                  border: TableBorder.all(color: colorSecondary, width: 1, borderRadius: BorderRadius.circular(10)),
                  children: [
                    TableRow(children: [
                      MyTextP3("    总", colorPrimaryContainer),
                      MyTextP3("    ${controller.gammaSign.value.toStringAsFixed(2)}", colorPrimaryContainer),
                      MyTextP3("    ${(controller.gammaSign.value > 0 ? '升' : '降')}", colorPrimaryContainer),
                    ]),
                    TableRow(children: [
                      MyTextP3("    前", colorPrimaryContainer),
                      MyTextP3("    ${controller.gammaSignLeft.value.toStringAsFixed(2)}", colorPrimaryContainer),
                      MyTextP3("    ${(controller.gammaSignLeft.value > 0 ? '升' : '降')}", colorPrimaryContainer),
                    ]),
                    TableRow(children: [
                      MyTextP3("    后", colorPrimaryContainer),
                      MyTextP3("    ${controller.gammaSignRight.value.toStringAsFixed(2)}", colorPrimaryContainer),
                      MyTextP3("    ${(controller.gammaSignRight.value > 0 ? '升' : '降')}", colorPrimaryContainer),
                    ]),
                  ],
                ),
                const SizedBox(height: 20),
                MyTextP3("变化活跃度", colorPrimaryContainer),
                const SizedBox(height: 10),
                Table(
                  defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                  columnWidths: {
                    0: FixedColumnWidth(60),
                    1: FixedColumnWidth(60),
                    2: FixedColumnWidth(60),
                    3: FixedColumnWidth(40),
                  },
                  border: TableBorder.all(color: colorSecondary, width: 1),
                  children: [
                    TableRow(decoration: BoxDecoration(color: colorSurface), children: [
                      MyTextP3("    前", colorPrimaryContainer),
                      MyTextP3("    后", colorPrimaryContainer),
                      MyTextP3("    变", colorPrimaryContainer),
                      MyTextP3("    化", colorPrimaryContainer),
                    ]),
                    TableRow(children: [
                      MyTextP3("    ${controller.gammaActivityLeft.value.toStringAsFixed(2)}", colorPrimaryContainer),
                      MyTextP3("    ${controller.gammaActivityRight.value.toStringAsFixed(2)}", colorPrimaryContainer),
                      MyTextP3(
                          "    ${((controller.gammaActivityRight.value - controller.gammaActivityLeft.value) / controller.gammaActivityLeft.value * 100).toStringAsFixed(1)}%",
                          colorPrimaryContainer),
                      MyTextP3("    ${(controller.gammaActivityRight.value > controller.gammaActivityLeft.value ? '升' : '降')}", colorPrimaryContainer),
                    ]),
                  ],
                ),
                const SizedBox(height: 40),
                Divider(height: 1),
                const SizedBox(height: 40),
                MyTextP2("◇α、β、γ 的活跃度对比图◇"),
                Container(
                  padding: EdgeInsets.all(20),
                  width: MediaQuery.of(context).size.width,
                  height: 400,
                  child: RadarChart(
                    RadarChartData(
                      radarBackgroundColor: Colors.transparent,
                      borderData: FlBorderData(show: false),
                      radarBorderData: BorderSide(color: colorSurface),
                      tickCount: 2,
                      tickBorderData: BorderSide(color: colorSurface),
                      ticksTextStyle: TextStyle(color: Colors.transparent),
                      gridBorderData: BorderSide(color: colorSurface),
                      dataSets: [
                        RadarDataSet(dataEntries: [
                          RadarEntry(value: controller.alphaActivityRight.value / controller.activityRightMax.value),
                          RadarEntry(value: controller.betaActivityRight.value / controller.activityRightMax.value),
                          RadarEntry(value: controller.gammaActivityRight.value / controller.activityRightMax.value),
                        ], fillColor: colorSurface.withValues(alpha: 0.5), borderColor: colorSurface),
                      ],
                      titlePositionPercentageOffset: 0.05,
                      titleTextStyle: TextStyle(color: colorPrimaryContainer, fontSize: 20),
                      getTitle: (index, angle) {
                        return switch (index) {
                          0 => RadarChartTitle(
                              text: 'α',
                              angle: 0,
                            ),
                          1 => RadarChartTitle(
                              text: 'β',
                              angle: 120,
                            ),
                          2 => RadarChartTitle(
                              text: 'γ',
                              angle: 240,
                            ),
                          _ => const RadarChartTitle(text: '', angle: 0),
                        };
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 40),
                Divider(height: 1),
                const SizedBox(height: 40),
                Container(
                  width: MediaQuery.of(context).size.width,
                  margin: EdgeInsets.all(0),
                  padding: EdgeInsets.all(0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      MyTextP2("◇心率 & 心率变异性◇"),
                      const SizedBox(height: 40),
                      MyTextP3("( 心率 )", colorPrimaryContainer),
                      PressureGauge(
                        label: controller.assess(controller.heartRateAvg.value),
                        value: controller.heartRateAvg.value.toDouble(),
                        maxValue: 150.0,
                        width: context.width * 0.5,
                      ),
                      const SizedBox(height: 10),
                      MyTextP2('${controller.heartRateAvg.value} bpm'),
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
                            MyTextP3("  < 50", colorPrimaryContainer),
                            MyTextP3(" 偏低", colorPrimaryContainer),
                            MyTextP3(" 或因情绪低落所致( 运动健将例外 )", colorPrimaryContainer),
                          ]),
                          TableRow(children: [
                            MyTextP3("  50 ~ 65", colorPrimaryContainer),
                            MyTextP3(" 优秀", colorPrimaryContainer),
                            MyTextP3(" 最佳状态，继续保持", colorPrimaryContainer),
                          ]),
                          TableRow(children: [
                            MyTextP3("  65 ~ 85", colorPrimaryContainer),
                            MyTextP3(" 常见", colorPrimaryContainer),
                            MyTextP3(" 继续保持", colorPrimaryContainer),
                          ]),
                          TableRow(children: [
                            MyTextP3("  85 ~ 105", colorPrimaryContainer),
                            MyTextP3(" 偏高", colorPrimaryContainer),
                            MyTextP3(" 或因兴奋所致( 当下是静息状态吗？)", colorPrimaryContainer),
                          ]),
                          TableRow(children: [
                            MyTextP3("  > 105", colorPrimaryContainer),
                            MyTextP3(" 过速", colorPrimaryContainer),
                            MyTextP3(" 建议寻求专业帮助", colorPrimaryContainer),
                          ]),
                        ],
                      ),
                      const SizedBox(height: 80),
                      MyTextP3("( 心率变异性 - HRV)", colorPrimaryContainer),
                      const SizedBox(height: 20),
                      MultiColorPieChart(
                        colors: [colorSurface, const Color.fromARGB(255, 160, 200, 255), Colors.grey],
                        values: [
                          controller.nn50.value / controller.nnCount.value,
                          controller.nn30.value / controller.nnCount.value,
                          controller.nn10.value / controller.nnCount.value,
                        ],
                        labels: ["NN50", "", ""],
                        width: context.width * 0.4,
                      ),
                      const SizedBox(height: 40),
                      Table(
                        defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                        columnWidths: {0: FixedColumnWidth(20), 1: FixedColumnWidth(120), 2: FixedColumnWidth(100), 3: FixedColumnWidth(120)},
                        border: TableBorder.all(color: colorSecondary, width: 1),
                        children: [
                          TableRow(decoration: BoxDecoration(color: colorSurface), children: [
                            Icon(Icons.circle_rounded, size: 16, color: colorSurface),
                            MyTextP3("  NN间期值", colorPrimaryContainer),
                            MyTextP3("  占比", colorPrimaryContainer),
                            MyTextP3(" 说明", colorPrimaryContainer),
                          ]),
                          TableRow(children: [
                            Icon(Icons.circle_rounded, size: 16, color: colorSurface),
                            MyTextP3("  >50", colorPrimaryContainer),
                            MyTextP3("  ${(controller.nn50.value / controller.nnCount.value * 100).toStringAsFixed(0)}%", colorPrimaryContainer),
                            MyTextP3(" 占比越高越好", colorPrimaryContainer),
                          ]),
                          TableRow(children: [
                            Icon(Icons.circle_rounded, size: 16, color: const Color.fromARGB(255, 160, 200, 255)),
                            MyTextP3("  30~50", colorPrimaryContainer),
                            MyTextP3("  ${(controller.nn30.value / controller.nnCount.value * 100).toStringAsFixed(0)}%", colorPrimaryContainer),
                            MyTextP3("", colorPrimaryContainer),
                          ]),
                          TableRow(children: [
                            Icon(Icons.circle_rounded, size: 16, color: Colors.grey),
                            MyTextP3("  <30", colorPrimaryContainer),
                            MyTextP3("  ${(controller.nn10.value / controller.nnCount.value * 100).toStringAsFixed(0)}%", colorPrimaryContainer),
                            MyTextP3(" 占比越低越好", colorPrimaryContainer),
                          ]),
                        ],
                      ),
                      const SizedBox(height: 20),
                      MyTextP3("NN50指相邻心跳间期值之差大于50ms，是副交感神经是否强健的重要指标", colorPrimaryContainer),
                      MyTextP3("（NN50占比>30%为优秀，20%~30%之间为普通，<20%较弱）", colorPrimaryContainer),
                      MyTextP3("副交感神经的强健能促进深度放松与内在修复，提升心脏调节的灵活性", colorPrimaryContainer),
                    ],
                  ),
                ),
                const SizedBox(height: 40),
                Divider(height: 1),
                const SizedBox(height: 40),
                Container(
                  width: MediaQuery.of(context).size.width,
                  margin: EdgeInsets.all(0),
                  padding: EdgeInsets.all(0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      MyTextP2("◇压力分析◇"),
                      const SizedBox(height: 40),
                      PressureGauge(
                        label: "${(controller.psyPresssure.value * 100).toStringAsFixed(1)}%",
                        value: controller.psyPresssure.value,
                        maxValue: 1.0,
                        width: context.width * 0.4,
                      ),
                      const SizedBox(height: 10),
                      MyTextP3("心理压力", colorPrimaryContainer),
                      const SizedBox(height: 20),
                      Table(
                        defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                        columnWidths: {0: FixedColumnWidth(100), 1: FixedColumnWidth(80), 2: FixedColumnWidth(240)},
                        border: TableBorder.all(color: colorSecondary, width: 1, borderRadius: BorderRadius.circular(5)),
                        children: [
                          TableRow(children: [
                            MyTextP3("  <50%", colorPrimaryContainer),
                            MyTextP3("  轻松", colorPrimaryContainer),
                            MyTextP3("  从从容容，游刃有余", colorPrimaryContainer),
                          ]),
                          TableRow(children: [
                            MyTextP3("  50%~70%", colorPrimaryContainer),
                            MyTextP3("  一般", colorPrimaryContainer),
                            MyTextP3("  增加阻抗训练，注意劳逸结合", colorPrimaryContainer),
                          ]),
                          TableRow(children: [
                            MyTextP3("  >70%", colorPrimaryContainer),
                            MyTextP3("  较重", colorPrimaryContainer),
                            MyTextP3("  寻求疗愈支持，帮助大脑减压", colorPrimaryContainer),
                          ]),
                        ],
                      ),
                      const SizedBox(height: 40),
                      PressureGauge(
                        label: "${(controller.phyPresssure.value * 100).toStringAsFixed(1)}%",
                        value: controller.phyPresssure.value,
                        maxValue: 1.0,
                        width: context.width * 0.4,
                      ),
                      const SizedBox(height: 10),
                      MyTextP3("心脏压力", colorPrimaryContainer),
                      const SizedBox(height: 20),
                      Table(
                        defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                        columnWidths: {0: FixedColumnWidth(100), 1: FixedColumnWidth(80), 2: FixedColumnWidth(240)},
                        border: TableBorder.all(color: colorSecondary, width: 1, borderRadius: BorderRadius.circular(5)),
                        children: [
                          TableRow(children: [
                            MyTextP3("  <20%", colorPrimaryContainer),
                            MyTextP3("  轻松", colorPrimaryContainer),
                            MyTextP3("  从从容容，游刃有余", colorPrimaryContainer),
                          ]),
                          TableRow(children: [
                            MyTextP3("  20%~60%", colorPrimaryContainer),
                            MyTextP3("  一般", colorPrimaryContainer),
                            MyTextP3("  增加阻抗训练，注意劳逸结合", colorPrimaryContainer),
                          ]),
                          TableRow(children: [
                            MyTextP3("  >60%", colorPrimaryContainer),
                            MyTextP3("  较重", colorPrimaryContainer),
                            MyTextP3("  寻求疗愈支持，帮助心脏减压", colorPrimaryContainer),
                          ]),
                        ],
                      ),
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
                const SizedBox(height: 40),
                Divider(height: 1),
                Container(
                  alignment: Alignment.center,
                  transformAlignment: Alignment.center,
                  height: 200,
                  child: MyTextP3("Copyright 2026 HealingAI", colorPrimaryContainer),
                ),
              ],
            )),
      ),
    );
  }
}

class RecordList extends GetView<RecordCtrl> {
  RecordList({super.key});
  final customerCtrl = Get.put(CustomerCtrl());
  final employeeCtrl = Get.put(EmployeeCtrl());
  final isUploading = false.obs;
  final isDownloading = false.obs;
  @override
  final controller = Get.put(RecordCtrl());
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(10),
      padding: EdgeInsets.all(10),
      width: MediaQuery.of(context).size.width,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            Container(
              margin: EdgeInsets.all(10),
              width: MediaQuery.of(context).size.width * 0.5,
              decoration: BoxDecoration(
                color: colorSecondary,
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey,
                    spreadRadius: 1,
                    blurRadius: 1,
                    offset: Offset(0, 1), // 阴影方向
                  ),
                ],
              ),
              child: Obx(() => ListView.builder(
                    itemCount: controller.customerRecordFileList.length,
                    itemBuilder: (context, index) {
                      return ListTile(
                        leading: isUploading.value
                            ? Icon(Icons.webhook_rounded)
                            : IconButton(
                                icon: Icon(controller.customerRecordFileList[index].endsWith(".json") ? Icons.upload_rounded : Icons.link_rounded),
                                onPressed: () async {
                                  final name = controller.customerRecordFileList[index];
                                  debugPrint(name);
                                  if (name.endsWith(".json")) {
                                    if (isUploading.value) {
                                      Get.snackbar("提示", "正在上传中，请稍后……");
                                      return;
                                    }
                                    Get.defaultDialog(
                                      title: "确认上传？",
                                      middleText: name,
                                      onConfirm: () async {
                                        Get.back();
                                        try {
                                          isUploading.value = true;
                                          final data = await Data.read(name);
                                          if (await controller.addRecord({
                                            "heartRate": List<double>.from(data["record_data"]["heartRate"]),
                                            "hrv": List<double>.from(data["record_data"]["hrv"]),
                                            "temperature": List<double>.from(data["record_data"]["temperature"]),
                                            "delta": List<double>.from(data["record_data"]["delta"]),
                                            "theta": List<double>.from(data["record_data"]["theta"]),
                                            "alpha": List<double>.from(data["record_data"]["alpha"]),
                                            "beta": List<double>.from(data["record_data"]["beta"]),
                                            "gamma": List<double>.from(data["record_data"]["gamma"])
                                          })) {
                                            Get.snackbar("成功", "记录上传成功！");
                                            isUploading.value = false;
                                            final newName = "${name}x";
                                            if (await Data.rename(name, newName)) {
                                              controller.customerRecordFileList[index] = newName;
                                            }
                                            Map<String, dynamic> customer = await employeeCtrl.getCusomer(customerCtrl.phone.value);
                                            if (customer.isNotEmpty) {
                                              customerCtrl.recordings.clear();
                                              customerCtrl.recordings.addAll(customer['recordings']);
                                            }
                                          } else {
                                            Get.snackbar("失败", "记录上传失败！");
                                          }
                                        } finally {
                                          isUploading.value = false;
                                        }
                                      },
                                      onCancel: () => Get.back(),
                                    );
                                  } else {
                                    Get.snackbar("提示", "数据已上传云端，本地备份可删除");
                                  }
                                }),
                        title: Text(controller.customerRecordFileList[index].split("_")[1]),
                        subtitle: Text(controller.customerRecordFileList[index].split("_")[4].split(".")[0]),
                        onTap: () async {
                          if (await controller.getLocalRecord(controller.customerRecordFileList[index])) controller.show();
                          Get.back();
                          Get.snackbar("提示", "加载本地记录");
                        },
                        trailing: controller.customerRecordFileList[index].endsWith(".jsonx")
                            ? IconButton(
                                icon: Icon(Icons.delete_outline_rounded),
                                onPressed: () async {
                                  Get.defaultDialog(
                                    title: "确认删除？",
                                    middleText: controller.customerRecordFileList[index],
                                    onConfirm: () async {
                                      await Data.delete(controller.customerRecordFileList[index]);
                                      controller.customerRecordFileList.removeAt(index);
                                      Get.back();
                                    },
                                    onCancel: () => Get.back(),
                                  );
                                },
                              )
                            : SizedBox.shrink(),
                      );
                    },
                  )),
            ),
            Container(
              margin: EdgeInsets.all(10),
              width: MediaQuery.of(context).size.width * 0.3,
              child: Obx(() => ListView.builder(
                    itemCount: customerCtrl.recordings.length,
                    itemBuilder: (context, index) {
                      return ListTile(
                        leading: Icon(Icons.cloud_queue_rounded),
                        title: Text(customerCtrl.nickname.value),
                        subtitle: Text(DateFormat('yyyy-MM-dd-HH:mm').format(DateTime.parse(customerCtrl.recordings[index]["record_at"]).toLocal())),
                        onTap: () async {
                          if (isDownloading.value) {
                            Get.snackbar("提示", "正在下载中，请稍后……");
                            return;
                          }
                          isDownloading.value = true;
                          try {
                            if (await controller.getCloudRecord(customerCtrl.recordings[index]["id"])) controller.show();
                            isDownloading.value = false;
                            Get.snackbar("提示", "数据已下载到本地");
                          } finally {
                            isDownloading.value = false;
                          }
                        },
                      );
                    },
                  )),
            ),
          ],
        ),
      ),
    );
  }
}

class RecordCtrl extends GetxController {
  final recordFileList = <String>[].obs;
  final customerRecordFileList = <String>[].obs;
  final customerCtrl = Get.put(CustomerCtrl());
  final employeeCtrl = Get.put(EmployeeCtrl());

  final heartRate = [].obs;
  final hrv = [].obs;
  final temperature = [].obs;
  final delta = [].obs;
  final theta = [].obs;
  final alpha = [].obs;
  final beta = [].obs;
  final gamma = [].obs;

  final sampleSize = 0.obs;
  final recordId = ''.obs;
  final recordAt = ''.obs;
  final employeePhone = ''.obs;
  final recordFile = ''.obs;
  final localFile = ''.obs;
  final isLock = "".obs;
  //
  final heartRateAvg = 72.obs;
  final hrvAvg = 800.obs;
  final temperatureAvg = 35.5.obs;
  final deltaAvg = 1.obs;
  final thetaAvg = 1.obs;
  final alphaAvg = 1.obs;
  final betaAvg = 1.obs;
  final gammaAvg = 1.obs;
  final totalAvg = 5.obs;
  final deltaAvgLeft = 1.obs;
  final thetaAvgLeft = 1.obs;
  final alphaAvgLeft = 1.obs;
  final betaAvgLeft = 1.obs;
  final gammaAvgLeft = 1.obs;
  final totalAvgLeft = 5.obs;
  final deltaAvgRight = 1.obs;
  final thetaAvgRight = 1.obs;
  final alphaAvgRight = 1.obs;
  final betaAvgRight = 1.obs;
  final gammaAvgRight = 1.obs;
  final totalAvgRight = 5.obs;
  //
  final deltaSpots = [].obs;
  final deltaSpotMax = 1.0.obs;
  final deltaSpotMin = 1.0.obs;
  final deltaSign = 1.0.obs;
  final deltaSignLeft = 1.0.obs;
  final deltaSignRight = 1.0.obs;
  final deltaActivityLeft = 1.0.obs;
  final deltaActivityRight = 1.0.obs;
  //
  final thetaSpots = [].obs;
  final thetaSpotMax = 1.0.obs;
  final thetaSpotMin = 1.0.obs;
  final thetaSign = 1.0.obs;
  final thetaSignLeft = 1.0.obs;
  final thetaSignRight = 1.0.obs;
  final thetaActivityLeft = 1.0.obs;
  final thetaActivityRight = 1.0.obs;
  //
  final alphaSpots = [].obs;
  final alphaSpotMax = 1.0.obs;
  final alphaSpotMin = 1.0.obs;
  final alphaSign = 1.0.obs;
  final alphaSignLeft = 1.0.obs;
  final alphaSignRight = 1.0.obs;
  final alphaActivityLeft = 1.0.obs;
  final alphaActivityRight = 1.0.obs;
  //
  final betaSpots = [].obs;
  final betaSpotMax = 1.0.obs;
  final betaSpotMin = 1.0.obs;
  final betaSign = 1.0.obs;
  final betaSignLeft = 1.0.obs;
  final betaSignRight = 1.0.obs;
  final betaActivityLeft = 1.0.obs;
  final betaActivityRight = 1.0.obs;
  //
  final gammaSpots = [].obs;
  final gammaSpotMax = 1.0.obs;
  final gammaSpotMin = 1.0.obs;
  final gammaSign = 1.0.obs;
  final gammaSignLeft = 1.0.obs;
  final gammaSignRight = 1.0.obs;
  final gammaActivityLeft = 1.0.obs;
  final gammaActivityRight = 1.0.obs;
  //
  final activityRightMax = 1.0.obs;
  //
  final psyPresssure = 0.5.obs;
  final phyPresssure = 0.5.obs;

  @override
  Future<void> onInit() async {
    super.onInit();
  }

  Future<void> init() async {
    recordFileList.value = await Data.readFileList("record_");
    if (customerCtrl.phone.value.isNotEmpty) {
      customerRecordFileList.value = recordFileList.where((element) => element.contains(customerCtrl.phone.value)).toList();
    }
  }

  Future<bool> getCloudRecord(int id) async {
    if (employeeCtrl.phone.value.isEmpty || employeeCtrl.password.value.isEmpty) {
      Get.snackbar('提示', '请先登录');
      return false;
    }
    if (customerCtrl.phone.value.isEmpty) {
      Get.snackbar('提示', '请先添加服务对象');
      return false;
    }
    http.Response? response;
    try {
      response = await http.post(Uri.parse('${Data.srvIp}employee/recording/'),
          body: jsonEncode({'phone': employeeCtrl.phone.value, 'password': employeeCtrl.password.value, 'record_id': id}));
    } catch (e) {
      debugPrint("异常GetCloudRecord $e");
    }
    if (response == null || response.statusCode != 200) {
      return false;
    } else {
      final responseData = json.decode(response.body);
      heartRate.value = List<double>.from(responseData["record_data"]["heartRate"]);
      hrv.value = List<double>.from(responseData["record_data"]["hrv"]);
      temperature.value = List<double>.from(responseData["record_data"]["temperature"]);
      delta.value = List<double>.from(responseData["record_data"]["delta"]);
      theta.value = List<double>.from(responseData["record_data"]["theta"]);
      alpha.value = List<double>.from(responseData["record_data"]["alpha"]);
      beta.value = List<double>.from(responseData["record_data"]["beta"]);
      gamma.value = List<double>.from(responseData["record_data"]["gamma"]);
      sampleSize.value = delta.length;
      recordId.value = id.toString();
      recordAt.value = DateFormat('yyyy-MM-dd-HH:mm').format(DateTime.parse(responseData["record_at"]).toLocal());
      employeePhone.value = responseData["employee_phone"];
      recordFile.value = ""; // responseData["record_file"];
      isLock.value = responseData["is_lock"] ? "已锁定" : "正常";
      //保存到本地
      final fileNameTemp = "record_${customerCtrl.nickname.value}_${customerCtrl.phone.value}_${sampleSize.value}_${recordAt.value}.jsonx";
      if (!await Data.exists(fileNameTemp)) {
        final dataTemp = {
          "record_id": recordId.value,
          "record_at": recordAt.value,
          "employee_phone": employeePhone.value,
          "record_file": recordFile.value,
          "is_lock": isLock.value,
          "sampleSize": sampleSize.value,
          "record_data": {
            "heartRate": heartRate.toList(),
            "hrv": hrv.toList(),
            "temperature": temperature.toList(),
            "delta": delta.toList(),
            "theta": theta.toList(),
            "alpha": alpha.toList(),
            "beta": beta.toList(),
            "gamma": gamma.toList(),
          }
        };
        await Data.write(dataTemp, fileNameTemp);
        customerRecordFileList.add(fileNameTemp);
      }

      return true;
    }
  }

  Future<bool> getLocalRecord(String fileName) async {
    localFile.value = fileName;
    final data = await Data.read(fileName);
    if (data.isNotEmpty) {
      heartRate.value = data["record_data"]["heartRate"];
      hrv.value = data["record_data"]["hrv"];
      temperature.value = data["record_data"]["temperature"];
      delta.value = data["record_data"]["delta"];
      theta.value = data["record_data"]["theta"];
      alpha.value = data["record_data"]["alpha"];
      beta.value = data["record_data"]["beta"];
      gamma.value = data["record_data"]["gamma"];
      sampleSize.value = data["sampleSize"];
      recordId.value = data["record_id"];
      recordAt.value = data["record_at"];
      employeePhone.value = data["employee_phone"];
      recordFile.value = data["record_file"];
      isLock.value = data["is_lock"];
      return true;
    } else {
      return false;
    }
  }

  void show() {
    heartRateAvg.value = Data.calculateMV(List<double>.from(heartRate)).toInt();
    hrvAvg.value = Data.calculateMV(List<double>.from(hrv)).toInt();
    temperatureAvg.value = Data.calculateMV(List<double>.from(temperature));
    deltaAvg.value = Data.calculateMV(List<double>.from(delta)).toInt();
    thetaAvg.value = Data.calculateMV(List<double>.from(theta)).toInt();
    alphaAvg.value = Data.calculateMV(List<double>.from(alpha)).toInt();
    betaAvg.value = Data.calculateMV(List<double>.from(beta)).toInt();
    gammaAvg.value = Data.calculateMV(List<double>.from(gamma)).toInt();
    totalAvg.value = deltaAvg.value + thetaAvg.value + alphaAvg.value + betaAvg.value + gammaAvg.value;
    deltaAvgLeft.value = Data.calculateMV(List<double>.from(delta.sublist(0, sampleSize.value ~/ 2))).toInt();
    thetaAvgLeft.value = Data.calculateMV(List<double>.from(theta.sublist(0, sampleSize.value ~/ 2))).toInt();
    alphaAvgLeft.value = Data.calculateMV(List<double>.from(alpha.sublist(0, sampleSize.value ~/ 2))).toInt();
    betaAvgLeft.value = Data.calculateMV(List<double>.from(beta.sublist(0, sampleSize.value ~/ 2))).toInt();
    gammaAvgLeft.value = Data.calculateMV(List<double>.from(gamma.sublist(0, sampleSize.value ~/ 2))).toInt();
    totalAvgLeft.value = deltaAvgLeft.value + thetaAvgLeft.value + alphaAvgLeft.value + betaAvgLeft.value + gammaAvgLeft.value;
    deltaAvgRight.value = Data.calculateMV(List<double>.from(delta.sublist(sampleSize.value ~/ 2))).toInt();
    thetaAvgRight.value = Data.calculateMV(List<double>.from(theta.sublist(sampleSize.value ~/ 2))).toInt();
    alphaAvgRight.value = Data.calculateMV(List<double>.from(alpha.sublist(sampleSize.value ~/ 2))).toInt();
    betaAvgRight.value = Data.calculateMV(List<double>.from(beta.sublist(sampleSize.value ~/ 2))).toInt();
    gammaAvgRight.value = Data.calculateMV(List<double>.from(gamma.sublist(sampleSize.value ~/ 2))).toInt();
    totalAvgRight.value = deltaAvgRight.value + thetaAvgRight.value + alphaAvgRight.value + betaAvgRight.value + gammaAvgRight.value;
    //
    deltaSpots.clear();
    deltaSpotMax.value = delta.reduce((value, element) => value > element ? value : element);
    deltaSpotMin.value = delta.reduce((value, element) => value < element ? value : element);
    for (int i = 0; i < delta.length; i++) {
      deltaSpots.add(FlSpot(i.toDouble(), (delta[i] / deltaSpotMax.value * 1000).toInt() / 1000));
    }
    final deltaTrend = Data.calculateTrendSign(List<double>.from(delta));
    deltaSign.value = deltaTrend['sign'];
    deltaSignLeft.value = deltaTrend['left']["sign"];
    deltaSignRight.value = deltaTrend['right']["sign"];
    deltaActivityLeft.value = deltaTrend['left']["activity"];
    deltaActivityRight.value = deltaTrend['right']["activity"];
    //
    thetaSpots.clear();
    thetaSpotMax.value = theta.reduce((value, element) => value > element ? value : element);
    thetaSpotMin.value = theta.reduce((value, element) => value < element ? value : element);
    for (int i = 0; i < theta.length; i++) {
      thetaSpots.add(FlSpot(i.toDouble(), (theta[i] / thetaSpotMax.value * 1000).toInt() / 1000));
    }
    final thetaTrend = Data.calculateTrendSign(List<double>.from(theta));
    thetaSign.value = thetaTrend['sign'];
    thetaSignLeft.value = thetaTrend['left']["sign"];
    thetaSignRight.value = thetaTrend['right']["sign"];
    thetaActivityLeft.value = thetaTrend['left']["activity"];
    thetaActivityRight.value = thetaTrend['right']["activity"];
    //
    alphaSpots.clear();
    alphaSpotMax.value = alpha.reduce((value, element) => value > element ? value : element);
    alphaSpotMin.value = alpha.reduce((value, element) => value < element ? value : element);
    for (int i = 0; i < alpha.length; i++) {
      alphaSpots.add(FlSpot(i.toDouble(), (alpha[i] / alphaSpotMax.value * 1000).toInt() / 1000));
    }
    final alphaTrend = Data.calculateTrendSign(List<double>.from(alpha));
    alphaSign.value = alphaTrend['sign'];
    alphaSignLeft.value = alphaTrend['left']["sign"];
    alphaSignRight.value = alphaTrend['right']["sign"];
    alphaActivityLeft.value = alphaTrend['left']["activity"];
    alphaActivityRight.value = alphaTrend['right']["activity"];
    //
    betaSpots.clear();
    betaSpotMax.value = beta.reduce((value, element) => value > element ? value : element);
    betaSpotMin.value = beta.reduce((value, element) => value < element ? value : element);
    for (int i = 0; i < beta.length; i++) {
      betaSpots.add(FlSpot(i.toDouble(), (beta[i] / betaSpotMax.value * 1000).toInt() / 1000));
    }
    final betaTrend = Data.calculateTrendSign(List<double>.from(beta));
    betaSign.value = betaTrend['sign'];
    betaSignLeft.value = betaTrend['left']["sign"];
    betaSignRight.value = betaTrend['right']["sign"];
    betaActivityLeft.value = betaTrend['left']["activity"];
    betaActivityRight.value = betaTrend['right']["activity"];
    //
    gammaSpots.clear();
    gammaSpotMax.value = gamma.reduce((value, element) => value > element ? value : element);
    gammaSpotMin.value = gamma.reduce((value, element) => value < element ? value : element);
    for (int i = 0; i < gamma.length; i++) {
      gammaSpots.add(FlSpot(i.toDouble(), (gamma[i] / gammaSpotMax.value * 1000).toInt() / 1000));
    }
    final gammaTrend = Data.calculateTrendSign(List<double>.from(gamma));
    gammaSign.value = gammaTrend['sign'];
    gammaSignLeft.value = gammaTrend['left']["sign"];
    gammaSignRight.value = gammaTrend['right']["sign"];
    gammaActivityLeft.value = gammaTrend['left']["activity"];
    gammaActivityRight.value = gammaTrend['right']["activity"];
    //
    activityRightMax.value = [
      alphaActivityRight.value,
      betaActivityRight.value,
      gammaActivityRight.value,
    ].reduce((value, element) => value > element ? value : element);
    //
    final hrvList = List<double>.from(hrv);
    nnCount.value = hrvList.length - 1;
    nn50.value = 0;
    nn30.value = 0;
    nn10.value = 0;
    for (int i = 0; i < hrvList.length - 1; i++) {
      if ((hrvList[i + 1] - hrvList[i]).abs() > 50) {
        nn50.value++;
      } else if ((hrvList[i + 1] - hrvList[i]).abs() > 30) {
        nn30.value++;
      } else {
        nn10.value++;
      }
    }
    //
    final psyPressureTotal = alphaActivityRight.value + betaActivityRight.value;
    if (psyPressureTotal > 0) psyPresssure.value = betaActivityRight.value / psyPressureTotal;
    phyPresssure.value = Data.calculateLFHF(hrvList)[3] / 5;
  }

  final touchedIndex = (-1).obs;
  List<PieChartSectionData> brainwavesPieSections() {
    return List.generate(
      5,
      (i) {
        final isTouched = i == touchedIndex.value;
        final radius = 400;
        return switch (i) {
          0 => PieChartSectionData(
              color: colors5[0],
              value: 20,
              title: 'δ ${(deltaAvg.value / totalAvg.value * 100).toStringAsFixed(0)}%',
              titleStyle: TextStyle(fontSize: 12, color: colorSecondary),
              radius: radius * (deltaAvg.value / totalAvg.value),
              titlePositionPercentageOffset: 0.55,
              borderSide: isTouched ? BorderSide(color: colorSecondary, width: 6) : BorderSide(color: colorSecondary.withValues(alpha: 0)),
            ),
          1 => PieChartSectionData(
              color: colors5[1],
              value: 20,
              title: 'θ ${(thetaAvg.value / totalAvg.value * 100).toStringAsFixed(0)}%',
              titleStyle: TextStyle(fontSize: 12, color: colorSecondary),
              radius: radius * (thetaAvg.value / totalAvg.value),
              titlePositionPercentageOffset: 0.55,
              borderSide: isTouched ? BorderSide(color: colorSecondary, width: 6) : BorderSide(color: colorSecondary.withValues(alpha: 0)),
            ),
          2 => PieChartSectionData(
              color: colors5[2],
              value: 20,
              title: 'α ${(alphaAvg.value / totalAvg.value * 100).toStringAsFixed(0)}%',
              titleStyle: TextStyle(fontSize: 12, color: colorSecondary),
              radius: radius * (alphaAvg.value / totalAvg.value),
              titlePositionPercentageOffset: 0.6,
              borderSide: isTouched ? BorderSide(color: colorSecondary, width: 6) : BorderSide(color: colorSecondary.withValues(alpha: 0)),
            ),
          3 => PieChartSectionData(
              color: colors5[3],
              value: 20,
              title: 'β ${(betaAvg.value / totalAvg.value * 100).toStringAsFixed(0)}%',
              titleStyle: TextStyle(fontSize: 12, color: colorSecondary),
              radius: radius * (betaAvg.value / totalAvg.value),
              titlePositionPercentageOffset: 0.55,
              borderSide: isTouched ? BorderSide(color: colorSecondary, width: 6) : BorderSide(color: colorSecondary.withValues(alpha: 0)),
            ),
          4 => PieChartSectionData(
              color: colors5[4],
              value: 20,
              title: 'γ ${(gammaAvg.value / totalAvg.value * 100).toStringAsFixed(0)}%',
              titleStyle: TextStyle(fontSize: 12, color: colorSecondary),
              radius: radius * (gammaAvg.value / totalAvg.value),
              titlePositionPercentageOffset: 0.55,
              borderSide: isTouched ? BorderSide(color: colorSecondary, width: 6) : BorderSide(color: colorSecondary.withValues(alpha: 0)),
            ),
          _ => throw StateError('Invalid'),
        };
      },
    );
  }

  List<PieChartSectionData> brainwavesPieSectionsLeft() {
    return List.generate(
      5,
      (i) {
        final isTouched = i == touchedIndex.value;
        final radius = 200;
        return switch (i) {
          0 => PieChartSectionData(
              color: colors5[0],
              value: 20,
              title: 'δ ${(deltaAvgLeft.value / totalAvgLeft.value * 100).toStringAsFixed(0)}%',
              titleStyle: TextStyle(fontSize: 12, color: colorSecondary),
              radius: radius * (deltaAvgLeft.value / totalAvgLeft.value),
              titlePositionPercentageOffset: 0.55,
              borderSide: isTouched ? BorderSide(color: colorSecondary, width: 6) : BorderSide(color: colorSecondary.withValues(alpha: 0)),
            ),
          1 => PieChartSectionData(
              color: colors5[1],
              value: 20,
              title: 'θ ${(thetaAvgLeft.value / totalAvgLeft.value * 100).toStringAsFixed(0)}%',
              titleStyle: TextStyle(fontSize: 12, color: colorSecondary),
              radius: radius * (thetaAvgLeft.value / totalAvgLeft.value),
              titlePositionPercentageOffset: 0.55,
              borderSide: isTouched ? BorderSide(color: colorSecondary, width: 6) : BorderSide(color: colorSecondary.withValues(alpha: 0)),
            ),
          2 => PieChartSectionData(
              color: colors5[2],
              value: 20,
              title: 'α ${(alphaAvgLeft.value / totalAvgLeft.value * 100).toStringAsFixed(0)}%',
              titleStyle: TextStyle(fontSize: 12, color: colorSecondary),
              radius: radius * (alphaAvgLeft.value / totalAvgLeft.value),
              titlePositionPercentageOffset: 0.6,
              borderSide: isTouched ? BorderSide(color: colorSecondary, width: 6) : BorderSide(color: colorSecondary.withValues(alpha: 0)),
            ),
          3 => PieChartSectionData(
              color: colors5[3],
              value: 20,
              title: 'β ${(betaAvgLeft.value / totalAvgLeft.value * 100).toStringAsFixed(0)}%',
              titleStyle: TextStyle(fontSize: 12, color: colorSecondary),
              radius: radius * (betaAvgLeft.value / totalAvgLeft.value),
              titlePositionPercentageOffset: 0.55,
              borderSide: isTouched ? BorderSide(color: colorSecondary, width: 6) : BorderSide(color: colorSecondary.withValues(alpha: 0)),
            ),
          4 => PieChartSectionData(
              color: colors5[4],
              value: 20,
              title: 'γ ${(gammaAvgLeft.value / totalAvgLeft.value * 100).toStringAsFixed(0)}%',
              titleStyle: TextStyle(fontSize: 12, color: colorSecondary),
              radius: radius * (gammaAvgLeft.value / totalAvgLeft.value),
              titlePositionPercentageOffset: 0.55,
              borderSide: isTouched ? BorderSide(color: colorSecondary, width: 6) : BorderSide(color: colorSecondary.withValues(alpha: 0)),
            ),
          _ => throw StateError('Invalid'),
        };
      },
    );
  }

  List<PieChartSectionData> brainwavesPieSectionsRight() {
    return List.generate(
      5,
      (i) {
        final isTouched = i == touchedIndex.value;
        final radius = 200;
        return switch (i) {
          0 => PieChartSectionData(
              color: colors5[0],
              value: 20,
              title: 'δ ${(deltaAvgRight.value / totalAvgRight.value * 100).toStringAsFixed(0)}%',
              titleStyle: TextStyle(fontSize: 12, color: colorSecondary),
              radius: radius * (deltaAvgRight.value / totalAvgRight.value),
              titlePositionPercentageOffset: 0.55,
              borderSide: isTouched ? BorderSide(color: colorSecondary, width: 6) : BorderSide(color: colorSecondary.withValues(alpha: 0)),
            ),
          1 => PieChartSectionData(
              color: colors5[1],
              value: 20,
              title: 'θ ${(thetaAvgRight.value / totalAvgRight.value * 100).toStringAsFixed(0)}%',
              titleStyle: TextStyle(fontSize: 12, color: colorSecondary),
              radius: radius * (thetaAvgRight.value / totalAvgRight.value),
              titlePositionPercentageOffset: 0.55,
              borderSide: isTouched ? BorderSide(color: colorSecondary, width: 6) : BorderSide(color: colorSecondary.withValues(alpha: 0)),
            ),
          2 => PieChartSectionData(
              color: colors5[2],
              value: 20,
              title: 'α ${(alphaAvgRight.value / totalAvgRight.value * 100).toStringAsFixed(0)}%',
              titleStyle: TextStyle(fontSize: 12, color: colorSecondary),
              radius: radius * (alphaAvgRight.value / totalAvgRight.value),
              titlePositionPercentageOffset: 0.6,
              borderSide: isTouched ? BorderSide(color: colorSecondary, width: 6) : BorderSide(color: colorSecondary.withValues(alpha: 0)),
            ),
          3 => PieChartSectionData(
              color: colors5[3],
              value: 20,
              title: 'β ${(betaAvgRight.value / totalAvgRight.value * 100).toStringAsFixed(0)}%',
              titleStyle: TextStyle(fontSize: 12, color: colorSecondary),
              radius: radius * (betaAvgRight.value / totalAvgRight.value),
              titlePositionPercentageOffset: 0.55,
              borderSide: isTouched ? BorderSide(color: colorSecondary, width: 6) : BorderSide(color: colorSecondary.withValues(alpha: 0)),
            ),
          4 => PieChartSectionData(
              color: colors5[4],
              value: 20,
              title: 'γ ${(gammaAvgRight.value / totalAvgRight.value * 100).toStringAsFixed(0)}%',
              titleStyle: TextStyle(fontSize: 12, color: colorSecondary),
              radius: radius * (gammaAvgRight.value / totalAvgRight.value),
              titlePositionPercentageOffset: 0.55,
              borderSide: isTouched ? BorderSide(color: colorSecondary, width: 6) : BorderSide(color: colorSecondary.withValues(alpha: 0)),
            ),
          _ => throw StateError('Invalid'),
        };
      },
    );
  }

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

  Future<bool> addRecord(Map<String, dynamic> newRecord) async {
    if (employeeCtrl.phone.value.isEmpty || employeeCtrl.password.value.isEmpty) {
      Get.snackbar('提示', '请先登录');
      return false;
    }
    if (customerCtrl.phone.value.isEmpty) {
      Get.snackbar('提示', '请先添加服务对象');
      return false;
    }
    http.Response? response;
    try {
      response = await http.post(Uri.parse('${Data.srvIp}employee/customer/recording/add/'),
          body: jsonEncode(
              {'phone': employeeCtrl.phone.value, 'password': employeeCtrl.password.value, 'customer_id': customerCtrl.id.value, 'record_data': newRecord}));
    } catch (e) {
      debugPrint("异常AddRecord $e");
    }

    if (response == null) {
      return false;
    } else if (response.statusCode != 200) {
      debugPrint(response.statusCode.toString());
      debugPrint(response.body);
      return false;
    } else {
      debugPrint(response.body);
      return true;
    }
  }
}

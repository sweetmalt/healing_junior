import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:healing_junior/apps/baseline.dart';
import 'package:healing_junior/apps/bci.dart';
import 'package:healing_junior/apps/brain_load.dart';
import 'package:healing_junior/apps/customer.dart';
import 'package:healing_junior/apps/draw.dart';
import 'package:healing_junior/apps/employee.dart';
import 'package:healing_junior/apps/heart_rate.dart';
import 'package:healing_junior/apps/hrv.dart';
import 'package:healing_junior/apps/institution.dart';
import 'package:healing_junior/apps/pdf.dart';
import 'package:healing_junior/apps/pressure.dart';
import 'package:healing_junior/apps/resting.dart';
import 'package:healing_junior/apps/setting.dart';
import 'package:healing_junior/apps/staff.dart';
import 'package:healing_junior/apps/steps.dart';
import 'package:healing_junior/apps/trend.dart';
import 'package:healing_junior/apps/waves.dart';
import 'package:healing_junior/apps/welcome.dart';
import 'package:healing_junior/apps/wuluohai.dart';
import 'package:healing_junior/ctrl.dart';

Color colorSurface = const Color.fromARGB(255, 188, 166, 244);
Color colorPrimary = const Color.fromARGB(255, 222, 222, 222);
Color colorPrimaryContainer = const Color.fromARGB(255, 33, 33, 33);
Color colorSecondary = Colors.white;
Color colorSecondaryContainer = Colors.black;
Color colorError = Colors.purple;
List<Color> colors5 = [
  Color.fromARGB(255, 255, 200, 0),
  Colors.green,
  Colors.blue,
  Colors.deepPurpleAccent,
  Colors.purple,
];

class MyView extends GetView<MyCtrl> {
  MyView({super.key});
  final settingCtrl = Get.put(SettingCtrl());
  final employeeCtrl = Get.put(EmployeeCtrl());
  final welcomeCtrl = Get.put(WelcomeCtrl());
  final customerCtrl = Get.put(CustomerCtrl());
  final wavesCtrl = Get.put(WavesCtrl());

  @override
  final MyCtrl controller = Get.put(MyCtrl());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          elevation: 1,
          toolbarHeight: 64,
          leadingWidth: 64,
          title: Obx(() => MyTextH2(
              "${welcomeCtrl.app} ${customerCtrl.isRecording.value ? '检测中……' : ''}${customerCtrl.isRecording.value ? controller.pureCount.value : ''}")),
          // leading: Row(
          //   children: [
          //     Obx(() => CircularIconButton(
          //           icon: controller.isConnect.value ? Icons.bluetooth_audio_rounded : Icons.bluetooth_disabled_rounded,
          //           onPressed: () {
          //             showModalBottomSheet(
          //               context: context,
          //               showDragHandle: true,
          //               useRootNavigator: true,
          //               isScrollControlled: true,
          //               useSafeArea: true,
          //               constraints: BoxConstraints(
          //                 maxHeight: MediaQuery.of(context).size.height - 64,
          //               ),
          //               builder: (context) {
          //                 return BrainView();
          //               },
          //             );
          //           },
          //         )),
          //     // CircularIconButton(
          //     //   icon: Icons.auto_stories_rounded,
          //     //   onPressed: () {
          //     //     Get.to(() => ReportList());
          //     //   },
          //     // )
          //   ],
          // ),
          actions: [
            CircularIconButton(
              icon: Icons.share,
              onPressed: () {
                if (customerCtrl.nickname.value.isEmpty) {
                  Get.snackbar('提示', '请先添加服务对象');
                  return;
                }
                final timestamp = DateTime.now().millisecondsSinceEpoch;
                controller.shareReport('脑电波与情绪', timestamp);
              },
            ),
            CircularIconButton(
              icon: Icons.attach_file_rounded,
              onPressed: () {
                showModalBottomSheet(
                  context: context,
                  showDragHandle: true,
                  useRootNavigator: true,
                  isScrollControlled: true,
                  useSafeArea: true,
                  constraints: BoxConstraints(
                    maxHeight: MediaQuery.of(context).size.height * 0.8,
                  ),
                  builder: (context) {
                    return PdfListView();
                  },
                );
              },
            ),
            CircularIconButton(
              icon: Icons.person_rounded,
              onPressed: () {
                showModalBottomSheet(
                  context: context,
                  showDragHandle: true,
                  useRootNavigator: true,
                  isScrollControlled: true,
                  useSafeArea: true,
                  constraints: BoxConstraints(
                    maxHeight: MediaQuery.of(context).size.height * 0.8,
                  ),
                  builder: (context) {
                    return EmployeeView();
                  },
                );
              },
            ),
            Obx(() =>
                employeeCtrl.isRegist.value ? Text('余额${employeeCtrl.paymentBalance.value > 0 ? employeeCtrl.paymentBalance.value : "不足"}') : Text("未登录")),
            CircularIconButton(
              icon: Icons.people_rounded,
              onPressed: () {
                showModalBottomSheet(
                  context: context,
                  showDragHandle: true,
                  useRootNavigator: true,
                  isScrollControlled: true,
                  useSafeArea: true,
                  constraints: BoxConstraints(
                    maxHeight: MediaQuery.of(context).size.height * 0.8,
                  ),
                  builder: (context) {
                    return InstitutionView();
                  },
                );
              },
            ),
            // CircularIconButton(
            //   icon: Icons.adjust_rounded,
            //   onPressed: () {
            //     showLogoutDialog(context);
            //   },
            // ),
            // Builder(
            //   builder: (context) => CircularIconButton(
            //     icon: Icons.settings_rounded,
            //     onPressed: () {
            //       Scaffold.of(context).openEndDrawer(); // 现在 context 是正确的
            //     },
            //   ),
            // ),
          ]),
      // drawer: Drawer(
      //   child: SettingView(),
      // ),
      // endDrawer: Drawer(
      //   child: SettingView(),
      // ),
      body: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            spacing: 10,
            children: <Widget>[
              WelcomeView(),
              ExpansionTile(
                leading: Icon(Icons.view_list_rounded),
                expandedCrossAxisAlignment: CrossAxisAlignment.start,
                collapsedShape: Border(top: BorderSide(color: colorSurface)),
                shape: Border(top: BorderSide(color: colorSurface)),
                title: MyTextP1("操作流程"),
                subtitle: MyTextP3("步骤和注意事项", colorPrimaryContainer),
                children: [
                  StepsView(),
                ],
              ),
              ExpansionTile(
                leading: Icon(Icons.directions_run_rounded),
                expandedCrossAxisAlignment: CrossAxisAlignment.start,
                collapsedShape: Border(top: BorderSide(color: colorSurface)),
                shape: Border(top: BorderSide(color: colorSurface)),
                title: MyTextP1("服务对象"),
                subtitle: MyTextP3("选择服务对象( 请先确认管理员在后台已提前录入该顾客信息! )", colorPrimaryContainer),
                children: [
                  CustomerView(),
                ],
              ),
              Visibility(
                  visible: settingCtrl.states[0],
                  child: RepaintBoundary(
                      key: controller.expansionKeys[0],
                      child: ExpansionTile(
                        initiallyExpanded: true,
                        leading: Icon(Icons.waves_rounded),
                        expandedCrossAxisAlignment: CrossAxisAlignment.start,
                        collapsedShape: Border(top: BorderSide(color: colorSurface)),
                        shape: Border(top: BorderSide(color: colorSurface)),
                        title: MyTextP1("脑电图"),
                        subtitle: MyTextP3("原始数据图", colorPrimaryContainer),
                        children: [
                          Obx(() => SwitchListTile(
                                title: const Text(""),
                                value: wavesCtrl.isFlay.value,
                                onChanged: (value) async {
                                  wavesCtrl.isFlay.value = value;
                                },
                              )),
                          WavesView(),
                          WavesButtons(),
                        ],
                      ))),
              Visibility(
                visible: settingCtrl.states[1],
                child: RepaintBoundary(
                  key: controller.expansionKeys[1],
                  child: ExpansionTile(
                    leading: Icon(Icons.network_ping_rounded),
                    collapsedShape: Border(top: BorderSide(color: colorSurface)),
                    shape: Border(top: BorderSide(color: colorSurface)),
                    title: MyTextP1("基线"),
                    subtitle: MyTextP3("与基线数据实时对比的各项指标", colorPrimaryContainer),
                    children: [BaselineView(), const SizedBox(height: 20), Divider(height: 1), const SizedBox(height: 20), ReaaltimeView()],
                  ),
                ),
              ),
              Visibility(
                visible: settingCtrl.states[2],
                child: RepaintBoundary(
                  key: controller.expansionKeys[2],
                  child: ExpansionTile(
                    leading: Icon(Icons.multitrack_audio_rounded),
                    collapsedShape: Border(top: BorderSide(color: colorSurface)),
                    shape: Border(top: BorderSide(color: colorSurface)),
                    title: MyTextP1("脑波 - δ、θ、α、β、γ"),
                    subtitle: MyTextP3("脑波能耗分布的动态变化实时跟踪", colorPrimaryContainer),
                    children: [
                      BciView(),
                    ],
                  ),
                ),
              ),
              Visibility(
                visible: settingCtrl.states[3],
                child: RepaintBoundary(
                  key: controller.expansionKeys[3],
                  child: ExpansionTile(
                    leading: Icon(Icons.query_stats_rounded),
                    collapsedShape: Border(top: BorderSide(color: colorSurface)),
                    shape: Border(top: BorderSide(color: colorSurface)),
                    title: MyTextP1("α波"),
                    subtitle: MyTextP3("Alpha波的能量在全部脑波能耗中占比的动态变化", colorPrimaryContainer),
                    children: [
                      AlphaView(),
                    ],
                  ),
                ),
              ),
              Visibility(
                visible: settingCtrl.states[4],
                child: RepaintBoundary(
                  key: controller.expansionKeys[4],
                  child: ExpansionTile(
                    leading: Icon(Icons.query_stats_rounded),
                    collapsedShape: Border(top: BorderSide(color: colorSurface)),
                    shape: Border(top: BorderSide(color: colorSurface)),
                    title: MyTextP1("β波"),
                    subtitle: MyTextP3("Beta波的能量在全部脑波能耗中占比的动态变化", colorPrimaryContainer),
                    children: [
                      BetaView(),
                      // Obx(() => HealingValue(
                      //     lowBetaBase: controller.lowBetaBase.value,
                      //     lowBetaMin: controller.lowBetaMin.value,
                      //     highBetaBase: controller.highBetaBase.value,
                      //     highBetaMin: controller.highBetaMin.value)),
                      // const SizedBox(height: 40),
                      // Obx(
                      //   () => EmoValue(data: [
                      //     controller.emoV1.value,
                      //     controller.emoV2.value,
                      //     controller.emoV3.value,
                      //     controller.emoV4.value,
                      //     controller.emoV5.value,
                      //     controller.emoV6.value,
                      //     controller.emoV7.value,
                      //     controller.emoV8.value,
                      //     controller.emoV9.value,
                      //     controller.emoV10.value,
                      //     controller.emoV11.value,
                      //     controller.emoV12.value,
                      //     controller.emoV13.value,
                      //     controller.emoV14.value,
                      //     controller.emoV15.value,
                      //     controller.emoV16.value
                      //   ]),
                      // ),
                      // const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
              Visibility(
                visible: settingCtrl.states[5],
                child: RepaintBoundary(
                  key: controller.expansionKeys[5],
                  child: ExpansionTile(
                    leading: Icon(Icons.query_stats_rounded),
                    collapsedShape: Border(top: BorderSide(color: colorSurface)),
                    shape: Border(top: BorderSide(color: colorSurface)),
                    title: MyTextP1("α波 pk β波"),
                    subtitle: MyTextP3("α波能量占比与β波能量占比的相对变化", colorPrimaryContainer),
                    children: [
                      AlphaBetaView(),
                      // MyTextP2("灵动指数"),
                      // Obx(() => MyTextP2("${controller.sensitiveValue.value}")),
                      // Obx(() => PressureGauge(label: "感知", width: context.width / 2, value: controller.sensitiveValue.value, maxValue: 1)),
                      // const SizedBox(height: 40),
                      // MyTextP2("灵动时刻"),
                      // Obx(() => MyTextP2("第${controller.sensitivePoint.value}~${controller.sensitivePoint.value + 8}秒")),
                      // MyTextP2("最活跃脑波"),
                      // Obx(() => MyTextP2(controller.sensitiveWave.value)),
                      // const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
              Visibility(
                visible: settingCtrl.states[6],
                child: RepaintBoundary(
                  key: controller.expansionKeys[6],
                  child: ExpansionTile(
                    leading: Icon(Icons.query_stats_rounded),
                    collapsedShape: Border(top: BorderSide(color: colorSurface)),
                    shape: Border(top: BorderSide(color: colorSurface)),
                    title: MyTextP1("γ波"),
                    subtitle: MyTextP3("γ波的能量在全部脑波能耗中占比的动态变化", colorPrimaryContainer),
                    children: [
                      GammaView(),
                    ],
                  ),
                ),
              ),
              Visibility(
                visible: settingCtrl.states[7],
                child: RepaintBoundary(
                  key: controller.expansionKeys[7],
                  child: ExpansionTile(
                    leading: Icon(Icons.query_stats_rounded),
                    collapsedShape: Border(top: BorderSide(color: colorSurface)),
                    shape: Border(top: BorderSide(color: colorSurface)),
                    title: MyTextP1("γ波 pk β波"),
                    subtitle: MyTextP3("γ波能量占比与β波能量占比的相对变化", colorPrimaryContainer),
                    children: [
                      GammaBetaView(),
                    ],
                  ),
                ),
              ),
              Visibility(
                visible: settingCtrl.states[8],
                child: RepaintBoundary(
                  key: controller.expansionKeys[8],
                  child: ExpansionTile(
                    leading: Icon(Icons.monitor_heart_rounded),
                    collapsedShape: Border(top: BorderSide(color: colorSurface)),
                    shape: Border(top: BorderSide(color: colorSurface)),
                    title: MyTextP1("心率 & HRV"),
                    subtitle: MyTextP3("心率与心率变异性的的动态变化", colorPrimaryContainer),
                    children: [
                      HeartRateView(),
                      const SizedBox(height: 20),
                      Divider(height: 1),
                      const SizedBox(height: 20),
                      HrvView(),
                      // MyTextP2("压力指数"),
                      // Obx(() => MyTextP2("${controller.pressValue.value}")),
                      // Obx(() => PressureGauge(label: "_", width: context.width / 2, value: controller.pressValue.value, maxValue: 1)),
                      // const SizedBox(height: 20),
                      // MyTextP2("（持续跟踪）"),
                      // const SizedBox(height: 80),
                      // MyTextP2("疏压表现"),
                      // MyTextP3("（测完后显示）", colorPrimary),
                      // Row(
                      //   mainAxisAlignment: MainAxisAlignment.spaceAround,
                      //   children: [
                      //     MyTextP2("压力指数"),
                      //     MyTextP2("压力指数"),
                      //   ],
                      // ),
                      // Row(
                      //   mainAxisAlignment: MainAxisAlignment.spaceAround,
                      //   children: [
                      //     Obx(() => MyTextP2("${controller.leftPressValue.value}")),
                      //     Obx(() => MyTextP2("${controller.rightPressValue.value}")),
                      //   ],
                      // ),
                      // Row(
                      //   mainAxisAlignment: MainAxisAlignment.spaceAround,
                      //   children: [
                      //     Obx(() => PressureGauge(label: "静息前1分钟", width: context.width / 3, value: (controller.leftPressValue.value).abs(), maxValue: 1)),
                      //     Obx(() => PressureGauge(label: "静息后1分钟", width: context.width / 3, value: (controller.rightPressValue.value).abs(), maxValue: 1)),
                      //   ],
                      // ),
                      // const SizedBox(height: 80),
                      // MyTextP2("疏压模式"),
                      // MyTextP3("（测完后显示）", colorPrimary),
                      // Row(
                      //   mainAxisAlignment: MainAxisAlignment.spaceAround,
                      //   children: [
                      //     MyTextP2("低Beta波"),
                      //     MyTextP2("高Beta波"),
                      //   ],
                      // ),
                      // Row(
                      //   mainAxisAlignment: MainAxisAlignment.spaceAround,
                      //   children: [
                      //     Obx(() => MyTextP2("显著度${controller.lowBetaSign.value}")),
                      //     Obx(() => MyTextP2("显著度${controller.highBetaSign.value}")),
                      //   ],
                      // ),
                      // Row(
                      //   mainAxisAlignment: MainAxisAlignment.spaceAround,
                      //   children: [
                      //     Obx(() => PressureGauge(
                      //         label: controller.lowBetaTrend.value == 1
                      //             ? "升"
                      //             : controller.lowBetaTrend.value == -1
                      //                 ? "降✔"
                      //                 : "_",
                      //         width: context.width / 3,
                      //         value: (controller.lowBetaSign.value).abs(),
                      //         maxValue: 1)),
                      //     Obx(() => PressureGauge(
                      //         label: controller.highBetaTrend.value == 1
                      //             ? "升"
                      //             : controller.highBetaTrend.value == -1
                      //                 ? "降✔"
                      //                 : "_",
                      //         width: context.width / 3,
                      //         value: (controller.highBetaSign.value).abs(),
                      //         maxValue: 1)),
                      //   ],
                      // ),
                      // const SizedBox(height: 20),
                      // Row(
                      //   mainAxisAlignment: MainAxisAlignment.spaceAround,
                      //   children: [
                      //     MyTextP2("与紧张焦虑相关"),
                      //     MyTextP2("与烦恼厌恶相关"),
                      //   ],
                      // ),
                      // const SizedBox(height: 40),
                      // Row(
                      //   mainAxisAlignment: MainAxisAlignment.spaceAround,
                      //   children: [
                      //     MyTextP2("低Alpha波"),
                      //     MyTextP2("高Alpha波"),
                      //   ],
                      // ),
                      // Row(
                      //   mainAxisAlignment: MainAxisAlignment.spaceAround,
                      //   children: [
                      //     Obx(() => MyTextP2("显著度${controller.lowAlphaSign.value}")),
                      //     Obx(() => MyTextP2("显著度${controller.highAlphaSign.value}")),
                      //   ],
                      // ),
                      // Row(
                      //   mainAxisAlignment: MainAxisAlignment.spaceAround,
                      //   children: [
                      //     Obx(() => PressureGauge(
                      //         label: controller.lowAlphaTrend.value == 1
                      //             ? "升✔"
                      //             : controller.lowAlphaTrend.value == -1
                      //                 ? "降"
                      //                 : "_",
                      //         width: context.width / 3,
                      //         value: (controller.lowAlphaSign.value).abs(),
                      //         maxValue: 1)),
                      //     Obx(() => PressureGauge(
                      //         label: controller.highAlphaTrend.value == 1
                      //             ? "升✔"
                      //             : controller.highAlphaTrend.value == -1
                      //                 ? "降"
                      //                 : "_",
                      //         width: context.width / 3,
                      //         value: (controller.highAlphaSign.value).abs(),
                      //         maxValue: 1)),
                      //   ],
                      // ),
                      // const SizedBox(height: 20),
                      // Row(
                      //   mainAxisAlignment: MainAxisAlignment.spaceAround,
                      //   children: [
                      //     MyTextP2("与兴奋快乐相关"),
                      //     MyTextP2("与镇定放松相关"),
                      //   ],
                      // ),
                      // const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
              Visibility(
                visible: settingCtrl.states[9],
                child: RepaintBoundary(
                  key: controller.expansionKeys[9],
                  child: ExpansionTile(
                    leading: Icon(Icons.restore_rounded),
                    collapsedShape: Border(top: BorderSide(color: colorSurface)),
                    shape: Border(top: BorderSide(color: colorSurface)),
                    title: MyTextP1("静息率"),
                    subtitle: MyTextP3("整个检测过程中情绪稳定呼吸平稳的时间比例", colorPrimaryContainer),
                    children: [
                      RestingView(),
                    ],
                  ),
                ),
              ),
              Visibility(
                visible: settingCtrl.states[10],
                child: RepaintBoundary(
                  key: controller.expansionKeys[10],
                  child: ExpansionTile(
                    leading: Icon(Icons.timelapse_rounded),
                    collapsedShape: Border(top: BorderSide(color: colorSurface)),
                    shape: Border(top: BorderSide(color: colorSurface)),
                    title: MyTextP1("大脑负载"),
                    subtitle: MyTextP3("整个检测过程中脑波能耗的末段均值与历史最高值之比", colorPrimaryContainer),
                    children: [
                      BrainLoadView(),
                    ],
                  ),
                ),
              ),
              Visibility(
                visible: settingCtrl.states[11],
                child: RepaintBoundary(
                  key: controller.expansionKeys[11],
                  child: ExpansionTile(
                    leading: Icon(Icons.timelapse_rounded),
                    collapsedShape: Border(top: BorderSide(color: colorSurface)),
                    shape: Border(top: BorderSide(color: colorSurface)),
                    title: MyTextP1("压力指数"),
                    subtitle: MyTextP3("基于脑波活跃度的心理压力 & 基于LF/HF的心脏压力", colorPrimaryContainer),
                    children: [
                      PressureView(),
                    ],
                  ),
                ),
              ),
              Visibility(
                visible: settingCtrl.states[12],
                child: RepaintBoundary(
                  key: controller.expansionKeys[12],
                  child: ExpansionTile(
                    leading: Icon(Icons.restore_rounded),
                    collapsedShape: Border(top: BorderSide(color: colorSurface)),
                    shape: Border(top: BorderSide(color: colorSurface)),
                    title: MyTextP1("情绪跟踪"),
                    subtitle: MyTextP3("基于脑波变化趋势相干性的情绪发现与计数", colorPrimaryContainer),
                    children: [
                      TrendView(),
                    ],
                  ),
                ),
              ),
              Visibility(
                visible: settingCtrl.states[13],
                child: RepaintBoundary(
                  key: controller.expansionKeys[13],
                  child: ExpansionTile(
                    leading: Icon(Icons.color_lens_rounded),
                    collapsedShape: Border(top: BorderSide(color: colorSurface)),
                    shape: Border(top: BorderSide(color: colorSurface)),
                    title: MyTextP1("脑波作画"),
                    subtitle: MyTextP3("让AI用图像色彩尝试表达当下心境", colorPrimaryContainer),
                    children: [
                      DrawView(),
                    ],
                  ),
                ),
              ),
              Visibility(
                visible: settingCtrl.states[14],
                child: RepaintBoundary(
                  key: controller.expansionKeys[14],
                  child: ExpansionTile(
                    leading: Icon(Icons.music_note_rounded),
                    collapsedShape: Border(top: BorderSide(color: colorSurface)),
                    shape: Border(top: BorderSide(color: colorSurface)),
                    title: MyTextP1("疗愈音乐"),
                    subtitle: MyTextP3("非遗古乐推荐，情绪八音盒", colorPrimaryContainer),
                    children: [
                      const SizedBox(height: 40),
                      MyTextP2("非遗古乐推荐"),
                      MyTextP2("（心布洛）"),
                      const SizedBox(height: 20),
                      WuluohaiView(),
                      Image.asset("assets/images/wuluohai.png", width: 150, height: 100),
                      const SizedBox(height: 20),
                      MyTextP2("心布洛是全球非遗活态传承平台，立足中国，服务全球"),
                      MyTextP2("用“非遗古乐+数字科技”为大众情绪健康保驾护航"),
                      MyTextP2("以人类共同体的使命传播中华民族非遗文化，弘扬世界和谐之乐"),
                      const SizedBox(height: 80),
                      StaffView(),
                    ],
                  ),
                ),
              ),

              // RepaintBoundary(
              //   key: controller.expansionKeys[8],
              //   child: ExpansionTile(
              //     leading: Icon(Icons.palette_rounded),
              //     title: MyTextH2("色彩疗愈"),
              //     subtitle: MyTextP2("脑波光环、AI脑波曼陀罗、AI情绪绘画"),
              //     children: [
              //       const SizedBox(height: 40),
              //       MyTextP2("脑波光环"),
              //       Obx(() => HaloView(sideLength: context.width, diameter8: [
              //             context.width * 0.6,
              //             controller.haloLowGamma.value * context.width * 0.6,
              //             controller.haloHighBeta.value * context.width * 0.6,
              //             controller.haloLowBeta.value * context.width * 0.6,
              //             controller.haloHighAlpha.value * context.width * 0.6,
              //             controller.haloLowAlpha.value * context.width * 0.6,
              //             controller.haloTheta.value * context.width * 0.6,
              //             controller.haloDelta.value * context.width * 0.6,
              //           ])),
              //       MyTextP2("从里到外分别代表${brainWaves8CN.join("、")}"),
              //       const SizedBox(height: 20),
              //       Obx(() => MyTextP2(controller.aiMandalaPrompt.value)),
              //       const SizedBox(height: 20),
              //       MyTextP2("情绪扫描 + AI七彩曼陀罗"),
              //       const SizedBox(height: 20),
              //       Obx(() => controller.pureCount.value >= 128
              //           ? IconButton.filled(
              //               onPressed: () => controller.drawMandala(),
              //               icon: controller.isGettingAiMandalaImage.value
              //                   ? CircularProgressIndicator(
              //                       color: colorSurface,
              //                       strokeWidth: 2,
              //                     )
              //                   : Icon(Icons.camera),
              //               iconSize: 40)
              //           : SizedBox.shrink()),
              //       Obx(() => controller.aiMandalaImageUrl.value != ""
              //           ? DrawView(sideLength: context.width, fileUrl: controller.aiMandalaImageUrl)
              //           : SizedBox.shrink()),
              //       Obx(() => controller.aiMandalaImageUrl.value != ""
              //           ? IconButton.filled(
              //               onPressed: () => controller.analysisMandala(),
              //               icon: controller.isAnalysisMandalaImage.value
              //                   ? CircularProgressIndicator(
              //                       color: colorSurface,
              //                       strokeWidth: 2,
              //                     )
              //                   : Icon(Icons.view_in_ar_rounded),
              //               iconSize: 40)
              //           : SizedBox.shrink()),
              //       Obx(() => controller.analysisMandalaImageText.value.isNotEmpty
              //           ? Container(
              //               margin: EdgeInsets.all(20),
              //               child: MarkdownBody(
              //                 data: controller.analysisMandalaImageText.value,
              //                 styleSheet: MarkdownStyleSheet(
              //                   h1: TextStyle(fontSize: 24, color: colorSecondary, fontWeight: FontWeight.bold),
              //                   h2: TextStyle(fontSize: 20, color: colorSecondary, fontWeight: FontWeight.bold),
              //                   h3: TextStyle(fontSize: 18, color: colorSecondary, fontWeight: FontWeight.bold),
              //                   p: TextStyle(fontSize: 16, color: colorSecondary),
              //                 ),
              //               ),
              //             )
              //           : SizedBox.shrink()),
              //       const SizedBox(height: 80),
              //       MyTextP2("情绪扫描 + AI情绪画作"),
              //       const SizedBox(height: 20),
              //       Obx(() => controller.pureCount.value >= 128
              //           ? IconButton.filled(
              //               onPressed: () => controller.drawDream(),
              //               icon: controller.isGettingAiDreanImage.value
              //                   ? CircularProgressIndicator(
              //                       color: colorSurface,
              //                       strokeWidth: 2,
              //                     )
              //                   : Icon(Icons.camera),
              //               iconSize: 40)
              //           : SizedBox.shrink()),
              //       Obx(() =>
              //           controller.aiDreanImageUrl.value != "" ? DrawView(sideLength: context.width, fileUrl: controller.aiDreanImageUrl) : SizedBox.shrink()),
              //       Obx(() => controller.aiDreanImageUrl.value != ""
              //           ? IconButton.filled(
              //               onPressed: () => controller.analysisDream(),
              //               icon: controller.isAnalysisDreanImage.value
              //                   ? CircularProgressIndicator(
              //                       color: colorSurface,
              //                       strokeWidth: 2,
              //                     )
              //                   : Icon(Icons.view_in_ar_rounded),
              //               iconSize: 40)
              //           : SizedBox.shrink()),
              //       Obx(() => controller.analysisDreanImageText.value.isNotEmpty
              //           ? Container(
              //               margin: EdgeInsets.all(20),
              //               child: MarkdownBody(
              //                 data: controller.analysisDreanImageText.value,
              //                 styleSheet: MarkdownStyleSheet(
              //                   h1: TextStyle(fontSize: 24, color: colorSecondary, fontWeight: FontWeight.bold),
              //                   h2: TextStyle(fontSize: 20, color: colorSecondary, fontWeight: FontWeight.bold),
              //                   h3: TextStyle(fontSize: 18, color: colorSecondary, fontWeight: FontWeight.bold),
              //                   p: TextStyle(fontSize: 16, color: colorSecondary),
              //                 ),
              //               ),
              //             )
              //           : SizedBox.shrink()),
              //       const SizedBox(height: 40),
              //     ],
              //   ),
              // ),

              // RepaintBoundary(
              //   key: controller.expansionKeys[9],
              //   child: ExpansionTile(
              //     leading: Icon(Icons.coronavirus_rounded),
              //     title: MyTextH2("七脉轮 - chakra"),
              //     subtitle: MyTextP2("基于脑波活跃度与易经乾卦的七脉轮表示法"),
              //     children: [
              //       const SizedBox(height: 40),
              //       Obx(() => MyTextH2("地心轮 ${controller.chakra0Delta.value.toStringAsFixed(2)} ${Data.qian(controller.chakra0Delta.value)}")),
              //       MyTextP2("（δ波活跃度）"),
              //       const SizedBox(height: 20),
              //       Obx(() => ChakraView(
              //             width: context.width,
              //             chakraValues: [
              //               controller.chakra7MiddleGamma.value,
              //               controller.chakra6LowGamma.value,
              //               controller.chakra5HighBeta.value,
              //               controller.chakra4LowBeta.value,
              //               controller.chakra3HighAlpha.value,
              //               controller.chakra2LowAlpha.value,
              //               controller.chakra1Theta.value,
              //             ],
              //           )),
              //       const SizedBox(height: 20),
              //       Table(
              //         defaultVerticalAlignment: TableCellVerticalAlignment.middle,
              //         columnWidths: {0: FixedColumnWidth(90), 1: FixedColumnWidth(50), 2: FixedColumnWidth(240)},
              //         border: TableBorder.all(color: colorSecondary, width: 1, borderRadius: BorderRadius.circular(5)),
              //         children: [
              //           TableRow(decoration: BoxDecoration(color: colorSecondaryContainer), children: [
              //             MyTextP2("  活跃度范围"),
              //             MyTextP2("  六爻"),
              //             MyTextP2("  乾卦卦辞 - 状态"),
              //           ]),
              //           TableRow(children: [
              //             MyTextP2("  2.5 ~ ···"),
              //             MyTextP2("  上九"),
              //             MyTextP2("  亢龙有悔"),
              //           ]),
              //           TableRow(children: [
              //             MyTextP2("  2.0 ~ 2.5"),
              //             MyTextP2("  九五"),
              //             MyTextP2("  飞龙在天，利见大人"),
              //           ]),
              //           TableRow(children: [
              //             MyTextP2("  1.5 ~ 2.0"),
              //             MyTextP2("  九四"),
              //             MyTextP2("  或跃在渊，无咎"),
              //           ]),
              //           TableRow(children: [
              //             MyTextP2("  1.0 ~ 1.5"),
              //             MyTextP2("  九三"),
              //             MyTextP2("  君子终日乾乾，夕惕若厉，无咎"),
              //           ]),
              //           TableRow(children: [
              //             MyTextP2("  0.5 ~ 1.0"),
              //             MyTextP2("  九二"),
              //             MyTextP2("  见龙在田，利见大人"),
              //           ]),
              //           TableRow(children: [
              //             MyTextP2("  0.0 ~ 0.5"),
              //             MyTextP2("  初九"),
              //             MyTextP2("  潜龙勿用"),
              //           ]),
              //         ],
              //       ),
              //       const SizedBox(height: 40),
              //     ],
              //   ),
              // ),

              // RepaintBoundary(
              //   key: controller.expansionKeys[10],
              //   child: ExpansionTile(
              //     leading: Icon(Icons.waves_rounded),
              //     expandedCrossAxisAlignment: CrossAxisAlignment.start,
              //     title: MyTextH2("脑波详情"),
              //     subtitle: MyTextP2("用于3分钟压力测评的详细脑波数据图表"),
              //     children: [
              //       MyTextP1("1·原始脑电图"),
              //       MyTextP2("频率为1HZ的原始振幅波动分层对比图，基线由低到高逐层加1"),
              //       WavesChart(controller: controller.pureController),
              //       WavesChartButtons(controller: controller.pureController),
              //       MyTextP1("2·脑波概略图"),
              //       MyTextP2("以8条数据为一组进行分段平滑处理，基线由低到高逐层加1"),
              //       WavesChart(controller: controller.mvController),
              //       WavesChartButtons(controller: controller.mvController),
              //       MyTextP1("3·脑波概要表"),
              //       MyTextP2("将全部时间一分为二情况下的全体脑波的变化趋势显著度及活跃度对比表"),
              //       WavesTable(controller: controller.wavesTableController),
              //       const SizedBox(height: 20),
              //       MyTextP1("4·趋势分布图"),
              //       MyTextP2("将全部时间分为16等份情况下的变化趋势方向对比图，基线为0，1为升，-1为降"),
              //       WavesChart(controller: controller.trendController),
              //       WavesChartButtons(controller: controller.trendController),
              //       MyTextP1("5·显著度分布图"),
              //       MyTextP2("基于上述分段法的变化趋势及其显著度对比图，基线为0，离基线越远越显著"),
              //       WavesChart(controller: controller.signController),
              //       WavesChartButtons(controller: controller.signController),
              //       MyTextP1("6·活跃度分布图"),
              //       MyTextP2("基于上述分段法的变化活跃度对比图，基线为0，基线之上越远越活跃"),
              //       WavesChart(controller: controller.activityController),
              //       WavesChartButtons(controller: controller.activityController),
              //       const SizedBox(height: 20),
              //       MyTextP1("7·脑波特征分析"),
              //       MyTextP2("主导压力的β波：LowBeta波 & HighBeta波"),
              //       Obx(() => MyTextP2("LowBeta的整体变化趋势 ${controller.baseLowBetaTrend.value == 1 ? "升" : "降✔"}")),
              //       Obx(() => MyTextP2("LowBeta的整体显著度 ${controller.baseLowBetaSign.value}%")),
              //       Obx(() => MyTextP2("LowBeta的整体活跃度 ${controller.baseLowBetaActivity.value}%")),
              //       BetaTable(controller: controller.lowBetaTableController),
              //       Obx(() => MyTextP2("LowBeta呈现显著降低趋势的时段数${controller.baseLowBetaTimes.value}/16，占比${controller.baseLowBetaRate.value}%")),
              //       Obx(() => MyTextP2("与LowBeta的显著降低时段相干次数最多的波 ${controller.baseLowBetaQueenName.value}")),
              //       Obx(() => MyTextP2(
              //           "${controller.baseLowBetaQueenName.value}与LowBeta的相干次数 ${controller.baseLowBetaQueenTimes.value}/${controller.baseLowBetaTimes.value}，占比 ${controller.baseLowBetaQueenPercent.value}%")),
              //       Obx(() => MyTextP2("${controller.baseLowBetaQueenName.value}的整体活跃度 ${controller.baseLowBetaQueenActivity.value}%")),
              //       Obx(() => MyTextP2("${controller.baseLowBetaQueenName.value}参与疗愈的显著度峰值 ${controller.baseLowBetaQueenSignTop.value}%")),
              //       Obx(() => MyTextP2(
              //           "${controller.baseLowBetaQueenName.value}参与疗愈的显著度峰值时段点位 ${controller.baseLowBetaQueenSignTopPoint.value}，时延率${controller.baseLowBetaQueenSignTopPercent.value}%")),
              //       Obx(() => MyTextP2("${controller.baseLowBetaQueenName.value}参与疗愈的显著度峰值时段的能量盈亏率 ${controller.baseLowBetaQueenSignTopMv.value}%")),
              //       Obx(() => MyTextP2("${controller.baseLowBetaQueenName.value}参与疗愈的活跃度峰值 ${controller.baseLowBetaQueenActivityTop.value}%")),
              //       Obx(() => MyTextP2(
              //           "${controller.baseLowBetaQueenName.value}参与疗愈的活跃度峰值时段点位 ${controller.baseLowBetaQueenActivityTopPoint.value}，时延率${controller.baseLowBetaQueenActivityTopPercent.value}%")),
              //       Obx(() => MyTextP2("${controller.baseLowBetaQueenName.value}参与疗愈的活跃度峰值时段的能量盈亏率 ${controller.baseLowBetaQueenActivityTopMv.value}%")),
              //       const Divider(height: 20),
              //       Obx(() => MyTextP2("HighBeta的整体变化趋势 ${controller.baseHighBetaTrend.value == 1 ? "升" : "降✔"}")),
              //       Obx(() => MyTextP2("HighBeta的整体显著度 ${controller.baseHighBetaSign.value}%")),
              //       Obx(() => MyTextP2("HighBeta的整体活跃度 ${controller.baseHighBetaActivity.value}%")),
              //       BetaTable(controller: controller.highBetaTableController),
              //       Obx(() => MyTextP2("HighBeta呈现显著降低趋势的时段数${controller.baseHighBetaTimes.value}/16，占比${controller.baseHighBetaRate.value}%")),
              //       Obx(() => MyTextP2("与HighBeta的显著降低时段相干次数最多的波 ${controller.baseHighBetaQueenName.value}")),
              //       Obx(() => MyTextP2(
              //           "${controller.baseHighBetaQueenName.value}与HighBeta的相干次数 ${controller.baseHighBetaQueenTimes.value}/${controller.baseHighBetaTimes.value}，占比 ${controller.baseHighBetaQueenPercent.value}%")),
              //       Obx(() => MyTextP2("${controller.baseHighBetaQueenName.value}的整体活跃度 ${controller.baseHighBetaQueenActivity.value}%")),
              //       Obx(() => MyTextP2("${controller.baseHighBetaQueenName.value}参与疗愈的显著度峰值 ${controller.baseHighBetaQueenSignTop.value}%")),
              //       Obx(() => MyTextP2(
              //           "${controller.baseHighBetaQueenName.value}参与疗愈的显著度峰值时段点位 ${controller.baseHighBetaQueenSignTopPoint.value}，时延率${controller.baseHighBetaQueenSignTopPercent.value}%")),
              //       Obx(() => MyTextP2("${controller.baseHighBetaQueenName.value}参与疗愈的显著度峰值时段的能量盈亏率 ${controller.baseHighBetaQueenSignTopMv.value}%")),
              //       Obx(() => MyTextP2("${controller.baseHighBetaQueenName.value}参与疗愈的活跃度峰值 ${controller.baseHighBetaQueenActivityTop.value}%")),
              //       Obx(() => MyTextP2(
              //           "${controller.baseHighBetaQueenName.value}参与疗愈的活跃度峰值时段点位 ${controller.baseHighBetaQueenActivityTopPoint.value}，时延率${controller.baseHighBetaQueenActivityTopPercent.value}%")),
              //       Obx(() => MyTextP2("${controller.baseHighBetaQueenName.value}参与疗愈的活跃度峰值时段的能量盈亏率 ${controller.baseHighBetaQueenActivityTopMv.value}%")),
              //       const Divider(height: 20),
              //       MyTextP1("8·由 β波降低呈现的自愈积极性（主）"),
              //       Obx(() => MyTextP1("1·低β波呈现显著降低趋势的时段${controller.baseLowBetaTimes.value}/16，占比${controller.baseLowBetaRate.value}%")),
              //       Obx(() => MyTextP1("2·高β波呈现显著降低趋势的时段${controller.baseHighBetaTimes.value}/16，占比${controller.baseHighBetaRate.value}%")),
              //       MyTextP2("- 上述比值揭示了闭眼静息状态下大脑自动开启自我修复的积极性"),
              //       MyTextP2("- 大于50%为积极，低于25%为不积极"),
              //       const Divider(height: 20),
              //       MyTextP1("9·其它脑电波呈现的参与积极性（从）"),
              //       Obx(() => MyTextP2(
              //           "1.1·δ波积极参与低β波调节的机会时段${controller.baseLowBetaTimesDelta.value}/${controller.baseLowBetaTimes.value}，占比${controller.baseLowBetaRateDelta.value}%")),
              //       Obx(() => MyTextP2(
              //           "1.2·δ波积极参与高β波调节的机会时段${controller.baseHighBetaTimesDelta.value}/${controller.baseHighBetaTimes.value}，占比${controller.baseHighBetaRateDelta.value}%")),
              //       MyTextP2("- δ波的显著升高可能与获得触觉安抚/深度睡眠有关"),
              //       const SizedBox(height: 10),
              //       Obx(() => MyTextP2(
              //           "2.1·θ波积极参与低β波调节的机会时段${controller.baseLowBetaTimesTheta.value}/${controller.baseLowBetaTimes.value}，占比${controller.baseLowBetaRateTheta.value}%")),
              //       Obx(() => MyTextP2(
              //           "2.2·θ波积极参与高β波调节的机会时段${controller.baseHighBetaTimesTheta.value}/${controller.baseHighBetaTimes.value}，占比${controller.baseHighBetaRateTheta.value}%")),
              //       MyTextP2("- θ波的显著升高可能与获得味觉安抚/消化食物/打盹小憩有关"),
              //       const SizedBox(height: 10),
              //       Obx(() => MyTextP2(
              //           "3.1·低α波积极参与低β波调节的机会时段${controller.baseLowBetaTimesLowAlpha.value}/${controller.baseLowBetaTimes.value}，占比${controller.baseLowBetaRateLowAlpha.value}%")),
              //       Obx(() => MyTextP2(
              //           "3.2·低α波积极参与高β波调节的机会时段${controller.baseHighBetaTimesLowAlpha.value}/${controller.baseHighBetaTimes.value}，占比${controller.baseHighBetaRateLowAlpha.value}%")),
              //       MyTextP2("- 低α波的显著升高可能与获得嗅觉安抚有关（如香氛疗愈）"),
              //       const SizedBox(height: 10),
              //       Obx(() => MyTextP2(
              //           "4.1·高α波积极参与低β波调节的机会时段${controller.baseLowBetaTimesHighAlpha.value}/${controller.baseLowBetaTimes.value}，占比${controller.baseLowBetaRateHighAlpha.value}%")),
              //       Obx(() => MyTextP2(
              //           "4.2·高α波积极参与高β波调节的机会时段${controller.baseHighBetaTimesHighAlpha.value}/${controller.baseHighBetaTimes.value}，占比${controller.baseHighBetaRateHighAlpha.value}%")),
              //       MyTextP2("- 高α波的显著升高可能与获得听觉安抚有关（如音乐疗愈）"),
              //       const SizedBox(height: 10),
              //       Obx(() => MyTextP2(
              //           "5.1·低γ波积极参与低β波调节的机会时段${controller.baseLowBetaTimesLowGamma.value}/${controller.baseLowBetaTimes.value}，占比${controller.baseLowBetaRateLowGamma.value}%")),
              //       Obx(() => MyTextP2(
              //           "5.2·低γ波积极参与高β波调节的机会时段${controller.baseHighBetaTimesLowGamma.value}/${controller.baseHighBetaTimes.value}，占比${controller.baseHighBetaRateLowGamma.value}%")),
              //       MyTextP2("- 低γ波的显著升高可能与获得冥想静心有关（如身体扫描）"),
              //       const SizedBox(height: 10),
              //       Obx(() => MyTextP2(
              //           "6.1·中γ波积极参与低β波调节的机会时段${controller.baseLowBetaTimesMiddleGamma.value}/${controller.baseLowBetaTimes.value}，占比${controller.baseLowBetaRateMiddleGamma.value}%")),
              //       Obx(() => MyTextP2(
              //           "6.2·中γ波积极参与高β波调节的机会时段${controller.baseHighBetaTimesMiddleGamma.value}/${controller.baseHighBetaTimes.value}，占比${controller.baseHighBetaRateMiddleGamma.value}%")),
              //       MyTextP2("- 中γ波的显著升高可能与获得心流状态有关（如默诵诗歌）"),
              //       const Divider(height: 20),
              //       MyTextP1("10·特征分析参考图"),
              //       MyTextP2("1·低β波"),
              //       MyTextP2("1.1·时机分布"),
              //       MyTextP2("- 值为1代表该时段可能参与调节，值为0代表可能不参与调节"),
              //       WavesChart(controller: controller.trendBaseLowBetaController),
              //       WavesChartButtons(controller: controller.trendBaseLowBetaController),
              //       MyTextP2("1.2·能量效用"),
              //       MyTextP2("- LowBeta波的能量输出与各参与波在各参与时段的差异显著度"),
              //       WavesChart(controller: controller.mvBaseLowBetaController),
              //       WavesChartButtons(controller: controller.mvBaseLowBetaController),
              //       MyTextP2("1.3·显著度效用"),
              //       MyTextP2("- 各参与波在各参与时段与LowBeta波的趋势显著度绝对值之和"),
              //       WavesChart(controller: controller.signBaseLowBetaController),
              //       WavesChartButtons(controller: controller.signBaseLowBetaController),
              //       MyTextP2("1.4·活跃度效用"),
              //       MyTextP2("- 各参与波在各参与时段与LowBeta波的活跃度之和"),
              //       WavesChart(controller: controller.activityBaseLowBetaController),
              //       WavesChartButtons(controller: controller.activityBaseLowBetaController),
              //       MyTextP1("2·高β波"),
              //       MyTextP2("2.1·时机分布"),
              //       MyTextP2("- 值为1代表该时段可能参与调节，值为0代表可能不参与调节"),
              //       WavesChart(controller: controller.trendBaseHighBetaController),
              //       WavesChartButtons(controller: controller.trendBaseHighBetaController),
              //       MyTextP2("2.2·能量效用"),
              //       MyTextP2("- HighBeta波的能量输出与各参与波在各参与时段的差异显著度"),
              //       WavesChart(controller: controller.mvBaseHighBetaController),
              //       WavesChartButtons(controller: controller.mvBaseHighBetaController),
              //       MyTextP2("2.3·显著度效用"),
              //       MyTextP2("- 各参与波在各参与时段与HighBeta波的趋势显著度绝对值之和"),
              //       WavesChart(controller: controller.signBaseHighBetaController),
              //       WavesChartButtons(controller: controller.signBaseHighBetaController),
              //       MyTextP2("2.4·活跃度效用"),
              //       MyTextP2("- 各参与波在各参与时段与HighBeta波的活跃度之和"),
              //       WavesChart(controller: controller.activityBaseHighBetaController),
              //       WavesChartButtons(controller: controller.activityBaseHighBetaController),
              //     ],
              //   ),
              // ),

              RepaintBoundary(
                key: controller.expansionKeys[15],
                child: Container(
                  alignment: Alignment.center,
                  transformAlignment: Alignment.center,
                  height: 200,
                  child: MyTextP3("Copyright 2026 HealingAI", colorPrimaryContainer),
                ),
              ),
            ],
          )),
      // floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      // floatingActionButton: Opacity(
      //     opacity: 0.9, // 0-1透明度
      //     child: Container(
      //       decoration: BoxDecoration(
      //         color: Colors.grey,
      //         borderRadius: BorderRadius.circular(50),
      //         boxShadow: [
      //           BoxShadow(
      //             color: Colors.grey,
      //           ),
      //         ],
      //       ),
      //       height: 90,
      //       width: 90,
      //       child: Column(
      //         children: [
      //           Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      //             Stack(
      //               alignment: Alignment.center,
      //               children: [
      //                 CircularIconTextButton(
      //                   text: "启动检测",
      //                   icon: Icons.insights_rounded,
      //                   onPressed: () {},
      //                 ),
      //                 ElevatedButton(
      //                   style: ElevatedButton.styleFrom(
      //                     backgroundColor: Colors.transparent,
      //                     overlayColor: Colors.transparent,
      //                     shadowColor: Colors.transparent,
      //                     minimumSize: Size(90, 90),
      //                     maximumSize: Size(90, 90),
      //                     fixedSize: Size(90, 90),
      //                     shape: const CircleBorder(),
      //                     elevation: 0,
      //                   ),
      //                   onPressed: () {
      //                     if (controller.isRecording.value == false) {
      //                       if (controller.isConnect.value == false) {
      //                         ScaffoldMessenger.of(context).showSnackBar(
      //                           SnackBar(
      //                             content: Text("启动失败，请检查脑机接口设备是否连接正常"),
      //                             backgroundColor: colorError,
      //                           ),
      //                         );
      //                         return;
      //                       }
      //                       //弹出一个对话框，提示用户该操作将清除之前的数据，确认后再继续
      //                       showDialog(
      //                         context: context,
      //                         builder: (context) => AlertDialog(
      //                           title: Text("确认启动检测？"),
      //                           content: Text("将清除之前的全部数据，请谨慎操作"),
      //                           actions: [
      //                             TextButton(
      //                               onPressed: () => Navigator.pop(context),
      //                               child: Text("取消"),
      //                             ),
      //                             TextButton(
      //                               onPressed: () {
      //                                 Navigator.pop(context);
      //                                 controller.clearData();
      //                                 controller.uuid.value = const Uuid().v1();
      //                                 controller.isRecording.value = true;
      //                                 ScaffoldMessenger.of(context).showSnackBar(
      //                                   SnackBar(
      //                                     content: Text("启动检测"),
      //                                     backgroundColor: colorPrimary,
      //                                   ),
      //                                 );
      //                               },
      //                               child: Text("确认"),
      //                             ),
      //                           ],
      //                         ),
      //                       );
      //                     } else {
      //                       controller.isRecording.value = false;
      //                       ScaffoldMessenger.of(context).showSnackBar(
      //                         SnackBar(
      //                           content: Text("停止检测"),
      //                           backgroundColor: colorPrimary,
      //                         ),
      //                       );
      //                     }
      //                   },
      //                   child: Obx(() => controller.isRecording.value
      //                       ? const SizedBox(
      //                           width: 90,
      //                           height: 90,
      //                           child: CircularProgressIndicator(),
      //                         )
      //                       : const Icon(
      //                           Icons.autorenew_rounded,
      //                           color: Colors.red,
      //                           size: 45,
      //                           shadows: [
      //                             Shadow(
      //                               color: Colors.grey,
      //                               blurRadius: 1,
      //                               offset: Offset(1, 1), // 阴影方向
      //                             ),
      //                           ],
      //                         )),
      //                 ),
      //               ],
      //             ),
      //             // Obx(() => controller.pureCount.value >= 128
      //             //     ? CircularIconTextButton(
      //             //         text: "生成报告",
      //             //         icon: Icons.download_rounded,
      //             //         backgroundColor: Colors.blue,
      //             //         foregroundColor: colorSurface,
      //             //         onPressed: () {
      //             //           controller.customerNickname.value.isEmpty
      //             //               ? showEditCustomerNicknameDialog(context, callBack: () {
      //             //                   showSaveConfirmationDialog(context);
      //             //                 })
      //             //               : showSaveConfirmationDialog(context);
      //             //         },
      //             //       )
      //             //     : MyTextP2("约3分钟")),
      //             // CircularIconTextButton(
      //             //   text: "报告管理",
      //             //   icon: Icons.auto_stories_rounded,
      //             //   backgroundColor: colorSurface,
      //             //   foregroundColor: colorPrimary,
      //             //   onPressed: () {
      //             //     Get.to(() => ReportList());
      //             //   },
      //             // ),
      //           ]),
      //         ],
      //       ),
      //     )),
    );
  }

  // Future<void> showEditCustomerNicknameDialog(BuildContext context, {VoidCallback? callBack}) async {
  //   return showDialog<void>(
  //     context: context,
  //     barrierDismissible: false, // 用户必须点击按钮才能关闭对话框
  //     builder: (BuildContext context) {
  //       return AlertDialog(
  //         title: const Text('学生'),
  //         contentPadding: const EdgeInsets.all(40),
  //         content: SingleChildScrollView(
  //           child: Column(
  //             children: <Widget>[
  //               TextFormField(
  //                   initialValue: controller.customerNickname.value,
  //                   decoration: const InputDecoration(
  //                     labelText: '学号',
  //                     hintText: '请输入学号（2-32个字）',
  //                   ),
  //                   inputFormatters: [
  //                     FilteringTextInputFormatter.allow(RegExp(r'[\u4e00-\u9fa5a-zA-Z0-9]')),
  //                   ],
  //                   onChanged: (value) {
  //                     controller.customerNickname.value = value;
  //                   }),
  //               const SizedBox(height: 20),
  //               TextFormField(
  //                   initialValue: controller.customerAge.value.toString(),
  //                   decoration: const InputDecoration(
  //                     labelText: '年龄',
  //                     hintText: '请输入年龄',
  //                   ),
  //                   keyboardType: TextInputType.number,
  //                   inputFormatters: [
  //                     FilteringTextInputFormatter.digitsOnly,
  //                     LengthLimitingTextInputFormatter(3),
  //                   ],
  //                   onChanged: (value) {
  //                     controller.customerAge.value = int.parse(value);
  //                   }),
  //               const SizedBox(height: 20),
  //               Row(
  //                 children: [
  //                   Obx(() => Text("性别：${controller.customerSex.value == 0 ? '男' : '女'}")),
  //                   const SizedBox(width: 40),
  //                   MyTextP3("男", colorSecondary),
  //                   IconButton(
  //                       onPressed: () {
  //                         controller.customerSex.value = 0;
  //                       },
  //                       icon: Obx(() => Icon(
  //                             controller.customerSex.value == 0 ? Icons.check_circle_rounded : Icons.male_rounded,
  //                             color: controller.customerSex.value == 0 ? Colors.blue : Colors.purple,
  //                           ))),
  //                   const SizedBox(width: 10),
  //                   MyTextP3("女", colorSecondary),
  //                   IconButton(
  //                       onPressed: () {
  //                         controller.customerSex.value = 1;
  //                       },
  //                       icon: Obx(() => Icon(
  //                             controller.customerSex.value == 1 ? Icons.check_circle_rounded : Icons.female_rounded,
  //                             color: controller.customerSex.value == 1 ? Colors.blue : Colors.purple,
  //                           ))),
  //                 ],
  //               ),
  //             ],
  //           ),
  //         ),
  //         actions: <Widget>[
  //           TextButton(
  //             child: const Text('取消'),
  //             onPressed: () {
  //               Navigator.of(context).pop(); // 关闭对话框
  //             },
  //           ),
  //           TextButton(
  //             child: const Text('确认'),
  //             onPressed: () {
  //               int age = controller.customerAge.value;
  //               if (age < 1 || age > 100) {
  //                 controller.customerAge.value = 18;
  //               }
  //               String name = controller.customerNickname.value;
  //               if (name.length >= 2 && name.length <= 32) {
  //                 //
  //                 Navigator.of(context).pop();
  //                 callBack?.call();
  //               } else {
  //                 ScaffoldMessenger.of(context).showSnackBar(
  //                   const SnackBar(content: Text('必须在2到32个字符之间')),
  //                 );
  //                 Navigator.of(context).pop();
  //               }
  //             },
  //           ),
  //         ],
  //       );
  //     },
  //   );
  // }

  // Future<void> showSaveConfirmationDialog(BuildContext context) async {
  //   return showDialog<void>(
  //     context: context,
  //     barrierDismissible: false, // 用户必须点击按钮才能关闭对话框
  //     builder: (BuildContext context) {
  //       return AlertDialog(
  //         title: const Text('保存一份报告'),
  //         content: const SingleChildScrollView(
  //           child: ListBody(
  //             children: <Widget>[
  //               Text('您确定要执行此操作吗？'),
  //               Text('此操作不可撤销。'),
  //             ],
  //           ),
  //         ),
  //         actions: <Widget>[
  //           TextButton(
  //             child: const Text('取消'),
  //             onPressed: () {
  //               Navigator.of(context).pop(); // 关闭对话框
  //             },
  //           ),
  //           TextButton(
  //             child: const Text('确认'),
  //             onPressed: () {
  //               ///在这里执行确认后的操作
  //               String nickname = controller.customerNickname.value;
  //               if (nickname.isEmpty) {
  //                 Navigator.of(context).pop();
  //                 ScaffoldMessenger.of(context).showSnackBar(
  //                   SnackBar(
  //                     backgroundColor: colorError,
  //                     content: Text('请输入用户ID'),
  //                   ),
  //                 );
  //                 return;
  //               }
  //               int timestamp = DateTime.now().millisecondsSinceEpoch;
  //               ///
  //               double beta = Data.calculateMV(controller.bciDataLowBeta) + Data.calculateMV(controller.bciDataHighBeta);
  //               double alpha = Data.calculateMV(controller.bciDataLowAlpha) + Data.calculateMV(controller.bciDataHighAlpha);
  //               double theta = Data.calculateMV(controller.bciDataTheta);
  //               //
  //               double stressPsych = (beta / (theta + alpha) * 1000).toInt() / 1000;
  //               double stressHeart = Data.calculateLFHF(controller.hrvData)[3];
  //               int heartRate = Data.calculateMV(controller.bciDataHeartRate).toInt();
  //               ///本机存储
  //               Map<String, dynamic> report = {
  //                 "nickname": controller.customerNickname.value,
  //                 "age": controller.customerAge.value,
  //                 "sex": controller.customerSex.value,
  //                 "timestamp": timestamp.toString(),
  //                 "uuid": controller.uuid.value,
  //                 "QA": controller.customerQAIndex.value,
  //                 ///脑波数据
  //                 "bciDataDelta": controller.bciDataDelta,
  //                 "bciDataTheta": controller.bciDataTheta,
  //                 "bciDataLowAlpha": controller.bciDataLowAlpha,
  //                 "bciDataHighAlpha": controller.bciDataHighAlpha,
  //                 "bciDataLowBeta": controller.bciDataLowBeta,
  //                 "bciDataHighBeta": controller.bciDataHighBeta,
  //                 "bciDataLowGamma": controller.bciDataLowGamma,
  //                 "bciDataMiddleGamma": controller.bciDataMiddleGamma,
  //                 "bciDataTemperature": controller.bciDataTemperature,
  //                 "bciDataHeartRate": controller.bciDataHeartRate,
  //                 //
  //                 "bciDataAtt": controller.bciDataAtt,
  //                 "bciDataMed": controller.bciDataMed,
  //                 //
  //                 "bciCount": controller.bciDataDelta.length,
  //                 ///hrv数据
  //                 "hrvData": controller.hrvData,
  //                 ///心理压力值
  //                 "stressPsych": stressPsych,
  //                 ///心脏压力值
  //                 "stressHeart": stressHeart,
  //                 ///平均静息心率
  //                 "heartRate": heartRate
  //               };
  //               Data.write(report, 'report_${nickname}_${controller.uuid.value}.json');
  //               Navigator.of(context).pop(); // 关闭对话框
  //               ScaffoldMessenger.of(context).showSnackBar(
  //                 SnackBar(
  //                   backgroundColor: Colors.blue,
  //                   content: Text('保存成功'),
  //                 ),
  //               );
  //             },
  //           ),
  //         ],
  //       );
  //     },
  //   );
  // }

  Future<void> showLogoutDialog(BuildContext context) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // 用户必须点击按钮才能关闭对话框
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('退出程序'),
          content: const SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('您确定要执行此操作吗？'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('取消'),
              onPressed: () {
                Navigator.of(context).pop(); // 关闭对话框
              },
            ),
            TextButton(
              child: const Text('确认'),
              onPressed: () {
//                controller.clearData();
                Navigator.of(context).pop();
                SystemNavigator.pop(); // 退出程序
              },
            ),
          ],
        );
      },
    );
  }
}

class MyTextH1 extends Text {
  final String text;
  const MyTextH1(this.text, {super.key}) : super('');
  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 28,
        color: colorPrimaryContainer,
      ),
    );
  }
}

class MyTextH2 extends Text {
  final String text;
  const MyTextH2(this.text, {super.key}) : super('');
  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 24,
        color: colorPrimaryContainer,
      ),
    );
  }
}

class MyTextH3 extends Text {
  final String text;
  final Color? foregroundColor;
  const MyTextH3(this.text, this.foregroundColor, {super.key}) : super('');
  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 20,
        color: foregroundColor,
        fontWeight: FontWeight.bold,
      ),
      overflow: TextOverflow.ellipsis,
    );
  }
}

class MyTextP1 extends Text {
  final String text;
  const MyTextP1(this.text, {super.key}) : super('');
  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 20,
        color: colorPrimaryContainer,
      ),
    );
  }
}

class MyTextP2 extends Text {
  final String text;
  const MyTextP2(this.text, {super.key}) : super('');
  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 16,
        color: colorPrimaryContainer,
      ),
    );
  }
}

class MyTextP3 extends Text {
  final String text;
  final Color? foregroundColor;
  const MyTextP3(this.text, this.foregroundColor, {super.key}) : super('');
  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(fontSize: 12, color: foregroundColor, overflow: TextOverflow.ellipsis),
    );
  }
}

class CircularIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;
  const CircularIconButton({super.key, required this.icon, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        shape: const CircleBorder(),
        padding: const EdgeInsets.all(3),
        elevation: 3,
      ),
      child: Icon(icon, size: 20),
    );
  }
}

class CircularIconTextButton extends StatelessWidget {
  final String text;
  final IconData icon;
  final VoidCallback onPressed;
  const CircularIconTextButton({
    super.key,
    required this.text,
    required this.icon,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: colorSecondary,
        iconSize: 24,
        minimumSize: Size(64, 64),
        shape: const CircleBorder(),
        elevation: 3,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon),
          MyTextP3(text, colorPrimaryContainer),
        ],
      ),
    );
  }
}

class LineIconTextButton extends StatelessWidget {
  final String text;
  final IconData icon;
  final VoidCallback onPressed;
  final Color? backgroundColor;
  final Color? foregroundColor;
  const LineIconTextButton({
    super.key,
    required this.text,
    required this.icon,
    required this.onPressed,
    this.backgroundColor,
    this.foregroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        iconSize: 30,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(5),
        ),
        elevation: 0,
        backgroundColor: backgroundColor,
        foregroundColor: foregroundColor,
      ),
      child: Row(
        children: [
          Icon(icon),
          const SizedBox(width: 10),
          MyTextH3(text, foregroundColor),
        ],
      ),
    );
  }
}

class CircleMiniContainer extends Container {
  final String title;
  final double value;
  final bool isShowAsScaling;
  final Color valueColor;
  CircleMiniContainer(this.title, this.value, this.isShowAsScaling, this.valueColor, {super.key});
  @override
  Widget build(BuildContext context) {
    return Stack(alignment: Alignment.center, children: [
      Container(
        width: 160,
        height: 160,
        margin: const EdgeInsets.all(5),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(80),
        ),
        child: CircularProgressIndicator(
          backgroundColor: Colors.grey,
          valueColor: AlwaysStoppedAnimation<Color>(valueColor),
          value: isShowAsScaling ? value : 1,
          strokeWidth: 20,
        ),
      ),
      Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (isShowAsScaling == true)
            Text('${(value * 1000).toInt() / 10}%',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ))
          else
            Text('${(value * 100).toInt() / 100}',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                )),
          Text(
            title,
          ),
        ],
      ),
    ]);
  }
}

class BarChart extends Container {
  final double valueLeft;
  final double valueRight;
  final Color valueColor;
  BarChart(this.valueLeft, this.valueRight, this.valueColor, {super.key}) : super(width: 100, height: 200);
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Column(
          children: [
            Opacity(
              opacity: 0,
              child: Container(
                width: 80,
                height: valueLeft < 1 ? 200 - valueLeft * 200 : 0,
                decoration: BoxDecoration(
                  color: colorPrimary,
                ),
              ),
            ),
            Container(
              width: 80,
              height: valueLeft < 1 ? valueLeft * 200 : 200,
              decoration: BoxDecoration(
                color: Colors.grey,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(10),
                  topRight: Radius.circular(10),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(width: 40),
        Column(
          children: [
            Opacity(
              opacity: 0,
              child: Container(
                width: 80,
                height: valueRight < 1 ? 200 - valueRight * 200 : 0,
                decoration: BoxDecoration(
                  color: colorPrimary,
                ),
              ),
            ),
            Container(
              width: 80,
              height: valueRight < 1 ? valueRight * 200 : 200,
              decoration: BoxDecoration(
                color: valueColor,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(10),
                  topRight: Radius.circular(10),
                ),
              ),
            ),
          ],
        )
      ],
    );
  }
}

// class WaveChart extends StatelessWidget {
//   final WaveChartController controller;
//   final Color lineColor;
//   final double lineWidth;
//   const WaveChart({
//     super.key,
//     required this.controller,
//     this.lineColor = Colors.blue,
//     this.lineWidth = 2,
//   });
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//         height: 160,
//         clipBehavior: Clip.hardEdge,
//         decoration: BoxDecoration(
//           borderRadius: BorderRadius.circular(10),
//           border: Border.all(color: colorPrimaryContainer),
//           color: Colors.black,
//         ),
//         child: Obx(() {
//           if (controller.dataFlSpot.isEmpty) {
//             return Center(child: CircularProgressIndicator());
//           }
//           return LineChart(
//             duration: Duration(milliseconds: 1000),
//             LineChartData(
//               gridData: const FlGridData(show: false),
//               titlesData: const FlTitlesData(show: false),
//               borderData: FlBorderData(show: false),
//               minX: controller.minX,
//               maxX: controller.maxX,
//               minY: controller.minY,
//               maxY: controller.maxY,
//               lineBarsData: [
//                 LineChartBarData(
//                   spots: controller.dataFlSpot,
//                   isCurved: true,
//                   color: lineColor,
//                   barWidth: lineWidth,
//                   belowBarData: BarAreaData(
//                     show: true,
//                     color: lineColor,
//                   ),
//                   dotData: const FlDotData(show: false),
//                   isStepLineChart: false,
//                 ),
//               ],
//             ),
//           );
//         }));
//   }
// }

// class WaveChart8 extends StatelessWidget {
//   final WaveChart8Controller controller;
//   final double height;
//   final RxBool isFlay;
//   const WaveChart8({
//     super.key,
//     required this.controller,
//     required this.height,
//     required this.isFlay,
//   });
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       width: context.width - 20,
//       decoration: BoxDecoration(
//         borderRadius: BorderRadius.circular(10),
//         color: Colors.black,
//       ),
//       clipBehavior: Clip.hardEdge,
//       child: SingleChildScrollView(
//         scrollDirection: Axis.horizontal,
//         reverse: true,
//         child: Obx(() {
//           return SizedBox(
//               width: isFlay.value ? context.width + controller.dataFlSpot0.length * 50.0 : context.width,
//               height: height,
//               child: LineChart(
//                 duration: Duration(milliseconds: 1000),
//                 LineChartData(
//                   gridData: const FlGridData(show: false),
//                   titlesData: FlTitlesData(show: false),
//                   borderData: FlBorderData(show: false),
//                   minY: controller.minY,
//                   maxY: controller.maxY,
//                   lineBarsData: [
//                     LineChartBarData(
//                       barWidth: 1,
//                       spots: controller.dataFlSpot0,
//                       color: colorList[0],
//                       isCurved: true,
//                       belowBarData: BarAreaData(
//                         show: true,
//                         color: colorList[0],
//                       ),
//                       dotData: const FlDotData(show: false),
//                       isStepLineChart: false,
//                     ),
//                     LineChartBarData(
//                       barWidth: 1,
//                       spots: controller.dataFlSpot1,
//                       color: colorList[1],
//                       isCurved: true,
//                       belowBarData: BarAreaData(
//                         show: true,
//                         color: colorList[1],
//                       ),
//                       dotData: const FlDotData(show: false),
//                       isStepLineChart: false,
//                     ),
//                     LineChartBarData(
//                       barWidth: 1,
//                       spots: controller.dataFlSpot2,
//                       color: colorList[2],
//                       isCurved: true,
//                       belowBarData: BarAreaData(
//                         show: true,
//                         color: colorList[2],
//                       ),
//                       dotData: const FlDotData(show: false),
//                       isStepLineChart: false,
//                     ),
//                     LineChartBarData(
//                       barWidth: 1,
//                       spots: controller.dataFlSpot3,
//                       color: colorList[3],
//                       isCurved: true,
//                       belowBarData: BarAreaData(
//                         show: true,
//                         color: colorList[3],
//                       ),
//                       dotData: const FlDotData(show: false),
//                       isStepLineChart: false,
//                     ),
//                     LineChartBarData(
//                       barWidth: 1,
//                       spots: controller.dataFlSpot4,
//                       color: colorList[4],
//                       isCurved: true,
//                       belowBarData: BarAreaData(
//                         show: true,
//                         color: colorList[4],
//                       ),
//                       dotData: const FlDotData(show: false),
//                       isStepLineChart: false,
//                     ),
//                     LineChartBarData(
//                       barWidth: 1,
//                       spots: controller.dataFlSpot5,
//                       color: colorList[5],
//                       isCurved: true,
//                       belowBarData: BarAreaData(
//                         show: true,
//                         color: colorList[5],
//                       ),
//                       dotData: const FlDotData(show: false),
//                       isStepLineChart: false,
//                     ),
//                     LineChartBarData(
//                       barWidth: 1,
//                       spots: controller.dataFlSpot6,
//                       color: colorList[6],
//                       isCurved: true,
//                       belowBarData: BarAreaData(
//                         show: true,
//                         color: colorList[6],
//                       ),
//                       dotData: const FlDotData(show: false),
//                       isStepLineChart: false,
//                     ),
//                     LineChartBarData(
//                       barWidth: 1,
//                       spots: controller.dataFlSpot7,
//                       color: colorList[7],
//                       isCurved: true,
//                       belowBarData: BarAreaData(
//                         show: true,
//                         color: colorList[7],
//                       ),
//                       dotData: const FlDotData(show: false),
//                       isStepLineChart: false,
//                     ),
//                   ],
//                 ),
//               ));
//         }),
//       ),
//     );
//   }
// }

// class WavesChart extends StatelessWidget {
//   final WavesController controller;
//   const WavesChart({
//     super.key,
//     required this.controller,
//   });
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       alignment: Alignment.center,
//       margin: const EdgeInsets.all(5),
//       padding: const EdgeInsets.only(top: 5, bottom: 5),
//       decoration: BoxDecoration(
//         borderRadius: BorderRadius.circular(5),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.grey,
//             spreadRadius: 1,
//             blurRadius: 3,
//             offset: const Offset(0, 3),
//           ),
//         ],
//         color: Colors.white,
//       ),
//       clipBehavior: Clip.none,
//       child: SingleChildScrollView(
//         scrollDirection: Axis.horizontal,
//         reverse: true,
//         child: Obx(() => SizedBox(
//             width: controller.isFlay.value ? 50 + controller.dataFlSpotBaseline.length * 50.0 : context.width * 0.95,
//             height: controller.height.value,
//             child: LineChart(
//                 duration: Duration(seconds: 1),
//                 LineChartData(
//                     gridData: const FlGridData(show: true),
//                     titlesData: FlTitlesData(
//                         topTitles: AxisTitles(sideTitles: SideTitles(showTitles: true)),
//                         leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
//                         rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
//                         bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
//                         show: true),
//                     borderData: FlBorderData(show: false),
//                     minY: controller.minY.value,
//                     maxY: controller.maxY.value,
//                     backgroundColor: Colors.black,
//                     lineBarsData: [
//                       LineChartBarData(
//                           barWidth: 2,
//                           spots: controller.dataFlSpotBaseline,
//                           show: true,
//                           color: Colors.white,
//                           isCurved: false,
//                           dotData: const FlDotData(show: true)),
//                       LineChartBarData(
//                           barWidth: controller.barWidthLine0.value,
//                           spots: controller.dataFlSpot0,
//                           show: controller.isShowLine0.value,
//                           color: colorList[7],
//                           isCurved: controller.isCurved.value,
//                           dotData: const FlDotData(show: false)),
//                       LineChartBarData(
//                           barWidth: controller.barWidthLine1.value,
//                           spots: controller.dataFlSpot1,
//                           show: controller.isShowLine1.value,
//                           color: colorList[6],
//                           isCurved: controller.isCurved.value,
//                           dotData: const FlDotData(show: false)),
//                       LineChartBarData(
//                           barWidth: controller.barWidthLine2.value,
//                           spots: controller.dataFlSpot2,
//                           show: controller.isShowLine2.value,
//                           color: colorList[5],
//                           isCurved: controller.isCurved.value,
//                           dotData: const FlDotData(show: false)),
//                       LineChartBarData(
//                           barWidth: controller.barWidthLine3.value,
//                           spots: controller.dataFlSpot3,
//                           show: controller.isShowLine3.value,
//                           color: colorList[4],
//                           isCurved: controller.isCurved.value,
//                           dotData: const FlDotData(show: false)),
//                       LineChartBarData(
//                           barWidth: controller.barWidthLine4.value,
//                           spots: controller.dataFlSpot4,
//                           show: controller.isShowLine4.value,
//                           color: colorList[3],
//                           isCurved: controller.isCurved.value,
//                           dotData: const FlDotData(show: false)),
//                       LineChartBarData(
//                           barWidth: controller.barWidthLine5.value,
//                           spots: controller.dataFlSpot5,
//                           show: controller.isShowLine5.value,
//                           color: colorList[2],
//                           isCurved: controller.isCurved.value,
//                           dotData: const FlDotData(show: false)),
//                       LineChartBarData(
//                           barWidth: controller.barWidthLine6.value,
//                           spots: controller.dataFlSpot6,
//                           show: controller.isShowLine6.value,
//                           color: colorList[1],
//                           isCurved: controller.isCurved.value,
//                           dotData: const FlDotData(show: false)),
//                       LineChartBarData(
//                           barWidth: controller.barWidthLine7.value,
//                           spots: controller.dataFlSpot7,
//                           show: controller.isShowLine7.value,
//                           color: colorList[0],
//                           isCurved: controller.isCurved.value,
//                           dotData: const FlDotData(show: false))
//                     ])))),
//       ),
//     );
//   }
// }

// class WavesTable extends StatelessWidget {
//   final WavesTableController controller;
//   const WavesTable({
//     super.key,
//     required this.controller,
//   });
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//         margin: EdgeInsets.all(5),
//         padding: const EdgeInsets.all(10),
//         alignment: Alignment.center,
//         transformAlignment: Alignment.center,
//         decoration: BoxDecoration(
//           color: Colors.white,
//           borderRadius: BorderRadius.circular(10),
//           boxShadow: [
//             BoxShadow(
//               color: Colors.grey,
//               spreadRadius: 1,
//               blurRadius: 3,
//               offset: const Offset(0, 3), // 阴影方向和距离
//             ),
//           ],
//         ),
//         child: Obx(() => Table(
//               children: [
//                 TableRow(children: [for (String item in controller.title) MyTextP2(item)]),
//                 TableRow(decoration: BoxDecoration(color: colorSurface), children: [for (String item in controller.delta) MyTextP2(item)]),
//                 TableRow(children: [for (String item in controller.theta) MyTextP2(item)]),
//                 TableRow(decoration: BoxDecoration(color: colorSurface), children: [for (String item in controller.lowAlpha) MyTextP2(item)]),
//                 TableRow(children: [for (String item in controller.highAlpha) MyTextP2(item)]),
//                 TableRow(decoration: BoxDecoration(color: colorSurface), children: [for (String item in controller.lowBeta) MyTextP2(item)]),
//                 TableRow(children: [for (String item in controller.highBeta) MyTextP2(item)]),
//                 TableRow(decoration: BoxDecoration(color: colorSurface), children: [for (String item in controller.lowGamma) MyTextP2(item)]),
//                 TableRow(children: [for (String item in controller.middleGamma) MyTextP2(item)]),
//               ],
//             )));
//   }
// }

// class BetaTable extends StatelessWidget {
//   final BetaTableController controller;
//   const BetaTable({
//     super.key,
//     required this.controller,
//   });
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//         margin: EdgeInsets.all(5),
//         padding: const EdgeInsets.all(10),
//         alignment: Alignment.center,
//         transformAlignment: Alignment.center,
//         decoration: BoxDecoration(
//           color: Colors.white,
//           borderRadius: BorderRadius.circular(5),
//           boxShadow: [
//             BoxShadow(
//               color: Colors.grey,
//               spreadRadius: 1,
//               blurRadius: 3,
//               offset: const Offset(0, 3), // 阴影方向和距离
//             ),
//           ],
//         ),
//         child: Obx(() => Table(
//               children: [
//                 TableRow(children: [for (String item in controller.title) MyTextP2(item)]),
//                 TableRow(decoration: BoxDecoration(color: colorSurface), children: [for (String item in controller.mv) MyTextP2(item)]),
//                 TableRow(children: [for (String item in controller.trend) MyTextP2(item)]),
//                 TableRow(decoration: BoxDecoration(color: colorSurface), children: [for (String item in controller.sign) MyTextP2(item)]),
//                 TableRow(children: [for (String item in controller.activity) MyTextP2(item)]),
//               ],
//             )));
//   }
// }

// class WavesChartButtons extends StatelessWidget {
//   final WavesController controller;
//   const WavesChartButtons({
//     super.key,
//     required this.controller,
//   });
//   @override
//   Widget build(BuildContext context) {
//     return SingleChildScrollView(
//       scrollDirection: Axis.horizontal,
//       child: Container(
//         alignment: Alignment.center,
//         child: Row(
//           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//           children: [
//             TextButton(
//                 onPressed: () {
//                   controller.isShowLine0.value = !controller.isShowLine0.value;
//                 },
//                 child: Text("·Delta·", style: TextStyle(color: colorPrimary, backgroundColor: colorList[7]))),
//             TextButton(
//                 onPressed: () {
//                   controller.isShowLine1.value = !controller.isShowLine1.value;
//                 },
//                 child: Text("·Theta·", style: TextStyle(color: colorSurface, backgroundColor: colorList[6]))),
//             TextButton(
//                 onPressed: () {
//                   controller.isShowLine2.value = !controller.isShowLine2.value;
//                 },
//                 child: Text("·LowAlpha·", style: TextStyle(color: colorSurface, backgroundColor: colorList[5]))),
//             TextButton(
//                 onPressed: () {
//                   controller.isShowLine3.value = !controller.isShowLine3.value;
//                 },
//                 child: Text("·HighAlpha·", style: TextStyle(color: colorSurface, backgroundColor: colorList[4]))),
//             TextButton(
//                 onPressed: () {
//                   controller.isShowLine4.value = !controller.isShowLine4.value;
//                 },
//                 child: Text("·LowBeta·", style: TextStyle(color: colorSurface, backgroundColor: colorList[3]))),
//             TextButton(
//                 onPressed: () {
//                   controller.isShowLine5.value = !controller.isShowLine5.value;
//                 },
//                 child: Text("·HighBeta·", style: TextStyle(color: colorSurface, backgroundColor: colorList[2]))),
//             TextButton(
//                 onPressed: () {
//                   controller.isShowLine6.value = !controller.isShowLine6.value;
//                 },
//                 child: Text("·LowGamma·", style: TextStyle(color: colorSurface, backgroundColor: colorList[1]))),
//             TextButton(
//                 onPressed: () {
//                   controller.isShowLine7.value = !controller.isShowLine7.value;
//                 },
//                 child: Text("·MidGamma·", style: TextStyle(color: colorSurface, backgroundColor: colorList[0])))
//           ],
//         ),
//       ),
//     );
//   }
// }

// class BrainView extends StatelessWidget {
//   BrainView({super.key});
//   final MyCtrl controller = Get.find();
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//         width: MediaQuery.of(context).size.width,
//         padding: const EdgeInsets.all(10),
//         decoration: const BoxDecoration(borderRadius: BorderRadius.only(topLeft: Radius.circular(10), topRight: Radius.circular(10))),
//         child: SingleChildScrollView(
//           scrollDirection: Axis.vertical,
//           child: Column(mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.center, spacing: 10, children: [
//             Obx(() => MyTextH3(controller.isConnect.value ? "（ 设备连接正常 ）" : "（ 设备连接异常 ）", controller.isConnect.value ? colorPrimary : colorError)),
//             Row(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 CircularIconTextButton(
//                     text: "清空",
//                     icon: Icons.refresh_rounded,
//                     onPressed: () {
//                       controller.wavesController.clearSpots();
//                     }),
//                 Obx(() => MyTextP2(controller.isRecording.value ? "数据采集中…… ${controller.pureCount.value}" : "脑电波")),
//                 Obx(() => CircularIconTextButton(
//                     text: controller.wavesController.isFlay.value ? "瞬时图" : "全图",
//                     icon: controller.wavesController.isFlay.value ? Icons.hourglass_empty_rounded : Icons.all_inclusive_rounded,
//                     onPressed: () {
//                       bool isFlay = controller.wavesController.changeIsFlay();
//                       controller.wavesController.setBarWidth(isFlay ? 3 : 1);
//                     }))
//               ],
//             ),
//             WavesChart(controller: controller.wavesController),
//             WavesChartButtons(controller: controller.wavesController),
//             Container(
//               alignment: Alignment.center,
//               transformAlignment: Alignment.center,
//               height: 200,
//               child: MyTextP3("Copyright 2025 HealingAI", colorPrimary),
//             ),
//           ]),
//         ));
//   }
// }

// class LoginView extends StatelessWidget {
//   LoginView({super.key});
//   final MyCtrl controller = Get.find();
//   @override
//   Widget build(BuildContext context) {
//     return SingleChildScrollView(
//       child: Container(
//         height: MediaQuery.of(context).size.height * 0.8,
//         decoration: const BoxDecoration(borderRadius: BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20))),
//         child: Column(
//           children: [
//             ListTile(
//               title: Text('登录'),
//               subtitle: const Text('请输入您的11位手机号和8位登录密码'),
//               trailing: IconButton(
//                   onPressed: () {
//                     Get.back();
//                   },
//                   icon: const Icon(Icons.close)),
//             ),
//             Container(
//               margin: const EdgeInsets.all(20),
//               padding: const EdgeInsets.all(20),
//               decoration: BoxDecoration(
//                 color: ThemeData().colorScheme.primaryContainer,
//                 borderRadius: const BorderRadius.all(Radius.circular(20)),
//               ),
//               child: Form(
//                   autovalidateMode: AutovalidateMode.onUserInteraction,
//                   child: Column(
//                     children: [
//                       TextFormField(
//                           initialValue: controller.user.adminPhonenumber.value,
//                           decoration: const InputDecoration(
//                             labelText: '联系人手机号',
//                           ),
//                           keyboardType: TextInputType.number,
//                           inputFormatters: [
//                             FilteringTextInputFormatter.digitsOnly,
//                             LengthLimitingTextInputFormatter(11),
//                           ],
//                           onChanged: (value) {
//                             controller.user.adminPhonenumber.value = value;
//                             if (value.length == 11) {
//                               FocusScope.of(context).unfocus();
//                               SystemChannels.textInput.invokeMethod('TextInput.hide');
//                             }
//                           },
//                           validator: (value) {
//                             if (value == null || value.isEmpty) {
//                               return '请输入11位手机号';
//                             } else if (value.length != 11) {
//                               return '手机号必须是11位数字';
//                             }
//                             return null;
//                           }),
//                       TextFormField(
//                           initialValue: controller.user.adminPassword.value,
//                           decoration: const InputDecoration(
//                             labelText: '登录密码',
//                           ),
//                           keyboardType: TextInputType.number,
//                           inputFormatters: [
//                             FilteringTextInputFormatter.digitsOnly,
//                             LengthLimitingTextInputFormatter(8),
//                           ],
//                           onChanged: (value) {
//                             controller.user.adminPassword.value = value;
//                             if (value.length == 8) {
//                               FocusScope.of(context).unfocus();
//                               SystemChannels.textInput.invokeMethod('TextInput.hide');
//                             }
//                           },
//                           validator: (value) {
//                             if (value == null || value.isEmpty) {
//                               return '请输入登录密码';
//                             } else if (value.length != 8) {
//                               return '登录密码必须是8位数字';
//                             }
//                             return null;
//                           }),
//                       Container(
//                         margin: const EdgeInsets.only(top: 20),
//                         width: double.infinity,
//                         child: ElevatedButton(
//                           onPressed: () {
//                             if (controller.user.adminPhonenumber.value.length == 11 && controller.user.adminPassword.value.length == 8) {
//                               Get.back();
//                               controller.user.login();
//                             } else {
//                               Get.snackbar('输入有误', '请检查手机号和登录密码的长度', snackPosition: SnackPosition.BOTTOM);
//                             }
//                           },
//                           child: Obx(() => switch (controller.user.loginState.value) {
//                                 0 => const Text('登录'),
//                                 1 => const CircularProgressIndicator(),
//                                 2 => const Text('已登录，可重新登录'),
//                                 int() => throw UnimplementedError(),
//                               }),
//                         ),
//                       )
//                     ],
//                   )),
//             )
//           ],
//         ),
//       ),
//     );
//   }
// }

// class EstrogenView extends StatelessWidget {
//   final EstrogenController controller;
//   final double height;
//   const EstrogenView({
//     super.key,
//     required this.controller,
//     required this.height,
//   });
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       width: context.width - 20,
//       decoration: BoxDecoration(
//         borderRadius: BorderRadius.circular(10),
//         color: Colors.white,
//       ),
//       clipBehavior: Clip.hardEdge,
//       child: SingleChildScrollView(
//         scrollDirection: Axis.horizontal,
//         reverse: true,
//         child: Obx(() {
//           return SizedBox(
//               width: context.width,
//               height: height,
//               child: LineChart(
//                 duration: Duration(milliseconds: 1000),
//                 LineChartData(
//                   gridData: const FlGridData(show: true),
//                   titlesData: FlTitlesData(show: true),
//                   borderData: FlBorderData(show: true),
//                   minY: controller.minY,
//                   maxY: controller.maxY,
//                   lineBarsData: [
//                     LineChartBarData(
//                       barWidth: 1,
//                       spots: controller.dataFlSpot0,
//                       color: Colors.grey,
//                       isCurved: true,
//                       belowBarData: BarAreaData(
//                         show: true,
//                         color: Colors.grey,
//                       ),
//                       dotData: const FlDotData(show: false),
//                       isStepLineChart: false,
//                     ),
//                     LineChartBarData(
//                       barWidth: 10,
//                       spots: controller.dataFlSpot1,
//                       color: Colors.red,
//                       isCurved: true,
//                       dotData: const FlDotData(show: false),
//                       isStepLineChart: false,
//                     ),
//                   ],
//                 ),
//               ));
//         }),
//       ),
//     );
//   }
// }

// class StressView extends StatelessWidget {
//   final StressController controller;
//   final double height;
//   const StressView({
//     super.key,
//     required this.controller,
//     required this.height,
//   });
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       width: context.width,
//       decoration: BoxDecoration(borderRadius: BorderRadius.circular(10), color: Colors.white),
//       clipBehavior: Clip.hardEdge,
//       child: SingleChildScrollView(
//         scrollDirection: Axis.horizontal,
//         reverse: true,
//         child: Obx(() {
//           return SizedBox(
//               width: context.width - 60,
//               height: height,
//               child: LineChart(
//                 duration: Duration(milliseconds: 1000),
//                 LineChartData(
//                   backgroundColor: Colors.transparent,
//                   gridData: const FlGridData(show: true),
//                   titlesData: FlTitlesData(show: true),
//                   borderData: FlBorderData(show: true),
//                   minY: controller.minY,
//                   maxY: controller.maxY,
//                   lineBarsData: [
//                     LineChartBarData(
//                       barWidth: 3,
//                       spots: controller.dataFlSpot,
//                       color: Colors.purple,
//                       isCurved: true,
//                       belowBarData: BarAreaData(
//                         show: true,
//                         color: Colors.transparent,
//                         gradient: LinearGradient(
//                           begin: Alignment.topCenter,
//                           end: Alignment.bottomCenter,
//                           colors: [
//                             Colors.green,
//                             Colors.white,
//                           ],
//                           stops: [0.0, 1.0],
//                         ),
//                       ),
//                       dotData: const FlDotData(show: true),
//                       isStepLineChart: false,
//                     )
//                   ],
//                 ),
//               ));
//         }),
//       ),
//     );
//   }
// }

class PressureGauge extends StatelessWidget {
  final String label;
  final double width;
  final double value;
  final double maxValue;
  const PressureGauge({super.key, required this.label, required this.value, required this.maxValue, required this.width});
  @override
  Widget build(BuildContext context) {
    final safeValue = value.isNaN || value.isInfinite ? 0.0 : value.clamp(0.0, maxValue);
    final safeMaxValue = maxValue.isNaN || maxValue.isInfinite ? 1.0 : maxValue.clamp(0.1, double.infinity);
    return LayoutBuilder(
      builder: (context, constraints) {
        return CustomPaint(
          size: Size(width, width / 2),
          painter: _GaugePainter(label: label, value: safeValue, maxValue: safeMaxValue),
        );
      },
    );
  }
}

class _GaugePainter extends CustomPainter {
  final String label;
  final double value;
  final double maxValue;
  _GaugePainter({required this.label, required this.value, required this.maxValue});
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height);
    final radius = size.width / 2 * 0.9;
    // 绘制背景圆弧
    final backgroundPaint = Paint()
      ..shader = SweepGradient(
        colors: [colorSurface, Colors.grey, colorError],
        stops: [0.4, 0.8, 1.0],
      ).createShader(Rect.fromCircle(center: center, radius: radius))
      ..style = PaintingStyle.stroke
      ..strokeWidth = 5;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      pi,
      pi,
      false,
      backgroundPaint,
    );
    // 绘制指针
    final angle = pi * (value / maxValue);
    final pointerPaint = Paint()
      ..color = const Color.fromARGB(255, 160, 200, 255)
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    final pointerLength = radius - 15;
    final pointerEnd = Offset(center.dx - pointerLength * cos(angle), center.dy - pointerLength * sin(angle));
    canvas.drawLine(center, pointerEnd, pointerPaint);
    canvas.drawCircle(center, 5, Paint()..color = Colors.red);
    // 添加文本标签
    _drawLabel(canvas, 'o', center, radius, pi * 1.0);
    _drawLabel(canvas, 'o', center, radius, pi * 1.25);
    _drawLabel(canvas, 'o', center, radius, pi * 1.5);
    _drawLabel(canvas, label, center, radius / 2, pi * 1.5);
    _drawLabel(canvas, 'o', center, radius, pi * 1.75);
    _drawLabel(canvas, 'o', center, radius, pi * 2.0);
  }

  void _drawLabel(Canvas canvas, String text, Offset center, double radius, double angle) {
    final textPainter = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(color: Colors.black, fontSize: 14),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    final offset = Offset(center.dx + (radius - 15) * cos(angle) - textPainter.width / 2, center.dy + (radius - 15) * sin(angle) - textPainter.height / 2);
    textPainter.paint(canvas, offset);
  }

  @override
  bool shouldRepaint(covariant _GaugePainter oldDelegate) {
    return oldDelegate.value != value || oldDelegate.maxValue != maxValue || oldDelegate.label != label;
  }
}

class MultiColorPieChart extends StatelessWidget {
  final List<Color> colors;
  final List<double> values;
  final List<String> labels;
  final double width;
  const MultiColorPieChart({
    super.key,
    required this.colors,
    required this.values,
    required this.labels,
    required this.width,
  });
  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(width, width),
      painter: _PieChartPainter(colors: colors, values: values, labels: labels),
    );
  }
}

class _PieChartPainter extends CustomPainter {
  final List<Color> colors;
  final List<double> values;
  final List<String> labels;
  _PieChartPainter({required this.colors, required this.values, required this.labels});
  @override
  void paint(Canvas canvas, Size size) {
    final radius = size.width / 2 * 0.9;
    final rect = Rect.fromCircle(
      center: Offset(size.width / 2, size.height / 2),
      radius: size.width / 2,
    );
    double pi = 3.1415926;
    double startAngle = -90 * (pi / 180); // 从12点方向开始
    for (int i = 0; i < values.length; i++) {
      final sweepAngle = values[i] * 2 * pi;
      final paint = Paint()
        ..color = colors[i % colors.length]
        ..style = PaintingStyle.fill;
      canvas.drawArc(rect, startAngle, sweepAngle, true, paint);
      final textPainter = TextPainter(
        text: TextSpan(
          text: labels[i], //"${(values[i] * 100).toStringAsFixed(1)}%",
          style: TextStyle(color: colorPrimaryContainer, fontSize: 12),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      final textOffset = Offset(
        rect.center.dx + (radius - 20) * cos(startAngle + sweepAngle / 2) - textPainter.width / 2,
        rect.center.dy + (radius - 20) * sin(startAngle + sweepAngle / 2) - textPainter.height / 2,
      );
      textPainter.paint(canvas, textOffset);
      startAngle += sweepAngle;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

// class EmoValue extends StatelessWidget {
//   final List<int> data;
//   const EmoValue({super.key, required this.data});
//   @override
//   Widget build(BuildContext context) {
//     const labels = ["恐惧-", "紧绷-", "警觉+", "欢喜+", "焦虑-", "紧张-", "兴奋+", "快乐+", "厌恶-", "烦恼-", "镇定+", "放松+", "抑郁-", "悲伤-", "平静+", "满足+"];
//     final total = data.reduce((prev, cur) => prev + cur);
//     return Container(
//       margin: EdgeInsets.all(10),
//       padding: EdgeInsets.all(10),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(10),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.grey,
//             spreadRadius: 1,
//             blurRadius: 1,
//             offset: Offset(0, 1), // 阴影方向
//           ),
//         ],
//       ),
//       child: Column(
//         children: [
//           MyTextP2("情绪效价与激活度"),
//           const SizedBox(height: 80),
//           Stack(
//             alignment: Alignment.center,
//             children: [
//               CustomPaint(
//                 size: Size(400, 200),
//                 painter: _EllipsePainter(),
//               ),
//               CustomPaint(
//                 size: Size(420, 220),
//                 painter: _CoordinateSystemPainter(),
//               ),
//               Table(
//                 defaultColumnWidth: FixedColumnWidth(40),
//                 children: [
//                   for (int i = 0; i < 4; i++)
//                     TableRow(children: [
//                       for (int j = 0; j < 4; j++)
//                         Container(
//                           alignment: Alignment.center,
//                           child: MyTextP3(labels[i * 4 + j], colorSecondary),
//                         ),
//                     ])
//                 ],
//               ),
//               Image.asset(width: 40 + (total < 160 ? total : 160).toDouble(), height: 40 + (total < 160 ? total : 160).toDouble(), 'assets/images/Bird.png'),
//             ],
//           ),
//           const SizedBox(height: 40),
//           const Divider(height: 20, thickness: 5, radius: BorderRadius.all(Radius.circular(5))),
//           MyTextP2("正向情绪的动态捕获"),
//           MyTextP2("（疗愈收益）"),
//           const Divider(height: 20),
//           Table(
//             columnWidths: {
//               0: FlexColumnWidth(60),
//               1: FlexColumnWidth(context.width),
//               2: FlexColumnWidth(60),
//             },
//             defaultVerticalAlignment: TableCellVerticalAlignment.middle,
//             children: [
//               for (int i = 0; i < labels.length; i++)
//                 TableRow(children: [
//                   MyTextP2(labels[i]),
//                   Row(
//                     children: [
//                       for (int j = 0; j < (data[i] > 16 ? 16 : data[i]); j++)
//                         Container(
//                           margin: EdgeInsets.only(right: 1),
//                           width: 30,
//                           height: 30,
//                           child: Image.asset(
//                             'assets/images/Bird.png',
//                           ),
//                         ),
//                       Container(
//                         margin: EdgeInsets.only(right: 1),
//                         width: 30,
//                         height: 30,
//                         child: Icon(Icons.keyboard_control_rounded),
//                       ),
//                     ],
//                   ),
//                   Container(
//                     alignment: Alignment.centerRight,
//                     child: MyTextP2("${data[i] > 0 ? "+" : ""} ${data[i].toString()}"),
//                   )
//                 ])
//             ],
//           ),
//           const Divider(height: 20),
//           MyTextP2("Total Birds $total"),
//         ],
//       ),
//     );
//   }
// }

// class _CoordinateSystemPainter extends CustomPainter {
//   @override
//   void paint(Canvas canvas, Size size) {
//     final paint = Paint()
//       ..color = colorSecondary
//       ..strokeWidth = 1;
//     // 绘制坐标轴
//     canvas.drawLine(Offset(0, size.height / 2), Offset(size.width, size.height / 2), paint);
//     canvas.drawLine(Offset(size.width / 2, 0), Offset(size.width / 2, size.height), paint);
//     // 添加坐标轴标签
//     final textPainter = TextPainter(
//       text: TextSpan(text: '>效价', style: TextStyle(color: colorSecondary, fontSize: 14)),
//       textDirection: TextDirection.ltr,
//     );
//     // 横轴标签（效价）
//     textPainter.layout();
//     textPainter.paint(canvas, Offset(size.width, size.height / 2 - 11));
//     // 纵轴标签（激活度）
//     final verticalText = TextPainter(
//       text: TextSpan(text: '>激活度', style: TextStyle(color: colorSecondary, fontSize: 14)),
//       textDirection: TextDirection.ltr,
//     );
//     verticalText.layout();
//     canvas.save();
//     canvas.translate(size.width / 2 - 11, 0);
//     canvas.rotate(-90 * 3.1415927 / 180);
//     verticalText.paint(canvas, Offset.zero);
//     canvas.restore();
//   }
//   @override
//   bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
// }

// class _EllipsePainter extends CustomPainter {
//   @override
//   void paint(Canvas canvas, Size size) {
//     final paint = Paint()..color = colorSurface;
//     // 以坐标原点为中心绘制椭圆
//     canvas.drawOval(Rect.fromCenter(center: Offset(size.width / 2, size.height / 2), width: size.width, height: size.height), paint);
//   }
//   @override
//   bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
// }

// class HealingValue extends StatelessWidget {
//   final double lowBetaBase;
//   final double lowBetaMin;
//   final double highBetaBase;
//   final double highBetaMin;
//   const HealingValue({super.key, required this.lowBetaBase, required this.lowBetaMin, required this.highBetaBase, required this.highBetaMin});
//   double calculatePercentage(double base, double min) {
//     if (base == 0) return 0.0;
//     return ((base - min) / base * 1000).toInt() / 10;
//   }
//   double calculateSize(double value, double maxBase) {
//     return 200 * value / maxBase;
//   }
//   @override
//   Widget build(BuildContext context) {
//     final plb = calculatePercentage(lowBetaBase, lowBetaMin);
//     final phb = calculatePercentage(highBetaBase, highBetaMin);
//     final maxb = highBetaBase > lowBetaBase ? highBetaBase : lowBetaBase;
//     final slb = calculateSize(lowBetaBase, maxb);
//     final slm = calculateSize(lowBetaMin, maxb);
//     final shb = calculateSize(highBetaBase, maxb);
//     final shm = calculateSize(highBetaMin, maxb);
//     return Container(
//         margin: EdgeInsets.all(10),
//         padding: EdgeInsets.all(10),
//         decoration: BoxDecoration(
//           color: Colors.white,
//           borderRadius: BorderRadius.circular(10),
//           boxShadow: [
//             BoxShadow(
//               color: Colors.grey,
//               spreadRadius: 1,
//               blurRadius: 1,
//               offset: Offset(0, 1), // 阴影方向
//             ),
//           ],
//         ),
//         child: Column(
//           children: [
//             const MyTextP2("负向情绪的释放动态"),
//             const MyTextP2("（启动检测约1分钟后开始统计）"),
//             const SizedBox(height: 40),
//             Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
//               Stack(alignment: AlignmentGeometry.center, children: [
//                 Container(
//                   width: slb,
//                   height: slb,
//                   decoration: BoxDecoration(
//                     color: colorSecondaryContainer,
//                     borderRadius: BorderRadius.circular(slb / 2),
//                     boxShadow: [
//                       BoxShadow(color: colorPrimary, blurRadius: 10),
//                     ],
//                   ),
//                 ),
//                 Container(
//                   width: slm,
//                   height: slm,
//                   margin: EdgeInsets.all(10),
//                   padding: EdgeInsets.all(10),
//                   decoration: BoxDecoration(
//                     color: colorSecondaryContainer,
//                     borderRadius: BorderRadius.circular(slm / 2),
//                     boxShadow: [BoxShadow(color: Colors.red, blurRadius: 10)],
//                   ),
//                 ),
//                 MyTextP2("紧张焦虑")
//               ]),
//               Stack(alignment: AlignmentGeometry.center, children: [
//                 Container(
//                   width: shb,
//                   height: shb,
//                   decoration: BoxDecoration(
//                     color: colorSecondaryContainer,
//                     borderRadius: BorderRadius.circular(shb / 2),
//                     boxShadow: [
//                       BoxShadow(color: colorPrimary, blurRadius: 10),
//                     ],
//                   ),
//                 ),
//                 Container(
//                   width: shm,
//                   height: shm,
//                   margin: EdgeInsets.all(10),
//                   padding: EdgeInsets.all(10),
//                   decoration: BoxDecoration(
//                     color: colorSecondaryContainer,
//                     borderRadius: BorderRadius.circular(shm / 2),
//                     boxShadow: [BoxShadow(color: Colors.red, blurRadius: 10)],
//                   ),
//                 ),
//                 MyTextP2("烦恼厌恶")
//               ]),
//             ]),
//             const SizedBox(height: 20),
//             MyTextP2("（外圈为基线-历史最高值，内圈为下限-历史最低值）"),
//             const SizedBox(height: 40),
//             Table(
//               border: TableBorder.all(color: colorSecondaryContainer, width: 1),
//               columnWidths: {
//                 0: FlexColumnWidth(100),
//                 1: FlexColumnWidth(100),
//                 2: FlexColumnWidth(100),
//                 3: FlexColumnWidth(100),
//               },
//               children: [
//                 TableRow(
//                     decoration: BoxDecoration(color: colorSecondaryContainer),
//                     children: [MyTextP2("  情绪\\脑波能耗"), MyTextP2("  基线值"), MyTextP2("  下限值"), MyTextP2("  变化显著度")]),
//                 TableRow(children: [MyTextP2("  紧张焦虑"), MyTextP2("  $lowBetaBase"), MyTextP2("  $lowBetaMin"), MyTextP2("  $plb%")]),
//                 TableRow(children: [MyTextP2("  烦恼厌恶"), MyTextP2("  $highBetaBase"), MyTextP2("  $highBetaMin"), MyTextP2("  $phb%")])
//               ],
//             ),
//             const SizedBox(height: 10),
//           ],
//         ));
//   }
// }

// class HaloView extends StatelessWidget {
//   final double sideLength;
//   final List<double> diameter8;
//   const HaloView({super.key, required this.sideLength, required this.diameter8});
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       alignment: Alignment.center,
//       width: sideLength,
//       height: sideLength,
//       margin: EdgeInsets.all(10),
//       padding: EdgeInsets.all(10),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(10),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.grey,
//             spreadRadius: 1,
//             blurRadius: 1,
//             offset: Offset(0, 1), // 阴影方向
//           ),
//         ],
//       ),
//       child: Stack(
//         alignment: Alignment.center,
//         children: [
//           Opacity(
//             opacity: 0.2,
//             child: Image.asset(
//               "assets/images/brain.png",
//               width: sideLength,
//               height: sideLength,
//             ),
//           ),
//           Opacity(
//             opacity: 0.8,
//             child: Stack(
//               alignment: Alignment.center,
//               children: [
//                 for (int i = 0; i < 8; i++)
//                   Container(
//                     width: diameter8[i],
//                     height: diameter8[i],
//                     decoration: BoxDecoration(
//                       color: colorList[i],
//                       borderRadius: BorderRadius.circular(diameter8[i] / 2),
//                     ),
//                   ),
//                 Image.asset(
//                   "assets/images/brain.png",
//                   width: 64,
//                   height: 64,
//                 )
//               ],
//             ),
//           )
//         ],
//       ),
//     );
//   }
// }

// class DrawView extends StatelessWidget {
//   final double sideLength;
//   final RxString fileUrl;
//   const DrawView({super.key, required this.sideLength, required this.fileUrl});
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       alignment: Alignment.center,
//       width: sideLength - 40,
//       height: sideLength - 40,
//       margin: EdgeInsets.all(10),
//       padding: EdgeInsets.all(10),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(10),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.grey,
//             spreadRadius: 1,
//             blurRadius: 1,
//             offset: Offset(0, 1), // 阴影方向
//           ),
//         ],
//       ),
//       child: Obx(() => fileUrl.value.isEmpty
//           ? Opacity(opacity: 0.1, child: Image.asset("assets/images/brain.png", width: sideLength, height: sideLength))
//           : Image.network(fileUrl.value, width: sideLength, height: sideLength)),
//     );
//   }
// }

// class MusicView extends StatelessWidget {
//   final double width;
//   final int selectedIndex;
//   const MusicView({super.key, required this.width, required this.selectedIndex});
//   @override
//   Widget build(BuildContext context) {
//     return SizedBox(
//       width: width,
//       child: GridView.builder(
//         shrinkWrap: true,
//         physics: const NeverScrollableScrollPhysics(),
//         gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
//           crossAxisCount: 3,
//           childAspectRatio: 1.8,
//           mainAxisSpacing: 8,
//           crossAxisSpacing: 8,
//         ),
//         itemCount: musicTitles.length,
//         itemBuilder: (context, index) => Card(
//           color: selectedIndex == index ? colorSecondaryContainer : Colors.white,
//           elevation: 2,
//           child: ListTile(
//             leading: selectedIndex == index
//                 ? Icon(
//                     Icons.check_circle,
//                     color: Colors.green,
//                     size: 32,
//                   )
//                 : Icon(
//                     Icons.music_note,
//                     color: Colors.grey,
//                     size: 24,
//                   ),
//             title: Text(
//               musicTitles.keys.elementAt(index),
//               style: Theme.of(context).textTheme.titleMedium,
//             ),
//             subtitle: Text(
//               musicTitles.values.elementAt(index),
//               style: Theme.of(context).textTheme.bodyMedium,
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }

// class StaffView extends StatelessWidget {
//   final double width;
//   final List<int> notes;
//   const StaffView({super.key, required this.width, required this.notes});
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       margin: EdgeInsets.all(10),
//       padding: EdgeInsets.only(top: 30, bottom: 10, left: 10, right: 10),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(10),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.grey,
//             spreadRadius: 1,
//             blurRadius: 1,
//             offset: Offset(0, 1), // 阴影方向
//           ),
//         ],
//       ),
//       width: width,
//       child: Table(
//         defaultVerticalAlignment: TableCellVerticalAlignment.middle,
//         children: [
//           for (int i = 0; i < 12; i++)
//             TableRow(
//               children: [
//                 Icon(
//                   Icons.music_note,
//                   size: 24,
//                   color: Colors.grey,
//                 ),
//                 for (int j = 0; j < notes.length; j++)
//                   Stack(
//                     alignment: Alignment.center,
//                     children: [
//                       i % 2 == 0 && i != 10 ? Divider(thickness: 2) : Container(),
//                       Icon(
//                         i != 10 ? Icons.radio_button_unchecked_rounded : Icons.strikethrough_s_rounded,
//                         size: 24,
//                         color: i == notes[j] ? Colors.green : Colors.white,
//                       )
//                     ],
//                   ),
//               ],
//             ),
//         ],
//       ),
//     );
//   }
// }

// class ChakraView extends StatelessWidget {
//   final double width;
//   final List<double> chakraValues;
//   const ChakraView({super.key, required this.width, required this.chakraValues});
//   @override
//   Widget build(BuildContext context) {
//     if (chakraValues.length != 7) {
//       return Container();
//     }
//     double total = chakraValues.fold(0, (prev, curr) => prev + curr);
//     List<double> chakraSize = chakraValues.map((e) => e / total).toList();
//     return Container(
//         margin: EdgeInsets.all(10),
//         padding: EdgeInsets.all(10),
//         decoration: BoxDecoration(
//           color: Colors.white,
//           borderRadius: BorderRadius.circular(10),
//           boxShadow: [
//             BoxShadow(
//               color: Colors.grey,
//               spreadRadius: 1,
//               blurRadius: 1,
//               offset: Offset(0, 1), // 阴影方向
//             ),
//           ],
//         ),
//         width: width,
//         child: Stack(
//           alignment: Alignment.center,
//           children: [
//             Image.asset("assets/images/body.png"),
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//               crossAxisAlignment: CrossAxisAlignment.center,
//               children: [
//                 SizedBox(
//                   width: width * 0.5,
//                   child: Column(
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     crossAxisAlignment: CrossAxisAlignment.center,
//                     children: [
//                       for (int i = 0; i < 7; i++)
//                         Icon(
//                           Icons.mode_standby_rounded,
//                           size: chakraSize[i] * 450,
//                           color: colorList[i],
//                         ),
//                     ],
//                   ),
//                 ),
//                 Table(defaultVerticalAlignment: TableCellVerticalAlignment.middle, border: TableBorder.all(color: Colors.grey), columnWidths: {
//                   0: FixedColumnWidth(20),
//                   1: FixedColumnWidth(100),
//                   2: FixedColumnWidth(50),
//                   3: FixedColumnWidth(40),
//                 }, children: [
//                   TableRow(
//                     decoration: BoxDecoration(color: Colors.grey[300]),
//                     children: [
//                       Icon(Icons.circle, size: 20, color: Colors.grey),
//                       MyTextP2("脉轮"),
//                       MyTextP2("活跃度"),
//                       MyTextP2("状态"),
//                     ],
//                   ),
//                   for (int i = 0; i < 7; i++)
//                     TableRow(
//                       children: [
//                         Icon(Icons.mode_standby_rounded, size: 20, color: colorList[i]),
//                         MyTextP2(chakra7.reversed.elementAt(i)),
//                         MyTextP2(chakraValues[i].toStringAsFixed(2)),
//                         MyTextP2(Data.qian(chakraValues[i])),
//                       ],
//                     ),
//                 ])
//               ],
//             ),
//           ],
//         ));
//   }
// }

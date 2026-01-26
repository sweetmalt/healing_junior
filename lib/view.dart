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
          actions: [
            CircularIconButton(
              icon: Icons.share,
              onPressed: () {
                if (customerCtrl.phone.value.isEmpty) {
                  Get.snackbar('提示', '请先添加服务对象');
                  return;
                }
                final timestamp = DateTime.now().millisecondsSinceEpoch;
                controller.shareReport('脑电波', timestamp);
              },
            ),
            CircularIconButton(
              icon: Icons.attach_file_rounded,
              onPressed: () {
                Get.to(() => PdfListView());
              },
            ),
            CircularIconButton(
              icon: Icons.person_rounded,
              onPressed: () {
                Get.to(() => EmployeeView());
              },
            ),
            Obx(() =>
                employeeCtrl.isRegist.value ? Text('余额${employeeCtrl.paymentBalance.value > 0 ? employeeCtrl.paymentBalance.value : "不足"}') : Text("未登录")),
            CircularIconButton(
              icon: Icons.people_rounded,
              onPressed: () {
                Get.to(() => InstitutionView());
              },
            ),
          ]),
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
                  replacement: const SizedBox(height: 0),
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
                replacement: const SizedBox(height: 0),
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
                replacement: const SizedBox(height: 0),
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
                replacement: const SizedBox(height: 0),
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
                replacement: const SizedBox(height: 0),
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
                    ],
                  ),
                ),
              ),
              Visibility(
                visible: settingCtrl.states[5],
                replacement: const SizedBox(height: 0),
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
                    ],
                  ),
                ),
              ),
              Visibility(
                visible: settingCtrl.states[6],
                replacement: const SizedBox(height: 0),
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
                replacement: const SizedBox(height: 0),
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
                replacement: const SizedBox(height: 0),
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
                    ],
                  ),
                ),
              ),
              Visibility(
                visible: settingCtrl.states[9],
                replacement: const SizedBox(height: 0),
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
                replacement: const SizedBox(height: 0),
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
                replacement: const SizedBox(height: 0),
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
                replacement: const SizedBox(height: 0),
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
                replacement: const SizedBox(height: 0),
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
                replacement: const SizedBox(height: 0),
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
    );
  }

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

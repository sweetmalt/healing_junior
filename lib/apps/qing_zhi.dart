import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';
import 'package:get/get.dart';
import 'package:healing_junior/apps/customer.dart';
import 'package:healing_junior/apps/employee.dart';
import 'package:healing_junior/apps/qing_zhi_music.dart';
import 'package:healing_junior/data.dart';
import 'package:healing_junior/view.dart';

class QingZhiView extends GetView<QingZhiCtrl> {
  QingZhiView({super.key});

  @override
  final controller = Get.put(QingZhiCtrl());
  @override
  Widget build(BuildContext context) {
    return Container(
        margin: EdgeInsets.all(10),
        child: Obx(() => Column(children: [
              MyTextP1(QingZhiCtrl.title),
              const SizedBox(height: 20),
              Table(
                defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                columnWidths: {0: FixedColumnWidth(80), 1: FixedColumnWidth(60), 2: FixedColumnWidth(360)},
                border: TableBorder.all(color: colorSecondary, width: 2, borderRadius: BorderRadius.circular(5)),
                children: [
                  TableRow(children: [
                    MyTextP1("  情绪"),
                    MyTextP1("  脏腑"),
                    MyTextP1("  关系与机理"),
                  ]),
                  TableRow(children: [
                    MyTextP2("  ${QingZhiCtrl.emoTitles[0]}${controller.emoValues[0]}"),
                    MyTextP2("  心"),
                    MyTextP2("  喜则气缓。适度的喜乐能使心气舒畅，营卫调和。但过度惊喜或暴喜，会使心气涣散，神不守舍，导致精神无法集中，甚至出现心悸、失眠、嬉笑不休或疯癫等症。"),
                  ]),
                  TableRow(children: [
                    MyTextP2("  ${QingZhiCtrl.emoTitles[1]}${controller.emoValues[1]}"),
                    MyTextP2("  肝"),
                    MyTextP2("  怒则气上。愤怒会使肝气横逆、上冲。表现为：面红目赤、头痛头晕、呕血（气逼血上行），甚至昏厥。长期郁怒，还会导致肝郁气滞，出现胸胁胀痛、月经不调、抑郁寡欢等。"),
                  ]),
                  TableRow(children: [
                    MyTextP2("  ${QingZhiCtrl.emoTitles[2]}${controller.emoValues[2]}"),
                    MyTextP2("  肺"),
                    MyTextP2("  忧则气沉。过度忧虑会耗伤肺气，导致气机闭塞不行。表现为：意志消沉、胸闷气短、咳嗽乏力、声音低微。"),
                  ]),
                  TableRow(children: [
                    MyTextP2("  ${QingZhiCtrl.emoTitles[3]}${controller.emoValues[3]}"),
                    MyTextP2("  脾"),
                    MyTextP2("  思则气结。思虑过度会使脾气郁结，运化功能失常。表现为：食欲不振、脘腹胀满、消化不良、形体消瘦、失眠健忘。即“思伤脾”。"),
                  ]),
                  TableRow(children: [
                    MyTextP2("  ${QingZhiCtrl.emoTitles[4]}${controller.emoValues[4]}"),
                    MyTextP2("  肺"),
                    MyTextP2("  悲则气消。过度悲哀会耗伤肺气，使上焦不通，营卫不散。表现为：气短懒言、精神萎靡、面色惨淡、哭泣不止。悲和忧都与肺相关。"),
                  ]),
                  TableRow(children: [
                    MyTextP2("  ${QingZhiCtrl.emoTitles[5]}${controller.emoValues[5]}"),
                    MyTextP2("  肾"),
                    MyTextP2("  恐则气下。恐惧会使肾气不固，气泄于下。表现为：二便失禁、遗精滑泄、骨痿无力、惶惶不安。即“恐伤肾”。"),
                  ]),
                  TableRow(children: [
                    MyTextP2("  ${QingZhiCtrl.emoTitles[6]}${controller.emoValues[6]}"),
                    MyTextP2("  心、肾"),
                    MyTextP2("  惊则气乱。突然受惊会扰乱心神，使心气紊乱，肾气不固。表现为：心悸心慌、惊慌失措、精神错乱、二便失禁。惊与恐相似，但“惊”为不自知，事出突然；“恐”为自知，俗称胆怯。"),
                  ]),
                ],
              ),
              const SizedBox(height: 40),
              controller.analysisPrompt.value != ""
                  ? CircularIconTextButton(
                      text: "AI解读",
                      icon: controller.isGettingAnalysis.value ? Icons.refresh_rounded : Icons.view_in_ar_rounded,
                      onPressed: () async {
                        if (controller.isGettingAnalysis.value) {
                          Get.snackbar("正在解读", "请稍候……");
                          return;
                        }
                        controller.gettingAnalysisTimer.value = 0;
                        controller.isGettingAnalysis.value = true;
                        try {
                          await controller.analysis();
                        } finally {
                          controller.isGettingAnalysis.value = false;
                        }
                      },
                    )
                  : SizedBox.shrink(),
              if (controller.isGettingAnalysis.value) MyTextP1("正在解读请稍后……${controller.gettingAnalysisTimer.value}"),
              controller.analysisText.value.isNotEmpty
                  ? Container(
                      margin: EdgeInsets.all(20),
                      child: MarkdownBody(
                        data: controller.analysisText.value,
                        styleSheet: MarkdownStyleSheet(
                          h1: TextStyle(fontSize: 24, color: colorPrimaryContainer, fontWeight: FontWeight.bold),
                          h2: TextStyle(fontSize: 20, color: colorPrimaryContainer, fontWeight: FontWeight.bold),
                          h3: TextStyle(fontSize: 18, color: colorPrimaryContainer, fontWeight: FontWeight.bold),
                          p: TextStyle(fontSize: 16, color: colorPrimaryContainer),
                        ),
                      ),
                    )
                  : SizedBox.shrink(),
              CircularIconTextButton(
                text: "档案",
                icon: Icons.folder_rounded,
                onPressed: () => Get.to(() => QingZhiListView()),
              ),
              const SizedBox(height: 100),
              QingZhiMUsicView(),
            ])));
  }
}

class QingZhiCtrl extends GetxController {
  static const String cozeBot = "7633509378907406346";
  Timer? _timer;
  static const String title = "中医情志 - 情绪与脏腑关系";
  final bearer = "".obs;
  static const List emoTitles = ["喜+", "怒-", "忧-", "思-", "悲-", "恐-", "惊-"];
  final RxList<int> emoValues = [0, 0, 0, 0, 0, 0, 0].obs;
  final analysisPrompt = "".obs;
  final analysisText = "".obs;
  final isGettingAnalysis = false.obs;
  final gettingAnalysisTimer = 0.obs;
  @override
  void onInit() {
    _timer = Timer.periodic(Duration(seconds: 1), (_) {
      if (isGettingAnalysis.value) {
        gettingAnalysisTimer.value++;
      }
    });
    super.onInit();
  }

  @override
  void onClose() {
    _timer?.cancel();
    super.onClose();
  }

  void init() {
    analysisPrompt.value = "";
    for (int i = 0; i < emoValues.length; i++) {
      emoValues[i] = 0;
    }
  }

  void updateEmoValues(List<int> values) {
    if (values.length != emoValues.length) {
      return;
    }
    for (int i = 0; i < values.length; i++) {
      emoValues[i] = values[i];
    }
  }

  void createCozePrompt(String label) {
    analysisPrompt.value = "";
    for (int i = 0; i < emoValues.length; i++) {
      if (emoValues[i] > 0) {
        analysisPrompt.value += "${emoTitles[i]}${emoValues[i]}";
      }
    }
    if (analysisPrompt.value.isNotEmpty) {
      String sexandgae = "性别${customerCtrl.sex.value} 年龄${customerCtrl.age.value}岁";
      analysisPrompt.value = "$sexandgae $label ${analysisPrompt.value} ";
    }
  }

  final employeeCtrl = Get.put(EmployeeCtrl());
  final customerCtrl = Get.put(CustomerCtrl());
  Future<void> analysis() async {
    if (analysisPrompt.value.isEmpty) {
      Get.snackbar("提示", "请先收集情绪数据");
      return;
    }
    if (!employeeCtrl.isRegist.value) {
      Get.snackbar("请先登录", "未登录或未联网，无法使用AI功能");
      return;
    }
    //余额不足
    if (employeeCtrl.paymentBalance.value < 1) {
      Get.snackbar("请先充值", "您的账号余额不足，无法使用AI功能");
      return;
    }
    if (employeeCtrl.paymentTemp.value < 1) {
      bearer.value = await employeeCtrl.pay(1);
    }
    if (bearer.value.isEmpty) {
      Get.snackbar("故障", "网络故障，请稍后重试");
      return;
    }
    try {
      analysisText.value = "";
      debugPrint(analysisPrompt.value);
      analysisText.value = await Data.generateAiText(cozeBot, analysisPrompt.value, bearer.value);
      if (analysisText.value.isNotEmpty) {
        employeeCtrl.paymentTemp.value -= 1;
        save();
      }
    } catch (e) {
      Get.snackbar("失败", "分析失败，请稍后重试");
    }
  }

  Future<void> save() async {
    Map<String, dynamic> data = await Data.read("qing_zhi.json");
    data[customerCtrl.phone.value] = {
      "nickname": customerCtrl.nickname.value,
      "timestamp": DateTime.now().millisecondsSinceEpoch,
      "analysisPrompt": analysisPrompt.value,
      "analysisText": analysisText.value,
    };
    await Data.write(data, "qing_zhi.json");
    Get.snackbar("成功", "中医情志AI分析报告保存成功");
  }

  Future<Map<String, dynamic>> read(String phone) async {
    Map<String, dynamic> data = await Data.read("qing_zhi.json");
    if (!data.containsKey(phone)) {
      return {};
    }
    return data[phone];
  }
}

class QingZhiListView extends GetView<QingZhiListController> {
  QingZhiListView({super.key});
  final selectedCtrl = Get.put(SelectedQingZhiController());
  @override
  final QingZhiListController controller = Get.put(QingZhiListController());

  @override
  Widget build(BuildContext context) {
    controller.load();
    return Scaffold(
      appBar: AppBar(
        title: Text('中医情志AI分析报告 文件列表'),
        backgroundColor: colorSecondary,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_rounded),
          onPressed: () => Get.back(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.arrow_back_ios_rounded),
            onPressed: () => Get.back(),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildImageList(context),
            Divider(height: 1),
            _buildDetailSection(context),
            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }

  Widget _buildImageList(BuildContext context) {
    return Obx(
      () => SizedBox(
        height: 80,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: controller.list.length,
          itemBuilder: (ctx, index) => GestureDetector(
            onTap: () => selectedCtrl.select(controller.list[index]),
            child: Container(
              width: 100,
              clipBehavior: Clip.hardEdge,
              margin: EdgeInsets.all(5),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(5),
              ),
              child: MyTextP2(controller.list[index].nickname),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDetailSection(BuildContext context) {
    return Obx(() => selectedCtrl.selected.value == null
        ? SizedBox.shrink()
        : Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('昵称: ${selectedCtrl.selected.value!.nickname}'),
              Text('时间: ${DateTime.fromMillisecondsSinceEpoch(selectedCtrl.selected.value!.timestamp)}'),
              Container(
                width: MediaQuery.of(context).size.width,
                margin: EdgeInsets.all(20),
                child: MarkdownBody(
                  data: selectedCtrl.selected.value!.analysisText,
                  styleSheet: MarkdownStyleSheet(
                    h1: TextStyle(fontSize: 24, color: colorPrimaryContainer, fontWeight: FontWeight.bold),
                    h2: TextStyle(fontSize: 20, color: colorPrimaryContainer, fontWeight: FontWeight.bold),
                    h3: TextStyle(fontSize: 18, color: colorPrimaryContainer, fontWeight: FontWeight.bold),
                    p: TextStyle(fontSize: 16, color: colorPrimaryContainer),
                  ),
                ),
              )
            ],
          ));
  }
}

class QingZhiListController extends GetxController {
  final RxList<QingZhiData> list = <QingZhiData>[].obs;

  Future<void> load() async {
    final data = await Data.read("qing_zhi.json");
    list.clear();
    list.addAll(data.values.map((e) => QingZhiData.fromJson(e)).toList());
  }

  @override
  void onInit() {
    super.onInit();
    load();
  }
}

class SelectedQingZhiController extends GetxController {
  final Rx<QingZhiData?> selected = Rx<QingZhiData?>(null);

  void select(QingZhiData data) => selected.value = data;
}

class QingZhiData {
  final String nickname;
  final int timestamp;
  final String analysisText;

  QingZhiData.fromJson(Map<String, dynamic> json)
      : nickname = json['nickname'],
        timestamp = json['timestamp'],
        analysisText = json['analysisText'];
}


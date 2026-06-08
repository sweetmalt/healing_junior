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
              Image.asset("assets/images/wuzang.png", width: 400),
              const SizedBox(height: 20),
              MyTextP1(QingZhiCtrl.title),
              const SizedBox(height: 20),
              Table(
                defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                columnWidths: {0: FixedColumnWidth(40), 1: FixedColumnWidth(40), 2: FixedColumnWidth(60), 3: FixedColumnWidth(360)},
                border: TableBorder.all(color: colorPrimary, width: 1, borderRadius: BorderRadius.circular(5)),
                children: [
                  TableRow(children: [
                    Container(alignment: Alignment.center, height: 40, child: MyTextP2("情绪")),
                    Container(alignment: Alignment.center, height: 40, child: MyTextP2("值")),
                    Container(alignment: Alignment.center, height: 40, child: MyTextP2("脏腑")),
                    Container(alignment: Alignment.center, height: 40, child: MyTextP2("关系与机理")),
                  ]),
                  TableRow(
                    decoration: BoxDecoration(color: colorSurface, borderRadius: BorderRadius.circular(10)),
                    children: [
                      Container(
                        alignment: Alignment.center,
                        height: 100,
                        child: MyTextP2("${QingZhiCtrl.emoTitles[0]}"),
                      ),
                      Container(
                        alignment: Alignment.center,
                        height: 100,
                        child: controller.emoValues[0] > 0 ? MyTextP3("${controller.emoValues[0]}", Colors.red) : MyTextP2("${controller.emoValues[0]}"),
                      ),
                      Container(alignment: Alignment.center, height: 100, child: MyTextP2("心")),
                      Container(
                        alignment: Alignment.center,
                        height: 100,
                        padding: EdgeInsets.all(10),
                        child: MyTextP2("喜则气缓。适度的喜乐能使心气舒畅，营卫调和。但过度惊喜或暴喜，会使心气涣散，神不守舍，导致精神无法集中，甚至出现心悸、失眠、嬉笑不休或疯癫等症。"),
                      ),
                    ],
                  ),
                  TableRow(children: [
                    Container(alignment: Alignment.center, height: 100, child: MyTextP2("${QingZhiCtrl.emoTitles[1]}")),
                    Container(
                        alignment: Alignment.center,
                        height: 100,
                        child: controller.emoValues[1] > 0 ? MyTextP3("${controller.emoValues[1]}", Colors.red) : MyTextP2("${controller.emoValues[1]}")),
                    Container(alignment: Alignment.center, height: 100, child: MyTextP2("肝")),
                    Container(
                        alignment: Alignment.center,
                        height: 100,
                        padding: EdgeInsets.all(10),
                        child: MyTextP2("怒则气上。愤怒会使肝气横逆、上冲。表现为：面红目赤、头痛头晕、呕血（气逼血上行），甚至昏厥。长期郁怒，还会导致肝郁气滞，出现胸胁胀痛、月经不调、抑郁寡欢等。")),
                  ]),
                  TableRow(
                    decoration: BoxDecoration(color: colorSurface, borderRadius: BorderRadius.circular(10)),
                    children: [
                      Container(alignment: Alignment.center, height: 100, child: MyTextP2("${QingZhiCtrl.emoTitles[2]}")),
                      Container(
                          alignment: Alignment.center,
                          height: 100,
                          child: controller.emoValues[2] > 0 ? MyTextP3("${controller.emoValues[2]}", Colors.red) : MyTextP2("${controller.emoValues[2]}")),
                      Container(alignment: Alignment.center, height: 100, child: MyTextP2("肺")),
                      Container(
                          alignment: Alignment.center,
                          height: 100,
                          padding: EdgeInsets.all(10),
                          child: MyTextP2("忧则气沉。过度忧虑会耗伤肺气，导致气机闭塞不行。表现为：意志消沉、胸闷气短、咳嗽乏力、声音低微。")),
                    ],
                  ),
                  TableRow(children: [
                    Container(alignment: Alignment.center, height: 100, child: MyTextP2("${QingZhiCtrl.emoTitles[3]}")),
                    Container(
                        alignment: Alignment.center,
                        height: 100,
                        child: controller.emoValues[3] > 0 ? MyTextP3("${controller.emoValues[3]}", Colors.red) : MyTextP2("${controller.emoValues[3]}")),
                    Container(alignment: Alignment.center, height: 100, child: MyTextP2("脾")),
                    Container(
                        alignment: Alignment.center,
                        height: 100,
                        padding: EdgeInsets.all(10),
                        child: MyTextP2("思则气结。思虑过度会使脾气郁结，运化功能失常。表现为：食欲不振、脘腹胀满、消化不良、形体消瘦、失眠健忘。即“思伤脾”。")),
                  ]),
                  TableRow(
                    decoration: BoxDecoration(color: colorSurface, borderRadius: BorderRadius.circular(10)),
                    children: [
                      Container(alignment: Alignment.center, height: 100, child: MyTextP2("${QingZhiCtrl.emoTitles[4]}")),
                      Container(
                          alignment: Alignment.center,
                          height: 100,
                          child: controller.emoValues[4] > 0 ? MyTextP3("${controller.emoValues[4]}", Colors.red) : MyTextP2("${controller.emoValues[4]}")),
                      Container(alignment: Alignment.center, height: 100, child: MyTextP2("肺")),
                      Container(
                          alignment: Alignment.center,
                          height: 100,
                          padding: EdgeInsets.all(10),
                          child: MyTextP2("悲则气消。过度悲哀会耗伤肺气，使上焦不通，营卫不散。表现为：气短懒言、精神萎靡、面色惨淡、哭泣不止。悲和忧都与肺相关。")),
                    ],
                  ),
                  TableRow(children: [
                    Container(alignment: Alignment.center, height: 100, child: MyTextP2("${QingZhiCtrl.emoTitles[5]}")),
                    Container(
                        alignment: Alignment.center,
                        height: 100,
                        child: controller.emoValues[5] > 0 ? MyTextP3("${controller.emoValues[5]}", Colors.red) : MyTextP2("${controller.emoValues[5]}")),
                    Container(alignment: Alignment.center, height: 100, child: MyTextP2("肾")),
                    Container(
                        alignment: Alignment.center,
                        height: 100,
                        padding: EdgeInsets.all(10),
                        child: MyTextP2("恐则气下。恐惧会使肾气不固，气泄于下。表现为：二便失禁、遗精滑泄、骨痿无力、惶惶不安。即“恐伤肾”。")),
                  ]),
                  TableRow(
                    decoration: BoxDecoration(color: colorSurface, borderRadius: BorderRadius.circular(10)),
                    children: [
                      Container(alignment: Alignment.center, height: 100, child: MyTextP2("${QingZhiCtrl.emoTitles[6]}")),
                      Container(
                          alignment: Alignment.center,
                          height: 100,
                          child: controller.emoValues[6] > 0 ? MyTextP3("${controller.emoValues[6]}", Colors.red) : MyTextP2("${controller.emoValues[6]}")),
                      Container(alignment: Alignment.center, height: 100, child: MyTextP2("肾")),
                      Container(
                          alignment: Alignment.center,
                          height: 100,
                          padding: EdgeInsets.all(10),
                          child: MyTextP2("惊则气乱。突然受惊会扰乱心神，使心气紊乱，肾气不固。表现为：心悸心慌、惊慌失措、精神错乱、二便失禁。惊与恐相似，但“惊”为不自知，事出突然；“恐”为自知，俗称胆怯。")),
                    ],
                  ),
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
              const SizedBox(height: 20),
              ExpansionTile(
                initiallyExpanded: false,
                leading: Icon(Icons.navigate_next_rounded),
                expandedCrossAxisAlignment: CrossAxisAlignment.start,
                collapsedShape: Border(top: BorderSide(color: colorPrimary)),
                shape: Border(top: BorderSide(color: colorPrimary)),
                title: MyTextP1("香灸方案"),
                subtitle: MyTextP3("用于情志疗愈的香灸方案", colorPrimaryContainer),
                children: [
                  QingZhiDocView(),
                ],
              ),
              ExpansionTile(
                initiallyExpanded: true,
                leading: Icon(Icons.navigate_next_rounded),
                expandedCrossAxisAlignment: CrossAxisAlignment.start,
                collapsedShape: Border(top: BorderSide(color: colorPrimary)),
                shape: Border(top: BorderSide(color: colorPrimary)),
                title: MyTextP1("情志疗愈音乐"),
                subtitle: MyTextP3("上海音乐学院 · 人工智能音乐疗愈重点实验室", colorPrimaryContainer),
                children: [
                  QingZhiMUsicView(),
                ],
              ),
            ])));
  }
}

class QingZhiCtrl extends GetxController {
  static const String cozeBot = "7633509378907406346";
  Timer? _timer;
  static const String title = "情志疗愈 - 情绪与脏腑关系";
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
    // if (employeeCtrl.paymentTemp.value < 1) {
    //   bearer.value = await employeeCtrl.pay(1);
    // }
    bearer.value = await employeeCtrl.pay(1);
    if (bearer.value.isEmpty) {
      Get.snackbar("故障", "获取coze_token失败，请稍后重试");
      return;
    }
    try {
      analysisText.value = "";
      debugPrint(analysisPrompt.value);
      analysisText.value = await Data.generateAiText(cozeBot, analysisPrompt.value, bearer.value);
      if (analysisText.value.isNotEmpty) {
        //employeeCtrl.paymentTemp.value -= 1;
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

class QingZhiDocView extends GetView {
  const QingZhiDocView({super.key});
  static const qingzhiDoc = {
    "xi": {
      "qingzhi": "喜",
      "zangfu": "心",
      "guanxi": "喜则气缓。适度的喜乐能使心气舒畅，营卫调和。但过度惊喜或暴喜，会使心气涣散，神不守舍，导致精神无法集中，甚至出现心悸、失眠、嬉笑不休或疯癫等症。",
      "zhuangtai": "心悸心慌、失眠多梦、精神不集中、心烦意乱、哭笑无常、神疲乏力",
      "xiangjiu": "先清（泡）：玉足香汤；再调（灸）：玫瑰气韵灸、五行情志香灸（火行）、茉莉香灸、花语私密灸",
      "liaocheng": "轻症：连续7天；中症：连续14天；重症：连续28天；日常舒缓：1-2次/周",
      "jujia": "夏日莲语香、睡若静莲香、鹅梨帐中香、玫瑰香、财神香；香暖贴；内调可选生命之源、玛卡沙棘、胶原三肽",
    },
    "nu": {
      "qingzhi": "怒",
      "zangfu": "肝",
      "guanxi": "怒则气上。愤怒会使肝气横逆、上冲。表现为：面红目赤、头痛头晕、呕血（气逼血上行），甚至昏厥。长期郁怒，还会导致肝郁气滞，出现胸胁胀痛、月经不调、抑郁寡欢等。",
      "zhuangtai": "面红目赤、头晕头痛、胸胁胀痛、烦躁易怒、月经不调、乳房胀痛、嗳气反酸",
      "xiangjiu": "先清（泡）：祛寒养生香汤；再调（灸）：玫瑰香灸、五行情志香灸（木行）、花好月圆灸",
      "liaocheng": "轻症：连续7天；中症：连续14天；重症：连续28天；日常舒缓：1-2次/周",
      "jujia": "春日诗语香、玫瑰香、夏日莲语香、若桃线香；香暖贴；内调可选臻白物语Ⅱ代、花青素、复合端粒离子肽",
    },
    "you": {
      "qingzhi": "忧",
      "zangfu": "肺",
      "guanxi": "忧则气沉。过度忧虑会耗伤肺气，导致气机闭塞不行。表现为：意志消沉、胸闷气短、咳嗽乏力、声音低微。",
      "zhuangtai": "胸闷气短、咳嗽无力、少气懒言、精神萎靡、意志消沉、咽喉不适、呼吸不畅",
      "xiangjiu": "先清（泡澡）：祛湿养生香汤；再调（灸）：茉莉香灸、五行情志香灸（金行）、扶阳舒缓灸、24节气灸",
      "liaocheng": "轻症：连续7天；中症：连续14天；重症：连续28天；日常舒缓：1-2次/周",
      "jujia": "秋日静语香、幽兰线香、睡若静莲香、财神香；香暖贴；内调可选花青素、生命之源、胶原三肽",
    },
    "si": {
      "qingzhi": "思",
      "zangfu": "脾",
      "guanxi": "思则气结。思虑过度会使脾气郁结，运化功能失常。表现为：食欲不振、脘腹胀满、消化不良、形体消瘦、失眠健忘。即“思伤脾”",
      "zhuangtai": "食欲不振、脘腹胀满、消化不良、大便溏稀、神疲乏力、失眠健忘、形体消瘦、口中无味",
      "xiangjiu": "先清（泡）：火莲养生香；再调（灸）：五行情志香灸（土行）、扶阳舒缓灸、24节气灸",
      "liaocheng": "轻症：连续7天；中症：连续14天；重症：连续28天；日常舒缓：1-2次/周",
      "jujia": "脾胃安然香、梅魂线香、春日诗语香、若桃线香；香暖贴；内调可选纤纤物语、玛卡沙棘、复合端粒离子肽",
    },
    "bei": {
      "qingzhi": "悲",
      "zangfu": "肺",
      "guanxi": "悲则气消。过度悲哀会耗伤肺气，使上焦不通，营卫不散。表现为：气短懒言、精神萎靡、面色惨淡、哭泣不止。悲和忧都与肺相关。",
      "zhuangtai": "气短懒言、精神萎靡、面色苍白、时常落泪、胸闷隐痛、咳嗽无痰、四肢乏力",
      "xiangjiu": "先清（泡）：玉臀香汤；再调（灸）：五行情志香灸（金行）、茉莉香灸、颐养元神灸、24节气灸",
      "liaocheng": "轻症：连续7天；中症：连续14天；重症：连续28天；日常舒缓：1-2次/周",
      "jujia": "秋日静语香、睡若静莲香、幽兰线香、财神香；香暖贴；内调可选花青素、生命之源、胶原三肽",
    },
    "kong": {
      "qingzhi": "恐",
      "zangfu": "肾",
      "guanxi": "恐则气下。恐惧会使肾气不固，气泄于下。表现为：二便失禁、遗精滑泄、骨痿无力、惶惶不安。即“恐伤肾”。",
      "zhuangtai": "惶惶不安、心慌胆怯、遗精滑泄、夜尿频繁、腰膝酸软、下肢无力、小便失禁",
      "xiangjiu": "先清（泡）：固本培元香汤；再调（灸）：五行情志香灸（水行）、乾坤通天灸、冬三九灸、花语私密灸",
      "liaocheng": "轻症：连续7天；中症：连续14天；重症：连续28天；日常舒缓：1-2次/周",
      "jujia": "冬日禅语香、吉祥平安香、鹅梨帐中香、若桃线香；香暖贴；内调可选玛卡沙棘、生命之源、秘密花园",
    },
    "jing": {
      "qingzhi": "惊",
      "zangfu": "肾",
      "guanxi": "惊则气乱。突然受惊会扰乱心神，使心气紊乱，肾气不固。表现为：心悸心慌、惊慌失措、精神错乱、二便失禁。惊与恐相似，但“惊”为不自知，事出突然；“恐”为自知，俗称胆怯。",
      "zhuangtai": "心悸心慌、惊慌失措、坐立不安、失眠易醒、夜尿增多、小便失禁、心神不宁",
      "xiangjiu": "先清（泡）：火莲养生香；再调（灸）：玫瑰气韵灸、五行情志香灸（火行+水行）、颐养元神灸、花语私密",
      "liaocheng": "轻症：连续7天；中症：连续14天；重症：连续28天；日常舒缓：1-2次/周",
      "jujia": "睡若静莲香、鹅梨帐中香、冬日禅语香、玫瑰香、财神香；香暖贴；内调可选生命之源、玛卡沙棘、复合端粒离子肽",
    },
  };

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(10),
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colorSecondary,
        borderRadius: BorderRadius.all(Radius.circular(20)),
        boxShadow: [
          BoxShadow(color: Colors.grey, spreadRadius: 1, blurRadius: 1, offset: Offset(0, 1)),
        ],
      ),
      child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 5,
          //遍历 qingzhiDoc
          children: [
            for (var key in qingzhiDoc.keys) ...[
              MyTextH3("情志: ${qingzhiDoc[key]!["qingzhi"]}",colorSecondaryContainer),
              MyTextH3("脏腑: ${qingzhiDoc[key]!["zangfu"]}", colorSurface),
              MyTextP2("🔑 关系与机理"),
              MyTextP2("${qingzhiDoc[key]!["guanxi"]}"),
              MyTextP2("☂ 亚健康状态"),
              MyTextP3("${qingzhiDoc[key]!["zhuangtai"]}", colorError),
              MyTextP2("✔ 香灸方案"),
              MyTextP2("${qingzhiDoc[key]!["xiangjiu"]}"),
              MyTextP2("✿ 疗程建议"),
              MyTextP3("${qingzhiDoc[key]!["liaocheng"]}", colorPrimaryContainer),
              MyTextP2("♨ 居家推荐"),
              MyTextP2("${qingzhiDoc[key]!["jujia"]}"),
              SizedBox(height: 10),
              Divider(height: 1),
            ]
          ]),
    );
  }
}

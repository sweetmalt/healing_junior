import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';
import 'package:get/get.dart';
import 'package:healing_junior/apps/album.dart';
import 'package:healing_junior/apps/customer.dart';
import 'package:healing_junior/apps/employee.dart';
import 'package:healing_junior/data.dart';
import 'package:healing_junior/view.dart';

class DrawView extends GetView<DrawCtrl> {
  DrawView({super.key});

  final isSaving = false.obs;

  @override
  final controller = Get.put(DrawCtrl());
  @override
  Widget build(BuildContext context) {
    double sideLength = MediaQuery.of(context).size.width;
    return Container(
      margin: EdgeInsets.all(10),
      child: Obx(
        () => Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Container(
                  width: 80,
                  height: 100,
                  padding: EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white,
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
                  child: Column(
                    spacing: 10,
                    children: [
                      MyTextP2("安全感"),
                      MyTextH2("${controller.att.value}"),
                    ],
                  ),
                ),
                Container(
                  width: 80,
                  height: 100,
                  padding: EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white,
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
                  child: Column(
                    spacing: 10,
                    children: [
                      MyTextP2("专注度"),
                      MyTextH2("${controller.med.value}"),
                    ],
                  ),
                ),
                Container(
                  width: 80,
                  height: 100,
                  padding: EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white,
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
                  child: Column(
                    spacing: 10,
                    children: [
                      MyTextP2("松弛感"),
                      MyTextH2("${controller.rel.value}"),
                    ],
                  ),
                ),
                Container(
                  width: 80,
                  height: 100,
                  padding: EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white,
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
                  child: Column(
                    spacing: 10,
                    children: [
                      MyTextP2("心流感"),
                      MyTextH2("${controller.flu.value}"),
                    ],
                  ),
                ),
                Container(
                  width: 80,
                  height: 100,
                  padding: EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white,
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
                  child: Column(
                    spacing: 10,
                    children: [
                      MyTextP2("愉悦感"),
                      MyTextH2("${controller.hap.value}"),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 40),
            controller.isReady.value
                ? CircularIconTextButton(
                    text: "AI作画",
                    icon: controller.isGettingImage.value ? Icons.refresh_rounded : Icons.camera,
                    onPressed: () async {
                      if (controller.isGettingImage.value) {
                        Get.snackbar("正在作画", "请稍候……");
                        return;
                      }
                      controller.gettingImageTimer.value = 0;
                      controller.isGettingImage.value = true;
                      try {
                        await controller.draw();
                      } finally {
                        controller.isGettingImage.value = false;
                      }
                    },
                  )
                : SizedBox.shrink(),
            if (controller.isGettingImage.value) MyTextP1("正在作画请稍后……${controller.gettingImageTimer.value}"),
            Container(
              alignment: Alignment.center,
              width: sideLength,
              height: sideLength,
              margin: EdgeInsets.all(10),
              padding: EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white,
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
              child: !controller.isImageExists.value
                  ? Opacity(opacity: 0.1, child: Image.asset("assets/images/brain.png", width: sideLength, height: sideLength))
                  : Image.file(File(controller.imagePath.value), width: sideLength, height: sideLength),
            ),
            const SizedBox(height: 40),
            controller.imageUrl.value != ""
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
            const SizedBox(height: 20),
            CircularIconTextButton(
              text: "相册",
              icon: Icons.album_rounded,
              onPressed: () => Get.to(() => AlbumView()),
            ),
          ],
        ),
      ),
    );
  }
}

class DrawCtrl extends GetxController {
  static const String cozeBot = "7509773070840922149";
  Timer? _timer;
  final isGettingImage = false.obs;
  final isImageExists = false.obs;
  final gettingImageTimer = 0.obs;
  final isGettingAnalysis = false.obs;
  final gettingAnalysisTimer = 0.obs;
  @override
  void onInit() {
    _timer = Timer.periodic(Duration(seconds: 1), (_) {
      if (isGettingImage.value) {
        gettingImageTimer.value++;
      }
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

  final imageUrl = "".obs;
  final imagePath = "".obs;
  final analysisPrompt = "".obs;
  final analysisText = "".obs;
  final att = 50.obs;
  final med = 50.obs;
  final rel = 50.obs;
  final flu = 50.obs;
  final hap = 50.obs;
  final isReady = false.obs;

  final bearer = "".obs;

  final employeeCtrl = Get.put(EmployeeCtrl());
  final customerCtrl = Get.put(CustomerCtrl());
  void init() {
    imageUrl.value = "";
    imagePath.value = "";
    analysisPrompt.value = "";
    analysisText.value = "";
    att.value = 50;
    med.value = 50;
    rel.value = 50;
    flu.value = 50;
    hap.value = 50;
    isReady.value = false;
    bearer.value = "";
  }

  Future<void> draw() async {
    if (!employeeCtrl.isRegist.value) {
      Get.snackbar("请先登录", "未登录或未联网，无法使用AI功能");
      return;
    }
    //余额不足
    if (employeeCtrl.paymentBalance.value < 1) {
      Get.snackbar("请先充值", "您的账号余额不足，无法使用AI功能");
      return;
    }
    if (employeeCtrl.paymentTemp.value < 2) {
      bearer.value = await employeeCtrl.pay(2);
    }
    if (bearer.value.isEmpty) {
      Get.snackbar("异常提示", "网络故障，请稍后重试");
      return;
    }
    String imagePrompt = "专注度${att.value}%、安全感${med.value}%、松弛感${rel.value}%、心流感${flu.value}% 愉悦感${hap.value}%";
    String randomStr = "意境：${contentTheme[Random().nextInt(contentTheme.length)]}";
    String randomStr2 = "意蕴：${auxiliaryElements[Random().nextInt(auxiliaryElements.length)]}";
    String prompt = "$imagePrompt $randomStr $randomStr2";
    try {
      isImageExists.value = false;
      imageUrl.value = await Data.generateAiImage(cozeBot, prompt, bearer.value);
      if (imageUrl.value.length > 20) {
        Get.snackbar("成功", "图片已生成，正在下载到本机，请耐心等候……");
        String sexandgae = "性别${customerCtrl.sex.value} 年龄${customerCtrl.age.value}岁";
        analysisPrompt.value = "${imageUrl.value}\n $imagePrompt $sexandgae";
        analysisText.value = "";
        String sub = imageUrl.value.substring(20, imageUrl.value.length - 1);
        if (sub.isNotEmpty) {
          String savePath = await Data.path("$sub.png");
          if (await Data.downloadAndSaveImage(imageUrl.value, savePath)) {
            imagePath.value = savePath;
            isImageExists.value = true;
            if (await Data.saveImageToGallery(savePath)) {
              save();
              employeeCtrl.paymentTemp.value -= 2;
            }
          }
        }
      }
    } catch (e) {
      //Get.snackbar("异常提示", "图片生成失败，请稍后重试");
    }
  }

  Future<void> analysis() async {
    if (analysisPrompt.value.isEmpty) {
      Get.snackbar("提示", "请先生成图片");
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
      analysisText.value = await Data.generateAiText("7581779378108629035", analysisPrompt.value, bearer.value);
      if (analysisText.value.isNotEmpty) {
        employeeCtrl.paymentTemp.value -= 1;
        save();
      }
    } catch (e) {
      Get.snackbar("失败", "分析失败，请稍后重试");
    }
  }

  Future<void> save() async {
    Map<String, dynamic> data = await Data.read("draw.json");
    data[customerCtrl.phone.value] = {
      "nickname": customerCtrl.nickname.value,
      "timestamp": DateTime.now().millisecondsSinceEpoch,
      "imageUrl": imageUrl.value,
      "imagePath": imagePath.value,
      "analysisPrompt": analysisPrompt.value,
      "analysisText": analysisText.value,
      "att": att.value,
      "med": med.value,
      "rel": rel.value,
      "flu": flu.value,
      "hap": hap.value,
    };
    await Data.write(data, "draw.json");
    Get.snackbar("成功", "图片已保存至本软件的自有相册");
  }

  Future<Map<String, dynamic>> read(String phone) async {
    Map<String, dynamic> data = await Data.read("draw.json");
    if (!data.containsKey(phone)) {
      return {};
    }
    return data[phone];
  }

  static const List<String> contentTheme = [
    "几何曲线",
    "佛光普照",
    "绿树村边合，青山郭外斜",
    "茅檐低小，溪上青青草",
    "梅子金黄杏子肥",
    "两个黄鹂鸣翠柳",
    "孤帆远影碧空尽",
    "接天莲叶无穷碧",
    "千里莺啼绿映红",
    "窗含西岭千秋雪",
    "烟笼寒水月笼沙",
    "市桥灯火连霄汉",
    "万家弦管送新秋",
    "飞流直下三千尺",
    "潮平两岸阔",
    "明月松间照",
    "天女散花",
    "月圆花好",
    "月满花香",
    "月露风云",
    "皓月千里",
    "众星拱月",
    "斗转星移",
    "星罗棋布",
    "天涯海角",
    "碧海青天",
    "春光明媚",
    "湖光山色",
    "天光云影",
    "山清水秀",
    "水碧山青",
    "水天一色",
    "天寒地冻",
    "滴水成冰",
    "冰天雪地",
    "白雪皑皑",
    "风花雪月",
    "雪泥鸿爪",
    "冰清玉洁",
    "云窗雾阁",
    "雾里看花",
    "霞光万道",
    "锦绣河山",
    "沧海桑田",
    "海纳百川",
    "海阔天空",
    "一马平川",
    "万紫千红",
    "层峦叠嶂",
    "崇山峻岭",
    "耸入云霄",
    "深山密林",
    "千山万水",
    "桃红柳绿",
    "古木参天",
    "繁花似锦",
    "玫瑰花海",
    "油菜花田",
    "自然风光",
    "金光大道",
    "金山银山",
    "几何曲面"
  ];

  static const List<String> auxiliaryElements = [
    "千里马",
    "独角兽",
    "梅花鹿",
    "和平鸽",
    "萤火虫",
    "内部有风暴或星云的水晶球",
    "会发光的微型蘑菇群",
    "缓慢旋转的克莱因瓶",
    "开满鲜花的钟表齿轮",
    "缠绕着光线的藤蔓",
    "半透明的缎带光带",
    "山雨欲来风满楼",
    "样式复古的街灯",
    "长着翅膀的钥匙",
    "飘散的星尘粒子",
    "半透明的阶梯",
    "金银珠宝",
    "大地回春",
    "日落西山",
    "日月合璧",
    "日薄桑榆",
    "白虹贯日",
    "月明星稀",
    "月明如水",
    "雨过天晴",
    "云开雾散",
    "云情雨意",
    "云屯星聚",
    "云中仙鹤",
    "云淡风轻",
    "云蒸霞蔚",
    "冰消云散",
    "风月无边",
    "风和日丽",
    "碧空如洗",
    "晴空万里",
    "阳光明媚",
    "天朗气清",
    "天清日白",
    "秋高气爽",
    "拨云见日",
    "雨后彩虹",
    "瓢泼大雨",
    "狂风暴雨",
    "山呼海啸",
    "水滴石穿",
    "星火燎原",
    "尘土飞扬",
    "微风轻拂",
    "碧波荡漾",
    "烟波浩渺",
    "百鸟朝凤",
    "万马奔腾",
    "汹涌澎湃",
    "热火朝天",
    "流光溢彩",
    "上下翻飞",
    "草长莺飞",
    "龙凤呈祥",
    "招蜂引蝶"
  ];
}

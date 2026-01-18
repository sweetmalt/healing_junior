// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:healing_junior/ctrl.dart';
// import 'package:healing_junior/data.dart';
// import 'package:healing_junior/view.dart';
// import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';

// class ReportList extends GetView<ReportListController> {
//   ReportList({super.key});
//   @override
//   final ReportListController controller = Get.put(ReportListController());
//   final ReporPageController reportPageController = Get.put(ReporPageController());
//   final RxString start = 'report'.obs;

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//         appBar: AppBar(
//           title: Text(
//             controller.title,
//             style: TextStyle(
//               fontSize: 20,
//               color: ThemeData().colorScheme.primary,
//               fontWeight: FontWeight.bold,
//             ),
//           ),
//           actions: [
//             IconButton(
//               icon: const Icon(
//                 Icons.arrow_back_ios_rounded,
//                 size: 30,
//               ),
//               onPressed: () {
//                 Get.back();
//               },
//             ),
//           ],
//         ),
//         body: SingleChildScrollView(
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.start,
//             crossAxisAlignment: CrossAxisAlignment.stretch,
//             children: [
//               ListTile(
//                 title: InputDecorator(
//                   decoration: InputDecoration(
//                     enabledBorder: InputBorder.none,
//                     labelText: '搜索（请输入用户ID）',
//                   ),
//                   child: TextField(
//                     onChanged: (value) {
//                       start.value = 'report_$value';
//                     },
//                   ),
//                 ),
//                 trailing: ElevatedButton(
//                   child: Icon(Icons.search_rounded),
//                   onPressed: () {
//                     controller.getReportFileList(start.value);
//                   },
//                 ),
//               ),
//               SingleChildScrollView(
//                   child: Obx(() => Column(
//                         children: [
//                           for (int i = 0; i < controller.reportFileList.length; i++)
//                             ListTile(
//                               title: Text(
//                                 controller.reportFileList[i].split('_')[1],
//                                 style: TextStyle(
//                                   fontSize: 20,
//                                   color: ThemeData().colorScheme.primary,
//                                 ),
//                               ),
//                               subtitle: Text(controller.reportFileList[i].split('_')[2].split('.')[0]),
//                               leading: Icon(
//                                 Icons.receipt_long_rounded,
//                                 color: ThemeData().colorScheme.primary,
//                                 size: 30,
//                               ),
//                               onTap: () {
//                                 reportPageController.getReport(controller.reportFileList[i]).then((_) => Get.to(() => ReportPage()));
//                               },
//                               trailing: ElevatedButton(
//                                 child: Text("删除"),
//                                 onPressed: () {
//                                   _showDeleteDialog(context, i);
//                                 },
//                               ),
//                             ),
//                         ],
//                       )))
//             ],
//           ),
//         ));
//   }

//   Future<void> _showDeleteDialog(BuildContext context, int index) async {
//     return showDialog<void>(
//       context: context,
//       barrierDismissible: false, // 用户必须点击按钮才能关闭对话框
//       builder: (BuildContext context) {
//         return AlertDialog(
//           title: const Text('删除报告'),
//           content: const SingleChildScrollView(
//             child: ListBody(
//               children: <Widget>[
//                 Text('您确定要执行此操作吗？'),
//               ],
//             ),
//           ),
//           actions: <Widget>[
//             TextButton(
//               child: const Text('取消'),
//               onPressed: () {
//                 Navigator.of(context).pop(); // 关闭对话框
//               },
//             ),
//             TextButton(
//               child: const Text('确认'),
//               onPressed: () {
//                 // 执行删除操作
//                 deleteReport(index, start.value);
//                 Navigator.of(context).pop();
//               },
//             ),
//           ],
//         );
//       },
//     );
//   }

//   void deleteReport(int index, String start) async {
//     if (await Data.delete('${controller.reportFileList[index]}')) {
//       await controller.getReportFileList(start);
//     }
//   }
// }

// class ReportListController extends GetxController {
//   final String title = '压力评测 - 报告 文件夹';
//   final RxList reportFileList = [].obs;

//   @override
//   void onInit() async {
//     super.onInit();
//     await getReportFileList('report');
//   }

//   Future<void> getReportFileList(String start) async {
//     reportFileList.clear();
//     reportFileList.value = await Data.readFileList(start);
//   }
// }

// class ReportPage extends GetView<ReporPageController> {
//   ReportPage({super.key});
//   @override
//   final ReporPageController controller = Get.put(ReporPageController());
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//         appBar: AppBar(
//           title: Text(controller.title),
//           actions: [
//             IconButton(
//               icon: const Icon(Icons.share),
//               onPressed: () async {
//                 //await Data.shareReport(controller.report['nickname'], '压力', int.parse(controller.report['timestamp']));
//               },
//             ),
//             IconButton(
//               icon: const Icon(Icons.arrow_back_ios_rounded),
//               onPressed: () {
//                 Get.back();
//               },
//             ),
//           ],
//         ),
//         body: SingleChildScrollView(
//             padding: EdgeInsets.all(10),
//             child: SizedBox(
//                 width: MediaQuery.of(context).size.width,
//                 child: Column(
//                   spacing: 10,
//                   mainAxisSize: MainAxisSize.min,
//                   crossAxisAlignment: CrossAxisAlignment.stretch,
//                   children: [
//                     const SizedBox(height: 20),
//                     MyTextH1("报告"),
//                     MyTextP3(Data.formatTimestamp(controller.report['timestamp']), colorSecondary),
//                     MyTextP2("时长：${controller.bciCount}秒"),
//                     MyTextP2("学号：${controller.report['nickname']}"),
//                     MyTextP2("年龄：${controller.report['age']}岁"),
//                     MyTextP2(controller.report['sex'] == 0 ? "性别：男" : "性别：女"),
//                     const SizedBox(height: 20),
//                     Container(
//                       color: colorSecondaryContainer,
//                       child: SizedBox(
//                         height: 2,
//                         width: context.width,
//                       ),
//                     ),
//                     const SizedBox(height: 40),
//                     MyTextH2("压力自察"),
//                     MyTextH3(controller.getSelfAssessment(controller.report["QA"]), Colors.blueAccent),
//                     const SizedBox(height: 40),
//                     MyTextH2("实测心理压力"),
//                     MyTextH3("数值：${controller.stressPsych.value}    状态：${controller.getStressPsych(controller.stressPsych.value)}", Colors.blueAccent),

//                     MyTextP2('''
// 心理压力状态对应数值区间：
// 暂无 (<=0.35)：对应深度放松状态，α和θ波占主导，β波极少。
// 轻微 (0.35~0.55)：日常放松状态，能有效调节情绪。
// 一般 (0.55~0.75)：正常学习生活中的压力水平，可自我调节。
// 较高 (0.75~1)：持续紧张状态，可能出现注意力分散、睡眠问题等。
// 超高 (>1)：强烈焦虑，β波过度活跃，需专业干预。
// '''),
//                     MyTextH2("实测心脏压力"),
//                     MyTextH3("数值：${controller.stressHeart.value}    状态：${controller.getStressHeart(controller.stressHeart.value)}", Colors.blueAccent),

//                     MyTextP2('''
// 心脏压力状态对应数值区间：
// 暂无 (<=1.5)：深度放松、睡眠质量高，运动恢复良好。
// 轻微 (1.5~2.5)：日常学习生活状态，偶有轻微紧张但可快速调节。
// 一般 (2.5~4)：持续课业负担、情绪紧张，伴注意力下降或睡眠变浅。
// 较高 (4~6)：慢性疲劳、焦虑倾向，常见心慌、多汗或胃肠功能紊乱。
// 超高 (>6)：自主神经失调，心血管风险显著升高，需专业干预。
// '''),
//                     MyTextH2("平均心率"),
//                     MyTextH3("${controller.heartRate.value}次/分", Colors.blueAccent),
//                     MyTextP2("普遍55~85，55以下偏低，85以上偏高"),

//                     const SizedBox(height: 40),
//                     AiTextView(controller), //AI分析
//                     const SizedBox(height: 40),
//                     MyTextH2("基础数据"),
//                     MyTextP2("样本量：${controller.bciCount.value}"),
//                     Row(
//                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                       children: [
//                         MyTextH3("脑电图", colorSecondary),
//                         Obx(() => ElevatedButton(
//                             onPressed: () {
//                               controller.isBciChartFlaying.value = !controller.isBciChartFlaying.value;
//                             },
//                             child: Text(
//                               controller.isBciChartFlaying.value ? "收起" : "展开",
//                               style: TextStyle(
//                                 fontSize: 14,
//                                 color: ThemeData().colorScheme.primary,
//                               ),
//                             )))
//                       ],
//                     ),
//                     WaveChart8(
//                       controller: controller.bci8WaveController,
//                       isFlay: controller.isBciChartFlaying,
//                       height: 200,
//                     ),
//                     Center(
//                       child: SingleChildScrollView(
//                         child: Row(
//                           spacing: 1,
//                           mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                           children: [
//                             Text("Delta", style: TextStyle(backgroundColor: colorList[7])),
//                             Text("Theta", style: TextStyle(backgroundColor: colorList[6])),
//                             Text("LowAlpha", style: TextStyle(backgroundColor: colorList[5])),
//                             Text("HighAlpha", style: TextStyle(backgroundColor: colorList[4])),
//                             Text("LowBeta", style: TextStyle(backgroundColor: colorList[3])),
//                             Text("HighBeta", style: TextStyle(backgroundColor: colorList[2])),
//                             Text("LowGamma", style: TextStyle(backgroundColor: colorList[1])),
//                             Text("MidGamma", style: TextStyle(backgroundColor: colorList[0]))
//                           ],
//                         ),
//                       ),
//                     ),
//                     const SizedBox(height: 40),
//                     MyTextH2("变化趋势( 基于${controller.historyReportCount.value}次检测 )"),
//                     MyTextP2("检测两次以上才能看到变化趋势"),
//                     Obx(() => controller.isHistoryReportExists.value
//                         ? Container(
//                             padding: EdgeInsets.all(10),
//                             decoration: BoxDecoration(
//                               borderRadius: BorderRadius.circular(20),
//                               color: colorSecondaryContainer,
//                             ),
//                             child: Column(
//                               children: [
//                                 SizedBox(height: 40),
//                                 StressView(height: 300, controller: controller.stressPsychWaveController),
//                                 MyTextP2("心理压力变化趋势图"),
//                                 SizedBox(height: 40),
//                                 StressView(height: 300, controller: controller.stressHeartWaveController),
//                                 MyTextP2("心脏压力变化趋势图"),
//                                 SizedBox(height: 40),
//                                 StressView(height: 300, controller: controller.heartRateWaveController),
//                                 MyTextP2("平均心率变化趋势图"),
//                                 SizedBox(height: 40),
//                               ],
//                             ),
//                           )
//                         : SizedBox()),
//                     Container(
//                       alignment: Alignment.center,
//                       transformAlignment: Alignment.center,
//                       height: 200,
//                       child: MyTextP3("Copyright 2025 HealingAI", colorPrimary),
//                     ),
//                   ],
//                 ))));
//   }
// }

// class ReporPageController extends GetxController {
//   final String title = '压力评测 - 报告';
//   String _fileName = '';
//   String get fileName => _fileName;
//   String _aiPrompt = '';
//   String get aiPrompt => _aiPrompt;
//   RxString aiText = ''.obs;
//   RxBool isAiLoading = false.obs;
//   RxString aiImageUrl = ''.obs;
//   RxBool isAiImageLoading = false.obs;
//   RxString aiImageFilePath = ''.obs;
//   String aiImageFilePath_ = '';
//   RxBool isAiImageExists = false.obs;
//   RxString aiTextFileName = ''.obs;
//   RxBool isAiTextExists = false.obs;
//   RxBool isShowSuggest = false.obs;
//   RxBool isBciChartFlaying = true.obs;
//   Map<String, dynamic> get report => _report;
//   final Map<String, dynamic> _report = {
//     "nickname": "", //学号
//     "age": 12, // 年龄
//     "sex": 1, //性别
//     "timestamp": "", //时间戳
//     "uuid": "",
//     "QA": "",

//     ///bci数据
//     "bciDataDelta": [],
//     "bciDataTheta": [],
//     "bciDataLowAlpha": [],
//     "bciDataHighAlpha": [],
//     "bciDataLowBeta": [],
//     "bciDataHighBeta": [],
//     "bciDataLowGamma": [],
//     "bciDataMiddleGamma": [],
//     "bciDataTemperature": [],
//     "bciDataHeartRate": [],
//     "bciCount": 0,

//     ///hrv数据
//     "hrvData": [],

//     ///
//     "stressPsych": 0.5,
//     "stressHeart": 2.0,
//     "heartRate": 60,
//     //
//     "fileName": "" //文件名
//   };

//   Map<String, dynamic> bciAtt = {};
//   Map<String, dynamic> bciMed = {};
//   RxInt bciCount = 0.obs;

//   ///脑电图
//   final WaveChart8Controller bci8WaveController = WaveChart8Controller(minY: 0, maxY: 1);

//   ///压力指数
//   RxDouble stressPsych = 0.0.obs; //心理压力指数
//   RxDouble stressHeart = 0.0.obs; //心脏压力指数
//   //
//   RxInt heartRate = 0.obs;

//   ///历史数据
//   RxBool isHistoryReportExists = false.obs;
//   RxList historyReportFileList = [].obs;
//   RxInt historyReportCount = 0.obs;
//   RxList historyStressPsych = [].obs;
//   RxList historyStressHeart = [].obs;
//   RxList historyHeartRate = [].obs;
//   final StressController stressPsychWaveController = StressController(minY: 0, maxY: 1);
//   final StressController stressHeartWaveController = StressController(minY: 0, maxY: 6);
//   final StressController heartRateWaveController = StressController(minY: 0, maxY: 200);

//   ///
//   Future<void> getReport(String fileName) async {
//     _fileName = fileName;
//     _report['fileName'] = fileName;
//     List<String> lf = fileName.split("_");
//     if (lf.length == 3) {
//       aiImageUrl.value = "";
//       String png = "image_${lf[1]}_${lf[2].split(".")[0]}.png";
//       aiImageFilePath_ = await Data.path(png);
//       aiImageFilePath.value = aiImageFilePath_;
//       isAiImageExists.value = false;
//       if (await Data.exists(png)) {
//         isAiImageExists.value = true;
//       }
//       String txt = "text_${lf[1]}_${lf[2].split(".")[0]}.json";
//       aiTextFileName.value = txt;
//       isAiTextExists.value = false;
//       aiText.value = "";
//       if (await Data.exists(txt)) {
//         isAiTextExists.value = true;
//         Map<String, dynamic> jsonObj = await Data.read(txt);
//         aiText.value = jsonObj['aiText'];
//       }
//     }
//     isAiLoading.value = false;

//     Map<String, dynamic> reportTemp = await Data.read(fileName);
//     _report['nickname'] = reportTemp['nickname'];
//     _report['age'] = reportTemp['age'];
//     _report['sex'] = reportTemp['sex'];
//     _report['timestamp'] = reportTemp['timestamp'];
//     _report['uuid'] = reportTemp['uuid'];
//     _report['QA'] = reportTemp['QA'];

//     ///bci数据
//     _report['bciDataDelta'] = reportTemp['bciDataDelta'];
//     _report['bciDataTheta'] = reportTemp['bciDataTheta'];
//     _report['bciDataLowAlpha'] = reportTemp['bciDataLowAlpha'];
//     _report['bciDataHighAlpha'] = reportTemp['bciDataHighAlpha'];
//     _report['bciDataLowBeta'] = reportTemp['bciDataLowBeta'];
//     _report['bciDataHighBeta'] = reportTemp['bciDataHighBeta'];
//     _report['bciDataLowGamma'] = reportTemp['bciDataLowGamma'];
//     _report['bciDataMiddleGamma'] = reportTemp['bciDataMiddleGamma'];
//     _report['bciDataTemperature'] = reportTemp['bciDataTemperature'];
//     _report['bciDataHeartRate'] = reportTemp['bciDataHeartRate'];
//     _report['bciCount'] = reportTemp['bciCount'];
//     //
//     int pureCount = 0;
//     Map<String, dynamic> reportPure = {
//       "bciDataDelta": [],
//       "bciDataTheta": [],
//       "bciDataLowAlpha": [],
//       "bciDataHighAlpha": [],
//       "bciDataLowBeta": [],
//       "bciDataHighBeta": [],
//       "bciDataLowGamma": [],
//       "bciDataMiddleGamma": [],
//       "bciDataTemperature": [],
//       "bciDataHeartRate": [],
//     };
//     for (int i = 0; i < bciCount.value; i++) {
//       if (reportTemp['bciDataDelta'][i] > 0 &&
//           reportTemp['bciDataDelta'][i] < 100000 &&
//           reportTemp['bciDataTheta'][i] > 0 &&
//           reportTemp['bciDataTheta'][i] < 100000 &&
//           reportTemp['bciDataLowAlpha'][i] > 0 &&
//           reportTemp['bciDataLowAlpha'][i] < 100000 &&
//           reportTemp['bciDataHighAlpha'][i] > 0 &&
//           reportTemp['bciDataHighAlpha'][i] < 100000 &&
//           reportTemp['bciDataLowBeta'][i] > 0 &&
//           reportTemp['bciDataLowBeta'][i] < 100000 &&
//           reportTemp['bciDataHighBeta'][i] > 0 &&
//           reportTemp['bciDataHighBeta'][i] < 100000 &&
//           reportTemp['bciDataLowGamma'][i] > 0 &&
//           reportTemp['bciDataLowGamma'][i] < 100000 &&
//           reportTemp['bciDataMiddleGamma'][i] > 0 &&
//           reportTemp['bciDataMiddleGamma'][i] < 100000 &&
//           pureCount < 128) {
//         pureCount++;
//         reportPure['bciDataDelta'].add(reportTemp['bciDataDelta'][i]);
//         reportPure['bciDataTheta'].add(reportTemp['bciDataTheta'][i]);
//         reportPure['bciDataLowAlpha'].add(reportTemp['bciDataLowAlpha'][i]);
//         reportPure['bciDataHighAlpha'].add(reportTemp['bciDataHighAlpha'][i]);
//         reportPure['bciDataLowBeta'].add(reportTemp['bciDataLowBeta'][i]);
//         reportPure['bciDataHighBeta'].add(reportTemp['bciDataHighBeta'][i]);
//         reportPure['bciDataLowGamma'].add(reportTemp['bciDataLowGamma'][i]);
//         reportPure['bciDataMiddleGamma'].add(reportTemp['bciDataMiddleGamma'][i]);
//         reportPure['bciDataTemperature'].add(reportTemp['bciDataTemperature'][i]);
//         reportPure['bciDataHeartRate'].add(reportTemp['bciDataHeartRate'][i]);
//       }
//       if (pureCount == 128) {
//         // 数据完整
//         break;
//       } else {
//         // 数据不完整
//       }
//     }

//     ///
//     _report['stressPsych'] = reportTemp['stressPsych'];
//     _report['stressHeart'] = reportTemp['stressHeart'];
//     _report['heartRate'] = reportTemp['heartRate'];

//     ///
//     stressPsych.value = (_report['stressPsych'] * 1000).toInt() / 1000;
//     stressHeart.value = (_report['stressHeart'] * 1000).toInt() / 1000;
//     heartRate.value = (_report['heartRate']).toInt();

//     ///脑电图
//     bciCount.value = _report['bciCount'];
//     bci8WaveController.clearData();
//     for (int i = 0; i < bciCount.value; i++) {
//       double a = _report['bciDataDelta'][i] +
//           _report['bciDataTheta'][i] +
//           _report['bciDataLowAlpha'][i] +
//           _report['bciDataHighAlpha'][i] +
//           _report['bciDataLowBeta'][i] +
//           _report['bciDataHighBeta'][i] +
//           _report['bciDataLowGamma'][i] +
//           _report['bciDataMiddleGamma'][i];
//       double x = 0.0;
//       x += _report['bciDataDelta'][i] / a;
//       await bci8WaveController.addDataPoint(bci8WaveController.dataFlSpot7, x);
//       x += _report['bciDataTheta'][i] / a;
//       await bci8WaveController.addDataPoint(bci8WaveController.dataFlSpot6, x);
//       x += _report['bciDataLowAlpha'][i] / a;
//       await bci8WaveController.addDataPoint(bci8WaveController.dataFlSpot5, x);
//       x += _report['bciDataHighAlpha'][i] / a;
//       await bci8WaveController.addDataPoint(bci8WaveController.dataFlSpot4, x);
//       x += _report['bciDataLowBeta'][i] / a;
//       await bci8WaveController.addDataPoint(bci8WaveController.dataFlSpot3, x);
//       x += _report['bciDataHighBeta'][i] / a;
//       await bci8WaveController.addDataPoint(bci8WaveController.dataFlSpot2, x);
//       x += _report['bciDataLowGamma'][i] / a;
//       await bci8WaveController.addDataPoint(bci8WaveController.dataFlSpot1, x);
//       x += _report['bciDataMiddleGamma'][i] / a;
//       await bci8WaveController.addDataPoint(bci8WaveController.dataFlSpot0, x);
//     }

//     ///AI
//     String sex = _report['sex'] == 0 ? '男' : '女';
//     _aiPrompt = [
//       "性别$sex",
//       "年龄${_report['age']}岁",
//       "压力状态自评:${getSelfAssessment(_report['QA'])}",
//       "心理压力实测值${stressPsych.value} 状态:${getStressPsych(stressPsych.value)}",
//       "心脏压力实测值${stressHeart.value} 状态:${getStressHeart(stressHeart.value)}",
//       "平均心率${heartRate.value}次/分钟"
//     ].where((s) => s.isNotEmpty).toList().join("，");

//     ///历史数据
//     isHistoryReportExists.value = false;
//     historyStressPsych.clear();
//     historyStressHeart.clear();
//     historyHeartRate.clear();
//     stressPsychWaveController.clearData();
//     stressHeartWaveController.clearData();
//     heartRateWaveController.clearData();

//     historyReportFileList.clear();
//     historyReportFileList.value = await Data.readFileList('report_${_report['nickname']}');
//     historyReportCount.value = historyReportFileList.length;
//     if (historyReportFileList.length > 1) {
//       isHistoryReportExists.value = true;
//       for (int i = historyReportFileList.length - 1; i >= 0; i--) {
//         Map<String, dynamic> historyReport = await Data.read(historyReportFileList[i]);
//         historyStressPsych.add(historyReport['stressPsych']);
//         historyStressHeart.add(historyReport['stressHeart']);
//         historyHeartRate.add(historyReport['heartRate']);
//         //
//         stressPsychWaveController.addDataPoint(historyReport['stressPsych']);
//         stressHeartWaveController.addDataPoint(historyReport['stressHeart']);
//         heartRateWaveController.addDataPoint(historyReport['heartRate'].toDouble());
//       }
//     }
//   }

//   ///获取综合压力自评
//   String getSelfAssessment(int value) {
//     switch (value) {
//       case 0:
//         return "暂无";
//       case 1:
//         return "轻微";
//       case 2:
//         return "一般";
//       case 3:
//         return "较高";
//       case 4:
//         return "超高";
//       default:
//         return "";
//     }
//   }

//   /// 获取心理压力评级
// // 五级心理压力状态对应的β/(α+θ)比值区间：
// // 暂无(<=0.35)：对应深度放松状态，α和θ波占主导，β波极少
// // 轻微(0.35~0.55)：日常放松状态，能有效调节情绪
// // 一般(0.55~0.75)：正常学习生活中的压力水平，可自我调节
// // 较高(0.75~1)：持续紧张状态，可能出现注意力分散、睡眠问题等
// // 超高(>1)：强烈焦虑，β波过度活跃，需专业干预
//   String getStressPsych(double value) {
//     if (value <= 0.35) {
//       return "暂无(<=0.35)";
//     } else if (value > 0.35 && value <= 0.55) {
//       return "轻微(0.35~0.55)";
//     } else if (value > 0.55 && value <= 0.75) {
//       return "一般(0.55~0.75)";
//     } else if (value > 0.75 && value <= 1) {
//       return "较高(0.75~1)";
//     }
//     return "超高(>1)";
//   }

//   /// 获取心脏压力评级
// // 五级心脏压力状态对应的LF/HF比值区间：
// // 暂无(<=1.5)：深度放松、睡眠质量高，运动恢复良好
// // 轻微(1.5~2.5)：日常学习生活状态，偶有轻微紧张但可快速调节
// // 一般(2.5~4)：持续课业负担、情绪紧张，伴注意力下降或睡眠变浅
// // 较高(4~6)：慢性疲劳、焦虑倾向，常见心慌、多汗或胃肠功能紊乱
// // 超高(>6)：自主神经失调，心血管风险显著升高，需专业干预
//   String getStressHeart(double value) {
//     if (value <= 1.5) {
//       return "暂无(<=1.5)";
//     } else if (value > 1.5 && value <= 2.5) {
//       return "轻微(1.5~2.5)";
//     } else if (value > 2.5 && value <= 4) {
//       return "一般(2.5~4)";
//     } else if (value > 4 && value <= 6) {
//       return "较高(4~6)";
//     }
//     return "超高(>6)";
//   }
// }

// class BciSlider extends StatelessWidget {
//   final double value;
//   final double maxValue;
//   final String title;
//   final Color color;

//   const BciSlider({super.key, required this.title, required this.color, required this.value, required this.maxValue});

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       margin: const EdgeInsets.only(left: 10, right: 10),
//       padding: const EdgeInsets.only(left: 10, right: 10),
//       child: Row(
//         children: [
//           Text(title),
//           Expanded(
//               child: SliderTheme(
//                   data: SliderTheme.of(context).copyWith(
//                     trackHeight: 3,
//                     activeTrackColor: color,
//                     thumbColor: ThemeData().colorScheme.surface,
//                     inactiveTrackColor: ThemeData().colorScheme.primaryContainer,
//                   ),
//                   child: Slider(
//                     min: 0.0,
//                     max: maxValue,
//                     value: value > maxValue ? maxValue : value,
//                     onChanged: (double value) {},
//                   ))),
//           Text("占比 ${((value / maxValue) * 1000).toInt() / 10}% ${getAttr(value, maxValue)}"),
//         ],
//       ),
//     );
//   }

//   String getAttr(double value, double maxValue) {
//     if (value > maxValue * 0.2) {
//       return "偏高";
//     }
//     if (value < maxValue * 0.1) {
//       return "偏低";
//     }
//     return "均衡";
//   }
// }

// class StatisticsContainerCircleMini extends Container {
//   final String title;
//   final double value;
//   final bool isShowAsScaling;
//   final Color valueColor;
//   StatisticsContainerCircleMini(this.title, this.value, this.isShowAsScaling, this.valueColor, {super.key});
//   @override
//   Widget build(BuildContext context) {
//     return Stack(alignment: Alignment.center, children: [
//       Container(
//         width: 160,
//         height: 160,
//         margin: const EdgeInsets.all(5),
//         decoration: BoxDecoration(
//           borderRadius: BorderRadius.circular(80),
//         ),
//         child: CircularProgressIndicator(
//           backgroundColor: Colors.grey,
//           valueColor: AlwaysStoppedAnimation<Color>(valueColor),
//           value: isShowAsScaling ? value : 1,
//           strokeWidth: 20,
//         ),
//       ),
//       Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           if (isShowAsScaling == true)
//             Text('${(value * 1000).toInt() / 10}%',
//                 style: const TextStyle(
//                   fontSize: 20,
//                   fontWeight: FontWeight.bold,
//                 ))
//           else
//             Text('${(value * 100).toInt() / 100}',
//                 style: const TextStyle(
//                   fontSize: 20,
//                   fontWeight: FontWeight.bold,
//                 )),
//           Text(
//             title,
//           ),
//         ],
//       ),
//     ]);
//   }
// }

// class SuggestView extends GetView {
//   @override
//   final ReporPageController controller;
//   SuggestView(this.controller, {super.key});
//   final MyCtrl deportController = Get.find();
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//         width: double.infinity,
//         padding: const EdgeInsets.all(10),
//         decoration: BoxDecoration(
//             color: ThemeData().colorScheme.surface,
//             borderRadius: const BorderRadius.all(Radius.circular(10)),
//             border: Border.all(
//               color: ThemeData().colorScheme.primaryContainer,
//               width: 1,
//             )),
//         child: Column(children: [
//           ElevatedButton(
//               style: ButtonStyle(
//                 backgroundColor: WidgetStateProperty.all(
//                   ThemeData().colorScheme.primaryContainer,
//                 ),
//               ),
//               onPressed: () {
//                 controller.isShowSuggest.value = !controller.isShowSuggest.value;
//               },
//               child: const Text('建议信')),
//           Obx(() => controller.isShowSuggest.value
//               ? Column(spacing: 10, mainAxisAlignment: MainAxisAlignment.start, crossAxisAlignment: CrossAxisAlignment.start, children: [
//                   const SizedBox(
//                     height: 20,
//                   ),
//                   MyTextH2("“定制您的专属焕新之旅！”"),
//                   MyTextP2("写信时间：${Data.formatTimestamp(controller.report['timestamp'])}"),
//                   MyTextP2("顾客昵称：${controller.report['nickname']}"),
//                   MyTextP2("顾客年龄：${controller.report['age']}岁"),
//                   MyTextP2("顾客性别：${controller.report['sex'] == 0 ? "男" : "女"}"),
//                   MyTextP2(
//                       "亲爱的朋友，\n感谢您选择与我们共同踏上这段身心疗愈的旅程!\n通过脑波数据采集与AI分析，我们有幸听到您内在身心健康最真实的“喃喃细语”，结合我们现有服务能力，为您量身定制如下专属疗愈方案。愿这份方案能如春日细雨，滋养您的能量场域，助力您以更笃定的姿态持续拥有内在强大的平衡与活力。"),
//                   const SizedBox(height: 60),
//                   Container(
//                     color: colorSecondaryContainer,
//                     child: SizedBox(
//                       height: 2,
//                       width: context.width,
//                     ),
//                   ),
//                   const SizedBox(height: 80),
//                   Container(
//                     color: colorSecondaryContainer,
//                     child: SizedBox(
//                       height: 2,
//                       width: context.width,
//                     ),
//                   ),
//                   const SizedBox(height: 20),
//                   MyTextH3("细分能量平衡与疗愈建议", colorSecondary),
//                   MyTextP3("侧重偏高部分：配合音疗、光疗，主调和", colorSecondary),
//                   MyTextP3("侧重偏低部分：配合食疗、芳疗，主温补", colorSecondary),
//                   Container(
//                     color: colorSecondaryContainer,
//                     child: SizedBox(
//                       height: 2,
//                       width: context.width,
//                     ),
//                   ),
//                   const SizedBox(height: 20),
//                   MyTextH3("七大能量与五蕴疗愈服务", colorSecondary),
//                   MyTextP3("能量驿站 疗愈服务项目2025版", colorPrimary),
//                   const SizedBox(height: 20),
//                   Row(mainAxisAlignment: MainAxisAlignment.center, children: [
//                     Image.asset(
//                       "assets/images/7e5s.png",
//                       width: 400,
//                     )
//                   ]),
//                   MyTextP1("全息能量"),
//                   MyTextP2('''
// 缺失：脊椎僵硬、头昏脑涨、神经紧张、焦虑不安
// 改善：全身轻松、神清目明、轻松愉悦、气定神闲
// 靶向：脑垂体
// 五蕴：色/AI光疗+声/AI音疗+香/全息和香+味/全息茶+触/全息能量霜与手法服务
// 指标：愉悦感
// '''),
//                   MyTextP1("睡眠能量"),
//                   MyTextP2('''
// 缺失：失眠头疼、记忆下降、容易困倦、容易伤感
// 改善：安睡清醒、提升记忆、集中精力、开心觉醒
// 靶向：松果体
// 五蕴：色/AI光疗+声/AI音疗+香/睡眠和香+味/睡眠茶+触/睡眠能量霜与手法服务
// 指标：松弛感
// '''),
//                   MyTextP1("代谢能量"),
//                   MyTextP2('''
// 缺失：呼吸问题、肠胃问题、肩颈劳损、易胖易怒
// 改善：呼吸顺畅、改善肠胃、身体轻松、情绪平和
// 靶向：甲状腺
// 五蕴：色/AI光疗+声/AI音疗+香/代谢和香+味/代谢茶+触/代谢能量霜与手法服务
// 指标：心流指数
// '''),
//                   MyTextP1("免疫能量"),
//                   MyTextP2('''
// 缺失：容易感冒、乳腺增生、皮肤暗淡、无力易胖
// 改善：增强体质、改善结节、肤色改善、改变身形
// 靶向：胸腺
// 五蕴：色/AI光疗+声/AI音疗+香/免疫和香+味/免疫茶+触/免疫能量霜与手法服务
// 指标：专注度
// '''),
//                   MyTextP1("消化能量"),
//                   MyTextP2('''
// 缺失：消化不良、大腹便便、气血亏虚、五心烦躁
// 改善：调理脾胃、身线窈窕、气血旺盛、神清气爽
// 靶向：胰腺
// 五蕴：色/AI光疗+声/AI音疗+香/消化和香+味/消化茶+触/消化能量霜与手法服务
// 指标：安全感
// '''),
//                   MyTextP1("幸福能量"),
//                   MyTextP2('''
// 缺失：月经不调、性欲降低、皮肤衰老、烦躁失眠
// 改善：例假正常、敏感润滑、紧致细腻、心情愉悦
// 靶向：性腺
// 五蕴：色/AI光疗+声/AI音疗+香/幸福和香+味/幸福茶+触/幸福能量霜与手法服务
// 指标：NN50
// '''),
//                   MyTextP1("动力能量"),
//                   MyTextP2('''
// 缺失：困倦乏力、长期便秘、腰腹肥胖、了无生趣
// 改善：充满活力、肠清身轻、精神十足、热情积极
// 靶向：肾上腺
// 五蕴：色/AI光疗+声/AI音疗+香/动力和香+味/动力茶+触/动力能量霜与手法服务
// 指标：LFHF
// '''),
//                   const SizedBox(height: 60),
//                   Container(
//                     color: colorSecondaryContainer,
//                     child: SizedBox(
//                       height: 2,
//                       width: context.width,
//                     ),
//                   ),
//                   const SizedBox(height: 20),
//                   MyTextH3("温馨提醒", colorSecondary),
//                   MyTextP2("具体疗愈方案选择，请咨询您的专属疗愈师"),
//                   MyTextP2("为了更好的疗愈体验，请您："),
//                   const ListTile(
//                     leading: Icon(Icons.check_circle_outline),
//                     title: Text('疗愈前'),
//                     subtitle: Text("请提前放下手机等电子设备，保持平静"),
//                   ),
//                   const ListTile(
//                     leading: Icon(Icons.check_circle_outline),
//                     title: Text('疗愈中'),
//                     subtitle: Text("正确穿戴脑机设备，让检测数据更精准"),
//                   ),
//                   const ListTile(
//                     leading: Icon(Icons.check_circle_outline),
//                     title: Text('疗愈后'),
//                     subtitle: Text("可再做一次检测，从点滴改善中发现更适合自己的项目"),
//                   ),
//                   const SizedBox(height: 60),
//                   Container(
//                     color: colorSecondaryContainer,
//                     child: SizedBox(
//                       height: 2,
//                       width: context.width,
//                     ),
//                   ),
//                   const SizedBox(height: 20),
//                   MyTextH3("结语", colorSecondary),
//                   MyTextP2("亲爱的朋友，真正的疗愈始于对自我的慈悲觉察。请相信，每一刻的关照都会在时光中沉淀为生命的光彩。我们愿做您旅程中的温暖烛火，静候您绽放身心原生的力量。"),
//                   MyTextP2("顺颂，"),
//                   MyTextP2("安康！"),
//                   MyTextP2("您的专属疗愈师：${deportController.user.adminNickname.value}"),
//                   const SizedBox(height: 40),
//                   Row(mainAxisAlignment: MainAxisAlignment.center, children: [
//                     MyTextP3("能量", colorPrimary),
//                     Image.asset("assets/images/logo.png", width: 100, height: 100),
//                     MyTextP3("驿站", colorSecondary),
//                   ]),
//                 ])
//               : const Text("点击按钮查看")),
//         ]));
//   }
// }

// class AiTextView extends GetView {
//   @override
//   final ReporPageController controller;

//   AiTextView(this.controller, {super.key});

//   final MyCtrl mainController = Get.find();
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       width: double.infinity,
//       padding: const EdgeInsets.all(20),
//       decoration: BoxDecoration(
//           color: ThemeData().colorScheme.surface,
//           borderRadius: const BorderRadius.all(Radius.circular(10)),
//           border: Border.all(
//             color: colorSecondaryContainer,
//             width: 1,
//           )),
//       child: Column(children: [
//         ElevatedButton(
//             style: ButtonStyle(
//               backgroundColor: WidgetStateProperty.all(
//                 ThemeData().colorScheme.primaryContainer,
//               ),
//             ),
//             onPressed: () async {
//               if (controller.isAiLoading.value == true) {
//                 return;
//               }
//               controller.isAiLoading.value = true;
//               //登录
//               if (mainController.user.loginState.value != 2) {
//                 controller.isAiLoading.value = false;
//                 Get.snackbar(
//                   "请先登录",
//                   "未登录或未联网，无法使用AI功能",
//                   colorText: colorSurface,
//                   backgroundColor: colorPrimary,
//                   snackPosition: SnackPosition.BOTTOM,
//                   margin: const EdgeInsets.all(10),
//                 );
//                 return;
//               }
//               //余额不足
//               if (mainController.user.tokens.value + mainController.user.usingTokens.value < 1) {
//                 controller.isAiLoading.value = false;
//                 Get.snackbar(
//                   "请先充值",
//                   "您的账号余额不足，无法使用AI功能",
//                   colorText: colorSurface,
//                   backgroundColor: colorPrimary,
//                   snackPosition: SnackPosition.BOTTOM,
//                   margin: const EdgeInsets.all(10),
//                 );
//                 return;
//               }
//               if (mainController.user.usingTokens.value <= 0) {
//                 await mainController.user.useOneToken();
//               }
//               if (mainController.user.usingTokens.value > 0) {
//                 String ai = await Data.generateAiText(
//                   "7536880378519339044",
//                   controller.aiPrompt,
//                   mainController.user.bearer.value,
//                 );
//                 if (ai.length > 100) {
//                   controller.aiText.value = ai;
//                   await Data.write({"aiText": controller.aiText.value}, controller.aiTextFileName.value);
//                   mainController.user.usingTokens.value -= 1;
//                   await mainController.user.cache();
//                 } else {
//                   Get.snackbar(
//                     "AI分析失败",
//                     "请稍后重试",
//                     colorText: colorSurface,
//                     backgroundColor: colorPrimary,
//                     snackPosition: SnackPosition.BOTTOM,
//                     margin: const EdgeInsets.all(10),
//                   );
//                 }
//               } else {
//                 Get.snackbar(
//                   "支付服务异常",
//                   "请联系管理员处理",
//                   colorText: colorSurface,
//                   backgroundColor: colorPrimary,
//                   snackPosition: SnackPosition.BOTTOM,
//                   margin: const EdgeInsets.all(10),
//                 );
//               }
//               controller.isAiLoading.value = false;
//             },
//             child: Obx(() => controller.isAiLoading.value ? const CircularProgressIndicator() : const Text('AI分析&减压建议'))),
//         const SizedBox(
//           height: 20,
//         ),
//         Obx(() => Text(
//               controller.isAiLoading.value ? "AI调用需要5~10秒，请耐心等待……" : "",
//               style: const TextStyle(fontSize: 16),
//             )),
//         Obx(() => MarkdownBody(
//             data: controller.aiText.value,
//             styleSheet: MarkdownStyleSheet(
//               h1: TextStyle(fontSize: 24, color: colorSecondary, fontWeight: FontWeight.bold),
//               h2: TextStyle(fontSize: 20, color: colorSecondary, fontWeight: FontWeight.bold),
//               h3: TextStyle(fontSize: 18, color: colorSecondary, fontWeight: FontWeight.bold),
//               p: TextStyle(fontSize: 18, color: colorSecondary),
//             ))),
//       ]),
//     );
//   }
// }

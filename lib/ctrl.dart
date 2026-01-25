import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:healing_junior/apps/baseline.dart';
import 'package:healing_junior/apps/bci.dart';
import 'package:healing_junior/apps/brain_load.dart';
import 'package:healing_junior/apps/customer.dart';
import 'package:healing_junior/apps/draw.dart';
import 'package:healing_junior/apps/heart_rate.dart';
import 'package:healing_junior/apps/hrv.dart';
import 'package:healing_junior/apps/pressure.dart';
import 'package:healing_junior/apps/resting.dart';
import 'package:healing_junior/apps/setting.dart';
import 'package:healing_junior/apps/staff.dart';
import 'package:healing_junior/apps/trend.dart';
import 'package:healing_junior/apps/waves.dart';
import 'package:healing_junior/apps/wuluohai.dart';
import 'package:healing_junior/data.dart';
import 'package:just_audio/just_audio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:share_plus/share_plus.dart';

// List<Color> colorList = [
//   Colors.purple,
//   Colors.deepPurpleAccent,
//   Colors.blue,
//   Colors.green,
//   const Color.fromARGB(255, 255, 200, 0),
//   Colors.orange,
//   Colors.red,
//   Colors.white
// ];
// List<String> color8CN = ["银色", "红色", "橙色", "金色", "绿色", "青色", "蓝色", "紫色"];
// List<IconData> iconList = [
//   Icons.sentiment_very_satisfied_rounded,
//   Icons.sentiment_satisfied_rounded,
//   Icons.sentiment_neutral_rounded,
//   Icons.sentiment_dissatisfied_rounded,
//   Icons.sentiment_very_dissatisfied_rounded
// ];
// List<String> brainWaves8 = ["delta", "theta", "lowAlpha", "highAlpha", "lowBeta", "highBeta", "lowGamma", "middleGamma"];
// List<String> brainWaves8CN = ["δ波", "θ波", "低α波", "高α波", "低β波", "高β波", "低γ波", "中γ波"];
// List<String> brainWaves5 = ["δ", "θ", "α", "β", "γ"];
// List<String> brainWaves5EN = ["delta", "theta", "alpha", "beta", "gamma"];
// List<String> brainWaves5CN = ["δ波", "θ波", "α波", "β波", "γ波"];
// List<String> xing5 = ["金", "水", "木", "火", "土"];
// List<String> gua8Base = ["乾", "巽", "离", "艮", "兑", "砍", "震", "坤"];
// List<String> gua8Thing = ["天", "风", "火", "山", "泽", "水", "雷", "地"];
// List<String> gua8Number = ["000", "001", "010", "011", "100", "101", "110", "111"];
// List<String> gua64 = [
//   "乾",
//   "坤",
//   "屯",
//   "蒙",
//   "需",
//   "讼",
//   "师",
//   "比",
//   "小畜",
//   "履",
//   "泰",
//   "否",
//   "同人",
//   "大有",
//   "谦",
//   "豫",
//   "随",
//   "蛊",
//   "临",
//   "观",
//   "噬嗑",
//   "贲",
//   "剥",
//   "复",
//   "无妄",
//   "大畜",
//   "颐",
//   "大过",
//   "坎",
//   "离",
//   "咸",
//   "恒",
//   "遁",
//   "大壮",
//   "晋",
//   "明夷",
//   "家人",
//   "睽",
//   "蹇",
//   "解",
//   "损",
//   "益",
//   "夬",
//   "姤",
//   "萃",
//   "升",
//   "困",
//   "井",
//   "革",
//   "鼎",
//   "震",
//   "艮",
//   "渐",
//   "小过",
//   "旅",
//   "巽",
//   "兑",
//   "涣",
//   "节",
//   "中孚",
//   "小过",
//   "大过",
//   "未济"
// ];
// List<String> shengxiao12 = ["鼠", "牛", "虎", "兔", "龙", "蛇", "马", "羊", "猴", "鸡", "狗", "猪"];
// List<String> shengxiao12Flower = ["梅花", "荷花", "桃花", "兰花", "梨花", "竹花", "杏花", "樱花", "松树", "苓花", "菊花", "桂花"];
// Map<String, String> musicTitles = {
//   "唤醒": "使人从睡眠或低迷状态中清醒，恢复意识与活力，开启新的一天。",
//   "激活": "激发内在潜能，调动身心积极性，为行动做好准备。",
//   "修复": "对受损的身心进行调养，缓解伤痛，帮助恢复至健康平衡状态。",
//   "放松（紧张）": "因压力等产生情绪紧绷，身体肌肉收缩，肌肉收缩，心理不安，需放松舒缓。",
//   "安宁（焦虑）": "内心过度担忧，思绪杂乱，对未来充满不安，影响正常生活。",
//   "温暖（忧郁）": "情绪低落，难以自拔，对事物缺乏兴趣，沉浸在悲伤氛围中，难以走出阴霾。",
//   "舒缓（焦躁）": "使紧张的情绪得到放松，身体舒展，使紧张情绪松弛，释放心理压力。",
//   "鼓舞（抑郁）": "长期情绪压抑，失去活力，对生活绝望，伴有消极思维。",
//   "喜悦": "内心充满快乐，情绪高涨，对周围事物感到愉悦和满足，感染周围氛围。",
//   "静心": "排除杂念，使内心平静，专注于当下，内心平和，达到精神纯净状态",
//   "宁静": "环境或心境安静祥和，远离喧嚣，享受平和安宁。",
//   "平衡": "调和身心，调和身心，稳定生理心理，避免极端情绪，维持和谐。",
//   "助眠": "帮助入睡，缓解失眠困扰，营造舒适睡眠环境，引导放松。",
//   "注意力": "集中精神，聚焦于特定任务或对象，提高专注度，提升工作学习效率。",
//   "探索": "对未知领域充满好奇，主动求知、新体验，拓展认知边界，对未知好奇，寻求新体验。",
//   "记忆力": "增强大脑对信息的存储和回忆能力，助力学习记忆，提升认知。",
//   "专注力": "全身心投入某件事，不受外界干扰，保持高度注意，高效完成任务。",
//   "创造力": "激发创新思维，突破常规，产生独特新颖的想法和解决方案。",
//   "洞察力": "深入观察和理解事物本质，敏锐捕捉细节，洞察人心和局势。",
//   "空": "内心虚无，放下执念，以空灵的心态接纳万物，感悟生命真谛。",
//   "悟": "经过思考和体验，突然领悟道理，实现心灵的升华和成长。",
//   "云游": "仿佛灵魂脱离肉体，在想象的空间中自由遨游，感受无拘无束，想象驰骋。",
//   "筑梦": "怀揣梦想，努力构建未来蓝图，充满希望前行，追逐理想。",
// };
// Map<int, String> noteMap = {
//   10: "1",
//   9: "2",
//   8: "3",
//   7: "4",
//   6: "5",
//   5: "6",
//   4: "7",
//   3: "8",
// };
// List<String> chakra7 = ["海底轮", "生殖轮", "太阳神经丛轮", "心轮", "喉轮", "眉心轮", "顶轮"];
// //
// List<String> notBetaList = ["delta", "theta", "lowAlpha", "highAlpha", "lowGamma", "middleGamma"];

class MyCtrl extends GetxController {
  final List<GlobalKey> expansionKeys = List.generate(16, (i) => GlobalKey(debugLabel: 'expansion_$i'));
  Future<void> shareReport(String type, int timestamp) async {
    Get.defaultDialog(
      title: '分享报告',
      middleText: '正在生成分享文件，请稍后...',
      barrierDismissible: false,
      actions: [CircularProgressIndicator()],
    );
    try {
      List<Uint8List> images = await _captureWidget(expansionKeys);
      await _createAndSharePDF(images, type, timestamp);
    } finally {
      Get.back();
    }
  }

  Future<List<Uint8List>> _captureWidget(List<GlobalKey> keys) async {
    final images = <Uint8List>[];
    try {
      for (int i = 0; i < keys.length; i++) {
        if (settingCtrl.states[i] == false) {
          continue;
        }
        final boundary = keys[i].currentContext?.findRenderObject() as RenderRepaintBoundary?;
        final image = await boundary?.toImage(pixelRatio: 2);
        final byteData = await image?.toByteData(format: ImageByteFormat.png);
        if (byteData != null) {
          images.add(byteData.buffer.asUint8List());
        }
      }
      return images;
    } catch (e) {
      return [];
    }
  }

  Future<void> _createAndSharePDF(List<Uint8List> images, String type, int timestamp) async {
    if (images.isEmpty) {
      return;
    }
    final pdf = pw.Document();
    for (final image in images) {
      final codec = await instantiateImageCodec(image);
      final frame = await codec.getNextFrame();
      final imageWidth = frame.image.width;
      final imageHeight = frame.image.height;
      final pwImage = pw.MemoryImage(image);
      pdf.addPage(pw.Page(
        pageFormat: PdfPageFormat(imageWidth.toDouble(), imageHeight.toDouble()),
        build: (pw.Context context) {
          return pw.Center(
            child: pw.Image(pwImage, fit: pw.BoxFit.contain),
          );
        },
      ));
    }
    final directory = await getApplicationDocumentsDirectory();
    final fileName = '${directory.path}/pdf_${customerCtrl.nickname.value}的$type报告_${Data.formatTimestamp("$timestamp")}';
    final pdfPath = '$fileName.pdf';
    final pdfFile = File(pdfPath);
    await pdfFile.writeAsBytes(await pdf.save());
    SharePlus.instance.share(ShareParams(
      files: [XFile(pdfPath)],
      text: '分享给好友',
    ));
  }

  static const eventChannel = EventChannel('top.healingAI.brainlink/receiver');
  StreamSubscription? _bciAndHrvBroadcastListener;
  Timer? _resetTimer;
  // final RxBool isConnect = false.obs;
  // final RxBool isConnectTimer = false.obs;
  // final RxBool isRecording = false.obs;
  // final User user = User();
  // ///
  // final RxString customerNickname = 'Rose'.obs;
  // final RxString uuid = ''.obs;
  // final RxInt customerAge = 18.obs;
  // final RxInt customerSex = 1.obs;
  // List<String> customerAS = ["暂无", "轻微", "一般", "较高", "超高"];
  // RxInt customerQAIndex = 0.obs;
  // ///
  // //脑波
  // final List<double> bciDataDelta = <double>[];
  // final List<double> bciDataTheta = <double>[];
  // final List<double> bciDataLowAlpha = <double>[];
  // final List<double> bciDataHighAlpha = <double>[];
  // final List<double> bciDataLowBeta = <double>[];
  // final List<double> bciDataHighBeta = <double>[];
  // final List<double> bciDataLowGamma = <double>[];
  // final List<double> bciDataMiddleGamma = <double>[];
  // //额温
  // final List<double> bciDataTemperature = <double>[];
  // //心率
  // final List<double> bciDataHeartRate = <double>[];
  // //情绪
  // final List<double> bciDataAtt = <double>[];
  // final List<double> bciDataMed = <double>[];
  // //
  // final Map<String, List<double>> _bciData = {
  //   //情绪
  //   "att": <double>[],
  //   "med": <double>[],
  //   //脑波
  //   'delta': <double>[],
  //   'theta': <double>[],
  //   'lowAlpha': <double>[],
  //   'highAlpha': <double>[],
  //   'lowBeta': <double>[],
  //   'highBeta': <double>[],
  //   'lowGamma': <double>[],
  //   'middleGamma': <double>[],
  //   //额温
  //   'temperature': <double>[],
  //   //心率
  //   'heartRate': <double>[],
  // };
  // final RxInt pureCount = 0.obs;
  final AudioPlayer _audioPlayer = AudioPlayer();
  Future<void> playAudio(String audio) async {
    try {
      await _audioPlayer.setAsset('assets/audios/$audio.MP3');
      await _audioPlayer.setVolume(0.5);
      await _audioPlayer.play();
    } on PlatformException catch (e) {
      debugPrint('播放错误: ${e.message}');
    }
  }

  // ///
  // WavesController wavesController = WavesController();
  // WavesController pureController = WavesController();
  // WavesController mvController = WavesController();
  // WavesController trendController = WavesController();
  // WavesController deepthController = WavesController();
  // WavesController signController = WavesController();
  // WavesController activityController = WavesController();
  // //
  // WavesController trendBaseLowBetaController = WavesController();
  // WavesController mvBaseLowBetaController = WavesController();
  // WavesController signBaseLowBetaController = WavesController();
  // WavesController activityBaseLowBetaController = WavesController();
  // final RxInt baseLowBetaTimes = 0.obs;
  // final RxDouble baseLowBetaRate = 0.0.obs;
  // final RxInt baseLowBetaTimesDelta = 0.obs;
  // final RxDouble baseLowBetaRateDelta = 0.0.obs;
  // final RxInt baseLowBetaTimesTheta = 0.obs;
  // final RxDouble baseLowBetaRateTheta = 0.0.obs;
  // final RxInt baseLowBetaTimesLowAlpha = 0.obs;
  // final RxDouble baseLowBetaRateLowAlpha = 0.0.obs;
  // final RxInt baseLowBetaTimesHighAlpha = 0.obs;
  // final RxDouble baseLowBetaRateHighAlpha = 0.0.obs;
  // final RxInt baseLowBetaTimesLowGamma = 0.obs;
  // final RxDouble baseLowBetaRateLowGamma = 0.0.obs;
  // final RxInt baseLowBetaTimesMiddleGamma = 0.obs;
  // final RxDouble baseLowBetaRateMiddleGamma = 0.0.obs;
  // final RxInt baseLowBetaMv = 0.obs;
  // final RxInt baseLowBetaTrend = 0.obs;
  // final RxDouble baseLowBetaSign = 0.0.obs;
  // final RxDouble baseLowBetaActivity = 0.0.obs;
  // final RxString baseLowBetaQueenName = "".obs;
  // final RxInt baseLowBetaQueenTimes = 0.obs;
  // final RxDouble baseLowBetaQueenPercent = 0.0.obs;
  // final RxInt baseLowBetaQueenMv = 0.obs;
  // final RxInt baseLowBetaQueenTrend = 0.obs;
  // final RxDouble baseLowBetaQueenSign = 0.0.obs;
  // final RxDouble baseLowBetaQueenActivity = 0.0.obs;
  // final RxDouble baseLowBetaQueenSignTop = 0.0.obs;
  // final RxInt baseLowBetaQueenSignTopPoint = 0.obs;
  // final RxDouble baseLowBetaQueenSignTopPercent = 0.0.obs;
  // final RxDouble baseLowBetaQueenSignTopMv = 0.0.obs;
  // final RxDouble baseLowBetaQueenActivityTop = 0.0.obs;
  // final RxInt baseLowBetaQueenActivityTopPoint = 0.obs;
  // final RxDouble baseLowBetaQueenActivityTopPercent = 0.0.obs;
  // final RxDouble baseLowBetaQueenActivityTopMv = 0.0.obs;
  // //
  // WavesController trendBaseHighBetaController = WavesController();
  // WavesController mvBaseHighBetaController = WavesController();
  // WavesController signBaseHighBetaController = WavesController();
  // WavesController activityBaseHighBetaController = WavesController();
  // final RxInt baseHighBetaTimes = 0.obs;
  // final RxDouble baseHighBetaRate = 0.0.obs;
  // final RxInt baseHighBetaTimesDelta = 0.obs;
  // final RxDouble baseHighBetaRateDelta = 0.0.obs;
  // final RxInt baseHighBetaTimesTheta = 0.obs;
  // final RxDouble baseHighBetaRateTheta = 0.0.obs;
  // final RxInt baseHighBetaTimesLowAlpha = 0.obs;
  // final RxDouble baseHighBetaRateLowAlpha = 0.0.obs;
  // final RxInt baseHighBetaTimesHighAlpha = 0.obs;
  // final RxDouble baseHighBetaRateHighAlpha = 0.0.obs;
  // final RxInt baseHighBetaTimesLowGamma = 0.obs;
  // final RxDouble baseHighBetaRateLowGamma = 0.0.obs;
  // final RxInt baseHighBetaTimesMiddleGamma = 0.obs;
  // final RxDouble baseHighBetaRateMiddleGamma = 0.0.obs;
  // final RxInt baseHighBetaMv = 0.obs;
  // final RxInt baseHighBetaTrend = 0.obs;
  // final RxDouble baseHighBetaSign = 0.0.obs;
  // final RxDouble baseHighBetaActivity = 0.0.obs;
  // final RxString baseHighBetaQueenName = "".obs;
  // final RxInt baseHighBetaQueenTimes = 0.obs;
  // final RxDouble baseHighBetaQueenPercent = 0.0.obs;
  // final RxInt baseHighBetaQueenMv = 0.obs;
  // final RxInt baseHighBetaQueenTrend = 0.obs;
  // final RxDouble baseHighBetaQueenSign = 0.0.obs;
  // final RxDouble baseHighBetaQueenActivity = 0.0.obs;
  // final RxDouble baseHighBetaQueenSignTop = 0.0.obs;
  // final RxInt baseHighBetaQueenSignTopPoint = 0.obs;
  // final RxDouble baseHighBetaQueenSignTopPercent = 0.0.obs;
  // final RxDouble baseHighBetaQueenSignTopMv = 0.0.obs;
  // final RxDouble baseHighBetaQueenActivityTop = 0.0.obs;
  // final RxInt baseHighBetaQueenActivityTopPoint = 0.obs;
  // final RxDouble baseHighBetaQueenActivityTopPercent = 0.0.obs;
  // final RxDouble baseHighBetaQueenActivityTopMv = 0.0.obs;
  // //
  // WavesTableController wavesTableController = WavesTableController();
  // BetaTableController lowBetaTableController = BetaTableController();
  // BetaTableController highBetaTableController = BetaTableController();
  // final RxDouble basePercent = 0.0.obs;
  // final RxDouble pressValue = 0.0.obs;
  // final RxDouble leftPressValue = 0.0.obs;
  // final RxDouble rightPressValue = 0.0.obs;
  // final RxDouble sensitiveValue = 0.0.obs;
  // final RxInt sensitivePoint = 0.obs;
  // final RxString sensitiveWave = "".obs;
  // //
  // final RxInt lowAlphaTrend = 0.obs;
  // final RxDouble lowAlphaSign = 0.0.obs;
  // final RxInt highAlphaTrend = 0.obs;
  // final RxDouble highAlphaSign = 0.0.obs;
  // final RxInt lowBetaTrend = 0.obs;
  // final RxDouble lowBetaSign = 0.0.obs;
  // final RxInt highBetaTrend = 0.obs;
  // final RxDouble highBetaSign = 0.0.obs;
  // //
  // final RxDouble curHeartRate = 60.0.obs;
  // //
  // final RxInt emoV1 = 0.obs;
  // final RxInt emoV2 = 0.obs;
  // final RxInt emoV3 = 0.obs;
  // final RxInt emoV4 = 0.obs;
  // final RxInt emoV5 = 0.obs;
  // final RxInt emoV6 = 0.obs;
  // final RxInt emoV7 = 0.obs;
  // final RxInt emoV8 = 0.obs;
  // final RxInt emoV9 = 0.obs;
  // final RxInt emoV10 = 0.obs;
  // final RxInt emoV11 = 0.obs;
  // final RxInt emoV12 = 0.obs;
  // final RxInt emoV13 = 0.obs;
  // final RxInt emoV14 = 0.obs;
  // final RxInt emoV15 = 0.obs;
  // final RxInt emoV16 = 0.obs;
  // //
  // final RxDouble lowBetaBase = 10000.0.obs;
  // final RxDouble lowBetaMin = 5000.0.obs;
  // final RxDouble highBetaBase = 10000.0.obs;
  // final RxDouble highBetaMin = 5000.0.obs;
  // //
  // final RxDouble brainLoad = 1.0.obs;
  // final RxDouble brainLoadTop = 1.0.obs;
  // final RxDouble brainLoadTemp = 1.0.obs;
  // //
  // final RxDouble haloDelta = 0.3.obs;
  // final RxDouble haloTheta = 0.4.obs;
  // final RxDouble haloLowAlpha = 0.5.obs;
  // final RxDouble haloHighAlpha = 0.6.obs;
  // final RxDouble haloLowBeta = 0.7.obs;
  // final RxDouble haloHighBeta = 0.8.obs;
  // final RxDouble haloLowGamma = 0.9.obs;
  // final RxDouble haloMiddleGamma = 1.0.obs;
  // //
  // final RxInt wuluohaiMusicIndex = (-1).obs;
  // final RxList staffNoteList = [].obs;
  // //
  // final RxDouble chakra0Delta = 1.0.obs;
  // final RxDouble chakra1Theta = 1.0.obs;
  // final RxDouble chakra2LowAlpha = 1.0.obs;
  // final RxDouble chakra3HighAlpha = 1.0.obs;
  // final RxDouble chakra4LowBeta = 1.0.obs;
  // final RxDouble chakra5HighBeta = 1.0.obs;
  // final RxDouble chakra6LowGamma = 1.0.obs;
  // final RxDouble chakra7MiddleGamma = 1.0.obs;

  ///
  final int upperLimit = 400000;
  final RxInt comeCount = 0.obs;
  final RxInt pureCount = 0.obs;

  ///脑波
  final List<double> bciDataDelta = <double>[];
  final List<double> bciDataTheta = <double>[];
  final List<double> bciDataAlpha = <double>[];
  final List<double> bciDataBeta = <double>[];
  final List<double> bciDataGamma = <double>[];
  //额温
  final List<double> bciDataTemperature = <double>[];
  //心率
  final List<double> bciDataHeartRate = <double>[];
  //情绪
  final List<double> bciDataAtt = <double>[];
  final List<double> bciDataMed = <double>[];

  ///
  final settingCtrl = Get.put(SettingCtrl());
  final wavesCtrl = Get.put(WavesCtrl());
  final baselineCtrl = Get.put(BaselineCtrl());
  final bciCtrl = Get.put(BciCtrl());
  final heartRateCtrl = Get.put(HeartRateCtrl());
  final customerCtrl = Get.put(CustomerCtrl());
  final wuluohaiCtrl = Get.put(WuluohaiCtrl());
  final staffCtrl = Get.put(StaffCtrl());
  final restingCtrl = Get.put(RestingCtrl());
  final brainLoadCtrl = Get.put(BrainLoadCtrl());
  final drawCtrl = Get.put(DrawCtrl());
  final trendCtrl = Get.put(TrendCtrl());
  final pressureCtrl = Get.put(PressureCtrl());
  //
  @override
  void onInit() {
    super.onInit();

    _resetTimer = Timer.periodic(Duration(seconds: 5), (_) {
      // if (isConnectTimer.value == false) {
      //   isConnect.value = false;
      // } else {
      //   isConnectTimer.value = false;
      // }
    });
    // user.init();
    // wavesController.setIsCurved(true);
    // wavesController.setBarWidth(3);
    // //
    // pureController.setBarWidth(1);
    // pureController.setIsCurved(true);
    // mvController.setBarWidth(1);
    // mvController.setIsCurved(true);
    // //
    // trendController.setBarWidth(1);
    // trendController.setHeight(320);
    // trendController.setMinY(-1);
    // trendController.setMaxY(1);
    // deepthController.setBarWidth(1);
    // deepthController.setHeight(320);
    // deepthController.setMinY(0);
    // deepthController.setMaxY(4);
    // signController.setBarWidth(1);
    // signController.setHeight(320);
    // signController.setMinY(-1);
    // signController.setMaxY(1);
    // activityController.setBarWidth(1);
    // activityController.setHeight(320);
    // activityController.setMaxY(2);
    // //
    // trendBaseLowBetaController.setBarWidth(1);
    // trendBaseLowBetaController.setHeight(320);
    // trendBaseLowBetaController.setMaxY(1);
    // mvBaseLowBetaController.setBarWidth(1);
    // mvBaseLowBetaController.setHeight(320);
    // mvBaseLowBetaController.setMinY(-1);
    // mvBaseLowBetaController.setMaxY(1);
    // signBaseLowBetaController.setBarWidth(1);
    // signBaseLowBetaController.setHeight(320);
    // signBaseLowBetaController.setMaxY(1);
    // activityBaseLowBetaController.setBarWidth(1);
    // activityBaseLowBetaController.setHeight(320);
    // activityBaseLowBetaController.setMaxY(5);
    // //
    // trendBaseHighBetaController.setBarWidth(1);
    // trendBaseHighBetaController.setHeight(320);
    // trendBaseHighBetaController.setMaxY(1);
    // mvBaseHighBetaController.setBarWidth(1);
    // mvBaseHighBetaController.setHeight(320);
    // mvBaseHighBetaController.setMinY(-1);
    // mvBaseHighBetaController.setMaxY(1);
    // signBaseHighBetaController.setBarWidth(1);
    // signBaseHighBetaController.setHeight(320);
    // signBaseHighBetaController.setMaxY(1);
    // activityBaseHighBetaController.setBarWidth(1);
    // activityBaseHighBetaController.setHeight(320);
    // activityBaseHighBetaController.setMaxY(5);
    // //
    // wavesTableController.initData();
    // lowBetaTableController.initData();
    // highBetaTableController.initData();
    //侦听脑波数据
    _bciAndHrvBroadcastListener = eventChannel.receiveBroadcastStream().listen((data) async {
      // isConnect.value = true;
      // isConnectTimer.value = true;
      List<String> temp = data.toString().split('_');
      if (temp.length == 2) {
        if (temp[0] == "bci") {
          temp = temp[1].split(',');
          if (temp.length == 15) {
            double att = double.parse(temp[0]);
            double med = double.parse(temp[1]);
            double delta = double.parse(temp[3]);
            double theta = double.parse(temp[4]);
            double lowAlpha = double.parse(temp[5]);
            double highAlpha = double.parse(temp[6]);
            double alpha = lowAlpha + highAlpha;
            double lowBeta = double.parse(temp[7]);
            double highBeta = double.parse(temp[8]);
            double beta = lowBeta + highBeta;
            double lowGamma = double.parse(temp[9]);
            double middleGamma = double.parse(temp[10]);
            double gamma = lowGamma + middleGamma;
            double temperature = double.parse(temp[11]);
            double heartRate = double.parse(temp[12]);
            if (heartRate < 1) {
              heartRate = (Random().nextInt(9) + 72).toDouble();
              //hrv(["${(60000 / heartRate).toInt()}"]);
            }
            //显示实时脑波数据
            wavesCtrl.addSpots([
              delta,
              theta,
              alpha,
              beta,
              gamma,
            ]);
            if (wavesCtrl.dataFlSpot0.length >= 600) {
              wavesCtrl.clearSpots();
            }

            ///收集脑波数据
            if (customerCtrl.isRecording.value) comeCount.value++; //全部数据量（包括静息数据）
            if ((delta > 0 && delta < upperLimit) &&
                (theta > 0 && theta < upperLimit) &&
                (alpha > 0 && alpha < upperLimit) &&
                (beta > 0 && beta < upperLimit) &&
                (gamma > 0 && gamma < upperLimit) &&
                customerCtrl.isRecording.value &&
                bciDataDelta.length < customerCtrl.sampleSize.value) {
              pureCount.value++; //静息数据量
              //
              bciDataDelta.add(delta);
              bciDataTheta.add(theta);
              bciDataAlpha.add(alpha);
              bciDataBeta.add(beta);
              bciDataGamma.add(gamma);
              bciDataTemperature.add(temperature);
              bciDataHeartRate.add(heartRate);
              bciDataAtt.add(att);
              bciDataMed.add(med);

              ///计算动态数据
              double bciTotal = delta + theta + alpha + beta + gamma;
              bciCtrl.total.value = bciTotal;
              bciCtrl.delta.value = delta;
              bciCtrl.theta.value = theta;
              bciCtrl.alpha.value = alpha;
              bciCtrl.beta.value = beta;
              bciCtrl.gamma.value = gamma;
              //
              baselineCtrl.alphaRealtimeRate.value = alpha / bciTotal;
              baselineCtrl.betaRealtimeRate.value = beta / bciTotal;
              baselineCtrl.gammaRealtimeRate.value = gamma / bciTotal;
              baselineCtrl.alphaBetaRealtimeRate.value = alpha / (alpha + beta);
              baselineCtrl.gammaBetaRealtimeRate.value = gamma / (gamma + beta);
              //
              baselineCtrl.deltaRealtime.value = delta.toInt();
              baselineCtrl.thetaRealtime.value = theta.toInt();
              baselineCtrl.alphaRealtime.value = alpha.toInt();
              baselineCtrl.betaRealtime.value = beta.toInt();
              baselineCtrl.gammaRealtime.value = gamma.toInt();
              baselineCtrl.temperatureRealtime.value = temperature;
              baselineCtrl.heartRateRealtime.value = heartRate.toInt();
              //
              heartRateCtrl.heartRate.value = heartRate.toInt();
              restingCtrl.rate.value = comeCount.value > 0 ? pureCount.value / comeCount.value : 1;
              brainLoadCtrl.topLoad.value = brainLoadCtrl.topLoad.value < bciTotal ? bciTotal : brainLoadCtrl.topLoad.value;
              brainLoadCtrl.load.value = brainLoadCtrl.load.value > bciTotal ? bciTotal : brainLoadCtrl.load.value;

              ///计算基线数据以及基于基线的动态数据
              if (bciDataDelta.length == 16) {
                baselineCtrl.delta.value = (baselineCtrl.median(bciDataDelta.sublist(0, 16))).toInt();
                baselineCtrl.theta.value = (baselineCtrl.median(bciDataTheta.sublist(0, 16))).toInt();
                baselineCtrl.alpha.value = (baselineCtrl.median(bciDataAlpha.sublist(0, 16))).toInt();
                baselineCtrl.beta.value = (baselineCtrl.median(bciDataBeta.sublist(0, 16))).toInt();
                baselineCtrl.gamma.value = (baselineCtrl.median(bciDataGamma.sublist(0, 16))).toInt();
                baselineCtrl.temperature.value = (baselineCtrl.median(bciDataTemperature.sublist(0, 16)) * 10).toInt() / 10;
                baselineCtrl.heartRate.value = (baselineCtrl.median(bciDataHeartRate.sublist(0, 16))).toInt();
                //
                int baselineTotal =
                    baselineCtrl.delta.value + baselineCtrl.theta.value + baselineCtrl.alpha.value + baselineCtrl.beta.value + baselineCtrl.gamma.value;
                baselineCtrl.alphaRate.value = baselineCtrl.alpha.value / baselineTotal;
                baselineCtrl.betaRate.value = baselineCtrl.beta.value / baselineTotal;
                baselineCtrl.gammaRate.value = baselineCtrl.gamma.value / baselineTotal;
                baselineCtrl.alphaBetaRate.value = baselineCtrl.alpha.value / (baselineCtrl.alpha.value + baselineCtrl.beta.value);
                baselineCtrl.gammaBetaRate.value = baselineCtrl.gamma.value / (baselineCtrl.gamma.value + baselineCtrl.beta.value);
                //
                baselineCtrl.isLoaded.value = true;
                Get.snackbar('提示', '基线数据加载完成');
              }

              ///trend,情绪跟踪
              if (bciDataDelta.length % 16 == 0) {
                double deltaTrendSign = Data.calculateTrendSign(bciDataDelta.sublist(bciDataDelta.length - 16, bciDataDelta.length))["sign"];
                double thetaTrendSign = Data.calculateTrendSign(bciDataTheta.sublist(bciDataTheta.length - 16, bciDataTheta.length))["sign"];
                double alphaTrendSign = Data.calculateTrendSign(bciDataAlpha.sublist(bciDataAlpha.length - 16, bciDataAlpha.length))["sign"];
                double betaTrendSign = Data.calculateTrendSign(bciDataBeta.sublist(bciDataBeta.length - 16, bciDataBeta.length))["sign"];
                double gammaTrendSign = Data.calculateTrendSign(bciDataGamma.sublist(bciDataGamma.length - 16, bciDataGamma.length))["sign"];
                trendCtrl.trend(deltaTrendSign, thetaTrendSign, alphaTrendSign, betaTrendSign, gammaTrendSign);
              }

              ///BCI检测完毕
              if (bciDataDelta.length == customerCtrl.sampleSize.value) {
                customerCtrl.isRecording.value = false; //停止BCI数据收集
                //Get.snackbar("提示", "BCI 检测样本数达到要求");
                wuluohaiCtrl.selectRandom();
                staffCtrl.refreshNotes();
                //
                Map<String, dynamic> deltaTrend = Data.calculateTrendSign(bciDataDelta);
                Map<String, dynamic> thetaTrend = Data.calculateTrendSign(bciDataTheta);
                Map<String, dynamic> alphaTrend = Data.calculateTrendSign(bciDataAlpha);
                Map<String, dynamic> betaTrend = Data.calculateTrendSign(bciDataBeta);
                Map<String, dynamic> gammaTrend = Data.calculateTrendSign(bciDataGamma);

                brainLoadCtrl.load.value = deltaTrend["mv"] + thetaTrend["mv"] + alphaTrend["mv"] + betaTrend["mv"] + gammaTrend["mv"];

                pressureCtrl.psyPresssure.value = betaTrend["activity"] / (alphaTrend["activity"] + betaTrend["activity"]);
                //
                drawCtrl.att.value = Data.calculateMV(bciDataAtt).toInt();
                drawCtrl.med.value = Data.calculateMV(bciDataMed).toInt();
                drawCtrl.rel.value = ((100 - drawCtrl.att.value) / 2 + drawCtrl.med.value / 2).toInt();
                drawCtrl.flu.value = (drawCtrl.att.value / 2 + drawCtrl.med.value / 2).toInt();
                drawCtrl.hap.value = 40 + Random().nextInt(31);
                drawCtrl.isReady.value = true;
                //

                if (hrvData.length == customerCtrl.sampleSize.value) {
                  customerCtrl.isRecordingHrv.value = false;
                  playAudio("1s Bell");
                  Get.defaultDialog(
                    title: "检测完毕",
                    middleText: "请逐一展开各个模块查看检测结果。",
                    textConfirm: "确定",
                    barrierDismissible: false, 
                    onConfirm: () => Get.back(),
                  );
                  customerCtrl.setSampleData({
                    "heartRate": bciDataHeartRate,
                    "hrv": hrvData,
                    "temperature": bciDataTemperature,
                    "delta": bciDataDelta,
                    "theta": bciDataTheta,
                    "alpha": bciDataAlpha,
                    "beta": bciDataBeta,
                    "gamma": bciDataGamma,
                  });
                }
              }
            }
            //
          }
        }

        ///收集HRV数据
        if (temp[0] == "hrv" && customerCtrl.isRecordingHrv.value) {
          hrv(temp[1].split(','));
          //HRV检测完毕
          if (hrvData.length == customerCtrl.sampleSize.value) {
            customerCtrl.isRecordingHrv.value = false;
            //Get.snackbar("提示", "HRV 检测样本数达到要求");
            pressureCtrl.phyPresssure.value = Data.calculateLFHF(hrvData)[3] / 5;
            if (bciDataDelta.length == customerCtrl.sampleSize.value) {
              customerCtrl.isRecording.value = false;
              playAudio("1s Bell");
              Get.defaultDialog(
                title: "检测完毕",
                middleText: "请逐一展开各个模块查看检测结果。",
                textConfirm: "确定",
                barrierDismissible: false, 
                onConfirm: () => Get.back(),
              );
              customerCtrl.setSampleData({
                "heartRate": bciDataHeartRate,
                "hrv": hrvData,
                "temperature": bciDataTemperature,
                "delta": bciDataDelta,
                "theta": bciDataTheta,
                "alpha": bciDataAlpha,
                "beta": bciDataBeta,
                "gamma": bciDataGamma,
              });
            }
          }
        }
      }
    }, onError: (error) {
      debugPrint('接收数据错误: $error');
    });
  }

  void clearData() {
    wavesCtrl.clearSpots();
    comeCount.value = 0;
    pureCount.value = 0;
    bciDataDelta.clear();
    bciDataTheta.clear();
    bciDataAlpha.clear();
    bciDataBeta.clear();
    bciDataGamma.clear();
    bciDataTemperature.clear();
    bciDataHeartRate.clear();
    bciDataAtt.clear();
    bciDataMed.clear();
    hrvData.clear();
    //
    baselineCtrl.init();
    brainLoadCtrl.init();
    drawCtrl.init();
    trendCtrl.init();
  }
  //       //
  //       if (isRecording.value && pureCount.value < Data.sampleSize.first) {
  //         bciDataDelta.add(delta);
  //         bciDataTheta.add(theta);
  //         bciDataLowAlpha.add(lowAlpha);
  //         bciDataHighAlpha.add(highAlpha);
  //         bciDataLowBeta.add(lowBeta);
  //         bciDataHighBeta.add(highBeta);
  //         bciDataLowGamma.add(lowGamma);
  //         bciDataMiddleGamma.add(middleGamma);
  //         //
  //         bciDataTemperature.add(temperature);
  //         bciDataHeartRate.add(heartRate);
  //         //
  //         bciDataAtt.add(att);
  //         bciDataMed.add(med);
  //       }
  //       //
  //       if (isRecording.value &&
  //           pureCount.value < Data.sampleSize.first &&
  //           delta > 0 &&
  //           delta < upperLimit &&
  //           theta > 0 &&
  //           theta < upperLimit &&
  //           lowAlpha > 0 &&
  //           lowAlpha < upperLimit &&
  //           highAlpha > 0 &&
  //           highAlpha < upperLimit &&
  //           lowBeta > 0 &&
  //           lowBeta < upperLimit &&
  //           highBeta > 0 &&
  //           highBeta < upperLimit &&
  //           lowGamma > 0 &&
  //           lowGamma < upperLimit &&
  //           middleGamma > 0 &&
  //           middleGamma < upperLimit) {
  //         double blt = delta + theta + lowAlpha + highAlpha + lowBeta + highBeta + lowGamma + middleGamma;
  //         brainLoadTemp.value = blt > brainLoadTemp.value ? blt : brainLoadTemp.value;
  //         //有效数据
  //         _bciData['att']!.add(att);
  //         _bciData['med']!.add(med);
  //         _bciData['delta']!.add(delta);
  //         _bciData['theta']!.add(theta);
  //         _bciData['lowAlpha']!.add(lowAlpha);
  //         _bciData['highAlpha']!.add(highAlpha);
  //         _bciData['lowBeta']!.add(lowBeta);
  //         _bciData['highBeta']!.add(highBeta);
  //         _bciData['lowGamma']!.add(lowGamma);
  //         _bciData['middleGamma']!.add(middleGamma);
  //         _bciData['temperature']!.add(temperature);
  //         _bciData['heartRate']!.add(heartRate);
  //         //有效数据图
  //         if (pureCount.value < 128) {
  //           pureController.addSpots([
  //             delta,
  //             theta,
  //             lowAlpha,
  //             highAlpha,
  //             lowBeta,
  //             highBeta,
  //             lowGamma,
  //             middleGamma,
  //           ]);
  //           //
  //           haloDelta.value = delta / blt;
  //           haloTheta.value = theta / blt + haloDelta.value;
  //           haloLowAlpha.value = lowAlpha / blt + haloTheta.value;
  //           haloHighAlpha.value = highAlpha / blt + haloLowAlpha.value;
  //           haloLowBeta.value = lowBeta / blt + haloHighAlpha.value;
  //           haloHighBeta.value = highBeta / blt + haloLowBeta.value;
  //           haloLowGamma.value = lowGamma / blt + haloHighBeta.value;
  //           //haloMiddleGamma.value = 1;
  //           wuluohaiMusicIndex.value = pureCount.value % musicTitles.length;
  //           //静息率
  //           basePercent.value = bciDataDelta.isNotEmpty ? (pureCount.value / bciDataDelta.length * 100).toInt() / 100 : 0.0;
  //           //压力指数
  //           pressValue.value = ((lowBeta + highBeta) / (lowAlpha + highAlpha + lowBeta + highBeta) * 100).toInt() / 100;
  //         }
  //         //有效数据量
  //         pureCount.value++;
  //         //播放检测启动提示音：颂钵
  //         if (pureCount.value == 1) {
  //           playAudio("1s Singging Bowl");
  //         }
  //         //初始的负向情绪基线数据
  //         if (pureCount.value == 15) {
  //           lowBetaBase.value = Data.calculateMV(_bciData['lowBeta']!.sublist(pureCount.value - 8));
  //           lowBetaMin.value = lowBetaBase.value;
  //           highBetaBase.value = Data.calculateMV(_bciData['highBeta']!.sublist(pureCount.value - 8));
  //           highBetaMin.value = highBetaBase.value;
  //         }
  //         //播放闭眼静息提示音：鸟叫
  //         if (pureCount.value >= 64 && pureCount.value % 8 == 0 && pureCount.value <= 120) {
  //           playAudio("1s Birds Songs");
  //           staffNoteList.add(noteMap.keys.elementAt(Random().nextInt(noteMap.keys.length)));
  //         }
  //         if (pureCount.value >= 16 && pureCount.value % 8 == 0 && pureCount.value <= 120) {
  //           brainLoadTop.value = brainLoadTemp.value;
  //           brainLoad.value = blt;
  //           //持续跟踪并记录Beta能耗的最低值和最高值，用于表征负向情绪的疏解效果
  //           double lbm = Data.calculateMV(_bciData['lowBeta']!.sublist(pureCount.value - 8));
  //           if (lbm < lowBetaMin.value) {
  //             lowBetaMin.value = lbm;
  //           }
  //           if (lbm > lowBetaBase.value) {
  //             lowBetaBase.value = lbm;
  //           }
  //           double hbm = Data.calculateMV(_bciData['highBeta']!.sublist(pureCount.value - 8));
  //           if (hbm < highBetaMin.value) {
  //             highBetaMin.value = hbm;
  //           }
  //           if (hbm > highBetaBase.value) {
  //             highBetaBase.value = hbm;
  //           }
  //           //持续跟踪并记录灵动时刻：观察Alpha Beta Gamma的增长趋势
  //           Map<String, dynamic> sign8 = {
  //             "delta": Data.sign8(_bciData['delta']!.sublist(pureCount.value - 8)),
  //             "theta": Data.sign8(_bciData['theta']!.sublist(pureCount.value - 8)),
  //             "lowAlpha": Data.sign8(_bciData['lowAlpha']!.sublist(pureCount.value - 8)),
  //             "highAlpha": Data.sign8(_bciData['highAlpha']!.sublist(pureCount.value - 8)),
  //             "lowBeta": Data.sign8(_bciData['lowBeta']!.sublist(pureCount.value - 8)),
  //             "highBeta": Data.sign8(_bciData['highBeta']!.sublist(pureCount.value - 8)),
  //             "lowGamma": Data.sign8(_bciData['lowGamma']!.sublist(pureCount.value - 8)),
  //             "middleGamma": Data.sign8(_bciData['middleGamma']!.sublist(pureCount.value - 8))
  //           };
  //           double s = 0.0;
  //           String w = "";
  //           if (sign8["lowAlpha"]["trend"] == 1) {
  //             s = sign8["lowAlpha"]["sign"];
  //             w = "lowAlpha";
  //           }
  //           if (sign8["highAlpha"]["trend"] == 1 && sign8["highAlpha"]["sign"] > s) {
  //             s = sign8["highAlpha"]["sign"];
  //             w = "highAlpha";
  //           }
  //           if (sign8["lowBeta"]["trend"] == 1 && sign8["lowBeta"]["sign"] > s) {
  //             s = sign8["lowBeta"]["sign"];
  //             w = "lowBeta";
  //           }
  //           if (sign8["highBeta"]["trend"] == 1 && sign8["highBeta"]["sign"] > s) {
  //             s = sign8["highBeta"]["sign"];
  //             w = "highBeta";
  //           }
  //           if (sign8["lowGamma"]["trend"] == 1 && sign8["lowGamma"]["sign"] > s) {
  //             s = sign8["lowGamma"]["sign"];
  //             w = "lowGamma";
  //           }
  //           if (sign8["middleGamma"]["trend"] == 1 && sign8["middleGamma"]["sign"] > s) {
  //             s = sign8["middleGamma"]["sign"];
  //             w = "middleGamma";
  //           }
  //           if (s > sensitiveValue.value) {
  //             sensitivePoint.value = pureCount.value - 8;
  //             sensitiveWave.value = w;
  //             sensitiveValue.value = s < 1 ? (s * 100).toInt() / 100 : 1.0;
  //           }
  //           //持续跟踪并记录情绪激活度&效价：抓鸟
  //           //la-  ha- ha+  la+
  //           //恐惧 紧绷 警觉 欢喜 lb-
  //           //焦虑 紧张 兴奋 快乐 hb-
  //           //厌恶 烦恼 镇定 放松 hb+
  //           //抑郁 悲伤 平静 满足 lb+
  //           if (sign8["highAlpha"]["trend"] == 1) {
  //             if (sign8["lowBeta"]["trend"] == -1) {
  //               emoV3.value += 1;
  //             } else {
  //               if (sign8["highAlpha"]["sign"] - sign8["lowBeta"]["sign"] > 0) {
  //                 emoV15.value += 1;
  //               }
  //             }
  //             if (sign8["highBeta"]["trend"] == -1) {
  //               emoV7.value += 1;
  //             } else {
  //               if (sign8["highAlpha"]["sign"] - sign8["highBeta"]["sign"] > 0) {
  //                 emoV11.value += 1;
  //               }
  //             }
  //           }
  //           if (sign8["lowAlpha"]["trend"] == 1) {
  //             if (sign8["lowBeta"]["trend"] == -1) {
  //               emoV4.value += 1;
  //             } else {
  //               if (sign8["lowAlpha"]["sign"] - sign8["lowBeta"]["sign"] > 0) {
  //                 emoV16.value += 1;
  //               }
  //             }
  //             if (sign8["highBeta"]["trend"] == -1) {
  //               emoV8.value += 1;
  //             } else {
  //               if (sign8["lowAlpha"]["sign"] - sign8["highBeta"]["sign"] > 0) {
  //                 emoV12.value += 1;
  //               }
  //             }
  //           }
  //           //
  //           chakra0Delta.value = (sign8["delta"]["activity"] * 100).toInt() / 100;
  //           if (chakra0Delta.value > 0) {
  //             chakra1Theta.value = (sign8["theta"]["activity"] / chakra0Delta.value * 100).toInt() / 100;
  //             chakra2LowAlpha.value = (sign8["lowAlpha"]["activity"] / chakra0Delta.value * 100).toInt() / 100;
  //             chakra3HighAlpha.value = (sign8["highAlpha"]["activity"] / chakra0Delta.value * 100).toInt() / 100;
  //             chakra4LowBeta.value = (sign8["lowBeta"]["activity"] / chakra0Delta.value * 100).toInt() / 100;
  //             chakra5HighBeta.value = (sign8["highBeta"]["activity"] / chakra0Delta.value * 100).toInt() / 100;
  //             chakra6LowGamma.value = (sign8["lowGamma"]["activity"] / chakra0Delta.value * 100).toInt() / 100;
  //             chakra7MiddleGamma.value = (sign8["middleGamma"]["activity"] / chakra0Delta.value * 100).toInt() / 100;
  //           }
  //         }
  //         if (pureCount.value == 128) {
  //           isRecording.value = false;
  //           Get.snackbar("OK", "检测完毕", snackPosition: SnackPosition.BOTTOM);
  //           playAudio("1s Bell");
  //           Map<String, dynamic> sign128 = {
  //             "delta": Data.sign128(_bciData['delta']!),
  //             "theta": Data.sign128(_bciData['theta']!),
  //             "lowAlpha": Data.sign128(_bciData['lowAlpha']!),
  //             "highAlpha": Data.sign128(_bciData['highAlpha']!),
  //             "lowBeta": Data.sign128(_bciData['lowBeta']!),
  //             "highBeta": Data.sign128(_bciData['highBeta']!),
  //             "lowGamma": Data.sign128(_bciData['lowGamma']!),
  //             "middleGamma": Data.sign128(_bciData['middleGamma']!)
  //           };
  //           Map<String, dynamic> trendSign = {
  //             "delta": Data.calculateTrendSign(_bciData['delta']!),
  //             "theta": Data.calculateTrendSign(_bciData['theta']!),
  //             "lowAlpha": Data.calculateTrendSign(_bciData['lowAlpha']!),
  //             "highAlpha": Data.calculateTrendSign(_bciData['highAlpha']!),
  //             "lowBeta": Data.calculateTrendSign(_bciData['lowBeta']!),
  //             "highBeta": Data.calculateTrendSign(_bciData['highBeta']!),
  //             "lowGamma": Data.calculateTrendSign(_bciData['lowGamma']!),
  //             "middleGamma": Data.calculateTrendSign(_bciData['middleGamma']!)
  //           };
  //           //
  //           brainLoadTop.value = brainLoadTemp.value;
  //           brainLoad.value = trendSign["delta"]["right"]["mv"] +
  //               trendSign["theta"]["right"]["mv"] +
  //               trendSign["lowAlpha"]["right"]["mv"] +
  //               trendSign["highAlpha"]["right"]["mv"] +
  //               trendSign["lowBeta"]["right"]["mv"] +
  //               trendSign["highBeta"]["right"]["mv"] +
  //               trendSign["lowGamma"]["right"]["mv"] +
  //               trendSign["middleGamma"]["right"]["mv"];
  //           //
  //           List<double> halo = [
  //             (trendSign["delta"]["right"]["mv"] / brainLoad.value * 1000).toInt() / 1000,
  //             (trendSign["theta"]["right"]["mv"] / brainLoad.value * 1000).toInt() / 1000,
  //             (trendSign["lowAlpha"]["right"]["mv"] / brainLoad.value * 1000).toInt() / 1000,
  //             (trendSign["highAlpha"]["right"]["mv"] / brainLoad.value * 1000).toInt() / 1000,
  //             (trendSign["lowBeta"]["right"]["mv"] / brainLoad.value * 1000).toInt() / 1000,
  //             (trendSign["highBeta"]["right"]["mv"] / brainLoad.value * 1000).toInt() / 1000,
  //             (trendSign["lowGamma"]["right"]["mv"] / brainLoad.value * 1000).toInt() / 1000,
  //             (trendSign["middleGamma"]["right"]["mv"] / brainLoad.value * 1000).toInt() / 1000,
  //           ];
  //           haloDelta.value = halo[0];
  //           haloTheta.value = halo[1] + haloDelta.value;
  //           haloLowAlpha.value = halo[2] + haloTheta.value;
  //           haloHighAlpha.value = halo[3] + haloLowAlpha.value;
  //           haloLowBeta.value = halo[4] + haloHighAlpha.value;
  //           haloHighBeta.value = halo[5] + haloLowBeta.value;
  //           haloLowGamma.value = halo[6] + haloHighBeta.value;
  //           //haloMiddleGamma.value = 1;
  //           //
  //           chakra0Delta.value = (trendSign["delta"]["right"]["activity"] * 100).toInt() / 100;
  //           if (chakra0Delta.value > 0) {
  //             chakra1Theta.value = (trendSign["theta"]["right"]["activity"] / chakra0Delta.value * 100).toInt() / 100;
  //             chakra2LowAlpha.value = (trendSign["lowAlpha"]["right"]["activity"] / chakra0Delta.value * 100).toInt() / 100;
  //             chakra3HighAlpha.value = (trendSign["highAlpha"]["right"]["activity"] / chakra0Delta.value * 100).toInt() / 100;
  //             chakra4LowBeta.value = (trendSign["lowBeta"]["right"]["activity"] / chakra0Delta.value * 100).toInt() / 100;
  //             chakra5HighBeta.value = (trendSign["highBeta"]["right"]["activity"] / chakra0Delta.value * 100).toInt() / 100;
  //             chakra6LowGamma.value = (trendSign["lowGamma"]["right"]["activity"] / chakra0Delta.value * 100).toInt() / 100;
  //             chakra7MiddleGamma.value = (trendSign["middleGamma"]["right"]["activity"] / chakra0Delta.value * 100).toInt() / 100;
  //           }
  //           //
  //           double pv = (trendSign["lowBeta"]["mv"] + trendSign["highBeta"]["mv"]) /
  //               (trendSign["lowAlpha"]["mv"] + trendSign["highAlpha"]["mv"] + trendSign["lowBeta"]["mv"] + trendSign["highBeta"]["mv"]);
  //           pressValue.value = (pv * 100).toInt() / 100;
  //           double lpv = (trendSign["lowBeta"]["left"]["mv"] + trendSign["highBeta"]["left"]["mv"]) /
  //               (trendSign["lowAlpha"]["left"]["mv"] +
  //                   trendSign["highAlpha"]["left"]["mv"] +
  //                   trendSign["lowBeta"]["left"]["mv"] +
  //                   trendSign["highBeta"]["left"]["mv"]);
  //           leftPressValue.value = (lpv * 100).toInt() / 100;
  //           double rpv = (trendSign["lowBeta"]["right"]["mv"] + trendSign["highBeta"]["right"]["mv"]) /
  //               (trendSign["lowAlpha"]["right"]["mv"] +
  //                   trendSign["highAlpha"]["right"]["mv"] +
  //                   trendSign["lowBeta"]["right"]["mv"] +
  //                   trendSign["highBeta"]["right"]["mv"]);
  //           rightPressValue.value = (rpv * 100).toInt() / 100;
  //           //
  //           //
  //           lowAlphaTrend.value = trendSign["lowAlpha"]["right"]["trend"];
  //           lowAlphaSign.value = (trendSign["lowAlpha"]["right"]["sign"] * 100).toInt() / 100;
  //           highAlphaTrend.value = trendSign["highAlpha"]["right"]["trend"];
  //           highAlphaSign.value = (trendSign["highAlpha"]["right"]["sign"] * 100).toInt() / 100;
  //           //
  //           lowBetaTrend.value = trendSign["lowBeta"]["trend"];
  //           lowBetaSign.value = (trendSign["lowBeta"]["sign"] * 100).toInt() / 100;
  //           highBetaTrend.value = trendSign["highBeta"]["trend"];
  //           highBetaSign.value = (trendSign["highBeta"]["sign"] * 100).toInt() / 100;
  //           //
  //           wavesTableController.resetData();
  //           wavesTableController.addCol([
  //             "整体趋势",
  //             trendSign["delta"]["trend"] == 1
  //                 ? "升"
  //                 : trendSign["delta"]["trend"] == -1
  //                     ? "降✔"
  //                     : "平",
  //             trendSign["theta"]["trend"] == 1
  //                 ? "升"
  //                 : trendSign["theta"]["trend"] == -1
  //                     ? "降✔"
  //                     : "平",
  //             trendSign["lowAlpha"]["trend"] == 1
  //                 ? "升✔"
  //                 : trendSign["lowAlpha"]["trend"] == -1
  //                     ? "降"
  //                     : "平",
  //             trendSign["highAlpha"]["trend"] == 1
  //                 ? "升✔"
  //                 : trendSign["highAlpha"]["trend"] == -1
  //                     ? "降"
  //                     : "平",
  //             trendSign["lowBeta"]["trend"] == 1
  //                 ? "升"
  //                 : trendSign["lowBeta"]["trend"] == -1
  //                     ? "降✔"
  //                     : "平",
  //             trendSign["highBeta"]["trend"] == 1
  //                 ? "升"
  //                 : trendSign["highBeta"]["trend"] == -1
  //                     ? "降✔"
  //                     : "平",
  //             trendSign["lowGamma"]["trend"] == 1
  //                 ? "升✔"
  //                 : trendSign["lowGamma"]["trend"] == -1
  //                     ? "降"
  //                     : "平",
  //             trendSign["middleGamma"]["trend"] == 1
  //                 ? "升✔"
  //                 : trendSign["middleGamma"]["trend"] == -1
  //                     ? "降"
  //                     : "平",
  //           ]);
  //           wavesTableController.addCol([
  //             "显著度（%）",
  //             ((trendSign["delta"]["sign"] * 10000).toInt() / 100).toString(),
  //             ((trendSign["theta"]["sign"] * 10000).toInt() / 100).toString(),
  //             ((trendSign["lowAlpha"]["sign"] * 10000).toInt() / 100).toString(),
  //             ((trendSign["highAlpha"]["sign"] * 10000).toInt() / 100).toString(),
  //             ((trendSign["lowBeta"]["sign"] * 10000).toInt() / 100).toString(),
  //             ((trendSign["highBeta"]["sign"] * 10000).toInt() / 100).toString(),
  //             ((trendSign["lowGamma"]["sign"] * 10000).toInt() / 100).toString(),
  //             ((trendSign["middleGamma"]["sign"] * 10000).toInt() / 100).toString(),
  //           ]);
  //           wavesTableController.addCol([
  //             "活跃度（%）",
  //             ((trendSign["delta"]["activity"] * 10000).toInt() / 100).toString(),
  //             ((trendSign["theta"]["activity"] * 10000).toInt() / 100).toString(),
  //             ((trendSign["lowAlpha"]["activity"] * 10000).toInt() / 100).toString(),
  //             ((trendSign["highAlpha"]["activity"] * 10000).toInt() / 100).toString(),
  //             ((trendSign["lowBeta"]["activity"] * 10000).toInt() / 100).toString(),
  //             ((trendSign["highBeta"]["activity"] * 10000).toInt() / 100).toString(),
  //             ((trendSign["lowGamma"]["activity"] * 10000).toInt() / 100).toString(),
  //             ((trendSign["middleGamma"]["activity"] * 10000).toInt() / 100).toString(),
  //           ]);
  //           //
  //           lowBetaTableController.resetData();
  //           lowBetaTableController.addCol([
  //             "干预前",
  //             trendSign["lowBeta"]["left"]["mv"].toInt().toString(),
  //             trendSign["lowBeta"]["left"]["trend"] == 1
  //                 ? "升"
  //                 : trendSign["lowBeta"]["left"]["trend"] == -1
  //                     ? "降✔"
  //                     : "平",
  //             ((trendSign["lowBeta"]["left"]["sign"] * 10000).toInt() / 100).toString(),
  //             ((trendSign["lowBeta"]["left"]["activity"] * 10000).toInt() / 100).toString(),
  //           ]);
  //           lowBetaTableController.addCol([
  //             "干预后",
  //             trendSign["lowBeta"]["right"]["mv"].toInt().toString(),
  //             trendSign["lowBeta"]["right"]["trend"] == 1
  //                 ? "升"
  //                 : trendSign["lowBeta"]["right"]["trend"] == -1
  //                     ? "降✔"
  //                     : "平",
  //             ((trendSign["lowBeta"]["right"]["sign"] * 10000).toInt() / 100).toString(),
  //             ((trendSign["lowBeta"]["right"]["activity"] * 10000).toInt() / 100).toString(),
  //           ]);
  //           highBetaTableController.resetData();
  //           highBetaTableController.addCol([
  //             "干预前",
  //             trendSign["highBeta"]["left"]["mv"].toInt().toString(),
  //             trendSign["highBeta"]["left"]["trend"] == 1
  //                 ? "升"
  //                 : trendSign["highBeta"]["left"]["trend"] == -1
  //                     ? "降✔"
  //                     : "平",
  //             ((trendSign["highBeta"]["left"]["sign"] * 10000).toInt() / 100).toString(),
  //             ((trendSign["highBeta"]["left"]["activity"] * 10000).toInt() / 100).toString(),
  //           ]);
  //           highBetaTableController.addCol([
  //             "干预后",
  //             trendSign["highBeta"]["right"]["mv"].toInt().toString(),
  //             trendSign["highBeta"]["right"]["trend"] == 1
  //                 ? "升"
  //                 : trendSign["highBeta"]["right"]["trend"] == -1
  //                     ? "降✔"
  //                     : "平",
  //             ((trendSign["highBeta"]["right"]["sign"] * 10000).toInt() / 100).toString(),
  //             ((trendSign["highBeta"]["right"]["activity"] * 10000).toInt() / 100).toString(),
  //           ]);
  //           //
  //           const int points = 16;
  //           Map<String, dynamic> baseLowBeta = {
  //             "times": 0,
  //             "%": 0.0,
  //             "mv": 0.0,
  //             "trend": 0,
  //             "sign": 0.0,
  //             "activity": 0.0,
  //             "queen": {
  //               "name": "",
  //               "times": 0,
  //               "%": 0.0,
  //               "mv": 0.0,
  //               "trend": 0,
  //               "sign": 0.0,
  //               "activity": 0.0,
  //               "signTop": 0.0,
  //               "signTopPoint": 0,
  //               "signTopMv": 0.0,
  //               "activityTop": 0.0,
  //               "activityTopPoint": 0,
  //               "activityTopMv": 0.0,
  //             },
  //             "delta": {
  //               "times": 0,
  //               "%": 0.0,
  //               "mv": List<double>.filled(points, 0.0),
  //               "trend": List<int>.filled(points, 0),
  //               "sign": List<double>.filled(points, 0.0),
  //               "activity": List<double>.filled(points, 0.0),
  //             },
  //             "theta": {
  //               "times": 0,
  //               "%": 0.0,
  //               "mv": List<double>.filled(points, 0.0),
  //               "trend": List<int>.filled(points, 0),
  //               "sign": List<double>.filled(points, 0.0),
  //               "activity": List<double>.filled(points, 0.0),
  //             },
  //             "lowAlpha": {
  //               "times": 0,
  //               "%": 0.0,
  //               "mv": List<double>.filled(points, 0.0),
  //               "trend": List<int>.filled(points, 0),
  //               "sign": List<double>.filled(points, 0.0),
  //               "activity": List<double>.filled(points, 0.0),
  //             },
  //             "highAlpha": {
  //               "times": 0,
  //               "%": 0.0,
  //               "mv": List<double>.filled(points, 0.0),
  //               "trend": List<int>.filled(points, 0),
  //               "sign": List<double>.filled(points, 0.0),
  //               "activity": List<double>.filled(points, 0.0),
  //             },
  //             "lowGamma": {
  //               "times": 0,
  //               "%": 0.0,
  //               "mv": List<double>.filled(points, 0.0),
  //               "trend": List<int>.filled(points, 0),
  //               "sign": List<double>.filled(points, 0.0),
  //               "activity": List<double>.filled(points, 0.0),
  //             },
  //             "middleGamma": {
  //               "times": 0,
  //               "%": 0.0,
  //               "mv": List<double>.filled(points, 0.0),
  //               "trend": List<int>.filled(points, 0),
  //               "sign": List<double>.filled(points, 0.0),
  //               "activity": List<double>.filled(points, 0.0),
  //             },
  //           };
  //           Map<String, dynamic> baseHighBeta = {
  //             "times": 0,
  //             "%": 0.0,
  //             "mv": 0.0,
  //             "trend": 0,
  //             "sign": 0.0,
  //             "activity": 0.0,
  //             "queen": {
  //               "name": "",
  //               "times": 0,
  //               "%": 0.0,
  //               "mv": 0.0,
  //               "trend": 0,
  //               "sign": 0.0,
  //               "activity": 0.0,
  //               "signTop": 0.0,
  //               "signTopPoint": 0,
  //               "signTopMv": 0.0,
  //               "activityTop": 0.0,
  //               "activityTopPoint": 0,
  //               "activityTopMv": 0.0,
  //             },
  //             "delta": {
  //               "times": 0,
  //               "%": 0.0,
  //               "mv": List<double>.filled(points, 0.0),
  //               "trend": List<int>.filled(points, 0),
  //               "sign": List<double>.filled(points, 0.0),
  //               "activity": List<double>.filled(points, 0.0),
  //             },
  //             "theta": {
  //               "times": 0,
  //               "%": 0.0,
  //               "mv": List<double>.filled(points, 0.0),
  //               "trend": List<int>.filled(points, 0),
  //               "sign": List<double>.filled(points, 0.0),
  //               "activity": List<double>.filled(points, 0.0),
  //             },
  //             "lowAlpha": {
  //               "times": 0,
  //               "%": 0.0,
  //               "mv": List<double>.filled(points, 0.0),
  //               "trend": List<int>.filled(points, 0),
  //               "sign": List<double>.filled(points, 0.0),
  //               "activity": List<double>.filled(points, 0.0),
  //             },
  //             "highAlpha": {
  //               "times": 0,
  //               "%": 0.0,
  //               "mv": List<double>.filled(points, 0.0),
  //               "trend": List<int>.filled(points, 0),
  //               "sign": List<double>.filled(points, 0.0),
  //               "activity": List<double>.filled(points, 0.0),
  //             },
  //             "lowGamma": {
  //               "times": 0,
  //               "%": 0.0,
  //               "mv": List<double>.filled(points, 0.0),
  //               "trend": List<int>.filled(points, 0),
  //               "sign": List<double>.filled(points, 0.0),
  //               "activity": List<double>.filled(points, 0.0),
  //             },
  //             "middleGamma": {
  //               "times": 0,
  //               "%": 0.0,
  //               "mv": List<double>.filled(points, 0.0),
  //               "trend": List<int>.filled(points, 0),
  //               "sign": List<double>.filled(points, 0.0),
  //               "activity": List<double>.filled(points, 0.0),
  //             },
  //           };
  //           for (int i = 0; i < points; i++) {
  //             //对比显示八种脑波的mv、trend、deepth、sign、activity
  //             mvController.addSpots([
  //               sign128["delta"]["mv"][i],
  //               sign128["theta"]["mv"][i],
  //               sign128["lowAlpha"]["mv"][i],
  //               sign128["highAlpha"]["mv"][i],
  //               sign128["lowBeta"]["mv"][i],
  //               sign128["highBeta"]["mv"][i],
  //               sign128["lowGamma"]["mv"][i],
  //               sign128["middleGamma"]["mv"][i],
  //             ]);
  //             trendController.addSpotsSign([
  //               sign128["delta"]["trend"][i].toDouble(),
  //               sign128["theta"]["trend"][i].toDouble(),
  //               sign128["lowAlpha"]["trend"][i].toDouble(),
  //               sign128["highAlpha"]["trend"][i].toDouble(),
  //               sign128["lowBeta"]["trend"][i].toDouble(),
  //               sign128["highBeta"]["trend"][i].toDouble(),
  //               sign128["lowGamma"]["trend"][i].toDouble(),
  //               sign128["middleGamma"]["trend"][i].toDouble(),
  //             ]);
  //             deepthController.addSpotsSign([
  //               sign128["delta"]["deepth"][i].toDouble(),
  //               sign128["theta"]["deepth"][i].toDouble(),
  //               sign128["lowAlpha"]["deepth"][i].toDouble(),
  //               sign128["highAlpha"]["deepth"][i].toDouble(),
  //               sign128["lowBeta"]["deepth"][i].toDouble(),
  //               sign128["highBeta"]["deepth"][i].toDouble(),
  //               sign128["lowGamma"]["deepth"][i].toDouble(),
  //               sign128["middleGamma"]["deepth"][i].toDouble(),
  //             ]);
  //             signController.addSpotsSign([
  //               sign128["delta"]["sign"][i],
  //               sign128["theta"]["sign"][i],
  //               sign128["lowAlpha"]["sign"][i],
  //               sign128["highAlpha"]["sign"][i],
  //               sign128["lowBeta"]["sign"][i],
  //               sign128["highBeta"]["sign"][i],
  //               sign128["lowGamma"]["sign"][i],
  //               sign128["middleGamma"]["sign"][i],
  //             ]);
  //             activityController.addSpotsSign([
  //               sign128["delta"]["activity"][i],
  //               sign128["theta"]["activity"][i],
  //               sign128["lowAlpha"]["activity"][i],
  //               sign128["highAlpha"]["activity"][i],
  //               sign128["lowBeta"]["activity"][i],
  //               sign128["highBeta"]["activity"][i],
  //               sign128["lowGamma"]["activity"][i],
  //               sign128["middleGamma"]["activity"][i],
  //             ]);
  //             ///计算其余6种脑波对LowBeta波可能存在的影响
  //             if (sign128["lowBeta"]["trend"][i] == -1) {
  //               baseLowBeta["times"]++;
  //               //Delta波
  //               if (sign128["delta"]["trend"][i] == 1) {
  //                 //计算Delta波对LowBeta波出现相干关系的次数
  //                 baseLowBeta["delta"]["times"]++;
  //                 //计算能耗比，表示Delta波影响LowBeta波的能量效价
  //                 baseLowBeta["delta"]["mv"][i] =
  //                     (sign128["lowBeta"]["mv"][i] - sign128["delta"]["mv"][i]) / (sign128["delta"]["mv"][i] + sign128["lowBeta"]["mv"][i]);
  //                 //1表示存在相干关系，默认的0表示不存在相干关系
  //                 baseLowBeta["delta"]["trend"][i] = 1;
  //                 //计算趋势显著度之和，表示Delta波与LowBeta波之间的变化张力
  //                 baseLowBeta["delta"]["sign"][i] = sign128["delta"]["sign"][i] - sign128["lowBeta"]["sign"][i];
  //                 //计算活跃度之和，表示Delta波与LowBeta波的总活跃度
  //                 baseLowBeta["delta"]["activity"][i] = sign128["delta"]["activity"][i] + sign128["lowBeta"]["activity"][i];
  //               }
  //               //Theta波
  //               if (sign128["theta"]["trend"][i] == 1) {
  //                 baseLowBeta["theta"]["times"]++;
  //                 baseLowBeta["theta"]["mv"][i] =
  //                     (sign128["lowBeta"]["mv"][i] - sign128["theta"]["mv"][i]) / (sign128["theta"]["mv"][i] + sign128["lowBeta"]["mv"][i]);
  //                 baseLowBeta["theta"]["trend"][i] = 1;
  //                 baseLowBeta["theta"]["sign"][i] = sign128["theta"]["sign"][i] - sign128["lowBeta"]["sign"][i];
  //                 baseLowBeta["theta"]["activity"][i] = sign128["theta"]["activity"][i] + sign128["lowBeta"]["activity"][i];
  //               }
  //               //LowAlpha波
  //               if (sign128["lowAlpha"]["trend"][i] == 1) {
  //                 baseLowBeta["lowAlpha"]["times"]++;
  //                 baseLowBeta["lowAlpha"]["mv"][i] =
  //                     (sign128["lowBeta"]["mv"][i] - sign128["lowAlpha"]["mv"][i]) / (sign128["lowAlpha"]["mv"][i] + sign128["lowBeta"]["mv"][i]);
  //                 baseLowBeta["lowAlpha"]["trend"][i] = 1;
  //                 baseLowBeta["lowAlpha"]["sign"][i] = sign128["lowAlpha"]["sign"][i] - sign128["lowBeta"]["sign"][i];
  //                 baseLowBeta["lowAlpha"]["activity"][i] = sign128["lowAlpha"]["activity"][i] + sign128["lowBeta"]["activity"][i];
  //               }
  //               //HighAlpha波
  //               if (sign128["highAlpha"]["trend"][i] == 1) {
  //                 baseLowBeta["highAlpha"]["times"]++;
  //                 baseLowBeta["highAlpha"]["mv"][i] =
  //                     (sign128["lowBeta"]["mv"][i] - sign128["highAlpha"]["mv"][i]) / (sign128["highAlpha"]["mv"][i] + sign128["lowBeta"]["mv"][i]);
  //                 baseLowBeta["highAlpha"]["trend"][i] = 1;
  //                 baseLowBeta["highAlpha"]["sign"][i] = sign128["highAlpha"]["sign"][i] - sign128["lowBeta"]["sign"][i];
  //                 baseLowBeta["highAlpha"]["activity"][i] = sign128["highAlpha"]["activity"][i] + sign128["lowBeta"]["activity"][i];
  //               }
  //               //LowGamma波
  //               if (sign128["lowGamma"]["trend"][i] == 1) {
  //                 baseLowBeta["lowGamma"]["times"]++;
  //                 baseLowBeta["lowGamma"]["mv"][i] =
  //                     (sign128["lowBeta"]["mv"][i] - sign128["lowGamma"]["mv"][i]) / (sign128["lowGamma"]["mv"][i] + sign128["lowBeta"]["mv"][i]);
  //                 baseLowBeta["lowGamma"]["trend"][i] = 1;
  //                 baseLowBeta["lowGamma"]["sign"][i] = sign128["lowGamma"]["sign"][i] - sign128["lowBeta"]["sign"][i];
  //                 baseLowBeta["lowGamma"]["activity"][i] = sign128["lowGamma"]["activity"][i] + sign128["lowBeta"]["activity"][i];
  //               }
  //               //MiddleGamma波
  //               if (sign128["middleGamma"]["trend"][i] == 1) {
  //                 baseLowBeta["middleGamma"]["times"]++;
  //                 baseLowBeta["middleGamma"]["mv"][i] =
  //                     (sign128["lowBeta"]["mv"][i] - sign128["middleGamma"]["mv"][i]) / (sign128["middleGamma"]["mv"][i] + sign128["lowBeta"]["mv"][i]);
  //                 baseLowBeta["middleGamma"]["trend"][i] = 1;
  //                 baseLowBeta["middleGamma"]["sign"][i] = sign128["middleGamma"]["sign"][i] - sign128["lowBeta"]["sign"][i];
  //                 baseLowBeta["middleGamma"]["activity"][i] = sign128["middleGamma"]["activity"][i] + sign128["lowBeta"]["activity"][i];
  //               }
  //             }
  //             ///计算其余6种脑波对HighBeta波可能存在的影响
  //             if (sign128["highBeta"]["trend"][i] == -1) {
  //               baseHighBeta["times"]++;
  //               //Delta波
  //               if (sign128["delta"]["trend"][i] == 1) {
  //                 //计算Delta波对HighBeta波出现相干关系的次数
  //                 baseHighBeta["delta"]["times"]++;
  //                 //计算能耗比，表示Delta波影响HighBeta波的能量效价
  //                 baseHighBeta["delta"]["mv"][i] =
  //                     (sign128["highBeta"]["mv"][i] - sign128["delta"]["mv"][i]) / (sign128["delta"]["mv"][i] + sign128["highBeta"]["mv"][i]);
  //                 //1表示存在相干关系，默认的0表示不存在相干关系
  //                 baseHighBeta["delta"]["trend"][i] = 1;
  //                 //计算趋势显著度之和，表示Delta波与HighBeta波之间的变化张力
  //                 baseHighBeta["delta"]["sign"][i] = sign128["delta"]["sign"][i] - sign128["highBeta"]["sign"][i];
  //                 //计算活跃度之和，表示Delta波与HighBeta波的总活跃度
  //                 baseHighBeta["delta"]["activity"][i] = sign128["delta"]["activity"][i] + sign128["highBeta"]["activity"][i];
  //               }
  //               //Theta波
  //               if (sign128["theta"]["trend"][i] == 1) {
  //                 baseHighBeta["theta"]["times"]++;
  //                 baseHighBeta["theta"]["mv"][i] =
  //                     (sign128["highBeta"]["mv"][i] - sign128["theta"]["mv"][i]) / (sign128["theta"]["mv"][i] + sign128["highBeta"]["mv"][i]);
  //                 baseHighBeta["theta"]["trend"][i] = 1;
  //                 baseHighBeta["theta"]["sign"][i] = sign128["theta"]["sign"][i] - sign128["highBeta"]["sign"][i];
  //                 baseHighBeta["theta"]["activity"][i] = sign128["theta"]["activity"][i] + sign128["highBeta"]["activity"][i];
  //               }
  //               //LowAlpha波
  //               if (sign128["lowAlpha"]["trend"][i] == 1) {
  //                 baseHighBeta["lowAlpha"]["times"]++;
  //                 baseHighBeta["lowAlpha"]["mv"][i] =
  //                     (sign128["highBeta"]["mv"][i] - sign128["lowAlpha"]["mv"][i]) / (sign128["lowAlpha"]["mv"][i] + sign128["highBeta"]["mv"][i]);
  //                 baseHighBeta["lowAlpha"]["trend"][i] = 1;
  //                 baseHighBeta["lowAlpha"]["sign"][i] = sign128["lowAlpha"]["sign"][i] - sign128["highBeta"]["sign"][i];
  //                 baseHighBeta["lowAlpha"]["activity"][i] = sign128["lowAlpha"]["activity"][i] + sign128["highBeta"]["activity"][i];
  //               }
  //               //HighAlpha波
  //               if (sign128["highAlpha"]["trend"][i] == 1) {
  //                 baseHighBeta["highAlpha"]["times"]++;
  //                 baseHighBeta["highAlpha"]["mv"][i] =
  //                     (sign128["highBeta"]["mv"][i] - sign128["highAlpha"]["mv"][i]) / (sign128["highAlpha"]["mv"][i] + sign128["highBeta"]["mv"][i]);
  //                 baseHighBeta["highAlpha"]["trend"][i] = 1;
  //                 baseHighBeta["highAlpha"]["sign"][i] = sign128["highAlpha"]["sign"][i] - sign128["highBeta"]["sign"][i];
  //                 baseHighBeta["highAlpha"]["activity"][i] = sign128["highAlpha"]["activity"][i] + sign128["highBeta"]["activity"][i];
  //               }
  //               //LowGamma波
  //               if (sign128["lowGamma"]["trend"][i] == 1) {
  //                 baseHighBeta["lowGamma"]["times"]++;
  //                 baseHighBeta["lowGamma"]["mv"][i] =
  //                     (sign128["highBeta"]["mv"][i] - sign128["lowGamma"]["mv"][i]) / (sign128["lowGamma"]["mv"][i] + sign128["highBeta"]["mv"][i]);
  //                 baseHighBeta["lowGamma"]["trend"][i] = 1;
  //                 baseHighBeta["lowGamma"]["sign"][i] = sign128["lowGamma"]["sign"][i] - sign128["highBeta"]["sign"][i];
  //                 baseHighBeta["lowGamma"]["activity"][i] = sign128["lowGamma"]["activity"][i] + sign128["highBeta"]["activity"][i];
  //               }
  //               //MiddleGamma波
  //               if (sign128["middleGamma"]["trend"][i] == 1) {
  //                 baseHighBeta["middleGamma"]["times"]++;
  //                 baseHighBeta["middleGamma"]["mv"][i] =
  //                     (sign128["highBeta"]["mv"][i] - sign128["middleGamma"]["mv"][i]) / (sign128["middleGamma"]["mv"][i] + sign128["highBeta"]["mv"][i]);
  //                 baseHighBeta["middleGamma"]["trend"][i] = 1;
  //                 baseHighBeta["middleGamma"]["sign"][i] = sign128["middleGamma"]["sign"][i] - sign128["highBeta"]["sign"][i];
  //                 baseHighBeta["middleGamma"]["activity"][i] = sign128["middleGamma"]["activity"][i] + sign128["highBeta"]["activity"][i];
  //               }
  //             }
  //             //BaseLowBeta
  //             trendBaseLowBetaController.addSpotsSign([
  //               baseLowBeta["delta"]["trend"][i].toDouble(),
  //               baseLowBeta["theta"]["trend"][i].toDouble(),
  //               baseLowBeta["lowAlpha"]["trend"][i].toDouble(),
  //               baseLowBeta["highAlpha"]["trend"][i].toDouble(),
  //               0.0,
  //               0.0,
  //               baseLowBeta["lowGamma"]["trend"][i].toDouble(),
  //               baseLowBeta["middleGamma"]["trend"][i].toDouble(),
  //             ]);
  //             mvBaseLowBetaController.addSpotsSign([
  //               baseLowBeta["delta"]["mv"][i],
  //               baseLowBeta["theta"]["mv"][i],
  //               baseLowBeta["lowAlpha"]["mv"][i],
  //               baseLowBeta["highAlpha"]["mv"][i],
  //               0.0,
  //               0.0,
  //               baseLowBeta["lowGamma"]["mv"][i],
  //               baseLowBeta["middleGamma"]["mv"][i],
  //             ]);
  //             signBaseLowBetaController.addSpotsSign([
  //               baseLowBeta["delta"]["sign"][i],
  //               baseLowBeta["theta"]["sign"][i],
  //               baseLowBeta["lowAlpha"]["sign"][i],
  //               baseLowBeta["highAlpha"]["sign"][i],
  //               0.0,
  //               0.0,
  //               baseLowBeta["lowGamma"]["sign"][i],
  //               baseLowBeta["middleGamma"]["sign"][i],
  //             ]);
  //             activityBaseLowBetaController.addSpotsSign([
  //               baseLowBeta["delta"]["activity"][i],
  //               baseLowBeta["theta"]["activity"][i],
  //               baseLowBeta["lowAlpha"]["activity"][i],
  //               baseLowBeta["highAlpha"]["activity"][i],
  //               0.0,
  //               0.0,
  //               baseLowBeta["lowGamma"]["activity"][i],
  //               baseLowBeta["middleGamma"]["activity"][i],
  //             ]);
  //             //BaseHighBeta
  //             trendBaseHighBetaController.addSpotsSign([
  //               baseHighBeta["delta"]["trend"][i].toDouble(),
  //               baseHighBeta["theta"]["trend"][i].toDouble(),
  //               baseHighBeta["lowAlpha"]["trend"][i].toDouble(),
  //               baseHighBeta["highAlpha"]["trend"][i].toDouble(),
  //               0.0,
  //               0.0,
  //               baseHighBeta["lowGamma"]["trend"][i].toDouble(),
  //               baseHighBeta["middleGamma"]["trend"][i].toDouble(),
  //             ]);
  //             mvBaseHighBetaController.addSpotsSign([
  //               baseHighBeta["delta"]["mv"][i],
  //               baseHighBeta["theta"]["mv"][i],
  //               baseHighBeta["lowAlpha"]["mv"][i],
  //               baseHighBeta["highAlpha"]["mv"][i],
  //               0.0,
  //               0.0,
  //               baseHighBeta["lowGamma"]["mv"][i],
  //               baseHighBeta["middleGamma"]["mv"][i],
  //             ]);
  //             signBaseHighBetaController.addSpotsSign([
  //               baseHighBeta["delta"]["sign"][i],
  //               baseHighBeta["theta"]["sign"][i],
  //               baseHighBeta["lowAlpha"]["sign"][i],
  //               baseHighBeta["highAlpha"]["sign"][i],
  //               0.0,
  //               0.0,
  //               baseHighBeta["lowGamma"]["sign"][i],
  //               baseHighBeta["middleGamma"]["sign"][i],
  //             ]);
  //             activityBaseHighBetaController.addSpotsSign([
  //               baseHighBeta["delta"]["activity"][i],
  //               baseHighBeta["theta"]["activity"][i],
  //               baseHighBeta["lowAlpha"]["activity"][i],
  //               baseHighBeta["highAlpha"]["activity"][i],
  //               0.0,
  //               0.0,
  //               baseHighBeta["lowGamma"]["activity"][i],
  //               baseHighBeta["middleGamma"]["activity"][i],
  //             ]);
  //           }
  //           const double lineWidthRate = 0.5;
  //           if (baseLowBeta["times"] > 0) {
  //             baseLowBeta["%"] = baseLowBeta["times"] / points;
  //             baseLowBetaRate.value = (baseLowBeta["%"] * 1000).toInt() / 10;
  //             baseLowBetaTimes.value = baseLowBeta["times"];
  //             //计算Delta波对LowBeta波出现相干关系的比例
  //             baseLowBeta["delta"]["%"] = baseLowBeta["delta"]["times"] / baseLowBeta["times"];
  //             baseLowBetaRateDelta.value = (baseLowBeta["delta"]["%"] * 10000).toInt() / 100;
  //             baseLowBetaTimesDelta.value = baseLowBeta["delta"]["times"];
  //             //计算Theta波对LowBeta波出现相干关系的比例
  //             baseLowBeta["theta"]["%"] = baseLowBeta["theta"]["times"] / baseLowBeta["times"];
  //             baseLowBetaRateTheta.value = (baseLowBeta["theta"]["%"] * 10000).toInt() / 100;
  //             baseLowBetaTimesTheta.value = baseLowBeta["theta"]["times"];
  //             //计算LowAlpha波对LowBeta波出现相干关系的比例
  //             baseLowBeta["lowAlpha"]["%"] = baseLowBeta["lowAlpha"]["times"] / baseLowBeta["times"];
  //             baseLowBetaRateLowAlpha.value = (baseLowBeta["lowAlpha"]["%"] * 10000).toInt() / 100;
  //             baseLowBetaTimesLowAlpha.value = baseLowBeta["lowAlpha"]["times"];
  //             //计算HighAlpha波对LowBeta波出现相干关系的比例
  //             baseLowBeta["highAlpha"]["%"] = baseLowBeta["highAlpha"]["times"] / baseLowBeta["times"];
  //             baseLowBetaRateHighAlpha.value = (baseLowBeta["highAlpha"]["%"] * 10000).toInt() / 100;
  //             baseLowBetaTimesHighAlpha.value = baseLowBeta["highAlpha"]["times"];
  //             //计算LowGamma波对LowBeta波出现相干关系的比例
  //             baseLowBeta["lowGamma"]["%"] = baseLowBeta["lowGamma"]["times"] / baseLowBeta["times"];
  //             baseLowBetaRateLowGamma.value = (baseLowBeta["lowGamma"]["%"] * 10000).toInt() / 100;
  //             baseLowBetaTimesLowGamma.value = baseLowBeta["lowGamma"]["times"];
  //             //计算MiddleGamma波对LowBeta波出现相干关系的比例
  //             baseLowBeta["middleGamma"]["%"] = baseLowBeta["middleGamma"]["times"] / baseLowBeta["times"];
  //             baseLowBetaRateMiddleGamma.value = (baseLowBeta["middleGamma"]["%"] * 10000).toInt() / 100;
  //             baseLowBetaTimesMiddleGamma.value = baseLowBeta["middleGamma"]["times"];
  //             ///
  //             List list = [
  //               baseLowBeta["delta"]["times"],
  //               baseLowBeta["theta"]["times"],
  //               baseLowBeta["lowAlpha"]["times"],
  //               baseLowBeta["highAlpha"]["times"],
  //               baseLowBeta["lowGamma"]["times"],
  //               baseLowBeta["middleGamma"]["times"]
  //             ];
  //             int w = -1;
  //             int t = 2;
  //             for (int i = 0; i < list.length; i++) {
  //               if (t <= list[i] && list[i] > 1) {
  //                 t = list[i];
  //                 w = i;
  //               }
  //             }
  //             if (w >= 0) {
  //               Map<String, dynamic> base = trendSign["lowBeta"]!;
  //               baseLowBeta["mv"] = base["mv"];
  //               baseLowBeta["trend"] = base["trend"];
  //               baseLowBeta["sign"] = base["sign"];
  //               baseLowBeta["activity"] = base["activity"];
  //               baseLowBetaMv.value = baseLowBeta["mv"].toInt();
  //               baseLowBetaTrend.value = baseLowBeta["trend"];
  //               baseLowBetaSign.value = (baseLowBeta["sign"] * 10000).toInt() / 100;
  //               baseLowBetaActivity.value = (baseLowBeta["activity"] * 10000).toInt() / 100;
  //               //
  //               baseLowBeta["queen"]["name"] = notBetaList[w];
  //               baseLowBeta["queen"]["times"] = baseLowBeta[notBetaList[w]]["times"];
  //               baseLowBeta["queen"]["%"] = baseLowBeta[notBetaList[w]]["%"];
  //               Map<String, dynamic> queen = trendSign[notBetaList[w]]!;
  //               baseLowBeta["queen"]["mv"] = queen["mv"];
  //               baseLowBeta["queen"]["trend"] = queen["trend"];
  //               baseLowBeta["queen"]["sign"] = queen["sign"];
  //               baseLowBeta["queen"]["activity"] = queen["activity"];
  //               baseLowBetaQueenName.value = baseLowBeta["queen"]["name"];
  //               baseLowBetaQueenTimes.value = baseLowBeta["queen"]["times"];
  //               baseLowBetaQueenPercent.value = (baseLowBeta["queen"]["%"] * 10000).toInt() / 100;
  //               baseLowBetaQueenMv.value = baseLowBeta["queen"]["mv"].toInt();
  //               baseLowBetaQueenTrend.value = baseLowBeta["queen"]["trend"];
  //               baseLowBetaQueenSign.value = (baseLowBeta["queen"]["sign"] * 10000).toInt() / 100;
  //               baseLowBetaQueenActivity.value = (baseLowBeta["queen"]["activity"] * 10000).toInt() / 100;
  //               int p = -1;
  //               double s = 0.001;
  //               for (int i = 8; i < points; i++) {
  //                 double temp = baseLowBeta[notBetaList[w]]["sign"][i];
  //                 if (s < temp) {
  //                   s = temp;
  //                   p = i;
  //                 }
  //               }
  //               if (p >= 8) {
  //                 baseLowBeta["queen"]["signTop"] = baseLowBeta[notBetaList[w]]["sign"][p];
  //                 baseLowBeta["queen"]["signTopPoint"] = p;
  //                 baseLowBeta["queen"]["signTopMv"] = baseLowBeta[notBetaList[w]]["mv"][p];
  //                 baseLowBetaQueenSignTop.value = (baseLowBeta["queen"]["signTop"] * 1000).toInt() / 10;
  //                 baseLowBetaQueenSignTopPoint.value = baseLowBeta["queen"]["signTopPoint"];
  //                 baseLowBetaQueenSignTopPercent.value = (((baseLowBeta["queen"]["signTopPoint"] - 7) / 8) * 1000).toInt() / 10;
  //                 baseLowBetaQueenSignTopMv.value = (baseLowBeta["queen"]["signTopMv"] * 1000).toInt() / 10;
  //               }
  //               p = -1;
  //               s = 0.001;
  //               for (int i = 8; i < points; i++) {
  //                 double temp = baseLowBeta[notBetaList[w]]["activity"][i];
  //                 if (s < temp) {
  //                   s = temp;
  //                   p = i;
  //                 }
  //               }
  //               if (p >= 8) {
  //                 baseLowBeta["queen"]["activityTop"] = baseLowBeta[notBetaList[w]]["activity"][p];
  //                 baseLowBeta["queen"]["activityTopPoint"] = p;
  //                 baseLowBeta["queen"]["activityTopMv"] = baseLowBeta[notBetaList[w]]["mv"][p];
  //                 baseLowBetaQueenActivityTop.value = (baseLowBeta["queen"]["activityTop"] * 1000).toInt() / 10;
  //                 baseLowBetaQueenActivityTopPoint.value = baseLowBeta["queen"]["activityTopPoint"];
  //                 baseLowBetaQueenActivityTopPercent.value = (((baseLowBeta["queen"]["activityTopPoint"] - 7) / 8) * 1000).toInt() / 10;
  //                 baseLowBetaQueenActivityTopMv.value = (baseLowBeta["queen"]["activityTopMv"] * 1000).toInt() / 10;
  //               }
  //             }
  //           }
  //           //
  //           if (baseLowBeta["delta"]["times"] < 2) {
  //             trendBaseLowBetaController.isShowLine0.value = false;
  //             mvBaseLowBetaController.isShowLine0.value = false;
  //             signBaseLowBetaController.isShowLine0.value = false;
  //             activityBaseLowBetaController.isShowLine0.value = false;
  //           } else {
  //             trendBaseLowBetaController.setBarWidth(baseLowBeta["delta"]["times"] * lineWidthRate, i: 0);
  //             mvBaseLowBetaController.setBarWidth(baseLowBeta["delta"]["times"] * lineWidthRate, i: 0);
  //             signBaseLowBetaController.setBarWidth(baseLowBeta["delta"]["times"] * lineWidthRate, i: 0);
  //             activityBaseLowBetaController.setBarWidth(baseLowBeta["delta"]["times"] * lineWidthRate, i: 0);
  //           }
  //           if (baseLowBeta["theta"]["times"] < 2) {
  //             trendBaseLowBetaController.isShowLine1.value = false;
  //             mvBaseLowBetaController.isShowLine1.value = false;
  //             signBaseLowBetaController.isShowLine1.value = false;
  //             activityBaseLowBetaController.isShowLine1.value = false;
  //           } else {
  //             trendBaseLowBetaController.setBarWidth(baseLowBeta["theta"]["times"] * lineWidthRate, i: 1);
  //             mvBaseLowBetaController.setBarWidth(baseLowBeta["theta"]["times"] * lineWidthRate, i: 1);
  //             signBaseLowBetaController.setBarWidth(baseLowBeta["theta"]["times"] * lineWidthRate, i: 1);
  //             activityBaseLowBetaController.setBarWidth(baseLowBeta["theta"]["times"] * lineWidthRate, i: 1);
  //           }
  //           if (baseLowBeta["lowAlpha"]["times"] < 2) {
  //             trendBaseLowBetaController.isShowLine2.value = false;
  //             mvBaseLowBetaController.isShowLine2.value = false;
  //             signBaseLowBetaController.isShowLine2.value = false;
  //             activityBaseLowBetaController.isShowLine2.value = false;
  //           } else {
  //             trendBaseLowBetaController.setBarWidth(baseLowBeta["lowAlpha"]["times"] * lineWidthRate, i: 2);
  //             mvBaseLowBetaController.setBarWidth(baseLowBeta["lowAlpha"]["times"] * lineWidthRate, i: 2);
  //             signBaseLowBetaController.setBarWidth(baseLowBeta["lowAlpha"]["times"] * lineWidthRate, i: 2);
  //             activityBaseLowBetaController.setBarWidth(baseLowBeta["lowAlpha"]["times"] * lineWidthRate, i: 2);
  //           }
  //           if (baseLowBeta["highAlpha"]["times"] < 2) {
  //             trendBaseLowBetaController.isShowLine3.value = false;
  //             mvBaseLowBetaController.isShowLine3.value = false;
  //             signBaseLowBetaController.isShowLine3.value = false;
  //             activityBaseLowBetaController.isShowLine3.value = false;
  //           } else {
  //             trendBaseLowBetaController.setBarWidth(baseLowBeta["highAlpha"]["times"] * lineWidthRate, i: 3);
  //             mvBaseLowBetaController.setBarWidth(baseLowBeta["highAlpha"]["times"] * lineWidthRate, i: 3);
  //             signBaseLowBetaController.setBarWidth(baseLowBeta["highAlpha"]["times"] * lineWidthRate, i: 3);
  //             activityBaseLowBetaController.setBarWidth(baseLowBeta["highAlpha"]["times"] * lineWidthRate, i: 3);
  //           }
  //           trendBaseLowBetaController.isShowLine4.value = false;
  //           mvBaseLowBetaController.isShowLine4.value = false;
  //           signBaseLowBetaController.isShowLine4.value = false;
  //           activityBaseLowBetaController.isShowLine4.value = false;
  //           trendBaseLowBetaController.isShowLine5.value = false;
  //           mvBaseLowBetaController.isShowLine5.value = false;
  //           signBaseLowBetaController.isShowLine5.value = false;
  //           activityBaseLowBetaController.isShowLine5.value = false;
  //           if (baseLowBeta["lowGamma"]["times"] < 2) {
  //             trendBaseLowBetaController.isShowLine6.value = false;
  //             mvBaseLowBetaController.isShowLine6.value = false;
  //             signBaseLowBetaController.isShowLine6.value = false;
  //             activityBaseLowBetaController.isShowLine6.value = false;
  //           } else {
  //             trendBaseLowBetaController.setBarWidth(baseLowBeta["lowGamma"]["times"] * lineWidthRate, i: 6);
  //             mvBaseLowBetaController.setBarWidth(baseLowBeta["lowGamma"]["times"] * lineWidthRate, i: 6);
  //             signBaseLowBetaController.setBarWidth(baseLowBeta["lowGamma"]["times"] * lineWidthRate, i: 6);
  //             activityBaseLowBetaController.setBarWidth(baseLowBeta["lowGamma"]["times"] * lineWidthRate, i: 6);
  //           }
  //           if (baseLowBeta["middleGamma"]["times"] < 2) {
  //             trendBaseLowBetaController.isShowLine7.value = false;
  //             mvBaseLowBetaController.isShowLine7.value = false;
  //             signBaseLowBetaController.isShowLine7.value = false;
  //             activityBaseLowBetaController.isShowLine7.value = false;
  //           } else {
  //             trendBaseLowBetaController.setBarWidth(baseLowBeta["middleGamma"]["times"] * lineWidthRate, i: 7);
  //             mvBaseLowBetaController.setBarWidth(baseLowBeta["middleGamma"]["times"] * lineWidthRate, i: 7);
  //             signBaseLowBetaController.setBarWidth(baseLowBeta["middleGamma"]["times"] * lineWidthRate, i: 7);
  //             activityBaseLowBetaController.setBarWidth(baseLowBeta["middleGamma"]["times"] * lineWidthRate, i: 7);
  //           }
  //           //
  //           if (baseHighBeta["times"] > 0) {
  //             baseHighBeta["%"] = baseHighBeta["times"] / points;
  //             baseHighBetaRate.value = (baseHighBeta["%"] * 10000).toInt() / 100;
  //             baseHighBetaTimes.value = baseHighBeta["times"];
  //             //计算Delta波对HighBeta波出现相干关系的比例
  //             baseHighBeta["delta"]["%"] = baseHighBeta["delta"]["times"] / baseHighBeta["times"];
  //             baseHighBetaRateDelta.value = (baseHighBeta["delta"]["%"] * 10000).toInt() / 100;
  //             baseHighBetaTimesDelta.value = baseHighBeta["delta"]["times"];
  //             //计算Theta波对HighBeta波出现相干关系的比例
  //             baseHighBeta["theta"]["%"] = baseHighBeta["theta"]["times"] / baseHighBeta["times"];
  //             baseHighBetaRateTheta.value = (baseHighBeta["theta"]["%"] * 10000).toInt() / 100;
  //             baseHighBetaTimesTheta.value = baseHighBeta["theta"]["times"];
  //             //计算LowAlpha波对HighBeta波出现相干关系的比例
  //             baseHighBeta["lowAlpha"]["%"] = baseHighBeta["lowAlpha"]["times"] / baseHighBeta["times"];
  //             baseHighBetaRateLowAlpha.value = (baseHighBeta["lowAlpha"]["%"] * 10000).toInt() / 100;
  //             baseHighBetaTimesLowAlpha.value = baseHighBeta["lowAlpha"]["times"];
  //             //计算HighAlpha波对HighBeta波出现相干关系的比例
  //             baseHighBeta["highAlpha"]["%"] = baseHighBeta["highAlpha"]["times"] / baseHighBeta["times"];
  //             baseHighBetaRateHighAlpha.value = (baseHighBeta["highAlpha"]["%"] * 10000).toInt() / 100;
  //             baseHighBetaTimesHighAlpha.value = baseHighBeta["highAlpha"]["times"];
  //             //计算LowGamma波对HighBeta波出现相干关系的比例
  //             baseHighBeta["lowGamma"]["%"] = baseHighBeta["lowGamma"]["times"] / baseHighBeta["times"];
  //             baseHighBetaRateLowGamma.value = (baseHighBeta["lowGamma"]["%"] * 10000).toInt() / 100;
  //             baseHighBetaTimesLowGamma.value = baseHighBeta["lowGamma"]["times"];
  //             //计算MiddleGamma波对HighBeta波出现相干关系的比例
  //             baseHighBeta["middleGamma"]["%"] = baseHighBeta["middleGamma"]["times"] / baseHighBeta["times"];
  //             baseHighBetaRateMiddleGamma.value = (baseHighBeta["middleGamma"]["%"] * 10000).toInt() / 100;
  //             baseHighBetaTimesMiddleGamma.value = baseHighBeta["middleGamma"]["times"];
  //             ///
  //             List list = [
  //               baseHighBeta["delta"]["times"],
  //               baseHighBeta["theta"]["times"],
  //               baseHighBeta["lowAlpha"]["times"],
  //               baseHighBeta["highAlpha"]["times"],
  //               baseHighBeta["lowGamma"]["times"],
  //               baseHighBeta["middleGamma"]["times"]
  //             ];
  //             int w = -1;
  //             int t = 2;
  //             for (int i = 0; i < list.length; i++) {
  //               if (t <= list[i] && list[i] > 1) {
  //                 t = list[i];
  //                 w = i;
  //               }
  //             }
  //             if (w >= 0) {
  //               Map<String, dynamic> base = trendSign["highBeta"]!;
  //               baseHighBeta["mv"] = base["mv"];
  //               baseHighBeta["trend"] = base["trend"];
  //               baseHighBeta["sign"] = base["sign"];
  //               baseHighBeta["activity"] = base["activity"];
  //               baseHighBetaMv.value = baseHighBeta["mv"].toInt();
  //               baseHighBetaTrend.value = baseHighBeta["trend"];
  //               baseHighBetaSign.value = (baseHighBeta["sign"] * 10000).toInt() / 100;
  //               baseHighBetaActivity.value = (baseHighBeta["activity"] * 10000).toInt() / 100;
  //               //
  //               baseHighBeta["queen"]["name"] = notBetaList[w];
  //               baseHighBeta["queen"]["times"] = baseHighBeta[notBetaList[w]]["times"];
  //               baseHighBeta["queen"]["%"] = baseHighBeta[notBetaList[w]]["%"];
  //               Map<String, dynamic> queen = trendSign[notBetaList[w]]!;
  //               baseHighBeta["queen"]["mv"] = queen["mv"];
  //               baseHighBeta["queen"]["trend"] = queen["trend"];
  //               baseHighBeta["queen"]["sign"] = queen["sign"];
  //               baseHighBeta["queen"]["activity"] = queen["activity"];
  //               baseHighBetaQueenName.value = baseHighBeta["queen"]["name"];
  //               baseHighBetaQueenTimes.value = baseHighBeta["queen"]["times"];
  //               baseHighBetaQueenPercent.value = (baseHighBeta["queen"]["%"] * 10000).toInt() / 100;
  //               baseHighBetaQueenMv.value = baseHighBeta["queen"]["mv"].toInt();
  //               baseHighBetaQueenTrend.value = baseHighBeta["queen"]["trend"];
  //               baseHighBetaQueenSign.value = (baseHighBeta["queen"]["sign"] * 10000).toInt() / 100;
  //               baseHighBetaQueenActivity.value = (baseHighBeta["queen"]["activity"] * 10000).toInt() / 100;
  //               int p = -1;
  //               double s = 0.001;
  //               for (int i = 8; i < points; i++) {
  //                 double temp = baseHighBeta[notBetaList[w]]["sign"][i];
  //                 if (s < temp) {
  //                   s = temp;
  //                   p = i;
  //                 }
  //               }
  //               if (p >= 8) {
  //                 baseHighBeta["queen"]["signTop"] = baseHighBeta[notBetaList[w]]["sign"][p];
  //                 baseHighBeta["queen"]["signTopPoint"] = p;
  //                 baseHighBeta["queen"]["signTopMv"] = baseHighBeta[notBetaList[w]]["mv"][p];
  //                 baseHighBetaQueenSignTop.value = (baseHighBeta["queen"]["signTop"] * 10000).toInt() / 100;
  //                 baseHighBetaQueenSignTopPoint.value = baseHighBeta["queen"]["signTopPoint"];
  //                 baseHighBetaQueenSignTopPercent.value = (((baseHighBeta["queen"]["signTopPoint"] - 7) / 8) * 1000).toInt() / 10;
  //                 baseHighBetaQueenSignTopMv.value = (baseHighBeta["queen"]["signTopMv"] * 10000).toInt() / 100;
  //               }
  //               p = -1;
  //               s = 0.001;
  //               for (int i = 8; i < points; i++) {
  //                 double temp = baseHighBeta[notBetaList[w]]["activity"][i];
  //                 if (s < temp) {
  //                   s = temp;
  //                   p = i;
  //                 }
  //               }
  //               if (p >= 8) {
  //                 baseHighBeta["queen"]["activityTop"] = baseHighBeta[notBetaList[w]]["activity"][p];
  //                 baseHighBeta["queen"]["activityTopPoint"] = p;
  //                 baseHighBeta["queen"]["activityTopMv"] = baseHighBeta[notBetaList[w]]["mv"][p];
  //                 baseHighBetaQueenActivityTop.value = (baseHighBeta["queen"]["activityTop"] * 10000).toInt() / 100;
  //                 baseHighBetaQueenActivityTopPoint.value = baseHighBeta["queen"]["activityTopPoint"];
  //                 baseHighBetaQueenActivityTopPercent.value = (((baseHighBeta["queen"]["activityTopPoint"] - 7) / 8) * 1000).toInt() / 10;
  //                 baseHighBetaQueenActivityTopMv.value = (baseHighBeta["queen"]["activityTopMv"] * 10000).toInt() / 100;
  //               }
  //             }
  //           }
  //           //
  //           if (baseHighBeta["delta"]["times"] < 2) {
  //             trendBaseHighBetaController.isShowLine0.value = false;
  //             mvBaseHighBetaController.isShowLine0.value = false;
  //             signBaseHighBetaController.isShowLine0.value = false;
  //             activityBaseHighBetaController.isShowLine0.value = false;
  //           } else {
  //             trendBaseHighBetaController.setBarWidth(baseHighBeta["delta"]["times"] * lineWidthRate, i: 0);
  //             mvBaseHighBetaController.setBarWidth(baseHighBeta["delta"]["times"] * lineWidthRate, i: 0);
  //             signBaseHighBetaController.setBarWidth(baseHighBeta["delta"]["times"] * lineWidthRate, i: 0);
  //             activityBaseHighBetaController.setBarWidth(baseHighBeta["delta"]["times"] * lineWidthRate, i: 0);
  //           }
  //           if (baseHighBeta["theta"]["times"] < 2) {
  //             trendBaseHighBetaController.isShowLine1.value = false;
  //             mvBaseHighBetaController.isShowLine1.value = false;
  //             signBaseHighBetaController.isShowLine1.value = false;
  //             activityBaseHighBetaController.isShowLine1.value = false;
  //           } else {
  //             trendBaseHighBetaController.setBarWidth(baseHighBeta["theta"]["times"] * lineWidthRate, i: 1);
  //             mvBaseHighBetaController.setBarWidth(baseHighBeta["theta"]["times"] * lineWidthRate, i: 1);
  //             signBaseHighBetaController.setBarWidth(baseHighBeta["theta"]["times"] * lineWidthRate, i: 1);
  //             activityBaseHighBetaController.setBarWidth(baseHighBeta["theta"]["times"] * lineWidthRate, i: 1);
  //           }
  //           if (baseHighBeta["lowAlpha"]["times"] < 2) {
  //             trendBaseHighBetaController.isShowLine2.value = false;
  //             mvBaseHighBetaController.isShowLine2.value = false;
  //             signBaseHighBetaController.isShowLine2.value = false;
  //             activityBaseHighBetaController.isShowLine2.value = false;
  //           } else {
  //             trendBaseHighBetaController.setBarWidth(baseHighBeta["lowAlpha"]["times"] * lineWidthRate, i: 2);
  //             mvBaseHighBetaController.setBarWidth(baseHighBeta["lowAlpha"]["times"] * lineWidthRate, i: 2);
  //             signBaseHighBetaController.setBarWidth(baseHighBeta["lowAlpha"]["times"] * lineWidthRate, i: 2);
  //             activityBaseHighBetaController.setBarWidth(baseHighBeta["lowAlpha"]["times"] * lineWidthRate, i: 2);
  //           }
  //           if (baseHighBeta["highAlpha"]["times"] < 2) {
  //             trendBaseHighBetaController.isShowLine3.value = false;
  //             mvBaseHighBetaController.isShowLine3.value = false;
  //             signBaseHighBetaController.isShowLine3.value = false;
  //             activityBaseHighBetaController.isShowLine3.value = false;
  //           } else {
  //             trendBaseHighBetaController.setBarWidth(baseHighBeta["highAlpha"]["times"] * lineWidthRate, i: 3);
  //             mvBaseHighBetaController.setBarWidth(baseHighBeta["highAlpha"]["times"] * lineWidthRate, i: 3);
  //             signBaseHighBetaController.setBarWidth(baseHighBeta["highAlpha"]["times"] * lineWidthRate, i: 3);
  //             activityBaseHighBetaController.setBarWidth(baseHighBeta["highAlpha"]["times"] * lineWidthRate, i: 3);
  //           }
  //           trendBaseHighBetaController.isShowLine4.value = false;
  //           mvBaseHighBetaController.isShowLine4.value = false;
  //           signBaseHighBetaController.isShowLine4.value = false;
  //           activityBaseHighBetaController.isShowLine4.value = false;
  //           trendBaseHighBetaController.isShowLine5.value = false;
  //           mvBaseHighBetaController.isShowLine5.value = false;
  //           signBaseHighBetaController.isShowLine5.value = false;
  //           activityBaseHighBetaController.isShowLine5.value = false;
  //           if (baseHighBeta["lowGamma"]["times"] < 2) {
  //             trendBaseHighBetaController.isShowLine6.value = false;
  //             mvBaseHighBetaController.isShowLine6.value = false;
  //             signBaseHighBetaController.isShowLine6.value = false;
  //             activityBaseHighBetaController.isShowLine6.value = false;
  //           } else {
  //             trendBaseHighBetaController.setBarWidth(baseHighBeta["lowGamma"]["times"] * lineWidthRate, i: 6);
  //             mvBaseHighBetaController.setBarWidth(baseHighBeta["lowGamma"]["times"] * lineWidthRate, i: 6);
  //             signBaseHighBetaController.setBarWidth(baseHighBeta["lowGamma"]["times"] * lineWidthRate, i: 6);
  //             activityBaseHighBetaController.setBarWidth(baseHighBeta["lowGamma"]["times"] * lineWidthRate, i: 6);
  //           }
  //           if (baseHighBeta["middleGamma"]["times"] < 2) {
  //             trendBaseHighBetaController.isShowLine7.value = false;
  //             mvBaseHighBetaController.isShowLine7.value = false;
  //             signBaseHighBetaController.isShowLine7.value = false;
  //             activityBaseHighBetaController.isShowLine7.value = false;
  //           } else {
  //             trendBaseHighBetaController.setBarWidth(baseHighBeta["middleGamma"]["times"] * lineWidthRate, i: 7);
  //             mvBaseHighBetaController.setBarWidth(baseHighBeta["middleGamma"]["times"] * lineWidthRate, i: 7);
  //             signBaseHighBetaController.setBarWidth(baseHighBeta["middleGamma"]["times"] * lineWidthRate, i: 7);
  //             activityBaseHighBetaController.setBarWidth(baseHighBeta["middleGamma"]["times"] * lineWidthRate, i: 7);
  //           }
  //           //
  //           List<int> lsm = selecteMusic();
  //           if (lsm.length > 1) {
  //             wuluohaiMusicIndex.value = lsm[Random().nextInt(lsm.length)];
  //           } else if (lsm.isNotEmpty) {
  //             wuluohaiMusicIndex.value = lsm[0];
  //           }
  //           //
  //           String promputTemp = "";
  //           for (int i = 0; i < 8; i++) {
  //             promputTemp += "${color8CN[i]}${(halo[i] * 100).toInt()}%\n";
  //           }
  //           aiMandalaPrompt.value = promputTemp;
  //           //计算情绪数据
  //           int emoAtt = Data.calculateMV(_bciData["att"]!).toInt(); //专注度
  //           int emoMed = Data.calculateMV(_bciData["med"]!).toInt(); //安全感
  //           int emoFlow = ((emoAtt + emoMed) / 2).toInt(); //心流指数
  //           int emoRelax = ((100 - emoAtt + emoMed) / 2).toInt(); //松弛度
  //           int posEmo = emoV3.value + emoV4.value + emoV7.value + emoV8.value + emoV11.value + emoV12.value + emoV15.value + emoV16.value;
  //           int emoHappy = (posEmo / 40 * 100).toInt(); //愉悦度
  //           emoHappy = emoHappy < 30 ? emoHappy + 30 : emoHappy;
  //           emoHappy = emoHappy > 100 ? 100 : emoHappy;
  //           String randomStr = "意境：${contentTheme[Random().nextInt(contentTheme.length)]}";
  //           String randomStr2 = "意蕴：${auxiliaryElements[Random().nextInt(auxiliaryElements.length)]}";
  //           aiDreanPrompt.value = "专注度: $emoAtt%\n安全感: $emoMed%\n心流指数: $emoFlow%\n松弛度: $emoRelax%\n愉悦度: $emoHappy%\n$randomStr\n$randomStr2\n$promputTemp";
  //         }
  //       }
  //     }
  //   }

  //用于缓存历史hrv数据（3分钟）
  final List<double> hrvData = <double>[];
  final hrvCtrl = Get.put(HrvCtrl());
  void hrv(List<String> messages) {
    if (messages.isNotEmpty && hrvData.length < customerCtrl.sampleSize.value) {
      double last = 0.0;
      if (hrvData.isNotEmpty) {
        last = hrvData.last;
      }
      for (String item in messages) {
        double x = double.parse(item);
        if ((x - last).abs() >= 1) {
          hrvData.add(x);
          if ((x - last).abs() >= 50) {
            hrvCtrl.nn50.value++;
          } else if ((x - last).abs() >= 30 && (x - last).abs() < 50) {
            hrvCtrl.nn30.value++;
          } else {
            hrvCtrl.nn10.value++;
          }
          hrvCtrl.nnCount.value = hrvCtrl.nn50.value + hrvCtrl.nn30.value + hrvCtrl.nn10.value;
          last = x;
          if (hrvData.length == 16) baselineCtrl.hrv.value = (baselineCtrl.median(hrvData)).toInt();
          if (hrvData.length == customerCtrl.sampleSize.value) {
            customerCtrl.isRecordingHrv.value = false; //停止HRV数据收集
            break;
          }
        }
      }
    }
  }

  // void clearData() {
  //   ///脑波
  //   bciDataDelta.clear();
  //   bciDataTheta.clear();
  //   bciDataLowAlpha.clear();
  //   bciDataHighAlpha.clear();
  //   bciDataLowBeta.clear();
  //   bciDataHighBeta.clear();
  //   bciDataLowGamma.clear();
  //   bciDataMiddleGamma.clear();
  //   //额温
  //   bciDataTemperature.clear();
  //   //心率
  //   bciDataHeartRate.clear();
  //   //情绪
  //   bciDataAtt.clear();
  //   bciDataMed.clear();
  //   //清空缓存数据
  //   _bciData['att']!.clear();
  //   _bciData['med']!.clear();
  //   _bciData['delta']!.clear();
  //   _bciData['theta']!.clear();
  //   _bciData['lowAlpha']!.clear();
  //   _bciData['highAlpha']!.clear();
  //   _bciData['lowBeta']!.clear();
  //   _bciData['highBeta']!.clear();
  //   _bciData['lowGamma']!.clear();
  //   _bciData['middleGamma']!.clear();
  //   _bciData['temperature']!.clear();
  //   _bciData['heartRate']!.clear();
  //   //
  //   wavesController.clearSpots();
  //   ///
  //   pureController.clearSpots();
  //   mvController.clearSpots();
  //   trendController.clearSpots();
  //   deepthController.clearSpots();
  //   signController.clearSpots();
  //   activityController.clearSpots();
  //   pureCount.value = 0;
  //   //
  //   mvBaseLowBetaController.clearSpots();
  //   signBaseLowBetaController.clearSpots();
  //   activityBaseLowBetaController.clearSpots();
  //   trendBaseLowBetaController.clearSpots();
  //   baseLowBetaRate.value = 0.0;
  //   baseLowBetaRateDelta.value = 0.0;
  //   baseLowBetaRateTheta.value = 0.0;
  //   baseLowBetaRateLowAlpha.value = 0.0;
  //   baseLowBetaRateHighAlpha.value = 0.0;
  //   baseLowBetaRateLowGamma.value = 0.0;
  //   baseLowBetaRateMiddleGamma.value = 0.0;
  //   baseLowBetaMv.value = 0;
  //   baseLowBetaTrend.value = 0;
  //   baseLowBetaSign.value = 0.0;
  //   baseLowBetaActivity.value = 0.0;
  //   baseLowBetaQueenName.value = "";
  //   baseLowBetaQueenTimes.value = 0;
  //   baseLowBetaQueenPercent.value = 0.0;
  //   baseLowBetaQueenMv.value = 0;
  //   baseLowBetaQueenTrend.value = 0;
  //   baseLowBetaQueenSign.value = 0.0;
  //   baseLowBetaQueenActivity.value = 0.0;
  //   baseLowBetaQueenSignTop.value = 0.0;
  //   baseLowBetaQueenSignTopPoint.value = 0;
  //   baseLowBetaQueenSignTopPercent.value = 0.0;
  //   baseLowBetaQueenSignTopMv.value = 0.0;
  //   baseLowBetaQueenActivityTop.value = 0.0;
  //   baseLowBetaQueenActivityTopPoint.value = 0;
  //   baseLowBetaQueenActivityTopPercent.value = 0.0;
  //   baseLowBetaQueenActivityTopMv.value = 0.0;
  //   //
  //   mvBaseHighBetaController.clearSpots();
  //   signBaseHighBetaController.clearSpots();
  //   activityBaseHighBetaController.clearSpots();
  //   trendBaseHighBetaController.clearSpots();
  //   baseHighBetaRate.value = 0.0;
  //   baseHighBetaRateDelta.value = 0.0;
  //   baseHighBetaRateTheta.value = 0.0;
  //   baseHighBetaRateLowAlpha.value = 0.0;
  //   baseHighBetaRateHighAlpha.value = 0.0;
  //   baseHighBetaRateLowGamma.value = 0.0;
  //   baseHighBetaRateMiddleGamma.value = 0.0;
  //   baseHighBetaMv.value = 0;
  //   baseHighBetaTrend.value = 0;
  //   baseHighBetaSign.value = 0.0;
  //   baseHighBetaActivity.value = 0.0;
  //   baseHighBetaQueenName.value = "";
  //   baseHighBetaQueenTimes.value = 0;
  //   baseHighBetaQueenPercent.value = 0.0;
  //   baseHighBetaQueenMv.value = 0;
  //   baseHighBetaQueenTrend.value = 0;
  //   baseHighBetaQueenSign.value = 0.0;
  //   baseHighBetaQueenActivity.value = 0.0;
  //   baseHighBetaQueenSignTop.value = 0.0;
  //   baseHighBetaQueenSignTopPoint.value = 0;
  //   baseHighBetaQueenSignTopPercent.value = 0.0;
  //   baseHighBetaQueenSignTopMv.value = 0.0;
  //   baseHighBetaQueenActivityTop.value = 0.0;
  //   baseHighBetaQueenActivityTopPoint.value = 0;
  //   baseHighBetaQueenActivityTopPercent.value = 0.0;
  //   baseHighBetaQueenActivityTopMv.value = 0.0;
  //   //
  //   basePercent.value = 0.0;
  //   pressValue.value = 0.0;
  //   leftPressValue.value = 0.0;
  //   rightPressValue.value = 0.0;
  //   sensitiveValue.value = 0.0;
  //   sensitivePoint.value = 0;
  //   sensitiveWave.value = "";
  //   //
  //   lowAlphaTrend.value = 0;
  //   lowAlphaSign.value = 0.0;
  //   highAlphaTrend.value = 0;
  //   highAlphaSign.value = 0.0;
  //   //
  //   lowBetaTrend.value = 0;
  //   lowBetaSign.value = 0.0;
  //   highBetaTrend.value = 0;
  //   highBetaSign.value = 0.0;
  //   ///清空hrv数据缓存
  //   hrvData.clear();
  //   curHeartRate.value = 60.0;
  //   hrvNNCount.value = 3;
  //   hrvNN50.value = 1;
  //   hrvNN3040.value = 1;
  //   hrvNN30.value = 1;
  //   //
  //   //
  //   emoV1.value = 0;
  //   emoV2.value = 0;
  //   emoV3.value = 0;
  //   emoV4.value = 0;
  //   emoV5.value = 0;
  //   emoV6.value = 0;
  //   emoV7.value = 0;
  //   emoV8.value = 0;
  //   emoV9.value = 0;
  //   emoV10.value = 0;
  //   emoV11.value = 0;
  //   emoV12.value = 0;
  //   emoV13.value = 0;
  //   emoV14.value = 0;
  //   emoV15.value = 0;
  //   emoV16.value = 0;
  //   //
  //   lowBetaBase.value = 10000;
  //   lowBetaMin.value = 5000;
  //   highBetaBase.value = 10000;
  //   highBetaMin.value = 5000;
  //   //
  //   uuid.value = '';
  //   //
  //   brainLoad.value = 0.0;
  //   brainLoadTop.value = 1.0;
  //   brainLoadTemp.value = 1.0;
  //   //
  //   haloDelta.value = 0.3;
  //   haloTheta.value = 0.4;
  //   haloLowAlpha.value = 0.5;
  //   haloHighAlpha.value = 0.6;
  //   haloLowBeta.value = 0.7;
  //   haloHighBeta.value = 0.8;
  //   haloLowGamma.value = 0.9;
  //   haloMiddleGamma.value = 1.0;
  //   //
  //   chakra0Delta.value = 1.0;
  //   chakra1Theta.value = 1.0;
  //   chakra2LowAlpha.value = 1.0;
  //   chakra3HighAlpha.value = 1.0;
  //   chakra4LowBeta.value = 1.0;
  //   chakra5HighBeta.value = 1.0;
  //   chakra6LowGamma.value = 1.0;
  //   chakra7MiddleGamma.value = 1.0;
  //   //
  //   wuluohaiMusicIndex.value = -1;
  //   //
  //   aiMandalaPrompt.value = "";
  //   aiMandalaImageUrl.value = "";
  //   aiMandalaImagePath.value = "";
  //   isGettingAiMandalaImage.value = false;
  //   //
  //   analysisMandalaImagePrompt.value = "";
  //   analysisMandalaImageText.value = "";
  //   isAnalysisMandalaImage.value = false;
  //   //
  //   aiDreanPrompt.value = "";
  //   aiDreanImageUrl.value = "";
  //   aiDreanImagePath.value = "";
  //   isGettingAiDreanImage.value = false;
  //   //
  //   analysisDreanImagePrompt.value = "";
  //   analysisDreanImageText.value = "";
  //   isAnalysisDreanImage.value = false;
  //   //
  //   staffNoteList.value = [];
  // }

  // ///
  // final RxString aiMandalaPrompt = "".obs;
  // final RxString aiMandalaImageUrl = "".obs;
  // final RxString aiMandalaImagePath = "".obs;
  // final RxBool isGettingAiMandalaImage = false.obs;
  // Future<void> drawMandala() async {
  //   if (isGettingAiMandalaImage.value) {
  //     return;
  //   }
  //   isGettingAiMandalaImage.value = true;
  //   if (user.loginState.value != 2) {
  //     isGettingAiMandalaImage.value = false;
  //     Get.snackbar(
  //       "请先登录",
  //       "未登录或未联网，无法使用AI功能",
  //       colorText: colorSurface,
  //       backgroundColor: colorPrimary,
  //       snackPosition: SnackPosition.BOTTOM,
  //       margin: const EdgeInsets.all(10),
  //     );
  //     return;
  //   }
  //   //余额不足
  //   if (user.tokens.value + user.usingTokens.value < 1) {
  //     isGettingAiMandalaImage.value = false;
  //     Get.snackbar(
  //       "请先充值",
  //       "您的账号余额不足，无法使用AI功能",
  //       colorText: colorSurface,
  //       backgroundColor: colorPrimary,
  //       snackPosition: SnackPosition.BOTTOM,
  //       margin: const EdgeInsets.all(10),
  //     );
  //     return;
  //   }
  //   try {
  //     if (user.usingTokens.value <= 0) {
  //       await user.useOneToken();
  //     }
  //     aiMandalaImageUrl.value = await Data.generateAiImage("7579177267255935018", aiMandalaPrompt.value, user.bearer.value);
  //     if (aiMandalaImageUrl.value.length > 20) {
  //       analysisMandalaImagePrompt.value = "${aiMandalaImageUrl.value}\n${aiMandalaPrompt.value}";
  //       user.usingTokens.value -= 1;
  //       await user.cache();
  //       Get.snackbar(
  //         "成功！",
  //         "图片已生成！",
  //         colorText: colorSurface,
  //         backgroundColor: Colors.green,
  //         snackPosition: SnackPosition.BOTTOM,
  //         margin: const EdgeInsets.all(10),
  //       );
  //       String sub = aiMandalaImageUrl.value.substring(20, aiMandalaImageUrl.value.length - 1);
  //       if (sub.isNotEmpty) {
  //         String savePath = await Data.path("$sub.png");
  //         await Data.downloadAndSaveImage(aiMandalaImageUrl.value, savePath);
  //         aiMandalaImagePath.value = savePath;
  //         await Data.saveImageToGallery(savePath);
  //         Get.snackbar(
  //           "成功！",
  //           "图片已保存到相册",
  //           colorText: colorSurface,
  //           backgroundColor: Colors.green,
  //           snackPosition: SnackPosition.BOTTOM,
  //           margin: const EdgeInsets.all(10),
  //         );
  //       }
  //     }
  //   } finally {
  //     isGettingAiMandalaImage.value = false;
  //   }
  // }
  // final RxString analysisMandalaImagePrompt = "".obs;
  // final RxString analysisMandalaImageText = "".obs;
  // final RxBool isAnalysisMandalaImage = false.obs;
  // Future<void> analysisMandala() async {
  //   if (isAnalysisMandalaImage.value || analysisMandalaImagePrompt.value.isEmpty) {
  //     return;
  //   }
  //   try {
  //     isAnalysisMandalaImage.value = true;
  //     analysisMandalaImageText.value = await Data.generateAiText("7580830302571429938", analysisMandalaImagePrompt.value, user.bearer.value);
  //   } finally {
  //     isAnalysisMandalaImage.value = false;
  //   }
  // }
  // ///
  // final RxString aiDreanPrompt = "".obs;
  // final RxString aiDreanImageUrl = "".obs;
  // final RxString aiDreanImagePath = "".obs;
  // final RxBool isGettingAiDreanImage = false.obs;
  // Future<void> drawDream() async {
  //   if (isGettingAiDreanImage.value) {
  //     return;
  //   }
  //   try {
  //     isGettingAiDreanImage.value = true;
  //     if (user.loginState.value != 2) {
  //       Get.snackbar(
  //         "请先登录",
  //         "未登录或未联网，无法使用AI功能",
  //         colorText: colorSurface,
  //         backgroundColor: colorPrimary,
  //         snackPosition: SnackPosition.BOTTOM,
  //         margin: const EdgeInsets.all(10),
  //       );
  //       return;
  //     }
  //     //余额不足
  //     if (user.tokens.value + user.usingTokens.value < 1) {
  //       Get.snackbar(
  //         "请先充值",
  //         "您的账号余额不足，无法使用AI功能",
  //         colorText: colorSurface,
  //         backgroundColor: colorPrimary,
  //         snackPosition: SnackPosition.BOTTOM,
  //         margin: const EdgeInsets.all(10),
  //       );
  //       return;
  //     }
  //     if (user.usingTokens.value <= 0) {
  //       await user.useOneToken();
  //     }
  //     aiDreanImageUrl.value = await Data.generateAiImage("7509773070840922149", aiDreanPrompt.value, user.bearer.value);
  //     if (aiDreanImageUrl.value.length > 20) {
  //       analysisDreanImagePrompt.value = "${aiDreanImageUrl.value}\n${aiDreanPrompt.value}";
  //       user.usingTokens.value -= 1;
  //       await user.cache();
  //       Get.snackbar(
  //         "成功！",
  //         "图片已生成！",
  //         colorText: colorSurface,
  //         backgroundColor: Colors.green,
  //         snackPosition: SnackPosition.BOTTOM,
  //         margin: const EdgeInsets.all(10),
  //       );
  //       String sub = aiDreanImageUrl.value.substring(20, aiDreanImageUrl.value.length - 1);
  //       if (sub.isNotEmpty) {
  //         String savePath = await Data.path("$sub.png");
  //         await Data.downloadAndSaveImage(aiDreanImageUrl.value, savePath);
  //         aiDreanImagePath.value = savePath;
  //         await Data.saveImageToGallery(savePath);
  //         Get.snackbar(
  //           "成功！",
  //           "图片已保存到相册",
  //           colorText: colorSurface,
  //           backgroundColor: Colors.green,
  //           snackPosition: SnackPosition.BOTTOM,
  //           margin: const EdgeInsets.all(10),
  //         );
  //       }
  //     }
  //   } finally {
  //     isGettingAiDreanImage.value = false;
  //   }
  // }
  // final RxString analysisDreanImagePrompt = "".obs;
  // final RxString analysisDreanImageText = "".obs;
  // final RxBool isAnalysisDreanImage = false.obs;
  // Future<void> analysisDream() async {
  //   if (isAnalysisDreanImage.value || analysisDreanImagePrompt.value.isEmpty) {
  //     return;
  //   }
  //   try {
  //     isAnalysisDreanImage.value = true;
  //     analysisDreanImageText.value = await Data.generateAiText("7581779378108629035", analysisDreanImagePrompt.value, user.bearer.value);
  //   } finally {
  //     isAnalysisDreanImage.value = false;
  //   }
  // }
  // List<int> selecteMusic() {
  //   String beta = lowBetaSign.value < highBetaSign.value ? "lowBeta" : "highBeta";
  //   String notBeta = lowBetaSign.value < highBetaSign.value ? baseLowBetaQueenName.value : baseHighBetaQueenName.value;
  //   switch (beta) {
  //     case "highBeta":
  //       switch (notBeta) {
  //         case "delta":
  //           return [11, 20];
  //         case "theta":
  //           return [12, 21];
  //         case "lowAlpha":
  //           return [9];
  //         case "highAlpha":
  //           return [10];
  //         case "lowGamma":
  //           return [13, 14];
  //         case "middleGamma":
  //           return [7, 8, 16];
  //         default:
  //           return [0];
  //       }
  //     case "lowBeta":
  //       switch (notBeta) {
  //         case "delta":
  //           return [15, 19];
  //         case "theta":
  //           return [0, 1];
  //         case "lowAlpha":
  //           return [2, 22];
  //         case "highAlpha":
  //           return [3];
  //         case "lowGamma":
  //           return [4, 6, 18];
  //         case "middleGamma":
  //           return [5, 17];
  //         default:
  //           return [0];
  //       }
  //     default:
  //       return [0];
  //   }
  // }

  @override
  void onClose() {
    _resetTimer?.cancel();
    _audioPlayer.dispose();
    _bciAndHrvBroadcastListener?.cancel();
    clearData();
    super.onClose();
  }
}

// class WaveChartController extends GetxController {
//   static const int maxDataPoints = 30;
//   final double minY;
//   final double maxY;
//   final RxList<FlSpot> dataFlSpot = <FlSpot>[].obs;
//   double minX = 0;
//   double maxX = 1;
//   WaveChartController({
//     required this.minY,
//     required this.maxY,
//   });
//   @override
//   void onInit() {
//     super.onInit();
//     dataFlSpot.add(const FlSpot(0, 0));
//     minX = 0;
//     maxX = 1;
//   }
//   @override
//   void onClose() {
//     super.onClose();
//     dataFlSpot.clear();
//   }
//   Future<void> clearData() async {
//     dataFlSpot.clear();
//     dataFlSpot.add(const FlSpot(0, 0));
//     minX = 0;
//     maxX = 1;
//   }
//   Future<void> addDataPoint(double value) async {
//     double v = value;
//     if (v < minY) {
//       v = minY;
//     }
//     if (v > maxY) {
//       v = maxY;
//     }
//     if (dataFlSpot.isEmpty) {
//       dataFlSpot.add(const FlSpot(0, 0));
//     }
//     maxX = dataFlSpot.length.toDouble();
//     dataFlSpot.add(FlSpot(maxX, v));
//     if (maxX - minX > maxDataPoints) {
//       minX = maxX - maxDataPoints;
//     }
//     if (dataFlSpot.length > 1800) {
//       clearData();
//     }
//     update();
//   }
// }

// class WaveChart8Controller extends GetxController {
//   final double minY;
//   final double maxY;
//   final RxList<FlSpot> dataFlSpot0 = <FlSpot>[].obs;
//   final RxList<FlSpot> dataFlSpot1 = <FlSpot>[].obs;
//   final RxList<FlSpot> dataFlSpot2 = <FlSpot>[].obs;
//   final RxList<FlSpot> dataFlSpot3 = <FlSpot>[].obs;
//   final RxList<FlSpot> dataFlSpot4 = <FlSpot>[].obs;
//   final RxList<FlSpot> dataFlSpot5 = <FlSpot>[].obs;
//   final RxList<FlSpot> dataFlSpot6 = <FlSpot>[].obs;
//   final RxList<FlSpot> dataFlSpot7 = <FlSpot>[].obs;
//   WaveChart8Controller({
//     required this.minY,
//     required this.maxY,
//   });
//   @override
//   void onInit() {
//     super.onInit();
//     dataFlSpot0.add(const FlSpot(0, 0));
//     dataFlSpot1.add(const FlSpot(0, 0));
//     dataFlSpot2.add(const FlSpot(0, 0));
//     dataFlSpot3.add(const FlSpot(0, 0));
//     dataFlSpot4.add(const FlSpot(0, 0));
//     dataFlSpot5.add(const FlSpot(0, 0));
//     dataFlSpot6.add(const FlSpot(0, 0));
//     dataFlSpot7.add(const FlSpot(0, 0));
//   }
//   @override
//   void onClose() {
//     super.onClose();
//     dataFlSpot0.clear();
//     dataFlSpot1.clear();
//     dataFlSpot2.clear();
//     dataFlSpot3.clear();
//     dataFlSpot4.clear();
//     dataFlSpot5.clear();
//     dataFlSpot6.clear();
//     dataFlSpot7.clear();
//   }
//   Future<void> clearData() async {
//     dataFlSpot0.clear();
//     dataFlSpot0.add(const FlSpot(0, 0));
//     dataFlSpot1.clear();
//     dataFlSpot1.add(const FlSpot(0, 0));
//     dataFlSpot2.clear();
//     dataFlSpot2.add(const FlSpot(0, 0));
//     dataFlSpot3.clear();
//     dataFlSpot3.add(const FlSpot(0, 0));
//     dataFlSpot4.clear();
//     dataFlSpot4.add(const FlSpot(0, 0));
//     dataFlSpot5.clear();
//     dataFlSpot5.add(const FlSpot(0, 0));
//     dataFlSpot6.clear();
//     dataFlSpot6.add(const FlSpot(0, 0));
//     dataFlSpot7.clear();
//     dataFlSpot7.add(const FlSpot(0, 0));
//   }
//   Future<void> addDataPoint(RxList<FlSpot> dataFlSpot, double value) async {
//     double v = value;
//     if (v < minY) {
//       v = minY;
//     }
//     if (v > maxY) {
//       v = maxY;
//     }
//     if (dataFlSpot.isEmpty) {
//       dataFlSpot.add(const FlSpot(0, 0));
//     }
//     double x = dataFlSpot.length.toDouble();
//     dataFlSpot.add(FlSpot(x, v));
//     update();
//   }
// }

// class WavesController extends GetxController {
//   final RxDouble height = 480.0.obs;
//   final RxBool isFlay = false.obs;
//   final RxBool isCurved = false.obs;
//   final RxDouble minY = 0.0.obs;
//   final RxDouble maxY = 12.0.obs;
//   RxList<FlSpot> dataFlSpotBaseline = <FlSpot>[].obs;
//   RxList<FlSpot> dataFlSpot0 = <FlSpot>[].obs;
//   RxList<FlSpot> dataFlSpot1 = <FlSpot>[].obs;
//   RxList<FlSpot> dataFlSpot2 = <FlSpot>[].obs;
//   RxList<FlSpot> dataFlSpot3 = <FlSpot>[].obs;
//   RxList<FlSpot> dataFlSpot4 = <FlSpot>[].obs;
//   RxList<FlSpot> dataFlSpot5 = <FlSpot>[].obs;
//   RxList<FlSpot> dataFlSpot6 = <FlSpot>[].obs;
//   RxList<FlSpot> dataFlSpot7 = <FlSpot>[].obs;
//   final RxBool isShowLine0 = true.obs;
//   final RxBool isShowLine1 = true.obs;
//   final RxBool isShowLine2 = true.obs;
//   final RxBool isShowLine3 = true.obs;
//   final RxBool isShowLine4 = true.obs;
//   final RxBool isShowLine5 = true.obs;
//   final RxBool isShowLine6 = true.obs;
//   final RxBool isShowLine7 = true.obs;
//   final RxDouble barWidthLine0 = 1.0.obs;
//   final RxDouble barWidthLine1 = 1.0.obs;
//   final RxDouble barWidthLine2 = 1.0.obs;
//   final RxDouble barWidthLine3 = 1.0.obs;
//   final RxDouble barWidthLine4 = 1.0.obs;
//   final RxDouble barWidthLine5 = 1.0.obs;
//   final RxDouble barWidthLine6 = 1.0.obs;
//   final RxDouble barWidthLine7 = 1.0.obs;
//   double setHeight(double h) {
//     height.value = h;
//     return h;
//   }
//   bool setIsFlay(bool f) {
//     isFlay.value = f;
//     return f;
//   }
//   bool setIsCurved(bool c) {
//     isCurved.value = c;
//     return c;
//   }
//   bool changeIsFlay() {
//     isFlay.value = !isFlay.value;
//     return isFlay.value;
//   }
//   double setBarWidth(double w, {int i = -1}) {
//     if (i == 0) {
//       barWidthLine0.value = w;
//       return w;
//     }
//     if (i == 1) {
//       barWidthLine1.value = w;
//       return w;
//     }
//     if (i == 2) {
//       barWidthLine2.value = w;
//       return w;
//     }
//     if (i == 3) {
//       barWidthLine3.value = w;
//       return w;
//     }
//     if (i == 4) {
//       barWidthLine4.value = w;
//       return w;
//     }
//     if (i == 5) {
//       barWidthLine5.value = w;
//       return w;
//     }
//     if (i == 6) {
//       barWidthLine6.value = w;
//       return w;
//     }
//     if (i == 7) {
//       barWidthLine7.value = w;
//       return w;
//     }
//     barWidthLine0.value = w;
//     barWidthLine1.value = w;
//     barWidthLine2.value = w;
//     barWidthLine3.value = w;
//     barWidthLine4.value = w;
//     barWidthLine5.value = w;
//     barWidthLine6.value = w;
//     barWidthLine7.value = w;
//     return w;
//   }
//   double setMinY(double y) {
//     minY.value = y;
//     return y;
//   }
//   double setMaxY(double y) {
//     maxY.value = y;
//     return y;
//   }
//   bool addSpots(List<double> spots) {
//     if (spots.length != 8) {
//       return false;
//     }
//     double len = dataFlSpotBaseline.length.toDouble();
//     dataFlSpotBaseline.add(FlSpot(len, 0.0));
//     double s = 0.0;
//     s = spots[0] / 10000 + 1.0;
//     s = s > 11 ? 11 : s;
//     dataFlSpot0.add(FlSpot(len, s));
//     s = spots[1] / 10000 + 2.0;
//     s = s > 11 ? 11 : s;
//     dataFlSpot1.add(FlSpot(len, s));
//     s = spots[2] / 10000 + 3.0;
//     s = s > 11 ? 11 : s;
//     dataFlSpot2.add(FlSpot(len, s));
//     s = spots[3] / 10000 + 4.0;
//     s = s > 11 ? 11 : s;
//     dataFlSpot3.add(FlSpot(len, s));
//     s = spots[4] / 10000 + 5.0;
//     s = s > 11 ? 11 : s;
//     dataFlSpot4.add(FlSpot(len, s));
//     s = spots[5] / 10000 + 6.0;
//     s = s > 11 ? 11 : s;
//     dataFlSpot5.add(FlSpot(len, s));
//     s = spots[6] / 10000 + 7.0;
//     s = s > 11 ? 11 : s;
//     dataFlSpot6.add(FlSpot(len, s));
//     s = spots[7] / 10000 + 8.0;
//     s = s > 11 ? 11 : s;
//     dataFlSpot7.add(FlSpot(len, s));
//     return true;
//   }
//   bool addSpotsSign(List<double> spots) {
//     if (spots.length != 8) {
//       return false;
//     }
//     double len = dataFlSpotBaseline.length.toDouble();
//     dataFlSpotBaseline.add(FlSpot(len, 0.0));
//     double s = 0.0;
//     s = spots[0];
//     s = s > maxY.value ? maxY.value : s;
//     s = s < minY.value ? minY.value : s;
//     dataFlSpot0.add(FlSpot(len, s));
//     s = spots[1];
//     s = s > maxY.value ? maxY.value : s;
//     s = s < minY.value ? minY.value : s;
//     dataFlSpot1.add(FlSpot(len, s));
//     s = spots[2];
//     s = s > maxY.value ? maxY.value : s;
//     s = s < minY.value ? minY.value : s;
//     dataFlSpot2.add(FlSpot(len, s));
//     s = spots[3];
//     s = s > maxY.value ? maxY.value : s;
//     s = s < minY.value ? minY.value : s;
//     dataFlSpot3.add(FlSpot(len, s));
//     s = spots[4];
//     s = s > maxY.value ? maxY.value : s;
//     s = s < minY.value ? minY.value : s;
//     dataFlSpot4.add(FlSpot(len, s));
//     s = spots[5];
//     s = s > maxY.value ? maxY.value : s;
//     s = s < minY.value ? minY.value : s;
//     dataFlSpot5.add(FlSpot(len, s));
//     s = spots[6];
//     s = s > maxY.value ? maxY.value : s;
//     s = s < minY.value ? minY.value : s;
//     dataFlSpot6.add(FlSpot(len, s));
//     s = spots[7];
//     s = s > maxY.value ? maxY.value : s;
//     s = s < minY.value ? minY.value : s;
//     dataFlSpot7.add(FlSpot(len, s));
//     return true;
//   }
//   void clearSpots() {
//     dataFlSpotBaseline.clear();
//     dataFlSpot0.clear();
//     dataFlSpot1.clear();
//     dataFlSpot2.clear();
//     dataFlSpot3.clear();
//     dataFlSpot4.clear();
//     dataFlSpot5.clear();
//     dataFlSpot6.clear();
//     dataFlSpot7.clear();
//   }
// }

// class WavesTableController extends GetxController {
//   final RxList<String> title = <String>[].obs;
//   final RxList<String> delta = <String>[].obs;
//   final RxList<String> theta = <String>[].obs;
//   final RxList<String> lowAlpha = <String>[].obs;
//   final RxList<String> highAlpha = <String>[].obs;
//   final RxList<String> lowBeta = <String>[].obs;
//   final RxList<String> highBeta = <String>[].obs;
//   final RxList<String> lowGamma = <String>[].obs;
//   final RxList<String> middleGamma = <String>[].obs;
//   @override
//   void onInit() {
//     super.onInit();
//     initData();
//   }
//   @override
//   void onClose() {
//     super.onClose();
//     clearData();
//   }
//   void initData() {
//     if (title.isEmpty) {
//       title.add("脑波");
//       delta.add("delta");
//       theta.add("theta");
//       lowAlpha.add("lowAlpha");
//       highAlpha.add("highAlpha");
//       lowBeta.add("lowBeta");
//       highBeta.add("highBeta");
//       lowGamma.add("lowGamma");
//       middleGamma.add("middleGamma");
//     }
//   }
//   void resetData() {
//     if (title.length > 1) {
//       title.removeRange(1, title.length);
//       delta.removeRange(1, delta.length);
//       theta.removeRange(1, theta.length);
//       lowAlpha.removeRange(1, lowAlpha.length);
//       highAlpha.removeRange(1, highAlpha.length);
//       lowBeta.removeRange(1, lowBeta.length);
//       highBeta.removeRange(1, highBeta.length);
//       lowGamma.removeRange(1, lowGamma.length);
//       middleGamma.removeRange(1, middleGamma.length);
//     }
//   }
//   void clearData() {
//     title.clear();
//     delta.clear();
//     theta.clear();
//     lowAlpha.clear();
//     highAlpha.clear();
//     lowBeta.clear();
//     highBeta.clear();
//     lowGamma.clear();
//     middleGamma.clear();
//   }
//   void addCol(List<String> values) {
//     if (values.length != 9) {
//       return;
//     }
//     title.add(values[0]);
//     delta.add(values[1]);
//     theta.add(values[2]);
//     lowAlpha.add(values[3]);
//     highAlpha.add(values[4]);
//     lowBeta.add(values[5]);
//     highBeta.add(values[6]);
//     lowGamma.add(values[7]);
//     middleGamma.add(values[8]);
//   }
// }

// class BetaTableController extends GetxController {
//   final RxList<String> title = <String>[].obs;
//   final RxList<String> mv = <String>[].obs;
//   final RxList<String> trend = <String>[].obs;
//   final RxList<String> sign = <String>[].obs;
//   final RxList<String> activity = <String>[].obs;
//   @override
//   void onInit() {
//     super.onInit();
//     initData();
//   }
//   @override
//   void onClose() {
//     super.onClose();
//     clearData();
//   }
//   void initData() {
//     if (title.isEmpty) {
//       title.add("项目");
//       mv.add("能量均值");
//       trend.add("趋势");
//       sign.add("显著度");
//       activity.add("活跃度");
//     }
//   }
//   void resetData() {
//     if (title.length > 1) {
//       title.removeRange(1, title.length);
//       mv.removeRange(1, mv.length);
//       trend.removeRange(1, trend.length);
//       sign.removeRange(1, sign.length);
//       activity.removeRange(1, activity.length);
//     }
//   }
//   void clearData() {
//     title.clear();
//     mv.clear();
//     trend.clear();
//     sign.clear();
//     activity.clear();
//   }
//   void addCol(List<String> values) {
//     if (values.length != 5) {
//       return;
//     }
//     title.add(values[0]);
//     mv.add(values[1]);
//     trend.add(values[2]);
//     sign.add(values[3]);
//     activity.add(values[4]);
//   }
// }

// class EstrogenController extends GetxController {
//   final double minY;
//   final double maxY;
//   final RxList<FlSpot> dataFlSpot0 = <FlSpot>[].obs;
//   final RxList<FlSpot> dataFlSpot1 = <FlSpot>[].obs;
//   EstrogenController({
//     required this.minY,
//     required this.maxY,
//   });
//   @override
//   void onClose() {
//     super.onClose();
//     clearData();
//   }
//   Future<void> clearData() async {
//     dataFlSpot0.clear();
//     dataFlSpot1.clear();
//   }
//   Future<void> addDataPoint(RxList<FlSpot> dataFlSpot, double x, double y) async {
//     double v = y;
//     if (v < minY) {
//       v = minY;
//     }
//     if (v > maxY) {
//       v = maxY;
//     }
//     double k = x;
//     if (k < 0) {
//       k = 0;
//     }
//     if (k > 100) {
//       k = 100;
//     }
//     dataFlSpot.add(FlSpot(k, v));
//     update();
//   }
// }

// class StressController extends GetxController {
//   final double minY;
//   final double maxY;
//   final RxList<FlSpot> dataFlSpot = <FlSpot>[].obs;
//   StressController({
//     required this.minY,
//     required this.maxY,
//   });
//   @override
//   void onClose() {
//     super.onClose();
//     dataFlSpot.clear();
//   }
//   Future<void> clearData() async {
//     dataFlSpot.clear();
//   }
//   Future<void> addDataPoint(double value) async {
//     double v = value;
//     if (v < minY) {
//       v = minY;
//     }
//     if (v > maxY) {
//       v = maxY;
//     }
//     double x = dataFlSpot.length.toDouble();
//     dataFlSpot.add(FlSpot(x, v));
//     update();
//   }
// }

// class RotationController extends GetxController with GetSingleTickerProviderStateMixin {
//   late AnimationController _controller;
//   RxDouble rotationAngle = 0.0.obs;
//   @override
//   void onInit() {
//     _controller = AnimationController(
//       vsync: this,
//       duration: const Duration(seconds: 60),
//     )..repeat();
//     _controller.addListener(() {
//       rotationAngle.value = _controller.value * 2 * 3.14159;
//     });
//     super.onInit();
//   }
//   @override
//   void onClose() {
//     _controller.dispose();
//     super.onClose();
//   }
// }

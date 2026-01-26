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

  @override
  void onInit() {
    super.onInit();
    //侦听脑波数据
    _bciAndHrvBroadcastListener = eventChannel.receiveBroadcastStream().listen((data) async {
      List<String> temp = data.toString().split('_');
      if (temp.length == 2) {
        ///收集脑波数据
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

  @override
  void onClose() {
    _audioPlayer.dispose();
    _bciAndHrvBroadcastListener?.cancel();
    clearData();
    super.onClose();
  }
}

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:healing_junior/index.dart';
import 'package:http/http.dart' as http;
import 'package:healing_junior/view.dart';
import 'package:just_audio/just_audio.dart';

class QingZhiMUsicView extends GetView<QingZhiMusicCtrl> {
  QingZhiMUsicView({super.key});

  @override
  final controller = Get.put(QingZhiMusicCtrl());
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(10),
      child: Column(children: [
        MyTextP1(QingZhiMusicCtrl.title),
        const SizedBox(height: 20),
        Table(
            defaultVerticalAlignment: TableCellVerticalAlignment.middle,
            border: TableBorder.all(color: colorSecondary, width: 2, borderRadius: BorderRadius.circular(5)),
            columnWidths: {
              0: FixedColumnWidth(50),
              1: FixedColumnWidth(50),
              2: FixedColumnWidth(100),
              3: FixedColumnWidth(100),
              4: FixedColumnWidth(150),
              5: FixedColumnWidth(50),
            },
            children: [
              TableRow(children: [
                MyTextP1("  五脏"),
                MyTextP1("  五行"),
                MyTextP1("  五音-简谱"),
                MyTextP1("  对应情志"),
                MyTextP1("  核心作用"),
                MyTextP1("  播放"),
              ]),
              TableRow(children: [
                MyTextP2("  肝"),
                MyTextP2("  木"),
                MyTextP2("  角 (Mi)"),
                MyTextP2("  怒"),
                MyTextP2("  ${QingZhiMusicCtrl.valuePrompt[0]}"),
                Obx(() => controller.playingMusicIndex.value == 0 && controller.isPlaying.value
                    ? IconButton(icon: Icon(Icons.pause), onPressed: () => controller.stopMusic())
                    : IconButton(icon: Icon(Icons.play_arrow), onPressed: () => controller.playMusic(0))),
              ]),
              TableRow(children: [
                MyTextP2("  心"),
                MyTextP2("  火"),
                MyTextP2("  徵 (Sol)"),
                MyTextP2("  喜"),
                MyTextP2("  ${QingZhiMusicCtrl.valuePrompt[1]}"),
                Obx(() => controller.playingMusicIndex.value == 1 && controller.isPlaying.value
                    ? IconButton(icon: Icon(Icons.pause), onPressed: () => controller.stopMusic())
                    : IconButton(icon: Icon(Icons.play_arrow), onPressed: () => controller.playMusic(1))),
              ]),
              TableRow(children: [
                MyTextP2("  脾"),
                MyTextP2("  土"),
                MyTextP2("  宫 (Do)"),
                MyTextP2("  思"),
                MyTextP2("  ${QingZhiMusicCtrl.valuePrompt[2]}"),
                Obx(() => controller.playingMusicIndex.value == 2 && controller.isPlaying.value
                    ? IconButton(icon: Icon(Icons.pause), onPressed: () => controller.stopMusic())
                    : IconButton(icon: Icon(Icons.play_arrow), onPressed: () => controller.playMusic(2))),
              ]),
              TableRow(children: [
                MyTextP2("  肺"),
                MyTextP2("  金"),
                MyTextP2("  商 (Re)"),
                MyTextP2("  悲/忧"),
                MyTextP2("  ${QingZhiMusicCtrl.valuePrompt[3]}"),
                Obx(() => controller.playingMusicIndex.value == 3 && controller.isPlaying.value
                    ? IconButton(icon: Icon(Icons.pause), onPressed: () => controller.stopMusic())
                    : IconButton(icon: Icon(Icons.play_arrow), onPressed: () => controller.playMusic(3))),
              ]),
              TableRow(children: [
                MyTextP2("  肾"),
                MyTextP2("  水"),
                MyTextP2("  羽 (La)"),
                MyTextP2("  恐/惊"),
                MyTextP2("  ${QingZhiMusicCtrl.valuePrompt[4]}"),
                Obx(() => controller.playingMusicIndex.value == 4 && controller.isPlaying.value
                    ? IconButton(icon: Icon(Icons.pause), onPressed: () => controller.stopMusic())
                    : IconButton(icon: Icon(Icons.play_arrow), onPressed: () => controller.playMusic(4))),
              ]),
            ]),
        const SizedBox(height: 20),
        MyTextP2(QingZhiMusicCtrl.subTitle),
        Image.asset("assets/images/shanghai.png", width: 150),
        const SizedBox(height: 20),
      ]),
    );
  }
}

class QingZhiMusicCtrl extends GetxController {
  static const title = "中医情志 - 疗愈音乐";
  static const subTitle = "* 上海音乐学院“人工智能音乐疗愈重点实验室”联袂奉献 *";
  static const valuePrompt = ["疏肝理气、平息易怒", "养心安神、振奋心气", "健脾和胃、缓解焦虑", "清肃肺气、宣解悲忧", "滋水涵木、安神定志"];
  static const musicTypes = ["relax", "relax", "relax", "relax", "relax"];

  static const String _baseUrl = "https://emotion.bm.easyblend.cn/api/v1";
  static const String _clientId = "musicTest";
  static const String _clientSecret = "X3dsxs4rsfg";

  final Rx<String> accessToken = "".obs;
  final RxBool isLoading = false.obs;
  final RxMap<int, MusicInfo> musicCache = <int, MusicInfo>{}.obs;

  final AudioPlayer _audioPlayer = AudioPlayer();
  final isPlaying = false.obs;
  final playingMusicIndex = (-1).obs;
  
  final IndexCtrl indexCtrl = Get.put(IndexCtrl());

  /// 第三方登录获取token
  Future<bool> _fetchAccessToken() async {
    try {
      final uri = Uri.parse("$_baseUrl/auth/third/login").replace(
        queryParameters: {
          "clientId": _clientId,
          "clientSecret": _clientSecret,
        },
      );
      final response = await http.post(uri);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data["code"] == "00000" && data["data"] != null) {
          accessToken.value = data["data"]["accessToken"] ?? "";
          return accessToken.value.isNotEmpty;
        }
      }
      return false;
    } catch (e) {
      debugPrint("获取token失败: $e");
      return false;
    }
  }

  /// 获取音乐推荐链接
  Future<MusicInfo?> fetchMusic(int index) async {
    if (isLoading.value) return null;

    // 如果缓存中有且未过期，直接返回
    final cached = musicCache[index];
    if (cached != null && !cached.isExpired) {
      return cached;
    }

    isLoading.value = true;
    try {
      // 确保有有效的token
      if (accessToken.value.isEmpty) {
        final success = await _fetchAccessToken();
        if (!success) {
          _showError("获取授权失败");
          return null;
        }
      }

      final userProfile = valuePrompt[index];
      final musicType = musicTypes[index];

      final response = await http.post(
        Uri.parse("$_baseUrl/music/recommend"),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer ${accessToken.value}",
        },
        body: jsonEncode({
          "userProfile": userProfile,
          "musicType": musicType,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data["code"] == "00000" && data["data"] != null) {
          final musicInfo = MusicInfo.fromJson(data["data"]);
          musicCache[index] = musicInfo;
          return musicInfo;
        }
      } else if (response.statusCode == 401) {
        // token过期，重新获取
        accessToken.value = "";
        return await fetchMusic(index);
      }
      return null;
    } catch (e) {
      debugPrint("获取音乐失败: $e");
      return null;
    } finally {
      isLoading.value = false;
    }
  }

  /// 播放指定索引的音乐
  Future<void> playMusic(int index) async {
    if (playingMusicIndex.value == index && isPlaying.value) {
      await stopMusic();
      return;
    }
    final musicInfo = await fetchMusic(index);
    if (musicInfo != null) {
      indexCtrl.updateTalk("开始播放: ${musicInfo.musicName}");
      await _audioPlayer.setUrl(musicInfo.downloadUrl);
      await _audioPlayer.setLoopMode(LoopMode.one);
      _audioPlayer.play();
      isPlaying.value = true;
      playingMusicIndex.value = index;
    } else {
      _showError("获取音乐失败");
    }
  }

  Future<void> stopMusic() async {
    await _audioPlayer.stop();
    isPlaying.value = false;
  }

  void _showError(String msg) {
    if (Get.isSnackbarOpen) Get.closeCurrentSnackbar();
    Get.snackbar("错误", msg, snackPosition: SnackPosition.BOTTOM);
  }

  // void _showSuccess(String msg) {
  //   if (Get.isSnackbarOpen) Get.closeCurrentSnackbar();
  //   Get.snackbar("提示", msg, snackPosition: SnackPosition.BOTTOM, duration: const Duration(seconds: 5));
  // }
}

/// 音乐信息模型
class MusicInfo {
  final String musicId;
  final String musicName;
  final String musicType;
  final String reason;
  final String downloadUrl;
  final DateTime? expiresTime;

  MusicInfo({
    required this.musicId,
    required this.musicName,
    required this.musicType,
    required this.reason,
    required this.downloadUrl,
    int? expiresIn,
  }) : expiresTime = expiresIn != null ? DateTime.now().add(Duration(seconds: expiresIn)) : null;

  factory MusicInfo.fromJson(Map<String, dynamic> json) {
    return MusicInfo(
      musicId: json["music_id"] ?? "",
      musicName: json["music_name"] ?? "",
      musicType: json["music_type"] ?? "",
      reason: json["reason"] ?? "",
      downloadUrl: json["download_url"] ?? "",
      expiresIn: json["download_expires_in"],
    );
  }

  bool get isExpired {
    if (expiresTime == null) return false;
    return DateTime.now().isAfter(expiresTime!);
  }
}

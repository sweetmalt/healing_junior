import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:healing_junior/view.dart';
import 'package:just_audio/just_audio.dart';

class StaffView extends GetView<StaffCtrl> {
  StaffView({super.key});
  @override
  final StaffCtrl controller = Get.put(StaffCtrl());
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(10),
      padding: EdgeInsets.only(top: 30, bottom: 10, left: 10, right: 10),
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
      child: Obx(() => Column(
            children: [
              MyTextP2("情绪八音盒"),
              Table(
                defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                children: [
                  for (int i = 0; i < 12; i++)
                    TableRow(
                      children: [
                        Icon(
                          Icons.music_note,
                          size: 24,
                          color: Colors.grey,
                        ),
                        for (int j = 0; j < controller.notes.length; j++)
                          Stack(
                            alignment: Alignment.center,
                            children: [
                              i % 2 == 0 && i != 10 ? Divider(thickness: 1) : Container(),
                              Icon(
                                i != 10 ? Icons.radio_button_unchecked_rounded : Icons.strikethrough_s_rounded,
                                size: 24,
                                color: i == controller.notes[j] ? Colors.green : Colors.white,
                              )
                            ],
                          ),
                      ],
                    ),
                ],
              ),
              IconButton.filled(
                onPressed: () async {
                  if (controller.isPlaying.value) {
                    await controller.stopAudioList();
                  } else {
                    await controller.playAudioList();
                  }
                },
                icon: Icon(controller.isPlaying.value ? Icons.stop_rounded : Icons.play_arrow_rounded),
              ),
            ],
          )),
    );
  }
}

class StaffCtrl extends GetxController {
  final RxBool isPlaying = false.obs;
  final RxList<int> notes = <int>[10, 9, 8, 7, 6, 5, 4, 3].obs;
  static const Map<int, String> noteMap = {
    10: "1",
    9: "2",
    8: "3",
    7: "4",
    6: "5",
    5: "6",
    4: "7",
    3: "8",
  };

  void refreshNotes() {
    notes.value = [];
    for (int i = 0; i < 8; i++) {
      notes.add(noteMap.keys.elementAt(Random().nextInt(noteMap.keys.length)));
    }
  }

  final AudioPlayer _audioPlayer = AudioPlayer();
  Future<void> playAudioList() async {
    try {
      isPlaying.value = true;
      await _audioPlayer.setAudioSources(notes.map((e) => AudioSource.asset('assets/audios/${noteMap[e]}.MP3')).toList());
      await _audioPlayer.setSpeed(2);
      await _audioPlayer.setVolume(1);
      await _audioPlayer.setLoopMode(LoopMode.all);
      _audioPlayer.play();
    } on PlatformException catch (e) {
      debugPrint('播放错误: ${e.message}');
    }
  }

  Future<void> stopAudioList() async {
    try {
      isPlaying.value = false;
      await _audioPlayer.stop();
    } on PlatformException catch (e) {
      debugPrint('停止错误: ${e.message}');
    }
  }
}

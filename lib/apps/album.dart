import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';
import 'package:get/get.dart';
import 'package:healing_junior/data.dart';
import 'package:healing_junior/view.dart';

class AlbumView extends GetView<AlbumController> {
  AlbumView({super.key});
  final selectedCtrl = Get.put(SelectedImageController());
  @override
  final AlbumController controller = Get.put(AlbumController());

  @override
  Widget build(BuildContext context) {
    controller.loadAlbums();
    return Scaffold(
      appBar: AppBar(
        title: Text('相册'),
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
        height: 100,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: controller.albums.length,
          itemBuilder: (ctx, index) => GestureDetector(
            onTap: () => selectedCtrl.selectImage(controller.albums[index]),
            child: Image.file(File(controller.albums[index].imagePath), width: 100, fit: BoxFit.cover),
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
              Image.file(File(selectedCtrl.selected.value!.imagePath)),
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

class AlbumController extends GetxController {
  final RxList<DrawData> albums = <DrawData>[].obs;

  Future<void> loadAlbums() async {
    final data = await Data.read("draw.json");
    albums.clear();
    albums.addAll(data.values.map((e) => DrawData.fromJson(e)).toList());
  }

  @override
  void onInit() {
    super.onInit();
    loadAlbums();
  }
}

class SelectedImageController extends GetxController {
  final Rx<DrawData?> selected = Rx<DrawData?>(null);

  void selectImage(DrawData data) => selected.value = data;
}

class DrawData {
  final String nickname;
  final int timestamp;
  final String imagePath;
  final String analysisText;

  DrawData.fromJson(Map<String, dynamic> json)
      : nickname = json['nickname'],
        timestamp = json['timestamp'],
        imagePath = json['imagePath'],
        analysisText = json['analysisText'];
}

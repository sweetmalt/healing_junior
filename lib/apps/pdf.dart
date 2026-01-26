import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:healing_junior/data.dart';
import 'package:healing_junior/view.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

class PdfView extends GetView<PdfController> {
  PdfView({super.key});
  @override
  final controller = Get.put(PdfController());
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          controller.selectedFIleTitle.value,
          style: TextStyle(
            fontSize: 20,
            color: ThemeData().colorScheme.primary,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(
              Icons.arrow_back_ios_rounded,
              size: 30,
            ),
            onPressed: () {
              Get.back();
            },
          ),
        ],
      ),
      body: SfPdfViewer.file(File(
        controller.selectedFIlePath.value,
      )),
    );
  }
}

class PdfListView extends GetView<PdfController> {
  PdfListView({super.key});
  @override
  final controller = Get.put(PdfController());
  final start = 'pdf_'.obs;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(controller.title),
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
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ListTile(
                title: InputDecorator(
                  decoration: InputDecoration(
                    enabledBorder: InputBorder.none,
                    labelText: '搜索（请输入用户昵称）',
                  ),
                  child: TextField(
                    onChanged: (value) {
                      start.value = 'pdf_$value';
                    },
                  ),
                ),
                trailing: ElevatedButton(
                  child: Icon(Icons.search_rounded),
                  onPressed: () {
                    controller.getFileList(start.value);
                  },
                ),
              ),
              SingleChildScrollView(
                  child: Obx(() => Column(
                        children: [
                          for (int i = 0; i < controller.fileList.length; i++)
                            ListTile(
                              title: Text(
                                controller.fileList[i].split('_')[1],
                                style: TextStyle(
                                  fontSize: 20,
                                  color: ThemeData().colorScheme.primary,
                                ),
                              ),
                              subtitle: Text(controller.fileList[i].split('_')[2].split('.')[0]),
                              leading: CircularIconButton(
                                icon: Icons.share_rounded,
                                onPressed: () async {
                                  final directory = await getApplicationDocumentsDirectory();
                                  final fileName = '${directory.path}/${controller.fileList[i]}';
                                  SharePlus.instance.share(ShareParams(
                                    files: [XFile(fileName)],
                                    text: '分享给好友',
                                  ));
                                },
                              ),
                              trailing: ElevatedButton(
                                child: Text("删除"),
                                onPressed: () {
                                  _showDeleteDialog(context, i);
                                },
                              ),
                              onTap: () async {
                                //打开显示pdf文档
                                controller.selectedFIleTitle.value = controller.fileList[i].split('_')[1];
                                final directory = await getApplicationDocumentsDirectory();
                                controller.selectedFIlePath.value = '${directory.path}/${controller.fileList[i]}';
                                Get.to(() => PdfView());
                              },
                            ),
                        ],
                      )))
            ],
          ),
        ));
  }

  Future<void> _showDeleteDialog(BuildContext context, int index) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // 用户必须点击按钮才能关闭对话框
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('删除报告'),
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
                // 执行删除操作
                delete(index, start.value);
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void delete(int index, String start) async {
    if (await Data.delete('${controller.fileList[index]}')) {
      await controller.getFileList(start);
    }
  }
}

class PdfController extends GetxController {
  final title = 'PDF 文件夹';
  final fileList = [].obs;
  final selectedFIleTitle = ''.obs;
  final selectedFIlePath = ''.obs;
  @override
  void onInit() async {
    super.onInit();
    await getFileList('pdf_');
  }

  Future<void> getFileList(String start) async {
    fileList.clear();
    fileList.value = await Data.readFileList(start);
  }
}

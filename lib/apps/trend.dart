import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:healing_junior/view.dart';

List<String> emoLabels = ["恐惧-", "紧绷-", "警觉+", "欢喜+", "焦虑-", "紧张-", "兴奋+", "快乐+", "厌恶-", "烦恼-", "镇定+", "放松+", "抑郁-", "悲伤-", "平静+", "满足+"];

class TrendView extends GetView<TrendCtrl> {
  TrendView({super.key});
  @override
  final TrendCtrl controller = Get.put(TrendCtrl());

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 10),
      child: Obx(() => EmoValue(data: controller.emoValues.toList())),
    );
  }
}

class TrendCtrl extends GetxController {
  final RxList<int> emoValues = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0].obs;
  final beEmo="".obs;
  // final RxInt emoV1 = 0.obs; //恐惧-
  // final RxInt emoV2 = 0.obs; //紧绷-
  // final RxInt emoV3 = 0.obs; //警觉+
  // final RxInt emoV4 = 0.obs; //欢喜+
  // final RxInt emoV5 = 0.obs; //焦虑-
  // final RxInt emoV6 = 0.obs; //紧张-
  // final RxInt emoV7 = 0.obs; //兴奋+
  // final RxInt emoV8 = 0.obs; //快乐+
  // final RxInt emoV9 = 0.obs; //厌恶-
  // final RxInt emoV10 = 0.obs; //烦恼-
  // final RxInt emoV11 = 0.obs; //镇定+
  // final RxInt emoV12 = 0.obs; //放松+
  // final RxInt emoV13 = 0.obs; //抑郁-
  // final RxInt emoV14 = 0.obs; //悲伤-
  // final RxInt emoV15 = 0.obs; //平静+
  // final RxInt emoV16 = 0.obs; //满足+
  List<String> trend(double deltaTrendSign, double thetaTrendSign, double alphaTrendSign, double betaTrendSign, double gammaTrendSign) {
    List<String> trendEmos = [];
    if (betaTrendSign < 0) {
      //正向情绪
      if (alphaTrendSign > 0) {
        //上层正向情绪
        if (gammaTrendSign > 0) {
          //上层左侧正向情绪
          if (thetaTrendSign < 0) {
            //上层左侧外向正向情绪
            //emoV3.value++;
            emoValues[2]++;
            trendEmos.add("${emoLabels[2]}1");
          } else {
            //上层左侧内向正向情绪
            //emoV7.value++;
            emoValues[6]++;
            trendEmos.add("${emoLabels[6]}1");
          }
        } else {
          //上层右侧正向情绪
          if (thetaTrendSign < 0) {
            //上层右侧外向正向情绪
            //emoV4.value++;
            emoValues[3]++;
            trendEmos.add("${emoLabels[3]}1");
          } else {
            //上层右侧内向正向情绪
            //emoV8.value++;
            emoValues[7]++;
            trendEmos.add("${emoLabels[7]}1");
          }
        }
      } else {
        //下层正向情绪
        if (gammaTrendSign > 0) {
          //下层左侧正向情绪
          if (thetaTrendSign < 0) {
            //下层左侧外向正向情绪
            //emoV11.value++;
            emoValues[10]++;
            trendEmos.add("${emoLabels[10]}1");
          } else {
            //下层左侧内向正向情绪
            //emoV15.value++;
            emoValues[14]++;
            trendEmos.add("${emoLabels[14]}1");
          }
        } else {
          //下层右侧正向情绪
          if (thetaTrendSign < 0) {
            //下层右侧外向正向情绪
            //emoV12.value++;
            emoValues[11]++;
            trendEmos.add("${emoLabels[11]}1");
          } else {
            //下层右侧内向正向情绪
            //emoV16.value++;
            emoValues[15]++;
            trendEmos.add("${emoLabels[15]}1");
          }
        }
      }
    } else {
      //负向情绪
      if (alphaTrendSign > 0) {
        //上层负向情绪
        if (gammaTrendSign > 0) {
          //上层左侧负向情绪
          if (thetaTrendSign < 0) {
            //上层左侧外向负向情绪
            //emoV1.value++;
            emoValues[0]++;
            trendEmos.add("${emoLabels[0]}1");
          } else {
            //上层左侧内向负向情绪
            //emoV5.value++;
            emoValues[4]++;
            trendEmos.add("${emoLabels[4]}1");
          }
        } else {
          //上层右侧负向情绪
          if (thetaTrendSign < 0) {
            //上层右侧外向负向情绪
            //emoV2.value++;
            emoValues[1]++;
            trendEmos.add("${emoLabels[1]}1");
          } else {
            //上层右侧内向负向情绪
            //emoV6.value++;
            emoValues[5]++;
            trendEmos.add("${emoLabels[5]}1");
          }
        }
      } else {
        //下层负向情绪
        if (gammaTrendSign > 0) {
          //下层左侧负向情绪
          if (thetaTrendSign < 0) {
            //下层左侧外向负向情绪
            //emoV9.value++;
            emoValues[8]++;
            trendEmos.add("${emoLabels[8]}1");
          } else {
            //下层左侧内向负向情绪
            //emoV13.value++;
            emoValues[12]++;
            trendEmos.add("${emoLabels[12]}1");
          }
        } else {
          //下层右侧负向情绪
          if (thetaTrendSign < 0) {
            //下层右侧外向负向情绪
            //emoV10.value++;
            emoValues[9]++;
            trendEmos.add("${emoLabels[9]}1");
          } else {
            //下层右侧内向负向情绪
            //emoV14.value++;
            emoValues[13]++;
            trendEmos.add("${emoLabels[13]}1");
          }
        }
      }
    }
    beEmo.value=trendEmos.join(",");
    return trendEmos;
  }

  void init() {
    for (int i = 0; i < emoValues.length; i++) {
      emoValues[i] = 0;
    }
    // emoV1.value = 0;
    // emoV2.value = 0;
    // emoV3.value = 0;
    // emoV4.value = 0;
    // emoV5.value = 0;
    // emoV6.value = 0;
    // emoV7.value = 0;
    // emoV8.value = 0;
    // emoV9.value = 0;
    // emoV10.value = 0;
    // emoV11.value = 0;
    // emoV12.value = 0;
    // emoV13.value = 0;
    // emoV14.value = 0;
    // emoV15.value = 0;
    // emoV16.value = 0;
  }
}

class EmoValue extends StatelessWidget {
  final List<int> data;
  const EmoValue({super.key, required this.data});
  @override
  Widget build(BuildContext context) {
    const indexs = [2, 3, 6, 7, 10, 11, 14, 15];
    List<int> dataTemp = [];
    for (int i = 0; i < data.length; i++) {
      if (indexs.contains(i)) {
        dataTemp.add(data[i]);
      }
    }
    final total = data.reduce((prev, cur) => prev + cur);
    final totalBirds = dataTemp.reduce((prev, cur) => prev + cur);
    final totalCribs = total - totalBirds;
    return Container(
      margin: EdgeInsets.all(10),
      padding: EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: colorSecondary,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [BoxShadow(color: Colors.grey, spreadRadius: 1, blurRadius: 1, offset: Offset(0, 1))],
      ),
      child: Column(
        children: [
          MyTextP2("情绪效价与激活度"),
          const SizedBox(height: 80),
          Stack(
            alignment: Alignment.center,
            children: [
              CustomPaint(size: Size(400, 200), painter: _EllipsePainter()),
              CustomPaint(size: Size(420, 220), painter: _CoordinateSystemPainter()),
              Table(
                defaultColumnWidth: FixedColumnWidth(40),
                children: [
                  for (int i = 0; i < 4; i++)
                    TableRow(children: [
                      for (int j = 0; j < 4; j++)
                        Container(
                          alignment: Alignment.center,
                          child: MyTextP3(emoLabels[i * 4 + j], colorPrimaryContainer),
                        ),
                    ])
                ],
              ),
            ],
          ),
          const SizedBox(height: 40),
          const Divider(height: 20, thickness: 5, radius: BorderRadius.all(Radius.circular(5))),
          MyTextP2("（疗愈收益）"),
          const Divider(height: 20),
          Table(
            columnWidths: {
              0: FlexColumnWidth(60),
              1: FlexColumnWidth(context.width),
              2: FlexColumnWidth(60),
            },
            defaultVerticalAlignment: TableCellVerticalAlignment.middle,
            children: [
              for (int i = 0; i < emoLabels.length; i++)
                TableRow(children: [
                  MyTextP2(emoLabels[i]),
                  Row(
                    children: [
                      for (int j = 0; j < (data[i] > 16 ? 16 : data[i]); j++)
                        Container(
                          margin: EdgeInsets.only(right: 1),
                          width: 30,
                          height: 30,
                          child: indexs.contains(i) ? Image.asset('assets/images/Bird.png') : Icon(Icons.crib_rounded),
                        ),
                      Container(margin: EdgeInsets.only(right: 1), width: 30, height: 30, child: Icon(Icons.keyboard_control_rounded))
                    ],
                  ),
                  Container(
                    alignment: Alignment.centerRight,
                    child: MyTextP2("${data[i] > 0 ? "+" : ""} ${data[i].toString()}"),
                  )
                ])
            ],
          ),
          const Divider(height: 20),
          MyTextP2("Total Birds $totalBirds + Total Cribs $totalCribs"),
          MyTextP2("收获的正向情绪 & 被克制的负向情绪"),
        ],
      ),
    );
  }
}

class _CoordinateSystemPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = colorSurface
      ..strokeWidth = 1;
    // 绘制坐标轴
    canvas.drawLine(Offset(0, size.height / 2), Offset(size.width, size.height / 2), paint);
    canvas.drawLine(Offset(size.width / 2, 0), Offset(size.width / 2, size.height), paint);
    // 添加坐标轴标签
    final textPainter = TextPainter(
      text: TextSpan(text: ' >效价', style: TextStyle(color: colorPrimaryContainer, fontSize: 14)),
      textDirection: TextDirection.ltr,
    );
    // 横轴标签（效价）
    textPainter.layout();
    textPainter.paint(canvas, Offset(size.width, size.height / 2 - 11));
    // 纵轴标签（激活度）
    final verticalText = TextPainter(
      text: TextSpan(text: ' >激活度', style: TextStyle(color: colorPrimaryContainer, fontSize: 14)),
      textDirection: TextDirection.ltr,
    );
    verticalText.layout();
    canvas.save();
    canvas.translate(size.width / 2 - 11, 0);
    canvas.rotate(-90 * 3.1415927 / 180);
    verticalText.paint(canvas, Offset.zero);
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _EllipsePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = colorPrimary;
    // 以坐标原点为中心绘制椭圆
    canvas.drawOval(Rect.fromCenter(center: Offset(size.width / 2, size.height / 2), width: size.width, height: size.height), paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

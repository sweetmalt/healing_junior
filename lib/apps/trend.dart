import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:healing_junior/view.dart';

class TrendView extends GetView<TrendCtrl> {
  TrendView({super.key});
  @override
  final TrendCtrl controller = Get.put(TrendCtrl());

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 10),
      child: Obx(() => EmoValue(data: [
            controller.emoV1.value,
            controller.emoV2.value,
            controller.emoV3.value,
            controller.emoV4.value,
            controller.emoV5.value,
            controller.emoV6.value,
            controller.emoV7.value,
            controller.emoV8.value,
            controller.emoV9.value,
            controller.emoV10.value,
            controller.emoV11.value,
            controller.emoV12.value,
            controller.emoV13.value,
            controller.emoV14.value,
            controller.emoV15.value,
            controller.emoV16.value
          ])),
    );
  }
}

class TrendCtrl extends GetxController {
  final RxInt emoV1 = 0.obs; //恐惧-
  final RxInt emoV2 = 0.obs; //紧绷-
  final RxInt emoV3 = 0.obs; //警觉+
  final RxInt emoV4 = 0.obs; //欢喜+
  final RxInt emoV5 = 0.obs; //焦虑-
  final RxInt emoV6 = 0.obs; //紧张-
  final RxInt emoV7 = 0.obs; //兴奋+
  final RxInt emoV8 = 0.obs; //快乐+
  final RxInt emoV9 = 0.obs; //厌恶-
  final RxInt emoV10 = 0.obs; //烦恼-
  final RxInt emoV11 = 0.obs; //镇定+
  final RxInt emoV12 = 0.obs; //放松+
  final RxInt emoV13 = 0.obs; //抑郁-
  final RxInt emoV14 = 0.obs; //悲伤-
  final RxInt emoV15 = 0.obs; //平静+
  final RxInt emoV16 = 0.obs; //满足+
  void trend(double deltaTrendSign, double thetaTrendSign, double alphaTrendSign, double betaTrendSign, double gammaTrendSign) {
    if (betaTrendSign < 0) {
      //正向情绪
      if (alphaTrendSign > 0) {
        //上层正向情绪
        if (gammaTrendSign > 0) {
          //上层左侧正向情绪
          if (thetaTrendSign < 0) {
            //上层左侧外向正向情绪
            emoV3.value++;
          } else {
            //上层左侧内向正向情绪
            emoV7.value++;
          }
        } else {
          //上层右侧正向情绪
          if (thetaTrendSign < 0) {
            //上层右侧外向正向情绪
            emoV4.value++;
          } else {
            //上层右侧内向正向情绪
            emoV8.value++;
          }
        }
      } else {
        //下层正向情绪
        if (gammaTrendSign > 0) {
          //下层左侧正向情绪
          if (thetaTrendSign < 0) {
            //下层左侧外向正向情绪
            emoV11.value++;
          } else {
            //下层左侧内向正向情绪
            emoV15.value++;
          }
        } else {
          //下层右侧正向情绪
          if (thetaTrendSign < 0) {
            //下层右侧外向正向情绪
            emoV12.value++;
          } else {
            //下层右侧内向正向情绪
            emoV16.value++;
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
            emoV1.value++;
          } else {
            //上层左侧内向负向情绪
            emoV5.value++;
          }
        } else {
          //上层右侧负向情绪
          if (thetaTrendSign < 0) {
            //上层右侧外向负向情绪
            emoV2.value++;
          } else {
            //上层右侧内向负向情绪
            emoV6.value++;
          }
        }
      } else {
        //下层负向情绪
        if (gammaTrendSign > 0) {
          //下层左侧负向情绪
          if (thetaTrendSign < 0) {
            //下层左侧外向负向情绪
            emoV9.value++;
          } else {
            //下层左侧内向负向情绪
            emoV13.value++;
          }
        } else {
          //下层右侧负向情绪
          if (thetaTrendSign < 0) {
            //下层右侧外向负向情绪
            emoV10.value++;
          } else {
            //下层右侧内向负向情绪
            emoV14.value++;
          }
        }
      }
    }
  }

  void init() {
    emoV1.value = 0;
    emoV2.value = 0;
    emoV3.value = 0;
    emoV4.value = 0;
    emoV5.value = 0;
    emoV6.value = 0;
    emoV7.value = 0;
    emoV8.value = 0;
    emoV9.value = 0;
    emoV10.value = 0;
    emoV11.value = 0;
    emoV12.value = 0;
    emoV13.value = 0;
    emoV14.value = 0;
    emoV15.value = 0;
    emoV16.value = 0;
  }
}

class EmoValue extends StatelessWidget {
  final List<int> data;
  const EmoValue({super.key, required this.data});
  @override
  Widget build(BuildContext context) {
    const labels = ["恐惧-", "紧绷-", "警觉+", "欢喜+", "焦虑-", "紧张-", "兴奋+", "快乐+", "厌恶-", "烦恼-", "镇定+", "放松+", "抑郁-", "悲伤-", "平静+", "满足+"];
    const indexs = [2, 3, 6, 7, 10, 11, 14, 15];
    List<int> dataTemp = [];
    for (int i = 0; i < data.length; i++) {
      if (indexs.contains(i)) {
        dataTemp.add(data[i]);
      }
    }
    final total = dataTemp.reduce((prev, cur) => prev + cur);
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
                          child: MyTextP3(labels[i * 4 + j], colorPrimaryContainer),
                        ),
                    ])
                ],
              ),
              // Image.asset(
              //   width: 40 + (total < 160 ? total : 160).toDouble(),
              //   height: 40 + (total < 160 ? total : 160).toDouble(),
              //   'assets/images/Bird.png',
              // ),
            ],
          ),
          const SizedBox(height: 40),
          const Divider(height: 20, thickness: 5, radius: BorderRadius.all(Radius.circular(5))),
          MyTextP2("正向情绪的动态捕获"),
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
              for (int i = 0; i < labels.length; i++)
                TableRow(children: [
                  MyTextP2(labels[i]),
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
          MyTextP2("Total Birds $total"),
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

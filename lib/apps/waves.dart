import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:healing_junior/view.dart';

class WavesButtons extends GetView<WavesCtrl> {
  @override
  final controller = Get.put(WavesCtrl());
  WavesButtons({
    super.key,
  });
  @override
  Widget build(BuildContext context) {
    // === 视觉优化(2026-06-28)===
    // 5 个按钮对应 5 条脑波线(isShowLine0..4)。
    // 显示时:彩色实心 + 圆角 + 白色文字
    // 隐藏时:同色 30% 不透明 + 灰色描边 + 灰色文字
    // 这样颜色始终与上方曲线呼应,一眼看出"哪个波被隐藏"
    final labels = const ['Delta', 'Theta', 'Alpha', 'Beta', 'Gamma'];
    return Container(
      alignment: Alignment.center,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(5, (i) {
          return Obx(() {
            final bool show = _isShow(i);
            final Color color = colors5[i];
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: TextButton(
                onPressed: () => _toggle(i),
                style: TextButton.styleFrom(
                  backgroundColor: show ? color : color.withValues(alpha: 0.3),
                  side: show
                      ? BorderSide.none
                      : BorderSide(color: Colors.grey.shade400, width: 1.5),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                ),
                child: Text(
                  labels[i],
                  style: TextStyle(
                    color: show ? colorSecondary : Colors.grey.shade400,
                    fontWeight: show ? FontWeight.w600 : FontWeight.w400,
                  ),
                ),
              ),
            );
          });
        }),
      ),
    );
  }

  /// 工具方法:按索引读取 5 个 isShowLineX
  bool _isShow(int i) {
    switch (i) {
      case 0: return controller.isShowLine0.value;
      case 1: return controller.isShowLine1.value;
      case 2: return controller.isShowLine2.value;
      case 3: return controller.isShowLine3.value;
      case 4: return controller.isShowLine4.value;
      default: return true;
    }
  }

  /// 工具方法:按索引翻转 5 个 isShowLineX
  void _toggle(int i) {
    switch (i) {
      case 0: controller.isShowLine0.value = !controller.isShowLine0.value; break;
      case 1: controller.isShowLine1.value = !controller.isShowLine1.value; break;
      case 2: controller.isShowLine2.value = !controller.isShowLine2.value; break;
      case 3: controller.isShowLine3.value = !controller.isShowLine3.value; break;
      case 4: controller.isShowLine4.value = !controller.isShowLine4.value; break;
    }
  }
}

class WavesView extends GetView<WavesCtrl> {
  @override
  final controller = Get.put(WavesCtrl());
  WavesView({
    super.key,
  });
  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    return Container(
      height: 320,
      alignment: Alignment.bottomRight,
      margin: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.grey,
            spreadRadius: 1,
            blurRadius: 3,
            offset: const Offset(0, 3),
          ),
        ],
        color: colorSecondaryContainer,
      ),
      clipBehavior: Clip.hardEdge,
      // === 流畅度优化(2026-06-27)===
      // 取消 SingleChildScrollView + reverse:true,改为由 fl_chart 的 minX/maxX 锁定滑动窗口。
      // 这样:
      // 1) 图占满屏幕宽度,不再"靠右四分之一有内容"
      // 2) 新数据从右滑入,老数据从左滑出,整体平滑平移
      // 3) duration: 150ms 隐式动画实现"流动"效果(不再靠"加新点"制造动画)
      child: SizedBox(
        width: screenWidth,
        height: controller.height.value,
        child: Obx(() {
          // ⚠️ 兜底防御 (2026-07-03 老张揪出 LateInitializationError)：
          // 读 .length 强制 Obx 追踪 dataFlSpot0 列表变化（addSpots/clearSpots 时重建）。
          // 检查任意 spot 有效才渲染 LineChart，避免 paint 时 mostLeftSpot 未初始化。
          final hasData = controller.dataFlSpot0.isNotEmpty &&
              controller.dataFlSpot0.any((s) => !s.isNull());
          if (!hasData) {
            return const SizedBox.shrink();
          }
          return LineChart(
            duration: const Duration(milliseconds: 950),
            LineChartData(
              minX: controller.minX.value,
              maxX: controller.maxX.value,
              gridData: const FlGridData(show: false, drawHorizontalLine: false, drawVerticalLine: false),
              titlesData: FlTitlesData(
                topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                show: true,
              ),
              borderData: FlBorderData(show: false),
              minY: controller.minY.value,
              maxY: controller.maxY.value,
              backgroundColor: Colors.black,
              // === 视觉优化(2026-06-28) ===
              // 取消默认触摸 tooltip(数值堆叠难看),保留滚动缩放等基础交互
              lineTouchData: const LineTouchData(enabled: false),
              // P5:基线改为 extraLinesData 水平虚线,删除原来的伪"点线"
              extraLinesData: ExtraLinesData(
                horizontalLines: [
                  HorizontalLine(
                    y: 0,
                    color: Colors.white24,
                    dashArray: [4, 4],
                  ),
                ],
              ),
              lineBarsData: [
                // 原"基线 LineChartBarData"已删除,基线改由上面的 extraLinesData 绘制
                LineChartBarData(
                  barWidth: controller.barWidthLine0.value,
                  spots: controller.dataFlSpot0,
                  show: controller.isShowLine0.value,
                  color: colors5[0],
                  isCurved: controller.isCurved.value,
                  isStrokeCapRound: true,                            // P3 圆头
                  preventCurveOverShooting: true,                    // P4 防过冲
                  dotData: const FlDotData(show: false),
                  // P1 渐变填充:线下 0.4 不透明 → 上方 0.0 不透明
                  belowBarData: BarAreaData(
                    show: true,
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        colors5[0].withValues(alpha: 0.4),
                        colors5[0].withValues(alpha: 0.0),
                      ],
                    ),
                  ),
                ),
                LineChartBarData(
                  barWidth: controller.barWidthLine1.value,
                  spots: controller.dataFlSpot1,
                  show: controller.isShowLine1.value,
                  color: colors5[1],
                  isCurved: controller.isCurved.value,
                  isStrokeCapRound: true,
                  preventCurveOverShooting: true,
                  dotData: const FlDotData(show: false),
                  belowBarData: BarAreaData(
                    show: true,
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        colors5[1].withValues(alpha: 0.4),
                        colors5[1].withValues(alpha: 0.0),
                      ],
                    ),
                  ),
                ),
                LineChartBarData(
                  barWidth: controller.barWidthLine2.value,
                  spots: controller.dataFlSpot2,
                  show: controller.isShowLine2.value,
                  color: colors5[2],
                  isCurved: controller.isCurved.value,
                  isStrokeCapRound: true,
                  preventCurveOverShooting: true,
                  dotData: const FlDotData(show: false),
                  belowBarData: BarAreaData(
                    show: true,
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        colors5[2].withValues(alpha: 0.4),
                        colors5[2].withValues(alpha: 0.0),
                      ],
                    ),
                  ),
                ),
                LineChartBarData(
                  barWidth: controller.barWidthLine3.value,
                  spots: controller.dataFlSpot3,
                  show: controller.isShowLine3.value,
                  color: colors5[3],
                  isCurved: controller.isCurved.value,
                  isStrokeCapRound: true,
                  preventCurveOverShooting: true,
                  dotData: const FlDotData(show: false),
                  belowBarData: BarAreaData(
                    show: true,
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        colors5[3].withValues(alpha: 0.4),
                        colors5[3].withValues(alpha: 0.0),
                      ],
                    ),
                  ),
                ),
                LineChartBarData(
                  barWidth: controller.barWidthLine4.value,
                  spots: controller.dataFlSpot4,
                  show: controller.isShowLine4.value,
                  color: colors5[4],
                  isCurved: controller.isCurved.value,
                  isStrokeCapRound: true,
                  preventCurveOverShooting: true,
                  dotData: const FlDotData(show: false),
                  belowBarData: BarAreaData(
                    show: true,
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        colors5[4].withValues(alpha: 0.4),
                        colors5[4].withValues(alpha: 0.0),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        }),
      ),
    );
  }
}

class WavesCtrl extends GetxController {
  final RxDouble height = 300.0.obs;
  // [兼容字段] 旧版 width 由 addSpots 持续累加(len*20);
  // 新版改用 minX/maxX 锁定滑动窗口,width 不再需要,保留以防外部读取。
  final RxDouble width = 20.0.obs;
  final RxBool isCurved = true.obs;
  final RxDouble minY = 0.0.obs;
  final RxDouble maxY = 45.0.obs;

  // === 流畅度优化核心字段(2026-06-27) ===
  /// X 轴滑动窗口左边界(由 addSpots 自动维护,Obx 监听后驱动 LineChart 平移)
  final RxDouble minX = 0.0.obs;
  /// X 轴滑动窗口右边界(总是等于最新一个点的 X 坐标)
  final RxDouble maxX = 0.0.obs;
  /// 滑动窗口容量(老张 2026-06-28 决定:固定 30,取消之前的 60/300 双模式切换)
  static const int windowSize = 30;
  /// list 内多保留的"溢出"点数(老张 2026-06-28:让最左边的点超出屏幕再裁掉,避免画面左边缘"切一绺")
  /// 屏幕上只显示最近 windowSize 个 X,但 list 内多保留 listBuffer 个点,这些点的 X < minX,
  /// 在屏幕左边缘外,被 ClipData 自动裁切,addSpots 时 removeAt(0) 移走的也是它们——画面看不到。
  static const int listBuffer = 5;
  /// 全局 X 计数器(永远递增,确保 X 编号单调,曲线不会因重新编号跳动)
  double _globalCounter = 0;
  RxList<FlSpot> dataFlSpotBaseline = <FlSpot>[FlSpot(0, 0)].obs;
  RxList<FlSpot> dataFlSpot0 = <FlSpot>[FlSpot(0, 0)].obs;
  RxList<FlSpot> dataFlSpot1 = <FlSpot>[FlSpot(0, 0)].obs;
  RxList<FlSpot> dataFlSpot2 = <FlSpot>[FlSpot(0, 0)].obs;
  RxList<FlSpot> dataFlSpot3 = <FlSpot>[FlSpot(0, 0)].obs;
  RxList<FlSpot> dataFlSpot4 = <FlSpot>[FlSpot(0, 0)].obs;
  final RxBool isShowLine0 = true.obs;
  final RxBool isShowLine1 = true.obs;
  final RxBool isShowLine2 = true.obs;
  final RxBool isShowLine3 = true.obs;
  final RxBool isShowLine4 = true.obs;
  final RxDouble barWidthLine0 = 1.0.obs;
  final RxDouble barWidthLine1 = 1.5.obs;
  final RxDouble barWidthLine2 = 2.0.obs;
  final RxDouble barWidthLine3 = 2.5.obs;
  final RxDouble barWidthLine4 = 3.0.obs;
  double setHeight(double h) {
    height.value = h;
    return h;
  }

  bool setIsCurved(bool c) {
    isCurved.value = c;
    return c;
  }

  double setBarWidth(double w, {int i = -1}) {
    if (i == 0) {
      barWidthLine0.value = w;
      return w;
    }
    if (i == 1) {
      barWidthLine1.value = w;
      return w;
    }
    if (i == 2) {
      barWidthLine2.value = w;
      return w;
    }
    if (i == 3) {
      barWidthLine3.value = w;
      return w;
    }
    if (i == 4) {
      barWidthLine4.value = w;
      return w;
    }

    barWidthLine0.value = w;
    barWidthLine1.value = w;
    barWidthLine2.value = w;
    barWidthLine3.value = w;
    barWidthLine4.value = w;
    return w;
  }

  double setMinY(double y) {
    minY.value = y;
    return y;
  }

  double setMaxY(double y) {
    maxY.value = y;
    return y;
  }

  /// list 容量 = windowSize + listBuffer(35),屏幕上只显示最近 windowSize (30) 个 X,
  /// 多余的 listBuffer (5) 个点在屏幕左边缘外,被 ClipData 自动裁切。
  int get _currentCapacity => windowSize + listBuffer;

  /// === 流畅度优化核心(2026-06-27,2026-06-28 升级)===
  /// 示波器风格:新数据从右端进入,X 用全局递增序号,LineChart 的 minX/maxX 锁定最近 windowSize 个点的窗口。
  /// list 内多保留 listBuffer 个"溢出"点,让最左边的点早已滑出屏幕左边缘再被裁切,避免"切一绺"。
  /// fl_chart 自带的 950ms 隐式动画负责平滑平移。
  /// 启动期一次性用 FlSpot.nullSpot 占满 list,保证首次渲染就是满屏。
  bool addSpots(List<double> spots) {
    if (spots.length != 5) {
      return false;
    }
    final int listCap = _currentCapacity;       // list 容量 = 35
    final int winSize = windowSize;              // 屏幕显示窗口 = 30

    // === 启动期:一次性用 nullSpot 灌满 list ===
    // 灌到 listCap (35) 个,确保启动后前 5 秒新数据进来时,最老的点仍在 list 内
    // 但不在屏幕范围内(它们 X < minX,在屏幕左外)
    if (dataFlSpot0.length < listCap) {
      while (dataFlSpotBaseline.length < listCap) {
        dataFlSpotBaseline.add(FlSpot.nullSpot);
      }
      while (dataFlSpot0.length < listCap) {
        dataFlSpot0.add(FlSpot.nullSpot);
        dataFlSpot1.add(FlSpot.nullSpot);
        dataFlSpot2.add(FlSpot.nullSpot);
        dataFlSpot3.add(FlSpot.nullSpot);
        dataFlSpot4.add(FlSpot.nullSpot);
      }
      // _globalCounter 设为 listCap,让初始 X 窗口 [1, listCap] 内已有数据可看
      _globalCounter = listCap.toDouble();
    }

    // 全局 X 序号递增(单调递增,确保曲线连续)
    _globalCounter++;
    final double x = _globalCounter;

    // 滑动窗口:超过 listCap 就从头丢,list 长度恒定 = listCap
    while (dataFlSpot0.length >= listCap) {
      dataFlSpotBaseline.removeAt(0);
      dataFlSpot0.removeAt(0);
      dataFlSpot1.removeAt(0);
      dataFlSpot2.removeAt(0);
      dataFlSpot3.removeAt(0);
      dataFlSpot4.removeAt(0);
    }

    dataFlSpotBaseline.add(FlSpot(x, 0.0));
    double s = 0.0;
    const double u = 40.0;
    const int b= 10000;
    s = spots[0] / b + 3.0;
    s = s > u ? u : s;
    dataFlSpot0.add(FlSpot(x, s));
    s = spots[1] / b + 11.0;
    s = s > u ? u : s;
    dataFlSpot1.add(FlSpot(x, s));
    s = spots[2] / b + 19.0;
    s = s > u ? u : s;
    dataFlSpot2.add(FlSpot(x, s));
    s = spots[3] / b + 27.0;
    s = s > u ? u : s;
    dataFlSpot3.add(FlSpot(x, s));
    s = spots[4] / b + 35.0;
    s = s > u ? u : s;
    dataFlSpot4.add(FlSpot(x, s));

    // minX/maxX 锁定最近 winSize (30) 个 X 序号范围(不 clamp 到 0,允许负数)
    // 例:winSize=30, _globalCounter=100 → minX=71, maxX=100
    //   → 屏幕上显示 X∈[71,100] 这 30 个点
    //   → list 内 X∈[66,100] 共 35 个点,X∈[66,70] 在屏幕左外,被 ClipData 裁掉
    minX.value = _globalCounter - winSize + 1;
    maxX.value = _globalCounter.toDouble();

    return true;
  }

  /// [兼容保留] 旧版 ctrl.dart 仍可能在数据量超过 3600 时调用此方法整体清空。
  /// 新版 addSpots 已采用滑动窗口,理论上此方法不会被自动触发。
  /// 保留实现以兼容外部调用(例如 MyCtrl.clearData() 在重新检测时调用)。
  void clearSpots() {
    dataFlSpotBaseline.clear();
    dataFlSpot0.clear();
    dataFlSpot1.clear();
    dataFlSpot2.clear();
    dataFlSpot3.clear();
    dataFlSpot4.clear();
    // ⚠️ 修复 LateInitializationError (2026-07-03 老张揪出)：
    // fl_chart 的 LineChartBarData 构造函数要求 spots 中至少有 1 个非 nullSpot，
    // 否则 mostLeftSpot/mostTopSpot/mostRightSpot/mostBottomSpot 这 4 个 late 字段
    // 永远未初始化，paint 时 drawBelowBar 访问 → LateError。
    // 之前 clearSpots 用 [FlSpot.nullSpot] 占位，会在"clearData 之后 addSpots 之前"
    // 触发 paint 红屏。这里改为 [FlSpot(0, 0)] 有效占位。
    dataFlSpotBaseline.add(FlSpot(0, 0));
    dataFlSpot0.add(FlSpot(0, 0));
    dataFlSpot1.add(FlSpot(0, 0));
    dataFlSpot2.add(FlSpot(0, 0));
    dataFlSpot3.add(FlSpot(0, 0));
    dataFlSpot4.add(FlSpot(0, 0));
    // 重置全局计数器,X 窗口归零
    _globalCounter = 0;
    minX.value = 0;
    maxX.value = 0;
    width.value = 0;
  }
}

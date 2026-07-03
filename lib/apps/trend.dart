import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:healing_junior/index.dart';
import 'package:healing_junior/view.dart';

/// 16 种情绪标签（4×4 象限）。
/// 下标与 TrendCtrl.emoValues 一一对应：
///   [ 0恐惧-, 1愤怒-, 2警觉+, 3欢喜+,
///     4焦虑-, 5紧张-, 6兴奋+, 7快乐+,
///     8厌恶-, 9烦恼-, 10镇定+, 11放松+,
///    12忧虑-, 13悲伤-, 14平静+, 15满足+ ]
/// 末尾 +/- 表示正负向，是产品语义的一部分，**禁止改动**。
List<String> emoLabels = [
  "恐惧-",
  "愤怒-",
  "警觉+",
  "欢喜+",
  "焦虑-",
  "紧张-",
  "兴奋+",
  "快乐+",
  "厌恶-",
  "烦恼-",
  "镇定+",
  "放松+",
  "忧虑-",
  "悲伤-",
  "平静+",
  "满足+",
];

/// UI 中显示为"Bird"（正向情绪）的下标集合，用于收益统计。
const Set<int> _positiveEmotionIndexes = {2, 3, 6, 7, 10, 11, 14, 15};

/// 把 1 个 sign 编码为 0/1/2（负/零/正）。
int _signCodeOf(double s) => s < 0 ? 0 : (s > 0 ? 2 : 1);

/// 把 5 个 sign 编码为唯一整数 key（3 进制位）。
///
/// 位序（高位→低位）: alpha | beta | gamma | theta | delta
///   每位取值：0=负、1=零、2=正 → 3^5 = 243 种组合。
///
/// 用 int key 替代字符串查表，规避"位顺序手抖"风险。
///
/// ⚠️ **关键：原 if-else 完全不使用 delta**——只根据 beta/alpha/gamma/theta
/// 这 4 个 sign 决定累加哪个 emoValues。delta 不参与决策。
///
/// 因此 [_signCode] **把 delta 位固定写为 0**（不参与编码），
/// 这样 alpha/beta/gamma/theta 相同的两个 sign（delta 不同）映射到同一个 key，
/// 与原 if-else 行为完全一致。
///
/// 同理，_trendLookup 只登记 16 条（与原 if-else 16 个分支一一对应）。
int _signCode(
  double delta, // 原 if-else 不使用此参数；保留为形参以兼容 trend() 接口
  double theta,
  double alpha,
  double beta,
  double gamma,
) {
  return _signCodeOf(alpha) * 81 + _signCodeOf(beta) * 27 + _signCodeOf(gamma) * 9 + _signCodeOf(theta) * 3 + 0; // delta 位固定 0：原代码不使用 delta，对任何 delta 都命中
}

/// signCode → emoValues 下标的查表。
///
/// 原 trend() 是 5 层 if-else 决策树（外层 if beta<0 / else 各 8 条，共 16 个分支），
/// 但**所有分支内都不使用 delta**——意味着 delta 的符号对结果无影响。
///
/// 因此查表只登记 16 条。_signCode 把 delta 位固定写 0，让
/// "alpha/beta/gamma/theta 相同、delta 不同"的两种 sign 落到同一条。
///
/// **设计哲学**：与原 if-else 一致——信任上游 [Data.calculateTrendSign]
/// 保证 sign 永不为 0，所以本查表不需要为 sign=0 做防御。
/// 如果上游契约被破坏（sign=0），新版会抛 NoSuchMethodError，而不是"安全地不累加"——
/// 这与原 if-else 在 sign=0 时会落入某层 else 累加的"死代码行为"不同，
/// 但上游契约不破，新版就 100% 与原版等价。
///
/// 表项生成规则见下方 [_buildLookup] 中的注释（来自对原 if-else 的人工核对）。
final Map<int, int> _trendLookup = _buildLookup();

Map<int, int> _buildLookup() {
  // 16 个分支按外层 beta<0 / else 拆成两组。
  // 表项格式：signCode(alpha, beta, gamma, theta, delta=0) → emoValues[idx]
  final map = <int, int>{};

  void add(int alpha, int beta, int gamma, int theta, int idx) {
    // delta 位固定 0：原代码不使用 delta，对任何 delta 都命中此条
    final key = alpha * 81 + beta * 27 + gamma * 9 + theta * 3 + 0;
    map[key] = idx;
  }

  // —— 外层 if (betaTrendSign < 0)：注释"正向情绪"，共 8 条 ——
  // P1  alpha>0, gamma>0, theta<0  → emoValues[2] 警觉+
  add(2, 0, 2, 0, 2);
  // P2  alpha>0, gamma>0, theta>0  → emoValues[6] 兴奋+
  add(2, 0, 2, 2, 6);
  // P3  alpha>0, gamma<0, theta<0  → emoValues[3] 欢喜+
  add(2, 0, 0, 0, 3);
  // P4  alpha>0, gamma<0, theta>0  → emoValues[7] 快乐+
  add(2, 0, 0, 2, 7);
  // P5  alpha<0, gamma>0, theta<0  → emoValues[10] 镇定+
  add(0, 0, 2, 0, 10);
  // P6  alpha<0, gamma>0, theta>0  → emoValues[14] 平静+
  add(0, 0, 2, 2, 14);
  // P7  alpha<0, gamma<0, theta<0  → emoValues[11] 放松+
  add(0, 0, 0, 0, 11);
  // P8  alpha<0, gamma<0, theta>0  → emoValues[15] 满足+
  add(0, 0, 0, 2, 15);

  // —— 外层 else (betaTrendSign >= 0)：注释"负向情绪"，共 8 条 ——
  // N1  alpha>0, gamma>0, theta<0  → emoValues[0] 恐惧-
  add(2, 2, 2, 0, 0);
  // N2  alpha>0, gamma>0, theta>0  → emoValues[4] 焦虑-
  add(2, 2, 2, 2, 4);
  // N3  alpha>0, gamma<0, theta<0  → emoValues[1] 愤怒-
  add(2, 2, 0, 0, 1);
  // N4  alpha>0, gamma<0, theta>0  → emoValues[5] 紧张-
  add(2, 2, 0, 2, 5);
  // N5  alpha<0, gamma>0, theta<0  → emoValues[8] 厌恶-
  add(0, 2, 2, 0, 8);
  // N6  alpha<0, gamma>0, theta>0  → emoValues[12] 忧虑-
  add(0, 2, 2, 2, 12);
  // N7  alpha<0, gamma<0, theta<0  → emoValues[9] 烦恼-
  add(0, 2, 0, 0, 9);
  // N8  alpha<0, gamma<0, theta>0  → emoValues[13] 悲伤-
  add(0, 2, 0, 2, 13);

  return map;
}

/// ==================== TrendView ====================

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

/// ==================== TrendCtrl ====================

class TrendCtrl extends GetxController {
  /// 16 个情绪计数器，下标语义见 [emoLabels]。
  /// RxList 配合 EmoValue 内的 Obx 实现精准重建。
  final RxList<int> emoValues = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0].obs;

  /// 根据 5 个频段趋势方向累加 emoValues，并通知 AI 对话。
  ///
  /// 原实现是 5 层 if-else（298 行），现已重构为查表：
  ///   1. 编码 5 个 sign → 唯一整数 key（3 进制位）
  ///   2. 在 [_trendLookup] 中查找对应 emoValues 下标
  ///   3. 命中则累加 + 上报 AI；否则保持原行为（不动 emoValues、不上报）
  ///
  /// ⚠️ 行为契约：与原 if-else 完全等价。
  /// 原代码外层 `if (betaTrendSign < 0)` / else 各自累加不同 emoValues，
  /// 且所有分支内都不使用 deltaTrendSign，因此 delta 不影响结果。
  void trend(
    double deltaTrendSign,
    double thetaTrendSign,
    double alphaTrendSign,
    double betaTrendSign,
    double gammaTrendSign,
  ) {
    final key = _signCode(
      deltaTrendSign,
      thetaTrendSign,
      alphaTrendSign,
      betaTrendSign,
      gammaTrendSign,
    );
    // Data.calculateTrendSign 保证 sign 永不为 0，故查表必然命中，无需 null 防御。
    final idx = _trendLookup[key]!;
    emoValues[idx]++;
    final trendEmos = ['${emoLabels[idx]}1']; // 末尾的 "1" 是产品语义，禁止改动

    // IndexCtrl 仅在本方法使用，改为局部变量避免无谓的字段占用。
    final indexCtrl = Get.put(IndexCtrl());
    indexCtrl.injectEmotion(trendEmos.join(','));
  }

  void init() {
    for (int i = 0; i < emoValues.length; i++) {
      emoValues[i] = 0;
    }
  }
}

/// ==================== EmoValue（收益表 + 4×4 象限图） ====================

class EmoValue extends StatelessWidget {
  final List<int> data;
  const EmoValue({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    final positiveValues = data.asMap().entries.where((e) => _positiveEmotionIndexes.contains(e.key)).map((e) => e.value).toList();
    final total = data.fold<int>(0, (p, c) => p + c);
    final totalBirds = positiveValues.fold<int>(0, (p, c) => p + c);
    final totalCribs = total - totalBirds;

    return Container(
      margin: const EdgeInsets.all(10),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: colorSecondary,
        borderRadius: BorderRadius.circular(10),
        boxShadow: const [
          BoxShadow(
            color: Colors.grey,
            spreadRadius: 1,
            blurRadius: 1,
            offset: Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        children: [
          const MyTextP2("情绪分型识别 - 云图"),
          MyTextP3("（情绪效价与激活度）", colorPrimaryContainer),
          const SizedBox(height: 80),
          const _QuadrantChart(),
          const SizedBox(height: 40),
          ExpansionTile(
            leading: Icon(Icons.restore_rounded),
            //collapsedShape: Border(top: BorderSide(color: colorSurface)),
            shape: Border(top: BorderSide(color: colorSurface), bottom: BorderSide(color: colorSurface)),
            title: MyTextP2("效价详表 Birds $totalBirds & Cribs $totalCribs"),
            subtitle: MyTextP3("收获的正向情绪 & 被克制的负向情绪", colorPrimaryContainer),
            children: [
              _HealingTable(data: data),
              const SizedBox(height: 20),
            ],
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }
}

/// 疗愈收益表：每行 [标签 | 条形 | 数值]。
///
/// **设计意图**：第 2 列（条形）需要展示最多 16+1 个 30×30 图标，
/// 因此给其分配 **远大于** 标签列和数值列的 flex 权重。
/// 原代码用 `FlexColumnWidth(context.width)`（≈ 屏幕宽度）作为 flex 值，
/// 效果是第 2 列占比 ≈ 77% ~ 100% 屏幕宽（取决于设备宽度），
/// 1/3 列窄、2/3 列宽，符合"一长串图标"的需求。
/// 保持原代码写法，**不要"优化"成 1 或 100** —— 那会破坏原布局。
class _HealingTable extends StatelessWidget {
  final List<int> data;
  const _HealingTable({required this.data});

  @override
  Widget build(BuildContext context) {
    return Table(
      columnWidths: {
        0: const FlexColumnWidth(60),
        1: FlexColumnWidth(context.width), // 原代码意图：第 2 列占绝大多数空间
        2: const FlexColumnWidth(60),
      },
      defaultVerticalAlignment: TableCellVerticalAlignment.middle,
      children: [
        for (int i = 0; i < emoLabels.length; i++)
          TableRow(children: [
            MyTextP2(emoLabels[i]),
            _BarsCell(
              value: data[i],
              positive: _positiveEmotionIndexes.contains(i),
            ),
            Container(
              alignment: Alignment.centerRight,
              child: MyTextP2("${data[i] > 0 ? '/' : ''} ${data[i].toString()}"),
            ),
          ]),
      ],
    );
  }
}

/// 单行条形：一组 Bird/Crib 图标 + 一个控制点图标。
/// 条数 = min(value, 16)，避免溢出。
class _BarsCell extends StatelessWidget {
  final int value;
  final bool positive;
  const _BarsCell({required this.value, required this.positive});

  @override
  Widget build(BuildContext context) {
    final shown = value > 16 ? 16 : value;
    return Row(
      children: [
        for (int j = 0; j < shown; j++)
          Container(
            margin: const EdgeInsets.only(right: 1),
            width: 28,
            height: 28,
            child: positive ? Image.asset('assets/images/Bird.png') : const Icon(Icons.crib_rounded, size: 20, color: Colors.grey),
          ),
        Container(
          margin: const EdgeInsets.only(right: 1),
          width: 24,
          height: 24,
          child: const Icon(Icons.keyboard_control_rounded, size: 20, color: Colors.grey),
        ),
      ],
    );
  }
}

/// 4×4 情绪象限图：椭圆背景 + 坐标系 + 16 个情绪内容块（Stack 叠加）。
///
/// **设计意图**：
/// - 椭圆 400×200 是 4 象限情绪的活动边界
/// - 坐标系 420×220 比椭圆大一圈，**专门为"效价""激活度"两个轴标签预留外圈空间**
/// - 16 个情绪内容块（100×50）绝对定位在 4×4 网格中心，**字号大小反映 emoValues[i] 数值**
///
/// ⚠️ **不要改坐标系 CustomPaint 的尺寸**：
/// 1. 改成 LayoutBuilder 的 maxWidth 会让"激活度"标签在窄屏上贴边或被裁剪
/// 2. 让坐标系和椭圆同尺寸会去掉轴标签的外圈空间
class _QuadrantChart extends StatelessWidget {
  const _QuadrantChart();

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (ctx, constraints) {
        final w = constraints.maxWidth;
        final h = constraints.hasBoundedHeight ? constraints.maxHeight : 220.0;
        // Stack 中心 = (w/2, h/2)
        // 16 个内容框均匀分布在坐标系 CustomPaint (400×200) 内部 4×4 网格：
        //   - 4 列，每列均分 400px 宽 → 列中心 = col*100 + 50 (坐标系内坐标)
        //   - 4 行，每行均分 200px 高 → 行中心 = row*50 + 25
        // 坐标系 size 中心落在 Stack 中心，所以坐标系内 (x, y) 对应 Stack 内：
        //   (w/2 - 200 + x, h/2 - 100 + y)
        // 内容框 100×50，Positioned left/top = 中心 - 50/25
        // 推导后：
        //   left = w/2 + col*100 - 200
        //   top  = h/2 + row*50  - 100
        final cx = w / 2;
        final cy = h / 2;
        return SizedBox(
          width: w,
          height: h,
          child: Stack(
            alignment: Alignment.center,
            children: [
              CustomPaint(size: const Size(400, 200), painter: _EllipsePainter()),
              CustomPaint(size: const Size(420, 220), painter: _CoordinateSystemPainter()),
              for (int i = 0; i < 16; i++)
                _EmotionCell(
                  index: i,
                  cellLeft: cx + (i % 4) * 100 - 200,
                  cellTop: cy + (i ~/ 4) * 50 - 100,
                ),
            ],
          ),
        );
      },
    );
  }
}

/// 单个情绪内容块：100×50 固定尺寸，居中显示词条字号随 value 变化，
/// 右上角圆角底色显示数值（0 值不显示，超过 99 显示 99）。
class _EmotionCell extends StatelessWidget {
  final int index;
  final double cellLeft;
  final double cellTop;
  const _EmotionCell({
    required this.index,
    required this.cellLeft,
    required this.cellTop,
  });

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<TrendCtrl>();
    return Positioned(
      left: cellLeft,
      top: cellTop,
      width: 100,
      height: 50,
      child: Obx(() {
        final value = ctrl.emoValues[index];
        final fontSize = _fontSizeFor(value);
        // 左半 (col 0,1) = 负向情绪, 右半 (col 2,3) = 正向情绪
        final isPositive = (index % 4) >= 2;
        return Stack(
          children: [
            Center(
              child: Text(
                emoLabels[index],
                style: TextStyle(
                  color: colorPrimaryContainer,
                  fontSize: fontSize,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            if (value > 0)
              Positioned(
                right: 2,
                top: 2,
                child: _ValueBadge(value: value, positive: isPositive),
              ),
          ],
        );
      }),
    );
  }

  /// 字号线性映射：value=0 → 11，value=34 → 28（上限 28）。
  /// 比例 0.5/单位 value，简单稳定。
  static double _fontSizeFor(int value) {
    return (11 + value * 0.5).clamp(11.0, 28.0);
  }
}

/// 右上角数值角标：圆形底色 + 白色数字。
/// 左半（负向情绪）橙色，右半（正向情绪）蓝色。
class _ValueBadge extends StatelessWidget {
  final int value;
  final bool positive;
  const _ValueBadge({required this.value, required this.positive});

  @override
  Widget build(BuildContext context) {
    final shown = value > 99 ? '99' : '$value';
    return Container(
      width: 18,
      height: 18,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: positive ? Colors.blue : Colors.orange,
        shape: BoxShape.circle,
      ),
      child: Text(
        shown,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

/// 坐标系：横轴 = 效价（左右），纵轴 = 激活度（上下）。
class _CoordinateSystemPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = colorSurface
      ..strokeWidth = 1;

    canvas.drawLine(Offset(0, size.height / 2), Offset(size.width, size.height / 2), paint);
    canvas.drawLine(Offset(size.width / 2, 0), Offset(size.width / 2, size.height), paint);

    // 横轴标签（>效价）
    final hLabel = TextPainter(
      text: TextSpan(text: ' >效价', style: TextStyle(color: colorPrimaryContainer, fontSize: 14)),
      textDirection: TextDirection.ltr,
    )..layout();
    hLabel.paint(canvas, Offset(size.width, size.height / 2 - 11));

    // 纵轴标签（>激活度），旋转 -90°
    final vLabel = TextPainter(
      text: TextSpan(text: ' >激活度', style: TextStyle(color: colorPrimaryContainer, fontSize: 14)),
      textDirection: TextDirection.ltr,
    )..layout();
    canvas.save();
    canvas.translate(size.width / 2 - 11, 0);
    canvas.rotate(-90 * 3.1415927 / 180);
    vLabel.paint(canvas, Offset.zero);
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// 椭圆：4 象限情绪的活动边界。
class _EllipsePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = colorPrimary;
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(size.width / 2, size.height / 2),
        width: size.width,
        height: size.height,
      ),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

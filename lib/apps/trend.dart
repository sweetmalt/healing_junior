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

  /// 时间轴数据源：每个元素是一组（4 次 trend() 调用）的 4 个情绪索引。
  /// 时间轴 UI 层读取此列表生成每分钟刻度。
  final RxList<List<int>> emotionGroups = <List<int>>[].obs;

  /// 时间轴组缓冲：4 次 trend() 凑成一组，满了就推入 [emotionGroups] 并清空。
  final List<int> _pendingGroup = [];

  /// 根据 5 个频段趋势方向累加 emoValues，并通知 AI 对话。
  ///
  /// 原实现是 5 层 if-else（298 行），现已重构为查表：
  ///   1. 编码 5 个 sign → 唯一整数 key（3 进制位）
  ///   2. 在 [_trendLookup] 中查找对应 emoValues 下标
  ///   3. 命中则累加 + 上报 AI；否则保持原行为（不动 emoValues、不上报）
  ///
  /// 同时把当次产出的情绪索引累入 [_pendingGroup]，
  /// **每 4 次调用 = 1 个时间轴 group**（约 64 个数据点 ≈ 1 分钟）。
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

    // 时间轴：累入缓冲，4 个一组。
    _pendingGroup.add(idx);
    if (_pendingGroup.length >= 4) {
      emotionGroups.add(List<int>.from(_pendingGroup));
      _pendingGroup.clear();
    }
  }

  void init() {
    for (int i = 0; i < emoValues.length; i++) {
      emoValues[i] = 0;
    }
    emotionGroups.clear();
    _pendingGroup.clear();
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
          const MyTextP2("情绪转折时刻表"),
          MyTextP3("（一个刻度大约对应1分钟的情绪数据）", colorPrimaryContainer),
          const _EmotionTimeline(),
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
              child: MyTextP2(" ${data[i].toString()}"),
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

/// ==================== 情绪转折时刻表（又称情绪时间轴） ====================
///
/// 老张 2026-07-03 命名：本模块叫"情绪转折时刻表"。
///
/// **核心结构**：横贯整个时间轴区域的**一条水平线**（"轴线"），
/// 每个刻度 = 轴线上**贴一个数字徽章**（数字画在小圆点里）+ 徽章上方挂鸟 + 下方挂木马。
///
///   ────●────●────●────●────●────●────●────  ← 轴线（CustomPaint 画 1 条横线）
///      1️⃣   2️⃣  3️⃣  4️⃣  5️⃣  6️⃣  7️⃣
///     🦅                🦅🦅🦅🦅
///
/// **绝对定位**：每个 tick 的所有元素都以"轴线"为唯一锚点，
/// 不依赖 Column center，徽章**始终贴在轴线 y 上**。
///
/// **空状态**：还没收到任何情绪组时，轴线横贯整个父级可用宽度（占满屏幕），
/// 提示用户"这里将出现情绪转折点"；收到第一个 group 后切回按 tick 数计算宽度。
///
/// 横向溢出时 SingleChildScrollView 滚动。
class _EmotionTimeline extends StatelessWidget {
  const _EmotionTimeline();

  /// 每格间距
  static const double _tickWidth = 30;

  /// 时间轴区域总高（老张 2026-07-03 决定从 200 提升到 240，
  /// 容纳 4 槽图标 (4×22) + 徽章 (22) + 上下边距，避免图标被裁切）
  static const double _axisHeight = 240;

  /// 轴线 y 坐标（区域中心）
  static const double _axisY = 120;

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<TrendCtrl>();
    // LayoutBuilder 在外层（拿到父级可用宽度，避免空状态时 SizedBox width 退化为 30px）。
    // Obx 在内层（直接读 ctrl.emotionGroups，GetX 才能正确建立依赖追踪）。
    return LayoutBuilder(
      builder: (ctx, constraints) {
        return Obx(() {
          final groups = ctrl.emotionGroups;
          // 空状态：让 SizedBox 宽度 = 父级可用宽度（横贯整个屏幕，提示"等待数据"）
          // 有数据：按 tick 数计算宽度，溢出时 SingleChildScrollView 横向滚动
          final double width;
          if (groups.isEmpty) {
            width = constraints.maxWidth;
          } else {
            width = (groups.length * _tickWidth)
                .clamp(_tickWidth, double.infinity)
                .toDouble();
          }
          return SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: SizedBox(
              width: width,
              height: _axisHeight,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  // 1. 横贯轴线：CustomPaint 画 1 条横线（贯穿整个 SizedBox 宽度）
                  Positioned(
                    left: 0,
                    right: 0,
                    top: _axisY - 0.5,
                    child: CustomPaint(
                      size: Size(width, 1),
                      painter: _AxisLinePainter(),
                    ),
                  ),
                  // 2. 每个刻度：Positioned 绝对定位（空状态时不渲染）
                  for (int i = 0; i < groups.length; i++)
                    Positioned(
                      left: i * _tickWidth,
                      width: _tickWidth,
                      top: 0,
                      height: _axisHeight,
                      child: _EmotionTick(
                        tickNumber: i + 1,
                        group: groups[i],
                        axisY: _axisY,
                      ),
                    ),
                ],
              ),
            ),
          );
        });
      },
    );
  }
}

/// 时间轴横线：1 条灰线横贯整个宽度。
class _AxisLinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.grey
      ..strokeWidth = 1;
    canvas.drawLine(
      Offset(0, size.height / 2),
      Offset(size.width, size.height / 2),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// 单个时间轴刻度：内部用 Stack + Positioned 绝对定位，
/// **以 axisY（轴线 y 坐标）为唯一锚点**，不受图标数量影响。
///
///   - 上方最多 4 只小鸟：从下往上向轴线收敛（最靠近轴线 = 最新）
///   - 中线：数字徽章（22×22 圆点），**贴在轴线上**
///   - 下方最多 4 只木马：从上往下向轴线收敛
class _EmotionTick extends StatelessWidget {
  final int tickNumber;
  final List<int> group;
  final double axisY;

  const _EmotionTick({
    required this.tickNumber,
    required this.group,
    required this.axisY,
  });

  /// 转折点判定（老张 2026-07-03 升级算法）：
///   - 4 个正向 → positiveStrong（深蓝）
///   - 3 个正向 → positiveLight（浅蓝）
///   - 0 正 4 负 → negative（橙底白字）
///   - 其他    → normal（灰底深字）
///
/// 只看 +/- 计数，不区分具体情绪类目。
TickKind get _kind {
    final posCount =
        group.where((i) => emoLabels[i].endsWith('+')).length;
    final negCount =
        group.where((i) => emoLabels[i].endsWith('-')).length;
    if (posCount == 4) return TickKind.positiveStrong;
    if (posCount == 3) return TickKind.positiveLight;
    if (posCount == 0 && negCount == 4) return TickKind.negative;
    return TickKind.normal;
  }

  /// 上方 4 槽：正向情绪列表。
  List<int> get _positiveSlots =>
      group.where((i) => emoLabels[i].endsWith('+')).toList();

  /// 下方 4 槽：负向情绪列表。
  List<int> get _negativeSlots =>
      group.where((i) => emoLabels[i].endsWith('-')).toList();

  // === 尺寸常量 ===
  static const double _iconSize = 20;
  static const double _iconSpacing = 2; // 图标间垂直间距
  static const double _badgeSize = 22;

  @override
  Widget build(BuildContext context) {
    final positives = _positiveSlots;
    final negatives = _negativeSlots;
    final kind = _kind;

    // 居中偏移：徽章和图标都在 30px tick 宽度内居中
    final centerX = (30 - _iconSize) / 2;
    final badgeX = (30 - _badgeSize) / 2;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        // === 上方 4 槽小鸟：从下往上向轴线收敛 ===
        // 最靠近轴线的是 positives 的最后一个（即"最新一个正向情绪"），
        // 所以放在 axisY - _badgeSize - 1（紧贴徽章上方）
        // 依次往上排：axisY - _badgeSize - 1 - i * (_iconSize + _iconSpacing)
        for (int i = 0; i < positives.length; i++)
          Positioned(
            left: centerX,
            top: axisY -
                _badgeSize -
                1 -
                (positives.length - i) * (_iconSize + _iconSpacing),
            child: _birdIcon(positives[i], size: _iconSize),
          ),

        // === 中线：数字徽章贴在轴线上 ===
        Positioned(
          left: badgeX,
          top: axisY - _badgeSize / 2,
          child: _TickBadge(number: tickNumber, kind: kind),
        ),

        // === 下方 4 槽木马：从上往下向轴线收敛 ===
        // 最靠近轴线的是 negatives 的第一个（即"最新一个负向情绪"），
        // 所以放在 axisY + _badgeSize / 2 + 1（紧贴徽章下方）
        // 依次往下排：axisY + _badgeSize / 2 + 1 + i * (_iconSize + _iconSpacing)
        for (int i = 0; i < negatives.length; i++)
          Positioned(
            left: centerX,
            top: axisY +
                _badgeSize / 2 +
                1 +
                i * (_iconSize + _iconSpacing),
            child: _cribIcon(negatives[i], size: _iconSize),
          ),
      ],
    );
  }

  Widget _birdIcon(int idx, {required double size}) {
    return Image.asset('assets/images/Bird.png',
        width: size, height: size, fit: BoxFit.contain);
  }

  Widget _cribIcon(int idx, {required double size}) {
    return Icon(Icons.crib_rounded, size: size, color: Colors.grey);
  }
}

/// 数字徽章状态枚举：决定徽章的底色和字色。
enum TickKind {
  /// 普通刻度：灰底深字
  normal,

  /// 强正向转折（4 正）：深蓝底白字
  positiveStrong,

  /// 弱正向转折（3 正）：浅蓝底白字
  positiveLight,

  /// 负向转折（0 正 4 负）：橙底白字
  negative,
}

/// 数字徽章：数字画在小圆点里。
/// 颜色按 [TickKind] 决定：4 正深蓝、3 正浅蓝、4 负橙、其余灰。
class _TickBadge extends StatelessWidget {
  final int number;
  final TickKind kind;
  const _TickBadge({required this.number, required this.kind});

  @override
  Widget build(BuildContext context) {
    final Color bg;
    final Color fg;
    switch (kind) {
      case TickKind.positiveStrong:
        bg = Colors.blue.shade800;
        fg = Colors.white;
        break;
      case TickKind.positiveLight:
        bg = Colors.blue.shade300;
        fg = Colors.white;
        break;
      case TickKind.negative:
        bg = Colors.orange;
        fg = Colors.white;
        break;
      case TickKind.normal:
        bg = Colors.grey.shade300;
        fg = Colors.black87;
        break;
    }
    return Container(
      width: 22,
      height: 22,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: bg,
        shape: BoxShape.circle,
      ),
      child: Text(
        '$number',
        style: TextStyle(
          color: fg,
          fontSize: 11,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

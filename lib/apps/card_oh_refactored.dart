import 'dart:math';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// 阶段枚举
enum CardohPhase { select, shuffling, fan, revealed }

/// 已抽卡牌数据结构
class DrawnCard {
  final int id;
  final bool isReversed;
  DrawnCard({required this.id, required this.isReversed});
}

/// 控制器
class CardohCtrl extends GetxController with GetTickerProviderStateMixin {
  // ==================== 状态 ====================
  final phase = CardohPhase.select.obs;
  final selectedDeck = Rxn<int>(); // null / 1 / 2
  final includeSpecial = true.obs; // 是否包含39/40/41特殊卡（仅基础卡有效）
  final allCards = <int>[].obs;
  final remainingCards = <int>[].obs;
  final drawnCards = <DrawnCard>[].obs;
  final currentPage = 0.obs;
  final drawnCard = Rxn<int>();
  final isReversed = false.obs;
  final isFlipped = false.obs;
  final cardFlyProgress = 0.0.obs; // 0.0~1.0 飞入动画进度
  final cardFlipProgress = 0.0.obs; // 0.0~1.0 翻转动画进度
  final showShuffleDone = false.obs; // 洗牌完成标记

  // ==================== 动画控制器 ====================
  AnimationController? _shuffleAnimCtrl;
  AnimationController? _flyAnimCtrl;
  AnimationController? _flipAnimCtrl;

  // 洗牌动画用的随机序列
  List<int> _shuffleSequence = [];

  // 扇形参数
  static const double fanAngle = 120.0; // 扇形总角度
  static const int visibleCards = 11; // 可见卡片数量

  // 选中卡在扇形中的位置（用于飞入动画起始位置计算）
  Offset? selectedCardOffset;

  // 洗牌动画步骤（暴露给widget）- 响应式
  final shuffleStep = 0.obs;

  @override
  void onClose() {
    _shuffleAnimCtrl?.dispose();
    _flyAnimCtrl?.dispose();
    _flipAnimCtrl?.dispose();
    super.onClose();
  }

  // ==================== 动作 ====================

  /// 选择卡组
  void selectDeck(int deck) {
    selectedDeck.value = deck;
    // 初始化卡牌列表
    final maxCards = deck == 1 ? 88 : 99;
    allCards.value = List.generate(maxCards, (i) => i + 1);
    // 基础卡且不包含特殊卡时，过滤掉39/40/41
    if (deck == 1 && !includeSpecial.value) {
      allCards.value = allCards.where((id) => ![39, 40, 41].contains(id)).toList();
    }
    remainingCards.value = List.from(allCards);
    drawnCards.clear();
    currentPage.value = 0;
    drawnCard.value = null;
    isReversed.value = false;
    isFlipped.value = false;
    cardFlyProgress.value = 0.0;
    cardFlipProgress.value = 0.0;
    phase.value = CardohPhase.shuffling;
    _startShuffle();
  }

  /// 开始洗牌动画
  void _startShuffle() {
    _shuffleSequence = List.generate(remainingCards.length, (i) => i);
    _shuffleSequence.shuffle(Random());
    shuffleStep.value = 0;

    _shuffleAnimCtrl?.dispose();
    _shuffleAnimCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2500),
    );

    _shuffleAnimCtrl!.addListener(_onShuffleTick);
    _shuffleAnimCtrl!.forward().then((_) {
      showShuffleDone.value = true;
      Future.delayed(const Duration(milliseconds: 300), () {
        phase.value = CardohPhase.fan;
        showShuffleDone.value = false;
      });
    });
  }

  void _onShuffleTick() {
    // 每帧更新洗牌步骤
    final progress = _shuffleAnimCtrl!.value;
    shuffleStep.value = (progress * _shuffleSequence.length * 2).toInt();
    remainingCards.refresh();
  }

  /// 点击卡片抽卡
  void drawCard(int cardId) {
    if (phase.value != CardohPhase.fan) return;
    if (remainingCards.length <= 1) return; // 最后一张不需要再抽

    // 决定正逆位
    isReversed.value = Random().nextBool();
    drawnCard.value = cardId;
    remainingCards.remove(cardId);
    drawnCards.add(DrawnCard(id: cardId, isReversed: isReversed.value));
    currentPage.value = 0; // 重置到第一页

    phase.value = CardohPhase.revealed;
    isFlipped.value = false;
    cardFlyProgress.value = 0.0;
    cardFlipProgress.value = 0.0;

    // 启动飞入动画
    _startFlyAnimation();
  }

  void _startFlyAnimation() {
    _flyAnimCtrl?.dispose();
    _flyAnimCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _flyAnimCtrl!.addListener(() {
      cardFlyProgress.value = _flyAnimCtrl!.value;
    });

    _flyAnimCtrl!.forward().then((_) {
      // 飞入完成后开始翻转
      Future.delayed(const Duration(milliseconds: 200), _startFlipAnimation);
    });
  }

  void _startFlipAnimation() {
    _flipAnimCtrl?.dispose();
    _flipAnimCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

    _flipAnimCtrl!.addListener(() {
      cardFlipProgress.value = _flipAnimCtrl!.value;
    });

    _flipAnimCtrl!.forward().then((_) {
      isFlipped.value = true;
    });
  }

  /// 返回扇形页
  void backToFan() {
    if (remainingCards.isEmpty) {
      // 最后一张抽完，关闭
      _showEndDialog();
      return;
    }
    phase.value = CardohPhase.fan;
    drawnCard.value = null;
    isFlipped.value = false;
    cardFlyProgress.value = 0.0;
    cardFlipProgress.value = 0.0;
  }

  void _showEndDialog() {
    Get.dialog(
      AlertDialog(
        backgroundColor: const Color(0xFF2A2A4E),
        title: const Text('恭喜完成', style: TextStyle(color: Colors.white)),
        content: Text(
          '已抽取全部 ${drawnCards.length} 张卡牌',
          style: const TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Get.back();
              resetAll();
            },
            child: const Text('重新开始'),
          ),
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('关闭'),
          ),
        ],
      ),
    );
  }

  /// 重新开始
  void resetAll() {
    phase.value = CardohPhase.select;
    selectedDeck.value = null;
    allCards.clear();
    remainingCards.clear();
    drawnCards.clear();
    currentPage.value = 0;
    drawnCard.value = null;
    isReversed.value = false;
    isFlipped.value = false;
  }

  /// 查看已抽卡大图
  void viewDrawnCard(DrawnCard card) {
    Get.dialog(
      Stack(
        children: [
          GestureDetector(
            onTap: () => Get.back(),
            child: Container(color: Colors.black54),
          ),
          Center(
            child: _buildFlipCard(
              card.id,
              card.isReversed,
              true, // 直接显示正面
              1.0,
              1.0,
            ),
          ),
        ],
      ),
    );
  }

  /// AI对话入口
  void showAIDialog() {
    Get.snackbar(
      '疗愈AI对话（下滑关闭）',
      '功能开发中',
      backgroundColor: const Color(0xFF2A2A4E),
      colorText: Colors.white,
      duration: const Duration(seconds: 3),
      margin: const EdgeInsets.all(16),
      snackPosition: SnackPosition.TOP,
    );
  }

  /// 构建翻转卡片widget
  Widget _buildFlipCard(int cardId, bool reversed, bool showFront, double flyProgress, double flipProgress) {
    final screenW = Get.width;
    final cardW = screenW * 0.8;
    final cardH = cardW * 4 / 3;

    // 计算飞入位置：从扇形位置飞到中央
    final startOffset = selectedCardOffset ?? Offset(screenW / 2, Get.height * 0.6);
    final endOffset = Offset(screenW / 2, Get.height * 0.35);

    // flyProgress 控制位置
    final currentOffset = Offset.lerp(startOffset, endOffset, Curves.easeInOut.transform(flyProgress))!;

    // 翻转角度
    final flipAngle = flipProgress * pi;

    return Positioned(
      left: currentOffset.dx - cardW / 2,
      top: currentOffset.dy - cardH / 2,
      child: Transform(
        alignment: Alignment.center,
        transform: Matrix4.identity()
          ..setEntry(3, 2, 0.001)
          ..rotateY(flipAngle),
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 50),
          child: flipAngle < pi / 2
              ? _buildCardBack(cardW, cardH)
              : Transform(
                  alignment: Alignment.center,
                  transform: Matrix4.identity()..rotateY(pi),
                  child: _buildCardFront(cardId, reversed, cardW, cardH),
                ),
        ),
      ),
    );
  }

  Widget _buildCardBack(double w, double h) {
    return Container(
      key: const ValueKey('back'),
      width: w,
      height: h,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF4A3F6B),
            Color(0xFF2D2654),
            Color(0xFF1A1A3E),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.purple.withValues(alpha: 0.3),
            blurRadius: 20,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Center(
        child: CustomPaint(
          size: Size(w * 0.6, h * 0.6),
          painter: _BackPatternPainter(),
        ),
      ),
    );
  }

  Widget _buildCardFront(int cardId, bool reversed, double w, double h) {
    Widget img = Image.asset(
      'assets/images/card_oh/${selectedDeck.value}/${cardId.toString().padLeft(2, '0')}.jpg',
      width: w,
      height: h,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) => Container(
        width: w,
        height: h,
        color: Colors.grey[800],
        child: Center(
          child: Text(
            cardId.toString(),
            style: const TextStyle(color: Colors.white, fontSize: 48),
          ),
        ),
      ),
    );

    if (reversed) {
      img = Transform.rotate(angle: pi, child: img);
    }

    return Container(
      key: const ValueKey('front'),
      width: w,
      height: h,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.purple.withValues(alpha: 0.4),
            blurRadius: 25,
            spreadRadius: 3,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: img,
      ),
    );
  }

  /// 构建扇形中单张卡片的widget
  Widget buildFanCard(int cardId, int index, int totalVisible) {
    const cardW = 70.0;
    const cardH = 93.0;

    return GestureDetector(
      onTap: () => drawCard(cardId),
      child: Container(
        width: cardW,
        height: cardH,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(6),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.4),
              blurRadius: 8,
              offset: const Offset(2, 3),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: Image.asset(
            'assets/images/card_oh/${selectedDeck.value}/${cardId.toString().padLeft(2, '0')}.jpg',
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => Container(
              color: Colors.grey[700],
              child: Center(
                child: Text(cardId.toString(), style: const TextStyle(color: Colors.white, fontSize: 16)),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// 背面图案绘制
class _BackPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width * 0.4;

    // 外圈
    final outerPaint = Paint()
      ..color = Colors.purple.withValues(alpha: 0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    canvas.drawCircle(center, radius, outerPaint);

    // 内圈
    final innerPaint = Paint()
      ..color = Colors.amber.withValues(alpha: 0.4)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    canvas.drawCircle(center, radius * 0.6, innerPaint);

    // 中心圆点
    final dotPaint = Paint()
      ..color = Colors.amber.withValues(alpha: 0.6)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, radius * 0.1, dotPaint);

    // 菱形装饰
    final path = Path();
    final diamondRadius = radius * 0.8;
    path.moveTo(center.dx, center.dy - diamondRadius);
    path.lineTo(center.dx + diamondRadius * 0.7, center.dy);
    path.lineTo(center.dx, center.dy + diamondRadius);
    path.lineTo(center.dx - diamondRadius * 0.7, center.dy);
    path.close();

    final diamondPaint = Paint()
      ..color = Colors.purple.withValues(alpha: 0.2)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    canvas.drawPath(path, diamondPaint);

    // 四角星
    for (var i = 0; i < 4; i++) {
      final angle = i * pi / 2;
      final starX = center.dx + cos(angle) * radius * 0.85;
      final starY = center.dy + sin(angle) * radius * 0.85;
      canvas.drawCircle(Offset(starX, starY), 3, dotPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// 视图
class CardohView extends GetView<CardohCtrl> {
  CardohView({super.key});

  @override
  final controller = Get.put(CardohCtrl());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A2E),
      appBar: _buildAppBar(),
      body: Obx(() => _buildBody()),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: const Color(0xFF1A1A2E),
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.white),
        onPressed: () {
          if (controller.phase.value == CardohPhase.select) {
            Get.back();
          } else {
            _showExitConfirm();
          }
        },
      ),
      title: Obx(() {
        final deck = controller.selectedDeck.value;
        final deckName = deck == 1 ? '基础卡' : (deck == 2 ? '复原卡' : 'OH Cards');
        return Text(
          deckName,
          style: const TextStyle(color: Colors.white, fontSize: 18),
        );
      }),
      centerTitle: true,
      actions: [
        // AI对话入口
        Obx(() {
          if (controller.phase.value == CardohPhase.select) {
            return IconButton(
              icon: const Icon(Icons.chat_bubble_outline, color: Colors.amber),
              onPressed: controller.showAIDialog,
              tooltip: 'AI对话',
            );
          }
          return const SizedBox.shrink();
        }),
      ],
    );
  }

  void _showExitConfirm() {
    Get.dialog(
      AlertDialog(
        backgroundColor: const Color(0xFF2A2A4E),
        title: const Text('确认退出？', style: TextStyle(color: Colors.white)),
        content: const Text(
          '退出后将结束本次抽卡',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () {
              Get.back();
              controller.resetAll();
              Get.back();
            },
            child: const Text('确认退出'),
          ),
        ],
      ),
    );
  }

  Widget _buildBody() {
    switch (controller.phase.value) {
      case CardohPhase.select:
        return _buildSelectPage();
      case CardohPhase.shuffling:
        return _buildShufflePage();
      case CardohPhase.fan:
        return _buildFanPage();
      case CardohPhase.revealed:
        return _buildRevealedPage();
    }
  }

  /// 卡组选择页
  Widget _buildSelectPage() {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              '选择卡组',
              style: TextStyle(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              '抽取属于你的专属卡牌',
              style: TextStyle(color: Colors.white54, fontSize: 16),
            ),
            const SizedBox(height: 48),
            _DeckButton(
              title: '基础卡',
              subtitle: '共88张',
              icon: Icons.style_outlined,
              showSpecialOption: true,
              onTap: () => controller.selectDeck(1),
            ),
            const SizedBox(height: 20),
            _DeckButton(
              title: '复原卡',
              subtitle: '共99张',
              icon: Icons.auto_awesome_outlined,
              onTap: () => controller.selectDeck(2),
            ),
          ],
        ),
      ),
    );
  }

  /// 洗牌动画页
  Widget _buildShufflePage() {
    return Stack(
      children: [
        // 洗牌动画区域
        Center(
          child: Obx(() => _ShuffleAnimation(
                cards: controller.remainingCards,
                step: controller.shuffleStep.value,
              )),
        ),
        // 遮罩文字
        Center(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.black45,
              borderRadius: BorderRadius.circular(30),
            ),
            child: const Text(
              '洗牌中...',
              style: TextStyle(color: Colors.white, fontSize: 18),
            ),
          ),
        ),
      ],
    );
  }

  /// 扇形抽卡页
  Widget _buildFanPage() {
    final remaining = controller.remainingCards;
    if (remaining.isEmpty) {
      return const Center(
        child: Text('暂无剩余卡牌', style: TextStyle(color: Colors.white54)),
      );
    }

    return Column(
      children: [
        // 剩余数量提示
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Text(
            '剩余 ${remaining.length} 张',
            style: const TextStyle(color: Colors.white54, fontSize: 14),
          ),
        ),
        // 扇形卡片区域
        Expanded(
          child: _FanCardView(controller: controller),
        ),
        // AI对话入口按钮
        Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: TextButton.icon(
            onPressed: controller.showAIDialog,
            icon: const Icon(Icons.chat_bubble_outline, color: Colors.amber, size: 18),
            label: const Text(
              'AI疗愈对话',
              style: TextStyle(color: Colors.amber, fontSize: 14),
            ),
          ),
        ),
        // 已抽卡缩略区
        Obx(() {
          final drawn = controller.drawnCards;
          if (drawn.isEmpty) return const SizedBox(height: 90);
          return _DrawnCardsBar(
            drawnCards: drawn,
            onCardTap: controller.viewDrawnCard,
            onReset: () => _showResetConfirm(),
          );
        }),
      ],
    );
  }

  void _showResetConfirm() {
    Get.dialog(
      AlertDialog(
        backgroundColor: const Color(0xFF2A2A4E),
        title: const Text('重新开始', style: TextStyle(color: Colors.white)),
        content: const Text(
          '确认后清空所有已抽卡牌，重新开始新一轮抽卡',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () {
              Get.back();
              if (controller.selectedDeck.value != null) {
                controller.selectDeck(controller.selectedDeck.value!);
              }
            },
            child: const Text('确认'),
          ),
        ],
      ),
    );
  }

  /// 抽中展示页
  Widget _buildRevealedPage() {
    final cardId = controller.drawnCard.value;
    if (cardId == null) return const SizedBox();

    return Stack(
      children: [
        // 背景点击关闭
        GestureDetector(
          onTap: controller.backToFan,
          child: Container(color: Colors.transparent),
        ),
        // 卡片
        Obx(() => controller._buildFlipCard(
              cardId,
              controller.isReversed.value,
              controller.isFlipped.value,
              controller.cardFlyProgress.value,
              controller.cardFlipProgress.value,
            )),
        // AI对话入口
        Positioned(
          top: 60,
          right: 16,
          child: IconButton(
            onPressed: controller.showAIDialog,
            icon: const Icon(Icons.chat_bubble_outline, color: Colors.amber, size: 28),
          ),
        ),
        // 底部提示
        Positioned(
          bottom: 60,
          left: 0,
          right: 0,
          child: Center(
            child: Obx(() {
              if (!controller.isFlipped.value) return const SizedBox();
              final reversed = controller.isReversed.value;
              return Column(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.purple.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      reversed ? '逆 位' : '正 位',
                      style: TextStyle(
                        color: reversed ? Colors.orange : Colors.amber,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: controller.backToFan,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF4A3F6B),
                      foregroundColor: Colors.white,
                    ),
                    child: Text(
                      controller.remainingCards.isEmpty ? '完成' : '再抽一张',
                    ),
                  ),
                ],
              );
            }),
          ),
        ),
      ],
    );
  }
}

/// 卡组选择按钮
class _DeckButton extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback onTap;
  final bool showSpecialOption;

  const _DeckButton({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onTap,
    this.showSpecialOption = false,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 24),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF3A3462), Color(0xFF2A2454)],
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.purple.withValues(alpha: 0.3), width: 1),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Container(
                    width: 60,
                    height: 80,
                    decoration: BoxDecoration(
                      color: Colors.purple.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(icon, color: Colors.amber, size: 32),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          subtitle,
                          style: const TextStyle(color: Colors.white54, fontSize: 14),
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.arrow_forward_ios, color: Colors.white38, size: 20),
                ],
              ),
              // 基础卡特殊选项：是否包含39/40/41
              if (showSpecialOption) ...[
                const SizedBox(height: 12),
                const Divider(color: Colors.white24, height: 1),
                const SizedBox(height: 12),
                _SpecialCardsToggle(),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// 基础卡特殊卡（39/40/41）开关
class _SpecialCardsToggle extends StatelessWidget {
  _SpecialCardsToggle();

  final _ctrl = Get.find<CardohCtrl>();

  @override
  Widget build(BuildContext context) {
    return Obx(() => Row(
          children: [
            const Icon(Icons.info_outline, color: Colors.white38, size: 16),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                '包含 39/40/41 特殊卡',
                style: TextStyle(
                  color: _ctrl.includeSpecial.value ? Colors.white70 : Colors.white38,
                  fontSize: 13,
                ),
              ),
            ),
            Switch(
              value: _ctrl.includeSpecial.value,
              onChanged: (v) => _ctrl.includeSpecial.value = v,
              activeTrackColor: Colors.amber.withValues(alpha: 0.5),
              thumbColor: WidgetStateProperty.resolveWith((states) =>
                  states.contains(WidgetState.selected) ? Colors.amber : Colors.grey),
            ),
          ],
        ));
  }
}

/// 洗牌动画widget
class _ShuffleAnimation extends StatelessWidget {
  final List<int> cards;
  final int step;

  const _ShuffleAnimation({required this.cards, required this.step});

  @override
  Widget build(BuildContext context) {
    // 根据步数计算卡片位置
    final displayCount = 12;
    final visibleCards = cards.take(displayCount).toList();

    return SizedBox(
      width: 160,
      height: 220,
      child: Stack(
        children: List.generate(visibleCards.length, (i) {
          // 交错偏移效果
          final offset = (step + i * 3) % 20;
          final yOffset = offset * 2.0 - 20;
          final rotation = (step % 2 == 0 ? 1 : -1) * (i % 3) * 0.02;

          return Positioned(
            top: yOffset + i * 3,
            left: 20 + (i % 3) * 8.0 - 8,
            child: Transform.rotate(
              angle: rotation,
              child: Container(
                width: 70,
                height: 93,
                decoration: BoxDecoration(
                  color: const Color(0xFF3A3462),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: Colors.purple.withValues(alpha: 0.3)),
                ),
                child: Center(
                  child: Text(
                    visibleCards[i].toString(),
                    style: const TextStyle(color: Colors.white54, fontSize: 12),
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}

/// 扇形卡片视图
class _FanCardView extends StatefulWidget {
  final CardohCtrl controller;

  const _FanCardView({required this.controller});

  @override
  State<_FanCardView> createState() => _FanCardViewState();
}

class _FanCardViewState extends State<_FanCardView> {
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(viewportFraction: 0.25);
    _pageController.addListener(_onPageChanged);
  }

  @override
  void dispose() {
    _pageController.removeListener(_onPageChanged);
    _pageController.dispose();
    super.dispose();
  }

  void _onPageChanged() {
    widget.controller.currentPage.value = _pageController.page?.round() ?? 0;
  }

  @override
  Widget build(BuildContext context) {
    final cards = widget.controller.remainingCards;
    final pageCount = (cards.length / CardohCtrl.visibleCards).ceil();

    if (cards.isEmpty) return const SizedBox();

    return Center(
      child: SizedBox(
        height: 200,
        child: PageView.builder(
          controller: _pageController,
          itemCount: pageCount,
          itemBuilder: (context, pageIndex) {
            return _buildFanRow(cards, pageIndex);
          },
        ),
      ),
    );
  }

  Widget _buildFanRow(List<int> allCards, int pageIndex) {
    const cardW = 70.0;
    const cardH = 93.0;
    const totalAngle = CardohCtrl.fanAngle * pi / 180;
    const startAngle = -totalAngle / 2;

    final startIdx = pageIndex * CardohCtrl.visibleCards;
    final endIdx = (startIdx + CardohCtrl.visibleCards).clamp(0, allCards.length);
    final pageCards = allCards.sublist(startIdx, endIdx);

    return SizedBox(
      width: 300,
      height: 200,
      child: Stack(
        alignment: Alignment.center,
        children: List.generate(pageCards.length, (i) {
          final progress = pageCards.length > 1 ? i / (pageCards.length - 1) : 0.5;
          final angle = startAngle + progress * totalAngle;

          // 计算卡片位置
          const radius = 100.0;
          final x = sin(angle + pi / 2) * radius;
          final y = cos(angle) * 30; // 轻微上下起伏

          // 当前页的中间卡片角度为0
          final offsetFromCenter = i - (pageCards.length / 2) + (pageCards.length % 2 == 0 ? 0.5 : 0);
          final extraAngle = offsetFromCenter * 0.08;

          return Positioned(
            top: 50 - y,
            left: 150 + x - cardW / 2,
            child: GestureDetector(
              onTap: () {
                // 记录选中卡片位置（用于飞入动画）
                final box = context.findRenderObject() as RenderBox?;
                if (box != null) {
                  final pos = box.localToGlobal(Offset.zero);
                  widget.controller.selectedCardOffset = Offset(
                    pos.dx + cardW / 2,
                    pos.dy + cardH / 2,
                  );
                }
                widget.controller.drawCard(pageCards[i]);
              },
              child: Transform.rotate(
                angle: extraAngle,
                child: Container(
                  width: cardW,
                  height: cardH,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(6),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.4),
                        blurRadius: 10,
                        offset: const Offset(2, 4),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: Image.asset(
                      'assets/images/card_oh/${widget.controller.selectedDeck.value}/${pageCards[i].toString().padLeft(2, '0')}.jpg',
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        color: Colors.grey[700],
                        child: Center(
                          child: Text(
                            pageCards[i].toString(),
                            style: const TextStyle(color: Colors.white, fontSize: 16),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}

/// 已抽卡缩略区
class _DrawnCardsBar extends StatelessWidget {
  final List<DrawnCard> drawnCards;
  final Function(DrawnCard) onCardTap;
  final VoidCallback onReset;

  const _DrawnCardsBar({
    required this.drawnCards,
    required this.onCardTap,
    required this.onReset,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 90,
      decoration: BoxDecoration(
        color: const Color(0xFF2A2A4E),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        children: [
          // 标题行
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 8, 4),
            child: Row(
              children: [
                Text(
                  '已抽 ${drawnCards.length} 张',
                  style: const TextStyle(color: Colors.white54, fontSize: 12),
                ),
                const Spacer(),
                TextButton(
                  onPressed: onReset,
                  child: const Text(
                    '重新开始',
                    style: TextStyle(color: Colors.orange, fontSize: 12),
                  ),
                ),
              ],
            ),
          ),
          // 缩略卡片列表
          Expanded(
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              itemCount: drawnCards.length,
              itemBuilder: (context, index) {
                final card = drawnCards[index];
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: GestureDetector(
                    onTap: () => onCardTap(card),
                    child: Transform.rotate(
                      angle: card.isReversed ? pi : 0,
                      child: Container(
                        width: 36,
                        height: 48,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(
                            color: card.isReversed ? Colors.orange : Colors.amber.withValues(alpha: 0.5),
                            width: 1,
                          ),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(3),
                          child: Image.asset(
                            'assets/images/card_oh/${Get.find<CardohCtrl>().selectedDeck.value}/${card.id.toString().padLeft(2, '0')}.jpg',
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Container(
                              color: Colors.grey[700],
                              child: Center(
                                child: Text(
                                  card.id.toString(),
                                  style: const TextStyle(color: Colors.white, fontSize: 10),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
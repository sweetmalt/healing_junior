import 'dart:math';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// ============================================================
/// 阶段枚举
/// ============================================================
enum CardohPhase {
  select, // 选择卡组
  shuffling, // 洗牌动画
  fan, // 扇形浏览/抽卡
  viewing, // 查看已抽卡
}

/// ============================================================
/// 控制器
/// ============================================================
class CardohCtrl extends GetxController {
  @override
  void onInit() {
    super.onInit();
    // 首次进入默认选择基础卡
    selectedDeck.value = 1;
    // 初始化基础卡数据
    selectDeck(1);
  }

  // ==================== 统一数据结构 ====================

  /// 当前显示的卡列表（可以是1-4张卡）
  final currentCards = <int>[].obs;

  /// 选中的卡的索引（null = 显示全部缩略图网格）
  final selectedCardIndex = Rxn<int>();

  /// 所有已抽卡的记录（每条是一组卡ID）
  final drawnCardSets = <List<int>>[].obs;

  /// 扇形显示用的完整卡列表
  final fanDisplayCards = <int>[].obs;

  /// 剩余可抽的卡列表
  final remainingCards = <int>[].obs;

  /// 飞行起点位置列表（每张卡一个起点）
  final flyStartPositions = <Offset>[].obs;

  /// 当前阶段
  final phase = CardohPhase.select.obs;

  /// 是否包含39/40/41特殊卡（仅基础卡有效，默认false）
  final includeSpecial = false.obs;

  /// 当前选中的卡组（1=基础卡, 2=复原卡）
  final selectedDeck = Rxn<int>();

  /// 飞行动画进度 0.0~1.0
  final flyProgress = 0.0.obs;

  /// 是否正在飞行
  final isFlying = false.obs;

  // ==================== 四卡连抽模式 ====================

  /// 四卡连抽模式（等待用户点击槽位）
  final fourDrawMode = false.obs;

  /// 四卡连抽的4张卡（用于最终一起加入drawnCardSets）
  final fourDrawCards = <int>[].obs;

  /// 已填充的槽位索引列表
  final filledSlots = <int>[].obs;

  /// 槽位坐标（屏幕位置），用于飞行终点计算
  final slotPositions = <Offset>[].obs;

  /// 当前飞向的槽位索引（用于飞行终点计算）
  final currentFlyToSlot = Rxn<int>();

  // ==================== 环形/扇形动画参数 ====================

  /// 圆环缩放比例（1.0=初始，1.0=放大后）
  final circleScale = 1.0.obs;

  /// 圆环垂直偏移（0=初始，向上为负，向下为正）
  final circleOffsetY = 0.0.obs;

  /// 圆环旋转角度（弧度），用于滑动控制
  final circleRotation = 0.0.obs;

  /// 散开动画进度（0.0~1.0）
  final shuffleProgress = 0.0.obs;

  /// 移动动画进度（0.0~1.0）
  final moveProgress = 0.0.obs;

  /// 圆环初始半径
  static const double circleRadius = 240.0;

  /// 放大后的圆环半径
  static const double expandedCircleRadius = 400.0;

  /// 圆环最终位置（用于动画终点）：圆心Y = 屏幕高度 + 400 - 240 + 80
  double get finalCircleCenterY => Get.height + 400 - 240 + 80;

  /// 扇形圆心Y（固定值，不受动画调整影响）
  double get fanCircleCenterY => Get.height + 400 - 240;

  /// 圆环初始中心Y（屏幕正中央）
  double get initialCircleCenterY => Get.height / 2;

  /// 是否保存了环形状态
  final hasSavedCircleState = false.obs;

  /// 保存的环形状态
  double savedScale = circleRadius;
  double savedOffsetY = 0;
  double savedCardW = cardW0;
  double savedCardH = cardH0;

  /// 保存的每张卡的角度（用于洗牌动画结束后保持随机位置）
  List<double> savedCardAngles = [];

  /// 保存环形牌阵的最终状态
  void saveCircleState({
    required double scale,
    required double offsetY,
    required double cardW,
    required double cardH,
    List<double>? cardAngles,
  }) {
    savedScale = scale;
    savedOffsetY = offsetY;
    savedCardW = cardW;
    savedCardH = cardH;
    if (cardAngles != null) {
      savedCardAngles = cardAngles;
    }
    hasSavedCircleState.value = true;
  }

  /// 卡牌初始尺寸
  static const double cardW0 = 60.0;
  static const double cardH0 = 80.0;

  /// 卡牌最终尺寸
  static const double cardW1 = 120.0;
  static const double cardH1 = 160.0;

  // ==================== 常量 ====================

  /// 扇形总角度（度）
  static const double fanAngle = 120.0;

  /// 可见卡片数量
  static const int visibleCards = 11;

  /// 圆环放大系数
  static const double circleExpandScale = 1.5;

  /// 卡牌尺寸
  static const double thumbW = 60.0; // 缩略图宽度
  static const double thumbH = 80.0; // 缩略图高度
  static const double fanCardW = 120.0; // 扇形卡宽度
  static const double fanCardH = 160.0; // 扇形卡高度
  static const double maxCardW = 300.0; // 放大最大宽度
  static const double maxCardH = 400.0; // 放大最大高度
  static const double fourDrawSpacing = 60.0; // 四卡连抽槽位间距

  /// 四卡连抽模式下的标签
  static const List<String> fourDrawLabels = ['当下', '卡点', '破局', '理想'];

  // ==================== 卡组数据 ====================

  /// 基础卡总数
  static const int baseDeckCount = 88;

  /// 复原卡总数
  static const int recoveryDeckCount = 99;

  /// 特殊卡ID
  static const List<int> specialCardIds = [39, 40, 41];

  // ==================== 方法 ====================

  /// 选择卡组（仅选择，不开始洗牌）
  void selectDeck(int deck) {
    selectedDeck.value = deck;
    // 保留 includeSpecial 的当前设置，不强制重置
    // 重建卡组时会根据 includeSpecial 决定是否包含特殊卡
    _rebuildCards();

    drawnCardSets.clear();
    currentCards.clear();
    selectedCardIndex.value = null;
    flyStartPositions.clear();

    // 回到整齐堆叠状态，让用户从洗牌开始玩
    phase.value = CardohPhase.select;
  }

  /// 开始洗牌动画
  void startShuffle() {
    if (selectedDeck.value == null) {
      // 如果没有选择卡组，弹出选择对话框
      switchDeck();
      return;
    }
    phase.value = CardohPhase.shuffling;
  }

  /// 洗牌完成，进入扇形
  void onShuffleComplete() {
    // 对 fanDisplayCards 进行真正的 Fisher-Yates 洗牌
    // 这是模拟真实洗牌的核心：洗牌后卡牌的排列顺序是随机的
    final cards = fanDisplayCards.toList();
    final random = Random();
    for (int i = cards.length - 1; i > 0; i--) {
      final j = random.nextInt(i + 1);
      final temp = cards[i];
      cards[i] = cards[j];
      cards[j] = temp;
    }
    fanDisplayCards.value = cards;

    // 重建 remainingCards（未抽的卡也重新随机）
    remainingCards.value = List.from(fanDisplayCards);

    phase.value = CardohPhase.fan;
  }

  /// 点击扇形中的卡
  void onFanCardTap(int cardId, Offset cardCenter) {
    // 四卡连抽模式：取消四槽模式
    if (fourDrawMode.value) {
      cancelFourDraw();
      return;
    }

    // 只要不在飞行动画中，就可以抽卡（无论是 fan 还是 viewing 阶段）
    if (isFlying.value) return;
    if (remainingCards.isEmpty) return;
    if (!remainingCards.contains(cardId)) return; // 确保这张卡还在剩余卡里

    // 记录飞行起点（不立即移除卡牌，等飞行完成后再移除）
    flyStartPositions.clear();
    flyStartPositions.add(cardCenter);

    // 设置当前卡（用于飞行动画显示）
    currentCards.value = [cardId];

    // 标记飞行状态
    isFlying.value = true;
    flyProgress.value = 0.0;
  }

  /// 飞行动画完成
  void onFlyComplete() {
    // 从剩余卡中移除飞出去的卡
    if (currentCards.isNotEmpty) {
      remainingCards.remove(currentCards.first);
    }

    // 如果在四卡连抽模式
    if (fourDrawMode.value) {
      isFlying.value = false;
      flyProgress.value = 0.0;

      // 获取当前飞向的槽位索引
      final slotIdx = currentFlyToSlot.value;
      if (slotIdx != null) {
        // 将卡牌添加到四卡列表
        fourDrawCards.add(currentCards.first);
        filledSlots.add(slotIdx);
        currentFlyToSlot.value = null;
      }

      // 检查是否4张都抽完了
      if (fourDrawCards.length >= 4) {
        // 四卡连抽完成，需要按位置顺序(0,1,2,3)重新排列后添加到已抽卡记录
        final slotToCard = <int, int>{};
        for (int i = 0; i < filledSlots.length && i < fourDrawCards.length; i++) {
          slotToCard[filledSlots[i]] = fourDrawCards[i];
        }
        // 按位置顺序排列：[0]=当下, [1]=卡点, [2]=破局, [3]=理想
        final orderedCards = [
          slotToCard[0] ?? slotToCard.values.first,
          slotToCard[1] ?? slotToCard.values.first,
          slotToCard[2] ?? slotToCard.values.first,
          slotToCard[3] ?? slotToCard.values.first,
        ];
        drawnCardSets.add(List.from(orderedCards));

        // 重置四卡连抽状态（这会清空fourDrawCards, filledSlots等，但不影响currentCards）
        resetFourDrawState();

        // 先设置当前卡，再进入查看模式
        currentCards.value = orderedCards;

        // 进入查看模式，显示全部4张
        phase.value = CardohPhase.viewing;
        selectedCardIndex.value = null;
      }
      // 如果还没抽完4张，继续等待用户点击剩余槽位
    } else {
      // 普通单卡模式
      isFlying.value = false;
      flyProgress.value = 0.0;

      // 添加到已抽卡记录
      drawnCardSets.add(List.from(currentCards));

      // 进入查看模式
      phase.value = CardohPhase.viewing;
      selectedCardIndex.value = 0;
    }
  }

  /// 四卡连抽 - 进入四槽等待模式
  void drawFourCards() {
    if (phase.value != CardohPhase.fan && phase.value != CardohPhase.viewing) return;
    if (isFlying.value) return;
    if (remainingCards.length < 4) return;
    // 已经在四卡连抽模式中：取消当前的四槽模式（作废）
    if (fourDrawMode.value) {
      cancelFourDraw();
    }

    // 重置四卡状态
    resetFourDrawState();

    // 进入四卡连抽模式
    fourDrawMode.value = true;
    currentCards.clear();
    selectedCardIndex.value = null;

    // 计算槽位在屏幕上的位置（2x2网格）
    // 必须与 _buildMultiCardGrid 的计算方式完全一致，避免跳动
    final screenSize = MediaQuery.of(Get.context!).size;
    const cardW = fanCardW; // 120
    const cardH = fanCardH; // 160
    const spacing = fourDrawSpacing; // 60
    final gridW = cardW * 2 + spacing;
    final gridH = cardH * 2 + spacing + 30; // 加30用于标签高度（与_buildMultiCardGrid一致）

    // 左上角起始位置（与_buildMultiCardGrid一致）
    final startX = (screenSize.width - gridW) / 2;
    final startY = (screenSize.height - gridH) / 2 - 160; // 与_buildMultiCardGrid完全一致

    // 四个槽位的中心坐标（与_buildMultiCardGrid的位置计算一致）
    // 布局：[0] [1]
    //       [2] [3]
    final positions = <Offset>[
      Offset(startX + cardW / 2, startY + cardH / 2 + 30), // 左上（+30是标签高度）
      Offset(startX + cardW + spacing + cardW / 2, startY + cardH / 2 + 30), // 右上
      Offset(startX + cardW / 2, startY + cardH + spacing + cardH / 2 + 30), // 左下
      Offset(startX + cardW + spacing + cardW / 2, startY + cardH + spacing + cardH / 2 + 30), // 右下
    ];

    slotPositions.value = positions;
  }

  /// 点击槽位
  void onSlotClicked(int slotIndex) {
    // 必须在四卡连抽模式
    if (!fourDrawMode.value) return;
    // 不能在飞行中
    if (isFlying.value) return;
    // 这个槽位已经被填充了
    if (filledSlots.contains(slotIndex)) return;
    // 剩余卡不够了
    if (remainingCards.isEmpty) return;

    // 随机选1张
    final random = Random();
    final remainingCopy = List<int>.from(remainingCards);
    final idx = random.nextInt(remainingCopy.length);
    final selectedCard = remainingCopy.removeAt(idx);

    // 更新剩余卡
    remainingCards.value = remainingCopy;

    // 设置当前卡
    currentCards.value = [selectedCard];

    // 计算飞行起点：卡牌在环形上的实际位置
    final allCards = fanDisplayCards;
    final cardIdx = allCards.indexOf(selectedCard);
    Offset startPos;

    if (cardIdx >= 0) {
      // 卡牌在环形上的角度
      final angle = (2 * pi * cardIdx / allCards.length) - pi / 2 + circleRotation.value;
      final x = Get.width / 2 + cos(angle) * savedScale;
      final y = savedOffsetY + sin(angle) * savedScale;
      startPos = Offset(x, y);
    } else {
      // 兜底：使用扇形圆心
      startPos = Offset(Get.width / 2, fanCircleCenterY);
    }

    // 记录飞行起点
    flyStartPositions.clear();
    flyStartPositions.add(startPos);

    // 记录目标槽位
    currentFlyToSlot.value = slotIndex;

    // 标记飞行状态
    isFlying.value = true;
    flyProgress.value = 0.0;
  }

  /// 重置四卡连抽状态
  void resetFourDrawState() {
    fourDrawMode.value = false;
    fourDrawCards.clear();
    filledSlots.clear();
    slotPositions.clear();
    currentFlyToSlot.value = null;
    // 注意：不清理 currentCards，因为四卡连抽完成后需要用它来显示
  }

  /// 取消四卡连抽（当用户执行其他操作时调用）
  void cancelFourDraw() {
    if (!fourDrawMode.value) return;

    // 重置 phase 和 currentCards，确保后续单卡抽卡能正常执行
    phase.value = CardohPhase.fan;
    currentCards.clear();

    resetFourDrawState();
  }

  /// 点击查看已抽卡组
  void viewDrawnSet(int setIndex) {
    // 四槽模式下不允许查看已抽卡组
    if (fourDrawMode.value) return;
    if (setIndex < 0 || setIndex >= drawnCardSets.length) return;

    final cards = drawnCardSets[setIndex];
    currentCards.value = List.from(cards);

    if (cards.length == 1) {
      selectedCardIndex.value = 0;
    } else {
      selectedCardIndex.value = null; // 多卡显示全部
    }

    phase.value = CardohPhase.viewing;
  }

  /// 选择某张卡（查看模式下）
  void selectCard(int index) {
    if (index < 0 || index >= currentCards.length) return;
    selectedCardIndex.value = index;
  }

  /// 清除选择
  void clearSelection() {
    selectedCardIndex.value = null;
  }

  /// 返回扇形
  void backToFan() {
    currentCards.clear();
    selectedCardIndex.value = null;
    flyStartPositions.clear();
    // 重置四卡连抽状态
    resetFourDrawState();
    phase.value = CardohPhase.fan;
  }

  /// 重新开始
  void resetAll() {
    // 清空已抽的卡，恢复所有卡到剩余卡
    drawnCardSets.clear();
    currentCards.clear();
    selectedCardIndex.value = null;
    flyStartPositions.clear();
    isFlying.value = false;
    flyProgress.value = 0.0;

    // 重置四卡连抽状态（重要：防止幽灵UI）
    resetFourDrawState();

    // 重建剩余卡（所有卡都可抽）
    final drawnIds = <int>{};
    remainingCards.value = fanDisplayCards.where((id) => !drawnIds.contains(id)).toList();

    // 回到整齐堆叠状态，和初始选择卡组后一样
    phase.value = CardohPhase.select;
  }

  /// 打开设置对话框
  void showSettingsDialog() {
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        backgroundColor: const Color(0xFFE0F7FA),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 标题
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFF2A2A4E),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  '基础卡特殊卡设置',
                  style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 20),
              // 三张特殊卡并排显示
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _SpecialCardItem(cardId: 39, deckType: 1),
                  _SpecialCardItem(cardId: 40, deckType: 1),
                  _SpecialCardItem(cardId: 41, deckType: 1),
                ],
              ),
              const SizedBox(height: 16),
              // 包含特殊卡开关
              Obx(() => Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: const Color(0xFF80CBC4)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text('包含特殊卡', style: TextStyle(color: Color(0xFF2A2A4E), fontSize: 14)),
                        const SizedBox(width: 8),
                        Switch(
                          value: includeSpecial.value,
                          onChanged: (v) {
                            includeSpecial.value = v;
                            _rebuildCards();
                          },
                          activeTrackColor: const Color(0xFF80CBC4),
                        ),
                      ],
                    ),
                  )),
              const SizedBox(height: 16),
              // 关闭按钮
              TextButton(
                onPressed: () => Get.back(),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF2A2A4E),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text('关闭', style: TextStyle(color: Colors.white)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 重建卡组（当设置改变时）
  void _rebuildCards() {
    if (selectedDeck.value == null) return;

    int totalCards = selectedDeck.value == 1 ? baseDeckCount : recoveryDeckCount;

    // 重新生成卡组
    final allCards = List.generate(totalCards, (i) => i + 1);

    if (selectedDeck.value == 1 && !includeSpecial.value) {
      allCards.removeWhere((id) => specialCardIds.contains(id));
    }

    fanDisplayCards.value = allCards;

    // 重建剩余卡（保留未抽的）
    final drawnIds = drawnCardSets.expand((s) => s).toSet();
    remainingCards.value = allCards.where((id) => !drawnIds.contains(id)).toList();
  }

  /// 切换卡组
  void switchDeck() {
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        backgroundColor: const Color(0xFFE0F7FA),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFF2A2A4E),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  '选择卡组',
                  style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 20),
              // 基础卡选项（动态显示卡数量）
              Obx(() {
                final isBase = selectedDeck.value == 1;
                final baseCount =
                    isBase ? (includeSpecial.value ? baseDeckCount : baseDeckCount - specialCardIds.length) : baseDeckCount - specialCardIds.length;
                final subtitle = isBase ? (includeSpecial.value ? '共 $baseDeckCount 张（含特殊卡）' : '共 $baseCount 张（不含特殊卡）') : '共 $baseCount 张（不含特殊卡）';
                return _DeckOption(
                  title: '基础卡',
                  subtitle: subtitle,
                  selected: isBase,
                  onTap: () {
                    Get.back();
                    selectDeck(1); // 清空一切，回到整齐堆叠状态
                  },
                );
              }),
              const SizedBox(height: 12),
              // 复原卡选项
              Obx(() => _DeckOption(
                    title: '复原卡',
                    subtitle: '共 $recoveryDeckCount 张',
                    selected: selectedDeck.value == 2,
                    onTap: () {
                      Get.back();
                      selectDeck(2); // 清空一切，回到整齐堆叠状态
                    },
                  )),
              const SizedBox(height: 20),
              TextButton(
                onPressed: () => Get.back(),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text('取消', style: TextStyle(color: Color(0xFF2A2A4E))),
                ),
              ),
            ],
          ),
        ),
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
}

/// 卡组选项
class _DeckOption extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool selected;
  final VoidCallback onTap;

  const _DeckOption({
    required this.title,
    required this.subtitle,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFF80CBC4).withValues(alpha: 0.3) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected ? const Color(0xFF80CBC4) : Colors.grey[300]!,
            width: selected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              selected ? Icons.check_circle : Icons.circle_outlined,
              color: selected ? const Color(0xFF80CBC4) : Colors.grey[400],
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: Color(0xFF2A2A4E),
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(color: Colors.grey[600], fontSize: 12),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// 特殊卡缩略图项（60x80）
class _SpecialCardItem extends StatelessWidget {
  final int cardId;
  final int deckType;

  const _SpecialCardItem({required this.cardId, required this.deckType});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 60,
          height: 80,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.2),
                blurRadius: 4,
                offset: const Offset(1, 2),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.asset(
              'assets/images/card_oh/$deckType/${cardId.toString().padLeft(2, '0')}.jpg',
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                color: Colors.grey[400],
                child: Center(
                  child: Text(
                    cardId.toString(),
                    style: const TextStyle(color: Colors.white, fontSize: 20),
                  ),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          '第 $cardId 号',
          style: const TextStyle(color: Color(0xFF2A2A4E), fontSize: 12),
        ),
      ],
    );
  }
}

/// ============================================================
/// 主视图
/// ============================================================
class CardohView extends StatelessWidget {
  const CardohView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(CardohCtrl());

    return Container(
      color: const Color(0xFFE0F7FA),
      child: LayoutBuilder(
        builder: (context, constraints) {
          return Stack(
            fit: StackFit.expand,
            children: [
              // 主内容
              Obx(() => _buildContent(controller)),
              // 右侧工具条
              Positioned(
                right: 16,
                top: 100,
                bottom: 200,
                child: _FloatingToolbar(controller: controller),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildContent(CardohCtrl controller) {
    switch (controller.phase.value) {
      case CardohPhase.select:
        // 首次进入或重置后：显示整齐堆叠的卡牌
        return _StackedCardsView(controller: controller);
      case CardohPhase.shuffling:
        return _ShufflePage(controller: controller);
      case CardohPhase.fan:
      case CardohPhase.viewing:
        return _MainContent(controller: controller);
    }
  }
}

/// ============================================================
/// 整齐堆叠的卡牌视图（初始状态）
/// ============================================================
class _StackedCardsView extends StatelessWidget {
  final CardohCtrl controller;

  const _StackedCardsView({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // 显示整齐堆叠的卡牌（可点击）
          Obx(() => GestureDetector(
                onTap: controller.selectedDeck.value != null ? () => controller.startShuffle() : null,
                child: _buildStackedDeck(),
              )),
          const SizedBox(height: 32),
          // 提示文字
          Obx(() {
            if (controller.selectedDeck.value == null) {
              return const Text(
                '请点击右侧工具栏选择卡组',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.black45,
                ),
              );
            }
            return const Text(
              '点击卡牌堆开始洗牌',
              style: TextStyle(
                fontSize: 16,
                color: Colors.black45,
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildStackedDeck() {
    if (controller.selectedDeck.value == null) {
      // 没有选择卡组时，显示默认的堆叠效果
      return _buildCardStack(null, 12);
    }
    // 根据选择的卡组显示对应数量的堆叠
    final deckType = controller.selectedDeck.value!;
    final cardCount = controller.fanDisplayCards.isEmpty
        ? 12 // 首次进入时显示默认堆叠
        : (controller.fanDisplayCards.length > 20 ? 20 : controller.fanDisplayCards.length);
    return _buildCardStack(deckType, cardCount);
  }

  Widget _buildCardStack(int? deckType, int count) {
    // 整齐堆叠的卡牌效果，尺寸 60x80
    return SizedBox(
      width: 60,
      height: 80,
      child: Stack(
        children: List.generate(count.clamp(0, 12), (index) {
          // 越在下面的卡偏移越小，创造整齐堆叠效果
          final offset = index * 0.3;
          return Positioned(
            left: offset,
            top: offset,
            child: Container(
              width: 60 - offset,
              height: 80 - offset * 1.2,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(6),
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFFB2DFDB), // 比背景 E0F7FA 深一点
                    Color(0xFF80CBC4),
                  ],
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.2),
                    blurRadius: 2,
                    offset: Offset(1 - offset * 0.1, 2 - offset * 0.15),
                  ),
                ],
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.5),
                  width: 1,
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}

/// ============================================================
/// 洗牌动画页面
/// ============================================================
class _ShufflePage extends StatefulWidget {
  final CardohCtrl controller;

  const _ShufflePage({required this.controller});

  @override
  State<_ShufflePage> createState() => _ShufflePageState();
}

class _ShufflePageState extends State<_ShufflePage> with TickerProviderStateMixin {
  late AnimationController _shuffleCtrl; // 洗牌散开动画
  late AnimationController _moveCtrl; // 环形移动动画（3秒）
  late Animation<double> _scaleAnim; // 放大动画
  late Animation<double> _offsetYAnim; // 下移动画
  late Animation<double> _cardWAnim; // 卡牌宽度动画
  late Animation<double> _cardHAnim; // 卡牌高度动画

  late List<_CardTarget> _cardTargets;

  @override
  void initState() {
    super.initState();

    _generateCardTargets();

    // 洗牌散开动画：每张卡0.1秒，总时长 = 卡数 * 0.1秒
    final totalCards = widget.controller.fanDisplayCards.length;
    final shuffleDurationMs = (totalCards * 0.1 * 1000).toInt();
    _shuffleCtrl = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: shuffleDurationMs),
    );

    // 环形移动动画：3秒
    _moveCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3000),
    );

    // 放大动画：半径从240到400，即400/240=1.667
    _scaleAnim = Tween<double>(
      begin: CardohCtrl.circleRadius,
      end: CardohCtrl.expandedCircleRadius,
    ).animate(CurvedAnimation(parent: _moveCtrl, curve: Curves.easeInOut));

    // 下移动画：从屏幕中央到最终位置
    _offsetYAnim = Tween<double>(
      begin: widget.controller.initialCircleCenterY,
      end: widget.controller.finalCircleCenterY,
    ).animate(CurvedAnimation(parent: _moveCtrl, curve: Curves.easeInOut));

    // 卡牌宽度动画：60 -> 120
    _cardWAnim = Tween<double>(
      begin: CardohCtrl.cardW0,
      end: CardohCtrl.cardW1,
    ).animate(CurvedAnimation(parent: _moveCtrl, curve: Curves.easeInOut));

    // 卡牌高度动画：80 -> 160
    _cardHAnim = Tween<double>(
      begin: CardohCtrl.cardH0,
      end: CardohCtrl.cardH1,
    ).animate(CurvedAnimation(parent: _moveCtrl, curve: Curves.easeInOut));

    // 洗牌完成后暂停1秒，然后执行移动动画
    _shuffleCtrl.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        Future.delayed(const Duration(seconds: 1), () {
          if (mounted) {
            _moveCtrl.forward();
          }
        });
      }
    });

    // 移动完成后进入扇形（但保持显示环形牌阵）
    _moveCtrl.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        if (mounted) {
          // 保存圆环的视觉状态（尺寸和位置）
          widget.controller.saveCircleState(
            scale: _scaleAnim.value,
            offsetY: _offsetYAnim.value,
            cardW: _cardWAnim.value,
            cardH: _cardHAnim.value,
          );
          // 执行真正的随机洗牌（Fisher-Yates）并进入扇形阶段
          widget.controller.onShuffleComplete();
        }
      }
    });

    _shuffleCtrl.forward();
  }

  void _generateCardTargets() {
    final totalCards = widget.controller.fanDisplayCards.length;
    final random = Random();

    // 卡牌位置均匀分布在圆环上
    // 角度从顶部(-π/2)开始，顺时针均匀分布
    final targetAngles = List.generate(
      totalCards,
      (i) => (2 * pi * i / totalCards) - pi / 2,
    );

    // 随机延迟（0.05~0.15秒），错开飞行时间
    final delays = List.generate(
      totalCards,
      (_) => 0.05 + random.nextDouble() * 0.10,
    );

    _cardTargets = List.generate(totalCards, (i) {
      // 每张卡在环形上的目标角度（均匀分布）
      final targetAngle = targetAngles[i];

      // 飞行方向：从中心向目标点飞去
      final flyAngle = targetAngle;

      // 每张卡随机延迟
      final delay = delays[i];

      // 最终旋转角度：卡牌指向圆心（垂直于半径方向）
      final finalRotation = targetAngle + pi / 2;

      // 初始旋转角度：0（牌堆是整齐叠放的，没有角度）
      const initialRotation = 0.0;

      return _CardTarget(
        id: widget.controller.fanDisplayCards[i],
        startX: 0.0,
        startY: 0.0,
        flyAngle: flyAngle,
        flyDistance: CardohCtrl.circleRadius,
        delay: delay,
        initialRotation: initialRotation,
        finalRotation: finalRotation,
      );
    });
  }

  @override
  void dispose() {
    _shuffleCtrl.dispose();
    _moveCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: AnimatedBuilder(
        animation: Listenable.merge([_shuffleCtrl, _moveCtrl]),
        builder: (context, child) {
          return CustomPaint(
            size: Size(MediaQuery.of(context).size.width, MediaQuery.of(context).size.height),
            painter: _ShufflePainter(
              shuffleProgress: _shuffleCtrl.value,
              moveProgress: _moveCtrl.value,
              scale: _scaleAnim.value,
              offsetY: _offsetYAnim.value,
              cardW: _cardWAnim.value,
              cardH: _cardHAnim.value,
              cardTargets: _cardTargets,
              centerX: MediaQuery.of(context).size.width / 2,
            ),
          );
        },
      ),
    );
  }
}

/// 单张卡牌的目标位置数据
class _CardTarget {
  final int id;
  final double startX; // 飞行起点X（中心）
  final double startY; // 飞行起点Y（中心）
  final double flyAngle; // 飞行方向角度
  final double flyDistance; // 飞行距离（半径）
  final double delay; // 延迟开始动画的时间
  final double initialRotation; // 初始旋转角度
  final double finalRotation; // 最终旋转角度（卡牌指向圆心）

  _CardTarget({
    required this.id,
    required this.startX,
    required this.startY,
    required this.flyAngle,
    required this.flyDistance,
    required this.delay,
    required this.initialRotation,
    required this.finalRotation,
  });
}

/// 洗牌动画画家
class _ShufflePainter extends CustomPainter {
  final double shuffleProgress; // 散开进度 0.0~1.0
  final double moveProgress; // 移动进度 0.0~1.0
  final double scale; // 当前半径
  final double offsetY; // 圆心Y位置
  final double cardW; // 当前卡牌宽度
  final double cardH; // 当前卡牌高度
  final List<_CardTarget> cardTargets;
  final double centerX; // 屏幕中心X

  _ShufflePainter({
    required this.shuffleProgress,
    required this.moveProgress,
    required this.scale,
    required this.offsetY,
    required this.cardW,
    required this.cardH,
    required this.cardTargets,
    required this.centerX,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final total = cardTargets.length;

    // 计算当前时间（秒）
    final currentTime = shuffleProgress * total * 0.1;

    for (int i = 0; i < cardTargets.length; i++) {
      final target = cardTargets[i];

      // 每张卡飞行0.1秒，依次进行
      // 卡i在时间 t_i 到 t_i+0.1 飞行
      final flyStartTime = i * 0.1;
      final flyEndTime = flyStartTime + 0.1;

      double cardProgress;
      if (shuffleProgress <= 0) {
        // 动画刚开始，所有卡都在中心
        cardProgress = 0.0;
      } else if (currentTime < flyStartTime) {
        // 还没开始，停留在中心
        cardProgress = 0.0;
      } else if (currentTime >= flyEndTime) {
        // 已经飞完
        cardProgress = 1.0;
      } else {
        // 飞行中
        cardProgress = (currentTime - flyStartTime) / 0.1;
      }

      final curved = Curves.easeOut.transform(cardProgress);

      // 目标点在环形上的坐标
      final targetX = cos(target.flyAngle) * scale;
      final targetY = sin(target.flyAngle) * scale;

      // 当前位置：从中心点插值到目标点
      final currentX = centerX + targetX * curved;
      final currentY = offsetY + targetY * curved;

      // 旋转角度：从初始角度插值到最终角度
      final currentRotation = target.initialRotation + (target.finalRotation - target.initialRotation) * curved;

      // 绘制卡牌（统一深色背面）
      final rect = Rect.fromCenter(
        center: Offset(currentX, currentY),
        width: cardW,
        height: cardH,
      );

      // 渐变画笔（比背景 E0F7FA 深一点）
      final gradientPaint = Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFB2DFDB),
            Color(0xFF80CBC4),
          ],
        ).createShader(rect)
        ..style = PaintingStyle.fill;

      canvas.save();
      canvas.translate(currentX, currentY);
      canvas.rotate(currentRotation);
      canvas.translate(-currentX, -currentY);

      // 卡牌矩形
      final rrect = RRect.fromRectAndRadius(rect, const Radius.circular(8));
      canvas.drawRRect(rrect, gradientPaint);

      // 卡牌边框
      final borderPaint = Paint()
        ..color = Colors.white.withValues(alpha: 0.5)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5;
      canvas.drawRRect(rrect, borderPaint);

      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant _ShufflePainter oldDelegate) {
    return oldDelegate.shuffleProgress != shuffleProgress ||
        oldDelegate.moveProgress != moveProgress ||
        oldDelegate.scale != scale ||
        oldDelegate.offsetY != offsetY ||
        oldDelegate.cardW != cardW ||
        oldDelegate.cardH != cardH;
  }
}

/// 环形上的单张卡
class _CircleCard extends StatelessWidget {
  final int deckType;
  final double cardW;
  final double cardH;

  const _CircleCard({
    required this.deckType,
    required this.cardW,
    required this.cardH,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: cardW,
      height: cardH,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFB2DFDB), // 比背景 E0F7FA 深一点
            Color(0xFF80CBC4),
          ],
        ),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.5),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 4,
            offset: const Offset(2, 2),
          ),
        ],
      ),
    );
  }
}

/// ============================================================
/// 主内容区域（扇形 + 已抽卡栏）
/// ============================================================
class _MainContent extends StatelessWidget {
  final CardohCtrl controller;

  const _MainContent({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // 顶部已抽卡缩略图栏（_DrawnCardsBar 内部已有 Obx）
        _DrawnCardsBar(controller: controller),
        // 中间区域
        Expanded(
          child: Stack(
            children: [
              // 扇形牌阵（始终在底层，viewing时半透明）
              _FanCardView(controller: controller),
              // 四槽按钮或飞行中的卡（中间层）
              Obx(() {
                // 四槽模式 或 飞行中时显示
                if (!controller.fourDrawMode.value && !controller.isFlying.value) {
                  return const SizedBox.shrink();
                }
                return _FlyingCardsView(controller: controller);
              }),
              // 查看已抽卡（顶层）
              Obx(() {
                // 必须等飞行动画结束后才显示（非四槽模式且viewing阶段）
                if (controller.phase.value != CardohPhase.viewing || controller.isFlying.value || controller.fourDrawMode.value) {
                  return const SizedBox.shrink();
                }
                // 必须引用这些变量以确保 Obx 监听它们的变化
                controller.currentCards.length;
                controller.selectedCardIndex.value;
                return _ViewingCardsView(controller: controller);
              }),
            ],
          ),
        ),
      ],
    );
  }
}

/// ============================================================
/// 顶部已抽卡缩略图栏
/// ============================================================
class _DrawnCardsBar extends StatelessWidget {
  final CardohCtrl controller;

  const _DrawnCardsBar({required this.controller});

  @override
  Widget build(BuildContext context) {
    // 直接在 Obx 内访问响应式状态
    return Obx(() {
      final isEmpty = controller.drawnCardSets.isEmpty;

      if (isEmpty) {
        return Container(
          height: 80,
          color: const Color(0xFFB2DFDB).withValues(alpha: 0.5),
          child: const Center(
            child: Text(
              '已抽卡将显示在这里',
              style: TextStyle(color: Colors.black38, fontSize: 14),
            ),
          ),
        );
      }

      return Container(
        height: 80,
        color: const Color(0xFFB2DFDB).withValues(alpha: 0.9),
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
          itemCount: controller.drawnCardSets.length,
          itemBuilder: (context, index) {
            final cards = controller.drawnCardSets[index];
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: GestureDetector(
                onTap: () => controller.viewDrawnSet(index),
                child: _CardSetThumbnail(
                  cardIds: cards,
                  deckType: controller.selectedDeck.value ?? 1,
                ),
              ),
            );
          },
        ),
      );
    });
  }
}

/// 卡组缩略图（单卡或四卡拼合）
class _CardSetThumbnail extends StatelessWidget {
  final List<int> cardIds;
  final int deckType;

  const _CardSetThumbnail({
    required this.cardIds,
    required this.deckType,
  });

  @override
  Widget build(BuildContext context) {
    const double w = CardohCtrl.thumbW; // 60
    const double h = CardohCtrl.thumbH; // 80

    if (cardIds.length == 1) {
      // 单卡：显示完整缩略图
      return _buildSingleThumbnail(cardIds[0], w, h);
    } else {
      // 多卡：2x2拼合
      return _buildMultiThumbnail(cardIds.take(4).toList(), w, h);
    }
  }

  Widget _buildSingleThumbnail(int cardId, double w, double h) {
    return Container(
      width: w,
      height: h,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(6),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 4,
            offset: const Offset(1, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(6),
        child: Image.asset(
          'assets/images/card_oh/$deckType/${cardId.toString().padLeft(2, '0')}.jpg',
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => Container(
            color: Colors.grey[400],
            child: Center(
              child: Text(
                cardId.toString(),
                style: const TextStyle(color: Colors.white, fontSize: 16),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMultiThumbnail(List<int> ids, double w, double h) {
    final halfW = w / 2;
    final halfH = h / 2;

    return Container(
      width: w,
      height: h,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(6),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 4,
            offset: const Offset(1, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(6),
        child: Stack(
          children: [
            for (int i = 0; i < ids.length && i < 4; i++)
              Positioned(
                left: (i % 2) * halfW,
                top: (i ~/ 2) * halfH,
                width: halfW,
                height: halfH,
                child: Image.asset(
                  'assets/images/card_oh/$deckType/${ids[i].toString().padLeft(2, '0')}.jpg',
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(color: Colors.grey[400]),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// ============================================================
/// 扇形牌阵视图
/// ============================================================
class _FanCardView extends StatefulWidget {
  final CardohCtrl controller;

  const _FanCardView({required this.controller});

  @override
  State<_FanCardView> createState() => _FanCardViewState();
}

class _FanCardViewState extends State<_FanCardView> with SingleTickerProviderStateMixin {
  late PageController _pageController;
  late AnimationController _entryAnimCtrl;

  // 旋转相关状态
  double _lastAngle = 0.0;
  bool _isDragging = false;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(viewportFraction: 0.3);
    _entryAnimCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    _entryAnimCtrl.forward();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _entryAnimCtrl.dispose();
    super.dispose();
  }

  /// 计算手指相对于圆心的角度（使用全局坐标）
  double _computeAngle(Offset globalPosition, Offset circleCenter) {
    final dx = globalPosition.dx - circleCenter.dx;
    final dy = globalPosition.dy - circleCenter.dy;
    return atan2(dy, dx);
  }

  @override
  Widget build(BuildContext context) {
    final controller = widget.controller;

    // 扇形区域始终保持可交互
    // 已抽的卡已经在各自的构建方法中被设置为透明+不可点击
    // 注意：必须监听 remainingCards 否则抽卡后UI不会更新
    return Obx(() {
      // 引用 remainingCards 和 circleRotation 以确保 Obx 能监听它们的变化
      // ignore: unnecessary_statements - 这些引用用于强制监听
      controller.remainingCards.length;
      controller.circleRotation.value;
      final content = controller.hasSavedCircleState.value ? _buildCircleView(controller) : _buildFanView(controller);

      return content;
    });
  }

  Widget _buildCircleView(CardohCtrl controller) {
    final screenW = MediaQuery.of(context).size.width;
    final allCards = controller.fanDisplayCards;
    final remaining = controller.remainingCards;
    // 圆心位置（使用固定的扇形圆心Y，不受动画调整影响）
    final circleCenterY = controller.fanCircleCenterY;

    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onPanStart: (details) {
        // 计算手指位置相对于圆心的角度
        final globalPos = details.globalPosition;
        final circleCenter = Offset(screenW / 2, circleCenterY);
        _lastAngle = _computeAngle(globalPos, circleCenter);
        _isDragging = true;
      },
      onPanUpdate: (details) {
        if (!_isDragging) return;
        final globalPos = details.globalPosition;
        final circleCenter = Offset(screenW / 2, circleCenterY);
        final currentAngle = _computeAngle(globalPos, circleCenter);
        final delta = currentAngle - _lastAngle;
        controller.circleRotation.value += delta;
        _lastAngle = currentAngle;
      },
      onPanEnd: (_) {
        _isDragging = false;
      },
      child: Stack(
        children: [
          // 环形上的卡牌（基于 fanDisplayCards，显示所有卡）
          // fanDisplayCards 的顺序已经是随机的（通过 Fisher-Yates 洗牌）
          // 卡牌位置均匀分布在圆环上
          ...List.generate(allCards.length, (i) {
            final cardId = allCards[i];
            final isDrawn = !remaining.contains(cardId);
            // 均匀分布的角度
            final baseAngle = (2 * pi * i / allCards.length) - pi / 2;
            final angle = baseAngle + controller.circleRotation.value;
            final scale = controller.savedScale;
            // 使用固定的扇形圆心Y
            final circleCenterY = controller.fanCircleCenterY;

            final x = screenW / 2 + cos(angle) * scale;
            final y = circleCenterY + sin(angle) * scale;

            // 旋转角度：卡牌指向圆心
            final rotation = angle + pi / 2;

            return Positioned(
              left: x - controller.savedCardW / 2,
              top: y - controller.savedCardH / 2,
              child: IgnorePointer(
                ignoring: isDrawn,
                child: Opacity(
                  opacity: isDrawn ? 0.0 : 1.0,
                  child: GestureDetector(
                    onTap: isDrawn
                        ? null
                        : () {
                            // 获取卡牌中心位置
                            final cardCenter = Offset(x, y);
                            controller.onFanCardTap(cardId, cardCenter);
                          },
                    child: Transform.rotate(
                      angle: rotation,
                      child: _CircleCard(
                        deckType: controller.selectedDeck.value ?? 1,
                        cardW: controller.savedCardW,
                        cardH: controller.savedCardH,
                      ),
                    ),
                  ),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildFanView(CardohCtrl controller) {
    final cards = controller.remainingCards;

    if (cards.isEmpty) {
      return const Center(
        child: Text(
          '暂无剩余卡牌',
          style: TextStyle(color: Colors.black45, fontSize: 16),
        ),
      );
    }

    final pageCount = (cards.length / CardohCtrl.visibleCards).ceil();

    return Column(
      children: [
        // 剩余数量
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Text(
            '剩余 ${cards.length} 张',
            style: const TextStyle(color: Colors.black54, fontSize: 14),
          ),
        ),
        // 扇形区域
        Expanded(
          child: Center(
            child: SizedBox(
              height: 220,
              child: PageView.builder(
                controller: _pageController,
                itemCount: pageCount,
                itemBuilder: (context, pageIndex) {
                  return _buildFanRow(cards, pageIndex);
                },
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFanRow(List<int> allCards, int pageIndex) {
    const cardW = CardohCtrl.fanCardW; // 120
    const cardH = CardohCtrl.fanCardH; // 160
    const totalAngle = CardohCtrl.fanAngle * pi / 180;
    const startAngle = -totalAngle / 2;

    final startIdx = pageIndex * CardohCtrl.visibleCards;
    final endIdx = min(startIdx + CardohCtrl.visibleCards, allCards.length);
    final pageCards = allCards.sublist(startIdx, endIdx);

    return AnimatedBuilder(
      animation: _entryAnimCtrl,
      builder: (context, child) {
        return SizedBox(
          width: 350,
          height: 220,
          child: Stack(
            alignment: Alignment.center,
            children: List.generate(pageCards.length, (i) {
              final progress = pageCards.length > 1 ? i / (pageCards.length - 1) : 0.5;
              final angle = startAngle + progress * totalAngle;

              // 计算卡片位置
              const radius = 120.0;
              final x = sin(angle + pi / 2) * radius;
              final y = cos(angle) * 25;

              // 入场动画
              final entryProgress = (_entryAnimCtrl.value - i * 0.05).clamp(0.0, 1.0);
              final entryScale = Curves.easeOut.transform(entryProgress);
              final entryOpacity = entryProgress;

              // 缩放从 0.5 到 1.0
              final scale = 0.5 + 0.5 * entryScale;

              return Positioned(
                top: 110 - y - cardH / 2 * scale,
                left: 175 + x - cardW / 2 * scale,
                child: Opacity(
                  opacity: entryOpacity,
                  child: Transform.scale(
                    scale: scale,
                    child: _FanCard(
                      cardId: pageCards[i],
                      deckType: widget.controller.selectedDeck.value ?? 1,
                      onTap: (center) {
                        widget.controller.onFanCardTap(pageCards[i], center);
                      },
                    ),
                  ),
                ),
              );
            }),
          ),
        );
      },
    );
  }
}

/// 扇形中的单张卡
class _FanCard extends StatelessWidget {
  final int cardId;
  final int deckType;
  final Function(Offset) onTap;

  const _FanCard({
    required this.cardId,
    required this.deckType,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    const cardW = CardohCtrl.fanCardW;
    const cardH = CardohCtrl.fanCardH;

    return GestureDetector(
      onTapUp: (details) {
        final box = context.findRenderObject() as RenderBox?;
        if (box != null) {
          final pos = box.localToGlobal(Offset.zero);
          final center = Offset(
            pos.dx + cardW / 2,
            pos.dy + cardH / 2,
          );
          onTap(center);
        }
      },
      child: Container(
        width: cardW,
        height: cardH,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.3),
              blurRadius: 12,
              offset: const Offset(3, 5),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: Image.asset(
            'assets/images/card_oh/$deckType/${cardId.toString().padLeft(2, '0')}.jpg',
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => Container(
              color: Colors.grey[400],
              child: Center(
                child: Text(
                  cardId.toString(),
                  style: const TextStyle(color: Colors.white, fontSize: 24),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// ============================================================
/// 飞行中的卡视图
/// ============================================================
class _FlyingCardsView extends StatefulWidget {
  final CardohCtrl controller;

  const _FlyingCardsView({required this.controller});

  @override
  State<_FlyingCardsView> createState() => _FlyingCardsViewState();
}

class _FlyingCardsViewState extends State<_FlyingCardsView> with SingleTickerProviderStateMixin {
  late AnimationController _flyCtrl;
  bool _wasFlying = false; // 追踪之前的飞行状态
  bool _isAnimating = false; // 防止重复启动动画

  @override
  void initState() {
    super.initState();
    _flyCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    _flyCtrl.addListener(() {
      widget.controller.flyProgress.value = _flyCtrl.value;
    });
  }

  @override
  void didUpdateWidget(_FlyingCardsView oldWidget) {
    super.didUpdateWidget(oldWidget);
    // 检测 isFlying 从 false 变为 true 的时刻
    final isFlying = widget.controller.isFlying.value;
    if (!_wasFlying && isFlying && !_isAnimating) {
      // isFlying 从 false 变为 true，启动动画
      _startFlyingAnimation();
    }
    _wasFlying = isFlying;
  }

  void _startFlyingAnimation() {
    if (!mounted || _isAnimating) return;
    _isAnimating = true;
    _flyCtrl.reset(); // 重置动画状态
    _flyCtrl.forward().then((_) {
      if (!mounted) return;
      _isAnimating = false;
      widget.controller.onFlyComplete();
    });
  }

  @override
  void dispose() {
    _flyCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // 使用 Obx 监听所有响应式变量变化
    return Obx(() {
      final fourDrawMode = widget.controller.fourDrawMode.value;
      final isFlying = widget.controller.isFlying.value;
      final currentFlySlot = widget.controller.currentFlyToSlot.value;
      final flyProgress = widget.controller.flyProgress.value;
      final flyingCards = widget.controller.currentCards.toList();
      // 关键：访问响应式变量以触发 Obx 重建
      final filledSlots = widget.controller.filledSlots.toList();
      final fourDrawCards = widget.controller.fourDrawCards.toList();
      final deckType = widget.controller.selectedDeck.value ?? 1;
      final labels = CardohCtrl.fourDrawLabels;

      // 强制读取响应式变量以确保 Obx 追踪变化
      widget.controller.filledSlots.length;
      widget.controller.fourDrawCards.length;
      widget.controller.currentCards.length; // 强制追踪 currentCards

      // 四卡连抽模式：显示槽位按钮
      if (fourDrawMode) {
        return _buildSlotButtons(
          isFlying: isFlying,
          currentFlySlot: currentFlySlot,
          flyProgress: flyProgress,
          flyingCards: flyingCards,
          filledSlots: filledSlots,
          fourDrawCards: fourDrawCards,
          deckType: deckType,
          labels: labels,
        );
      }

      final cards = widget.controller.currentCards;
      final starts = widget.controller.flyStartPositions;
      final screenSize = MediaQuery.of(context).size;
      final cardCount = cards.length;

      // 在 Obx 中也检测 isFlying 变化，确保单卡模式下动画能启动
      // didUpdateWidget 可能不会被调用（widget 没有变化时），所以需要双重保险
      if (!_wasFlying && isFlying && !_isAnimating && cardCount > 0) {
        _startFlyingAnimation();
      }
      _wasFlying = isFlying;

      // 计算目标位置：单卡居中，四卡2x2网格
      final targetPositions = _calculateTargetPositions(screenSize, cardCount);

      return Stack(
        children: List.generate(cardCount, (index) {
          if (index >= starts.length) return const SizedBox.shrink();

          // 交错动画：每张卡延迟
          final delay = index * 0.15;
          final cardProgress = ((flyProgress - delay) / (1 - delay * cardCount * 0.5)).clamp(0.0, 1.0);
          final eased = Curves.easeOut.transform(cardProgress);

          // 起点是卡中心位置，需要转为左上角
          final startPos = starts[index];
          final startLeft = startPos.dx - CardohCtrl.fanCardW / 2;
          final startTop = startPos.dy - CardohCtrl.fanCardH / 2;

          // 目标位置：如果指定了槽位，飞向槽位位置
          Offset target;
          final slotIdx = widget.controller.currentFlyToSlot.value;
          if (slotIdx != null && index == 0 && widget.controller.slotPositions.length > slotIdx) {
            // 飞向指定槽位
            final slotPos = widget.controller.slotPositions[slotIdx];
            target = Offset(slotPos.dx - CardohCtrl.fanCardW / 2, slotPos.dy - CardohCtrl.fanCardH / 2);
          } else {
            target = targetPositions[index];
          }

          final targetLeft = target.dx;
          final targetTop = target.dy;

          // 插值计算当前位置（使用左上角）
          final x = startLeft + (targetLeft - startLeft) * eased;
          final y = startTop + (targetTop - startTop) * eased;

          // 缩放动画：单卡 1.0->1.5，四卡 1.0->1.0（保持原尺寸）
          final scale = cardCount == 1 ? (1.0 + 0.5 * eased) : 1.0;

          // 翻牌动画：在飞行后期进行（当 eased > 0.6 时开始翻）
          final flipProgress = ((eased - 0.6) / 0.4).clamp(0.0, 1.0);

          return Positioned(
            left: x,
            top: y,
            child: Transform.scale(
              scale: scale,
              child: _FlyingCard(
                cardId: cards[index],
                deckType: deckType,
                flipProgress: flipProgress,
              ),
            ),
          );
        }),
      );
    });
  }

  /// 构建四槽按钮界面
  /// 构建四槽按钮界面（接收参数确保响应式追踪正确）
  Widget _buildSlotButtons({
    required bool isFlying,
    required int? currentFlySlot,
    required double flyProgress,
    required List<int> flyingCards,
    required List<int> filledSlots,
    required List<int> fourDrawCards,
    required int deckType,
    required List<String> labels,
  }) {
    // 创建槽位索引到卡片ID的映射
    final slotToCard = <int, int>{};
    for (int i = 0; i < filledSlots.length && i < fourDrawCards.length; i++) {
      slotToCard[filledSlots[i]] = fourDrawCards[i];
    }

    // 获取飞行中的卡（如果当前槽位正在飞行）
    int? flyingCardId;
    if (isFlying && currentFlySlot != null && flyingCards.isNotEmpty) {
      flyingCardId = flyingCards.first;
    }

    // 计算位置（与 _buildMultiCardGrid 一致）
    final screenSize = MediaQuery.of(Get.context!).size;
    const cardW = CardohCtrl.fanCardW; // 120
    const cardH = CardohCtrl.fanCardH; // 160
    const spacing = CardohCtrl.fourDrawSpacing; // 60
    final gridW = cardW * 2 + spacing;
    final gridH = cardH * 2 + spacing + 30; // 加30用于标签高度
    final startX = (screenSize.width - gridW) / 2;
    final startY = (screenSize.height - gridH) / 2 - 160;

    // 2x2位置（与_buildMultiCardGrid完全一致）
    final positions = [
      Offset(startX, startY + 30), // 考虑标签高度
      Offset(startX + cardW + spacing, startY + 30),
      Offset(startX, startY + cardH + spacing + 30),
      Offset(startX + cardW + spacing, startY + cardH + spacing + 30),
    ];

    return Stack(
      children: [
        // 标签层（放在对应槽位的正上方，与槽位位置计算一致）
        ...List.generate(4, (i) {
          // 使用与槽位相同的布局逻辑来确定标签位置
          // positions[i] 是槽位位置，标签放在槽位上方
          final labelLeft = positions[i].dx + cardW / 2 - 30;
          final labelTop = positions[i].dy - 28; // 标签在槽位上方28px
          return Positioned(
            left: labelLeft,
            top: labelTop,
            child: SizedBox(
              width: 60,
              child: Text(
                labels[i],
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          );
        }),
        // 槽位/卡片层
        ...List.generate(4, (index) {
          final cardId = slotToCard[index];
          final pos = positions[index];

          // 如果这个槽位正在飞行中，显示飞行中的卡
          if (isFlying && currentFlySlot == index && flyingCardId != null) {
            // 计算飞行中的卡位置（从扇形中心飞到槽位）
            final startPos = Offset(screenSize.width / 2, widget.controller.fanCircleCenterY);
            final targetPos = pos;
            final eased = Curves.easeOut.transform(flyProgress);
            final x = startPos.dx + (targetPos.dx - startPos.dx) * eased;
            final y = startPos.dy + (targetPos.dy - startPos.dy) * eased;
            // 翻牌动画
            final flipProgress = ((eased - 0.6) / 0.4).clamp(0.0, 1.0);

            return Positioned(
              left: x,
              top: y,
              child: _FlyingCard(
                cardId: flyingCardId,
                deckType: deckType,
                flipProgress: flipProgress,
              ),
            );
          }

          // 已填充的卡或空槽
          return Positioned(
            left: pos.dx,
            top: pos.dy,
            child: cardId != null
                ? _SlotFilledCard(
                    cardId: cardId,
                    deckType: deckType,
                    onTap: () {
                      // 点击放大查看（全屏显示）
                      _showZoomedCardDialog(context, cardId, deckType);
                    },
                  )
                : _buildEmptySlot(index),
          );
        }),
      ],
    );
  }

  /// 构建空槽位按钮
  Widget _buildEmptySlot(int slotIndex) {
    return GestureDetector(
      onTap: () {
        widget.controller.onSlotClicked(slotIndex);
      },
      child: Container(
        width: CardohCtrl.fanCardW,
        height: CardohCtrl.fanCardH,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.white, width: 2),
          color: Colors.transparent,
        ),
      ),
    );
  }

  /// 显示放大的卡（全屏对话框，支持缩放和拖动）
  void _showZoomedCardDialog(BuildContext context, int cardId, int deckType) {
    showDialog(
      context: context,
      barrierColor: Colors.black54,
      builder: (ctx) => _ZoomableCardDialog(
        cardId: cardId,
        deckType: deckType,
      ),
    );
  }

  /// 计算目标位置：单卡居中，四卡2x2网格
  List<Offset> _calculateTargetPositions(Size screenSize, int cardCount) {
    if (cardCount == 1) {
      // 单卡：居中
      return [
        Offset(
          screenSize.width / 2 - CardohCtrl.maxCardW / 2,
          screenSize.height / 2 - CardohCtrl.maxCardH / 2,
        ),
      ];
    } else {
      // 四卡：2x2网格居中
      const cardW = CardohCtrl.fanCardW; // 120
      const cardH = CardohCtrl.fanCardH; // 160
      const spacing = 20.0;
      final gridW = cardW * 2 + spacing;
      final gridH = cardH * 2 + spacing;
      final startX = (screenSize.width - gridW) / 2;
      final startY = (screenSize.height - gridH) / 2;

      return [
        Offset(startX, startY), // 左上
        Offset(startX + cardW + spacing, startY), // 右上
        Offset(startX, startY + cardH + spacing), // 左下
        Offset(startX + cardW + spacing, startY + cardH + spacing), // 右下
      ];
    }
  }
}

/// 飞行中的单张卡（带翻牌动画）
class _FlyingCard extends StatefulWidget {
  final int cardId;
  final int deckType;
  final double flipProgress; // 0.0=背面, 1.0=正面

  const _FlyingCard({
    required this.cardId,
    required this.deckType,
    this.flipProgress = 0.0,
  });

  @override
  State<_FlyingCard> createState() => _FlyingCardState();
}

class _FlyingCardState extends State<_FlyingCard> {
  @override
  Widget build(BuildContext context) {
    // 3D翻牌效果
    final angle = widget.flipProgress * pi;
    final transform = Matrix4.identity()
      ..setEntry(3, 2, 0.001) // perspective
      ..rotateY(angle);

    // 根据角度判断显示哪一面
    final showFront = widget.flipProgress > 0.5;

    return Transform(
      transform: transform,
      alignment: Alignment.center,
      child: Container(
        width: CardohCtrl.fanCardW,
        height: CardohCtrl.fanCardH,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.4),
              blurRadius: 20,
              offset: const Offset(5, 10),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: showFront
              ? Image.asset(
                  'assets/images/card_oh/${widget.deckType}/${widget.cardId.toString().padLeft(2, '0')}.jpg',
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    color: Colors.grey[400],
                    child: Center(
                      child: Text(
                        widget.cardId.toString(),
                        style: const TextStyle(color: Colors.white, fontSize: 24),
                      ),
                    ),
                  ),
                )
              : _buildCardBack(),
        ),
      ),
    );
  }

  Widget _buildCardBack() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFB2DFDB), // 比背景 E0F7FA 深一点
            Color(0xFF80CBC4),
          ],
        ),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.5),
          width: 1.5,
        ),
      ),
      child: const Center(
        child: Text(
          '?',
          style: TextStyle(
            color: Color(0xFF00695C), // 深青色
            fontSize: 48,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}

/// 四槽模式已填充的卡（支持点击放大）
class _SlotFilledCard extends StatelessWidget {
  final int cardId;
  final int deckType;
  final VoidCallback onTap;

  const _SlotFilledCard({
    required this.cardId,
    required this.deckType,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: CardohCtrl.fanCardW,
        height: CardohCtrl.fanCardH,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.3),
              blurRadius: 10,
              offset: const Offset(3, 5),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: Image.asset(
            'assets/images/card_oh/$deckType/${cardId.toString().padLeft(2, '0')}.jpg',
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => Container(
              color: Colors.grey[400],
              child: Center(
                child: Text(
                  cardId.toString(),
                  style: const TextStyle(color: Colors.white, fontSize: 24),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// ============================================================
/// 四槽模式下放大查看的对话框（支持缩放和拖动）
/// ============================================================
class _ZoomableCardDialog extends StatefulWidget {
  final int cardId;
  final int deckType;

  const _ZoomableCardDialog({
    required this.cardId,
    required this.deckType,
  });

  @override
  State<_ZoomableCardDialog> createState() => _ZoomableCardDialogState();
}

class _ZoomableCardDialogState extends State<_ZoomableCardDialog> {
  double _scale = 1.0;
  double _baseScale = 1.0;
  double _offsetX = 0.0;
  double _offsetY = 0.0;
  double _baseOffsetX = 0.0;
  double _baseOffsetY = 0.0;

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    const cardW = CardohCtrl.maxCardW; // 300
    const cardH = CardohCtrl.maxCardH; // 400
    final baseX = (screenSize.width - cardW) / 2;
    final baseY = (screenSize.height - cardH) / 2 - 100;
    final finalX = baseX + _offsetX;
    final finalY = baseY + _offsetY;

    return GestureDetector(
      onScaleStart: (details) {
        _baseScale = _scale;
        _baseOffsetX = _offsetX;
        _baseOffsetY = _offsetY;
      },
      onScaleUpdate: (details) {
        setState(() {
          _scale = (_baseScale * details.scale).clamp(1.0, 3.0);
          _offsetX = _baseOffsetX + details.focalPointDelta.dx;
          _offsetY = _baseOffsetY + details.focalPointDelta.dy;
        });
      },
      onTap: () => Navigator.of(context).pop(),
      child: Container(
        color: Colors.transparent,
        child: Stack(
          children: [
            // 放大的卡
            Positioned(
              left: finalX,
              top: finalY,
              child: Transform.scale(
                scale: _scale,
                child: Container(
                  width: cardW,
                  height: cardH,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.5),
                        blurRadius: 20,
                        offset: const Offset(5, 10),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.asset(
                      'assets/images/card_oh/${widget.deckType}/${widget.cardId.toString().padLeft(2, '0')}.jpg',
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        color: Colors.grey[400],
                        child: Center(
                          child: Text(
                            widget.cardId.toString(),
                            style: const TextStyle(color: Colors.white, fontSize: 48),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            // 关闭提示
            Positioned(
              bottom: 50,
              left: 0,
              right: 0,
              child: const Text(
                '点击任意处关闭',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white70, fontSize: 14),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// ============================================================
/// 查看已抽卡视图（放大/缩小/拖动）
/// ============================================================
class _ViewingCardsView extends StatefulWidget {
  final CardohCtrl controller;

  const _ViewingCardsView({required this.controller});

  @override
  State<_ViewingCardsView> createState() => _ViewingCardsViewState();
}

class _ViewingCardsViewState extends State<_ViewingCardsView> {
  // 缩放和拖动状态
  double _pinchScale = 1.0;
  double _basePinchScale = 1.0;
  double _offsetX = 0.0;
  double _offsetY = 0.0;

  @override
  Widget build(BuildContext context) {
    // 使用 Obx 监听 currentCards 和 selectedCardIndex 的变化
    return Obx(() {
      final cards = widget.controller.currentCards;
      final selectedIdx = widget.controller.selectedCardIndex.value;
      final deckType = widget.controller.selectedDeck.value ?? 1;

      if (cards.isEmpty) return const SizedBox.shrink();

      // 单卡模式：始终显示300x400，支持拖放和缩放
      if (cards.length == 1) {
        return _buildSingleCardView(cards[0], deckType);
      }

      // 多卡模式：如果有选中的卡，显示放大的卡在其他卡之上
      if (selectedIdx != null && selectedIdx < cards.length) {
        return Stack(
          children: [
            // 背景：显示其他卡的小图
            _buildMultiCardGrid(cards, deckType, excludeIndex: selectedIdx),
            // 前景：放大的卡
            _buildZoomedCard(cards[selectedIdx], deckType),
          ],
        );
      }

      // 多卡网格视图
      return _buildMultiCardGrid(cards, deckType);
    });
  }

  /// 单卡视图：300x400居中，支持拖放和缩放
  Widget _buildSingleCardView(int cardId, int deckType) {
    final screenSize = MediaQuery.of(context).size;
    const cardW = CardohCtrl.maxCardW; // 300
    const cardH = CardohCtrl.maxCardH; // 400

    // 居中位置，向上偏移160px
    final baseX = (screenSize.width - cardW) / 2;
    final baseY = (screenSize.height - cardH) / 2 - 160;

    // 加上拖动偏移
    final finalX = baseX + _offsetX;
    final finalY = baseY + _offsetY;

    return Stack(
      children: [
        Positioned(
          left: finalX,
          top: finalY,
          child: GestureDetector(
            onScaleStart: (details) {
              _basePinchScale = _pinchScale;
            },
            onScaleUpdate: (details) {
              setState(() {
                _pinchScale = (_basePinchScale * details.scale).clamp(1.0, 2.5);
                _offsetX += details.focalPointDelta.dx;
                _offsetY += details.focalPointDelta.dy;
              });
            },
            onDoubleTap: () {
              // 双击重置
              setState(() {
                _pinchScale = 1.0;
                _basePinchScale = 1.0;
                _offsetX = 0.0;
                _offsetY = 0.0;
              });
            },
            child: Container(
              width: cardW * _pinchScale,
              height: cardH * _pinchScale,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.4),
                    blurRadius: 30,
                    offset: const Offset(5, 10),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.asset(
                  'assets/images/card_oh/$deckType/${cardId.toString().padLeft(2, '0')}.jpg',
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    color: Colors.grey[400],
                    child: Center(
                      child: Text(cardId.toString(), style: const TextStyle(color: Colors.white, fontSize: 32)),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  /// 多卡网格视图（2x2）：每张卡120x160，点击放大，带标签
  Widget _buildMultiCardGrid(List<int> cards, int deckType, {int? excludeIndex}) {
    final screenSize = MediaQuery.of(context).size;
    const cardW = CardohCtrl.fanCardW; // 120
    const cardH = CardohCtrl.fanCardH; // 160
    const spacing = CardohCtrl.fourDrawSpacing; // 60
    final labels = CardohCtrl.fourDrawLabels;
    final gridW = cardW * 2 + spacing;
    final gridH = cardH * 2 + spacing + 30; // 加30用于标签高度
    final startX = (screenSize.width - gridW) / 2;
    final startY = (screenSize.height - gridH) / 2 - 160;

    // 2x2位置（考虑标签高度）
    final positions = [
      Offset(startX, startY + 30), // 标签占30高度
      Offset(startX + cardW + spacing, startY + 30),
      Offset(startX, startY + cardH + spacing + 30),
      Offset(startX + cardW + spacing, startY + cardH + spacing + 30),
    ];

    return Stack(
      children: [
        // 标签层（与_buildSlotButtons一致的布局）
        ...List.generate(4, (i) {
          if (i >= cards.length) return const SizedBox.shrink();
          // 使用与卡片位置一致的计算方式
          final labelLeft = positions[i].dx + cardW / 2 - 30;
          final labelTop = positions[i].dy - 28; // 标签在卡片上方28px
          return Positioned(
            left: labelLeft,
            top: labelTop,
            child: SizedBox(
              width: 60,
              child: Text(
                labels[i],
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          );
        }),
        // 卡片层
        ...List.generate(cards.length, (i) {
          if (excludeIndex != null && i == excludeIndex) {
            return const SizedBox.shrink();
          }
          final pos = positions[i];
          return Positioned(
            left: pos.dx,
            top: pos.dy,
            child: GestureDetector(
              onTap: () {
                // 点击放大
                widget.controller.selectedCardIndex.value = i;
                setState(() {
                  _pinchScale = 1.0;
                  _basePinchScale = 1.0;
                  _offsetX = 0.0;
                  _offsetY = 0.0;
                });
              },
              child: Container(
                width: cardW,
                height: cardH,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.3),
                      blurRadius: 10,
                      offset: const Offset(3, 5),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.asset(
                    'assets/images/card_oh/$deckType/${cards[i].toString().padLeft(2, '0')}.jpg',
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      color: Colors.grey[400],
                      child: Center(
                        child: Text(cards[i].toString(), style: const TextStyle(color: Colors.white, fontSize: 24)),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        }),
      ],
    );
  }

  /// 放大的单卡（从多卡选中）：300x400，支持拖放缩放
  Widget _buildZoomedCard(int cardId, int deckType) {
    final screenSize = MediaQuery.of(context).size;
    const cardW = CardohCtrl.maxCardW; // 300
    const cardH = CardohCtrl.maxCardH; // 400

    final baseX = (screenSize.width - cardW) / 2;
    final baseY = (screenSize.height - cardH) / 2 - 160; // 向上偏移160px
    final finalX = baseX + _offsetX;
    final finalY = baseY + _offsetY;

    return Stack(
      children: [
        // 放大的卡（点击图片本身关闭）
        Positioned(
          left: finalX,
          top: finalY,
          child: GestureDetector(
            onScaleStart: (details) {
              _basePinchScale = _pinchScale;
            },
            onScaleUpdate: (details) {
              setState(() {
                _pinchScale = (_basePinchScale * details.scale).clamp(1.0, 2.5);
                _offsetX += details.focalPointDelta.dx;
                _offsetY += details.focalPointDelta.dy;
              });
            },
            onTap: () {
              // 点击图片本身关闭放大
              widget.controller.selectedCardIndex.value = null;
            },
            onDoubleTap: () {
              // 双击重置缩放
              setState(() {
                _pinchScale = 1.0;
                _basePinchScale = 1.0;
                _offsetX = 0.0;
                _offsetY = 0.0;
              });
            },
            child: Container(
              width: cardW * _pinchScale,
              height: cardH * _pinchScale,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.5),
                    blurRadius: 40,
                    offset: const Offset(5, 10),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.asset(
                  'assets/images/card_oh/$deckType/${cardId.toString().padLeft(2, '0')}.jpg',
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    color: Colors.grey[400],
                    child: Center(
                      child: Text(cardId.toString(), style: const TextStyle(color: Colors.white, fontSize: 32)),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// ============================================================
/// 右侧浮动工具条
/// ============================================================
class _FloatingToolbar extends StatelessWidget {
  final CardohCtrl controller;

  const _FloatingToolbar({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // 设置按钮（始终可用）
        _ToolbarButton(
          icon: Icons.settings,
          tooltip: '设置',
          onTap: () => controller.showSettingsDialog(),
        ),
        const SizedBox(height: 24),
        // 卡组选择（始终可用，切换卡组相当于重新开始）
        _ToolbarButton(
          icon: Icons.layers,
          tooltip: '卡组选择',
          onTap: () => controller.switchDeck(),
        ),
        const SizedBox(height: 24),
        // 重新开始（始终可用）
        _ToolbarButton(
          icon: Icons.refresh,
          tooltip: '重新开始',
          onTap: () => _showResetConfirm(context),
        ),
        const SizedBox(height: 24),
        // 洗牌（只在扇形阶段可用）
        Obx(() {
          final isDisabled = controller.phase.value != CardohPhase.fan;
          return _ToolbarButton(
            icon: Icons.shuffle,
            tooltip: '洗牌',
            enabled: !isDisabled,
            onTap: () => controller.startShuffle(),
          );
        }),
        const SizedBox(height: 24),
        // 四卡连抽（扇形/查看阶段且剩余卡>=4）
        Obx(() {
          final canDraw = controller.remainingCards.length >= 4 && (controller.phase.value == CardohPhase.fan || controller.phase.value == CardohPhase.viewing);
          return _ToolbarButton(
            icon: Icons.grid_view,
            tooltip: '四卡连抽',
            enabled: canDraw,
            onTap: () => _doFourDraw(context),
          );
        }),
      ],
    );
  }

  void _showResetConfirm(BuildContext context) {
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        backgroundColor: const Color(0xFFE0F7FA),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFF2A2A4E),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  '重新开始',
                  style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                '确定要重新开始吗？\n所有已抽卡将被清空。',
                textAlign: TextAlign.center,
                style: TextStyle(color: Color(0xFF2A2A4E), fontSize: 14),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  TextButton(
                    onPressed: () => Get.back(),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text('取消', style: TextStyle(color: Color(0xFF2A2A4E))),
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      Get.back();
                      controller.resetAll();
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                      decoration: BoxDecoration(
                        color: const Color(0xFF80CBC4),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text('确定', style: TextStyle(color: Color(0xFF2A2A4E), fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _doFourDraw(BuildContext context) {
    // 四卡连抽：控制器内部随机选卡并计算飞行起点
    controller.drawFourCards();
  }
}

/// 工具条按钮
class _ToolbarButton extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final bool enabled;
  final VoidCallback onTap;

  const _ToolbarButton({
    required this.icon,
    required this.tooltip,
    required this.onTap,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      preferBelow: false,
      child: InkWell(
        onTap: enabled ? onTap : null,
        borderRadius: BorderRadius.circular(30),
        child: Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            color: enabled ? Colors.white : Colors.white24,
            borderRadius: BorderRadius.circular(30),
          ),
          child: Icon(
            icon,
            color: enabled ? const Color(0xFF4DB6AC) : Colors.white38,
            size: 30,
          ),
        ),
      ),
    );
  }
}

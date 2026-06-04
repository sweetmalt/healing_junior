# OH卡算法文档

## 洗牌算法

### 核心目标
模拟真实洗牌后的卡牌乱序状态，确保每次洗牌后卡牌的排列顺序是真正随机的。

### Fisher-Yates 洗牌算法

**位置**：`CardohCtrl.onShuffleComplete()`（`lib/apps/card_oh.dart`）

**触发时机**：洗牌动画完成后

**算法实现**：
```dart
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
```

### 算法说明

**Fisher-Yates 洗牌**（又称 Knuth Shuffle）：
- 从列表末尾向前遍历
- 每次循环中，将当前元素与它之前（含）的任意一个元素交换
- 时间复杂度：O(n)
- 空间复杂度：O(n)（需要复制列表）
- **数学证明**：每个排列出现的概率相等，是真正的均匀随机洗牌

### 随机数来源

使用 `dart:math.Random()`：
- 系统级别的伪随机数生成器
- 基于 Mersenne Twister 算法
- 适合游戏级别的随机性需求

### 与显示动画的关系

**注意**：洗牌动画（`_ShufflePage`）中的 `_generateCardTargets()` 负责的是**视觉效果**：
- 卡牌从中心飞向圆周各点的动画
- 目标角度是随机分布的（`random.nextDouble() * 2 * pi`）
- 飞行延迟也是随机的（0.05~0.15秒错开）

**两层随机性**：
1. **数据层**（本算法）：卡牌在列表中的顺序随机
2. **表现层**（动画）：卡牌飞行的角度和时序随机

两者独立，确保视觉和逻辑都是随机的。

### 验证方法

每次洗牌后，`fanDisplayCards` 的顺序都是不同的。例如：
- 初始：`[1, 2, 3, 4, 5, ...]`
- 洗牌后：`[42, 17, 88, 3, 56, ...]`（随机排列）

### 为什么不每次抽卡都重新洗牌？

用户洗牌一次后，卡牌顺序固定，后续单抽或四连抽都是从这个顺序中**依次取出**：
- 单抽：从 `remainingCards` 头部取一张
- 四连抽：从 `remainingCards` 中随机取4张
- 重新开始：清空已抽卡，`remainingCards` 恢复完整列表
- 再次洗牌：重新执行 Fisher-Yates，得到新的随机排列

这符合真实卡牌游戏的逻辑：洗牌一次后，按顺序发牌。

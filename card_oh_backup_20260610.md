# card_oh.dart 寮€鍙戞垚鏋滃浠?

**澶囦唤鏃ユ湡**: 2026-06-10
**鏂囦欢璺緞**: `C:\z_project\healingai\healing_junior\lib\apps\card_oh.dart`
**鎬昏鏁?*: ~2900琛?

---

## 馃搵 寮€鍙戞垚鏋滄憳瑕?

### 1. 娲楃墝鍔ㄧ敾浼樺寲
- **鍒濆鍗″爢灏哄**: 60脳80 鈫?**90脳120**
- **娲楃墝鎻愮ず**: 鏂囧瓧鏀逛负 "鐐瑰嚮娲楃墝" 鎸夐挳锛堢櫧鑹插渾瑙掔煩褰?+ 闈掕壊鍥炬爣锛?
- **鏁ｅ紑鍔ㄧ敾**: 鍗＄墝浠?90脳120 缂╁皬鍒?60脳80
- **绉诲姩鍔ㄧ敾**: 鐜舰浠庡睆骞曚腑澶Щ鍔ㄥ埌涓嬫柟锛屽崱鐗屾斁澶у埌 120脳160

### 2. 鍥涘崱杩炴娊妯″紡
- **缁熶竴瑙﹀彂鏂瑰紡**: 鎵€鏈夋娊鍗℃搷浣滐紙鍗曞崱/鍥涘崱锛夐兘閫氳繃鐐瑰嚮鎵囧舰鍗¤Е鍙?
- **娴佺▼**: 鐐瑰嚮鍥涘崱鎸夐挳 鈫?鏄剧ず4涓Ы浣?2脳2缃戞牸) 鈫?鐐瑰嚮鎵囧舰鍗?鈫?椋炲悜妲戒綅 鈫?閲嶅4娆?鈫?瀹屾垚
- **妲戒綅鏍囩**: 褰撲笅銆佸崱鐐广€佺牬灞€銆佺悊鎯筹紙椤哄簭濉厖锛?
- **绌虹櫧妲戒綅**: 绾潤鎬佸崰浣嶇锛屾棤鐐瑰嚮浜や簰
- **宸插～鍏呮Ы浣?*: 鐐瑰嚮鍙斁澶ф煡鐪?

### 3. 椋炶鍔ㄧ敾浼樺寲
- **璧风偣浣嶇疆**: 浣跨敤鐢ㄦ埛瀹為檯鐐瑰嚮鐨勫崱鐨勪綅缃?
- **鍒濆濮挎€?*: 淇濇寔鎵囧舰涓殑鏃嬭浆瑙掑害
- **鏃嬭浆鍔ㄧ敾**: 浠庡垵濮嬭搴﹂€愭笎杩囨浮鍒版按骞?0搴?

---

## 馃敡 鍏抽敭浠ｇ爜鍙樻洿璁板綍

### 鎺у埗鍣ㄧ姸鎬佸彉閲?

```dart
/// 椋炶璧风偣浣嶇疆鍒楄〃
final flyStartPositions = <Offset>[].obs;

/// 椋炶璧风偣鏃嬭浆瑙掑害鍒楄〃锛堟柊澧烇級
final flyStartRotations = <double>[].obs;

/// 鍥涘崱杩炴娊妯″紡
final fourDrawMode = false.obs;

/// 鍥涘崱杩炴娊鐨?寮犲崱
final fourDrawCards = <int>[].obs;

/// 宸插～鍏呯殑妲戒綅绱㈠紩鍒楄〃
final filledSlots = <int>[].obs;

/// 妲戒綅鍧愭爣
final slotPositions = <Offset>[].obs;

/// 褰撳墠椋炲悜鐨勬Ы浣嶇储寮?
final currentFlyToSlot = Rxn<int>();
```

### 鏂规硶绛惧悕鍙樻洿

```dart
/// onFanCardTap 鏂板 cardRotation 鍙傛暟
void onFanCardTap(int cardId, Offset cardCenter, {double? cardRotation})
```

### 椋炶鍔ㄧ敾涓殑浣嶇疆璁＄畻锛堜慨澶嶏級

```dart
// 淇鍓嶏紙閿欒锛?
final x = startPos.dx + (targetPos.dx - startPos.dx) * eased;

// 淇鍚庯紙姝ｇ‘锛?
final startLeft = startPos.dx - cardW / 2;
final startTop = startPos.dy - cardH / 2;
final targetLeft = targetPos.dx - cardW / 2;
final targetTop = targetPos.dy - cardH / 2;
final x = startLeft + (targetLeft - startLeft) * eased;
```

---

## 馃搧 瀹屾暣浠ｇ爜

> 浠ヤ笅鏄?`card_oh.dart` 鐨勫畬鏁翠唬鐮佸浠斤細
`n```dart`nimport 'dart:math';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

/// ============================================================
/// 闃舵鏋氫妇
/// ============================================================
enum CardohPhase {
  select, // 閫夋嫨鍗＄粍
  shuffling, // 娲楃墝鍔ㄧ敾
  fan, // 鎵囧舰娴忚/鎶藉崱
  viewing, // 鏌ョ湅宸叉娊鍗?
}

/// ============================================================
/// 鎺у埗鍣?
/// ============================================================
class CardohCtrl extends GetxController {
  /// 棰勫姞杞界殑鍗¤儗鍥剧墖锛堢敤浜嶴hufflePainter锛?
  static ui.Image? cardBackImage;

  /// 鍔犺浇鍗¤儗鍥剧墖
  static Future<void> loadCardBackImage() async {
    if (cardBackImage != null) return;
    final bytes = await rootBundle.load('assets/images/card_one_bk.jpg');
    final codec = await ui.instantiateImageCodec(bytes.buffer.asUint8List());
    final frame = await codec.getNextFrame();
    cardBackImage = frame.image;
  }

  @override
  void onInit() {
    super.onInit();
    // 棰勫姞杞藉崱鑳屽浘鐗?
    loadCardBackImage();
    // 棣栨杩涘叆榛樿閫夋嫨鍩虹鍗?
    selectedDeck.value = 1;
    // 鍒濆鍖栧熀纭€鍗℃暟鎹?
    selectDeck(1);
  }

  // ==================== 缁熶竴鏁版嵁缁撴瀯 ====================

  /// 褰撳墠鏄剧ず鐨勫崱鍒楄〃锛堝彲浠ユ槸1-4寮犲崱锛?
  final currentCards = <int>[].obs;

  /// 閫変腑鐨勫崱鐨勭储寮曪紙null = 鏄剧ず鍏ㄩ儴缂╃暐鍥剧綉鏍硷級
  final selectedCardIndex = Rxn<int>();

  /// 鎵€鏈夊凡鎶藉崱鐨勮褰曪紙姣忔潯鏄竴缁勫崱ID锛?
  final drawnCardSets = <List<int>>[].obs;

  /// 鎵囧舰鏄剧ず鐢ㄧ殑瀹屾暣鍗″垪琛?
  final fanDisplayCards = <int>[].obs;

  /// 鍓╀綑鍙娊鐨勫崱鍒楄〃
  final remainingCards = <int>[].obs;

  /// 椋炶璧风偣浣嶇疆鍒楄〃锛堟瘡寮犲崱涓€涓捣鐐癸級
  final flyStartPositions = <Offset>[].obs;

  /// 椋炶璧风偣鏃嬭浆瑙掑害鍒楄〃锛堟瘡寮犲崱涓€涓搴︼紝鍗曚綅锛氬姬搴︼級
  final flyStartRotations = <double>[].obs;

  /// 褰撳墠闃舵
  final phase = CardohPhase.select.obs;

  /// 鏄惁鍖呭惈39/40/41鐗规畩鍗★紙浠呭熀纭€鍗℃湁鏁堬紝榛樿false锛?
  final includeSpecial = false.obs;

  /// 褰撳墠閫変腑鐨勫崱缁勶紙1=鍩虹鍗? 2=澶嶅師鍗★級
  final selectedDeck = Rxn<int>();

  /// 椋炶鍔ㄧ敾杩涘害 0.0~1.0
  final flyProgress = 0.0.obs;

  /// 鏄惁姝ｅ湪椋炶
  final isFlying = false.obs;

  // ==================== 鍥涘崱杩炴娊妯″紡 ====================

  /// 鍥涘崱杩炴娊妯″紡锛堢瓑寰呯敤鎴风偣鍑绘Ы浣嶏級
  final fourDrawMode = false.obs;

  /// 鍥涘崱杩炴娊鐨?寮犲崱锛堢敤浜庢渶缁堜竴璧峰姞鍏rawnCardSets锛?
  final fourDrawCards = <int>[].obs;

  /// 宸插～鍏呯殑妲戒綅绱㈠紩鍒楄〃
  final filledSlots = <int>[].obs;

  /// 妲戒綅鍧愭爣锛堝睆骞曚綅缃級锛岀敤浜庨琛岀粓鐐硅绠?
  final slotPositions = <Offset>[].obs;

  /// 褰撳墠椋炲悜鐨勬Ы浣嶇储寮曪紙鐢ㄤ簬椋炶缁堢偣璁＄畻锛?
  final currentFlyToSlot = Rxn<int>();

  // ==================== 鐜舰/鎵囧舰鍔ㄧ敾鍙傛暟 ====================

  /// 鍦嗙幆缂╂斁姣斾緥锛?.0=鍒濆锛?.0=鏀惧ぇ鍚庯級
  final circleScale = 1.0.obs;

  /// 鍦嗙幆鍨傜洿鍋忕Щ锛?=鍒濆锛屽悜涓婁负璐燂紝鍚戜笅涓烘锛?
  final circleOffsetY = 0.0.obs;

  /// 鍦嗙幆鏃嬭浆瑙掑害锛堝姬搴︼級锛岀敤浜庢粦鍔ㄦ帶鍒?
  final circleRotation = 0.0.obs;

  /// 鏁ｅ紑鍔ㄧ敾杩涘害锛?.0~1.0锛?
  final shuffleProgress = 0.0.obs;

  /// 绉诲姩鍔ㄧ敾杩涘害锛?.0~1.0锛?
  final moveProgress = 0.0.obs;

  /// 鍦嗙幆鍒濆鍗婂緞
  static const double circleRadius = 240.0;

  /// 鏀惧ぇ鍚庣殑鍦嗙幆鍗婂緞
  static const double expandedCircleRadius = 400.0;

  /// 鍦嗙幆鏈€缁堜綅缃紙鐢ㄤ簬鍔ㄧ敾缁堢偣锛夛細鍦嗗績Y = 灞忓箷楂樺害 + 400 - 240
  double get finalCircleCenterY => Get.height + 400 - 240;

  /// 鎵囧舰鍦嗗績Y锛堝浐瀹氬€硷紝涓嶅彈鍔ㄧ敾璋冩暣褰卞搷锛夛細鏁翠綋鍚戜笂鎻愬崌80px
  double get fanCircleCenterY => Get.height + 400 - 240 - 80;

  /// 鍦嗙幆鍒濆涓績Y锛堝睆骞曟涓ぎ锛?
  double get initialCircleCenterY => Get.height / 2;

  /// 鏄惁淇濆瓨浜嗙幆褰㈢姸鎬?
  final hasSavedCircleState = false.obs;

  /// 淇濆瓨鐨勭幆褰㈢姸鎬?
  double savedScale = circleRadius;
  double savedOffsetY = 0;
  double savedCardW = cardW0;
  double savedCardH = cardH0;

  /// 淇濆瓨鐨勬瘡寮犲崱鐨勮搴︼紙鐢ㄤ簬娲楃墝鍔ㄧ敾缁撴潫鍚庝繚鎸侀殢鏈轰綅缃級
  List<double> savedCardAngles = [];

  /// 淇濆瓨鐜舰鐗岄樀鐨勬渶缁堢姸鎬?
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

  /// 鍗＄墝鍒濆灏哄锛堢幆褰㈠崱鐗屽爢灏哄锛?
  static const double cardW0 = 60.0;
  static const double cardH0 = 80.0;

  /// 鍗＄墝鏈€缁堝昂瀵革紙鎵囧舰鍗″昂瀵革級
  static const double cardW1 = 120.0;
  static const double cardH1 = 160.0;

  /// 鍒濆鍗＄墝鍫嗗昂瀵革紙娲楃墝鍓嶇殑澶у崱锛?
  static const double stackedCardW = 90.0;
  static const double stackedCardH = 120.0;

  // ==================== 甯搁噺 ====================

  /// 鎵囧舰鎬昏搴︼紙搴︼級
  static const double fanAngle = 120.0;

  /// 鍙鍗＄墖鏁伴噺
  static const int visibleCards = 11;

  /// 鍦嗙幆鏀惧ぇ绯绘暟
  static const double circleExpandScale = 1.5;

  /// 鍗＄墝灏哄
  static const double thumbW = 60.0; // 缂╃暐鍥惧搴?
  static const double thumbH = 80.0; // 缂╃暐鍥鹃珮搴?
  static const double fanCardW = 120.0; // 鎵囧舰鍗″搴?
  static const double fanCardH = 160.0; // 鎵囧舰鍗￠珮搴?
  static const double maxCardW = 300.0; // 鏀惧ぇ鏈€澶у搴?
  static const double maxCardH = 400.0; // 鏀惧ぇ鏈€澶ч珮搴?
  static const double fourDrawSpacing = 60.0; // 鍥涘崱杩炴娊妲戒綅闂磋窛

  /// 鍥涘崱杩炴娊妯″紡涓嬬殑鏍囩
  static const List<String> fourDrawLabels = ['鐜扮姸', '鍗＄偣', '绐佺牬', '鐞嗘兂'];

  // ==================== 鍗＄粍鏁版嵁 ====================

  /// 鍩虹鍗℃€绘暟
  static const int baseDeckCount = 88;

  /// 澶嶅師鍗℃€绘暟
  static const int recoveryDeckCount = 99;

  /// 鐗规畩鍗D
  static const List<int> specialCardIds = [39, 40, 41];

  // ==================== 鏂规硶 ====================

  /// 閫夋嫨鍗＄粍锛堜粎閫夋嫨锛屼笉寮€濮嬫礂鐗岋級
  void selectDeck(int deck) {
    selectedDeck.value = deck;
    // 淇濈暀 includeSpecial 鐨勫綋鍓嶈缃紝涓嶅己鍒堕噸缃?
    // 閲嶅缓鍗＄粍鏃朵細鏍规嵁 includeSpecial 鍐冲畾鏄惁鍖呭惈鐗规畩鍗?
    _rebuildCards();

    drawnCardSets.clear();
    currentCards.clear();
    selectedCardIndex.value = null;
    flyStartPositions.clear();

    // 鍥炲埌鏁撮綈鍫嗗彔鐘舵€侊紝璁╃敤鎴蜂粠娲楃墝寮€濮嬬帺
    phase.value = CardohPhase.select;
  }

  /// 寮€濮嬫礂鐗屽姩鐢?
  void startShuffle() {
    if (selectedDeck.value == null) {
      // 濡傛灉娌℃湁閫夋嫨鍗＄粍锛屽脊鍑洪€夋嫨瀵硅瘽妗?
      switchDeck();
      return;
    }
    phase.value = CardohPhase.shuffling;
  }

  /// 娲楃墝瀹屾垚锛岃繘鍏ユ墖褰?
  void onShuffleComplete() {
    // 瀵?fanDisplayCards 杩涜鐪熸鐨?Fisher-Yates 娲楃墝
    // 杩欐槸妯℃嫙鐪熷疄娲楃墝鐨勬牳蹇冿細娲楃墝鍚庡崱鐗岀殑鎺掑垪椤哄簭鏄殢鏈虹殑
    final cards = fanDisplayCards.toList();
    final random = Random();
    for (int i = cards.length - 1; i > 0; i--) {
      final j = random.nextInt(i + 1);
      final temp = cards[i];
      cards[i] = cards[j];
      cards[j] = temp;
    }
    fanDisplayCards.value = cards;

    // 閲嶅缓 remainingCards锛堟湭鎶界殑鍗′篃閲嶆柊闅忔満锛?
    remainingCards.value = List.from(fanDisplayCards);

    phase.value = CardohPhase.fan;
  }

  /// 鐐瑰嚮鎵囧舰涓殑鍗?
  /// [cardCenter] 鍗＄墝涓績鍦ㄥ睆骞曚笂鐨勪綅缃?
  /// [cardRotation] 鍗＄墝鐨勬棆杞搴︼紙寮у害锛夛紝0琛ㄧず姘村钩锛宲i/2琛ㄧず鍨傜洿鎸囧悜灞忓箷涓嬫柟
  void onFanCardTap(int cardId, Offset cardCenter, {double? cardRotation}) {
    // 鍙涓嶅湪椋炶鍔ㄧ敾涓紝灏卞彲浠ユ娊鍗★紙鏃犺鏄?fan 杩樻槸 viewing 闃舵锛?
    if (isFlying.value) return;
    if (remainingCards.isEmpty) return;
    if (!remainingCards.contains(cardId)) return; // 纭繚杩欏紶鍗¤繕鍦ㄥ墿浣欏崱閲?

    // 鍥涘崱杩炴娊妯″紡锛氫负涓嬩竴涓┖妲戒綅鎶藉崱锛堟寜椤哄簭锛氬綋涓?鈫掑崱鐐?鈫掔獊鐮?鈫掔悊鎯?锛?
    if (fourDrawMode.value) {
      // 鎵惧埌涓嬩竴涓┖妲戒綅锛堟寜椤哄簭锛?
      int? nextSlot;
      for (int i = 0; i < 4; i++) {
        if (!filledSlots.contains(i)) {
          nextSlot = i;
          break;
        }
      }
      if (nextSlot == null) return; // 鎵€鏈夋Ы浣嶉兘婊′簡

      // 浣跨敤鐢ㄦ埛鐐瑰嚮鐨勫崱
      final selectedCard = cardId;

      // 鏇存柊鍓╀綑鍗★紙绉婚櫎閫変腑鐨勫崱锛?
      remainingCards.remove(selectedCard);

      // 璁剧疆褰撳墠鍗★紙鐢ㄤ簬椋炶鍔ㄧ敾鏄剧ず锛?
      currentCards.value = [selectedCard];

      // 璁板綍椋炶璧风偣锛堜粠鐐瑰嚮鐨勫崱浣嶇疆锛?
      flyStartPositions.clear();
      flyStartPositions.add(cardCenter);

      // 璁板綍椋炶璧风偣鏃嬭浆瑙掑害
      flyStartRotations.clear();
      flyStartRotations.add(cardRotation ?? 0.0);

      // 璁板綍鐩爣妲戒綅
      currentFlyToSlot.value = nextSlot;

      // 鏍囪椋炶鐘舵€?
      isFlying.value = true;
      flyProgress.value = 0.0;
      return;
    }

    // 鏅€氬崟鍗℃ā寮?
    // 璁板綍椋炶璧风偣锛堜笉绔嬪嵆绉婚櫎鍗＄墝锛岀瓑椋炶瀹屾垚鍚庡啀绉婚櫎锛?
    flyStartPositions.clear();
    flyStartPositions.add(cardCenter);

    // 璁板綍椋炶璧风偣鏃嬭浆瑙掑害
    flyStartRotations.clear();
    flyStartRotations.add(cardRotation ?? 0.0);

    // 璁剧疆褰撳墠鍗★紙鐢ㄤ簬椋炶鍔ㄧ敾鏄剧ず锛?
    currentCards.value = [cardId];

    // 鏍囪椋炶鐘舵€?
    isFlying.value = true;
    flyProgress.value = 0.0;
  }

  /// 椋炶鍔ㄧ敾瀹屾垚
  void onFlyComplete() {
    // 濡傛灉鍦ㄥ洓鍗¤繛鎶芥ā寮?
    if (fourDrawMode.value) {
      isFlying.value = false;
      flyProgress.value = 0.0;

      // 鑾峰彇褰撳墠椋炲悜鐨勬Ы浣嶇储寮?
      final slotIdx = currentFlyToSlot.value;
      if (slotIdx != null) {
        // 灏嗗崱鐗屾坊鍔犲埌鍥涘崱鍒楄〃
        fourDrawCards.add(currentCards.first);
        filledSlots.add(slotIdx);
        currentFlyToSlot.value = null;
      }

      // 妫€鏌ユ槸鍚?寮犻兘鎶藉畬浜?
      if (fourDrawCards.length >= 4) {
        // 鍥涘崱杩炴娊瀹屾垚锛岄渶瑕佹寜浣嶇疆椤哄簭(0,1,2,3)閲嶆柊鎺掑垪鍚庢坊鍔犲埌宸叉娊鍗¤褰?
        final slotToCard = <int, int>{};
        for (int i = 0; i < filledSlots.length && i < fourDrawCards.length; i++) {
          slotToCard[filledSlots[i]] = fourDrawCards[i];
        }
        // 鎸変綅缃『搴忔帓鍒楋細[0]=鐜扮姸, [1]=鍗＄偣, [2]=绐佺牬, [3]=鐞嗘兂
        final orderedCards = [
          slotToCard[0] ?? slotToCard.values.first,
          slotToCard[1] ?? slotToCard.values.first,
          slotToCard[2] ?? slotToCard.values.first,
          slotToCard[3] ?? slotToCard.values.first,
        ];
        drawnCardSets.add(List.from(orderedCards));

        // 閲嶇疆鍥涘崱杩炴娊鐘舵€侊紙杩欎細娓呯┖fourDrawCards, filledSlots绛夛紝浣嗕笉褰卞搷currentCards锛?
        resetFourDrawState();

        // 鍏堣缃綋鍓嶅崱锛屽啀杩涘叆鏌ョ湅妯″紡
        currentCards.value = orderedCards;

        // 杩涘叆鏌ョ湅妯″紡锛屾樉绀哄叏閮?寮?
        phase.value = CardohPhase.viewing;
        selectedCardIndex.value = null;
      }
      // 濡傛灉杩樻病鎶藉畬4寮狅紝缁х画绛夊緟鐢ㄦ埛鐐瑰嚮鎵囧舰
    } else {
      // 鏅€氬崟鍗℃ā寮忥細浠庡墿浣欏崱涓Щ闄ら鍑哄幓鐨勫崱
      if (currentCards.isNotEmpty) {
        remainingCards.remove(currentCards.first);
      }

      isFlying.value = false;
      flyProgress.value = 0.0;

      // 娣诲姞鍒板凡鎶藉崱璁板綍
      drawnCardSets.add(List.from(currentCards));

      // 杩涘叆鏌ョ湅妯″紡
      phase.value = CardohPhase.viewing;
      selectedCardIndex.value = 0;
    }
  }

  /// 鍥涘崱杩炴娊 - 杩涘叆鍥涙Ы绛夊緟妯″紡
  void drawFourCards() {
    if (phase.value != CardohPhase.fan && phase.value != CardohPhase.viewing) return;
    if (isFlying.value) return;
    if (remainingCards.length < 4) return;
    // 宸茬粡鍦ㄥ洓鍗¤繛鎶芥ā寮忎腑锛氬彇娑堝綋鍓嶇殑鍥涙Ы妯″紡锛堜綔搴燂級
    if (fourDrawMode.value) {
      cancelFourDraw();
    }

    // 閲嶇疆鍥涘崱鐘舵€?
    resetFourDrawState();

    // 杩涘叆鍥涘崱杩炴娊妯″紡
    fourDrawMode.value = true;
    currentCards.clear();
    selectedCardIndex.value = null;

    // 璁＄畻妲戒綅鍦ㄥ睆骞曚笂鐨勪綅缃紙2x2缃戞牸锛?
    // 蹇呴』涓?_buildMultiCardGrid 鐨勮绠楁柟寮忓畬鍏ㄤ竴鑷达紝閬垮厤璺冲姩
    final screenSize = MediaQuery.of(Get.context!).size;
    const cardW = fanCardW; // 120
    const cardH = fanCardH; // 160
    const spacing = fourDrawSpacing; // 60
    final gridW = cardW * 2 + spacing;
    final gridH = cardH * 2 + spacing + 30; // 鍔?0鐢ㄤ簬鏍囩楂樺害锛堜笌_buildMultiCardGrid涓€鑷达級

    // 宸︿笂瑙掕捣濮嬩綅缃紙涓巁buildMultiCardGrid涓€鑷达級
    final startX = (screenSize.width - gridW) / 2;
    final startY = (screenSize.height - gridH) / 2 - 160; // 涓巁buildMultiCardGrid瀹屽叏涓€鑷?

    // 鍥涗釜妲戒綅鐨勪腑蹇冨潗鏍囷紙涓巁buildMultiCardGrid鐨勪綅缃绠椾竴鑷达級
    // 甯冨眬锛歔0] [1]
    //       [2] [3]
    final positions = <Offset>[
      Offset(startX + cardW / 2, startY + cardH / 2 + 30), // 宸︿笂锛?30鏄爣绛鹃珮搴︼級
      Offset(startX + cardW + spacing + cardW / 2, startY + cardH / 2 + 30), // 鍙充笂
      Offset(startX + cardW / 2, startY + cardH + spacing + cardH / 2 + 30), // 宸︿笅
      Offset(startX + cardW + spacing + cardW / 2, startY + cardH + spacing + cardH / 2 + 30), // 鍙充笅
    ];

    slotPositions.value = positions;
  }

  /// 鐐瑰嚮妲戒綅锛堢敤浜庢煡鐪嬪凡濉厖鐨勫崱锛涚┖鐧芥Ы浣嶆棤浜や簰锛?
  void onSlotClicked(int slotIndex) {
    // 蹇呴』鍦ㄥ洓鍗¤繛鎶芥ā寮?
    if (!fourDrawMode.value) return;
    // 涓嶈兘鍦ㄩ琛屼腑
    if (isFlying.value) return;
    // 绌虹櫧妲戒綅鏃犱氦浜?
    if (!filledSlots.contains(slotIndex)) return;

    // 妲戒綅宸插～鍏咃細閫変腑璇ュ崱杩涜鏌ョ湅
    final cardIndex = filledSlots.indexOf(slotIndex);
    if (cardIndex >= 0 && cardIndex < fourDrawCards.length) {
      currentCards.value = [fourDrawCards[cardIndex]];
      selectedCardIndex.value = 0;
    }
  }

  /// 閲嶇疆鍥涘崱杩炴娊鐘舵€?
  void resetFourDrawState() {
    fourDrawMode.value = false;
    fourDrawCards.clear();
    filledSlots.clear();
    slotPositions.clear();
    currentFlyToSlot.value = null;
    // 娉ㄦ剰锛氫笉娓呯悊 currentCards锛屽洜涓哄洓鍗¤繛鎶藉畬鎴愬悗闇€瑕佺敤瀹冩潵鏄剧ず
  }

  /// 鍙栨秷鍥涘崱杩炴娊锛堝綋鐢ㄦ埛鎵ц鍏朵粬鎿嶄綔鏃惰皟鐢級
  void cancelFourDraw() {
    if (!fourDrawMode.value) return;

    // 閲嶇疆 phase 鍜?currentCards锛岀‘淇濆悗缁崟鍗℃娊鍗¤兘姝ｅ父鎵ц
    phase.value = CardohPhase.fan;
    currentCards.clear();

    resetFourDrawState();
  }

  /// 鐐瑰嚮鏌ョ湅宸叉娊鍗＄粍
  void viewDrawnSet(int setIndex) {
    // 鍥涙Ы妯″紡涓嬩笉鍏佽鏌ョ湅宸叉娊鍗＄粍
    if (fourDrawMode.value) return;
    if (setIndex < 0 || setIndex >= drawnCardSets.length) return;

    final cards = drawnCardSets[setIndex];
    currentCards.value = List.from(cards);

    if (cards.length == 1) {
      selectedCardIndex.value = 0;
    } else {
      selectedCardIndex.value = null; // 澶氬崱鏄剧ず鍏ㄩ儴
    }

    phase.value = CardohPhase.viewing;
  }

  /// 閫夋嫨鏌愬紶鍗★紙鏌ョ湅妯″紡涓嬶級
  void selectCard(int index) {
    if (index < 0 || index >= currentCards.length) return;
    selectedCardIndex.value = index;
  }

  /// 娓呴櫎閫夋嫨
  void clearSelection() {
    selectedCardIndex.value = null;
  }

  /// 杩斿洖鎵囧舰
  void backToFan() {
    currentCards.clear();
    selectedCardIndex.value = null;
    flyStartPositions.clear();
    // 閲嶇疆鍥涘崱杩炴娊鐘舵€?
    resetFourDrawState();
    phase.value = CardohPhase.fan;
  }

  /// 閲嶆柊寮€濮?
  void resetAll() {
    // 娓呯┖宸叉娊鐨勫崱锛屾仮澶嶆墍鏈夊崱鍒板墿浣欏崱
    drawnCardSets.clear();
    currentCards.clear();
    selectedCardIndex.value = null;
    flyStartPositions.clear();
    isFlying.value = false;
    flyProgress.value = 0.0;

    // 閲嶇疆鍥涘崱杩炴娊鐘舵€侊紙閲嶈锛氶槻姝㈠菇鐏礥I锛?
    resetFourDrawState();

    // 閲嶅缓鍓╀綑鍗★紙鎵€鏈夊崱閮藉彲鎶斤級
    final drawnIds = <int>{};
    remainingCards.value = fanDisplayCards.where((id) => !drawnIds.contains(id)).toList();

    // 鍥炲埌鏁撮綈鍫嗗彔鐘舵€侊紝鍜屽垵濮嬮€夋嫨鍗＄粍鍚庝竴鏍?
    phase.value = CardohPhase.select;
  }

  /// 鎵撳紑璁剧疆瀵硅瘽妗?
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
              // 鏍囬
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFF2A2A4E),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  '鍩虹鍗＄壒娈婂崱璁剧疆',
                  style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 20),
              // 涓夊紶鐗规畩鍗″苟鎺掓樉绀?
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _SpecialCardItem(cardId: 39, deckType: 1),
                  _SpecialCardItem(cardId: 40, deckType: 1),
                  _SpecialCardItem(cardId: 41, deckType: 1),
                ],
              ),
              const SizedBox(height: 16),
              // 鍖呭惈鐗规畩鍗″紑鍏?
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
                        const Text('鍖呭惈鐗规畩鍗?, style: TextStyle(color: Color(0xFF2A2A4E), fontSize: 14)),
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
              // 鍏抽棴鎸夐挳
              TextButton(
                onPressed: () => Get.back(),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF2A2A4E),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text('鍏抽棴', style: TextStyle(color: Colors.white)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 閲嶅缓鍗＄粍锛堝綋璁剧疆鏀瑰彉鏃讹級
  void _rebuildCards() {
    if (selectedDeck.value == null) return;

    int totalCards = selectedDeck.value == 1 ? baseDeckCount : recoveryDeckCount;

    // 閲嶆柊鐢熸垚鍗＄粍
    final allCards = List.generate(totalCards, (i) => i + 1);

    if (selectedDeck.value == 1 && !includeSpecial.value) {
      allCards.removeWhere((id) => specialCardIds.contains(id));
    }

    fanDisplayCards.value = allCards;

    // 閲嶅缓鍓╀綑鍗★紙淇濈暀鏈娊鐨勶級
    final drawnIds = drawnCardSets.expand((s) => s).toSet();
    remainingCards.value = allCards.where((id) => !drawnIds.contains(id)).toList();
  }

  /// 鍒囨崲鍗＄粍
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
                  '閫夋嫨鍗＄粍',
                  style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 20),
              // 鍩虹鍗￠€夐」锛堝姩鎬佹樉绀哄崱鏁伴噺锛?
              Obx(() {
                final isBase = selectedDeck.value == 1;
                final baseCount =
                    isBase ? (includeSpecial.value ? baseDeckCount : baseDeckCount - specialCardIds.length) : baseDeckCount - specialCardIds.length;
                final subtitle = isBase ? (includeSpecial.value ? '鍏?$baseDeckCount 寮狅紙鍚壒娈婂崱锛? : '鍏?$baseCount 寮狅紙涓嶅惈鐗规畩鍗★級') : '鍏?$baseCount 寮狅紙涓嶅惈鐗规畩鍗★級';
                return _DeckOption(
                  title: '鍩虹鍗?,
                  subtitle: subtitle,
                  selected: isBase,
                  onTap: () {
                    Get.back();
                    selectDeck(1); // 娓呯┖涓€鍒囷紝鍥炲埌鏁撮綈鍫嗗彔鐘舵€?
                  },
                );
              }),
              const SizedBox(height: 12),
              // 澶嶅師鍗￠€夐」
              Obx(() => _DeckOption(
                    title: '澶嶅師鍗?,
                    subtitle: '鍏?$recoveryDeckCount 寮?,
                    selected: selectedDeck.value == 2,
                    onTap: () {
                      Get.back();
                      selectDeck(2); // 娓呯┖涓€鍒囷紝鍥炲埌鏁撮綈鍫嗗彔鐘舵€?
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
                  child: const Text('鍙栨秷', style: TextStyle(color: Color(0xFF2A2A4E))),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// 鍗＄粍閫夐」
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

/// 鐗规畩鍗＄缉鐣ュ浘椤癸紙60x80锛?
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
          '绗?$cardId 鍙?,
          style: const TextStyle(color: Color(0xFF2A2A4E), fontSize: 12),
        ),
      ],
    );
  }
}

/// ============================================================
/// 涓昏鍥?
/// ============================================================
class CardohView extends StatelessWidget {
  const CardohView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(CardohCtrl());

    return Container(
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage('assets/images/card_win_bk.jpg'),
          fit: BoxFit.cover,
        ),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          return Stack(
            fit: StackFit.expand,
            children: [
              // 涓诲唴瀹?
              Obx(() => _buildContent(controller)),
              // 鍙充晶宸ュ叿鏉?
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
        // 棣栨杩涘叆鎴栭噸缃悗锛氭樉绀烘暣榻愬爢鍙犵殑鍗＄墝
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
/// 鏁撮綈鍫嗗彔鐨勫崱鐗岃鍥撅紙鍒濆鐘舵€侊級
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
          // 鏄剧ず鏁撮綈鍫嗗彔鐨勫崱鐗岋紙鍙偣鍑伙級
          Obx(() => GestureDetector(
                onTap: controller.selectedDeck.value != null ? () => controller.startShuffle() : null,
                child: _buildStackedDeck(),
              )),
          const SizedBox(height: 32),
          // 鎻愮ず鏂囧瓧鎴栨礂鐗屾寜閽?
          Obx(() {
            if (controller.selectedDeck.value == null) {
              return const Text(
                '璇风偣鍑诲彸渚у伐鍏锋爮閫夋嫨鍗＄粍',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.black45,
                ),
              );
            }
            // 鐐瑰嚮娲楃墝鎸夐挳
            return GestureDetector(
              onTap: () => controller.startShuffle(),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.15),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.shuffle,
                      color: Color(0xFF4DB6AC),
                      size: 20,
                    ),
                    SizedBox(width: 8),
                    Text(
                      '鐐瑰嚮娲楃墝',
                      style: TextStyle(
                        fontSize: 16,
                        color: Color(0xFF2A2A4E),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildStackedDeck() {
    if (controller.selectedDeck.value == null) {
      // 娌℃湁閫夋嫨鍗＄粍鏃讹紝鏄剧ず榛樿鐨勫爢鍙犳晥鏋?
      return _buildCardStack(null, 12);
    }
    // 鏍规嵁閫夋嫨鐨勫崱缁勬樉绀哄搴旀暟閲忕殑鍫嗗彔
    final deckType = controller.selectedDeck.value!;
    final cardCount = controller.fanDisplayCards.isEmpty
        ? 12 // 棣栨杩涘叆鏃舵樉绀洪粯璁ゅ爢鍙?
        : (controller.fanDisplayCards.length > 20 ? 20 : controller.fanDisplayCards.length);
    return _buildCardStack(deckType, cardCount);
  }

  Widget _buildCardStack(int? deckType, int count) {
    // 鏁撮綈鍫嗗彔鐨勫崱鐗屾晥鏋滐紝灏哄 90x120
    const cardW = CardohCtrl.stackedCardW;
    const cardH = CardohCtrl.stackedCardH;
    return SizedBox(
      width: cardW,
      height: cardH,
      child: Stack(
        children: List.generate(count.clamp(0, 12), (index) {
          // 瓒婂湪涓嬮潰鐨勫崱鍋忕Щ瓒婂皬锛屽垱閫犳暣榻愬爢鍙犳晥鏋?
          final offset = index * 0.4;
          return Positioned(
            left: offset,
            top: offset,
            child: Container(
              width: cardW - offset,
              height: cardH - offset * 1.2,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                image: const DecorationImage(
                  image: AssetImage('assets/images/card_one_bk.jpg'),
                  fit: BoxFit.cover,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.25),
                    blurRadius: 4,
                    offset: Offset(1.5 - offset * 0.1, 2.5 - offset * 0.15),
                  ),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }
}
class _ShufflePage extends StatefulWidget {
  final CardohCtrl controller;

  const _ShufflePage({required this.controller});

  @override
  State<_ShufflePage> createState() => _ShufflePageState();
}

class _ShufflePageState extends State<_ShufflePage> with TickerProviderStateMixin {
  late AnimationController _shuffleCtrl; // 娲楃墝鏁ｅ紑鍔ㄧ敾
  late AnimationController _moveCtrl; // 鐜舰绉诲姩鍔ㄧ敾锛?绉掞級
  late Animation<double> _scaleAnim; // 鏀惧ぇ鍔ㄧ敾
  late Animation<double> _offsetYAnim; // 涓嬬Щ鍔ㄧ敾
  late Animation<double> _cardWAnim; // 鍗＄墝瀹藉害鍔ㄧ敾
  late Animation<double> _cardHAnim; // 鍗＄墝楂樺害鍔ㄧ敾

  late List<_CardTarget> _cardTargets;

  @override
  void initState() {
    super.initState();

    _generateCardTargets();

    // 娲楃墝鏁ｅ紑鍔ㄧ敾锛氭瘡寮犲崱0.1绉掞紝鎬绘椂闀?= 鍗℃暟 * 0.1绉?
    final totalCards = widget.controller.fanDisplayCards.length;
    final shuffleDurationMs = (totalCards * 0.1 * 1000).toInt();
    _shuffleCtrl = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: shuffleDurationMs),
    );

    // 鐜舰绉诲姩鍔ㄧ敾锛?绉?
    _moveCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3000),
    );

    // 鏀惧ぇ鍔ㄧ敾锛氬崐寰勪粠240鍒?00锛屽嵆400/240=1.667
    _scaleAnim = Tween<double>(
      begin: CardohCtrl.circleRadius,
      end: CardohCtrl.expandedCircleRadius,
    ).animate(CurvedAnimation(parent: _moveCtrl, curve: Curves.easeInOut));

    // 涓嬬Щ鍔ㄧ敾锛氫粠灞忓箷涓ぎ鍒版渶缁堜綅缃?
    _offsetYAnim = Tween<double>(
      begin: widget.controller.initialCircleCenterY,
      end: widget.controller.finalCircleCenterY,
    ).animate(CurvedAnimation(parent: _moveCtrl, curve: Curves.easeInOut));

    // 鍗＄墝瀹藉害鍔ㄧ敾锛?0 -> 120
    _cardWAnim = Tween<double>(
      begin: CardohCtrl.cardW0,
      end: CardohCtrl.cardW1,
    ).animate(CurvedAnimation(parent: _moveCtrl, curve: Curves.easeInOut));

    // 鍗＄墝楂樺害鍔ㄧ敾锛?0 -> 160
    _cardHAnim = Tween<double>(
      begin: CardohCtrl.cardH0,
      end: CardohCtrl.cardH1,
    ).animate(CurvedAnimation(parent: _moveCtrl, curve: Curves.easeInOut));

    // 娲楃墝瀹屾垚鍚庢殏鍋?绉掞紝鐒跺悗鎵ц绉诲姩鍔ㄧ敾
    _shuffleCtrl.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        Future.delayed(const Duration(seconds: 1), () {
          if (mounted) {
            _moveCtrl.forward();
          }
        });
      }
    });

    // 绉诲姩瀹屾垚鍚庤繘鍏ユ墖褰紙浣嗕繚鎸佹樉绀虹幆褰㈢墝闃碉級
    _moveCtrl.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        if (mounted) {
          // 淇濆瓨鍦嗙幆鐨勮瑙夌姸鎬侊紙灏哄鍜屼綅缃級
          widget.controller.saveCircleState(
            scale: _scaleAnim.value,
            offsetY: _offsetYAnim.value,
            cardW: _cardWAnim.value,
            cardH: _cardHAnim.value,
          );
          // 鎵ц鐪熸鐨勯殢鏈烘礂鐗岋紙Fisher-Yates锛夊苟杩涘叆鎵囧舰闃舵
          widget.controller.onShuffleComplete();
        }
      }
    });

    _shuffleCtrl.forward();
  }

  void _generateCardTargets() {
    final totalCards = widget.controller.fanDisplayCards.length;
    final random = Random();

    // 鍗＄墝浣嶇疆鍧囧寑鍒嗗竷鍦ㄥ渾鐜笂
    // 瑙掑害浠庨《閮?-蟺/2)寮€濮嬶紝椤烘椂閽堝潎鍖€鍒嗗竷
    final targetAngles = List.generate(
      totalCards,
      (i) => (2 * pi * i / totalCards) - pi / 2,
    );

    // 闅忔満寤惰繜锛?.05~0.15绉掞級锛岄敊寮€椋炶鏃堕棿
    final delays = List.generate(
      totalCards,
      (_) => 0.05 + random.nextDouble() * 0.10,
    );

    _cardTargets = List.generate(totalCards, (i) {
      // 姣忓紶鍗″湪鐜舰涓婄殑鐩爣瑙掑害锛堝潎鍖€鍒嗗竷锛?
      final targetAngle = targetAngles[i];

      // 椋炶鏂瑰悜锛氫粠涓績鍚戠洰鏍囩偣椋炲幓
      final flyAngle = targetAngle;

      // 姣忓紶鍗￠殢鏈哄欢杩?
      final delay = delays[i];

      // 鏈€缁堟棆杞搴︼細鍗＄墝鎸囧悜鍦嗗績锛堝瀭鐩翠簬鍗婂緞鏂瑰悜锛?
      final finalRotation = targetAngle + pi / 2;

      // 鍒濆鏃嬭浆瑙掑害锛?锛堢墝鍫嗘槸鏁撮綈鍙犳斁鐨勶紝娌℃湁瑙掑害锛?
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
              shuffleCardW: CardohCtrl.stackedCardW,
              shuffleCardH: CardohCtrl.stackedCardH,
              cardTargets: _cardTargets,
              centerX: MediaQuery.of(context).size.width / 2,
              cardBackImage: CardohCtrl.cardBackImage,
            ),
          );
        },
      ),
    );
  }
}

/// 鍗曞紶鍗＄墝鐨勭洰鏍囦綅缃暟鎹?
class _CardTarget {
  final int id;
  final double startX; // 椋炶璧风偣X锛堜腑蹇冿級
  final double startY; // 椋炶璧风偣Y锛堜腑蹇冿級
  final double flyAngle; // 椋炶鏂瑰悜瑙掑害
  final double flyDistance; // 椋炶璺濈锛堝崐寰勶級
  final double delay; // 寤惰繜寮€濮嬪姩鐢荤殑鏃堕棿
  final double initialRotation; // 鍒濆鏃嬭浆瑙掑害
  final double finalRotation; // 鏈€缁堟棆杞搴︼紙鍗＄墝鎸囧悜鍦嗗績锛?

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

/// 娲楃墝鍔ㄧ敾鐢诲
class _ShufflePainter extends CustomPainter {
  final double shuffleProgress; // 鏁ｅ紑杩涘害 0.0~1.0
  final double moveProgress; // 绉诲姩杩涘害 0.0~1.0
  final double scale; // 褰撳墠鍗婂緞
  final double offsetY; // 鍦嗗績Y浣嶇疆
  final double cardW; // 鐜舰鍗＄墝瀹藉害锛堢Щ鍔ㄩ樁娈电粓鐐瑰昂瀵革細60鈫?20锛?
  final double cardH; // 鐜舰鍗＄墝楂樺害锛堢Щ鍔ㄩ樁娈电粓鐐瑰昂瀵革細80鈫?60锛?
  final double shuffleCardW; // 鏁ｅ紑闃舵璧峰鍗＄墝瀹藉害锛?0锛?
  final double shuffleCardH; // 鏁ｅ紑闃舵璧峰鍗＄墝楂樺害锛?20锛?
  final List<_CardTarget> cardTargets;
  final double centerX; // 灞忓箷涓績X
  final ui.Image? cardBackImage; // 棰勫姞杞界殑鍗¤儗鍥剧墖

  _ShufflePainter({
    required this.shuffleProgress,
    required this.moveProgress,
    required this.scale,
    required this.offsetY,
    required this.cardW,
    required this.cardH,
    required this.shuffleCardW,
    required this.shuffleCardH,
    required this.cardTargets,
    required this.centerX,
    this.cardBackImage,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final total = cardTargets.length;

    // 璁＄畻褰撳墠鏃堕棿锛堢锛?
    final currentTime = shuffleProgress * total * 0.1;

    for (int i = 0; i < cardTargets.length; i++) {
      final target = cardTargets[i];

      // 姣忓紶鍗￠琛?.1绉掞紝渚濇杩涜
      // 鍗鍦ㄦ椂闂?t_i 鍒?t_i+0.1 椋炶
      final flyStartTime = i * 0.1;
      final flyEndTime = flyStartTime + 0.1;

      double cardProgress;
      if (shuffleProgress <= 0) {
        // 鍔ㄧ敾鍒氬紑濮嬶紝鎵€鏈夊崱閮藉湪涓績
        cardProgress = 0.0;
      } else if (currentTime < flyStartTime) {
        // 杩樻病寮€濮嬶紝鍋滅暀鍦ㄤ腑蹇?
        cardProgress = 0.0;
      } else if (currentTime >= flyEndTime) {
        // 宸茬粡椋炲畬
        cardProgress = 1.0;
      } else {
        // 椋炶涓?
        cardProgress = (currentTime - flyStartTime) / 0.1;
      }

      final curved = Curves.easeOut.transform(cardProgress);

      // 鐩爣鐐瑰湪鐜舰涓婄殑鍧愭爣
      final targetX = cos(target.flyAngle) * scale;
      final targetY = sin(target.flyAngle) * scale;

      // 褰撳墠浣嶇疆锛氫粠涓績鐐规彃鍊煎埌鐩爣鐐?
      final currentX = centerX + targetX * curved;
      final currentY = offsetY + targetY * curved;

      // 鏃嬭浆瑙掑害锛氫粠鍒濆瑙掑害鎻掑€煎埌鏈€缁堣搴?
      final currentRotation = target.initialRotation + (target.finalRotation - target.initialRotation) * curved;

      // 褰撳墠鍗＄墝灏哄锛氭暎寮€闃舵浠庡ぇ鍗★紙90脳120锛夌缉灏忓埌灏忓崱锛?0脳80锛?
      // cardW/cardH 鍦ㄦ暎寮€闃舵缁撴潫鍚庣瓑浜?60/80锛岀Щ鍔ㄩ樁娈电户缁姩鐢诲埌 120/160
      final currentCardW = shuffleCardW + (cardW - shuffleCardW) * shuffleProgress;
      final currentCardH = shuffleCardH + (cardH - shuffleCardH) * shuffleProgress;

      // 缁樺埗鍗＄墝
      final rect = Rect.fromCenter(
        center: Offset(currentX, currentY),
        width: currentCardW,
        height: currentCardH,
      );

      canvas.save();
      canvas.translate(currentX, currentY);
      canvas.rotate(currentRotation);
      canvas.translate(-currentX, -currentY);

      // 鍗＄墝鐭╁舰
      final rrect = RRect.fromRectAndRadius(rect, const Radius.circular(8));

      // 濡傛灉鏈夐鍔犺浇鐨勫崱鑳屽浘鐗囷紝缁樺埗鍥剧墖锛涘惁鍒欎娇鐢ㄦ笎鍙?
      if (cardBackImage != null) {
        canvas.drawImageRect(
          cardBackImage!,
          Rect.fromLTWH(0, 0, cardBackImage!.width.toDouble(), cardBackImage!.height.toDouble()),
          rect,
          Paint(),
        );
      } else {
        // 娓愬彉鐢荤瑪锛堝鐢級
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
        canvas.drawRRect(rrect, gradientPaint);
      }

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
        oldDelegate.cardH != cardH ||
        oldDelegate.shuffleCardW != shuffleCardW ||
        oldDelegate.shuffleCardH != shuffleCardH;
  }
}

/// 鐜舰涓婄殑鍗曞紶鍗?
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
        image: const DecorationImage(
          image: AssetImage('assets/images/card_one_bk.jpg'),
          fit: BoxFit.cover,
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
/// 涓诲唴瀹瑰尯鍩燂紙鎵囧舰 + 宸叉娊鍗℃爮锛?
/// ============================================================
class _MainContent extends StatelessWidget {
  final CardohCtrl controller;

  const _MainContent({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // 椤堕儴宸叉娊鍗＄缉鐣ュ浘鏍忥紙_DrawnCardsBar 鍐呴儴宸叉湁 Obx锛?
        _DrawnCardsBar(controller: controller),
        // 涓棿鍖哄煙
        Expanded(
          child: Stack(
            children: [
              // 鎵囧舰鐗岄樀锛堝缁堝湪搴曞眰锛寁iewing鏃跺崐閫忔槑锛?
              _FanCardView(controller: controller),
              // 鍥涙Ы鎸夐挳鎴栭琛屼腑鐨勫崱锛堜腑闂村眰锛?
              Obx(() {
                // 鍥涙Ы妯″紡 鎴?椋炶涓椂鏄剧ず
                if (!controller.fourDrawMode.value && !controller.isFlying.value) {
                  return const SizedBox.shrink();
                }
                return _FlyingCardsView(controller: controller);
              }),
              // 鏌ョ湅宸叉娊鍗★紙椤跺眰锛?
              Obx(() {
                // 蹇呴』绛夐琛屽姩鐢荤粨鏉熷悗鎵嶆樉绀猴紙闈炲洓妲芥ā寮忎笖viewing闃舵锛?
                if (controller.phase.value != CardohPhase.viewing || controller.isFlying.value || controller.fourDrawMode.value) {
                  return const SizedBox.shrink();
                }
                // 蹇呴』寮曠敤杩欎簺鍙橀噺浠ョ‘淇?Obx 鐩戝惉瀹冧滑鐨勫彉鍖?
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
/// 椤堕儴宸叉娊鍗＄缉鐣ュ浘鏍?
/// ============================================================
class _DrawnCardsBar extends StatelessWidget {
  final CardohCtrl controller;

  const _DrawnCardsBar({required this.controller});

  @override
  Widget build(BuildContext context) {
    // 鐩存帴鍦?Obx 鍐呰闂搷搴斿紡鐘舵€?
    return Obx(() {
      final isEmpty = controller.drawnCardSets.isEmpty;

      if (isEmpty) {
        return SizedBox(
          height: 80,
          child: const Center(
            child: Text(
              '宸叉娊鍗″皢鏄剧ず鍦ㄨ繖閲?,
              style: TextStyle(color: Colors.black38, fontSize: 14),
            ),
          ),
        );
      }

      return SizedBox(
        height: 80,
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

/// 鍗＄粍缂╃暐鍥撅紙鍗曞崱鎴栧洓鍗℃嫾鍚堬級
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
      // 鍗曞崱锛氭樉绀哄畬鏁寸缉鐣ュ浘
      return _buildSingleThumbnail(cardIds[0], w, h);
    } else {
      // 澶氬崱锛?x2鎷煎悎
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
/// 鎵囧舰鐗岄樀瑙嗗浘
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

  // 鏃嬭浆鐩稿叧鐘舵€?
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

  /// 璁＄畻鎵嬫寚鐩稿浜庡渾蹇冪殑瑙掑害锛堜娇鐢ㄥ叏灞€鍧愭爣锛?
  double _computeAngle(Offset globalPosition, Offset circleCenter) {
    final dx = globalPosition.dx - circleCenter.dx;
    final dy = globalPosition.dy - circleCenter.dy;
    return atan2(dy, dx);
  }

  @override
  Widget build(BuildContext context) {
    final controller = widget.controller;

    // 鎵囧舰鍖哄煙濮嬬粓淇濇寔鍙氦浜?
    // 宸叉娊鐨勫崱宸茬粡鍦ㄥ悇鑷殑鏋勫缓鏂规硶涓璁剧疆涓洪€忔槑+涓嶅彲鐐瑰嚮
    // 娉ㄦ剰锛氬繀椤荤洃鍚?remainingCards 鍚﹀垯鎶藉崱鍚嶶I涓嶄細鏇存柊
    return Obx(() {
      // 寮曠敤 remainingCards 鍜?circleRotation 浠ョ‘淇?Obx 鑳界洃鍚畠浠殑鍙樺寲
      // ignore: unnecessary_statements - 杩欎簺寮曠敤鐢ㄤ簬寮哄埗鐩戝惉
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
    // 鍦嗗績浣嶇疆锛堜娇鐢ㄥ浐瀹氱殑鎵囧舰鍦嗗績Y锛屼笉鍙楀姩鐢昏皟鏁村奖鍝嶏級
    final circleCenterY = controller.fanCircleCenterY;

    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onPanStart: (details) {
        // 璁＄畻鎵嬫寚浣嶇疆鐩稿浜庡渾蹇冪殑瑙掑害
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
          // 鐜舰涓婄殑鍗＄墝锛堝熀浜?fanDisplayCards锛屾樉绀烘墍鏈夊崱锛?
          // fanDisplayCards 鐨勯『搴忓凡缁忔槸闅忔満鐨勶紙閫氳繃 Fisher-Yates 娲楃墝锛?
          // 鍗＄墝浣嶇疆鍧囧寑鍒嗗竷鍦ㄥ渾鐜笂
          ...List.generate(allCards.length, (i) {
            final cardId = allCards[i];
            final isDrawn = !remaining.contains(cardId);
            // 鍧囧寑鍒嗗竷鐨勮搴?
            final baseAngle = (2 * pi * i / allCards.length) - pi / 2;
            final angle = baseAngle + controller.circleRotation.value;
            final scale = controller.savedScale;
            // 浣跨敤鍥哄畾鐨勬墖褰㈠渾蹇僘
            final circleCenterY = controller.fanCircleCenterY;

            final x = screenW / 2 + cos(angle) * scale;
            final y = circleCenterY + sin(angle) * scale;

            // 鏃嬭浆瑙掑害锛氬崱鐗屾寚鍚戝渾蹇?
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
                            // 鑾峰彇鍗＄墝涓績浣嶇疆鍜屾棆杞搴?
                            final cardCenter = Offset(x, y);
                            controller.onFanCardTap(cardId, cardCenter, cardRotation: rotation);
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
          '鏆傛棤鍓╀綑鍗＄墝',
          style: TextStyle(color: Colors.black45, fontSize: 16),
        ),
      );
    }

    final pageCount = (cards.length / CardohCtrl.visibleCards).ceil();

    return Column(
      children: [
        // 鍓╀綑鏁伴噺
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Text(
            '鍓╀綑 ${cards.length} 寮?,
            style: const TextStyle(color: Colors.black54, fontSize: 14),
          ),
        ),
        // 鎵囧舰鍖哄煙
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

              // 璁＄畻鍗＄墖浣嶇疆
              const radius = 120.0;
              final x = sin(angle + pi / 2) * radius;
              final y = cos(angle) * 25;

              // 鍏ュ満鍔ㄧ敾
              final entryProgress = (_entryAnimCtrl.value - i * 0.05).clamp(0.0, 1.0);
              final entryScale = Curves.easeOut.transform(entryProgress);
              final entryOpacity = entryProgress;

              // 缂╂斁浠?0.5 鍒?1.0
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
                      onTap: (center, rotation) {
                        widget.controller.onFanCardTap(pageCards[i], center, cardRotation: rotation);
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

/// 鎵囧舰涓殑鍗曞紶鍗?
class _FanCard extends StatelessWidget {
  final int cardId;
  final int deckType;
  final Function(Offset center, double rotation) onTap;

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
          // 鎵囧舰瑙嗗浘涓殑鍗℃病鏈夋棆杞搴︼紝浼犲叆0
          onTap(center, 0.0);
        }
      },
      child: Container(
        width: cardW,
        height: cardH,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          image: const DecorationImage(
            image: AssetImage('assets/images/card_one_bk.jpg'),
            fit: BoxFit.cover,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.3),
              blurRadius: 12,
              offset: const Offset(3, 5),
            ),
          ],
        ),
      ),
    );
  }
}

/// ============================================================
/// 椋炶涓殑鍗¤鍥?
/// ============================================================
class _FlyingCardsView extends StatefulWidget {
  final CardohCtrl controller;

  const _FlyingCardsView({required this.controller});

  @override
  State<_FlyingCardsView> createState() => _FlyingCardsViewState();
}

class _FlyingCardsViewState extends State<_FlyingCardsView> with SingleTickerProviderStateMixin {
  late AnimationController _flyCtrl;
  bool _wasFlying = false; // 杩借釜涔嬪墠鐨勯琛岀姸鎬?
  bool _isAnimating = false; // 闃叉閲嶅鍚姩鍔ㄧ敾

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
    // 妫€娴?isFlying 浠?false 鍙樹负 true 鐨勬椂鍒?
    final isFlying = widget.controller.isFlying.value;
    if (!_wasFlying && isFlying && !_isAnimating) {
      // isFlying 浠?false 鍙樹负 true锛屽惎鍔ㄥ姩鐢?
      _startFlyingAnimation();
    }
    _wasFlying = isFlying;
  }

  void _startFlyingAnimation() {
    if (!mounted || _isAnimating) return;
    _isAnimating = true;
    _flyCtrl.reset(); // 閲嶇疆鍔ㄧ敾鐘舵€?
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
    // 浣跨敤 Obx 鐩戝惉鎵€鏈夊搷搴斿紡鍙橀噺鍙樺寲
    return Obx(() {
      final fourDrawMode = widget.controller.fourDrawMode.value;
      final isFlying = widget.controller.isFlying.value;
      final currentFlySlot = widget.controller.currentFlyToSlot.value;
      final flyProgress = widget.controller.flyProgress.value;
      final flyingCards = widget.controller.currentCards.toList();
      // 鍏抽敭锛氳闂搷搴斿紡鍙橀噺浠ヨЕ鍙?Obx 閲嶅缓
      final filledSlots = widget.controller.filledSlots.toList();
      final fourDrawCards = widget.controller.fourDrawCards.toList();
      final deckType = widget.controller.selectedDeck.value ?? 1;
      final labels = CardohCtrl.fourDrawLabels;

      // 寮哄埗璇诲彇鍝嶅簲寮忓彉閲忎互纭繚 Obx 杩借釜鍙樺寲
      widget.controller.filledSlots.length;
      widget.controller.fourDrawCards.length;
      widget.controller.currentCards.length; // 寮哄埗杩借釜 currentCards

      // 鍥涘崱杩炴娊妯″紡锛氭樉绀烘Ы浣嶆寜閽?
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

      // 鍦?Obx 涓篃妫€娴?isFlying 鍙樺寲锛岀‘淇濆崟鍗℃ā寮忎笅鍔ㄧ敾鑳藉惎鍔?
      // didUpdateWidget 鍙兘涓嶄細琚皟鐢紙widget 娌℃湁鍙樺寲鏃讹級锛屾墍浠ラ渶瑕佸弻閲嶄繚闄?
      if (!_wasFlying && isFlying && !_isAnimating && cardCount > 0) {
        _startFlyingAnimation();
      }
      _wasFlying = isFlying;

      // 璁＄畻鐩爣浣嶇疆锛氬崟鍗″眳涓紝鍥涘崱2x2缃戞牸
      final targetPositions = _calculateTargetPositions(screenSize, cardCount);

      return Stack(
        children: List.generate(cardCount, (index) {
          if (index >= starts.length) return const SizedBox.shrink();

          // 浜ら敊鍔ㄧ敾锛氭瘡寮犲崱寤惰繜
          final delay = index * 0.15;
          final cardProgress = ((flyProgress - delay) / (1 - delay * cardCount * 0.5)).clamp(0.0, 1.0);
          final eased = Curves.easeOut.transform(cardProgress);

          // 璧风偣鏄崱涓績浣嶇疆锛岄渶瑕佽浆涓哄乏涓婅
          final startPos = starts[index];
          final startLeft = startPos.dx - CardohCtrl.fanCardW / 2;
          final startTop = startPos.dy - CardohCtrl.fanCardH / 2;

          // 鐩爣浣嶇疆锛氬鏋滄寚瀹氫簡妲戒綅锛岄鍚戞Ы浣嶄綅缃?
          Offset target;
          final slotIdx = widget.controller.currentFlyToSlot.value;
          if (slotIdx != null && index == 0 && widget.controller.slotPositions.length > slotIdx) {
            // 椋炲悜鎸囧畾妲戒綅
            final slotPos = widget.controller.slotPositions[slotIdx];
            target = Offset(slotPos.dx - CardohCtrl.fanCardW / 2, slotPos.dy - CardohCtrl.fanCardH / 2);
          } else {
            target = targetPositions[index];
          }

          final targetLeft = target.dx;
          final targetTop = target.dy;

          // 鎻掑€艰绠楀綋鍓嶄綅缃紙浣跨敤宸︿笂瑙掞級
          final x = startLeft + (targetLeft - startLeft) * eased;
          final y = startTop + (targetTop - startTop) * eased;

          // 缂╂斁鍔ㄧ敾锛氬崟鍗?1.0->1.5锛屽洓鍗?1.0->1.0锛堜繚鎸佸師灏哄锛?
          final scale = cardCount == 1 ? (1.0 + 0.5 * eased) : 1.0;

          // 缈荤墝鍔ㄧ敾锛氬湪椋炶鍚庢湡杩涜锛堝綋 eased > 0.6 鏃跺紑濮嬬炕锛?
          final flipProgress = ((eased - 0.6) / 0.4).clamp(0.0, 1.0);

          // 鏃嬭浆鍔ㄧ敾锛氫粠鍒濆瑙掑害杩囨浮鍒?搴?
          final startRotation = index < widget.controller.flyStartRotations.length
              ? widget.controller.flyStartRotations[index]
              : 0.0;
          final rotation = startRotation * (1.0 - eased);

          return Positioned(
            left: x,
            top: y,
            child: Transform.scale(
              scale: scale,
              child: Transform.rotate(
                angle: rotation,
                child: _FlyingCard(
                  cardId: cards[index],
                  deckType: deckType,
                  flipProgress: flipProgress,
                ),
              ),
            ),
          );
        }),
      );
    });
  }

  /// 鏋勫缓鍥涙Ы鎸夐挳鐣岄潰
  /// 鏋勫缓鍥涙Ы鎸夐挳鐣岄潰锛堟帴鏀跺弬鏁扮‘淇濆搷搴斿紡杩借釜姝ｇ‘锛?
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
    // 鍒涘缓妲戒綅绱㈠紩鍒板崱鐗嘔D鐨勬槧灏?
    final slotToCard = <int, int>{};
    for (int i = 0; i < filledSlots.length && i < fourDrawCards.length; i++) {
      slotToCard[filledSlots[i]] = fourDrawCards[i];
    }

    // 鑾峰彇椋炶涓殑鍗★紙濡傛灉褰撳墠妲戒綅姝ｅ湪椋炶锛?
    int? flyingCardId;
    if (isFlying && currentFlySlot != null && flyingCards.isNotEmpty) {
      flyingCardId = flyingCards.first;
    }

    // 璁＄畻浣嶇疆锛堜笌 _buildMultiCardGrid 涓€鑷达級
    final screenSize = MediaQuery.of(Get.context!).size;
    const cardW = CardohCtrl.fanCardW; // 120
    const cardH = CardohCtrl.fanCardH; // 160
    const spacing = CardohCtrl.fourDrawSpacing; // 60
    final gridW = cardW * 2 + spacing;
    final gridH = cardH * 2 + spacing + 30; // 鍔?0鐢ㄤ簬鏍囩楂樺害
    final startX = (screenSize.width - gridW) / 2;
    final startY = (screenSize.height - gridH) / 2 - 160;

    // 2x2浣嶇疆锛堜笌_buildMultiCardGrid瀹屽叏涓€鑷达級
    final positions = [
      Offset(startX, startY + 30), // 鑰冭檻鏍囩楂樺害
      Offset(startX + cardW + spacing, startY + 30),
      Offset(startX, startY + cardH + spacing + 30),
      Offset(startX + cardW + spacing, startY + cardH + spacing + 30),
    ];

    return Stack(
      children: [
        // 鏍囩灞傦紙鏀惧湪瀵瑰簲妲戒綅鐨勬涓婃柟锛屼笌妲戒綅浣嶇疆璁＄畻涓€鑷达級
        ...List.generate(4, (i) {
          // 浣跨敤涓庢Ы浣嶇浉鍚岀殑甯冨眬閫昏緫鏉ョ‘瀹氭爣绛句綅缃?
          // positions[i] 鏄Ы浣嶄綅缃紝鏍囩鏀惧湪妲戒綅涓婃柟
          final labelLeft = positions[i].dx + cardW / 2 - 30;
          final labelTop = positions[i].dy - 28; // 鏍囩鍦ㄦЫ浣嶄笂鏂?8px
          return Positioned(
            left: labelLeft,
            top: labelTop,
            child: SizedBox(
              width: 60,
              child: Text(
                labels[i],
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Color(0xFF4DB6AC),
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          );
        }),
        // 妲戒綅/鍗＄墖灞?
        ...List.generate(4, (index) {
          final cardId = slotToCard[index];
          final pos = positions[index];

          // 濡傛灉杩欎釜妲戒綅姝ｅ湪椋炶涓紝鏄剧ず椋炶涓殑鍗?
          if (isFlying && currentFlySlot == index && flyingCardId != null) {
            // 椋炶璧风偣锛氫娇鐢ㄧ敤鎴风偣鍑荤殑鍗＄殑浣嶇疆锛堜腑蹇冪偣锛?
            final startPos = widget.controller.flyStartPositions.isNotEmpty
                ? widget.controller.flyStartPositions.first
                : Offset(screenSize.width / 2, widget.controller.fanCircleCenterY);
            // 鐩爣浣嶇疆锛堜腑蹇冪偣锛?
            final targetPos = pos;
            // 杞负宸︿笂瑙掍綅缃繘琛屾彃鍊?
            final startLeft = startPos.dx - cardW / 2;
            final startTop = startPos.dy - cardH / 2;
            final targetLeft = targetPos.dx - cardW / 2;
            final targetTop = targetPos.dy - cardH / 2;
            final eased = Curves.easeOut.transform(flyProgress);
            final x = startLeft + (targetLeft - startLeft) * eased;
            final y = startTop + (targetTop - startTop) * eased;
            // 缈荤墝鍔ㄧ敾
            final flipProgress = ((eased - 0.6) / 0.4).clamp(0.0, 1.0);
            // 鏃嬭浆鍔ㄧ敾锛氫粠鍒濆瑙掑害杩囨浮鍒?搴?
            final startRotation = widget.controller.flyStartRotations.isNotEmpty
                ? widget.controller.flyStartRotations.first
                : 0.0;
            final rotation = startRotation * (1.0 - eased);

            return Positioned(
              left: x,
              top: y,
              child: Transform.rotate(
                angle: rotation,
                child: _FlyingCard(
                  cardId: flyingCardId,
                  deckType: deckType,
                  flipProgress: flipProgress,
                ),
              ),
            );
          }

          // 宸插～鍏呯殑鍗℃垨绌烘Ы
          return Positioned(
            left: pos.dx,
            top: pos.dy,
            child: cardId != null
                ? _SlotFilledCard(
                    cardId: cardId,
                    deckType: deckType,
                    onTap: () {
                      // 鐐瑰嚮鏀惧ぇ鏌ョ湅锛堝叏灞忔樉绀猴級
                      _showZoomedCardDialog(context, cardId, deckType);
                    },
                  )
                : _buildEmptySlot(index),
          );
        }),
      ],
    );
  }

  /// 鏋勫缓绌烘Ы浣嶏紙闈欐€佸崰浣嶇锛屾棤浜や簰锛?
  Widget _buildEmptySlot(int slotIndex) {
    return Container(
      width: CardohCtrl.fanCardW,
      height: CardohCtrl.fanCardH,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFF4DB6AC), width: 2),
        color: Colors.transparent,
      ),
    );
  }

  /// 鏄剧ず鏀惧ぇ鐨勫崱锛堝叏灞忓璇濇锛屾敮鎸佺缉鏀惧拰鎷栧姩锛?
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

  /// 璁＄畻鐩爣浣嶇疆锛氬崟鍗″眳涓紝鍥涘崱2x2缃戞牸
  List<Offset> _calculateTargetPositions(Size screenSize, int cardCount) {
    if (cardCount == 1) {
      // 鍗曞崱锛氬眳涓?
      return [
        Offset(
          screenSize.width / 2 - CardohCtrl.maxCardW / 2,
          screenSize.height / 2 - CardohCtrl.maxCardH / 2,
        ),
      ];
    } else {
      // 鍥涘崱锛?x2缃戞牸灞呬腑
      const cardW = CardohCtrl.fanCardW; // 120
      const cardH = CardohCtrl.fanCardH; // 160
      const spacing = 20.0;
      final gridW = cardW * 2 + spacing;
      final gridH = cardH * 2 + spacing;
      final startX = (screenSize.width - gridW) / 2;
      final startY = (screenSize.height - gridH) / 2;

      return [
        Offset(startX, startY), // 宸︿笂
        Offset(startX + cardW + spacing, startY), // 鍙充笂
        Offset(startX, startY + cardH + spacing), // 宸︿笅
        Offset(startX + cardW + spacing, startY + cardH + spacing), // 鍙充笅
      ];
    }
  }
}

/// 椋炶涓殑鍗曞紶鍗★紙甯︾炕鐗屽姩鐢伙級
class _FlyingCard extends StatefulWidget {
  final int cardId;
  final int deckType;
  final double flipProgress; // 0.0=鑳岄潰, 1.0=姝ｉ潰

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
    // 3D缈荤墝鏁堟灉
    final angle = widget.flipProgress * pi;
    final transform = Matrix4.identity()
      ..setEntry(3, 2, 0.001) // perspective
      ..rotateY(angle);

    // 鏍规嵁瑙掑害鍒ゆ柇鏄剧ず鍝竴闈?
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
        image: const DecorationImage(
          image: AssetImage('assets/images/card_one_bk.jpg'),
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}

/// 鍥涙Ы妯″紡宸插～鍏呯殑鍗★紙鏀寔鐐瑰嚮鏀惧ぇ锛?
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
/// 鍥涙Ы妯″紡涓嬫斁澶ф煡鐪嬬殑瀵硅瘽妗嗭紙鏀寔缂╂斁鍜屾嫋鍔級
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
            // 鏀惧ぇ鐨勫崱
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
            // 鍏抽棴鎻愮ず
            Positioned(
              bottom: 50,
              left: 0,
              right: 0,
              child: const Text(
                '鐐瑰嚮浠绘剰澶勫叧闂?,
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
/// 鏌ョ湅宸叉娊鍗¤鍥撅紙鏀惧ぇ/缂╁皬/鎷栧姩锛?
/// ============================================================
class _ViewingCardsView extends StatefulWidget {
  final CardohCtrl controller;

  const _ViewingCardsView({required this.controller});

  @override
  State<_ViewingCardsView> createState() => _ViewingCardsViewState();
}

class _ViewingCardsViewState extends State<_ViewingCardsView> {
  // 缂╂斁鍜屾嫋鍔ㄧ姸鎬?
  double _pinchScale = 1.0;
  double _basePinchScale = 1.0;
  double _offsetX = 0.0;
  double _offsetY = 0.0;

  @override
  Widget build(BuildContext context) {
    // 浣跨敤 Obx 鐩戝惉 currentCards 鍜?selectedCardIndex 鐨勫彉鍖?
    return Obx(() {
      final cards = widget.controller.currentCards;
      final selectedIdx = widget.controller.selectedCardIndex.value;
      final deckType = widget.controller.selectedDeck.value ?? 1;

      if (cards.isEmpty) return const SizedBox.shrink();

      // 鍗曞崱妯″紡锛氬缁堟樉绀?00x400锛屾敮鎸佹嫋鏀惧拰缂╂斁
      if (cards.length == 1) {
        return _buildSingleCardView(cards[0], deckType);
      }

      // 澶氬崱妯″紡锛氬鏋滄湁閫変腑鐨勫崱锛屾樉绀烘斁澶х殑鍗″湪鍏朵粬鍗′箣涓?
      if (selectedIdx != null && selectedIdx < cards.length) {
        return Stack(
          children: [
            // 鑳屾櫙锛氭樉绀哄叾浠栧崱鐨勫皬鍥?
            _buildMultiCardGrid(cards, deckType, excludeIndex: selectedIdx),
            // 鍓嶆櫙锛氭斁澶х殑鍗?
            _buildZoomedCard(cards[selectedIdx], deckType),
          ],
        );
      }

      // 澶氬崱缃戞牸瑙嗗浘
      return _buildMultiCardGrid(cards, deckType);
    });
  }

  /// 鍗曞崱瑙嗗浘锛?00x400灞呬腑锛屾敮鎸佹嫋鏀惧拰缂╂斁
  Widget _buildSingleCardView(int cardId, int deckType) {
    final screenSize = MediaQuery.of(context).size;
    const cardW = CardohCtrl.maxCardW; // 300
    const cardH = CardohCtrl.maxCardH; // 400

    // 灞呬腑浣嶇疆锛屽悜涓婂亸绉?60px
    final baseX = (screenSize.width - cardW) / 2;
    final baseY = (screenSize.height - cardH) / 2 - 160;

    // 鍔犱笂鎷栧姩鍋忕Щ
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
              // 鍙屽嚮閲嶇疆
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

  /// 澶氬崱缃戞牸瑙嗗浘锛?x2锛夛細姣忓紶鍗?20x160锛岀偣鍑绘斁澶э紝甯︽爣绛?
  Widget _buildMultiCardGrid(List<int> cards, int deckType, {int? excludeIndex}) {
    final screenSize = MediaQuery.of(context).size;
    const cardW = CardohCtrl.fanCardW; // 120
    const cardH = CardohCtrl.fanCardH; // 160
    const spacing = CardohCtrl.fourDrawSpacing; // 60
    final labels = CardohCtrl.fourDrawLabels;
    final gridW = cardW * 2 + spacing;
    final gridH = cardH * 2 + spacing + 30; // 鍔?0鐢ㄤ簬鏍囩楂樺害
    final startX = (screenSize.width - gridW) / 2;
    final startY = (screenSize.height - gridH) / 2 - 160;

    // 2x2浣嶇疆锛堣€冭檻鏍囩楂樺害锛?
    final positions = [
      Offset(startX, startY + 30), // 鏍囩鍗?0楂樺害
      Offset(startX + cardW + spacing, startY + 30),
      Offset(startX, startY + cardH + spacing + 30),
      Offset(startX + cardW + spacing, startY + cardH + spacing + 30),
    ];

    return Stack(
      children: [
        // 鏍囩灞傦紙涓巁buildSlotButtons涓€鑷寸殑甯冨眬锛?
        ...List.generate(4, (i) {
          if (i >= cards.length) return const SizedBox.shrink();
          // 浣跨敤涓庡崱鐗囦綅缃竴鑷寸殑璁＄畻鏂瑰紡
          final labelLeft = positions[i].dx + cardW / 2 - 30;
          final labelTop = positions[i].dy - 28; // 鏍囩鍦ㄥ崱鐗囦笂鏂?8px
          return Positioned(
            left: labelLeft,
            top: labelTop,
            child: SizedBox(
              width: 60,
              child: Text(
                labels[i],
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Color(0xFF4DB6AC),
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          );
        }),
        // 鍗＄墖灞?
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
                // 鐐瑰嚮鏀惧ぇ
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

  /// 鏀惧ぇ鐨勫崟鍗★紙浠庡鍗￠€変腑锛夛細300x400锛屾敮鎸佹嫋鏀剧缉鏀?
  Widget _buildZoomedCard(int cardId, int deckType) {
    final screenSize = MediaQuery.of(context).size;
    const cardW = CardohCtrl.maxCardW; // 300
    const cardH = CardohCtrl.maxCardH; // 400

    final baseX = (screenSize.width - cardW) / 2;
    final baseY = (screenSize.height - cardH) / 2 - 160; // 鍚戜笂鍋忕Щ160px
    final finalX = baseX + _offsetX;
    final finalY = baseY + _offsetY;

    return Stack(
      children: [
        // 鏀惧ぇ鐨勫崱锛堢偣鍑诲浘鐗囨湰韬叧闂級
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
              // 鐐瑰嚮鍥剧墖鏈韩鍏抽棴鏀惧ぇ
              widget.controller.selectedCardIndex.value = null;
            },
            onDoubleTap: () {
              // 鍙屽嚮閲嶇疆缂╂斁
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
/// 鍙充晶娴姩宸ュ叿鏉?
/// ============================================================
class _FloatingToolbar extends StatelessWidget {
  final CardohCtrl controller;

  const _FloatingToolbar({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // 璁剧疆鎸夐挳锛堝缁堝彲鐢級
        _ToolbarButton(
          icon: Icons.settings,
          tooltip: '璁剧疆',
          onTap: () => controller.showSettingsDialog(),
        ),
        const SizedBox(height: 24),
        // 鍗＄粍閫夋嫨锛堝缁堝彲鐢紝鍒囨崲鍗＄粍鐩稿綋浜庨噸鏂板紑濮嬶級
        _ToolbarButton(
          icon: Icons.layers,
          tooltip: '鍗＄粍閫夋嫨',
          onTap: () => controller.switchDeck(),
        ),
        const SizedBox(height: 24),
        // 閲嶆柊寮€濮嬶紙濮嬬粓鍙敤锛?
        _ToolbarButton(
          icon: Icons.refresh,
          tooltip: '閲嶆柊寮€濮?,
          onTap: () => _showResetConfirm(context),
        ),
        const SizedBox(height: 24),
        // 娲楃墝锛堝彧鍦ㄦ墖褰㈤樁娈靛彲鐢級
        Obx(() {
          final isDisabled = controller.phase.value != CardohPhase.fan;
          return _ToolbarButton(
            icon: Icons.shuffle,
            tooltip: '娲楃墝',
            enabled: !isDisabled,
            onTap: () => controller.startShuffle(),
          );
        }),
        const SizedBox(height: 24),
        // 鍥涘崱杩炴娊锛堟墖褰?鏌ョ湅闃舵涓斿墿浣欏崱>=4锛?
        Obx(() {
          final canDraw = controller.remainingCards.length >= 4 && (controller.phase.value == CardohPhase.fan || controller.phase.value == CardohPhase.viewing);
          return _ToolbarButton(
            icon: Icons.grid_view,
            tooltip: '鍥涘崱杩炴娊',
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
                  '閲嶆柊寮€濮?,
                  style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                '纭畾瑕侀噸鏂板紑濮嬪悧锛焅n鎵€鏈夊凡鎶藉崱灏嗚娓呯┖銆?,
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
                      child: const Text('鍙栨秷', style: TextStyle(color: Color(0xFF2A2A4E))),
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
                      child: const Text('纭畾', style: TextStyle(color: Color(0xFF2A2A4E), fontWeight: FontWeight.bold)),
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
    // 鍥涘崱杩炴娊锛氭帶鍒跺櫒鍐呴儴闅忔満閫夊崱骞惰绠楅琛岃捣鐐?
    controller.drawFourCards();
  }
}

/// 宸ュ叿鏉℃寜閽?
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
`n```

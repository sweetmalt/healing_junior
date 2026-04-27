import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:healing_junior/data.dart';
import 'package:http/http.dart' as http;

const String _srvIp = 'https://healingai.schemas.top';

class Yao {
  final bool yang;
  final int number;
  final bool changed;
  const Yao({required this.yang, required this.number, required this.changed});
  @override
  String toString() => yang ? '阳' : '阴';
}

var _hexSymbolToNumber = <String, int>{};
var _hexMap = <String, dynamic>{};

void initHexagramMap(Map<String, dynamic> hexagramsData) {
  _hexSymbolToNumber.clear();
  final hexagrams = hexagramsData['hexagrams'] as Map<String, dynamic>? ?? hexagramsData;
  for (final entry in hexagrams.entries) {
    final hex = entry.value as Map<String, dynamic>?;
    if (hex != null && hex['symbol'] != null) {
      _hexSymbolToNumber[hex['symbol'] as String] = int.parse(entry.key);
    }
  }
  _hexMap = hexagrams;
}

String? getHexName(int? number) {
  if (number == null) return null;
  final hex = _hexMap[number.toString()] as Map<String, dynamic>?;
  return hex?['name'] as String?;
}

Map<String, dynamic>? getHexData(int number) {
  return _hexMap[number.toString()] as Map<String, dynamic>?;
}

Map<String, dynamic> _narrativesData = {};

void initNarrativesMap(Map<String, dynamic> narrativesData) {
  _narrativesData = narrativesData['narratives'] as Map<String, dynamic>? ?? narrativesData;
}

Map<String, dynamic>? getNarrative(int number) {
  // 尝试零填充key（如"01"）和普通key（如"1"）
  final k = number.toString().padLeft(2, '0');
  return (_narrativesData[k] ?? _narrativesData[number.toString()]) as Map<String, dynamic>?;
}

var _cardPackage = <String, dynamic>{};

void initCardPackage(Map<String, dynamic> pkg) {
  _cardPackage = pkg;
}

String? getCardImageUrl(int number) {
  if (_cardPackage.isEmpty) return null;
  final cards = _cardPackage['cards'] as Map<String, dynamic>? ?? {};
  final card = cards[number.toString()] as Map<String, dynamic>? ?? cards[number.toString().padLeft(2, '0')];
  var url = card?['compressed_url'] as String?;
  if (url != null && !url.startsWith('http')) {
    url = '$_srvIp$url';
  }
  return url;
}

Future<void> loadServerData() async {
  try {
    final resp = await http.get(Uri.parse('$_srvIp/brain/api/hexagrams/'));
    if (resp.statusCode == 200) {
      initHexagramMap(jsonDecode(resp.body) as Map<String, dynamic>);
    }
  } catch (e) {
    debugPrint('loadServerData error: $e');
  }
}

Yao tossCoins() {
  final rnd = math.Random();
  int n = 0;
  if (rnd.nextDouble() > 0.5) n++;
  if (rnd.nextDouble() > 0.5) n++;
  if (rnd.nextDouble() > 0.5) n++;
  if (n == 3) return Yao(yang: true, number: 9, changed: true);
  if (n == 0) return Yao(yang: false, number: 6, changed: true);
  if (n == 2) return Yao(yang: false, number: 8, changed: false);
  return Yao(yang: true, number: 7, changed: false);
}

// 根据铜钱数字列表计算爻（三枚铜钱显示2或3）
Yao calcYaoFromCoins(List<String> coins) {
  int n = coins.where((c) => c == '3').length; // 正面数量
  if (n == 3) return Yao(yang: true, number: 9, changed: true);
  if (n == 0) return Yao(yang: false, number: 6, changed: true);
  if (n == 2) return Yao(yang: false, number: 8, changed: false);
  return Yao(yang: true, number: 7, changed: false);
}

List<Yao> tossHexagram() => List.generate(6, (_) => tossCoins());

int? yaoListToHexNumber(List<Yao> yaoList) {
  final s = yaoList.map((y) => y.yang ? '阳' : '阴').join();
  return _hexSymbolToNumber[s];
}

List<Yao> calculateHuGua(List<Yao> ben) => [ben[1], ben[2], ben[3], ben[3], ben[4], ben[2]];
List<Yao> calculateCuoGua(List<Yao> ben) => ben.map((y) => Yao(yang: !y.yang, number: y.number, changed: false)).toList();
List<Yao> calculateZongGua(List<Yao> ben) => [ben[5], ben[4], ben[3], ben[2], ben[1], ben[0]];
List<Yao> calculateBianGua(List<Yao> ben) => ben.map((y) => y.changed ? Yao(yang: !y.yang, number: y.number, changed: true) : y).toList();

class BaguaCtrl extends GetxController {
  final phase = 'ready'.obs;
  final tossCount = 0.obs;
  final yaoList = <Yao>[].obs;
  final viewIndex = 2.obs;
  final hasChange = false.obs;
  final numbersStr = ''.obs;
  final fiveYaoLists = <List<dynamic>>[].obs;
  final fiveNames = <String>['', '', '', '', ''].obs;
  final currentHexData = Rxn<Map<String, dynamic>>();
  final currentNarrative = Rxn<Map<String, dynamic>>();
  final cardImageUrl = ''.obs;
  // 铜钱数字显示（3=正面, 2=背面），三枚之和决定6/7/8/9
  final coinNums = <String>['3', '2', '3'].obs;
  // 动画取消标记
  bool _disposed = false;
  // 快速翻转定时器
  Timer? _coinFlipTimer;

  @override
  void onClose() {
    _disposed = true;
    _coinFlipTimer?.cancel();
    super.onClose();
  }

  void startCoinAnim() {
    _coinFlipTimer?.cancel();
    // 快速切换铜钱数字，模拟抛掷效果
    _coinFlipTimer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
      if (_disposed) {
        timer.cancel();
        return;
      }
      final rnd = math.Random();
      coinNums.value = [
        rnd.nextBool() ? '3' : '2',
        rnd.nextBool() ? '3' : '2',
        rnd.nextBool() ? '3' : '2',
      ];
    });
  }

  void stopCoinAnim() {
    _coinFlipTimer?.cancel();
    _coinFlipTimer = null;
  }

  @override
  void onInit() {
    super.onInit();
    _ensureData();
  }

  Future<void> _ensureData() async {
    if (_hexSymbolToNumber.isNotEmpty) return;
    // 优先从本地读取
    if (await Data.exists(_kHexagramsKey)) {
      try {
        final local = await Data.read(_kHexagramsKey);
        if (local.isNotEmpty) {
          initHexagramMap(local);
        }
      } catch (e) {
        debugPrint('read local hexagrams error: $e');
      }
    }
    if (_hexSymbolToNumber.isEmpty) {
      await loadServerData();
    }
    // 加载视觉故事（如果本地有）
    final localNarr = await Data.read(_kNarrativesKey);
    if (localNarr.isNotEmpty) {
      initNarrativesMap(localNarr);
    } else {
      try {
        final resp = await http.get(Uri.parse('$_srvIp/brain/api/hexagrams/narratives/'));
        if (resp.statusCode == 200) {
          initNarrativesMap(jsonDecode(resp.body) as Map<String, dynamic>);
        }
      } catch (e) {
        debugPrint('load narratives error: $e');
      }
    }
  }

  void startDivination() {
    if (_hexSymbolToNumber.isEmpty) {
      Get.snackbar('提示', '正在加载数据，请稍后', snackPosition: SnackPosition.BOTTOM);
      loadServerData().then((_) => _doStart());
      return;
    }
    _doStart();
  }

  void _doStart() {
    phase.value = 'tossing';
    tossCount.value = 0;
    yaoList.clear();
    fiveYaoLists.clear();
    fiveNames.value = ['', '', '', '', ''];
    _performToss();
  }

  void _performToss() {
    if (_disposed) return;
    if (tossCount.value >= 6) {
      _showResult();
      return;
    }
    // 开始铜钱快速翻转动画
    startCoinAnim();
    // 3秒后停止动画，显示最终结果
    Future.delayed(const Duration(seconds: 3), () {
      if (_disposed) return;
      stopCoinAnim(); // 保持最终随机结果
      // 再停顿1秒，让用户看清铜钱结果
      Future.delayed(const Duration(seconds: 1), () {
        if (_disposed) return;
        // 根据三枚铜钱计算爻并添加到列表
        final toss = calcYaoFromCoins(coinNums.toList());
        yaoList.add(toss);
        tossCount.value++;
        // 短暂停顿后进入下一爻
        Future.delayed(const Duration(milliseconds: 300), _performToss);
      });
    });
  }

  void _showResult() {
    final ben = yaoList.toList();
    hasChange.value = ben.any((y) => y.changed);
    numbersStr.value = ben.map((y) => '${y.number}').join();

    final huYao = calculateHuGua(ben);
    final cuoYao = calculateCuoGua(ben);
    final zongYao = calculateZongGua(ben);
    final bianYao = calculateBianGua(ben);

    fiveYaoLists.value = [
      ['互卦', 'hu', huYao],
      ['错卦', 'cuo', cuoYao],
      ['本卦', 'ben', ben],
      ['综卦', 'zong', zongYao],
      ['变卦', 'bian', bianYao],
    ];

    fiveNames.value = [
      getHexName(yaoListToHexNumber(huYao)) ?? '—',
      getHexName(yaoListToHexNumber(cuoYao)) ?? '—',
      getHexName(yaoListToHexNumber(ben)) ?? '—',
      getHexName(yaoListToHexNumber(zongYao)) ?? '—',
      getHexName(yaoListToHexNumber(bianYao)) ?? '—',
    ];

    // 填充当前卦的图文内容
    final benNum = yaoListToHexNumber(ben);
    if (benNum != null) {
      currentHexData.value = getHexData(benNum);
      currentNarrative.value = getNarrative(benNum);
      _loadCardPackage(benNum);
    }

    viewIndex.value = 2;
    phase.value = 'result';
  }

  Future<void> _loadCardPackage(int hexNumber) async {
    // 如果已经加载过，直接返回
    if (_cardPackage.isNotEmpty) {
      cardImageUrl.value = getCardImageUrl(hexNumber) ?? '';
      return;
    }
    // 尝试加载ID=1的卡包
    int pkgId = 1;
    try {
      final idData = await Data.read('current_package_id');
      if (idData['id'] != null) pkgId = idData['id'] as int;
    } catch (_) {}
    final pkgPath = await Data.path('card_package_$pkgId');
    final pkgFile = File(pkgPath);
    debugPrint('loadCardPackage: path=$pkgPath, exists=${await pkgFile.exists()}');
    if (await pkgFile.exists()) {
      try {
        final contents = await pkgFile.readAsString();
        final pkg = jsonDecode(contents) as Map<String, dynamic>;
        debugPrint('loadCardPackage: cards count=${(pkg['cards'] as Map?)?.length}');
        initCardPackage(pkg);
        cardImageUrl.value = getCardImageUrl(hexNumber) ?? '';
        debugPrint('loadCardPackage: imageUrl=${cardImageUrl.value}');
      } catch (e) {
        debugPrint('loadCardPackage error: $e');
      }
    }
  }

  void _updateDetail() {
    final idx = viewIndex.value;
    if (idx < 0 || idx >= fiveYaoLists.length) return;
    final yaoList = fiveYaoLists[idx][2] as List<Yao>;
    final num = yaoListToHexNumber(yaoList);
    if (num != null) {
      currentHexData.value = getHexData(num);
      currentNarrative.value = getNarrative(num);
      // 如果卡包还没加载，先加载
      if (_cardPackage.isEmpty) {
        _loadCardPackage(num);
      } else {
        cardImageUrl.value = getCardImageUrl(num) ?? '';
      }
    }
  }

  void selectHexagram(int index) {
    viewIndex.value = index;
    _updateDetail();
  }

  void restart() {
    phase.value = 'ready';
    tossCount.value = 0;
    yaoList.clear();
    fiveYaoLists.clear();
    fiveNames.value = ['', '', '', '', ''];
    viewIndex.value = 2;
    hasChange.value = false;
    numbersStr.value = '';
    currentHexData.value = null;
    currentNarrative.value = null;
    startDivination();
  }
}

// ============================================================
// 占卦视图
// ============================================================
class BaguaView extends GetView<BaguaCtrl> {
  BaguaView({super.key});

  @override
  final controller = Get.put(BaguaCtrl());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A2E),
      body: Obx(() {
        final phase = controller.phase.value;
        if (phase == 'ready') return _buildReady(context);
        if (phase == 'tossing') return _buildTossing(context);
        return _buildResult(context);
      }),
    );
  }

  Widget _buildReady(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('是你所选皆为序章', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFFD4AF37))),
          const SizedBox(height: 16),
          const Text('以抽卡方式选择学习章节', style: TextStyle(fontSize: 14, color: Color(0xFF888888))),
          const SizedBox(height: 48),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFD4AF37),
              foregroundColor: const Color(0xFF1A1A2E),
              padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 16),
            ),
            onPressed: controller.startDivination,
            child: const Text('龟币占卦', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ),
          const SizedBox(height: 16),
          OutlinedButton(
            style: OutlinedButton.styleFrom(
              foregroundColor: const Color(0xFFD4AF37),
              side: const BorderSide(color: Color(0xFFD4AF37)),
              padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 14),
            ),
            onPressed: () => Get.to(() => BaguaDataView()),
            child: const Text('资料管理', style: TextStyle(fontSize: 16)),
          ),
        ],
      ),
    );
  }

  // 单枚铜钱组件
  // 爻线组件：阳爻为实线，阴爻为断开的线，末端显示数字
  Widget yaoLine({Yao? yao}) {
    final lineHeight = 12.0; // 爻线粗细
    final lineLength = 150.0; // 爻线长度
    final gap = 18.0; // 阴爻断开宽度
    final numWidth = 30.0; // 数字区域宽度

    if (yao == null) {
      return SizedBox(
        height: lineHeight,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(width: lineLength, height: lineHeight, color: const Color(0xFF333344)),
            SizedBox(width: numWidth),
          ],
        ),
      );
    }

    final color = yao.yang ? const Color(0xFFD4AF37) : const Color(0xFF888888);
    final numStr = yao.number.toString();

    if (yao.yang) {
      return SizedBox(
        height: lineHeight,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: lineLength,
              height: lineHeight,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(lineHeight / 2),
              ),
            ),
            SizedBox(
              width: numWidth,
              child: Text(
                numStr,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: color, height: 1),
              ),
            ),
          ],
        ),
      );
    } else {
      return SizedBox(
        height: lineHeight,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: (lineLength - gap) / 2,
              height: lineHeight,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.horizontal(left: Radius.circular(lineHeight / 2)),
              ),
            ),
            Container(width: gap),
            Container(
              width: (lineLength - gap) / 2,
              height: lineHeight,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.horizontal(right: Radius.circular(lineHeight / 2)),
              ),
            ),
            SizedBox(
              width: numWidth,
              child: Text(
                numStr,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: color, height: 1),
              ),
            ),
          ],
        ),
      );
    }
  }

  Widget coinWidget({required int index}) {
    return Obx(() {
      final num = controller.coinNums[index];
      return Container(
        width: 80,
        height: 80,
        margin: const EdgeInsets.symmetric(horizontal: 8),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFD4AF37), Color(0xFFC49B2F)],
          ),
          border: Border.all(color: const Color(0xFFA07C20), width: 3),
        ),
        child: Center(
          child: Text(
            num,
            style: const TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1A1A2E),
            ),
          ),
        ),
      );
    });
  }

  Widget _buildTossing(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // 进度指示
          Obx(() => Text('第 ${controller.tossCount.value} 爻 / 共6爻',
              style: const TextStyle(fontSize: 14, color: Color(0xFF888888)))),
          const SizedBox(height: 12),
          // 爻线显示
          Obx(() => SizedBox(
            height: 240,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(6, (i) {
                final idx = 5 - i;
                final yao = idx < controller.yaoList.length ? controller.yaoList[idx] : null;
                return AnimatedOpacity(
                  opacity: yao != null ? 1.0 : 0.15,
                  duration: const Duration(milliseconds: 300),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: yao != null
                        ? yaoLine(yao: yao)
                        : yaoLine(yao: null),
                  ),
                );
              }),
            ),
          )),
          const SizedBox(height: 16),
          // 铜钱翻转动画
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(3, (i) => coinWidget(index: i)),
          ),
          const SizedBox(height: 12),
          // 当前爻结果
          Obx(() {
            final tossCount = controller.tossCount.value;
            final yaoList = controller.yaoList;
            if (tossCount > 0 && yaoList.length >= tossCount) {
              final yao = yaoList[tossCount - 1];
              return Text(
                yao.changed ? '⚠ 变爻：${yao.number}' : '数字：${yao.number}',
                style: TextStyle(fontSize: 14, color: yao.changed ? const Color(0xFFFF6B6B) : const Color(0xFF888888)),
              );
            }
            return const Text('', style: TextStyle(fontSize: 14));
          }),
        ],
      ),
    );
  }

  Widget _buildResult(BuildContext context) {
    return Container(
      color: const Color(0xFF1A1A2E),
      child: Column(
        children: [
          // 顶部：数字符号（保留，简洁提示）
          Padding(
            padding: const EdgeInsets.only(top: 12, left: 16, right: 16),
            child: Obx(() => Text(controller.numbersStr.value, style: const TextStyle(fontSize: 14, color: Color(0xFF888888), letterSpacing: 2))),
          ),
          // 十字按钮行（紧凑布局）
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: Column(
              children: [
                _buildHexBtn(0),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildHexBtn(1),
                    const SizedBox(width: 12),
                    _buildHexBtn(2),
                    const SizedBox(width: 12),
                    _buildHexBtn(3),
                  ],
                ),
                Obx(() => controller.hasChange.value ? _buildHexBtn(4) : const SizedBox.shrink()),
              ],
            ),
          ),
          const Divider(color: Color(0xFF333355), height: 1),
          // 内容展示区
          Expanded(
            child: Obx(() => _buildHexDetail()),
          ),
          // 再次占卦按钮
          Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFD4AF37),
                foregroundColor: const Color(0xFF1A1A2E),
              ),
              onPressed: controller.restart,
              child: const Text('再占一卦'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHexDetail() {
    final hex = controller.currentHexData.value;
    final narr = controller.currentNarrative.value;
    if (hex == null) {
      return const Center(child: Text('暂无数据', style: TextStyle(color: Color(0xFF888888))));
    }

    final yaoItems = <Map<String, dynamic>>[];
    if (hex['yao_texts'] != null) {
      final texts = (hex['yao_texts'] as List).reversed.toList();
      for (final raw in texts) {
        if (raw is Map) {
          yaoItems.add({
            'position': raw['position'] ?? '',
            'symbol': (raw['position']?.toString().contains('九') ?? false) ? '☰' : '☷',
            'yang': raw['position']?.toString().contains('九') ?? false,
            'text': raw['text'] ?? '',
          });
        }
      }
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 卡图显示（16:9比例，高度为屏幕的35%）
          Obx(() {
            final imgUrl = controller.cardImageUrl.value;
            if (imgUrl.isEmpty) return const SizedBox.shrink();
            return Builder(
              builder: (context) {
                final screenH = MediaQuery.of(context).size.height;
                final imgH = screenH * 0.6;
                final imgW = imgH * 9 / 16;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Center(
                    child: SizedBox(
                      width: imgW,
                      height: imgH,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.network(
                          imgUrl,
                          fit: BoxFit.contain,
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return Container(
                              alignment: Alignment.center,
                              color: const Color(0xFF2A2A4E),
                              child: CircularProgressIndicator(
                                value: loadingProgress.expectedTotalBytes != null
                                    ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                                    : null,
                                color: const Color(0xFFD4AF37),
                              ),
                            );
                          },
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              alignment: Alignment.center,
                              color: const Color(0xFF2A2A4E),
                              child: const Text('图片加载失败', style: TextStyle(color: Color(0xFF888888))),
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                );
              },
            );
          }),
          // 视觉叙事-主内容
          if (narr != null && narr['visual_narrative'] != null && (narr['visual_narrative']['primary'] ?? '').isNotEmpty) ...[
            _buildSection('.', narr['visual_narrative']['primary'] ?? '', const Color(0xFFD4AF37), fontSize: 20),
            const SizedBox(height: 12),
          ],
          // 视觉叙事-描述
          if (narr != null && narr['visual_narrative'] != null && (narr['visual_narrative']['primary_description'] ?? '').isNotEmpty) ...[
            _buildSection('内容', narr['visual_narrative']['primary_description'] ?? '', const Color(0xFFAAAAAA), fontSize: 20),
            const SizedBox(height: 12),
          ],
          // 视觉叙事-启发
          if (narr != null && narr['visual_narrative'] != null) ...[
            _buildSection('启发', narr['visual_narrative']['启发点'] ?? '', const Color(0xFF6EC6FF), fontSize: 20),
            const SizedBox(height: 12),
          ],
          // 卦辞
          _buildSection('卦辞', hex['gua_text'] ?? '', Colors.white, fontSize: 20),
          const SizedBox(height: 12),
          // 爻辞
          const Text('爻辞', style: TextStyle(color: Color(0xFFD4AF37), fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 6),
          ...yaoItems.map((y) => Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: 36,
                      child: Text('${y['symbol']} ${y['position']}',
                          style: TextStyle(color: y['yang'] ? const Color(0xFFFF8844) : const Color(0xFF66BBAA), fontSize: 20)),
                    ),
                    Expanded(child: Text('${y['text']}', style: const TextStyle(color: Color(0xFFDDDDDD), fontSize: 20, height: 1.4))),
                  ],
                ),
              )),
          const SizedBox(height: 8),
          // 象曰
          if (hex['xiang'] != null) _buildSection('象曰', hex['xiang'], const Color(0xFFAAAAAA), fontSize: 20),
          const SizedBox(height: 8),
          // 彖曰
          if (hex['tuan'] != null) _buildSection('彖曰', hex['tuan'], const Color(0xFFBBBBBB), fontSize: 20),
        ],
      ),
    );
  }

  Widget _buildSection(String title, String content, Color titleColor, {double fontSize = 20}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: TextStyle(color: titleColor, fontSize: fontSize, fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        Text(content, style: TextStyle(color: Colors.white, fontSize: fontSize, height: 1.5)),
      ],
    );
  }

  static const _names = ['互卦', '错卦', '本卦', '综卦', '变卦'];

  Widget _buildHexBtn(int index) {
    return Obx(() {
      final active = controller.viewIndex.value == index;
      return GestureDetector(
        onTap: () => controller.selectHexagram(index),
        child: Container(
          width: 48,
          height: 48,
          margin: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: const Color(0xFF252540),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: active ? const Color(0xFFD4AF37) : const Color(0xFF555577),
              width: active ? 2 : 1,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // 类型标签（互卦/错卦/本卦/综卦/变卦）
              Text(_names[index], style: TextStyle(fontSize: 8, color: active ? const Color(0xFFD4AF37) : const Color(0xFF777799))),
              const SizedBox(height: 2),
              // 卦名（每个按钮都显示）
              Obx(() => Text(
                    controller.fiveNames.length > index ? controller.fiveNames[index] : '—',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: active ? const Color(0xFFD4AF37) : const Color(0xFFCCCCCC)),
                  )),
            ],
          ),
        ),
      );
    });
  }
}

// ============================================================
// 资料管理页面
// ============================================================
const String _kHexagramsKey = 'hexagrams_data';
const String _kNarrativesKey = 'narratives_data';
const String _kPackagesKey = 'card_packages_list';
const String _kPackagePrefix = 'card_package_';

class BaguaDataCtrl extends GetxController {
  final hexagramsStatus = 'none'.obs; // none | ok
  final narrativesStatus = 'none'.obs; // none | ok
  final packages = <Map<String, dynamic>>[].obs;
  final packagesStatus = <String>[].obs; // none | ok | current per package
  final downloadingId = ''.obs;

  @override
  void onInit() {
    super.onInit();
    _loadStatus();
    _fetchPackageList();
  }

  Future<void> _loadStatus() async {
    hexagramsStatus.value = await Data.exists(_kHexagramsKey) ? 'ok' : 'none';
    narrativesStatus.value = await Data.exists(_kNarrativesKey) ? 'ok' : 'none';
  }

  Future<void> _fetchPackageList() async {
    // 读本地卡包列表
    final list = await Data.read(_kPackagesKey);
    if (list.isNotEmpty && list['packages'] != null) {
      packages.value = List<Map<String, dynamic>>.from(list['packages']);
    }
    // 从服务器刷新列表
    try {
      final resp = await http.get(Uri.parse('$_srvIp/brain/api/cardpackages/public/'));
      if (resp.statusCode == 200) {
        final data = jsonDecode(resp.body);
        final listPath = await Data.path(_kPackagesKey);
        await File(listPath).writeAsString(jsonEncode(data));
        packages.value = List<Map<String, dynamic>>.from(data);
      }
    } catch (e) {
      debugPrint('fetchPackageList error: $e');
    }
    // 刷新各卡包本地状态
    _refreshPackagesStatus();
  }

  Future<void> _refreshPackagesStatus() async {
    final currentId = await Data.read('current_package_id');
    final ids = currentId['id']?.toString();
    final statusList = <String>[];
    for (final p in packages) {
      final id = p['id'].toString();
      if (ids == id) {
        statusList.add('current');
      } else {
        final ok = await Data.exists('$_kPackagePrefix$id');
        statusList.add(ok ? 'ok' : 'none');
      }
    }
    packagesStatus.value = statusList;
  }

  Future<void> downloadHexagrams() async {
    try {
      final resp = await http.get(Uri.parse('$_srvIp/brain/api/hexagrams/'));
      if (resp.statusCode == 200) {
        final data = jsonDecode(resp.body);
        final filePath = await Data.path(_kHexagramsKey);
        await File(filePath).writeAsString(jsonEncode(data));
        initHexagramMap(data);
        hexagramsStatus.value = 'ok';
        Get.snackbar('成功', '易经原文下载完成', snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.green, colorText: Colors.white, duration: const Duration(seconds: 2));
      }
    } catch (e) {
      debugPrint('downloadHexagrams error: $e');
      Get.snackbar('失败', '易经原文下载失败', snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.red, colorText: Colors.white, duration: const Duration(seconds: 2));
    }
  }

  Future<void> downloadNarratives() async {
    try {
      final resp = await http.get(Uri.parse('$_srvIp/brain/api/hexagrams/narratives/'));
      if (resp.statusCode == 200) {
        final data = jsonDecode(resp.body);
        final filePath = await Data.path(_kNarrativesKey);
        await File(filePath).writeAsString(jsonEncode(data));
        initNarrativesMap(data);
        narrativesStatus.value = 'ok';
        Get.snackbar('成功', '视觉故事下载完成', snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.green, colorText: Colors.white, duration: const Duration(seconds: 2));
      }
    } catch (e) {
      debugPrint('downloadNarratives error: $e');
      Get.snackbar('失败', '视觉故事下载失败', snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.red, colorText: Colors.white, duration: const Duration(seconds: 2));
    }
  }

  Future<void> downloadPackage(int id) async {
    if (downloadingId.value.isNotEmpty) return;
    downloadingId.value = id.toString();
    try {
      final resp = await http.get(Uri.parse('$_srvIp/brain/api/cardpackages/$id/download/?compressed=1'));
      if (resp.statusCode == 200) {
        final data = jsonDecode(resp.body);
        final pkgPath = await Data.path('$_kPackagePrefix$id');
        await File(pkgPath).writeAsString(jsonEncode(data));
        final idPath = await Data.path('current_package_id');
        await File(idPath).writeAsString(jsonEncode({'id': id}));
        await _loadStatus();
        _refreshPackagesStatus();
        Get.snackbar('成功', '卡包下载完成', snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.green, colorText: Colors.white, duration: const Duration(seconds: 2));
      }
    } catch (e) {
      debugPrint('downloadPackage error: $e');
      Get.snackbar('失败', '卡包下载失败', snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.red, colorText: Colors.white, duration: const Duration(seconds: 2));
    } finally {
      downloadingId.value = '';
    }
  }

  Future<void> selectPackage(int id) async {
    try {
      final idPath = await Data.path('current_package_id');
      await File(idPath).writeAsString(jsonEncode({'id': id}));
      await _refreshPackagesStatus();
      Get.snackbar('已选择', '当前卡包已切换', snackPosition: SnackPosition.BOTTOM, backgroundColor: const Color(0xFFD4AF37), colorText: Colors.black, duration: const Duration(seconds: 2));
    } catch (e) {
      debugPrint('selectPackage error: $e');
    }
  }
}

class BaguaDataView extends GetView<BaguaDataCtrl> {
  BaguaDataView({super.key});

  @override
  final controller = Get.put(BaguaDataCtrl());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A2E),
      appBar: AppBar(
        backgroundColor: const Color(0xFF252540),
        foregroundColor: Colors.white,
        title: const Text('资料管理'),
      ),
      body: Obx(() => ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _buildCard(
                title: '易经原文',
                status: controller.hexagramsStatus.value,
                onDownload: controller.downloadHexagrams,
                onTap: controller.hexagramsStatus.value == 'ok' ? () => Get.to(() => BaguaHexTextView()) : null,
              ),
              const SizedBox(height: 16),
              _buildCard(
                title: '视觉故事',
                status: controller.narrativesStatus.value,
                onDownload: controller.downloadNarratives,
                onTap: controller.narrativesStatus.value == 'ok' ? () => Get.to(() => BaguaNarrativeView()) : null,
              ),
              const SizedBox(height: 24),
              const Text('卡包列表', style: TextStyle(color: Colors.white, fontSize: 16)),
              const SizedBox(height: 12),
              ...List.generate(
                controller.packages.length,
                (i) => _buildPackageItem(i),
              ),
            ],
          )),
    );
  }

  Widget _buildCard({required String title, required String status, required Future<void> Function() onDownload, VoidCallback? onTap}) {
    final isOk = status == 'ok';
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF252540),
          borderRadius: BorderRadius.circular(12),
          border: onTap != null ? Border.all(color: const Color(0xFFD4AF37).withAlpha(77), width: 1) : null,
        ),
        child: Row(
          children: [
            Icon(
              isOk ? Icons.check_circle : Icons.cloud_download,
              color: isOk ? Colors.green : const Color(0xFFD4AF37),
            ),
            const SizedBox(width: 12),
            Expanded(child: Text(title, style: const TextStyle(color: Colors.white, fontSize: 16))),
            if (isOk) const Text('查看', style: TextStyle(color: Color(0xFFD4AF37))),
            if (!isOk)
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFD4AF37)),
                onPressed: onDownload,
                child: const Text('下载', style: TextStyle(color: Color(0xFF1A1A2E))),
              )
            else
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF555555)),
                onPressed: onDownload,
                child: const Text('重新下载', style: TextStyle(color: Colors.white, fontSize: 12)),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildPackageItem(int i) {
    final pkg = controller.packages[i];
    final status = i < controller.packagesStatus.length ? controller.packagesStatus[i] : 'none';
    final isCurrent = status == 'current';
    final isOk = status == 'ok' || isCurrent;
    final isDownloading = controller.downloadingId.value == pkg['id'].toString();

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF252540),
        borderRadius: BorderRadius.circular(12),
        border: isCurrent ? Border.all(color: const Color(0xFFD4AF37), width: 2) : null,
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(pkg['name'] ?? '卡包${pkg['id']}', style: TextStyle(color: isCurrent ? const Color(0xFFD4AF37) : Colors.white, fontSize: 16, fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal)),
                if (pkg['description'] != null) Text(pkg['description'], style: const TextStyle(color: Color(0xFF888888), fontSize: 12)),
              ],
            ),
          ),
          const SizedBox(width: 12),
          if (isCurrent)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(color: const Color(0xFFD4AF37), borderRadius: BorderRadius.circular(16)),
              child: const Text('当前', style: TextStyle(color: Color(0xFF1A1A2E), fontWeight: FontWeight.bold)),
            )
          else if (isOk)
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF333355), foregroundColor: Colors.white),
              onPressed: () => controller.selectPackage(pkg['id']),
              child: const Text('选择', style: TextStyle(fontSize: 12)),
            )
          else if (isDownloading)
            const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFFD4AF37)))
          else
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFD4AF37)),
              onPressed: () => controller.downloadPackage(pkg['id']),
              child: const Text('下载', style: TextStyle(color: Color(0xFF1A1A2E))),
            ),
        ],
      ),
    );
  }
}

// ============================================================
// 易经原文浏览页面
// ============================================================
class BaguaHexTextCtrl extends GetxController {
  final hexList = <Map<String, dynamic>>[].obs;
  final isLoading = true.obs;
  // 详情弹窗
  final selectedHex = Rxn<Map<String, dynamic>>();
  final showDetail = false.obs;

  @override
  void onInit() {
    super.onInit();
    _load();
  }

  Future<void> _load() async {
    isLoading.value = true;
    final local = await Data.read(_kHexagramsKey);
    if (local.isNotEmpty) {
      _buildList(local);
    } else {
      try {
        final resp = await http.get(Uri.parse('$_srvIp/brain/api/hexagrams/'));
        if (resp.statusCode == 200) {
          final data = jsonDecode(resp.body) as Map<String, dynamic>;
          _buildList(data);
          final fp = await Data.path(_kHexagramsKey);
          await File(fp).writeAsString(jsonEncode(data));
        }
      } catch (e) {
        debugPrint('load hexagrams error: $e');
      }
    }
    isLoading.value = false;
  }

  void _buildList(Map<String, dynamic> data) {
    final list = <Map<String, dynamic>>[];
    // data = {"version":..., "hexagrams": {"1":{...}, "2":{...}}}
    final hexagrams = data['hexagrams'] as Map<String, dynamic>? ?? data;
    for (final entry in hexagrams.entries) {
      if (int.tryParse(entry.key) != null) {
        list.add({'number': int.parse(entry.key), ...entry.value as Map<String, dynamic>});
      }
    }
    list.sort((a, b) => (a['number'] as int).compareTo(b['number'] as int));
    hexList.value = list;
  }

  void showHexDetail(Map<String, dynamic> hex) {
    selectedHex.value = hex;
    showDetail.value = true;
  }

  void closeDetail() {
    showDetail.value = false;
  }

  // 解析爻辞列表（处理对象数组和字符串数组）
  List<String> getYaoList(Map<String, dynamic> hex) {
    final yaoTexts = hex['yao_texts'];
    if (yaoTexts is List) {
      return yaoTexts.map((item) {
        if (item is String) return item;
        if (item is Map) {
          return (item['text'] ?? item['content'] ?? item.toString()) as String;
        }
        return item.toString();
      }).toList();
    }
    return [];
  }
}

class BaguaHexTextView extends GetView<BaguaHexTextCtrl> {
  BaguaHexTextView({super.key});
  @override
  final controller = Get.put(BaguaHexTextCtrl());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A2E),
      appBar: AppBar(
        backgroundColor: const Color(0xFF252540),
        foregroundColor: Colors.white,
        title: const Text('易经原文'),
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator(color: Color(0xFFD4AF37)));
        }
        if (controller.hexList.isEmpty) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.book_outlined, size: 64, color: Color(0xFF555577)),
                SizedBox(height: 16),
                Text('暂无数据', style: TextStyle(color: Color(0xFF888888), fontSize: 16)),
                SizedBox(height: 8),
                Text('请先在「资料管理」中下载原文电子书', style: TextStyle(color: Color(0xFF555577), fontSize: 14)),
              ],
            ),
          );
        }
        return Stack(
          children: [
            ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: controller.hexList.length,
              itemBuilder: (context, i) {
                final hex = controller.hexList[i];
                return GestureDetector(
                  onTap: () => controller.showHexDetail(hex),
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFF252540),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        // 序号
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: const Color(0xFF333355),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          alignment: Alignment.center,
                          child: Text('${hex['number']}', style: const TextStyle(color: Color(0xFFD4AF37), fontSize: 18, fontWeight: FontWeight.bold)),
                        ),
                        const SizedBox(width: 12),
                        // 名称+卦辞
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(hex['name'] ?? '', style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                              const SizedBox(height: 4),
                              Text(
                                hex['gua_text'] ?? '',
                                style: const TextStyle(color: Color(0xFFAAAAAA), fontSize: 13),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        // 元素+箭头
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            if (hex['element'] != null)
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF3A3A5A),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(hex['element'], style: const TextStyle(color: Color(0xFFD4AF37), fontSize: 11)),
                              ),
                            const SizedBox(height: 4),
                            const Icon(Icons.chevron_right, color: Color(0xFF555577)),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
            // 详情弹窗
            Obx(() => controller.showDetail.value ? _buildHexDetailDialog() : const SizedBox.shrink()),
          ],
        );
      }),
    );
  }

  Widget _buildHexDetailDialog() {
    final hex = controller.selectedHex.value;
    if (hex == null) return const SizedBox.shrink();
    final yaoList = controller.getYaoList(hex);
    final keywords = (hex['keywords'] as List?)?.cast<String>() ?? [];
    return GestureDetector(
      onTap: controller.closeDetail,
      child: Container(
        color: Colors.black54,
        child: Center(
          child: GestureDetector(
            onTap: () {},
            child: Container(
              margin: const EdgeInsets.all(24),
              constraints: const BoxConstraints(maxHeight: 600),
              decoration: BoxDecoration(
                color: const Color(0xFF252540),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // 头部
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: const BoxDecoration(
                      border: Border(bottom: BorderSide(color: Color(0xFF3A3A5A))),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: const Color(0xFFD4AF37).withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              alignment: Alignment.center,
                              child: Text('${hex['number']}', style: const TextStyle(color: Color(0xFFD4AF37), fontSize: 18, fontWeight: FontWeight.bold)),
                            ),
                            const SizedBox(width: 12),
                            Text(hex['name'] ?? '', style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(hex['gua_text'] ?? '', style: const TextStyle(color: Color(0xFFAAAAAA), fontSize: 14), overflow: TextOverflow.ellipsis),
                            ),
                            GestureDetector(
                              onTap: controller.closeDetail,
                              child: const Icon(Icons.close, color: Color(0xFF888888)),
                            ),
                          ],
                        ),
                        if (keywords.isNotEmpty || hex['element'] != null) ...[
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 8,
                            runSpacing: 4,
                            children: [
                              if (hex['element'] != null)
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF3A3A5A),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(hex['element'], style: const TextStyle(color: Color(0xFFD4AF37), fontSize: 11)),
                                ),
                              ...keywords.map((k) => Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF3A3A5A),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(k, style: const TextStyle(color: Color(0xFFAAAAAA), fontSize: 11)),
                              )),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                  // 内容区（可滚动）
                  Flexible(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // 卦辞
                          _buildSection('卦辞', hex['gua_text'] ?? ''),
                          const SizedBox(height: 16),
                          // 爻辞
                          if (yaoList.isNotEmpty) ...[
                            const Text('爻辞', style: TextStyle(color: Color(0xFFD4AF37), fontSize: 15, fontWeight: FontWeight.bold)),
                            const SizedBox(height: 8),
                            ...yaoList.asMap().entries.map((e) => Padding(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: Text(e.value, style: const TextStyle(color: Colors.white, fontSize: 13, height: 1.5)),
                            )),
                          ],
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSection(String title, String content) {
    if (content.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(color: Color(0xFFD4AF37), fontSize: 15, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Text(content, style: const TextStyle(color: Colors.white, fontSize: 13, height: 1.6)),
      ],
    );
  }
}

// ============================================================
// 视觉故事浏览页面
// ============================================================
class BaguaNarrativeCtrl extends GetxController {
  final items = <Map<String, dynamic>>[].obs;
  final isLoading = true.obs;
  // 详情弹窗
  final selectedNarrative = Rxn<Map<String, dynamic>>();
  final showDetail = false.obs;

  @override
  void onInit() {
    super.onInit();
    _load();
  }

  Future<void> _load() async {
    isLoading.value = true;
    final local = await Data.read(_kNarrativesKey);
    if (local.isNotEmpty) {
      _buildList(local);
    } else {
      try {
        final resp = await http.get(Uri.parse('$_srvIp/brain/api/hexagrams/narratives/'));
        if (resp.statusCode == 200) {
          final data = jsonDecode(resp.body) as Map<String, dynamic>;
          _buildList(data);
          final fp = await Data.path(_kNarrativesKey);
          await File(fp).writeAsString(jsonEncode(data));
        }
      } catch (e) {
        debugPrint('load narratives error: $e');
      }
    }
    isLoading.value = false;
  }

  void _buildList(Map<String, dynamic> data) {
    final list = <Map<String, dynamic>>[];
    final narratives = data['narratives'] as Map<String, dynamic>? ?? data;
    for (final entry in narratives.entries) {
      if (int.tryParse(entry.key) != null) {
        list.add({'number': int.parse(entry.key), ...entry.value as Map<String, dynamic>});
      }
    }
    list.sort((a, b) => (a['number'] as int).compareTo(b['number'] as int));
    items.value = list;
  }

  void showNarrativeDetail(Map<String, dynamic> narrative) {
    selectedNarrative.value = narrative;
    showDetail.value = true;
  }

  void closeDetail() {
    showDetail.value = false;
  }

  // 获取视觉叙事数据
  String? getVnPrimary(Map<String, dynamic> narrative) {
    return narrative['visual_narrative']?['primary'] as String?;
  }

  String? getVnDescription(Map<String, dynamic> narrative) {
    return narrative['visual_narrative']?['primary_description'] as String?;
  }

  String? getVnInspiration(Map<String, dynamic> narrative) {
    // 启发点是中文key
    return narrative['visual_narrative']?['启发点'] as String?;
  }
}

class BaguaNarrativeView extends GetView<BaguaNarrativeCtrl> {
  BaguaNarrativeView({super.key});
  @override
  final controller = Get.put(BaguaNarrativeCtrl());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A2E),
      appBar: AppBar(
        backgroundColor: const Color(0xFF252540),
        foregroundColor: Colors.white,
        title: const Text('通俗理解'),
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator(color: Color(0xFFD4AF37)));
        }
        if (controller.items.isEmpty) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.auto_stories_outlined, size: 64, color: Color(0xFF555577)),
                SizedBox(height: 16),
                Text('暂无资料', style: TextStyle(color: Color(0xFF888888), fontSize: 16)),
                SizedBox(height: 8),
                Text('请先在「资料管理」中下载视觉叙事', style: TextStyle(color: Color(0xFF555577), fontSize: 14)),
              ],
            ),
          );
        }
        return Stack(
          children: [
            ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: controller.items.length,
              itemBuilder: (context, i) {
                final item = controller.items[i];
                return GestureDetector(
                  onTap: () => controller.showNarrativeDetail(item),
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFF252540),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        // 序号
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: const Color(0xFF333355),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          alignment: Alignment.center,
                          child: Text('${item['number']}', style: const TextStyle(color: Color(0xFFD4AF37), fontSize: 18, fontWeight: FontWeight.bold)),
                        ),
                        const SizedBox(width: 12),
                        // 名称+摘要
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(item['name'] ?? '', style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                              const SizedBox(height: 4),
                              Text(
                                item['summary'] ?? '',
                                style: const TextStyle(color: Color(0xFFAAAAAA), fontSize: 13),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Icon(Icons.chevron_right, color: Color(0xFF555577)),
                      ],
                    ),
                  ),
                );
              },
            ),
            // 详情弹窗
            Obx(() => controller.showDetail.value ? _buildNarrativeDetailDialog() : const SizedBox.shrink()),
          ],
        );
      }),
    );
  }

  Widget _buildNarrativeDetailDialog() {
    final narrative = controller.selectedNarrative.value;
    if (narrative == null) return const SizedBox.shrink();
    final vnPrimary = controller.getVnPrimary(narrative);
    final vnDescription = controller.getVnDescription(narrative);
    final vnInspiration = controller.getVnInspiration(narrative);
    return GestureDetector(
      onTap: controller.closeDetail,
      child: Container(
        color: Colors.black54,
        child: Center(
          child: GestureDetector(
            onTap: () {},
            child: Container(
              margin: const EdgeInsets.all(24),
              constraints: const BoxConstraints(maxHeight: 600),
              decoration: BoxDecoration(
                color: const Color(0xFF252540),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // 头部
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: const BoxDecoration(
                      border: Border(bottom: BorderSide(color: Color(0xFF3A3A5A))),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: const Color(0xFFD4AF37).withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          alignment: Alignment.center,
                          child: Text('${narrative['number']}', style: const TextStyle(color: Color(0xFFD4AF37), fontSize: 18, fontWeight: FontWeight.bold)),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(narrative['name'] ?? '', style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                        ),
                        GestureDetector(
                          onTap: controller.closeDetail,
                          child: const Icon(Icons.close, color: Color(0xFF888888)),
                        ),
                      ],
                    ),
                  ),
                  // 内容区（可滚动）
                  Flexible(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // 常规理解
                          _buildSection('常规理解', narrative['summary'] ?? ''),
                          // 视觉故事
                          if (vnPrimary != null) ...[
                            const SizedBox(height: 16),
                            _buildVisualStory(vnPrimary, vnDescription),
                          ],
                          // 启发点
                          if (vnInspiration != null) ...[
                            const SizedBox(height: 16),
                            _buildInspiration(vnInspiration),
                          ],
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSection(String title, String content) {
    if (content.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(color: Color(0xFFD4AF37), fontSize: 15, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Text(content, style: const TextStyle(color: Colors.white, fontSize: 13, height: 1.6)),
      ],
    );
  }

  Widget _buildVisualStory(String primary, String? description) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('视觉故事', style: TextStyle(color: Color(0xFFD4AF37), fontSize: 15, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFF1A1A2E).withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: const Color(0xFF3A3A5A)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(primary, style: const TextStyle(color: Colors.white, fontSize: 14, height: 1.6, fontWeight: FontWeight.w500)),
              if (description != null && description.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(description, style: const TextStyle(color: Color(0xFFAAAAAA), fontSize: 12, height: 1.5)),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildInspiration(String content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('启发点', style: TextStyle(color: Color(0xFFD4AF37), fontSize: 15, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFFD4AF37).withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: const Color(0xFFD4AF37).withValues(alpha: 0.3)),
          ),
          child: Text(content, style: const TextStyle(color: Color(0xFFD4AF37), fontSize: 13, height: 1.6)),
        ),
      ],
    );
  }
}

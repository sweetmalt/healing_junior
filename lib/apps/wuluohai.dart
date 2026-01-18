import 'dart:math';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:healing_junior/view.dart';

class WuluohaiView extends GetView<WuluohaiCtrl> {
  WuluohaiView({super.key});
  @override
  final WuluohaiCtrl controller = Get.put(WuluohaiCtrl());
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(10),
      padding: const EdgeInsets.all(10),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          childAspectRatio: 1.8,
          mainAxisSpacing: 8,
          crossAxisSpacing: 8,
        ),
        itemCount: WuluohaiCtrl.musicTitles.length,
        itemBuilder: (context, index) => Obx(() => Card(
              color: controller.selectedIndex.value == index ? colorSurface : Colors.white,
              elevation: 2,
              child: ListTile(
                leading: controller.selectedIndex.value == index
                    ? Icon(
                        Icons.check_circle,
                        color: colorSecondary,
                        size: 20,
                      )
                    : Icon(
                        Icons.music_note,
                        color: colorSurface,
                        size: 20,
                      ),
                title: Text(
                  WuluohaiCtrl.musicTitles.keys.elementAt(index),
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                subtitle: Text(
                  WuluohaiCtrl.musicTitles.values.elementAt(index),
                  style: TextStyle(
                    fontSize: 12,
                    color: colorPrimaryContainer,
                  ),
                ),
              ),
            )),
      ),
    );
  }
}

class WuluohaiCtrl extends GetxController {
  RxInt selectedIndex = 0.obs;
  void selectRandom() {
    selectedIndex.value = Random().nextInt(musicTitles.length);
  }

  static const Map<String, String> musicTitles = {
    "唤醒": "使人从睡眠或低迷状态中清醒，恢复意识与活力，开启新的一天。",
    "激活": "激发内在潜能，调动身心积极性，为行动做好准备。",
    "修复": "对受损的身心进行调养，缓解伤痛，帮助恢复至健康平衡状态。",
    "放松（紧张）": "因压力等产生情绪紧绷，身体肌肉收缩，肌肉收缩，心理不安，需放松舒缓。",
    "安宁（焦虑）": "内心过度担忧，思绪杂乱，对未来充满不安，影响正常生活。",
    "温暖（忧郁）": "情绪低落，难以自拔，对事物缺乏兴趣，沉浸在悲伤氛围中，难以走出阴霾。",
    "舒缓（焦躁）": "使紧张的情绪得到放松，身体舒展，使紧张情绪松弛，释放心理压力。",
    "鼓舞（抑郁）": "长期情绪压抑，失去活力，对生活绝望，伴有消极思维。",
    "喜悦": "内心充满快乐，情绪高涨，对周围事物感到愉悦和满足，感染周围氛围。",
    "静心": "排除杂念，使内心平静，专注于当下，内心平和，达到精神纯净状态",
    "宁静": "环境或心境安静祥和，远离喧嚣，享受平和安宁。",
    "平衡": "调和身心，调和身心，稳定生理心理，避免极端情绪，维持和谐。",
    "助眠": "帮助入睡，缓解失眠困扰，营造舒适睡眠环境，引导放松。",
    "注意力": "集中精神，聚焦于特定任务或对象，提高专注度，提升工作学习效率。",
    "探索": "对未知领域充满好奇，主动求知、新体验，拓展认知边界，对未知好奇，寻求新体验。",
    "记忆力": "增强大脑对信息的存储和回忆能力，助力学习记忆，提升认知。",
    "专注力": "全身心投入某件事，不受外界干扰，保持高度注意，高效完成任务。",
    "创造力": "激发创新思维，突破常规，产生独特新颖的想法和解决方案。",
    "洞察力": "深入观察和理解事物本质，敏锐捕捉细节，洞察人心和局势。",
    "空": "内心虚无，放下执念，以空灵的心态接纳万物，感悟生命真谛。",
    "悟": "经过思考和体验，突然领悟道理，实现心灵的升华和成长。",
    "云游": "仿佛灵魂脱离肉体，在想象的空间中自由遨游，感受无拘无束，想象驰骋。",
    "筑梦": "怀揣梦想，努力构建未来蓝图，充满希望前行，追逐理想。",
  };
}

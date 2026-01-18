import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

import 'dart:math' as math;
import 'package:scidart/numdart.dart';
import 'package:scidart/scidart.dart';
import 'package:image_gallery_saver_plus/image_gallery_saver_plus.dart';

// class MemoryCache {
//   static final _cache = <String, dynamic>{};
//   bool containsKey(String key) => _cache.containsKey(key);
//   dynamic get(String key) => _cache[key];
//   void put(String key, dynamic value) => _cache[key] = value;
//   void clear() => _cache.clear();
// }

class Data {
  Data();
  @override
  String toString() {
    return 'Data';
  }

  static const String srvIp = "http://43.139.97.199/brain/api/";
  static int calculateAge(DateTime birthDate) {
    final now = DateTime.now();
    int age = now.year - birthDate.year;
    if (now.month < birthDate.month || (now.month == birthDate.month && now.day < birthDate.day)) {
      age--;
    }
    return age;
  }

  static String formatTimestamp(String timestamp) {
    if (timestamp.isEmpty) return '';

    int milliseconds = int.tryParse(timestamp) ?? 0;
    if (milliseconds == 0) return timestamp; // 如果解析失败，返回原始字符串

    DateTime dateTime = DateTime.fromMillisecondsSinceEpoch(milliseconds);
    return '${dateTime.year}年${dateTime.month.toString().padLeft(2, '0')}月${dateTime.day.toString().padLeft(2, '0')}日 '
        '${dateTime.hour.toString().padLeft(2, '0')}点${dateTime.minute.toString().padLeft(2, '0')}分${dateTime.second.toString().padLeft(2, '0')}秒${dateTime.millisecond.toString().padLeft(3, '0')}毫秒';
  }

  static Future<String> path(String fileName) async {
    if (fileName.isEmpty) {
      throw ArgumentError('文件名不能为空');
    }
    final directory = await getApplicationDocumentsDirectory();
    return '${directory.path}/$fileName';
  }

  static Future<bool> exists(String fileName) async {
    if (fileName.isEmpty) {
      throw ArgumentError('文件名不能为空');
    }
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/$fileName');
    return await file.exists();
  }

  static Future<Map<String, dynamic>> read(String jsonFileName) async {
    if (jsonFileName.isEmpty) {
      throw ArgumentError('文件名不能为空');
    }
    try {
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/$jsonFileName');
      if (await file.exists()) {
        final contents = await file.readAsString();
        return json.decode(contents);
      } else {
        return {};
      }
    } catch (e) {
      return {};
    }
  }

  static Future<List<String>> readFileList(String startKeyword) async {
    if (startKeyword.isEmpty) {
      throw ArgumentError('文件名前缀关键词不能为空');
    }
    try {
      final directory = await getApplicationDocumentsDirectory();
      // 获取目录下以start开头的的所有文件
      final files = directory.listSync().where((file) {
        return file is File && file.path.startsWith('${directory.path}/$startKeyword');
      }).toList();
      // 按文件的最后修改时间倒排
      files.sort((a, b) => b.statSync().modified.compareTo(a.statSync().modified));
      // 将文件列表转换为文件名列表
      if (files.isNotEmpty) {
        final fileNames = files.map((file) => file.path.split('/').last).toList();
        return fileNames;
      } else {
        return [];
      }
    } catch (e) {
      return [];
    }
  }

  static Future<bool> delete(String fileName) async {
    if (fileName.isEmpty) {
      throw ArgumentError('文件名不能为空');
    }
    try {
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/$fileName');
      await file.delete();
      return true;
    } catch (e) {
      return false;
    }
  }

  static Future<bool> write(Map<String, dynamic> data, String jsonFileName) async {
    if (jsonFileName.isEmpty) {
      throw ArgumentError('文件名不能为空');
    }
    try {
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/$jsonFileName');
      final jsonString = json.encode(data);
      await file.writeAsString(jsonString);
      return true;
    } catch (e) {
      return false;
    }
  }

  static List<double> calculateLFHF(List<double> hrvData) {
    if (hrvData.length < 10) {
      return [0.0, 0.0, 0.0, 0.0];
    }
    // 将HRV数据转换为数组
    ArrayComplex arrayComplex = ArrayComplex.empty();
    for (int i = 0; i < hrvData.length; i++) {
      Complex c = Complex(real: hrvData[i]);
      arrayComplex.add(c);
    }
    // 进行傅里叶变换
    ArrayComplex fftResult = fft(arrayComplex);
    // 计算频率分辨率
    double freqResolution = 1.0 / hrvData.length;
    double tp = 0.0; // 总功率（TP）
    double lf = 0.0; //低频功率（LF）
    double hf = 0.0; //高频功率（HF）
    for (int i = 0; i < fftResult.length; i++) {
      if (i * freqResolution >= 0.04 && i * freqResolution <= 0.4) {
        tp += fftResult[i].real * fftResult[i].real + fftResult[i].imaginary * fftResult[i].imaginary;
      }
      if (i * freqResolution >= 0.04 && i * freqResolution <= 0.15) {
        lf += fftResult[i].real * fftResult[i].real + fftResult[i].imaginary * fftResult[i].imaginary;
      }
      if (i * freqResolution > 0.15 && i * freqResolution <= 0.4) {
        hf += fftResult[i].real * fftResult[i].real + fftResult[i].imaginary * fftResult[i].imaginary;
      }
    }
    tp = (tp * 1000).toInt() / 1000;
    lf = (lf * 1000).toInt() / 1000;
    hf = (hf * 1000).toInt() / 1000;
    //计算 LF/HF 比值
    double lfhf = 0.0;
    if (hf > 0) {
      lfhf = lf / hf;
    }
    lfhf = (lfhf * 1000).toInt() / 1000;

    return [tp, lf, hf, lfhf];
  }

  /// 计算HRV时域指标（MV/SDNN/RMSSD）
  /// [data] 输入心率间隔数组（单位：毫秒）
  /// 返回三元数组 [平均值, 标准差, 均方根差]
  static List<double> calculate(List<double> data) {
    if (data.length < 10) {
      return [0.0, 0.0, 0.0];
    }

    ///计算平均值
    double mv = data.reduce((a, b) => a + b) / data.length;

    ///计算标准差
    double sum = 0.0;
    for (int i = 0; i < data.length; i++) {
      sum += math.pow(data[i] - mv, 2);
    }
    double sdnn = math.sqrt(sum / data.length);

    /// 计算均方根
    sum = 0.0;
    for (int i = 1; i < data.length; i++) {
      sum += math.pow((data[i] - data[i - 1]), 2);
    }
    double rmssd = math.sqrt(sum / (data.length - 1));
    //
    mv = (mv * 1000).toInt() / 1000;
    sdnn = (sdnn * 1000).toInt() / 1000;
    rmssd = (rmssd * 1000).toInt() / 1000;
    return [mv, sdnn, rmssd];
  }

  static double calculateMV(List<double> data) {
    if (data.length < 2) {
      return 0.0;
    }
    double mv = data.reduce((a, b) => a + b) / data.length;
    mv = (mv * 100).toInt() / 100;
    return mv;
  }

  static final Map<String, Map<String, String>> dataDoc = {
    'energyPsy': {
      "title": '心理能量 EPS',
      "short": "心理能量 EPS",
      "long": "心理能量 EPS",
    },
    'energyPhy': {
      "title": '生理能量 EPH',
      "short": "生理能量 EPH",
      "long": "生理能量 EPH",
    },
    'curRelax': {
      "title": '松弛感 RELAX',
      "short": "松弛感，是一场灵魂的深海潜游",
      "long": "“松弛感”是指个体在特定情境下感受到的放松和自在的程度。它反映了大脑处于一种低压力、低焦虑、高舒适度的状态。在日常生活中，当我们感到轻松、无忧无虑时，就代表处于一种“松弛感”较强的状态。松弛感是心理能量的第一要素。",
    },
    'curSharp': {
      "title": '敏锐度 SHARP',
      "short": "唤醒清醒力，掌控动态平衡",
      "long":
          "当感官褪去麻木，当直觉穿透表象，真正的敏锐力便成为连接世界的天线——它不意味着焦虑，而是让阳光下的尘埃与暗夜里的萤火都清晰可辨。在动态呼吸冥想中，您将训练大脑捕捉细微的情绪波动；通过环境音波解析课程，唤醒听觉对频率的精准解码；触觉感知矩阵则让指尖读懂温度变化的密语。这些并非超能力，而是人类与生俱来的觉察本能。",
    },
    'curFlow': {
      "title": '心流指数 FLOW',
      "short": "沉浸心流之境，唤醒内在能量",
      "long": "“心流”是指一种完全沉浸在当前活动中的状态，伴随着高度的专注、控制感和愉悦感。在这种状态下，人们会忘记时间的流逝，感到自己的能力与挑战完美匹配。这种状态由心理学家米哈里·契克森米哈赖首次提出。心流是一种心灵与身体融为一体的美好体验，一种不可多得的疗愈之力。"
    },
    'bciAtt': {
      "title": '性张力指数 ATT',
      "short": "个体身心和谐、能量充盈、情绪通达时自然散发的生命魅力。",
      "long":
          "“性张力”是指个体基于其当前生理与心理健康水平，自然外显的一种综合情绪能量场与吸引力特质。它并非单纯指向对他人的性吸引，而是根植于个体内在状态，通过情绪表达传递出的生命活力与潜在亲密可能性。生理健康（如精力水平、神经内分泌平衡）支撑起一种饱满、活跃的生命力底色，表现为自信、从容或带有热忱的存在感。"
    },
    'bciMed': {
      "title": '性压抑指数 MED',
      "short": "健康性能量流动的阻滞。",
      "long":
          "“性压抑”是指个体因内在心理冲突或外部社会压力，对自身自然性冲动、性需求或性表达进行持续性抑制或扭曲的心理状态。生理层面：性激素分泌失调、身体敏感度降低或性功能障碍；心理层面：对欲望的羞耻/恐惧、性幻想抑制、亲密关系回避；行为层面：回避性话题、僵化的道德自我审查、或过度代偿性行为（如突然纵欲）。"
    },
    'bciAp': {
      "title": '愉悦度 AP',
      "short": "越愉悦，越接纳，这是吸纳外部能量的关键时刻。",
      "state": "平常,舒心,畅快,欢喜,极乐",
      "long": "“愉悦感”是对高度安全感和高度松弛感的综合体现。是一种人与环境和谐共生的美好状态。反映一个人抵御日常负面情绪、迅速回归自我稳态平衡的速度和效率。如何帮助人们获得发自内心的喜悦之力，是几乎所有传统修行理念以及各色疗愈服务的唯一共同追求。悦己者自愈。"
    },
    'bciDelta': {
      "title": 'δ波 Delta',
      "short": "德尔塔波是一种睡眠状态时占主导的神经活动。",
      "long":
          "德尔塔波是一类极为特殊的神经活动。当我们陷入睡眠状态，大脑不再被清醒时的繁杂思绪充斥，德尔塔波便逐渐占据主导地位。它的频率极为缓慢，却蕴含着巨大的能量。这种波的产生，意味着身体已进入深度的休息阶段。在德尔塔波的作用下，心跳趋于平缓，呼吸变得深沉且均匀，肌肉也彻底放松下来。身体仿佛开启了自我修复的 “夜间工厂”，细胞加速新陈代谢，疲惫的器官得到滋养，免疫系统全力运作。德尔塔波主导的睡眠状态，是身心恢复活力、为新一天积蓄能量的关键时期 。"
    },
    'bciTheta': {
      "title": 'θ波 Theta',
      "short": "θ波是一种趋近睡眠状态时占主导的神经活动。",
      "long":
          "θ 波在趋近睡眠状态时发挥着主导作用。当夜幕降临，白日的喧嚣渐渐远去，我们的意识开始变得模糊，身体也愈发放松，此时 θ 波便悄然登场。它的频率介于 4 至 8 赫兹之间，相比清醒时的高频脑波，θ 波显得缓慢而沉稳。伴随着 θ 波的产生，我们仿佛进入了一个半梦半醒的奇妙地带。在这个状态下，身体各部分机能逐渐放缓节奏，肌肉松弛，呼吸也趋于平稳。大脑不再进行高强度的思考运算，转而开始为即将到来的深度睡眠做准备，让身心在 θ 波的轻抚下，慢慢沉浸到舒缓宁静的氛围之中，为睡眠修复之旅拉开序幕。"
    },
    'bciLowAlpha': {
      "title": '低α波 LowAlpha',
      "short": "低α波是一种处在松弛状态时占主导的神经活动。",
      "long":
          "低 α 波的频率通常在 8 至 10 赫兹之间，节奏舒缓而平稳。它的出现，如同给身心注入了一股宁静的力量。随着低 α 波的活跃，紧绷的肌肉渐渐放松，焦虑与压力悄然消散。我们的思维不再急切地追逐目标，而是变得悠然、闲适。在低 α 波主导下，身心如同进入了一片宁静港湾，享受着惬意与自在，为后续的精力恢复奠定良好基础 。"
    },
    'bciHighAlpha': {
      "title": '高α波 HighAlpha',
      "short": "高α波是一种趋近松弛状态时占主导的神经活动。",
      "long":
          "高 α 波频率大约处于 10 至 12 赫兹之间，其节奏轻快而富有韵律。此时，身体尚未完全松弛下来，但已开始感知到放松的信号。就像在繁忙工作间隙，暂时放下手头事务，靠在椅背上，轻轻闭上双眼的那一刻，高 α 波活跃起来。它促使紧绷的神经纤维逐步舒展，心跳也随之稍缓，呼吸渐趋平和。思维不再被繁杂琐事紧紧束缚，开始拥有一丝自由的灵动，为即将到来的全身心松弛状态铺就道路，引领我们走向宁静舒缓之境 。"
    },
    'bciLowBeta': {
      "title": '低β波 LowBeta',
      "short": "低β波是一种处在思虑状态时占主导的神经活动。",
      "long":
          "低 β 波是思虑状态下的显著标识。当我们陷入对问题的思索、规划未来事务，或是回忆过往经历时，低 β 波便开始在神经元之间踊跃传递。它的频率范围通常在 12 至 15 赫兹，不算太快，但充满活力。此时，大脑的不同区域协同运作，前额叶负责逻辑分析，海马体助力记忆调取。随着低 β 波的主导，我们全身心投入思考，注意力高度聚焦。身体虽保持相对静止，可大脑内部如同忙碌的蜂巢。血液加速流向大脑，为神经细胞输送充足养分，助力思维不断深入拓展，让我们在思虑的海洋中持续探索，直至梳理清思绪，找到问题的解决方向 。"
    },
    'bciHighBeta': {
      "title": '高β波 HighBeta',
      "short": "高β波是一种趋近思虑状态时占主导的神经活动。",
      "long":
          "它的频率范围大致在 15 至 30 赫兹，节奏急促且充满力量。随着高 β 波占据主导，大脑各区域迅速进入 “备战” 状态。前额叶皮质飞速运转，进行逻辑推理与决策判断；颞叶积极参与，唤起相关知识与经验。身体也会不自觉地紧绷，心跳加快，为大脑高强度的工作提供充足能量。在高 β 波的驱动下，我们的思维愈发敏捷，不断在脑海中碰撞出灵感火花，朝着解决问题、达成目标的方向全速迈进 。"
    },
    'bciLowGamma': {
      "title": '低γ波 LowGamma',
      "short": "低γ波是一种处在一般专注状态时占主导的神经活动。",
      "long":
          "低 γ 波在一般专注状态下发挥着关键的主导作用。当我们沉浸于日常事务，像阅读一本引人入胜的书籍、专注地操作电脑处理文档，又或是精心烹制一顿美食时，低 γ 波便悄然 “上岗”。它的频率通常处于 30 至 50 赫兹之间，有着平稳且有序的节奏。一旦低 γ 波占据主导，大脑便开启高效工作模式。神经元之间默契协作，信息传递迅速而精准。我们的注意力高度集中，周围的干扰被自动屏蔽，全身心投入手头之事。此时，身体维持着稳定的状态，呼吸均匀，肌肉保持适度张力，为大脑专注运行提供坚实支撑，助力我们在一般专注状态下，高效完成各项任务，达成预期目标 。"
    },
    'bciMiddleGamma': {
      "title": '中γ波 MiddleGamma',
      "short": "中γ波是一种达到高度专注状态时占主导的神经活动。",
      "long":
          "当中 γ 波在高度专注状态下闪亮登场，整个 “会场” 便会被彻底点燃。在攻克一道棘手的数学难题、精心雕琢一幅艺术画作，或者进行一场紧张激烈的竞技比赛时，中 γ 波开始发挥它的魔力。其频率范围大致在 50 至 80 赫兹，节奏紧凑且充满爆发力。中 γ 波一旦占据主导，大脑的各个区域仿佛训练有素的精锐部队，迅速进入特级战备状态。前额叶皮质全力施展逻辑分析与深度思考的能力，视觉、听觉等感官区域将信息高效传递整合。身体也进入高度协调状态，呼吸不自觉放缓，心跳却沉稳有力，源源不断地为大脑输送能量。在中 γ 波的强力驱动下，我们与专注之事融为一体，外界的一切都被隔绝，全身心沉浸在高度专注的巅峰体验中，不断突破自我，向着目标全力冲刺 。"
    },
    'bciTemperature': {
      "title": '额温 Temperature',
      "short": "反应当前体温，一般比标准体温低1~2度。",
      "long":
          "人体体温是反映健康状况的重要指标，而额温作为常用的体温测量方式之一，有着独特的特性。额头部位暴露在外，其温度受外界环境影响较大。额温所反应的当前体温，一般情况下会比标准体温低 1 至 2 度。这是因为额头皮肤直接与空气接触，热量容易散失。比如在正常的室内环境下，使用额温枪测量，得出的数值通常会低于口腔或腋下测量的标准体温。不过，这一差值并非固定不变，在寒冷的室外，差值可能更大；而在闷热的环境里，差值或许会有所缩小。但总体而言，了解额温与标准体温的这一关系，能帮助我们更准确地解读体温数据，及时察觉身体的异常状况 。"
    },
    'bciHeartRate': {
      "title": '心率 HeartRate',
      "short": "心跳是驱动生命活力的核心机制，55~75bpm的平稳静息心率是释放生命能量的最佳状态。",
      "long":
          "心跳，宛如生命乐章中那激昂而又稳健的鼓点，是驱动生命活力的核心机制。从生命最初的萌芽开始，心脏便不知疲倦地跳动，它如同一位忠诚的卫士，为全身各个器官与组织源源不断地输送着饱含氧气与营养的血液。在众多心率数值中，55 至 75bpm 的平稳静息心率堪称释放生命能量的最佳状态。当心率处于这一区间，心脏无需过度操劳，却能高效地完成血液循环任务。身体的新陈代谢有条不紊地进行，各个细胞如同被精准调校的机器部件，活力满满地运转。在这样的心率下，我们会感到精力充沛，思维清晰，无论是应对日常工作，还是投入休闲活动，都能轻松胜任，尽情释放生命蕴含的无限能量，享受健康活力的生活。"
    },
    'bciHrv': {
      "title": '心率变异性 HRV',
      "short": "HRV（心率变异性）：副交感神经活性指标。",
      "long":
          "NN50是HRV时域分析中的一个指标，表示相邻两次正常心动周期（NN间期）之间的差值大于50毫秒的次数比例。NN50常用于评估副交感神经的活性状态，特别是在短时HRV分析中。是将个体从警觉和兴奋中迅速解放出来、为下一次行动积蓄力量的内在机制。\nLF/HF是HRV频域分析指标，表示低频功率（LF, 0.04~0.15 Hz）与高频功率（HF, 0.15~0.4 Hz）的比值，一般在0~5之间，1~3属于常见范围，低于1常见于运动员群体，高于3则需引起重视。LF/HF比值的变化可以反映交感神经和副交感神经的平衡状态，特别是在应激反应、情绪调节和心血管健康研究中有明确意义。"
    },
    'bciGrind': {
      "title": '咬牙',
      "short": "可用于控制音乐。",
      "long": "可用于控制音乐。",
    },
  };

  // static Future<String> generateAiText(String prompt) async {
  //   if (prompt == "") {
  //     return "";
  //   }
  //   final response = await http.post(
  //     Uri.parse('https://api.deepseek.com/chat/completions'),
  //     headers: {
  //       'Content-Type': 'application/json; charset=UTF-8',
  //       'Authorization': 'Bearer sk-a7170a19070b426683827950e06a0dfa',
  //     },
  //     body: jsonEncode({
  //       'model': 'deepseek-chat',
  //       'messages': [
  //         {
  //           'role': 'system',
  //           'content': '''
  //               你是一位专业的心理和情绪分析疗愈师，我现在给你几项用户数据，需要你以这些数据为基础，发挥你心理分析和疗愈上的专业优势，为客户在1.心理层面2.因心理问题可引发的对生理的影响，这两个维度上输出个性化分析和日常建议的报告。
  //               我给你的用户数据是经由脑机接口设备采集并计算得到的数据，包含安全感、专注度、心流指数、松弛感、愉悦感、心率变异性NN50和LF/HF（其中LF/HF值越低越好，其他数值都是越高越好）。这些数据均以百分比表示。
  //               该分析和建议报告分为四段，第一段为情绪和心理解读，第二段为因心理问题可引发的生理问题的分析，第三段为日常调节心理和生理的建议，包含情绪训练、生理锻炼、饮食调节、生活方式调节等，最后第四段以通用的内容结尾：“另外，也建议您与专业咨询/疗愈师沟通，以获得针对您的个性化解决方案。祝您健康幸福！”
  //               整体文字数量控制在不超过800字，文字的风格要阳光积极正面，体现对用户的关怀，传递温度，具有亲和力和感染力，段落标题里禁止出现#号*号等各种markdown格式原有的标识符号。
  //               '''
  //         },
  //         {'role': 'user', 'content': prompt},
  //       ],
  //       'stream': false,
  //     }),
  //   );

  //   if (response.statusCode == 200) {
  //     final data = jsonDecode(utf8.decode(response.bodyBytes));
  //     String res = data['choices'][0]['message']['content'];
  //     res = res.replaceAll('**', '');
  //     return res;
  //   } else {
  //     throw Exception('Failed to generate AI text');
  //   }
  // }

  static Future<String> generateAiText(String bot, String prompt, String bearer) async {
    if (bot == "" || prompt == "" || bearer == "") {
      return "";
    }
    final client = http.Client();
    try {
      final request = http.Request('POST', Uri.parse('https://api.coze.cn/v3/chat?'));
      request.headers.addAll({
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $bearer',
      });
      request.body = jsonEncode({
        "bot_id": bot, //"7536880378519339044"
        "user_id": "${DateTime.now().millisecondsSinceEpoch}",
        "stream": true,
        "additional_messages": [
          {"role": "user", "content": prompt, "content_type": "text", "type": "question"}
        ]
      });

      final response = await client.send(request);
      await for (var chunk in response.stream.transform(utf8.decoder)) {
        List<String> lines = chunk.trim().split('\n');
        for (var line in lines) {
          if (line.startsWith('data:')) {
            String jsonData = line.substring(5);
            Map<String, dynamic> data = jsonDecode(jsonData);
            if (data.isNotEmpty && data.containsKey('type') && data['type'] == 'answer' && data.containsKey('content') && data['content'].length > 100) {
              return data['content'];
            }
          }
        }
      }
      return "";
    } finally {
      client.close();
    }
  }

  static Future<String> generateAiImage(String bot, String prompt, String bearer) async {
    if (bot == "" || prompt == "" || bearer == "") {
      return "";
    }
    final client = http.Client();
    try {
      final request = http.Request('POST', Uri.parse('https://api.coze.cn/v3/chat?'));
      request.headers.addAll({
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $bearer',
      });
      request.body = jsonEncode({
        "bot_id": bot,
        "user_id": "${DateTime.now().millisecondsSinceEpoch}",
        "stream": true,
        "additional_messages": [
          {"role": "user", "content": prompt, "content_type": "text", "type": "question"}
        ]
      });
      final response = await client.send(request);
      await for (var chunk in response.stream.transform(utf8.decoder)) {
        List<String> lines = chunk.trim().split('\n');
        for (var line in lines) {
          if (kDebugMode) {
            print(line);
          }
          if (line.startsWith('data:')) {
            String jsonData = line.substring(5);
            Map<String, dynamic> data = jsonDecode(jsonData);
            if (data.containsKey('type') && data['type'] == 'answer' && data.containsKey('content') && data['content'].length > 20) {
              RegExp urlRegex = RegExp(r'https?://[^\s]+');
              Match? match = urlRegex.firstMatch(data['content']);
              String imgUrl = match?.group(0) ?? '';
              if (imgUrl.isNotEmpty) {
                return imgUrl;
              }
            }
          }
        }
      }
      return "";
    } finally {
      client.close();
    }
  }

  // static Future<void> downloadAndSaveImage(String imageUrl, String savePath) async {
  //   if (imageUrl.isEmpty || savePath.isEmpty) {
  //     return;
  //   }
  //   try {
  //     // 发送HTTP GET请求获取图片数据
  //     final response = await http.get(Uri.parse(imageUrl));
  //     if (response.statusCode == 200) {
  //       // 将图片数据写入文件
  //       final file = File(savePath);
  //       await file.writeAsBytes(response.bodyBytes);
  //       if (kDebugMode) {
  //         print('图片保存成功: $savePath');
  //       }
  //     } else {
  //       if (kDebugMode) {
  //         print('图片下载失败，状态码: ${response.statusCode}');
  //       }
  //     }
  //   } catch (e) {
  //     if (kDebugMode) {
  //       print('图片下载或保存过程中发生错误: $e');
  //     }
  //   }
  // }

  static Future<bool> downloadAndSaveImage(String imageUrl, String savePath) async {
    if (imageUrl.isEmpty || savePath.isEmpty) return false;
    try {
      final dio = Dio(BaseOptions(
          connectTimeout: const Duration(seconds: 5),
          receiveTimeout: const Duration(seconds: 15),
          persistentConnection: true,
          headers: {'Cache-Control': 'no-cache', 'Pragma': 'no-cache'}));
      await dio.download(
        imageUrl,
        savePath,
        deleteOnError: true,
        onReceiveProgress: (received, total) {
          // 进度回调（可选）
        },
      );
      showSnackbar("成功", "图片已成功下载到本机", ThemeData().colorScheme.primary);
      return true;
    } catch (e) {
      debugPrint('下载异常: \$e');
      return false;
    }
  }

  static Future<bool> saveImageToGallery(String imagePath) async {
    try {
      final result = await ImageGallerySaverPlus.saveFile(imagePath);
      if (result['isSuccess']) {
        //showSnackbar("成功", "图片成功写入设备相册", ThemeData().colorScheme.primary);
        return true;
      } else {
        //showSnackbar("失败", "图片写入设备相册失败", colorError);
        return false;
      }
    } catch (e) {
      //showSnackbar("错误", "图片写入相册时发生错误", colorError);
      return false;
    }
  }

  /// 趋势显著度数据结构
  // Map<String, dynamic> trendSign = {
  //   "trend": 0, //0持平,1升高，-1降低
  //   "deepth": 1, //深度
  //   "activity": 0.0, //活跃度
  //   "sign": 0.0, //显著度dv/mv
  //   "length": 2, //总样本量,2为最小单位，之上为4，8，16等2的n次方
  //   "mv": 0.0, //整体均值
  //   "dv": 0.0, //左右差值
  //   "left": {}, //左侧子项，递归嵌套
  //   "right": {}, //右侧子项，递归嵌套
  // };
  static const List<int> sampleSize = [4096, 2048, 1024, 512, 256, 128, 64, 32, 16, 8, 4, 2];
  static const List<String> sampleSizeTitle = ["约需80分钟", "约需40分钟", "约需20分钟", "约需10分钟", "约需5分钟", "约需3分钟"];
  static const List<String> sampleSizeModel = ["浅睡", "小憩", "正念", "感官", "呼吸", "静息"];
  static int trendSignLength(int length) {
    for (final temp in sampleSize) {
      if (length >= temp) {
        return temp;
      }
    }
    return 0;
  }

  /// 趋势显著度算法，递归函数
  static Map<String, dynamic> calculateTrendSign(List<double> data) {
    if (data.length < 2) {
      return {};
    }
    List<double> dataTemp = data.sublist(0, trendSignLength(data.length));
    if (dataTemp.length == 2) {
      //合并结果
      double sv = dataTemp.first + dataTemp.last;
      //计算整体均值
      double mv = sv / 2;
      //计算左右差值
      double dv = dataTemp.last - dataTemp.first;
      //计算显著度
      double sign = (dv == 0 || sv == 0) ? 0.001 : dv / sv;
      //判断趋势
      int trend = sign > 0.001
          ? 1
          : sign < -0.001
              ? -1
              : 0;
      //计算活跃度
      double activity = sign.abs();
      return {
        "trend": trend,
        "deepth": 1,
        "activity": activity,
        "sign": sign,
        "length": 2,
        "mv": mv,
        "dv": dv,
        "left": {"mv": dataTemp.first},
        "right": {"mv": dataTemp.last},
      };
    }
    //递归计算左侧子项
    Map<String, dynamic> left = calculateTrendSign(dataTemp.sublist(0, dataTemp.length ~/ 2));
    //递归计算右侧子项
    Map<String, dynamic> right = calculateTrendSign(dataTemp.sublist(dataTemp.length ~/ 2));
    //合并结果
    double sv = (left["mv"] + right["mv"]);
    //计算整体均值
    double mv = sv / 2;
    //计算左右差值
    double dv = right["mv"] - left["mv"];
    //计算显著度
    double sign = (dv == 0 || sv == 0) ? 0.001 : dv / sv;
    //判断趋势
    int trend = sign > 0.001
        ? 1
        : sign < -0.001
            ? -1
            : 0;
    //计算深度
    int deepth = 1;
    if ((trend == left["trend"] && trend == right["trend"]) ||
        (trend == 0 && left["trend"] == right["trend"]) ||
        (right["trend"] == 0 && trend == left["trend"]) ||
        (left["trend"] == 0 && trend == right["trend"])) {
      deepth = left["deepth"] > right["deepth"] ? left["deepth"] + 1 : right["deepth"] + 1;
    }
    //计算活跃度
    double activity = (1 + sign.abs()) * (left["activity"] + right["activity"]) / 2;
    return {
      "trend": trend,
      "deepth": deepth,
      "activity": activity,
      "sign": sign,
      "length": dataTemp.length,
      "mv": mv,
      "dv": dv,
      "left": left,
      "right": right,
    };
  }

  static Map<String, dynamic> sign8(List<double> data) {
    if (data.length != 8) {
      return {};
    }
    Map<String, dynamic> result = calculateTrendSign(data);
    return {
      "trend": result["trend"],
      "deepth": result["deepth"],
      "activity": result["activity"],
      "sign": result["sign"],
      "mv": result["mv"],
      "dv": result["dv"],
    };
  }

  static Map<String, dynamic> sign128(List<double> data) {
    if (data.length != 128) {
      return {};
    }
    Map<String, dynamic> result = {
      "trend": [],
      "deepth": [],
      "activity": [],
      "maxActivity": 0.0,
      "maxActivityIndex": 0,
      "minActivity": 0.0,
      "minActivityIndex": 0,
      "sign": [],
      "maxSign": 0.0,
      "maxSignIndex": 0,
      "minSign": 0.0,
      "minSignIndex": 0,
      "mv": [],
      "dv": [],
    };
    for (int i = 0; i < 16; i++) {
      List<double> subData = data.sublist(i * 8, i * 8 + 8);
      Map<String, dynamic> subResult = sign8(subData);
      result["trend"].add(subResult["trend"]);
      result["deepth"].add(subResult["deepth"]);
      result["activity"].add(subResult["activity"]);
      result["sign"].add(subResult["sign"]);
      result["mv"].add(subResult["mv"]);
      result["dv"].add(subResult["dv"]);
      if (i == 0) {
        result["maxActivity"] = subResult["activity"];
        result["maxActivityIndex"] = 0;
        result["minActivity"] = subResult["activity"];
        result["minActivityIndex"] = 0;
        result["maxSign"] = subResult["sign"];
        result["maxSignIndex"] = 0;
        result["minSign"] = subResult["sign"];
        result["minSignIndex"] = 0;
      } else {
        if (subResult["activity"] > result["maxActivity"]) {
          result["maxActivity"] = subResult["activity"];
          result["maxActivityIndex"] = i;
        }
        if (subResult["activity"] < result["minActivity"]) {
          result["minActivity"] = subResult["activity"];
          result["minActivityIndex"] = i;
        }
        if (subResult["sign"] > result["maxSign"]) {
          result["maxSign"] = subResult["sign"];
          result["maxSignIndex"] = i;
        }
        if (subResult["sign"] < result["minSign"]) {
          result["minSign"] = subResult["sign"];
          result["minSignIndex"] = i;
        }
      }
    }
    return result;
  }

  static String qian(double value) {
    if (value <= 0.5) {
      return "潜龙";
    }
    if (value <= 1) {
      return "见龙";
    }
    if (value <= 1.5) {
      return "君子";
    }
    if (value <= 2) {
      return "或跃";
    }
    if (value <= 2.5) {
      return "飞龙";
    }
    return "亢龙";
  }

  static final Map<String, dynamic> settings = {"sampleSize": sampleSize[5], "title": sampleSizeTitle[5], "model": sampleSizeModel[5]};

  static final Map<String, Map<String, dynamic>> apps = {
    "heartRate": {
      "isSelected": true,
      "icon": Icons.favorite_border_rounded,
      "title": "心率",
      "subtitle": "心率监测",
    },
    "hrv": {
      "isSelected": true,
      "icon": Icons.heart_broken_rounded,
      "title": "HRV",
      "subtitle": "心率变异性监测",
    },
    "temperature": {
      "isSelected": true,
      "icon": Icons.thermostat_rounded,
      "title": "额温",
      "subtitle": "额温监测",
    },
  };

  static Future<void> apiTest(String phone, String password) async {
    final dio = Dio();
    try {
      final response = await dio.get('http://43.139.97.199/brain/api/test/');
      if (kDebugMode) {
        print('Response: ${response.data}');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error: $e');
      }
    }
  }
}

void showSnackbar(String title, String message, Color backgroundColor) {
  Get.snackbar(
    title,
    message,
    backgroundColor: backgroundColor,
    colorText: ThemeData().colorScheme.primaryContainer,
    snackPosition: SnackPosition.BOTTOM,
    margin: const EdgeInsets.all(10),
  );
}

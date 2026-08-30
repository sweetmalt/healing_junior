# healing_junior

基于多模头带的脑机接口 Flutter 应用。

## 硬件协议（多模头带）

> 详细字段定义见供应商文档《多模头带串口协议解析说明》。
> 以下为 App 实现侧的关键摘要。

### 串口参数

| 项目 | 参数 |
|---|---|
| 波特率 | 57600 |
| 数据位 | 8 |
| 校验位 | None |
| 停止位 | 1 |
| 数据类型 | HEX 字节流 |
| 解析方式 | 按字节状态机解析 |

### 公共帧格式

```
AA 55 LEN [Payload] Checksum
```

| 字段 | 长度 | 说明 |
|---|---|---|
| AA | 1 字节 | 帧头 1 |
| 55 | 1 字节 | 帧头 2 |
| LEN | 1 字节 | Payload 长度 |
| Payload | LEN 字节 | 有效数据 |
| Checksum | 1 字节 | `sum(Payload) & 0xFF`，**仅算 Payload** |

### 包类型

| Type | LEN | Payload 长度 | 整包长度 | 作用 | 默认频率 |
|---|---|---|---|---|---|
| `0x01` | `0x22` | 34 字节 | 38 字节 | 融合数据包（TGAM + 心率 + 血氧 + 额温 + 电池） | 约 1.1 秒/包 |
| `0x02` | `0x11` | 17 字节 | 21 字节 | 六轴数据包（MPU6050 加速计/陀螺仪） | 200Hz |

### 融合数据包 Payload 字段定义

| 偏移 | 长度 | 字段 | 类型 | 说明 |
|---|---|---|---|---|
| 0 | 1 | PacketType | uint8 | 固定 `0x01` |
| 1 | 1 | Signal | uint8 | 佩戴状态（详见下表） |
| 2-4 | 3 | Delta | uint24 BE | Delta 脑波功率 |
| 5-7 | 3 | Theta | uint24 BE | Theta 脑波功率 |
| 8-10 | 3 | LowAlpha | uint24 BE | 低 Alpha |
| 11-13 | 3 | HighAlpha | uint24 BE | 高 Alpha |
| 14-16 | 3 | LowBeta | uint24 BE | 低 Beta |
| 17-19 | 3 | HighBeta | uint24 BE | 高 Beta |
| 20-22 | 3 | LowGamma | uint24 BE | 低 Gamma |
| 23-25 | 3 | MiddleGamma | uint24 BE | 中 Gamma |
| 26 | 1 | AttentionCode | uint8 | 固定 `0x04` |
| 27 | 1 | Attention | uint8 | 专注度 0~100 |
| 28 | 1 | MeditationCode | uint8 | 固定 `0x05` |
| 29 | 1 | Meditation | uint8 | 放松度 0~100 |
| 30 | 1 | HeartRate | uint8 | 心率 bpm |
| 31 | 1 | SpO2 | uint8 | 血氧 % |
| 32 | 1 | ForeheadTemp | uint8 | 额温 ℃ |
| 33 | 1 | Battery | uint8 | 电池 0~100% |

App 在解析时把 `LowAlpha+HighAlpha`、`LowBeta+HighBeta`、`LowGamma+MiddleGamma` 合成后存入
`alpha` / `beta` / `gamma`，下游消费者（waves/baseline/bci/trend）拿到的就是聚合波段。

### Signal 显示规则建议（4 档）

| Signal 值 | 文案 |
|---|---|
| 0 | 佩戴良好 |
| 1~100 | 接触轻微不良 / 晃动 |
| 101~199 | 接触不良 |
| 200 | 未佩戴 / 空闲 |

### 六轴数据包

App **不消费**六轴数据（解析后直接丢弃），因此本项目不展开字段细节。
如需扩展（例如姿态检测），请在 `MultimodalHeadbandParser._parseImuPacket` 中实现。

### App 侧架构

- `MultimodalHeadbandParser`：状态机按字节解析，校验通过后分发到融合包/六轴包处理；
  - LEN 仅接受 `0x22` / `0x11`，非法值立即回到 `WAIT_AA`；
  - Checksum = `sum(Payload) & 0xFF`，失败立即回到 `WAIT_AA`。
- `EEGController`：收到融合包即调用 `MyCtrl.pushData([att, med, delta, theta, alpha, beta, gamma])`，
  **每包一推**，无定时器窗口。
- `BluetoothView`：详细数据展示页面，按上述字段呈现。
- `BluetoothAdmin`：设备扫描 / 连接 / 断开管理页。

### 设备识别

App 通过 BLE 扫描时按设备名前缀 `HR-` 过滤目标设备。

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

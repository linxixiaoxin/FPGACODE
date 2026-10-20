# AxisesCTRL 技术文档索引

> **项目**: 四轴伺服驱动器 FPGA  
> **器件**: Anlogic EG4X20BG256  
> **工具链**: Tang Dynasty v5.6.59063  
> **文档版本**: v1.0 | 2026-05-07

---

## 文档列表

| 编号 | 文档 | 涉及模块 | 关键内容 |
|------|------|---------|---------|
| 00 | [技术架构分析文档](技术架构分析文档.md) | 全系统 | 产品概述、工程结构、模块层次树、寄存器地址映射总览 |
| 01 | [时钟与复位系统](01_时钟与复位系统技术开发文档.md) | SysPLL, ESCPLL, AnlogicPLL | PLL配置、三路时钟域、复位层次、跨域同步策略 |
| 02 | [总线互连系统](02_总线互连系统技术开发文档.md) | BusInterconnecter, MultiAccessPreDeal, AccessLocalspcae | 双主仲裁、地址译码、Renesas/STM32/SPI接口时序 |
| 03 | [FOC电流控制器](03_FOC电流控制器技术开发文档.md) | AxisesCurrentCtrler, ArithmeticScheduler, VectorCtrler | Clarke/Park变换、PI控制器、电压圆限制、SVPWM、CORDIC |
| 04 | [电流采样系统](04_电流采样系统技术开发文档.md) | CurrentSample, ADCsDriver, Sinc3Driver | Σ-Δ ADC、Sinc3滤波器算法、W相推导、ACR锁存、过流检测 |
| 05 | [位置检测系统](05_位置检测系统技术开发文档.md) | PositionDetection, ABZDriver, LiteBISSCProtocol, LiteDMCProtocol | ABZ/BISS-C/DMC编码器协议、电气角度计算、CORDIC sin/cos |
| 06 | [PWM载波与生成](06_PWM载波与生成技术开发文档.md) | CarrierModule, CarrierGen, PwmGen | 8kHz中心对齐载波、死区插入、窄脉冲抑制、触发信号时序 |
| 07 | [安全监控系统](07_安全监控系统技术开发文档.md) | SafetyMonitor, RegSpcae_SafetyMonitor | IPM故障/过流检测、故障锁存、看门狗、PWMUNLOCK逻辑 |
| 08 | [Zlink通信协议](08_Zlink通信协议技术开发文档.md) | ZlinkslavestationShell, Zlinkslavestation, PHY驱动 | 菊花链拓扑、在线读取、CRC32、RMII PHY管理、子报文协议 |
| 09 | [辅助信号采集](09_辅助信号采集与保留空间技术开发文档.md) | UnrelatedSigSample, DriversMux, LiteDMCProtocol_Monitor | VBUS采样、数字IO、DMC被动监听、保留RAM空间 |
| 10 | [系统顶层集成](10_系统顶层集成技术开发文档.md) | AppEnvironment, FourAxisesDriver | 引脚映射、信号互联矩阵、硬件版本切换检查清单 |

---

## 系统架构速览

```
AppEnvironment (FPGA顶层 — 引脚边界)
└── FourAxisesDriver (内部顶层)
    ├── SysPLL          → 50/100/20MHz + 同步复位
    ├── BusInterconnecter → 双主×8从 寄存器总线
    │   ├── Master1: Renesas异步总线 / STM32 FSMC / SPI
    │   └── Master2: UDP/RMII / Zlink / UART调试
    ├── CarrierModule   → 8kHz PWM载波 + 触发信号
    ├── CurrentSample   → Σ-Δ ADC + Sinc3 × 8通道
    ├── PositionDetection → ABZ/BISS-C/DMC × 4轴
    ├── AxisesCurrentCtrler → FOC电流环 × 4轴
    ├── SafetyMonitor   → 故障检测 + PWM安全控制
    ├── UnrelatedSigSample → VBUS + 数字IO + DMC监听
    └── Reservespace    → 调试RAM
```

## 关键参数速查

| 参数 | 值 |
|------|-----|
| PWM频率 | 8 kHz |
| 主时钟 | 100 MHz |
| ADC时钟 | 20 MHz |
| 死区时间 | 2 μs |
| 最小脉宽 | 4 μs |
| 单轴FOC计算时间 | ~0.21 μs |
| 看门狗默认周期 | 1000 μs |
| 总线地址宽度 | 16-bit (字地址) |
| 数值格式 | Q15 有符号 16-bit |

## 全局寄存器地址映射

| 地址范围 | 模块 | 文档 |
|---------|------|------|
| `0x0000 – 0x00FF` | Reservespace | [09](09_辅助信号采集与保留空间技术开发文档.md) |
| `0x0100 – 0x01FF` | CurrentSample | [04](04_电流采样系统技术开发文档.md) |
| `0x0200 – 0x02FF` | PositionDetection | [05](05_位置检测系统技术开发文档.md) |
| `0x0300 – 0x06FF` | AxisesCurrentCtrler | [03](03_FOC电流控制器技术开发文档.md) |
| `0x0700 – 0x077F` | CarrierModule | [06](06_PWM载波与生成技术开发文档.md) |
| `0x0780 – 0x07FF` | UnrelatedSigSample | [09](09_辅助信号采集与保留空间技术开发文档.md) |
| `0x0800 – 0x087F` | SafetyMonitor | [07](07_安全监控系统技术开发文档.md) |
| `0x0880 – 0x08FF` | OverAllControl (预留) | — |

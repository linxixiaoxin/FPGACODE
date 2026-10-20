# 06 — PWM载波与生成技术开发文档

> **所属项目**: AxisesCTRL (四轴伺服驱动器 FPGA)  
> **涉及目录**: `CarrierModule/`  
> **关键模块**: CarrierModule, CarrierGen, PwmGen, RegSpcae_CarrierModule

---

## 1. 模块概述

PWM载波与生成模块产生中心对齐的三角载波、时序触发信号，以及每轴独立的六路互补PWM门极驱动信号（带死区插入和窄脉冲抑制）。

### 1.1 设计指标

| 参数 | 值 | 说明 |
|------|-----|------|
| PWM载波频率 | 8 kHz | 125 μs 全周期 |
| 载波类型 | 中心对齐 (三角波) | 对称增减计数 |
| 计数精度 | 16-bit | 12500 counts / 半周期 |
| 死区时间 | 2 μs | 200 clk @ 100MHz |
| 最小脉宽 | 4 μs | 400 clk @ 100MHz |
| PWM通道数 | 24路 (4轴 × 6路) | U_P/U_N/V_P/V_N/W_P/W_N |

### 1.2 模块层次

```
CarrierModule.v
├── RegSpcae_CarrierModule.v     ← 寄存器接口 (4个控制寄存器)
├── CarrierGen.v                 ← 载波计数器 + 触发信号生成
└── PwmGen.v ×4                  ← 单轴PWM生成 (每个轴1个实例)
```

---

## 2. 载波生成 (CarrierGen.v)

### 2.1 核心计数器

```verilog
parameter CNTPeriod = 16'd6249;  // 半周期计数值

// 增减计数 (中心对齐三角波)
// 0 → 1 → ... → 6249 → 6248 → ... → 1 → 0 → ...

reg [15:0] CounterCNT;   // 当前计数值
reg        CounterDIR;   // 0=递增, 1=递减

always @(posedge clk or negedge rst) begin
    if (!rst) begin
        CounterCNT <= 0;
        CounterDIR <= 0;
    end else begin
        if (CounterDIR == 0) begin  // 递增阶段
            if (CounterCNT == CNTPeriod)
                CounterDIR <= 1;     // 到达顶点 → 递减
            else
                CounterCNT <= CounterCNT + 1;
        end else begin               // 递减阶段
            if (CounterCNT == 0)
                CounterDIR <= 0;     // 到达零点 → 递增
            else
                CounterCNT <= CounterCNT - 1;
        end
    end
end
```

### 2.2 载波波形

```
CounterCNT
  6249 ┤     ┌──────┐     ┌──────┐
       │    /│      │\    /│      │\
       │   / │      │ \  / │      │ \
       │  /  │      │  \/  │      │  \
     0 ┤─┘   └──────┘      └──────┘   └──

时间:   ├─ 62.5μs ─┤├─ 62.5μs ─┤
        ├────── 125μs (8kHz) ──────┤
```

### 2.3 触发信号时序

```
CounterCNT
  6249 ┤           ┌──────┐
       │          /        \              PeriodTrig (峰值)
       │         /          \              ↑
  5999 ┤- - - - ├- - - - - -┤- - - - -    ACRTrig (提前250clk = 2.5μs)
       │       /              \           ↑
       │      /                \
   250 ┤- - ├- - - - - - - - - ├- - - -   ACRTrig (提前250clk)
       │   /                    \         ↑
     0 ┤──┘                      └────── ZEROTrig (谷值)
                                          ↑
```

### 2.4 触发信号生成逻辑

```verilog
// ACRTrig: 在极值前 ACRTrigLead=250 个时钟触发
// 递增阶段: CounterCNT == CNTPeriod - 250
// 递减阶段: CounterCNT == 250
wire ACRTrig_pre = (CounterDIR==0 && CounterCNT == CNTPeriod - 250) ||
                   (CounterDIR==1 && CounterCNT == 250);

// 极值脉冲
assign ZeroPluse   = (CounterCNT == 0)     && (CounterDIR == 1);
assign PeriodPluse = (CounterCNT == CNTPeriod) && (CounterDIR == 0);

// 编码器触发 = 在任意极值触发
assign EncoderTrig = ZeroPluse || PeriodPluse;

// 中断输出: 极值处低电平, 保持990ns后恢复高电平
// INTPluseHoldTime = 99 (990ns @ 100MHz)
```

### 2.5 触发信号使用者

| 信号 | 使用者 | 用途 |
|------|--------|------|
| `ACRTrig` | CurrentSample (ACRLockTrig), PositionDetection (TimeCriticalPluse) | 电流锁存、FOC启动 |
| `EncoderTrig` | PositionDetection (RequestTrig) | 编码器位置读取 |
| `ZEROTrig` | BusInterconnecter (DealBaseTrig，与PeriodTrig OR) | 调试帧触发 |
| `PeriodTrig` | BusInterconnecter (DealBaseTrig) | 调试帧触发 |
| `INTOut` | MCU (INT2MCU) | 同步中断 |

---

## 3. PWM生成 (PwmGen.v) — 单轴

### 3.1 接口

| 端口 | 方向 | 位宽 | 描述 |
|------|------|------|------|
| `CounterCNT[15:0]` | in | 16 | 共享载波计数值 |
| `CounterDIR` | in | 1 | 载波方向 |
| `CounterPeriod[15:0]` | in | 16 | = 6249 |
| `ZeroPluse / PeriodPluse` | in | 1 | 占空比更新同步信号 |
| `PWMUNLOCK` | in | 1 | 安全解锁 (来自SafetyMonitor) |
| `PWMEN` | in | 1 | PWM使能 |
| `BootstrapInit` | in | 1 | 引导加载模式 |
| `DutyA/B/C[15:0]` | in | 16 | 占空比值 Q15 |
| `PWMU_P/N, PWMV_P/N, PWMW_P/N` | out | 1 | 6路PWM输出 |

### 3.2 占空比→比较值转换

```verilog
// DutyX: [0, 1) Q15格式
// CMPX: 比较值 = CounterPeriod - DutyX × CounterPeriod
//
// 物理含义:
//   DutyX = 0.0 → CMPX = 6249 (最小占空比 = 最小脉宽限制)
//   DutyX = 0.5 → CMPX = 3125 (50%占空比)
//   DutyX = 1.0 → CMPX = 0   (最大占空比 = 最大脉宽限制)

CMPX = CounterPeriod - DutyX;
```

### 3.3 死区时间插入

```verilog
// 死区时间参数
parameter DeadTime = 200;           // 2μs = 200 clk
parameter DeadTime_half = 100;      // 半死区 = 1μs
parameter MinPulseWidth = 400;      // 最小脉宽 = 4μs
parameter MinPulseWidth_half = 200; // 半最小脉宽 = 2μs

// 限幅范围
CMPMAX = CounterPeriod - MinPulseWidth_half - DeadTime_half;  // = 6249-200-100 = 5949
CMPMIN = MinPulseWidth_half + DeadTime_half;                   // = 200+100 = 300

// 限幅后的比较值
CMPX_limited = clamp(CMPX, CMPMIN, CMPMAX);

// 死区偏移
CMPXH_Act = CMPX_limited + DeadTime_half;  // 高边: 延迟100clk导通
CMPXL_Act = CMPX_limited - DeadTime_half;  // 低边: 提前100clk导通
```

### 3.4 PWM输出逻辑

```verilog
// U相高边: 计数器 > 高比较值时导通
PWMU_P = (CounterCNT > CMPUH_Act) ? 1'b1 : 1'b0;

// U相低边: 计数器 < 低比较值时导通
PWMU_N = (CounterCNT < CMPUL_Act) ? 1'b1 : 1'b0;

// V相、W相同理
```

### 3.5 PWM波形示意

```
CounterCNT
  CMPMAX ┤───────────────────────────────
         │         ┌──────┐
  CMPXH  │- - - - ├- - - ┤- - - - - -
         │        /│      │\
  CMPX   │- - - ─┤─      ─┤- - - - - -
         │      /  │      │  \
  CMPXL  │- - ├- - ┤- - - ┤- - - - - -
         │   /     │      │     \
  CMPMIN ┤──┘      │      │      └──────
         │         │      │
      0  ┤─────────┘      └──────────────

PWMU_P  ─────┐     ┌──────────────┐
             └─────┘              └────────  高边导通

PWMU_N  ───────────────┐     ┌──────────────
                       └─────┘              低边导通

         ├─DeadTime─┤                     ← 死区区间
```

### 3.6 安全覆盖逻辑

```verilog
// 优先级: PWMUNLOCK > BootstrapInit > PWMEN > 正常PWM

if (!PWMUNLOCK) begin
    // 最高优先级: 安全锁止
    {PWMU_P, PWMU_N, PWMV_P, PWMV_N, PWMW_P, PWMW_N} = 6'b000000;
end else if (BootstrapInit) begin
    // 引导加载: 所有下管导通, 上管关断
    {PWMU_P, PWMU_N, PWMV_P, PWMV_N, PWMW_P, PWMW_N} = 6'b010101;
end else if (!PWMEN) begin
    // PWM未使能: 全部关断
    {PWMU_P, PWMU_N, PWMV_P, PWMV_N, PWMW_P, PWMW_N} = 6'b000000;
end else begin
    // 正常PWM输出
    按比较结果正常驱动
end
```

### 3.7 占空比更新同步

```verilog
// 在载波极值处 (ZeroPluse 或 PeriodPluse) 更新占空比值
// 这确保了:
// 1. PWM波形对称
// 2. 不在PWM周期中间改变占空比, 避免诡异脉冲

always @(posedge clk) begin
    if (ZeroPluse || PeriodPluse) begin
        CMPU <= CMPU_limited;
        CMPV <= CMPV_limited;
        CMPW <= CMPW_limited;
    end
end
```

### 3.8 CalEN逻辑

```verilog
// 当PWM使能且不在引导加载时, 允许FOC计算
assign CalEN = PWMEN && !BootstrapInit;

// CalEN=0时, FOC输出的占空比被强制归零
```

---

## 4. 载波模块顶层 (CarrierModule.v)

### 4.1 四轴实例化

```verilog
CarrierGen CarrierGen_inst (
    .clk(clk), .rst(rst),
    .CounterCNT(CounterCNT),
    .CounterDIR(CounterDIR),
    .CounterPeriod(CounterPeriod),
    .ZeroPluse(ZeroPluse), .PeriodPluse(PeriodPluse),
    .ACRTrig(ACRTrig), .EncoderTrig(EncoderTrig),
    .INTOut(INTOut)
);

// 每轴独立的PwmGen实例
genvar i;
generate
    for (i = 0; i < 4; i = i + 1) begin
        PwmGen PwmGen_inst (
            .CounterCNT(CounterCNT),     // 共享载波
            .CounterDIR(CounterDIR),
            .CounterPeriod(CounterPeriod),
            .ZeroPluse(ZeroPluse), .PeriodPluse(PeriodPluse),
            .PWMUNLOCK(PWMUNLOCK[i]),
            .PWMEN(PWMEN[i]), .BootstrapInit(BootstrapInit[i]),
            .DutyA(DutyA[i]), .DutyB(DutyB[i]), .DutyC(DutyC[i]),
            .PWMU_P(...) // 6路输出
        );
    end
endgenerate
```

### 4.2 CalEN生成

```verilog
assign Axis1_CalEN = Axis1_PWMEN && !Axis1_BootstrapInit;
assign Axis2_CalEN = Axis2_PWMEN && !Axis2_BootstrapInit;
// Axis3, Axis4同理
```

---

## 5. 寄存器地址映射

### 5.1 通道基地址: `0x0700`

### 5.2 控制寄存器

| 偏移 | 名称 | 位宽 | R/W | 描述 |
|------|------|------|-----|------|
| 0x00 | Axis1_PWMCTRL | 16 | R/W | [15]=PWMUNLOCK(RO), [1]=PWMEN, [0]=BootstrapInit |
| 0x10 | Axis2_PWMCTRL | 16 | R/W | 同 Axis1 |
| 0x20 | Axis3_PWMCTRL | 16 | R/W | 同 Axis1 |
| 0x30 | Axis4_PWMCTRL | 16 | R/W | 同 Axis1 |

### 5.3 PWMCTRL寄存器位定义

| 位 | 名称 | R/W | 描述 |
|----|------|-----|------|
| 15 | PWMUNLOCK | R | 来自 SafetyMonitor 的安全解锁状态 |
| 14:2 | (保留) | — | 读为0 |
| 1 | PWMEN | R/W | PWM输出使能 (1=使能) |
| 0 | BootstrapInit | R/W | 引导加载模式 (1=下管全通) |

**安全互锁**(RegSpcae_CarrierModule):
```verilog
// 当PWMUNLOCK=0时, 硬件自动清除PWMEN和BootstrapInit
if (!PWMUNLOCK) begin
    PWMEN <= 0;
    BootstrapInit <= 0;
end
```

---

## 6. 启动时序

### 6.1 正常启动流程

```
1. MCU配置电流环PI参数
2. MCU使能编码器 → PositionDetection开始输出角度
3. MCU使能电流采样 → CurrentSample开始输出电流
4. MCU设置 CarrierModule: BootstrapInit=1
   → 下管全通, 建立自举电容电压
5. 等待自举电容充电完成 (通常几百ms)
6. MCU设置 CarrierModule: PWMEN=1, BootstrapInit=0
   → PWM正常输出, CalEN=1, FOC开始计算
7. SafetyMonitor检测无故障 → PWMUNLOCK=1
   → 全部PWM正常输出
```

### 6.2 紧急停机流程

```
1. 故障发生 (IPM Fault / OC / Watchdog)
2. SafetyMonitor → PWMUNLOCK=0
3. CarrierModule硬件自动: PWMEN=0, BootstrapInit=0
4. 所有PWM输出立即关断 (6路全0)
5. MCU通过寄存器读取故障状态, 判断原因
```

---

## 7. 设计注意事项

1. **死区时间验证**: 需用示波器实测上下管PWM之间的死区, 确保≥2μs且无交叠
2. **窄脉冲抑制**: MinPulseWidth=4μs 考虑到了IGBT/IPM的导通/关断延迟
3. **载波同步**: 所有4轴共享同一载波, 确保EMI频谱集中, 便于滤波
4. **载波极值更新**: 占空比在ZeroPluse/PeriodPluse更新, 确保中心对齐PWM波形对称
5. **引导加载**期间下管全通, 上管全关 → 电机绕组短接 → 无转矩输出 → 安全

---

*文档版本: v1.0 | 编写日期: 2026-05-07*

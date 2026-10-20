# 03 — FOC电流控制器技术开发文档

> **所属项目**: AxisesCTRL (四轴伺服驱动器 FPGA)  
> **涉及目录**: `AxisesCurrentCtrler/`, `HWInterface/`  
> **关键模块**: ArithmeticScheduler, ClarkTrans, ParkTrans, PICtrler, MotorCurrrentCtrler, VectorCtrler, Sqrt32, SvpwmModulate, InputCurrentMonitor

---

## 1. 模块概述

FOC (Field Oriented Control / 磁场定向控制) 电流控制器是伺服驱动的核心算法硬件实现。本模块实现完整的电流环FOC：Clarke变换、Park变换、PI调节、电压圆限制、反Park变换、SVPWM调制。

### 1.1 设计指标

| 参数 | 值 |
|------|-----|
| 控制轴数 | 4轴独立 |
| PWM载波 | 8 kHz (125 μs) |
| FOC更新率 | 8 kHz (同步于PWM) |
| 主时钟 | 100 MHz |
| 单轴FOC计算 | ~21 clk = 0.21 μs |
| 四轴总计算 | < 2 μs (含SVPWM) |
| 数值格式 | 16-bit Q15 (大部分信号) |

### 1.2 模块层次

```
AxisesCurrentCtrler.v
├── RegSpcae_AxisesCurrentCtrler.v   ← 寄存器接口
└── ArithmeticScheduler.v            ← FOC流水线调度
    └── MotorCurrrentCtrler.v        ← 单轴电流控制器
        ├── ClarkTrans.v             ← Clarke变换
        ├── ParkTrans.v              ← Park变换
        ├── InputCurrentMonitor.v    ← IW检测
        └── VectorCtrler.v           ← 矢量控制 (D/Q轴PI + 电压圆限制 + 反Park)
            ├── PICtrler.v ×2        ← D轴/Q轴PI控制器
            └── Sqrt32.v             ← 平方根计算
    └── SvpwmModulate.v              ← SVPWM调制

HWInterface/
├── HW_MULT_S1616.v                  ← 16×16有符号乘法器 (最常用)
├── HW_MULT_S3217.v                  ← 32×17有符号乘法器 (PI用)
├── HW_MULT_U3232.v                  ← 32×32无符号乘法器 (角度用)
└── HW_MULT_U1616.v                  ← 16×16无符号乘法器 (备用)
```

---

## 2. 数值格式约定

| 信号 | 格式 | 位宽 | 物理基准 | 范围 |
|------|------|------|---------|------|
| IU, IV (相电流) | Q15有符号 | 16-bit | Ibase (额定电流) | [-1, +1) |
| IALPHA, IBETA | Q15有符号 | 16-bit | Ibase | [-1, +1) |
| ID, IQ | Q15有符号 | 16-bit | Ibase | [-1, +1) |
| IDref, IQref | Q15有符号 | 16-bit | Ibase | [-1, +1) |
| UD, UQ | Q15有符号 | 16-bit | Ubase (额定电压) | [-1, +1) |
| UALPHA, UBETA | Q15有符号 | 16-bit | Ubase | [-1, +1) |
| Kp, Ki (PI增益) | Q15有符号 | 32-bit | Ubase/Ibase | [-1, +1) |
| 积分累加器 UiAcc | Q30无符号 | 32-bit | Ubase | [-1, +1) |
| SINval, COSval | Q15有符号 | 16-bit | 1.0 | [-1, +1) |
| 占空比 DutyA/B/C | Q15无符号 | 16-bit | 1.0 (100%) | [0, 1) |
| 电压圆限制半径 | Q15 | 16-bit | 2/3*Udc | — |

**关键常量**:
- `VoltageCircleLimit = 16'h6ED9` = 0.8660 ≈ √3/3 (Q15格式)
- `Kp_Max = 32'd32767` (Q15最大值 ≈ 1.0)

---

## 3. 流水线调度 (ArithmeticScheduler.v)

### 3.1 两阶段重叠流水线

```
时间 →

阶段1 (MotorCurrrentCtrler):
  [轴1 FOC] [轴2 FOC] [轴3 FOC] [轴4 FOC]
             ↑触发 SVPWM 开始 (可重叠)

阶段2 (SvpwmModulate):
            [轴1 SVPWM] [轴2 SVPWM] [轴3 SVPWM] [轴4 SVPWM]
```

### 3.2 状态机

```
SchedulerCNT:
  0: IDLE — 等待 trig
  1: 加载轴1参数 → 触发 MotorCurrrentCtrler
  2: 等待 MotorCurrrentCtrler 完成 → 锁存轴1结果
  3: 加载轴2参数 → 触发 MotorCurrrentCtrler
  4: 等待 → 锁存轴2结果
  ... (每个轴2拍)
  9: 锁存轴4结果
  
SVPWM调度:
  当轴1的ID/IQ/UQ/UD被锁存后 → 将UALPHA/UBETA送入SvpwmModulate
  若 SvpwmInputSel=1: 使用寄存器直灌值 (开环测试)
  若 SvpwmInputSel=0: 使用FOC计算结果
```

### 3.3 关键控制信号

| 信号 | 描述 |
|------|------|
| `trig` (=DataLockedPluse) | 电流数据就绪，启动FOC |
| `MotorCurrrentCtrler_busy` | 电机控制器忙碌中 |
| `MotorCurrrentCtrler_finish` | 电机控制器完成 |
| `SvpwmModulate_busy` | SVPWM忙碌中 |
| `SvpwmModulate_finish` | SVPWM完成 |
| `SvpwmInputSel` | SVPWM输入选择 (0=FOC结果, 1=寄存器直灌) |

---

## 4. Clarke变换 (ClarkTrans.v)

### 4.1 算法

```
输入: IU, IV (16-bit Q15有符号)
输出: IALPHA, IBETA (16-bit Q15)

IALPHA = IU
IBETA  = (IU + 2×IV) / √3

注: 此处使用了简化的功率不变Clarke变换变体
```

### 4.2 硬件实现

```verilog
// 使用 HW_MULT_S1616: MultA × MultB
// 计算 IBETA = MultResult >> 15 (Q15提取)

Step 0: MultA = IU, MultB = 比例系数
Step 1: MultA = IV, MultB = 比例系数
Step 2: 锁存 IALPHA, IBETA
```

**延迟**: 2 clk

---

## 5. Park变换 (ParkTrans.v)

### 5.1 算法

```
ID  = COSval × IALPHA + SINval × IBETA
IQ  = COSval × IBETA - SINval × IALPHA
```

### 5.2 硬件实现

分时复用2个 `HW_MULT_S1616` 乘法器:

```
Step 0: COS×IALPHA (乘法器1), COS×IBETA (乘法器2)
Step 1: SIN×IBETA (乘法器1), SIN×IALPHA (乘法器2)
Step 2: ID = 结果1 + 结果2, IQ = 结果1 - 结果2
```

**延迟**: 3 clk

---

## 6. PI控制器 (PICtrler.v)

### 6.1 增量式PI算法

```
e(k)   = Reference - Feedback                    (17-bit)
up(k)  = Kp × e(k)                                (32×17 → 49-bit)
ui(k)  = Ki × e(k)                                (32×17 → 49-bit)
UiAcc(k) = clamp(UiAcc(k-1) + ui(k), ±Limit32)   (32-bit Q30)
PIResult = clamp(up + UiAcc + Compensate, ±Limit) (16-bit Q15)
```

### 6.2 计算步骤 (7 clk)

| CalCNT | 操作 | 乘法器输入 |
|--------|------|-----------|
| 0 | 捕获误差 Err = Ref - Fbk; MultA=Kp | Kp × Err |
| 1 | MultA=Ki | Ki × Err |
| 2 | 锁存 up = clamp(Kp×Err) → 32-bit Q30 | — |
| 3 | 锁存 ui = clamp(Ki×Err) → 32-bit Q30 | — |
| 4 | uiacc_pre = ui + UiAcc | — |
| 5 | UiAcc_new = clamp(uiacc_pre, ±Limit32) | — |
| 6 | PIResult = clamp(up_18 + UiAcc_new_18 + Compensate_18, ±Limit) | — |

### 6.3 限幅保护

**乘法结果限幅** (32-bit Q30):
```verilog
if (Result_dly[48]==0) begin    // 正数
    if (Result_dly[47:30]==0)
        MultResult = Result_dly[31:0];  // 正常
    else
        MultResult = 32'h3FFFFFFF;       // 正溢出 → +1
end else begin                   // 负数
    if (Result_dly[47:30]==18'h3FFFF)
        MultResult = Result_dly[31:0];  // 正常
    else
        MultResult = 32'hC0000000;       // 负溢出 → -1
end
```

**积分抗饱和** (Anti-windup):
```verilog
if (uiacc_pre[31]==0) begin  // 正
    if (uiacc_pre[30]==0)
        UiAcc_new = min(uiacc_pre, Limit32);
    else
        UiAcc_new = Limit32;
end else begin                 // 负
    if (uiacc_pre[30]==1)
        UiAcc_new = max(uiacc_pre, -Limit32);
    else
        UiAcc_new = -Limit32;
end
```

---

## 7. 矢量控制器 (VectorCtrler.v)

### 7.1 状态机

```
状态机: IDLE → FirstPICAL → CircleLimitPRE → CircleLimitCAL
        → SecondPICAL → IPARKCAL_Ualpha → IPARKCAL_Ubeta → Calfinish
```

### 7.2 控制流程

```
1. IDLE: 等待 trig
2. FirstPICAL: 计算第一个PI (D轴或Q轴, 由LimitMode_HDLQ决定)
3. CircleLimitPRE: 准备电压圆限制
4. CircleLimitCAL: 计算 sqrt(R² - PIResult²) 作为第二个PI的限幅值
5. SecondPICAL: 计算第二个PI (受限于上一步计算的limit)
6. IPARKCAL_Ualpha: 反Park变换 UALPHA = COS×UD - SIN×UQ
7. IPARKCAL_Ubeta:  反Park变换 UBETA  = SIN×UD + COS×UQ
8. Calfinish: 完成 → 返回IDLE
```

### 7.3 电压圆限制

```verilog
// 限幅半径 = min(用户设置, 硬件SVPWM最大)
R² = min(LimitCircleRadius_user², LimitCircleRadiusHW²)

// 模式0 (Limit Q): 先算D轴PI, Q轴限制在 √(R² - UD²)
SquareDiff = R² - UD²
Q_limit = sqrt(SquareDiff)

// 模式1 (Limit D): 先算Q轴PI, D轴限制在 √(R² - UQ²)
SquareDiff = R² - UQ²
D_limit = sqrt(SquareDiff)
```

### 7.4 反Park变换

```
UALPHA = COSval × UD - SINval × UQ
UBETA  = SINval × UD + COSval × UQ
```

---

## 8. SVPWM调制 (SvpwmModulate.v)

### 8.1 算法流程 (11 clk)

| CalStep | 操作 | 乘法器 |
|---------|------|--------|
| 0 | 计算 Ualpha_sqrt3_half = Ualpha × √3/2; Vref1=Ubeta, Vref2=Ubeta/2+..., Vref3=Ubeta/2-... | Ualpha × 0x6ED9 |
| 1 | 扇区识别 N={Vref2[15],Vref3[15],~Vref1[15]}; x = Vref1 × 2/√3 | Vref1 × 0x49E6 |
| 2 | y = Vref2 × 2/√3 | Vref2 × 0x49E6 |
| 3 | z = Vref3 × 2/√3 | Vref3 × 0x49E6 |
| 4 | 扇区映射: {T1, T2, Sector} ← f(N, x, y, z) | — |
| 5 | 过调制检测: T1+T2 > 1.0? | — |
| 6 | 最终 T1, T2 | — |
| 7 | ta=(1-T1-T2)/2, tb=ta+T1, tc=ta+T1+T2 → cmp1/cmp2/cmp3 (扇区分配) | — |
| 8 | DutyA = PeriodCNT - cmp1 × PeriodCNT | cmp1 × PeriodCNT |
| 9 | DutyB = PeriodCNT - cmp2 × PeriodCNT | cmp2 × PeriodCNT |
| 10 | DutyC = PeriodCNT - cmp3 × PeriodCNT; finish | cmp3 × PeriodCNT |

### 8.2 扇区识别表

| N | T1 | T2 | 扇区 |
|---|----|----|------|
| 1 | z | y | 1 |
| 2 | y | -x | 5 |
| 3 | -z | x | 0 |
| 4 | -x | z | 3 |
| 5 | x | -y | 2 |
| 6 | -y | -z | 4 |

### 8.3 扇区→CMP映射

| 扇区 | cmp1 | cmp2 | cmp3 |
|------|------|------|------|
| 0 | ta | tb | tc |
| 1 | tb | ta | tc |
| 2 | tc | ta | tb |
| 3 | tc | tb | ta |
| 4 | tb | tc | ta |
| 5 | ta | tc | tb |

### 8.4 过调制处理

当前实现中过调制处理为**占位代码**（标注 `temp deal`），直接将 T1_pre/T2_pre 赋值给 T1/T2。这意味着：
- 正常区域 (T1+T2 ≤ 1): 正常工作
- 过调制区域 (T1+T2 > 1): 波形可能畸变，需要后续完善

### 8.5 关键常量

| 常量 | 值 | 含义 |
|------|-----|------|
| `0x6ED9` | ≈ 0.8660 | √3/2 (Q15) |
| `0x49E6` | ≈ 0.5774 | 2×√3/3 = 2/√3 (Q14, 实际Q15中为 ≈ 1.1547/2) |
| `0x7FFF` | 1.0 (Q15) | T1+T2上限 |

---

## 9. 平方根 (Sqrt32.v)

### 9.1 算法

逐次逼近法 (试位法)，17次迭代确定32位结果:

```
for i = 15 downto 0:
    guess = current_result | (1 << i)
    if (guess × guess ≤ input_value)
        current_result = guess
```

### 9.2 硬件实现

```verilog
reg [31:0] ResultReg;      // 当前逼近结果
reg [31:0] MultB;           // = ResultReg (平方计算)
reg [63:0] Square;          // = ResultReg × ResultReg

// 使用 HW_MULT_S1616 (实际硬件乘法器)
// 每个周期: MultA = ResultReg[15:0] 或 [31:16]
//           Result = MultA × MultB
// 然后通过比较决定是否保留当前位
```

**延迟**: 17 clk

---

## 10. 输入电流监控 (InputCurrentMonitor.v)

### 10.1 功能

从 IU 和 IV 推导 IW，检查是否溢出16位有符号范围:

```verilog
IW = -(IU + IV)  // 基尔霍夫电流定律

if IW[16] != IW[15]  → OutOFRange (溢出)
```

---

## 11. 硬件乘法器

所有乘法器为组合逻辑，综合工具推断为DSP块:

| 模块 | 输入格式 | 输出格式 | 用途 |
|------|---------|---------|------|
| `HW_MULT_S1616` | s16 × s16 → s32 | 16×16 Q15→Q30 | Clarke/Park/SVPWM/CORDIC/Sqrt |
| `HW_MULT_S3217` | s32 × s17 → s49 | 32×17 Q15→Q32 | PI (Kp/Ki × Err) |
| `HW_MULT_U3232` | u32 × u32 → u64 | 32×32 | 角度转换 (MechPos × TransCoeff) |
| `HW_MULT_U1616` | u16 × u16 → u32 | 16×16 | 备用 |

---

## 12. 寄存器地址映射

### 12.1 基地址与范围

- 通道基地址: `0x0300`
- 每轴范围: 0x00~0x7F (128字 × 4轴 = 512字)
- 总范围: `0x0300` ~ `0x06FF`

### 12.2 每轴寄存器 (示例轴1: 0x0300)

| 偏移 | 名称 | 位宽 | R/W | 描述 |
|------|------|------|-----|------|
| 0x00 | Kp_D | 32 | R/W | D轴电流环比例增益 Q15 (高/低半字) |
| 0x02 | Ki_D | 32 | R/W | D轴电流环积分增益 Q15 |
| 0x04 | Kp_Q | 32 | R/W | Q轴电流环比例增益 Q15 |
| 0x06 | Ki_Q | 32 | R/W | Q轴电流环积分增益 Q15 |
| 0x08 | ID_ref | 16 | R/W | D轴电流参考值 Q15 |
| 0x09 | IQ_ref | 16 | R/W | Q轴电流参考值 Q15 |
| 0x0A | Compensate_D | 16 | R/W | D轴前馈补偿 Q15 |
| 0x0B | Compensate_Q | 16 | R/W | Q轴前馈补偿 Q15 |
| 0x0C | Limit_D | 16 | R/W | D轴PI输出限幅 Q15 |
| 0x0D | Limit_Q | 16 | R/W | Q轴PI输出限幅 Q15 |
| 0x0E | LimitCircleRadius | 16 | R/W | 电压圆限制半径 Q15 |
| 0x0F | LimitMode_HDLQ | 1 | R/W | 限幅模式: 0=Limit Q, 1=Limit D |
| 0x10 | SvpwmInputSel | 1 | R/W | 0=FOC结果, 1=寄存器直灌 |
| 0x11 | Ualpha_Manual | 16 | R/W | 手动UALPHA (开环测试) Q15 |
| 0x12 | Ubeta_Manual | 16 | R/W | 手动UBETA (开环测试) Q15 |
| 0x20 | ID_monitor | 16 | R | D轴电流反馈 Q15 |
| 0x21 | IQ_monitor | 16 | R | Q轴电流反馈 Q15 |
| 0x22 | UD_monitor | 16 | R | D轴电压输出 Q15 |
| 0x23 | UQ_monitor | 16 | R | Q轴电压输出 Q15 |

**轴2**: +0x0080 | **轴3**: +0x0100 | **轴4**: +0x0180

---

*文档版本: v1.0 | 编写日期: 2026-05-07*

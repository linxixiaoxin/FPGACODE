# 08 — Zlink通信协议技术开发文档

> **所属项目**: AxisesCTRL (四轴伺服驱动器 FPGA)  
> **涉及目录**: `BusInterconnecter/ZlinkSlave/`  
> **关键模块**: ZlinkslavestationShell, Zlinkslavestation, FrameAnalysis, TopUnPack, SubDatagramdeal, IndependentRead/Write, FrameTramsmit, TopologyManage, CRC32CORE, PhyInterface_1bit100Mhz

---

## 1. 协议概述

Zlink 是一个**自定义Layer 2以太网实时控制协议**，设计用于工业自动化中的分布式运动控制。它运行在100Mbps RMII物理层之上，支持**菊花链拓扑**和**在线读取**（in-stream read），实现确定性的低延迟数据传输。

### 1.1 协议栈层次

```
┌────────────────────────────────────────────┐
│          应用层: 寄存器读写                  │
│  IndependentRead / IndependentWrite         │
│  支持: 广播写(CMD=0x01), 寻址写(0x11),     │
│        寻址读(0x12)                         │
├────────────────────────────────────────────┤
│          子报文层: 多子报文链式封装           │
│  SubDatagramdeal                            │
│  每子报含: CMD + SlaveAddr + LocalAddr     │
│           + DataLength + NextFlag            │
├────────────────────────────────────────────┤
│          拓扑发现层: 节点计数                 │
│  TopUnPack                                  │
│  EtherType: 0x88A4                          │
│  SlaveDetect字节 +1 中继                     │
├────────────────────────────────────────────┤
│          以太网MAC层: 帧组装/解析             │
│  FrameAnalysis (接收) / FrameTramsmit (发送)│
│  CRC32 校验 (IEEE 802.3 多项式)              │
├────────────────────────────────────────────┤
│          PHY物理层: RMII 双端口              │
│  PhyInterface_1bit100Mhz                    │
│  2-bit@50MHz ↔ 1-bit@100MHz 转换            │
│  MDIO PHY管理 (自动协商 + 链路监控)          │
└────────────────────────────────────────────┘
```

### 1.2 协议特点

| 特性 | 描述 |
|------|------|
| **菊花链拓扑** | 节点间使用标准以太网PHY级联, 单方向数据流 |
| **在线读取** | 读响应直接在转发帧中替换，无需等待独立响应帧 |
| **从站发现** | 每个节点对SlaveDetect字节+1, 主控通过最终值获知节点数 |
| **广播写** | CMD=0x01 写入所有从站, 无需寻址 |
| **CRC32保护** | 标准Ethernet CRC32 (多项式0x04C11DB7) |

---

## 2. 模块层次

```
ZlinkslavestationShell.v             ← 顶层封装
├── Zlinkslavestation.v              ← 协议引擎
│   ├── Slave100MHz_FrameAnalysis.v  ← 以太网帧接收
│   ├── Slave100MHz_TopUnPack.v      ← 拓扑头解析 + SlaveDetect+1
│   ├── Slave100MHz_SubDatagramdeal.v← 子报文解析
│   ├── Slave100MHz_IndependentWrite.v ← 写操作执行
│   ├── Slave100MHz_IndependentRead.v  ← 读操作执行 (在线替换)
│   ├── Slave100MHz_FrameTramsmit.v  ← 帧转发/重组 + CRC32
│   ├── Slave100MHz_TopologyManage.v ← 双端口转发控制
│   ├── Slave100MHz_CRC32CORE.v      ← CRC32计算核心
│   ├── Slave100MHz_CRCCHECK.v       ← CRC校验
│   └── Slave100MHz_CRCCal.v         ← CRC计算封装
└── PhyInterface_1bit100Mhz.v ×2     ← 每端口PHY接口
    ├── PhyManage.v                  ← MDIO PHY管理状态机
    │   ├── PhyManageMDC.v           ← MDC时钟生成 (1MHz)
    │   └── PhyManageDriver.v        ← MDIO帧协议
    ├── CRSDV2RXDV.v                 ← RMII CRSDV → RXDV转换
    ├── Stream2bitTo1bit.v           ← 2-bit@50M → 1-bit@100M (含异步FIFO)
    └── Stream1bitTo2bit.v           ← 1-bit@100M → 2-bit@50M (含异步FIFO)
```

---

## 3. PHY物理层

### 3.1 RMII接口

标准RMII (Reduced MII) 接口:
- **REFCLK**: 50MHz (由外部PHY提供)
- **CRSDV**: 载波检测/数据有效 (复用信号)
- **RXD[1:0]**: 2-bit接收数据 (每时钟2位 → 100Mbps)
- **TXEN**: 发送使能
- **TXD[1:0]**: 2-bit发送数据
- **MDC/MDIO**: PHY管理接口

### 3.2 2-bit ↔ 1-bit 转换

```
RMII 域 (50MHz):              内部域 (100MHz):
                      
RXD[1:0] @ 50MHz    →    Stream2bitTo1bit  →   1-bit @ 100MHz
    (异步FIFO: 32深 × 2路双端口SRAM)

1-bit @ 100MHz      →    Stream1bitTo2bit  →   TXD[1:0] @ 50MHz
    (异步FIFO: 32深 × 2路双端口SRAM)
```

### 3.3 CRSDV → RXDV 转换

```verilog
// 连续检测模式
// 101 表示有效帧开始
if (CRSDV=1, RXD=01) twice in a row:
    RXDV = 1 (数据有效开始)
// 0XX twice in a row:
    RXDV = 0 (数据有效结束)
```

### 3.4 PHY管理状态机

```
IDLE → RDID0 → RDID1 → PHYDetect → PHYnormal_WRCtrlReg 
  → PHYnormal_RDLinkState → PHYnormal_wait → (循环)

- 读取 PHY ID: 寄存器2和3 (识别PHY型号)
- 写入控制寄存器: reg0 = 0x3300 (使能自动协商, 重启协商)
- 连续读取状态寄存器: reg1 bit2 (链路状态)
- 输出: Linkstate 信号
```

---

## 4. 以太网MAC层

### 4.1 帧接收状态机 (FrameAnalysis)

```
Frame_Idel (0)
  │ RXDV rising
  ▼
Frame_Preamble (1)
  │ 检测111 (前导码结束), 8字节前导码
  ▼
Frame_Message (2)
  │ 111 bits (14字节: MAC dst + MAC src + EtherType)
  ▼
Frame_DATA_FCS (3)
  │ 数据 + FCS 4字节
  ▼
Frame_Idel (0)
  
异常 → Frame_InValid (15) → Frame_Idel (0)
```

### 4.2 字段提取

```
BitsCounterLoop: 0→7循环 (8位 = 1字节)
FrameMsgBytesCount:
  1-6:   目标MAC地址  MSG_TargetAddress[47:0]
  7-12:  源MAC地址    MSG_SourceAddress[47:0]
  13-14: 以太网类型   MSG_EthernetType[15:0]
  15+:   数据载荷
```

### 4.3 CRC32

**多项式**: `0x04C11DB7` (IEEE 802.3 Ethernet)

```verilog
// 256项查找表
table_index = crc_temp[7:0] ^ ByteStream;
// 前4字节: 输入字节按位取反
if (count <= 4)
    table_index = crc_temp[7:0] ^ ~ByteStream[7:0];
crc_temp <= table_out ^ {8'd0, crc_temp[31:8]};

// 最终结果: 按位取反
CRC_Result = ~crc_temp;
CRC_Valid  = (CRC_Result == FrameFCS);  // 与帧中FCS比较
```

---

## 5. 拓扑发现层 (TopUnPack)

### 5.1 Zlink帧头 (EtherType 0x88A4)

| 字节偏移 | 字段 | 描述 |
|---------|------|------|
| 0-3 | SysRefClk[31:0] | 系统参考时钟 |
| 4 | SlaveDetect[7:0] | 从站检测字节 (每跳+1) |
| 5 | OperationMode[7:0] | 操作模式 |
| 6-7 | FrameIndex[15:0] | 帧序号 |
| 8-9 | Datalength[15:0] | 子报文数据长度 |

### 5.2 SlaveDetect +1 机制

```verilog
// 每个节点在转发时对SlaveDetect字节加1
// 实现: 串行加法器 (RXD + carry)
// 在位流中替换SlaveDetect字节的每一位

if (ReplaceFlag && ReplaceBitPosition == SlaveDetectByte)
    TXD = RXD ^ Carry;      // 半加器
    Carry = RXD & Carry;

// 效果:
// 主控发送 SlaveDetect = 0
// 第1个节点: SlaveDetect = 1
// 第2个节点: SlaveDetect = 2
// ...
// 最后一个节点返回主控: SlaveDetect = N (节点总数)
```

---

## 6. 子报文层 (SubDatagramdeal)

### 6.1 子报文格式

Zlink帧数据部分可包含多个**链式子报文**:

```
┌──────┬──────────┬───────────┬───────────┬──────────┐
│ CMD  │SlaveAddr │LocalAddr  │DataLength │ NextFlag │ 数据... │
│ 8-bit│ 8-bit    │ 16-bit    │ 15-bit    │ 1-bit    │         │
└──────┴──────────┴───────────┴───────────┴──────────┘
│←────────────── 6字节头部 ──────────────→│←─DataLength字节─→│
```

**NextFlag**: 0=当前子报文是最后一个, 1=后面还有子报文

### 6.2 子报文解析状态

```verilog
SubDatagramByteCNT: 在子报文内逐字节计数
SubDatagramCNT: 链式子报文序号

// CMDValid 在字节5时置位 (头部接收完成)
SubDatagram_CMDValid = (SubDatagramByteCNT == 5);
```

---

## 7. 寄存器访问操作

### 7.1 独立写操作 (IndependentWrite)

**命令**:
- `CMD = 0x01`: 广播写 (所有从站执行)
- `CMD = 0x11`: 寻址写 (仅当 SlaveAddr == SetSlaveAddr 时执行)

**执行逻辑**:
```verilog
// 在CMDValid时判断
WREN = (CMD==0x01) || (CMD==0x11 && SlaveAddr_Match);

// 写地址计算
ADDR = SubDatagram_LocalAddr + 字节偏移/2;

// 写数据: 每2字节组装为16-bit WRDATA
// 写脉冲: WRPluse 在每个16-bit字边界触发
```

### 7.2 独立读操作 (IndependentRead)

**命令**:
- `CMD = 0x12`: 寻址读 (仅当 SlaveAddr == SetSlaveAddr)

**在线读取实现**:
```verilog
// 1. 在CMDValid时发出读请求
RDPluse → FPGA内部总线 → 获取 RDDATA

// 2. 读数据锁存到LoadByte0/LoadByte1 (乒乓缓冲)
LoadByte0 = {RDDATA[15:8]};
LoadByte1 = {RDDATA[7:0]};

// 3. 在位流中替换 (in-stream replacement)
// 子报文头部之后的数据部分被替换为实际读出的值
if (LoadByte0_ReplaceFlag)
    TXD = LoadByte0[BitCNT];
if (LoadByte1_ReplaceFlag)
    TXD = LoadByte1[BitCNT];

// 替换位置: SubDatagramByteCNT 在特定偏移处触发
```

**优势**: 读响应与转发帧同步，无需等待独立响应帧。延迟 = 帧转发延迟 + 内部总线读取延迟(2-3 clk)。

---

## 8. 帧发送与转发 (FrameTramsmit)

### 8.1 数据源优先级

```
TXD输出 = (优先选择):
  1. TopPackReplace (最高优先级): SlaveDetect+1
  2. IndependentReadReplace: 在线读取数据替换
  3. Raw RXD (最低优先级): 直接转发
```

### 8.2 CRC重新计算

```verilog
// 转发帧需要重新计算CRC (因为SlaveDetect和读数据已被替换)
// CRC32计算覆盖: 帧头(14字节) + 数据载荷
// 计算完成后追加32-bit CRC到帧尾

// 最小以太网帧长度: 46字节数据
MinDataLength = 46;
if (DataLength < 46)
    自动追加填充字节
```

---

## 9. 拓扑管理 (TopologyManage)

### 9.1 双端口工作模式

| Linkstate[1:0] | Port 0 | Port 1 | 描述 |
|---------------|--------|--------|------|
| 00 | 禁用 | 禁用 | 无链路 |
| 10 | 发送本地TX | 禁用 | 仅Port0连接 |
| 11 | 转发Port1的RX | 发送本地TX | 双端口菊花链 (中继模式) |
| 01 | 禁用 | 自环回 | Port1回环测试 |

### 9.2 菊花链数据流

```
Port1 (上游)                   Port0 (下游)
   RX ←────────────────── TX
   TX ──────────────────→ RX

中继模式 (Linkstate=11):
   Port1.RX → (转发) → Port0.TX     // 上游帧转发到下游
   Port1.TX ← Zlink本地TX           // 本地数据注入到上游
```

---

## 10. 内部总线接口

### 10.1 UserSpace接口

ZlinkSlave通过UserSpace接口连接到总线矩阵的Master2通道:

```
ZlinkSlave                    BusInterconnecter (Master2)
  ZlinkS_ADDR[15:0]     →     UserSpace_ADDR[15:0]
  ZlinkS_WRDATA[15:0]   →     UserSpace_WRDATA[15:0]
  ZlinkS_RD             →     UserSpace_RD
  ZlinkS_WR             →     UserSpace_WR
  ZlinkS_RDDATA[15:0]   ←     UserSpace_RDDATA[15:0]
  ZlinkS_RDDATAVALID    ←     UserSpace_RDDATAVALID
  ZlinkS_WRACK          ←     UserSpace_WRACK
```

### 10.2 从站地址设置

```verilog
// SetSlaveAddr 由拓扑发现或静态配置确定
// 决定了寻址读写时的地址匹配
parameter SetSlaveAddr = 8'h01;  // 默认值
```

---

## 11. 时序与性能

| 参数 | 值 |
|------|-----|
| 线路速率 | 100 Mbps |
| 内部处理时钟 | 100 MHz |
| 每跳转发延迟 | ~0.5 μs (帧头处理 + CRC) |
| 在线读取延迟 | 转发延迟 + 2 clk = ~0.52 μs |
| 最大节点数 | 受限于 SlaveDetect 8-bit (255个) |
| 最小帧间隔 | 标准以太网 IFG (96 bit时间) |

---

## 12. 错误处理

| 错误类型 | 检测方式 | 处理 |
|---------|---------|------|
| CRC错误 | CRC32校验不匹配 | 丢弃帧 |
| 无效帧 | 前导码异常/长度不匹配 | Frame_InValid状态 |
| 链路断开 | PHY Linkstate = 0 | 对应端口禁用 |
| 编码器CRC错误 | DMC/BISS位置校验失败 | ENCCRCERRCNT递增 |
| 编码器无响应 | BISS超时/DMC超时 | ENCNoResponseCNT递增 |

---

*文档版本: v1.0 | 编写日期: 2026-05-07*

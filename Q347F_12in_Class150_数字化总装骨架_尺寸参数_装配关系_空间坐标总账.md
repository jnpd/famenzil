# Q347F 12寸 Class150——数字化总装骨架总账 V5

> **定位**：本文件是当前 Q347F 12寸 Class150 固定球阀的“唯一汇总结果页”。  
> 这里不重复所有推导，只保存当前有效的 **尺寸参数 + 装配关系 + 空间坐标 + SolidWorks变量 + 开放项**。  
> **当前主线已推进到 V17 / 第5B步**：内部功能包络已建立；球体—阀体中腔间隙采用三档敏感性配置；下球孔旧“52mm固定深度”已纠错。

[← 总导航](./00_Q347F_12in_Class150_文档导航_从这里开始.md)  
[← 主计算母版](./Q347F_12in_Class150_球体设计计算底稿_第一部分_小白可读公式完整版.md)  
[← 当前有效V11](./Q347F_12in_Class150_第4C步_20寸原生支承_阀杆轴向证据_12寸V11坐标骨架.md)  
[← 当前有效V12](./Q347F_12in_Class150_第4D步_12寸前盖_底盖制造草模尺寸链_V12.md)  
[← V15支承纠错](./Q347F_12in_Class150_第4G步_上下主支承身份纠错_反力中心与CAD坐标闭合_V15.md)  
[← V16内部整体空间](./Q347F_12in_Class150_第5A步_内部整体空间_球体阀座上下支承统一包络_V16.md)  
[← V17中腔间隙与下球孔纠错](./Q347F_12in_Class150_第5B步_阀体中腔间隙_公司规则分层_下球孔纠错_V17.md)

---

# 0. 永久数字化主线

```text
                     球心 O
                       │
          ┌────────────┼────────────┐
          ↓            ↓            ↓
       尺寸参数      装配关系      空间坐标
          │            │            │
          └────────────┼────────────┘
                       ↓
                 SolidWorks骨架
                       ↓
                    零件模型
                       ↓
                    自动装配
                       ↓
                    干涉检查
                       ↓
                    运动检查
                       ↓
                    工程图
```

每完成一个模块，三张账必须一起更新。

---

# 1. 状态规则

| 状态 | 含义 |
|---|---|
| **A** | 项目输入 / 12寸BOM / 公司受控规则明确值 |
| **A-policy** | 公司设计方法已经明确，但公式中的标准数值仍需查表 |
| **B** | 由已接受输入直接计算 |
| **C** | 有依据的CAD候选，可草模，未制造冻结 |
| **C+** | 多条独立证据交叉支持 |
| **D** | 仍缺前置条件，禁止填死 |
| **P-XREF** | 同公司其他阀型/跨结构参考，只用于敏感性 |
| **H** | 历史值 |
| **H/R** | 历史且已被纠正，禁止当前使用 |
| **R** | 当前风险，制造冻结前必须关闭 |

---

# 2. 全局坐标系

```text
BALL_CENTER_O = (0,0,0)
FLOW_AXIS     = X
SUPPORT_AXIS  = Z

-X = 入口
+X = 出口
+Z = 前盖 / 执行器方向
-Z = 底盖方向
```

SolidWorks：

```text
Origin      = BALL_CENTER_O
Front Plane = XZ
Top Plane   = XY
Right Plane = YZ
```

---

# 3. 项目基线

| 参数 | 当前值 | 状态 |
|---|---:|---|
| 公称尺寸 | NPS12 / DN300 | A |
| 压力等级 | Class150 | A |
| 结构 | 固定球 / 枢轴固定 / 全通径 | A |
| 介质 | 天然气 | A |
| 设计压力 | 2.0 MPa | A |
| 流道 | φ303 | A |
| 阀体材料 | ASTM A216 WCB | A |
| 球体材料 | ASTM A182 F316 | A |
| 阀杆材料 | ASTM A182 F51 | A |
| 阀座软密封 | DEVLON | A / 具体牌号D |
| O形圈 | VITON | A |

公司结构规则：

```text
CL150~CL900 且 NPS≤12 → 枢轴固定结构
```

所以本项目不是支撑板固定结构。

---

# 4. 尺寸参数总表 V5

## 4.1 球体

| 参数ID | 当前值 | 状态 | 说明 |
|---|---:|---|---|
| `BALL_OD` | 465 | C / 公司系列支持 | 主球面 |
| `BALL_R` | 232.5 | B | 主球面半径 |
| `BALL_W_X` | 348 | C | X向总宽 |
| `BALL_X_FACE_L/R` | ±174 | B/C | 闭阀端基准 |
| `BALL_UPPER_BORE_D` | 105 | C+ | 上球体主支承孔 |
| `BALL_UPPER_BORE_EFFECTIVE_L` | ≈28.9 | C | 有效圆柱支承段 |
| `BALL_UPPER_BORE_TOTAL_DEPTH` | ? | D | 含导角/过渡的总孔深 |
| `BALL_LOWER_BORE_D` | 70 | C+ | 下球体主支承孔 |
| `BALL_LOWER_BORE_EFFECTIVE_L` | 50 | C+ | 与50长采购轴承匹配 |
| `BALL_LOWER_BORE_TOTAL_DEPTH` | `>=50`，具体? | D | 不再固定52 |

### 历史纠错

```text
旧 BALL_LOWER_BORE_H = 52
→ H/C-history

旧 LOWER_BORE_BOTTOM_Z = -175
→ H/C-history
```

当前禁止把52当有效圆柱长度或制造冻结孔深。

---

## 4.2 阀座密封副

| 参数ID | 当前值 | 状态 |
|---|---:|---|
| `SEAT_D9` | φ323.88 | B/C |
| `SEAT_D10` | φ327.13 | B/C |
| `SEAT_D11` | φ342 | C |
| `SEAT_GUIDE_BORE` | φ342.4 | C+ |
| `SEAT_GUIDE_CLR_RAD` | 0.20 | B/C |
| `SEAT_ORING_MAIN` | φ320×5.3 | A/C+ |
| `SEAT_ORING_ROOT` | φ333.6 | C+ |
| `SEAT_ORING_2` | φ311×3.55 | A |
| `SEAT_PILOT_2` | φ323.6 | C |
| `SEAT_GUIDE_2` | φ323.8 | C |
| `SEAT_CLR2_RAD` | 0.10 | B/C |
| `DEVLON_ID_ENV` | ≈φ323.8 | C/P |
| `DEVLON_OD_ENV` | ≈φ331 | C/P |
| `DEVLON_W_ENV` | ≈8 | C/H |
| `SEAT_TRAVEL_FWD` | ≥1.0 | B/C |
| `SEAT_TRAVEL_BACK` | 0.5 | C |
| `SEAT_TRAVEL_ENV` | ≥1.5 | C |
| `SPRING` | φ8×φ1.6×18×7，36/侧 | A/C |
| `SPRING_H_INST` | ≈15.6 | B/C |
| `SPRING_PCD` | φ362 | C |
| `SEAT_BIG_OD` | φ380 | C |
| `COVER_BIG_BORE` | φ382 | C |
| `WSEAT_ENV` | ≈58 | C-space |

真实球面接触带X：

```text
右：+165.235 ~ +166.828
中心：+166.036

左：-166.828 ~ -165.235
中心：-166.036
```

不能用 `X=±174` 端面代替球面接触。

---

## 4.3 上球体主支承——外轨

| 参数ID | 当前值 | 状态 |
|---|---:|---|
| `UP_BALL_BRG` | φ105×φ100×30 | A/C+ |
| `UP_JOURNAL_D` | φ100 | C+ |
| `UP_BRG_CENTER_Z` | +208.6 | C |
| `UP_BRG_Z0` | +193.6 | C |
| `UP_BRG_Z1` | +223.6 | C |
| `A_SUPPORT_ARM` | 208.566 | B/C |
| `A_SUPPORT_SENS` | 206.47~210.66 | B/C |

正确功能链：

```text
球体φ105孔
↓
φ105×φ100×30轴承
↓
前盖一体φ100轴颈
```

---

## 4.4 阀杆 / 前盖内轨

| 参数ID | 当前值 | 状态 |
|---|---:|---|
| `STEM_MAIN_D` | φ65 | C+ |
| `STEM_KEY_D` | φ60候选 | C |
| `STEM_SHOULDER_OD` | ≈φ74 | C+ |
| `THRUST_UP` | φ75×φ65×2 | A |
| `STEM_GUIDE_BRG` | φ70×φ65×50 | A/C+ |
| `F0_Z` | +201.4 CAD | C |
| `STEM_GUIDE_Z0/Z1` | +203.4 / +253.4 | C |
| `STEM_ORING` | φ65×5.3 ×2 | A |
| `STEM_ORING_GROOT` | φ73.8 | B/C+ |
| `STEM_ORING_GW` | 7 | A |
| `OIL_LAND` | ≈16.8 | C |
| `PACKING` | φ75×φ65×5 | A |
| `PACK_INSTALL_T` | ≈4.4 | C/P |
| `COVER_OUT_BOSS_D` | φ105 | C+ |
| `COVER_OUT_ORING` | φ95×5.3 | A |
| `COVER_OUT_ORING_GROOT` | φ96.6（按静槽深4.2） | B/C+ |
| `COVER_GASKET` | φ115×φ105×3.2 | A |

当前V12轴向草模链：

```text
止推：+201.4 ~ +203.4
阀杆导向轴承：+203.4 ~ +253.4
第一O圈槽：约+277.0 ~ +284.0
第二O圈槽：约+300.8 ~ +307.8
填料自由件：约+313.1 ~ +318.1
```

上球体轴承外轨和阀杆内轨允许在Z方向重叠，因为半径不同。

---

## 4.5 下球体主支承 / 底盖

| 参数ID | 当前值 | 状态 |
|---|---:|---|
| `LOWER_BRG` | φ70×φ65×50 | A |
| `LOWER_JOURNAL_D` | φ65，底盖本体一体 | C+ |
| `LOWER_THRUST` | φ65×φ20×2 | A/C+ |
| `LOWER_BRG_CENTER_Z` | -202.0 | C |
| `LOWER_BRG_Z_OUT` | -227.0 | C |
| `LOWER_BRG_Z_IN` | -177.0 | C |
| `LOWER_BORE_MOUTH_Z` | -227.0 CAD候选 | C |
| `LOWER_BORE_BOTTOM_Z` | ? | D |
| `B_SUPPORT_ARM` | 202.039 | B/C |
| `BOTTOM_BOSS_D` | φ70 | C+ |
| `BOTTOM_ORING` | φ58×5.3 AED | A |
| `BOTTOM_ORING_GROOT` | φ61.6 | B/C+ |
| `BOTTOM_GASKET` | φ80×φ70×3.2 | A |
| `BOTTOM_STUD` | 6×M12×55 | A |
| `BOTTOM_COVER_H_CAD` | ≈114 | C/H-guide |
| `BOTTOM_BOLT_PCD` | ? | D |
| `BOTTOM_FLANGE_OD` | ? | D |

正确链：

```text
球体φ70孔
↓
φ70×φ65×50轴承
↓
底盖本体一体φ65轴颈
```

---

# 5. 支承载荷与反力

```text
F_SUPPORT = 164.692 kN

a = 208.566 mm
b = 202.039 mm

Ru = F*b/(a+b) = 81.037 kN
Rl = F*a/(a+b) = 83.655 kN
```

敏感性：

```text
Ru ≈80.0~82.1 kN
Rl ≈82.6~84.7 kN
```

平均面压需求：

```text
上轴承：81.037kN/(100×30) ≈27.01 MPa
下轴承：83.655kN/(65×50)  ≈25.74 MPa
```

316+PTFE具体牌号/许用面压仍D。

---

# 6. 第5步内部功能包络

## ENV-A：中央球体运动区

```text
ENV_BALL:
x²+y²+z² ≤ 232.5²
```

中央径向最大控制对象是：

```text
球体 R232.5
```

因为阀座/阀盖最大主要径向包络：

```text
φ382 → R191
```

比球半径小：

```text
232.5-191 = 41.5 mm
```

---

## ENV-B：左右阀座延伸区

当前功能空间：

```text
单侧WSEAT_ENV ≈58
前移 ≥1.0
后退草模余量 0.5
```

真实座腔轴向基准仍D。

第一轮仅作空间预留：

```text
X_SEAT_RESERVE_R = +232.5    P/C-space
X_SEAT_RESERVE_L = -232.5    P/C-space
```

这不是结构长度或制造端面。

---

## ENV-C：上部支承 / 阀杆颈区

上球体轴承：

```text
φ105
Z=+193.6 ~ +223.6
```

整个轴承圆柱包络仍可落在R232.5主球面空间内。

真正向+Z突破球体包络的是阀杆密封/填料链：

```text
Z_TOP_STEM_FUNC_CAD ≈ +318.1
```

当前最低已知上颈功能外径：

```text
TOP_NECK_FUNC_D_MIN = 115
```

φ115由当前缠绕垫OD控制，不是前盖法兰OD。

---

## ENV-D：下部支承 / 底盖接口区

下轴承：

```text
φ70
Z=-227 ~ -177
```

也位于球体运动包络内部。

当前最低已知底部密封功能直径：

```text
BOTTOM_FUNC_D_MIN = 80
```

底盖法兰OD/PCD、阀体安装面绝对Z仍D。

---

# 7. 球体—阀体中腔三档敏感性

固定球阀公司规范当前没有直接给本枢轴结构的球体主球面—阀体间隙固定数值。

因此：

```text
BALL_BODY_CLR_RAD_FINAL = ?    D
```

同公司浮动球阀 `GFE-JS02` 的 `1.5~6mm` 仅作为 `P-XREF`。

SolidWorks建立三档配置：

| 配置 | 径向间隙 | 功能中腔直径 | 状态 |
|---|---:|---:|---|
| `CLR_1P5` | 1.5 | φ468 | P-XREF |
| `CLR_3P0` | 3.0 | φ471 | P-XREF |
| `CLR_6P0` | 6.0 | φ477 | P-XREF |

公式：

```text
BODY_CAVITY_D_FUNC
= 465 + 2*BALL_BODY_CLR_RAD
```

可把 `CLR_3P0` 当默认显示场景，但禁止标成最终制造值。

---

# 8. 阀体承压壁厚政策

公司固定球阀规范已关闭方法：

```text
先查 ASME B16.34 最小壁厚
再增加 3~5mm
查不到则按 ASME VIII-1 UG-27
```

所以：

```text
T_B1634 = ?                       D
BODY_WALL_ADD = 3~5 mm            A-policy
BODY_WALL_TARGET >= T_B1634+3~5  A-policy / 数值D
```

当前不能用历史HTML或估值冒充 `T_B1634` 正式表值。

---

# 9. 当前装配关系表 V5

| Mate ID | 主对象 | 从对象 | 关系 |
|---|---|---|---|
| M001 | 骨架 | 球体 | 球心O固定，X/Z轴对齐 |
| M002 | 球体 | 左DEVLON | R232.5同心球面接触 |
| M003 | 球体 | 右DEVLON | R232.5同心球面接触 |
| M004 | 骨架X轴 | 左阀座 | 同轴，仅留X功能移动 |
| M005 | 骨架X轴 | 右阀座 | 同轴，仅留X功能移动 |
| M006 | 阀盖 | 阀座支承圈 | φ342.4孔 ↔ φ342 OD同轴 |
| M007 | 阀盖 | 内pilot | φ323.8 ↔ φ323.6同轴 |
| M008 | 阀盖 | 支承圈大端 | φ382 ↔ φ380同轴 |
| M009 | 球体上孔 | 上球体轴承 | φ105 ↔ φ105同轴 |
| M010 | 上球体轴承 | 前盖一体轴颈 | φ100 ID ↔ φ100轴颈 |
| M011 | 阀杆 | 阀杆导向轴承 | φ65 ↔ φ65同轴 |
| M012 | 前盖 | 阀杆导向轴承 | φ70孔 ↔ φ70 OD |
| M013 | 阀杆 | 上止推垫 | 同轴+端面止推 |
| M014 | 球体下孔 | 下球体轴承 | φ70 ↔ φ70同轴 |
| M015 | 下球体轴承 | 底盖一体轴颈 | φ65 ↔ φ65同轴 |
| M016 | 底盖 | 阀体下接口 | 定位圆同轴 + 安装面定位 |
| M017 | 上球体轴承 | 阀杆导向轴承 | 不同径向轨道，允许Z重叠 |
| M018 | 球体 | 阀体内腔 | 必须留功能间隙，不设接触 |

---

# 10. 当前空间坐标表 V5

| 坐标ID | 对象 | 当前坐标/范围 | 状态 |
|---|---|---:|---|
| C001 | 球心 | (0,0,0) | B/C+ |
| C002 | 左/右球体端基准 | X=±174 | B/C |
| C003 | 右阀座接触带中心 | X=+166.036 | B/C |
| C004 | 左阀座接触带中心 | X=-166.036 | B/C |
| C005 | 上球体轴承中心 | Z=+208.6 | C |
| C006 | 上球体轴承范围 | +193.6~+223.6 | C |
| C007 | 阀杆F0 | Z≈+201.4 | C |
| C008 | 阀杆导向轴承 | +203.4~+253.4 | C |
| C009 | 当前阀杆功能最高点 | Z≈+318.1 | C |
| C010 | 下球体轴承中心 | Z=-202.0 | C |
| C011 | 下球体轴承范围 | -227~-177 | C |
| C012 | 下球孔口 | Z≈-227 | C |
| C013 | 下球孔总孔底 | ? | D |
| C014 | 左右座腔真实外端 | ? | D |
| C015 | 底盖—阀体真实安装面 | ? | D |

---

# 11. SolidWorks当前直接可用变量

```text
# ---------- BASE ----------
BALL_CENTER_O = (0,0,0)
FLOW_AXIS     = X
SUPPORT_AXIS  = Z

# ---------- BALL ----------
BORE_D        = 303
BALL_OD       = 465
BALL_R        = 232.5
BALL_X_L      = -174
BALL_X_R      = +174
BALL_UPPER_BORE_D = 105
BALL_UPPER_BORE_EFFECTIVE_L = 28.9
BALL_UPPER_BORE_TOTAL_DEPTH = ?
BALL_LOWER_BORE_D = 70
BALL_LOWER_BORE_EFFECTIVE_L = 50
BALL_LOWER_BORE_TOTAL_DEPTH = ?

# ---------- SEAT ----------
SEAT_D9       = 323.88
SEAT_D10      = 327.13
SEAT_D11      = 342
SEAT_GUIDE_BORE = 342.4
SPRING_PCD    = 362
SEAT_BIG_OD   = 380
COVER_BIG_BORE= 382
WSEAT_ENV     = 58
SEAT_TRAVEL_FWD  = 1.0
SEAT_TRAVEL_BACK = 0.5

# ---------- UPPER BALL SUPPORT ----------
UP_BALL_BRG_OD = 105
UP_BALL_BRG_ID = 100
UP_BALL_BRG_L  = 30
UP_BRG_CENTER_Z= 208.6
UP_BRG_Z0      = 193.6
UP_BRG_Z1      = 223.6
UP_JOURNAL_D   = 100

# ---------- STEM INNER RAIL ----------
STEM_MAIN_D    = 65
F0_Z           = 201.4
THRUST_UP_T    = 2
STEM_GUIDE_OD  = 70
STEM_GUIDE_ID  = 65
STEM_GUIDE_L   = 50
STEM_GUIDE_Z0  = 203.4
STEM_GUIDE_Z1  = 253.4
STEM_ORING_ROOT= 73.8
STEM_ORING_GW  = 7
OIL_LAND       = 16.8
Z_TOP_STEM_FUNC_CAD = 318.1
TOP_NECK_FUNC_D_MIN = 115

# ---------- LOWER BALL SUPPORT ----------
LOWER_BRG_OD   = 70
LOWER_BRG_ID   = 65
LOWER_BRG_L    = 50
LOWER_BRG_CENTER_Z = -202.0
LOWER_BRG_Z_OUT    = -227.0
LOWER_BRG_Z_IN     = -177.0
LOWER_BORE_MOUTH_Z = -227.0
LOWER_BORE_BOTTOM_Z= ?
LOWER_JOURNAL_D= 65
BOTTOM_FUNC_D_MIN = 80

# ---------- CAVITY SENSITIVITY ----------
CLR_1P5 = 1.5
BODY_CAVITY_D_1P5 = 468
CLR_3P0 = 3.0
BODY_CAVITY_D_3P0 = 471
CLR_6P0 = 6.0
BODY_CAVITY_D_6P0 = 477
BALL_BODY_CLR_RAD_FINAL = ?
BODY_CAVITY_D_FINAL = ?

# ---------- BODY WALL ----------
T_B1634 = ?
BODY_WALL_ADD_MIN = 3
BODY_WALL_ADD_MAX = 5

# ---------- LOAD ----------
F_SUPPORT     = 164.692
A_SUPPORT_ARM = 208.566
B_SUPPORT_ARM = 202.039
RU_SUPPORT    = 81.037
RL_SUPPORT    = 83.655
```

---

# 12. 当前开放项 R/D

| ID | 开放项 | 状态 | 关闭方式 |
|---|---|---|---|
| RD001 | 球体—阀体最终径向间隙 | D | 固定球成熟12寸/公司规则/装配校核 |
| RD002 | ASME B16.34最小壁厚 `T_B1634` | D | 正式表号/页码 |
| RD003 | 阀体最终设计壁厚 | D | `T_B1634 + 3~5` |
| RD004 | 左右阀座真实座腔轴向基准 | D | 20寸总装拓扑 + 12寸座腔闭合 |
| RD005 | 上球孔总加工深度 | D | 12寸球体加工过渡 |
| RD006 | 下球孔总加工深度/孔底Z | D | 12寸球体加工过渡 |
| RD007 | 前盖最终总高/接口面 | D | 第5C/6步 |
| RD008 | 底盖—阀体真实安装面 | D | 第5C/6步 |
| RD009 | 底盖法兰OD/PCD | D | 强度+边距+公司系列 |
| RD010 | 316+PTFE轴承许用面压 | D | 供应商数据 |
| RD011 | 项目最终设计温度 | R/D | 正式项目数据表 |

---

# 13. 历史纠错——禁止重新启用

```text
H/R-01
上球体主支承 = φ70×φ65×50
→ 错；当前为φ105×φ100×30

H/R-02
Z_RU = Z_U0_ABS+27 作为上球体反力中心
→ 错；那是旧阀杆内轨理解

H-03
Ru=Rl≈82.35kN
→ 仅早期对称假设

H/R-04
独立下支承轴
→ 当前为底盖本体一体φ65轴颈

H/C-05
下球孔固定总深52mm
→ 当前只有有效圆柱50mm已关闭；总深D

H/C-06
下球孔固定孔底Z=-175
→ 当前孔底D
```

---

# 14. 当前SolidWorks装配顺序

```text
00_SKELETON
↓
01_BALL
↓
02_LEFT_SEAT / 03_RIGHT_SEAT
↓
04_FRONT_COVER / UPPER BALL SUPPORT
↓
05_STEM INNER RAIL
↓
06_BOTTOM_COVER / LOWER SUPPORT
↓
07_BODY / END COVERS
↓
连接盘 / 密封 / 紧固
↓
三档中腔配置干涉检查
↓
阀座活动极限检查
↓
90°运动检查
↓
公差 / 强度复核
```

---

# 15. 下一步

当前第5步已经完成：

```text
球体中央运动包络
+
左右阀座空间包络
+
上部支承/阀杆包络
+
下部支承包络
+
中腔三档敏感性
```

下一步继续：

```text
第5C / 第6步预处理
↓
读取现有20寸成熟总装的左右阀座/阀盖X向层级
↓
读取前盖/底盖与阀体真实接口层级
↓
建立12寸BODY第一版参数化承压外壳
↓
待T_B1634正式值到位后冻结壁厚
```

**当前继续推进不需要用户提供新资料。**

---

# 16. V5变更记录

## 2026-08-22

- 同步V16内部整体空间；
- 同步V17球体—阀体中腔三档敏感性；
- 增加固定球公司规则与浮动球跨结构参考的权限分层；
- 阀体壁厚政策固定为 `ASME B16.34 +3~5mm`；
- 下球孔“52固定深度”正式降级为H/C；
- 下孔有效圆柱段改为50mm C+；
- `LOWER_BORE_BOTTOM_Z=-175`降级为H/C，当前孔底保持D；
- 上球孔增加有效圆柱段约28.9mm，总加工深度保持D；
- 数字化总账正式进入第5步完成、准备阀体/阀盖参数化外壳阶段。

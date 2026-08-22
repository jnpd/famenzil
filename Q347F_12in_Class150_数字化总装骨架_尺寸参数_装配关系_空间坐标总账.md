# Q347F 12寸 Class150——数字化总装骨架总账 V6

> **定位**：这是当前 Q347F 12寸 Class150 固定球阀的唯一汇总结果页。  
> 保存当前有效的 **尺寸参数 + 装配关系 + 空间坐标 + SolidWorks变量 + 开放项**。  
> **当前主线已推进到 V18 / 第5C步**：内部功能包络、610长型CAD结构长度、左右体盖/上前盖/底盖参数化接口以及中法兰公式均已建立。

[← 总导航](./00_Q347F_12in_Class150_文档导航_从这里开始.md)  
[← 主计算母版](./Q347F_12in_Class150_球体设计计算底稿_第一部分_小白可读公式完整版.md)  
[← 当前有效V11](./Q347F_12in_Class150_第4C步_20寸原生支承_阀杆轴向证据_12寸V11坐标骨架.md)  
[← 当前有效V12](./Q347F_12in_Class150_第4D步_12寸前盖_底盖制造草模尺寸链_V12.md)  
[← V15支承纠错](./Q347F_12in_Class150_第4G步_上下主支承身份纠错_反力中心与CAD坐标闭合_V15.md)  
[← V16内部整体空间](./Q347F_12in_Class150_第5A步_内部整体空间_球体阀座上下支承统一包络_V16.md)  
[← V17中腔间隙与下球孔纠错](./Q347F_12in_Class150_第5B步_阀体中腔间隙_公司规则分层_下球孔纠错_V17.md)  
[← V18阀体/阀盖参数化接口](./Q347F_12in_Class150_第5C步_阀体阀盖参数化接口_中法兰与XYZ骨架_V18.md)

---

# 1. 状态规则

| 状态 | 含义 |
|---|---|
| **A** | 项目/BOM/公司明确值 |
| **A-policy** | 公司设计方法明确，具体标准数值待查 |
| **B** | 由接受输入直接计算 |
| **C** | CAD候选，可草模，未制造冻结 |
| **C+** | 多条独立证据交叉支持 |
| **D** | 前置条件不足，禁止填死 |
| **P-XREF** | 跨结构参考/敏感性 |
| **H** | 历史值 |
| **H/R** | 历史且已纠正，禁止当前使用 |

---

# 2. 项目基线

```text
NPS              = 12 / DN300                 A
CLASS            = 150                        A
TYPE             = 固定球 / 枢轴固定          A
BORE_D           = 303                        A
P_DESIGN         = 2.0 MPa                    A
MEDIUM           = 天然气                      A
BODY_MAT         = ASTM A216 WCB              A
BALL_MAT         = ASTM A182 F316             A
STEM_MAT         = ASTM A182 F51              A
SEAT_SOFT        = DEVLON                     A
ORING_MAT        = VITON                      A
```

公司结构规则：

```text
CL150~CL900 且 NPS≤12 → 枢轴固定
```

---

# 3. 全局坐标 / 结构长度

```text
BALL_CENTER_O = (0,0,0)
FLOW_AXIS     = X
SUPPORT_AXIS  = Z
```

当前结构长度：

```text
F2F_LONG_REF  = 610 mm
F2F_SHORT_REF = 356 mm
VALVE_F2F_CAD = 610 mm       C+
VALVE_F2F_FINAL = ?          D/A待项目最终确认

X_END_FACE_R  = +305
X_END_FACE_L  = -305
```

几何反校核：

```text
球体端基准±174
长型每侧可用：305-174=131
减阀座功能包络58后仍≈73mm/侧
```

因此610与当前几何链兼容。

短型：

```text
178-174=4mm/侧
```

无法容纳当前约58mm/侧阀座功能链，故：

```text
356短型 = H/R-for-current-geometry
```

---

# 4. 球体

```text
BALL_OD                         = 465          C
BALL_R                          = 232.5        B
BALL_W_X                        = 348          C
BALL_X_FACE_L/R                 = ±174         B/C
BALL_UPPER_BORE_D               = 105          C+
BALL_UPPER_BORE_EFFECTIVE_L     ≈28.9         C
BALL_UPPER_BORE_TOTAL_DEPTH     = ?            D
BALL_LOWER_BORE_D               = 70           C+
BALL_LOWER_BORE_EFFECTIVE_L     = 50           C+
BALL_LOWER_BORE_TOTAL_DEPTH     = >=50,具体?   D
```

历史：

```text
下球孔固定52mm → H/C
孔底Z=-175      → H/C
```

---

# 5. 阀座密封副

```text
SEAT_D9             = 323.88
SEAT_D10            = 327.13
SEAT_D11            = 342
SEAT_GUIDE_BORE     = 342.4
SEAT_GUIDE_CLR_RAD  = 0.20

SEAT_ORING_MAIN     = 320×5.3
SEAT_ORING_ROOT     = 333.6

SEAT_ORING_2        = 311×3.55
SEAT_PILOT_2        = 323.6
SEAT_GUIDE_2        = 323.8
SEAT_CLR2_RAD       = 0.10

SPRING              = φ8×φ1.6×18×7
SPRING_QTY          = 36/侧
SPRING_H_INST       ≈15.6
SPRING_PCD          = 362

SEAT_BIG_OD         = 380
COVER_BIG_BORE      = 382
WSEAT_ENV           ≈58       C-space
SEAT_TRAVEL_FWD     >=1.0
SEAT_TRAVEL_BACK    =0.5
```

接触带：

```text
X_CONTACT_R = +166.036
X_CONTACT_L = -166.036
```

局部坐标：

```text
u_R = X - X_CONTACT_R
u_L = -(X - X_CONTACT_L)
```

真实体盖接口：

```text
L_CONTACT_TO_SEAT_DATUM = ?
L_SEAT_DATUM_TO_COVER_IF = ?

X_BODY_COVER_IF_R
= X_CONTACT_R + L_CONTACT_TO_SEAT_DATUM + L_SEAT_DATUM_TO_COVER_IF

X_BODY_COVER_IF_L
= -X_BODY_COVER_IF_R
```

当前：

```text
X_BODY_COVER_IF_L/R = ? D
```

---

# 6. 上球体主支承

```text
UP_BALL_BRG       = φ105×φ100×30     A/C+
UP_JOURNAL_D      = φ100             C+
UP_BRG_CENTER_Z   = +208.6           C
UP_BRG_Z0         = +193.6           C
UP_BRG_Z1         = +223.6           C
A_SUPPORT_ARM     = 208.566          B/C
```

正确链：

```text
球体φ105孔
↓
φ105×φ100×30轴承
↓
前盖一体φ100轴颈
```

---

# 7. 阀杆 / 上部内轨

```text
STEM_MAIN_D          = 65
STEM_KEY_D           = 60候选
STEM_SHOULDER_OD     ≈74
THRUST_UP            = φ75×φ65×2
STEM_GUIDE_BRG       = φ70×φ65×50

F0_Z                 = +201.4        C
STEM_GUIDE_Z0        = +203.4
STEM_GUIDE_Z1        = +253.4

STEM_ORING            = φ65×5.3×2
STEM_ORING_GROOT      = φ73.8
STEM_ORING_GW         = 7
OIL_LAND              ≈16.8
PACKING               = φ75×φ65×5
PACK_INSTALL_T        ≈4.4 C/P
Z_TOP_STEM_FUNC_CAD   ≈+318.1
```

---

# 8. 下球体主支承 / 底盖

```text
LOWER_BRG             = φ70×φ65×50      A
LOWER_JOURNAL_D       = φ65              C+ / 底盖一体
LOWER_THRUST          = φ65×φ20×2       A/C+
LOWER_BRG_CENTER_Z    = -202.0           C
LOWER_BRG_Z_OUT       = -227.0           C
LOWER_BRG_Z_IN        = -177.0           C
LOWER_BORE_MOUTH_Z    = -227.0           C
LOWER_BORE_BOTTOM_Z   = ?                D
B_SUPPORT_ARM         = 202.039          B/C
```

---

# 9. 支承载荷

```text
F_SUPPORT = 164.692 kN
Ru = 81.037 kN
Rl = 83.655 kN
```

平均面压需求：

```text
上≈27.01 MPa
下≈25.74 MPa
```

316+PTFE具体许用面压仍D。

---

# 10. 第5步内部功能包络

中央：

```text
ENV_BALL: x²+y²+z² ≤ 232.5²
```

阀座大端：

```text
φ382 → R191 < R232.5
```

所以上下轴承不会把中央径向球腔顶大；中央主控制仍为球体。

上部：

```text
上轴承 Z=193.6~223.6
阀杆功能链最高 ≈+318.1
TOP_NECK_FUNC_D_MIN=115
```

下部：

```text
下轴承 Z=-227~-177
BOTTOM_FUNC_D_MIN=80
```

---

# 11. 中央球腔三档敏感性

最终固定球间隙仍：

```text
BALL_BODY_CLR_RAD_FINAL = ? D
```

P-XREF：

```text
CLR_1P5 → φ468
CLR_3P0 → φ471
CLR_6P0 → φ477
```

默认显示草模可用φ471，但不是制造值。

---

# 12. BODY承压壁政策

公司固定球阀规则：

```text
T_BODY_TARGET
>= T_B1634 + 3~5mm
```

当前：

```text
T_B1634 = ? D
BODY_WALL_ADD = 3~5 A-policy
```

中央第一轮外包络公式：

```text
BODY_OUTER_D_CENTRAL_GUIDE
= BODY_CAVITY_D_FUNC + 2*T_BODY_TARGET
```

---

# 13. 左右中法兰参数公式

公司规则已经转成：

```text
MID_GASKET_W = 5~10mm    A-policy

MID_BCD
= MID_GASKET_OD
+ MID_BOLT_HOLE_D
+ MID_BCD_EDGE

MID_BCD_EDGE = 3~6mm

MID_FLANGE_OD
= MID_BCD + MID_COUNTERBORE_D
```

待定变量：

```text
MID_GASKET_ID/OD = ?
MID_BOLT_SIZE = ?
MID_BOLT_QTY = ?
MID_BOLT_HOLE_D = ?
MID_COUNTERBORE_D = ?
```

螺栓总有效抗拉面积需按ASME B16.34 6.4.2.1校核。

---

# 14. 上前盖接口 IF-Z-U

当前径向链：

```text
TOP_IF_GUIDE_D      =105
TOP_IF_ORING        =95×5.3
TOP_IF_ORING_ROOT_D =96.6
TOP_IF_GASKET       =115×105×3.2
```

轴向安装面：

```text
Z_BODY_TOP_IF = ? D
```

注意：

```text
F0=+201.4
≠
BODY_TOP_IF
```

---

# 15. 底盖接口 IF-Z-L

```text
BOTTOM_IF_GUIDE_D      =70
BOTTOM_IF_ORING        =58×5.3
BOTTOM_IF_ORING_ROOT_D =61.6
BOTTOM_IF_GASKET       =80×70×3.2
BOTTOM_IF_STUD_QTY     =6
BOTTOM_IF_STUD_SIZE    =M12
BOTTOM_IF_STUD_L       =55
```

待定：

```text
Z_BODY_BOTTOM_IF = ?
BOTTOM_IF_BCD = ?
BOTTOM_IF_FLANGE_OD = ?
```

---

# 16. 当前核心装配关系

| Mate | 关系 |
|---|---|
| M001 | 球体固定在O，X/Z轴对齐 |
| M002/3 | 左右DEVLON与R232.5球面同心接触 |
| M004/5 | 左右阀座同轴X，只保留X向功能移动 |
| M006 | φ342支承圈 ↔ φ342.4阀盖孔 |
| M007 | φ323.6 pilot ↔ φ323.8阀盖孔 |
| M008 | φ380大端 ↔ φ382阀盖孔 |
| M009 | 球体φ105孔 ↔ 上球体轴承φ105 |
| M010 | 上轴承φ100ID ↔ 前盖一体φ100轴颈 |
| M011 | 阀杆φ65 ↔ 阀杆导向轴承φ65ID |
| M012 | 阀杆导向轴承φ70OD ↔ 前盖φ70孔 |
| M013 | 球体φ70下孔 ↔ 下轴承φ70OD |
| M014 | 下轴承φ65ID ↔ 底盖一体φ65轴颈 |
| M015 | 前盖φ105boss ↔ BODY上接口导向孔 + 端面定位 |
| M016 | 底盖φ70boss ↔ BODY下接口导向孔 + 端面定位 |
| M017 | BODY ↔ 左右阀盖：同轴X + 中法兰端面压紧 |
| M018 | 上球体轴承外轨与阀杆导向内轨允许Z向重叠 |

---

# 17. SolidWorks当前变量块

```text
# BASE
BALL_CENTER_O=(0,0,0)
FLOW_AXIS=X
SUPPORT_AXIS=Z

# F2F
VALVE_F2F_CAD=610
X_END_FACE_R=305
X_END_FACE_L=-305

# BALL
BORE_D=303
BALL_OD=465
BALL_R=232.5
BALL_X_R=174
BALL_X_L=-174
BALL_UPPER_BORE_D=105
BALL_UPPER_BORE_EFFECTIVE_L=28.9
BALL_UPPER_BORE_TOTAL_DEPTH=?
BALL_LOWER_BORE_D=70
BALL_LOWER_BORE_EFFECTIVE_L=50
BALL_LOWER_BORE_TOTAL_DEPTH=?

# SEAT
X_CONTACT_R=166.036
X_CONTACT_L=-166.036
SEAT_D11=342
SEAT_GUIDE_BORE=342.4
SPRING_PCD=362
SEAT_BIG_OD=380
COVER_BIG_BORE=382
WSEAT_ENV=58
X_BODY_COVER_IF_R=?
X_BODY_COVER_IF_L=?

# UPPER SUPPORT
UP_BALL_BRG_OD=105
UP_BALL_BRG_ID=100
UP_BALL_BRG_L=30
UP_BRG_CENTER_Z=208.6
UP_BRG_Z0=193.6
UP_BRG_Z1=223.6
UP_JOURNAL_D=100

# STEM
STEM_MAIN_D=65
F0_Z=201.4
STEM_GUIDE_OD=70
STEM_GUIDE_ID=65
STEM_GUIDE_L=50
STEM_GUIDE_Z0=203.4
STEM_GUIDE_Z1=253.4
Z_TOP_STEM_FUNC_CAD=318.1

# LOWER SUPPORT
LOWER_BRG_OD=70
LOWER_BRG_ID=65
LOWER_BRG_L=50
LOWER_BRG_CENTER_Z=-202.0
LOWER_BRG_Z_OUT=-227.0
LOWER_BRG_Z_IN=-177.0
LOWER_BORE_MOUTH_Z=-227.0
LOWER_BORE_BOTTOM_Z=?
LOWER_JOURNAL_D=65

# TOP IF
TOP_IF_GUIDE_D=105
TOP_IF_ORING_ROOT_D=96.6
TOP_IF_GASKET_ID=105
TOP_IF_GASKET_OD=115
Z_BODY_TOP_IF=?

# BOTTOM IF
BOTTOM_IF_GUIDE_D=70
BOTTOM_IF_ORING_ROOT_D=61.6
BOTTOM_IF_GASKET_ID=70
BOTTOM_IF_GASKET_OD=80
BOTTOM_IF_STUD_QTY=6
BOTTOM_IF_STUD_SIZE=M12
BOTTOM_IF_BCD=?
BOTTOM_IF_FLANGE_OD=?
Z_BODY_BOTTOM_IF=?

# CAVITY
BALL_BODY_CLR_RAD=3.0   # 当前显示配置，P-XREF
BODY_CAVITY_D_FUNC=471
BALL_BODY_CLR_RAD_FINAL=?
BODY_CAVITY_D_FINAL=?

# BODY WALL
T_B1634=?
BODY_WALL_ADD_MIN=3
BODY_WALL_ADD_MAX=5
T_BODY_TARGET=?

# MID FLANGE
MID_GASKET_ID=?
MID_GASKET_OD=?
MID_GASKET_W_MIN=5
MID_GASKET_W_MAX=10
MID_BOLT_HOLE_D=?
MID_COUNTERBORE_D=?
MID_BCD_EDGE=3~6
MID_BCD=?
MID_FLANGE_OD=?
MID_BOLT_QTY=?
MID_BOLT_SIZE=?

# LOAD
F_SUPPORT=164.692
A_SUPPORT_ARM=208.566
B_SUPPORT_ARM=202.039
RU_SUPPORT=81.037
RL_SUPPORT=83.655
```

---

# 18. 当前开放项

| ID | 开放项 | 状态 |
|---|---|---|
| RD001 | 最终球体—阀体间隙 | D |
| RD002 | ASME B16.34最小壁厚T_B1634 | D |
| RD003 | BODY最终壁厚 | D |
| RD004 | 左右BODY-COVER接口X | D |
| RD005 | 中法兰垫片尺寸 | D |
| RD006 | 中法兰螺栓规格/数量/PCD/OD | D |
| RD007 | 上前盖安装面Z | D |
| RD008 | 底盖安装面Z | D |
| RD009 | 底盖法兰PCD/OD | D |
| RD010 | 上/下球孔总加工深度 | D |
| RD011 | 316+PTFE许用面压 | D |
| RD012 | 最终F2F项目确认 | D/A；CAD当前610 C+ |
| RD013 | 最终设计温度 | R/D |

---

# 19. 历史纠错

```text
H/R 上球体主轴承=φ70×φ65×50
→ 当前φ105×φ100×30

H/R Z_RU=Z_U0_ABS+27作为上球体反力中心
→ 当前约+208.6

H 对称Ru=Rl≈82.35
→ 当前81.037/83.655

H/R 独立下支承轴
→ 当前底盖本体一体φ65轴颈

H/C 下球孔固定总深52
→ 当前有效圆柱50，总深D

H/C 下球孔底Z=-175
→ 当前D

H/R 356短型用于当前348宽球体/58阀座链
→ 几何空间不兼容；当前CAD采用610长型
```

---

# 20. 当前建模文件层级

```text
00_SKELETON.SLDPRT
01_BALL.SLDPRT
02_LEFT_SEAT.SLDASM
03_RIGHT_SEAT.SLDASM
04_FRONT_COVER.SLDPRT
05_STEM.SLDPRT
06_BOTTOM_COVER.SLDPRT
07_BODY_ENVELOPE.SLDPRT
08_LEFT_END_COVER_ENVELOPE.SLDPRT
09_RIGHT_END_COVER_ENVELOPE.SLDPRT
```

当前07~09先做参数化Envelope，不冒充制造冻结零件。

---

# 21. 下一步

```text
第6A 阀体承压设计
↓
查T_B1634
↓
BODY中央壁厚
↓
左右中法兰螺栓面积
↓
上/下接口局部承压肉厚
↓
BODY第一版参数化承压实体
```

当前继续优先从已有资料寻找可追溯的 `T_B1634` 数据；若正式标准值没有可靠来源，则保持D，不猜。

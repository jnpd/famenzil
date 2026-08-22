# Q347F 12寸 Class150——第5C步：阀体 / 阀盖参数化接口、中法兰与XYZ骨架 V18

> **定位**：V16/V17已经回答“阀体内部至少要包住什么”。V18开始回答“这些功能空间怎样挂到阀体 / 左右阀盖 / 上前盖 / 底盖上”。  
> **本页目标**：先建立**接口基准 + 参数公式 + SolidWorks骨架关系**，不在缺正式壁厚、座腔端面和法兰细节时硬造加工尺寸。  
> **权限原则**：项目/BOM/公司固定球阀规范优先；20寸成熟结构只继承拓扑和无量纲关系；标准存在长/短型时保留配置切换，不把候选冒充最终项目值。

[← 总导航](./00_Q347F_12in_Class150_文档导航_从这里开始.md)  
[← 数字化总装骨架总账](./Q347F_12in_Class150_数字化总装骨架_尺寸参数_装配关系_空间坐标总账.md)  
[← V16 内部整体空间](./Q347F_12in_Class150_第5A步_内部整体空间_球体阀座上下支承统一包络_V16.md)  
[← V17 中腔间隙与下球孔纠错](./Q347F_12in_Class150_第5B步_阀体中腔间隙_公司规则分层_下球孔纠错_V17.md)

---

# 1. V18先把整阀拆成5个接口域

以球心O为全局原点：

```text
                     TOP / +Z
                         │
                    前盖 / 阀杆
                         │
 LEFT COVER ───── BODY ───── RIGHT COVER
    -X                   +X
                         │
                    BOTTOM COVER
                         │
                     BOTTOM / -Z
```

定义五个域：

```text
IF-X-L  = 左阀盖 / 阀体接口
IF-X-R  = 右阀盖 / 阀体接口
IF-Z-U  = 上前盖 / 阀体接口
IF-Z-L  = 底盖 / 阀体接口
ENV-C   = 中央球腔承压域
```

这样以后某一个接口尺寸变化，不需要把整个总装坐标重新算一遍。

---

# 2. 永久全局基准

```text
BALL_CENTER_O = (0,0,0)
FLOW_AXIS     = X
SUPPORT_AXIS  = Z
```

永久基准面：

```text
PLN_O_XY = Z=0
PLN_O_YZ = X=0
PLN_O_XZ = Y=0
```

左右镜像规则：

```text
X_LEFT = -X_RIGHT
```

在客户没有明确非对称结构要求前，左右阀盖/阀座骨架优先镜像。

---

# 3. 结构长度F2F：先参数化，不偷换“长型/短型”

当前 NPS12 / Class150 / 法兰球阀标准存在两种常见结构长度口径：

```text
Short Pattern ≈ 356 mm
Long Pattern  ≈ 610 mm
```

此前项目主线对天然气、全通径固定球阀第一轮骨架倾向：

```text
F2F_LONG_CANDIDATE = 610 mm
```

但制造冻结前仍必须由：

```text
客户数据表 / 项目规格书 / 正式API 6D或ASME B16.10选型口径
```

确认到底采用长型还是短型。

因此V18状态：

| 参数 | 当前值 | 状态 |
|---|---:|---|
| `F2F_LONG_REF` | 610 | C/STD-candidate |
| `F2F_SHORT_REF` | 356 | C/STD-alt |
| `VALVE_F2F_FINAL` | ? | D/A待项目确认 |

SolidWorks先建立配置：

```text
CFG_F2F_LONG  → VALVE_F2F = 610
CFG_F2F_SHORT → VALVE_F2F = 356
```

当前默认草模：

```text
CFG_F2F_LONG
```

对应法兰端面：

```text
X_END_FACE_R = +VALVE_F2F/2
X_END_FACE_L = -VALVE_F2F/2
```

长型草模：

```text
X_END_FACE_R = +305 mm
X_END_FACE_L = -305 mm
```

**±305只是长型骨架端面，不代表左右阀盖与阀体分界面。**

---

# 4. 左右阀座不要再用“绝对X硬塞”，改成局部坐标u

当前真实球面密封接触代表中心：

```text
X_CONTACT_R = +166.036 mm
X_CONTACT_L = -166.036 mm
```

为了以后阀座结构变化不破坏全局坐标，定义：

## 4.1 右侧局部坐标

```text
u_R = X - X_CONTACT_R
```

规定：

```text
u_R > 0 = 从球体向右阀盖外侧
```

所以：

```text
球面接触中心 = u_R=0
支承圈后端 / 弹簧 / 阀盖座腔 = u_R>0
```

## 4.2 左侧局部坐标

为了左右两侧都保持“向外为正”，定义：

```text
u_L = -(X - X_CONTACT_L)
```

所以：

```text
球面接触中心 = u_L=0
向左阀盖外侧 = u_L>0
```

这样左右阀座可以共用同一套局部尺寸链。

---

# 5. 阀座58mm功能包络在V18里的正确用法

当前：

```text
WSEAT_ENV ≈58 mm   C-space
```

它只表示：

```text
从某个阀座内部功能基准开始
需要约58mm总轴向功能空间
```

不等于：

```text
球面接触中心 + 58 = 阀盖安装面
```

因此正式增加变量：

```text
L_CONTACT_TO_SEAT_DATUM = ?      D
L_SEAT_DATUM_TO_COVER_IF = ?     D
```

右侧阀体—阀盖接口面：

```text
X_BODY_COVER_IF_R
= X_CONTACT_R
+ L_CONTACT_TO_SEAT_DATUM
+ L_SEAT_DATUM_TO_COVER_IF
```

左侧镜像：

```text
X_BODY_COVER_IF_L
= -X_BODY_COVER_IF_R
```

当前：

```text
X_BODY_COVER_IF_L/R = ?   D
```

这比把V16的 `±232.5` 当真实接口面更严谨。

V16：

```text
X_SEAT_RESERVE_R/L = ±232.5
```

继续仅保留：

```text
P/C-SPACE
```

用途只是第一轮占位盒。

---

# 6. 左右阀盖/阀体接口必须承担4个不同功能

一个真正的 `IF-X` 接口，不是“一张端面”这么简单，至少包括：

```text
A. 阀座导向 / 座腔
B. 阀体—阀盖定位
C. 承压静密封
D. 中法兰螺栓夹紧
```

所以V18骨架把它分成四条径向轨道：

```text
TRACK-X1 = 阀座内侧pilot / 第二O圈
TRACK-X2 = 主阀座导向 D11
TRACK-X3 = 支承圈大端 / 弹簧 / 防火密封
TRACK-X4 = 阀体—阀盖中法兰
```

当前前三轨主要径向尺寸已经有：

```text
TRACK-X1:
  pilot OD ≈323.6
  bore ≈323.8
  O-ring φ311×3.55

TRACK-X2:
  seat OD D11 =342
  guide bore  =342.4

TRACK-X3:
  spring PCD =362
  support big OD =380
  cover big bore =382
```

TRACK-X4的中法兰OD/螺栓圈尚未制造冻结。

---

# 7. 公司中法兰规则现在可以直接变成参数公式

公司固定球阀规范对阀体/阀盖中法兰给出：

```text
1. 中法兰用金属缠绕垫片
2. 垫片有效宽度约5~10mm
3. 螺栓中心圆直径
   = 垫片外径 + 螺栓孔径 + 3~6mm
4. 中法兰外圆
   = 螺栓中心圆 + 螺栓锪孔/沉孔直径
5. 螺栓规格/数量按ASME B16.34 6.4.2.1校核总有效拉应力面积
```

因此建立：

```text
MID_GASKET_ID = ?
MID_GASKET_OD = ?
MID_GASKET_W  = 5~10       A-policy

MID_BOLT_D    = ?
MID_BOLT_HOLE_D = ?
MID_COUNTERBORE_D = ?
MID_BOLT_QTY  = ?

MID_BCD_MIN
= MID_GASKET_OD + MID_BOLT_HOLE_D + 3

MID_BCD_MAX_GUIDE
= MID_GASKET_OD + MID_BOLT_HOLE_D + 6

MID_FLANGE_OD
= MID_BCD + MID_COUNTERBORE_D
```

这里：

```text
+3~6
```

是公司设计边距规则，不是最终公差。

---

# 8. 中法兰螺栓不靠“看起来够多”，而留出强度门

定义：

```text
A_G = 以中法兰垫片外围为压力边界的面积
P_C = 中法兰设计压力工况
S_B = 螺栓38℃许用应力
A_B_TOTAL = 全部螺栓有效抗拉面积
```

公司规范要求按照 ASME B16.34 6.4.2.1 的螺栓连接规则校核。

所以SolidWorks/计算账先建：

```text
MID_BOLT_QTY = ?
MID_BOLT_SIZE = ?
MID_BOLT_AREA_ONE = ?
MID_BOLT_AREA_TOTAL
= MID_BOLT_QTY * MID_BOLT_AREA_ONE

MID_BOLT_AREA_REQUIRED = f(P_C, A_G, S_B)

MID_BOLT_MARGIN
= MID_BOLT_AREA_TOTAL / MID_BOLT_AREA_REQUIRED
```

制造冻结目标：

```text
MID_BOLT_MARGIN >= 1
```

具体公式系数/标准表值等进入第6/7步正式标准校核。

---

# 9. 中央BODY承压外壳：从功能球腔向外长，不从外形向里猜

V17三档中腔功能直径：

```text
CLR_1P5 → φ468
CLR_3P0 → φ471
CLR_6P0 → φ477
```

它们全部是：

```text
P-XREF sensitivity
```

定义：

```text
BODY_CAVITY_D_FUNC
= BALL_OD + 2*BALL_BODY_CLR_RAD
```

然后阀体承压外边界不是再猜一个OD，而是：

```text
BODY_OUTER_R_LOCAL(θ,x)
>= BODY_CAVITY_R_LOCAL(θ,x)
 + T_BODY_REQUIRED_LOCAL(θ,x)
```

第一版中央等效圆包络可以写：

```text
BODY_OUTER_D_CENTRAL_GUIDE
= BODY_CAVITY_D_FUNC
+ 2*T_BODY_TARGET
```

其中：

```text
T_BODY_TARGET
>= T_B1634 + 3~5 mm
```

当前：

```text
T_B1634 = ? D
T_BODY_TARGET = ? D
```

但公式已经可以写进方程式管理器。

---

# 10. 为什么BODY不能直接做成“φ471 + 壁厚”的大圆球/大圆筒

实际阀体至少有：

```text
中央球腔
左右流道颈
左右中法兰座
上前盖座
下底盖座
VENT / DRAIN / 注脂局部肉厚
铸造圆角
```

所以：

```text
BODY_OUTER_D_CENTRAL_GUIDE
```

只负责中央区的第一轮承压外包络。

最后阀体应是多个压力边界圆滑融合，而不是一个“万能大圆筒”。

SolidWorks建议采用：

```text
中央回转/放样母体
+
左右颈部Boss
+
上支承Boss
+
下支承Boss
+
中法兰Boss
+
大圆角/过渡
```

---

# 11. 上前盖—阀体接口 IF-Z-U

当前12寸BOM/设计链已经给：

```text
上球体主支承：φ105×φ100×30
前盖球体支承轴颈：φ100
前盖外定位/密封boss：φ105
前盖外O圈：φ95×5.3
当前公司静槽深：4.2
槽底候选：φ96.6
接口缠绕垫：φ115×φ105×3.2
```

因此上接口径向功能链确定为：

```text
阀杆内轨 φ65/φ70
↓
上球体支承轴颈 φ100
↓
前盖外定位boss φ105
↓
φ95×5.3 静O圈槽
↓
φ115×φ105 缠绕垫端面密封
↓
阀体上部安装Boss / 紧固区
```

定义：

```text
TOP_IF_GUIDE_D       = 105
TOP_IF_ORING          = 95×5.3
TOP_IF_ORING_ROOT_D   = 96.6
TOP_IF_GASKET_ID      = 105
TOP_IF_GASKET_OD      = 115
```

这些径向链已经能进骨架。

但是：

```text
Z_BODY_TOP_IF = ?    D
```

仍不能由F0=+201.4直接冒充。

因为：

```text
F0 = 阀杆止推功能基准
```

而：

```text
Z_BODY_TOP_IF = 前盖与阀体真正安装/压紧端面
```

二者不是一个物理对象。

---

# 12. 上接口的SolidWorks正确Mate顺序

```text
BODY_SUPPORT_AXIS
=
FRONT_COVER_AXIS

BODY_TOP_GUIDE_BORE
↔
FRONT_COVER φ105 boss

BODY_TOP_MATE_FACE
↔
FRONT_COVER_MATE_FACE

φ115×φ105 gasket
位于两压紧端面之间

φ95×5.3 O-ring
位于前盖外圆静密封轨道
```

当前最重要的是**分清同轴定位和端面定位是两件事**。

---

# 13. 底盖—阀体接口 IF-Z-L

12寸BOM当前：

```text
底盖一体φ65轴颈
下球体轴承 φ70×φ65×50
底盖外定位/密封boss φ70
底盖O圈 φ58×5.3
当前静槽根径 φ61.6
缠绕垫 φ80×φ70×3.2
6×M12×55
```

因此底部径向功能链：

```text
球体下φ70支承孔
↓
φ70×φ65×50轴承
↓
底盖一体φ65轴颈
↓
底盖φ70定位boss
↓
φ58×5.3静O圈
↓
φ80×φ70缠绕垫
↓
阀体下部安装Boss / 6×M12紧固
```

定义：

```text
BOTTOM_IF_GUIDE_D      = 70
BOTTOM_IF_ORING         = 58×5.3
BOTTOM_IF_ORING_ROOT_D  = 61.6
BOTTOM_IF_GASKET_ID     = 70
BOTTOM_IF_GASKET_OD     = 80
BOTTOM_IF_STUD_QTY      = 6
BOTTOM_IF_STUD_SIZE     = M12
BOTTOM_IF_STUD_L        = 55
```

但：

```text
Z_BODY_BOTTOM_IF = ?   D
BOTTOM_IF_BCD     = ?   D
BOTTOM_IF_FLANGE_OD = ? D
```

仍必须等接口边距/强度/成熟系列关闭。

---

# 14. 上下接口为什么不能直接拿20寸同比缩

20寸能告诉我们：

```text
前盖是：一体支承轴颈 + 多级孔 + 密封boss + 法兰
底盖是：一体下支承轴颈 + O圈/垫片 + 圆周螺栓法兰
```

这是成熟拓扑 `C+`。

但不能做：

```text
20寸前盖法兰OD ×465/748 = 12寸最终法兰OD
20寸底盖PCD ×465/748 = 12寸最终PCD
```

因为12寸已经有独立的：

```text
φ115×φ105 gasket
φ80×φ70 gasket
M12紧固
```

这些12寸A类采购件会反过来控制接口尺寸。

---

# 15. V18建立的“BODY五张永久基准面”

SolidWorks `00_SKELETON.SLDPRT` 新增：

```text
PLN_END_L
X = -VALVE_F2F/2

PLN_END_R
X = +VALVE_F2F/2

PLN_BODY_COVER_IF_L
X = ?

PLN_BODY_COVER_IF_R
X = ?

PLN_BODY_TOP_IF
Z = ?

PLN_BODY_BOTTOM_IF
Z = ?
```

严格说是六张，但左右 `BODY_COVER_IF` 由镜像参数联动，可视为同一接口族。

规则：

```text
端法兰面
≠
体盖分界面
≠
阀座接触面
```

三类面永远不能混用。

---

# 16. 第一版BODY参数化外壳怎么画

当前还没有最终壁厚，但已经可以做“方程式驱动母体”。

## 16.1 中央腔

默认显示配置先用：

```text
BALL_BODY_CLR_RAD = 3.0   P-XREF
BODY_CAVITY_D_FUNC = 471
```

## 16.2 中央外壁

```text
T_BODY_TARGET = T_B1634 + BODY_WALL_ADD
BODY_WALL_ADD = 3~5
```

当 `T_B1634` 暂缺时，不把BODY做成制造零件；做成：

```text
06_BODY_ENVELOPE.SLDPRT
```

或骨架中的：

```text
SURF_BODY_PRESSURE_BOUNDARY
```

## 16.3 左右颈部

端面先由F2F配置控制：

```text
X_END = ±305   # long config
```

体盖分界面保持：

```text
X_BODY_COVER_IF = ?
```

因此左右阀盖长度自动定义：

```text
L_END_COVER_R
= X_END_FACE_R - X_BODY_COVER_IF_R

L_END_COVER_L
= X_BODY_COVER_IF_L - X_END_FACE_L
```

对称设计时：

```text
L_END_COVER_L = L_END_COVER_R
```

---

# 17. 用F2F做一个“空间可行性检查”，不是反推制造尺寸

长型草模：

```text
X_END = ±305
```

球体闭阀端基准：

```text
X_BALL_FACE = ±174
```

所以每侧从球体端基准到阀门端面的总可用空间：

```text
305 - 174 = 131 mm/侧
```

当前阀座总功能包络：

```text
≈58 mm/侧
```

那么长型第一轮剩余轴向空间：

```text
131 - 58 = 73 mm/侧
```

这73mm需要容纳/分配给：

```text
阀座起点定义误差
阀盖承压颈部
端法兰厚度/颈部过渡
体盖接口
制造余量
```

这说明：

> **610长型在当前功能包络层面有继续设计的空间，但73mm绝不能直接等于阀盖长度或法兰厚度。**

短型草模：

```text
X_END = ±178
```

球体端基准到端面：

```text
178 - 174 = 4 mm/侧
```

而当前单侧阀座功能包络约58mm。

因此对于当前 `BALL_W_X=348 / 球体端基准±174` 的设计链：

```text
356短型与当前球体/阀座空间明显不兼容
```

除非：

```text
球体X向宽348的定义被推翻
或短型采用完全不同的阀盖/球体结构
```

所以V18把结构长度候选状态提升为：

```text
F2F_LONG_REF = 610   C+
F2F_SHORT_REF = 356  H/R-for-current-geometry
```

当前SolidWorks主配置可以正式使用：

```text
VALVE_F2F_CAD = 610 mm   C+
```

制造冻结仍等待项目/标准选型最终确认，但短型不再作为当前几何同等候选。

---

# 18. V18新增SolidWorks变量

```text
# ========================
# F2F
# ========================
F2F_LONG_REF = 610
F2F_SHORT_REF = 356
VALVE_F2F_CAD = 610
VALVE_F2F_FINAL = ?

X_END_FACE_R = +VALVE_F2F_CAD/2
X_END_FACE_L = -VALVE_F2F_CAD/2

# ========================
# SEAT LOCAL DATUM
# ========================
X_CONTACT_R = +166.036
X_CONTACT_L = -166.036

L_CONTACT_TO_SEAT_DATUM = ?
L_SEAT_DATUM_TO_COVER_IF = ?

X_BODY_COVER_IF_R = X_CONTACT_R + L_CONTACT_TO_SEAT_DATUM + L_SEAT_DATUM_TO_COVER_IF
X_BODY_COVER_IF_L = -X_BODY_COVER_IF_R

WSEAT_ENV = 58

# ========================
# MID FLANGE
# ========================
MID_GASKET_ID = ?
MID_GASKET_OD = ?
MID_GASKET_W_MIN = 5
MID_GASKET_W_MAX = 10
MID_BOLT_HOLE_D = ?
MID_COUNTERBORE_D = ?
MID_BCD_EDGE_MIN = 3
MID_BCD_EDGE_MAX = 6
MID_BCD = MID_GASKET_OD + MID_BOLT_HOLE_D + MID_BCD_EDGE
MID_FLANGE_OD = MID_BCD + MID_COUNTERBORE_D
MID_BOLT_QTY = ?
MID_BOLT_SIZE = ?

# ========================
# TOP INTERFACE
# ========================
TOP_IF_GUIDE_D = 105
TOP_IF_ORING_ID = 95
TOP_IF_ORING_CS = 5.3
TOP_IF_ORING_ROOT_D = 96.6
TOP_IF_GASKET_ID = 105
TOP_IF_GASKET_OD = 115
TOP_IF_GASKET_T = 3.2
Z_BODY_TOP_IF = ?

# ========================
# BOTTOM INTERFACE
# ========================
BOTTOM_IF_GUIDE_D = 70
BOTTOM_IF_ORING_ID = 58
BOTTOM_IF_ORING_CS = 5.3
BOTTOM_IF_ORING_ROOT_D = 61.6
BOTTOM_IF_GASKET_ID = 70
BOTTOM_IF_GASKET_OD = 80
BOTTOM_IF_GASKET_T = 3.2
BOTTOM_IF_STUD_QTY = 6
BOTTOM_IF_STUD_SIZE = M12
BOTTOM_IF_STUD_L = 55
BOTTOM_IF_BCD = ?
BOTTOM_IF_FLANGE_OD = ?
Z_BODY_BOTTOM_IF = ?

# ========================
# BODY PRESSURE SHELL
# ========================
BALL_BODY_CLR_RAD = 3.0   # 当前显示配置，P-XREF
BODY_CAVITY_D_FUNC = BALL_OD + 2*BALL_BODY_CLR_RAD
T_B1634 = ?
BODY_WALL_ADD = 3~5
T_BODY_TARGET = T_B1634 + BODY_WALL_ADD
BODY_OUTER_D_CENTRAL_GUIDE = BODY_CAVITY_D_FUNC + 2*T_BODY_TARGET
```

---

# 19. V18当前关闭项

| 项目 | V18状态 |
|---|---|
| BODY/左右阀盖/上前盖/底盖接口域 | **关闭到拓扑C+** |
| 左右阀座局部坐标u | **关闭B/C+** |
| 端面/体盖面/接触面三类基准区分 | **关闭C+** |
| 公司中法兰参数公式 | **关闭A-policy** |
| 上前盖径向接口链 | **关闭A/C+** |
| 底盖径向接口链 | **关闭A/C+** |
| 610长型当前几何可行性 | **关闭到C+** |
| 356短型对当前348球宽链 | **H/R，不兼容** |
| 左右体盖分界面绝对X | D |
| 上前盖安装面绝对Z | D |
| 底盖安装面绝对Z | D |
| 中法兰具体螺栓规格/PCD/OD | D |
| B16.34具体壁厚 | D |

---

# 20. 当前可以直接建立的SolidWorks文件层级

```text
00_SKELETON.SLDPRT
│
├─ ENV_BALL_MOTION
├─ ENV_SEAT_L / ENV_SEAT_R
├─ ENV_TOP_STEM
├─ ENV_BOTTOM_SUPPORT
│
├─ PLN_END_L / PLN_END_R
├─ PLN_BODY_COVER_IF_L / R   # 参数化D
├─ PLN_BODY_TOP_IF            # 参数化D
├─ PLN_BODY_BOTTOM_IF         # 参数化D
│
├─ SURF_BODY_CAVITY
└─ SURF_BODY_PRESSURE_BOUNDARY

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

`07~09`当前先是参数化Envelope，不是制造冻结实体。

---

# 21. 下一步：正式进入第6A步阀体承压设计

V18已经把BODY“在哪里、挂谁、接口如何表达”搭好了。

下一步只剩两类问题：

```text
A. 承压强度问题
  → B16.34最小壁厚
  → +3~5mm公司余量
  → 中法兰螺栓面积

B. 制造接口问题
  → BODY_COVER_IF_X
  → TOP_IF_Z
  → BOTTOM_IF_Z
```

当前我们仍可以继续做第6A的**公式/参数化承压骨架**，不需要用户操作。

真正要把WCB阀体实体尺寸制造冻结时，最先需要补的是：

```text
ASME B16.34当前适用版本中
NPS12 / Class150 / WCB / 设计温度对应的最小壁厚表值
```

在这个值没有正式来源前，保持 `T_B1634=?` 是正确做法。

---

# 22. V18变更记录

## 2026-08-22

- 把阀体总装拆成左右体盖、上前盖、底盖、中央承压域五个接口族；
- 新增阀座左右局部坐标u，避免继续用模糊绝对X；
- 明确阀座58mm只作功能空间，不等于体盖接口面；
- 将公司中法兰规则转换成可直接写入SolidWorks/计算程序的公式变量；
- 建立上前盖φ105/φ95 O圈/φ115垫片接口链；
- 建立底盖φ70/φ58 O圈/φ80垫片/6×M12接口链；
- 将F2F长/短型做空间可行性反校核；
- 610长型在当前球体348宽+58单侧阀座包络下保留约73mm/侧其他结构空间，升级为当前CAD C+候选；
- 356短型仅剩约4mm/侧，和当前结构链明显冲突，降为当前几何H/R；
- 建立 `07_BODY_ENVELOPE` / `08/09_END_COVER_ENVELOPE` 参数化文件策略；
- 下一步正式进入第6A阀体承压骨架。

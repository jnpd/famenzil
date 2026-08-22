# Q347F 12寸 Class150——数字化总装骨架总账 V6

> **定位（Purpose）**：这是当前 Q347F 12寸 Class150 固定球阀的唯一汇总结果页。  
> 保存当前有效的 **尺寸参数（Dimensional Parameters）+ 装配关系（Assembly Relations）+ 空间坐标（Spatial Coordinates）+ SolidWorks变量（SolidWorks Variables）+ 开放项（Open Items）**。  
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

# 1. 状态规则（Status Rules）

| 状态（Status） | 含义（Meaning） |
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

# 2. 项目基线（Project Baseline）

```text
公称尺寸（NPS）                 = 12 / DN300                 A
压力等级（CLASS）              = 150                        A
结构形式（TYPE）               = 固定球 / 枢轴固定          A
流道直径（BORE_D）             = 303                        A
设计压力（P_DESIGN）           = 2.0 MPa                    A
介质（MEDIUM）                 = 天然气                      A
阀体材料（BODY_MAT）           = ASTM A216 WCB              A
球体材料（BALL_MAT）           = ASTM A182 F316             A
阀杆材料（STEM_MAT）           = ASTM A182 F51              A
阀座软密封材料（SEAT_SOFT）    = DEVLON                     A
O形圈材料（ORING_MAT）         = VITON                      A
```

公司结构规则：

```text
CL150~CL900 且 NPS≤12 → 枢轴固定
```

---

# 3. 全局坐标 / 结构长度（Global Coordinates / Face-to-Face Length）

```text
球心坐标（BALL_CENTER_O） = (0,0,0)
流道轴（FLOW_AXIS）       = X
支承轴（SUPPORT_AXIS）    = Z
```

当前结构长度：

```text
长型结构长度参考（F2F_LONG_REF）   = 610 mm
短型结构长度参考（F2F_SHORT_REF）  = 356 mm
CAD结构长度（VALVE_F2F_CAD）       = 610 mm       C+
最终结构长度（VALVE_F2F_FINAL）    = ?            D/A待项目最终确认

右端面X坐标（X_END_FACE_R）        = +305
左端面X坐标（X_END_FACE_L）        = -305
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

# 4. 球体（Ball）

```text
球体外径（BALL_OD）                         = 465          C
球体半径（BALL_R）                          = 232.5        B
球体X向总宽（BALL_W_X）                     = 348          C
球体左右端基准X（BALL_X_FACE_L/R）          = ±174         B/C
球体上孔直径（BALL_UPPER_BORE_D）           = 105          C+
球体上孔有效长度（BALL_UPPER_BORE_EFFECTIVE_L） = ≈28.9     C
球体上孔总深（BALL_UPPER_BORE_TOTAL_DEPTH） = ?            D
球体下孔直径（BALL_LOWER_BORE_D）           = 70           C+
球体下孔有效长度（BALL_LOWER_BORE_EFFECTIVE_L） = 50        C+
球体下孔总深（BALL_LOWER_BORE_TOTAL_DEPTH） = >=50,具体?   D
```

历史：

```text
下球孔固定52mm → H/C
孔底Z=-175      → H/C
```

---

# 5. 阀座密封副（Seat Sealing Pair）

```text
阀座D9直径（SEAT_D9）                 = 323.88
阀座D10直径（SEAT_D10）               = 327.13
阀座D11直径（SEAT_D11）               = 342
阀座导向孔直径（SEAT_GUIDE_BORE）     = 342.4
阀座导向径向间隙（SEAT_GUIDE_CLR_RAD）= 0.20

阀座主O形圈（SEAT_ORING_MAIN）        = 320×5.3
阀座主O形圈沟槽根径（SEAT_ORING_ROOT）= 333.6

阀座第二O形圈（SEAT_ORING_2）         = 311×3.55
阀座第二导向段（SEAT_PILOT_2）        = 323.6
阀座第二导向孔（SEAT_GUIDE_2）        = 323.8
阀座第二径向间隙（SEAT_CLR2_RAD）     = 0.10

弹簧规格（SPRING）                    = φ8×φ1.6×18×7
单侧弹簧数量（SPRING_QTY）            = 36/侧
弹簧安装高度（SPRING_H_INST）         ≈15.6
弹簧分布圆直径（SPRING_PCD）          = 362

阀座大端外径（SEAT_BIG_OD）           = 380
阀盖大孔直径（COVER_BIG_BORE）        = 382
阀座功能包络宽度（WSEAT_ENV）         ≈58       C-space
阀座前移行程（SEAT_TRAVEL_FWD）       >=1.0
阀座后退行程（SEAT_TRAVEL_BACK）      =0.5
```

接触带：

```text
右侧密封接触X坐标（X_CONTACT_R） = +166.036
左侧密封接触X坐标（X_CONTACT_L） = -166.036
```

局部坐标：

```text
右侧局部坐标（u_R） = X - X_CONTACT_R
左侧局部坐标（u_L） = -(X - X_CONTACT_L)
```

真实体盖接口：

```text
接触面到阀座基准距离（L_CONTACT_TO_SEAT_DATUM） = ?
阀座基准到阀盖接口距离（L_SEAT_DATUM_TO_COVER_IF） = ?

右侧阀体-阀盖接口X（X_BODY_COVER_IF_R）
= X_CONTACT_R + L_CONTACT_TO_SEAT_DATUM + L_SEAT_DATUM_TO_COVER_IF

左侧阀体-阀盖接口X（X_BODY_COVER_IF_L）
= -X_BODY_COVER_IF_R
```

当前：

```text
左右阀体-阀盖接口X（X_BODY_COVER_IF_L/R） = ? D
```

---

# 6. 上球体主支承（Upper Ball Main Support）

```text
上球体轴承（UP_BALL_BRG）            = φ105×φ100×30     A/C+
上轴颈直径（UP_JOURNAL_D）           = φ100             C+
上轴承中心Z（UP_BRG_CENTER_Z）       = +208.6           C
上轴承下端Z（UP_BRG_Z0）             = +193.6           C
上轴承上端Z（UP_BRG_Z1）             = +223.6           C
上支承力臂（A_SUPPORT_ARM）           = 208.566          B/C
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

# 7. 阀杆 / 上部内轨（Stem / Upper Inner Guide）

```text
阀杆主径（STEM_MAIN_D）              = 65
阀杆键部直径（STEM_KEY_D）           = 60候选
阀杆台肩外径（STEM_SHOULDER_OD）     ≈74
上止推垫（THRUST_UP）                = φ75×φ65×2
阀杆导向轴承（STEM_GUIDE_BRG）       = φ70×φ65×50

阀杆基准面Z（F0_Z）                  = +201.4        C
阀杆导向轴承下端Z（STEM_GUIDE_Z0）   = +203.4
阀杆导向轴承上端Z（STEM_GUIDE_Z1）   = +253.4

阀杆O形圈（STEM_ORING）              = φ65×5.3×2
阀杆O形圈沟槽根径（STEM_ORING_GROOT）= φ73.8
阀杆O形圈沟槽宽（STEM_ORING_GW）     = 7
润滑脂槽区长度（OIL_LAND）           ≈16.8
填料（PACKING）                      = φ75×φ65×5
填料安装厚度（PACK_INSTALL_T）       ≈4.4 C/P
CAD阀杆功能链最高Z（Z_TOP_STEM_FUNC_CAD） = ≈+318.1
```

---

# 8. 下球体主支承 / 底盖（Lower Ball Main Support / Bottom Cover）

```text
下球体轴承（LOWER_BRG）              = φ70×φ65×50      A
下轴颈直径（LOWER_JOURNAL_D）        = φ65              C+ / 底盖一体
下止推垫（LOWER_THRUST）             = φ65×φ20×2       A/C+
下轴承中心Z（LOWER_BRG_CENTER_Z）    = -202.0           C
下轴承外端Z（LOWER_BRG_Z_OUT）       = -227.0           C
下轴承内端Z（LOWER_BRG_Z_IN）        = -177.0           C
下球孔口Z（LOWER_BORE_MOUTH_Z）      = -227.0           C
下球孔底Z（LOWER_BORE_BOTTOM_Z）     = ?                D
下支承力臂（B_SUPPORT_ARM）           = 202.039          B/C
```

---

# 9. 支承载荷（Support Loads）

```text
总支承载荷（F_SUPPORT） = 164.692 kN
上支承反力（Ru）        = 81.037 kN
下支承反力（Rl）        = 83.655 kN
```

平均面压需求：

```text
上≈27.01 MPa
下≈25.74 MPa
```

316+PTFE具体许用面压仍D。

---

# 10. 第5步内部功能包络（Internal Functional Envelope）

中央：

```text
球体包络（ENV_BALL）: x²+y²+z² ≤ 232.5²
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
上颈部最小功能直径（TOP_NECK_FUNC_D_MIN）=115
```

下部：

```text
下轴承 Z=-227~-177
底部最小功能直径（BOTTOM_FUNC_D_MIN）=80
```

---

# 11. 中央球腔三档敏感性（Central Ball Cavity Sensitivity）

最终固定球间隙仍：

```text
最终球体-阀体径向间隙（BALL_BODY_CLR_RAD_FINAL） = ? D
```

P-XREF：

```text
1.5mm径向间隙（CLR_1P5） → φ468
3.0mm径向间隙（CLR_3P0） → φ471
6.0mm径向间隙（CLR_6P0） → φ477
```

默认显示草模可用φ471，但不是制造值。

---

# 12. 阀体承压壁政策（Body Pressure-Wall Policy）

公司固定球阀规则：

```text
目标阀体壁厚（T_BODY_TARGET）
>= B16.34最小壁厚（T_B1634） + 3~5mm
```

当前：

```text
B16.34最小壁厚（T_B1634） = ? D
阀体附加壁厚（BODY_WALL_ADD） = 3~5 A-policy
```

中央第一轮外包络公式：

```text
中央阀体指导外径（BODY_OUTER_D_CENTRAL_GUIDE）
= 功能球腔直径（BODY_CAVITY_D_FUNC） + 2*目标阀体壁厚（T_BODY_TARGET）
```

---

# 13. 左右中法兰参数公式（Left/Right Mid-Flange Parameters）

公司规则已经转成：

```text
中法兰垫片宽度（MID_GASKET_W） = 5~10mm    A-policy

中法兰螺栓分布圆（MID_BCD）
= 中法兰垫片外径（MID_GASKET_OD）
+ 中法兰螺栓孔直径（MID_BOLT_HOLE_D）
+ 中法兰BCD边距（MID_BCD_EDGE）

中法兰BCD边距（MID_BCD_EDGE） = 3~6mm

中法兰外径（MID_FLANGE_OD）
= 中法兰螺栓分布圆（MID_BCD） + 沉孔直径（MID_COUNTERBORE_D）
```

待定变量：

```text
中法兰垫片内/外径（MID_GASKET_ID/OD） = ?
中法兰螺栓规格（MID_BOLT_SIZE） = ?
中法兰螺栓数量（MID_BOLT_QTY） = ?
中法兰螺栓孔直径（MID_BOLT_HOLE_D） = ?
中法兰沉孔直径（MID_COUNTERBORE_D） = ?
```

螺栓总有效抗拉面积需按ASME B16.34 6.4.2.1校核。

---

# 14. 上前盖接口 IF-Z-U（Upper Front-Cover Interface IF-Z-U）

当前径向链：

```text
上接口导向直径（TOP_IF_GUIDE_D）       =105
上接口O形圈（TOP_IF_ORING）            =95×5.3
上接口O形圈沟槽根径（TOP_IF_ORING_ROOT_D） =96.6
上接口垫片（TOP_IF_GASKET）            =115×105×3.2
```

轴向安装面：

```text
阀体上接口安装面Z（Z_BODY_TOP_IF） = ? D
```

注意：

```text
阀杆基准面（F0）=+201.4
≠
阀体上接口安装面（BODY_TOP_IF）
```

---

# 15. 底盖接口 IF-Z-L（Bottom-Cover Interface IF-Z-L）

```text
底接口导向直径（BOTTOM_IF_GUIDE_D）       =70
底接口O形圈（BOTTOM_IF_ORING）            =58×5.3
底接口O形圈沟槽根径（BOTTOM_IF_ORING_ROOT_D） =61.6
底接口垫片（BOTTOM_IF_GASKET）            =80×70×3.2
底接口双头螺柱数量（BOTTOM_IF_STUD_QTY）  =6
底接口双头螺柱规格（BOTTOM_IF_STUD_SIZE） =M12
底接口双头螺柱长度（BOTTOM_IF_STUD_L）    =55
```

待定：

```text
阀体底接口安装面Z（Z_BODY_BOTTOM_IF） = ?
底接口螺栓分布圆（BOTTOM_IF_BCD） = ?
底接口法兰外径（BOTTOM_IF_FLANGE_OD） = ?
```

---

# 16. 当前核心装配关系（Current Core Assembly Relations）

| 配合编号（Mate ID） | 装配关系（Mate Relation） |
|---|---|
| M001 | 球体固定在O，X/Z轴对齐 |
| M002/3 | 左右DEVLON与R232.5球面同心接触 |
| M004/5 | 左右阀座同轴X，只保留X向功能移动 |
| M006 | φ342支承圈 ↔ φ342.4阀盖孔 |
| M007 | φ323.6导向段（pilot） ↔ φ323.8阀盖孔 |
| M008 | φ380大端 ↔ φ382阀盖孔 |
| M009 | 球体φ105孔 ↔ 上球体轴承φ105 |
| M010 | 上轴承φ100内径（ID） ↔ 前盖一体φ100轴颈 |
| M011 | 阀杆φ65 ↔ 阀杆导向轴承φ65内径（ID） |
| M012 | 阀杆导向轴承φ70外径（OD） ↔ 前盖φ70孔 |
| M013 | 球体φ70下孔 ↔ 下轴承φ70外径（OD） |
| M014 | 下轴承φ65内径（ID） ↔ 底盖一体φ65轴颈 |
| M015 | 前盖φ105凸台（boss） ↔ 阀体（BODY）上接口导向孔 + 端面定位 |
| M016 | 底盖φ70凸台（boss） ↔ 阀体（BODY）下接口导向孔 + 端面定位 |
| M017 | 阀体（BODY） ↔ 左右阀盖：同轴X + 中法兰端面压紧 |
| M018 | 上球体轴承外轨与阀杆导向内轨允许Z向重叠 |

---

# 17. SolidWorks当前变量块（Current SolidWorks Variable Block）

> 说明：本节保留原英文变量名，确保后续 SolidWorks 方程式、宏和参数化脚本可以继续直接引用；每个变量右侧增加中文说明。

```text
# 基础 / BASE
BALL_CENTER_O=(0,0,0)       # 球心坐标
FLOW_AXIS=X                  # 流道轴
SUPPORT_AXIS=Z               # 支承轴

# 结构长度 / F2F
VALVE_F2F_CAD=610            # CAD结构长度
X_END_FACE_R=305             # 右端面X坐标
X_END_FACE_L=-305            # 左端面X坐标

# 球体 / BALL
BORE_D=303                   # 流道直径
BALL_OD=465                  # 球体外径
BALL_R=232.5                 # 球体半径
BALL_X_R=174                 # 球体右端基准X
BALL_X_L=-174                # 球体左端基准X
BALL_UPPER_BORE_D=105        # 球体上孔直径
BALL_UPPER_BORE_EFFECTIVE_L=28.9  # 球体上孔有效长度
BALL_UPPER_BORE_TOTAL_DEPTH=?     # 球体上孔总深
BALL_LOWER_BORE_D=70              # 球体下孔直径
BALL_LOWER_BORE_EFFECTIVE_L=50    # 球体下孔有效长度
BALL_LOWER_BORE_TOTAL_DEPTH=?     # 球体下孔总深

# 阀座 / SEAT
X_CONTACT_R=166.036          # 右侧密封接触X坐标
X_CONTACT_L=-166.036         # 左侧密封接触X坐标
SEAT_D11=342                 # 阀座D11直径
SEAT_GUIDE_BORE=342.4        # 阀座导向孔直径
SPRING_PCD=362               # 弹簧分布圆直径
SEAT_BIG_OD=380              # 阀座大端外径
COVER_BIG_BORE=382           # 阀盖大孔直径
WSEAT_ENV=58                 # 阀座功能包络宽度
X_BODY_COVER_IF_R=?          # 右侧阀体-阀盖接口X
X_BODY_COVER_IF_L=?          # 左侧阀体-阀盖接口X

# 上支承 / UPPER SUPPORT
UP_BALL_BRG_OD=105           # 上球体轴承外径
UP_BALL_BRG_ID=100           # 上球体轴承内径
UP_BALL_BRG_L=30             # 上球体轴承长度
UP_BRG_CENTER_Z=208.6        # 上轴承中心Z
UP_BRG_Z0=193.6              # 上轴承下端Z
UP_BRG_Z1=223.6              # 上轴承上端Z
UP_JOURNAL_D=100             # 上轴颈直径

# 阀杆 / STEM
STEM_MAIN_D=65               # 阀杆主径
F0_Z=201.4                   # 阀杆基准面Z
STEM_GUIDE_OD=70             # 阀杆导向轴承外径
STEM_GUIDE_ID=65             # 阀杆导向轴承内径
STEM_GUIDE_L=50              # 阀杆导向轴承长度
STEM_GUIDE_Z0=203.4          # 阀杆导向轴承下端Z
STEM_GUIDE_Z1=253.4          # 阀杆导向轴承上端Z
Z_TOP_STEM_FUNC_CAD=318.1    # CAD阀杆功能链最高Z

# 下支承 / LOWER SUPPORT
LOWER_BRG_OD=70              # 下球体轴承外径
LOWER_BRG_ID=65              # 下球体轴承内径
LOWER_BRG_L=50               # 下球体轴承长度
LOWER_BRG_CENTER_Z=-202.0    # 下轴承中心Z
LOWER_BRG_Z_OUT=-227.0       # 下轴承外端Z
LOWER_BRG_Z_IN=-177.0        # 下轴承内端Z
LOWER_BORE_MOUTH_Z=-227.0    # 下球孔口Z
LOWER_BORE_BOTTOM_Z=?        # 下球孔底Z
LOWER_JOURNAL_D=65           # 下轴颈直径

# 上接口 / TOP IF
TOP_IF_GUIDE_D=105           # 上接口导向直径
TOP_IF_ORING_ROOT_D=96.6     # 上接口O形圈沟槽根径
TOP_IF_GASKET_ID=105         # 上接口垫片内径
TOP_IF_GASKET_OD=115         # 上接口垫片外径
Z_BODY_TOP_IF=?              # 阀体上接口安装面Z

# 底接口 / BOTTOM IF
BOTTOM_IF_GUIDE_D=70         # 底接口导向直径
BOTTOM_IF_ORING_ROOT_D=61.6  # 底接口O形圈沟槽根径
BOTTOM_IF_GASKET_ID=70       # 底接口垫片内径
BOTTOM_IF_GASKET_OD=80       # 底接口垫片外径
BOTTOM_IF_STUD_QTY=6         # 底接口双头螺柱数量
BOTTOM_IF_STUD_SIZE=M12      # 底接口双头螺柱规格
BOTTOM_IF_BCD=?              # 底接口螺栓分布圆
BOTTOM_IF_FLANGE_OD=?        # 底接口法兰外径
Z_BODY_BOTTOM_IF=?           # 阀体底接口安装面Z

# 球腔 / CAVITY
BALL_BODY_CLR_RAD=3.0        # 当前球体-阀体径向间隙；当前显示配置，P-XREF
BODY_CAVITY_D_FUNC=471       # 功能球腔直径
BALL_BODY_CLR_RAD_FINAL=?    # 最终球体-阀体径向间隙
BODY_CAVITY_D_FINAL=?        # 最终球腔直径

# 阀体壁厚 / BODY WALL
T_B1634=?                    # ASME B16.34最小壁厚
BODY_WALL_ADD_MIN=3          # 阀体最小附加壁厚
BODY_WALL_ADD_MAX=5          # 阀体最大附加壁厚
T_BODY_TARGET=?              # 目标阀体壁厚

# 中法兰 / MID FLANGE
MID_GASKET_ID=?              # 中法兰垫片内径
MID_GASKET_OD=?              # 中法兰垫片外径
MID_GASKET_W_MIN=5           # 中法兰垫片最小宽度
MID_GASKET_W_MAX=10          # 中法兰垫片最大宽度
MID_BOLT_HOLE_D=?            # 中法兰螺栓孔直径
MID_COUNTERBORE_D=?          # 中法兰沉孔直径
MID_BCD_EDGE=3~6             # 中法兰BCD边距
MID_BCD=?                    # 中法兰螺栓分布圆
MID_FLANGE_OD=?              # 中法兰外径
MID_BOLT_QTY=?               # 中法兰螺栓数量
MID_BOLT_SIZE=?              # 中法兰螺栓规格

# 载荷 / LOAD
F_SUPPORT=164.692            # 总支承载荷
A_SUPPORT_ARM=208.566        # 上支承力臂
B_SUPPORT_ARM=202.039        # 下支承力臂
RU_SUPPORT=81.037            # 上支承反力
RL_SUPPORT=83.655            # 下支承反力
```

---

# 18. 当前开放项（Current Open Items）

| 编号（ID） | 开放项（Open Item） | 状态（Status） |
|---|---|---|
| RD001 | 最终球体—阀体间隙 | D |
| RD002 | ASME B16.34最小壁厚T_B1634 | D |
| RD003 | 阀体（BODY）最终壁厚 | D |
| RD004 | 左右阀体-阀盖（BODY-COVER）接口X | D |
| RD005 | 中法兰垫片尺寸 | D |
| RD006 | 中法兰螺栓规格/数量/PCD/OD | D |
| RD007 | 上前盖安装面Z | D |
| RD008 | 底盖安装面Z | D |
| RD009 | 底盖法兰PCD/OD | D |
| RD010 | 上/下球孔总加工深度 | D |
| RD011 | 316+PTFE许用面压 | D |
| RD012 | 最终结构长度（F2F）项目确认 | D/A；CAD当前610 C+ |
| RD013 | 最终设计温度 | R/D |

---

# 19. 历史纠错（Historical Corrections）

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

# 20. 当前建模文件层级（Current Modeling File Hierarchy）

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

当前07~09先做参数化包络（Envelope），不冒充制造冻结零件。

---

# 21. 下一步（Next Step）

```text
第6A 阀体承压设计（Body Pressure Design）
↓
查B16.34最小壁厚（T_B1634）
↓
阀体中央壁厚（BODY Central Wall Thickness）
↓
左右中法兰螺栓面积（Mid-Flange Bolt Area）
↓
上/下接口局部承压肉厚（Local Pressure-Bearing Thickness）
↓
阀体第一版参数化承压实体（BODY Parametric Pressure-Bearing Solid V1）
```

当前继续优先从已有资料寻找可追溯的 `B16.34最小壁厚（T_B1634）` 数据；若正式标准值没有可靠来源，则保持D，不猜。
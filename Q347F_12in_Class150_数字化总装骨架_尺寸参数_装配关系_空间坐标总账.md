# Q347F 12寸 Class150——数字化总装骨架总账 V7

> **定位**：这是当前 Q347F 12寸 Class150 固定球阀的唯一数字化汇总页。  
> 同步保存 **尺寸参数 + 装配关系 + 空间坐标 + SolidWorks变量 + 开放项 + 历史纠错**。  
> **当前主线已推进到 V21 / 第6B步**：F2F=610已项目锁定；B16.34中央壁厚已建立；主壳体已纠正为 `BODY×1 + BODY_COVER×1` 两片式侧装结构；唯一主中法兰已绑定 `φ466×7 O圈 + φ500×φ490×3.2缠绕垫 + 20×M20×85`，并完成B16.34 §6.4.2.1第一轮面积校核。

[← 总导航](./00_Q347F_12in_Class150_文档导航_从这里开始.md)  
[← 主计算母版](./Q347F_12in_Class150_球体设计计算底稿_第一部分_小白可读公式完整版.md)  
[← V19 F2F / Side Entry](./Q347F_12in_Class150_第5D步_API6D侧装式结构长度_610与838口径关闭_V19.md)  
[← V20 B16.34壁厚](./Q347F_12in_Class150_第6A步_ASME_B16_34阀体最小壁厚_压力等级风险_承压外壳_V20.md)  
[← V21 两片式主壳体 / 中法兰](./Q347F_12in_Class150_第6B步_两片式主壳体纠错_中法兰垫片_M20螺柱_B16_34校核_V21.md)

---

# 1. 状态规则

| 状态 | 含义 |
|---|---|
| A | 项目/BOM/公司明确输入 |
| A-policy | 公司设计方法明确，具体标准/制造值仍需关闭 |
| B | 由接受输入直接计算 |
| C | 有依据的CAD候选，可草模，未制造冻结 |
| C+ | 多条独立证据交叉支持 |
| D | 前置不足，禁止填死 |
| P-XREF | 跨结构参考/敏感性，仅作分析 |
| H | 历史值 |
| H/R | 历史且已纠正，当前禁止使用 |
| R | 当前风险/冻结门 |

---

# 2. 项目基线

```text
NPS=12 / DN300                       A
CLASS=150                            A
TYPE=trunnion-mounted fixed ball     A
BODY_ENTRY_TYPE=SIDE_ENTRY           A/C+
BODY_PIECE_COUNT=2                   A/C+
BORE_D=303                           A
MEDIUM=天然气                         A
P_LOAD_CALC=2.00 MPa                 A / 机械载荷计算输入
BODY_MAT=ASTM A216 WCB               A
BALL_MAT=ASTM A182 F316              A
STEM_MAT=ASTM A182 F51               A
SEAT_SOFT=DEVLON                     A
ORING_MAT=VITON                      A
```

压力等级标准合规永久拆开：

```text
P_LOAD_CALC=2.00MPa
用途：球体/支承/阀杆等保守机械载荷计算

P_RATING_ALLOWED=f(CLASS,MATERIAL,T_DESIGN)
用途：ASME B16.34压力-温度额定合规
```

当前WCB/Class150常温段标准额定约：

```text
1.96 MPa
```

因此：

```text
R20_01_PRESSURE_CLASS=HIGH
T_DESIGN=?
```

2.00MPa不能直接写成WCB/Class150标准额定压力。

---

# 3. 永久坐标与结构长度

```text
BALL_CENTER_O=(0,0,0)
FLOW_AXIS=X
SUPPORT_AXIS=Z
-X=入口方向
+X=出口方向
+Z=阀杆/驱动方向
-Z=底盖方向
```

SolidWorks基准：

```text
Origin=BALL_CENTER_O
Front=XZ
Top=XY
Right=YZ
Axis_X=FLOW_AXIS
Axis_Z=SUPPORT_AXIS
```

结构长度项目已锁定：

```text
VALVE_F2F=610 mm             A
HALF_F2F=305                 B
X_END_FACE_L=-305            B/A
X_END_FACE_R=+305            B/A
F2F_TOL_STD=±3 mm            STD
```

历史/参考：

```text
356 short pattern → H/R-for-current-project
838 top-entry口径 → H/R-for-current-side-entry
```

---

# 4. 主壳体拓扑——V21永久修正

永久命名：

```text
BODY         = 主阀体，主承压大件1
BODY_COVER   = BOM“阀盖”，侧装主阀盖/连接体，主承压大件2
STEM_COVER   = BOM“前盖”，Z轴上部小盖
BOTTOM_COVER = BOM“底盖”，Z轴下部小盖
```

一级结构：

```text
                         STEM_COVER
                              │
END FLANGE ─ BODY ─ SEAT ─── BALL ─── SEAT ─ BODY_COVER ─ END FLANGE
                              │
                         BOTTOM_COVER
```

当前：

```text
BODY_QTY=1                         A
BODY_COVER_QTY=1                   A
BODY_JOINT_COUNT=1                 A/C+
```

旧：

```text
LEFT COVER ─ BODY ─ RIGHT COVER
IF-X-L / IF-X-R
X_BODY_COVER_IF_L=-X_BODY_COVER_IF_R
```

统一：`H/R`。

当前唯一主分界：

```text
IF-X-BODY-JOINT
PLN_BODY_JOINT_X
X_BODY_JOINT=?                     D
```

左右阀座仍为2套，左右接触带与局部坐标仍可镜像。

---

# 5. 球体

```text
BALL_OD=465                         C
BALL_R=232.5                        B
BALL_W_X=348                        C
BALL_X_FACE_L=-174                  B/C
BALL_X_FACE_R=+174                  B/C
BORE_D=303                          A
```

上孔：

```text
BALL_UPPER_BORE_D=105               C+
BALL_UPPER_BORE_EFFECTIVE_L≈28.9    C
BALL_UPPER_BORE_TOTAL_DEPTH=?       D
```

下孔：

```text
BALL_LOWER_BORE_D=70                C+
BALL_LOWER_BORE_EFFECTIVE_L=50      C+
BALL_LOWER_BORE_TOTAL_DEPTH>=50,最终? D
```

历史：

```text
下球孔固定52 → H/C
LOWER_BORE_BOTTOM_Z=-175 → H/R
```

---

# 6. 阀座密封副

```text
SEAT_D9=323.88
SEAT_D10=327.13
SEAT_D11=342
SEAT_GUIDE_BORE=342.4
SEAT_GUIDE_CLR_RAD=0.20

SEAT_ORING_MAIN=φ320×5.3
SEAT_ORING_ROOT=333.6

SEAT_ORING_2=φ311×3.55
SEAT_PILOT_2=323.6
SEAT_GUIDE_2=323.8
SEAT_CLR2_RAD=0.10

SPRING=φ8×φ1.6×18×7
SPRING_QTY=36/side
SPRING_H_INST≈15.6
SPRING_PCD=362

SEAT_BIG_OD=380
SEAT_BIG_BORE=382
WSEAT_ENV≈58                     C-space
SEAT_TRAVEL_FWD>=1.0
SEAT_TRAVEL_BACK=0.5             C
```

真实球面密封接触：

```text
右接触带≈+165.235~+166.828
X_CONTACT_R=+166.036
左接触带≈-166.828~-165.235
X_CONTACT_L=-166.036
```

不要用球体端面±174代替密封接触位置。

局部坐标继续有效：

```text
u_R=X-X_CONTACT_R
u_L=-(X-X_CONTACT_L)
```

---

# 7. 上球体主支承

```text
UP_BALL_BRG=φ105×φ100×30          A/C+
UP_JOURNAL_D=100                   C+
UP_BRG_CENTER_Z=+208.6             C
UP_BRG_Z0=+193.6                   C
UP_BRG_Z1=+223.6                   C
A_SUPPORT_ARM=208.566              B/C
```

正确链：

```text
球体φ105孔
↓
φ105×φ100×30轴承
↓
STEM_COVER一体φ100支承轴颈
```

旧“上球体主轴承=φ70×φ65×50” → H/R。

---

# 8. 阀杆 / STEM_COVER内轨

```text
STEM_MAIN_D=65
STEM_KEY_D≈60                    C
STEM_SHOULDER_OD≈74              C+
THRUST_UP=φ75×φ65×2
STEM_GUIDE_BRG=φ70×φ65×50

F0_Z≈+201.4                     C
STEM_GUIDE_Z0≈+203.4
STEM_GUIDE_Z1≈+253.4

STEM_ORING=φ65×5.3×2
STEM_ORING_GROOT=73.8
STEM_ORING_GW=7
OIL_LAND≈16.8

PACKING=φ75×φ65×5
PACK_INSTALL_T≈4.4               C/P
Z_TOP_STEM_FUNC_CAD≈+318.1
```

STEM_COVER外接口：

```text
TOP_IF_GUIDE_D=105
TOP_IF_ORING=φ95×5.3
TOP_IF_ORING_ROOT_D=96.6         C+
TOP_IF_GASKET=φ115×φ105×3.2
Z_BODY_TOP_IF=?                  D
```

---

# 9. 下球体主支承 / BOTTOM_COVER

```text
LOWER_BRG=φ70×φ65×50            A
LOWER_JOURNAL_D=65               C+ / 底盖一体
LOWER_THRUST=φ65×φ20×2          A/C+
LOWER_BRG_CENTER_Z=-202.0        C
LOWER_BRG_Z_OUT=-227.0           C
LOWER_BRG_Z_IN=-177.0            C
LOWER_BORE_MOUTH_Z=-227.0        C
LOWER_BORE_BOTTOM_Z=?            D
B_SUPPORT_ARM=202.039            B/C
```

底盖密封/连接：

```text
BOTTOM_IF_GUIDE_D=70
BOTTOM_IF_ORING=φ58×5.3 AED
BOTTOM_IF_ORING_ROOT_D=61.6
BOTTOM_IF_GASKET=φ80×φ70×3.2
BOTTOM_IF_STUD_QTY=6
BOTTOM_IF_STUD_SIZE=M12
BOTTOM_IF_STUD_L=55
BOTTOM_IF_BCD=?                  D
BOTTOM_IF_FLANGE_OD=?            D
Z_BODY_BOTTOM_IF=?               D
```

---

# 10. 支承载荷

```text
F_SUPPORT=164.692 kN
RU_SUPPORT=81.037 kN
RL_SUPPORT=83.655 kN
```

平均轴承面压需求：

```text
上≈27.01 MPa
下≈25.74 MPa
```

316+PTFE真实许用面压仍D。

---

# 11. 内部整体包络

中央球体包络：

```text
x²+y²+z² <=232.5²
```

阀座大端：

```text
φ382 → R191 < R232.5
```

因此中央径向主控制仍为球体。

上部：

```text
UP_BRG Z≈193.6~223.6
Z_TOP_STEM_FUNC_CAD≈+318.1
TOP_NECK_FUNC_D_MIN=115
```

下部：

```text
LOWER_BRG Z≈-227~-177
BOTTOM_FUNC_D_MIN=80
```

---

# 12. 中央球腔敏感性

最终固定球与阀体径向间隙：

```text
BALL_BODY_CLR_RAD_FINAL=?         D
```

P-XREF：

```text
CLR1.5 → BODY_CAVITY_D=468
CLR3.0 → BODY_CAVITY_D=471
CLR6.0 → BODY_CAVITY_D=477
```

当前CAD显示：

```text
BALL_BODY_CLR_RAD=3.0             P-XREF
BODY_CAVITY_D_FUNC=471            P-XREF/C-display
```

---

# 13. B16.34阀体最小壁厚 / V20

Class150、`100<d<=1300mm`：

```text
T_B1634(d)=0.0163*d+4.70
```

中央d=303：

```text
T_B1634=9.6 mm                    B/STD
```

公司：

```text
BODY_WALL_ADD=3~5 mm              A-policy
T_BODY_TARGET=12.6~14.6 mm        B/C
T_BODY_CAD=13.6 mm                C
```

中央三档外包络：

```text
BODY_LOW =468+2×12.6=493.2
BODY_MID =471+2×13.6=498.2        C default
BODY_HIGH=477+2×14.6=506.2
```

因此：

```text
BODY_OUTER_D_CENTRAL_CAD=498.2
```

不是最终整阀最大外径。

局部φ382若确属直接承压控制内径：

```text
T_B1634_LOCAL≈10.9
公司目标≈13.9~15.9
```

边界归属进入BODY/BODY_COVER剖面继续检查。

---

# 14. 唯一主BODY—BODY_COVER中法兰 / V21

12寸BOM + 20寸成熟对应已绑定：

```text
BODY_JOINT_ORING=φ466×7            A/C+
MID_GASKET=φ500×φ490×3.2           A/C+
MID_STUD=M20×85                     A/C+
MID_STUD_QTY=20                     A/C+
MID_NUT=M20                         A/C+
MID_NUT_QTY=20                      A/C+
BODY_COVER_QTY=1                    A
```

垫片径向宽：

```text
MID_GASKET_RADIAL_W=(500-490)/2=5mm   B/C+
```

公司规则：5~10mm，吻合。

M20普通间隙孔第一版：

```text
MID_BOLT_HOLE_D_CAD=22             C/STD-default
```

公司BCD公式：

```text
MID_BCD=GASKET_OD+BOLT_HOLE_D+(3~6)
```

得到：

```text
MID_BCD_MIN=525
MID_BCD_MAX=528
MID_BCD_CAD=526.5                  C
```

20等分圆周节距：

```text
≈82.7mm
```

M20螺母：

```text
s=30mm
e_min≈32.95mm
```

锪平/沉孔仍D；仅CAD敏感性：

```text
35 → MID_FLANGE_OD≈560~563
36 → MID_FLANGE_OD≈561~564
38 → MID_FLANGE_OD≈563~566
```

第一版：

```text
MID_SPOTFACE_D_CAD=36              C
MID_FLANGE_OD_CAD≈562.5            C
```

不可用于制造冻结。

---

# 15. ASME B16.34-2025 §6.4.2.1 主中法兰螺栓面积门

当前按 sectional body joint：

```text
Pc=150
Ag=π/4×500²≈196349.5 mm²
```

M20粗牙P=2.5：

```text
As_one≈244.79 mm²
Ab_actual=20×244.79≈4895.9 mm²
```

`Sa≈138MPa`口径下：

```text
min(K2*Sa,Limit)=7000
```

要求：

```text
Ab_required=150×196349.5/7000≈4207.5 mm²
```

结果：

```text
MID_BOLT_AREA_MARGIN=4895.9/4207.5≈1.164
```

当前结论：

```text
§6.4.2.1 PRELIMINARY PASS
约+16.4%有效拉应力面积裕量
```

注意公式中的：

```text
Pc=Class designation=150
```

不是 `P_LOAD_CALC=2MPa`。

---

# 16. ASME B16.34-2025 §6.4.2.3 截面模量门

2025版 sectional body joint 还必须检查：

```text
Zbn = body nozzle section modulus
Zfb = bolting arrangement section modulus
```

圆形螺栓圈：

```text
Zfb=C*AB/4
```

并结合：

```text
Sa=bolt allowable stress
Sb=body allowable stress
```

满足标准关系。

当前：

```text
MID_ZBN=?
MID_ZFB=?
R21_02_SECTION_MODULUS=OPEN        R/D
```

因此不能因为§6.4.2.1通过就宣布整个中法兰最终合格。

---

# 17. 核心装配关系

| ID | 当前装配关系 |
|---|---|
| M001 | 球体中心固定到O，流道轴X、支承轴Z |
| M002/3 | 左右DEVLON与R232.5球面形成密封接触 |
| M004/5 | 左右阀座同轴X，仅保留规定轴向浮动 |
| M006 | φ342阀座导向 ↔ φ342.4座孔 |
| M007 | φ323.6 pilot ↔ φ323.8导向孔 |
| M008 | φ380大端 ↔ φ382大孔 |
| M009 | 球体φ105上孔 ↔ φ105上球轴承 |
| M010 | 上轴承ID100 ↔ STEM_COVER一体φ100轴颈 |
| M011 | 阀杆φ65 ↔ 阀杆导向轴承ID65 |
| M012 | 阀杆导向轴承OD70 ↔ STEM_COVER φ70孔 |
| M013 | 球体φ70下孔 ↔ 下轴承OD70 |
| M014 | 下轴承ID65 ↔ BOTTOM_COVER一体φ65轴颈 |
| M015 | STEM_COVER φ105 boss ↔ BODY上接口导向 + 端面 |
| M016 | BOTTOM_COVER φ70 boss ↔ BODY下接口导向 + 端面 |
| M017 | **BODY ↔ BODY_COVER：唯一X向主中法兰，同轴 + 定位止口 + O圈/缠绕垫 + 20×M20夹紧** |
| M018 | 上球体轴承轨与阀杆导向轨允许Z向功能重叠 |

旧M017“BODY↔左右两个阀盖” → H/R。

---

# 18. 当前SolidWorks变量块

```text
# BASE
BALL_CENTER_O=(0,0,0)
FLOW_AXIS=X
SUPPORT_AXIS=Z

# F2F
VALVE_F2F=610
X_END_FACE_L=-305
X_END_FACE_R=305

# MAIN BODY TOPOLOGY
BODY_PIECE_COUNT=2
BODY_QTY=1
BODY_COVER_QTY=1
BODY_JOINT_COUNT=1
X_BODY_JOINT=?

# BALL
BORE_D=303
BALL_OD=465
BALL_R=232.5
BALL_X_L=-174
BALL_X_R=174
BALL_UPPER_BORE_D=105
BALL_UPPER_BORE_EFFECTIVE_L=28.9
BALL_UPPER_BORE_TOTAL_DEPTH=?
BALL_LOWER_BORE_D=70
BALL_LOWER_BORE_EFFECTIVE_L=50
BALL_LOWER_BORE_TOTAL_DEPTH=?

# SEAT
X_CONTACT_L=-166.036
X_CONTACT_R=166.036
SEAT_D9=323.88
SEAT_D10=327.13
SEAT_D11=342
SEAT_GUIDE_BORE=342.4
SEAT_PILOT_2=323.6
SEAT_GUIDE_2=323.8
SPRING_PCD=362
SEAT_BIG_OD=380
SEAT_BIG_BORE=382
WSEAT_ENV=58

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
STEM_KEY_D=60
F0_Z=201.4
STEM_GUIDE_OD=70
STEM_GUIDE_ID=65
STEM_GUIDE_L=50
STEM_GUIDE_Z0=203.4
STEM_GUIDE_Z1=253.4
STEM_ORING_GROOT=73.8
STEM_ORING_GW=7
OIL_LAND=16.8
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
BOTTOM_IF_STUD_L=55
BOTTOM_IF_BCD=?
BOTTOM_IF_FLANGE_OD=?
Z_BODY_BOTTOM_IF=?

# CAVITY / BODY WALL
BALL_BODY_CLR_RAD=3.0
BODY_CAVITY_D_FUNC=471
BALL_BODY_CLR_RAD_FINAL=?
T_B1634=9.6
BODY_WALL_ADD_MIN=3
BODY_WALL_ADD_MAX=5
T_BODY_MIN_GUIDE=12.6
T_BODY_CAD=13.6
T_BODY_MAX_GUIDE=14.6
T_BODY_FINAL=?
BODY_OUTER_D_CENTRAL_CAD=498.2

# MAIN BODY JOINT SEALS
BODY_JOINT_ORING_D0=466
BODY_JOINT_ORING_CS=7
MID_GASKET_OD=500
MID_GASKET_ID=490
MID_GASKET_T=3.2
MID_GASKET_RADIAL_W=5

# MAIN BODY JOINT BOLTING
MID_STUD_SIZE=M20
MID_STUD_L=85
MID_STUD_QTY=20
MID_NUT_SIZE=M20
MID_NUT_QTY=20
MID_BOLT_HOLE_D_CAD=22
MID_BCD_MIN=525
MID_BCD_MAX=528
MID_BCD_CAD=526.5
MID_SPOTFACE_D=?
MID_SPOTFACE_D_CAD=36
MID_FLANGE_OD_CAD=562.5

# B16.34 BODY JOINT
MID_AG=196349.5
MID_AS_ONE=244.79
MID_AB_ACTUAL=4895.9
MID_AB_REQUIRED=4207.5
MID_BOLT_AREA_MARGIN=1.164
MID_ZBN=?
MID_ZFB=?
R21_02_SECTION_MODULUS=OPEN

# LOAD
F_SUPPORT=164.692
A_SUPPORT_ARM=208.566
B_SUPPORT_ARM=202.039
RU_SUPPORT=81.037
RL_SUPPORT=83.655

# PRESSURE RATING SPLIT
P_LOAD_CALC=2.00
T_DESIGN=?
P_RATING_ALLOWED=?

# RETIRED
X_BODY_COVER_IF_L=H/R
X_BODY_COVER_IF_R=H/R
M24_MAIN_BODY_JOINT=H/R
M24_GROUP_FUNCTION=?
```

---

# 19. 当前开放项

| ID | 开放项 | 状态 |
|---|---|---|
| RD001 | 最终球体—阀体径向间隙 | D |
| RD002 | 阀体最终制造壁厚 | D |
| RD003 | **唯一主BODY—BODY_COVER接口X：X_BODY_JOINT** | D |
| RD004 | BODY/BODY_COVER定位止口直径与轴向长度 | D |
| RD005 | φ466×7 O圈具体槽位置/槽尺寸 | D |
| RD006 | 中法兰真实孔径、锪平/沉孔直径 | D |
| RD007 | 中法兰最终OD | D |
| RD008 | B16.34-2025 §6.4.2.3截面模量 | R/D |
| RD009 | 垫片压紧/螺栓预紧/中法兰局部弯曲完整校核 | R/D |
| RD010 | 上前盖安装面Z | D |
| RD011 | 底盖安装面Z、BCD、OD | D |
| RD012 | 上/下球孔总加工深度 | D |
| RD013 | 316+PTFE许用面压 | D |
| RD014 | 最终设计温度T_DESIGN | R/D |
| RD015 | 2.00MPa是否为精确项目设计压力或1.96的机械圆整 | R/D |
| RD016 | M24×100×10实际装配归属 | D |

已关闭：

```text
原RD002 T_B1634 → 9.6 B/STD
原RD005 主中法兰垫片 → φ500×φ490×3.2
原RD006 主中法兰主螺柱 → 20×M20×85；BCD第一版已建立
原RD012 F2F → 610 A / 项目锁定
```

---

# 20. 历史纠错

```text
H/R 上球体主轴承=φ70×φ65×50
→ 当前φ105×φ100×30

H/R Z_RU=Z_U0_ABS+27
→ 当前约+208.6

H 对称Ru=Rl≈82.35
→ 当前81.037/83.655

H/R 独立下支承轴
→ 当前BOTTOM_COVER一体φ65轴颈

H/C 下球孔固定总深52
→ 当前有效轴承圆柱段50，总深D

H/R 下球孔底Z=-175
→ 当前D

H/R LEFT COVER—BODY—RIGHT COVER
→ 当前BODY + BODY_COVER，两片式，一个主分界面

H/R X_BODY_COVER_IF_L/R镜像
→ 当前X_BODY_JOINT=?

H/R 主中法兰M24×100×10
→ 当前20×M20×85；M24组功能重新D
```

---

# 21. 当前建模文件层级

建议正式调整为：

```text
00_SKELETON.SLDPRT
01_BALL.SLDPRT
02_LEFT_SEAT.SLDASM
03_RIGHT_SEAT.SLDASM
04_STEM_COVER.SLDPRT
05_STEM.SLDPRT
06_BOTTOM_COVER.SLDPRT
07_BODY.SLDPRT
08_BODY_COVER.SLDPRT
09_MAIN_BODY_JOINT_FASTENERS.SLDASM
10_TOP_ADAPTER.SLDPRT
```

旧：

```text
08_LEFT_END_COVER_ENVELOPE
09_RIGHT_END_COVER_ENVELOPE
```

降为H/R，不再创建两个大阀盖实体。

---

# 22. 下一步 V22 / 第6C

现在已具备：

```text
BALL_CENTER_O
F2F=610 / 端面±305
球体与两侧阀座功能包络
BODY中央承压外包络φ498.2 C
唯一主中法兰密封件
20×M20主中法兰
BCD≈φ526.5 C
中法兰外包络≈φ562.5 C
```

下一步必须沿真实X轴建立完整轴向链：

```text
左右球面密封接触带
↓
阀座导向 / 弹簧 / 支承圈轴向台阶
↓
BODY侧座腔
↓
BODY_COVER侧座腔
↓
定位止口
↓
φ466×7 O圈
↓
φ500×φ490×3.2缠绕垫
↓
PLN_BODY_JOINT_X
↓
BODY_COVER到对应端面±305的长度
↓
BODY + BODY_COVER第一版承压实体骨架
```

**V22的第一目标不是再增加更多零件，而是把 `X_BODY_JOINT` 从 `D` 推到可追溯的 `C/C+`，让两片式主壳体真正能在SolidWorks里落地。**

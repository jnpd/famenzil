# Q347F 12寸 Class150——数字化总装骨架总账 V8

> **定位**：这是当前 Q347F 12寸 Class150 固定球阀的唯一数字化汇总页。同步保存 **尺寸参数 + 装配关系 + 空间坐标 + SolidWorks变量 + 开放项 + 历史纠错**。  
> **当前主线已推进到 V24 / 第6E步**：两片式主壳体、F2F=610、BODY中央壁厚、唯一主中法兰、BODY/BODY_COVER轴向分界、M20×85轴向预算、VENT/DRAIN Boss约束，以及“端面φ466×7 O圈 + φ500×φ490缠绕垫 + H8/f8止口”均已建立。

> **永久规则**：  
> 1. 工程字段统一使用 **中文名称（英文变量名）**；  
> 2. 后续更新不得删除已存在工程字段，旧值被纠正时降为 `H/H-R`；  
> 3. SolidWorks英文变量名用于方程式/VBA/脚本，变量名不得随意改；  
> 4. 20寸资料只用于成熟结构参考，不直接成为12寸制造尺寸。

[← 总导航](./00_Q347F_12in_Class150_文档导航_从这里开始.md)  
[← 主计算母版](./Q347F_12in_Class150_球体设计计算底稿_第一部分_小白可读公式完整版.md)  
[← V21](./Q347F_12in_Class150_第6B步_两片式主壳体纠错_中法兰垫片_M20螺柱_B16_34校核_V21.md)  
[← V22](./Q347F_12in_Class150_第6C步_BODY_BODY_COVER轴向分界_X_BODY_JOINT与610闭合_V22.md)  
[← V23](./Q347F_12in_Class150_第6D步_主中法兰螺柱轴向预算_VENT_DRAIN接口Boss_V23.md)  
[← V24](./Q347F_12in_Class150_第6E步_主中法兰端面O圈_缠绕垫_H8f8止口_V24.md)

---

# 1. 状态规则

| 状态 | 含义 |
|---|---|
| A | 项目/BOM/公司明确值 |
| A-policy | 公司设计方法明确，具体制造值仍待关闭 |
| B | 由接受输入直接计算 |
| C | 有依据的CAD候选，可草模，未制造冻结 |
| C+ | 多条独立证据交叉支持 |
| C-space | 仅为保持CAD空间链不断的草模候选 |
| D | 前置不足，禁止填死 |
| P-XREF | 跨结构参考/敏感性 |
| H | 历史值 |
| H/R | 历史且已纠正，当前禁止使用 |
| R | 风险/冻结门 |

---

# 2. 项目基线

```text
公称尺寸（NPS）                    = NPS12 / DN300                    A
压力等级（CLASS）                 = 150                              A
结构形式（TYPE）                  = 枢轴固定球 / trunnion-mounted    A
阀体装入形式（BODY_ENTRY_TYPE）   = SIDE_ENTRY / 侧装式              A/C+
主壳体件数（BODY_PIECE_COUNT）    = 2                                A/C+
流道直径（BORE_D）                = 303                              A
介质（MEDIUM）                    = 天然气                            A
机械载荷计算压力（P_LOAD_CALC）   = 2.00 MPa                         A
阀体材料（BODY_MAT）              = ASTM A216 WCB                    A
球体材料（BALL_MAT）              = ASTM A182 F316                   A
阀杆材料（STEM_MAT）              = ASTM A182 F51                    A
阀座软密封材料（SEAT_SOFT）       = DEVLON                           A
O形圈材料（ORING_MAT）            = VITON                            A
```

标准额定压力与机械计算压力永久拆开：

```text
P_LOAD_CALC = 2.00MPa
P_RATING_ALLOWED = f(CLASS, MATERIAL, T_DESIGN)
```

当前 WCB / Class150 常温段参考额定约1.96MPa，因此：

```text
压力等级风险（R20_01_PRESSURE_CLASS） = HIGH
最终设计温度（T_DESIGN）              = ? D/R
```

不能直接把2.00MPa写成WCB/Class150标准额定压力。

---

# 3. 永久坐标 / F2F

```text
球心坐标（BALL_CENTER_O） = (0,0,0)
流道轴（FLOW_AXIS）       = X
支承轴（SUPPORT_AXIS）    = Z
-X = 入口
+X = 出口
+Z = 阀杆/驱动
-Z = 底盖
```

SolidWorks基准：

```text
Origin = BALL_CENTER_O
Front = XZ
Top   = XY
Right = YZ
Axis_X = FLOW_AXIS
Axis_Z = SUPPORT_AXIS
```

结构长度项目锁定：

```text
阀门结构长度（VALVE_F2F）       = 610mm     A
半结构长度（HALF_F2F）          = 305       B
左端面X（X_END_FACE_L）         = -305      B/A
右端面X（X_END_FACE_R）         = +305      B/A
标准F2F公差（F2F_TOL_STD）      = ±3mm      STD
```

838顶装式口径 → `H/R-for-current-side-entry`。

---

# 4. 主壳体拓扑——永久修正

```text
主阀体（BODY）             = 主承压大件1
侧装主阀盖（BODY_COVER）   = BOM“阀盖”，主承压大件2
前盖（STEM_COVER）         = Z轴上部小盖
底盖（BOTTOM_COVER）       = Z轴下部小盖
```

一级结构：

```text
                         STEM_COVER
                              │
END FLANGE ─ BODY ─ SEAT ─── BALL ─── SEAT ─ BODY_COVER ─ END FLANGE
                              │
                         BOTTOM_COVER
```

```text
主阀体数量（BODY_QTY）               =1   A
侧装主阀盖数量（BODY_COVER_QTY）     =1   A
主壳体分界面数量（BODY_JOINT_COUNT） =1   A/C+
```

旧：

```text
LEFT COVER ─ BODY ─ RIGHT COVER
IF-X-L / IF-X-R
X_BODY_COVER_IF_L/R镜像
```

全部 `H/R`。

---

# 5. 球体

```text
球体外径（BALL_OD）                        =465       C
球体半径（BALL_R）                         =232.5     B
球体X向总宽（BALL_W_X）                    =348       C
球体左端基准X（BALL_X_FACE_L）             =-174      B/C
球体右端基准X（BALL_X_FACE_R）             =+174      B/C
流道直径（BORE_D）                         =303       A

球体上孔直径（BALL_UPPER_BORE_D）          =105       C+
球体上孔有效长度（BALL_UPPER_BORE_EFFECTIVE_L）≈28.9 C
球体上孔总深（BALL_UPPER_BORE_TOTAL_DEPTH）=?        D

球体下孔直径（BALL_LOWER_BORE_D）          =70        C+
球体下孔有效长度（BALL_LOWER_BORE_EFFECTIVE_L）=50   C+
球体下孔总深（BALL_LOWER_BORE_TOTAL_DEPTH）>=50,最终? D
```

历史：

```text
下球孔固定52mm → H/C
下球孔底Z=-175 → H/R
```

---

# 6. 阀座密封副

```text
阀座D9（SEAT_D9）                    =323.88
阀座D10（SEAT_D10）                  =327.13
阀座D11（SEAT_D11）                  =342
阀座导向孔（SEAT_GUIDE_BORE）        =342.4
阀座导向径向间隙（SEAT_GUIDE_CLR_RAD）=0.20

阀座主O圈（SEAT_ORING_MAIN）         =φ320×5.3
主O圈槽根径（SEAT_ORING_ROOT）       =333.6

第二O圈（SEAT_ORING_2）              =φ311×3.55
第二导向段（SEAT_PILOT_2）           =323.6
第二导向孔（SEAT_GUIDE_2）           =323.8
第二径向间隙（SEAT_CLR2_RAD）        =0.10

弹簧（SPRING）                       =φ8×φ1.6×18×7
弹簧数量（SPRING_QTY）               =36/侧
弹簧安装高度（SPRING_H_INST）        ≈15.6
弹簧PCD（SPRING_PCD）                =362

阀座大端OD（SEAT_BIG_OD）            =380
阀座大孔（SEAT_BIG_BORE）            =382
阀座功能包络宽（WSEAT_ENV）          ≈58 C-space
阀座前移（SEAT_TRAVEL_FWD）          >=1.0
阀座后退（SEAT_TRAVEL_BACK）         =0.5 C
```

真实球面密封接触：

```text
右侧接触带 ≈ +165.235~+166.828
右侧接触中心（X_CONTACT_R） = +166.036
左侧接触带 ≈ -166.828~-165.235
左侧接触中心（X_CONTACT_L） = -166.036
```

局部坐标：

```text
u_R = X - X_CONTACT_R
u_L = -(X - X_CONTACT_L)
```

禁止用球体平端±174替代密封接触位置。

---

# 7. 上球体主支承

```text
上球体主轴承（UP_BALL_BRG）      =φ105×φ100×30 A/C+
上轴颈（UP_JOURNAL_D）           =100            C+
上轴承中心Z（UP_BRG_CENTER_Z）   =+208.6         C
上轴承下端Z（UP_BRG_Z0）         =+193.6         C
上轴承上端Z（UP_BRG_Z1）         =+223.6         C
上支承力臂（A_SUPPORT_ARM）       =208.566        B/C
```

链：

```text
球体φ105孔
↓
φ105×φ100×30轴承
↓
STEM_COVER一体φ100轴颈
```

旧“上球体主轴承=φ70×φ65×50” → H/R。

---

# 8. 阀杆 / STEM_COVER内轨

```text
阀杆主径（STEM_MAIN_D）              =65
阀杆键部直径（STEM_KEY_D）           ≈60 C
阀杆台肩OD（STEM_SHOULDER_OD）       ≈74 C+
上止推垫（THRUST_UP）                =φ75×φ65×2
阀杆导向轴承（STEM_GUIDE_BRG）       =φ70×φ65×50

阀杆基准面Z（F0_Z）                  ≈+201.4 C
阀杆导向轴承下端Z（STEM_GUIDE_Z0）   ≈+203.4
阀杆导向轴承上端Z（STEM_GUIDE_Z1）   ≈+253.4

阀杆O圈（STEM_ORING）                =φ65×5.3×2
阀杆O圈槽根径（STEM_ORING_GROOT）    =73.8
阀杆O圈槽宽（STEM_ORING_GW）         =7
润滑脂区长度（OIL_LAND）             ≈16.8

填料（PACKING）                      =φ75×φ65×5
填料安装厚度（PACK_INSTALL_T）       ≈4.4 C/P
CAD阀杆功能链最高Z（Z_TOP_STEM_FUNC_CAD）≈+318.1
```

STEM_COVER外接口：

```text
上接口导向（TOP_IF_GUIDE_D）              =105
上接口O圈（TOP_IF_ORING）                 =φ95×5.3
上接口O圈槽根径（TOP_IF_ORING_ROOT_D）    =96.6 C+
上接口垫片（TOP_IF_GASKET）               =φ115×φ105×3.2
BODY上接口安装面Z（Z_BODY_TOP_IF）        =? D
```

---

# 9. 下球体主支承 / BOTTOM_COVER

```text
下球体主轴承（LOWER_BRG）             =φ70×φ65×50 A
下轴颈（LOWER_JOURNAL_D）             =65 C+ / 底盖一体
下止推垫（LOWER_THRUST）              =φ65×φ20×2 A/C+
下轴承中心Z（LOWER_BRG_CENTER_Z）     =-202.0 C
下轴承外端Z（LOWER_BRG_Z_OUT）        =-227.0 C
下轴承内端Z（LOWER_BRG_Z_IN）         =-177.0 C
下球孔口Z（LOWER_BORE_MOUTH_Z）       =-227.0 C
下球孔底Z（LOWER_BORE_BOTTOM_Z）      =? D
下支承力臂（B_SUPPORT_ARM）            =202.039 B/C
```

底盖接口：

```text
底接口导向（BOTTOM_IF_GUIDE_D）             =70
底接口O圈（BOTTOM_IF_ORING）                =φ58×5.3 AED
底接口O圈槽根径（BOTTOM_IF_ORING_ROOT_D）   =61.6
底接口垫片（BOTTOM_IF_GASKET）              =φ80×φ70×3.2
底接口螺柱（BOTTOM_IF_STUD）                =6×M12×55
底接口BCD（BOTTOM_IF_BCD）                  =? D
底接口法兰OD（BOTTOM_IF_FLANGE_OD）         =? D
BODY底接口面Z（Z_BODY_BOTTOM_IF）           =? D
```

---

# 10. 支承载荷

```text
总支承载荷（F_SUPPORT） =164.692 kN
上支承反力（RU_SUPPORT）=81.037 kN
下支承反力（RL_SUPPORT）=83.655 kN
```

平均轴承面压需求：

```text
上≈27.01MPa
下≈25.74MPa
```

316+PTFE真实许用面压仍D。

---

# 11. 内部整体包络

```text
中央球体包络：x²+y²+z² <=232.5²
```

阀座大端：φ382 → R191 < R232.5，中央径向仍由球体控制。

```text
上轴承Z ≈193.6~223.6
Z_TOP_STEM_FUNC_CAD≈+318.1
TOP_NECK_FUNC_D_MIN=115

下轴承Z≈-227~-177
BOTTOM_FUNC_D_MIN=80
```

---

# 12. 中央球腔敏感性

最终径向间隙：

```text
BALL_BODY_CLR_RAD_FINAL=? D
```

P-XREF：

```text
CLR1.5 → BODY_CAVITY_D=468
CLR3.0 → BODY_CAVITY_D=471
CLR6.0 → BODY_CAVITY_D=477
```

当前CAD显示：

```text
BALL_BODY_CLR_RAD=3.0 P-XREF
BODY_CAVITY_D_FUNC=471 P-XREF/C-display
```

---

# 13. B16.34阀体壁厚 / V20

Class150、`100<d<=1300mm`：

```text
T_B1634(d)=0.0163*d+4.70
```

中央d=303：

```text
T_B1634=9.6mm B/STD
```

公司规则：

```text
BODY_WALL_ADD=3~5 A-policy
T_BODY_TARGET=12.6~14.6 B/C
T_BODY_CAD=13.6 C
```

中央外包络：

```text
BODY_LOW =493.2
BODY_MID =498.2 C default
BODY_HIGH=506.2
BODY_OUTER_D_CENTRAL_CAD=498.2
```

局部φ382若属于直接承压控制内径：

```text
T_B1634_LOCAL≈10.9
公司目标≈13.9~15.9
```

---

# 14. 唯一主中法兰 / V21

12寸主中法兰BOM链：

```text
主壳体O圈（BODY_JOINT_ORING） =φ466×7 A/C+
缠绕垫（MID_GASKET）          =φ500×φ490×3.2 A/C+
双头螺柱（MID_STUD）          =M20×85 A/C+
螺柱数量（MID_STUD_QTY）      =20 A/C+
螺母（MID_NUT）               =M20 A/C+
螺母数量（MID_NUT_QTY）       =20 A/C+
```

垫片径向宽：

```text
MID_GASKET_RADIAL_W=(500-490)/2=5mm B/C+
```

公司BCD公式：

```text
BCD = gasket OD + bolt-hole dia + 3~6
```

CAD：

```text
MID_BOLT_HOLE_D_CAD=22 C
MID_BCD_MIN=525
MID_BCD_MAX=528
MID_BCD_CAD=526.5 C
MID_SPOTFACE_D_CAD=36 C
MID_FLANGE_OD_CAD≈562.5 C
```

M20螺母：

```text
s=30
emin≈32.95
```

---

# 15. B16.34主中法兰第一轮校核

按sectional body joint：

```text
Pc=150
Ag=π/4×500²≈196349.5mm²
M20粗牙P=2.5
As_one≈244.79mm²
Ab_actual=20×244.79≈4895.9mm²
Ab_required≈4207.5mm²
MID_BOLT_AREA_MARGIN≈1.164
```

结论：

```text
§6.4.2.1 PRELIMINARY PASS
有效拉应力面积裕量约+16.4%
```

但2025版还需要截面模量门：

```text
MID_ZBN=?
MID_ZFB=?
R21_02_SECTION_MODULUS=OPEN R/D
```

不能把“螺栓面积通过”写成“整个中法兰最终合格”。

---

# 16. BODY/BODY_COVER轴向分界 / V22

当前CAD主分界：

```text
主分界面X CAD（X_BODY_JOINT_CAD） =+232.5 C
主分界面X最终（X_BODY_JOINT_FINAL）=? D
```

几何反校核：

```text
球体右平端→主分界 =232.5-174=58.5mm
右密封接触中心→主分界 =232.5-166.036=66.464mm
主分界→+X端面 =305-232.5=72.5mm
```

所以当前骨架：

```text
BALL_CENTER      X=0
BALL_FACE_R      X=174
BODY_JOINT_CAD   X=232.5
END_FACE_R       X=305
```

`232.5`只用于CAD骨架，不用于加工图。

---

# 17. M20×85轴向预算 / V23

GB/T901 M20：

```text
P=2.5
标准端部螺纹长度b=52
L_STUD=85
```

因为 `2b=104>85`，禁止使用“85-52-52=光杆长度”的算法。

GB/T6175 M20螺母：

```text
NUT_M=19.0~20.3
```

公司螺柱露出：

```text
2~3牙 =5~7.5mm
```

所以：

```text
MID_ANCHOR_PLUS_GRIP_AVAILABLE
=85-NUT_M-PROTRUSION
≈57.2~61.0mm
```

这是：

```text
有效锚固
+
有效夹持结构
+
必要装配影响
```

的总预算，**不是法兰厚度**。

当前：

```text
MID_STUD_ANCHOR_SIDE_FINAL=? D
MID_STUD_EMBED_EFFECTIVE=? D
MID_GRIP_EFFECTIVE=? D
```

敏感性仅供分析：

```text
锚固20 → 夹持37.2~41.0
锚固25 → 夹持32.2~36.0
锚固30 → 夹持27.2~31.0
```

---

# 18. BODY附件接口 / V23

12寸BOM明确：

```text
DRAIN_PORT_SIZE=1_NPT            A
DRAIN_PORT_QTY=1                 A
VENT_PORT_SIZE=1_NPT             A
VENT_PORT_QTY=1                  A
SEAT_GREASE_PORT_SIZE=3/8_NPT    A
SEAT_GREASE_PORT_QTY=2           A
CHECK_PORT_SIZE=1/4_NPT          A
CHECK_PORT_QTY=2                 A
```

1"NPT不是φ25.4直孔；当前参考有效螺纹长度约17.34mm，而中央CAD壁厚13.6mm：

```text
17.34-13.6≈3.74mm
```

所以：

```text
VENT_BOSS_REQUIRED=YES C+
DRAIN_BOSS_REQUIRED=YES C+
VENT_BOSS_H_FINAL=? D
DRAIN_BOSS_H_FINAL=? D
```

功能位置：

```text
VENT_PORT_Z>0
DRAIN_PORT_Z<0
```

绝对XYZ仍D，需避开前盖、底盖、主中法兰螺栓圈、注脂孔、筋板等。

---

# 19. 主中法兰端面密封 + H8/f8止口 / V24

## 19.1 φ466×7 O圈公司静槽

公司对`d1=7`：

```text
静槽深（MID_ORING_GROOVE_DEPTH）=5.7 A-policy
槽宽（MID_ORING_GROOVE_W）=9.5 A-policy
导角（MID_ORING_LEAD_Z）=5 A-policy
r1=1
r2=0.2
```

当前主方案：

```text
MID_ORING_MODE=AXIAL_FACE_STATIC C+
```

O圈几何：

```text
MID_ORING_ID=466
MID_ORING_CS=7
MID_ORING_FREE_OD=480
MID_ORING_CL_D_CAD=473
```

端面环槽CAD：

```text
MID_ORING_GROOVE_ID_CAD=463.5 B/C
MID_ORING_GROOVE_OD_CAD=482.5 B/C
MID_ORING_GROOVE_DEPTH=5.7
```

名义轴向压缩：

```text
MID_ORING_AXIAL_SQUEEZE_NOM
=(7-5.7)/7
≈18.57% B
```

## 19.2 与φ500×φ490缠绕垫嵌套

```text
MID_GASKET_ID=490
MID_GASKET_OD=500
MID_GASKET_T_FREE=3.2
```

自由O圈OD480到垫片ID490：

```text
(490-480)/2=5.0mm
```

当前O圈槽OD482.5到垫片ID490：

```text
MID_LAND_ORING_TO_GASKET_CAD
=(490-482.5)/2
=3.75mm B/C
```

径向主链：

```text
压力腔/止口
↓
φ463.5~φ482.5端面O圈槽
↓ 3.75
φ490~φ500缠绕垫
↓
φ526.5螺栓圈
↓
≈φ562.5中法兰外包络
```

## 19.3 H8/f8定位止口方向

公司：

```text
BODY=H8
BODY_COVER=f8
```

当前关闭：

```text
MID_PILOT_FEMALE_OWNER=BODY C+/A-policy
MID_PILOT_FEMALE_FIT=H8 A-policy
MID_PILOT_MALE_OWNER=BODY_COVER C+/A-policy
MID_PILOT_MALE_FIT=f8 A-policy
```

即：BODY为定位内孔，BODY_COVER为外圆凸止口。

最终：

```text
MID_PILOT_D_FINAL=? D
MID_PILOT_INSERT_L_FINAL=? D
```

为了SolidWorks第一版不断链：

```text
MID_PILOT_D_CAD=450 C-space
MID_LAND_PILOT_TO_ORING_CAD
=(463.5-450)/2
=6.75mm
```

**φ450禁止作为加工图制造尺寸。**

O圈槽归属：

```text
MID_ORING_GROOVE_OWNER_CAD=BODY_COVER C
MID_ORING_GROOVE_OWNER_FINAL=? D
```

CAD归属只为第一版实体建模便利，不是规范事实。

风险：

```text
R24_01_ORING_GASKET_LAND=OPEN   # 3.75mm金属带制造/刚度/防火校核
R24_02_PILOT_FINAL=OPEN         # φ450仅C-space
R24_03_GROOVE_OWNER=OPEN        # 最终槽归属待正式剖面
```

---

# 20. 核心装配关系

| Mate ID | 装配关系 |
|---|---|
| M001 | 球体中心固定到O，流道X、支承Z |
| M002/3 | 左右DEVLON与R232.5球面形成密封接触 |
| M004/5 | 左右阀座同轴X，仅保留规定轴向浮动 |
| M006 | φ342阀座导向 ↔ φ342.4座孔 |
| M007 | φ323.6导向段 ↔ φ323.8导向孔 |
| M008 | φ380大端 ↔ φ382大孔 |
| M009 | 球体φ105上孔 ↔ φ105上球轴承 |
| M010 | 上轴承ID100 ↔ STEM_COVER一体φ100轴颈 |
| M011 | 阀杆φ65 ↔ 阀杆导向轴承ID65 |
| M012 | 阀杆导向轴承OD70 ↔ STEM_COVER φ70孔 |
| M013 | 球体φ70下孔 ↔ 下轴承OD70 |
| M014 | 下轴承ID65 ↔ BOTTOM_COVER一体φ65轴颈 |
| M015 | STEM_COVER φ105凸台 ↔ BODY上接口导向+端面 |
| M016 | BOTTOM_COVER φ70凸台 ↔ BODY下接口导向+端面 |
| M017 | **BODY H8内孔 ↔ BODY_COVER f8凸止口；唯一X向主中法兰；端面φ466×7 O圈 + φ500×φ490缠绕垫 + 20×M20×85夹紧** |
| M018 | 上球体轴承轨与阀杆导向轨允许Z向功能重叠 |

旧M017“BODY↔左右两个主阀盖” → H/R。

---

# 21. SolidWorks变量块

> 英文变量名保留，中文注释不得删除。

```text
# BASE / 基础
BALL_CENTER_O=(0,0,0)              # 球心
FLOW_AXIS=X                         # 流道轴
SUPPORT_AXIS=Z                      # 支承轴

# F2F / 结构长度
VALVE_F2F=610                       # 结构长度
X_END_FACE_L=-305                   # 左端面
X_END_FACE_R=305                    # 右端面

# MAIN BODY TOPOLOGY / 主壳体
BODY_PIECE_COUNT=2                  # 主承压壳体件数
BODY_QTY=1                          # 主阀体数量
BODY_COVER_QTY=1                    # 侧装主阀盖数量
BODY_JOINT_COUNT=1                  # 主分界数量
X_BODY_JOINT_CAD=232.5              # CAD主分界X
X_BODY_JOINT_FINAL=?                # 最终主分界X

# BALL / 球体
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

# SEAT / 阀座
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

# UPPER SUPPORT / 上球体支承
UP_BALL_BRG_OD=105
UP_BALL_BRG_ID=100
UP_BALL_BRG_L=30
UP_BRG_CENTER_Z=208.6
UP_BRG_Z0=193.6
UP_BRG_Z1=223.6
UP_JOURNAL_D=100

# STEM / 阀杆
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

# LOWER SUPPORT / 下球体支承
LOWER_BRG_OD=70
LOWER_BRG_ID=65
LOWER_BRG_L=50
LOWER_BRG_CENTER_Z=-202.0
LOWER_BRG_Z_OUT=-227.0
LOWER_BRG_Z_IN=-177.0
LOWER_BORE_MOUTH_Z=-227.0
LOWER_BORE_BOTTOM_Z=?
LOWER_JOURNAL_D=65

# TOP IF / 上接口
TOP_IF_GUIDE_D=105
TOP_IF_ORING_ROOT_D=96.6
TOP_IF_GASKET_ID=105
TOP_IF_GASKET_OD=115
Z_BODY_TOP_IF=?

# BOTTOM IF / 底接口
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

# CAVITY / BODY WALL / 球腔壁厚
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

# MAIN JOINT FACE SEAL / 主中法兰端面密封
MID_ORING_ID=466                    # 主O圈内径
MID_ORING_CS=7                      # 主O圈截面
MID_ORING_FREE_OD=480               # 主O圈自由外径
MID_ORING_CL_D_CAD=473              # 主O圈CAD中心线直径
MID_ORING_GROOVE_DEPTH=5.7          # 公司φ7静槽深
MID_ORING_GROOVE_W=9.5              # 公司φ7槽宽
MID_ORING_LEAD_Z=5
MID_ORING_R1=1
MID_ORING_R2=0.2
MID_ORING_GROOVE_ID_CAD=463.5
MID_ORING_GROOVE_OD_CAD=482.5
MID_ORING_AXIAL_SQUEEZE_NOM=18.57
MID_ORING_GROOVE_OWNER_CAD=BODY_COVER
MID_ORING_GROOVE_OWNER_FINAL=?

MID_GASKET_OD=500
MID_GASKET_ID=490
MID_GASKET_T_FREE=3.2
MID_GASKET_RADIAL_W=5
MID_LAND_ORING_TO_GASKET_CAD=3.75

# LOCATING PILOT / 体盖定位止口
MID_PILOT_FEMALE_OWNER=BODY
MID_PILOT_FEMALE_FIT=H8
MID_PILOT_MALE_OWNER=BODY_COVER
MID_PILOT_MALE_FIT=f8
MID_PILOT_D_CAD=450
MID_PILOT_D_FINAL=?
MID_PILOT_INSERT_L_FINAL=?
MID_LAND_PILOT_TO_ORING_CAD=6.75

# MAIN BOLTING / 主中法兰紧固
MID_STUD_STANDARD=GBT901
MID_STUD_SIZE=M20
MID_STUD_P=2.5
MID_STUD_L=85
MID_STUD_END_THREAD_B=52
MID_STUD_QTY=20
MID_NUT_STANDARD=GBT6175
MID_NUT_SIZE=M20
MID_NUT_QTY=20
MID_NUT_M_MIN=19.0
MID_NUT_M_MAX=20.3
MID_BOLT_HOLE_D_CAD=22
MID_BCD_MIN=525
MID_BCD_MAX=528
MID_BCD_CAD=526.5
MID_SPOTFACE_D_CAD=36
MID_SPOTFACE_D_FINAL=?
MID_FLANGE_OD_CAD=562.5
MID_STUD_PROTRUSION_L_MIN=5.0
MID_STUD_PROTRUSION_L_MAX=7.5
MID_ANCHOR_PLUS_GRIP_MIN=57.2
MID_ANCHOR_PLUS_GRIP_MAX=61.0
MID_STUD_ANCHOR_SIDE_FINAL=?
MID_STUD_EMBED_EFFECTIVE=?
MID_GRIP_EFFECTIVE=?

# B16.34 BODY JOINT / 主壳体分界校核
MID_AG=196349.5
MID_AS_ONE=244.79
MID_AB_ACTUAL=4895.9
MID_AB_REQUIRED=4207.5
MID_BOLT_AREA_MARGIN=1.164
MID_ZBN=?
MID_ZFB=?
R21_02_SECTION_MODULUS=OPEN

# BODY ACCESSORIES / 阀体附件
DRAIN_PORT_SIZE=1_NPT
DRAIN_PORT_QTY=1
VENT_PORT_SIZE=1_NPT
VENT_PORT_QTY=1
SEAT_GREASE_PORT_SIZE=3/8_NPT
SEAT_GREASE_PORT_QTY=2
CHECK_PORT_SIZE=1/4_NPT
CHECK_PORT_QTY=2
VENT_BOSS_REQUIRED=YES
DRAIN_BOSS_REQUIRED=YES
VENT_BOSS_H_FINAL=?
DRAIN_BOSS_H_FINAL=?

# LOAD / 载荷
F_SUPPORT=164.692
A_SUPPORT_ARM=208.566
B_SUPPORT_ARM=202.039
RU_SUPPORT=81.037
RL_SUPPORT=83.655

# PRESSURE RATING / 压力等级拆分
P_LOAD_CALC=2.00
T_DESIGN=?
P_RATING_ALLOWED=?

# RETIRED / 已停用
X_BODY_COVER_IF_L=H/R
X_BODY_COVER_IF_R=H/R
M24_MAIN_BODY_JOINT=H/R
M24_GROUP_FUNCTION=?
```

---

# 22. 当前开放项

| ID | 开放项 | 状态 |
|---|---|---|
| RD001 | 最终球体—阀体径向间隙 | D |
| RD002 | 阀体最终制造壁厚 | D |
| RD003 | X_BODY_JOINT_FINAL | D |
| RD004 | MID_PILOT_D_FINAL | D |
| RD005 | MID_PILOT_INSERT_L_FINAL | D |
| RD006 | 主中法兰O圈槽最终归属BODY还是BODY_COVER | D |
| RD007 | O圈槽—缠绕垫3.75mm金属带制造/刚度/防火复核 | R/D |
| RD008 | 主中法兰最终孔径/锪平直径/OD | D |
| RD009 | M20×85锚固侧及有效旋入长度 | D |
| RD010 | BODY/BODY_COVER各自中法兰有效轴向厚度 | D |
| RD011 | B16.34 §6.4.2.3截面模量 | R/D |
| RD012 | 垫片压紧/螺栓预紧/局部弯曲完整校核 | R/D |
| RD013 | STEM_COVER安装面Z | D |
| RD014 | BOTTOM_COVER安装面Z/BCD/OD | D |
| RD015 | 上/下球孔总加工深度 | D |
| RD016 | 316+PTFE许用面压 | D |
| RD017 | 最终设计温度T_DESIGN | R/D |
| RD018 | 2.00MPa是否精确项目设计压力或1.96的机械圆整 | R/D |
| RD019 | M24×100×10实际装配归属 | D |
| RD020 | VENT/DRAIN最终Boss高度与XYZ | D |

已关闭：

```text
F2F →610 A
T_B1634 →9.6 B/STD
主中法兰垫片 →φ500×φ490×3.2
主中法兰主螺柱 →20×M20×85
X_BODY_JOINT_CAD →+232.5 C
φ466×7静槽规则 →5.7深 / 9.5宽 A-policy
体盖定位方向 →BODY H8孔 / BODY_COVER f8凸止口
```

---

# 23. 历史纠错

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
→ 当前BODY+BODY_COVER两片式，一个主分界面

H/R X_BODY_COVER_IF_L/R镜像
→ 当前X_BODY_JOINT_CAD=+232.5 / FINAL=D

H/R 主中法兰M24×100×10
→ 当前20×M20×85；M24组功能重新D
```

---

# 24. 当前建模文件层级

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
LEFT_END_COVER_ENVELOPE
RIGHT_END_COVER_ENVELOPE
```

全部H/R。

在 `00_SKELETON.SLDPRT` 新增主接口参考对象：

```text
PLN_BODY_JOINT_X             X=232.5
SURF_MID_PILOT_REF           D=450 C-space
RING_MID_ORING_GROOVE_REF    ID=463.5 / OD=482.5 / DEPTH=5.7
RING_MID_GASKET_REF          ID=490 / OD=500 / T_FREE=3.2
CIRCLE_MID_BCD_REF           D=526.5 / 20等分
SURF_MID_FLANGE_OD_REF       D≈562.5
```

---

# 25. 下一步 V25 / 第6F

```text
MID_PILOT_INSERT_L
↓
M20×85锚固侧 / 有效旋入长度
↓
BODY侧中法兰有效轴向厚度
↓
BODY_COVER侧中法兰有效轴向厚度
↓
57.2~61.0mm轴向预算闭合
↓
B16.34 §6.4.2.3截面模量门
↓
BODY / BODY_COVER第一版可干涉检查实体
```

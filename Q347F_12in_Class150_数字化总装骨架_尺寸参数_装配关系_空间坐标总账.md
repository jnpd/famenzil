# Q347F 12寸 Class150——数字化总装骨架总账 V7

> **定位**：这是当前 Q347F 12寸 Class150 固定球阀的唯一数字化汇总页。  
> 同步保存 **尺寸参数 + 装配关系 + 空间坐标 + SolidWorks变量 + 开放项 + 历史纠错**。  
> **当前主线已推进到 V21 / 第6B步**：F2F=610已项目锁定；B16.34中央壁厚已建立；主壳体已纠正为 `BODY×1 + BODY_COVER×1` 两片式侧装结构；唯一主中法兰已绑定 `φ466×7 O圈 + φ500×φ490×3.2缠绕垫 + 20×M20×85`，并完成B16.34 §6.4.2.1第一轮面积校核。

> **字段展示永久规则（不得删除）**：  
> 1. 本总账所有工程字段统一使用 **中文名称（英文变量名）**，中文在前，英文变量名放括号内。  
> 2. 后续任何版本更新、合并、重构，都 **不得删除中文字段说明，不得退回只显示英文变量名**。  
> 3. `SolidWorks` 变量块为了宏、方程式和参数化脚本兼容，**英文变量名本体不得改名**，但每一行必须保留中文注释。  
> 4. 当前设计对象始终为 **12寸 / NPS 12 / DN300 / Class150**；20寸资料只用于成熟结构参考和交叉核对，**20寸尺寸不得直接写成12寸最终设计值**。

[← 总导航](./00_Q347F_12in_Class150_文档导航_从这里开始.md)  
[← 主计算母版](./Q347F_12in_Class150_球体设计计算底稿_第一部分_小白可读公式完整版.md)  
[← V19 F2F / Side Entry](./Q347F_12in_Class150_第5D步_API6D侧装式结构长度_610与838口径关闭_V19.md)  
[← V20 B16.34壁厚](./Q347F_12in_Class150_第6A步_ASME_B16_34阀体最小壁厚_压力等级风险_承压外壳_V20.md)  
[← V21 两片式主壳体 / 中法兰](./Q347F_12in_Class150_第6B步_两片式主壳体纠错_中法兰垫片_M20螺柱_B16_34校核_V21.md)

---

# 1. 状态规则

| 状态（Status） | 含义（Meaning） |
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
公称尺寸（NPS）                    = 12 / DN300                    A
压力等级（CLASS）                 = 150                           A
结构形式（TYPE）                  = 枢轴固定球（trunnion-mounted fixed ball） A
阀体装入形式（BODY_ENTRY_TYPE）   = 侧装式（SIDE_ENTRY）          A/C+
主壳体件数（BODY_PIECE_COUNT）    = 2                             A/C+
流道直径（BORE_D）                = 303                           A
介质（MEDIUM）                    = 天然气                         A
机械载荷计算压力（P_LOAD_CALC）   = 2.00 MPa                      A / 机械载荷计算输入
阀体材料（BODY_MAT）              = ASTM A216 WCB                 A
球体材料（BALL_MAT）              = ASTM A182 F316                A
阀杆材料（STEM_MAT）              = ASTM A182 F51                 A
阀座软密封材料（SEAT_SOFT）       = DEVLON                        A
O形圈材料（ORING_MAT）            = VITON                         A
```

压力等级标准合规永久拆开：

```text
机械载荷计算压力（P_LOAD_CALC） = 2.00MPa
用途：球体/支承/阀杆等保守机械载荷计算

标准允许压力（P_RATING_ALLOWED） = f(压力等级CLASS, 材料MATERIAL, 设计温度T_DESIGN)
用途：ASME B16.34压力-温度额定合规
```

当前 WCB / Class150 常温段标准额定约：

```text
1.96 MPa
```

因此：

```text
压力等级风险（R20_01_PRESSURE_CLASS） = HIGH
设计温度（T_DESIGN）                  = ?
```

2.00MPa不能直接写成WCB/Class150标准额定压力。

---

# 3. 永久坐标与结构长度

```text
球心坐标（BALL_CENTER_O） = (0,0,0)
流道轴（FLOW_AXIS）       = X
支承轴（SUPPORT_AXIS）    = Z
-X = 入口方向
+X = 出口方向
+Z = 阀杆/驱动方向
-Z = 底盖方向
```

SolidWorks基准：

```text
原点（Origin）   = 球心坐标（BALL_CENTER_O）
前视基准面（Front） = XZ
上视基准面（Top）   = XY
右视基准面（Right） = YZ
X轴（Axis_X）    = 流道轴（FLOW_AXIS）
Z轴（Axis_Z）    = 支承轴（SUPPORT_AXIS）
```

结构长度项目已锁定：

```text
阀门结构长度（VALVE_F2F）       = 610 mm             A
半结构长度（HALF_F2F）          = 305                 B
左端面X坐标（X_END_FACE_L）     = -305                B/A
右端面X坐标（X_END_FACE_R）     = +305                B/A
结构长度标准公差（F2F_TOL_STD） = ±3 mm               STD
```

历史/参考：

```text
838顶装式口径 → H/R-for-current-side-entry
```

---

# 4. 主壳体拓扑——V21永久修正

永久命名：

```text
主阀体（BODY）             = 主承压大件1
侧装主阀盖（BODY_COVER）   = BOM“阀盖”，侧装主阀盖/连接体，主承压大件2
前盖（STEM_COVER）         = BOM“前盖”，Z轴上部小盖
底盖（BOTTOM_COVER）       = BOM“底盖”，Z轴下部小盖
```

一级结构：

```text
                         前盖（STEM_COVER）
                              │
端法兰 ─ 主阀体（BODY） ─ 阀座 ─ 球体 ─ 阀座 ─ 侧装主阀盖（BODY_COVER） ─ 端法兰
                              │
                         底盖（BOTTOM_COVER）
```

当前：

```text
主阀体数量（BODY_QTY）              = 1      A
侧装主阀盖数量（BODY_COVER_QTY）    = 1      A
主壳体分界面数量（BODY_JOINT_COUNT）= 1      A/C+
```

旧结构：

```text
LEFT COVER ─ BODY ─ RIGHT COVER
IF-X-L / IF-X-R
X_BODY_COVER_IF_L=-X_BODY_COVER_IF_R
```

统一：`H/R`。

当前唯一主分界：

```text
主阀体分界接口（IF-X-BODY-JOINT）
主阀体分界基准面（PLN_BODY_JOINT_X）
主阀体分界X坐标（X_BODY_JOINT） = ?     D
```

左右阀座仍为2套，左右接触带与局部坐标仍可镜像。

---

# 5. 球体

```text
球体外径（BALL_OD）               = 465       C
球体半径（BALL_R）                = 232.5     B
球体X向总宽（BALL_W_X）           = 348       C
球体左端基准X（BALL_X_FACE_L）    = -174      B/C
球体右端基准X（BALL_X_FACE_R）    = +174      B/C
流道直径（BORE_D）                = 303       A
```

上孔：

```text
球体上孔直径（BALL_UPPER_BORE_D）              = 105     C+
球体上孔有效长度（BALL_UPPER_BORE_EFFECTIVE_L） ≈ 28.9    C
球体上孔总加工深度（BALL_UPPER_BORE_TOTAL_DEPTH） = ?      D
```

下孔：

```text
球体下孔直径（BALL_LOWER_BORE_D）               = 70      C+
球体下孔有效长度（BALL_LOWER_BORE_EFFECTIVE_L） = 50      C+
球体下孔总加工深度（BALL_LOWER_BORE_TOTAL_DEPTH） >=50，最终? D
```

历史：

```text
下球孔固定52 → H/C
历史下球孔底Z（LOWER_BORE_BOTTOM_Z）=-175 → H/R
```

---

# 6. 阀座密封副

```text
阀座D9直径（SEAT_D9）                   = 323.88
阀座D10直径（SEAT_D10）                 = 327.13
阀座D11直径（SEAT_D11）                 = 342
阀座导向孔直径（SEAT_GUIDE_BORE）       = 342.4
阀座导向径向间隙（SEAT_GUIDE_CLR_RAD）  = 0.20

阀座主O形圈（SEAT_ORING_MAIN）          = φ320×5.3
阀座主O形圈槽根径（SEAT_ORING_ROOT）    = 333.6

阀座第二O形圈（SEAT_ORING_2）           = φ311×3.55
阀座第二导向段直径（SEAT_PILOT_2）      = 323.6
阀座第二导向孔直径（SEAT_GUIDE_2）      = 323.8
阀座第二径向间隙（SEAT_CLR2_RAD）       = 0.10

弹簧规格（SPRING）                      = φ8×φ1.6×18×7
单侧弹簧数量（SPRING_QTY）              = 36/侧（side）
弹簧安装高度（SPRING_H_INST）           ≈15.6
弹簧分布圆直径（SPRING_PCD）            = 362

阀座大端外径（SEAT_BIG_OD）             = 380
阀座大孔直径（SEAT_BIG_BORE）           = 382
阀座功能包络宽度（WSEAT_ENV）           ≈58       C-space
阀座前移行程（SEAT_TRAVEL_FWD）         >=1.0
阀座后退行程（SEAT_TRAVEL_BACK）        =0.5      C
```

真实球面密封接触：

```text
右侧密封接触带 ≈ +165.235~+166.828
右侧密封接触X（X_CONTACT_R） = +166.036
左侧密封接触带 ≈ -166.828~-165.235
左侧密封接触X（X_CONTACT_L） = -166.036
```

不要用球体端面±174代替密封接触位置。

局部坐标继续有效：

```text
右侧局部坐标（u_R） = X - X_CONTACT_R
左侧局部坐标（u_L） = -(X - X_CONTACT_L)
```

---

# 7. 上球体主支承

```text
上球体主轴承（UP_BALL_BRG）      = φ105×φ100×30   A/C+
上支承轴颈直径（UP_JOURNAL_D）   = 100             C+
上轴承中心Z（UP_BRG_CENTER_Z）   = +208.6          C
上轴承下端Z（UP_BRG_Z0）         = +193.6          C
上轴承上端Z（UP_BRG_Z1）         = +223.6          C
上支承力臂（A_SUPPORT_ARM）       = 208.566         B/C
```

正确链：

```text
球体φ105孔
↓
φ105×φ100×30轴承
↓
前盖（STEM_COVER）一体φ100支承轴颈
```

旧“上球体主轴承=φ70×φ65×50” → H/R。

---

# 8. 阀杆 / 前盖（STEM_COVER）内轨

```text
阀杆主径（STEM_MAIN_D）                = 65
阀杆键部直径（STEM_KEY_D）             ≈60        C
阀杆台肩外径（STEM_SHOULDER_OD）       ≈74        C+
上止推垫（THRUST_UP）                  = φ75×φ65×2
阀杆导向轴承（STEM_GUIDE_BRG）         = φ70×φ65×50

阀杆基准面Z（F0_Z）                    ≈+201.4    C
阀杆导向轴承下端Z（STEM_GUIDE_Z0）     ≈+203.4
阀杆导向轴承上端Z（STEM_GUIDE_Z1）     ≈+253.4

阀杆O形圈（STEM_ORING）                = φ65×5.3×2
阀杆O形圈槽根径（STEM_ORING_GROOT）    = 73.8
阀杆O形圈槽宽（STEM_ORING_GW）         = 7
润滑脂槽区长度（OIL_LAND）             ≈16.8

填料（PACKING）                        = φ75×φ65×5
填料安装厚度（PACK_INSTALL_T）         ≈4.4       C/P
CAD阀杆功能链最高Z（Z_TOP_STEM_FUNC_CAD） ≈+318.1
```

前盖（STEM_COVER）外接口：

```text
上接口导向直径（TOP_IF_GUIDE_D）          = 105
上接口O形圈（TOP_IF_ORING）               = φ95×5.3
上接口O形圈槽根径（TOP_IF_ORING_ROOT_D）  = 96.6      C+
上接口垫片（TOP_IF_GASKET）               = φ115×φ105×3.2
阀体上接口安装面Z（Z_BODY_TOP_IF）        = ?         D
```

---

# 9. 下球体主支承 / 底盖（BOTTOM_COVER）

```text
下球体主轴承（LOWER_BRG）          = φ70×φ65×50      A
下支承轴颈直径（LOWER_JOURNAL_D） = 65                C+ / 底盖一体
下止推垫（LOWER_THRUST）           = φ65×φ20×2       A/C+
下轴承中心Z（LOWER_BRG_CENTER_Z） = -202.0            C
下轴承外端Z（LOWER_BRG_Z_OUT）    = -227.0            C
下轴承内端Z（LOWER_BRG_Z_IN）     = -177.0            C
下球孔口Z（LOWER_BORE_MOUTH_Z）   = -227.0            C
下球孔底Z（LOWER_BORE_BOTTOM_Z）  = ?                 D
下支承力臂（B_SUPPORT_ARM）        = 202.039           B/C
```

底盖密封/连接：

```text
底接口导向直径（BOTTOM_IF_GUIDE_D）           = 70
底接口O形圈（BOTTOM_IF_ORING）                = φ58×5.3 AED
底接口O形圈槽根径（BOTTOM_IF_ORING_ROOT_D）   = 61.6
底接口垫片（BOTTOM_IF_GASKET）                = φ80×φ70×3.2
底接口双头螺柱数量（BOTTOM_IF_STUD_QTY）      = 6
底接口双头螺柱规格（BOTTOM_IF_STUD_SIZE）     = M12
底接口双头螺柱长度（BOTTOM_IF_STUD_L）        = 55
底接口螺栓分布圆（BOTTOM_IF_BCD）             = ?     D
底接口法兰外径（BOTTOM_IF_FLANGE_OD）         = ?     D
阀体底接口安装面Z（Z_BODY_BOTTOM_IF）         = ?     D
```

---

# 10. 支承载荷

```text
总支承载荷（F_SUPPORT） = 164.692 kN
上支承反力（RU_SUPPORT）= 81.037 kN
下支承反力（RL_SUPPORT）= 83.655 kN
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
球体包络：x²+y²+z² <=232.5²
```

阀座大端：

```text
φ382 → R191 < R232.5
```

因此中央径向主控制仍为球体。

上部：

```text
上轴承Z范围（UP_BRG Z）                 ≈193.6~223.6
CAD阀杆功能链最高Z（Z_TOP_STEM_FUNC_CAD）≈+318.1
上颈部最小功能直径（TOP_NECK_FUNC_D_MIN）=115
```

下部：

```text
下轴承Z范围（LOWER_BRG Z）             ≈-227~-177
底部最小功能直径（BOTTOM_FUNC_D_MIN）   =80
```

---

# 12. 中央球腔敏感性

最终固定球与阀体径向间隙：

```text
最终球体-阀体径向间隙（BALL_BODY_CLR_RAD_FINAL） = ?   D
```

P-XREF：

```text
1.5mm间隙（CLR1.5） → 球腔直径（BODY_CAVITY_D）=468
3.0mm间隙（CLR3.0） → 球腔直径（BODY_CAVITY_D）=471
6.0mm间隙（CLR6.0） → 球腔直径（BODY_CAVITY_D）=477
```

当前CAD显示：

```text
当前球体-阀体径向间隙（BALL_BODY_CLR_RAD） = 3.0   P-XREF
功能球腔直径（BODY_CAVITY_D_FUNC）          = 471   P-XREF/C-display
```

---

# 13. B16.34阀体最小壁厚 / V20

Class150、`100<d<=1300mm`：

```text
B16.34最小壁厚函数（T_B1634(d)） = 0.0163*d+4.70
```

中央 d=303：

```text
B16.34中央最小壁厚（T_B1634） = 9.6 mm   B/STD
```

公司规则：

```text
阀体附加壁厚（BODY_WALL_ADD）    = 3~5 mm       A-policy
目标阀体壁厚（T_BODY_TARGET）    = 12.6~14.6 mm B/C
CAD阀体壁厚（T_BODY_CAD）        = 13.6 mm       C
```

中央三档外包络：

```text
低档中央外包络（BODY_LOW）  = 468+2×12.6 = 493.2
中档中央外包络（BODY_MID）  = 471+2×13.6 = 498.2   C default
高档中央外包络（BODY_HIGH） = 477+2×14.6 = 506.2
```

因此：

```text
CAD中央阀体外包络直径（BODY_OUTER_D_CENTRAL_CAD） = 498.2
```

不是最终整阀最大外径。

局部φ382若确属直接承压控制内径：

```text
局部B16.34最小壁厚（T_B1634_LOCAL）≈10.9
公司目标≈13.9~15.9
```

边界归属进入BODY/BODY_COVER剖面继续检查。

---

# 14. 唯一主BODY—BODY_COVER中法兰 / V21

> 本节以 **12寸BOM和12寸设计链为主**；20寸成熟结构仅用于对应关系和成熟结构交叉核对，不直接继承20寸尺寸。

```text
主壳体连接O形圈（BODY_JOINT_ORING） = φ466×7             A/C+
主中法兰缠绕垫（MID_GASKET）         = φ500×φ490×3.2     A/C+
主中法兰双头螺柱（MID_STUD）         = M20×85             A/C+
主中法兰螺柱数量（MID_STUD_QTY）     = 20                 A/C+
主中法兰螺母（MID_NUT）              = M20                A/C+
主中法兰螺母数量（MID_NUT_QTY）      = 20                 A/C+
侧装主阀盖数量（BODY_COVER_QTY）      = 1                  A
```

垫片径向宽：

```text
中法兰垫片径向宽（MID_GASKET_RADIAL_W） = (500-490)/2 = 5mm   B/C+
```

公司规则：5~10mm，吻合。

M20普通间隙孔第一版：

```text
CAD中法兰螺栓孔直径（MID_BOLT_HOLE_D_CAD） = 22   C/STD-default
```

公司BCD公式：

```text
中法兰螺栓分布圆（MID_BCD）
= 垫片外径（GASKET_OD） + 螺栓孔直径（BOLT_HOLE_D） + (3~6)
```

得到：

```text
中法兰BCD最小值（MID_BCD_MIN） = 525
中法兰BCD最大值（MID_BCD_MAX） = 528
CAD中法兰BCD（MID_BCD_CAD）     = 526.5    C
```

20等分圆周节距：

```text
≈82.7mm
```

M20螺母：

```text
对边宽（s）=30mm
最小对角尺寸（e_min）≈32.95mm
```

锪平/沉孔仍D；仅CAD敏感性：

```text
35 → 中法兰外径（MID_FLANGE_OD）≈560~563
36 → 中法兰外径（MID_FLANGE_OD）≈561~564
38 → 中法兰外径（MID_FLANGE_OD）≈563~566
```

第一版：

```text
CAD锪平直径（MID_SPOTFACE_D_CAD） = 36       C
CAD中法兰外径（MID_FLANGE_OD_CAD） ≈562.5    C
```

不可用于制造冻结。

---

# 15. ASME B16.34-2025 §6.4.2.1 主中法兰螺栓面积门

当前按 sectional body joint：

```text
等级代号（Pc） = 150
垫片投影面积（Ag） = π/4×500² ≈196349.5 mm²
```

M20粗牙 P=2.5：

```text
单根M20有效拉应力面积（As_one） ≈244.79 mm²
实际总有效拉应力面积（Ab_actual） =20×244.79≈4895.9 mm²
```

`Sa≈138MPa`口径下：

```text
min(K2*Sa,Limit)=7000
```

要求：

```text
要求总有效拉应力面积（Ab_required） =150×196349.5/7000≈4207.5 mm²
```

结果：

```text
中法兰螺栓面积裕量（MID_BOLT_AREA_MARGIN） =4895.9/4207.5≈1.164
```

当前结论：

```text
§6.4.2.1 初步通过（PRELIMINARY PASS）
约+16.4%有效拉应力面积裕量
```

注意公式中的：

```text
等级代号（Pc） = Class designation = 150
```

不是 `机械载荷计算压力（P_LOAD_CALC）=2MPa`。

---

# 16. ASME B16.34-2025 §6.4.2.3 截面模量门

2025版 sectional body joint 还必须检查：

```text
阀体接管截面模量（Zbn） = body nozzle section modulus
螺栓布置截面模量（Zfb） = bolting arrangement section modulus
```

圆形螺栓圈：

```text
螺栓布置截面模量（Zfb） = C*AB/4
```

并结合：

```text
螺栓许用应力（Sa） = bolt allowable stress
阀体许用应力（Sb） = body allowable stress
```

满足标准关系。

当前：

```text
中法兰阀体截面模量（MID_ZBN） = ?
中法兰螺栓布置截面模量（MID_ZFB） = ?
截面模量风险门（R21_02_SECTION_MODULUS） = OPEN   R/D
```

因此不能因为§6.4.2.1通过就宣布整个中法兰最终合格。

---

# 17. 核心装配关系

| 配合编号（Mate ID） | 当前装配关系（Assembly Relation） |
|---|---|
| M001 | 球体中心固定到O，流道轴X、支承轴Z |
| M002/3 | 左右DEVLON与R232.5球面形成密封接触 |
| M004/5 | 左右阀座同轴X，仅保留规定轴向浮动 |
| M006 | φ342阀座导向 ↔ φ342.4座孔 |
| M007 | φ323.6导向段（pilot） ↔ φ323.8导向孔 |
| M008 | φ380大端 ↔ φ382大孔 |
| M009 | 球体φ105上孔 ↔ φ105上球轴承 |
| M010 | 上轴承内径100（ID100） ↔ 前盖（STEM_COVER）一体φ100轴颈 |
| M011 | 阀杆φ65 ↔ 阀杆导向轴承内径65（ID65） |
| M012 | 阀杆导向轴承外径70（OD70） ↔ 前盖（STEM_COVER）φ70孔 |
| M013 | 球体φ70下孔 ↔ 下轴承外径70（OD70） |
| M014 | 下轴承内径65（ID65） ↔ 底盖（BOTTOM_COVER）一体φ65轴颈 |
| M015 | 前盖φ105凸台（STEM_COVER boss） ↔ BODY上接口导向 + 端面 |
| M016 | 底盖φ70凸台（BOTTOM_COVER boss） ↔ BODY下接口导向 + 端面 |
| M017 | **主阀体（BODY） ↔ 侧装主阀盖（BODY_COVER）：唯一X向主中法兰，同轴 + 定位止口 + O圈/缠绕垫 + 20×M20夹紧** |
| M018 | 上球体轴承轨与阀杆导向轨允许Z向功能重叠 |

旧M017“BODY↔左右两个阀盖” → H/R。

---

# 18. 当前SolidWorks变量块

> **永久规则**：本节英文变量名是 SolidWorks / VBA / 参数化脚本接口，**变量名不得随意修改或翻译**；但每一行右侧的 **中文说明不得删除**。

```text
# 基础 / BASE
BALL_CENTER_O=(0,0,0)            # 球心坐标
FLOW_AXIS=X                       # 流道轴
SUPPORT_AXIS=Z                    # 支承轴

# 结构长度 / F2F
VALVE_F2F=610                     # 阀门结构长度
X_END_FACE_L=-305                 # 左端面X坐标
X_END_FACE_R=305                  # 右端面X坐标

# 主壳体拓扑 / MAIN BODY TOPOLOGY
BODY_PIECE_COUNT=2                # 主承压壳体总件数
BODY_QTY=1                        # 主阀体数量
BODY_COVER_QTY=1                  # 侧装主阀盖数量
BODY_JOINT_COUNT=1                # 主壳体分界面数量
X_BODY_JOINT=?                    # 主阀体与侧装主阀盖分界X坐标

# 球体 / BALL
BORE_D=303                        # 流道直径
BALL_OD=465                       # 球体外径
BALL_R=232.5                      # 球体半径
BALL_X_L=-174                     # 球体左端基准X
BALL_X_R=174                      # 球体右端基准X
BALL_UPPER_BORE_D=105             # 球体上孔直径
BALL_UPPER_BORE_EFFECTIVE_L=28.9  # 球体上孔有效长度
BALL_UPPER_BORE_TOTAL_DEPTH=?     # 球体上孔总加工深度
BALL_LOWER_BORE_D=70              # 球体下孔直径
BALL_LOWER_BORE_EFFECTIVE_L=50    # 球体下孔有效长度
BALL_LOWER_BORE_TOTAL_DEPTH=?     # 球体下孔总加工深度

# 阀座 / SEAT
X_CONTACT_L=-166.036              # 左侧密封接触X坐标
X_CONTACT_R=166.036               # 右侧密封接触X坐标
SEAT_D9=323.88                    # 阀座D9直径
SEAT_D10=327.13                   # 阀座D10直径
SEAT_D11=342                      # 阀座D11直径
SEAT_GUIDE_BORE=342.4             # 阀座导向孔直径
SEAT_PILOT_2=323.6                # 阀座第二导向段直径
SEAT_GUIDE_2=323.8                # 阀座第二导向孔直径
SPRING_PCD=362                    # 弹簧分布圆直径
SEAT_BIG_OD=380                   # 阀座大端外径
SEAT_BIG_BORE=382                 # 阀座大孔直径
WSEAT_ENV=58                      # 阀座功能包络宽度

# 上球体主支承 / UPPER SUPPORT
UP_BALL_BRG_OD=105                # 上球体轴承外径
UP_BALL_BRG_ID=100                # 上球体轴承内径
UP_BALL_BRG_L=30                  # 上球体轴承长度
UP_BRG_CENTER_Z=208.6             # 上轴承中心Z
UP_BRG_Z0=193.6                   # 上轴承下端Z
UP_BRG_Z1=223.6                   # 上轴承上端Z
UP_JOURNAL_D=100                  # 上支承轴颈直径

# 阀杆 / STEM
STEM_MAIN_D=65                    # 阀杆主径
STEM_KEY_D=60                     # 阀杆键部直径
F0_Z=201.4                        # 阀杆基准面Z
STEM_GUIDE_OD=70                  # 阀杆导向轴承外径
STEM_GUIDE_ID=65                  # 阀杆导向轴承内径
STEM_GUIDE_L=50                   # 阀杆导向轴承长度
STEM_GUIDE_Z0=203.4               # 阀杆导向轴承下端Z
STEM_GUIDE_Z1=253.4               # 阀杆导向轴承上端Z
STEM_ORING_GROOT=73.8             # 阀杆O形圈槽根径
STEM_ORING_GW=7                   # 阀杆O形圈槽宽
OIL_LAND=16.8                     # 润滑脂槽区长度
Z_TOP_STEM_FUNC_CAD=318.1         # CAD阀杆功能链最高Z

# 下球体主支承 / LOWER SUPPORT
LOWER_BRG_OD=70                   # 下球体轴承外径
LOWER_BRG_ID=65                   # 下球体轴承内径
LOWER_BRG_L=50                    # 下球体轴承长度
LOWER_BRG_CENTER_Z=-202.0         # 下轴承中心Z
LOWER_BRG_Z_OUT=-227.0            # 下轴承外端Z
LOWER_BRG_Z_IN=-177.0             # 下轴承内端Z
LOWER_BORE_MOUTH_Z=-227.0         # 下球孔口Z
LOWER_BORE_BOTTOM_Z=?             # 下球孔底Z
LOWER_JOURNAL_D=65                # 下支承轴颈直径

# 上接口 / TOP IF
TOP_IF_GUIDE_D=105                # 上接口导向直径
TOP_IF_ORING_ROOT_D=96.6          # 上接口O形圈槽根径
TOP_IF_GASKET_ID=105              # 上接口垫片内径
TOP_IF_GASKET_OD=115              # 上接口垫片外径
Z_BODY_TOP_IF=?                   # 阀体上接口安装面Z

# 底接口 / BOTTOM IF
BOTTOM_IF_GUIDE_D=70              # 底接口导向直径
BOTTOM_IF_ORING_ROOT_D=61.6       # 底接口O形圈槽根径
BOTTOM_IF_GASKET_ID=70            # 底接口垫片内径
BOTTOM_IF_GASKET_OD=80            # 底接口垫片外径
BOTTOM_IF_STUD_QTY=6              # 底接口双头螺柱数量
BOTTOM_IF_STUD_SIZE=M12           # 底接口双头螺柱规格
BOTTOM_IF_STUD_L=55               # 底接口双头螺柱长度
BOTTOM_IF_BCD=?                   # 底接口螺栓分布圆
BOTTOM_IF_FLANGE_OD=?             # 底接口法兰外径
Z_BODY_BOTTOM_IF=?                # 阀体底接口安装面Z

# 球腔 / 阀体壁厚 / CAVITY / BODY WALL
BALL_BODY_CLR_RAD=3.0             # 当前球体-阀体径向间隙（显示配置）
BODY_CAVITY_D_FUNC=471            # 功能球腔直径
BALL_BODY_CLR_RAD_FINAL=?         # 最终球体-阀体径向间隙
T_B1634=9.6                       # ASME B16.34中央最小壁厚
BODY_WALL_ADD_MIN=3               # 公司最小附加壁厚
BODY_WALL_ADD_MAX=5               # 公司最大附加壁厚
T_BODY_MIN_GUIDE=12.6             # 阀体指导最小目标壁厚
T_BODY_CAD=13.6                   # CAD阀体壁厚
T_BODY_MAX_GUIDE=14.6             # 阀体指导最大目标壁厚
T_BODY_FINAL=?                    # 最终制造阀体壁厚
BODY_OUTER_D_CENTRAL_CAD=498.2    # CAD中央阀体外包络直径

# 主壳体连接密封 / MAIN BODY JOINT SEALS
BODY_JOINT_ORING_D0=466           # 主壳体连接O形圈公称内径/基准直径
BODY_JOINT_ORING_CS=7             # 主壳体连接O形圈截面直径
MID_GASKET_OD=500                 # 主中法兰垫片外径
MID_GASKET_ID=490                 # 主中法兰垫片内径
MID_GASKET_T=3.2                  # 主中法兰垫片厚度
MID_GASKET_RADIAL_W=5             # 主中法兰垫片径向宽度

# 主中法兰紧固 / MAIN BODY JOINT BOLTING
MID_STUD_SIZE=M20                 # 主中法兰双头螺柱规格
MID_STUD_L=85                     # 主中法兰双头螺柱长度
MID_STUD_QTY=20                   # 主中法兰双头螺柱数量
MID_NUT_SIZE=M20                  # 主中法兰螺母规格
MID_NUT_QTY=20                    # 主中法兰螺母数量
MID_BOLT_HOLE_D_CAD=22            # CAD主中法兰螺栓孔直径
MID_BCD_MIN=525                   # 主中法兰BCD最小指导值
MID_BCD_MAX=528                   # 主中法兰BCD最大指导值
MID_BCD_CAD=526.5                 # CAD主中法兰螺栓分布圆
MID_SPOTFACE_D=?                  # 主中法兰最终锪平/沉孔直径
MID_SPOTFACE_D_CAD=36             # CAD主中法兰锪平直径
MID_FLANGE_OD_CAD=562.5           # CAD主中法兰外径

# B16.34主壳体分界校核 / B16.34 BODY JOINT
MID_AG=196349.5                   # 垫片投影面积Ag
MID_AS_ONE=244.79                 # 单根M20有效拉应力面积
MID_AB_ACTUAL=4895.9              # 实际螺栓总有效拉应力面积
MID_AB_REQUIRED=4207.5            # 标准要求螺栓总有效拉应力面积
MID_BOLT_AREA_MARGIN=1.164        # 主中法兰螺栓面积裕量
MID_ZBN=?                         # 阀体接管截面模量
MID_ZFB=?                         # 螺栓布置截面模量
R21_02_SECTION_MODULUS=OPEN       # B16.34截面模量风险门

# 载荷 / LOAD
F_SUPPORT=164.692                 # 总支承载荷kN
A_SUPPORT_ARM=208.566             # 上支承力臂
B_SUPPORT_ARM=202.039             # 下支承力臂
RU_SUPPORT=81.037                 # 上支承反力kN
RL_SUPPORT=83.655                 # 下支承反力kN

# 压力等级拆分 / PRESSURE RATING SPLIT
P_LOAD_CALC=2.00                  # 机械载荷计算压力MPa
T_DESIGN=?                        # 最终设计温度
P_RATING_ALLOWED=?                # 标准允许压力

# 已停用变量 / RETIRED
X_BODY_COVER_IF_L=H/R             # 历史左侧主阀体-阀盖接口X，已停用
X_BODY_COVER_IF_R=H/R             # 历史右侧主阀体-阀盖接口X，已停用
M24_MAIN_BODY_JOINT=H/R           # 历史主中法兰M24方案，已停用
M24_GROUP_FUNCTION=?              # M24组实际功能待重新确认
```

---

# 19. 当前开放项

| 编号（ID） | 开放项（Open Item） | 状态（Status） |
|---|---|---|
| RD001 | 最终球体—阀体径向间隙 | D |
| RD002 | 阀体最终制造壁厚 | D |
| RD003 | **唯一主BODY—BODY_COVER接口X：主壳体分界X坐标（X_BODY_JOINT）** | D |
| RD004 | BODY/BODY_COVER定位止口直径与轴向长度 | D |
| RD005 | φ466×7 O圈具体槽位置/槽尺寸 | D |
| RD006 | 中法兰真实孔径、锪平/沉孔直径 | D |
| RD007 | 中法兰最终外径（OD） | D |
| RD008 | B16.34-2025 §6.4.2.3截面模量 | R/D |
| RD009 | 垫片压紧/螺栓预紧/中法兰局部弯曲完整校核 | R/D |
| RD010 | 上前盖安装面Z | D |
| RD011 | 底盖安装面Z、螺栓分布圆（BCD）、外径（OD） | D |
| RD012 | 上/下球孔总加工深度 | D |
| RD013 | 316+PTFE许用面压 | D |
| RD014 | 最终设计温度（T_DESIGN） | R/D |
| RD015 | 2.00MPa是否为精确项目设计压力或1.96的机械圆整 | R/D |
| RD016 | M24×100×10实际装配归属 | D |

已关闭：

```text
原RD002 B16.34中央最小壁厚（T_B1634） → 9.6 B/STD
原RD005 主中法兰垫片 → φ500×φ490×3.2
原RD006 主中法兰主螺柱 → 20×M20×85；BCD第一版已建立
原RD012 结构长度（F2F） → 610 A / 项目锁定
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
→ 当前底盖（BOTTOM_COVER）一体φ65轴颈

H/C 下球孔固定总深52
→ 当前有效轴承圆柱段50，总深D

H/R 下球孔底Z=-175
→ 当前D

H/R LEFT COVER—BODY—RIGHT COVER
→ 当前主阀体（BODY） + 侧装主阀盖（BODY_COVER），两片式，一个主分界面

H/R X_BODY_COVER_IF_L/R镜像
→ 当前唯一主壳体分界X坐标（X_BODY_JOINT）=?

H/R 主中法兰M24×100×10
→ 当前20×M20×85；M24组功能重新D
```

---

# 21. 当前建模文件层级

建议正式调整为：

```text
00_SKELETON.SLDPRT                    # 总装骨架
01_BALL.SLDPRT                        # 球体
02_LEFT_SEAT.SLDASM                   # 左阀座组件
03_RIGHT_SEAT.SLDASM                  # 右阀座组件
04_STEM_COVER.SLDPRT                  # 前盖
05_STEM.SLDPRT                        # 阀杆
06_BOTTOM_COVER.SLDPRT                # 底盖
07_BODY.SLDPRT                        # 主阀体
08_BODY_COVER.SLDPRT                  # 侧装主阀盖
09_MAIN_BODY_JOINT_FASTENERS.SLDASM   # 主中法兰紧固件组件
10_TOP_ADAPTER.SLDPRT                 # 上部连接盘/适配件
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
球心坐标（BALL_CENTER_O）
结构长度F2F=610 / 端面±305
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
主阀体（BODY）侧座腔
↓
侧装主阀盖（BODY_COVER）侧座腔
↓
定位止口
↓
φ466×7 O圈
↓
φ500×φ490×3.2缠绕垫
↓
主壳体分界基准面（PLN_BODY_JOINT_X）
↓
侧装主阀盖（BODY_COVER）到对应端面±305的长度
↓
BODY + BODY_COVER第一版承压实体骨架
```

**V22的第一目标不是再增加更多零件，而是把 `主壳体分界X坐标（X_BODY_JOINT）` 从 `D` 推到可追溯的 `C/C+`，让两片式主壳体真正能在SolidWorks里落地。**
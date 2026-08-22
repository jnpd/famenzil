# Q347F 12寸 Class150——数字化总装骨架 / 尺寸参数 / 装配关系 / 空间坐标总账（当前统一版）

> **定位**：这是当前 Q347F 12寸 Class150 固定球阀的**唯一数字化结果总账**。只回答四件事：`现在是多少？在哪里？和谁装？状态是什么？`  
> **当前设计专题进度**：V43。  
> **当前SolidWorks实机进度**：`S00 PASS / S01 PASS / S02 PASS / S03 PASS`；`00_SKELETON.SLDPRT` 已生成。  
> **计算来源**：公式、推导、选值原因统一回到 [设计计算主线](./Q347F_12in_Class150_球体设计计算底稿_第一部分_小白可读公式完整版.md) 和各 Vxx 专题页。  
> **永久边界**：本账中的 `CAD` / `C` / `C+` 值可用于参数化草模，不自动等于制造冻结尺寸。

[← 总导航](./00_Q347F_12in_Class150_文档导航_从这里开始.md)  
[← 设计计算主线](./Q347F_12in_Class150_球体设计计算底稿_第一部分_小白可读公式完整版.md)  
[→ V42 SolidWorks变量交付](./Q347F_12in_Class150_第7L步_SolidWorks全局变量交付版_当前CAD_D门与HR隔离_V42.md)  
[→ 自动建模永久主流程](./Q347F_12in_Class150_SolidWorks一键自动建模_永久唯一主流程.md)

---

# 1. 状态规则

| 状态 | 含义 | 当前模型权限 |
|---|---|---|
| `A` | 项目/BOM/受控规范明确输入 | 可用 |
| `A-policy` | 方法/规则明确，最终制造数仍待关闭 | 按规则可用 |
| `B` | 已接受输入直接计算值 | 可用 |
| `C+` | 多条独立依据交叉支持的候选 | 可用于CAD |
| `C` | 有依据的设计/CAD候选 | 可用于CAD |
| `C-space` | 仅空间/包络占位 | 仅包络 |
| `P / P-XREF` | 代用、跨规格、敏感性 | 仅参考 |
| `D` | 前置不足 | 禁止填死 |
| `R / R-D` | 风险/合规门未关闭 | 关闭前不得冻结 |
| `H` | 历史值 | 禁止作为当前值 |
| `H/R` | 已纠正、禁止继续使用 | 禁止 |

---

# 2. 当前项目基线

| 中文工程名称 | English / Variable | 当前值 | 状态 |
|---|---|---:|---|
| 公称尺寸 | NPS / DN | NPS12 / DN300 | A |
| 压力等级 | CLASS | 150 | A |
| 结构形式 | TYPE | 固定球 / Trunnion-mounted | A |
| 主壳体结构 | BODY_CONSTRUCTION | 两片式 / Two-piece | A/C+ |
| 装入形式 | BODY_ENTRY_TYPE | Side Entry / 侧装式 | A/C+ |
| 流道 | BORE_D | φ303 mm | A |
| 介质 | MEDIUM | 天然气 | A |
| 机械载荷计算压力 | P_LOAD_CALC | 2.00 MPa | A |
| 设计温度 | T_DESIGN | ? | D/R |
| 标准允许额定压力 | P_RATING_ALLOWED | f(CLASS,MATERIAL,T_DESIGN) | D |
| 阀体材料 | BODY_MAT | ASTM A216 WCB | A |
| 球体材料 | BALL_MAT | ASTM A182 F316 | A |
| 阀杆材料 | STEM_MAT | ASTM A182 F51 | A |
| 阀座软密封 | SEAT_SOFT | DEVLON | A |
| O形圈 | ORING_MAT | VITON | A |

**压力永久拆分**：`P_LOAD_CALC=2.00MPa` 用于当前机械计算；不得自动等同 `P_RATING_ALLOWED`。

---

# 3. 全局坐标——项目语义坐标永远不变

```text
BALL_CENTER_O = (0,0,0)
X = FLOW_AXIS      流道轴
Y = CROSS_AXIS     横向轴
Z = SUPPORT_AXIS   支承/阀杆轴

-X = 入口方向
+X = 出口方向
+Z = 阀杆/驱动方向
-Z = 底盖方向
```

## 3.1 SolidWorks原生基准面规则——已由S03实机纠正

**禁止再写成永久硬绑定：**

```text
Front = XZ
Top   = XY
Right = YZ
```

程序必须：

```text
读取原生RefPlane真实世界几何
↓
按法向/恒定坐标识别 XY / XZ / YZ
↓
建立项目自己的语义基准面
```

项目统一使用：

```text
PLN_BASE_XY_FLOW_CROSS
PLN_BASE_XZ_FLOW_SUPPORT
PLN_BASE_YZ_CROSS_SUPPORT
AXIS_X_FLOW
AXIS_Z_SUPPORT
SK_PT_BALL_CENTER_O
```

---

# 4. X向总账

| 中文工程名称 | Variable / Feature | X mm | 状态 / 来源 |
|---|---|---:|---|
| 左RF端面 | X_END_FACE_L | -305.000 | A/B；F2F/2 |
| 左端法兰背面 | X_END_FLANGE_BACK_L_CAD | -273.200 | B/C |
| 左侧内部结构参考站 | X_BODY_JOINT_REF_L | -232.500 | C-reference；**不是第二主BODY joint** |
| 球体左平端 | BALL_X_L | -174.000 | B/C |
| 左真实密封接触 | X_CONTACT_L | -166.036 | B/C |
| 球心 | BALL_CENTER_O | 0 | A/定义 |
| 右真实密封接触 | X_CONTACT_R | +166.036 | B/C |
| 球体右平端 | BALL_X_R | +174.000 | B/C |
| 唯一主BODY分界 | X_BODY_JOINT_CAD | +232.500 | C+ |
| 右端法兰背面 | X_END_FLANGE_BACK_R_CAD | +273.200 | B/C |
| 右RF端面 | X_END_FACE_R | +305.000 | A/B |

```text
VALVE_F2F = 610 mm A
HALF_F2F  = 305 mm B
```

历史：顶装式/其它结构长度 `838`、短型 `356` 对当前几何统一 `H/R-for-current-geometry`。

---

# 5. Z向总账

| 中文工程名称 | Variable / Feature | Z mm | 状态 / 身份 |
|---|---|---:|---|
| 底盖外侧粗参考 | Z_BOTTOM_COVER_OUTER_REF_CAD | -289.1 | C/H-guide |
| BODY—BOTTOM_COVER安装面 | Z_BODY_BOTTOM_IF_CAD | -270.5 | C |
| 下支承轴→φ70 Boss肩面 | Z_BOTTOM_JOURNAL_PILOT_SHOULDER_CAD | -230.0 | C+ |
| 下轴承外端 | LOWER_BRG_Z_OUT | -227.0 | C |
| 下轴承内端 | LOWER_BRG_Z_IN | -177.0 | C |
| 球心 | BALL_CENTER_O | 0 | A/定义 |
| 上轴承内端 | UP_BRG_Z0 | +193.6 | C |
| 上轴承外端 | UP_BRG_Z1 | +223.6 | C |
| 上支承轴→φ105 Boss肩面 | Z_TOP_JOURNAL_PILOT_SHOULDER_CAD | +226.9 | C+ |
| BODY—STEM_COVER安装面 | Z_BODY_TOP_IF_CAD | +264.5 | C |
| 前盖外侧粗参考 | Z_TOP_COVER_OUTER_REF_CAD | +300.0 | C/H-guide |
| 填料压紧/Adapter底参考 | Z_PACK_PRESS_FACE_CAD | +313.3 | C |
| F25接口面 | Z_F25_INTERFACE_CAD | +337.3 | C |
| 键起点 | Z_KEY_START_CAD | +339.8 | C |
| 键终点 | Z_KEY_END_CAD | +429.8 | C |
| 阀杆顶部CAD参考 | Z_STEM_TOP_CAD | +430.0 | C |

关键纠错：

```text
+227 作为BODY上安装面  → H/R
-230 作为BODY下安装面  → H/R
```

当前：

```text
+226.9 = 上支承轴→φ105定位Boss肩面
-230.0 = 下支承轴→φ70定位Boss肩面
+264.5 = 真正BODY上安装面CAD
-270.5 = 真正BODY下安装面CAD
```

---

# 6. 球体 BALL 当前总账

| 中文工程名称 | Variable | 当前值 | 状态 |
|---|---|---:|---|
| 球体外径 | BALL_OD | φ465 | C |
| 球体半径 | BALL_R | 232.5 | B |
| 球体X向总宽 | BALL_W_X | 348 | C |
| 流道 | BORE_D | φ303 | A |
| 上球孔 | BALL_UPPER_BORE_D | φ105 | C+ |
| 上孔总深CAD | BALL_UPPER_BORE_DEPTH | 30 | C-CAD；制造最终待闭合 |
| 下球孔 | BALL_LOWER_BORE_D | φ70 | C+ |
| 下孔有效支承圆柱段 | BALL_LOWER_BORE_EFFECTIVE_L | 50 | C+ |
| 下孔总深CAD | BALL_LOWER_BORE_DEPTH | 52 | C-CAD；不是制造冻结 |
| 驱动槽X向长 | BALL_DRIVE_SLOT_L_X | 70 | C-CAD |
| 驱动槽Y向宽 | BALL_DRIVE_SLOT_W_Y | 44 | C-CAD |
| 驱动槽根圆角 | BALL_DRIVE_SLOT_R | R8 | C-CAD |
| 驱动槽深 | BALL_DRIVE_SLOT_DEPTH | 27 | C-CAD |

几何校核：

```text
(BALL_OD - BORE_D)/2 = (465-303)/2 = 81 mm
```

`81` 是几何空间，不是净承压壁厚。

---

# 7. 阀座 SEAT 当前总账

```text
SEAT_D9=323.88
SEAT_D10=327.13
SEAT_D11=342
SEAT_GUIDE_BORE=342.4
SEAT_PILOT_2=323.6
SEAT_GUIDE_2=323.8

SEAT_ORING_MAIN=φ320×5.3
SEAT_ORING_MAIN_ROOT≈φ333.6
SEAT_ORING_2=φ311×3.55

SPRING=φ8×φ1.6×18×7
SPRING_QTY=36/侧
SPRING_H_INST≈15.6
SPRING_PCD=362

SEAT_BIG_OD=380
SEAT_BIG_BORE=382
WSEAT_ENV≈58 C-space
```

真实密封接触：

```text
X_CONTACT_L=-166.036
X_CONTACT_R=+166.036
```

当前主阀座链能用于CAD；DEVLON最终热配合、石墨槽、第二O圈最终功能位置、自泄压动作/公差仍有制造冻结门。

---

# 8. 上球体主支承 / STEM_COVER

```text
UP_BRG = φ105×φ100×30
UP_JOURNAL_D = 100
UP_BRG_Z0 = 193.6
UP_BRG_Z1 = 223.6
UP_BRG_CENTER_Z = 208.6
```

正确承载链：

```text
BALL φ105孔
↓
φ105×φ100×30轴承
↓
STEM_COVER一体φ100支承轴
↓
φ105定位Boss
↓
BODY
```

BODY上安装链：

```text
Z_TOP_SHOULDER = 226.9
TOP_PILOT_ENGAGEMENT_CAD = 37.6
Z_BODY_TOP_IF_CAD = 226.9 + 37.6 = 264.5
```

STEM_COVER当前：

```text
TOP_PILOT_D=105
TOP_COVER_FLANGE_T_CAD≈35.5
TOP_IF_ORING=φ95×5.3
TOP_IF_ORING_ROOT_D=96.6 C+
TOP_IF_GASKET=φ115×φ105×3.2
TOP_BODY_SCREW=4×M12×75 C+
TOP_ADAPTER_SCREW=4×M12×50 C+
```

上接口最终BCD/OD、最终配合公差仍 `D`。

---

# 9. 下球体主支承 / BOTTOM_COVER

```text
LOWER_BRG = φ70×φ65×50
LOWER_JOURNAL_D = 65
LOWER_BRG_Z_IN = -177
LOWER_BRG_Z_OUT = -227
LOWER_BRG_CENTER_Z = -202
```

正确承载链：

```text
BALL φ70孔
↓
φ70×φ65×50轴承
↓
BOTTOM_COVER一体φ65支承轴
↓
φ70定位Boss
↓
BODY
```

BODY下安装链：

```text
Z_BOTTOM_SHOULDER = -230
BOTTOM_PILOT_ENGAGEMENT_CAD = 40.5
Z_BODY_BOTTOM_IF_CAD = -230 - 40.5 = -270.5
```

BOTTOM_COVER当前：

```text
BOTTOM_PILOT_D=70
BOTTOM_COVER_FLANGE_T_CAD≈20
BOTTOM_IF_ORING=φ58×5.3 AED
BOTTOM_IF_ORING_ROOT_D_CAD=61.6 C/R
BOTTOM_IF_GASKET=φ80×φ70×3.2
BOTTOM_STUD=6×M12×55
```

底部AED O圈厂家最终拉伸/压缩/挤出间隙、最终BCD/OD仍未冻结。

---

# 10. 支承载荷总账

```text
F_SUPPORT = 164.692 kN     B/C工程包络
R_UP      = 81.037 kN      B/C
R_LOW     = 83.655 kN      B/C
```

轴承平均面压需求：

```text
UP ≈ 27.01 MPa
LOW≈ 25.74 MPa
```

316+PTFE真实牌号与允许面压仍 `D`。

---

# 11. 阀杆 / 键 / 驱动链

```text
STEM_MAIN_D≈65 C+
STEM_KEY_D=60 C
STEM_SHOULDER_OD≈74 C+
KEY=18×11×90 C/C+
T_DESIGN_DRIVE=1800 N·m
```

按单键承担100% 1800N·m：

```text
F_t≈60.0 kN
τ_key≈37.04 MPa
σ_key≈121.21 MPa
```

当前：

```text
Z_KEY_START_CAD≈339.8
Z_KEY_END_CAD≈429.8
Z_STEM_TOP_CAD≈430
```

最终键槽Kt、实际装键数量、阀杆总长仍需制造冻结。

---

# 12. BODY / BODY_COVER当前主骨架

主壳体拓扑：

```text
BODY         = 主阀体 ×1
BODY_COVER   = 侧装主阀盖/连接体 ×1
STEM_COVER   = 上前盖
BOTTOM_COVER = 下支承底盖
BODY_JOINT_COUNT = 1
```

唯一主分界：

```text
X_BODY_JOINT_CAD=+232.5 C+
X_BODY_JOINT_FINAL=? D
```

中央功能/承压包络：

```text
BODY_CAVITY_D_FUNC_CAD≈471 P-XREF/CAD
BODY_OUTER_D_CENTRAL_CAD≈504 C
```

主拆装口：

```text
MAIN_OPENING_D=480 C+
BODY female pilot=φ480 H8
BODY_COVER male pilot=φ480 f8
MAIN_COVER_PILOT_L_CAD=20 C
BALL through clearance=(480-465)/2=7.5mm/侧 B
```

主开口压力Boss：

```text
MAIN_OPENING_BOSS_OD_CAD≈520 C
```

---

# 13. 主BODY joint密封 / 中法兰

主O圈：

```text
BODY_JOINT_ORING=φ466×7
MODE=RADIAL_STATIC_EXTERNAL_GROOVE
GROOVE_DEPTH=5.7
GROOVE_W=9.5
GROOVE_ROOT_D=468.6
ID_STRETCH≈0.56%
NOM_RADIAL_SQUEEZE≈18.57%
```

缠绕垫：

```text
MID_GASKET=φ500×φ490×3.2
```

中法兰：

```text
MID_STUD_QTY=20
MID_STUD=M20×85
MID_BCD_CAD≈526.5
MID_FLANGE_OD_CAD≈562.5
```

历史禁止项：

```text
φ450主止口          H/R
φ466×7端面O圈       H/R
M24主中法兰方案      H/R
```

---

# 14. NPS12 Class150 RF端法兰

```text
END_FLANGE_OD=482.6 A/STD
END_FLANGE_BCD=431.8 A/STD
END_FLANGE_HOLE_QTY=12 A/STD
END_FLANGE_HOLE_D=25.4 A/STD
END_RF_OD=381.0 A/STD
END_FLANGE_BODY_T_CAD=30.2 C/STD-reference
END_RF_H_CAD=1.6 C
```

端法兰背面站位：

```text
X_END_FLANGE_BACK_L_CAD≈-273.2
X_END_FLANGE_BACK_R_CAD≈+273.2
```

历史 `RF OD≈355.6` → `H/R`。

---

# 15. F25 / ADAPTER 当前总账

```text
ADAPTER_OD_CAD=300 C
ADAPTER_T_CAD=24 C
Z_ADAPTER_BOTTOM_CAD=313.3 C
Z_F25_INTERFACE_CAD=337.3 C

F25_BOLT_PCD=254
F25_BOLT_QTY=8
F25_THREAD_D=16
F25_CLEAR_HOLE_D=17.5
F25_THREAD_DEPTH_MIN=24
F25_HOLE_START_ANGLE=22.5°
F25_HOLE_STEP=45°
```

厂家蜗轮箱正式输入接口未关闭前：

```text
F25 = 当前CAD主方案
≠ 最终采购接口冻结
```

---

# 16. 核心装配关系表

| Mate ID | 装配关系 | 当前规则 |
|---|---|---|
| M001 | BALL中心 ↔ O | 球心固定O，流道X，支承Z |
| M002/M003 | 左右SEAT ↔ BALL | 在 `X=±166.036` 真实球面接触 |
| M004/M005 | 左右SEAT导向 | 同轴X，保留规定轴向浮动 |
| M006 | φ342 ↔ φ342.4 | 阀座主导向 |
| M007 | φ323.6 ↔ φ323.8 | 第二导向候选 |
| M008 | φ380 ↔ φ382 | 阀座大端导向 |
| M009 | BALL φ105 ↔ 上轴承OD105 | 上主支承 |
| M010 | 上轴承ID100 ↔ STEM_COVER φ100轴 | 上主支承 |
| M011 | STEM φ65 ↔ 阀杆导向轴承ID65 | 阀杆导向 |
| M012 | 导向轴承OD70 ↔ STEM_COVER φ70孔 | 阀杆导向 |
| M013 | BALL φ70 ↔ 下轴承OD70 | 下主支承 |
| M014 | 下轴承ID65 ↔ BOTTOM_COVER φ65轴 | 下主支承 |
| M015 | STEM_COVER φ105 Boss ↔ BODY上接口 | Z≈+264.5 CAD |
| M016 | BOTTOM_COVER φ70 Boss ↔ BODY下接口 | Z≈-270.5 CAD |
| M017A | BODY φ480 H8 ↔ BODY_COVER φ480 f8 | 同轴间隙定位 |
| M017B | BODY ↔ BODY_COVER分界端面 | X=+232.5 CAD |
| M017C | φ466×7 O圈 ↔ φ480孔/凸止口 | 径向静密封 |
| M017D | φ500×φ490缠绕垫 | 主中法兰端面密封 |
| M017E | 20×M20×85 | BODY锚固 + COVER通孔 + 螺母夹紧 |
| M018 | ADAPTER/F25 ↔ STEM_COVER/STEM | Z≈337.3接口 |

禁止使用随机 `Face1/Edge7` 作为长期自动装配身份。

---

# 17. SolidWorks允许进入当前参数文件的范围

允许进入 CAD 草模/Skeleton：

```text
A
A-policy（按规则）
B
C+
C
明确批准的C-space / CAD envelope
```

禁止自动写死：

```text
D
H
H/R
未关闭R
```

当前仍不应作为制造冻结自动参数的典型项：

```text
T_DESIGN
P_RATING_ALLOWED
X_BODY_JOINT_FINAL
BODY最终壁厚/铸造外形
上下接口最终公差/BCD/OD
DEVLON最终热配合
底部AED O圈最终厂家槽
316+PTFE真实许用面压
GEARBOX真实接口
STEM_TOTAL_LEN_FINAL
```

---

# 18. 当前 GlobalVariables 与本账的关系

唯一当前参数源：

[Q347F_12in_Class150_00_SKELETON_GlobalVariables_V1.txt](./Q347F_12in_Class150_00_SKELETON_GlobalVariables_V1.txt)

它是**CAD执行输入**，不是完整工程计算书。

原则：

```text
计算主线
↓
本数字总账
↓
GlobalVariables
↓
SolidWorks
```

禁止从 SolidWorks 模型反向抄一个尺寸后，未经工程依据就把它提升为本账的 A/B/C+ 值。

---

# 19. S03实机“as-built”结果

当前真正运行通过：

```text
S00 ENVIRONMENT = PASS
S01 PARAMETERS  = PASS
S02 SOLIDWORKS  = PASS
S03 SKELETON    = PASS
```

S03验证：

```text
BALL_CENTER_O=(0,0,0) created
AXIS_X_FLOW created
AXIS_Z_SUPPORT created

X station planes = 11 / 11 world-coordinate readback PASS
Z station planes = 16 / 16 world-coordinate readback PASS

RefPlaneCount = 33
RefAxisCount  = 2

ForceRebuild = PASS
Feature errors = 0
What's Wrong errors = 0
warnings = 0

00_SKELETON.SLDPRT published
```

当前输出：

```text
SolidWorks_AutoBuild_Q347F_12in/02_output/00_SKELETON.SLDPRT
```

---

# 20. S03过程中发现的问题，对本账的影响

已证明属于软件/CAD实现问题而**不是设计参数重算**的问题：

```text
PowerShell Parser变量冒号
CMD中文编码
SW安装路径发现
Interop DLL运行时装载
System.__ComObject强类型边界
EquationMgr Add2/Add3与角度表达
SolidWorks原生基准面映射
RefPlane坐标回读方法
staging / publish / resume
```

因此没有依据因为这些API问题去推翻：

```text
F2F=610
BORE=303
BALL=465
BALL_R=232.5
X_BODY_JOINT_CAD=232.5
Z_BODY_TOP_IF_CAD=264.5
Z_BODY_BOTTOM_IF_CAD=-270.5
F25_PCD=254
```

需要修正的是**文档版本、参数身份和软件映射规则**。

---

# 21. 当前历史纠错总表

| 历史值/解释 | 当前处理 |
|---|---|
| 上主轴承 `φ70×φ65×50` | H/R；真实上球体主轴承为 `φ105×φ100×30` |
| 独立下支承轴 | H/R；当前底盖一体 `φ65` 支承轴 |
| 左右各一只主阀盖 | H/R；当前 `BODY + BODY_COVER` 两片式，一个主分界 |
| 主中法兰 M24 | H/R；当前 20×M20×85 |
| RF OD≈φ355.6 | H/R；当前 φ381 |
| 主止口φ450 | H/R；球体φ465无法通过，当前φ480 |
| φ466×7端面O圈 | H/R；当前φ480止口外圆径向静密封 |
| BODY中央外包络φ498.2作为当前默认 | H；当前CAD≈φ504 |
| `+227`=BODY上安装面 | H/R；当前肩面≈+226.9，安装面≈+264.5 |
| `-230`=BODY下安装面 | H/R；当前肩面=-230，安装面≈-270.5 |
| Front=XZ / Top=XY / Right=YZ永久硬绑定 | H/R；S03按世界几何识别原生平面 |

---

# 22. 当前制造冻结门

仍需关闭：

```text
T_DESIGN
P_RATING_ALLOWED
2.00MPa最终项目合规口径
DEVLON最终牌号/热配合
VITON最终牌号/硬度/AED要求
X-750热处理/许用应力
316+PTFE许用面压
BALL上下孔最终总深/驱动槽最终强度公差
BODY/BODY_COVER最终壁厚/铸造圆角
φ480 H8/f8最终公差叠加
主中法兰最终预紧/局部弯曲/FEA
上/下Boss最终配合公差
上/下盖最终BCD/OD
底部AED O圈厂家最终槽
蜗轮箱真实输入接口
阀杆最终总长/键槽Kt/实际装键数量
```

这些可以不阻塞当前 CAD 草模，但会阻塞制造冻结。

---

# 23. 当前下一步

唯一下一阶段：

```text
S04 BALL
↓
01_BALL.SLDPRT
↓
验证：φ465 / φ303 / 宽348 / φ105 / φ70 / 驱动槽
↓
关键尺寸世界几何回读
↓
ForceRebuild
↓
What's Wrong / Feature errors
↓
保存 / 日志 / PASS
```

S04未实机PASS前，不宣布球体自动建模完成。
# Q347F 12寸 Class150 固定球阀——设计计算主线（当前统一版）

> **设计对象**：Q347F / NPS12 / DN300 / Class150 / 固定球 / 两片式 / Side Entry（侧装式）/ 全通径 φ303 / 天然气。  
> **当前文档主线**：设计专题已推进到 **V43**；SolidWorks 自动化已经实机完成 **S00～S03 PASS**，`00_SKELETON.SLDPRT` 已生成并通过坐标回读、Rebuild、What's Wrong 校验。  
> **本文件定位**：只负责回答“**为什么这样设计、公式怎么算、数字从哪里来、最后为什么取这个值**”。“现在到底是多少、在哪里、和谁装”的唯一结果账见：[数字化总装骨架总账](./Q347F_12in_Class150_数字化总装骨架_尺寸参数_装配关系_空间坐标总账.md)。  
> **历史说明**：本文件此前的 V1～V12 超长母版仍保存在 Git 历史中；当前版不再把 V12 写成“当前有效版本”。早期专题页仍保留，冲突时以 **本文件 + 当前数字总账 + V42/V43 + 实机 S03 结果** 为准。

[← 总导航](./00_Q347F_12in_Class150_文档导航_从这里开始.md)  
[→ 当前数字总账](./Q347F_12in_Class150_数字化总装骨架_尺寸参数_装配关系_空间坐标总账.md)  
[→ V42 SolidWorks变量交付](./Q347F_12in_Class150_第7L步_SolidWorks全局变量交付版_当前CAD_D门与HR隔离_V42.md)  
[→ V43 Skeleton规则](./Q347F_12in_Class150_第7M步_SolidWorks_Skeleton手工稳定建模顺序_宏自动化边界_V43.md)

---

# 0. 唯一设计链

本项目以后固定按下面顺序理解：

```text
项目输入 / 正式标准 / 公司设计规则
        ↓
工程计算：公式 + 输入 + 代入 + 结果
        ↓
工程选值：为什么取这个尺寸
        ↓
参数状态：A / B / C / C+ / D / R / H-R
        ↓
尺寸参数 + 装配关系 + 空间坐标总账
        ↓
SolidWorks GlobalVariables
        ↓
00_SKELETON.SLDPRT
        ↓
BALL → SEAT → BODY → BODY_COVER → Z向零件 → ADAPTER
        ↓
SLDASM / Rebuild / What's Wrong / 干涉 / 运动 / 公差
        ↓
制造冻结
```

**永久原则：SolidWorks 不负责发明尺寸。**  
SolidWorks 只把已有工程依据的参数实体化，并用几何回读、重建、干涉等方式反校核设计。

---

# 1. 参数状态统一规则

| 状态 | 含义 | CAD草模 | 制造冻结 |
|---|---|---|---|
| `A` | 项目/BOM/受控规范明确输入 | 可 | 仍看项目批准状态 |
| `A-policy` | 公司方法/规则明确，具体制造值仍待闭合 | 可按规则使用 | 不一定 |
| `B` | 由已接受输入直接公式计算 | 可 | 前置输入冻结后可 |
| `C+` | 多条独立证据交叉支持的设计候选 | 可 | 仍需冻结门 |
| `C` | 有依据的设计/CAD候选 | 可 | 否 |
| `C-space` | 只为保持空间链不断的包络候选 | 可做包络 | 否 |
| `P / P-XREF` | 临时代用、跨规格参考、敏感性值 | 仅参考 | 否 |
| `D` | 前置条件不足 | **禁止自动填死** | 否 |
| `R / R-D` | 风险或合规门未关闭 | 视情况 | 否 |
| `H` | 历史值 | 否 | 否 |
| `H/R` | 已纠正、当前禁止继续使用 | **禁止** | **禁止** |

以后任何关键数字都必须同时具备：

```text
字段名
当前值
单位
状态
来源
公式/选值逻辑
CAD用途
制造冻结条件
```

---

# 2. 项目统一输入——先把“输入”和“计算”分开

| 项目 | 当前值 | 状态 | 说明 |
|---|---:|---|---|
| 公称尺寸 | NPS12 / DN300 | A | 项目输入 |
| 压力等级 | Class150 | A | 项目输入 |
| 结构 | 固定球 / trunnion-mounted | A | 项目输入 |
| 主壳体 | 两片式 / two-piece | A/C+ | 当前结构闭合 |
| 装入形式 | Side Entry / 侧装式 | A/C+ | 当前主线 |
| 流道 | φ303 | A | 全通径控制尺寸 |
| 介质 | 天然气 | A | 项目输入 |
| 机械载荷计算压力 `P_LOAD_CALC` | 2.00 MPa | A | 当前机械设计统一输入 |
| 阀体 | ASTM A216 WCB | A | 当前统一材料 |
| 球体 | ASTM A182 F316 | A | 当前统一材料 |
| 阀杆 | ASTM A182 F51 | A | 当前统一材料 |
| 阀座软密封 | DEVLON | A | 完整牌号仍待最终关闭 |
| O形圈 | VITON | A | 具体牌号/硬度/AED能力按位置关闭 |

## 2.1 压力必须永久拆成两条线

机械计算使用：

```text
P_LOAD_CALC = 2.00 MPa
```

标准压力—温度额定必须单独求：

```text
P_RATING_ALLOWED = f(CLASS, MATERIAL, T_DESIGN)
```

当前：

```text
T_DESIGN = ?                  D/R
P_RATING_ALLOWED = ?          D
```

因此现在**不能**把下面两句话画等号：

```text
机械计算压力 = 2.00 MPa
Class150/WCB在所有设计温度下标准允许压力 = 2.00 MPa
```

早期资料出现的 `-46～200℃` 当前统一为 `H/R`，不能自动回写成12寸正式设计温度。

---

# 3. 依据优先级

```text
客户 / 项目正式输入
    ↓
公司受控设计规范 / 公司计算程序
    ↓
API / ASME / GB 等正式标准
    ↓
受控历史计算书
    ↓
人工复算
    ↓
12寸BOM / 已确认采购件
    ↓
20寸成熟结构：只做拓扑、功能关系、无量纲/系列参考
    ↓
旧BOM / 旧尺寸：只做交叉检查
```

**20寸制造尺寸不得直接缩放成12寸制造尺寸。**

---

# 4. 第1步——流道

当前：

```text
BORE_D = 303 mm     A
```

它不是 SolidWorks 算出来的，而是项目全通径控制输入。

控制链：

```text
BORE_D
  ↓
BALL流道
  ↓
SEAT通径/密封副
  ↓
BODY / BODY_COVER流道
```

---

# 5. 第2步——球体

## 5.1 球体外径

公司球体优选逻辑当前采用：

```text
NPS12
+ F316
+ Class ≤ 300
↓
BALL_OD = 465 mm
```

所以：

```text
BALL_OD = 465 mm     C
```

它不是“20寸同比缩小”得到，也不是从 SolidWorks 量出来的。

## 5.2 球体半径

公式：

```text
BALL_R = BALL_OD / 2
       = 465 / 2
       = 232.5 mm
```

得到：

```text
BALL_R = 232.5 mm     B
```

## 5.3 球体与流道的径向几何空间

公式：

```text
T_GEOM_RAD = (BALL_OD - BORE_D) / 2
           = (465 - 303) / 2
           = 81 mm
```

注意：

> `81 mm` 只是球面外径与流道之间的**几何空间**，不是球体承压净壁厚。上孔、下孔、流道、驱动槽都会削弱真实截面。

## 5.4 球体X向总宽

当前设计候选：

```text
BALL_W_X = 348 mm     C
```

因此：

```text
BALL_HALF_W = 348 / 2 = 174 mm
BALL_X_L = -174
BALL_X_R = +174
```

`±174` 是由已接受的 `348` 直接计算出来的几何站位，状态 `B/C`。

## 5.5 S04 BALL当前CAD候选接口

当前参数文件中已有：

```text
BALL_UPPER_BORE_D       = 105 mm
BALL_UPPER_BORE_DEPTH   = 30 mm
BALL_LOWER_BORE_D       = 70 mm
BALL_LOWER_BORE_DEPTH   = 52 mm
BALL_DRIVE_SLOT_L_X     = 70 mm
BALL_DRIVE_SLOT_W_Y     = 44 mm
BALL_DRIVE_SLOT_R       = 8 mm
BALL_DRIVE_SLOT_DEPTH   = 27 mm
```

统一解释：

```text
φ105 / φ70孔径                  = 当前结构主链，C/C+
上孔30深                        = S04 CAD候选，C；制造最终深度仍需球体图闭合
下孔有效支承圆柱段 ≥50          = 由轴承L50得到的几何下限，B/C+
下孔总深52                      = S04 CAD候选，C-CAD；不得写成“制造冻结”
70×44、R8、深27驱动槽           = 当前S04草模候选，C-CAD
```

所以 S04 可以用这些值建参数化球体，但 **S04 PASS ≠ 球体制造图冻结**。

---

# 6. 第3步——阀座密封副

详细计算入口：

- [D9 / D10 / D11 详细计算与修正](./Q347F_12in_Class150_第3步阀座密封副_D9_D10_D11_详细计算与修正记录.md)
- [O形圈 / K1-K4 / DEVLON截面](./Q347F_12in_Class150_第3步阀座_O形圈_K1-K4_DEVLON截面_V1详细计算.md)
- [V3 真实接触带 / 第二O圈 / 弹簧 / Wseat](./Q347F_12in_Class150_第3D步_真实密封接触带_第二O圈_防火面_弹簧_Wseat_V3.md)
- [V4 D11台阶 / 弹簧PCD / 大端外径](./Q347F_12in_Class150_第3E步_D11原生台阶映射_弹簧PCD_大端外径_V4.md)
- [V5 轴向尺寸链](./Q347F_12in_Class150_第3F步_阀座轴向尺寸链_DEVLON保持_第二O圈_弹簧安装高度_Wseat_V5.md)
- [V6 制造冻结校核](./Q347F_12in_Class150_第3G步_制造冻结校核_O形圈_DEVLON热配合_弹簧_轴向链_V6.md)
- [V7 DEVLON代用规则](./Q347F_12in_Class150_第3H步_DEVLON代用牌号_V7继续设计规则.md)
- [V8 阀座冻结门](./Q347F_12in_Class150_第3I步_第3点5步阀座制造冻结门_V8.md)

## 6.1 当前密封接触主结果

```text
SEAT_D9  = 323.88 mm
SEAT_D10 = 327.13 mm
SEAT_D11 = 342.00 mm
```

统一解释：

```text
D9/D10 = 真实软密封接触带控制直径
D11    = 当前主静压/导向外径候选
```

禁止把：

```text
D10 = DEVLON物理外径
```

简单画等号。

## 6.2 预紧力

当前真实接触投影面积：

```text
A_SEAL ≈ 1658.59 mm²
```

公司当前预紧比压：

```text
q_pre = 2.5 MPa
```

所以每侧总预紧：

```text
Q2 = q_pre × A_SEAL
   ≈ 2.5 × 1658.59
   ≈ 4146.5 N
   ≈ 4.15 kN / side
```

36只弹簧/侧：

```text
F_spring_target = Q2 / 36
                ≈ 115.2 N / spring
```

## 6.3 弹簧几何

当前：

```text
Do = 8 mm
d  = 1.6 mm
H0 = 18 mm
Nt = 7
Dm = Do - d = 6.4 mm
C  = Dm / d = 4
```

项目当前近似：

```text
Na ≈ 5
G  ≈ 77.2 GPa   P/C
```

圆柱压缩弹簧刚度近似：

```text
k = G d^4 / (8 Dm^3 Na)
  ≈ 48.25 N/mm
```

所以：

```text
δ ≈ 115.2 / 48.25 ≈ 2.39 mm
H_install ≈ 18 - 2.39 ≈ 15.61 mm
```

当前草模：

```text
SPRING_H_INST ≈ 15.6 mm     B/C
```

X-750热处理/最终许用应力仍为 `D/R`，所以不能因为几何能装就宣布弹簧最终合格。

## 6.4 主阀座O圈

当前：

```text
O-ring = φ320 × 5.3
导向外径 D11 = 342
阀盖导向孔 = 342.4
静槽深 = 4.2
槽宽 = 7.0
槽根OD = 342 - 2×4.2 = 333.6
```

ID安装拉伸：

```text
S = (333.6 - 320) / 320
  ≈ 4.25%
```

拉伸后截面修正后，当前有效压缩约：

```text
≈14.43%
```

20寸成熟结构同算法约：

```text
≈14.23%
```

因此主阀座O圈链属于当前较强的 `C+` 几何链，但最终 VITON 牌号/硬度/公差叠加仍要关闭。

## 6.5 当前阀座主包络

```text
SEAT_GUIDE_BORE = 342.4
SEAT_PILOT_2    = 323.6
SEAT_GUIDE_2    = 323.8
SPRING_PCD      = 362
SEAT_BIG_OD     = 380
SEAT_BIG_BORE   = 382
WSEAT_ENV       ≈58     C-space
```

真实密封接触X站：

```text
X_CONTACT_L = -166.036
X_CONTACT_R = +166.036
```

禁止用球体平端 `±174` 替代真实密封接触站位。

---

# 7. 第4步——球体压力载荷、上下支承、轴承

详细推导：

- [V9 球体压力载荷 / 支承 / 阀杆 / 轴承](./Q347F_12in_Class150_第4A步_球体压力载荷_上下主支承_阀杆_滑动轴承_V9.md)
- [V11 20寸原生支承证据与12寸坐标骨架](./Q347F_12in_Class150_第4C步_20寸原生支承_阀杆轴向证据_12寸V11坐标骨架.md)
- [V15 上下主支承身份纠错](./Q347F_12in_Class150_第4G步_上下主支承身份纠错_反力中心与CAD坐标闭合_V15.md)

## 7.1 基础压力面积公式

```text
A = π D² / 4
F = P × A
```

例如只按流道 `D=303`、`P=2MPa` 的基础投影量：

```text
F303 = 2 × π × 303² / 4
     ≈ 144.2 kN
```

当前支承设计采用更保守的工程包络有效径：

```text
D_eff = 323.8 mm     C
```

所以：

```text
F_SUPPORT
= 2 × π × 323.8² / 4
≈ 164.692 kN
```

注意：这是当前工程支承载荷包络，不应误写成某一正式标准的唯一“球阀推力公式”。

## 7.2 上下反力分配

当前反力中心：

```text
a = 上支承臂 ≈ 208.566 mm
b = 下支承臂 ≈ 202.039 mm
```

静力平衡：

```text
R_up  = F × b / (a+b)
R_low = F × a / (a+b)
```

当前结果：

```text
R_up  ≈ 81.037 kN
R_low ≈ 83.655 kN
```

## 7.3 轴承平均面压需求

上主轴承：

```text
φ105 × φ100 × 30
投影承载面积近似 = 100 × 30 = 3000 mm²
p_up ≈ 81.037kN / 3000
     ≈ 27.01 MPa
```

下主轴承：

```text
φ70 × φ65 × 50
投影承载面积近似 = 65 × 50 = 3250 mm²
p_low ≈ 83.655kN / 3250
      ≈ 25.74 MPa
```

316+PTFE真实牌号及允许面压仍为 `D`，所以当前只能说“需求约27.01/25.74MPa”，不能说最终材料已经通过。

---

# 8. 第5步——阀杆 / 键传扭

当前驱动设计扭矩：

```text
T_DESIGN_DRIVE = 1800 N·m
```

当前键轴：

```text
d = 60 mm
Key = 18 × 11 × 90
```

按**单键承担100%扭矩**：

切向力：

```text
F_t = 2T / d
    = 2 × 1,800,000 / 60
    = 60,000 N
```

键剪应力：

```text
τ_key = F_t / (bL)
      = 60000 / (18×90)
      ≈ 37.04 MPa
```

键挤压简化：

```text
σ_key = F_t / ((h/2)×L)
      = 60000 / (5.5×90)
      ≈ 121.21 MPa
```

当前设计原则：

> 不依赖“双键50/50均载”才能通过；至少按一键承担全部1800 N·m完成第一轮校核。

当前：

```text
STEM_MAIN_D ≈65
STEM_KEY_D  ≈60
KEY         =18×11×90
STEM_SHOULDER_OD≈74
```

最终键槽根部应力集中、温度许用、实际装键数量仍需制造冻结阶段关闭。

---

# 9. 第6步——内部包络 → BODY / BODY_COVER

设计逻辑不是“先画阀体外形”，而是：

```text
BALL
+ 左右SEAT
+ 上下支承
+ 装拆路径
+ 密封/紧固空间
↓
内部功能包络
↓
承压壳体
```

当前功能球腔显示：

```text
BODY_CAVITY_D_FUNC_CAD ≈ 471 mm     P-XREF/CAD
```

当前中央承压外包络：

```text
BODY_OUTER_D_CENTRAL_CAD ≈ 504 mm   C
```

`φ471` 是内部功能/显示口径，`φ504` 是当前CAD外承压包络候选，性质不同，禁止混为一个“阀体直径”。

---

# 10. F2F与X向尺寸链

项目锁定：

```text
VALVE_F2F = 610 mm     A
```

所以：

```text
HALF_F2F = 610 / 2 = 305 mm     B
X_END_FACE_L = -305
X_END_FACE_R = +305
```

当前唯一主BODY分界：

```text
X_BODY_JOINT_CAD = +232.5 mm     C+
```

虽然数值恰好等于 `BALL_R=232.5`，但**不能**写成：

```text
X_BODY_JOINT = BALL_R    ← 禁止把数值巧合当设计公式
```

真实来源是：

```text
球体装拆通过
+ BODY/BODY_COVER拓扑
+ 中法兰/止口
+ 端法兰与内部过渡轴向链
↓
当前选值 +232.5
```

---

# 11. 主拆装口 / φ480止口

球体：

```text
BALL_OD = 465
```

当前主拆装口：

```text
MAIN_OPENING_D = 480     C+
```

通过余量：

```text
CLEAR_RAD
= (480 - 465) / 2
= 7.5 mm / side
```

这是 S01 自动几何检查的正式依据之一：

```text
MAIN_OPENING_D > BALL_OD
```

定位关系：

```text
BODY孔：φ480 H8
BODY_COVER凸止口：φ480 f8
止口CAD长度：20
```

最终配合公差表版本/制造公差仍要在冻结门关闭。

---

# 12. 主BODY joint O形圈

当前：

```text
O-ring = φ466 × 7
模式 = BODY_COVER φ480凸止口外圆径向静密封
槽深 = 5.7
槽宽 = 9.5
```

槽根直径：

```text
D_root = 480 - 2×5.7
       = 468.6 mm
```

ID拉伸：

```text
S = (468.6 - 466) / 466
  ≈ 0.56%
```

名义径向压缩：

```text
ε = (7 - 5.7) / 7
  ≈ 18.57%
```

历史：

```text
φ450主止口                 H/R
φ466×7端面O圈              H/R
端面槽φ463.5～φ482.5       H/R
```

这些值禁止重新进入当前模型。

---

# 13. 主中法兰 / 垫片 / M20

当前：

```text
缠绕垫 = φ500 × φ490 × 3.2
MID_BCD_CAD ≈ 526.5
MID_FLANGE_OD_CAD ≈ 562.5
20 × M20 × 85
```

当前BCD公司经验筛选链：

```text
BCD ≈ gasket_OD + bolt_hole_D + 3～6
    ≈ 500 + 22 + 3～6
    ≈ 525～528
```

因此取：

```text
MID_BCD_CAD = 526.5 mm     C
```

这仍属于当前CAD设计闭合值，不是因为SolidWorks需要圆周阵列就随意填的数字。

V20～V29 的 B16.34 壁厚/主中法兰面积与截面模量计算属于**初步筛查**；最终仍需按锁定标准版次、材料温度许用和真实截面复核，不能把PRELIM PASS等同制造冻结。

---

# 14. 端法兰当前标准骨架

当前 NPS12 Class150 RF：

```text
END_FLANGE_OD       = 482.6
END_FLANGE_BCD      = 431.8
END_FLANGE_HOLE_QTY = 12
END_FLANGE_HOLE_D   = 25.4
END_RF_OD           = 381.0
```

历史：

```text
RF OD = 355.6     H/R
```

端法兰背面CAD站位：

```text
END_FLANGE_BODY_T_CAD = 30.2
END_RF_H_CAD          = 1.6
END_FACE_TO_BACK      = 31.8

X_BACK_R = 305 - 31.8 = 273.2
X_BACK_L = -305 + 31.8 = -273.2
```

---

# 15. Z向上支承尺寸链

球心：

```text
O = Z0 = 0
```

上球体主轴承：

```text
φ105 × φ100 × 30
Z = 193.6 ～ 223.6
中心 Z = 208.6
```

前盖一体支承轴：

```text
φ100
```

轴 → φ105定位Boss肩面：

```text
Z_TOP_SHOULDER = +226.9
```

BODY安装面：

```text
Z_BODY_TOP_IF_CAD = +264.5     C
```

所以当前有效Boss轴向长度：

```text
L_TOP_PILOT
= 264.5 - 226.9
= 37.6 mm
```

历史纠错：

```text
+227 = BODY上安装面     H/R
```

当前正确身份是：

```text
+226.9 ≈ 上支承轴 → φ105定位Boss肩面
```

---

# 16. Z向下支承尺寸链

下主轴承：

```text
φ70 × φ65 × 50
Z = -227 ～ -177
中心 Z = -202
```

底盖一体支承轴：

```text
φ65
```

轴 → φ70定位Boss肩面：

```text
Z_BOTTOM_SHOULDER = -230
```

BODY安装面：

```text
Z_BODY_BOTTOM_IF_CAD = -270.5     C
```

当前有效Boss长度：

```text
L_BOTTOM_PILOT
= |-270.5 - (-230)|
= 40.5 mm
```

历史纠错：

```text
-230 = BODY下安装面     H/R
```

当前正确身份是下支承轴到 φ70 Boss 的肩面。

---

# 17. F25 / ADAPTER / 阀杆顶部

当前CAD主方案：

```text
ADAPTER_OD_CAD        = 300
ADAPTER_T_CAD         = 24
Z_ADAPTER_BOTTOM_CAD  = 313.3
Z_F25_INTERFACE_CAD   = 337.3
F25_BOLT_PCD          = 254
F25_BOLT_QTY          = 8
F25_THREAD_D          = 16
F25_HOLE_START_ANGLE  = 22.5°
F25_HOLE_STEP         = 45°
```

键：

```text
KEY = 18×11×90
Z_KEY_START_CAD ≈ 339.8
Z_KEY_END_CAD   ≈ 429.8
Z_STEM_TOP_CAD  ≈ 430
```

厂家真实蜗轮箱输入接口未关闭前，F25/φ300/24厚等仍属于当前CAD主方案，不等于采购冻结。

---

# 18. 当前完整XYZ站位——计算结果如何进入几何

## X站位

```text
-305
-273.2
-232.5
-174
-166.036
0
+166.036
+174
+232.5
+273.2
+305
```

## Z站位

```text
-289.1
-270.5
-230
-227
-177
0
+193.6
+223.6
+226.9
+264.5
+300
+313.3
+337.3
+339.8
+429.8
+430
```

其中：

```text
±305        ← F2F/2
±174        ← BALL_W_X/2
±166.036    ← 真实密封接触位置
+232.5      ← 当前主BODY分界C+
+264.5      ← 上BODY安装面C
-270.5      ← 下BODY安装面C
+337.3      ← F25接口面C
+430        ← 当前阀杆顶部CAD参考C
```

---

# 19. SolidWorks坐标纠错——S03实机已经证明

项目语义坐标永久固定：

```text
O = BALL_CENTER_O
X = FLOW_AXIS
Y = CROSS_AXIS
Z = SUPPORT_AXIS / STEM_AXIS
```

但禁止再写成：

```text
Front = XZ
Top   = XY
Right = YZ
```

作为软件原生名称的永久硬绑定。

原因：SolidWorks 模板/语言/原生基准面对象不能靠名称或枚举顺序安全推断项目坐标含义。

当前自动化正确规则：

```text
读取原生参考面的真实世界几何
↓
判断其法向/恒定坐标
↓
识别XY / XZ / YZ
↓
再建立项目自己的命名基准
```

项目长期只认：

```text
PLN_BASE_XY_FLOW_CROSS
PLN_BASE_XZ_FLOW_SUPPORT
PLN_BASE_YZ_CROSS_SUPPORT
AXIS_X_FLOW
AXIS_Z_SUPPORT
SK_PT_BALL_CENTER_O
```

S03 已实机验证：

```text
X站位 = 11个全部世界坐标回读PASS
Z站位 = 16个全部世界坐标回读PASS
RefPlaneCount = 33
RefAxisCount = 2
Rebuild = PASS
What's Wrong errors = 0
warnings = 0
```

因此这次自动化故障属于 **CAD/API坐标实现纠错**，并不构成推翻 `F2F=610、BORE=303、BALL=465、Z=+264.5/-270.5` 等工程设计参数的依据。

---

# 20. 详细专题页——当前完整演进

## 阀座 V1～V8

- [V1 O形圈/K1-K4/DEVLON](./Q347F_12in_Class150_第3步阀座_O形圈_K1-K4_DEVLON截面_V1详细计算.md)
- [V2 20寸原生阀座核对](./Q347F_12in_Class150_第3C步_20寸原生SolidWorks阀座结构核对与12寸V2.md)
- [V3 真实接触带/第二O圈/弹簧/Wseat](./Q347F_12in_Class150_第3D步_真实密封接触带_第二O圈_防火面_弹簧_Wseat_V3.md)
- [V4 D11/弹簧PCD/大端外径](./Q347F_12in_Class150_第3E步_D11原生台阶映射_弹簧PCD_大端外径_V4.md)
- [V5 阀座轴向尺寸链](./Q347F_12in_Class150_第3F步_阀座轴向尺寸链_DEVLON保持_第二O圈_弹簧安装高度_Wseat_V5.md)
- [V6 制造冻结校核](./Q347F_12in_Class150_第3G步_制造冻结校核_O形圈_DEVLON热配合_弹簧_轴向链_V6.md)
- [V7 DEVLON代用规则](./Q347F_12in_Class150_第3H步_DEVLON代用牌号_V7继续设计规则.md)
- [V8 阀座制造冻结门](./Q347F_12in_Class150_第3I步_第3点5步阀座制造冻结门_V8.md)

## 支承/阀杆 V9～V15

- [V9 压力载荷/支承/阀杆/轴承](./Q347F_12in_Class150_第4A步_球体压力载荷_上下主支承_阀杆_滑动轴承_V9.md)
- [V10 阀杆完整分段/防吹出链](./Q347F_12in_Class150_第4B步_阀杆完整分段_前盖内外接口_防吹出链_V10.md)
- [V11 20寸原生支承证据与12寸坐标](./Q347F_12in_Class150_第4C步_20寸原生支承_阀杆轴向证据_12寸V11坐标骨架.md)
- [V12 12寸前盖/底盖草模链](./Q347F_12in_Class150_第4D步_12寸前盖_底盖制造草模尺寸链_V12.md)
- [V13 20寸前盖底盖原生坐标核对](./Q347F_12in_Class150_第4E步_20寸前盖底盖原生SolidWorks结构坐标核对_V13.md)
- [V14 共同坐标/球心与支承关闭](./Q347F_12in_Class150_第4F步_20寸总装共同坐标_球心与上下支承关闭_V14.md)
- [V15 上下主支承身份纠错](./Q347F_12in_Class150_第4G步_上下主支承身份纠错_反力中心与CAD坐标闭合_V15.md)

## 内部包络/主壳体 V16～V31

- [V16 内部整体空间包络](./Q347F_12in_Class150_第5A步_内部整体空间_球体阀座上下支承统一包络_V16.md)
- [V17 阀体中腔间隙/下球孔纠错](./Q347F_12in_Class150_第5B步_阀体中腔间隙_公司规则分层_下球孔纠错_V17.md)
- [V18 阀体阀盖参数化接口/XYZ](./Q347F_12in_Class150_第5C步_阀体阀盖参数化接口_中法兰与XYZ骨架_V18.md)
- [V19 F2F 610关闭](./Q347F_12in_Class150_第5D步_API6D侧装式结构长度_610与838口径关闭_V19.md)
- [V20 B16.34壁厚/压力等级风险](./Q347F_12in_Class150_第6A步_ASME_B16_34阀体最小壁厚_压力等级风险_承压外壳_V20.md)
- [V21 两片式主壳体/中法兰](./Q347F_12in_Class150_第6B步_两片式主壳体纠错_中法兰垫片_M20螺柱_B16_34校核_V21.md)
- [V22 X_BODY_JOINT与610闭合](./Q347F_12in_Class150_第6C步_BODY_BODY_COVER轴向分界_X_BODY_JOINT与610闭合_V22.md)
- [V23 主中法兰螺柱/VENT-DRAIN](./Q347F_12in_Class150_第6D步_主中法兰螺柱轴向预算_VENT_DRAIN接口Boss_V23.md)
- [V24 旧主中法兰O圈/止口历史页](./Q347F_12in_Class150_第6E步_主中法兰端面O圈_缠绕垫_H8f8止口_V24.md) — **其中φ450/端面O圈已H/R**
- [V25 M20锚固/截面模量](./Q347F_12in_Class150_第6F步_M20锚固_体盖夹持厚度_止口长度_截面模量_V25.md)
- [V26 BODY_COVER轴向剖面/RF纠错](./Q347F_12in_Class150_第6G步_BODY_COVER完整轴向剖面_端法兰RF纠错_内锥过渡_V26.md)
- [V27 BODY_COVER承压颈](./Q347F_12in_Class150_第6H步_BODY_COVER外承压颈_局部壁厚_法兰环分层_V27.md)
- [V28 φ480拆装口/径向O圈纠错](./Q347F_12in_Class150_第6I步_主拆装口校核_φ480_H8f8止口_φ466x7径向O圈纠错_V28.md)
- [V29 BODY完整承压骨架](./Q347F_12in_Class150_第6J步_BODY完整承压骨架_φ471局部壁厚纠错_左端到主开口_V29.md)
- [V30 总装干涉预检查](./Q347F_12in_Class150_第6K步_BODY_BODY_COVER_BALL_SEAT总装干涉预检查_V30.md)
- [V31 第一版SolidWorks建模尺寸表](./Q347F_12in_Class150_第7A步_BODY_BODY_COVER第一版SolidWorks建模尺寸表_V31.md)

## 上下接口/驱动/SolidWorks V32～V43

- [V32 上下Z接口第一轮](./Q347F_12in_Class150_第7B步_上前盖底盖绝对Z接口_M12紧固组与安装面闭合_V32.md) — **+227/-230作为安装面已H/R**
- [V33 上下盖载荷路径](./Q347F_12in_Class150_第7C步_上下盖载荷路径_M12连接筛查_定位Boss承载门_V33.md)
- [V34 真正上下BODY安装面纠错](./Q347F_12in_Class150_第7D步_上下安装面纠错_支承轴肩与定位Boss有效长度_V34.md)
- [V35 完整Z纵剖面/M12长度反校核](./Q347F_12in_Class150_第7E步_上下盖完整Z向纵剖面_M12长度反校核_V35.md)
- [V36 底部AED O圈门](./Q347F_12in_Class150_第7F步_底部φ58x5点3_AED_O圈拉伸_有效压缩与Boss配合门_V36.md)
- [V37 ISO5211 F25 / 1800Nm接口](./Q347F_12in_Class150_第7G步_连接盘_ISO5211_F25_8xM16与1800Nm驱动接口_V37.md)
- [V38 φ60阀杆/18×11×90单键](./Q347F_12in_Class150_第7H步_φ60阀杆_18x11x90单键传扭_键槽净截面_V38.md)
- [V39 F25 8×M16反力矩/M16×65](./Q347F_12in_Class150_第7I步_F25连接盘_8xM16反力矩_M16x65轴向闭合_V39.md)
- [V40 连接盘Z/F25接口/键轴站位](./Q347F_12in_Class150_第7J步_连接盘Z坐标_F25接口面_M12x50与键轴站位_V40.md)
- [V41 完整XYZ总装骨架](./Q347F_12in_Class150_第7K步_完整总装骨架_XYZ包络_装配与维修路径预检查_V41.md)
- [V42 SolidWorks全局变量交付](./Q347F_12in_Class150_第7L步_SolidWorks全局变量交付版_当前CAD_D门与HR隔离_V42.md)
- [V43 Skeleton稳定建模规则](./Q347F_12in_Class150_第7M步_SolidWorks_Skeleton手工稳定建模顺序_宏自动化边界_V43.md)

---

# 21. 当前制造冻结门

当前仍不能因为 Skeleton 已生成就自动关闭：

```text
T_DESIGN
P_RATING_ALLOWED(CLASS, MATERIAL, T_DESIGN)
2.00MPa最终项目合规口径
DEVLON最终完整牌号及热配合
VITON各位置最终牌号/硬度/AED要求
X-750实际材料状态/热处理/允许应力
316+PTFE轴承真实牌号/许用面压
BALL上下孔最终总加工深度
BALL驱动槽最终制造公差/根部强度
BODY / BODY_COVER最终制造壁厚与铸造圆角
φ480 H8/f8最终公差版次与总叠加
主O圈最终挤出间隙
主中法兰最终预紧/局部弯曲/FEA
上下Boss最终配合公差
上/下盖最终BCD/OD
底部AED O圈最终厂家槽
蜗轮箱真实输入接口
阀杆最终总长/键槽Kt/实际装键数量
```

这些不阻塞当前参数化CAD继续，但会阻塞“制造冻结”。

---

# 22. 当前自动化状态与下一步

实机已完成：

```text
S00 ENVIRONMENT   PASS
S01 PARAMETERS    PASS
S02 SOLIDWORKS    PASS
S03 SKELETON      PASS
```

S03证据：

```text
11个X站位世界坐标回读 PASS
16个Z站位世界坐标回读 PASS
RefPlaneCount=33
RefAxisCount=2
Feature errors=0
What's Wrong errors=0
warnings=0
00_SKELETON.SLDPRT published
```

下一步唯一实施目标：

```text
S04 BALL
↓
生成 01_BALL.SLDPRT
↓
关键尺寸回读
↓
Rebuild / What's Wrong
↓
S04 PASS 后再进入 S05 SEAT
```

**一句话结论**：当前计算参数没有因为 S03 的 SolidWorks API/坐标问题而被整体推翻；需要修正的是文档版本、参数身份、SolidWorks原生平面映射和“CAD候选 ≠ 制造冻结”的边界。
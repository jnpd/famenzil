# Q347F 12寸 Class150——第6A步：ASME B16.34 阀体最小壁厚 / 压力等级风险 / 承压外壳 V20

> **定位**：V19已经关闭结构形式与F2F：本项目为两片式、枢轴固定、侧装式，API 6D长型RF结构长度610mm。V20开始把第5步的“内部功能包络”外面真正围成第一版承压边界。  
> **本页只关闭到承压骨架级**：ASME B16.34最小壁厚、公司附加壁厚、中央外包络以及压力等级风险。铸造圆角、局部Boss、中法兰最终尺寸、加工余量仍后续关闭。  
> **特别提醒**：当前设计计算输入 `2.00 MPa` 与 A216 WCB / Class150 在常温段的标准额定压力 `1.96 MPa` 存在0.04MPa差异，本页将其正式列为高优先级风险，不再把两者混写成同一个概念。

[← 总导航](./00_Q347F_12in_Class150_文档导航_从这里开始.md)  
[← 数字化总装骨架总账](./Q347F_12in_Class150_数字化总装骨架_尺寸参数_装配关系_空间坐标总账.md)  
[← V19 API 6D侧装式结构长度](./Q347F_12in_Class150_第5D步_API6D侧装式结构长度_610与838口径关闭_V19.md)

---

# 1. 第6A步先把“壁厚”和“压力等级”拆开

这两个概念不能混：

```text
最小壁厚 tm
= ASME B16.34 对某压力等级、某内径范围的结构最小壁厚要求

压力-温度额定值
= 某材料在某Class、某温度下允许的最大工作压力
```

因此：

> **即使壁厚做得更厚，也不能自动把 Class150 / WCB 的压力-温度额定值从1.96MPa改成2.00MPa。**

厚壁解决的是局部承压结构下限；Class额定值仍必须由B16.34压力-温度表控制。

---

# 2. ASME B16.34 Class150最小壁厚公式

对于 Class150 且：

```text
100 < d ≤ 1300 mm
```

Mandatory Appendix VI 的SI公式：

```text
tm = 0.0163 d + 4.70
```

并按：

```text
0.1 mm
```

圆整。

本项目中央主流道：

```text
d = 303 mm
```

代入：

```text
tm
= 0.0163×303 + 4.70
= 9.6389 mm
```

圆整：

```text
T_B1634 = 9.6 mm
```

状态：

```text
B / STD
```

说明：

- 这里把 `d=303` 作为中央流道/承压边界第一轮控制内径；
- 后续局部区域若实际有效内径更大，要按局部更大的 `d_local` 再复核；
- `9.6` 是标准最小壁厚基线，不是公司最终设计壁厚。

---

# 3. 公司固定球阀规则：标准最小值上再加3～5mm

公司 `GFE-JS01-2025` 当前规则：

```text
阀体最小壁厚查 ASME B16.34
并适当增加 3~5 mm
如果标准查不到，则按 ASME VIII-1 UG-27
```

所以：

```text
T_BODY_TARGET
= T_B1634 + BODY_WALL_ADD
```

其中：

```text
T_B1634 = 9.6 mm
BODY_WALL_ADD = 3~5 mm
```

得到：

```text
T_BODY_TARGET = 12.6~14.6 mm
```

第一轮CAD默认中值：

```text
BODY_WALL_ADD_CAD = 4.0 mm
T_BODY_CAD = 13.6 mm
```

状态分层：

| 参数 | 当前值 | 状态 |
|---|---:|---|
| `T_B1634` | 9.6 | B/STD |
| `BODY_WALL_ADD_MIN` | 3 | A-policy |
| `BODY_WALL_ADD_MAX` | 5 | A-policy |
| `T_BODY_MIN_GUIDE` | 12.6 | B/C |
| `T_BODY_CAD` | 13.6 | C |
| `T_BODY_MAX_GUIDE` | 14.6 | B/C |
| `T_BODY_FINAL` | ? | D |

这里的 `13.6` 只用于第一版参数化承压外壳，不等于加工图最终最薄壁厚。

---

# 4. 把V17三档球腔与壁厚组合成中央BODY外包络

V17当前球体—阀体功能中腔三档：

```text
CLR_1P5 → BODY_CAVITY_D = 468
CLR_3P0 → BODY_CAVITY_D = 471
CLR_6P0 → BODY_CAVITY_D = 477
```

定义中央等效外包络：

```text
BODY_OUTER_D_CENTRAL_GUIDE
= BODY_CAVITY_D_FUNC + 2*T_BODY
```

## 4.1 紧凑下限场景

```text
BODY_CAVITY_D = 468
T_BODY = 12.6

BODY_OUTER_D
= 468 + 2×12.6
= 493.2 mm
```

## 4.2 当前默认CAD场景

```text
BODY_CAVITY_D = 471
T_BODY = 13.6

BODY_OUTER_D
= 471 + 27.2
= 498.2 mm
```

## 4.3 宽松上限筛查场景

```text
BODY_CAVITY_D = 477
T_BODY = 14.6

BODY_OUTER_D
= 477 + 29.2
= 506.2 mm
```

所以中央区可以先建立三个承压外包络配置：

| 配置 | 中腔功能直径 | 壁厚 | 中央外包络 | 状态 |
|---|---:|---:|---:|---|
| `BODY_LOW` | 468 | 12.6 | 493.2 | P/C |
| `BODY_MID` | 471 | 13.6 | 498.2 | **C 默认草模** |
| `BODY_HIGH` | 477 | 14.6 | 506.2 | P/C |

**注意：这些都只是中央承压区等效包络，不是整个阀体最大外径。**

左右中法兰、上前盖Boss、底盖Boss、VENT/DRAIN凸台都会局部超过这个直径。

---

# 5. 为什么不能把φ498.2直接画成最终阀体

实际WCB阀体至少还包括：

```text
中央球腔承压壳
+
左右流道颈
+
左右中法兰连接区
+
上前盖安装Boss
+
底盖安装Boss
+
VENT / DRAIN / 注脂凸台
+
铸造圆角
+
局部加工余量
```

因此：

```text
φ498.2
```

只能作为：

```text
SURF_BODY_CENTRAL_OUTER_GUIDE
```

而不是：

```text
BODY_FINAL_OD
```

SolidWorks策略：

```text
先建中央承压Guide Surface
↓
再长左右颈部Boss
↓
再长上/下接口Boss
↓
再加中法兰
↓
最后做圆角融合
```

---

# 6. 局部壁厚必须按局部内径复核

B16.34的 `tm` 不是“全阀任何地方永远都取9.6”。

如果某局部承压腔有效内径：

```text
d_local > 303
```

则应重新计算：

```text
T_B1634_LOCAL
= 0.0163*d_local + 4.70
```

例如第5步阀座大端座腔：

```text
COVER_BIG_BORE = 382 mm
```

如果该 `φ382` 的某一段确实属于阀体/阀盖直接承压边界控制直径，则：

```text
tm382
=0.0163×382+4.70
=10.9266
≈10.9 mm
```

公司附加3~5后：

```text
T_LOCAL_382 ≈13.9~15.9 mm
```

因此V20新增规则：

> **中央流道区9.6mm只是第一层；阀座大腔、上/下接口和局部大孔必须按各自控制内径再检查，最终取更不利值。**

---

# 7. 第一版“局部壁厚检查表”

| 区域 | 当前控制内径 | B16.34最小壁厚 | 公司+3~5后 | 状态 |
|---|---:|---:|---:|---|
| 中央流道基线 | 303 | 9.6 | 12.6~14.6 | B/C |
| 阀座大端若直接承压 | 382 | 10.9 | 13.9~15.9 | C/R需确认边界归属 |
| 上接口φ105 | 105 | 6.4 | 9.4~11.4 | 仅局部参考，不替代整体过渡强度 |
| 下接口φ70 | 70 | 5.9 | 8.9~10.9 | 仅局部参考 |

说明：

- 上/下接口真正承压肉厚还受轴承载荷、螺栓夹紧、圆角应力集中控制；
- 不能仅按B16.34最低公式就宣布合格；
- 阀座φ382到底属于阀体还是阀盖的直接压力边界，需要第6B接口剖面关闭。

---

# 8. 高优先级风险：2.00 MPa 与 Class150 / WCB额定压力

ASME B16.34 Group 1.1 中包含：

```text
ASTM A216 WCB
```

Class150在低温到常温段约：

```text
-29~38°C → 19.6 bar
          → 1.96 MPa
```

当前项目计算基线：

```text
P_DESIGN_CALC = 2.00 MPa
```

差值：

```text
ΔP = 2.00 - 1.96
   = 0.04 MPa
   = 0.4 bar
```

相对1.96：

```text
约 +2.04%
```

因此新增：

```text
R20-01 = HIGH
```

风险定义：

> **必须确认当前“2 MPa”到底是用于设计载荷计算的工程圆整值，还是客户数据单要求的精确设计压力。**

如果它只是：

```text
Class150常温1.96MPa → 工程计算向上圆整成2.0MPa
```

那么继续用2.0计算支承/载荷是保守的，同时标准合规仍按1.96MPa压力-温度额定值声明。

如果项目真正要求：

```text
Design Pressure = 2.00 MPa exact
```

则不能直接宣布当前 `WCB + Class150` 已满足B16.34压力-温度额定要求，必须重新核对项目等级、特殊Class/材料/温度或客户规范。

---

# 9. 设计温度成为标准合规必填项

当前仓库主线尚未关闭本12寸项目的：

```text
T_DESIGN
```

这不能长期保持空白，因为WCB / Class150额定压力随温度升高会下降。

例如标准表显示：

```text
-29~38°C → 19.6 bar
50°C      → 约19.1~19.2 bar
100°C     → 17.7 bar
```

所以：

```text
RD_TEMP_01
T_DESIGN = ?   HIGH
```

制造冻结前必须来自：

```text
项目数据单
客户规格书
正式设计条件
```

V20不从20寸旧项目温度、其他阀门项目或历史资料偷填本12寸温度。

---

# 10. 当前如何同时保留“2.0MPa”和“1.96MPa”而不混乱

建议永久分成两个变量：

```text
P_LOAD_CALC = 2.00 MPa
```

用途：

```text
球体压力载荷
支承反力
阀杆/轴承保守机械计算
```

以及：

```text
P_RATING_ALLOWED = f(Class, Material, T_DESIGN)
```

当前常温参考：

```text
P_RATING_ALLOWED_38C = 1.96 MPa
```

用途：

```text
ASME B16.34压力-温度合规判定
```

最终增加检查量：

```text
RATING_MARGIN
= P_RATING_ALLOWED(T_DESIGN) - P_DESIGN_EXACT
```

目标：

```text
RATING_MARGIN >= 0
```

当前因为：

```text
P_DESIGN_EXACT = ?
T_DESIGN = ?
```

所以：

```text
RATING_MARGIN = D/R
```

---

# 11. 中法兰螺栓强度：先把公式骨架写清楚

公司规范要求中法兰螺栓按：

```text
ASME B16.34 6.4.2.1
```

校核。

变量：

```text
Ag = 以垫片外围为边界的面积
Pc = 压力等级相关设计压力参数
Ab = 全部螺栓有效抗拉面积
Sa = 螺栓许用应力
```

B16.34的体连接螺栓面积要求采用：

```text
Ag, Pc, Ab, Sa
```

关系进行校核。

因为当前项目尚未锁定：

```text
MID_GASKET_OD
MID_BOLT_SIZE
MID_BOLT_QTY
适用B16.34版本
```

V20只建立：

```text
MID_BOLT_AREA_TOTAL
= MID_BOLT_QTY * BOLT_TENSILE_AREA_ONE

MID_BODY_JOINT_CHECK
= per ASME B16.34 6.4.2.1
```

具体中法兰螺栓数量/规格留第6B，不用不完整公式伪造一个M值。

---

# 12. SolidWorks第6A新增变量

```text
# ========================
# B16.34 WALL
# ========================
D_WALL_BASE = 303
T_B1634 = 9.6

BODY_WALL_ADD_MIN = 3
BODY_WALL_ADD_CAD = 4
BODY_WALL_ADD_MAX = 5

T_BODY_MIN_GUIDE = 12.6
T_BODY_CAD = 13.6
T_BODY_MAX_GUIDE = 14.6
T_BODY_FINAL = ?

# local rule
T_B1634_LOCAL(d_local) = 0.0163*d_local + 4.70
T_BODY_LOCAL(d_local) = T_B1634_LOCAL(d_local) + BODY_WALL_ADD

# φ382 potential pressure boundary
T_B1634_D382 = 10.9
T_D382_MIN_GUIDE = 13.9
T_D382_MAX_GUIDE = 15.9

# ========================
# BODY CENTRAL ENVELOPE
# ========================
BODY_CAVITY_D_LOW = 468
BODY_CAVITY_D_MID = 471
BODY_CAVITY_D_HIGH = 477

BODY_OUTER_D_LOW_GUIDE = 493.2
BODY_OUTER_D_MID_GUIDE = 498.2
BODY_OUTER_D_HIGH_GUIDE = 506.2

BODY_OUTER_D_CENTRAL_CAD = 498.2

# ========================
# PRESSURE/RATING SPLIT
# ========================
P_LOAD_CALC = 2.00
P_RATING_ALLOWED_38C = 1.96
P_DESIGN_EXACT = ?
T_DESIGN = ?
RATING_MARGIN = P_RATING_ALLOWED(T_DESIGN) - P_DESIGN_EXACT

# ========================
# RISK
# ========================
R20_01_PRESSURE_CLASS = HIGH
RD_TEMP_01 = HIGH
```

---

# 13. V20后BODY第一版SolidWorks实体策略

现在可以建立：

```text
07_BODY_ENVELOPE.SLDPRT
```

第一版：

```text
中央内腔：
默认显示 φ471 P-XREF

中央外Guide：
φ498.2 C

左右端面：
X=±305 A/C+

左右体盖分界：
保持参数X=? D

上前盖接口：
径向链已知，安装面Z=? D

底盖接口：
径向链已知，安装面Z=? D
```

建模时建议中央外壁先使用：

```text
Surface / Envelope Body
```

而不是直接标加工公差。

---

# 14. 当前关闭项

| 项目 | V20状态 |
|---|---|
| Class150 / d303 的B16.34最小壁厚 | **9.6 mm，B/STD** |
| 公司附加壁厚 | **+3~5 mm，A-policy** |
| 中央设计壁厚带 | **12.6~14.6 mm，B/C** |
| 当前CAD壁厚 | **13.6 mm，C** |
| 中央BODY默认外包络 | **φ498.2，C** |
| φ382局部若承压的壁厚要求 | **13.9~15.9，C/R** |
| 2.00MPa机械载荷基线 | **继续保留** |
| 2.00MPa是否为精确项目设计压力 | **D/HIGH** |
| WCB Class150常温额定 | **1.96MPa，STD** |
| 本12寸设计温度 | **D/HIGH** |
| 中法兰螺栓规格/数量 | D |
| BODY最终铸造/加工壁厚 | D |

---

# 15. 下一步：第6B

```text
第6A完成
↓
第6B 左右体盖 / 中法兰承压接口
↓
确定中法兰垫片OD
↓
确定体盖接口面X
↓
按B16.34 6.4.2.1选螺栓总面积
↓
确定BCD / 中法兰OD
↓
把左右END COVER从Envelope升级到第一版实体
```

同时并行继续：

```text
上前盖安装面Z
底盖安装面Z
VENT / DRAIN NPT凸台
```

当前仍可以继续推进；只有到“标准合规冻结”时，必须补：

```text
本12寸项目确切设计温度
2.00MPa是否为精确项目设计压力
```

---

# 16. V20变更记录

## 2026-08-22

- 由ASME B16.34 Class150最小壁厚公式得到d303时tm=9.6mm；
- 按公司GFE-JS01增加3~5mm，建立12.6~14.6mm中央设计壁厚带；
- 选13.6mm作为第一版CAD承压骨架中值；
- 将V17三档球腔与壁厚组合，得到中央外包络φ493.2 / φ498.2 / φ506.2；
- 新增局部壁厚规则，不再把9.6mm错误套遍全阀；
- 对φ382潜在承压大腔计算B16.34最小壁厚约10.9mm，公司设计带约13.9~15.9mm；
- 正式拆分 `P_LOAD_CALC=2.00MPa` 与 `P_RATING_ALLOWED`；
- 发现WCB Class150常温额定1.96MPa与2.00MPa存在0.04MPa差异，建立R20-01高优先级风险；
- 将本12寸设计温度提升为制造冻结前必须关闭的HIGH开放项；
- 中法兰螺栓强度继续按B16.34 6.4.2.1参数化，不在缺垫片/螺栓规格时伪造尺寸。

# Q347F 12寸 Class150——第7A步：BODY / BODY_COVER 第一版 SolidWorks 建模尺寸表 V31

> **定位**：V30已经完成 BODY / BODY_COVER / BALL / SEAT 第一轮数字干涉预检查。V31不再继续推新理论，而是把当前有效参数整理成工程师可以直接照着建 `07_BODY.SLDPRT` 和 `08_BODY_COVER.SLDPRT` 的第一版尺寸/Feature清单。
>
> **使用规则**：A/B/C+/C参数可进入草模；`D`不允许写死进制造图。C-space/P-XREF只用于当前模型不断链。所有被V28/V29纠正的V24旧φ450/端面O圈方案禁止再使用。

[← 总导航](./00_Q347F_12in_Class150_文档导航_从这里开始.md)  
[← 数字化总账](./Q347F_12in_Class150_数字化总装骨架_尺寸参数_装配关系_空间坐标总账.md)  
[← V30干涉预检查](./Q347F_12in_Class150_第6K步_BODY_BODY_COVER_BALL_SEAT总装干涉预检查_V30.md)

---

# 1. 公共骨架参数

| 中文参数 | SolidWorks变量 | 当前值 | 状态 |
|---|---|---:|---|
| 球心 | `BALL_CENTER_O` | (0,0,0) | A |
| 流道轴 | `FLOW_AXIS` | X | A |
| 支承轴 | `SUPPORT_AXIS` | Z | A |
| 结构长度 | `VALVE_F2F` | 610 | A |
| 左RF面 | `X_END_FACE_L` | -305 | B/A |
| 右RF面 | `X_END_FACE_R` | +305 | B/A |
| 主分界面 | `X_BODY_JOINT_CAD` | +232.5 | C+ CAD |
| 主分界最终 | `X_BODY_JOINT_FINAL` | ? | D |
| 球体OD | `BALL_OD` | 465 | C |
| 全通径 | `BORE_D` | 303 | A |
| 阀座大端OD | `SEAT_BIG_OD` | 380 | C |
| 阀座大孔 | `SEAT_BIG_BORE` | 382 | C |

---

# 2. `07_BODY.SLDPRT` 第一版尺寸表

## 2.1 X向主结构

| 中文参数 | 变量 | 值 mm | 状态 |
|---|---|---:|---|
| BODY左RF面 | `X_BODY_LEFT_END` | -305 | B/A |
| BODY右主分界 | `X_BODY_RIGHT_JOINT` | +232.5 | C+ |
| BODY主长度 | `L_BODY_MAIN_CAD` | 537.5 | B/C+ |
| 左端法兰背面 | `X_LEFT_END_FLANGE_BACK_CAD` | -273.2 | B/C |
| 左φ303过渡端 | `X_LEFT_BORE_TAPER_END_CAD` | -272.0 | B/C |
| 左φ382座腔站 | `X_LEFT_BORE_TAPER_START_CAD` | -232.5 | C-space |
| 右φ480主孔内端 | `X_BODY_OPENING_INNER_CAD` | +212.5 | C |
| 右主分界 | `X_BODY_JOINT_CAD` | +232.5 | C+ |

## 2.2 左端NPS12 Class150 RF法兰

| 参数 | 变量 | 值 | 状态 |
|---|---|---:|---|
| 法兰OD | `END_FLANGE_OD` | φ482.6 | A/STD |
| BCD | `END_FLANGE_BCD` | φ431.8 | A/STD |
| 孔数 | `END_FLANGE_HOLE_QTY` | 12 | A/STD |
| 孔径 | `END_FLANGE_HOLE_D` | φ25.4 | A/STD |
| 配套螺栓 | `END_FLANGE_BOLT` | 7/8 in | A/STD |
| RF OD | `END_RF_OD` | **φ381.0** | A/STD |
| 法兰环本体最小厚参考 | `END_FLANGE_T_BASE_MIN` | 30.2 | A/STD-ref |
| RF高度CAD | `END_RF_H_CAD` | 1.6 | C |

历史：`RF≈φ355.6` → H/R。

## 2.3 左侧流道/座腔

```text
X=-305 ~ -272：φ303流道贯穿端法兰
X=-272 ~ -232.5：φ303→φ382，45°内锥CAD
X≈-232.5向球体侧：进入左阀座功能区
```

| 参数 | 变量 | 值 | 状态 |
|---|---|---:|---|
| 小端孔 | `BORE_D` | φ303 | A |
| 大端座腔 | `SEAT_BIG_BORE` | φ382 | C |
| 半径差 | `LEFT_BORE_TAPER_DR` | 39.5 | B |
| 内锥角 | `LEFT_BORE_TAPER_ANGLE_CAD` | 45° | C |
| 内锥轴长 | `LEFT_BORE_TAPER_L_CAD` | 39.5 | B/C |

## 2.4 中央球腔与外壳

| 参数 | 变量 | 值 | 状态 |
|---|---|---:|---|
| 球腔显示直径 | `BODY_CAVITY_D_FUNC` | φ471 | P-XREF/C-display |
| d471 B16.34最小壁厚 | `T_B1634_471` | 12.38 | B/STD-screen |
| 公司+4 CAD壁厚 | `T_BODY_471_CAD` | 16.38 | B/C |
| 中央外包络 | `BODY_OUTER_D_CENTRAL_CAD` | **φ504** | C |
| 最终中央外形 | `BODY_OUTER_D_CENTRAL_FINAL` | ? | D |

历史：`φ498.2` → H/C，下限参考，不再是当前默认。

## 2.5 右侧主拆装/定位孔

| 参数 | 变量 | 值 | 状态 |
|---|---|---:|---|
| 主拆装孔 | `MID_ASSEMBLY_OPENING_D_CAD` | φ480 | C+ |
| BODY孔公差 | `MID_PILOT_FEMALE_FIT` | H8 | A-policy |
| 球体通过径向余量 | `BALL_THROUGH_OPENING_CLEAR_RAD` | 7.5/侧 | B/C+ |
| 主孔局部B16.34 | `T_B1634_480` | 12.524 | B/STD-screen |
| 公司+4壁厚 | `T_BODY_480_CAD` | 16.524 | B/C |
| 压力Boss最低OD | `BODY_JOINT_PRESSURE_BOSS_OD_MIN` | φ513.05 | B/C |
| 压力Boss CAD | `BODY_JOINT_PRESSURE_BOSS_OD_CAD` | φ520 | C |

## 2.6 BODY主中法兰环

| 参数 | 变量 | 值 | 状态 |
|---|---|---:|---|
| 主中法兰OD | `MID_FLANGE_OD_CAD` | ≈φ562.5 | C |
| 主中法兰BCD | `MID_BCD_CAD` | φ526.5 | C |
| 锚固螺纹 | `MID_STUD_SIZE` | M20 | A/C+ |
| 锚固孔数量 | `MID_STUD_QTY` | 20 | A/C+ |
| 有效旋合CAD | `MID_STUD_ENGAGE_CAD` | 30 | C |
| 有效旋合最终 | `MID_STUD_ENGAGE_FINAL` | ? | D |
| 盲孔总深 | `MID_BODY_TAPPED_DEPTH_FINAL` | ? | D |
| 孔底剩余肉厚 | `MID_BODY_THREAD_BOTTOM_METAL_FINAL` | ? | D |

**BODY侧画的是 `20×M20螺纹锚固孔`，不是20×φ22通孔。**

---

# 3. `08_BODY_COVER.SLDPRT` 第一版尺寸表

## 3.1 总轴向站位

| 参数 | 变量 | 值 | 状态 |
|---|---|---:|---|
| 主分界面 | `X_BODY_JOINT_CAD` | +232.5 | C+ |
| RF端面 | `X_END_FACE_R` | +305 | B/A |
| 主壳体贡献长度 | `L_BODY_COVER_TOTAL_CAD` | 72.5 | B/C+ |
| 凸止口内端 | `X_MID_PILOT_TIP_CAD` | +212.5 | C |
| 零件实际X包络 | 212.5~305 | 92.5总包络 | B/C |
| 螺母支承面 | `X_MID_NUT_BEARING_CAD` | +261.5 | C |
| 内锥终点 | `X_BORE_TAPER_END_CAD` | +272.0 | B/C |
| 端法兰背面 | `X_END_FLANGE_BACK_CAD` | +273.2 | B/C |

说明：72.5是BODY_COVER对F2F的贡献；由于φ480凸止口向BODY内插20mm，零件几何包络实际延伸到X=212.5。

## 3.2 φ480 f8凸止口

| 参数 | 变量 | 值 | 状态 |
|---|---|---:|---|
| 凸止口OD | `MID_PILOT_D_CAD` | **φ480** | C+ |
| 公差 | `MID_PILOT_MALE_FIT` | f8 | A-policy |
| 插入长度 | `MID_PILOT_INSERT_L_CAD` | 20 | C |
| 最终插入长度 | `MID_PILOT_INSERT_L_FINAL` | ? | D |
| 前端导入段 | `MID_PILOT_LEAD_L_CAD` | 5.0 | C/A-policy |
| 槽后金属段 | `MID_PILOT_BACK_LAND_CAD` | 5.5 | C |

ISO286参考：

```text
BODY H8孔 ≈480.000~480.110
BODY_COVER f8 ≈479.814~479.924
直径间隙≈0.076~0.296
```

## 3.3 φ466×7径向静密封槽

| 参数 | 变量 | 值 | 状态 |
|---|---|---:|---|
| O圈 | `MID_ORING_ID × MID_ORING_CS` | φ466×7 | A/C+ |
| 模式 | `MID_ORING_MODE` | 外圆径向静密封 | C+ |
| 槽深 | `MID_ORING_GROOVE_DEPTH` | 5.7 | A-policy |
| 槽轴向宽 | `MID_ORING_GROOVE_AXIAL_W` | 9.5 | A-policy |
| 槽根径 | `MID_ORING_GROOVE_ROOT_D_CAD` | **φ468.6** | B/C+ |
| O圈ID拉伸 | `MID_ORING_ID_STRETCH_CAD` | ≈0.56% | B/C+ |
| 名义径向压缩 | `MID_ORING_RADIAL_SQUEEZE_NOM` | ≈18.57% | B |
| H8/f8影响后压缩参考 | `MID_ORING_SQUEEZE_FIT_REF` | ≈16.5~18.0% | B/C |

X位置：

```text
止口前端：X=212.5
导入段：212.5~217.5
O圈槽：217.5~227.0
槽中心：222.25
槽后金属段：227.0~232.5
```

## 3.4 外侧端面缠绕垫

| 参数 | 变量 | 值 | 状态 |
|---|---|---:|---|
| 垫片ID | `MID_GASKET_ID` | φ490 | A/C+ |
| 垫片OD | `MID_GASKET_OD` | φ500 | A/C+ |
| 自由厚 | `MID_GASKET_T_FREE` | 3.2 | A/C+ |
| 止口OD→垫片ID径向带 | `MID_LAND_PILOT_TO_GASKET_CAD` | 5.0 | B/C+ |

## 3.5 BODY_COVER主中法兰孔

| 参数 | 变量 | 值 | 状态 |
|---|---|---:|---|
| BCD | `MID_BCD_CAD` | φ526.5 | C |
| 通孔数量 | `MID_STUD_QTY` | 20 | A/C+ |
| 通孔CAD径 | `MID_BOLT_HOLE_D_CAD` | φ22 | C |
| 螺母/spotface CAD | `MID_SPOTFACE_D_CAD` | φ36 | C |
| 中法兰OD | `MID_FLANGE_OD_CAD` | φ562.5 | C |
| 有效夹持厚 | `MID_BODY_COVER_GRIP_CAD` | 29 | C |
| 最终夹持厚 | `MID_BODY_COVER_GRIP_FINAL` | ? | D |

**BODY_COVER侧是 `20×φ22通孔 + 外侧螺母支承面`，不是M20攻丝孔。**

## 3.6 内流道

```text
X=232.5：φ382
↓ 45°内锥 / L=39.5
X=272.0：φ303
↓ φ303直孔
X=305：RF端面
```

| 参数 | 变量 | 值 | 状态 |
|---|---|---:|---|
| 大端座孔 | `BODY_COVER_BORE_D0` | φ382 | C |
| 小端通径 | `BODY_COVER_BORE_D1` | φ303 | A |
| 内锥角 | `BODY_COVER_BORE_TAPER_ANGLE_CAD` | 45° | C |
| 内锥长 | `BODY_COVER_BORE_TAPER_L_CAD` | 39.5 | B/C |

## 3.7 外承压颈

V28已覆盖V27旧φ450起点：

```text
BODY_COVER_NECK_OD_JOINT_CAD=φ480 C+
```

端部Hub仍只用跨结构参考：

```text
END_HUB_OD_WN_REF≈φ365.3 P-XREF
```

第一版可草模放样：

```text
φ480 @ X232.5
→
约φ365.3 @ X273.2
```

实际铸造外轮廓最终D。

## 3.8 右端法兰

与BODY左端同源：

```text
ODφ482.6
BCDφ431.8
12×φ25.4
RF ODφ381.0
法兰本体厚参考30.2
RF高度CAD≈1.6
```

---

# 4. BODY与BODY_COVER装配Mate

```text
M017-A：BODY φ480 H8孔 ↔ BODY_COVER φ480 f8凸止口，同轴
M017-B：BODY主分界端面 ↔ BODY_COVER主分界端面
M017-C：φ466×7 O圈 ↔ BODY φ480孔，径向静压缩
M017-D：φ500×φ490缠绕垫 ↔ 两侧中法兰端面
M017-E：20×M20×85螺柱 ↔ BODY M20锚固孔
M017-F：螺柱穿过BODY_COVER φ22通孔，M20螺母外侧夹紧
```

当前H8/f8参考间隙：

```text
直径0.076~0.296mm
```

---

# 5. 第一版Feature顺序——BODY

建议 `07_BODY.SLDPRT`：

```text
F01  建X轴/YZ中心面
F02  建左φ303主流道
F03  建左φ303→φ382 45°座腔过渡
F04  建中央φ471球腔Guide/Cut
F05  建中央φ504外承压母体Guide
F06  建右φ480 H8主拆装孔，深至X=212.5
F07  建右φ520局部压力Boss
F08  叠加主中法兰环OD≈φ562.5
F09  20×M20螺纹锚固孔@BCD526.5（盲孔总深先参数D）
F10  建左端NPS12 Class150 RF法兰
F11  12×φ25.4端法兰孔
F12  建STEM_COVER上Boss占位
F13  建BOTTOM_COVER下Boss占位
F14  建VENT/DRAIN/注脂Boss占位
F15  最后加铸造圆角/融合
```

---

# 6. 第一版Feature顺序——BODY_COVER

建议 `08_BODY_COVER.SLDPRT`：

```text
F01  建X轴和PLN_BODY_JOINT_X
F02  建φ480 f8凸止口，向-X长20
F03  在凸止口外圆切φ466×7静密封槽：rootφ468.6，宽9.5
F04  建内部φ382→φ303 45°锥孔
F05  建外承压颈Guide
F06  叠加主中法兰环OD≈φ562.5
F07  建φ490~φ500缠绕垫端面座
F08  20×φ22通孔@BCD526.5
F09  外侧20×φ36 spotface/螺母支承区
F10  建NPS12 Class150右端法兰ODφ482.6
F11  12×φ25.4端法兰孔@BCD431.8
F12  建RFφ381
F13  最后做铸造圆角/外轮廓融合
```

---

# 7. 草模配置

建议建立：

```text
CFG_BODY_CAD_V1
CFG_BODY_COVER_CAD_V1
```

统一开启：

```text
X_BODY_JOINT_CAD=232.5
MID_PILOT_D_CAD=480
MID_PILOT_INSERT_L_CAD=20
MID_STUD_ENGAGE_CAD=30
MID_BODY_COVER_GRIP_CAD=29
BODY_OUTER_D_CENTRAL_CAD=504
```

所有D项用方程式变量保留问号/占位，不偷偷硬填制造值。

---

# 8. 当前禁止再使用的旧变量

```text
MID_PILOT_D_CAD=450                  H/R
MID_ORING_MODE=AXIAL_FACE_STATIC     H/R
MID_ORING_GROOVE_ID_CAD=463.5        H/R
MID_ORING_GROOVE_OD_CAD=482.5        H/R
BODY_OUTER_D_CENTRAL_CAD=498.2       H/C old
END_RF_OD=355.6                       H/R
MID_STUD_ENGAGE_CAD=20               H/C lower-bound only
MID_BODY_COVER_GRIP_CAD=39            H/C old
```

当前替换：

```text
MID_PILOT_D_CAD=480
MID_ORING_MODE=RADIAL_STATIC_EXTERNAL_GROOVE
MID_ORING_GROOVE_ROOT_D_CAD=468.6
BODY_OUTER_D_CENTRAL_CAD=504
END_RF_OD=381.0
MID_STUD_ENGAGE_CAD=30
MID_BODY_COVER_GRIP_CAD=29
```

---

# 9. V31一句话结论

> **现在已经可以正式开始画 `07_BODY.SLDPRT` 和 `08_BODY_COVER.SLDPRT` 第一版草模：BODY从X=-305到+232.5，左端标准RF法兰、φ303→φ382座腔、中央φ471/外φ504承压包络、右φ480 H8主拆装孔、φ520压力Boss和φ562.5主中法兰；BODY_COVER用φ480 f8×20凸止口，外圆切φ466×7径向静密封槽（rootφ468.6、宽9.5），外侧布φ490~φ500缠绕垫、20×φ22通孔@φ526.5，再以45°从φ382收至φ303并接NPS12 Class150端法兰。BODY侧是M20螺纹锚固孔，BODY_COVER侧才是φ22通孔，这个孔身份必须严格区分。**

---

# 10. 下一步 V32 / 第7B

```text
关闭上STEM_COVER / 下BOTTOM_COVER与BODY的绝对Z安装面
↓
把前盖/底盖从“轴承坐标链”变成“BODY真实加工接口”
↓
计算上/下Boss径向尺寸、BCD、螺栓圈
↓
形成完整07_BODY四向接口：左端 / 右主盖 / 上前盖 / 下底盖
```

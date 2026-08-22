# Q347F 12寸 Class150——第6G步：BODY_COVER完整轴向剖面 / 端法兰RF纠错 / 内锥过渡 V26

> **定位**：V22给出 `X_BODY_JOINT_CAD=+232.5`，V24建立主中法兰径向接口，V25建立M20×85轴向预算。V26用 NPS12 Class150 RF 端法兰标准尺寸反向约束 BODY_COVER 的72.5mm轴向空间，并纠正旧RF直径。
>
> **核心结论**：从主中法兰 `X=232.5` 到端法兰RF接触面 `X=305` 共72.5mm；其中从φ382座腔过渡到φ303流道，采用45°内锥恰需39.5mm，与端法兰背面位置高度吻合。这个独立几何闭合使 `X_BODY_JOINT_CAD=232.5` 从普通C候选升级为 `C+ CAD`，但仍不等于加工图最终值。

[← 总导航](./00_Q347F_12in_Class150_文档导航_从这里开始.md)  
[← 总账](./Q347F_12in_Class150_数字化总装骨架_尺寸参数_装配关系_空间坐标总账.md)  
[← V25](./Q347F_12in_Class150_第6F步_M20锚固_体盖夹持厚度_止口长度_截面模量_V25.md)

---

# 1. NPS12 Class150 RF端法兰尺寸重新核对

当前项目端连接：

```text
NPS12 / DN300
Class150
RF
ASME B16.5
```

可靠表值交叉确认：

```text
端法兰外径（END_FLANGE_OD）      = 19.00in = 482.6mm
端法兰BCD（END_FLANGE_BCD）      = 17.00in = 431.8mm
端法兰孔（END_FLANGE_HOLES）     = 12×1.00in = 12×φ25.4
配套螺栓（END_FLANGE_BOLT）      = 7/8in
RF外径（END_RF_OD）              = 15.00in = 381.0mm
```

因此旧账曾出现的：

```text
RF≈14.00in≈φ355.6
```

正式降为：

```text
H/R
```

当前：

```text
END_RF_OD=381.0 A/STD
```

---

# 2. 端法兰厚度必须区分“法兰环本体”和“RF凸台”

ASME B16.5 Class150 NPS12常用英制尺寸表：

```text
法兰环本体最小厚度 tf ≈1.19in≈30.2mm
```

Class150 RF凸台高度采用当前项目英制换算口径：

```text
RF_H_CAD≈1/16in≈1.6mm
```

因此以F2F的RF接触面作为：

```text
X_END_FACE_R=+305
```

第一版CAD从RF接触面到法兰背面的总轴向尺寸：

```text
END_FLANGE_AXIAL_TO_BACK_CAD
=30.2+1.6
=31.8mm
```

得到：

```text
X_END_FLANGE_BACK_CAD
=305-31.8
=273.2mm
```

状态：

```text
END_FLANGE_T_BASE_MIN=30.2 A/STD-reference
END_RF_H_CAD=1.6 C/STD-inch-convention
END_FLANGE_AXIAL_TO_BACK_CAD=31.8 B/C
X_END_FLANGE_BACK_CAD=273.2 B/C
```

正式制造图应按项目最终采用的ASME B16.5单位表/版次重新冻结RF高度和厚度口径。

---

# 3. BODY_COVER总轴向空间

当前：

```text
X_BODY_JOINT_CAD=232.5
X_END_FACE_R=305
```

所以：

```text
L_BODY_COVER_TOTAL_CAD
=305-232.5
=72.5mm
```

而主分界到端法兰背面：

```text
L_JOINT_TO_END_FLANGE_BACK_CAD
=273.2-232.5
=40.7mm
```

这40.7mm就是 BODY_COVER 在端法兰环前可用于：

```text
阀座大腔 → φ303流道收缩
主中法兰外圈/螺母区
内部承压过渡
外壳圆角/颈部
```

的共同轴向空间。

**这些功能位于不同半径，可以轴向重叠，不能全部串联相加。**

---

# 4. φ382座腔→φ303流道的45°内锥第一次闭合

主中法兰附近当前功能大孔：

```text
SEAT_BIG_BORE=382
```

端部全通径：

```text
BORE_D=303
```

半径差：

```text
ΔR
=(382-303)/2
=39.5mm
```

如果第一版采用45°内锥：

```text
L_TAPER_45=ΔR/tan45°
=39.5mm
```

从主分界向+X：

```text
X_BORE_TAPER_START_CAD=232.5
X_BORE_TAPER_END_CAD=232.5+39.5=272.0
```

而端法兰背面：

```text
X_END_FLANGE_BACK_CAD=273.2
```

只剩：

```text
L_TAPER_TO_FLANGE_BACK
=273.2-272.0
=1.2mm
```

随后φ303流道贯穿端法兰至RF面。

因此当前BODY_COVER内流道可以直接草模为：

```text
X=232.5：φ382
↓ 45°内锥 / L=39.5
X=272.0：φ303
↓ φ303直孔
X=305：RF端面
```

状态：

```text
BODY_COVER_BORE_TAPER_ANGLE_CAD=45° C
BODY_COVER_BORE_TAPER_L_CAD=39.5 B/C
X_BORE_TAPER_END_CAD=272.0 B/C
```

45°是CAD候选，不是标准强制角度。

---

# 5. 为什么这一轮让X_BODY_JOINT_CAD=232.5更可信

V22最初232.5来自：

```text
球体/阀座功能包络
+
610结构长度
```

V26完全从另一条链反算：

```text
NPS12 Class150端法兰厚度
+
φ382座腔
+
φ303全通径
+
紧凑45°内锥
```

却得到：

```text
主分界→法兰背面≈40.7
所需内锥≈39.5
```

只差约：

```text
1.2mm
```

因此：

```text
X_BODY_JOINT_CAD=232.5
```

从：

```text
C
```

升级为：

```text
C+ CAD
```

但：

```text
X_BODY_JOINT_FINAL=? D
```

继续保留，直到正式12寸剖面/工程图冻结。

---

# 6. V25的20mm锚固/39mm夹持要被V26重新优化

V25为了先让85mm螺柱闭合，取：

```text
MID_STUD_ENGAGE_CAD=20
MID_BODY_COVER_GRIP_CAD=39
```

20mm本质上只是约1d的下限参考。

V26加入端法兰背面：

```text
X_END_FLANGE_BACK_CAD=273.2
```

如果仍取39mm夹持：

```text
X_NUT_BEARING_FACE
=232.5+39
=271.5
```

则螺母支承面到端法兰背面只剩：

```text
273.2-271.5=1.7mm
```

对BODY_COVER外壳圆角/颈部过渡过于拥挤。

因此：

```text
V25的20mm锚固 = P-XREF下限，不再作为当前首选CAD值
V25的39mm夹持 = H/C候选，被V26优化
```

---

# 7. V26把锚固提高到1.5d≈30mm

M20：

```text
d=20
```

当前CAD设计候选取：

```text
MID_STUD_ENGAGE_CAD=30mm
=1.5d
```

状态：`C`。

它不是ASME/API强制1.5d，而是综合：

```text
API 6D约1d下限参考
+
85mm总长
+
BODY_COVER端法兰空间
+
铸钢BODY螺纹锚固稳健性
```

得到的当前工程候选。

V23总预算：

```text
anchor + grip ≈57.2~61.0
```

所以：

```text
MID_GRIP_MIN_CAD=57.2-30=27.2
MID_GRIP_MAX_CAD=61.0-30=31.0
```

中值：

```text
≈29.1mm
```

SolidWorks取：

```text
MID_BODY_COVER_GRIP_CAD=29mm C
```

对应螺母支承面：

```text
X_MID_NUT_BEARING_CAD
=232.5+29
=261.5mm
```

到端法兰背面剩：

```text
L_NECK_RESERVE_CAD
=273.2-261.5
=11.7mm
```

相比旧1.7mm明显合理。

---

# 8. 85mm螺柱重新闭合

当前典型中值链：

```text
BODY有效旋合       =30
BODY_COVER有效夹持 =29
M20螺母            ≈20
露牙                ≈6
----------------------
合计                ≈85mm
```

所以V26当前CAD链：

```text
MID_STUD_ENGAGE_CAD=30
MID_BODY_COVER_GRIP_CAD=29
MID_NUT_M_CAD≈20
MID_STUD_PROTRUSION_CAD≈6
```

状态全部为CAD候选，最终还需正式盲孔深度/材料螺纹强度/预紧计算。

---

# 9. 内锥和外侧中法兰可以轴向重叠

这是V26必须永久保留的建模原则。

在 `X=232.5~261.5`：

```text
内半径区：φ382→约φ324的流道内锥
外半径区：φ490~φ562.5中法兰密封/螺柱/螺母承载环
```

它们在同一X范围但处于不同半径，不冲突。

所以错误算法：

```text
中法兰厚29
+
内锥39.5
+
端法兰31.8
=100.3 >72.5
→ 判定放不下
```

是错误的。

正确理解：

```text
内锥39.5与中法兰29可以大量轴向重叠
端法兰区域又允许φ303流道继续贯穿
```

因此72.5mm完全可能闭合。

---

# 10. BODY_COVER第一版轴向剖面站位

```text
X=232.5  PLN_BODY_JOINT_X
          ├─ φ450 f8凸止口向-X插入12 C-space
          ├─ φ463.5~φ482.5 O圈槽
          ├─ φ490~φ500缠绕垫
          ├─ φ526.5 / 20×M20主螺栓圈
          └─ 内孔φ382

X≈261.5  MID_NUT_BEARING_FACE_CAD
          └─ BODY_COVER有效夹持≈29

X=272.0  内锥结束
          └─ 内孔进入φ303

X≈273.2  END_FLANGE_BACK_CAD
          └─ NPS12 Class150端法兰环开始

X=305.0  RF接触端面
          ├─ END_FLANGE_OD=φ482.6
          ├─ END_BCD=φ431.8
          ├─ 12×φ25.4
          └─ END_RF_OD=φ381.0
```

---

# 11. SolidWorks变量新增/修正

```text
# END FLANGE / 端法兰
END_FLANGE_OD=482.6
END_FLANGE_BCD=431.8
END_FLANGE_HOLE_D=25.4
END_FLANGE_HOLE_QTY=12
END_FLANGE_BOLT=7/8IN
END_RF_OD=381.0
END_FLANGE_T_BASE_MIN=30.2
END_RF_H_CAD=1.6
END_FLANGE_AXIAL_TO_BACK_CAD=31.8
X_END_FLANGE_BACK_CAD=273.2

# BODY COVER AXIAL / 主阀盖轴向
L_BODY_COVER_TOTAL_CAD=72.5
L_JOINT_TO_END_FLANGE_BACK_CAD=40.7
BODY_COVER_BORE_D0=382
BODY_COVER_BORE_D1=303
BODY_COVER_BORE_TAPER_ANGLE_CAD=45
BODY_COVER_BORE_TAPER_L_CAD=39.5
X_BORE_TAPER_START_CAD=232.5
X_BORE_TAPER_END_CAD=272.0

# STUD UPDATED / 螺柱当前优化
MID_STUD_ENGAGE_MIN_REF=20
MID_STUD_ENGAGE_CAD=30
MID_GRIP_MIN_CAD=27.2
MID_GRIP_MAX_CAD=31.0
MID_BODY_COVER_GRIP_CAD=29
X_MID_NUT_BEARING_CAD=261.5
L_NECK_RESERVE_CAD=11.7
```

---

# 12. 历史修正

```text
H/R END_RF_OD≈φ355.6 / 14.00in
→ 当前NPS12 Class150 RF = φ381.0 / 15.00in

H/C MID_STUD_ENGAGE_CAD=20
→ 20仅保留为约1d下限参考
→ 当前CAD优化值=30

H/C MID_BODY_COVER_GRIP_CAD=39
→ 当前CAD优化值=29
```

---

# 13. 当前状态

| 参数 | 当前值 | 状态 |
|---|---:|---|
| END_FLANGE_OD | φ482.6 | A/STD |
| END_FLANGE_BCD | φ431.8 | A/STD |
| 端法兰孔 | 12×φ25.4 | A/STD |
| END_RF_OD | **φ381.0** | A/STD |
| 法兰环本体最小厚 | 30.2 | A/STD-reference |
| RF高度CAD | 1.6 | C/STD-inch |
| RF面→法兰背面CAD | 31.8 | B/C |
| X_END_FLANGE_BACK_CAD | 273.2 | B/C |
| X_BODY_JOINT_CAD | **232.5** | **C+ CAD** |
| BODY_COVER总长 | 72.5 | B/C+ |
| φ382→φ303 45°内锥长度 | 39.5 | B/C |
| 内锥结束X | 272.0 | B/C |
| 当前M20有效旋合 | 30 | C |
| 当前BODY_COVER有效夹持 | 29 | C |
| 螺母支承面X | 261.5 | B/C |
| 螺母面→端法兰背面余量 | 11.7 | B/C |

---

# 14. 一句话结论

> **BODY_COVER的72.5mm轴向空间现在第一次完整闭合：NPS12 Class150端法兰为ODφ482.6、BCDφ431.8、12×φ25.4、RF外径φ381.0；用30.2mm法兰环本体+约1.6mm RF建立背面X≈273.2。主分界X=232.5到法兰背面40.7mm，而φ382座腔缩到φ303全通径的45°内锥恰需39.5mm，独立验证了X_BODY_JOINT_CAD=232.5。为给BODY_COVER外壳留下合理颈部空间，M20有效旋合从V25的20mm下限候选优化到30mm，夹持厚度由39mm优化到29mm，螺母支承面到端法兰背面留下约11.7mm。**

---

# 15. 下一步 V27 / 第6H

```text
BODY_COVER外轮廓/铸造圆角
↓
中法兰φ562.5到端法兰φ482.6之间的外部承压过渡
↓
φ382→φ303内锥局部壁厚检查
↓
BODY侧从-X端法兰到中央球腔的对应实体骨架
↓
07_BODY + 08_BODY_COVER第一版干涉检查尺寸表
```

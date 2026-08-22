# Q347F 12寸 Class150——第6K步：BODY / BODY_COVER / BALL / SEAT 总装干涉预检查 V30

> **定位**：V28纠正主拆装孔/主O圈，V29形成BODY第一版承压骨架。V30第一次把 `BODY + BODY_COVER + BALL + 左右SEAT + 主中法兰密封/螺栓` 放到同一数字骨架中做装配与干涉预检查。
>
> **目标**：不是宣布制造完成，而是验证当前CAD候选是否至少“装得进去、配得上、不互相切穿”。发现冲突就回退候选。

[← 总导航](./00_Q347F_12in_Class150_文档导航_从这里开始.md)  
[← 总账](./Q347F_12in_Class150_数字化总装骨架_尺寸参数_装配关系_空间坐标总账.md)  
[← V28主拆装口纠错](./Q347F_12in_Class150_第6I步_主拆装口校核_φ480_H8f8止口_φ466x7径向O圈纠错_V28.md)  
[← V29 BODY骨架](./Q347F_12in_Class150_第6J步_BODY完整承压骨架_φ471局部壁厚纠错_左端到主开口_V29.md)

---

# 1. 当前总装一级骨架

```text
                         STEM_COVER
                              │
                              │ Z+
-X                                                         +X
RF ─ BODY ─ LEFT_SEAT ─── BALL ─── RIGHT_SEAT ─ BODY_COVER ─ RF
                              │
                              │ Z-
                         BOTTOM_COVER
```

唯一主BODY joint：

```text
X_BODY_JOINT_CAD=+232.5
```

主要当前CAD尺寸：

```text
BALL_OD=465
BODY主拆装孔=φ480 H8
BODY_COVER凸止口=φ480 f8
SEAT_BIG_OD=380
SEAT_BIG_BORE=382
主O圈=φ466×7
主缠绕垫=φ500×φ490×3.2
MID_BCD_CAD=526.5
20×M20×85
MID_FLANGE_OD_CAD≈562.5
```

---

# 2. 检查A：球体φ465能否通过BODY φ480主拆装孔

```text
D_opening=480
D_ball=465
```

直径余量：

```text
ΔD=15mm
```

径向余量：

```text
ΔR=7.5mm/侧
```

结论：

```text
PASS / CAD
```

这条是V28把φ450纠正成φ480的最主要装配门。

注意：这里只检查球面最大OD通过；最终装配工艺还要考虑球体上下孔边、吊装姿态、阀座安装顺序和工具空间。

---

# 3. 检查B：阀座组件能否通过主拆装口

当前阀座最大功能外径：

```text
SEAT_BIG_OD=380
```

主拆装孔：

```text
480
```

直径差：

```text
480-380=100mm
```

径向：

```text
50mm/侧
```

弹簧PCD：

```text
362 < 380 < 480
```

所以阀座组件主要径向包络通过主拆装口没有问题。

结论：

```text
PASS / CAD
```

---

# 4. 检查C：阀座φ380与BODY_COVER内部φ382座孔

```text
SEAT_BIG_OD=380
SEAT_BIG_BORE=382
```

直径间隙：

```text
2mm
```

径向间隙：

```text
1mm/侧
```

这与公司“≥6in阀座大端外圆比阀盖内孔小2mm”的既有设计关系一致。

结论：

```text
PASS / C+
```

---

# 5. 检查D：φ480 H8/f8止口是否为可装配间隙配合

对φ480所在450~500mm尺寸段，ISO 286参考表：

```text
BODY H8孔：
EI=0
ES≈+0.110mm
→ 480.000~480.110

BODY_COVER f8轴：
es≈-0.076mm
ei≈-0.186mm
→ 479.814~479.924
```

所以直径配合间隙：

```text
最小≈480.000-479.924=0.076mm
最大≈480.110-479.814=0.296mm
```

径向间隙：

```text
≈0.038~0.148mm/侧
```

结论：

```text
PASS / ISO286-reference
```

既能定位，又不会形成过盈装配。

正式工程图仍需确认公司采用的ISO/GB公差表版本及铸件加工基准。

---

# 6. 检查E：H8/f8间隙对φ466×7径向O圈压缩的影响

名义槽深：

```text
5.7mm
```

由于H8/f8有径向配合间隙，实际O圈径向容纳空间第一轮约：

```text
5.7 + 0.038 ~ 0.148
=5.738 ~ 5.848mm
```

仅考虑止口配合公差，不含O圈/沟槽自身公差时，压缩率约：

```text
εmax=(7-5.738)/7≈18.03%
εmin=(7-5.848)/7≈16.46%
```

所以当前：

```text
O圈名义压缩18.57%
H8/f8配合影响后约16.5~18.0%
```

仍保持正常静密封压缩量级。

结论：

```text
PASS / preliminary
```

最终必须叠加：

```text
O圈截面公差
槽深公差
温度收缩/膨胀
VITON实际硬度
AED快速降压要求
```

---

# 7. 检查F：20mm止口能否容纳导入段 + O圈槽 + 后金属带

V28：

```text
MID_PILOT_INSERT_L_CAD=20
O圈槽轴向宽=9.5
公司最小导角/导入z=5
```

V30把20mm正式分段：

```text
止口前端导入/完整圆柱段 =5.0
O圈槽轴向宽            =9.5
槽后至主端面金属带      =5.5
----------------------------
总止口插入长度          =20.0
```

定义X坐标：

```text
主分界面       X=232.5
止口内端/前端   X=212.5

导入段：
212.5~217.5  L=5.0

O圈槽：
217.5~227.0  W=9.5

后金属带：
227.0~232.5  L=5.5
```

所以：

```text
X_MID_PILOT_TIP_CAD=212.5
X_MID_ORING_GROOVE_START_CAD=217.5
X_MID_ORING_GROOVE_END_CAD=227.0
X_MID_ORING_GROOVE_CENTER_CAD=222.25
```

结论：

```text
PASS / C
```

20mm止口第一次获得完整功能分段依据。

---

# 8. 检查G：止口φ480与缠绕垫φ490内径

```text
D_pilot=480
D_gasket_ID=490
```

径向金属带：

```text
(490-480)/2=5mm
```

结论：

```text
PASS / C+
```

缠绕垫不会压在定位止口上。

---

# 9. 检查H：缠绕垫外缘与M20孔

```text
MID_GASKET_OD=500 → R=250
MID_BCD_CAD=526.5 → R=263.25
MID_BOLT_HOLE_D_CAD=22 → r=11
```

螺栓孔内缘半径：

```text
263.25-11
=252.25
```

垫片OD到螺栓孔内缘的径向金属带：

```text
252.25-250
=2.25mm
```

这正对应公司BCD公式中当前取的：

```text
+4.5mm直径边距 / 2
=2.25mm径向边距
```

结论：

```text
PASS / A-policy geometry
```

但2.25mm较紧，最终孔公差、垫片制造偏差和加工偏心仍需制造校核。

---

# 10. 检查I：M20 spotface与中法兰OD

当前：

```text
MID_BCD_CAD=526.5 → R=263.25
MID_SPOTFACE_D_CAD=36 → r=18
```

spotface最外缘：

```text
263.25+18
=281.25
```

中法兰外半径：

```text
562.5/2=281.25
```

完全相等。

这不是偶然，因为公司公式就是：

```text
MID_FLANGE_OD
=MID_BCD+MID_COUNTERBORE_D
```

结论：

```text
PASS / formula-consistent
```

但最终如果需要外缘加工余量，可在制造阶段把法兰毛坯外径略加，而不改变功能BCD。

---

# 11. 检查J：主中法兰和端法兰X方向是否撞在一起

V26当前优化：

```text
X_BODY_JOINT=232.5
MID_BODY_COVER_GRIP_CAD=29
X_MID_NUT_BEARING_CAD=261.5
X_END_FLANGE_BACK_CAD=273.2
```

两法兰功能区之间：

```text
273.2-261.5
=11.7mm
```

留给：

```text
颈部外露段
铸造过渡圆角
```

当前不发生轴向实体硬碰撞。

结论：

```text
PASS / CAD
```

11.7mm是否足够最终铸造圆角，仍是制造优化项。

---

# 12. 检查K：内部45°锥与29mm中法兰夹持是否“长度相加超限”

内部：

```text
φ382→φ303
45°
L=39.5
```

外侧螺母夹持：

```text
L=29
```

它们位于不同半径：

```text
内锥：R≈151.5~191
主中法兰螺柱：R≈263.25
```

所以可以在相同X范围轴向重叠。

结论：

```text
PASS
```

永久禁止：

```text
39.5+29+端法兰厚度
```

这种把不同半径功能长度机械串加的错误算法。

---

# 13. 当前V30干涉预检查总表

| 检查项 | 结果 | 余量/说明 |
|---|---|---|
| φ465球体通过φ480主口 | PASS | 7.5mm/侧 |
| φ380阀座通过φ480主口 | PASS | 50mm/侧 |
| φ380阀座装入φ382座孔 | PASS | 1mm/侧 |
| φ480 H8/f8止口装配 | PASS | 直径间隙0.076~0.296参考 |
| O圈配合公差后压缩 | PASS prelim | 约16.5~18.0% |
| 20mm止口容纳O圈槽 | PASS | 5+9.5+5.5=20 |
| φ480止口→φ490垫片 | PASS | 5mm径向带 |
| φ500垫片→M20孔 | PASS | 2.25mm径向带 |
| spotface→中法兰OD | PASS | 按公司公式正好相切 |
| 中法兰→端法兰X空间 | PASS CAD | 11.7mm余量 |
| 内锥与中法兰夹持 | PASS | 不同半径，可轴向重叠 |

当前没有发现需要再次推翻主骨架的硬干涉。

---

# 14. V30 SolidWorks新增变量

```text
# ISO FIT / H8-f8
MID_PILOT_H8_ES_REF=0.110
MID_PILOT_H8_EI_REF=0
MID_PILOT_F8_ES_REF=-0.076
MID_PILOT_F8_EI_REF=-0.186
MID_PILOT_CLEAR_D_MIN_REF=0.076
MID_PILOT_CLEAR_D_MAX_REF=0.296
MID_PILOT_CLEAR_RAD_MIN_REF=0.038
MID_PILOT_CLEAR_RAD_MAX_REF=0.148

# O-RING WITH FIT
MID_ORING_SQUEEZE_FIT_MIN_REF=16.46
MID_ORING_SQUEEZE_FIT_MAX_REF=18.03

# PILOT X LAYOUT
X_MID_PILOT_TIP_CAD=212.5
MID_PILOT_LEAD_L_CAD=5.0
X_MID_ORING_GROOVE_START_CAD=217.5
X_MID_ORING_GROOVE_END_CAD=227.0
X_MID_ORING_GROOVE_CENTER_CAD=222.25
MID_PILOT_BACK_LAND_CAD=5.5

# INTERFERENCE LANDS
MID_LAND_PILOT_TO_GASKET_CAD=5.0
MID_LAND_GASKET_TO_BOLT_HOLE_CAD=2.25
MID_NECK_AXIAL_RESERVE_CAD=11.7
```

---

# 15. 仍未关闭的制造门

```text
O圈和槽自身尺寸公差叠加
VITON硬度/AED牌号
止口表面粗糙度
止口最终直径是否确取480
20mm止口最终长度
2.25mm垫片到孔边距的制造裕量
中法兰根部铸造圆角
真实螺栓预紧
左右阀座完整轴向站位
上/下BODY Boss绝对Z
```

这些不阻塞第一版SolidWorks干涉实体。

---

# 16. 一句话结论

> **V30第一次证明当前两片式数字骨架至少在几何上“装得进去”：φ465球体通过φ480主口有7.5mm/侧余量，φ380阀座通过主口有50mm/侧且装入φ382座孔保持1mm/侧；φ480 H8/f8为明确间隙配合，参考直径间隙约0.076~0.296mm；20mm凸止口可以精确排成5mm导入+9.5mm O圈槽+5.5mm后金属带；φ480止口到φ490垫片保留5mm，垫片到M20孔再保留2.25mm。当前未发现必须推翻BODY/BODY_COVER主骨架的硬干涉，可以进入第一版SolidWorks实体建模。**

---

# 17. 下一步 V31 / 第7A

```text
生成07_BODY / 08_BODY_COVER第一版建模尺寸表
↓
把每个尺寸标A/B/C/C+/D
↓
明确SolidWorks Feature建模顺序
↓
建立干涉检查配置
↓
然后继续上/下Boss绝对Z和前盖/底盖最终接口
```

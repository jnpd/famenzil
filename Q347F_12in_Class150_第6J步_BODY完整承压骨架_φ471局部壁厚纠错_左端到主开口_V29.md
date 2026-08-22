# Q347F 12寸 Class150——第6J步：BODY完整承压骨架 / φ471局部壁厚纠错 / 左端到主开口 V29

> **定位**：V28已经把主拆装/定位孔纠正为φ480，并把主O圈纠正为BODY_COVER凸止口外圆径向静密封。V29开始形成 `07_BODY.SLDPRT` 第一版完整纵向压力骨架，同时按V20自己的“局部大内径必须重算B16.34壁厚”规则，纠正中央φ471球腔的外包络。
>
> **关键纠错**：旧 `BODY_OUTER_D_CENTRAL_CAD=φ498.2` 是把按d=303得到的13.6mm壁厚直接套到φ471球腔外面，只能作为历史下限参考。若φ471按局部直接承压等效内径筛查，则公司+4mm的CAD壁厚约16.38mm，中央BODY外包络应升级到约φ503.8，SolidWorks取φ504。

[← 总导航](./00_Q347F_12in_Class150_文档导航_从这里开始.md)  
[← 总账](./Q347F_12in_Class150_数字化总装骨架_尺寸参数_装配关系_空间坐标总账.md)  
[← V28](./Q347F_12in_Class150_第6I步_主拆装口校核_φ480_H8f8止口_φ466x7径向O圈纠错_V28.md)

---

# 1. BODY当前X方向范围

主阀体BODY从左端RF面到右侧唯一主分界：

```text
X_BODY_LEFT_END=-305
X_BODY_RIGHT_JOINT=+232.5
```

所以第一版主阀体X向总包络：

```text
L_BODY_MAIN_CAD
=232.5-(-305)
=537.5mm
```

注意：

```text
537.5不是整个阀门F2F
整个阀门仍是610
```

BODY_COVER占右侧剩余72.5mm。

---

# 2. 左端法兰站位继承V26标准值

左端RF接触面：

```text
X_END_FACE_L=-305
```

当前RF面到法兰背面CAD轴向约：

```text
31.8mm
```

所以左端法兰背面：

```text
X_LEFT_END_FLANGE_BACK_CAD
=-305+31.8
=-273.2mm
```

端法兰标准骨架：

```text
OD=φ482.6
BCD=φ431.8
12×φ25.4
RF OD=φ381.0
```

---

# 3. 左侧内流道用与BODY_COVER同源的功能过渡

左端全通径：

```text
φ303
```

左阀座大孔：

```text
φ382
```

仍有：

```text
ΔR=(382-303)/2=39.5mm
```

为了骨架同源和加工简化，左侧第一版也采用45°内锥：

```text
X_LEFT_BORE_TAPER_END_CAD=-272.0
X_LEFT_BORE_TAPER_START_CAD=-232.5
```

方向从左向中心：

```text
X=-272.0：φ303
↓ 45° / 39.5mm
X=-232.5：φ382
```

注意：

```text
X=-232.5
```

只是左侧座腔/流道内部功能站位，**不是第二个BODY joint**。

唯一主分界仍只有：

```text
X=+232.5
```

---

# 4. 左右内流道因此形成几何对称，壳体分件仍不对称

内部功能站位：

```text
-305  -273.2  -272   -232.5        0       +232.5  +272 +273.2 +305
 |       |       |       |          |          |      |     |     |
 RF    法兰背   φ303   φ382       BALL       φ382   φ303 法兰背  RF
```

左右内流道/阀座功能可以保持同源：

```text
±232.5：φ382座腔外侧功能站
±272.0：φ303过渡终点
±273.2：端法兰背面
±305：RF端面
```

但结构分件：

```text
+232.5 = BODY / BODY_COVER真实分界
-232.5 = BODY内部普通几何站位
```

这正是“两片式侧装”而不是“三片式”的数字化表达。

---

# 5. V20中央φ498.2为什么需要纠正

V20原CAD：

```text
BODY_CAVITY_D_FUNC=471
T_BODY_CAD=13.6
BODY_OUTER_D_CENTRAL_CAD=471+2×13.6=498.2
```

其中13.6来自：

```text
d=303
T_B1634=9.6
+公司CAD附加4
=13.6
```

V20同时已经规定：

> 局部承压有效内径大于303时，应按 `d_local` 重新算B16.34最小壁厚。

因此不能一边采用该规则，一边对φ471球腔继续只用d303的壁厚。

---

# 6. φ471球腔局部壁厚重新计算

按：

```text
T_B1634_LOCAL(d)=0.0163d+4.70
```

取：

```text
d_local=471
```

得到：

```text
T_B1634_471
=0.0163×471+4.70
≈12.377mm
≈12.38mm
```

公司附加3~5：

```text
T_BODY_471_TARGET
≈15.38~17.38mm
```

当前CAD仍取附加中值4：

```text
T_BODY_471_CAD
≈16.38mm
```

所以中央外包络：

```text
BODY_OUTER_D_CENTRAL_LOCAL_CAD
=471+2×16.38
≈503.76mm
```

SolidWorks圆整：

```text
BODY_OUTER_D_CENTRAL_CAD=504mm C
```

---

# 7. 旧φ498.2如何处理

不删除，降级：

```text
BODY_OUTER_D_CENTRAL_OLD=498.2 H/C
```

含义：

```text
“φ471球腔 + d303处13.6mm壁厚”得到的历史简单外套值
```

不得再作为当前BODY中央压力壳默认外径。

当前主方案：

```text
BODY_OUTER_D_CENTRAL_CAD=504 C
```

最终仍：

```text
BODY_OUTER_D_CENTRAL_FINAL=? D
```

因为正式铸件还要考虑球腔真实形状、上/下Boss、筋、圆角和局部应力。

---

# 8. 右侧φ480主拆装孔的局部壁厚

V28：

```text
MID_ASSEMBLY_OPENING_D_CAD=480
```

按同一局部规则：

```text
T_B1634_480
=0.0163×480+4.70
=12.524mm
```

公司CAD+4：

```text
T_BODY_480_CAD≈16.524mm
```

因此主拆装孔区域最低承压外包络：

```text
D_BODY_JOINT_BOSS_MIN_CAD
=480+2×16.524
≈513.05mm
```

主中法兰实际CAD外径：

```text
MID_FLANGE_OD_CAD≈562.5
```

所以螺栓/法兰区域外径充足。

为了不把整个φ562.5法兰环误当成承压颈，新增压力Boss指导：

```text
BODY_JOINT_PRESSURE_BOSS_OD_MIN≈513.1 B/C
```

第一版实体可圆整：

```text
BODY_JOINT_PRESSURE_BOSS_OD_CAD=520 C
```

外侧再叠加：

```text
MID_FLANGE_OD_CAD≈562.5
```

---

# 9. φ480主孔进入φ471中央球腔

V28止口当前插入：

```text
X_BODY_JOINT_CAD=232.5
MID_PILOT_INSERT_L_CAD=20
X_MID_PILOT_INNER_CAD=212.5
```

BODY自身H8孔：

```text
φ480
```

中央球腔显示配置：

```text
φ471
```

直径只差：

```text
9mm
```

径向差：

```text
4.5mm
```

因此从：

```text
X≈212.5 φ480
```

向中央球腔：

```text
φ471
```

只需要很小的台阶/圆角/放样过渡。

第一版骨架定义：

```text
X_BODY_OPENING_INNER_CAD=212.5
BODY_OPENING_D=480
BODY_CAVITY_D_FUNC=471
BODY_OPENING_TO_CAVITY_RADIAL_STEP=4.5
```

最终过渡圆角D。

---

# 10. 主拆装口现在确实能让球体通过

```text
BODY主拆装孔=φ480
球体最大球面OD=φ465
```

通过间隙：

```text
15mm直径
7.5mm/侧
```

因此SIDE ENTRY装配链可以写成：

```text
拆BODY_COVER
↓
BODY暴露φ480 H8主开口
↓
球体φ465沿X方向通过
↓
进入中央球腔
↓
安装/定位阀座与支承结构
↓
BODY_COVER φ480 f8止口插入BODY
↓
O圈径向密封 + 缠绕垫端面密封
↓
20×M20×85夹紧
```

这条装配关系正式进入总装骨架。

---

# 11. BODY中央外形第一版

中央球腔当前：

```text
内功能球腔≈φ471 P-XREF/C-display
外压力包络≈φ504 C
```

径向CAD壁厚：

```text
(504-471)/2
=16.5mm
```

与重新计算的16.38基本一致。

因此第一版 `07_BODY.SLDPRT` 中央母体可先采用：

```text
SURF_BODY_CAVITY_GUIDE≈φ471
SURF_BODY_CENTRAL_OUTER_GUIDE≈φ504
```

然后再局部长：

```text
右侧φ520压力Boss + φ562.5主中法兰环
左侧端法兰/颈部
上STEM_COVER Boss
下BOTTOM_COVER Boss
VENT/DRAIN Boss
注脂Boss
```

---

# 12. 上/下接口目前如何挂到BODY

不重新猜绝对Z，只挂功能轨：

```text
Z+：STEM_COVER接口
  φ105导向
  φ95×5.3 O圈
  φ115×φ105×3.2垫片
  Z_BODY_TOP_IF=? D

Z-：BOTTOM_COVER接口
  φ70导向
  φ58×5.3 AED O圈
  φ80×φ70×3.2垫片
  6×M12×55
  Z_BODY_BOTTOM_IF=? D
```

中央BODY外包络从φ498.2升级到φ504后，上/下Boss与中央壳融合空间略有增加，不产生新的功能冲突。

---

# 13. V29 SolidWorks变量

```text
# BODY AXIAL / 主阀体X站位
X_BODY_LEFT_END=-305
X_BODY_RIGHT_JOINT=232.5
L_BODY_MAIN_CAD=537.5
X_LEFT_END_FLANGE_BACK_CAD=-273.2
X_LEFT_BORE_TAPER_END_CAD=-272.0
X_LEFT_BORE_TAPER_START_CAD=-232.5
LEFT_BORE_TAPER_ANGLE_CAD=45
LEFT_BORE_TAPER_L_CAD=39.5

# CENTRAL LOCAL WALL / 中央球腔局部壁厚
T_B1634_471=12.38
T_BODY_471_MIN=15.38
T_BODY_471_CAD=16.38
T_BODY_471_MAX=17.38
BODY_OUTER_D_CENTRAL_OLD=498.2
BODY_OUTER_D_CENTRAL_CAD=504
BODY_OUTER_D_CENTRAL_FINAL=?

# BODY JOINT OPENING / 右主拆装孔
MID_ASSEMBLY_OPENING_D_CAD=480
T_B1634_480=12.524
T_BODY_480_CAD=16.524
BODY_JOINT_PRESSURE_BOSS_OD_MIN=513.05
BODY_JOINT_PRESSURE_BOSS_OD_CAD=520
MID_FLANGE_OD_CAD=562.5

# OPENING TO CAVITY / 主孔到球腔
X_BODY_OPENING_INNER_CAD=212.5
BODY_OPENING_D=480
BODY_CAVITY_D_FUNC=471
BODY_OPENING_TO_CAVITY_RADIAL_STEP=4.5
```

---

# 14. 历史纠错

```text
H/C BODY_OUTER_D_CENTRAL_CAD=498.2
→ 原因：把d303处13.6壁厚直接外套到φ471球腔
→ 当前按局部d471重算，BODY_OUTER_D_CENTRAL_CAD=504

H/R MID_PILOT_D_CAD=450
→ V28已改为φ480
```

---

# 15. 当前状态

| 参数 | 当前值 | 状态 |
|---|---:|---|
| BODY X范围 | -305~+232.5 | B/C+ |
| BODY主长度 | 537.5 | B/C+ |
| 左端法兰背面 | -273.2 | B/C |
| 左内锥 | φ303→φ382 / 45° /39.5 | C |
| 左座腔功能站 | X=-232.5 | C-space |
| 中央球腔 | φ471 | P-XREF/C-display |
| d471 B16.34最小壁厚 | 12.38 | B/STD-screen |
| d471公司CAD壁厚 | 16.38 | B/C |
| 中央BODY外包络 | **φ504** | C |
| 旧中央外包络φ498.2 | H/C | retired |
| 主拆装孔 | φ480 H8 | C+/A-policy |
| d480公司CAD壁厚 | 16.524 | B/C |
| 主孔压力Boss最低OD | ≈φ513.1 | B/C |
| 主孔压力BossCAD | φ520 | C |
| 主中法兰环OD | ≈φ562.5 | C |

---

# 16. 一句话结论

> **07_BODY现在第一次拥有从左RF端面到右侧主拆装口的完整压力骨架：左端φ303流道在X=-272~-232.5以45°扩至φ382座腔；中央球腔当前显示φ471，但按局部d471重新执行B16.34+公司附加后，中央BODY外包络应由旧φ498.2升级到约φ504；右侧BODY采用φ480 H8主拆装孔，球体φ465可获得7.5mm/侧通过间隙，该φ480区域按局部壁厚需要约φ513.1最低压力Boss，CAD取φ520，再外叠加φ562.5主中法兰环。BODY的内部功能可左右同源，但真正壳体分界仍只有+232.5一个。**

---

# 17. 下一步 V30 / 第6K

```text
把BODY + BODY_COVER两份纵剖面合到同一总装骨架
↓
检查球体φ465能否从φ480主口完整装入
↓
检查左右阀座φ380/φ382与主口/内锥干涉
↓
检查M20螺柱、φ500垫片、φ466径向O圈是否互相干涉
↓
给出07_BODY / 08_BODY_COVER第一版“可建模尺寸表”
↓
再进入上/下Boss绝对Z关闭
```

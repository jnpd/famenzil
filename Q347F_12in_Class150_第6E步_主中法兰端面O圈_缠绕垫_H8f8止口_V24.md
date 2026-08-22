# Q347F 12寸 Class150——第6E步：主中法兰端面O圈 / 缠绕垫 / H8-f8止口 V24

> V21已关闭两片式主壳体，V22给出 `X_BODY_JOINT_CAD=+232.5`，V23建立 `M20×85` 轴向预算。V24把唯一 BODY—BODY_COVER 主分界面继续细化成可进入 SolidWorks 的真实接口骨架：**定位止口 + φ466×7端面O圈 + φ500×φ490×3.2缠绕垫 + 20×M20螺栓圈**。
>
> 本页只把有证据的结构和CAD候选关闭；止口最终直径/插入长度、O圈槽最终开在哪一侧仍保留D。

[← 总导航](./00_Q347F_12in_Class150_文档导航_从这里开始.md)  
[← 数字化总装骨架总账](./Q347F_12in_Class150_数字化总装骨架_尺寸参数_装配关系_空间坐标总账.md)  
[← V21](./Q347F_12in_Class150_第6B步_两片式主壳体纠错_中法兰垫片_M20螺柱_B16_34校核_V21.md)  
[← V22](./Q347F_12in_Class150_第6C步_BODY_BODY_COVER轴向分界_X_BODY_JOINT与610闭合_V22.md)  
[← V23](./Q347F_12in_Class150_第6D步_主中法兰螺柱轴向预算_VENT_DRAIN接口Boss_V23.md)

---

# 1. 12寸主中法兰BOM链

```text
BODY_JOINT_ORING = VITON φ466×7                ×1
MID_GASKET       = 316+柔性石墨 φ500×φ490×3.2  ×1
MID_STUD         = A193 B7M M20×85             ×20
MID_NUT          = A194 2HM M20                ×20
BODY_COVER       = A216 WCB                    ×1
```

这些零件与20寸成熟主中法兰组一一对应，所以当前归属主BODY—BODY_COVER接口，状态 `A/C+`。

---

# 2. 公司φ7 O圈沟槽规则

公司 `GFE-JS01-2025` 对截面 `d1=7mm` 给：

```text
静槽深 h = 5.7
动槽深   = 5.8
槽宽 b   = 9.5
最小导角 z = 5
r1 = 1
r2 = 0.2
```

BODY—BODY_COVER装配后无相对运动，因此当前主方案采用静密封：

```text
MID_ORING_MODE = AXIAL_FACE_STATIC   C+
MID_ORING_GROOVE_DEPTH = 5.7         A-policy
MID_ORING_GROOVE_W = 9.5             A-policy
MID_ORING_LEAD_Z = 5                 A-policy
MID_ORING_R1 = 1                     A-policy
MID_ORING_R2 = 0.2                   A-policy
```

---

# 3. φ466×7端面O圈CAD环槽

O圈：

```text
ID =466
截面 =7
自由OD =466+2×7=480
自由中心线直径 D_CL=466+7=473
```

第一版CAD让O圈中心线保持在φ473，不主动增加周向拉伸。

用公司槽宽9.5布置端面环槽：

```text
MID_ORING_GROOVE_ID_CAD
=473-9.5
=463.5

MID_ORING_GROOVE_OD_CAD
=473+9.5
=482.5
```

所以：

```text
端面槽 = φ463.5 ~ φ482.5
槽深   = 5.7
```

状态：`B/C`，可进CAD，未制造冻结。

名义轴向压缩率：

```text
ε=(7-5.7)/7
 ≈18.57%
```

即：

```text
MID_ORING_AXIAL_SQUEEZE_NOM≈18.6%   B
```

---

# 4. O圈与金属缠绕垫的径向嵌套

主缠绕垫：

```text
ID=490
OD=500
T=3.2
径向宽=(500-490)/2=5
```

O圈自由OD=480，所以自由O圈到垫片ID：

```text
(490-480)/2=5.0mm
```

按当前环槽OD=482.5，环槽外缘到垫片ID：

```text
MID_LAND_ORING_TO_GASKET_CAD
=(490-482.5)/2
=3.75mm
```

因此当前从内到外：

```text
压力腔/止口区
↓
φ463.5~φ482.5 端面O圈槽
↓
3.75mm CAD金属带
↓
φ490~φ500 金属缠绕垫
↓
主中法兰M20螺栓圈
```

这组几何强烈支持：

```text
φ466×7 = 正常工况主端面静密封
φ500×φ490×3.2 = 外侧第二道端面密封/防火密封链
```

状态：`C+ topology`。

`3.75mm` 不是公司规定的最小值，制造冻结前继续校核。

---

# 5. H8/f8关闭止口方向

公司规范明确：

```text
阀体 = H8
阀盖 = f8
```

当前按孔/轴配合解释为：

```text
BODY        = female locating bore = H8
BODY_COVER  = male locating spigot = f8
```

即：

```text
MID_PILOT_FEMALE_OWNER=BODY
MID_PILOT_FEMALE_FIT=H8
MID_PILOT_MALE_OWNER=BODY_COVER
MID_PILOT_MALE_FIT=f8
```

状态：`A-policy/C+`。

这条止口负责同轴定位，不和O圈密封功能混写。

---

# 6. 止口名义直径仍不制造冻结

正式保持：

```text
MID_PILOT_D_FINAL=?          D
MID_PILOT_INSERT_L_FINAL=?   D
```

为了第一版SolidWorks实体不断链，V24设置纯空间候选：

```text
MID_PILOT_D_CAD=450mm   C-space
```

它与O圈槽内径φ463.5之间剩余径向金属带：

```text
(463.5-450)/2
=6.75mm
```

所以当前径向骨架：

```text
φ450 H8/f8定位止口
↓ 6.75
φ463.5~φ482.5 O圈槽
↓ 3.75
φ490~φ500 缠绕垫
```

**φ450不是标准值，也不是最终加工尺寸。**

---

# 7. O圈槽归属零件分两层

正式制造值：

```text
MID_ORING_GROOVE_OWNER_FINAL=?   D
```

总装骨架只建立：

```text
RING_MID_ORING_GROOVE_REF
```

如果第一版零件实体必须选一侧，CAD配置暂取：

```text
MID_ORING_GROOVE_OWNER_CAD=BODY_COVER   C
```

理由仅为可拆主阀盖安装/检修方便，不作为规范事实。

---

# 8. 与V21螺栓圈合并后的完整径向骨架

V21已有：

```text
MID_STUD=M20×85 ×20
MID_BOLT_HOLE_D_CAD=22
MID_BCD_CAD=526.5
MID_SPOTFACE_D_CAD=36
MID_FLANGE_OD_CAD≈562.5
```

V24合并后：

```text
SEAT / PRESSURE CAVITY
↓
MID_PILOT_D_CAD = φ450
↓
MID_ORING_GROOVE = φ463.5~φ482.5
↓
MID_GASKET = φ490~φ500
↓
MID_BCD_CAD = φ526.5
↓
20×M20
↓
MID_FLANGE_OD_CAD ≈ φ562.5
```

这组尺寸已经足够生成BODY和BODY_COVER第一版主中法兰实体骨架。

---

# 9. 轴向仍与V22/V23联动

```text
X_BODY_JOINT_CAD=+232.5   C
X_BODY_JOINT_FINAL=?      D
```

V23：

```text
MID_ANCHOR_PLUS_GRIP_AVAILABLE≈57.2~61.0mm
```

V24新增：

```text
O圈槽深=5.7
缠绕垫自由厚=3.2
止口插入长度=?
BODY侧法兰肉厚=?
BODY_COVER侧法兰肉厚=?
```

不能把 `57.2~61.0-5.7-3.2` 直接当法兰厚度，因为O圈槽是局部切槽，缠绕垫装配后也有压缩。

---

# 10. SolidWorks骨架变量

```text
X_BODY_JOINT_CAD=232.5
X_BODY_JOINT_FINAL=?

MID_ORING_ID=466
MID_ORING_CS=7
MID_ORING_FREE_OD=480
MID_ORING_CL_D_CAD=473
MID_ORING_GROOVE_DEPTH=5.7
MID_ORING_GROOVE_W=9.5
MID_ORING_GROOVE_ID_CAD=463.5
MID_ORING_GROOVE_OD_CAD=482.5
MID_ORING_AXIAL_SQUEEZE_NOM=18.57
MID_ORING_GROOVE_OWNER_CAD=BODY_COVER
MID_ORING_GROOVE_OWNER_FINAL=?

MID_GASKET_ID=490
MID_GASKET_OD=500
MID_GASKET_T_FREE=3.2
MID_LAND_ORING_TO_GASKET_CAD=3.75

MID_PILOT_FEMALE_OWNER=BODY
MID_PILOT_FEMALE_FIT=H8
MID_PILOT_MALE_OWNER=BODY_COVER
MID_PILOT_MALE_FIT=f8
MID_PILOT_D_CAD=450
MID_PILOT_D_FINAL=?
MID_PILOT_INSERT_L_FINAL=?
MID_LAND_PILOT_TO_ORING_CAD=6.75

MID_BCD_CAD=526.5
MID_STUD_QTY=20
MID_STUD_SIZE=M20
MID_STUD_L=85
MID_FLANGE_OD_CAD=562.5
```

骨架对象：

```text
PLN_BODY_JOINT_X
SURF_MID_PILOT_REF
RING_MID_ORING_GROOVE_REF
RING_MID_GASKET_REF
CIRCLE_MID_BCD_REF
SURF_MID_FLANGE_OD_REF
```

---

# 11. 当前状态

| 参数 | 当前值 | 状态 |
|---|---:|---|
| 主O圈 | φ466×7 | A/C+ |
| 端面静密封拓扑 | 是 | C+ |
| 静槽深 / 槽宽 | 5.7 / 9.5 | A-policy |
| O圈槽ID/OD CAD | φ463.5 / φ482.5 | B/C |
| 名义轴向压缩 | 18.57% | B |
| 缠绕垫 | φ500×φ490×3.2 | A/C+ |
| 槽到垫片径向带 | 3.75 | B/C |
| BODY定位 | H8内孔 | A-policy/C+ |
| BODY_COVER定位 | f8凸止口 | A-policy/C+ |
| 止口CAD直径 | φ450 | C-space |
| 止口最终直径/插入长度 | ? / ? | D |
| O圈槽CAD归属 | BODY_COVER | C |
| O圈槽最终归属 | ? | D |
| BCD CAD | φ526.5 | C |
| 中法兰OD CAD | ≈φ562.5 | C |

---

# 12. V24风险门

```text
R24-01：O圈槽与缠绕垫之间3.75mm金属带，需继续校核加工/刚度/防火路径。
R24-02：φ450只是CAD空间止口，禁止写入制造图。
R24-03：O圈槽最终开BODY还是BODY_COVER，仍待正式12寸剖面确认。
```

---

# 13. 一句话结论

> **BODY—BODY_COVER现在第一次形成真正可画的主接口剖面：BODY H8内孔 + BODY_COVER f8凸止口定位；φ466×7按公司静槽规则形成φ463.5~φ482.5、深5.7的端面O圈槽，名义压缩约18.6%；外侧布置φ490~φ500×3.2缠绕垫，再外侧是φ526.5的20×M20螺栓圈。φ450止口仅为CAD空间候选，最终止口和槽归属仍D。**

---

# 14. 下一步 V25 / 第6F

```text
止口插入长度
↓
M20×85实际锚固侧/旋入长度
↓
BODY侧法兰有效厚度
↓
BODY_COVER侧法兰有效厚度
↓
57.2~61.0mm轴向预算闭环
↓
B16.34 §6.4.2.3截面模量门
↓
BODY / BODY_COVER第一版可干涉检查实体
```

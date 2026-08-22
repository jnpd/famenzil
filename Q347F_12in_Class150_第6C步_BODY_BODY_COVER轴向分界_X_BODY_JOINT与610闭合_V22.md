# Q347F 12寸 Class150——第6C步：BODY / BODY_COVER轴向分界、X_BODY_JOINT与610闭合 V22

> **定位**：V21已经把主壳体纠正为 `BODY×1 + BODY_COVER×1` 的两片式侧装结构，并关闭了主中法兰的第一轮径向尺寸与M20螺栓面积门。V22只做一件事：**建立唯一主中法兰分界面的X坐标骨架**，让BODY与BODY_COVER第一次可以作为两个独立SolidWorks承压实体落地。
>
> **权限边界**：本页关闭的是 `CAD骨架分界`，不是12寸加工图制造分界。`X_BODY_JOINT_CAD` 可以用于草模、装配、干涉和后续轴向尺寸链；`X_BODY_JOINT_FINAL` 在正式12寸阀体/阀盖剖面或成熟源模型精确测量前继续保持 `D`。

[← 总导航](./00_Q347F_12in_Class150_文档导航_从这里开始.md)  
[← 数字化总装骨架总账](./Q347F_12in_Class150_数字化总装骨架_尺寸参数_装配关系_空间坐标总账.md)  
[← V21 两片式主壳体 / 主中法兰](./Q347F_12in_Class150_第6B步_两片式主壳体纠错_中法兰垫片_M20螺柱_B16_34校核_V21.md)

---

# 1. 先明确：V22不是在“猜加工面”

当前已经有4个可靠X向基准：

```text
BALL_CENTER_O = 0
BALL_X_FACE_R = +174
X_CONTACT_R   = +166.036
X_END_FACE_R  = +305
```

以及：

```text
BALL_R = 232.5
WSEAT_ENV ≈58 mm     C-space
```

但仍缺：

```text
X_BODY_JOINT_FINAL = ?
```

所以V22采用两层变量：

```text
X_BODY_JOINT_CAD   = 当前SolidWorks骨架候选
X_BODY_JOINT_FINAL = 正式制造分界面
```

两者禁止混写。

---

# 2. 为什么第一版CAD把分界面放到 |X|=232.5

球体半径：

```text
BALL_R = 232.5 mm
```

如果把第一版主中法兰骨架面放在：

```text
ABS_X_BODY_JOINT_CAD = 232.5 mm
```

则从球体X向平端基准 `174` 到该分界面：

```text
L_BALL_FACE_TO_JOINT_CAD
= 232.5 - 174
= 58.5 mm
```

而当前单侧阀座功能包络：

```text
WSEAT_ENV ≈58 mm
```

二者只差：

```text
58.5 - 58 = 0.5 mm
```

这说明：

> **把主中法兰第一版骨架面放在球心外232.5mm处，与当前球体宽348和约58mm阀座功能包装在量级上高度协调。**

但必须强调：

```text
WSEAT_ENV≈58
```

本身是功能空间包络，并没有被证明“严格从球体平端174量到中法兰面”。

所以这种吻合只能把：

```text
ABS_X_BODY_JOINT_CAD=232.5
```

提升到：

```text
C / strong CAD skeleton candidate
```

不能提升成制造冻结值A/B/C+。

---

# 3. 用真实密封接触中心再做一次反校核

右侧真实密封接触代表中心：

```text
X_CONTACT_R=+166.036
```

若CAD分界面在：

```text
+232.5
```

则：

```text
L_CONTACT_TO_JOINT_CAD
=232.5-166.036
=66.464 mm
```

与当前：

```text
WSEAT_ENV≈58
```

相比，剩余：

```text
66.464-58
=8.464 mm
```

这个 `≈8.46mm` 可以容纳第一轮：

```text
阀座后端停止肩/金属带
+
BODY/BODY_COVER定位/密封接口的一部分轴向空间
```

从空间上没有立即冲突。

但这里仍不允许反推：

```text
“8.464mm就是定位止口长度”
```

它仅是：

```text
AXIAL_RESIDUAL_CHECK ≈8.464 mm   P/C-check
```

---

# 4. 与F2F=610的另一端空间闭合

项目结构长度已锁定：

```text
VALVE_F2F=610 mm
X_END_FACE_R=+305
X_END_FACE_L=-305
```

若把BODY_COVER暂时放在 `+X` 侧，主中法兰CAD面：

```text
X_BODY_JOINT_CAD=+232.5
```

则：

```text
L_JOINT_TO_END_FACE_CAD
=305-232.5
=72.5 mm
```

也就是说BODY_COVER从主中法兰基准面到端部RF基准面的第一轮轴向包装：

```text
BODY_COVER_AXIAL_ENV_CAD=72.5 mm
```

这72.5mm用于后续分配：

```text
中法兰厚度/密封台阶
+
BODY_COVER流道颈
+
端部Class150 RF法兰轴向厚度/过渡
+
铸造圆角
```

当前不把这72.5拆成加工尺寸。

---

# 5. 这里为什么采用“+X是BODY_COVER”只是坐标约定

用户爆炸图可以确认：

```text
BODY×1
BODY_COVER×1
主分界面×1
```

但爆炸图相机视角不能可靠定义我们数字模型的 `+X/-X`。

所以V22新增：

```text
BODY_COVER_SIDE = +1
```

含义只是：

> **在当前SolidWorks骨架里，把BODY_COVER约定放在+X侧，方便变量统一。**

它不是工程功能要求。

若后续12寸正式总装图显示BODY_COVER应在-X侧，只需：

```text
BODY_COVER_SIDE=-1
```

所有绝对距离保持不变，整个主分件结构镜像即可。

公式：

```text
X_BODY_JOINT_CAD
= BODY_COVER_SIDE * ABS_X_BODY_JOINT_CAD
```

当前：

```text
BODY_COVER_SIDE=+1             C-convention
ABS_X_BODY_JOINT_CAD=232.5     C
X_BODY_JOINT_CAD=+232.5        C
X_BODY_JOINT_FINAL=?           D
```

---

# 6. BODY与BODY_COVER第一版轴向占区

在当前 `BODY_COVER_SIDE=+1` 约定下：

```text
BODY主轴向占区（骨架）
X=-305 ～ +232.5

BODY_COVER主轴向占区（骨架）
X=+232.5 ～ +305
```

但这里的“占区”仅指：

```text
零件一级骨架归属
```

实际两件在中法兰处会存在：

```text
止口插入
O圈沟槽
缠绕垫槽/密封面
螺柱孔
圆柱销
局部台阶
```

所以真实实体可能在 `X=232.5` 两侧互相套入，不代表几何实体只能各占半空间。

---

# 7. 主中法兰径向尺寸与本X位置是否冲突

V20当前中央承压壳默认：

```text
BODY_OUTER_D_CENTRAL_CAD≈498.2
```

V21：

```text
BODY_JOINT_ORING=φ466×7
MID_GASKET_OD=500
MID_GASKET_ID=490
MID_BCD_CAD=526.5
MID_FLANGE_OD_CAD≈562.5
```

因此在：

```text
X≈232.5
```

建立局部中法兰鼓包时，径向层次可自然写成：

```text
中央承压壳约φ498.2
↓
缠绕垫外缘φ500
↓
20×M20螺柱圆φ526.5
↓
法兰外包络约φ562.5
```

不存在“中法兰必须比中央壳更小”的几何矛盾。

这条证据只是空间合理性校核，不是X坐标的独立标准来源。

---

# 8. V22不再恢复V18的左右双主接口

正式禁止：

```text
X_BODY_COVER_IF_L=-X_BODY_COVER_IF_R
```

也禁止为了“左右阀座对称”再生成两张主中法兰面。

当前正确关系是：

```text
左阀座       = 1套
右阀座       = 1套
主壳体分界面 = 1张
```

因此：

```text
seat symmetry != pressure-shell piece symmetry
```

左右阀座的尺寸关系可以镜像；BODY和BODY_COVER的零件边界不需要关于O镜像。

---

# 9. 当前轴向链图

```text
-X端面                                                   +X端面
-305                                                       +305
 │                                                           │
 │<---------------------- F2F = 610 ------------------------>│
 │                                                           │
 BODY                                                        │
 │                                                           │
 │    左阀座       BALL              右阀座                  │
 │       │     -174     +174            │                    │
 │-------│------[========O========]------│---------|----------│
                                                   ↑          │
                                            X_BODY_JOINT_CAD  │
                                                +232.5        │
                                                   │<--72.5-->│
                                                   BODY_COVER
```

右侧关键距离：

```text
X_CONTACT_R           =166.036
BALL_X_FACE_R         =174
X_BODY_JOINT_CAD      =232.5
X_END_FACE_R          =305

FACE → JOINT          =58.5
CONTACT → JOINT       =66.464
JOINT → END FACE      =72.5
```

---

# 10. SolidWorks骨架怎么建

在 `00_SKELETON.SLDPRT` 建立：

```text
PLN_BALL_CENTER      : X=0
PLN_END_L            : X=-305
PLN_END_R            : X=+305
PLN_BALL_FACE_L      : X=-174
PLN_BALL_FACE_R      : X=+174
PLN_CONTACT_L        : X=-166.036
PLN_CONTACT_R        : X=+166.036
PLN_BODY_JOINT_CAD   : X=+232.5   # 当前约定
```

BODY零件：

```text
引用 PLN_END_L
引用 BALL_CENTER_O
引用 PLN_BODY_JOINT_CAD
引用中央球腔/阀座/上盖/底盖功能包络
```

BODY_COVER零件：

```text
引用 PLN_BODY_JOINT_CAD
引用 PLN_END_R
引用右阀座局部坐标u_R
引用MID_GASKET/MID_BCD/MID_FLANGE_OD
```

主装配配合：

```text
BODY固定到总装骨架
BODY_COVER X轴同轴
BODY_COVER主中法兰基准面 ↔ PLN_BODY_JOINT_CAD
φ12×22定位销在后续止口/孔位关闭后加入角向定位
```

---

# 11. V22变量块

```text
# BODY / BODY_COVER AXIAL SPLIT
BODY_COVER_SIDE=+1
ABS_X_BODY_JOINT_CAD=232.5
X_BODY_JOINT_CAD=232.5
X_BODY_JOINT_FINAL=?

# AXIAL CHECKS
L_BALL_FACE_TO_JOINT_CAD=58.5
L_CONTACT_TO_JOINT_CAD=66.464
L_JOINT_TO_END_FACE_CAD=72.5
AXIAL_RESIDUAL_AFTER_WSEAT=8.464
BODY_COVER_AXIAL_ENV_CAD=72.5

# EXISTING X DATUMS
X_END_FACE_L=-305
X_END_FACE_R=305
BALL_X_FACE_L=-174
BALL_X_FACE_R=174
X_CONTACT_L=-166.036
X_CONTACT_R=166.036

# MAIN JOINT RADIAL ENVELOPE
BODY_OUTER_D_CENTRAL_CAD=498.2
BODY_JOINT_ORING_D0=466
BODY_JOINT_ORING_CS=7
MID_GASKET_OD=500
MID_GASKET_ID=490
MID_BCD_CAD=526.5
MID_FLANGE_OD_CAD=562.5
```

---

# 12. 状态表

| 参数 | 当前值 | 状态 | 是否可进SolidWorks |
|---|---:|---|---|
| `BODY_COVER_SIDE` | +1 | C-convention | 是 |
| `ABS_X_BODY_JOINT_CAD` | 232.5 | C | 是 |
| `X_BODY_JOINT_CAD` | +232.5 | C | 是 |
| `X_BODY_JOINT_FINAL` | ? | D | 否 |
| `L_BALL_FACE_TO_JOINT_CAD` | 58.5 | B/C | 是 |
| `L_CONTACT_TO_JOINT_CAD` | 66.464 | B/C | 是 |
| `L_JOINT_TO_END_FACE_CAD` | 72.5 | B/C | 是 |
| `AXIAL_RESIDUAL_AFTER_WSEAT` | 8.464 | P/C-check | 仅检查 |
| `BODY_COVER_AXIAL_ENV_CAD` | 72.5 | C | 是 |

---

# 13. 当前仍不能制造冻结的部分

即使有了 `X_BODY_JOINT_CAD=232.5`，以下仍是D：

```text
BODY与BODY_COVER真实分界面X
BODY/BODY_COVER定位止口直径
止口插入长度
止口H8/f8最终尺寸
φ466×7 O圈具体开在BODY还是BODY_COVER
φ466×7 O圈静槽的轴向位置
φ500×φ490×3.2垫片沟槽/压缩后的真实轴向层
主中法兰BODY侧厚度
主中法兰BODY_COVER侧厚度
端法兰颈部真实轴向尺寸
```

这些将在真实12寸剖面或成熟20寸BODY/COVER精确测量证据进入后逐项替换C候选。

---

# 14. V22正式结论

当前数字化总装第一次可以明确写：

```text
两片式主壳体
=
BODY
+
BODY_COVER
```

并在SolidWorks骨架中建立唯一分件面：

```text
PLN_BODY_JOINT_CAD
X=+232.5 mm
```

当前选择它的核心原因不是“232.5看起来顺眼”，而是：

```text
232.5-174=58.5
```

与当前：

```text
WSEAT_ENV≈58
```

高度协调，同时：

```text
305-232.5=72.5
```

又能给BODY_COVER到端法兰留下完整轴向包装空间。

因此：

```text
X_BODY_JOINT_CAD=+232.5 mm   C
```

允许用于：

```text
SolidWorks骨架
BODY/BODY_COVER粗模
总装配合
干涉预检查
后续轴向尺寸链
```

但：

```text
X_BODY_JOINT_FINAL=? D
```

继续保留，禁止在二维加工图上直接标232.5。

---

# 15. 下一步：V23 / 第6D

V23开始不再讨论“主壳体到底几片”，这个问题已经关闭。

下一步围绕 `PLN_BODY_JOINT_CAD` 建真实接口截面：

```text
BODY侧座腔终点
↓
BODY/BODY_COVER定位止口
↓
H8/f8配合
↓
φ466×7静O圈槽
↓
φ500×φ490×3.2缠绕垫密封面
↓
M20螺柱孔/定位销孔
↓
BODY侧中法兰厚度
↓
BODY_COVER侧中法兰厚度
↓
检查M20×85长度是否与夹持厚度/螺母露牙闭合
```

同时进入BODY附属承压Boss：

```text
NPS12 ≥10"
VENT = 1" NPT
DRAIN = 1" NPT
```

若局部壁厚不足有效螺纹长度，则按公司规则增加Boss。

> **一句话：V22把两片式结构真正变成了SolidWorks可执行的“一张分件面”；232.5是当前强CAD候选，不是加工冻结值。**

# Q347F 12寸 Class150——第6D步：主中法兰螺柱轴向预算 / VENT-DRAIN接口Boss V23

> **定位**：V22已建立唯一主中法兰CAD分件面 `X_BODY_JOINT_CAD=+232.5 C`。V23继续关闭这个接口的“轴向可用空间”，但不在锚固深度未知时硬造中法兰厚度；同时把12寸BOM已经明确的放空、排污接口加入BODY承压骨架。
>
> **本页核心结论**：`M20×85` 不能被简单理解成“85mm=两片法兰夹持厚度”；GB/T 901 是等长双头螺柱，M20标准端部螺纹长度 `b=52mm`，而12寸/20寸BOM都是“一根主中法兰螺柱对应一只螺母”的成熟系列关系。当前可以关闭的是“螺柱轴向总预算”，不能关闭的是“螺纹锚固深度”和“BODY/BODY_COVER各自法兰厚度”。

[← 总导航](./00_Q347F_12in_Class150_文档导航_从这里开始.md)  
[← 数字化总装骨架总账](./Q347F_12in_Class150_数字化总装骨架_尺寸参数_装配关系_空间坐标总账.md)  
[← V22 BODY / BODY_COVER轴向分界](./Q347F_12in_Class150_第6C步_BODY_BODY_COVER轴向分界_X_BODY_JOINT与610闭合_V22.md)

---

# 1. 12寸主中法兰紧固件拓扑再次确认

12寸目标BOM主中法兰连续件：

```text
M20×85 螺柱 ×20
M20 2型六角螺母 ×20
BODY_COVER ×1
```

20寸成熟对应：

```text
M30×145 螺柱 ×32
M30 螺母 ×32
BODY_COVER ×1
```

所以跨规格一致关系是：

```text
1根主中法兰螺柱
↔
1只外部螺母
```

这强烈支持：

```text
螺柱一端由BODY/BODY_COVER中的一个承压件锚固
另一端由螺母夹紧另一承压件
```

状态：

```text
BODY_JOINT_STUD_TOPOLOGY = ONE_ANCHORED_END + ONE_NUT   C+
```

但：

```text
锚固在BODY还是BODY_COVER = ? D
螺纹孔是否盲孔/通孔      = ? D
有效旋入深度              = ? D
```

当前不从爆炸图相机视角强行指定。

---

# 2. GB/T 901本身不能被误读成“专用旋入端螺柱”

GB/T 901-1988名称：

```text
等长双头螺柱 B级
Double end studs (clamping type)
```

标准表对M20：

```text
d = M20
P = 2.5 mm
b = 52 mm
l允许范围 =70~300 mm
```

本项目：

```text
l =85 mm
```

注意：

```text
2b =104 mm > l=85 mm
```

所以两端标准螺纹长度区域会发生重叠。

这意味着：

> **绝不能使用“85 - 52 - 52 = 光杆长度”这种算法。**

M20×85在几何上属于高度螺纹化的短双头螺柱，中心不应预设存在一个明确的长光杆夹持段。

---

# 3. M20螺母的真实轴向高度

GB/T 6175 2型六角螺母，M20：

```text
P =2.5 mm
m_max =20.3 mm
m_min =19.0 mm
s =30 mm
emin≈32.95 mm
```

因此当前轴向预算必须用：

```text
NUT_M =19.0~20.3 mm
```

而不是把“对边30”误当成螺母厚度。

---

# 4. 公司规则：螺柱露出螺母2~3牙

公司固定球阀规范：

```text
螺柱露出螺母统一保留2~3牙
```

M20粗牙：

```text
P=2.5 mm
```

所以露牙轴向长度：

```text
L_PROTRUSION_MIN=2×2.5=5.0 mm
L_PROTRUSION_MAX=3×2.5=7.5 mm
```

当前：

```text
L_PROTRUSION=5~7.5 mm    A-policy/B
```

---

# 5. M20×85可以关闭的“总轴向预算”

从螺柱总长：

```text
L_STUD=85
```

扣除：

```text
螺母高度19~20.3
+
露牙5~7.5
```

得到：

```text
L_ANCHOR_PLUS_GRIP_AVAILABLE
=85-NUT_M-L_PROTRUSION
```

最小：

```text
85-20.3-7.5
=57.2 mm
```

最大：

```text
85-19.0-5.0
=61.0 mm
```

所以：

```text
L_ANCHOR_PLUS_GRIP_AVAILABLE≈57.2~61.0 mm
```

状态：

```text
B/C+ stack constraint
```

这里定义：

```text
L_ANCHOR_PLUS_GRIP_AVAILABLE
=
有效锚固占用长度
+
BODY/BODY_COVER被夹紧的有效轴向厚度
+
必要的垫片/垫圈轴向影响（若存在）
```

因此：

> **57.2~61.0mm不是法兰厚度，而是“锚固 + 夹持”的总预算。**

---

# 6. 为什么当前不能直接算BODY/BODY_COVER法兰厚度

设：

```text
L_EMBED_EFFECTIVE = 主螺柱有效锚固长度
T_GRIP_EFFECTIVE  = 从锚固承压面到螺母支承面的夹持厚度
```

则第一轮：

```text
L_EMBED_EFFECTIVE + T_GRIP_EFFECTIVE
≈57.2~61.0
```

所以：

```text
T_GRIP_EFFECTIVE
≈57.2~61.0 - L_EMBED_EFFECTIVE
```

但当前：

```text
L_EMBED_EFFECTIVE=? D
```

所以：

```text
T_GRIP_EFFECTIVE=? D
```

为了看敏感性，可以暂时列：

| 假定有效锚固 | 剩余夹持预算 |
|---:|---:|
| 20 mm | 37.2~41.0 mm |
| 25 mm | 32.2~36.0 mm |
| 30 mm | 27.2~31.0 mm |

这张表只是敏感性，不代表V23选择了20/25/30中的任何一个。

---

# 7. 对X_BODY_JOINT=232.5的影响

V22：

```text
X_BODY_JOINT_CAD=+232.5
X_BODY_JOINT_FINAL=?
```

V23说明：

```text
螺柱总长85
```

不会迫使：

```text
X_BODY_JOINT_CAD
```

发生变化。

因为X_BODY_JOINT是一张装配分界基准面，而中法兰真实厚度会分布在该面两侧：

```text
BODY侧中法兰肉厚
← X_BODY_JOINT →
BODY_COVER侧中法兰肉厚
```

再叠加：

```text
止口插入
O圈槽
缠绕垫槽
螺柱锚固
螺母支承台
```

所以SolidWorks应把 `X_BODY_JOINT_CAD` 当“接口基准面”，不是某一件零件的绝对最外端面。

---

# 8. 12寸BODY附件接口：BOM已经直接给出

12寸目标BOM当前明确：

```text
排污阀 / DRAIN   =1" NPT ×1
放空阀 / VENT    =1" NPT ×1
注脂阀           =3/8" NPT ×2
止回阀           =1/4" NPT ×2
```

因此进入BODY数字骨架：

```text
DRAIN_PORT_SIZE=1_NPT           A
DRAIN_PORT_QTY=1                A
VENT_PORT_SIZE=1_NPT            A
VENT_PORT_QTY=1                 A
SEAT_GREASE_PORT_SIZE=3/8_NPT   A
SEAT_GREASE_PORT_QTY=2          A
CHECK_PORT_SIZE=1/4_NPT         A
CHECK_PORT_QTY=2                A
```

具体空间坐标仍D。

---

# 9. 1" NPT不是“直径25.4mm的孔”

ASME B1.20.1口径下，1" NPT：

```text
名义尺寸 =1"
实际外螺纹大径D≈1.3150 in≈33.401 mm
螺纹数 =11.5 TPI
螺距P≈2.209 mm
有效外锥管螺纹长度L2≈0.6828 in≈17.34 mm
锥度 =1:16（按直径）
```

所以建模时禁止画：

```text
φ25.4直孔 = 1" NPT
```

正确做法：

```text
先建NPT螺纹轴线/基准
↓
按加工底孔/锥螺纹标准处理
↓
外购排污阀/放空阀按1" NPT接口装配
```

---

# 10. 1" NPT对当前13.6mm中央壁厚提出Boss要求

V20当前中央BODY CAD壁厚：

```text
T_BODY_CAD=13.6 mm
```

1" NPT有效螺纹长度基准约：

```text
L2≈17.34 mm
```

纯几何比较：

```text
17.34-13.6
≈3.74 mm
```

所以如果1" NPT直接打在仅13.6mm厚的普通中央壳壁上：

```text
局部厚度 < 有效螺纹长度基准
```

第一轮结论：

> **VENT/DRAIN区域必须预留局部加厚或Boss，不能把1" NPT直接切进φ498.2中央薄壳后就结束。**

最小差额：

```text
3.74 mm
```

只是几何差额，不是最终Boss高度。

最终还需考虑：

```text
承压剩余肉厚
加工底孔
螺纹退刀/不完整牙
铸造圆角
工具空间
阀件六方扳手空间
局部应力
```

所以：

```text
VENT_BOSS_H_FINAL=?
DRAIN_BOSS_H_FINAL=?
```

继续D。

---

# 11. VENT / DRAIN空间位置先只定功能，不定绝对坐标

功能原则：

```text
VENT
=尽量连通中央腔高位气体空间

DRAIN
=尽量连通中央腔低位液体/排污空间
```

当前固定坐标方向：

```text
+Z =顶部阀杆方向
-Z =底部支承方向
```

所以第一版骨架功能约束：

```text
VENT_PORT_Z > 0
DRAIN_PORT_Z < 0
```

但不能直接写：

```text
VENT在+Z最高点
DRAIN在-Z最低点
```

因为必须避开：

```text
STEM_COVER
BOTTOM_COVER
主中法兰螺柱圈
脚架/吊耳
阀座注脂孔
铸造筋
```

因此：

```text
VENT_PORT_X/Y/Z=? D
DRAIN_PORT_X/Y/Z=? D
```

---

# 12. V23 SolidWorks变量块

```text
# MAIN BODY JOINT STUD TOPOLOGY
MID_STUD_STANDARD=GBT901
MID_STUD_SIZE=M20
MID_STUD_P=2.5
MID_STUD_L=85
MID_STUD_END_THREAD_B=52
MID_STUD_QTY=20
MID_NUT_STANDARD=GBT6175
MID_NUT_QTY=20
MID_NUT_M_MIN=19.0
MID_NUT_M_MAX=20.3
MID_NUT_S=30
MID_NUT_E_MIN=32.95

# COMPANY THREAD PROTRUSION
MID_STUD_PROTRUSION_THREADS_MIN=2
MID_STUD_PROTRUSION_THREADS_MAX=3
MID_STUD_PROTRUSION_L_MIN=5.0
MID_STUD_PROTRUSION_L_MAX=7.5

# AXIAL BUDGET
MID_ANCHOR_PLUS_GRIP_MIN=57.2
MID_ANCHOR_PLUS_GRIP_MAX=61.0
MID_STUD_EMBED_EFFECTIVE=?
MID_GRIP_EFFECTIVE=?

# BODY JOINT DATUM
BODY_COVER_SIDE=+1
X_BODY_JOINT_CAD=232.5
X_BODY_JOINT_FINAL=?

# BODY ACCESSORY PORTS
VENT_PORT_SIZE=1_NPT
VENT_PORT_QTY=1
DRAIN_PORT_SIZE=1_NPT
DRAIN_PORT_QTY=1
SEAT_GREASE_PORT_SIZE=3/8_NPT
SEAT_GREASE_PORT_QTY=2
CHECK_PORT_SIZE=1/4_NPT
CHECK_PORT_QTY=2

# 1 NPT GUIDE
NPT1_MAJOR_D≈33.401
NPT1_TPI=11.5
NPT1_PITCH≈2.209
NPT1_EFFECTIVE_L≈17.34

# BODY WALL / BOSS
T_BODY_CAD=13.6
NPT1_THREAD_MINUS_WALL≈3.74
VENT_BOSS_H_FINAL=?
DRAIN_BOSS_H_FINAL=?
VENT_PORT_X=?
VENT_PORT_Y=?
VENT_PORT_Z=?
DRAIN_PORT_X=?
DRAIN_PORT_Y=?
DRAIN_PORT_Z=?
```

---

# 13. V23正式结论

当前已经能可靠写：

```text
20×M20×85主中法兰螺柱
+
20×M20螺母
```

的轴向装配约束为：

```text
锚固有效长度 + 被夹持有效厚度
≈57.2~61.0 mm
```

但：

```text
有效锚固深度=?
最终夹持厚度=?
```

继续保持D。

同时，BODY已经必须在草模中出现：

```text
1" NPT VENT Boss ×1
1" NPT DRAIN Boss ×1
3/8" NPT seat grease接口 ×2
1/4" NPT check接口 ×2
```

其中1" NPT有效螺纹长度约17.34mm，大于当前中央13.6mm CAD壁厚，因此VENT/DRAIN区域要做局部加厚/Boss，而不能直接在中央薄壳上简单攻丝。

---

# 14. 下一步：V24 / 第6E

下一步优先关闭主中法兰真实截面中的：

```text
φ466×7 O圈
↓
静密封沟槽深度 / 宽度
↓
BODY/BODY_COVER定位止口直径
↓
H8/f8配合
↓
缠绕垫φ500×φ490×3.2的轴向落位
↓
螺柱锚固侧选择
↓
有效锚固深度候选
↓
BODY侧 / BODY_COVER侧中法兰厚度
↓
用57.2~61.0mm螺柱预算反校核
```

与此同时为VENT/DRAIN Boss建立不与上下盖、中法兰和脚架冲突的空间窗口。

> **一句话：V23没有“猜法兰厚度”，而是先把M20×85能真正告诉我们的57.2~61.0mm轴向预算锁住，并把1" NPT放空/排污Boss正式加入BODY骨架。**

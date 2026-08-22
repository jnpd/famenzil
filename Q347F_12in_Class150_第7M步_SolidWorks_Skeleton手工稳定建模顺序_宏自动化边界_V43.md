# Q347F 12寸 Class150——第7M步：SolidWorks Skeleton手工稳定建模顺序 / 宏自动化边界 V43

> **定位**：V42已经产出SolidWorks可读的全局变量txt。V43回答“小白实际打开SolidWorks后先点什么、建什么、怎么命名”，并规定第一版VBA宏只做到Skeleton，不去批量修改/生成全部零件。
>
> **核心原则**：先把 `00_SKELETON.SLDPRT` 建成稳定、可重建、可测量的唯一几何母版，再派生BODY/BALL/COVER。当前不允许宏直接操作44个零件，也不允许直接依赖20寸零件特征名。

[← 总导航](./00_Q347F_12in_Class150_文档导航_从这里开始.md)  
[← V42 SolidWorks全局变量交付](./Q347F_12in_Class150_第7L步_SolidWorks全局变量交付版_当前CAD_D门与HR隔离_V42.md)  
[← GlobalVariables V1](./Q347F_12in_Class150_00_SKELETON_GlobalVariables_V1.txt)

---

# 1. 第一件事：新建独立Skeleton零件

不要在20寸总装里改。

新建：

```text
Part
```

单位：

```text
MMGS
mm / g / s
```

立即另存：

```text
00_SKELETON.SLDPRT
```

建议项目目录：

```text
12_Q347F_150LB/
├─ 00_SKELETON.SLDPRT
├─ 01_BALL.SLDPRT
├─ 02_LEFT_SEAT.SLDASM
├─ 03_RIGHT_SEAT.SLDASM
├─ 04_STEM_COVER.SLDPRT
├─ 05_STEM.SLDPRT
├─ 06_BOTTOM_COVER.SLDPRT
├─ 07_BODY.SLDPRT
├─ 08_BODY_COVER.SLDPRT
├─ 10_TOP_ADAPTER.SLDPRT
└─ 11_F25_GEARBOX_PLACEHOLDER.SLDPRT
```

---

# 2. 第二件事：链接GlobalVariables

打开：

```text
Tools
→ Equations
```

选择：

```text
Link to external file
```

链接：

```text
Q347F_12in_Class150_00_SKELETON_GlobalVariables_V1.txt
```

点击：

```text
Rebuild
```

先不要画任何复杂实体。

---

# 3. 链接后先检查7个计算结果

在Equation Manager确认：

```text
HALF_F2F=305
X_END_FACE_R=305
X_END_FLANGE_BACK_R_CAD≈273.2
Z_ADAPTER_TOP_CAD=337.3
Z_KEY_START_CAD≈339.8
Z_KEY_END_CAD≈429.8
ASM_Z_TOTAL_CAD≈719.1
```

任何一个不对：

```text
STOP
```

先修txt或单位，不继续建Skeleton。

---

# 4. 默认基准面永久映射

本项目统一：

```text
Front Plane = XZ
Top Plane   = XY
Right Plane = YZ
```

所以：

```text
X方向偏置面
→ 平行Right Plane

Z方向偏置面
→ 平行Top Plane
```

这条关系永久不改。

---

# 5. 建两个永久轴

## Axis_X / FLOW_AXIS

用：

```text
Front Plane
+
Top Plane
```

两平面交线建立：

```text
Axis_X_FLOW
```

## Axis_Z / SUPPORT_AXIS

用：

```text
Front Plane
+
Right Plane
```

建立：

```text
Axis_Z_SUPPORT
```

以后球体、阀座、端法兰全部引用X轴；阀杆、前盖、底盖全部引用Z轴。

---

# 6. X向基准面——按这个顺序建

全部平行：

```text
Right Plane / YZ
```

建议名称：

```text
PLN_X_END_L             = -305
PLN_X_FLANGE_BACK_L     ≈ -273.2
PLN_X_BODY_JOINT_REF_L  = -232.5 仅结构参考，不代表第二主中法兰
PLN_X_BALL_FACE_L       = -174
PLN_X_CONTACT_L         = -166.036

Right Plane / BALL_CENTER = 0

PLN_X_CONTACT_R         = +166.036
PLN_X_BALL_FACE_R       = +174
PLN_X_BODY_JOINT        = +232.5
PLN_X_FLANGE_BACK_R     ≈ +273.2
PLN_X_END_R             = +305
```

重要：

```text
PLN_X_BODY_JOINT_REF_L=-232.5
```

只能用于左右内部几何空间参考，不允许把它理解成“左边第二个BODY_COVER接口”。

真正主BODY分界只有：

```text
PLN_X_BODY_JOINT=+232.5
```

---

# 7. Z向基准面——按当前有效口径建

全部平行：

```text
Top Plane / XY
```

下部：

```text
PLN_Z_BOTTOM_COVER_OUT_REF = -289.1
PLN_Z_BODY_BOTTOM_IF       = -270.5
PLN_Z_BOTTOM_SHOULDER      = -230.0
PLN_Z_LOW_BRG_OUT          = -227.0
PLN_Z_LOW_BRG_IN           = -177.0
```

中心：

```text
Top Plane = Z=0
```

上部：

```text
PLN_Z_UP_BRG_IN            = +193.6
PLN_Z_UP_BRG_OUT           = +223.6
PLN_Z_TOP_SHOULDER         = +226.9
PLN_Z_BODY_TOP_IF          = +264.5
PLN_Z_TOP_COVER_OUT_REF    = +300.0
PLN_Z_PACK_PRESS           = +313.3
PLN_Z_F25                  = +337.3
PLN_Z_KEY_START            = +339.8
PLN_Z_KEY_END              = +429.8
PLN_Z_STEM_TOP_REF         = +430.0
```

---

# 8. 不要再建V32错误安装面

禁止创建：

```text
BODY_TOP_IF=+227
BODY_BOTTOM_IF=-230
```

当前正确身份：

```text
+226.9 = 上支承轴→φ105 Boss肩面
-230.0 = 下支承轴→φ70 Boss肩面
```

真正安装面：

```text
+264.5
-270.5
```

---

# 9. Front/XZ主纵剖面草图

在：

```text
Front Plane
```

新建：

```text
SK_XZ_MAIN_SECTION
```

只画Construction Geometry，不急着拉实体。

必须有：

```text
球体圆：R232.5
流道上下边界：±151.5
球体左右平端：X=±174
密封接触站：X=±166.036
主BODY分界：X=+232.5
端面：X=±305
```

再叠：

```text
上轴承Z=193.6~223.6
上肩=226.9
上BODY面=264.5

下轴承Z=-227~-177
下肩=-230
下BODY面=-270.5
```

草图颜色/线型可以后续整理，第一版只要求尺寸完全驱动。

---

# 10. 主中法兰YZ草图

在：

```text
PLN_X_BODY_JOINT
```

建：

```text
SK_YZ_MAIN_JOINT
```

同心Construction圆：

```text
φ468.6  O圈槽根
φ480    主止口
φ490    缠绕垫ID
φ500    缠绕垫OD
φ526.5  M20 PCD
φ562.5  中法兰OD CAD
```

20等分点：

```text
MID_STUD_QTY=20
```

孔/螺纹最终模式在BODY和BODY_COVER零件中分别实现，不在Skeleton里造真实螺纹。

---

# 11. F25 XY草图

在：

```text
PLN_Z_F25
```

建：

```text
SK_XY_F25_PATTERN
```

Construction圆：

```text
φ300  最小接口OD
φ254  PCD
φ200  最大止口包络
φ60   键轴
```

8个孔中心：

```text
首孔22.5°
步距45°
```

孔口径Skeleton仅显示参考：

```text
M16 threaded
或
φ17.5 clearance
```

具体孔类型等厂家图。

---

# 12. 上接口XY草图

在：

```text
PLN_Z_BODY_TOP_IF
```

建：

```text
SK_XY_TOP_IF
```

当前同心参考：

```text
φ105 定位Boss
φ96.6 外O圈槽根候选
φ105 垫片ID
φ115 垫片OD
```

不要画4×M12最终孔位，因为：

```text
TOP_BODY_BOLT_PCD_FINAL=?
```

只留：

```text
4孔Pattern Placeholder
```

---

# 13. 下接口XY草图

在：

```text
PLN_Z_BODY_BOTTOM_IF
```

建：

```text
SK_XY_BOTTOM_IF
```

同心参考：

```text
φ70 定位Boss
φ61.6 O圈槽根当前C/R
φ70 垫片ID
φ80 垫片OD
```

同样：

```text
6×M12
```

只画等分占位，不锁最终BCD。

---

# 14. 第一版Envelope只做5个

不要一下生成所有零件。

第一版Skeleton建议只做：

```text
ENV_BALL
ENV_SEAT_L
ENV_SEAT_R
ENV_MAIN_BODY
ENV_F25_ADAPTER
```

第二轮再加：

```text
ENV_STEM_COVER
ENV_BOTTOM_COVER
ENV_STEM
```

原因：

> 先证明主X轴尺寸链和Side Entry装配通路稳定，再叠Z向复杂内轨。

---

# 15. Skeleton里不要做真实螺纹/O圈实体

Skeleton只负责：

```text
中心
尺寸
平面
轴
包络
孔圈
密封槽位置参考
```

不要在Skeleton里建：

```text
真实螺纹牙型
O圈实体
弹簧螺旋线
键真实倒角
螺栓头
铸造圆角
```

这些进入零件/装配层。

---

# 16. 建完Skeleton后必须测的10项

使用Evaluate → Measure：

```text
1. PLN_X_END_L ↔ PLN_X_END_R = 610
2. 球体直径 =465
3. 球体流道 =303
4. 球体→φ480主开口径向余量=7.5
5. X_BODY_JOINT=232.5
6. BODY中央外包络≈504
7. 主中法兰OD≈562.5
8. Z_BODY_TOP_IF≈264.5
9. Z_BODY_BOTTOM_IF≈-270.5
10. F25接口面≈337.3
```

全部正确再进入零件。

---

# 17. 第一版宏自动化到哪里

V43规定第一版VBA宏只允许：

```text
检查活动文档是不是Part
↓
读取/建立Global Variables
↓
创建X/Z参考基准面
↓
创建/命名Axis_X、Axis_Z
↓
建立主草图的Construction Geometry
↓
Rebuild
↓
输出日志
```

禁止第一版宏：

```text
自动修改20寸零件
自动替换44个组件
自动切真实螺纹
自动建O圈/弹簧
自动生成工程图
```

---

# 18. 为什么这样比“直接宏生成整阀”稳定

此前宏出错常见原因：

```text
旧模型特征名不一致
方程式不存在
组件数组类型差异
中文/英文特征名
配置名不同
20寸源模型不是全参数化
```

而Skeleton新建法：

```text
没有历史特征债务
没有组件替换
没有旧配合
没有20寸方程式依赖
```

所以第一版成功率远高于“改旧20寸总装”。

---

# 19. 下一步 V44

下一步可以正式输出：

```text
Q347F_12in_Class150_CreateSkeleton_V1.bas
```

目标：

```text
在你新建并打开00_SKELETON.SLDPRT后
运行宏
↓
自动创建主要全局变量与基准面
↓
生成日志
```

为了兼容中文SOLIDWORKS，宏尽量不通过“Front Plane/Top Plane”中文名称硬找特征，而优先用稳定的文档/FeatureManager对象和选择检查。

> **V43一句话结论：现在先建一个“不会错的空骨架”，比让AI一次性生成整台阀门更重要；骨架稳定后，后面每个零件只是把这套数字实体化。**
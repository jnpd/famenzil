# Q347F 12寸 Class150——第7K步：完整总装骨架 / XYZ包络 / 装配与维修路径预检查 V41

> **定位**：V31关闭BODY/BODY_COVER第一版实体尺寸，V35关闭上下盖Z向纵剖面，V40关闭连接盘/F25/键轴绝对Z。V41第一次把所有主件放进同一个XYZ总装骨架，不再只逐零件检查。
>
> **核心结论**：当前不含真实蜗轮箱壳体的12寸主总装骨架约为 `X长度610 × Y最大宽度562.5 × Z高度719`；φ480主拆装口可让φ465球体和φ380阀座通过；上/下支承Boss、F25连接盘与主中法兰不存在第一轮硬干涉。阀杆装配方向必须特别控制：防吹出肩φ74大于φ70阀杆导向孔，因此阀杆不能从执行器侧简单向下穿过已装好的φ70导向孔，必须按防吹出结构从内侧/前盖预装路径完成。

[← 总导航](./00_Q347F_12in_Class150_文档导航_从这里开始.md)  
[← 数字化总装骨架总账](./Q347F_12in_Class150_数字化总装骨架_尺寸参数_装配关系_空间坐标总账.md)  
[← V31 BODY/BODY_COVER建模尺寸表](./Q347F_12in_Class150_第7A步_BODY_BODY_COVER第一版SolidWorks建模尺寸表_V31.md)  
[← V35 上下盖完整Z剖面](./Q347F_12in_Class150_第7E步_上下盖完整Z向纵剖面_M12长度反校核_V35.md)  
[← V40 连接盘/F25绝对Z](./Q347F_12in_Class150_第7J步_连接盘Z坐标_F25接口面_M12x50与键轴站位_V40.md)

---

# 1. 当前主总装零件树

```text
00_SKELETON
├─ BODY
├─ BODY_COVER
├─ BALL
├─ LEFT_SEAT
├─ RIGHT_SEAT
├─ STEM_COVER
├─ STEM
├─ BOTTOM_COVER
├─ TOP_ADAPTER
├─ MAIN_BODY_JOINT_FASTENERS
└─ F25_GEARBOX_PLACEHOLDER
```

外购/标准件嵌入：

```text
上下轴承
止推垫
O圈
缠绕垫
弹簧
M20主中法兰组
M12上下盖组
M16 F25驱动组
平键
定位销
```

---

# 2. X方向完整骨架

```text
左RF端面                    -305
左端法兰背面约              -273.2
左内锥/座腔功能站约         -232.5
左真实球面接触中心          -166.036
球心                         0
右真实球面接触中心          +166.036
球体右平端                  +174
BODY—BODY_COVER主分界       +232.5 C+
右内锥结束约                +272.0
右端法兰背面约              +273.2
右RF端面                    +305
```

整阀：

```text
X_MIN=-305
X_MAX=+305
TOTAL_X=610
```

---

# 3. Z方向完整骨架

```text
阀杆/键最低上端包络          +430.0 C-space
键结束                       +429.8 C
键开始                       +339.8 C+
F25接口面 / 连接盘上表面     +337.3 C
连接盘下表面/填料压紧面      +313.3 C
前盖法兰外侧粗参考            +300.0 C/H-guide
BODY—STEM_COVER安装面        +264.5 C
φ100→φ105定位Boss肩面        +226.9 C+
上球体轴承                   +193.6~+223.6
球心                          0
下球体轴承                   -227.0~-177.0
φ65→φ70定位Boss肩面          -230.0 C+
底部O圈功能区                 -257.4~-261.7 C
BODY—BOTTOM_COVER安装面      -270.5 C
底盖外侧粗参考                -289.1 C/H-guide
```

不含真实齿轮箱壳体时：

```text
Z_MIN≈-289.1
Z_MAX≈+430.0
TOTAL_Z≈719.1 mm
```

---

# 4. Y / 径向最大包络

当前主要外径：

```text
BODY中央承压包络        ≈φ504
端法兰                  φ482.6
主BODY中法兰CAD         ≈φ562.5
F25连接盘               φ300
主BODY开口压力Boss      ≈φ520 CAD
```

所以不含蜗轮/手轮时，总装Y向最大当前由：

```text
MID_FLANGE_OD_CAD≈φ562.5
```

控制：

```text
Y_MIN≈-281.25
Y_MAX≈+281.25
TOTAL_Y≈562.5
```

---

# 5. 第一版总装外包络

不含厂家蜗轮箱真实壳体、手轮、脚架和吊耳最终突出量：

```text
610 × 562.5 × 719.1 mm
```

含义：

```text
X = RF-to-RF结构长度
Y = 当前主中法兰最大宽度
Z = 底盖外端到阀杆/键上端
```

状态：`C / skeleton envelope`。

不是包装运输尺寸。

---

# 6. Side Entry主拆装路径——球体

当前：

```text
主拆装孔 = φ480
球体 = φ465
```

直径余量：

```text
480-465=15mm
```

径向：

```text
7.5mm/侧
```

所以：

```text
BALL_THROUGH_MAIN_OPENING=PASS
```

这是V28以后Side Entry结构能够成立的最重要运动学门之一。

---

# 7. Side Entry主拆装路径——阀座

阀座最大当前：

```text
SEAT_BIG_OD=φ380
```

通过：

```text
φ480主开口
```

直径余量：

```text
480-380=100mm
```

径向50mm/侧。

所以：

```text
SEAT_THROUGH_MAIN_OPENING=PASS
```

左/右阀座均具备从主拆装口进入的几何条件。

---

# 8. BODY_COVER装配路径

当前：

```text
BODY孔 = φ480 H8
BODY_COVER凸止口 = φ480 f8
止口有效轴向 ≈20mm
```

径向静密封：

```text
φ466×7 O圈
槽根φ468.6
```

外侧第二密封：

```text
φ500×φ490×3.2缠绕垫
```

所以BODY_COVER沿X轴从+X向BODY推进：

```text
先导角
↓
φ480止口进入H8孔
↓
O圈进入径向密封区
↓
端面缠绕垫接触
↓
20×M20夹紧
```

第一轮：`PASS`。

---

# 9. 上支承装配空间检查

上球体轴承：

```text
Z=+193.6~+223.6
OD105 / ID100
```

上支承轴→定位Boss肩：

```text
+226.9
```

轴承外端到肩面：

```text
226.9-223.6≈3.3mm
```

然后φ105定位Boss到BODY安装面：

```text
264.5-226.9≈37.6mm
```

所以：

```text
轴承
↓3.3mm肩/过渡
长φ105承载定位Boss
↓
BODY安装面
```

没有轴向负空间。

状态：`PASS C`。

---

# 10. 下支承装配空间检查

下球体轴承：

```text
Z=-227~-177
OD70 / ID65
```

支承轴→Boss肩：

```text
Z=-230
```

轴承外端到肩：

```text
3mm
```

φ70 Boss到BODY安装面：

```text
≈40.5mm
```

O圈区：

```text
-257.4~-261.7
```

完整落在Boss范围：

```text
-230 → -270.5
```

状态：`PASS C`。

---

# 11. F25连接盘与BODY中央壳的垂向间隙

BODY中央外包络：

```text
φ504 → R≈252
```

连接盘底面：

```text
Z=+313.3
```

若仅做中心线径向包络比较：

```text
313.3-252≈61.3mm
```

所以连接盘不会直接撞入中央BODY主壳。

主中法兰最大半径：

```text
562.5/2=281.25
```

到连接盘底面：

```text
313.3-281.25≈32.05mm
```

且主中法兰中心位于：

```text
X=+232.5
```

F25连接盘只到：

```text
X≈±150
```

二者X向仍有明显分离，所以第一轮不存在实体硬撞。

---

# 12. F25连接盘与主中法兰X向检查

F25连接盘：

```text
OD300 → X/Y半径150
中心X=0
```

其X最大：

```text
+150
```

主BODY joint中心：

```text
+232.5
```

中心面差：

```text
82.5mm
```

即使主中法兰具有一定轴向厚度，当前仍有明显空间。

状态：`PASS C-screen`。

---

# 13. 最关键装配门：阀杆不能从外面穿过φ70导向孔

当前阀杆防吹出肩：

```text
STEM_SHOULDER_OD≈φ74
```

阀杆导向轴承/孔：

```text
ID≈φ65
外轴承OD≈φ70
前盖对应导向孔≈φ70
```

因为：

```text
74 > 70
```

所以：

> **φ74防吹出肩不可能从执行器侧穿过已经成形的φ70导向孔向下装入。**

这是正常的防吹出结构逻辑，不是设计错误。

---

# 14. 阀杆正确装配策略

当前CAD必须支持以下一种防吹出装配方式：

## 优先草模策略

```text
STEM从STEM_COVER内侧/靠球体侧预装
↓
防吹出肩留在φ70导向系统下方
↓
安装止推垫/轴承/O圈/填料
↓
形成STEM + STEM_COVER子装配
↓
该子装配沿-Z方向进入BODY上接口
↓
φ100上支承轴进入球体上轴承
↓
阀杆驱动头进入球体驱动槽
↓
4×M12×75夹紧STEM_COVER到BODY
```

最终具体顺序仍需前盖真实加工剖面确认，但永久禁止：

```text
从执行器顶端把完整φ74肩阀杆穿过φ70孔向下塞
```

---

# 15. 底盖装配策略

当前：

```text
下轴承预装于球体φ70下孔
```

底盖从-Z外侧向+Z推进：

```text
φ65一体支承轴
↓
进入轴承ID65
↓
φ70长Boss进入BODY下导向孔
↓
O圈进入密封工作区
↓
φ80×φ70垫片压紧
↓
6×M12×55锁紧
```

第一轮：`PASS C`。

---

# 16. 主体推荐装配顺序骨架

当前第一版装配工艺逻辑：

```text
1. BODY定位
2. 从φ480主开口装BODY侧阀座
3. 从φ480主开口装BALL
4. 完成另一侧阀座/BODY_COVER侧阀座预装
5. BODY_COVER沿X装入，完成主中法兰密封/锁紧
6. 安装BOTTOM_COVER / 下支承
7. 预装STEM + STEM_COVER子装配
8. 从+Z安装上支承/阀杆子装配
9. 安装填料压紧与TOP_ADAPTER
10. 安装F25 gearbox placeholder / 最终蜗轮
```

真实工艺中第5~8步先后可以根据支承装配要求调整；V41只关闭“必须存在的通路”，不冒充正式装配作业指导书。

---

# 17. 维修路径当前开放门

防吹出结构意味着：

```text
阀杆不允许在带压状态向外吹出
```

但“现场只拆上部是否能把阀杆完整取出”取决于：

```text
φ74肩的位置
前盖内孔台阶
球体驱动槽释放方向
上支承轴/轴承配合
```

所以：

```text
STEM_SERVICE_REMOVAL_PATH_FINAL=? D
```

当前只确认安全方向：

```text
不能简单向外拔出越过防吹出肩
```

---

# 18. V41 SolidWorks总装变量

```text
# OVERALL SKELETON ENVELOPE
ASM_X_MIN=-305
ASM_X_MAX=305
ASM_X_TOTAL=610
ASM_Y_MAX_RADIUS=281.25
ASM_Y_TOTAL=562.5
ASM_Z_MIN_CAD=-289.1
ASM_Z_MAX_CAD=430.0
ASM_Z_TOTAL_CAD=719.1

# SIDE ENTRY ASSEMBLY
MAIN_OPENING_D=480
BALL_OD=465
BALL_OPENING_CLR_D=15
BALL_OPENING_CLR_RAD=7.5
SEAT_BIG_OD=380
SEAT_OPENING_CLR_D=100
SEAT_OPENING_CLR_RAD=50

# STEM ASSEMBLY GATE
STEM_SHOULDER_OD=74
STEM_GUIDE_BORE_D≈70
STEM_TOP_DOWN_INSERT_ALLOWED=FALSE
STEM_PREASSEMBLY_WITH_COVER_REQUIRED=TRUE_CANDIDATE
STEM_SERVICE_REMOVAL_PATH_FINAL=?

# SPATIAL CLEARANCE SCREEN
BODY_CENTRAL_RADIUS_CAD=252
ADAPTER_BOTTOM_Z=313.3
BODY_TO_ADAPTER_Z_CLEAR≈61.3
MID_FLANGE_RADIUS_CAD=281.25
MID_FLANGE_TO_ADAPTER_Z_CLEAR≈32.05
F25_ADAPTER_RADIUS=150
F25_X_MAX=150
BODY_JOINT_X=232.5
F25_TO_BODY_JOINT_X_CENTER_GAP=82.5
```

---

# 19. V41当前结论

第一版完整主骨架当前没有发现以下硬冲突：

```text
球体无法通过主开口        → 否，PASS
阀座无法通过主开口        → 否，PASS
BODY_COVER止口负间隙      → 否，PASS
上下支承轴向负空间        → 否，PASS
F25连接盘撞中央BODY       → 否，PASS
F25连接盘撞主中法兰       → 第一轮否，PASS
底O圈超出Boss功能区        → 否，PASS
```

发现并正式记录：

```text
阀杆防吹出装配方向约束
```

这不是干涉错误，而是装配工艺必须遵守的结构要求。

---

# 20. 下一步 V42

下一步进入真正的SolidWorks骨架交付准备：

```text
把当前所有C+/C变量
↓
分成
A. 可直接写入方程式管理器
B. 仅Envelope参考
C. 制造冻结D变量
↓
输出统一 Global Variables 表
↓
给后续VBA宏 / 手工骨架建模直接使用
```

同时清理：

```text
被V28/V34/V40纠正的旧变量
```

确保SolidWorks方程式里只使用当前值，不会引用H/R历史值。

> **V41一句话结论：当前12寸主总装骨架在XYZ三方向第一次闭合，主体装配通路可行；下一步可以把参数真正转成SolidWorks方程式输入，而不是继续停留在Markdown计算页。**
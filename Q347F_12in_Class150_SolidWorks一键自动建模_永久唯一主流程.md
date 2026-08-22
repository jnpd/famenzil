# Q347F 12寸 Class150——SolidWorks 一键自动建模永久唯一主流程（当前统一版）

> **定位**：本文件是 Q347F / NPS12 / DN300 / Class150 固定球阀 SolidWorks 自动建模的永久唯一执行主流程。  
> **最新用户实机验证**：`S00 PASS / S01 PASS / S02 PASS / S03 PASS`。  
> **当前代码实现**：S04 BALL 已完成并接入主流程，尚待下一次用户本机运行确认 PASS/FAIL。  
> **未实现**：S05～S12。  
> **正式路线**：`BAT → Windows PowerShell 5.1 → 内嵌C# → SolidWorks COM API → SOLIDWORKS 2025`。

[← 总导航](./00_Q347F_12in_Class150_文档导航_从这里开始.md)  
[← 当前数字总账](./Q347F_12in_Class150_数字化总装骨架_尺寸参数_装配关系_空间坐标总账.md)  
[← V42 参数交付](./Q347F_12in_Class150_第7L步_SolidWorks全局变量交付版_当前CAD_D门与HR隔离_V42.md)  
[← V43 Skeleton规则](./Q347F_12in_Class150_第7M步_SolidWorks_Skeleton手工稳定建模顺序_宏自动化边界_V43.md)

---

# 1. 唯一用户入口

```text
SolidWorks_AutoBuild_Q347F_12in/一键生成12寸Q347F.bat
```

调用：

```text
01_scripts/Build_Q347F_12in.ps1
```

VBA只用于API试验/诊断，不是正式一键构建主路线。

---

# 2. 永久S00～S12链

```text
S00 环境预检查
↓
S01 参数读取 / 快照 / SHA256 / 工程逻辑检查
↓
S02 连接或启动 SOLIDWORKS 2025
↓
S03 创建并验证 00_SKELETON.SLDPRT
↓
S04 创建并验证 01_BALL.SLDPRT
↓
S05 左右 SEAT
↓
S06 BODY
↓
S07 BODY_COVER
↓
S08 STEM / STEM_COVER / BOTTOM_COVER
↓
S09 ADAPTER / F25
↓
S10 SLDASM / 自动配合
↓
S11 Rebuild / What's Wrong / Feature Error / 干涉 / 间隙 / 运动
↓
S12 保存 / 发布 / 汇总报告
```

---

# 3. 当前开发状态与验证状态必须分开

| Step | 代码实现 | 最新用户实机验证 |
|---|---|---|
| S00 | 已实现 | PASS |
| S01 | 已实现 | PASS |
| S02 | 已实现 | PASS |
| S03 Skeleton | 已实现 | PASS |
| S04 BALL | **已实现并接入** | **待验证** |
| S05～S12 | 未实现 | WAITING |

因此：

```text
“代码里有S04” ≠ “S04已经PASS”
```

只有真实日志通过所有 S04 PASS 门后才能升级状态。

---

# 4. 数据权威链

```text
项目输入 / 标准 / 公司规则
↓
设计计算主线
↓
数字化总账
↓
Q347F_12in_Class150_00_SKELETON_GlobalVariables_V1.txt
↓
S01参数快照
↓
SolidWorks
```

CAD状态允许：

```text
A / A-policy / B / C+ / C / 明确批准的C-space
```

默认禁止自动写死：

```text
D / H / H-R / 未关闭R
```

**CAD_DRAFT ≠ MANUFACTURING_FREEZE。**

---

# 5. S00环境预检查

必须检查：

```text
Windows / 64-bit PowerShell Desktop
PowerShell Parser
build lock
build_config.json
SolidWorks 2025路径
Interop sldworks/swconst DLL
输出目录/磁盘空间
内嵌C#编译
```

SolidWorks路径按：

```text
exePath
↓
installDir\SLDWORKS.exe
↓
autoDiscoverFallback
```

换机器只改配置，不改主程序。

---

# 6. S01参数

唯一参数源：

```text
Q347F_12in_Class150_00_SKELETON_GlobalVariables_V1.txt
```

每次保存：

```text
parameters_snapshot.txt
SHA256
```

关键逻辑至少：

```text
F2F=610 → HALF=305
480 > 465
500 > 490
105 > 100
70 > 65
Z_BODY_TOP_IF=+264.5
Z_BODY_BOTTOM_IF=-270.5
```

---

# 7. S02 SolidWorks连接

当前实现：

```text
优先附着已运行实例
↓
否则启动 SldWorks.Application
↓
RevisionNumber必须33.x
↓
解析Part模板
```

PowerShell只做编排，SolidWorks强类型COM转换尽量封装在C#内部，避免 `System.__ComObject` Binder问题。

---

# 8. S03 Skeleton

输出：

```text
02_output/00_SKELETON.SLDPRT
```

项目坐标：

```text
O=(0,0,0)
X=FLOW_AXIS
Y=CROSS_AXIS
Z=SUPPORT_AXIS
```

X站位11个：

```text
-305 -273.2 -232.5 -174 -166.036 0 +166.036 +174 +232.5 +273.2 +305
```

Z站位16个：

```text
-289.1 -270.5 -230 -227 -177 0 +193.6 +223.6 +226.9 +264.5 +300 +313.3 +337.3 +339.8 +429.8 +430
```

---

# 9. SolidWorks原生平面永久规则

禁止：

```text
Front=XZ
Top=XY
Right=YZ
```

正确：

```text
读取原生RefPlane真实世界几何
↓
识别XY/XZ/YZ
↓
建立项目语义基准面
```

项目长期只认：

```text
PLN_BASE_XY_FLOW_CROSS
PLN_BASE_XZ_FLOW_SUPPORT
PLN_BASE_YZ_CROSS_SUPPORT
AXIS_X_FLOW
AXIS_Z_SUPPORT
SK_PT_BALL_CENTER_O
```

---

# 10. S03已实机PASS的证据

```text
X world-coordinate readback = 11/11 PASS
Z world-coordinate readback = 16/16 PASS
RefPlaneCount=33
RefAxisCount=2
ForceRebuild PASS
Feature errors=0
What's Wrong errors=0
warnings=0
```

所以S03不是“保存成功就算PASS”。

---

# 11. S04 BALL——代码已经实现

当前主脚本：

```text
Build_Q347F_12in.ps1
```

已经：

```text
加载 Q347F_SwBallApi.ps1
加载 Q347F_Stage_S04.ps1
编译S04内嵌C#层
在S03后实际调用 Invoke-S04
```

所以当前工作是：

> **运行并验证S04，不是再“计划写S04”。**

---

# 12. S04当前参数——唯一口径

```text
BALL_OD=465
BALL_W_X=348
BORE_D=303

BALL_UPPER_BORE_D=105
BALL_UPPER_BORE_DEPTH=30

BALL_LOWER_BORE_D=70
BALL_LOWER_BORE_DEPTH=52

BALL_DRIVE_SLOT_L_X=70
BALL_DRIVE_SLOT_W_Y=44
BALL_DRIVE_SLOT_R=8
BALL_DRIVE_SLOT_DEPTH=27
```

状态：

```text
φ105 / φ70 = 当前接口链 C/C+
30 / 52 / 70×44 / R8 / 27 = CAD-draft candidates
```

不自动制造冻结。

---

# 13. S04当前Feature设计

```text
BALL_CORE
CUT_BORE_D303
CUT_UPPER_SUPPORT_BORE_D105
CUT_UPPER_DRIVE_SLOT_CORE_X
CUT_UPPER_DRIVE_SLOT_CORE_Y
CUT_UPPER_DRIVE_SLOT_70x44_R8
CUT_LOWER_SUPPORT_BORE_D70
```

驱动槽由两个核心矩形 + 四个R8角圆组合切除形成，最终参数仍来自 GlobalVariables。

---

# 14. S04 PASS门

必须真实运行满足：

```text
01_BALL.SLDPRT创建成功
必须Feature全部存在
SolidBodyCount=1
X width≈348
Y envelope≈465
Z envelope与上下支承孔切除后的解析值一致
ForceRebuild PASS
Feature errors=0
What's Wrong errors=0
staging保存成功
publish成功
```

没有真实日志前不写 `S04 PASS`。

---

# 15. S05～S09后续零件原则

以后仍保持：

```text
Skeleton语义定位
↓
Part Builder
↓
关键几何Readback
↓
Rebuild
↓
What's Wrong / Feature Error
↓
staging
↓
PASS后publish
```

SEAT / BODY / BODY_COVER / Z Parts / ADAPTER 不允许跳过这套门。

---

# 16. S10总装原则

基础件：BODY。

装配优先依赖：

```text
项目语义轴
项目语义面
命名接口
同轴
端面重合
限定距离
```

禁止长期依赖：

```text
Face1 / Face2 / Edge7 / 随机拓扑ID
```

---

# 17. S11验证

至少：

```text
ForceRebuild
What's Wrong
Feature Error
Interference Detection
关键尺寸Readback
关键间隙
装配路径
运动方向
```

重点：

```text
BALL φ465通过φ480
SEAT球面接触
BODY_COVER止口
主O圈槽金属余量
M20圈与垫片
上下Boss
阀杆防吹出方向
F25与前盖/阀杆干涉
```

---

# 18. staging → validate → publish

所有关键模型：

```text
创建到staging
↓
验证
↓
PASS
↓
备份current
↓
publish
```

当前：

```text
00_SKELETON_staging.SLDPRT → 00_SKELETON.SLDPRT
01_BALL_staging.SLDPRT     → 01_BALL.SLDPRT
```

失败不得覆盖上一版PASS。

---

# 19. 日志状态

运行态只认：

```text
WAITING / RUNNING / PASS / WARN / FAIL / BLOCKED / SKIP
```

其中“代码已实现/未实现”是开发状态，不能与运行态混为一谈。

---

# 20. Resume

```text
一键生成12寸Q347F.bat resume
```

S00/S01/S02永远重检。

S03/S04只有：

```text
上次PASS
+
参数SHA256一致
+
最终文件存在
```

才能SKIP。

---

# 21. 当前结论

本项目已经真实跑通：

```text
工程参数
↓
参数txt
↓
PowerShell + C#
↓
SOLIDWORKS 2025
↓
00_SKELETON.SLDPRT
↓
世界坐标Readback
↓
Rebuild / What's Wrong
↓
S03 PASS
```

同时 S04 BALL 代码已经接入。

**下一步唯一动作：在用户本机运行当前版本，验证 S04 BALL 是否 PASS。**
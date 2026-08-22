# Q347F 12寸 Class150——SolidWorks 一键自动建模永久唯一主流程（当前统一版）

> **定位**：本文件是 Q347F / NPS12 / DN300 / Class150 固定球阀 SolidWorks 自动建模的**永久唯一执行主流程**。  
> 后续所有 BAT、PowerShell、内嵌C#、SolidWorks COM API、零件构建器、总装构建器、日志、断点续跑和验证都服从本文。  
> **当前实机里程碑**：`S00 PASS / S01 PASS / S02 PASS / S03 PASS`；`00_SKELETON.SLDPRT` 已通过世界坐标回读、Rebuild、What's Wrong 后发布。  
> **当前下一步**：S04 BALL。S04～S12 尚未宣布实机 PASS。

[← 总导航](./00_Q347F_12in_Class150_文档导航_从这里开始.md)  
[← 当前数字总账](./Q347F_12in_Class150_数字化总装骨架_尺寸参数_装配关系_空间坐标总账.md)  
[← V42 参数交付](./Q347F_12in_Class150_第7L步_SolidWorks全局变量交付版_当前CAD_D门与HR隔离_V42.md)  
[← V43 Skeleton实机规则](./Q347F_12in_Class150_第7M步_SolidWorks_Skeleton手工稳定建模顺序_宏自动化边界_V43.md)

---

# 1. 用户唯一入口

正式入口：

```text
SolidWorks_AutoBuild_Q347F_12in/一键生成12寸Q347F.bat
```

调用：

```text
01_scripts/Build_Q347F_12in.ps1
```

永久技术路线：

```text
Windows BAT
↓
Windows PowerShell 5.1
↓
模块化 PowerShell 总控
↓
内嵌 C# SolidWorks Adapter
↓
SolidWorks COM API
↓
SOLIDWORKS 2025
```

VBA：

```text
只用于API试验 / 单零件诊断 / 人工辅助
不作为正式一键构建主路线
```

---

# 2. 永久S00～S12构建链

```text
S00 环境预检查
↓
S01 参数读取 / 解析 / 工程逻辑检查
↓
S02 连接或启动 SOLIDWORKS 2025
↓
S03 创建并验证 00_SKELETON.SLDPRT
↓
S04 创建 01_BALL.SLDPRT
↓
S05 创建左右 SEAT
↓
S06 创建 BODY
↓
S07 创建 BODY_COVER
↓
S08 创建 STEM / STEM_COVER / BOTTOM_COVER
↓
S09 创建 ADAPTER / F25接口
↓
S10 创建 SLDASM / 自动配合
↓
S11 Rebuild / What's Wrong / Feature Error / 干涉 / 关键间隙
↓
S12 保存 / 发布 / 汇总报告
```

这条核心顺序不随意改变。

---

# 3. 当前真实开发状态

| Step | 内容 | 当前状态 |
|---|---|---|
| S00 | 环境预检查 | **PASS** |
| S01 | 参数读取与校验 | **PASS** |
| S02 | SolidWorks 2025连接 | **PASS** |
| S03 | Skeleton | **PASS** |
| S04 | BALL | **WAITING / 下一实施** |
| S05 | SEAT | WAITING |
| S06 | BODY | WAITING |
| S07 | BODY_COVER | WAITING |
| S08 | STEM / STEM_COVER / BOTTOM_COVER | WAITING |
| S09 | ADAPTER / F25 | WAITING |
| S10 | Assembly | WAITING |
| S11 | 完整验证 | WAITING |
| S12 | 发布/报告 | WAITING |

**禁止用“设计文档已经有尺寸”冒充对应自动构建 Step 已 PASS。**

---

# 4. 数据权威链

自动化不能自己决定设计尺寸。

永久权威链：

```text
项目输入 / 标准 / 公司规则
↓
设计计算主线
↓
数字化总装总账
↓
Q347F_12in_Class150_00_SKELETON_GlobalVariables_V1.txt
↓
S01参数快照
↓
SolidWorks
```

参数txt是当前CAD执行输入，不是完整工程计算书。

状态权限：

```text
A / A-policy / B / C+ / C
→ 按当前规则可进入CAD草模

D / H / H-R / 未关闭R
→ 禁止自动写死
```

CAD候选不等于制造冻结。

---

# 5. S00——环境预检查

必须检查：

```text
Windows
64-bit PowerShell Desktop
构建锁
build_config.json
SolidWorks 2025安装/可发现路径
SolidWorks.Interop.sldworks.dll
SolidWorks.Interop.swconst.dll
输出目录可写
磁盘空间
所有PowerShell脚本Parser预检
内嵌C#可编译
```

当前安装路径允许配置，例如：

```text
C:\Program Files\sw2025\SOLIDWORKS Corp 2025\SOLIDWORKS
```

路径规则：

```text
显式exePath
↓
installDir\SLDWORKS.exe
↓
自动发现fallback
```

换机器只改配置，不改主程序。

---

# 6. S01——参数读取与工程校验

当前唯一参数源：

```text
Q347F_12in_Class150_00_SKELETON_GlobalVariables_V1.txt
```

每次运行保存：

```text
parameters_snapshot.txt
SHA256
```

必须检查至少：

```text
VALVE_F2F=610
BORE_D=303
BALL_OD=465
BALL_R=232.5
X_BODY_JOINT_CAD=232.5
MAIN_OPENING_D=480
MID_GASKET_OD=500
MID_BCD_CAD=526.5
UP_BRG_OD=105
LOWER_BRG_OD=70
Z_BODY_TOP_IF_CAD=264.5
Z_BODY_BOTTOM_IF_CAD=-270.5
F25_BOLT_PCD=254
Z_STEM_TOP_CAD=430
```

逻辑校验：

```text
480 > 465
610/2 = 305
500 > 490
105 > 100
70 > 65
+264.5 > 0
-270.5 < 0
```

矛盾时 `BLOCKED`，禁止继续。

---

# 7. S02——SolidWorks 2025连接

行为：

```text
优先尝试附着已运行的SolidWorks实例
↓
无可用实例则通过ProgID启动
↓
检查 RevisionNumber
↓
必须为SW2025对应33.x
↓
解析Part模板
```

Interop DLL必须显式加载/可解析，避免“编译成功但运行时找不到StrongName程序集”。

PowerShell与COM边界规则：

> PowerShell负责总控，SolidWorks强类型COM转换尽量留在内嵌C#中，避免 `System.__ComObject` 被 PowerShell Binder 强转为 `SldWorks/ModelDoc2` 失败。

当前实机：

```text
Revision=33.5.0
模板=C:\ProgramData\SolidWorks\SOLIDWORKS 2025\templates\gb_part.prtdot
S02 PASS
```

---

# 8. S03——Skeleton永久定义

输出：

```text
02_output/00_SKELETON.SLDPRT
```

必须保存：

```text
O=(0,0,0)
X=FLOW_AXIS
Y=CROSS_AXIS
Z=SUPPORT_AXIS
F2F=610
BALL φ465
BORE φ303
BODY外包络 φ504 CAD
MID FLANGE φ562.5 CAD
F25 φ300 CAD
```

X站位：

```text
-305, -273.2, -232.5, -174, -166.036,
0,
+166.036, +174, +232.5, +273.2, +305
```

Z站位：

```text
-289.1, -270.5, -230, -227, -177,
0,
+193.6, +223.6, +226.9, +264.5,
+300, +313.3, +337.3, +339.8, +429.8, +430
```

---

# 9. SolidWorks原生平面永久规则

禁止硬编码：

```text
Front=XZ
Top=XY
Right=YZ
```

正确：

```text
读取原生RefPlane真实世界几何
↓
识别XY / XZ / YZ
↓
建立项目语义面
```

项目只长期认：

```text
PLN_BASE_XY_FLOW_CROSS
PLN_BASE_XZ_FLOW_SUPPORT
PLN_BASE_YZ_CROSS_SUPPORT
AXIS_X_FLOW
AXIS_Z_SUPPORT
SK_PT_BALL_CENTER_O
```

这条规则已由 S03 实机纠错并验证。

---

# 10. S03为什么是真PASS而不是“文件保存了”

当前实机结果：

```text
X站位世界坐标回读 = 11/11 PASS
Z站位世界坐标回读 = 16/16 PASS
RefPlaneCount=33
RefAxisCount=2
ForceRebuild PASS
Feature errors=0
What's Wrong errors=0
warnings=0
```

最终才发布：

```text
00_SKELETON.SLDPRT
```

所以成功标准永久是：

```text
CREATE
+
独立几何READBACK
+
REBUILD
+
FEATURE ERROR
+
WHAT'S WRONG
+
SAVE/PUBLISH
```

而不是“API返回一个Feature对象”就算成功。

---

# 11. EquationMgr永久实现规则

当前已实机解决：

```text
单配置新Part的全局变量导入路径
Add2 / Add3场景区别
角度deg参数规范化
COM对象强类型边界
```

当前参数txt可以保留工程可读单位语义；导入器负责转换为 SolidWorks 接受的表达。

不要在零件特征树还不存在时预先写死：

```text
D1@Sketch7
D2@Boss-Extrude14
```

第一阶段以 Global Variables 为主，具体零件构建器再创建自己的命名特征。

---

# 12. S04 BALL——下一实施阶段

输出：

```text
01_BALL.SLDPRT
```

主结构：

```text
BALL_OD=465
BORE_D=303
BALL_W_X=348
BALL_UPPER_BORE_D=105
BALL_LOWER_BORE_D=70
```

当前CAD草模候选：

```text
UPPER_BORE_DEPTH=30
LOWER_BORE_DEPTH=52
DRIVE_SLOT=70×44
R8
DEPTH=27
```

这些值可进入 S04 第一版模型，但必须标记：

```text
CAD_DRAFT
≠ MANUFACTURING_FREEZE
```

S04 PASS条件至少：

```text
模型创建成功
φ465回读
φ303回读
宽348回读
φ105/φ70孔径回读
驱动接口存在
ForceRebuild PASS
Feature errors=0
What's Wrong errors=0
保存成功
```

---

# 13. S05 SEAT

输出可以是左右独立装配对象或参数化共用零件的左右实例。

关键：

```text
D9=323.88
D10=327.13
D11=342
Guide=342.4
Pilot2=323.6
Guide2=323.8
Big OD=380
Big Bore=382
Spring PCD=362
X_CONTACT=±166.036
```

验证：

```text
左右方向正确
真实球面接触位置正确
导向正确
轴向浮动空间存在
无镜像错误
```

---

# 14. S06 BODY

至少创建：

```text
左NPS12 Class150 RF端
φ303流道
φ471功能球腔CAD
φ504中央外包络CAD
左右SEAT功能腔
φ480主拆装口
主中法兰
20×M20 BODY锚固孔
上φ105接口
下φ70接口
VENT / DRAIN Boss
```

BODY是关键承压零件，必须把“CAD创建成功”和“最终承压制造冻结”分开。

---

# 15. S07 BODY_COVER

至少：

```text
φ480 f8凸止口
φ466×7径向O圈槽
φ500×φ490×3.2垫片接口
20×φ22通孔 / 螺母支承区
右NPS12 Class150 RF端
φ382→φ303内过渡
```

验证：

```text
BALL φ465可通过φ480
H8/f8定位逻辑正确
O圈槽不切穿
垫片/螺栓圈不冲突
```

---

# 16. S08 Z向零件

包括：

```text
STEM
STEM_COVER
BOTTOM_COVER
```

关键语义：

```text
STEM_COVER一体φ100上支承轴
φ105定位Boss
BODY安装面Z≈+264.5

BOTTOM_COVER一体φ65下支承轴
φ70定位Boss
BODY安装面Z≈-270.5

STEM主径≈65
键轴≈60
18×11×90单键设计
```

---

# 17. S09 ADAPTER/F25

当前CAD方案：

```text
OD≈300
T≈24
PCD254
8×M16
Z_F25≈337.3
```

厂家蜗轮箱正式接口未关闭前，不能升级为采购冻结。

---

# 18. S10自动总装

输出：

```text
12-Q347F-150LB-总装图.SLDASM
```

优先插入：

```text
BODY
BALL
SEAT L/R
BODY_COVER
STEM_COVER
BOTTOM_COVER
STEM
ADAPTER
标准件 / 密封 / 轴承 / 紧固件
```

装配约束必须依赖稳定语义：

```text
项目轴
项目基准面
命名接口
同轴
端面重合
限定距离
```

禁止长期依赖随机：

```text
Face1
Face2
Edge7
```

---

# 19. S11验证

自动验证至少包括：

```text
ForceRebuild
What's Wrong
Feature Error
Interference Detection
关键尺寸回读
关键间隙
装配路径
运动方向
```

重点：

```text
BALL通过φ480
SEAT与球面接触
BODY_COVER止口可装入
主O圈槽金属余量
M20圈与垫片不冲突
上下Boss不碰球体/轴承
阀杆防吹出方向正确
F25与阀杆/前盖不干涉
```

---

# 20. S12保存 / 发布 / 报告

正式运行保留：

```text
参数快照
参数SHA256
staging模型
上一版成功模型备份
本次发布模型
build.log
summary.json
错误/验证汇总
```

禁止：

```text
构建失败后覆盖上一版PASS模型
```

---

# 21. staging → validate → publish

所有关键零件建议统一：

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

S03已经实际采用：

```text
03_backup/run_xxx/00_SKELETON_staging.SLDPRT
↓
02_output/00_SKELETON.SLDPRT
```

后续零件沿用同样机制。

---

# 22. 日志状态永久只认

```text
WAITING
RUNNING
PASS
WARN
FAIL
BLOCKED
SKIP（仅明确配置允许）
```

失败默认停止。

禁止：

```text
API失败后静默跳过
红叉特征仍写PASS
D参数自动填0继续
```

---

# 23. 断点续跑

入口支持：

```text
一键生成12寸Q347F.bat resume
```

状态文件：

```text
02_output/build_state.json
```

必须结合：

```text
Step状态
参数SHA256
已有发布模型
依赖关系
```

如果 Skeleton 参数发生变化，后续依赖件必须标记 `STALE` 并重建。

---

# 24. 本轮已经实际解决的自动化问题

```text
PowerShell变量冒号Parser错误
CMD中文乱码
SolidWorks自定义安装路径
Interop DLL运行时装载
PowerShell System.__ComObject强类型转换
EquationMgr Add2/Add3场景
角度deg表达
原生Front/Top/Right错误映射
RefPlane坐标回读错误
失败覆盖成功模型风险
重复从头执行问题
```

这些属于自动化实现问题，没有证据要求因此推翻现有核心设计计算值。

---

# 25. 最终定义

本项目的一键自动建模不是：

```text
AI生成一个看起来像阀门的3D外形
```

而是：

```text
工程计算
↓
数字总账
↓
受控CAD参数
↓
PowerShell + C# + COM API
↓
真实SLDPRT / SLDASM特征树
↓
独立几何回读
↓
Rebuild / What's Wrong / 干涉
↓
staging / backup / publish
↓
可追溯日志与报告
```

**当前已经把这条链真实跑通到 S03 Skeleton；下一步只推进 S04 BALL。**
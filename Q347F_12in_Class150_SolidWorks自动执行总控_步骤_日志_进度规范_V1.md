# Q347F 12寸 Class150——SolidWorks 自动执行总控 / 步骤 / 日志 / 进度规范 V1（当前统一版）

> **用途**：本文件规定自动构建如何执行、如何显示进度、如何判定 PASS/FAIL、如何断点续跑和如何发布模型。它不是工程计算书。  
> **正式路线**：`BAT → PowerShell 5.1 → 内嵌C# → SOLIDWORKS COM API`。  
> **当前实机基线**：`S00 PASS / S01 PASS / S02 PASS / S03 PASS`；S04～S12 仍为 WAITING。  
> **当前输出**：`02_output/00_SKELETON.SLDPRT` 已通过世界坐标回读、Rebuild、What's Wrong。

---

# 1. 用户操作原则

正常用户只需要：

```text
1. 双击 一键生成12寸Q347F.bat
2. 看实时日志/进度
3. 失败时保留最新 04_logs/run_xxx
```

断点恢复：

```text
一键生成12寸Q347F.bat resume
```

---

# 2. 目录约定——以当前仓库为准

```text
SolidWorks_AutoBuild_Q347F_12in/
├─ 一键生成12寸Q347F.bat
├─ 00_config/
│  └─ build_config.json
├─ 01_scripts/
│  ├─ 00_Preflight_Parse.ps1
│  ├─ Build_Q347F_12in.ps1
│  └─ lib/
│     ├─ Q347F_Common.ps1
│     ├─ Q347F_Config.ps1
│     ├─ Q347F_SwSessionApi.ps1
│     ├─ Q347F_SwEquationApi.ps1
│     ├─ Q347F_SwGeometryApi.ps1
│     ├─ Q347F_SwValidationApi.ps1
│     ├─ Q347F_Stages_S00_S02.ps1
│     └─ Q347F_Stage_S03.ps1
├─ 02_output/
│  ├─ 00_SKELETON.SLDPRT
│  └─ build_state.json
├─ 03_backup/
│  └─ run_YYYYMMDD_HHMMSS/
└─ 04_logs/
   └─ run_YYYYMMDD_HHMMSS/
      ├─ build.log
      ├─ summary.json
      └─ parameters_snapshot.txt
```

S04以后继续模块化扩展，不把所有逻辑重新塞回一个超长主PS1。

---

# 3. 状态只认这7种

| 状态 | 含义 | 默认行为 |
|---|---|---|
| `WAITING` | 未执行 | 等待 |
| `RUNNING` | 正执行 | 继续 |
| `PASS` | 执行并验证通过 | 继续 |
| `WARN` | 有非阻塞风险 | 继续但记录 |
| `FAIL` | 实现/几何/验证失败 | **停止** |
| `BLOCKED` | 环境/参数/前置条件不足 | **停止** |
| `SKIP` | 明确配置允许不执行 | 仅显式允许 |

永久禁止：

```text
失败后悄悄跳过
API报错但日志写PASS
红叉Feature仍发布
D参数填0继续
没有验证就覆盖上一版PASS模型
```

---

# 4. 参数状态与自动构建权限

当前工程状态：

```text
A / A-policy / B / C+ / C / C-space / P / P-XREF / D / R / H / H-R
```

CAD_DRAFT允许：

```text
A
A-policy
B
C+
C
明确批准的C-space/CAD envelope
```

默认禁止：

```text
D
H
H/R
未关闭的R
```

若关键参数为：

```text
?
空值
D
H/R
工程上非法的0
```

必须：

```text
BLOCKED
记录参数名/来源/依赖
停止当前链
```

---

# 5. 总进度区间

| Step | 内容 | 进度 |
|---|---|---:|
| S00 | 环境预检查 | 0% → 5% |
| S01 | 参数读取/校验 | 5% → 10% |
| S02 | SolidWorks连接 | 10% → 15% |
| S03 | Skeleton | 15% → 25% |
| S04 | BALL | 25% → 34% |
| S05 | SEAT | 34% → 43% |
| S06 | BODY | 43% → 57% |
| S07 | BODY_COVER | 57% → 67% |
| S08 | STEM/STEM_COVER/BOTTOM_COVER | 67% → 78% |
| S09 | ADAPTER/F25 | 78% → 84% |
| S10 | Assembly/Mates | 84% → 92% |
| S11 | Rebuild/What's Wrong/Interference | 92% → 98% |
| S12 | Save/Publish/Report | 98% → 100% |

当前里程碑成功停止在：

```text
25%
S00 PASS
S01 PASS
S02 PASS
S03 PASS
S04-S12 WAITING
```

---

# 6. 日志固定格式

```text
[时间][Step][对象][进度][状态] 消息
```

例如：

```text
[15:08:35][S03][READBACK][23%][PASS] Required station planes verified by feature name and world-coordinate readback. X=11, Z=16.
[15:08:36][S03][WHATS_WRONG][24%][PASS] Rebuild PASS; What's Wrong/Feature errors=0; warnings=0.
[15:08:37][S03][SAVE][25%][PASS] 00_SKELETON.SLDPRT published.
```

失败日志必须给：

```text
Step
对象/Feature
API或验证点
实际值
期望值
错误码/异常
停止动作
日志目录
```

---

# 7. S00——环境预检查

检查：

```text
Windows
PowerShell Desktop/64-bit
脚本Parser
build lock
build_config.json
SolidWorks exe
Interop DLL
输出目录
磁盘空间
内嵌C#编译
```

当前配置路径优先级：

```text
solidWorks.exePath
↓
solidWorks.installDir\SLDWORKS.exe
↓
autoDiscoverFallback
```

Interop解析：

```text
配置/安装目录候选
↓
Assembly.LoadFrom
↓
AssemblyResolve兜底
```

S00不能再把SolidWorks固定写死在默认Program Files路径。

---

# 8. 启动前Parser预检

BAT先运行：

```text
01_scripts/00_Preflight_Parse.ps1
```

目的：

```text
在连接SolidWorks之前
一次性解析所有PS1
```

防止类似：

```text
$lineNo:
```

被PowerShell解释成非法变量作用域语法。

---

# 9. S01——参数读取 / 快照 / SHA256

主输入：

```text
../Q347F_12in_Class150_00_SKELETON_GlobalVariables_V1.txt
```

S01必须：

```text
解析Global Variables
解析单位/表达式
保存parameters_snapshot.txt
保存参数源SHA256
执行关键数字检查
执行工程逻辑检查
```

关键参数至少：

```text
VALVE_F2F=610
BORE_D=303
BALL_OD=465
BALL_R=232.5
X_BODY_JOINT_CAD=232.5
MAIN_OPENING_D=480
MID_GASKET_ID=490
MID_GASKET_OD=500
MID_BCD_CAD=526.5
UP_BRG_OD/ID=105/100
LOWER_BRG_OD/ID=70/65
Z_BODY_TOP_IF_CAD=264.5
Z_BODY_BOTTOM_IF_CAD=-270.5
F25_BOLT_PCD=254
Z_STEM_TOP_CAD=430
```

逻辑：

```text
480>465
610/2=305
500>490
105>100
70>65
264.5>0
-270.5<0
```

---

# 10. S02——连接/启动SOLIDWORKS 2025

当前实现：

```text
Marshal.GetActiveObject("SldWorks.Application")
↓ 若无实例
Activator.CreateInstance(Type.GetTypeFromProgID("SldWorks.Application"))
```

然后检查：

```text
RevisionNumber必须33.x
PID
Visibility
默认/配置Part template
LatestSupportedFileVersion
```

当前实机：

```text
ATTACH/START_NEW均已验证可行
Revision=33.5.0
Part template=C:\ProgramData\SolidWorks\SOLIDWORKS 2025\templates\gb_part.prtdot
```

COM边界原则：

> PowerShell不承担SolidWorks强类型接口绑定。`System.__ComObject` 在PowerShell侧只做编排，强类型转换封装在C#内部。

---

# 11. S03——Skeleton创建

输出：

```text
00_SKELETON.SLDPRT
```

必须：

```text
球心 O
项目X/Z轴
3个项目语义基准面
11个X站位面
16个Z站位面
BALL/BORE/BODY/MID FLANGE包络
F25包络
```

X：

```text
-305 -273.2 -232.5 -174 -166.036 0
+166.036 +174 +232.5 +273.2 +305
```

Z：

```text
-289.1 -270.5 -230 -227 -177 0
+193.6 +223.6 +226.9 +264.5 +300 +313.3
+337.3 +339.8 +429.8 +430
```

---

# 12. 原生平面识别——禁止按名称猜

旧硬编码：

```text
Front=XZ
Top=XY
Right=YZ
```

现为：

```text
H/R
```

当前算法：

```text
读取原生RefPlane真实世界几何
↓
识别其实际XY/XZ/YZ
↓
建立项目语义面
```

项目名：

```text
PLN_BASE_XY_FLOW_CROSS
PLN_BASE_XZ_FLOW_SUPPORT
PLN_BASE_YZ_CROSS_SUPPORT
```

---

# 13. S03 Readback——独立验证是强制的

创建Feature之后必须：

```text
ForceRebuild
↓
按Feature name找到要求平面
↓
用世界几何/CornerPoints回读实际坐标
↓
actual vs expected
↓
容差检查
```

不能只依赖 `RefPlane.Transform.ArrayData` 某个分量直接当位移。

当前实际结果：

```text
X=11 PASS
Z=16 PASS
```

---

# 14. S03 PASS条件——当前已经实机满足

```text
新Part创建成功
参数导入成功
球心/轴/面创建成功
11 X站位回读PASS
16 Z站位回读PASS
ForceRebuild PASS
Feature error=0
What's Wrong error=0
warning=0
staging保存成功
publish成功
```

最终：

```text
RefPlaneCount=33
RefAxisCount=2
```

---

# 15. EquationMgr当前实现规范

本轮已确认：

```text
新Part/单配置环境不能机械套用错误Add3路径
当前场景使用匹配的Add2导入策略
角度deg需在导入层规范化
```

参数源保持工程可读；SolidWorks适配层负责API兼容。

若：

```text
EquationMgr.Status != 成功
```

必须抛出具体：

```text
source line
parameter name
equation text
EquationCount
Status
```

并 FAIL。

---

# 16. staging / backup / publish

S03当前已经使用：

```text
03_backup/run_xxx/00_SKELETON_staging.SLDPRT
```

只有验证全部PASS后才发布：

```text
02_output/00_SKELETON.SLDPRT
```

发布前若已有上一版PASS：

```text
先备份
再替换
```

失败不污染current。

---

# 17. build_state / Resume

状态：

```text
02_output/build_state.json
```

Resume至少检查：

```text
上次Step状态
参数SHA256
已发布文件是否存在
依赖是否过期
```

参数源变化后：

```text
S03及其依赖链可标记STALE
```

以后进入S04+后应逐步升级为依赖图，而不是简单“从下一编号继续”。

---

# 18. S04 BALL规范——下一实施

第一版要求：

```text
BALL_OD=465
BORE_D=303
BALL_W_X=348
UPPER_BORE_D=105
LOWER_BORE_D=70
```

当前CAD候选：

```text
UPPER_BORE_DEPTH=30
LOWER_BORE_DEPTH=52
DRIVE_SLOT=70×44
R8
DEPTH=27
```

注意：这些后四类为CAD候选，**不因写入参数源就变成制造冻结值**。

S04验证至少：

```text
Bounding/geometry size
φ465
φ303
width=348
φ105
φ70
驱动接口存在
Rebuild
Feature errors
What's Wrong
Save
```

---

# 19. 后续Step验证原则

每个Part永远执行：

```text
CREATE
↓
REBUILD
↓
关键尺寸/位置READBACK
↓
Feature Error
↓
What's Wrong
↓
SAVE STAGING
↓
PASS后PUBLISH
```

总装再加：

```text
Mates
Interference
Movement
Clearance
Assembly path
```

---

# 20. 本轮已经遇到、现应回归测试的典型故障

| 类型 | 典型错误 | 当前防线 |
|---|---|---|
| PowerShell语法 | `$lineNo:` ParserError | Parser预检 + `${lineNo}` |
| CMD编码 | 中文乱码 | BAT逻辑ASCII优先 |
| 安装路径 | 找不到SLDWORKS.exe | config + fallback |
| Interop | runtime assembly load fail | LoadFrom + Resolve |
| COM Binder | `System.__ComObject`强转失败 | 强类型放C#内部 |
| EquationMgr | Add2/Add3错误 | 单配置场景匹配策略 |
| Angle | `22.5deg` Add2失败 | 导入规范化 |
| Plane mapping | Z面实际读0 | 世界几何识别 |
| Readback | Transform误判 | CornerPoints/世界坐标独立验证 |
| 发布 | 失败覆盖成功 | staging→validate→publish |
| 重跑 | 每次全从头 | build_state + SHA256 + resume |

---

# 21. 当前控制台里程碑应显示

```text
Q347F 12in Class150 AUTO BUILD
============================================================
Status : PASS
S00    : PASS
S01    : PASS
S02    : PASS
S03    : PASS
S04-S12: WAITING
Skeleton: ...\02_output\00_SKELETON.SLDPRT
============================================================
```

这才是当前真实状态。

---

# 22. 下一步

只推进：

```text
S04 BALL
```

不要同时启动 S05～S12。

S04实机 PASS 后再把它升级为第二个稳定里程碑和后续Part Builder模板。
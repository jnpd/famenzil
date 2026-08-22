# Q347F 12寸 Class150——SolidWorks 自动执行总控 / 步骤 / 日志 / 进度规范 V1（当前统一版）

> **用途**：规定自动构建怎么执行、显示进度、判定 PASS/FAIL、断点续跑和发布模型。  
> **正式路线**：`BAT → PowerShell 5.1 → 内嵌C# → SOLIDWORKS COM API`。  
> **最新用户实机验证**：`S00～S03 PASS`。  
> **当前代码实现**：S04 BALL 已实现并由主脚本调用，等待下一次真实运行验证；S05～S12 未实现。

---

# 1. 两种“状态”必须分开

## 1.1 开发状态

```text
IMPLEMENTED
NOT_IMPLEMENTED
```

当前：

```text
S00～S04 = IMPLEMENTED
S05～S12 = NOT_IMPLEMENTED
```

## 1.2 运行状态

只认：

```text
WAITING
RUNNING
PASS
WARN
FAIL
BLOCKED
SKIP
```

最新用户已验证：

```text
S00 PASS
S01 PASS
S02 PASS
S03 PASS
```

S04尚未有当前版本的用户本机 PASS/FAIL 结果，因此运行验证状态仍待下一次执行。

---

# 2. 用户操作

正常：

```text
双击 一键生成12寸Q347F.bat
```

断点：

```bat
一键生成12寸Q347F.bat resume
```

失败时保留：

```text
04_logs\run_xxx
03_backup\run_xxx
```

---

# 3. 当前目录

```text
SolidWorks_AutoBuild_Q347F_12in/
├─ 一键生成12寸Q347F.bat
├─ README.md
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
│     ├─ Q347F_SwBallApi.ps1
│     ├─ Q347F_Stages_S00_S02.ps1
│     ├─ Q347F_Stage_S03.ps1
│     └─ Q347F_Stage_S04.ps1
├─ 02_output/
│  ├─ 00_SKELETON.SLDPRT
│  ├─ 01_BALL.SLDPRT        ← S04 PASS后发布
│  └─ build_state.json
├─ 03_backup/
└─ 04_logs/
```

---

# 4. 总进度区间

| Step | 内容 | 进度 | 开发状态 |
|---|---|---:|---|
| S00 | Environment | 0→5% | 已实现 |
| S01 | Parameters | 5→10% | 已实现 |
| S02 | SolidWorks | 10→15% | 已实现 |
| S03 | Skeleton | 15→25% | 已实现/实机PASS |
| S04 | BALL | 25→34% | **已实现/待实机验证** |
| S05 | SEAT | 34→43% | 未实现 |
| S06 | BODY | 43→57% | 未实现 |
| S07 | BODY_COVER | 57→67% | 未实现 |
| S08 | Z Parts | 67→78% | 未实现 |
| S09 | ADAPTER | 78→84% | 未实现 |
| S10 | Assembly | 84→92% | 未实现 |
| S11 | Validation | 92→98% | 未实现 |
| S12 | Report | 98→100% | 未实现 |

当前**已验证里程碑**仍是25% / S03 PASS；当前代码执行目标已经扩展到34% / S04。

---

# 5. 日志格式

```text
[时间][Step][对象][进度][状态] 消息
```

例如已验证：

```text
[S03][READBACK][23%][PASS] ... X=11, Z=16
[S03][WHATS_WRONG][24%][PASS] Rebuild PASS; errors=0; warnings=0
[S03][SAVE][25%][PASS] 00_SKELETON.SLDPRT published
```

S04当前代码会继续输出：

```text
[S04][BALL][25%][RUNNING]
[S04][BALL_CORE]...
[S04][FLOW_BORE]...
[S04][UPPER_SUPPORT]...
[S04][DRIVE_SLOT]...
[S04][LOWER_SUPPORT]...
[S04][AUDIT]...
[S04][WHATS_WRONG]...
[S04][SAVE][34%]...
```

---

# 6. 失败原则

永久禁止：

```text
失败后静默跳过
API报错却写PASS
红叉Feature仍发布
D参数填0继续
验证失败覆盖上一版PASS
```

`FAIL/BLOCKED` 默认立即停止后续链。

---

# 7. S00

检查：

```text
Windows / 64-bit PowerShell Desktop
所有PS1 Parser
.build.lock
build_config.json
SOLIDWORKS.exe
Interop DLL
输出目录
磁盘空间
内嵌C#编译
```

路径优先：

```text
exePath
↓
installDir\SLDWORKS.exe
↓
autoDiscoverFallback
```

Interop：

```text
Assembly.LoadFrom
+
AssemblyResolve兜底
```

---

# 8. S01

唯一参数源：

```text
Q347F_12in_Class150_00_SKELETON_GlobalVariables_V1.txt
```

每次：

```text
解析
逻辑检查
parameters_snapshot.txt
SHA256
```

关键：

```text
F2F=610
BORE=303
BALL=465
R=232.5
MAIN_OPENING=480
Z_BODY_TOP_IF=264.5
Z_BODY_BOTTOM_IF=-270.5
F25_PCD=254
```

---

# 9. S02

当前：

```text
Marshal.GetActiveObject
↓ 无实例
Activator.CreateInstance(SldWorks.Application)
↓
RevisionNumber=33.x
↓
Part template
```

PowerShell不承担SolidWorks强类型COM绑定；强类型尽量在内嵌C#内部完成。

---

# 10. S03 Skeleton

必须创建：

```text
SK_PT_BALL_CENTER_O
AXIS_X_FLOW
AXIS_Z_SUPPORT
3个项目语义基准面
11个X station
16个Z station
构造Envelope
```

原生平面禁止：

```text
Front=XZ / Top=XY / Right=YZ 硬绑定
```

正确：按真实世界几何识别原生 XY/XZ/YZ。

---

# 11. S03 Readback / PASS门

```text
ForceRebuild
↓
Feature name验证
↓
世界坐标独立Readback
↓
actual vs expected
↓
Feature Error
↓
What's Wrong
↓
staging
↓
publish
```

当前实机：

```text
X 11/11 PASS
Z 16/16 PASS
RefPlaneCount=33
RefAxisCount=2
errors=0
warnings=0
```

---

# 12. S04 BALL——代码已实现

主脚本已实际调用：

```text
Add-EmbeddedSwBallApiType
Invoke-S04
```

当前参数：

```text
BALL_OD=465
BALL_W_X=348
BORE_D=303
BALL_UPPER_BORE_D=105
BALL_UPPER_BORE_DEPTH=30
BALL_LOWER_BORE_D=70
BALL_LOWER_BORE_DEPTH=52
BALL_DRIVE_SLOT=70×44 R8 depth27
```

统一称为：

```text
current CAD-draft candidate dimensions
```

禁止在日志/文档里称这些 CAD 候选为“manufacturing dimensions”。

---

# 13. S04当前Feature门

必须至少存在：

```text
BALL_CORE
SK_BALL_PROFILE
CUT_BORE_D303
CUT_UPPER_SUPPORT_BORE_D105
CUT_UPPER_DRIVE_SLOT_70x44_R8
CUT_LOWER_SUPPORT_BORE_D70
```

Audit：

```text
SolidBodyCount=1
X span≈348
Y span≈465
Z min/max/span与解析上下孔切除结果一致
```

再要求：

```text
ForceRebuild PASS
Feature errors=0
What's Wrong errors=0
staging保存
publish成功
```

才允许：

```text
S04 PASS
```

---

# 14. staging / backup / publish

```text
03_backup\run_xxx\00_SKELETON_staging.SLDPRT
03_backup\run_xxx\01_BALL_staging.SLDPRT
```

只有PASS后：

```text
02_output\00_SKELETON.SLDPRT
02_output\01_BALL.SLDPRT
```

如果current已存在，先备份 previous_PASS。

---

# 15. Resume

S00/S01/S02永远重跑。

S03/S04只有：

```text
上次PASS
+
参数SHA256一致
+
最终文件存在
```

才允许SKIP。

本次同步修改了参数文件注释，因此文件SHA256会变化；下一次 `resume` 可能会按设计重新验证 S03，再进入 S04。这是正常的。

---

# 16. 当前已解决的典型故障

| 问题 | 当前防线 |
|---|---|
| `$lineNo:` ParserError | Parser预检 + `${lineNo}` |
| CMD中文乱码 | BAT逻辑ASCII优先 |
| SW路径写死 | config + fallback |
| Interop运行时失败 | LoadFrom + Resolve |
| `System.__ComObject`强转 | 强类型留C#内部 |
| Add2/Add3错误 | 匹配单配置场景 |
| `deg`失败 | 导入层角度规范化 |
| 原生基准面映射错误 | 世界几何识别 |
| Transform读回误判 | 独立世界坐标回读 |
| 失败覆盖成功 | staging→validate→publish |
| 每次从头 | build_state + SHA256 + resume |

---

# 17. 下一次运行的判断标准

当前代码跑完后应该明确得到：

```text
S00 PASS
S01 PASS
S02 PASS
S03 PASS 或 SKIP
S04 PASS 或明确FAIL
S05-S12 WAITING (not implemented)
```

如果 S04 PASS，才把“最新实机里程碑”从 S03 更新到 S04。
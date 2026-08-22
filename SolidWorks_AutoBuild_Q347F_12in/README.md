# Q347F 12in Class150 — SolidWorks 2025 AutoBuild（当前统一版）

本目录是 `Q347F / NPS12 / DN300 / Class150 / 固定球 / 两片式 / Side Entry / 全通径 φ303` 的正式 SolidWorks 自动建模代码目录。

当前代码已经接入：

```text
S00 本机环境检查
↓
S01 参数读取校验
↓
S02 连接 / 启动 SolidWorks 2025
↓
S03 自动生成 00_SKELETON.SLDPRT
↓
S04 自动生成 01_BALL.SLDPRT
```

当前必须区分：

```text
代码实现状态：S00～S04 已接入主流程
最新用户实机验证：S00～S03 PASS
S04：代码已实现，等待下一次本机运行取得 PASS/FAIL 日志
S05～S12：尚未实现
```

因此当前不能提前宣布 `S04 PASS`。

---

## 1. 当前唯一参数源

仓库根目录：

```text
Q347F_12in_Class150_00_SKELETON_GlobalVariables_V1.txt
```

设计链：

```text
设计计算主线
↓
数字化总账
↓
GlobalVariables.txt
↓
S01参数解析/快照/SHA256
↓
S03 Skeleton / S04 BALL
```

参数文件是 CAD 执行输入，不是完整计算书。

---

## 2. 当前 S03 实机基线

已经由用户本机实测：

```text
S00 PASS
S01 PASS
S02 PASS
S03 PASS
```

Skeleton验证：

```text
11个X station 世界坐标回读 PASS
16个Z station 世界坐标回读 PASS
RefPlaneCount=33
RefAxisCount=2
ForceRebuild PASS
Feature errors=0
What's Wrong errors=0
warnings=0
00_SKELETON.SLDPRT published
```

输出：

```text
02_output\00_SKELETON.SLDPRT
```

---

## 3. S04 当前代码目标

S04 已经写入：

```text
01_scripts\lib\Q347F_SwBallApi.ps1
01_scripts\lib\Q347F_Stage_S04.ps1
```

并由：

```text
01_scripts\Build_Q347F_12in.ps1
```

实际调用。

成功时输出：

```text
02_output\01_BALL.SLDPRT
```

但是否 PASS 必须以你下一次真实运行日志为准。

---

## 4. S04 当前 BALL 参数——与唯一参数源保持一致

主球体：

```text
BALL_OD                  = φ465
BALL_W_X                 = 348
BORE_D                   = φ303 Through All
```

上接口：

```text
BALL_UPPER_BORE_D        = φ105
BALL_UPPER_BORE_DEPTH    = 30
```

下接口：

```text
BALL_LOWER_BORE_D        = φ70
BALL_LOWER_BORE_DEPTH    = 52
```

驱动槽：

```text
BALL_DRIVE_SLOT_L_X      = 70
BALL_DRIVE_SLOT_W_Y      = 44
BALL_DRIVE_SLOT_R        = R8
BALL_DRIVE_SLOT_DEPTH    = 27
```

**统一状态说明：**

```text
φ105 / φ70 = 当前结构接口主链 C/C+
30 / 52    = S04 CAD候选 C-CAD
70×44/R8/27= S04 CAD候选 C-CAD
```

这些值用于当前参数化 CAD 验证，**不自动等于制造冻结尺寸**。

---

## 5. S04 当前Feature顺序

代码当前创建：

```text
项目语义基准面 / 项目轴
↓
SK_BALL_PROFILE
↓
BALL_CORE
↓
SK_BORE_D303
↓
CUT_BORE_D303
↓
SK_UPPER_SUPPORT_BORE_D105
↓
CUT_UPPER_SUPPORT_BORE_D105
↓
SK_UPPER_DRIVE_SLOT_CORE_X
↓
CUT_UPPER_DRIVE_SLOT_CORE_X
↓
SK_UPPER_DRIVE_SLOT_CORE_Y
↓
CUT_UPPER_DRIVE_SLOT_CORE_Y
↓
SK_UPPER_DRIVE_SLOT_70x44_R8
↓
CUT_UPPER_DRIVE_SLOT_70x44_R8
↓
SK_LOWER_SUPPORT_BORE_D70
↓
CUT_LOWER_SUPPORT_BORE_D70
```

驱动槽的 70×44 R8 由：

```text
两个核心矩形
+
四个R8角圆
```

组合切除形成，尺寸来自参数文件。

---

## 6. S04 PASS 门

至少必须满足：

```text
BALL_CORE存在
CUT_BORE_D303存在
CUT_UPPER_SUPPORT_BORE_D105存在
CUT_UPPER_DRIVE_SLOT_70x44_R8存在
CUT_LOWER_SUPPORT_BORE_D70存在

SolidBodyCount=1
BALL X width≈348
BALL Y envelope≈465
Z envelope与上下孔切除后的解析值一致

ForceRebuild PASS
Feature errors=0
What's Wrong errors=0
staging保存成功
final publish成功
```

Body Box 是自动化 sanity check，不是制造检验方法。

---

## 7. SolidWorks坐标规则

项目语义：

```text
BALL_CENTER_O=(0,0,0)
X=FLOW_AXIS
Y=CROSS_AXIS
Z=SUPPORT_AXIS
```

禁止硬绑定：

```text
Front=XZ
Top=XY
Right=YZ
```

S03/S04使用项目自己的：

```text
PLN_BASE_XY_FLOW_CROSS
PLN_BASE_XZ_FLOW_SUPPORT
PLN_BASE_YZ_CROSS_SUPPORT
AXIS_X_FLOW
AXIS_Z_SUPPORT
SK_PT_BALL_CENTER_O
```

原生面按真实世界几何识别。

---

## 8. 目录

```text
SolidWorks_AutoBuild_Q347F_12in\
├─ 一键生成12寸Q347F.bat
├─ README.md
├─ .gitignore
├─ 00_config\
│  ├─ README.md
│  └─ build_config.json
├─ 01_scripts\
│  ├─ 00_Preflight_Parse.ps1
│  ├─ Build_Q347F_12in.ps1
│  └─ lib\
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
├─ 02_output\
├─ 03_backup\
└─ 04_logs\
```

正式路线：

```text
BAT
↓
64位 Windows PowerShell 5.1
↓
PowerShell编排
↓
Add-Type内嵌C#
↓
SolidWorks.Interop.sldworks.dll + swconst.dll
↓
SOLIDWORKS 2025 COM API
```

---

## 9. Windows运行

正常：

```text
双击：一键生成12寸Q347F.bat
```

断点：

```bat
一键生成12寸Q347F.bat resume
```

或：

```powershell
powershell.exe -NoLogo -NoProfile -ExecutionPolicy Bypass -File .\01_scripts\Build_Q347F_12in.ps1 -Resume
```

必须使用 64 位 Windows PowerShell。

---

## 10. Resume规则

```text
S00/S01/S02永远重新检查
```

S03/S04只有同时满足：

```text
上一状态PASS
+
参数SHA256一致
+
最终文件存在
```

才允许 SKIP。

参数文件发生变化后，依赖模型应重新验证。

---

## 11. staging / publish

S03：

```text
03_backup\run_xxx\00_SKELETON_staging.SLDPRT
↓ PASS
02_output\00_SKELETON.SLDPRT
```

S04：

```text
03_backup\run_xxx\01_BALL_staging.SLDPRT
↓ PASS
02_output\01_BALL.SLDPRT
```

失败禁止覆盖上一版 PASS。

---

## 12. 你下一次运行重点看什么

因为当前代码已经接入 S04，下一次运行最终应该出现：

```text
S00 PASS
S01 PASS
S02 PASS
S03 PASS 或 SKIP
S04 PASS 或明确 FAIL
```

如果 S04 PASS，再确认：

```text
02_output\01_BALL.SLDPRT
```

以及 FeatureManager 中没有红叉。

如果失败，保留：

```text
04_logs\run_xxx
03_backup\run_xxx\01_BALL_staging.SLDPRT
```

**不要先改设计尺寸；先按具体API/几何验证错误定位。**
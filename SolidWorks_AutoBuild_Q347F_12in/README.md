# Q347F 12in Class150 — SolidWorks 2025 AutoBuild

本目录是 `Q347F / NPS12 / DN300 / Class150 / 固定球 / 两片式 / Side Entry / 全通径 φ303` 的正式 SolidWorks 自动建模代码目录。

当前已实现：

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

当前版本在 **S04 / 34%** 停止。S05 SEAT 及后续 BODY、BODY_COVER、总装暂未接入。

---

## 1. 当前输出

成功运行后：

```text
02_output\00_SKELETON.SLDPRT
02_output\01_BALL.SLDPRT
```

`01_BALL.SLDPRT` 是真正可编辑的 SolidWorks 特征树，不是 STEP 临时体。

当前 Ball 特征顺序：

```text
项目基准面 / 项目轴
↓
SK_BALL_PROFILE
↓
BALL_CORE                 360°旋转实体
↓
SK_BORE_D303
↓
CUT_BORE_D303             X向φ303双向贯通
↓
SK_UPPER_SUPPORT_BORE_D105
↓
CUT_UPPER_SUPPORT_BORE_D105
↓
SK_UPPER_DRIVE_SLOT_70x50_R8
↓
CUT_UPPER_DRIVE_SLOT_70x50_R8
↓
SK_LOWER_SUPPORT_BORE_D70
↓
CUT_LOWER_SUPPORT_BORE_D70
```

---

## 2. S04 当前球体制造尺寸

为了先把完整球体稳定画出来，本版把原先尚待供应商/最终图确认的接口尺寸按当前设计值直接用于制造级 CAD 建模。

```text
球体外径 BALL_OD                    = φ465
球体X向总宽 BALL_W_X               = 348
流道 BORE_D                         = φ303 Through All

上主支承孔 BALL_UPPER_BORE_D        = φ105
上主支承孔总加工深度                = 35

上驱动槽 X向长度                    = 70
上驱动槽 Y向宽度                    = 50
槽根圆角                            = R8
驱动槽深度                          = 35
驱动槽起点                          = 上φ105孔底面

下主支承孔 BALL_LOWER_BORE_D        = φ70
下主支承孔总加工深度                = 52
```

其中 `φ105×35` 的选择可使球面入口损失后得到约 29 mm 的有效圆柱支承段，与当前约 `28.9 mm` 的支承链相符；`φ70×52` 则对应约 50 mm 的有效下支承圆柱段。

参数全部放在仓库根目录唯一参数源：

```text
Q347F_12in_Class150_00_SKELETON_GlobalVariables_V1.txt
```

以后正式图纸尺寸变化时，优先修改参数，不重写 S04 拓扑。

---

## 3. 目录

```text
SolidWorks_AutoBuild_Q347F_12in\
├─ 一键生成12寸Q347F.bat
├─ README.md
├─ .gitignore
├─ 00_config\
│  └─ README.md
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

技术路线：

```text
BAT
↓
64位 Windows PowerShell
↓
PowerShell Add-Type 编译 C#
↓
SolidWorks.Interop.sldworks.dll
+ SolidWorks.Interop.swconst.dll
↓
SOLIDWORKS 2025 COM API
```

VBA 不是正式主路线。

---

## 4. Windows 运行

正常运行直接双击：

```text
一键生成12寸Q347F.bat
```

断点续跑：

```bat
一键生成12寸Q347F.bat resume
```

或：

```powershell
powershell.exe -NoLogo -NoProfile -ExecutionPolicy Bypass -File .\01_scripts\Build_Q347F_12in.ps1 -Resume
```

必须使用 **64位 Windows PowerShell (`powershell.exe`)**。

---

## 5. S00 — 环境检查

检查：

- Windows / 64位 Windows PowerShell；
- `SLDWORKS.exe`；
- `SolidWorks.Interop.sldworks.dll`；
- `SolidWorks.Interop.swconst.dll`；
- Interop 主版本必须为 `33`（SOLIDWORKS 2025）；
- 输出目录可写；
- 磁盘空间；
- `.build.lock` 防止双开。

关键依赖缺失立即 `BLOCKED`。

---

## 6. S01 — 参数读取校验

关键控制值包括：

```text
F2F                       = 610
BORE_D                    = 303
BALL_OD                   = 465
BALL_R                    = 232.5
BALL_W_X                  = 348
MAIN_OPENING_D            = 480
UP_BRG_OD                 = 105
LOWER_BRG_OD              = 70
```

并检查 Opening > Ball、轴承 OD>ID、上下 Z 正负方向等逻辑。

每次运行保存参数快照与 SHA256：

```text
04_logs\run_YYYYMMDD_HHMMSS\parameters_snapshot.txt
```

参数哈希变化时，不允许 Resume 跳过旧 S03/S04。

---

## 7. S03 — Skeleton PASS 门

项目坐标：

```text
BALL_CENTER_O=(0,0,0)
X = FLOW_AXIS
Z = SUPPORT_AXIS
```

S03 必须满足：

1. 需要的 X/Z station planes 存在；
2. 世界坐标读回方向正确；
3. `ForceRebuild3(false)` 成功；
4. `GetWhatsWrong` 无 Error；
5. Feature `GetErrorCode2` 无 Error；
6. staging 保存成功；
7. 最终 Skeleton 发布成功。

---

## 8. S04 — Ball PASS 门

S04 必须满足：

1. `BALL_CORE` 创建成功；
2. φ303 X向双向贯通孔创建成功；
3. φ105 上支承孔创建成功；
4. 70×50×R8 上驱动槽创建成功；
5. φ70 下支承孔创建成功；
6. Solid body 数量必须等于 1；
7. Body box 复核约为 `X=348 / Y=465 / Z=465`；
8. `ForceRebuild3(false)` 成功；
9. What's Wrong 无 Error；
10. staging 保存成功；
11. 最终 `01_BALL.SLDPRT` 发布成功。

Body box 只做自动建模 sanity check，不作为制造检验方法。

---

## 9. 防止失败覆盖上一次 PASS

每次运行先写 staging：

```text
03_backup\run_YYYYMMDD_HHMMSS\00_SKELETON_staging.SLDPRT
03_backup\run_YYYYMMDD_HHMMSS\01_BALL_staging.SLDPRT
```

只有各自 PASS 后才发布到 `02_output`。

已有成功文件时，本次发布前备份：

```text
00_SKELETON_previous_PASS.SLDPRT
01_BALL_previous_PASS.SLDPRT
```

---

## 10. 日志 / 状态 / 断点

```text
04_logs\run_YYYYMMDD_HHMMSS\
├─ build.log
├─ summary.json
└─ parameters_snapshot.txt
```

持久断点：

```text
02_output\build_state.json
```

状态：

```text
WAITING / RUNNING / PASS / WARN / FAIL / BLOCKED / SKIP
```

Resume 时 S00/S01/S02 永远重检；S03/S04 只有满足“上次 PASS + 参数哈希一致 + 最终文件仍存在”才允许 SKIP。

---

## 11. 你本机第一次跑 S04 只看这些

```text
S00 PASS
S01 PASS
S02 PASS
S03 PASS 或 SKIP
S04 PASS
```

然后确认：

```text
02_output\01_BALL.SLDPRT
```

打开后 FeatureManager 中应看到：

```text
BALL_CORE
CUT_BORE_D303
CUT_UPPER_SUPPORT_BORE_D105
CUT_UPPER_DRIVE_SLOT_70x50_R8
CUT_LOWER_SUPPORT_BORE_D70
```

没有红叉，并且最后日志类似：

```text
[S04][SAVE][34%][PASS] 01_BALL.SLDPRT published
```

若 S04 失败，先不要改设计尺寸；保留最新 `04_logs\run_xxx` 与 `03_backup\run_xxx\01_BALL_staging.SLDPRT`，先按具体 API/特征错误修代码。

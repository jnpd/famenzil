# Q347F 12in Class150 — SolidWorks 2025 AutoBuild

本目录是 `Q347F / NPS12 / DN300 / Class150 / 固定球 / 两片式 / Side Entry / 全通径 φ303` 的正式 SolidWorks 自动建模代码目录。

当前第一里程碑只实现：

```text
S00 本机环境检查
↓
S01 参数读取校验
↓
S02 连接 / 启动 SolidWorks 2025
↓
S03 自动生成 00_SKELETON.SLDPRT
```

**当前版本故意停在 S03 / 25%。不会继续生成 BALL、SEAT、BODY 等零件。**

## 目录

```text
SolidWorks_AutoBuild_Q347F_12in\
├─ 一键生成12寸Q347F.bat
├─ README.md
├─ .gitignore
├─ 00_config\
│  └─ README.md
├─ 01_scripts\
│  ├─ Build_Q347F_12in.ps1        # 唯一总入口
│  └─ lib\
│     ├─ Q347F_Common.ps1          # 日志、状态、参数解析、断点
│     ├─ Q347F_SwSessionApi.ps1    # ATTACH/START_NEW、模板、新建Part
│     ├─ Q347F_SwEquationApi.ps1   # EquationMgr / Global Variables
│     ├─ Q347F_SwGeometryApi.ps1   # 基准面、轴、站位、Skeleton构造草图
│     ├─ Q347F_SwValidationApi.ps1 # Rebuild / What's Wrong / Save
│     ├─ Q347F_Stages_S00_S02.ps1
│     └─ Q347F_Stage_S03.ps1
├─ 02_output\                      # 本机生成，不提交Git
├─ 03_backup\                      # 每次运行staging/上一版备份
└─ 04_logs\                        # 每次运行独立日志
```

技术路线仍然是：

```text
BAT
↓
PowerShell
↓
PowerShell 内 Add-Type 编译 C#
↓
SolidWorks.Interop.sldworks.dll
+ SolidWorks.Interop.swconst.dll
↓
SOLIDWORKS 2025 COM API
```

VBA 不是正式主路线。

## 参数唯一来源

默认只读取仓库根目录：

```text
Q347F_12in_Class150_00_SKELETON_GlobalVariables_V1.txt
```

本目录不复制第二份参数源，防止出现两套参数。

每次运行都会生成参数快照：

```text
04_logs\run_YYYYMMDD_HHMMSS\parameters_snapshot.txt
```

并记录 SHA256。断点续跑时如果参数哈希变化，旧 S03 自动失效并重新生成。

## Windows 运行

### 第一次 / 正常运行

直接双击：

```text
一键生成12寸Q347F.bat
```

### 断点续跑

CMD：

```bat
一键生成12寸Q347F.bat resume
```

或：

```powershell
powershell.exe -NoLogo -NoProfile -ExecutionPolicy Bypass -File .\01_scripts\Build_Q347F_12in.ps1 -Resume
```

V1 明确用 **64位 Windows PowerShell (`powershell.exe`)**，不是把 VBA 当主入口。

## S00 — 本机环境检查

检查：

- Windows / 64位 Windows PowerShell；
- `SLDWORKS.exe`；
- `SolidWorks.Interop.sldworks.dll`；
- `SolidWorks.Interop.swconst.dll`；
- Interop 主版本必须为 `33`（SOLIDWORKS 2025）；
- 输出目录可写；
- 磁盘空间；
- `.build.lock` 防止双开脚本；
- 四组内嵌 C# API 层能否编译。

关键依赖缺失时立即 `BLOCKED`，不进入 S01。

## S01 — 参数读取校验

当前关键值至少校验：

```text
F2F                       = 610
BORE                      = 303
BALL                      = 465
BALL_R                    = 232.5
X_BODY_JOINT_CAD          = 232.5
MAIN_OPENING_D            = 480
MID_GASKET_OD             = 500
MID_BCD_CAD               = 526.5
UP_BRG_OD                 = 105
LOWER_BRG_OD              = 70
Z_BODY_TOP_IF_CAD         = +264.5
Z_BODY_BOTTOM_IF_CAD      = -270.5
F25_BOLT_PCD              = 254
Z_STEM_TOP_CAD            = +430
```

同时检查：

```text
MAIN_OPENING_D > BALL_OD
VALVE_F2F / 2 = 305
MID_GASKET_OD > MID_GASKET_ID
UP_BRG_OD > UP_BRG_ID
LOWER_BRG_OD > LOWER_BRG_ID
Z_BODY_TOP_IF_CAD > 0
Z_BODY_BOTTOM_IF_CAD < 0
```

参数冲突立即停止。

## S02 — SolidWorks 2025 连接

策略：

```text
优先 ATTACH 已打开的 SOLIDWORKS
↓
没有则 COM START_NEW
↓
读取 RevisionNumber
↓
必须为 33.x
↓
读取当前 SOLIDWORKS 默认 Part 模板
```

默认 Part 模板未配置或文件不存在时，S02 `BLOCKED`，不偷偷改用户模板设置。

## S03 — 00_SKELETON.SLDPRT

项目坐标固定：

```text
BALL_CENTER_O=(0,0,0)
X = FLOW_AXIS
Z = SUPPORT_AXIS
Front = XZ
Top   = XY
Right = YZ
```

显式创建：

```text
PLN_BASE_XZ_FLOW_SUPPORT
PLN_BASE_XY_FLOW_CROSS
PLN_BASE_YZ_CROSS_SUPPORT
AXIS_X_FLOW
AXIS_Z_SUPPORT
SK_PT_BALL_CENTER_O
```

X 主要站位：

```text
-305
-273.2
-232.5
-174
-166.036
0
+166.036
+174
+232.5
+273.2
+305
```

Z 主要站位：

```text
-289.1
-270.5
-230
-227
-177
0
+193.6
+223.6
+226.9
+264.5
+300
+313.3
+337.3
+339.8
+429.8
+430
```

命名例：

```text
PLN_X_M305_000
PLN_X_P232_500
PLN_Z_M270_500
PLN_Z_P337_300
PLN_Z_P430_000
```

并创建 Skeleton 构造草图包络，**不是制造实体**：

```text
SK_ENV_X0_BALL_BORE_BODY_MIDFLANGE
  BALL φ465
  BORE φ303
  BODY φ504 CAD
  MID FLANGE φ562.5 CAD

SK_ENV_F25_OD
  ADAPTER/F25 φ300 CAD
```

## S03 PASS 门

只有以下全部满足才发布最终 Skeleton：

1. X/Z 所有要求的站位基准面存在；
2. 通过 `RefPlane.Transform` 读回世界坐标，正负方向必须正确；
3. `ForceRebuild3(false)` 成功；
4. `GetWhatsWrong` 无 Error；
5. Feature `GetErrorCode2` 无 Error；
6. staging 保存成功；
7. 最终 `02_output\00_SKELETON.SLDPRT` 保存成功。

警告写 `WARN`；硬错误立即 `FAIL` 并停止。

## 防止失败覆盖上一次 PASS

当前运行先保存：

```text
03_backup\run_YYYYMMDD_HHMMSS\00_SKELETON_staging.SLDPRT
```

只有坐标读回 + Rebuild + What's Wrong 全部通过后，才发布：

```text
02_output\00_SKELETON.SLDPRT
```

如果已有上一版成功 Skeleton，本次发布前会备份为：

```text
03_backup\run_YYYYMMDD_HHMMSS\00_SKELETON_previous_PASS.SLDPRT
```

## 日志 / 状态 / 断点

每次运行独立目录：

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

日志格式：

```text
[时间][Step][对象][百分比][状态] 消息
```

S00/S01/S02 因为本机环境、参数和 COM 会话会变化，所以断点续跑时仍会重新检查；S03 只有在“上次 PASS + 参数哈希未变 + 最终 Skeleton 仍存在”时才允许 `SKIP`。

## 第一次本机验证只看这几个结果

1. `S00` 是否找到 2025 Interop；
2. `S02` 是否显示 `Revision=33.x`；
3. FeatureManager 中负 X/Z 站位方向是否正确；
4. `00_SKELETON.SLDPRT` 是否无红叉；
5. `build.log` 最后是否为 `S03 ... 25% ... PASS`。

如果失败，**先不要改设计参数**。保留完整 `04_logs\run_xxx` 和 staging Skeleton，用日志定位代码/API问题。

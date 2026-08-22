# Q347F 12寸 Class150——SolidWorks 自动执行总控 / 步骤 / 日志 / 进度规范 V1

> **用途**：这不是设计计算页，而是后续所有自动建模脚本的“总控执行规范”。  
> 后续 `Build_Q347F_12in*.ps1`、内嵌 C#、SolidWorks API 都必须按本文执行。  
> **目标**：让非专业 SolidWorks 用户也能清楚看到：现在跑到哪一步、输入了什么、生成了什么、是否通过、失败在哪里、能否继续。

---

# 1. 自动建模的最终使用方式

最终希望做到：

```text
双击：一键生成12寸Q347F.bat
↓
Build_Q347F_12in.ps1
↓
读取参数
↓
连接 / 启动 SOLIDWORKS 2025
↓
创建 Skeleton
↓
创建核心零件
↓
创建总装
↓
自动配合
↓
自动重建
↓
干涉 / Feature Error / What's Wrong 检查
↓
保存全部 SLDPRT / SLDASM
↓
生成日志 + 进度 + 汇总报告
```

用户原则上只需要：

```text
1. 双击启动
2. 看实时进度
3. 失败时把本次logs目录发回来
```

---

# 2. 主技术路线

正式主路线：

```text
PowerShell .ps1
+
内嵌 C#
+
SOLIDWORKS COM API
```

不是以 VBA 宏作为主构建器。

VBA 可保留用于：

```text
单零件调试
Equation验证
API实验
本机辅助诊断
```

但正式一键构建入口统一为：

```text
Build_Q347F_12in.ps1
```

---

# 3. 目录约定

推荐本机工作目录：

```text
C:\solidworks\阀门\12Q347F\
│
├─ 00_config\
│  ├─ Q347F_12in_parameters.txt
│  └─ build_config.json
│
├─ 01_scripts\
│  ├─ Build_Q347F_12in.ps1
│  ├─ Build_Skeleton.ps1
│  ├─ Build_Ball.ps1
│  ├─ Build_Seats.ps1
│  ├─ Build_Body.ps1
│  ├─ Build_BodyCover.ps1
│  ├─ Build_ZParts.ps1
│  └─ Build_Assembly.ps1
│
├─ 02_output\
│  ├─ 00_SKELETON.SLDPRT
│  ├─ 01_BALL.SLDPRT
│  ├─ 02_LEFT_SEAT.SLDASM
│  ├─ 03_RIGHT_SEAT.SLDASM
│  ├─ 04_STEM_COVER.SLDPRT
│  ├─ 05_STEM.SLDPRT
│  ├─ 06_BOTTOM_COVER.SLDPRT
│  ├─ 07_BODY.SLDPRT
│  ├─ 08_BODY_COVER.SLDPRT
│  ├─ 09_ADAPTER.SLDPRT
│  └─ 12-Q347F-150LB-总装图.SLDASM
│
├─ 03_backup\
│
└─ 04_logs\
   └─ run_YYYYMMDD_HHMMSS\
```

所有运行都必须创建独立 `run_时间戳` 日志目录，不覆盖上一次记录。

---

# 4. 状态定义——以后日志只认这7种状态

| 状态 | 含义 | 是否继续 |
|---|---|---|
| `WAITING` | 尚未执行 | 等待 |
| `RUNNING` | 当前正在执行 | 是 |
| `PASS` | 已完成且检查通过 | 是 |
| `WARN` | 已完成，但存在非阻塞风险 | 是，但必须记录 |
| `FAIL` | 当前步骤失败 | 默认停止 |
| `BLOCKED` | 参数或前置条件不足 | 停止 |
| `SKIP` | 本次明确不执行 | 仅配置允许时 |

禁止：

```text
失败后悄悄跳过
API返回错误却继续保存
特征红叉但日志写成功
D参数被自动填成0继续建模
```

---

# 5. 参数状态与自动建模权限

当前工程状态仍采用：

```text
A / A-policy / B / C+ / C / C-space / D / H / H-R / R
```

自动草模 `CAD_DRAFT` 模式允许：

```text
A
B
C+
C
经主线明确批准的 C-space
```

自动脚本默认禁止直接使用：

```text
D
H
H/R
未关闭的R
```

若脚本发现关键输入为：

```text
?
D
H/R
空值
0（但工程上不允许为0）
```

必须：

```text
状态 = BLOCKED
立即记录参数名
停止当前依赖链
```

---

# 6. 总进度条——用户必须始终看到

总构建分为 13 个 Step。

| Step | 内容 | 总进度区间 |
|---|---|---:|
| S00 | 本机环境预检查 | 0% → 5% |
| S01 | 参数读取与校验 | 5% → 10% |
| S02 | 连接 / 启动 SolidWorks | 10% → 15% |
| S03 | 创建 Skeleton | 15% → 25% |
| S04 | 创建 Ball | 25% → 34% |
| S05 | 创建左右 Seat | 34% → 43% |
| S06 | 创建 BODY | 43% → 57% |
| S07 | 创建 BODY_COVER | 57% → 67% |
| S08 | 创建 STEM / STEM_COVER / BOTTOM_COVER | 67% → 78% |
| S09 | 创建 ADAPTER / F25 接口 | 78% → 84% |
| S10 | 创建总装 / 自动配合 | 84% → 92% |
| S11 | 干涉 / Feature / Rebuild 检查 | 92% → 98% |
| S12 | 保存 / 汇总 / 报告 | 98% → 100% |

控制台每完成一个小阶段都必须刷新，例如：

```text
Q347F 12in Class150 AUTO BUILD
============================================================
Overall : [############--------] 63%
Run ID  : 20260822_113000
Current : S07 BODY_COVER
Status  : RUNNING
Elapsed : 00:06:42

S00 ENVIRONMENT       PASS
S01 PARAMETERS        PASS
S02 SOLIDWORKS        PASS
S03 SKELETON          PASS
S04 BALL              PASS
S05 SEATS             PASS
S06 BODY              PASS
S07 BODY_COVER        RUNNING
S08 Z PARTS           WAITING
S09 ADAPTER           WAITING
S10 ASSEMBLY          WAITING
S11 VALIDATION        WAITING
S12 REPORT            WAITING
============================================================
```

---

# 7. 每一条日志的固定格式

所有脚本统一：

```text
[时间][Step][对象][进度][状态] 消息
```

示例：

```text
[11:30:01][S00][ENV][01%][RUNNING] Checking Windows environment
[11:30:02][S00][SW2025][02%][PASS] SolidWorks.Interop.sldworks.dll found
[11:30:04][S01][PARAM][07%][PASS] BALL_OD=465 mm
[11:30:04][S01][PARAM][07%][PASS] VALVE_F2F=610 mm
[11:30:11][S03][SKELETON][18%][RUNNING] Creating BALL_CENTER_O
[11:30:15][S03][SKELETON][21%][PASS] Plane PLN_X_BODY_JOINT created at +232.5 mm
[11:31:22][S06][BODY][49%][RUNNING] Cut main opening Ø480
[11:31:35][S06][BODY][53%][PASS] 20×M20 threaded pattern created
[11:32:40][S06][BODY][57%][PASS] Rebuild, errors=0, warnings=0
```

失败必须写清：

```text
[11:33:15][S07][BODY_COVER][62%][FAIL]
Feature: Cut-SeatPocket-R
API: FeatureCut4
ErrorCode: 5
Reason: sketch contour invalid
Action: build stopped; source model not overwritten
```

---

# 8. S00——本机环境预检查

## 要求

检查：

```text
Windows PowerShell可运行
SOLIDWORKS 2025安装目录存在
SolidWorks.Interop.sldworks.dll存在
SolidWorks.Interop.swconst.dll（如使用）存在
模板路径存在
输出目录可写
磁盘空间足够
本次Build没有重复锁
```

## 必须显示的日志

```text
SW安装路径
Interop DLL路径
PowerShell版本
脚本版本
参数版本
输出目录
```

## PASS条件

所有关键依赖存在。

若 SolidWorks 没启动：

```text
允许脚本尝试启动
```

若 COM/API DLL 不存在：

```text
BLOCKED
```

---

# 9. S01——参数读取与校验

## 输入

主参数源优先：

```text
Q347F_12in_Class150_00_SKELETON_GlobalVariables_V1.txt
```

同时生成运行快照：

```text
parameters_snapshot.txt
```

## 第一轮必须校验

至少：

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

## 几何逻辑校验

必须自动检查：

```text
MAIN_OPENING_D > BALL_OD
480 > 465                     PASS

VALVE_F2F / 2 = 305           PASS

MID_GASKET_OD > MID_GASKET_ID PASS

UP_BRG_OD > UP_BRG_ID         PASS
LOWER_BRG_OD > LOWER_BRG_ID   PASS

Z_BODY_TOP_IF_CAD > 0         PASS
Z_BODY_BOTTOM_IF_CAD < 0      PASS
```

发现矛盾：

```text
BLOCKED
```

---

# 10. S02——连接 / 启动 SOLIDWORKS 2025

## 优先逻辑

```text
先查 Windows Running Object Table
↓
找到已运行 SW2025
↓
直接复用
```

找不到：

```text
启动 SLDWORKS.exe
↓
等待 COM 就绪
↓
重新连接
```

## 日志必须显示

```text
SolidWorks版本
RevisionNumber
进程PID
连接方式：ATTACH / START_NEW
Visibility
```

## PASS条件

获得有效：

```text
ISldWorks
```

---

# 11. S03——创建 00_SKELETON.SLDPRT

## 目标

建立整个12寸总装唯一坐标骨架。

## 必建项目

```text
Origin = BALL_CENTER_O
X = FLOW_AXIS
Z = SUPPORT_AXIS

X站位：
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

Z站位：
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

## Skeleton还应保存

```text
BALL包络 φ465
BORE包络 φ303
BODY中央包络 φ504 CAD
主中法兰包络 φ562.5 CAD
F25包络 φ300
```

## PASS条件

```text
Rebuild = PASS
Feature error = 0
Required planes count = expected
关键坐标全部可读回
```

---

# 12. S04——创建 01_BALL.SLDPRT

## 第一版要求

```text
主球面 φ465
流道 φ303
X向宽度348
上孔 φ105
下孔 φ70
阀杆接口/键结构按当前有效参数
```

## 自动检查

```text
Bounding box
球体外径
流道直径
上孔直径
下孔直径
MassProperties可读取
Rebuild无红叉
```

## 失败原则

BALL失败：

```text
禁止继续BODY总装链
```

---

# 13. S05——创建左右 Seat

## 第一版要求

左右两套阀座必须独立成为装配对象，但几何可共用同一参数定义。

关键参数：

```text
D9=323.88
D10=327.13
D11=342
Guide bore=342.4
Pilot2=323.6
Guide2=323.8
Big OD=380
Big bore=382
Spring PCD=362
```

## 检查

```text
左/右方向正确
与球面接触位置正确
允许轴向浮动
无镜像方向错误
```

---

# 14. S06——创建 07_BODY.SLDPRT

这是第一版最重要、日志最详细的零件。

## 必建功能

```text
左端 NPS12 Class150 RF
φ303流道
φ471中央功能球腔 CAD
φ504中央外承压包络 CAD
左右阀座功能腔
主拆装孔 φ480 H8 CAD
主中法兰
20×M20螺纹锚固孔
上 φ105 Boss接口
下 φ70 Boss接口
VENT Boss
DRAIN Boss
```

## 每个Feature单独写日志

例如：

```text
BODY-001 MainRevolve
BODY-002 Bore303
BODY-003 Cavity471
BODY-004 SeatPocketL
BODY-005 SeatPocketR
BODY-006 MainOpening480
BODY-007 MidFlange
BODY-008 M20ThreadPattern20x
BODY-009 TopInterface
BODY-010 BottomInterface
BODY-011 VentBoss
BODY-012 DrainBoss
```

每个 Feature 建完立即：

```text
检查Feature ErrorCode
```

不要全部建完才检查。

---

# 15. S07——创建 08_BODY_COVER.SLDPRT

## 必建功能

```text
右端NPS12 Class150 RF
φ303流道
φ382→φ303内过渡
φ480 f8凸止口 CAD
止口长度20 CAD
φ466×7径向O圈槽
槽根φ468.6
缠绕垫端面
20×φ22通孔 CAD
螺母/spotface区
```

## 关键自动检查

```text
φ480止口能进入BODY φ480 H8孔
球体能通过主口
O圈槽没有切穿止口
O圈槽与缠绕垫没有重叠
M20孔与垫片没有径向冲突
```

---

# 16. S08——创建Z方向零件

包括：

```text
04_STEM_COVER.SLDPRT
05_STEM.SLDPRT
06_BOTTOM_COVER.SLDPRT
```

## STEM_COVER

关键：

```text
φ100一体上支承轴
φ105定位Boss
Boss有效长度约37.6 CAD
安装面Z≈+264.5 CAD
φ95×5.3 O圈
φ115×φ105×3.2垫片
4×M12×75主连接
```

## BOTTOM_COVER

关键：

```text
φ65一体下支承轴
φ70定位Boss
Boss有效长度约40.5 CAD
安装面Z≈-270.5 CAD
φ58×5.3 AED
φ80×φ70×3.2垫片
6×M12×55
```

底部AED O圈必须在日志中提示：

```text
WARN: supplier confirmation required before manufacturing freeze
```

## STEM

关键：

```text
主径φ65
上键轴φ60 CAD
防吹出肩≈φ74 CAD
18×11×90键槽
```

自动装配检查：

```text
φ74肩 > φ70导向孔
```

若成立：

```text
记录防吹出结构PASS
同时记录装配方向约束
```

---

# 17. S09——创建 ADAPTER / F25

当前CAD骨架：

```text
ADAPTER OD≈φ300
厚度24 CAD
F25 PCD φ254
8×M16
孔阵列首角22.5°
步距45°
中心止口不超过φ200
```

接口孔归属必须允许配置：

```text
一侧 M16螺纹锚固
另一侧 φ17.5通孔 + 螺母
```

在厂家蜗轮图未到前：

```text
状态 = WARN/CAD
不是制造冻结
```

---

# 18. S10——创建总装 SLDASM

目标：

```text
12-Q347F-150LB-总装图.SLDASM
```

推荐装配顺序：

```text
BODY fixed
↓
LEFT SEAT
↓
BALL
↓
RIGHT SEAT
↓
BODY_COVER
↓
BOTTOM_COVER
↓
STEM / STEM_COVER
↓
ADAPTER
↓
标准件 / 密封件
```

## 主要Mate

```text
BALL_CENTER_O ↔ Assembly Origin
FLOW_AXIS共轴
BODY_COVER φ480止口 ↔ BODY φ480主口
BODY/COVER分界端面配合
上Boss ↔ BODY上孔/端面
下Boss ↔ BODY下孔/端面
STEM ↔ 支承轴Z
```

## PASS条件

```text
Assembly rebuild success
Mate error=0
Suppressed unexpected components=0
Missing reference=0
```

---

# 19. S11——自动验证

这一阶段必须独立执行，不能因为“看起来像”就PASS。

## A. Feature检查

对所有 Part：

```text
GetErrorCode
What's Wrong
Rebuild
```

## B. 装配干涉

至少记录：

```text
BALL ↔ BODY
BALL ↔ BODY_COVER
BALL ↔ STEM/BOTTOM support
SEAT ↔ BODY
SEAT ↔ BODY_COVER
STEM ↔ STEM_COVER
ADAPTER ↔ STEM_COVER
```

## C. 尺寸回读

自动回读关键值：

```text
总F2F=610
BALL=465
BORE=303
主口=480
中法兰BCD≈526.5
顶安装面≈264.5
底安装面≈-270.5
F25 PCD=254
```

## D. Bounding Box

当前CAD预期参考：

```text
X≈610
Y≈562.5
Z≈719.1（不含真实蜗轮箱外壳）
```

若偏差超过配置阈值：

```text
WARN或FAIL
```

---

# 20. S12——保存与汇总

只有：

```text
S11无阻塞FAIL
```

才允许正式写入 `02_output`。

如果运行前已有旧文件：

```text
先复制到03_backup\run_时间戳
```

禁止：

```text
直接覆盖唯一可用源文件且无备份
```

---

# 21. 每次运行必须产生的日志文件

每一个 `run_YYYYMMDD_HHMMSS` 至少包含：

```text
00_master.log
01_environment.log
02_parameters.log
03_skeleton.log
04_ball.log
05_seats.log
06_body.log
07_body_cover.log
08_z_parts.log
09_adapter.log
10_assembly.log
11_validation.log
12_report.log

build_state.json
build_progress.json
parameters_snapshot.txt
feature_check.csv
model_inventory.csv
interference_report.csv
build_summary.md
```

以后如果失败，你只要把：

```text
04_logs\run_xxx\
```

整个目录给我，就能继续分析。

---

# 22. build_progress.json——给用户看的实时进度

建议格式：

```json
{
  "run_id": "20260822_113000",
  "project": "Q347F_12in_Class150",
  "overall_percent": 57,
  "current_step": "S06",
  "current_object": "BODY",
  "current_action": "Create M20 threaded pattern 20x",
  "status": "RUNNING",
  "started_at": "2026-08-22T11:30:00+08:00",
  "last_update": "2026-08-22T11:35:18+08:00",
  "steps": {
    "S00": "PASS",
    "S01": "PASS",
    "S02": "PASS",
    "S03": "PASS",
    "S04": "PASS",
    "S05": "PASS",
    "S06": "RUNNING",
    "S07": "WAITING",
    "S08": "WAITING",
    "S09": "WAITING",
    "S10": "WAITING",
    "S11": "WAITING",
    "S12": "WAITING"
  }
}
```

脚本每完成一个 Feature 或主要动作都必须刷新这个文件。

---

# 23. build_state.json——用于断点续跑

除了给人看的Progress，还要有给程序看的状态。

例如：

```json
{
  "last_passed_step": "S05",
  "failed_step": "S06",
  "failed_object": "07_BODY.SLDPRT",
  "safe_to_resume": true,
  "resume_from": "S06",
  "backup_path": "03_backup/run_20260822_113000"
}
```

以后可以支持：

```powershell
.\Build_Q347F_12in.ps1 -Resume
```

而不是每次从零重建。

---

# 24. 错误分级

## E1——立即停止

例如：

```text
参数缺失
API无法连接
Skeleton失败
BALL失败
BODY关键Feature失败
Assembly mate错误
保存失败
```

## E2——当前对象失败，允许以后重试

例如：

```text
一个附件Boss失败
非核心标准件缺失
```

仍必须把总Build标为：

```text
WARN / INCOMPLETE
```

不能显示100% PASS。

## W——警告

例如：

```text
AED O圈厂家数据未冻结
F25厂家接口未最终确认
设计温度未关闭
```

CAD草模可继续，但最终报告必须列出。

---

# 25. 日志中的“成功”必须分三层

以后禁止只写：

```text
成功
```

必须区分：

```text
CREATE_PASS
= Feature/API创建成功

REBUILD_PASS
= SolidWorks重建无错误

ENGINEERING_PASS
= 当前已定义工程校核通过
```

例如 BODY：

```text
CREATE_PASS      YES
REBUILD_PASS     YES
ENGINEERING_PASS PRELIMINARY
MANUFACTURING_FREEZE NO
```

这样不会把“画出来了”误认为“可以生产”。

---

# 26. 每个零件完成时必须显示小结

例如：

```text
------------------------------------------------------------
OBJECT COMPLETE: 07_BODY.SLDPRT
Progress        : 57%
Create          : PASS
Rebuild         : PASS
Feature errors  : 0
Warnings        : 1
Main OD CAD     : 504.0 mm
Main opening    : 480.0 mm
Mid flange BCD  : 526.5 mm
M20 holes       : 20
Manufacturing   : NOT FROZEN
Elapsed         : 00:01:44
------------------------------------------------------------
```

用户一眼就知道这个零件到底做到哪里。

---

# 27. 总装完成时最终报告必须这样回答

最终 `build_summary.md` 至少回答：

```text
本次是否完整执行？
完成到第几步？
生成了哪些SLDPRT？
是否生成SLDASM？
哪些Feature有WARN？
是否存在红叉？
是否有干涉？
F2F实际回读多少？
BALL实际回读多少？
当前CAD总包络多少？
哪些参数仍未制造冻结？
下一步建议是什么？
```

最终状态只能是：

```text
BUILD PASS
BUILD PASS WITH WARNINGS
BUILD INCOMPLETE
BUILD FAILED
```

---

# 28. 第一阶段实施顺序

不要一开始直接做全部零件。

## M1——先完成总控框架

开发：

```text
Build_Q347F_12in.ps1
日志模块
Progress模块
State模块
SW连接模块
```

验收：

```text
可以跑S00~S02
控制台显示进度
04_logs自动生成
build_progress.json持续更新
```

## M2——自动创建Skeleton

开发：

```text
Build_Skeleton.ps1
```

验收：

```text
00_SKELETON.SLDPRT真实生成
基准面真实生成
Rebuild PASS
关键坐标回读PASS
```

## M3——自动创建BALL

验收：

```text
01_BALL.SLDPRT真实生成
φ465 / φ303 / φ105 / φ70回读通过
```

## M4——BODY / BODY_COVER

核心壳体跑通后，再扩大到上下盖和总装。

---

# 29. 当前项目自动化开发进度

截至本规范 V1：

```text
设计参数主线         已建立
SolidWorks参数TXT    已建立
VBA参数初始化验证    已建立 / 备用
PowerShell+C#路线    已确认作为正式主路线
自动执行总控规范     本页完成

Build总控脚本        下一步
实时Progress模块     下一步
Skeleton自动生成     紧接着
BALL自动生成         Skeleton通过后
BODY自动生成         BALL通过后
总装自动生成         核心零件通过后
```

所以当前不是：

```text
已经一键自动生成整阀
```

而是：

```text
参数和自动执行规则已准备完成
↓
现在正式进入自动构建程序开发阶段
```

---

# 30. 永久执行原则

后续自动化必须遵守：

```text
先备份
再修改

每一步有日志
每一步有PASS条件

失败立即显式报告
禁止静默跳过

草模参数和制造冻结参数分开

先Skeleton
再核心零件
再总装
再标准件

每次Build都有Run ID
每次Build都可追溯
每次失败都能断点继续
```

最终目标不是“脚本运行完了”，而是：

> **用户能够清楚看到当前自动建模执行到哪里、已经生成了什么、哪些通过、哪些失败、失败后从哪里继续。**

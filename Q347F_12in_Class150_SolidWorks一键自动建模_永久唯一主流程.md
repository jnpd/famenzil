# Q347F 12寸 Class150——SolidWorks 一键自动建模永久唯一主流程

> **定位**：本文件是 Q347F 12寸 / NPS12 / DN300 / Class150 固定球阀 SolidWorks 自动建模的**永久唯一总流程**。  
> 后续所有 `Build_Q347F_12in*.ps1`、内嵌 C#、SolidWorks COM API、日志、进度条、断点续跑、零件构建器和总装构建器，都必须服从本流程。  
> 如果其他文档、旧脚本或旧宏与本流程冲突，以本流程和当前数字化总账为准。

---

# 1. 最终用户入口

最终目标不是让用户逐个运行脚本，而是只保留一个入口：

```text
双击：
一键生成12寸Q347F.bat
```

该入口启动：

```text
Build_Q347F_12in.ps1
```

主技术路线永久采用：

```text
Windows BAT
↓
PowerShell .ps1
↓
内嵌 C#
↓
SolidWorks COM API
↓
SOLIDWORKS 2025
```

VBA 宏只允许用于单零件调试、API试验和诊断，不再作为正式一键构建主入口。

---

# 2. 永久唯一自动建模主流程

```text
双击：
一键生成12寸Q347F.bat
        ↓
启动 Build_Q347F_12in.ps1
        ↓
连接 / 启动 SolidWorks 2025
        ↓
读取12寸参数
        ↓
自动建 Skeleton
        ↓
自动建球体
        ↓
自动建阀座
        ↓
自动建 BODY
        ↓
自动建 BODY_COVER
        ↓
自动建前盖
        ↓
自动建底盖
        ↓
自动建阀杆
        ↓
自动建连接盘
        ↓
自动生成 SLDASM
        ↓
自动配合
        ↓
Rebuild
        ↓
What's Wrong 检查
        ↓
干涉检查
        ↓
保存全部文件
        ↓
输出日志 / 进度 / 汇总报告
```

这条链以后不得随意改变顺序。

如果后续新增：

```text
标准件
轴承
O形圈
缠绕垫
弹簧
螺柱
螺母
排污阀
放空阀
注脂阀
蜗轮箱
```

应插入对应零件/总装阶段，不改变上面核心主线。

---

# 3. 为什么必须先 Skeleton

任何实体零件都不得先于 Skeleton 成为全局尺寸源。

Skeleton 必须统一保存：

```text
球心 O=(0,0,0)
X = FLOW_AXIS
Z = SUPPORT_AXIS
F2F=610
端面 X=±305
球体包络 φ465
流道 φ303
BODY / BODY_COVER主分界 X=+232.5 CAD
上前盖BODY安装面 Z≈+264.5 CAD
下底盖BODY安装面 Z≈-270.5 CAD
F25接口面 Z≈+337.3 CAD
阀杆顶部 Z≈+430 CAD
```

零件尽量从 Skeleton 引用基准和参数，而不是彼此互相引用，避免循环依赖。

---

# 4. 核心零件生成顺序

## 4.1 Skeleton

输出：

```text
00_SKELETON.SLDPRT
```

作用：

```text
统一原点
统一X/Z轴
统一关键基准面
统一包络
统一参数入口
```

Skeleton失败，整个构建立即停止。

---

## 4.2 球体 BALL

输出：

```text
01_BALL.SLDPRT
```

第一版必须包含：

```text
φ465球面
φ303流道
X向总宽348
上孔φ105
下孔φ70
阀杆驱动接口
```

球体是内部装配的核心运动/密封基准，BALL失败后禁止继续进入最终总装。

---

## 4.3 左右阀座 SEAT

输出建议：

```text
02_LEFT_SEAT.SLDASM
03_RIGHT_SEAT.SLDASM
```

或共用参数化零件后在总装中左右实例化。

必须验证：

```text
左右方向
球面接触位置
导向关系
轴向浮动空间
弹簧方向
```

---

## 4.4 主阀体 BODY

输出：

```text
07_BODY.SLDPRT
```

第一版至少创建：

```text
NPS12 Class150 RF端
φ303流道
中央球腔
左右阀座功能腔
BODY中央承压外包络
φ480主拆装口
主中法兰
20×M20螺纹锚固孔
上前盖接口
下底盖接口
VENT Boss
DRAIN Boss
```

BODY 是第一版自动建模中日志最详细的零件之一。

---

## 4.5 侧装主阀盖 BODY_COVER

输出：

```text
08_BODY_COVER.SLDPRT
```

必须包含：

```text
φ480 f8凸止口
φ466×7主O圈槽
φ500×φ490×3.2缠绕垫接口
20×φ22通孔 / 对应螺母支承区
右侧NPS12 Class150 RF端
内部φ382→φ303过渡
```

必须验证：

```text
BALL φ465能通过φ480主拆装口
BODY H8 / BODY_COVER f8关系正确
O圈槽不切穿
垫片与螺栓圈不冲突
```

---

## 4.6 前盖 STEM_COVER

输出：

```text
04_STEM_COVER.SLDPRT
```

必须建立：

```text
φ100上支承轴颈
φ105定位Boss
阀杆导向轴承轨
O圈轨
填料轨
BODY安装端面
上部连接接口
```

---

## 4.7 底盖 BOTTOM_COVER

输出：

```text
06_BOTTOM_COVER.SLDPRT
```

必须建立：

```text
一体φ65下支承轴颈
φ70定位Boss
φ58×5.3 AED O圈槽候选
φ80×φ70×3.2垫片接口
6×M12×55连接区
```

下支承轴颈不得错误拆成独立零件，除非12寸正式图纸后续明确反证。

---

## 4.8 阀杆 STEM

输出：

```text
05_STEM.SLDPRT
```

第一版：

```text
主径φ65
上键轴φ60
防吹出台肩≈φ74
18×11×90键槽
顶部Z≈+430 CAD
```

强度设计按：

```text
单键承担100% 1800 N·m
```

不能依赖双键均分扭矩。

---

## 4.9 连接盘 ADAPTER

输出：

```text
09_ADAPTER.SLDPRT
```

当前CAD主方案：

```text
ISO 5211 F25
OD≈φ300
PCD φ254
8×M16
接口面Z≈+337.3
```

厂家蜗轮箱正式图未关闭前，F25属于CAD主方案，不等于采购接口最终冻结。

---

# 5. 自动生成总装

输出：

```text
12-Q347F-150LB-总装图.SLDASM
```

总装自动插入顺序建议：

```text
BODY
↓
BALL
↓
LEFT SEAT
↓
RIGHT SEAT
↓
BODY_COVER
↓
STEM_COVER
↓
BOTTOM_COVER
↓
STEM
↓
ADAPTER
↓
标准件 / 密封件 / 轴承 / 紧固件
```

BODY作为总装基础件固定。

---

# 6. 自动配合原则

优先使用：

```text
统一Skeleton坐标
同轴
端面重合
基准面重合
限定轴向距离
```

禁止依赖：

```text
Face1
Face2
Edge7
随机拓扑ID
```

因为零件参数变化后实体面ID可能改变。

关键装配关系：

```text
BALL_CENTER = Origin
BALL_FLOW_AXIS = X
BALL_SUPPORT_AXIS = Z

BODY_COVER φ480止口 ↔ BODY φ480主口
STEM_COVER φ105Boss ↔ BODY上接口
BOTTOM_COVER φ70Boss ↔ BODY下接口
STEM ↔ BALL驱动接口
ADAPTER ↔ STEM_COVER / STEM上部
```

---

# 7. Rebuild不是最终成功

每个零件、总装都必须经过：

```text
Create Feature
↓
ForceRebuild
↓
Feature Error检查
↓
What's Wrong检查
↓
尺寸读回检查
↓
保存
```

因此必须永久区分：

```text
CREATE_PASS
REBUILD_PASS
ENGINEERING_PASS
MANUFACTURING_FREEZE
```

例如：

```text
BODY
CREATE_PASS          = YES
REBUILD_PASS         = YES
ENGINEERING_PASS     = PRELIMINARY
MANUFACTURING_FREEZE = NO
```

“能画出来”不等于“可以生产”。

---

# 8. What's Wrong 与干涉检查

总装完成后必须自动执行：

```text
Rebuild
↓
What's Wrong
↓
Feature Errors
↓
Interference Detection
↓
关键间隙检查
↓
装配路径检查
```

重点检查：

```text
φ465 BALL是否能通过φ480主拆装口
左右阀座是否和球面正确接触
BODY_COVER止口是否装得进去
主O圈槽是否有足够金属余量
M20圈与缠绕垫是否冲突
前盖/底盖Boss是否碰球体或轴承
阀杆防吹出台肩是否导致错误装配方向
F25连接盘是否和前盖/阀杆干涉
```

发现硬干涉：

```text
FAIL
停止最终成功状态
```

---

# 9. 保存要求

正式运行必须保留：

```text
源文件备份
构建前参数快照
本次生成SLDPRT
本次生成SLDASM
日志
错误报告
干涉报告
最终汇总
```

不得：

```text
构建失败后覆盖上一版成功模型
```

建议使用：

```text
03_backup\run_xxx\
02_output\current\
04_logs\run_xxx\
```

---

# 10. 日志与实时进度是主流程的一部分

日志不是附加功能。

从第一版脚本开始必须同步存在：

```text
当前Step
当前零件
当前Feature
总进度%
状态
耗时
API结果
错误码
下一步
```

例如：

```text
[13:25:12][S06][BODY][49%][RUNNING] Creating MAIN_OPENING Ø480
[13:25:16][S06][BODY][50%][PASS] MAIN_OPENING created
[13:25:18][S06][BODY][51%][RUNNING] Creating 20×M20 threaded holes
```

详细规范统一见：

```text
Q347F_12in_Class150_SolidWorks自动执行总控_步骤_日志_进度规范_V1.md
```

---

# 11. 断点续跑

正式总控脚本必须支持：

```powershell
Build_Q347F_12in.ps1 -Resume
```

例如：

```text
S00 PASS
S01 PASS
S02 PASS
S03 PASS
S04 PASS
S05 PASS
S06 FAIL
```

修复后：

```text
从S06恢复
```

而不是每次从头重新生成所有文件。

但若Skeleton参数版本发生变化：

```text
所有依赖Skeleton的后续零件必须标记STALE并重新构建
```

---

# 12. 当前开发原则

自动化开发不采用“一次写完44个零件”。

永久阶段：

```text
阶段1
一键入口 + 日志 + 参数 + SolidWorks连接
↓
阶段2
Skeleton
↓
阶段3
BALL
↓
阶段4
SEAT
↓
阶段5
BODY
↓
阶段6
BODY_COVER
↓
阶段7
Z向零件
↓
阶段8
ADAPTER
↓
阶段9
SLDASM
↓
阶段10
标准件 + 完整验证
```

每一阶段只有在：

```text
CREATE PASS
+
REBUILD PASS
+
日志完整
```

之后才能进入下一阶段。

---

# 13. 最终一句话定义

本项目的自动建模不是：

```text
AI直接生成一个3D外形
```

而是：

```text
数字化设计总账
↓
参数文件
↓
PowerShell + C#
↓
SolidWorks COM API
↓
真实SLDPRT / SLDASM特征树
↓
自动装配
↓
自动重建
↓
自动检查
↓
可追溯日志
```

这条路线从本文件起作为 **Q347F 12寸 Class150 SolidWorks自动建模永久唯一主流程**。

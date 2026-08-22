# Q347F 12寸 Class150——第7M步：SolidWorks Skeleton稳定建模 / 自动化边界 V43（实机统一版）

> **定位**：V43定义 `00_SKELETON.SLDPRT` 应该怎样建立、命名和验证。  
> **最新实机验证**：`S00～S03 PASS`，Skeleton 已生成。  
> **当前代码实现**：S04 BALL 已接入主流程，但尚未取得用户本机最新 `S04 PASS` 日志。  
> **正式路线**：`BAT → PowerShell → 内嵌C# → SolidWorks COM API`；VBA只用于诊断/小实验。  
> **关键纠错**：禁止把 SolidWorks 原生 `Front/Top/Right` 名称硬绑定为项目 `XZ/XY/YZ`，必须按真实世界几何识别。

[← 总导航](./00_Q347F_12in_Class150_文档导航_从这里开始.md)  
[← V42 参数交付](./Q347F_12in_Class150_第7L步_SolidWorks全局变量交付版_当前CAD_D门与HR隔离_V42.md)  
[← 当前数字总账](./Q347F_12in_Class150_数字化总装骨架_尺寸参数_装配关系_空间坐标总账.md)  
[→ 自动建模永久主流程](./Q347F_12in_Class150_SolidWorks一键自动建模_永久唯一主流程.md)

---

# 1. Skeleton永久职责

`00_SKELETON.SLDPRT` 是共享3D定位骨架，不是最终制造零件。

负责：

```text
球心O
项目X/Y/Z方向
关键X/Z站位
全局参数入口
BALL / BORE / BODY / F25包络
后续零件公共定位语义
```

不负责：

```text
最终制造公差
最终材料冻结
真实螺纹牙型
O形圈实体
弹簧螺旋线
铸造圆角最终制造形状
```

---

# 2. 项目坐标

```text
O = BALL_CENTER_O = (0,0,0)
X = FLOW_AXIS
Y = CROSS_AXIS
Z = SUPPORT_AXIS / STEM_AXIS

-X = 入口
+X = 出口
+Z = 阀杆/驱动
-Z = 底盖
```

这是项目语义，与SolidWorks原生平面显示名称无关。

---

# 3. 原生基准面映射——永久纠错

旧规则：

```text
Front Plane = XZ
Top Plane   = XY
Right Plane = YZ
```

当前：

```text
H/R
```

正确实现：

```text
获取原生RefPlane
↓
读取真实世界几何 / CornerPoints / 法向关系
↓
识别实际XY / XZ / YZ
↓
建立项目语义基准面
```

统一项目面：

```text
PLN_BASE_XY_FLOW_CROSS
PLN_BASE_XZ_FLOW_SUPPORT
PLN_BASE_YZ_CROSS_SUPPORT
```

---

# 4. 永久轴和球心

S03已实机建立：

```text
SK_PT_BALL_CENTER_O
AXIS_X_FLOW
AXIS_Z_SUPPORT
```

```text
AXIS_X_FLOW
→ BALL流道 / SEAT / END FLANGE / BODY流道

AXIS_Z_SUPPORT
→ BALL上下支承 / STEM / STEM_COVER / BOTTOM_COVER / ADAPTER
```

---

# 5. X向站位

11个：

```text
-305.000
-273.200
-232.500
-174.000
-166.036
0
+166.036
+174.000
+232.500
+273.200
+305.000
```

名称：

```text
PLN_X_M305_000
PLN_X_M273_200
PLN_X_M232_500
PLN_X_M174_000
PLN_X_M166_036
PLN_X_000_000
PLN_X_P166_036
PLN_X_P174_000
PLN_X_P232_500
PLN_X_P273_200
PLN_X_P305_000
```

身份：

```text
±305       = RF端面
±273.2     = 端法兰背面CAD
-232.5     = 左内部参考，不是第二主BODY joint
±174       = BALL平端
±166.036   = 真实SEAT/BALL密封接触
0          = BALL CENTER
+232.5     = 唯一主BODY/BODY_COVER分界
```

---

# 6. Z向站位

16个：

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

名称：

```text
PLN_Z_M289_100
PLN_Z_M270_500
PLN_Z_M230_000
PLN_Z_M227_000
PLN_Z_M177_000
PLN_Z_000_000
PLN_Z_P193_600
PLN_Z_P223_600
PLN_Z_P226_900
PLN_Z_P264_500
PLN_Z_P300_000
PLN_Z_P313_300
PLN_Z_P337_300
PLN_Z_P339_800
PLN_Z_P429_800
PLN_Z_P430_000
```

关键身份：

```text
-270.5 = BODY—BOTTOM_COVER安装面CAD
-230   = 下支承轴→φ70 Boss肩面
-227~-177 = 下主轴承

+193.6~+223.6 = 上主轴承
+226.9 = 上支承轴→φ105 Boss肩面
+264.5 = BODY—STEM_COVER安装面CAD
+313.3 = 填料压紧 / ADAPTER底参考
+337.3 = F25接口面
+339.8 = 键起点
+429.8 = 键终点
+430 = 阀杆顶部CAD参考
```

---

# 7. V32旧安装面隔离

```text
BODY_TOP_IF=+227      H/R
BODY_BOTTOM_IF=-230  H/R
```

当前：

```text
+226.9 = 上Boss肩面
-230.0 = 下Boss肩面
+264.5 = 真正BODY上安装面CAD
-270.5 = 真正BODY下安装面CAD
```

---

# 8. S03 Envelope

X=0构造包络：

```text
BALL φ465
BORE φ303
BODY φ504 CAD
MID FLANGE φ562.5 CAD
```

F25：

```text
OD φ300 CAD
Z=337.3
```

这些是空间/CAD包络，不是最终制造表面。

---

# 9. S03 PASS不能只看Feature创建

实际曾发生：

```text
PLN_Z_M289_100 Feature存在
但第一次readback actual=0 expected=-289.1
```

所以永久PASS门：

```text
Feature存在
+
ForceRebuild
+
世界坐标独立回读
+
Feature Error
+
What's Wrong
+
staging保存
+
PASS后publish
```

---

# 10. 当前S03实机结果

```text
S00 PASS
S01 PASS
S02 PASS
S03 PASS
```

```text
X=11/11 world-coordinate readback PASS
Z=16/16 world-coordinate readback PASS
RefPlaneCount=33
RefAxisCount=2
Rebuild PASS
Feature errors=0
What's Wrong errors=0
warnings=0
```

输出：

```text
SolidWorks_AutoBuild_Q347F_12in/02_output/00_SKELETON.SLDPRT
```

RefPlane=33：

```text
原生基准面 3
项目语义面 3
X站位 11
Z站位 16
合计 33
```

---

# 11. 保存发布规则

```text
创建到staging
↓
验证
↓
PASS
↓
备份上一版成功文件
↓
publish到02_output
```

S03：

```text
03_backup/run_xxx/00_SKELETON_staging.SLDPRT
↓
02_output/00_SKELETON.SLDPRT
```

失败不得覆盖上一版PASS。

---

# 12. VBA边界

旧V43计划：

```text
下一步V44写CreateSkeleton_V1.bas
```

当前实现已替代为：

```text
PowerShell + embedded C# + COM API
```

所以旧“V44 VBA Skeleton主路线”统一 `H/R-for-current-implementation`。

---

# 13. 开发状态 vs 实机状态

必须分开：

| Step | 代码实现 | 最新用户实机验证 |
|---|---|---|
| S00 | 已实现 | PASS |
| S01 | 已实现 | PASS |
| S02 | 已实现 | PASS |
| S03 | 已实现 | PASS |
| S04 BALL | **已实现并接入主流程** | **待下一次运行验证** |
| S05～S12 | 未实现 | WAITING |

运行开始前，S04在 `build_state` 中可以仍显示 `WAITING`；这不代表代码未实现。

---

# 14. S04当前参数口径

S04代码从唯一参数源读取：

```text
BALL_OD=465
BORE_D=303
BALL_W_X=348
BALL_UPPER_BORE_D=105
BALL_UPPER_BORE_DEPTH=30
BALL_LOWER_BORE_D=70
BALL_LOWER_BORE_DEPTH=52
BALL_DRIVE_SLOT_L_X=70
BALL_DRIVE_SLOT_W_Y=44
BALL_DRIVE_SLOT_R=8
BALL_DRIVE_SLOT_DEPTH=27
```

统一状态：

```text
φ105 / φ70 = 当前接口主链 C/C+
30 / 52 / 70×44 / R8 / 27 = CAD-draft candidates
```

不是自动制造冻结。

---

# 15. S04 PASS门

S04已实现，但必须等真实运行满足：

```text
01_BALL.SLDPRT创建
BALL_CORE存在
CUT_BORE_D303存在
CUT_UPPER_SUPPORT_BORE_D105存在
CUT_UPPER_DRIVE_SLOT_70x44_R8存在
CUT_LOWER_SUPPORT_BORE_D70存在
SolidBodyCount=1
X width≈348
Y envelope≈465
Z envelope与解析切除结果一致
ForceRebuild PASS
Feature errors=0
What's Wrong errors=0
staging保存
publish成功
```

之后才能写：

```text
S04 PASS
```

**V43当前结论**：Skeleton基础链已经实机闭合；S04代码已经完成接入，下一工作不是“写S04”，而是**运行并验证S04 BALL**。
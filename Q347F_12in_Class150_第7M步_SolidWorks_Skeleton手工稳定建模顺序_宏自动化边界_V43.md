# Q347F 12寸 Class150——第7M步：SolidWorks Skeleton稳定建模 / 自动化边界 V43（实机统一版）

> **定位**：V43定义 `00_SKELETON.SLDPRT` 应该怎样建立、怎样命名、怎样验证。  
> **当前状态**：这已经不是“准备写宏”的计划页。S00～S03 已在 SOLIDWORKS 2025 实机跑通，Skeleton 已生成。  
> **正式技术路线**：`BAT → PowerShell → 内嵌C# → SolidWorks COM API`；VBA只保留用于诊断和API小实验。  
> **最重要纠错**：禁止再把 SolidWorks 原生 `Front/Top/Right` 名称硬绑定为项目 `XZ/XY/YZ`。必须按真实世界几何识别。

[← 总导航](./00_Q347F_12in_Class150_文档导航_从这里开始.md)  
[← V42 SolidWorks参数交付](./Q347F_12in_Class150_第7L步_SolidWorks全局变量交付版_当前CAD_D门与HR隔离_V42.md)  
[← 当前数字总账](./Q347F_12in_Class150_数字化总装骨架_尺寸参数_装配关系_空间坐标总账.md)  
[→ 自动建模永久主流程](./Q347F_12in_Class150_SolidWorks一键自动建模_永久唯一主流程.md)

---

# 1. Skeleton的永久职责

`00_SKELETON.SLDPRT` 是共享3D定位骨架，不是最终制造零件。

它负责：

```text
球心O
项目X/Y/Z方向
关键X/Z站位
全局参数入口
BALL / BORE / BODY / F25包络
后续零件的公共定位语义
```

它不负责：

```text
真实螺纹牙型
O形圈实体
弹簧螺旋线
铸造圆角最终制造形状
最终公差
最终材料冻结
```

---

# 2. 当前唯一项目坐标定义

```text
O = BALL_CENTER_O = (0,0,0)
X = FLOW_AXIS
Y = CROSS_AXIS
Z = SUPPORT_AXIS / STEM_AXIS
```

方向：

```text
-X = 入口
+X = 出口
+Z = 阀杆/驱动
-Z = 底盖
```

这些是**项目语义**，与 SolidWorks 原生平面的显示名称无关。

---

# 3. 原生基准面映射——本轮最关键纠错

旧V43曾写：

```text
Front Plane = XZ
Top Plane   = XY
Right Plane = YZ
```

并称“永久不改”。

这条规则已经被 S03 实机证明不可靠，现统一：

```text
旧硬绑定 = H/R
```

当前正确实现：

```text
获取SolidWorks原生RefPlane
↓
读取真实世界几何 / CornerPoints / 法向关系
↓
识别其实际XY / XZ / YZ
↓
建立项目自己的语义基准面
```

统一项目面：

```text
PLN_BASE_XY_FLOW_CROSS
PLN_BASE_XZ_FLOW_SUPPORT
PLN_BASE_YZ_CROSS_SUPPORT
```

以后脚本、零件、装配文档都引用项目语义名，不引用“Front/Top/Right一定代表什么”。

---

# 4. 永久轴和球心

当前 S03 已建立并验证：

```text
SK_PT_BALL_CENTER_O
AXIS_X_FLOW
AXIS_Z_SUPPORT
```

意义：

```text
AXIS_X_FLOW
→ BALL流道 / SEAT / END FLANGE / BODY主流道

AXIS_Z_SUPPORT
→ BALL上下支承 / STEM / STEM_COVER / BOTTOM_COVER / ADAPTER
```

---

# 5. X向站位——当前实机名称规则

S03当前要求11个X站位：

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

自动命名示例：

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
-305 / +305      = RF端面
-273.2 / +273.2  = 端法兰背面CAD
-232.5           = 左内部参考站，不是第二个主BODY joint
-174 / +174      = BALL左右平端
-166.036/+166.036= 真实SEAT/BALL密封接触站
0                = BALL CENTER
+232.5           = 唯一主BODY/BODY_COVER分界
```

---

# 6. Z向站位——当前实机名称规则

S03要求16个Z站位：

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

自动命名示例：

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
-230   = 下支承轴→φ70定位Boss肩面
-227   = 下主轴承外端
-177   = 下主轴承内端

+193.6 = 上主轴承内端
+223.6 = 上主轴承外端
+226.9 = 上支承轴→φ105定位Boss肩面
+264.5 = BODY—STEM_COVER安装面CAD
+313.3 = 填料压紧 / ADAPTER底参考
+337.3 = F25接口面
+339.8 = 键起点
+429.8 = 键终点
+430   = 阀杆顶部CAD参考
```

---

# 7. V32旧安装面必须永久隔离

禁止重新使用：

```text
BODY_TOP_IF=+227
BODY_BOTTOM_IF=-230
```

统一：

```text
+226.9 ≈ 上支承轴→φ105 Boss肩面
-230.0 = 下支承轴→φ70 Boss肩面

真正BODY安装面CAD：
+264.5
-270.5
```

---

# 8. S03第一版Envelope

当前 Skeleton 只建立构造/包络，不做制造实体。

X=0主包络：

```text
BALL φ465
BORE φ303
BODY中央外包络 φ504 CAD
MID FLANGE φ562.5 CAD
```

F25包络：

```text
OD φ300
Z=337.3
```

这些包络的作用是：

```text
快速观察总体空间
后续零件定位
预防明显硬干涉
```

不是最终制造表面。

---

# 9. 为什么不在Skeleton里建复杂实体

如果骨架阶段就加入：

```text
真实螺纹
O圈实体
弹簧
所有孔
复杂铸造形状
```

会把“坐标/参数错误”和“零件特征错误”混在一起。

所以当前分层：

```text
S03 Skeleton
= 坐标 + 参数 + 基准 + 包络

S04以后 Parts
= 实体特征 + 功能几何
```

---

# 10. 当前验证方式——不能只看Feature名称

一开始曾出现：

```text
PLN_Z_M289_100 created
但readback actual=0 expected=-289.1
```

所以现在 S03 PASS 条件不是：

```text
“Feature创建成功”
```

而是：

```text
Feature存在
+
ForceRebuild
+
世界坐标独立回读
+
What's Wrong / Feature Error
+
保存成功
```

当前世界坐标验证已经证明：

```text
X=11 / 11 PASS
Z=16 / 16 PASS
```

---

# 11. 当前S03实机最终结果

成功运行：

```text
S00 PASS
S01 PASS
S02 PASS
S03 PASS
```

关键结果：

```text
Required station planes verified by feature name and world-coordinate readback.
X=11
Z=16

Rebuild PASS
What's Wrong errors=0
warnings=0

RefPlaneCount=33
RefAxisCount=2
```

最终发布：

```text
SolidWorks_AutoBuild_Q347F_12in/02_output/00_SKELETON.SLDPRT
```

---

# 12. RefPlaneCount=33为什么合理

当前计数包含：

```text
SolidWorks原生基准面      3
项目语义基准面            3
X站位面                  11
Z站位面                  16
----------------------------
合计                     33
```

轴：

```text
AXIS_X_FLOW
AXIS_Z_SUPPORT
```

合计2根。

---

# 13. S03保存发布规则

禁止直接覆盖上一版成功 Skeleton。

当前：

```text
创建/修改
↓
保存 staging
↓
Rebuild / readback / What's Wrong
↓
PASS
↓
备份上一版成功文件
↓
publish到02_output
```

staging示例：

```text
03_backup/run_xxx/00_SKELETON_staging.SLDPRT
```

正式：

```text
02_output/00_SKELETON.SLDPRT
```

失败时不得发布为最新成功版。

---

# 14. V43自动化边界已经更新

旧V43计划：

```text
下一步写CreateSkeleton_V1.bas
```

当前已经被正式路线替代：

```text
PowerShell + embedded C# + COM API
```

所以：

```text
“下一步V44 VBA Skeleton宏” = H/R-for-current-implementation
```

VBA仍允许：

```text
API单点实验
本机诊断
人工验证
```

但不作为永久一键构建主入口。

---

# 15. 当前正式构建阶段

```text
S00 环境             PASS
S01 参数             PASS
S02 SolidWorks       PASS
S03 Skeleton         PASS
S04 Ball             WAITING / 下一实施
S05 Seats            WAITING
S06 BODY             WAITING
S07 BODY_COVER       WAITING
S08 Z Parts          WAITING
S09 ADAPTER/F25      WAITING
S10 Assembly         WAITING
S11 Validation       WAITING
S12 Save/Report      WAITING
```

---

# 16. 下一步唯一目标——S04 BALL

S04需要从 Skeleton / 参数源消费：

```text
BALL_OD=465
BORE_D=303
BALL_W_X=348
BALL_UPPER_BORE_D=105
BALL_LOWER_BORE_D=70
```

当前CAD候选还包括：

```text
UPPER_BORE_DEPTH=30
LOWER_BORE_DEPTH=52
DRIVE_SLOT=70×44
R8
DEPTH=27
```

这些允许用于第一版 S04 参数化模型，但必须明确：

```text
CAD候选
≠ 制造冻结
```

S04 PASS 至少要求：

```text
01_BALL.SLDPRT创建成功
φ465回读正确
φ303流道回读正确
X向宽348回读正确
φ105/φ70孔径正确
关键接口/驱动槽存在
ForceRebuild PASS
What's Wrong errors=0
Feature errors=0
保存成功
```

---

# 17. V43一句话结论

现在已经不再是：

```text
“先试着建一个Skeleton看看”
```

而是：

```text
数字参数
↓
自动创建真实Skeleton
↓
世界坐标回读
↓
Rebuild / What's Wrong
↓
S03 PASS
```

这条基础链已经实机闭合。后续所有零件都必须沿这套**项目语义坐标 + 参数状态隔离 + 独立回读验证**规则继续。
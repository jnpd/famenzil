# Q347F 12寸 Class150——第7L步：SolidWorks参数交付 / 当前CAD / D门 / H-R隔离 V42（当前统一版）

> **定位**：V42定义“哪些工程参数可以进入 SolidWorks、以什么方式进入、哪些值必须隔离”。  
> **当前实机状态**：S00～S03 已 PASS，`00_SKELETON.SLDPRT` 已成功生成。  
> **正式技术路线**：`BAT → PowerShell → 内嵌C# → SolidWorks COM API`。VBA仅保留为诊断/试验工具，不是正式主构建器。  
> **参数源**：[Q347F_12in_Class150_00_SKELETON_GlobalVariables_V1.txt](./Q347F_12in_Class150_00_SKELETON_GlobalVariables_V1.txt)

[← 总导航](./00_Q347F_12in_Class150_文档导航_从这里开始.md)  
[← 当前数字总账](./Q347F_12in_Class150_数字化总装骨架_尺寸参数_装配关系_空间坐标总账.md)  
[→ V43 Skeleton规则](./Q347F_12in_Class150_第7M步_SolidWorks_Skeleton手工稳定建模顺序_宏自动化边界_V43.md)  
[→ 自动建模永久主流程](./Q347F_12in_Class150_SolidWorks一键自动建模_永久唯一主流程.md)

---

# 1. 当前参数交付方式

旧的“人工在 Equation Manager 中长期 Link to external file”可以作为手工调试方法，但**不是当前正式一键构建的唯一实现**。

当前正式实现：

```text
Q347F_12in_Class150_00_SKELETON_GlobalVariables_V1.txt
        ↓
S01 PowerShell解析/单位与逻辑校验
        ↓
生成本次 parameters_snapshot.txt + SHA256
        ↓
S03 通过内嵌C#调用 EquationMgr
        ↓
ImportOrUpdateEquations
        ↓
00_SKELETON.SLDPRT
```

所以 txt 的角色是：

> **唯一当前CAD参数源 / 可追溯文本输入。**

它不是完整工程计算书，工程计算依据仍在计算主线和数字总账中。

---

# 2. 为什么参数层与零件层必须分离

推荐架构：

```text
工程计算
↓
数字总账
↓
GlobalVariables.txt
↓
00_SKELETON
↓
BALL / SEAT / BODY / COVERS / STEM / ADAPTER
```

不推荐所有零件各自长期直接依赖同一个外部txt，因为容易形成：

```text
重建顺序混乱
外部引用循环
路径丢失
变量名漂移
配置互相覆盖
```

后续零件优先通过统一语义基准、参数快照和构建器获取数据，而不是互相引用随机实体面。

---

# 3. 参数状态与SolidWorks权限

允许当前CAD草模使用：

```text
A
A-policy（按规则）
B
C+
C
明确批准的C-space / CAD envelope
```

禁止自动写死：

```text
D
H
H/R
未关闭的R
```

必须长期区分：

```text
CAD_DRAFT
≠ ENGINEERING_FREEZE
≠ MANUFACTURING_FREEZE
```

例如：

```text
BALL_LOWER_BORE_DEPTH=52
```

当前只能解释为：

```text
S04 CAD候选
```

不能因为它已经写入 txt 就自动升级为制造冻结尺寸。

---

# 4. 当前核心X向参数

```text
VALVE_F2F=610
HALF_F2F=305
X_END_FACE_L=-305
X_END_FACE_R=+305

X_END_FLANGE_BACK_L_CAD≈-273.2
X_BODY_JOINT_REF_L=-232.5 仅内部参考，不是第二主分界
BALL_X_L=-174
X_CONTACT_L=-166.036
BALL_CENTER=0
X_CONTACT_R=+166.036
BALL_X_R=+174
X_BODY_JOINT_CAD=+232.5
X_END_FLANGE_BACK_R_CAD≈+273.2
```

唯一主BODY分界只有：

```text
X_BODY_JOINT_CAD=+232.5
```

---

# 5. 当前BALL参数

```text
BORE_D=303
BALL_OD=465
BALL_R=232.5
BALL_W_X=348
BALL_X_L/R=±174
```

S04当前CAD候选：

```text
BALL_UPPER_BORE_D=105
BALL_UPPER_BORE_DEPTH=30
BALL_LOWER_BORE_D=70
BALL_LOWER_BORE_DEPTH=52
BALL_DRIVE_SLOT_L_X=70
BALL_DRIVE_SLOT_W_Y=44
BALL_DRIVE_SLOT_R=8
BALL_DRIVE_SLOT_DEPTH=27
```

统一状态解释：

```text
φ105 / φ70接口径：当前结构主链 C/C+
30 / 52深度：CAD候选 C-CAD
70×44 / R8 / 深27驱动槽：CAD候选 C-CAD
```

它们允许 S04 建模和验证，但不自动成为球体制造图冻结值。

---

# 6. 阀座当前参数

```text
SEAT_D9=323.88
SEAT_D10=327.13
SEAT_D11=342
SEAT_GUIDE_BORE=342.4
SEAT_PILOT_2=323.6
SEAT_GUIDE_2=323.8
SPRING_PCD=362
SEAT_BIG_OD=380
SEAT_BIG_BORE=382
WSEAT_ENV=58
```

真实接触：

```text
X_CONTACT_L=-166.036
X_CONTACT_R=+166.036
```

`WSEAT_ENV=58` 为当前空间包络，不等于内部所有轴向站位已经制造冻结。

---

# 7. BODY / BODY_COVER当前CAD参数

```text
BODY_CAVITY_D_FUNC_CAD=471
BODY_OUTER_D_CENTRAL_CAD=504
MAIN_OPENING_D=480
MAIN_COVER_PILOT_D=480
MAIN_COVER_PILOT_L_CAD=20
```

主O圈：

```text
φ466×7
径向静密封
槽深5.7
槽宽9.5
槽根φ468.6
```

中法兰：

```text
MID_GASKET=φ500×φ490×3.2
MID_BCD_CAD=526.5
MID_FLANGE_OD_CAD=562.5
MID_STUD=20×M20×85
```

主开口局部Boss：

```text
MAIN_OPENING_BOSS_OD_CAD≈520
```

---

# 8. Z向当前参数

上主支承：

```text
UP_BRG=φ105×φ100×30
Z=193.6~223.6
CENTER=208.6
Z_TOP_SHOULDER=226.9
Z_BODY_TOP_IF_CAD=264.5
TOP_PILOT_ENGAGEMENT_CAD=37.6
```

下主支承：

```text
LOWER_BRG=φ70×φ65×50
Z=-227~-177
CENTER=-202
Z_BOTTOM_SHOULDER=-230
Z_BODY_BOTTOM_IF_CAD=-270.5
BOTTOM_PILOT_ENGAGEMENT_CAD=40.5
```

历史：

```text
+227作为BODY上安装面 → H/R
-230作为BODY下安装面 → H/R
```

---

# 9. STEM / F25 当前参数

```text
STEM_MAIN_D=65
STEM_KEY_D=60
STEM_SHOULDER_OD=74
KEY=18×11×90
```

F25：

```text
ADAPTER_OD_CAD=300
ADAPTER_T_CAD=24
Z_ADAPTER_BOTTOM_CAD=313.3
Z_F25_INTERFACE_CAD=337.3
F25_BOLT_PCD=254
F25_BOLT_QTY=8
F25_THREAD_D=16
F25_CLEAR_HOLE_D=17.5
F25_HOLE_START_ANGLE=22.5°
F25_HOLE_STEP=45°
```

键轴站位：

```text
Z_KEY_START_CAD≈339.8
Z_KEY_END_CAD≈429.8
Z_STEM_TOP_CAD≈430
```

---

# 10. SolidWorks原生基准面——永久纠错

项目语义坐标：

```text
O=(0,0,0)
X=FLOW_AXIS
Y=CROSS_AXIS
Z=SUPPORT_AXIS
```

**禁止硬编码：**

```text
Front=XZ
Top=XY
Right=YZ
```

当前 S03 正确实现：

```text
读取原生RefPlane真实世界几何
↓
识别哪个平面是XY / XZ / YZ
↓
建立项目语义基准面
```

统一名称：

```text
PLN_BASE_XY_FLOW_CROSS
PLN_BASE_XZ_FLOW_SUPPORT
PLN_BASE_YZ_CROSS_SUPPORT
AXIS_X_FLOW
AXIS_Z_SUPPORT
SK_PT_BALL_CENTER_O
```

这条规则已经由实际 S03 世界坐标回读验证，不再回退到依赖中文/英文原生平面名称的方法。

---

# 11. EquationMgr当前实现注意项

这轮实机已经踩过并关闭：

```text
单配置新Part导入全局变量：使用适合当前场景的 Add2 路径
角度参数：源文件可保留deg语义，导入时做SolidWorks可接受的角度规范化
PowerShell COM对象：不在PowerShell边界强制绑定为SldWorks/ModelDoc2
COM强类型转换：放到内嵌C#内部
```

原则：

> PowerShell负责流程编排；SolidWorks COM强类型调用尽量封装在C#层。

---

# 12. 当前D门——不得因为CAD需要数值就乱填

```text
T_DESIGN
P_RATING_ALLOWED
2.00MPa最终项目合规口径
BALL_BODY_CLR_RAD_FINAL
BODY_FINAL_WALL
X_BODY_JOINT_FINAL
BODY/BODY_COVER最终止口加工公差
TOP/BOTTOM PILOT最终配合公差
上/下盖最终BCD和OD
底部AED O圈厂家最终槽
316+PTFE真实许用面压
DEVLON最终完整牌号/热配合公差
STEM_TOTAL_LEN_FINAL
GEARBOX_SPIGOT_D_FINAL
GEARBOX_INPUT_BORE_FINAL
GEARBOX_KEYWAY_FINAL
```

---

# 13. 当前H/R隔离表

```text
左右两个主阀盖
第二个主BODY joint
主止口φ450
φ466×7端面O圈
端面槽φ463.5~φ482.5
RF OD φ355.6
BODY中央φ498.2作为当前默认
+227作为BODY上安装面
-230作为BODY下安装面
Front=XZ / Top=XY / Right=YZ永久硬绑定
F20作为当前ISO5211主接口
双键默认50/50均载
```

这些值只允许历史追溯，不得重新进入当前CAD主线。

---

# 14. S03当前as-built结果

实机已经得到：

```text
S00 PASS
S01 PASS
S02 PASS
S03 PASS
```

Skeleton验证：

```text
11个X站位全部世界坐标回读PASS
16个Z站位全部世界坐标回读PASS
RefPlaneCount=33
RefAxisCount=2
ForceRebuild PASS
Feature errors=0
What's Wrong errors=0
warnings=0
00_SKELETON.SLDPRT published
```

所以当前 V42 已从“准备交给 SolidWorks”升级为：

> **参数交付链已经由真实 SolidWorks 2025 自动执行验证通过。**

---

# 15. 当前正式输出与下一步

参数源：

```text
Q347F_12in_Class150_00_SKELETON_GlobalVariables_V1.txt
```

当前模型输出：

```text
SolidWorks_AutoBuild_Q347F_12in/02_output/00_SKELETON.SLDPRT
```

下一步不再是“V43写VBA宏”，而是：

```text
S04 BALL
↓
自动创建 01_BALL.SLDPRT
↓
关键尺寸回读
↓
Rebuild
↓
What's Wrong / Feature Error
↓
保存与日志
```

**V42一句话结论**：当前工程数据已经成功穿过“数字总账 → 参数txt → S01解析 → S03 EquationMgr/几何构建 → Skeleton验证”，后续保持同一套状态隔离和验证规则继续 S04。
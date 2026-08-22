# Q347F 12寸 Class150——第7L步：SolidWorks全局变量交付版 / 当前CAD / D门 / H-R隔离 V42

> **定位**：V41已经证明当前主总装骨架在XYZ三方向具备第一版装配通路。V42开始真正“交给SolidWorks”，不再只写计算说明。
>
> **配套文件**：[Q347F_12in_Class150_00_SKELETON_GlobalVariables_V1.txt](./Q347F_12in_Class150_00_SKELETON_GlobalVariables_V1.txt)
>
> **核心原则**：外部方程式文件只服务 `00_SKELETON.SLDPRT`。所有 `D` 未知值与 `H/R` 历史错误值都不写进自动方程式；少量 `C/R` 或 `P-XREF` 当前草模值若必须用于形成实体，会明确列入“仅CAD显示层”，不得从模型反向抄成制造图尺寸。

[← 总导航](./00_Q347F_12in_Class150_文档导航_从这里开始.md)  
[← V41 完整总装骨架](./Q347F_12in_Class150_第7K步_完整总装骨架_XYZ包络_装配与维修路径预检查_V41.md)

---

# 1. SOLIDWORKS 2025外部方程式的正确用法

SOLIDWORKS支持在外部文本文件中按“方程式管理器同样格式”写：

```text
"base" = 20
"D1@Boss-Extrude1" = "base" + 10
```

然后：

```text
工具 Tools
→ 方程式 Equations
→ 链接到外部文件 / Link to external file
```

本项目唯一主链接文件：

```text
Q347F_12in_Class150_00_SKELETON_GlobalVariables_V1.txt
```

建议：

```text
00_SKELETON.SLDPRT
↕ 唯一长期链接
GlobalVariables_V1.txt
```

零件不要十几个一起长期链接同一个txt；零件优先通过Skeleton的基准面、草图、实体/曲面引用获得尺寸。

---

# 2. 为什么只让Skeleton链接外部参数

如果：

```text
BODY
BALL
BODY_COVER
STEM_COVER
BOTTOM_COVER
ADAPTER
...
```

全部独立链接同一个txt，后面很容易出现：

```text
重建顺序
外部引用循环
文件路径丢失
某零件局部变量改名
不同配置互相覆盖
```

当前推荐：

```text
GlobalVariables.txt
↓
00_SKELETON.SLDPRT
↓
主基准面 / 轴 / 主草图 / 包络曲面
↓
各零件In-context或派生引用
```

这与本项目一直坚持的：

```text
尺寸参数 + 装配关系 + 空间坐标
→ Skeleton
→ Parts
```

完全一致。

---

# 3. 当前外部txt已经包含哪些主变量

## 3.1 X向总体

```text
VALVE_F2F=610
X_END_FACE_L=-305
X_END_FACE_R=+305
X_BODY_JOINT_CAD=+232.5
```

端法兰：

```text
OD=482.6
BCD=431.8
12×φ25.4
RF OD=381
法兰本体厚CAD=30.2
RF高CAD=1.6
法兰背面≈±273.2
```

---

# 4. 球体 / 阀座

```text
BORE_D=303
BALL_OD=465
BALL_R=232.5
BALL_W_X=348
BALL_X_L/R=±174
X_CONTACT_L/R=±166.036
```

阀座：

```text
D9=323.88
D10=327.13
D11=342
guide bore=342.4
pilot2=323.6
bore2=323.8
spring PCD=362
big OD=380
big bore=382
WSEAT_ENV=58
```

---

# 5. BODY / BODY_COVER当前CAD主变量

```text
当前显示球腔 = φ471
当前中央承压外包络 = φ504
主拆装口 = φ480
BODY_COVER止口 = φ480
止口长 =20
```

主O圈：

```text
φ466×7
槽深5.7
槽宽9.5
槽根φ468.6
```

主垫片/中法兰：

```text
φ500×φ490×3.2
BCD=526.5 CAD
中法兰OD=562.5 CAD
20×M20×85
```

主开口局部压力Boss：

```text
≈φ520 CAD
```

---

# 6. Z向上支承 / 前盖

```text
上球体轴承 = φ105×φ100×30
Z=193.6~223.6
中心=208.6
```

前盖：

```text
φ100一体支承轴
轴→Boss肩面 Z=226.9
φ105定位Boss
BODY安装面 Z=264.5
Boss有效长≈37.6
前盖法兰厚CAD≈35.5
外侧粗参考Z≈300
```

主连接：

```text
4×M12×75
```

---

# 7. 阀杆 / 填料内轨

```text
主径φ65
上键轴φ60
防吹出肩φ74
阀杆导向轴承φ70×φ65×50
```

密封/填料：

```text
阀杆O圈槽根φ73.8
槽宽7
双O圈中间功能区≈17.3
填料φ75×φ65×5
压后厚CAD≈4.4
填料压紧面Z≈313.3
```

---

# 8. 下支承 / 底盖

```text
下轴承φ70×φ65×50
Z=-227~-177
中心=-202
```

底盖：

```text
φ65一体支承轴
轴→Boss肩面Z=-230
φ70定位Boss
BODY安装面Z=-270.5
有效Boss长≈40.5
底盖法兰厚CAD≈20
外侧粗参考Z≈-289.1
```

密封：

```text
φ58×5.3 AED
当前槽根φ61.6 C/R
φ80×φ70×3.2垫片
6×M12×55
```

---

# 9. F25连接盘 / 驱动链

当前：

```text
ADAPTER_OD_CAD=300
ADAPTER_T_CAD=24
Z_ADAPTER_BOTTOM=313.3
Z_F25_INTERFACE=337.3
```

ISO 5211 F25：

```text
PCD254
8×M16
φ17.5通孔口径
M16螺纹深度24级
首孔22.5°
孔间隔45°
中心止口最大包络φ200
```

键轴：

```text
φ60
18×11×90 C型键
KEY_START≈339.8
KEY_END≈429.8
STEM_TOP_CAD≈430
```

---

# 10. 外部txt中的“可直接SolidWorks草模值”不等于制造冻结

把外部变量再分两层。

## A层——结构主基准，优先稳定

```text
F2F610
端面±305
球心O
球体φ465
流道φ303
球宽348
真实密封接触±166.036
主BODY分界+232.5
主拆装口φ480
主中法兰垫片φ500/490
20×M20
上下轴承规格
上下支承轴φ100/φ65
上键轴φ60
F25 PCD254 / 8×M16 / φ300最小接口
```

这些变化会牵动全总装，除非新证据推翻，不随便改。

## B层——当前CAD/Envelope值

```text
球腔φ471
BODY中央外径φ504
主中法兰OD562.5
主开口Bossφ520
上安装面264.5
下安装面-270.5
上Boss长37.6
下Boss长40.5
连接盘厚24
底O圈槽根61.6
STEM_TOP=430
```

这些可以形成第一版3D，但制造冻结前可能回算。

---

# 11. 明确不进入外部txt的D变量

以下不能因为SolidWorks需要数值就乱填：

```text
T_DESIGN
P_RATING_ALLOWED(T)
2.00MPa最终项目合规口径
BALL_BODY_CLR_RAD_FINAL
BODY_FINAL_WALL
X_BODY_JOINT_FINAL
BODY/BODY_COVER最终止口长度与加工公差
上下BODY安装面FINAL
TOP_PILOT_FIT_FINAL
BOTTOM_PILOT_FIT_FINAL
底部AED O圈厂家最终槽
上/下盖最终BCD和OD
316+PTFE轴承真实许用面压
DEVLON最终完整牌号/热膨胀制造公差
双键槽最终角度
实际安装键数量
STEM_KEYWAY_KT_FINAL
ADAPTER_T_FINAL
GEARBOX_SPIGOT_D_FINAL
GEARBOX_INPUT_BORE_FINAL
GEARBOX_KEYWAY_FINAL
STEM_TOTAL_LEN_FINAL
真实蜗轮箱总体尺寸
```

它们继续留在Markdown设计账，不写问号进方程式文件。

---

# 12. 明确禁止进入方程式的H/R旧值

```text
左右各一只主阀盖
X_BODY_COVER_IF_L/R镜像
主中法兰M24×100×10
主止口φ450
φ466×7端面O圈
BODY中央外径φ498.2作为当前默认
RF OD φ355.6
+227作为BODY上安装面
-230作为BODY下安装面
F20作为ISO 5211标准接口
双键默认50/50均载
```

这些历史数字只为追溯，禁止重新进入当前模型。

---

# 13. 第一次导入后必须核对的7个结果

链接txt并重建后，先不要画复杂实体，只看方程式结果：

```text
HALF_F2F =305
X_END_FLANGE_BACK_R≈273.2
X_END_FLANGE_BACK_L≈-273.2
Z_ADAPTER_TOP=337.3
Z_KEY_START=339.8
Z_KEY_END=429.8
ASM_Z_TOTAL≈719.1
```

如果任何一项不对，先修外部方程式，不要继续建零件。

---

# 14. 00_SKELETON建议第一版特征树

```text
00_SKELETON.SLDPRT
│
├─ Origin = BALL_CENTER_O
├─ Axis_X = FLOW_AXIS
├─ Axis_Z = SUPPORT_AXIS
│
├─ PLN_X_END_L       X=-305
├─ PLN_BALL_FACE_L   X=-174
├─ PLN_BALL_CENTER   X=0
├─ PLN_BALL_FACE_R   X=+174
├─ PLN_BODY_JOINT    X=+232.5
├─ PLN_X_END_R       X=+305
│
├─ PLN_UP_BRG_Z0     Z=193.6
├─ PLN_UP_BRG_Z1     Z=223.6
├─ PLN_TOP_SHOULDER  Z=226.9
├─ PLN_BODY_TOP_IF   Z=264.5
├─ PLN_PACK_PRESS    Z=313.3
├─ PLN_F25           Z=337.3
├─ PLN_KEY_START     Z=339.8
├─ PLN_KEY_END       Z=429.8
│
├─ PLN_LOW_BRG_IN    Z=-177
├─ PLN_LOW_BRG_OUT   Z=-227
├─ PLN_BOTTOM_SHOULDER Z=-230
├─ PLN_BODY_BOTTOM_IF  Z=-270.5
│
├─ SK_XZ_MAIN_SECTION
├─ SK_XY_F25_PATTERN
├─ SK_YZ_MAIN_JOINT
│
├─ ENV_BALL
├─ ENV_SEAT_L
├─ ENV_SEAT_R
├─ ENV_BODY
├─ ENV_BODY_COVER
├─ ENV_TOP_SUPPORT
├─ ENV_BOTTOM_SUPPORT
└─ ENV_F25
```

---

# 15. 外部方程式文件不直接绑零件尺寸名

V1文件现在主要定义：

```text
Global Variables
```

而不是写死：

```text
D1@Sketch7
D2@Boss-Extrude14
```

原因：零件特征树还没创建，提前猜特征名反而会导致导入失败。

正确顺序：

```text
先导入Global Variables
↓
建立Skeleton特征
↓
再让具体尺寸引用变量
```

---

# 16. 当前交付物

```text
Q347F_12in_Class150_00_SKELETON_GlobalVariables_V1.txt
```

用途：

```text
SOLIDWORKS 2025
Tools → Equations
→ Link to external file
```

然后用本页第14节建立骨架树。

---

# 17. 下一步 V43

下一步直接把V42转换成“手工建骨架的点击顺序 + VBA宏输入规范”：

```text
创建新零件00_SKELETON
↓
导入GlobalVariables
↓
自动建X/Z基准面
↓
自动建Axis
↓
自动建球体/主BODY/F25包络草图
↓
保存
```

先生成只负责Skeleton的宏，不直接自动生成44个零件，确保第一根数字骨架稳定后再向下派生。

> **V42一句话结论：到这里已经第一次从“设计计算文档”跨到“SolidWorks可直接读取的参数源”；后续修改设计优先改数字总账/外部变量，再由Skeleton统一重建。**
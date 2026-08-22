# Q347F 12寸 Class150——第7D步：上下安装面纠错 / 支承轴肩与定位Boss有效长度 V34

> **定位**：V32把20寸 `+365/-370` 错解释成BODY与上下盖的安装法兰面，并映射得到12寸 `+227/-230`。V34回到V13原生20寸前盖/底盖零件坐标重新拆层，正式纠正：`+227/-230`实际对应“支承轴颈结束、定位/密封Boss开始”的轴肩；真正BODY安装面还在更外侧。
>
> **核心结论**：当前12寸CAD使用 `Z_BODY_TOP_IF_CAD≈+264.5 mm`、`Z_BODY_BOTTOM_IF_CAD≈-270.5 mm`；原V32的 `+227/-230` 不删除，改名为上下“支承轴→定位Boss肩面”。由此得到上φ105定位Boss有效长度约37.6mm、下φ70定位Boss约39.2~42.0mm，正好满足V33提出的“定位Boss必须承担主横向反力”的结构要求。

[← 总导航](./00_Q347F_12in_Class150_文档导航_从这里开始.md)  
[← 数字化总装骨架总账](./Q347F_12in_Class150_数字化总装骨架_尺寸参数_装配关系_空间坐标总账.md)  
[← V32 上下Z接口第一轮](./Q347F_12in_Class150_第7B步_上前盖底盖绝对Z接口_M12紧固组与安装面闭合_V32.md)  
[← V33 上下盖载荷路径](./Q347F_12in_Class150_第7C步_上下盖载荷路径_M12连接筛查_定位Boss承载门_V33.md)

---

# 1. V32为什么需要纠正

V32曾使用20寸原生：

```text
前盖下支承轴外端 ≈ +365
底盖主支承轴肩   ≈ -370
```

并映射：

```text
+365×465/748 ≈ +227
-370×465/748 ≈ -230
```

当时把这两个点叫：

```text
Z_BODY_TOP_IF_CAD
Z_BODY_BOTTOM_IF_CAD
```

这是对“站位身份”的误读。

V13原生零件进一步给出：

```text
20寸前盖整个实体：约 +299.5 ~ +482.5
下部粗套筒长度：约126
法兰粗厚：约57

20寸底盖：
轴颈靠球侧端 ≈ -278
主轴颈肩面   ≈ -370
O圈功能区    ≈ -414 ~ -421
法兰内侧/定位肩 ≈ -433 ~ -437.5
法兰外侧端面 ≈ -465
```

所以：

> `+365/-370` 是支承轴颈向外部定位/密封圆柱过渡的肩面，而不是真正BODY法兰安装面。

---

# 2. 上前盖完整20寸分层

20寸原生结构可按Z向重新解释：

```text
靠球体侧
+299.5
  ↓
前盖下部套筒 / 支承结构
  ↓
+365
【φ145支承轴结束 / φ150级外导向开始】
  ↓
定位 / 外O圈 / BODY导向功能段
  ↓
约+425.5
【前盖法兰内侧 / BODY安装面】
  ↓
法兰厚约57
  ↓
+482.5
前盖法兰外侧
```

其中：

```text
+425.5
≈ +299.5 + 126
```

也等于：

```text
+482.5 - 57
```

两条包络关系一致。

---

# 3. 映射到12寸上部CAD坐标

仍只继承成熟无量纲站位，不继承20寸制造尺寸。

比例：

```text
k=465/748≈0.6216578
```

得到：

```text
上前盖靠球侧参考（Z_TOP_COVER_INNER_REF_CAD）
≈299.5×k
≈+186.19

上支承轴→定位Boss肩面（Z_TOP_JOURNAL_PILOT_SHOULDER_CAD）
≈365×k
≈+226.91
≈+226.9

BODY—STEM_COVER安装面（Z_BODY_TOP_IF_CAD）
≈425.5×k
≈+264.52
≈+264.5

前盖外侧粗包络参考（Z_TOP_COVER_OUTER_REF_CAD）
≈482.5×k
≈+299.95
≈+300.0
```

状态：

```text
Z_TOP_JOURNAL_PILOT_SHOULDER_CAD=+226.9   C+
Z_BODY_TOP_IF_CAD=+264.5                  C
Z_BODY_TOP_IF_FINAL=?                     D
```

为什么安装面只给C而不是C+：

- `+425.5`来自20寸“焊前图”粗包络分层；
- 结构身份可靠，但精加工安装面最终会有加工余量变化；
- 因此足够CAD建骨架，不够制造冻结。

---

# 4. 上φ105定位Boss有效长度第一次闭合

当前上部：

```text
肩面 = +226.9
安装面 = +264.5
```

所以BODY配合/定位/密封功能段轴向可用长度：

```text
TOP_PILOT_ENGAGEMENT_CAD
=264.5-226.9
≈37.6 mm
```

这与V33敏感性形成强交叉：

```text
Ru=81.037kN
D=105
L≈37.6

平均投影接触压力需求：
p≈81037/(105×37.6)
≈20.5 MPa
```

这不是最终局部接触应力，但说明：

> φ105导向Boss若拥有约38mm有效接触长度，完全不同于“3mm浅止口”的错误模型，具备成为主横向载荷传递轨道的几何基础。

---

# 5. 下底盖20寸分层更加清楚

V13原生站位：

```text
-278
靠球体侧轴颈端
  ↓
φ100主支承轴颈
  ↓
-370
【主轴颈肩面 / φ105级定位密封圆柱开始】
  ↓
-414~-421
O圈功能区
  ↓
-433~-437.5
【法兰内侧 / 定位肩 / BODY安装面区】
  ↓
-465
法兰外侧端面
```

因此底部真正安装面绝不是-370。

---

# 6. 映射到12寸底部CAD坐标

```text
下底盖靠球侧参考
-278×k≈-172.82

下支承轴→定位Boss肩面
-370×k≈-230.01

O圈区参考
-414×k≈-257.37
-421×k≈-261.72

BODY—BOTTOM_COVER安装面区
-433×k≈-269.18
-437.5×k≈-271.98

底盖外侧参考
-465×k≈-289.07
```

所以当前CAD不报假精度，取：

```text
Z_BOTTOM_JOURNAL_PILOT_SHOULDER_CAD=-230.0   C+
Z_BODY_BOTTOM_IF_RANGE_CAD≈-269.2~-272.0      C
Z_BODY_BOTTOM_IF_CAD=-270.5                   C
Z_BODY_BOTTOM_IF_FINAL=?                      D
```

---

# 7. 下φ70定位Boss有效长度

最短口径：

```text
269.18-230.01≈39.17 mm
```

最长口径：

```text
271.98-230.01≈41.96 mm
```

因此：

```text
BOTTOM_PILOT_ENGAGEMENT_RANGE_CAD≈39.2~42.0 mm
BOTTOM_PILOT_ENGAGEMENT_CAD≈40.5 mm
```

用当前下支承反力粗筛：

```text
Rl=83.655kN
D=70
L=40.5

p≈83655/(70×40.5)
≈29.5 MPa
```

同样只表示平均投影承载需求，不替代局部接触/弯曲/圆角FEA。

---

# 8. V32旧坐标如何处理

不删除，正式重命名：

```text
V32旧：
Z_BODY_TOP_IF_CAD=+227
→ H/R as interface
→ 当前：Z_TOP_JOURNAL_PILOT_SHOULDER_CAD=+226.9

V32旧：
Z_BODY_BOTTOM_IF_CAD=-230
→ H/R as interface
→ 当前：Z_BOTTOM_JOURNAL_PILOT_SHOULDER_CAD=-230.0
```

因此真正安装面当前为：

```text
Z_BODY_TOP_IF_CAD=+264.5
Z_BODY_BOTTOM_IF_CAD=-270.5
```

---

# 9. 这次纠错反而验证了V33载荷路径

V33说：

```text
球体横向反力
不应主要靠M12剪切
而应通过φ105/φ70定位Boss传入BODY
```

V34现在得到：

```text
TOP_PILOT_ENGAGEMENT_CAD≈37.6 mm
BOTTOM_PILOT_ENGAGEMENT_CAD≈40.5 mm
```

这两个长度与：

```text
上81.0kN
下83.7kN
```

的高横向载荷非常匹配。

所以载荷路径升级：

```text
C+ topology
```

---

# 10. 更新后的完整Z轴骨架

```text
                +Z

前盖外侧粗参考     ≈ +300.0
BODY上安装面        = +264.5 C
上定位Boss肩面      = +226.9 C+
上主轴承            = +193.6 ~ +223.6
球心                 = 0
下主轴承            = -227.0 ~ -177.0
下定位Boss肩面      = -230.0 C+
底部O圈功能区参考   ≈ -257.4 ~ -261.7
BODY下安装面        ≈ -270.5 C
底盖外侧粗参考      ≈ -289.1

                -Z
```

注意：

- 这里“前盖外侧粗参考≈+300”来自20寸焊前包络比例；
- 当前V11阀杆密封/填料功能链可继续高于这个位置，因为内部阀杆/填料/连接盘站位来自另一套精加工轨道，不能把不同半径的轴向包络简单相加；
- 后续V35会把这些同轴轨道重新叠在一个真正的纵剖面里。

---

# 11. SolidWorks变量更新

```text
# TOP SUPPORT / PILOT / BODY INTERFACE
Z_TOP_JOURNAL_PILOT_SHOULDER_CAD=226.9   # 上支承轴转定位Boss肩面
Z_BODY_TOP_IF_CAD=264.5                  # BODY与STEM_COVER安装面CAD
Z_BODY_TOP_IF_FINAL=?                    # 制造安装面Z
TOP_PILOT_ENGAGEMENT_CAD=37.6            # φ105定位Boss有效CAD长度
TOP_PILOT_ENGAGEMENT_FINAL=?             # 最终有效接触长度

# BOTTOM SUPPORT / PILOT / BODY INTERFACE
Z_BOTTOM_JOURNAL_PILOT_SHOULDER_CAD=-230.0 # 下支承轴转定位Boss肩面
Z_BODY_BOTTOM_IF_CAD=-270.5                # BODY与BOTTOM_COVER安装面CAD
Z_BODY_BOTTOM_IF_FINAL=?                   # 制造安装面Z
BOTTOM_PILOT_ENGAGEMENT_MIN_CAD=39.2       # 下定位Boss长度敏感性下限
BOTTOM_PILOT_ENGAGEMENT_MAX_CAD=42.0       # 下定位Boss长度敏感性上限
BOTTOM_PILOT_ENGAGEMENT_CAD=40.5           # 下定位Boss当前CAD值
BOTTOM_PILOT_ENGAGEMENT_FINAL=?            # 最终有效接触长度

# RETIRED INTERPRETATION
V32_Z_BODY_TOP_IF_227=H/R                  # 旧安装面解释停用
V32_Z_BODY_BOTTOM_IF_M230=H/R              # 旧安装面解释停用
```

---

# 12. 下一步 V35

下一步把同轴但不同半径的功能轨道真正叠图：

```text
上：
φ100球体支承轴
φ105 BODY导向Boss
φ70阀杆导向轴承
φ65双O圈
φ75填料
φ95外O圈
φ115缠绕垫
4×M12×75
4×M12×50

下：
φ65支承轴
φ70 BODY导向Boss
φ58×5.3 O圈
φ80×φ70垫片
6×M12×55
```

目标：第一次形成 `STEM_COVER / BODY / BOTTOM_COVER` 完整Z向纵剖面，而不是几条孤立坐标。

> **V34一句话结论：+227/-230没有消失，它们只是从“安装面”纠正为“支承轴→定位Boss肩面”；真正BODY上下安装面当前约为+264.5/-270.5，定位Boss长度约37.6/40.5mm。**
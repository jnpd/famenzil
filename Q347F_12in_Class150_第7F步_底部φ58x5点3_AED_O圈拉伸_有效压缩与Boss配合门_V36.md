# Q347F 12寸 Class150——第7F步：底部φ58×5.3 AED O圈拉伸 / 有效压缩 / Boss配合门 V36

> **定位**：V35发现：若底部 `φ58×5.3 AED` O圈安装在 `φ70` 定位Boss的公司5.3截面静槽（深4.2）上，则槽根径 `φ61.6`，O圈ID拉伸约6.21%。V36不把这个现象简单判成“不合格”，而是按主流O圈设计手册重新计算拉伸后的截面变化和有效压缩率，并把最终判断交给实际AED VITON牌号/厂家数据。
>
> **核心结论**：6.21%拉伸高于Parker“优选不超过5%”口径，但仍处于Trelleborg静态活塞式径向密封2%~8%的推荐范围。考虑拉伸导致截面约缩小4.0%后，5.3mm截面约变为5.09mm；在当前4.2mm径向密封间隙下，有效压缩约17.4%。因此 `φ61.6` 不作废，状态从普通C调整为 `C/R-供应商确认`。

[← 总导航](./00_Q347F_12in_Class150_文档导航_从这里开始.md)  
[← 数字化总装骨架总账](./Q347F_12in_Class150_数字化总装骨架_尺寸参数_装配关系_空间坐标总账.md)  
[← V35 上下盖完整Z向纵剖面](./Q347F_12in_Class150_第7E步_上下盖完整Z向纵剖面_M12长度反校核_V35.md)

---

# 1. 当前底部密封几何

12寸当前BOM/设计链：

```text
底部定位Boss名义直径 = φ70
底部O圈               = φ58×5.3 AED
公司5.3截面静槽深     = 4.2
公司槽宽               = 7.0
```

若O圈槽开在φ70外圆：

```text
BOTTOM_IF_ORING_ROOT_D
=70-2×4.2
=φ61.6
```

O圈自由内径：

```text
d1=58
```

安装到槽根的名义ID拉伸：

```text
S
=(61.6-58)/58×100%
≈6.21%
```

---

# 2. 6.21%不能简单判错

两个主流设计口径并不完全相同：

## Parker

Parker O-Ring Handbook建议：

```text
装配后的O圈ID拉伸通常不推荐超过5%
```

原因主要是：

```text
过度拉伸
→ 截面变细
→ 内应力增加
→ 老化寿命下降
```

## Trelleborg

Trelleborg对“径向安装、活塞式外密封”给出：

```text
动态：2%~5%
静态：2%~8%
```

本项目底盖接口当前定义为：

```text
静态径向外密封
```

所以：

```text
S≈6.21%
```

属于：

```text
高于Parker保守优选值
但仍在Trelleborg静态推荐区间
```

因此不能写：

```text
6.21% = 必然不合格
```

---

# 3. 拉伸以后截面会变细，必须重新算压缩率

Trelleborg对3%~25%拉伸给出截面缩减近似：

```text
R = 0.56 + 0.59*S - 0.0046*S²
```

其中：

```text
S=6.21
```

得到：

```text
R≈4.04%
```

所以自由截面：

```text
CS_free=5.3
```

拉伸后有效截面约：

```text
CS_stretched
=5.3×(1-0.0404)
≈5.09 mm
```

---

# 4. 有效径向压缩重新计算

当前名义径向密封间隙由：

```text
BODY配合孔φ70
-
槽根φ61.6
```

得到单边：

```text
gap_radial
=(70-61.6)/2
=4.2 mm
```

若忽略拉伸影响，名义压缩：

```text
(5.3-4.2)/5.3
≈20.75%
```

但考虑拉伸后截面约5.09：

```text
ε_effective
=(5.09-4.2)/5.09
≈17.4%
```

所以：

```text
BOTTOM_ORING_EFFECTIVE_SQUEEZE≈17.4%   B/C-screen
```

这说明：

> 6.21% ID拉伸虽然偏高，但它同时降低了截面；当前实际有效压缩并没有保持在20.75%，而更接近17%左右。

---

# 5. 当前不建议擅自改成φ68台阶

一种直觉修正是：

```text
把O圈安装台阶从φ70改小
```

以降低ID拉伸。

但这样会同时改变：

```text
BODY对应孔径
O圈实际径向间隙
压缩率
定位Boss承载面积
底盖与BODY配合关系
```

如果只把外圆改小、BODY孔仍φ70，反而可能导致O圈径向压缩不足。

因此V36明确禁止：

```text
为了把拉伸降到5%以内
直接拍一个φ68/φ69局部台阶
```

除非完整重算：

```text
槽根
配合孔
截面缩减
压缩率
间隙
挤出风险
承载Boss
```

---

# 6. 当前推荐处理

当前SolidWorks草模继续：

```text
BOTTOM_IF_GUIDE_D=70
BOTTOM_IF_ORING=58×5.3 AED
BOTTOM_IF_ORING_GROOVE_DEPTH=4.2
BOTTOM_IF_ORING_GROOVE_W=7.0
BOTTOM_IF_ORING_ROOT_D=61.6
```

但状态调整为：

```text
BOTTOM_IF_ORING_ROOT_D=61.6   C/R
```

风险门：

```text
R35_01_BOTTOM_ORING_STRETCH
= SUPPLIER CONFIRMATION REQUIRED
```

必须补的不是“另一个猜测尺寸”，而是：

```text
1. AED VITON实际牌号
2. 硬度
3. 低温/最高温性能
4. 厂家允许静态ID拉伸
5. 厂家推荐压缩率
6. 2MPa气体下挤出间隙建议
```

---

# 7. 上部φ95×5.3作为对照

上接口：

```text
TOP_IF_GUIDE_D=105
静槽根≈96.6
O圈ID=95
```

ID拉伸：

```text
(96.6-95)/95
≈1.68%
```

明显低于底部。

因此：

```text
TOP_IF_ORING_STRETCH≈1.68%   B/C+
BOTTOM_IF_ORING_STRETCH≈6.21% B/R
```

这也说明底部必须单独经过材料供应商确认，不能因为上下都用5.3截面就认为设计条件相同。

---

# 8. 上下Boss配合公差不能直接照抄主中法兰H8/f8

公司当前明确的：

```text
BODY H8 / BODY_COVER f8
```

是主BODY—BODY_COVER中法兰定位止口规则。

不能自动扩展成：

```text
STEM_COVER φ105 = f8
BOTTOM_COVER φ70 = f8
BODY上下孔 = H8
```

因为上下Boss同时承担：

```text
支承反力传递
密封
装配导向
热膨胀
拆装
```

所以新增：

```text
TOP_PILOT_FIT_FINAL=? D
BOTTOM_PILOT_FIT_FINAL=? D
```

CAD只保持：

```text
名义同径配合
TOP nominal = φ105
BOTTOM nominal = φ70
```

不在没有公司条款/正式零件图时硬填公差带。

---

# 9. V36 SolidWorks变量

```text
# BOTTOM AED O-RING
BOTTOM_IF_GUIDE_D=70
BOTTOM_IF_ORING_D0=58
BOTTOM_IF_ORING_CS_FREE=5.3
BOTTOM_IF_ORING_GROOVE_DEPTH=4.2
BOTTOM_IF_ORING_GROOVE_W=7.0
BOTTOM_IF_ORING_ROOT_D=61.6
BOTTOM_IF_ORING_ID_STRETCH=6.21
BOTTOM_IF_ORING_CS_REDUCTION≈4.04
BOTTOM_IF_ORING_CS_STRETCHED≈5.09
BOTTOM_IF_ORING_EFFECTIVE_SQUEEZE≈17.4
R35_01_BOTTOM_ORING_STRETCH=SUPPLIER_CONFIRM

# PILOT FIT GATES
TOP_PILOT_NOMINAL_D=105
TOP_PILOT_FIT_FINAL=?
BOTTOM_PILOT_NOMINAL_D=70
BOTTOM_PILOT_FIT_FINAL=?
```

---

# 10. 当前结论

```text
φ58×5.3 AED
+
φ70名义Boss
+
4.2静槽深
```

当前没有被推翻。

正确状态是：

```text
几何链可继续CAD
但制造冻结必须由AED VITON实际材料数据确认
```

---

# 11. 下一步 V37

下一步开始上部驱动接口：

```text
STEM_COVER
↓
4×M12×50次级连接
↓
连接盘 ADAPTER
↓
ISO 5211顶法兰
↓
蜗轮箱 LT-Q06 / 最终驱动接口
```

同时继续保留：

```text
上下Boss配合公差
底部AED O圈厂家确认
```

作为制造冻结门。

> **V36一句话结论：底部6.21%拉伸不是直接判废，而是“静态可行区间内、但超出更保守的5%优选值”；考虑截面变细后有效压缩约17.4%，当前φ61.6槽根可以继续CAD，最终交给AED VITON实际牌号确认。**
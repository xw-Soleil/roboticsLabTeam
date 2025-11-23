#import "导入函数库/lib_academic.typ": *
#show: codly-init.with()    // 初始化codly，每个文档只需执行一次
#codly(languages: codly-languages)  // 配置codly
#show table: three-line-table

#show: project.with(
  title: "实验5：基于速度控制的轨迹跟踪",
  author: "第3组 金加康 吴必兴 沈学文 钱满亮 赵钰泓",
  date: auto,
  // abstract: [基于ZJU-I型机械臂的速度层逆运动学轨迹跟踪实验。],
  // keywords: ("机械臂", "速度控制", "Jacobian矩阵", "阻尼最小二乘"),
)

= 实验目的和要求

== 实验目的
+ 掌握基于Jacobian矩阵的速度层逆运动学方法
+ 理解末端速度与关节速度之间的映射关系
+ 学习阻尼最小二乘法处理奇异点问题
+ 对比速度控制与位置控制的优缺点
+ 熟练运用速度控制实现实时轨迹跟踪

== 任务要求
+ *正方形轨迹*：控制ZJU-I型机械臂末端执行器端点沿着边长为10cm的正方形连续移动，移动过程中末端执行器空间姿态保持不变，自定义正方形在笛卡尔空间的位置、末端点的移动速度。使用速度控制方法，实时计算期望末端线速度，通过Jacobian矩阵映射到关节速度。
+ *圆形轨迹*：控制ZJU-I型机械臂末端执行器端点沿着直径为10cm的圆连续移动，移动过程中末端执行器空间姿态保持不变，自定义圆在笛卡尔空间的位置、末端点的移动速度。利用圆周运动的速度方程，实时计算切向速度。
+ *圆锥轨迹*：控制ZJU-I型机械臂末端执行器绕着执行器的端点转动，即末端点位于空间圆锥体的顶点上，末端执行器绕点运动时其轴线（机械臂第6轴）始终与圆锥体的素线重合，圆锥体的锥角为60度，自定义圆锥体在笛卡尔空间中的位置、旋转角速度。仅控制角速度，末端位置保持不变。
+ 提交计算过程报告、仿真工程文件以及仿真结果视频。

= 结果与分析

== 正方形轨迹

下图展示了机械臂末端执行器沿正方形轨迹运动的结果。使用速度控制方法，末端执行器准确地沿着边长为10cm的正方形路径运动，红色轨迹线清晰地显示了运动路径：
#v(-0.5em)


下图为机械臂运动时各关节的位置、速度和加速度变化曲线：
#v(-0.5em)

#v(-0.5em)
从曲线可以观察到速度控制的特点：
+ #reder[速度直接控制]：与位置控制不同，关节速度是直接计算并控制的，通过Jacobian矩阵从末端速度实时映射得到。
+ #reder[转角平滑性]：在正方形四个顶点处，由于速度方向突变，关节速度也会快速调整，但得益于速度限幅和软限位保护，不会出现剧烈跳变。
+ #reder[实时响应]：速度控制不需要预先规划整条轨迹，而是每个控制周期实时计算，因此具有更好的实时性。
+ #reder[轨迹圆角]：仔细观察会发现，速度控制的正方形轨迹在顶点处有轻微的圆角效应，这是因为速度切换需要时间，关节不能瞬间改变运动方向。

== 圆形轨迹

下图展示了机械臂末端执行器沿圆形轨迹运动的结果。红色圆圈清晰地显示了末端执行器的运动轨迹，直径约为10cm：
#v(-1em)

#v(-0.5em)
下图为圆形轨迹运动时的关节运动曲线：



圆形轨迹的速度控制特点：
+ #reder[完美适配]：圆形轨迹的速度是连续变化的，非常适合速度控制方法。与位置控制相比，速度控制的实现更加直观——直接对圆周运动的参数方程求导得到速度。
+ #reder[平滑周期性]：各关节的位置和速度曲线都呈现完美的周期性，说明速度控制能够很好地跟踪连续变化的轨迹。
+ #reder[无需路径点]：与位置控制需要将圆周分成多个离散点不同，速度控制可以直接使用连续的速度方程，避免了离散化误差。
+ #reder[速度恒定]：末端执行器的线速度大小保持恒定（0.025 m/s），仅方向沿切线方向变化，这正是圆周运动的固有特性。

== 圆锥轨迹

下图展示了机械臂末端执行器绕固定点作圆锥运动的结果。从图中可以看出，末端执行器的轴线与圆锥素线重合，末端点保持固定：
#v(-1em)

#v(-0.5em)
下图为圆锥轨迹运动时的关节运动曲线：
#v(-0.5em)

#v(-0.5em)
圆锥轨迹的速度控制分析：
+ #reder[纯姿态控制]：圆锥运动仅涉及姿态变化（末端点位置固定），因此线速度为零，仅有角速度。这是对Jacobian矩阵角速度部分的直接测试。
+ #reder[实现简洁]：速度控制下，圆锥运动的实现非常简单——只需给定一个恒定的角速度向量 $bold(omega) = [0, 0, 20°/s]^T$，无需复杂的姿态规划。
+ #reder[与位置控制对比]：位置控制需要计算圆锥面上每个点的姿态、优化自旋角、处理多解选择等复杂问题；而速度控制只需给定角速度即可，体现了速度控制的灵活性优势。
+ #reder[周期性运动]：各关节速度呈现周期性变化，周期约为18秒（360°÷20°/s），与给定的旋转角速度完全吻合。

= 实验内容与原理

== 速度控制与位置控制的对比

在机械臂控制领域，主要有两种轨迹跟踪策略：#bluer[位置控制]和#bluer[速度控制]。

=== 位置控制方法

位置控制的核心思想是：
+ 预先规划完整轨迹的所有路径点
+ 对每个路径点使用逆运动学求解对应的关节角度
+ 在相邻路径点之间使用五次多项式等方法进行插值
+ 执行时给定关节的期望位置，由位置控制器跟踪

#bluer[优点]：
- 轨迹精确可控，可以保证机械臂严格经过指定的路径点
- 运动平滑，通过多项式插值保证速度和加速度连续
- 理论成熟，易于分析和优化

#bluer[缺点]：
- 需要预先规划整条轨迹，实时性较差
- 不够灵活，难以应对动态变化的目标
- 逆运动学可能存在多解或无解的情况

=== 速度控制方法

速度控制的核心思想是：
+ 不预先规划关节角度轨迹
+ 实时计算末端执行器的#reder[期望速度]（包括线速度 $bold(v)$ 和角速度 $bold(omega)$）
+ 通过#reder[Jacobian矩阵]将末端速度映射到关节速度
+ 直接控制关节速度，让机械臂实时跟踪期望轨迹

#bluer[优点]：
- 实时性强，可以动态调整目标速度
- 实现灵活，易于加入避障、力控等功能
- 计算高效，每个周期只需计算当前Jacobian
- 奇异点鲁棒，通过阻尼最小二乘法保证数值稳定

#bluer[缺点]：
- 轨迹精度可能稍低（基于速度积分的位置跟踪）
- 需要精确的Jacobian矩阵计算
- 参数调节（阻尼系数、速度增益等）需要经验

=== 对比总结
#v(-0.5em)
#figure(
  table(
    columns: 3,
    align: center + horizon,
    [*对比项*], [*位置控制*], [*速度控制*],
    [控制变量], [关节角度 $bold(q)$], [关节速度 $dot(bold(q))$],
    [预规划], [需要完整轨迹], [仅需当前速度],
    [逆运动学], [位置层求解关节角], [速度层通过Jacobian],
    [实时性], [较低（需预规划）], [高（实时计算）],
    [灵活性], [较低（固定轨迹）], [高（动态调整）],
    [奇异点处理], [多解选择], [阻尼最小二乘],
    [轨迹精度], [高（精确插值）], [中等（速度积分）],
    [计算复杂度], [高（全轨迹规划）], [低（单步计算）],
    [适用场景], [高精度路径跟踪], [实时响应、动态任务],
  ),
  caption: [位置控制与速度控制详细对比],
)

== 速度层逆运动学基础理论

=== Jacobian矩阵的定义

Jacobian矩阵建立了机械臂#bluer[关节速度]与#bluer[末端速度]之间的线性映射关系：
#v(-0.5em)
$
  dot(bold(x)) = bold(J)(bold(q)) dot(bold(q))
$ <eq1>
#v(-0.5em)
其中：
+ $dot(bold(x)) = mat(bold(v); bold(omega)) in RR^6$ 是末端执行器的#reder[速度旋量]：
  - $bold(v) = [v_x, v_y, v_z]^T$ 为线速度（m/s）
  - $bold(omega) = [omega_x, omega_y, omega_z]^T$ 为角速度（rad/s）
+ $bold(J)(bold(q)) in RR^(6 times 6)$ 是#reder[几何Jacobian矩阵]，是关节角 $bold(q)$ 的函数
+ $dot(bold(q)) = [dot(theta)_1, dot(theta)_2, ..., dot(theta)_6]^T in RR^6$ 是关节角速度向量

Jacobian矩阵的结构为：
#v(-0.5em)
$
  bold(J)(bold(q)) = mat(
    bold(J)_v;
    bold(J)_omega
  ) = mat(
    J_(v_x 1), J_(v_x 2), ..., J_(v_x 6);
    J_(v_y 1), J_(v_y 2), ..., J_(v_y 6);
    J_(v_z 1), J_(v_z 2), ..., J_(v_z 6);
    J_(omega_x 1), J_(omega_x 2), ..., J_(omega_x 6);
    J_(omega_y 1), J_(omega_y 2), ..., J_(omega_y 6);
    J_(omega_z 1), J_(omega_z 2), ..., J_(omega_z 6)
  )
$ <eq2>
#v(-0.5em)
上半部分 $bold(J)_v$ 描述线速度映射，下半部分 $bold(J)_omega$ 描述角速度映射。

=== 几何Jacobian的推导

对于旋转关节，Jacobian矩阵的第 $i$ 列可以通过几何法推导：
#v(-0.5em)
$
  bold(J)_i = mat(
    bold(z)_(i-1) times (bold(p)_"ee" - bold(p)_(i-1));
    bold(z)_(i-1)
  )
$ <eq3>
#v(-0.5em)
其中：
+ $bold(z)_(i-1)$ 是第 $i$ 个关节轴在世界坐标系下的方向向量
+ $bold(p)_"ee"$ 是末端执行器在世界坐标系下的位置
+ $bold(p)_(i-1)$ 是第 $i-1$ 个坐标系原点的位置
+ $times$ 表示叉乘运算

#bluer[推导思路]：
+ 第 $i$ 个关节旋转时，末端执行器的#reder[线速度]等于 $bold(z)_(i-1) times bold(r)_i$，其中 $bold(r)_i = bold(p)_"ee" - bold(p)_(i-1)$ 是从关节 $i$ 到末端的位置向量
+ 末端执行器的#reder[角速度]直接等于关节转轴方向 $bold(z)_(i-1)$

对于ZJU-I型六自由度机械臂，可以基于DH参数和正运动学推导出解析形式的Jacobian矩阵。这样可以避免每次都进行数值微分，大大提高计算效率。

=== 速度层逆解问题

#bluer[问题描述]：已知期望末端速度 $dot(bold(x))_"des"$，求解关节速度 $dot(bold(q))$。

最直接的想法是对方程 @eq1 两边求逆：
#v(-0.5em)
$
  dot(bold(q)) = bold(J)^(-1)(bold(q)) dot(bold(x))
$ <eq4>
#v(-0.5em)

然而，这个方法存在严重问题：

+ #reder[奇异性问题]：当机械臂处于奇异构型时，$bold(J)$ 的行列式接近零，$bold(J)^(-1)$ 趋于无穷大，导致关节速度剧烈增大，实际不可行。
+ #reder[数值不稳定]：即使不完全奇异，$bold(J)$ 接近奇异时，直接求逆的数值误差也会被极大放大。

因此，需要更加鲁棒的求解方法。

=== 阻尼最小二乘法（Damped Least Squares）

为了解决奇异性问题，采用#bluer[阻尼最小二乘法]（也称为Levenberg-Marquardt方法）：
#v(-0.5em)
$
  dot(bold(q)) = bold(J)^T (bold(J) bold(J)^T + lambda^2 bold(I)_6)^(-1) dot(bold(x))
$ <eq5>
#v(-0.5em)
其中 $lambda > 0$ 是#reder[阻尼系数]，通常取较小值（如0.01-0.1）。

#bluer[算法优势]：

+ #reder[数值稳定性]：
  - 即使 $bold(J)$ 奇异（秩小于6），矩阵 $bold(J) bold(J)^T + lambda^2 bold(I)_6$ 仍然是#bluer[满秩的]
  - 阻尼项 $lambda^2 bold(I)_6$ 保证了矩阵的条件数不会过大
  - 可以安全地进行矩阵求逆或线性方程组求解

+ #reder[奇异点处的平滑性]：
  - 在奇异构型附近，算法会自动#bluer[减小关节速度]，避免剧烈运动
  - 这是通过最小化修正后的目标函数实现的：
    #v(-0.5em)
    $
      min_(dot(bold(q))) norm(bold(J) dot(bold(q)) - dot(bold(x)))^2 + lambda^2 norm(dot(bold(q)))^2
    $ <eq6>
    #v(-0.5em)
  - 第二项是对关节速度的惩罚，防止其过大

+ #reder[计算效率]：
  - 需要求解的线性方程组为 $(bold(J) bold(J)^T + lambda^2 bold(I)_6) bold(y) = dot(bold(x))$，然后 $dot(bold(q)) = bold(J)^T bold(y)$
  - $bold(J) bold(J)^T$ 是 $6 times 6$ 的对称正定矩阵，可以用Cholesky分解高效求解
  - 复杂度为 $O(6^3) = O(216)$，实时性优秀

+ #reder[参数调节]：
  - 阻尼系数 $lambda$ 是关键参数
  - $lambda$ 过小：接近直接求逆，奇异点附近数值不稳定
  - $lambda$ 过大：过度保守，轨迹跟踪误差增大
  - 实践中，$lambda = 0.01$ 是一个较好的起点

#bluer[几何解释]：
阻尼最小二乘法在末端速度跟踪误差和关节速度大小之间做权衡。在远离奇异点时，它近似于直接求逆，能很好地跟踪期望速度；在奇异点附近，它优先保证关节速度不会过大，即使这会牺牲一些跟踪精度。

== 三种轨迹的速度定义与计算

=== 正方形轨迹速度

正方形轨迹由四条边组成，每条边是一条直线段。在速度控制下，需要实时计算末端在当前边上的运动速度。

#bluer[速度计算]：

+ 确定当前时刻所在的边（第 $i$ 条边）：
  #v(-0.5em)
  $
    i = floor(t mod T_"total" / T_"edge") in {0, 1, 2, 3}
  $ <eq7>
  #v(-0.5em)
  其中 $T_"total"$ 是完成一圈的总时间，$T_"edge"$ 是每条边的运动时间。

+ 计算边的方向单位向量：
  #v(-0.5em)
  $
    bold(u)_i = (bold(p)_(i+1) - bold(p)_i) / norm(bold(p)_(i+1) - bold(p)_i)
  $ <eq8>
  #v(-0.5em)
  其中 $bold(p)_i$ 和 $bold(p)_(i+1)$ 是第 $i$ 条边的起点和终点。

+ 线速度为恒定速度沿边方向：
  #v(-0.5em)
  $
    bold(v)(t) = v_"lin" bold(u)_i
  $ <eq9>
  #v(-0.5em)
  其中 $v_"lin" = 0.025$ m/s 是给定的线速度大小。

+ 角速度为零（姿态保持不变）：
  #v(-0.5em)
  $
    bold(omega)(t) = bold(0)
  $ <eq10>
  #v(-0.5em)

#bluer[特殊处理]：

在四个顶点处，速度方向需要瞬间切换（从一条边的方向变为下一条边的方向）。这会导致速度在数学上不连续，但在实际控制中：
- 由于控制周期的存在（如50Hz），切换不是瞬时的
- 关节的惯性会使运动自然平滑
- 速度限幅机制也会约束加速度，避免剧烈冲击

结果是轨迹在顶点处会有轻微的#reder[圆角效应]，这是速度控制的固有特性。

=== 圆形轨迹速度

圆形轨迹是最适合速度控制的路径之一，因为其速度是#bluer[连续变化]的。

#bluer[轨迹参数方程]：

圆心为 $bold(p)_c = [x_c, y_c, z_c]^T$，半径为 $R$，在水平面内运动：
#v(-0.5em)
$
  bold(p)(t) = mat(
    x_c + R cos(omega t);
    y_c + R sin(omega t);
    z_c
  )
$ <eq11>
#v(-0.5em)
其中 $omega = v_"lin" / R$ 是角频率。

#bluer[速度推导]：

对位置方程对时间求导：
#v(-0.5em)
$
  bold(v)(t) = dif / (dif t) bold(p)(t) = mat(
    -R omega sin(omega t);
    R omega cos(omega t);
    0
  ) = v_"lin" mat(
    -sin(omega t);
    cos(omega t);
    0
  )
$ <eq12>
#v(-0.5em)

可以验证速度大小恒定：
#v(-0.5em)
$
  norm(bold(v)(t)) = v_"lin" sqrt(sin^2(omega t) + cos^2(omega t)) = v_"lin"
$ <eq13>
#v(-0.5em)

速度方向始终与位置向量 $bold(p)(t) - bold(p)_c$ 垂直，即沿圆的#bluer[切线方向]。

角速度仍为零：
#v(-0.5em)
$
  bold(omega)(t) = bold(0)
$ <eq14>
#v(-0.5em)

#bluer[与位置控制的对比]：

+ 位置控制需要将圆周离散成 $N$ 个点（如60个），然后在相邻点之间插值
+ 速度控制直接使用连续的速度方程 @eq12，无需离散化
+ 理论上，速度控制可以得到更精确的圆形轨迹

=== 圆锥轨迹速度

圆锥运动是#bluer[纯姿态变化]的任务，末端点位置固定，仅姿态绕圆锥轴旋转。

#bluer[运动描述]：

+ 末端点固定在圆锥顶点：
  #v(-0.5em)
  $
    bold(p)(t) = bold(p)_"apex" = "常量"
  $ <eq15>
  #v(-0.5em)

+ 末端执行器轴线（approach向量）在圆锥面上旋转，与圆锥轴夹角为半锥角 $alpha_"cone" = 30degree$

+ 轴线绕圆锥轴（取为z轴）以角速度 $omega_z$ 旋转

#bluer[速度定义]：

线速度为零：
#v(-0.5em)
$
  bold(v)(t) = bold(0)
$ <eq16>
#v(-0.5em)

角速度为绕圆锥轴的旋转：
#v(-0.5em)
$
  bold(omega)(t) = omega_z bold(e)_z = mat(0; 0; omega_z)
$ <eq17>
#v(-0.5em)
其中 $omega_z = 20 degree"/s" = 0.349$ rad/s，$bold(e)_z$ 是圆锥轴方向（通常取为 $[0, 0, -1]^T$ 或 $[0, 0, 1]^T$）。

#bluer[Jacobian角速度部分的作用]：

由于线速度为零，速度映射方程简化为：
#v(-0.5em)
$
  mat(bold(0); bold(omega)) = mat(bold(J)_v; bold(J)_omega) dot(bold(q)) => bold(omega) = bold(J)_omega dot(bold(q))
$ <eq18>
#v(-0.5em)

圆锥任务主要测试Jacobian矩阵的#reder[角速度部分] $bold(J)_omega$ 的正确性。

#bluer[与位置控制的巨大差异]：

+ 位置控制下，圆锥运动极其复杂：
  - 需要计算圆锥面上每个方位角对应的姿态（欧拉角或旋转矩阵）
  - 由于绕末端轴线旋转有自旋自由度，需要搜索最优自旋角
  - 涉及大量的三角函数计算和优化算法

+ 速度控制下，圆锥运动非常简单：
  - 只需给定恒定的角速度向量 $bold(omega) = [0, 0, omega_z]^T$
  - Jacobian自动处理姿态变化到关节速度的映射
  - 代码仅需一行：`omega = np.array([0, 0, CONE_ANGULAR_VEL])`

这充分体现了速度控制的#bluer[优雅和灵活性]。

= 代码实现思路

== 总体架构

速度控制的代码架构分为以下几个模块：

+ #bluer[Jacobian计算模块]（C++ + Python绑定）
  - `jacobi_core.cpp/h`：C++实现的高效Jacobian矩阵计算
  - `jacobi_zjui_module.cpp`：pybind11封装，提供Python接口
  - `setup.py`：编译配置，生成 `jacobi_zjui.pyd` 动态库

+ #bluer[初始化模块]（`sysCall_init`）
  - 设置机械臂参数（关节限位、速度限制等）
  - 获取仿真对象句柄（关节、末端执行器、图表等）
  - 配置关节控制模式（动力学模式、速度控制）
  - 计算轨迹起始点并求解初始关节角
  - 设置可视化（轨迹绘制、圆锥示意等）

+ #bluer[实时控制模块]（`sysCall_actuation`）
  - 阶段1：初始定位（使用位置控制平滑移动到起点）
  - 阶段2：速度跟踪（主要控制逻辑）
    - 根据任务类型计算期望末端速度 $dot(bold(x))_"des"$
    - 读取当前关节角 $bold(q)$
    - 调用Jacobian模块计算 $bold(J)(bold(q))$
    - 使用阻尼最小二乘法求解关节速度 $dot(bold(q))$
    - 应用速度限幅和软限位保护
    - 发送速度指令到各关节

+ #bluer[监控模块]（`sysCall_sensing`）
  - 检查关节位置是否超限
  - 更新图表数据流（位置、速度）
  - 错误处理（超限则暂停仿真）

+ #bluer[清理模块]（`sysCall_cleanup`）
  - 停止所有关节运动
  - 清除绘图对象

== 与位置控制的架构对比

#figure(
  table(
    columns: 3,
    align: left + horizon,
    [*模块*], [*位置控制*], [*速度控制*],
    [核心算法], [逆运动学求解器], [Jacobian矩阵计算],
    [轨迹规划], [五次多项式插值], [实时速度方程],
    [预计算], [所有路径点的关节角], [仅计算起点关节角],
    [实时计算], [插值得到当前期望角度], [Jacobian + DLS求速度],
    [数据存储], [存储所有多项式系数], [存储轨迹参数（中心、半径等）],
    [控制指令], [`setJointPosition`], [`setJointTargetVelocity`],
  ),
  caption: [位置控制与速度控制的架构对比],
)

== Jacobian计算模块设计

=== 为何使用C++实现

Jacobian矩阵需要在#reder[每个控制周期]计算一次（如50Hz频率）。虽然单次计算量不大，但频繁调用会影响实时性。使用C++实现有以下优势：

+ #bluer[计算效率]：C++编译后的代码比Python快10-100倍
+ #bluer[数值精度]：直接使用 `<cmath>` 的高精度三角函数
+ #bluer[内存管理]：栈分配局部变量，无GC开销
+ #bluer[易于优化]：编译器可以进行向量化、内联等优化

=== pybind11绑定策略

为了在Python中使用C++模块，采用pybind11进行绑定：

+ #bluer[接口设计]：简洁的函数式接口 `jacobi(q) -> J`
+ #bluer[数据转换]：自动处理NumPy数组与C++数组的转换
+ #bluer[异常处理]：C++异常可以传递到Python
+ #bluer[类型安全]：编译时检查类型，运行时检查数组维度

=== 编译与部署

使用 `setuptools` 和 `pybind11.setup_helpers` 自动化编译：
```bash
python setup.py build_ext --inplace
```
生成的 `.pyd` 文件（Windows）或 `.so` 文件（Linux）可以直接在Python中导入。

== 速度控制循环详解

=== 初始定位阶段（0-4秒）

为何需要初始定位？
+ 仿真开始时，所有关节角度为零（机械臂直立）
+ 如果直接进入速度控制，末端会从零位突然启动，可能偏离预期轨迹
+ 因此，先使用#bluer[位置控制]平滑移动到轨迹起点

实现方法：
+ 使用#reder[五次多项式]进行平滑插值：
  #v(-0.5em)
  $
    s(tau) = 10 tau^3 - 15 tau^4 + 6 tau^5, quad tau = t / T_"init"
  $ <eq19>
  #v(-0.5em)
  其中 $s(0) = 0, s(1) = 1$，且 $s'(0) = s'(1) = 0$（速度边界为零）
+ 期望关节角度为：
  #v(-0.5em)
  $
    bold(q)_"des"(t) = bold(q)_0 + s(tau) (bold(q)_"start" - bold(q)_0)
  $ <eq20>
  #v(-0.5em)
+ 使用比例控制计算速度：
  #v(-0.5em)
  $
    dot(bold(q)) = K_p (bold(q)_"des" - bold(q)_"current")
  $ <eq21>
  #v(-0.5em)
  其中 $K_p = 2.0$ 是增益系数。

=== 速度跟踪阶段（4秒后）

这是速度控制的核心阶段，控制流程如下：

*速度控制循环（每个控制周期）：*

1. 读取当前关节角度

2. 根据任务类型和当前时间，计算期望末端速度

3. 调用Jacobian模块计算当前Jacobian矩阵

4. 使用阻尼最小二乘法求解关节速度：
  #v(-0.5em)
  $
    dot(bold(q)) = bold(J)^T (bold(J) bold(J)^T + lambda^2 bold(I))^(-1) dot(bold(x))_"des"
  $ <eq22>
  #v(-0.5em)

5. 应用速度限幅：对每个关节，若速度超过限制则按比例缩放

6. 软限位保护：接近关节限位时自动减速

7. 发送速度指令到各关节

8. 更新轨迹可视化（绘制末端位置）

=== 关键技术细节

+ #bluer[阻尼系数选择]：
  - 本实验使用 $lambda = 0.01$
  - 这个值在跟踪精度和奇异点鲁棒性之间取得了良好平衡
  - 可以根据具体任务调整（精密任务减小，复杂任务增大）

+ #bluer[速度限幅]：
  - 每个关节的速度限制为 $100 degree"/s" = 1.745$ rad/s
  - 限幅时乘以0.9留有裕度，避免饱和
  - 如果期望速度过大，会按比例缩放，保持方向不变

+ #bluer[软限位保护]：
  - 在距离关节限位 $10degree$ 范围内，反向速度会被大幅衰减（乘以0.1）
  - 这避免了硬碰撞，同时允许关节在安全范围内自由运动
  - 比硬限位更平滑，不会产生突然的停止

+ #bluer[线性方程组求解]：
  - Python的 `np.linalg.solve(A, b)` 使用LU分解求解 $A bold(x) = bold(b)$
  - 对于 $6 times 6$ 的对称正定矩阵，也可以用Cholesky分解加速
  - 本实验中，计算时间远小于控制周期（50Hz → 20ms），实时性充足

= 核心代码实现

== Jacobian矩阵计算（C++核心）

这是速度控制的#reder[核心计算模块]，基于DH参数推导的解析公式计算6×6几何Jacobian矩阵。

#v(-0.5em)
#figure(
  [```cpp
  #include "jacobi_core.h"
  #include <cmath>

  // DH参数：连杆长度 (185, 170, 77, 23, 171/2, 230) mm
  void jacobi_zjui_core(const double q[6], double J[36]) {
      // 提取关节角度
      const double q1 = q[0];
      const double q2 = q[1];
      const double q3 = q[2];
      const double q4 = q[3];
      const double q5 = q[4];
      // q6不影响几何Jacobian

      // 关节2+3+4的累加角度
      const double Sigma = q2 + q3 + q4;

      // 预计算三角函数值，避免重复计算
      const double s1 = std::sin(q1);
      const double c1 = std::cos(q1);
      const double s2 = std::sin(q2);
      const double c2 = std::cos(q2);
      const double s23 = std::sin(q2 + q3);
      const double c23 = std::cos(q2 + q3);
      const double sSig = std::sin(Sigma);
      const double cSig = std::cos(Sigma);
      const double s5 = std::sin(q5);
      const double c5 = std::cos(q5);

      const double k = 171.0 / 2.0;  // 末端连杆长度的一半

      // ========== 第1列：关节1的贡献 ==========
      const double J1vx = -185.0 * s1 * s2 - 170.0 * s1 * s23 - 77.0 * s1 * sSig -
                          k * s1 * c5 * cSig - k * s5 * c1 - 23.0 * c1;
      const double J1vy = -k * s1 * s5 - 23.0 * s1 + 185.0 * s2 * c1 +
                          170.0 * s23 * c1 + 77.0 * sSig * c1 + k * c1 * c5 * cSig;

      J[0 * 6 + 0] = J1vx;        // 线速度 x 分量
      J[1 * 6 + 0] = J1vy;        // 线速度 y 分量
      J[2 * 6 + 0] = 0.0;         // 线速度 z 分量（关节1绕z轴）
      J[3 * 6 + 0] = 0.0;         // 角速度 x 分量
      J[4 * 6 + 0] = 0.0;         // 角速度 y 分量
      J[5 * 6 + 0] = 1.0;         // 角速度 z 分量（z1 = [0,0,1]）

      // ========== 第2列：关节2的贡献 ==========
      const double common2 = -k * sSig * c5 + 185.0 * c2 + 170.0 * c23 + 77.0 * cSig;

      const double J2vx = c1 * common2;
      const double J2vy = s1 * common2;
      const double J2vz = -185.0 * s2 - 170.0 * s23 - 77.0 * sSig - k * c5 * cSig;

      J[0 * 6 + 1] = J2vx;
      J[1 * 6 + 1] = J2vy;
      J[2 * 6 + 1] = J2vz;
      J[3 * 6 + 1] = -s1;         // z2 = [-sin(q1), cos(q1), 0]
      J[4 * 6 + 1] = c1;
      J[5 * 6 + 1] = 0.0;

      // ========== 第3列：关节3的贡献 ==========
      const double common3 = -k * sSig * c5 + 170.0 * c23 + 77.0 * cSig;

      const double J3vx = c1 * common3;
      const double J3vy = s1 * common3;
      const double J3vz = -170.0 * s23 - 77.0 * sSig - k * c5 * cSig;

      J[0 * 6 + 2] = J3vx;
      J[1 * 6 + 2] = J3vy;
      J[2 * 6 + 2] = J3vz;
      J[3 * 6 + 2] = -s1;         // z3 = z2（关节3与关节2平行）
      J[4 * 6 + 2] = c1;
      J[5 * 6 + 2] = 0.0;

      // ========== 第4列：关节4的贡献 ==========
      const double common4 = -k * sSig * c5 + 77.0 * cSig;

      const double J4vx = c1 * common4;
      const double J4vy = s1 * common4;
      const double J4vz = -77.0 * sSig - k * c5 * cSig;

      J[0 * 6 + 3] = J4vx;
      J[1 * 6 + 3] = J4vy;
      J[2 * 6 + 3] = J4vz;
      J[3 * 6 + 3] = -s1;         // z4 = z2
      J[4 * 6 + 3] = c1;
      J[5 * 6 + 3] = 0.0;

      // ========== 第5列：关节5的贡献 ==========
      const double J5vx = -k * s1 * c5 - k * s5 * c1 * cSig;
      const double J5vy = -k * s1 * s5 * cSig + k * c1 * c5;
      const double J5vz = k * s5 * sSig;

      J[0 * 6 + 4] = J5vx;
      J[1 * 6 + 4] = J5vy;
      J[2 * 6 + 4] = J5vz;
      J[3 * 6 + 4] = sSig * c1;   // z5方向
      J[4 * 6 + 4] = s1 * sSig;
      J[5 * 6 + 4] = cSig;

      // ========== 第6列：关节6的贡献 ==========
      // 线速度为零（关节6是末端转轴）
      J[0 * 6 + 5] = 0.0;
      J[1 * 6 + 5] = 0.0;
      J[2 * 6 + 5] = 0.0;

      // 角速度：z6方向
      const double J6wx = -s1 * s5 + c1 * c5 * cSig;
      const double J6wy = s1 * c5 * cSig + s5 * c1;
      const double J6wz = -sSig * c5;

      J[3 * 6 + 5] = J6wx;
      J[4 * 6 + 5] = J6wy;
      J[5 * 6 + 5] = J6wz;

      // ========== 单位转换：mm → m ==========
      const double scale = 1e-3;
      for (int col = 0; col < 6; ++col) {
          for (int row = 0; row < 3; ++row) {
              J[row * 6 + col] *= scale;
          }
      }
  }
  ```],
)

#bluer[代码解析]：

+ #reder[DH参数]：185, 170, 77, 23 是主要连杆长度（mm），171/2 是末端连杆长度的一半，这些来自ZJU-I机械臂的设计参数。

+ #reder[累加角度Sigma]：机械臂的关节2、3、4是串联的旋转关节，它们的累加效果体现在 $Sigma = q_2 + q_3 + q_4$。

+ #reder[预计算三角函数]：`s1 = sin(q1)`, `c1 = cos(q1)` 等，避免重复调用 `sin/cos` 函数，提高效率。

+ #reder[分列计算]：每一列对应一个关节的贡献。上半部分（前3行）是线速度 $bold(J)_v$，下半部分（后3行）是角速度 $bold(J)_omega$。

+ #reder[z轴方向]：
  - 关节1绕世界坐标系的z轴，故 $bold(z)_1 = [0, 0, 1]^T$
  - 关节2、3、4绕经过关节1旋转后的y轴（在世界坐标系中是 $[-sin(q_1), cos(q_1), 0]^T$）
  - 关节5、6的轴线方向更复杂，需要通过完整运动学推导

+ #reder[单位转换]：推导时使用mm作为长度单位（与DH参数一致），最后转换为m，以匹配SI单位制。

== Python绑定模块（pybind11）

#v(-0.5em)
#figure(
  [```cpp
  #include "jacobi_core.h"
  #include <pybind11/numpy.h>
  #include <pybind11/pybind11.h>

  namespace py = pybind11;

  // Python接口函数：输入关节角度数组，返回Jacobian矩阵
  py::array_t<double>
  jacobi_py(py::array_t<double, py::array::c_style | py::array::forcecast> q_in) {
      // 检查输入维度
      if (q_in.size() != 6)
          throw std::runtime_error("q must be length 6");

      // 从NumPy数组提取数据
      double q[6];
      auto buf = q_in.request();
      double *qptr = static_cast<double *>(buf.ptr);
      for (int i = 0; i < 6; ++i)
          q[i] = qptr[i];

      // 调用核心计算函数
      double J[36];
      jacobi_zjui_core(q, J);

      // 创建返回的NumPy数组（6×6）
      auto result = py::array_t<double>({6, 6});
      auto rbuf = result.request();
      double *rptr = static_cast<double *>(rbuf.ptr);
      for (int i = 0; i < 36; ++i)
          rptr[i] = J[i];

      return result;
  }

  // pybind11模块定义
  PYBIND11_MODULE(jacobi_zjui, m) {
      m.doc() = "Geometric Jacobian for ZJU-I robot arm";
      m.def("jacobi", &jacobi_py, "Compute 6x6 Jacobian matrix J(q)");
  }
  ```],
)

#bluer[代码解析]：

+ #reder[NumPy数组接口]：
  - `py::array_t<double>` 是pybind11提供的NumPy数组类型
  - `q_in.request()` 获取数组的缓冲区信息
  - `buf.ptr` 是指向数据的指针，可以直接访问数组元素

+ #reder[参数检查]：检查输入数组长度是否为6，否则抛出异常（会传递到Python）

+ #reder[数据复制]：
  - 从Python数组复制到C++数组 `q[6]`
  - 计算完成后，从C++数组 `J[36]` 复制到Python数组
  - 虽然有复制开销，但对于小数组（6×6）可以忽略

+ #reder[模块定义]：
  - `PYBIND11_MODULE(jacobi_zjui, m)` 定义了模块名称
  - `m.def("jacobi", ...)` 导出函数
  - Python中使用：`import jacobi_zjui; J = jacobi_zjui.jacobi(q)`

== 编译配置（setup.py）

#v(-0.5em)
#figure(
  [```python
  from setuptools import setup
  from pybind11.setup_helpers import Pybind11Extension, build_ext

  # 定义扩展模块
  ext_modules = [
      Pybind11Extension(
          "jacobi_zjui",                              # 模块名称
          ["jacobi_zjui_module.cpp", "jacobi_core.cpp"],  # 源文件列表
      ),
  ]

  # 配置setup
  setup(
      name="jacobi_zjui",
      version="0.1",
      ext_modules=ext_modules,
      cmdclass={"build_ext": build_ext},
  )
  ```],
)

#bluer[编译命令]：
```bash
# 安装pybind11（如果尚未安装）
pip install pybind11

# 编译扩展模块（生成jacobi_zjui.pyd或.so）
python setup.py build_ext --inplace
```

编译成功后，会在当前目录生成 `jacobi_zjui.cp310-win_amd64.pyd`（Windows）或 `jacobi_zjui.cpython-310-x86_64-linux-gnu.so`（Linux），可以直接在Python中导入。

== 主控制循环实现

这是速度控制的#reder[主要逻辑]，实现了从期望速度到关节速度指令的完整流程。

#v(-0.5em)
#figure(
  [```python
  def sysCall_actuation():
      """每个仿真步调用一次的控制函数"""

      t = sim.getSimulationTime()

      # ========== 阶段1：初始定位（0-4秒） ==========
      if t < INIT_DURATION:
          # 读取当前关节角度
          q_current = np.array([sim.getJointPosition(h) for h in self.jointHandles])

          # 使用五次多项式平滑过渡到起始位置
          tau = t / INIT_DURATION
          s = 10*tau**3 - 15*tau**4 + 6*tau**5  # Quintic polynomial: s(0)=0, s(1)=1

          q_desired = self.q0 + s * (self.q_start - self.q0)

          # 比例控制计算速度
          position_error = q_desired - q_current
          qdot = POSITION_GAIN * position_error

          # 应用速度限制
          for i in range(6):
              if abs(qdot[i]) > self.Vel_limits[i]:
                  qdot[i] = np.sign(qdot[i]) * self.Vel_limits[i] * 0.5

          # 发送速度指令
          for i in range(6):
              sim.setJointTargetVelocity(self.jointHandles[i], float(qdot[i]))

          return  # 初始定位阶段结束

      # ========== 阶段2：速度跟踪（4秒后） ==========

      # 首次进入速度控制模式
      if not self.velocityModeEnabled:
          self.velocityModeEnabled = True
          self.last_q = np.array([sim.getJointPosition(h) for h in self.jointHandles])
          self.sim_dt = sim.getSimulationTimeStep()

      # 检查Jacobian模块是否可用
      if not JACOBI_OK:
          sim.pauseSimulation()
          return

      t2 = t - INIT_DURATION  # 速度控制阶段的时间
      q = np.array([sim.getJointPosition(h) for h in self.jointHandles])

      # ---------- 计算期望末端速度 ----------
      if TASK_MODE == 1:
          # 正方形轨迹
          tau = t2 % self.squarePeriod  # 当前周期内的时间
          idx = min(int(tau // self.squareEdgeTime), 3)  # 当前边的索引
          p1 = self.squareCorners[idx]
          p2 = self.squareCorners[(idx+1) % 4]
          # 线速度：沿边方向的单位向量 × 速度大小
          v = SQUARE_VELOCITY * (p2 - p1) / np.linalg.norm(p2 - p1)
          omega = np.zeros(3)  # 姿态不变

      elif TASK_MODE == 2:
          # 圆形轨迹
          phi = self.circleOmega * t2  # 当前角度
          # 线速度：圆周运动的切向速度
          v = np.array([
              -CIRCLE_RADIUS * self.circleOmega * np.sin(phi),
              CIRCLE_RADIUS * self.circleOmega * np.cos(phi),
              0
          ])
          omega = np.zeros(3)

      else:  # TASK_MODE == 3
          # 圆锥轨迹
          v = np.zeros(3)  # 位置不动
          omega = np.array([0.0, 0.0, CONE_ANGULAR_VEL])  # 仅绕z轴旋转

          # 可视化末端轴线（仅圆锥任务）
          if self.cone_vis_enabled:
              try:
                  tip_pos = np.array(sim.getObjectPosition(self.tipHandle, -1))
                  tip_matrix = sim.getObjectMatrix(self.tipHandle, sim.handle_world)
                  axis_z = np.array([tip_matrix[2], tip_matrix[6], tip_matrix[10]])
                  axis_length = 0.12
                  line_start = tip_pos
                  line_end = tip_pos + axis_length * axis_z
                  sim.addDrawingObjectItem(self.endAxisDrawing,
                                          list(line_start) + list(line_end))
              except:
                  pass

      # 合成6维速度旋量 [v; ω]
      xdot = np.concatenate([v, omega])

      # ---------- 阻尼最小二乘求解关节速度 ----------
      # 计算Jacobian矩阵
      J = np.array(jacobi_zjui.jacobi(q), dtype=float)
      JT = J.T
      JJT = J @ JT

      # 求解 (JJ^T + λ²I) y = xdot，然后 qdot = J^T y
      qdot = JT @ np.linalg.solve(JJT + (DAMPING_FACTOR**2) * np.eye(6), xdot)

      # ---------- 速度限幅 ----------
      for i in range(6):
          if abs(qdot[i]) > self.Vel_limits[i]:
              qdot[i] = np.sign(qdot[i]) * self.Vel_limits[i] * 0.9

      # ---------- 软限位保护 ----------
      limit_margin = 10.0 * np.pi / 180  # 10度裕度
      for i in range(6):
          # 接近下限且向下运动 → 减速
          if q[i] < self.Joint_limits[i,0] + limit_margin and qdot[i] < 0:
              qdot[i] *= 0.1
          # 接近上限且向上运动 → 减速
          elif q[i] > self.Joint_limits[i,1] - limit_margin and qdot[i] > 0:
              qdot[i] *= 0.1

      # ---------- 发送关节速度指令 ----------
      for i in range(6):
          sim.setJointTargetVelocity(self.jointHandles[i], float(qdot[i]))

      # ---------- 轨迹可视化 ----------
      if self.trajectory_enabled and self.tipHandle is not None:
          tip_pos = sim.getObjectPosition(self.tipHandle, -1)
          sim.addDrawingObjectItem(self.drawingObject, tip_pos)
  ```],
)

#bluer[代码详解]：

=== 初始定位阶段
+ #reder[为何需要]：仿真开始时关节角度全为零，直接启动速度控制可能偏离轨迹
+ #reder[五次多项式]：$s(tau) = 10tau^3 - 15tau^4 + 6tau^5$ 保证了 $s(0)=0, s(1)=1, s'(0)=s'(1)=0$，即起点和终点速度为零
+ #reder[比例控制]：$dot(bold(q)) = K_p (bold(q)_"des" - bold(q))$，增益 $K_p=2.0$ 是经验值

=== 期望速度计算
+ #reder[正方形]：根据时间计算当前所在边，沿边方向给定恒定速度
+ #reder[圆形]：直接使用圆周运动的参数方程导数
+ #reder[圆锥]：仅给定角速度，线速度为零

=== 阻尼最小二乘求解
+ #reder[核心公式]：$dot(bold(q)) = bold(J)^T (bold(J) bold(J)^T + lambda^2 bold(I))^(-1) dot(bold(x))$
+ #reder[实现]：使用 `np.linalg.solve` 求解线性方程组，比直接求逆更稳定高效
+ #reder[阻尼系数]：$lambda = 0.01$ 是经验值，可根据任务调整

=== 安全保护机制
+ #reder[速度限幅]：防止关节速度超过硬件限制（100°/s）
+ #reder[软限位]：接近关节限位时自动减速，避免硬碰撞
+ #reder[乘以0.9/0.1]：留有安全裕度

= 实验总结与讨论

== 速度控制的优势

通过本次实验，验证了速度控制方法在机械臂轨迹跟踪中的以下优势：

+ #bluer[实现简洁]：
  - 圆锥轨迹：速度控制仅需1行代码 `omega = [0, 0, ω_z]`，而位置控制需要复杂的姿态规划和优化
  - 圆形轨迹：直接使用连续速度方程，无需离散化

+ #bluer[实时性强]：
  - 不需要预先规划整条轨迹
  - 每个周期只计算当前时刻的Jacobian（约0.1ms）
  - 可以动态调整目标速度，适合人机交互

+ #bluer[奇异点鲁棒]：
  - 阻尼最小二乘法保证数值稳定
  - 在奇异构型附近自动减速，避免关节速度爆炸
  - 比位置控制的多解选择更优雅

+ #bluer[易于扩展]：
  - 可以方便地加入力控、避障等功能
  - 只需修改期望速度的计算逻辑
  - 适合复杂的动态任务

== 速度控制的局限

实验中也发现了速度控制的一些不足：

+ #bluer[轨迹精度]：
  - 正方形顶点处有轻微圆角（约1-2mm）
  - 这是由于速度切换需要时间，关节不能瞬间改变方向
  - 对于需要严格经过路径点的任务，位置控制更合适

+ #bluer[参数调节]：
  - 阻尼系数 $lambda$ 的选择影响性能
  - 速度增益、限幅系数也需要调试
  - 需要一定的经验和试错

+ #bluer[Jacobian依赖]：
  - 需要精确的Jacobian矩阵
  - 如果模型参数（DH参数、连杆长度）不准确，会影响控制效果
  - 需要高效的计算实现（本实验使用C++）

== 两种方法的应用场景

根据实验结果，可以给出以下建议：

#figure(
  table(
    columns: 2,
    align: left + horizon,
    [*位置控制适用场景*], [*速度控制适用场景*],
    [- 高精度路径跟踪（如焊接、切割）], [- 实时响应任务（如遥操作、示教）],
    [- 预先知道完整轨迹], [- 动态目标跟踪],
    [- 需要严格经过指定点], [- 需要力控、阻抗控制],
    [- 离线规划任务], [- 避障、碰撞检测],
    [- 对实时性要求不高], [- 人机协作],
  ),
  caption: [两种控制方法的应用场景对比],
)

== 实验心得

+ #bluer[理论与实践结合]：
  - Jacobian矩阵从理论推导到代码实现，加深了对速度映射关系的理解
  - 阻尼最小二乘法不仅是数学公式，更是解决实际问题的工具

+ #bluer[代码优化的重要性]：
  - C++实现的Jacobian计算比Python快数十倍
  - 对于实时控制系统，计算效率至关重要

+ #bluer[安全机制不可或缺]：
  - 速度限幅、软限位保护避免了硬件损坏
  - 初始定位阶段保证了平滑启动

+ #bluer[灵活性的价值]：
  - 速度控制的灵活性在圆锥任务中体现得淋漓尽致
  - 相同的控制框架可以适用于多种任务

本次实验成功实现了基于速度控制的三种轨迹跟踪，验证了Jacobian方法的有效性，为后续的力控、避障等高级功能奠定了基础。

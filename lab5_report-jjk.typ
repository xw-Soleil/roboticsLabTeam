#import "导入函数库/lib_academic.typ": *
#show: codly-init.with()    // 初始化codly，每个文档只需执行一次
#codly(languages: codly-languages)  // 配置codly
#show table: three-line-table

#show: project.with(
  title: "实验5：世界坐标系下的轨迹规划",
  author: "第3组 金加康 吴必兴 沈学文 钱满亮 赵钰泓",
  date: auto,
  cover_name: "实验5：世界坐标系下的轨迹规划",
  cover_subname: "机器人技术与实践实验报告",
  school_id: "第三组",
  course: "机器人技术与实践",
  teacher: "周春琳",
  cover_date:"2025年11月23日",
  
  // abstract: [基于ZJU-I型机械臂的笛卡尔空间轨迹规划实验。],
  // keywords: ("机械臂", "轨迹规划", "笛卡尔空间"),
)


= 实验目的和要求

== 实验目的
+ 掌握在笛卡尔空间进行轨迹规划的方法
+ 学习控制机械臂末端执行器在世界坐标系下沿指定路径运动
+ 理解关节空间与笛卡尔空间之间的转换关系
+ 熟练运用逆运动学求解器实现复杂轨迹规划

== 任务要求
+ *正方形轨迹*：控制ZJU-I型机械臂末端执行器端点沿着边长为10cm的正方形连续移动，移动过程中末端执行器空间姿态保持不变，自定义正方形在笛卡尔空间的位置、末端点的移动速度。
+ *圆形轨迹*：控制ZJU-I型机械臂末端执行器端点沿着直径为10cm的圆连续移动，移动过程中末端执行器空间姿态保持不变，自定义圆在笛卡尔空间的位置、末端点的移动速度。
+ *圆锥轨迹*：控制ZJU-I型机械臂末端执行器绕着执行器的端点转动，即末端点位于空间圆锥体的顶点上，末端执行器绕点运动时其轴线（机械臂第6轴）始终与圆锥体的素线重合，圆锥体的锥角为60度，自定义圆锥体在笛卡尔空间中的位置、旋转角速度。
+ 提交计算过程报告、仿真工程文件以及仿真结果视频。

== 组员分工

1. *三种轨迹的速度控制实现*：吴必兴、沈学文

2. *三种轨迹的位置控制实现*：金加康、赵钰泓、钱满亮

3. *报告撰写*：小组成员撰写各自实现部分


= ZJUI型机械臂DH参数与坐标轴

#grid(
  columns: (auto, auto),
  column-gutter: 10em,
  align: horizon,

  // 左侧：表格
  figure(
    table(
      columns: 7,
      // 修正为7列
      stroke: none,
      align: center + horizon,

      fill: (x, y) => if y == 0 {
        rgb("#6ca0f9")
      } else if calc.odd(y) {
        rgb("#F2F2F2")
      } else {
        white
      },

      // 表头行（7列）
      text(fill: white, weight: "bold")[*关节 $i$*],
      text(fill: white, weight: "bold")[*$alpha_(i-1)$ \ (rad)*],
      text(fill: white, weight: "bold")[*$a_(i-1)$ \ (mm)*],
      text(fill: white, weight: "bold")[*$d_i$ \ (mm)*],
      text(fill: white, weight: "bold")[*$theta_i$ \ (rad)*],
      text(fill: white, weight: "bold")[*初始偏置*],
      text(fill: white, weight: "bold")[*关节类型*],

      // 数据行（每行7个单元格）
      [$1$], [$0$], [$0$], [$230$], [$theta_1$], [$0$], [旋转],
      [$2$], [$-pi/2$], [$0$], [$0$], [$theta_2$], [$-pi/2$], [旋转],
      [$3$], [$0$], [$185$], [$0$], [$theta_3$], [$0$], [旋转],
      [$4$], [$0$], [$170$], [$23$], [$theta_4$], [$pi/2$], [旋转],
      [$5$], [$pi/2$], [$0$], [$77$], [$theta_5$], [$pi/2$], [旋转],
      [$6$], [$pi/2$], [$0$], [$85.5$], [$theta_6$], [$0$], [旋转],
    ),
    caption: [DH参数表],
  ),

  // 右侧：图像
  figure(
    image("images/arm.jpg", width: 3cm),
    caption: [机械臂坐标系示意图],
  ),
)
= 基于速度控制的轨迹规划

== 结果与分析

=== 正方形轨迹

下图展示了机械臂末端执行器沿正方形轨迹运动的结果。使用速度控制方法，末端执行器准确地沿着边长为10cm的正方形路径运动，红色轨迹线清晰地显示了运动路径：
#v(-0.5em)
#figure(
  image("images/velocityCtrl/square.png", width: 62.5%),
  caption: [正方形轨迹运动结果 ｜ 速度控制],
)
下图为正方形轨迹运动时的关节运动曲线：

#v(-0.5em)
#figure(
  box(
    width: 75%,
    grid(
      columns: (1fr, 1fr),
      column-gutter: 2mm,
      image("images/velocityCtrl/squareDatapos.png", width: 100%),
      image("images/velocityCtrl/squareDatavel.png", width: 100%),
    ),
  ),
  caption: [正方形轨迹的关节运动曲线 ｜ 速度控制],
)
#v(-0.5em)
正方形轨迹的速度控制分析：
+ *速度直接控制*：与位置控制不同，关节速度是直接计算并控制的，通过Jacobian矩阵从末端速度实时映射得到。
+ *较好的实时性*：速度控制不需要预先规划整条轨迹，而是每个控制周期实时计算，因此具有更好的实时性。


=== 圆形轨迹

下图展示了机械臂末端执行器沿圆形轨迹运动的结果。红色圆圈清晰地显示了末端执行器的运动轨迹，直径约为10cm：
#v(-1em)
#figure(
  image("images/velocityCtrl/circle.png", width: 40%),
  caption: [圆形轨迹运动结果 ｜ 速度控制],
)
#v(-0.5em)
下图为圆形轨迹运动时的关节运动曲线：

#figure(
  box(
    width: 75%,
    grid(
      columns: (1fr, 1fr),
      column-gutter: 2mm,
      image("images/velocityCtrl/circleDatapos.png", width: 100%),
      image("images/velocityCtrl/circleDatavel.png", width: 100%),
    ),
  ),
  caption: [圆形轨迹的关节运动曲线 ｜ 速度控制],
)

圆形轨迹的速度控制分析：
+ *控制方法直观*：圆形轨迹的速度是连续变化的，适合速度控制方法。与位置控制相比，直接对圆周运动的参数方程求导即可得到速度。
+ *平滑周期性*：各关节的位置和速度曲线都呈现周期性，说明速度控制能够很好地跟踪连续变化的轨迹。
+ *速度恒定*：末端执行器的线速度大小保持恒定（0.025 m/s），仅方向沿切线方向变化。

=== 圆锥轨迹

下图展示了机械臂末端执行器绕固定点作圆锥运动的结果。从图中可以看出，末端执行器的轴线与圆锥素线重合，末端点保持固定：
#v(-1em)
#figure(
  image("images/velocityCtrl/cone.png", width: 40%),
  caption: [圆锥轨迹运动结果 ｜ 速度控制],
)
#v(-0.5em)
下图为圆锥轨迹运动时的关节运动曲线：
#v(-0.5em)
#figure(
  box(
    width: 75%,
    grid(
      columns: (1fr, 1fr),
      column-gutter: 2mm,
      image("images/velocityCtrl/coneDatapos.png", width: 100%),
      image("images/velocityCtrl/coneDatavel.png", width: 100%),
    ),
  ),
  caption: [圆锥轨迹的关节运动曲线 ｜ 速度控制],
)
#v(-0.5em)
圆锥轨迹的速度控制分析：
+ *纯姿态控制*：圆锥运动仅涉及姿态变化（末端点位置固定），因此线速度为零，仅有角速度。
+ *实现简洁*：速度控制下，圆锥运动的实现只需给定一个恒定的角速度向量 $bold(omega) = [0, 0, 20degree\/s]^T$，无需复杂的姿态规划。
// + *与位置控制对比*：位置控制需要计算圆锥面上每个点的姿态、优化自旋角、处理多解选择等复杂问题；而速度控制只需给定角速度即可，体现了速度控制的灵活性优势。
+ *周期性变化*：各关节速度呈现周期性变化，周期约为18秒（$360degree div 20degree\/s$），与给定的旋转角速度一致。


== 实验内容与原理

=== Jacobian矩阵的定义

Jacobian矩阵建立了机械臂#bluer[关节速度]与#bluer[末端速度]之间的线性映射关系：
#v(-0.5em)
$
  dot(bold(x)) = bold(J)(bold(q)) dot(bold(q))
$ <eq1>

#h(2em)Jacobian矩阵的结构为：
#v(-0.5em)
$
  bold(J)(bold(q)) = mat(
    bold(J)_v;
    bold(J)_omega
  ) = mat(
    J_(v_x 1), J_(v_x 2), J_(v_x 3), J_(v_x 4), J_(v_x 5), J_(v_x 6);
    J_(v_y 1), J_(v_y 2), J_(v_y 3), J_(v_y 4), J_(v_y 5), J_(v_y 6);
    J_(v_z 1), J_(v_z 2), J_(v_z 3), J_(v_z 4), J_(v_z 5), J_(v_z 6);
    J_(omega_x 1), J_(omega_x 2), J_(omega_x 3), J_(omega_x 4), J_(omega_x 5), J_(omega_x 6);
    J_(omega_y 1), J_(omega_y 2), J_(omega_y 3), J_(omega_y 4), J_(omega_y 5), J_(omega_y 6);
    J_(omega_z 1), J_(omega_z 2), J_(omega_z 3), J_(omega_z 4), J_(omega_z 5), J_(omega_z 6)
  )
$ <eq2>
#v(-0.5em)

#h(2em)上半部分 $bold(J)_v$ 描述线速度映射，下半部分 $bold(J)_omega$ 描述角速度映射。




=== ZJU-I 型机械臂几何雅可比矩阵表达式

结合上一次实验报告的推导结果，ZJU-I 型机械臂的几何雅可比矩阵可以表示为：

$
  J(q) = mat(
    J_v;
    J_omega
  ) = mat(
    J_v^(1), J_v^(2), J_v^(3), J_v^(4), J_v^(5), J_v^(6);
    J_omega^(1), J_omega^(2), J_omega^(3), J_omega^(4), J_omega^(5), J_omega^(6);
  )
$

#h(2em)其中，$J_v in bb(R)^(3 times 6)$ 为线速度雅可比，$J_omega in bb(R)^(3 times 6)$ 为角速度雅可比。为简化表达，记 *$Sigma = q_2 + q_3 + q_4$*。

==== 线速度雅可比矩阵 $J_v$

$
  J_v = mat(
    -y_e, cos(q_1) J_v^(2)_"共", cos(q_1) J_v^(3)_"共", cos(q_1) J_v^(4)_"共", J_v^(5)_x, 0;
    x_e, sin(q_1) J_v^(2)_"共", sin(q_1) J_v^(3)_"共", sin(q_1) J_v^(4)_"共", J_v^(5)_y, 0;
    0, J_v^(2)_z, J_v^(3)_z, J_v^(4)_z, J_v^(5)_z, 0;
  )
$

#h(2em)其中各项具体表达式为：

*第 1 列：*

$
  J_v^(1) = [-y_e, x_e, 0]^T
$

$
  x_e & = -171/2 sin(q_1) sin(q_5) - 23 sin(q_1) + 185 sin(q_2) cos(q_1) \
      & quad + 170 sin(q_2 + q_3) cos(q_1) + 77 sin(Sigma) cos(q_1) \
      & quad + 171/2 cos(q_1) cos(q_5) cos(Sigma)
$

$
  y_e & = 185 sin(q_1) sin(q_2) + 170 sin(q_1) sin(q_2 + q_3) + 77 sin(q_1) sin(Sigma) \
      & quad + 171/2 sin(q_1) cos(q_5) cos(Sigma) + 171/2 sin(q_5) cos(q_1) + 23 cos(q_1)
$

#h(2em)*第 2 列：*

$
  J_v^(2)_"共" & = -171/2 sin(Sigma) cos(q_5) + 185 cos(q_2) \
               & quad + 170 cos(q_2 + q_3) + 77 cos(Sigma)
$

$
  J_v^(2)_z & = -185 sin(q_2) - 170 sin(q_2 + q_3) - 77 sin(Sigma) \
            & quad - 171/2 cos(q_5) cos(Sigma)
$

#h(2em)*第 3 列：*

$
  J_v^(3)_"共" & = -171/2 sin(Sigma) cos(q_5) + 170 cos(q_2 + q_3) + 77 cos(Sigma)
$

$
  J_v^(3)_z & = -170 sin(q_2 + q_3) - 77 sin(Sigma) - 171/2 cos(q_5) cos(Sigma)
$

#h(2em)*第 4 列：*

$
  J_v^(4)_"共" & = -171/2 sin(Sigma) cos(q_5) + 77 cos(Sigma)
$

$
  J_v^(4)_z & = -77 sin(Sigma) - 171/2 cos(q_5) cos(Sigma)
$

#h(2em)*第 5 列：*

$ J_v^(5)_x = -171/2 sin(q_1) cos(q_5) - 171/2 sin(q_5) cos(q_1) cos(Sigma) $

$ J_v^(5)_y = -171/2 sin(q_1) sin(q_5) cos(Sigma) + 171/2 cos(q_1) cos(q_5) $

$ J_v^(5)_z = 171/2 sin(q_5) sin(Sigma) $

#h(2em)*第 6 列：* 末端关节轴通过末端点，线速度贡献为零。

==== 角速度雅可比矩阵 $J_omega$

$
  J_omega = mat(
    0, -sin(q_1), -sin(q_1), -sin(q_1), sin(Sigma) cos(q_1), J_omega^(6)_x;
    0, cos(q_1), cos(q_1), cos(q_1), sin(q_1) sin(Sigma), J_omega^(6)_y;
    1, 0, 0, 0, cos(Sigma), J_omega^(6)_z;
  )
$

#h(2em)其中第 6 列各分量为：

$ J_omega^(6)_x = -sin(q_1) sin(q_5) + cos(q_1) cos(q_5) cos(Sigma) $

$ J_omega^(6)_y = sin(q_1) cos(q_5) cos(Sigma) + sin(q_5) cos(q_1) $

$ J_omega^(6)_z = -sin(Sigma) cos(q_5) $

=== 速度层逆解问题

*问题描述*：已知期望末端速度 $dot(bold(x))_"des"$，求解关节速度 $dot(bold(q))$。

最直接的想法是对方程 @eq1 两边求逆：
#v(-0.5em)
$
  dot(bold(q)) = bold(J)^(-1)(bold(q)) dot(bold(x))
$ <eq4>
#v(-0.5em)

#h(2em)然而，这个方法存在以下问题：

+ *奇异性问题*：当机械臂处于奇异构型时，$bold(J)$ 的行列式接近零，$bold(J)^(-1)$ 趋于无穷大，导致关节速度剧烈增大，实际不可行。
+ *数值不稳定*：即使不完全奇异，$bold(J)$ 接近奇异时，直接求逆的数值误差也会被极大放大。

为了解决奇异性问题，采用#bluer[阻尼最小二乘法]（也称为Levenberg-Marquardt方法）：
#v(-0.5em)
$
  dot(bold(q)) = bold(J)^T (bold(J) bold(J)^T + lambda^2 bold(I)_6)^(-1) dot(bold(x))
$ <eq5>
#v(-0.5em)
#h(2em)其中 $lambda > 0$ 是*阻尼系数*，通常取较小值（如0.01-0.1）。



=== 三种轨迹的速度定义与计算

==== 正方形轨迹速度

正方形轨迹由四条边组成，每条边是一条直线段。在速度控制下，需要实时计算末端在当前边上的运动速度。

*速度计算*：

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


==== 圆形轨迹速度

圆形轨迹是最适合速度控制的路径之一，因为其速度是*连续变化*的。

*轨迹参数方程*：

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
#h(2em)其中 $omega = v_"lin" / R$ 是角频率。

*速度推导：*

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

#h(2em)可以验证速度大小恒定：
#v(-0.5em)
$
  norm(bold(v)(t)) = v_"lin" sqrt(sin^2(omega t) + cos^2(omega t)) = v_"lin"
$ <eq13>
#v(-0.5em)

#h(2em)速度方向始终与位置向量 $bold(p)(t) - bold(p)_c$ 垂直，即沿圆的#bluer[切线方向]。

角速度仍为零：
#v(-0.5em)
$
  bold(omega)(t) = bold(0)
$ <eq14>
#v(-0.5em)


==== 圆锥轨迹速度

圆锥运动是#bluer[纯姿态变化]的任务，末端点位置固定，仅姿态绕圆锥轴旋转。

*运动描述*：

+ 末端点固定在圆锥顶点：
  #v(-0.5em)
  $
    bold(p)(t) = bold(p)_"apex" = "常量"
  $ <eq15>
  #v(-0.5em)

+ 末端执行器轴线在圆锥面上旋转，与圆锥轴夹角为半锥角 $alpha_"cone" = 30degree$

+ 轴线绕圆锥轴（取为z轴）以角速度 $omega_z$ 旋转

*速度定义*：

1. 线速度为零：
#v(-0.5em)
$
  bold(v)(t) = bold(0)
$ <eq16>
#v(-0.5em)

2. 角速度为绕圆锥轴的旋转：
#v(-0.5em)
$
  bold(omega)(t) = omega_z bold(e)_z = mat(0; 0; omega_z)
$ <eq17>
#v(-0.5em)
#h(2em)其中 $omega_z = 20 degree"/s" = 0.349$ rad/s，$bold(e)_z$ 是圆锥轴方向（通常取为 $[0, 0, -1]^T$ 或 $[0, 0, 1]^T$）。

由于线速度为零，速度映射方程简化为：
#v(-0.5em)
$
  mat(bold(0); bold(omega)) = mat(bold(J)_v; bold(J)_omega) dot(bold(q)) => bold(omega) = bold(J)_omega dot(bold(q))
$ <eq18>
#v(-0.5em)

== 核心代码实现

=== Jacobian矩阵计算
基于DH参数推导的解析公式计算6×6几何Jacobian矩阵,使用`C++`实现。

#v(-0.5em)
#figure(
  [```cpp
  #include "jacobi_core.h"
  #include <cmath>

  // Length parameters (185, 170, 77, 23, 171/2, 230) in mm units

  void jacobi_zjui_core(const double q[6], double J[36]) {
    const double q1 = q[0];
    const double q2 = q[1];
    const double q3 = q[2];
    const double q4 = q[3];
    const double q5 = q[4];
    // q6 not used in geometric Jacobian

    const double Sigma = q2 + q3 + q4;

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

    const double k = 171.0 / 2.0;

    // Column 1
    const double J1vx = -185.0 * s1 * s2 - 170.0 * s1 * s23 - 77.0 * s1 * sSig -
                        k * s1 * c5 * cSig - k * s5 * c1 - 23.0 * c1;

    const double J1vy = -k * s1 * s5 - 23.0 * s1 + 185.0 * s2 * c1 +
                        170.0 * s23 * c1 + 77.0 * sSig * c1 + k * c1 * c5 * cSig;

    // Linear velocity
    J[0 * 6 + 0] = J1vx;
    J[1 * 6 + 0] = J1vy;
    J[2 * 6 + 0] = 0.0;
    // Angular velocity: z1 = [0,0,1]^T
    J[3 * 6 + 0] = 0.0;
    J[4 * 6 + 0] = 0.0;
    J[5 * 6 + 0] = 1.0;

    // Column 2
    const double common2 =
        -k * sSig * c5 + 185.0 * c2 + 170.0 * c23 + 77.0 * cSig;

    const double J2vx = c1 * common2;
    const double J2vy = s1 * common2;
    const double J2vz = -185.0 * s2 - 170.0 * s23 - 77.0 * sSig - k * c5 * cSig;

    J[0 * 6 + 1] = J2vx;
    J[1 * 6 + 1] = J2vy;
    J[2 * 6 + 1] = J2vz;
    // Angular velocity: z2 = [-sin(q1), cos(q1), 0]^T
    J[3 * 6 + 1] = -s1;
    J[4 * 6 + 1] = c1;
    J[5 * 6 + 1] = 0.0;

    // Column 3
    const double common3 = -k * sSig * c5 + 170.0 * c23 + 77.0 * cSig;

    const double J3vx = c1 * common3;
    const double J3vy = s1 * common3;
    const double J3vz = -170.0 * s23 - 77.0 * sSig - k * c5 * cSig;

    J[0 * 6 + 2] = J3vx;
    J[1 * 6 + 2] = J3vy;
    J[2 * 6 + 2] = J3vz;
    // Angular velocity: z3 = z2
    J[3 * 6 + 2] = -s1;
    J[4 * 6 + 2] = c1;
    J[5 * 6 + 2] = 0.0;

    // Column 4
    const double common4 = -k * sSig * c5 + 77.0 * cSig;

    const double J4vx = c1 * common4;
    const double J4vy = s1 * common4;
    const double J4vz = -77.0 * sSig - k * c5 * cSig;

    J[0 * 6 + 3] = J4vx;
    J[1 * 6 + 3] = J4vy;
    J[2 * 6 + 3] = J4vz;
    // Angular velocity: z4 = z2
    J[3 * 6 + 3] = -s1;
    J[4 * 6 + 3] = c1;
    J[5 * 6 + 3] = 0.0;

    // Column 5
    const double J5vx = -k * s1 * c5 - k * s5 * c1 * cSig;

    const double J5vy = -k * s1 * s5 * cSig + k * c1 * c5;

    const double J5vz = k * s5 * sSig;

    J[0 * 6 + 4] = J5vx;
    J[1 * 6 + 4] = J5vy;
    J[2 * 6 + 4] = J5vz;
    // Angular velocity: z5
    J[3 * 6 + 4] = sSig * c1;
    J[4 * 6 + 4] = s1 * sSig;
    J[5 * 6 + 4] = cSig;

    // Column 6
    // Linear velocity is zero
    J[0 * 6 + 5] = 0.0;
    J[1 * 6 + 5] = 0.0;
    J[2 * 6 + 5] = 0.0;

    // Angular velocity: z6
    const double J6wx = -s1 * s5 + c1 * c5 * cSig;
    const double J6wy = s1 * c5 * cSig + s5 * c1;
    const double J6wz = -sSig * c5;

    J[3 * 6 + 5] = J6wx;
    J[4 * 6 + 5] = J6wy;
    J[5 * 6 + 5] = J6wz;

    // Convert linear velocity from mm to m
    const double scale = 1e-3;
    for (int col = 0; col < 6; ++col) {
      for (int row = 0; row < 3; ++row) {
        J[row * 6 + col] *= scale;
      }
    }
  }
  ```],
)

#h(-2em)*代码解析*：

+ *DH参数*：185, 170, 77, 23 等参数可参见第二章节中的DH参数表。

+ *累加角度$Sigma$*：机械臂的关节2、3、4是串联的旋转关节，它们的累加效果体现在 $Sigma = q_2 + q_3 + q_4$。

+ *预计算三角函数*：`s1 = sin(q1)`, `c1 = cos(q1)` 等，避免重复调用 `sin/cos` 函数，提高效率。

+ *分列计算*：每一列对应一个关节的贡献。上半部分（前3行）是线速度 $bold(J)_v$，下半部分（后3行）是角速度 $bold(J)_omega$。

+ *z轴方向*：
  + 关节1绕世界坐标系的z轴，故 $bold(z)_1 = [0, 0, 1]^T$
  + 关节2、3、4绕经过关节1旋转后的y轴（在世界坐标系中是 $[-sin(q_1), cos(q_1), 0]^T$）
  + 关节5、6的轴线方向更复杂，需要通过完整运动学推导

+ *单位转换*：推导时使用mm作为长度单位（与DH参数一致），最后转换为m，以匹配SI单位制。

=== `PyBind11` 封装模块

使用`PyBind11`对`C++`代码进行封装

#figure(
  [```cpp
  #include "jacobi_core.h"
  #include <pybind11/numpy.h>
  #include <pybind11/pybind11.h>

  namespace py = pybind11;

  // Python wrapper for Jacobian computation
  py::array_t<double>
  jacobi_py(py::array_t<double, py::array::c_style | py::array::forcecast> q_in) {
    if (q_in.size() != 6)
      throw std::runtime_error("q must be length 6");

    // Extract joint angles from numpy array
    double q[6];
    auto buf = q_in.request();
    double *qptr = static_cast<double *>(buf.ptr);
    for (int i = 0; i < 6; ++i)
      q[i] = qptr[i];

    // Compute Jacobian
    double J[36];
    jacobi_zjui_core(q, J);

    // Return 6x6 numpy array
    auto result = py::array_t<double>({6, 6});
    auto rbuf = result.request();
    double *rptr = static_cast<double *>(rbuf.ptr);
    for (int i = 0; i < 36; ++i)
      rptr[i] = J[i];

    return result;
  }

  PYBIND11_MODULE(jacobi_zjui, m) {
    m.doc() = "Geometric Jacobian for ZJU-I arm";
    m.def("jacobi", &jacobi_py, "Compute 6x6 Jacobian J(q)");
  }
  ```],
)

=== 编译配置（setup.py）

#v(-0.5em)
#figure(
  [```python
  from setuptools import setup
  from pybind11.setup_helpers import Pybind11Extension, build_ext

  # Extension module configuration
  ext_modules = [
      Pybind11Extension(
          "jacobi_zjui",
          ["jacobi_zjui_module.cpp", "jacobi_core.cpp"],
      ),
  ]

  # Package setup
  setup(
      name="jacobi_zjui",
      version="0.1",
      ext_modules=ext_modules,
      cmdclass={"build_ext": build_ext},
  )
  ```],
)

#h(-2em)*编译命令: *
```bash
# 安装pybind11
pip install pybind11

# 编译生成jacobi_zjui.pyd
python setup.py build_ext --inplace
```

#h(2em) 编译成功后，会在当前目录生成 `jacobi_zjui.cp310-win_amd64.pyd`可以直接在Python中导入。

=== 运动轨迹控制代码实现

这是速度控制的*主要逻辑*，实现了从期望速度到关节速度的转换。

#v(-0.5em)
#figure(
  [```python
  def sysCall_actuation():

      t = sim.getSimulationTime()

      # Initial positioning
      if t < INIT_DURATION:
          q_current = np.array([sim.getJointPosition(h) for h in self.jointHandles])

          # Quintic polynomial interpolation for smooth motion
          tau = t / INIT_DURATION
          s = 10*tau**3 - 15*tau**4 + 6*tau**5
          q_desired = self.q0 + s * (self.q_start - self.q0)

          # Proportional control with velocity limiting
          position_error = q_desired - q_current
          qdot = POSITION_GAIN * position_error

          # Apply velocity limits
          for i in range(6):
              if abs(qdot[i]) > self.Vel_limits[i]:
                  qdot[i] = np.sign(qdot[i]) * self.Vel_limits[i] * 0.5

          # Send velocity commands
          for i in range(6):
              sim.setJointTargetVelocity(self.jointHandles[i], float(qdot[i]))

          return

      # Initialize trajectory control
      if not self.velocityModeEnabled:
          self.velocityModeEnabled = True
          q_before_switch = np.array([sim.getJointPosition(h) for h in self.jointHandles])
          self.last_q = q_before_switch.copy()
          self.sim_dt = sim.getSimulationTimeStep()

      # Trajectory control
      if not JACOBI_OK:
          sim.pauseSimulation()
          return

      t2 = t - INIT_DURATION
      q = np.array([sim.getJointPosition(h) for h in self.jointHandles])

      # Compute desired end-effector velocity
      if TASK_MODE == 1:
          # Square
          tau = t2 % self.squarePeriod
          idx = min(int(tau // self.squareEdgeTime), 3)
          p1 = self.squareCorners[idx]
          p2 = self.squareCorners[(idx+1) % 4]
          v = SQUARE_VELOCITY * (p2 - p1) / np.linalg.norm(p2 - p1)
          omega = np.zeros(3)

      elif TASK_MODE == 2:
          # Circle
          phi = self.circleOmega * t2
          v = np.array([
              -CIRCLE_RADIUS * self.circleOmega * np.sin(phi),
              CIRCLE_RADIUS * self.circleOmega * np.cos(phi),
              0
          ])
          omega = np.zeros(3)

      else:  # TASK_MODE == 3
          # Cone orientation
          v = np.zeros(3)
          omega = np.array([0.0, 0.0, CONE_ANGULAR_VEL])

          # Visualize end effector axis during cone motion
          if self.cone_vis_enabled:
              try:
                  tip_pos_current = np.array(sim.getObjectPosition(self.tipHandle, -1))
                  tip_matrix = sim.getObjectMatrix(self.tipHandle, sim.handle_world)
                  axis_z = np.array([tip_matrix[2], tip_matrix[6], tip_matrix[10]])
                  axis_length = 0.12
                  line_start = tip_pos_current
                  line_end = tip_pos_current + axis_length * axis_z
                  sim.addDrawingObjectItem(self.endAxisDrawing, list(line_start) + list(line_end))
              except:
                  pass

      # Combine linear and angular velocity
      xdot = np.concatenate([v, omega])

      # Jacobian-based inverse kinematics
      J = np.array(jacobi_zjui.jacobi(q), dtype=float)
      JT = J.T
      JJT = J @ JT
      qdot = JT @ np.linalg.solve(JJT + (DAMPING_FACTOR**2) * np.eye(6), xdot)

      # Apply joint velocity limits
      for i in range(6):
          if abs(qdot[i]) > self.Vel_limits[i]:
              qdot[i] = np.sign(qdot[i]) * self.Vel_limits[i] * 0.9

      # Soft joint limit protection
      limit_margin = 10.0 * np.pi / 180
      for i in range(6):
          if q[i] < self.Joint_limits[i,0] + limit_margin and qdot[i] < 0:
              qdot[i] *= 0.1
          elif q[i] > self.Joint_limits[i,1] - limit_margin and qdot[i] > 0:
              qdot[i] *= 0.1

      # Send joint velocity commands
      for i in range(6):
          sim.setJointTargetVelocity(self.jointHandles[i], float(qdot[i]))

      # Trajectory visualization
      if self.trajectory_enabled and self.tipHandle is not None:
          tip_pos = sim.getObjectPosition(self.tipHandle, -1)
          sim.addDrawingObjectItem(self.drawingObject, tip_pos)
  ```],
)
#h(-2em)*代码解析*：

+ 初始定位轨迹规划
  + 仿真开始时关节角度全为零，直接启动速度控制可能*偏离轨迹*，所以需要在开始阶段加入一个初始定位，以避免轨迹偏离。
  + 使用*五次多项式*进行位置规划，插值函数为$s(tau) = 10tau^3 - 15tau^4 + 6tau^5$， 其中 $tau in [0,1]$ 是归一化时间, 这保证了 $s(0)=0, s(1)=1, s'(0)=s'(1)=0$，即起点和终点速度为零
  + *比例控制*：加入比例控制，产生跟踪速度消除位置误差。公式为 $dot(bold(q)) = K_p (bold(q)_"des" - bold(q))$，增益 $K_p=2.0$ 是经验值

+ 期望速度计算
  + *正方形*：根据时间计算当前所在边，沿边方向给定恒定速度
  + *圆形*：直接使用圆周运动的参数方程导数
  + *圆锥*：仅给定角速度，线速度为零

+ 阻尼最小二乘求解
  + *实现原理*：$dot(bold(q)) = bold(J)^T (bold(J) bold(J)^T + lambda^2 bold(I))^(-1) dot(bold(x))$，使用此公式来求逆从而进行逆运动学求解
  + *实现方式*：使用 `np.linalg.solve` 求解线性方程组 $(bold(J) bold(J)^T + lambda^2 bold(I)) bold(z) = dot(bold(x))$，然后计算 $dot(bold(q)) = bold(J)^T bold(z)$，比直接求逆更稳定
  + *阻尼系数*：$lambda = 0.01$ 是经验值，在此次仿真中效果较好。阻尼项 $lambda^2 bold(I)$ 防止了雅可比矩阵接近奇异时的数值不稳定

+ 速度与位置限制
  + *速度限幅*：检查每个关节的计算速度是否超过硬件限制（100°/s），超过时按比例缩放到限制值的90%
  + *软限位保护*：当关节位置接近运动范围边界（留10°安全裕度）且速度方向朝向边界时，将速度缩减为10%，实现平滑减速
  + *参数设定*：速度限幅时乘以0.9、软限位时乘以0.1


= 基于位置控制的轨迹规划

== 结果与分析

=== 正方形轨迹

下图展示了机械臂末端执行器沿正方形轨迹运动的结果。从仿真截图可以看出，末端执行器准确地沿着边长为10cm的正方形路径运动，绿色轨迹线清晰地显示了运动路径：
#v(-0.5em)
#figure(
  image("images/（位置控制）正方形结果.png", width: 62.5%),
  caption: [正方形轨迹运动结果],
)

下图为机械臂运动时各关节的位置、速度和加速度变化曲线：
#v(-0.5em)
#figure(
  image("images/（位置控制）正方形曲线.png", width: 100%),
  caption: [正方形轨迹的关节运动曲线],
)
#v(-0.5em)
从曲线可以观察到：
+ *位置连续性*：各关节位置曲线平滑连续，在正方形四个顶点处有明显的转折，这是由于路径方向改变所致。
+ *速度平滑性*：速度曲线呈现周期性变化，在直线段保持相对稳定，在转角处有适当的过渡。
+ *加速度控制*：加速度峰值控制在限制范围内，整体变化平稳，无剧烈跳变。

=== 圆形轨迹

下图展示了机械臂末端执行器沿圆形轨迹运动的结果。绿色圆圈清晰地显示了末端执行器的运动轨迹，直径约为10cm：
#v(-1em)
#figure(
  image("images/（位置控制）圆形结果.png", width: 40%),
  caption: [圆形轨迹运动结果],
)
#v(-0.5em)
下图为圆形轨迹运动时的关节运动曲线：

#figure(
  image("images/（位置控制）圆形曲线.png", width: 100%),
  caption: [圆形轨迹的关节运动曲线],
)

圆形轨迹的运动特点：
+ *周期性*：由于圆形轨迹的周期性特性，各关节的位置、速度曲线均呈现明显的周期性变化。
+ *平滑性*：相比正方形轨迹，圆形轨迹的速度和加速度变化更加平滑，这是因为圆形路径没有尖锐的转角。
+ *关节3波动*：关节3（蓝色曲线）的速度变化幅度最大，达到约±20 deg/s，这是由于该关节在维持圆形轨迹中承担了主要的运动任务。

=== 圆锥轨迹

下图展示了机械臂末端执行器绕固定点作圆锥运动的结果。从图中可以看出，末端执行器的轴线与圆锥素线重合，末端点保持固定：
#v(-1em)
#figure(
  image("images/（位置控制）圆锥结果.png", width: 40%),
  caption: [圆锥轨迹运动结果],
)
#v(-0.5em)
下图为圆锥轨迹运动时的关节运动曲线：
#v(-0.5em)
#figure(
  image("images/（位置控制）圆锥曲线.png", width: 100%),
  caption: [圆锥轨迹的关节运动曲线],
)
#v(-0.5em)
圆锥轨迹的特点：
+ *姿态变化*：与前两个任务不同，圆锥运动主要体现在末端执行器的姿态变化上，而非位置变化。
+ *速度分布*：各关节速度呈现周期性变化，其中关节1和关节3的速度变化最为显著。
+ *加速度峰值*：在约10秒时刻，关节5出现了较大的加速度峰值（超过100 deg/s²），但仍在安全限制（500 deg/s²）范围内。

== 实验内容与原理

=== 坐标系与运动学
+ 在机械臂轨迹规划中，涉及两种主要的坐标系：
  + #bluer[关节空间]：由各关节角度 $bold(q) = [theta_1, theta_2, theta_3, theta_4, theta_5, theta_6]^T$ 组成的空间。
  + #bluer[笛卡尔空间]：由末端执行器的位置和姿态 $bold(p) = [x, y, z, alpha, beta, gamma]^T$ 组成的空间。
+ 正运动学建立了从关节空间到笛卡尔空间的映射：
  #v(-0.5em)
  $
    bold(p) = f(bold(q))
  $
  #v(-0.5em)
+ 逆运动学则是其逆过程：
  #v(-0.5em)
  $
    bold(q) = f^(-1)(bold(p))
  $
  #v(-0.5em)
  由于逆运动学通常存在多解，需要通过优化算法选择最合理的解。

=== 五次多项式轨迹规划

为了保证关节运动的平滑性，采用五次多项式进行轨迹插值。五次多项式的形式为：
#v(-0.5em)
$
  theta(t) = a_0 + a_1 t + a_2 t^2 + a_3 t^3 + a_4 t^4 + a_5 t^5
$
#v(-0.5em)
#h(2em)对应的速度和加速度为：
#v(-0.5em)
$
  cases(
    dot(theta)(t) = a_1 + 2a_2 t + 3a_3 t^2 + 4a_4 t^3 + 5a_5 t^4,
    dot.double(theta)(t) = 2a_2 + 6a_3 t + 12a_4 t^2 + 20a_5 t^3
  )
$
#v(-0.5em)
#h(2em)给定初始和终止条件：
#v(-0.5em)
$
  cases(
    theta(0) = theta_0\, dot(theta)(0) = v_0\, dot.double(theta)(0) = a_0,
    theta(T) = theta_T\, dot(theta)(T) = v_T\, dot.double(theta)(T) = a_T
  )
$
#v(-0.5em)
#h(2em)可以求解出六个系数 $a_0, a_1, a_2, a_3, a_4, a_5$，从而得到平滑的轨迹。

=== 正方形轨迹规划
+ 正方形轨迹由四条边组成，每条边的规划方法相同。对于每条边：
  + 确定起点和终点的笛卡尔坐标
  + 使用逆运动学求解器计算对应的关节角
  + 在关节空间使用五次多项式插值
  + 保持末端姿态不变
+ 正方形的四个顶点坐标设定为（以中心为原点）：
  #v(-0.5em)
  $
    cases(
      bold(p)_1 = [x_c - L\/2\, y_c - L\/2\, z_c\, alpha\, beta\, gamma]^T,
      bold(p)_2 = [x_c + L\/2\, y_c - L\/2\, z_c\, alpha\, beta\, gamma]^T,
      bold(p)_3 = [x_c + L\/2\, y_c + L\/2\, z_c\, alpha\, beta\, gamma]^T,
      bold(p)_4 = [x_c - L\/2\, y_c + L\/2\, z_c\, alpha\, beta\, gamma]^T
    )
  $
  #v(-0.5em)
  其中 $L = 0.1$ m 为边长。

=== 圆形轨迹规划
圆形轨迹通过参数方程描述。将圆周分为 $N$ 个离散点，每个点的位置为：
#v(-0.5em)
$
  cases(
    x(t) = x_c + R cos(2pi t \/ T),
    y(t) = y_c + R sin(2pi t \/ T),
    z(t) = z_c
  )
$
#v(-0.5em)
其中 $R = 0.05$ m 为半径，$T$ 为运动周期。对于每个时间段，使用五次多项式在关节空间插值。

=== 圆锥轨迹规划
+ 圆锥运动的特点是末端点位置固定，但末端执行器的姿态按圆锥面旋转。设圆锥顶点为 $bold(p)_"apex"$，半锥角为 $alpha_"cone" = 30degree$。
+ 末端执行器的#bluer[轴线（approach vector）]在圆锥面上运动，可以用球坐标描述：
  #v(-0.5em)
  $
    bold(a)(phi) = mat(
      sin(alpha_"cone") cos(phi);
      sin(alpha_"cone") sin(phi);
      cos(alpha_"cone")
    )
  $
  #v(-0.5em)
  其中 $phi in [0, 2pi]$ 为方位角。对于每个姿态，需要构建完整的旋转矩阵 $bold(R) = [bold(n), bold(o), bold(a)]$，然后转换为欧拉角。
+ 为了保证姿态的连续性，引入#bluer[自旋角（spin angle）参数]，通过优化算法选择使关节角变化最小的解。

== 代码实现思路

=== 总体架构

代码分为以下几个主要部分：
+ *逆运动学求解器*（`myIKSolver` 类）：根据末端位姿计算关节角，返回所有可能的解。
+ *轨迹规划函数*（`quintic_trajectory_coefficients` 等）：计算多项式系数和轨迹点。
+ *姿态处理函数*（`build_rotation_matrix_from_a_axis` 等）：处理旋转矩阵和欧拉角转换。
+ *初始化函数*（`sysCall_init`）：为每个任务生成完整的轨迹参数。
+ *执行函数*（`sysCall_actuation`）：在每个仿真步实时计算并执行关节角。

=== 正方形轨迹实现

+ 正方形轨迹的关键步骤：
  + 定义正方形中心位置和边长。
    #v(-1em)
    ```python
    square_center = [0.05, 0.4, 0.25]
    square_size = 0.1
    square_pose = [np.pi, 0, -np.pi/2]
    ```
  + 计算四个顶点的笛卡尔坐标。
  + 使用逆运动学求解器计算每个顶点的关节角。
  + 从多个解中选择与前一点距离最小的解，保证连续性。
  + 对每条边使用五次多项式规划，设置合适的边界条件。
+ 关键代码片段：
  #v(-1em)
  ```python
  # 计算四条边的五次多项式系数
  for i in range(4):
      start_angles = square_angles[i]
      end_angles = square_angles[(i+1) % 4]
      edge_coeffs = []
      for j in range(6):
          coeffs = quintic_trajectory_coefficients(
              start_angles[j], 0, 0,
              end_angles[j], 0, 0,
              time_per_edge
          )
          edge_coeffs.append(coeffs)
      self.square_edge_coeffs.append(edge_coeffs)
  ```

=== 圆形轨迹实现
圆形轨迹将圆周均匀分为多个点：
+ 设定圆心、半径和姿态。
  #v(-1em)
  ```python
  circle_center = [0.05, 0.4, 0.25]
  circle_radius = 0.05
  circle_pose = [np.pi, 0, -np.pi/2]
  circle_points = 60
  ```
+ 使用参数方程计算圆周上的点。
  #v(-1em)
  ```python
  for i in range(circle_points):
      angle = 2 * np.pi * i / circle_points
      x = circle_center[0] + circle_radius * np.cos(angle)
      y = circle_center[1] + circle_radius * np.sin(angle)
      z = circle_center[2]
      pose = [x, y, z] + circle_pose
  ```
+ 对每个相邻点对进行五次多项式插值。
+ 特别处理最后一点到第一点的连接，形成闭环。

=== 圆锥轨迹实现
圆锥轨迹的难点在于姿态的连续性控制：
+ 固定末端点位置。
  #v(-1em)
  ```python
  cone_apex = [0.05, 0.4, 0.25]
  cone_half_angle_deg = 30
  ```
+ 计算圆锥面上的方向向量。
  #v(-1em)
  ```python
  for i in range(num_points):
      phi = 2 * np.pi * i / num_points
      a_axis = np.array([
          np.sin(half_angle_rad) * np.cos(phi),
          np.sin(half_angle_rad) * np.sin(phi),
          np.cos(half_angle_rad)
      ])
  ```
+ 使用 `find_best_spin_for_pose` 函数搜索最优自旋角：该函数在一定范围内搜索，找到使关节角变化最小的姿态。
  #v(-1em)
  ```python
  best_angles, best_spin = find_best_spin_for_pose(
      iks, position, a_axis, prev_angles, prev_spin,
      joint_limits, num_samples=SPIN_SEARCH_SAMPLES
  )
  ```

=== 关键技术细节
+ 多解选择策略：
  + 对于每个笛卡尔位姿，逆运动学可能返回多个解（最多8个）
  + 选择策略：优先选择与前一时刻关节角距离最小的解
  + 同时考虑关节限位，过滤掉超出限制的解
    #v(-1em)
    ```python
    best_sol = None
    min_dist = float('inf')
    for sol_idx in range(angles.shape[1]):
        candidate = angles[:, sol_idx]
        # 检查关节限位
        if not all(joint_limits[j,0] <= candidate[j] <= joint_limits[j,1]
                  for j in range(6)):
            continue
        # 计算距离
        dist = np.sum((candidate - prev_angles)**2)
        if dist < min_dist:
            min_dist = dist
            best_sol = candidate
    ```
+ 过渡轨迹：
  + 在开始主轨迹前，需要从初始位置（关节角全为0）过渡到轨迹起点
  + 使用五次多项式规划过渡段，设置合适的过渡时间
  + 对于圆锥任务，使用两段过渡以避免关节角剧烈变化
+ 轨迹可视化：
  + 使用 CoppeliaSim 的 drawing object 功能绘制轨迹
  + 绿色轨迹显示末端执行器路径
  + 对于圆锥任务，额外用橙色显示关节6的轨迹

== 核心代码实现

=== 逆运动学求解器（*自行编写的*）
#v(-0.5em)
#figure(
  [```python
  class myIKSolver:
      def solve(self, p):
          d_x, d_y, d_z, alpha, beta, gamma = p
          d_1, a_2, a_3, d_4, d_5, d_6 = 0.230, 0.185, 0.170, 0.023, 0.077, 0.0855
          n_x, n_y, n_z = np.cos(gamma)* np.cos(beta), np.cos(alpha) * np.sin(gamma) + np.sin(alpha) * np.sin(beta) * np.cos(gamma), np.sin(alpha) * np.sin(gamma) - np.cos(alpha) * np.sin(beta) * np.cos(gamma)
          o_x, o_y, o_z = -np.sin(gamma) * np.cos(beta), np.cos(alpha) * np.cos(gamma) - np.sin(alpha) * np.sin(beta) * np.sin(gamma), np.sin(alpha) * np.cos(gamma) + np.cos(alpha) * np.sin(beta) * np.sin(gamma)
          a_x, a_y, a_z = np.sin(beta), - np.sin(alpha) * np.cos(beta), np.cos(alpha) * np.cos(beta)

          A = d_y - d_6 * a_y
          B = d_x - d_6 * a_x
          pm = np.array([1, -1])
          theta_1 = np.arctan2(A, B) - np.arctan2(d_4,  pm * np.sqrt(A**2 + B**2 - d_4**2))

          theta_5 = np.arcsin(a_y * np.cos(theta_1) - a_x * np.sin(theta_1))

          theta_5 = np.array([[x, np.pi - x if x > 0 else -np.pi - x] for x in theta_5]).flatten()
          theta_1 = np.array([[x, x] for x in theta_1]).flatten()

          C = n_y * np.cos(theta_1) - n_x * np.sin(theta_1)
          D = o_y * np.cos(theta_1) - o_x * np.sin(theta_1)
          theta_6 = np.arctan2(C, D) - np.arctan2(np.cos(theta_5), 0)

          E = -d_5 * (np.sin(theta_6) * (n_x * np.cos(theta_1) + n_y * np.sin(theta_1)) + np.cos(theta_6) * (o_x * np.cos(theta_1) + o_y * np.sin(theta_1))) - d_6 * (a_x * np.cos(theta_1) + a_y * np.sin(theta_1)) + d_x * np.cos(theta_1) + d_y * np.sin(theta_1)
          F = -d_1 - a_z * d_6 - d_5 * (o_z * np.cos(theta_6) + n_z * np.sin(theta_6)) + d_z
          theta_3 = np.arccos((E**2 + F**2 - a_2**2 - a_3**2) / (2 * a_2 * a_3))

          theta_3 = np.array([[x, -x] for x in theta_3]).flatten()
          theta_1 = np.array([[x, x] for x in theta_1]).flatten()
          theta_5 = np.array([[x, x] for x in theta_5]).flatten()
          theta_6 = np.array([[x, x] for x in theta_6]).flatten()
          E = np.array([[x, x] for x in E]).flatten()
          F = np.array([[x, x] for x in F]).flatten()

          G = a_2 + a_3 * np.cos(theta_3)
          H = a_3 * np.sin(theta_3)
          theta_2 = np.arctan2(G * E - H * F, G * F + H * E)

          I = (n_x * np.cos(theta_1) + n_y * np.sin(theta_1)) * np.sin(theta_6) + (o_x * np.cos(theta_1) + o_y * np.sin(theta_1)) * np.cos(theta_6)
          J = n_z * np.sin(theta_6) + o_z * np.cos(theta_6)
          theta_4 = np.arctan2(I, J) - theta_2 - theta_3

          ans = np.array([theta_1, theta_2, theta_3, theta_4, theta_5, theta_6])
          cols_with_nan = np.isnan(ans).any(axis=0)
          ans = ans[:, ~cols_with_nan]

          ans = (ans + np.pi) % (2 * np.pi) - np.pi

          ans[:, [0, 1, 2, 3]] = ans[:, [2, 3, 0, 1]]

          return ans
  ```],
)

这个逆运动学求解器是基于机械臂的DH参数推导出来的解析解。整个求解过程按照 1→5→6→3→2→4 的顺序来算，这个顺序是经过推导确定的最优顺序。核心思路是利用末端位姿反推各关节角度，因为是6自由度机械臂，理论上最多可能有8组解（每个关节的正负解组合）。
#v(-0.5em)
代码里 `pm = np.array([1, -1])` 这一步会同时计算两种可能的解，然后通过数组操作不断扩展解空间。比如求 theta_3 时用了 `[[x, -x] for x in theta_3]` 这种方式来同时考虑肘部向上和向下两种姿态。最后用 `cols_with_nan` 来过滤掉那些数学上不成立的解（比如 arccos 超出定义域导致的 NaN）。
#v(-0.5em)
有个坑是最后那句 `ans[:, [0, 1, 2, 3]] = ans[:, [2, 3, 0, 1]]`，这是因为我推导时的关节顺序和实际仿真环境中的编号不一样，需要重新排列一下。返回的 ans 是个 6×n 的矩阵，每一列代表一组可行解。

=== 五次多项式轨迹规划
#v(-0.5em)
#figure(
  [```python
  def quintic_trajectory_coefficients(p0, v0, a0, p1, v1, a1, total_time):
      T = total_time

      coeff_a0 = p0
      coeff_a1 = v0
      coeff_a2 = a0 / 2.0
      coeff_a3 = (20*p1 - 20*p0 - (8*v1 + 12*v0)*T - (3*a0 - a1)*T**2) / (2*T**3)
      coeff_a4 = (30*p0 - 30*p1 + (14*v1 + 16*v0)*T + (3*a0 - 2*a1)*T**2) / (2*T**4)
      coeff_a5 = (12*p1 - 12*p0 - (6*v1 + 6*v0)*T - (a0 - a1)*T**2) / (2*T**5)

      return [coeff_a0, coeff_a1, coeff_a2, coeff_a3, coeff_a4, coeff_a5]


  def quintic_trajectory_eval(coeffs, t):
      a0, a1, a2, a3, a4, a5 = coeffs
      return a0 + a1*t + a2*t**2 + a3*t**3 + a4*t**4 + a5*t**5
  ```],
)

五次多项式是轨迹规划里最常用的方法之一，好处是可以同时约束位置、速度和加速度。系数的计算公式看着挺吓人，其实就是把六个边界条件（起点的位置/速度/加速度，终点的位置/速度/加速度）代入多项式及其导数，解一个六元一次方程组得到的。
#v(-0.5em)
这里直接把解出来的公式硬编码了，比用矩阵求逆要快一些。计算时注意 coeff_a0 到 coeff_a5 对应的是多项式从低次到高次的系数。`quintic_trajectory_eval` 就是个简单的霍纳法则求值，给定时间 t 就能算出对应的关节角度。
#v(-0.5em)
实际使用时，一般会把起点和终点的速度、加速度都设为 0，这样可以保证在路径切换的时候不会有突变。但如果想让运动更流畅，也可以在中间点保持一定的速度，让机械臂不用完全停下来再启动。

=== 圆锥轨迹的姿态处理
#v(-0.5em)
#figure(
  [```python
  def build_rotation_matrix_from_a_axis(a_vec, spin_angle=0):
      # build rotation matrix [n, o, a] where a is the approach vector
      # spin_angle controls rotation around a axis
      a = a_vec / np.linalg.norm(a_vec)

      # choose reference perpendicular to a
      if np.abs(a[2]) < 0.9:
          ref = np.array([0, 0, 1])
      else:
          ref = np.array([1, 0, 0])

      # base n and o vectors
      n_base = np.cross(a, ref)
      n_base = n_base / np.linalg.norm(n_base)
      o_base = np.cross(a, n_base)

      # apply spin rotation around a axis
      cos_s = np.cos(spin_angle)
      sin_s = np.sin(spin_angle)
      n = cos_s * n_base + sin_s * o_base
      o = -sin_s * n_base + cos_s * o_base

      R = np.column_stack([n, o, a])
      return R


  def rotation_matrix_to_euler_zyx(R):
      beta = np.arctan2(-R[2, 0], np.sqrt(R[0, 0]**2 + R[1, 0]**2))

      if np.abs(np.cos(beta)) > 1e-6:
          alpha = np.arctan2(R[2, 1] / np.cos(beta), R[2, 2] / np.cos(beta))
          gamma = np.arctan2(R[1, 0] / np.cos(beta), R[0, 0] / np.cos(beta))
      else:
          alpha = 0
          gamma = np.arctan2(-R[0, 1], R[1, 1])

      return alpha, beta, gamma
  ```],
)

圆锥轨迹最麻烦的就是姿态控制。机械臂末端需要绕着一个固定点旋转，同时保持轴线方向始终在圆锥面上。这就需要从 approach 向量（也就是末端轴线方向）构建完整的旋转矩阵。
#v(-0.5em)
`build_rotation_matrix_from_a_axis` 函数解决的就是这个问题。给定 a 向量后，需要再找两个垂直的向量 n 和 o 来构成完整的坐标系。这里用了个小技巧：先选一个参考向量（如果 a 不接近 z 轴就用 z 轴，否则用 x 轴），然后用叉乘来构造正交基。
#v(-0.5em)
关键是 spin_angle 这个参数。即使 a 向量确定了，绕 a 轴旋转还有无穷多种可能的姿态，这就是自旋自由度。通过调整 spin_angle，可以在保持末端方向不变的情况下旋转整个末端执行器。这个自由度后面会用来优化轨迹的连续性。
#v(-0.5em)
`rotation_matrix_to_euler_zyx` 就是标准的旋转矩阵转欧拉角公式了，需要注意万向锁的情况（当 beta 接近 ±90° 时会出现奇异）。这里用了一个阈值判断来避免除零错误。

=== 最优自旋角搜索
#v(-0.5em)
#figure(
  [```python
  def find_best_spin_for_pose(iks, position, a_axis, prev_angles, prev_spin,
                               joint_limits, num_samples=20):
      # find best spin angle for smooth continuation from previous pose
      # searches wider range and returns both angles and spin

      # narrow search around previous spin for continuity
      narrow_range = np.pi / 2
      test_spins_narrow = np.linspace(prev_spin - narrow_range,
                                      prev_spin + narrow_range, num_samples)

      best_angles = None
      best_spin = prev_spin
      best_score = float('inf')

      # narrow search first
      for spin in test_spins_narrow:
          R = build_rotation_matrix_from_a_axis(a_axis, spin)
          alpha, beta, gamma = rotation_matrix_to_euler_zyx(R)
          pose = np.concatenate([position, [alpha, beta, gamma]])

          try:
              angles = iks.solve(pose)
              if angles.shape[1] == 0:
                  continue

              for sol_idx in range(angles.shape[1]):
                  candidate = angles[:, sol_idx]

                  # check limits
                  if not all(joint_limits[j, 0] <= candidate[j] <= joint_limits[j, 1]
                            for j in range(6)):
                      continue

                  # score: heavily prioritize continuity
                  dist_score = np.sum((candidate - prev_angles)**2)
                  max_score = np.max(np.abs(candidate)) * 0.05
                  score = dist_score + max_score

                  if score < best_score:
                      best_score = score
                      best_angles = candidate
                      best_spin = spin
          except:
              continue

      # if no good solution or big jump, try wider search
      if best_angles is None or np.max(np.abs(best_angles - prev_angles)) > 0.5:
          test_spins_wide = np.linspace(prev_spin - np.pi,
                                        prev_spin + np.pi, num_samples * 2)

          for spin in test_spins_wide:
              R = build_rotation_matrix_from_a_axis(a_axis, spin)
              alpha, beta, gamma = rotation_matrix_to_euler_zyx(R)
              pose = np.concatenate([position, [alpha, beta, gamma]])

              try:
                  angles = iks.solve(pose)
                  if angles.shape[1] == 0:
                      continue

                  for sol_idx in range(angles.shape[1]):
                      candidate = angles[:, sol_idx]

                      if not all(joint_limits[j, 0] <= candidate[j] <= joint_limits[j, 1]
                                for j in range(6)):
                          continue

                      dist_score = np.sum((candidate - prev_angles)**2)
                      max_score = np.max(np.abs(candidate)) * 0.05
                      score = dist_score + max_score

                      if score < best_score:
                          best_score = score
                          best_angles = candidate
                          best_spin = spin
              except:
                  continue

      return best_angles, best_spin
  ```],
)

这个函数是整个圆锥轨迹能够平滑运动的核心。问题在于，对于圆锥面上的每个点，虽然 approach 向量是固定的，但绕这个向量旋转（spin）还有一个自由度。如果随便选一个 spin 角度，虽然末端方向对了，但关节角可能会突然跳变一大截，导致运动不连续。
#v(-0.5em)
搜索策略是两阶段的。先在上一次 spin 角附近搜索（±90°范围），这是基于连续性假设——相邻两个点的最优 spin 角应该比较接近。如果这个窄范围搜索失败了，或者找到的解跳变太大（超过 0.5 弧度），就扩大到 ±180° 全范围搜索。
#v(-0.5em)
评分函数设计也有讲究：`dist_score` 是关节角变化的平方和，这个权重最大，保证连续性优先；`max_score` 是关节角绝对值的惩罚，避免选择那种关节角特别极端的解。两个分数加起来，分数越低越好。
#v(-0.5em)
每个 spin 角度都会生成一个位姿，然后调用逆运动学求解器得到多组解，再逐个检查关节限位，最后选出综合得分最好的那组。整个过程是个暴力搜索，但因为只在一维空间搜索（spin 角），计算量还能接受。实测下来，24 个采样点基本够用，既能保证找到好的解，又不会太慢。

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

== 实验内容与原理


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

=== ZJU-I型机械臂的雅可比矩阵



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


= 核心代码实现

== Jacobian矩阵计算（C++核心）

这是速度控制的#reder[核心计算模块]，基于DH参数推导的解析公式计算6×6几何Jacobian矩阵。

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

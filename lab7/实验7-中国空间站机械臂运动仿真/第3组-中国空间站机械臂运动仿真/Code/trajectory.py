"""
轨迹规划模块: 使用五次多项式插值生成平滑的关节空间轨迹
"""
import numpy as np
from numpy import pi
from ik_solver import inverse_kinematics


class Trajectory:
    """
    五次多项式轨迹规划器
    在关键点之间生成平滑的五次多项式轨迹,保证位置、速度和加速度连续
    """

    def __init__(self, waypoints, time_points):
        """
        初始化轨迹规划器
        Args:
            waypoints: 关键点位置列表,每个元素为7维关节角度数组
            time_points: 关键点对应的时间列表
        """
        self.waypoints = np.array(waypoints)
        self.time_points = np.array(time_points)
        self.num_waypoints = len(waypoints)
        self._compute_waypoint_velocities_and_accelerations()
        self._compute_polynomial_coefficients()

    def GetCurvePosition(self, time):
        """
        获取指定时刻的关节位置
        Args:
            time: 查询时间
        Returns:
            7维关节角度数组
        """
        # 查找time所在的时间段
        for i in range(self.num_waypoints - 1):
            if time < self.time_points[i + 1]:
                # 计算该时间段的五次多项式值
                positions = []
                for joint_idx in range(7):
                    coeffs = self.polynomial_coefficients[i, :, joint_idx]
                    position = np.dot(coeffs, [time**5, time**4, time**3, time**2, time, 1])
                    positions.append(position)
                return positions

        # 超出时间范围,返回最后一个关键点
        return self.waypoints[self.num_waypoints - 1]

    def _compute_polynomial_coefficients(self):
        """计算所有时间段的多项式系数"""
        self.polynomial_coefficients = []
        for i in range(self.num_waypoints - 1):
            self._compute_quintic_polynomial_segment(i)
        # 转换为NumPy数组以支持高级索引
        self.polynomial_coefficients = np.array(self.polynomial_coefficients)

    def _compute_quintic_polynomial_segment(self, segment_idx):
        """
        计算单个时间段的五次多项式系数
        五次多项式形式: q(t) = a5*t^5 + a4*t^4 + a3*t^3 + a2*t^2 + a1*t + a0
        边界条件: 起点和终点的位置、速度、加速度
        Args:
            segment_idx: 时间段索引
        """
        t_start = self.time_points[segment_idx]
        t_end = self.time_points[segment_idx + 1]

        q_start = self.waypoints[segment_idx]
        q_end = self.waypoints[segment_idx + 1]

        v_start = self.velocities[segment_idx]
        v_end = self.velocities[segment_idx + 1]

        a_start = self.accelerations[segment_idx]
        a_end = self.accelerations[segment_idx + 1]

        # 构建系数矩阵 A*x = b
        # 6个约束条件:起点和终点的位置、速度、加速度
        coefficient_matrix = np.array([
            [t_start**5,      t_start**4,     t_start**3,     t_start**2,    t_start, 1],  # 起点位置
            [5 * t_start**4,  4 * t_start**3, 3 * t_start**2, 2 * t_start,   1,       0],  # 起点速度
            [20 * t_start**3, 12 * t_start**2, 6 * t_start,   2,             0,       0],  # 起点加速度
            [t_end**5,        t_end**4,       t_end**3,       t_end**2,      t_end,   1],  # 终点位置
            [5 * t_end**4,    4 * t_end**3,   3 * t_end**2,   2 * t_end,     1,       0],  # 终点速度
            [20 * t_end**3,   12 * t_end**2,  6 * t_end,      2,             0,       0],  # 终点加速度
        ])

        boundary_conditions = np.array([q_start, v_start, a_start, q_end, v_end, a_end])

        # 求解多项式系数
        coefficients = np.linalg.solve(coefficient_matrix, boundary_conditions)
        self.polynomial_coefficients.append(coefficients)

    def _compute_waypoint_velocities_and_accelerations(self):
        """
        计算关键点处的速度和加速度
        使用中心差分法估算中间点的速度和加速度
        起点和终点的速度和加速度设为0
        """
        self.velocities = []
        self.accelerations = []

        # 计算速度
        for i in range(self.num_waypoints):
            if i == 0 or i == self.num_waypoints - 1:
                # 起点和终点速度为0
                velocity = np.array([0, 0, 0, 0, 0, 0, 0])
            else:
                # 中心差分法估算速度
                delta_q = self.waypoints[i + 1] - self.waypoints[i - 1]
                delta_t = self.time_points[i + 1] - self.time_points[i - 1]
                velocity = delta_q / delta_t
            self.velocities.append(velocity)

        # 计算加速度
        for i in range(self.num_waypoints):
            if i == 0 or i == self.num_waypoints - 1:
                # 起点和终点加速度为0
                acceleration = np.array([0, 0, 0, 0, 0, 0, 0])
            else:
                # 中心差分法估算加速度
                delta_v = self.velocities[i + 1] - self.velocities[i - 1]
                delta_t = self.time_points[i + 1] - self.time_points[i - 1]
                acceleration = delta_v / delta_t
            self.accelerations.append(acceleration)

    @staticmethod
    def get_straight_line_position(start_pos, start_x1, end_pos, end_x1, current_time, total_time):
        """
        生成直线轨迹(笛卡尔空间插值,然后求逆运动学)
        Args:
            start_pos: 起点位置
            start_x1: 起点第一个关节角度
            end_pos: 终点位置
            end_x1: 终点第一个关节角度
            current_time: 当前时间
            total_time: 总时间
        Returns:
            关节角度解
        """
        if current_time < total_time:
            # 线性插值
            interpolation_ratio = current_time / total_time
            interpolated_pos = start_pos * (1 - interpolation_ratio) + end_pos * interpolation_ratio
            interpolated_x1 = start_x1 * (1 - interpolation_ratio) + end_x1 * interpolation_ratio
            ik_solutions = inverse_kinematics(interpolated_pos, interpolated_x1, base_type='left')
        else:
            ik_solutions = inverse_kinematics(end_pos, end_x1, base_type='left')

        # 处理逆运动学解:角度归一化和符号调整
        for solution in ik_solutions:
            for i in range(len(solution)):
                # 角度归一化到[-π, π]
                if solution[i] > np.pi:
                    solution[i] -= np.pi * 2
                if solution[i] < -np.pi:
                    solution[i] += np.pi * 2

            # 关节符号调整
            solution[1] = -solution[1]
            solution[2] = -solution[2]
            solution[3] = -solution[3]
            solution[5] = -solution[5]
            solution[6] = -solution[6]
            print(solution)

        # 选择第6个解
        return ik_solutions[5]


"""
7自由度机械臂逆运动学求解器
"""
import numpy as np
from numpy import cos, sin, arcsin, arccos, arctan2, sqrt, pi


def calc_angle2and6(rotation_matrix, x, y, z, angle1):
    """计算关节2和关节6"""
    a1 = rotation_matrix[0, 2] * sin(angle1) - rotation_matrix[1, 2] * cos(angle1)
    b1 = -rotation_matrix[2, 2]
    a2 = x * sin(angle1) - y * cos(angle1)
    b2 = 120 - z
    a = a2 - 120 * a1
    b = b2 - 120 * b1

    angle2_1 = arctan2(-300, sqrt(a**2 + b**2 - 300**2)) - arctan2(a, b)
    angle2_2 = arctan2(-300, -sqrt(a**2 + b**2 - 300**2)) - arctan2(a, b)

    angle6_1 = -arcsin(a1 * cos(angle2_1) + b1 * sin(angle2_1))
    angle6_3 = np.pi - angle6_1
    angle6_2 = -arcsin(a1 * cos(angle2_2) + b1 * sin(angle2_2))
    angle6_4 = np.pi - angle6_2

    return angle2_1, angle2_2, angle6_1, angle6_2, angle6_3, angle6_4


def calc_angle7(rotation_matrix, angle1, angle2, angle6):
    """计算关节7"""
    sin_value = (rotation_matrix[0, 1] * cos(angle2) * sin(angle1) -
                 rotation_matrix[1, 1] * cos(angle1) * cos(angle2) -
                 rotation_matrix[2, 1] * sin(angle2)) / cos(angle6)
    cos_value = -((rotation_matrix[0, 0] * cos(angle2) * sin(angle1) -
                   rotation_matrix[1, 0] * cos(angle1) * cos(angle2) -
                   rotation_matrix[2, 0] * sin(angle2))) / cos(angle6)
    return arctan2(sin_value, cos_value)


def calc_angle345(rotation_matrix, angle1, angle6, angle7, base_type='left'):
    """
    计算关节3+4+5的角度和
    Args:
        base_type: 'left'或'right',指定基座类型
    """
    if base_type == 'left':
        m = -rotation_matrix[0, 0] * cos(angle1) - rotation_matrix[1, 0] * sin(angle1)
        b = cos(angle7) * sin(angle6)
        a = -sin(angle7)
        return arcsin(m / sqrt(a**2 + b**2)) - arctan2(a, b)
    else:  # right
        k1 = -rotation_matrix[0, 1] * cos(angle1) - rotation_matrix[1, 1] * sin(angle1)
        k2 = -rotation_matrix[0, 0] * cos(angle1) - rotation_matrix[1, 0] * sin(angle1)
        sin_345 = (cos(angle7) * k2 - sin(angle7) * k1) / sin(angle6)
        cos_345 = -sin(angle7) * k2 - cos(angle7) * k1
        return arctan2(sin_345, cos_345)


def calc_angle34(x, y, z, angle1, angle2, angle6, angle_345, base_type='left'):
    """
    计算关节3和关节4
    Args:
        base_type: 'left'或'right'，指定基座类型
    """
    if base_type == 'left':
        m1 = (120 * cos(angle_345) * cos(angle6) - 100 * sin(angle_345) +
              (z - 120) * cos(angle2) + x * sin(angle1) * sin(angle2) -
              y * cos(angle1) * sin(angle2)) / 400

        m2 = (120 * sin(angle_345) * cos(angle6) + 100 * cos(angle_345) -
              x * cos(angle1) - y * sin(angle1) - 100) / 400

        angle4_1 = arccos(1 - (m1**2 + m2**2) / 2)
        angle4_2 = -angle4_1

        angle3_1 = arctan2(((1 + cos(angle4_1)) * m1 + sin(angle4_1) * m2) / (2 * sin(angle4_1)),
                          ((1 - cos(angle4_1)) * m1 - sin(angle4_1) * m2) / (2 * (1 - cos(angle4_1))))
        angle3_2 = arctan2(((1 + cos(angle4_2)) * m1 + sin(angle4_2) * m2) / (2 * sin(angle4_2)),
                          ((1 - cos(angle4_2)) * m1 - sin(angle4_2) * m2) / (2 * (1 - cos(angle4_2))))
    else:  # right
        m1 = (120 * cos(angle_345) * cos(angle6) + 100 * sin(angle_345) +
              (z - 120) * cos(angle2) + x * sin(angle1) * sin(angle2) -
              y * cos(angle1) * sin(angle2)) / 400

        m2 = (120 * sin(angle_345) * cos(angle6) - 100 * cos(angle_345) -
              x * cos(angle1) - y * sin(angle1) + 100) / 400

        gamma = arctan2(m1, -m2)

        if sin(gamma) > 1e-10:
            angle4_1 = 2 * arcsin(m1 / 2 / sin(gamma))
        else:
            angle4_1 = 2 * arcsin(-m2 / 2 / cos(gamma))

        angle4_2 = 2 * np.pi - angle4_1
        angle3_1 = gamma - angle4_1 / 2
        angle3_2 = gamma - angle4_2 / 2

    angle5_1 = angle_345 - angle3_1 - angle4_1
    angle5_2 = angle_345 - angle3_2 - angle4_2

    return angle3_1, angle4_1, angle5_1, angle3_2, angle4_2, angle5_2


def solve(target_transform, angle1, base_type='left'):
    """
    求解逆运动学的8组可能解
    Args:
        target_transform: 4x4目标变换矩阵
        angle1: 关节1角度
        base_type: 'left'或'right',指定基座类型
    """
    x = target_transform[0, 3]
    y = target_transform[1, 3]
    z = target_transform[2, 3]
    rotation_matrix = target_transform[0:3, 0:3]

    # 计算各关节候选解
    a2_1, a2_2, a6_1, a6_2, a6_3, a6_4 = calc_angle2and6(rotation_matrix, x, y, z, angle1)
    a7_1 = calc_angle7(rotation_matrix, angle1, a2_1, a6_1)
    a7_2 = calc_angle7(rotation_matrix, angle1, a2_2, a6_2)
    a7_3 = calc_angle7(rotation_matrix, angle1, a2_1, a6_3)
    a7_4 = calc_angle7(rotation_matrix, angle1, a2_2, a6_4)

    a345_1 = calc_angle345(rotation_matrix, angle1, a6_1, a7_1, base_type)
    a345_2 = calc_angle345(rotation_matrix, angle1, a6_2, a7_2, base_type)
    a345_3 = calc_angle345(rotation_matrix, angle1, a6_3, a7_3, base_type)
    a345_4 = calc_angle345(rotation_matrix, angle1, a6_4, a7_4, base_type)

    a3_1, a4_1, a5_1, a3_5, a4_5, a5_5 = calc_angle34(x, y, z, angle1, a2_1, a6_1, a345_1, base_type)
    a3_2, a4_2, a5_2, a3_6, a4_6, a5_6 = calc_angle34(x, y, z, angle1, a2_2, a6_2, a345_2, base_type)
    a3_3, a4_3, a5_3, a3_7, a4_7, a5_7 = calc_angle34(x, y, z, angle1, a2_1, a6_3, a345_3, base_type)
    a3_4, a4_4, a5_4, a3_8, a4_8, a5_8 = calc_angle34(x, y, z, angle1, a2_2, a6_4, a345_4, base_type)

    # 组合8组解
    if base_type == 'right':
        # 右基座需要符号调整
        solutions = [
            [angle1, -a2_1, a3_1, -a4_1, a5_1, -a6_1, a7_1],
            [angle1, -a2_1, a3_5, -a4_5, a5_5, -a6_1, a7_1],
            [angle1, -a2_1, a3_3, -a4_3, a5_3, -a6_3, a7_3],
            [angle1, -a2_1, a3_7, -a4_7, a5_7, -a6_3, a7_3],
            [angle1, -a2_2, a3_2, -a4_2, a5_2, -a6_2, a7_2],
            [angle1, -a2_2, a3_6, -a4_6, a5_6, -a6_2, a7_2],
            [angle1, -a2_2, a3_4, -a4_4, a5_4, -a6_4, a7_4],
            [angle1, -a2_2, a3_8, -a4_8, a5_8, -a6_4, a7_4]
        ]
    else:  # left
        solutions = [
            [angle1, a2_1, a3_1, a4_1, a5_1, a6_1, a7_1],
            [angle1, a2_1, a3_5, a4_5, a5_5, a6_1, a7_1],
            [angle1, a2_1, a3_3, a4_3, a5_3, a6_3, a7_3],
            [angle1, a2_1, a3_7, a4_7, a5_7, a6_3, a7_3],
            [angle1, a2_2, a3_2, a4_2, a5_2, a6_2, a7_2],
            [angle1, a2_2, a3_6, a4_6, a5_6, a6_2, a7_2],
            [angle1, a2_2, a3_4, a4_4, a5_4, a6_4, a7_4],
            [angle1, a2_2, a3_8, a4_8, a5_8, a6_4, a7_4]
        ]

    return solutions


def euler_to_rotation_matrix(roll, pitch, yaw):
    """欧拉角转旋转矩阵(ZYX顺序)"""
    rx = np.array([[1, 0, 0],
                   [0, np.cos(roll), -np.sin(roll)],
                   [0, np.sin(roll), np.cos(roll)]])

    ry = np.array([[np.cos(pitch), 0, np.sin(pitch)],
                   [0, 1, 0],
                   [-np.sin(pitch), 0, np.cos(pitch)]])

    rz = np.array([[np.cos(yaw), -np.sin(yaw), 0],
                   [np.sin(yaw), np.cos(yaw), 0],
                   [0, 0, 1]])

    return np.dot(rx, np.dot(ry, rz))


def inverse_kinematics(position_and_orientation, angle1, base_type='left'):
    """
    逆运动学主入口函数
    Args:
        position_and_orientation: [x, y, z, roll, pitch, yaw]目标位姿
        angle1: 关节1角度
        base_type: 'left'或'right',指定基座类型
    Returns:
        8组可能的关节角度解
    """
    position = np.array(position_and_orientation[:3])
    rotation_matrix = euler_to_rotation_matrix(*position_and_orientation[3:])

    transform = np.vstack((np.hstack((rotation_matrix, position[:, None])),
                          np.array([0, 0, 0, 1])))

    return solve(transform, angle1, base_type)


if __name__ == "__main__":
    # 测试右基座
    print("右基座测试")
    test_pose_right = [0, -600, 20, pi, 0, pi/2]
    solutions_right = inverse_kinematics(test_pose_right, 0, base_type='right')

    print("\n右基座逆运动学解:")
    for idx, sol in enumerate(solutions_right, 1):
        # 角度归一化
        sol = [(s - 2*pi if s > pi else s + 2*pi if s < -pi else s) for s in sol]
        print(f"Solution {idx}: {sol}, sum={sum(abs(a) for a in sol):.4f}")

    # 测试左基座
    print("\n左基座测试")
    test_pose_left = [120, 400, -100, pi/2, 0, pi/2]
    solutions_left = inverse_kinematics(test_pose_left, 2/3*pi + 4.92659305 - 2*pi, base_type='left')

    print("\n左基座逆运动学解:")
    for idx, sol in enumerate(solutions_left, 1):
        sol = [(s - 2*pi if s > pi else s + 2*pi if s < -pi else s) for s in sol]
        print(f"Solution {idx}: {sol}, sum={sum(abs(a) for a in sol):.4f}")

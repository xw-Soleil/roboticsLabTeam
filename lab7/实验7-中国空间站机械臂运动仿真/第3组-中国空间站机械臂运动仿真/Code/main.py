"""
空间机器人仿真主程序 main.py
"""
import time
import numpy as np
from math import pi
from coppeliasim_zmqremoteapi_client import RemoteAPIClient
from trajectory import Trajectory
from base_switcher import change_base_LtoR, change_base_RtoL

NUM_JOINTS = 7
GRAPH_STREAM_COUNT = 7
LOW_PASS_FILTER_ALPHA = 0.05
SIMULATION_DURATION = 10  # 秒
PHASE_1_END = 5  # 第一阶段结束时间
PHASE_2_END = 6  # 第二阶段结束时间
OBJECT_MATRIX_START_INDEX = 16
OBJECT_MATRIX_END_INDEX = 30

# 仿真速度控制
SIMULATION_TIME_STEP = 0.05  # 仿真时间步长(秒)
REAL_TIME_DELAY = 0.025  # 每步后的实际延迟(秒)

print('Program started')

# 初始化CoppeliaSim连接
client = RemoteAPIClient()
sim = client.getObject('sim')

# 配置仿真参数
# 当仿真未运行时，ZMQ消息处理速度较慢，设置为全速运行
default_idle_fps = sim.getInt32Param(sim.intparam_idle_fps)
sim.setInt32Param(sim.intparam_idle_fps, 0)

response = client.call('sim.setStepping', [True])
print(f'Response from sim.setStepping: {response}')
client.setStepping(True)
sim.startSimulation()

# 设置仿真时间步长
sim.setFloatParam(sim.floatparam_simulation_time_step, SIMULATION_TIME_STEP)

# 获取关节对象句柄
joints = [0] * NUM_JOINTS
l_joint1 = joints[0] = sim.getObject('./L_Joint1')
l_joint2 = joints[1] = sim.getObject('./L_Joint2')
l_joint3 = joints[2] = sim.getObject('./L_Joint3')
joint4   = joints[3] = sim.getObject('./Joint4')
r_joint3 = joints[4] = sim.getObject('./R_Joint3')
r_joint2 = joints[5] = sim.getObject('./R_Joint2')
r_joint1 = joints[6] = sim.getObject('./R_Joint1')

# 存储对象变换矩阵
matrix_left_to_right = []
matrix_right_to_left = []
for i in range(OBJECT_MATRIX_START_INDEX, OBJECT_MATRIX_END_INDEX):
    matrix_left_to_right.append(sim.getObjectMatrix(i, i + 1))
for i in range(OBJECT_MATRIX_START_INDEX, OBJECT_MATRIX_END_INDEX):
    matrix_right_to_left.append(sim.getObjectMatrix(i + 1, i))

# 配置速度图表
graph = sim.getObject('/Graph')
velocity_stream_handles = [0] * GRAPH_STREAM_COUNT
velocity_stream_handles[0] = sim.addGraphStream(graph, 'L_joint1 velocity', 'deg/s', 0, [1, 0, 0])
velocity_stream_handles[1] = sim.addGraphStream(graph, 'L_joint2 velocity', 'deg/s', 0, [0, 1, 0])
velocity_stream_handles[2] = sim.addGraphStream(graph, 'L_joint3 velocity', 'deg/s', 0, [0, 0, 1])
velocity_stream_handles[3] = sim.addGraphStream(graph, 'joint4 velocity', 'deg/s', 0, [1, 1, 0])
velocity_stream_handles[4] = sim.addGraphStream(graph, 'R_joint1 velocity', 'deg/s', 0, [1, 0, 1])
velocity_stream_handles[5] = sim.addGraphStream(graph, 'R_joint2 velocity', 'deg/s', 0, [0, 1, 1])
velocity_stream_handles[6] = sim.addGraphStream(graph, 'R_joint3 velocity', 'deg/s', 0, [1, 1, 1])


def low_pass_filter(new_value, prev_filtered_value, alpha):
    """
    低通滤波器，平滑速度信号
    Args:
        new_value: 新测量值
        prev_filtered_value: 上一次滤波后的值
        alpha: 滤波系数(0-1)，值越小滤波效果越强
    """
    return alpha * new_value + (1 - alpha) * prev_filtered_value


filtered_velocities = [0.0] * NUM_JOINTS 

def set_joint_positions(sim, joint_positions, base_type):
    """
    设置关节位置
    Args:
        sim: CoppeliaSim仿真对象
        joint_positions: 7个关节的位置数组
        base_type: 基座类型,'B'表示右基座,'A'表示左基座
    """
    if base_type == 'B':  # 右基座为参考系
        sim.setJointPosition(r_joint1, joint_positions[0])
        sim.setJointPosition(r_joint2, joint_positions[1])
        sim.setJointPosition(r_joint3, joint_positions[2])
        sim.setJointPosition(joint4,   joint_positions[3])
        sim.setJointPosition(l_joint3, joint_positions[4])
        sim.setJointPosition(l_joint2, joint_positions[5])
        sim.setJointPosition(l_joint1, joint_positions[6])
    elif base_type == 'A':  # 左基座为参考系
        sim.setJointPosition(l_joint1, joint_positions[0])
        sim.setJointPosition(l_joint2, joint_positions[1])
        sim.setJointPosition(l_joint3, joint_positions[2])
        sim.setJointPosition(joint4,   joint_positions[3])
        sim.setJointPosition(r_joint3, joint_positions[4])
        sim.setJointPosition(r_joint2, joint_positions[5])
        sim.setJointPosition(r_joint1, joint_positions[6])


# 预定义关键姿态
pose_initial = np.array([0, 0, 0, 0, 0, 0, 0])  # 初始姿态

# 第一阶段姿态(右基座为参考)
pose_phase1_waypoint1 = np.array([0, 0.5, 0.5, 0, -0.1715480681505778, -0.05697852345543221, 0])
pose_phase1_waypoint2 = np.array([0, 1.9, 0.43322658049096774, -1.539541238295402, -1.168574248127406, -1.0471975511965979, 0])
pose_phase1_final = np.array([0, 2.094395102393195, 0.4336038030273939, -1.539541238295402, -1.1684476122669976, -1.0471975511965979, 0])

# 第二阶段姿态(左基座为参考)
pose_phase2_initial = np.array([0, 1.0471975511965979, 1.1684476122669976, 1.539541238295402, -0.4336038030273939, -2.094395102393195, 0])
pose_phase2_waypoint = np.array([0, -2.790686821121354, -1.2549397494525802, -1.2424883197633365, 2.214960911168772, -3.141592653589793, 2.790686821121354])
pose_phase2_final = np.array([0, -2.790686821121354, -1.2220722576756144, -1.2252700800130993, 2.2650466426959754, -3.141592653589793, 2.790686821121354])


# 主仿真循环
is_base_switched = False  # 基座切换标志

while (current_time := sim.getSimulationTime()) < SIMULATION_DURATION:
    # 获取并滤波关节速度
    current_velocities = [
        sim.getJointVelocity(l_joint1),
        sim.getJointVelocity(l_joint2),
        sim.getJointVelocity(l_joint3),
        sim.getJointVelocity(joint4),
        sim.getJointVelocity(r_joint1),
        sim.getJointVelocity(r_joint2),
        sim.getJointVelocity(r_joint3)
    ]

    # 应用低通滤波
    for i in range(NUM_JOINTS):
        filtered_velocities[i] = low_pass_filter(
            current_velocities[i],
            filtered_velocities[i],
            LOW_PASS_FILTER_ALPHA
        )

    # 转换速度图表为度/秒
    for i, velocity in enumerate(filtered_velocities):
        sim.setGraphStreamValue(graph, velocity_stream_handles[i], 180 * velocity / pi)

    # 第一阶段: 从初始位置移动到目标位置(使用右基座)
    if current_time < PHASE_1_END:
        if not is_base_switched:
            # 切换到右基座为参考系
            change_base_LtoR(sim)
            is_base_switched = True

            # 保存当前关节位置
            current_positions = [0.0] * NUM_JOINTS
            for i in range(NUM_JOINTS):
                current_positions[i] = sim.getJointPosition(joints[i])

            # 更新对象变换矩阵
            for i in range(OBJECT_MATRIX_START_INDEX, OBJECT_MATRIX_END_INDEX):
                sim.setObjectMatrix(i + 1, i, matrix_right_to_left[i - OBJECT_MATRIX_START_INDEX])
                if i % 2 == 1:
                    sim.setJointPosition(i, -current_positions[(i - 17) // 2])

        # 生成轨迹并获取当前位置
        trajectory = Trajectory(
            [pose_initial, pose_phase1_waypoint1, pose_phase1_waypoint2, pose_phase1_final],
            [0, 1, 4, 5]
        )
        joint_positions = trajectory.GetCurvePosition(current_time)
        set_joint_positions(sim, joint_positions, "B")

    # 第二阶段: 保持姿态
    elif current_time < PHASE_2_END:
        joint_positions = pose_phase1_final
        set_joint_positions(sim, joint_positions, "B")

    # 第三阶段: 返回最终姿态(使用左基座)
    elif current_time < SIMULATION_DURATION + 1:
        if is_base_switched:
            # 切换回左基座为参考系
            change_base_RtoL(sim)
            is_base_switched = False

            # 保存当前关节位置
            current_positions = [0.0] * NUM_JOINTS
            for i in range(NUM_JOINTS):
                current_positions[i] = sim.getJointPosition(joints[i])

            # 更新对象变换矩阵
            for i in range(OBJECT_MATRIX_START_INDEX, OBJECT_MATRIX_END_INDEX):
                sim.setObjectMatrix(i + 1, i, matrix_right_to_left[i - OBJECT_MATRIX_START_INDEX])
                if i % 2 == 1:
                    sim.setJointPosition(i, -current_positions[(i - 17) // 2])

        # 生成返回轨迹
        trajectory = Trajectory(
            [pose_phase2_initial, pose_phase2_waypoint, pose_phase2_final],
            [6, 9, 10]
        )
        joint_positions = trajectory.GetCurvePosition(current_time)
        set_joint_positions(sim, joint_positions, "A")

    # 日志输出
    log_message = f'Simulation time: {current_time:.2f} s'
    print(log_message)
    sim.addLog(sim.verbosity_scriptinfos, log_message)
    client.step()

    # 添加实时延迟以减慢仿真速度
    if REAL_TIME_DELAY > 0:
        time.sleep(REAL_TIME_DELAY)  

# 等待仿真稳定
time.sleep(1)

# 停止仿真
sim.stopSimulation()

# 恢复原始空闲循环频率
sim.setInt32Param(sim.intparam_idle_fps, default_idle_fps)

print('Program ended')

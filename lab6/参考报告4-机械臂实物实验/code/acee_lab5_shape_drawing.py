from Robot.Robot import Robot
import numpy as np
import until
import time
from myIK import IKSolver

# ============ 参数配置 ============
TASK_MODE = 3          # 1=画正方形, 2=画圆, 3=圆锥运动
COM_PORT = 'COM5'      # 串口号
BAUD_RATE = 250000     # 波特率
T = 0.02               # 控制周期 20ms

# 圆锥运动参数
CONE_POINTS = 360           # 圆锥轨迹采样点数
CONE_TIME_PER_SEG = 0.04    # 每段时间（秒）
CONE_HALF_ANGLE_DEG = 30    # 圆锥半角（度）, 即锥角60度的一半


def test():
    q_array = []
    r = Robot(com=COM_PORT, baud=BAUD_RATE)
    r.connect()
    
    iks = IKSolver()
    
    # 初始位置（零位）
    q0 = np.zeros(6)
    
    # 末端姿态（朝下）- 用于正方形和圆形
    orientation = [np.pi, 0, -np.pi/2]
    
    if TASK_MODE == 1:
        # ========== 正方形参数 ==========
        print("任务: 画正方形")
        center = np.array([0.25, 0.0, 0.35])
        side = 0.10  # 边长10cm
        half = side / 2.0
        
        # 四个角点位置
        corners_pos = [
            np.array([center[0] - half, center[1] - half, center[2]]),
            np.array([center[0] + half, center[1] - half, center[2]]),
            np.array([center[0] + half, center[1] + half, center[2]]),
            np.array([center[0] - half, center[1] + half, center[2]])
        ]
        
        # 计算四个角点的关节角度
        corner_angles = []
        for i, pos in enumerate(corners_pos):
            pose = np.concatenate([pos, orientation])
            angles = iks.solve(pose)
            q = angles[:, 2] if angles.shape[1] > 2 else angles[:, 0]
            corner_angles.append(q)
        
        # 时间参数
        t_transition = 3.0    # 过渡时间
        t_per_edge = 1.5      # 每条边时间
        t_total = t_transition + t_per_edge * 4 + 0.5
        
        # 规划轨迹
        planner_trans = until.quinticCurvePlanning(
            q0, corner_angles[0], np.zeros(6), np.zeros(6), t_transition
        )
        
        edge_planners = []
        for i in range(4):
            next_i = (i + 1) % 4
            planner = until.quinticCurvePlanning(
                corner_angles[i], corner_angles[next_i],
                np.zeros(6), np.zeros(6), t_per_edge
            )
            edge_planners.append(planner)
        
        t_points = {
            'trans': (0, t_transition),
            'edge0': (t_transition, t_transition + t_per_edge),
            'edge1': (t_transition + t_per_edge, t_transition + 2*t_per_edge),
            'edge2': (t_transition + 2*t_per_edge, t_transition + 3*t_per_edge),
            'edge3': (t_transition + 3*t_per_edge, t_transition + 4*t_per_edge)
        }
        
        # 执行
        print(f"\n总时间: {t_total}s")
        print("机械臂回零位...")
        r.go_home()
        time.sleep(1)
        
        print("开始执行轨迹...")
        t = 0
        
        while True:
            start_time = time.time()
            
            if t >= t_total:
                print('轨迹执行完成')
                r.go_home()
                break
            
            q = None
            
            if t_points['trans'][0] <= t < t_points['trans'][1]:
                q = until.quinticCurveExcute(planner_trans, t - t_points['trans'][0])
            elif t_points['edge0'][0] <= t < t_points['edge0'][1]:
                q = until.quinticCurveExcute(edge_planners[0], t - t_points['edge0'][0])
            elif t_points['edge1'][0] <= t < t_points['edge1'][1]:
                q = until.quinticCurveExcute(edge_planners[1], t - t_points['edge1'][0])
            elif t_points['edge2'][0] <= t < t_points['edge2'][1]:
                q = until.quinticCurveExcute(edge_planners[2], t - t_points['edge2'][0])
            elif t_points['edge3'][0] <= t < t_points['edge3'][1]:
                q = until.quinticCurveExcute(edge_planners[3], t - t_points['edge3'][0])
            
            if q is not None:
                r.syncMove(np.reshape(q, (6, 1)))
            
            t = t + T
            
            end_time = time.time()
            spend_time = end_time - start_time
            if spend_time < T:
                time.sleep(T - spend_time)
            else:
                print("timeout!")
            
            q_array.append(r.syncFeedback())
        
    elif TASK_MODE == 2:
        # ========== 圆形参数 ==========
        print("任务: 画圆")
        center = np.array([0.25, 0.0, 0.35])
        radius = 0.05
        num_points = 180
        
        circle_angles = []
        for i in range(num_points + 1):
            theta = 2 * np.pi * i / num_points
            pos = np.array([
                center[0] + radius * np.cos(theta),
                center[1] + radius * np.sin(theta),
                center[2]
            ])
            pose = np.concatenate([pos, orientation])
            angles = iks.solve(pose)
            q = angles[:, 2] if angles.shape[1] > 2 else angles[:, 0]
            circle_angles.append(q)
        
        t_transition = 3.0
        t_per_seg = 0.04
        t_circle = t_per_seg * num_points
        t_total = t_transition + t_circle + 0.5
        
        planner_trans = until.quinticCurvePlanning(
            q0, circle_angles[0], np.zeros(6), np.zeros(6), t_transition
        )
        
        circle_planners = []
        for i in range(num_points):
            planner = until.quinticCurvePlanning(
                circle_angles[i], circle_angles[i+1],
                np.zeros(6), np.zeros(6), t_per_seg
            )
            circle_planners.append(planner)
        
        # 执行
        print(f"\n总时间: {t_total}s")
        print("机械臂回零位...")
        r.go_home()
        time.sleep(1)
        
        print("开始执行轨迹...")
        t = 0
        
        while True:
            start_time = time.time()
            
            if t >= t_total:
                print('轨迹执行完成')
                r.go_home()
                break
            
            q = None
            
            if t < t_transition:
                q = until.quinticCurveExcute(planner_trans, t)
            else:
                t_local = t - t_transition
                if t_local < t_circle:
                    seg_idx = int(t_local / t_per_seg)
                    seg_idx = min(seg_idx, num_points - 1)
                    seg_t = t_local - seg_idx * t_per_seg
                    q = until.quinticCurveExcute(circle_planners[seg_idx], seg_t)
            
            if q is not None:
                r.syncMove(np.reshape(q, (6, 1)))
            
            t = t + T
            
            end_time = time.time()
            spend_time = end_time - start_time
            if spend_time < T:
                time.sleep(T - spend_time)
            else:
                print("timeout!")
            
            q_array.append(r.syncFeedback())
    
    elif TASK_MODE == 3:
        # ========== 圆锥运动 ==========
        print("任务: 圆锥运动")
        print(f"  采样点数: {CONE_POINTS}")
        
        # 圆锥顶点
        cone_tip = np.array([0.26, -0.1, 0.35])
        cone_half_angle = CONE_HALF_ANGLE_DEG * np.pi / 180
        
        # 生成圆锥轨迹点的关节角度
        cone_angles = []
        
        for i in range(CONE_POINTS + 1):
            phi = 2 * np.pi * i / CONE_POINTS  # 绕z轴旋转的角度
            phi_deg = phi * 180 / np.pi
            
            # 计算欧拉角 (alpha, beta, gamma) - 基础姿态朝下: alpha=pi, beta=0, gamma=-pi/2, 加入锥面倾斜
            alpha = np.pi - cone_half_angle * np.cos(phi)
            beta = -cone_half_angle * np.sin(phi)
            gamma = -np.pi/2
            
            pose = np.array([cone_tip[0], cone_tip[1], cone_tip[2], alpha, beta, gamma])
            
            try:
                angles = iks.solve(pose)
                if angles.shape[1] > 0:
                    # 选择最接近前一个解的解
                    if len(cone_angles) > 0:
                        best_idx = 0
                        best_dist = float('inf')
                        for sol_idx in range(angles.shape[1]):
                            dist = np.sum((angles[:, sol_idx] - cone_angles[-1])**2)
                            if dist < best_dist:
                                best_dist = dist
                                best_idx = sol_idx
                        q = angles[:, best_idx]
                    else:
                        q = angles[:, 2] if angles.shape[1] > 2 else angles[:, 0]
                    cone_angles.append(q)
                else:
                    if len(cone_angles) > 0:
                        cone_angles.append(cone_angles[-1].copy())
            except Exception as e:
                if len(cone_angles) > 0:
                    cone_angles.append(cone_angles[-1].copy())
        
        # 检查轨迹中的关节角度范围
        joint_limits_deg = np.array([
            [-200, 200],   # 关节1
            [-90, 90],     # 关节2
            [-120, 120],   # 关节3
            [-150, 150],   # 关节4
            [-150, 150],   # 关节5
            [-180, 180]    # 关节6
        ])
        
        problem_points = []
        for j in range(6):
            joint_vals = [np.rad2deg(cone_angles[i][j]) for i in range(len(cone_angles))]
            min_val = min(joint_vals)
            max_val = max(joint_vals)
            
            # 找出超限的点
            for i, val in enumerate(joint_vals):
                if val < joint_limits_deg[j, 0] or val > joint_limits_deg[j, 1]:
                    if i not in [p[0] for p in problem_points]:
                        problem_points.append((i, j, val))
        
        # 处理超限的点：用线性插值替代
        if problem_points:
            # 按点的索引排序
            problem_indices = sorted(set([p[0] for p in problem_points]))
            
            # 找到连续的超限区间
            if len(problem_indices) > 0:
                # 找到第一个和最后一个正常点
                all_indices = set(range(len(cone_angles)))
                normal_indices = sorted(all_indices - set(problem_indices))
                
                if len(normal_indices) >= 2:
                    # 对每个超限点，用前后正常点插值
                    for prob_idx in problem_indices:
                        # 找前一个正常点
                        prev_normal = None
                        for ni in reversed(normal_indices):
                            if ni < prob_idx:
                                prev_normal = ni
                                break
                        
                        # 找后一个正常点
                        next_normal = None
                        for ni in normal_indices:
                            if ni > prob_idx:
                                next_normal = ni
                                break
                        
                        # 线性插值
                        if prev_normal is not None and next_normal is not None:
                            alpha = (prob_idx - prev_normal) / (next_normal - prev_normal)
                            cone_angles[prob_idx] = (1 - alpha) * cone_angles[prev_normal] + alpha * cone_angles[next_normal]
                        elif prev_normal is not None:
                            cone_angles[prob_idx] = cone_angles[prev_normal].copy()
                        elif next_normal is not None:
                            cone_angles[prob_idx] = cone_angles[next_normal].copy()
        
        # 确保闭合
        if len(cone_angles) > 1:
            cone_angles[-1] = cone_angles[0].copy()
        
        # 时间参数
        num_segments = len(cone_angles) - 1
        t_per_seg = CONE_TIME_PER_SEG
        
        # 过渡: 零位 -> 圆锥起始点
        t_transition = 4.0
        t_cone = t_per_seg * num_segments
        t_total = t_transition + t_cone + 0.5
        
        # 规划过渡轨迹
        planner_trans = until.quinticCurvePlanning(
            q0, cone_angles[0], np.zeros(6), np.zeros(6), t_transition
        )
        
        # 规划圆锥各段
        cone_planners = []
        for i in range(num_segments):
            planner = until.quinticCurvePlanning(
                cone_angles[i], cone_angles[i+1],
                np.zeros(6), np.zeros(6), t_per_seg
            )
            cone_planners.append(planner)
        
        # 执行轨迹
        print("\n机械臂回零位...")
        r.go_home()
        time.sleep(1)
        
        print("开始执行轨迹...")
        t = 0
        last_print_seg = -1
        
        while True:
            start_time = time.time()
            
            if t >= t_total:
                print('轨迹执行完成')
                r.go_home()
                break
            
            q = None
            
            # 过渡段
            if t < t_transition:
                q = until.quinticCurveExcute(planner_trans, t)
            else:
                # 圆锥运动段
                t_local = t - t_transition
                if t_local < t_cone:
                    seg_idx = int(t_local / t_per_seg)
                    seg_idx = min(seg_idx, num_segments - 1)
                    seg_t = t_local - seg_idx * t_per_seg
                    q = until.quinticCurveExcute(cone_planners[seg_idx], seg_t)
                    
                    # 每1段打印一次进度
                    if seg_idx // 1 != last_print_seg // 1:
                        phi_deg = 360.0 * seg_idx / CONE_POINTS
                        print(f"  执行中: 段{seg_idx}/{num_segments} (phi={phi_deg:.1f}度)")
                        last_print_seg = seg_idx
            
            # 发送指令
            if q is not None:
                r.syncMove(np.reshape(q, (6, 1)))
            
            t = t + T
            
            # 时间控制
            end_time = time.time()
            spend_time = end_time - start_time
            if spend_time < T:
                time.sleep(T - spend_time)
            else:
                print("timeout!")
            
            q_array.append(r.syncFeedback())


if __name__ == '__main__':
    test()

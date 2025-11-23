import sys
import getpass
import numpy as np

# task mode: 1=square, 2=circle, 3=cone
TASK_MODE = 2

# tunable parameters for cone motion
CONE_POINTS = 120
CONE_TIME_PER_SEG = 0.1
CONE_HALF_ANGLE_DEG = 30
SPIN_SEARCH_SAMPLES = 24

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


def wrap_to_pi(angle):
    return (angle + np.pi) % (2 * np.pi) - np.pi


def rotation_matrix_to_euler_zyx(R):
    beta = np.arctan2(-R[2, 0], np.sqrt(R[0, 0]**2 + R[1, 0]**2))
    
    if np.abs(np.cos(beta)) > 1e-6:
        alpha = np.arctan2(R[2, 1] / np.cos(beta), R[2, 2] / np.cos(beta))
        gamma = np.arctan2(R[1, 0] / np.cos(beta), R[0, 0] / np.cos(beta))
    else:
        alpha = 0
        gamma = np.arctan2(-R[0, 1], R[1, 1])
    
    return alpha, beta, gamma


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


def find_best_spin_for_pose(iks, position, a_axis, prev_angles, prev_spin, joint_limits, num_samples=20):
    # find best spin angle for smooth continuation from previous pose
    # searches wider range and returns both angles and spin
    
    # narrow search around previous spin for continuity
    narrow_range = np.pi / 2
    test_spins_narrow = np.linspace(prev_spin - narrow_range, prev_spin + narrow_range, num_samples)
    
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
                if not all(joint_limits[j, 0] <= candidate[j] <= joint_limits[j, 1] for j in range(6)):
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
        test_spins_wide = np.linspace(prev_spin - np.pi, prev_spin + np.pi, num_samples * 2)
        
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
                    
                    if not all(joint_limits[j, 0] <= candidate[j] <= joint_limits[j, 1] for j in range(6)):
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


def sysCall_init():
    sim = require('sim')
    doSomeInit()
 
    iks = myIKSolver()
    
    print("\n=== Task Mode:", TASK_MODE, "===")
    if TASK_MODE == 1:
        print("Square trajectory")
    elif TASK_MODE == 2:
        print("Circle trajectory")
    else:
        print("Cone motion")
    
    # create visualization trails
    self.end_effector_trail = sim.addDrawingObject(sim.drawing_lines, 2, 0, -1, 999999, [0, 1, 0])
    self.prev_ee_pos = None
    
    if TASK_MODE == 3:
        # for cone, also track joint 6
        self.joint6Handle = sim.getObject('/Robot/Joint6')
        self.joint6_trail = sim.addDrawingObject(sim.drawing_lines, 2, 0, -1, 999999, [1, 0.5, 0])
        self.prev_j6_pos = None
    
    if TASK_MODE == 3:
        self.transition_time = 8.0
    else:
        self.transition_time = 4.0
    self.initial_angles = np.zeros(6)
    
    # TASK 1: SQUARE
    if TASK_MODE == 1:
        self.square_center = np.array([0.25, 0.0, 0.35])
        self.square_side = 0.1
        self.orientation = np.array([np.pi, 0, -np.pi/2])
        self.square_time_per_edge = 4.0
        
        half_side = self.square_side / 2.0
        corners_offset = [
            np.array([-half_side, -half_side, 0]),
            np.array([half_side, -half_side, 0]),
            np.array([half_side, half_side, 0]),
            np.array([-half_side, half_side, 0])
        ]
        
        self.square_corners = []
        for offset in corners_offset:
            self.square_corners.append(self.square_center + offset)
        
        self.corner_angles = []
        for corner in self.square_corners:
            pose = np.concatenate([corner, self.orientation])
            angles = iks.solve(pose)
            selected = angles[:, 2] if angles.shape[1] > 2 else angles[:, 0]
            self.corner_angles.append(selected)
        
        self.corner_angles.append(self.corner_angles[0])
        
        self.transition_coeffs = []
        for j in range(6):
            coeffs = quintic_trajectory_coefficients(
                self.initial_angles[j], 0, 0,
                self.corner_angles[0][j], 0, 0,
                self.transition_time
            )
            self.transition_coeffs.append(coeffs)
        
        self.square_edge_coeffs = []
        for i in range(4):
            edge_coeffs = []
            for j in range(6):
                coeffs = quintic_trajectory_coefficients(
                    self.corner_angles[i][j], 0, 0,
                    self.corner_angles[i + 1][j], 0, 0,
                    self.square_time_per_edge
                )
                edge_coeffs.append(coeffs)
            self.square_edge_coeffs.append(edge_coeffs)
        
        self.total_time = self.square_time_per_edge * 4
        print("  Side:", self.square_side, "m")
        print("  Total time:", self.total_time, "s")
    
    # TASK 2: CIRCLE
    elif TASK_MODE == 2:
        self.circle_center = np.array([0.25, 0.0, 0.35])
        self.circle_radius = 0.05
        self.circle_points = 120
        self.orientation = np.array([np.pi, 0, -np.pi/2])
        self.circle_time_per_segment = 0.1
        
        self.circle_positions = []
        for i in range(self.circle_points):
            theta = 2 * np.pi * i / self.circle_points
            offset = np.array([
                self.circle_radius * np.cos(theta),
                self.circle_radius * np.sin(theta),
                0
            ])
            self.circle_positions.append(self.circle_center + offset)
        
        self.circle_angles = []
        for pos in self.circle_positions:
            pose = np.concatenate([pos, self.orientation])
            angles = iks.solve(pose)
            selected = angles[:, 2] if angles.shape[1] > 2 else angles[:, 0]
            self.circle_angles.append(selected)
        
        self.circle_angles.append(self.circle_angles[0])
        
        self.transition_coeffs = []
        for j in range(6):
            coeffs = quintic_trajectory_coefficients(
                self.initial_angles[j], 0, 0,
                self.circle_angles[0][j], 0, 0,
                self.transition_time
            )
            self.transition_coeffs.append(coeffs)
        
        self.circle_coeffs = []
        for i in range(self.circle_points):
            seg_coeffs = []
            for j in range(6):
                coeffs = quintic_trajectory_coefficients(
                    self.circle_angles[i][j], 0, 0,
                    self.circle_angles[i + 1][j], 0, 0,
                    self.circle_time_per_segment
                )
                seg_coeffs.append(coeffs)
            self.circle_coeffs.append(seg_coeffs)
        
        self.total_time = self.circle_time_per_segment * self.circle_points
        print("  Radius:", self.circle_radius, "m")
        print("  Total time:", self.total_time, "s")
    
    # TASK 3: CONE
    else:
        # cone parameters
        self.cone_tip = np.array([0.25, 0.0, 0.35])
        self.cone_half_angle = CONE_HALF_ANGLE_DEG * np.pi / 180
        self.cone_points = CONE_POINTS
        self.cone_time_per_segment = CONE_TIME_PER_SEG
        self.cone_rotation_degrees = 360.0
        
        print(f"  Cone half-angle: {CONE_HALF_ANGLE_DEG} deg (total {2*CONE_HALF_ANGLE_DEG} deg)")
        print(f"  Waypoints: {CONE_POINTS}")
        
        # generate a-axis directions (cone surface) for full 360 degrees
        rotation_radians = 2 * np.pi
        a_axes = []
        
        for i in range(self.cone_points + 1):
            phi = rotation_radians * i / self.cone_points
            
            # tilt vector at cone half-angle
            tilt_vec = np.array([
                np.sin(self.cone_half_angle),
                0,
                -np.cos(self.cone_half_angle)
            ])
            
            # rotate around z
            Rz = np.array([
                [np.cos(phi), -np.sin(phi), 0],
                [np.sin(phi),  np.cos(phi), 0],
                [0,            0,           1]
            ])
            
            a_axis = Rz @ tilt_vec
            a_axes.append(a_axis)
        
        # solve IK with smooth spin optimization
        joint_limits = np.array([[-200, -90, -120, -150, -150, -180],
                                  [200, 90, 120, 150, 150, 180]]).T / 180 * np.pi
        
        self.cone_angles = []
        
        # find best starting point
        initial_spin_candidates = np.linspace(0, 2*np.pi, 8)
        best_start = None
        best_start_spin = 0
        best_start_score = float('inf')
        
        for init_spin in initial_spin_candidates:
            R = build_rotation_matrix_from_a_axis(a_axes[0], init_spin)
            alpha, beta, gamma = rotation_matrix_to_euler_zyx(R)
            pose = np.concatenate([self.cone_tip, [alpha, beta, gamma]])
            
            try:
                angles = iks.solve(pose)
                if angles.shape[1] > 0:
                    for sol_idx in range(angles.shape[1]):
                        candidate = angles[:, sol_idx]
                        if all(joint_limits[j, 0] <= candidate[j] <= joint_limits[j, 1] for j in range(6)):
                            # prefer smaller joint angles
                            score = np.sum(candidate**2)
                            if score < best_start_score:
                                best_start_score = score
                                best_start = candidate
                                best_start_spin = init_spin
            except:
                continue
        
        if best_start is None:
            best_start = np.zeros(6)
            best_start_spin = 0
        
        prev_angles = best_start
        prev_spin = best_start_spin
        
        spin_angles = [best_start_spin]
        
        for i, a_axis in enumerate(a_axes):
            best_angles, best_spin = find_best_spin_for_pose(
                iks, self.cone_tip, a_axis, prev_angles, prev_spin, joint_limits, SPIN_SEARCH_SAMPLES
            )
            
            if best_angles is None:
                best_angles = prev_angles
                best_spin = prev_spin
            
            self.cone_angles.append(best_angles)
            spin_angles.append(best_spin)
            prev_angles = best_angles
            prev_spin = best_spin
        
        # check for angle jumps and refine if needed
        max_jump_threshold = 0.4
        jumps_detected = []
        
        for i in range(len(self.cone_angles) - 1):
            angle_diff = self.cone_angles[i+1] - self.cone_angles[i]
            max_jump = np.max(np.abs(angle_diff))
            if max_jump > max_jump_threshold:
                jumps_detected.append((i, max_jump))
        
        if jumps_detected:
            # first pass: try to find better solutions
            for idx, jump_size in jumps_detected:
                a_axis_problem = a_axes[idx + 1]
                better_angles, better_spin = find_best_spin_for_pose(
                    iks, self.cone_tip, a_axis_problem, 
                    self.cone_angles[idx], spin_angles[idx+1], 
                    joint_limits, SPIN_SEARCH_SAMPLES * 2
                )
                
                if better_angles is not None:
                    new_diff = better_angles - self.cone_angles[idx]
                    new_max_jump = np.max(np.abs(new_diff))
                    if new_max_jump < jump_size:
                        self.cone_angles[idx + 1] = better_angles
                        spin_angles[idx + 1] = better_spin
            
            # second pass: insert intermediate points if needed
            remaining_jumps = []
            for i in range(len(self.cone_angles) - 1):
                angle_diff = self.cone_angles[i+1] - self.cone_angles[i]
                max_jump = np.max(np.abs(angle_diff))
                if max_jump > max_jump_threshold * 1.5:
                    remaining_jumps.append(i)
            
            if remaining_jumps:
                # insert points in reverse to maintain indices
                for idx in reversed(remaining_jumps):
                    # create intermediate a_axis
                    phi1 = rotation_radians * idx / self.cone_points
                    phi2 = rotation_radians * (idx + 1) / self.cone_points
                    phi_mid = (phi1 + phi2) / 2
                    
                    tilt_vec = np.array([
                        np.sin(self.cone_half_angle),
                        0,
                        -np.cos(self.cone_half_angle)
                    ])
                    Rz = np.array([
                        [np.cos(phi_mid), -np.sin(phi_mid), 0],
                        [np.sin(phi_mid),  np.cos(phi_mid), 0],
                        [0,                0,                1]
                    ])
                    a_axis_mid = Rz @ tilt_vec
                    
                    # find solution for midpoint
                    mid_spin = (spin_angles[idx] + spin_angles[idx+1]) / 2
                    mid_angles, mid_spin = find_best_spin_for_pose(
                        iks, self.cone_tip, a_axis_mid,
                        self.cone_angles[idx], mid_spin,
                        joint_limits, SPIN_SEARCH_SAMPLES
                    )
                    
                    if mid_angles is not None:
                        self.cone_angles.insert(idx + 1, mid_angles)
                        spin_angles.insert(idx + 1, mid_spin)
                        a_axes.insert(idx + 1, a_axis_mid)
        
        # check closure
        closure_error = np.linalg.norm(self.cone_angles[-1] - self.cone_angles[0])
        
        if closure_error > 0.5:
            self.cone_angles[-1] = self.cone_angles[0]
        
        # two-stage transition via intermediate
        intermediate_pos = np.array([0.25, 0.0, 0.35])
        intermediate_ori = np.array([np.pi, 0, -np.pi/2])
        intermediate_pose = np.concatenate([intermediate_pos, intermediate_ori])
        
        angles_mid = iks.solve(intermediate_pose)
        if angles_mid.shape[1] > 0:
            self.intermediate_angles = angles_mid[:, 2] if angles_mid.shape[1] > 2 else angles_mid[:, 0]
        else:
            self.intermediate_angles = (self.initial_angles + self.cone_angles[0]) / 2
        
        # stage 1: zero -> intermediate
        self.transition_coeffs_1 = []
        for j in range(6):
            coeffs = quintic_trajectory_coefficients(
                self.initial_angles[j], 0, 0,
                self.intermediate_angles[j], 0, 0,
                self.transition_time * 0.4
            )
            self.transition_coeffs_1.append(coeffs)
        
        # stage 2: intermediate -> cone start
        self.transition_coeffs_2 = []
        for j in range(6):
            coeffs = quintic_trajectory_coefficients(
                self.intermediate_angles[j], 0, 0,
                self.cone_angles[0][j], 0, 0,
                self.transition_time * 0.6
            )
            self.transition_coeffs_2.append(coeffs)
        
        # segments
        num_segments = len(self.cone_angles) - 1
        
        # adjust time per segment if points were inserted
        actual_time_per_seg = self.cone_time_per_segment
        if num_segments > self.cone_points:
            # we inserted some points, adjust time
            actual_time_per_seg = (self.cone_points * self.cone_time_per_segment) / num_segments
        
        self.cone_coeffs = []
        for i in range(num_segments):
            seg_coeffs = []
            for j in range(6):
                coeffs = quintic_trajectory_coefficients(
                    self.cone_angles[i][j], 0, 0,
                    self.cone_angles[i + 1][j], 0, 0,
                    actual_time_per_seg
                )
                seg_coeffs.append(coeffs)
            self.cone_coeffs.append(seg_coeffs)
        
        self.total_time = actual_time_per_seg * num_segments
        self.cone_num_segments = num_segments
        self.cone_segment_time = actual_time_per_seg
        
        print("  Total time:", self.total_time, "s")
    
    self.start_time = sim.getSimulationTime()
    print("===\n")


def sysCall_actuation():
    t = sim.getSimulationTime() - self.start_time
    
    # phase 1: transition
    if t < self.transition_time:
        q = np.zeros(6)
        
        if TASK_MODE == 3:
            t1_duration = self.transition_time * 0.4
            if t < t1_duration:
                for j in range(6):
                    q[j] = quintic_trajectory_eval(self.transition_coeffs_1[j], t)
            else:
                t_local = t - t1_duration
                for j in range(6):
                    q[j] = quintic_trajectory_eval(self.transition_coeffs_2[j], t_local)
        else:
            for j in range(6):
                q[j] = quintic_trajectory_eval(self.transition_coeffs[j], t)
        
        move(q, False)
        update_trail()
        return
    
    t -= self.transition_time
    
    # phase 2: main trajectory
    if TASK_MODE == 1:
        if t < self.total_time:
            edge_idx = int(t / self.square_time_per_edge)
            edge_idx = min(edge_idx, 3)
            edge_t = t - edge_idx * self.square_time_per_edge
            edge_t = min(edge_t, self.square_time_per_edge)
            
            q = np.zeros(6)
            for j in range(6):
                q[j] = quintic_trajectory_eval(self.square_edge_coeffs[edge_idx][j], edge_t)
            move(q, False)
        else:
            print("Square done")
            sim.pauseSimulation()
    
    elif TASK_MODE == 2:
        if t < self.total_time:
            seg_idx = int(t / self.circle_time_per_segment)
            seg_idx = min(seg_idx, self.circle_points - 1)
            seg_t = t - seg_idx * self.circle_time_per_segment
            seg_t = min(seg_t, self.circle_time_per_segment)
            
            q = np.zeros(6)
            for j in range(6):
                q[j] = quintic_trajectory_eval(self.circle_coeffs[seg_idx][j], seg_t)
            move(q, False)
        else:
            print("Circle done")
            sim.pauseSimulation()
    
    else:
        if t < self.total_time:
            seg_idx = int(t / self.cone_segment_time)
            seg_idx = min(seg_idx, self.cone_num_segments - 1)
            seg_t = t - seg_idx * self.cone_segment_time
            seg_t = min(seg_t, self.cone_segment_time)
            
            q = np.zeros(6)
            for j in range(6):
                q[j] = quintic_trajectory_eval(self.cone_coeffs[seg_idx][j], seg_t)
            move(q, False)
        else:
            print("Cone done")
            sim.pauseSimulation()
    
    update_trail()


def update_trail():
    # draw end effector trail (green)
    ee_pose = sim.getObjectPose(self.suctionHandle, -1)
    ee_pos = np.array(ee_pose[0:3])
    
    if self.prev_ee_pos is not None:
        sim.addDrawingObjectItem(self.end_effector_trail, self.prev_ee_pos.tolist() + ee_pos.tolist())
    
    self.prev_ee_pos = ee_pos
    
    # for cone mode, also draw joint 6 trail (orange)
    if TASK_MODE == 3:
        j6_pose = sim.getObjectPose(self.joint6Handle, -1)
        j6_pos = np.array(j6_pose[0:3])
        
        if self.prev_j6_pos is not None:
            sim.addDrawingObjectItem(self.joint6_trail, self.prev_j6_pos.tolist() + j6_pos.tolist())
        
        self.prev_j6_pos = j6_pos


####################################################
# system functions
####################################################

def doSomeInit():
    self.Joint_limits = np.array([[-200, -90, -120, -150, -150, -180],
                            [200, 90, 120, 150, 150, 180]]).transpose()/180*np.pi
    self.Vel_limits = np.array([100, 100, 100, 100, 100, 100])/180*np.pi
    self.Acc_limits = np.array([500, 500, 500, 500, 500, 500])/180*np.pi
    
    self.lastPos = np.zeros(6)
    self.lastVel = np.zeros(6)
    self.sensorVel = np.zeros(6)
    
    self.robotHandle = sim.getObject('/Robot')
    self.suctionHandle = sim.getObject('/Robot/SuctionCup')
    self.jointHandles = []
    for i in range(6):
        self.jointHandles.append(sim.getObject('/Robot/Joint' + str(i+1)))
    sim.writeCustomStringData(self.suctionHandle, 'activity', 'off')
    sim.writeCustomStringData(self.robotHandle, 'error', '0')
    
    self.dataPos = []
    self.dataVel = []
    self.dataAcc = []
    self.graphPos = sim.getObject('/Robot/DataPos')
    self.graphVel = sim.getObject('/Robot/DataVel')
    self.graphAcc = sim.getObject('/Robot/DataAcc')
    color = [[1, 0, 0], [0, 1, 0], [0, 0, 1], [1, 1, 0], [1, 0, 1], [0, 1, 1]]
    for i in range(6):
        self.dataPos.append(sim.addGraphStream(self.graphPos, 'Joint'+str(i+1), 'deg', 0, color[i]))
        self.dataVel.append(sim.addGraphStream(self.graphVel, 'Joint'+str(i+1), 'deg/s', 0, color[i]))
        self.dataAcc.append(sim.addGraphStream(self.graphAcc, 'Joint'+str(i+1), 'deg/s2', 0, color[i]))

def sysCall_sensing():
    if sim.readCustomStringData(self.robotHandle,'error') == '1':
        return
    for i in range(6):
        pos = sim.getJointPosition(self.jointHandles[i])
        if i == 0:
            if pos < -160/180*np.pi:
                pos += 2*np.pi
        vel = sim.getJointVelocity(self.jointHandles[i])
        acc = (vel - self.sensorVel[i])/sim.getSimulationTimeStep()
        if pos < self.Joint_limits[i, 0] or pos > self.Joint_limits[i, 1]:
            print("Error: Joint" + str(i+1) + " Position Out of Range!")
            sim.writeCustomStringData(self.robotHandle, 'error', '1')
            return
        
        if abs(vel) > self.Vel_limits[i]:
            print("Error: Joint" + str(i+1) + " Velocity Out of Range!")
            sim.writeCustomStringData(self.robotHandle, 'error', '1')
            return
        
        if abs(acc) > self.Acc_limits[i]:
            print("Error: Joint" + str(i+1) + " Acceleration Out of Range!")
            sim.writeCustomStringData(self.robotHandle, 'error', '1')
            return
        
        sim.setGraphStreamValue(self.graphPos, self.dataPos[i], pos*180/np.pi)
        sim.setGraphStreamValue(self.graphVel, self.dataVel[i], vel*180/np.pi)
        sim.setGraphStreamValue(self.graphAcc, self.dataAcc[i], acc*180/np.pi)
        self.sensorVel[i] = vel

def sysCall_cleanup():
    sim.writeCustomStringData(self.suctionHandle, 'activity', 'off')
    sim.writeCustomStringData(self.robotHandle, 'error', '0')


def move(q, state):
    if sim.readCustomStringData(self.robotHandle,'error') == '1':
        return
    for i in range(6):
        if q[i] < self.Joint_limits[i, 0] or q[i] > self.Joint_limits[i, 1]:
            print("move(): Joint" + str(i+1) + " Position Out of Range!")
            return False
        if abs(q[i] - self.lastPos[i])/sim.getSimulationTimeStep() > self.Vel_limits[i]:
            print("move(): Joint" + str(i+1) + " Velocity Out of Range!")
            return False
        if abs(self.lastVel[i] - (q[i] - self.lastPos[i]))/sim.getSimulationTimeStep() > self.Acc_limits[i]:
            print("move(): Joint" + str(i+1) + " Acceleration Out of Range!")
            return False
            
    self.lastPos = q
    self.lastVel = q - self.lastPos
    
    for i in range(6):
        sim.setJointTargetPosition(self.jointHandles[i], q[i])
        
    if state:
        sim.writeCustomStringData(self.suctionHandle, 'activity', 'on')
    else:
        sim.writeCustomStringData(self.suctionHandle, 'activity', 'off')
    
    return True
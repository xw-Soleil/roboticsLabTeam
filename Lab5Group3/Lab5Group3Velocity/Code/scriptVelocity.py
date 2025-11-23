import sys
import numpy as np
import math

# Task Configuration
TASK_MODE = 1  # 1=Square, 2=Circle, 3=Cone

# Task 1: Square
SQUARE_SIZE = 0.10          # 10cm side length
SQUARE_VELOCITY = 0.025     # Linear velocity
SQUARE_CENTER = np.array([0.25, 0.0, 0.35])

# Task 2: Circle
CIRCLE_RADIUS = 0.05        # 5cm radius, 10cm diameter
CIRCLE_VELOCITY = 0.025     # Linear velocity
CIRCLE_CENTER = np.array([0.25, 0.0, 0.35])

# Task 3: Cone
CONE_TIP_POSITION = np.array([0.25, 0.0, 0.35])
CONE_HALF_ANGLE = math.radians(30.0)    # 30deg half-angle
CONE_ANGULAR_VEL = math.radians(20.0)   # Angular velocity
CONE_AXIS = np.array([0.0, 0.0, -1.0])

# Control Parameters
DAMPING_FACTOR = 0.01       # Damping factor for Jacobian inverse
INIT_DURATION = 4.0         # Duration for initial positioning
POSITION_GAIN = 2.0         # Proportional gain for position control


# Module Import
try:
    import jacobi_zjui
    JACOBI_OK = True
except ImportError:
    JACOBI_OK = False
    print("WARNING: jacobi_zjui module not found! Please check.")


#  Our own IK Solver
class myIKSolver:

    def solve(self, p):

        d_x, d_y, d_z, alpha, beta, gamma = p

        # DH parameters
        d_1, a_2, a_3, d_4, d_5, d_6 = 0.230, 0.185, 0.170, 0.023, 0.077, 0.0855

        # Rotation matrix elements
        n_x = np.cos(gamma) * np.cos(beta)
        n_y = np.cos(alpha) * np.sin(gamma) + np.sin(alpha) * np.sin(beta) * np.cos(gamma)
        n_z = np.sin(alpha) * np.sin(gamma) - np.cos(alpha) * np.sin(beta) * np.cos(gamma)

        o_x = -np.sin(gamma) * np.cos(beta)
        o_y = np.cos(alpha) * np.cos(gamma) - np.sin(alpha) * np.sin(beta) * np.sin(gamma)
        o_z = np.sin(alpha) * np.cos(gamma) + np.cos(alpha) * np.sin(beta) * np.sin(gamma)

        a_x = np.sin(beta)
        a_y = -np.sin(alpha) * np.cos(beta)
        a_z = np.cos(alpha) * np.cos(beta)

        # Solve for theta_1
        A = d_y - d_6 * a_y
        B = d_x - d_6 * a_x
        pm = np.array([1, -1])
        theta_1 = np.arctan2(A, B) - np.arctan2(d_4, pm * np.sqrt(A**2 + B**2 - d_4**2))

        # Solve for theta_5
        theta_5 = np.arcsin(a_y * np.cos(theta_1) - a_x * np.sin(theta_1))
        theta_5 = np.array([[x, np.pi - x if x > 0 else -np.pi - x] for x in theta_5]).flatten()
        theta_1 = np.array([[x, x] for x in theta_1]).flatten()

        # Solve for theta_6
        C = n_y * np.cos(theta_1) - n_x * np.sin(theta_1)
        D = o_y * np.cos(theta_1) - o_x * np.sin(theta_1)
        theta_6 = np.arctan2(C, D) - np.arctan2(np.cos(theta_5), 0)

        # Solve for theta_3
        E = -d_5 * (np.sin(theta_6) * (n_x * np.cos(theta_1) + n_y * np.sin(theta_1)) +
                    np.cos(theta_6) * (o_x * np.cos(theta_1) + o_y * np.sin(theta_1))) - \
            d_6 * (a_x * np.cos(theta_1) + a_y * np.sin(theta_1)) + \
            d_x * np.cos(theta_1) + d_y * np.sin(theta_1)
        F = -d_1 - a_z * d_6 - d_5 * (o_z * np.cos(theta_6) + n_z * np.sin(theta_6)) + d_z
        theta_3 = np.arccos((E**2 + F**2 - a_2**2 - a_3**2) / (2 * a_2 * a_3))

        # Expand solution arrays
        theta_3 = np.array([[x, -x] for x in theta_3]).flatten()
        theta_1 = np.array([[x, x] for x in theta_1]).flatten()
        theta_5 = np.array([[x, x] for x in theta_5]).flatten()
        theta_6 = np.array([[x, x] for x in theta_6]).flatten()
        E = np.array([[x, x] for x in E]).flatten()
        F = np.array([[x, x] for x in F]).flatten()

        # Solve for theta_2
        G = a_2 + a_3 * np.cos(theta_3)
        H = a_3 * np.sin(theta_3)
        theta_2 = np.arctan2(G * E - H * F, G * F + H * E)

        # Solve for theta_4
        I = (n_x * np.cos(theta_1) + n_y * np.sin(theta_1)) * np.sin(theta_6) + \
            (o_x * np.cos(theta_1) + o_y * np.sin(theta_1)) * np.cos(theta_6)
        J = n_z * np.sin(theta_6) + o_z * np.cos(theta_6)
        theta_4 = np.arctan2(I, J) - theta_2 - theta_3

        # Assemble solutions
        ans = np.array([theta_1, theta_2, theta_3, theta_4, theta_5, theta_6])

        # Remove NaN solutions
        cols_with_nan = np.isnan(ans).any(axis=0)
        ans = ans[:, ~cols_with_nan]

        # Normalize angles to [-pi, pi]
        ans = (ans + np.pi) % (2 * np.pi) - np.pi

        # Reorder axes
        ans[:, [0, 1, 2, 3]] = ans[:, [2, 3, 0, 1]]

        return ans


def sysCall_init():

    sim = require('sim')

    import builtins
    builtins.sim = sim

    # Robot parameters
    self.Joint_limits = np.array([
        [-200, -90, -120, -150, -150, -180],
        [200, 90, 120, 150, 150, 180]
    ]).T / 180 * np.pi

    self.Vel_limits = np.array([100, 100, 100, 100, 100, 100]) / 180 * np.pi

    # Get robot handles
    self.robotHandle = sim.getObject('/Robot')
    self.jointHandles = [sim.getObject(f'/Robot/Joint{i+1}') for i in range(6)]

    # Setup graph streams
    try:
        self.graphPos = sim.getObject('/Robot/DataPos')
        self.graphVel = sim.getObject('/Robot/DataVel')
        self.dataPos = []
        self.dataVel = []
        colors = [[1,0,0], [0,1,0], [0,0,1], [1,1,0], [1,0,1], [0,1,1]]
        for i in range(6):
            self.dataPos.append(sim.addGraphStream(self.graphPos, f'J{i+1}', 'deg', 0, colors[i]))
            self.dataVel.append(sim.addGraphStream(self.graphVel, f'J{i+1}', 'deg/s', 0, colors[i]))
    except:
        pass

    # Initialize control state
    sim.writeCustomStringData(self.robotHandle, 'error', '0')
    self.velocityModeEnabled = False
    self.lastPrintTime = 0

    # Set joint control mode
    for h in self.jointHandles:
        try:
            sim.setJointMode(h, sim.jointmode_dynamic, 0)
            sim.setObjectInt32Param(h, sim.jointintparam_dynctrlmode, sim.jointdynctrl_velocity)
            sim.setJointMaxForce(h, 9999.0)
        except:
            pass

    # Setup end effector and trajectory visualization
    try:
        self.tipHandle = sim.getObject('/Robot/SuctionCup')
        self.drawingObject = sim.addDrawingObject(
            sim.drawing_linestrip + sim.drawing_cyclic,
            2, 0, -1, 10000, [1, 0, 0]
        )
        self.trajectory_enabled = True
    except:
        self.tipHandle = self.jointHandles[-1]
        self.drawingObject = None
        self.trajectory_enabled = False

    # Cone visualization
    self.cone_vis_enabled = False
    if TASK_MODE == 3:
        try:
            # Cone axis line
            self.coneAxisDrawing = sim.addDrawingObject(
                sim.drawing_lines, 3, 0, -1, 2, [0, 0, 1])

            # End effector axis
            self.endAxisDrawing = sim.addDrawingObject(
                sim.drawing_lines, 2, 0, -1, 100, [0, 1, 0])

            # Cone outline
            self.coneOutlineDrawing = sim.addDrawingObject(
                sim.drawing_linestrip + sim.drawing_cyclic,
                1, 0, -1, 1000, [1, 1, 0])

            # Cone tip marker
            self.coneTipMarker = sim.addDrawingObject(
                sim.drawing_spherepts, 0.008, 0, -1, 1, [1, 1, 1])
            sim.addDrawingObjectItem(self.coneTipMarker, list(CONE_TIP_POSITION))

            # Draw cone axis
            axis_length = 0.15
            axis_start = CONE_TIP_POSITION
            axis_end = CONE_TIP_POSITION + axis_length * CONE_AXIS
            sim.addDrawingObjectItem(self.coneAxisDrawing, list(axis_start) + list(axis_end))

            # Draw cone base circle
            cone_base_radius = axis_length * np.tan(CONE_HALF_ANGLE)
            cone_base_center = axis_end
            for i in range(37):
                angle = 2 * np.pi * i / 36
                point = cone_base_center + np.array([
                    cone_base_radius * np.cos(angle),
                    cone_base_radius * np.sin(angle),
                    0
                ])
                sim.addDrawingObjectItem(self.coneOutlineDrawing, list(point))

            self.cone_vis_enabled = True
        except:
            pass

    # Read initial joint positions
    self.q0 = np.array([sim.getJointPosition(h) for h in self.jointHandles])

    # Trajectory planning
    iks = myIKSolver()

    if TASK_MODE == 1:
        # Square trajectory
        half = SQUARE_SIZE / 2
        start_pos = SQUARE_CENTER + np.array([-half, -half, 0])
        self.squareCorners = [
            SQUARE_CENTER + np.array([-half, -half, 0]),
            SQUARE_CENTER + np.array([half, -half, 0]),
            SQUARE_CENTER + np.array([half, half, 0]),
            SQUARE_CENTER + np.array([-half, half, 0]),
        ]
        self.squareEdgeTime = SQUARE_SIZE / SQUARE_VELOCITY
        self.squarePeriod = 4 * self.squareEdgeTime
        start_euler = np.array([np.pi, 0, -np.pi/2])

    elif TASK_MODE == 2:
        # Circle trajectory
        start_pos = CIRCLE_CENTER + np.array([CIRCLE_RADIUS, 0, 0])
        self.circleOmega = CIRCLE_VELOCITY / CIRCLE_RADIUS
        start_euler = np.array([np.pi, 0, -np.pi/2])

    else:  # TASK_MODE == 3
        # Cone trajectory
        start_pos = CONE_TIP_POSITION.copy()

        # Find valid IK solutions
        cone_initial_candidates = []
        for azimuth in [0, np.pi/2, np.pi, -np.pi/2]:
            euler = np.array([np.pi, CONE_HALF_ANGLE, -np.pi/2 + azimuth])
            cone_initial_candidates.append(euler)

        self.cone_initial_euler = None
        self.q_start = None

        # Find first valid IK solution
        for euler in cone_initial_candidates:
            pose = np.concatenate([start_pos, euler])
            try:
                angles = iks.solve(pose)
                if angles.shape[1] > 0:
                    for sol_idx in range(angles.shape[1]):
                        sol = angles[:, sol_idx]
                        # Check if within joint limits
                        valid = all(self.Joint_limits[j,0] <= sol[j] <= self.Joint_limits[j,1]
                                  for j in range(6))
                        if valid:
                            self.cone_initial_euler = euler
                            self.q_start = sol
                            break
                    if self.q_start is not None:
                        break
            except:
                continue

        # Fallback if no valid solution found
        if self.q_start is None:
            self.cone_initial_euler = np.array([np.pi, CONE_HALF_ANGLE, -np.pi/2])
            self.q_start = np.array([0, 25, -50, 25, 0, 0]) * np.pi/180

        self.cone_initial_azimuth = (self.cone_initial_euler[2] + np.pi/2
                                    if self.cone_initial_euler is not None else 0)
        start_euler = self.cone_initial_euler

    # Solve IK for start position
    if TASK_MODE != 3:  # For square and circle
        try:
            pose = np.concatenate([start_pos, start_euler])
            angles = iks.solve(pose)
            # Select 3rd solution as verified to work
            selected = angles[:, 2] if angles.shape[1] > 2 else angles[:, 0]
            self.q_start = selected
        except:
            # Fallback to safe position
            self.q_start = np.array([0, 25, -50, 25, 0, 0]) * np.pi/180


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


def sysCall_sensing():

    if sim.readCustomStringData(self.robotHandle, 'error') == '1':
        return

    for i in range(6):
        pos = sim.getJointPosition(self.jointHandles[i])
        vel = sim.getJointVelocity(self.jointHandles[i])

        # Check joint position limits
        if pos < self.Joint_limits[i,0] or pos > self.Joint_limits[i,1]:
            print(f"ERROR: Joint{i+1} = {pos*180/np.pi:.1f}deg out of range "
                  f"[{self.Joint_limits[i,0]*180/np.pi:.1f}, {self.Joint_limits[i,1]*180/np.pi:.1f}]deg")
            sim.writeCustomStringData(self.robotHandle, 'error', '1')
            sim.pauseSimulation()
            return

        # Update graph streams
        try:
            sim.setGraphStreamValue(self.graphPos, self.dataPos[i], pos*180/np.pi)
            sim.setGraphStreamValue(self.graphVel, self.dataVel[i], vel*180/np.pi)
        except:
            pass


def sysCall_cleanup():

    # Stop all joints
    for h in self.jointHandles:
        try:
            sim.setJointTargetVelocity(h, 0.0)
        except:
            pass

    # Remove trajectory drawing
    if hasattr(self, 'drawingObject') and self.drawingObject is not None:
        try:
            sim.removeDrawingObject(self.drawingObject)
        except:
            pass

    # Remove cone visualization
    if hasattr(self, 'cone_vis_enabled') and self.cone_vis_enabled:
        for attr in ['coneAxisDrawing', 'endAxisDrawing', 'coneOutlineDrawing', 'coneTipMarker']:
            if hasattr(self, attr):
                try:
                    sim.removeDrawingObject(getattr(self, attr))
                except:
                    pass

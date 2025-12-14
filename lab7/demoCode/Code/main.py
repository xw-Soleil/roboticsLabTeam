import time
import numpy as np
from math import pi
from math import *
from numpy import arctan, arccos
from coppeliasim_zmqremoteapi_client import RemoteAPIClient
from trajectory import Trajectory
from change import change_base_LtoR, change_base_RtoL

print('Program started')

client = RemoteAPIClient()
sim = client.getObject('sim')

# When simulation is not running, ZMQ message handling could be a bit
# slow, since the idle loop runs at 8 Hz by default. So let's make
# sure that the idle loop runs at full speed for this program:
defaultIdleFps = sim.getInt32Param(sim.intparam_idle_fps)
sim.setInt32Param(sim.intparam_idle_fps, 0)

# Run a simulation in stepping mode:
response = client.call('sim.setStepping', [True])
print('Response from sim.setStepping:', response)
client.setStepping(True)
sim.startSimulation()

# Get object handle
joint = np.zeros(7)
joint[0] = L_joint1 = sim.getObject('./L_Joint1')
joint[1] = L_joint2 = sim.getObject('./L_Joint2')
joint[2] = L_joint3 = sim.getObject('./L_Joint3')
joint[3] = joint4 = sim.getObject('./Joint4')
joint[4] = R_joint3 = sim.getObject('./R_Joint3')
joint[5] = R_joint2 = sim.getObject('./R_Joint2')
joint[6] = R_joint1 = sim.getObject('./R_Joint1')

matrix_l = []
matrix_r = []
for i in range(16, 30):
    matrix_l.append(sim.getObjectMatrix(i, i + 1))
for i in range(16, 30):
    matrix_r.append(sim.getObjectMatrix(i + 1, i))

graph0 = sim.getObject('/Graph')
velocityStreamHandles = [0, 0, 0, 0, 0, 0, 0]
velocityStreamHandles[0] = sim.addGraphStream(graph0, 'L_joint1 velocity', 'deg/s', 0, [1, 0, 0])
velocityStreamHandles[1] = sim.addGraphStream(graph0, 'L_joint2 velocity', 'deg/s', 0, [0, 1, 0])
velocityStreamHandles[2] = sim.addGraphStream(graph0, 'L_joint3 velocity', 'deg/s', 0, [0, 0, 1])
velocityStreamHandles[3] = sim.addGraphStream(graph0, 'joint4 velocity', 'deg/s', 0, [1, 1, 0])
velocityStreamHandles[4] = sim.addGraphStream(graph0, 'R_joint1 velocity', 'deg/s', 0, [1, 0, 1])
velocityStreamHandles[5] = sim.addGraphStream(graph0, 'R_joint2 velocity', 'deg/s', 0, [0, 1, 1])
velocityStreamHandles[6] = sim.addGraphStream(graph0, 'R_joint3 velocity', 'deg/s', 0, [1, 1, 1])

def low_pass_filter(new_value, prev_filtered_value, alpha):
    return alpha * new_value + (1 - alpha) * prev_filtered_value

filtered_velocities = [0 for _ in range(7)] 
alpha = 0.05 

def set_joint_positions(sim, q, base):
    if (base == 'B'):
        sim.setJointPosition(R_joint1, q[0])
        sim.setJointPosition(R_joint2, q[1])
        sim.setJointPosition(R_joint3, q[2])
        sim.setJointPosition(joint4,   q[3])
        sim.setJointPosition(L_joint3, q[4])
        sim.setJointPosition(L_joint2, q[5])
        sim.setJointPosition(L_joint1, q[6])
    if (base == 'A'): 
        sim.setJointPosition(L_joint1, q[0])
        sim.setJointPosition(L_joint2, q[1])
        sim.setJointPosition(L_joint3, q[2])
        sim.setJointPosition(joint4,   q[3])
        sim.setJointPosition(R_joint3, q[4])
        sim.setJointPosition(R_joint2, q[5])
        sim.setJointPosition(R_joint1, q[6])


q0 = np.array([0, 0, 0, 0, 0, 0, 0]) 

q1 = np.array([0, 2.094395102393195, 0.4336038030273939, -1.539541238295402, -1.1684476122669976, -1.0471975511965979, 0]) 

q1_1 = np.array([0, 0.5, 0.5, 0, -0.1715480681505778, -0.05697852345543221, 0])

q1_2 = np.array([0, 1.9, 0.43322658049096774, -1.539541238295402, -1.168574248127406, -1.0471975511965979, 0])

q2 = np.array([0, -2.790686821121354, -1.2220722576756144, -1.2252700800130993, 2.2650466426959754, -3.141592653589793, 2.790686821121354])

q_m2_0 = np.array([0, 1.0471975511965979, 1.1684476122669976, 1.539541238295402, -0.4336038030273939, -2.094395102393195, 0])
    
q_m2_3 = np.array([0, -2.790686821121354, -1.2549397494525802, -1.2424883197633365, 2.214960911168772, -3.141592653589793, 2.790686821121354])


flag_turn = 1
while (t := sim.getSimulationTime()) < 10:
    current_velocities = [sim.getJointVelocity(joint) for joint in [L_joint1, L_joint2, L_joint3, joint4, R_joint1, R_joint2, R_joint3]]

    for i in range(7):
        filtered_velocities[i] = low_pass_filter(current_velocities[i], filtered_velocities[i], alpha)

    for i, vel in enumerate(filtered_velocities):
        sim.setGraphStreamValue(graph0, velocityStreamHandles[i], 180 * vel / pi)

    if t < 5:
        if flag_turn:
            change_base_LtoR(sim)
            flag_turn = 0
            
            pos_now = np.zeros(7)
            for i in range(0, 7):
                pos_now[i] = sim.getJointPosition(joint[i])
            for i in range(16, 30):
                sim.setObjectMatrix(i + 1, i, matrix_r[i - 16])
                if i % 2 == 1:   
                    sim.setJointPosition(i, -pos_now[(i - 17) // 2])
        trajectory = Trajectory([q0, q1_1, q1_2, q1], [0, 1, 4, 5])
        q=trajectory.GetCurvePosition(t)

        set_joint_positions(sim, q, "B")

    elif t < 6:
        q = q1
        set_joint_positions(sim, q, "B")

    elif t < 11:
        if not flag_turn:
            change_base_RtoL(sim)
            flag_turn = 1

            pos_now = np.zeros(7)
            for i in range(0, 7):
                pos_now[i] = sim.getJointPosition(joint[i])
            for i in range(16, 30):
                sim.setObjectMatrix(i + 1, i, matrix_r[i - 16])
                if i % 2 == 1:  
                    sim.setJointPosition(i, -pos_now[(i - 17) // 2])
            
        trajectory = Trajectory([q_m2_0, q_m2_3, q2], [6, 9, 10])
        q=trajectory.GetCurvePosition(t)
        
        set_joint_positions(sim, q, "A")

    message = f'Simulation time: {t:.2f} s'
    print(message)
    sim.addLog(sim.verbosity_scriptinfos, message)
    client.step()  
time.sleep(1)

# Stop simulation
sim.stopSimulation()

# Restore the original idle loop frequency:
sim.setInt32Param(sim.intparam_idle_fps, defaultIdleFps)

print('Program ended')
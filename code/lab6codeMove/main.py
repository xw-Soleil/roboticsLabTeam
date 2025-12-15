from Robot.Robot import Robot
import numpy as np
import until
import time
import pandas as pd
import math
from myIK import IKSolver


def test():
    q_array = []
    r = Robot(com='COM5', baud=250000)
    r.connect()
    T = 0.02
    t = 0

    iks = IKSolver()

    # waypoints for A/B path
    qA_ = np.array([0.37, -0.09, 0.165, np.pi, 0, -np.pi/2])
    qA = iks.solve(qA_)[:, 2]
    print(qA)
    
    qB_ = np.array([0.288, -0.288, 0.165, np.pi, 0, -np.pi/2])
    qB = iks.solve(qB_)[:, 2]

    # home and cube positions
    q0 = np.zeros(6)
    q1 = iks.solve(np.array([0.348004121976367, -0.022031675538176, 0.09, -np.pi, 0, -np.pi/2]))[:, 2]
    q2 = iks.solve(np.array([0.051780861973690, -0.389209243590751, 0.1, -178.49/180 * np.pi, 0, 10.78/180*np.pi]))[:, 2]
    q3 = iks.solve(np.array([0.348004121976367, 0.097050798735177, 0.09, -np.pi, 0, -np.pi/2]))[:, 2]
    q4 = iks.solve(np.array([0.045, -0.389209243590751, 0.16, -178.49/180 * np.pi, 0, 10.78/180*np.pi]))[:, 2]
    q5 = np.array([-83.49609375, 63.01757812, 29.79492188, 0.96679688, 0, 0])
    q6 = np.array([7.82226562, 53.87695312, 60.46875, -19.42382812, 12.83203125, 0.61523438])
    q7 = iks.solve(np.array([0.051780861973690, -0.389209243590751, 0.215206767132024, -np.pi, 0, 0]))[:, 2]
    
    # rotate joint 1 back by 90deg at q7
    q7_prime = q7.copy()
    q7_prime[0] = q7[0] - np.pi/2
    
    # approach point above q3
    q3_up = iks.solve(np.array([0.356112642250006, 0.097050798735177, 0.093340875363385 + 0.15, -np.pi, 0, -np.pi/2]))[:, 2]

    # velocity params for smooth transitions
    vA = (np.array([-1.71663009e+01, 6.60437634e+01, 6.19368716e+01, -3.79806349e+01, 5.72957795e-15, -1.71663009e+01])
          - np.array([-1.71341349e+01, 6.60528610e+01, 6.19162960e+01, -3.79691570e+01, 5.72957795e-15, -1.71341349e+01])) / (1.2/1000)
    
    vB = (np.array([-4.82100285e+01, 7.47944383e+01, 4.25252492e+01, -2.73196876e+01, 5.72957795e-15, -4.82100285e+01])
          - np.array([-4.81828115e+01, 7.47610811e+01, 4.25980378e+01, -2.73591189e+01, 5.72957795e-15, -4.81828115e+01])) / (1.2/1000)

    # timing config
    t_buff = 1.0
    durations = {
        'O1': 3.0, '1A': 1.2, 'AB': 1.2, 'B7': 1.2, '72': 1.2,
        '27': 1.2, '77': 0.8, '73a': 1.5, '73b': 0.8, '36': 1.2,
        '6A': 1.2, 'AB2': 1.2, 'B5': 1.2, '54': 1.2
    }

    # build trajectory planners
    vo1 = (q1 - q0) / durations['O1']
    planners = {
        '1A': until.quinticCurvePlanning(q1, qA, np.zeros(6), vA, durations['1A']),
        'AB': until.splinePlanning(qA_[:3], qB_[:3]),
        'B7': until.quinticCurvePlanning(qB, q7, vB, np.zeros(6), durations['B7']),
        '72': until.quinticCurvePlanning(q7, q2, np.zeros(6), np.zeros(6), durations['72']),
        '27': until.quinticCurvePlanning(q2, q7, np.zeros(6), np.zeros(6), durations['27']),
        '77': until.quinticCurvePlanning(q7, q7_prime, np.zeros(6), np.zeros(6), durations['77']),
        '73a': until.quinticCurvePlanning(q7_prime, q3_up, np.zeros(6), np.zeros(6), durations['73a']),
        '73b': until.quinticCurvePlanning(q3_up, q3, np.zeros(6), np.zeros(6), durations['73b']),
        '36': until.quinticCurvePlanning(q3, q6, np.zeros(6), np.zeros(6), durations['36']),
        '6A': until.quinticCurvePlanning(q6, qA, np.zeros(6), vA, durations['6A']),
        'B5': until.quinticCurvePlanning(qB, q5, vB, np.zeros(6), durations['B5']),
        '54': until.quinticCurvePlanning(q5, q4, np.zeros(6), np.zeros(6), durations['54'])
    }

    # calculate time checkpoints
    # format: (segment_name, duration, buffer_before, buffer_after)
    t_points = {}
    t_current = 0
    
    time_sequence = [
        ('O1', durations['O1'], False, True),
        ('1A', durations['1A'], False, False),
        ('AB', durations['AB'], False, False),
        ('B7', durations['B7'], False, False),
        ('72', durations['72'], False, False),
        ('27', durations['27'], False, False),
        ('77', durations['77'], False, False),
        ('73a', durations['73a'], False, False),
        ('73b', durations['73b'], False, True),
        ('36', durations['36'], False, False),
        ('6A', durations['6A'], False, False),
        ('AB2', durations['AB2'], False, False),
        ('B5', durations['B5'], False, False),
        ('54', durations['54'], False, False),
    ]
    
    for name, duration, buff_before, buff_after in time_sequence:
        if buff_before:
            t_current += t_buff
        t_points[name] = (t_current, t_current + duration)
        t_current += duration
        if buff_after:
            t_current += t_buff
    
    t_tot = t_current + 0.1

    # main control loop
    r.go_home()
    
    while True:
        start = time.time()
        
        if t >= t_tot:
            print('Control Finished')
            r.go_home()
            break

        # execute current segment based on time
        q = None
        print_dots = False
        
        if t_points['O1'][0] <= t < t_points['O1'][1]:
            q = vo1 * (t - t_points['O1'][0])
            print_dots = True
        
        elif t_points['1A'][0] <= t < t_points['1A'][1]:
            q = until.quinticCurveExcute(planners['1A'], t - t_points['1A'][0])
            print_dots = True
        
        elif t_points['AB'][0] <= t < t_points['AB'][1]:
            q = until.splineExcute(planners['AB'], t - t_points['AB'][0], durations['AB'])
            print_dots = True
        
        elif t_points['B7'][0] <= t < t_points['B7'][1]:
            q = until.quinticCurveExcute(planners['B7'], t - t_points['B7'][0])
        
        elif t_points['72'][0] <= t < t_points['72'][1]:
            q = until.quinticCurveExcute(planners['72'], t - t_points['72'][0])
        
        elif t_points['27'][0] <= t < t_points['27'][1]:
            q = until.quinticCurveExcute(planners['27'], t - t_points['27'][0])
        
        elif t_points['77'][0] <= t < t_points['77'][1]:
            q = until.quinticCurveExcute(planners['77'], t - t_points['77'][0])
        
        elif t_points['73a'][0] <= t < t_points['73a'][1]:
            q = until.quinticCurveExcute(planners['73a'], t - t_points['73a'][0])
        
        elif t_points['73b'][0] <= t < t_points['73b'][1]:
            q = until.quinticCurveExcute(planners['73b'], t - t_points['73b'][0])
        
        elif t_points['36'][0] <= t < t_points['36'][1]:
            q = until.quinticCurveExcute(planners['36'], t - t_points['36'][0])
        
        elif t_points['6A'][0] <= t < t_points['6A'][1]:
            q = until.quinticCurveExcute(planners['6A'], t - t_points['6A'][0])
        
        elif t_points['AB2'][0] <= t < t_points['AB2'][1]:
            q = until.splineExcute(planners['AB'], t - t_points['AB2'][0], durations['AB2'])
        
        elif t_points['B5'][0] <= t < t_points['B5'][1]:
            q = until.quinticCurveExcute(planners['B5'], t - t_points['B5'][0])
        
        elif t_points['54'][0] <= t < t_points['54'][1]:
            q = until.quinticCurveExcute(planners['54'], t - t_points['54'][0])

        if q is not None:
            if print_dots:
                print("... ")
            r.syncMove(np.reshape(q, (6, 1)))

        t = t + T

        end = time.time()
        spend_time = end - start
        if spend_time < T:
            time.sleep(T - spend_time)
        else:
            print("timeout!")

        q_array.append(r.syncFeedback())


if __name__ == '__main__':
    test()
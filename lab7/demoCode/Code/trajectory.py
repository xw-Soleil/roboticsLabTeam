import numpy as np
from numpy import pi
from IK_L_base import inv as inv_L

class Trajectory:
    def __init__(self, PointsPosition, PointsTime):
        self.Q = np.array(PointsPosition)
        self.T = np.array(PointsTime)
        self.N = len(PointsPosition)
        self.GetPointsVA()
        self.GetCoefficient()

    def GetCurvePosition(self, t):
        for i in range(self.N-1):
            if t < self.T[i+1]: 
                ans = []
                for j in range(7):
                    ans.append(np.dot(np.array(self.Coefficient)[i, :, j], [t**5, t**4, t**3, t**2, t, 1]))
                return ans
        return self.Q[self.N - 1] 

    def GetCoefficient(self):
        self.Coefficient = []
        for i in range(self.N - 1):
            self.QuinticPoly(i)

    '''
      Q: joint angle vector
      V: joint angle velocity
      A: joint angle acceleration 
      s = start
      e = end
    '''

    def QuinticPoly(self, k): 
        Ts = self.T[k]
        Te = self.T[k+1]
        Qs = self.Q[k]
        Qe = self.Q[k+1]
        Vs = self.V[k]
        Ve = self.V[k+1]
        As = self.A[k]
        Ae = self.A[k+1]
        A = np.array([
            [     Ts**5,      Ts**4,     Ts**3,     Ts**2,    Ts, 1], #q
            [ 5 * Ts**4,  4 * Ts**3, 3 * Ts**2, 2 * Ts,        1, 0], #v
            [20 * Ts**3, 12 * Ts**2, 6 * Ts,         2,        0, 0], #a
            [     Te**5,      Te**4,     Te**3,     Te**2,    Te, 1], #q
            [ 5 * Te**4,  4 * Te**3, 3 * Te**2, 2 * Te,        1, 0], #v
            [20 * Te**3, 12 * Te**2, 6 * Te,         2,        0, 0], #a
        ])
        b = np.array([Qs, Vs, As, Qe, Ve, Ae])
        self.Coefficient.append(np.linalg.solve(A, b))

    def GetPointsVA(self):
        self.V    = []
        self.A    = []
        for i in range(self.N):
            if i == 0 or i == self.N - 1: # 起终点速度为0
                v = np.array([0, 0, 0, 0, 0, 0, 0])
            else:
                v = (self.Q[i+1] - self.Q[i-1]) / (self.T[i+1] - self.T[i-1])
            self.V.append(v)
        for i in range(self.N):
            if i == 0 or i == self.N - 1: # 起终点加速度为0
                a = np.array([0, 0, 0, 0, 0, 0, 0])
            else:
                a = (self.V[i+1] - self.V[i-1]) / (self.T[i+1] - self.T[i-1])
            self.A.append(a)

    def GetStraightPosition(start, startX1, end, endX1, t, time):
        if t < time:
            xArray = start*(1-t/time) + end*t/time
            xangles = inv_L(xArray, startX1*(1-t/time) + endX1*t/time)
            x = xangles
        else:
            x = inv_L(end, endX1)
        for ans in x:
            for i in range(len(ans)):
                if(ans[i] > np.pi): ans[i] -= np.pi * 2
                if(ans[i] < -np.pi): ans[i] += np.pi * 2
            ans[1] = -ans[1]
            ans[2] = -ans[2]
            ans[3] = -ans[3]
            ans[5] = -ans[5]
            ans[6] = -ans[6]
            print(ans)
        ret = x[5]
        return ret

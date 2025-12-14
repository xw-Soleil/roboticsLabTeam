import numpy as np

class IKSolver:
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

        return ans/np.pi*180


if __name__ == "__main__":

    np.set_printoptions(suppress=True)

    end_lists = [[0.37, -0.09, 0.115, np.pi, 0, -np.pi/2],
                 [0.288, -0.288, 0.115, np.pi, 0, -np.pi/2]]

    iks = IKSolver()

    for end in end_lists:
        res = iks.solve(end)
        print(res)
    # print(res)

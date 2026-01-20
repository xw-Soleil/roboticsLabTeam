"""
RRT_star 
"""

import math
import random
import time
import numpy as np
import matplotlib.pyplot as plt
from scipy.spatial import KDTree

class Node:
    def __init__(self, x, y):
        self.x = x
        self.y = y
        self.path_x = []
        self.path_y = []
        self.parent = None
        self.cost = 0.0

class RRT_star:
    def __init__(self, minx, maxx, miny, maxy, obstacles, robot_size, safe_dist=0.1, path_smooth=True):
        self.min_x = minx
        self.max_x = maxx
        self.min_y = miny
        self.max_y = maxy
        self.path_smooth = path_smooth
        self.robot_radius = robot_size + safe_dist
        
        # kdtree加速查询
        clean_obstacles = [obs for obs in obstacles if obs[0] > -5000]
        if clean_obstacles:
            self.obs_tree = KDTree(clean_obstacles)
            self.obs_x = [x for (x, y) in clean_obstacles]
            self.obs_y = [y for (x, y) in clean_obstacles]
        else:
            self.obs_tree = None
            self.obs_x = []
            self.obs_y = []

        # RRT*参数
        self.expand_dis = 1.0
        self.goal_sample_rate = 10
        self.max_iter = 200
        self.connect_circle_dist = 8.0
        
        self.node_list = []
        self.start = None
        self.goal = None
        
        # 统计用
        self.planning_time = 0.0
        self.path_length = 0.0
        self.iteration_count = 0

    def plan(self, sx, sy, gx, gy, animation=False):
        """规划主函数"""
        start_time = time.time()
        
        self.start = Node(sx, sy)
        self.goal = Node(gx, gy)
        self.node_list = [self.start]

        for i in range(self.max_iter):
            rnd_node = self.get_random_node()
            nearest_ind = self.get_nearest_node_index(self.node_list, rnd_node)
            nearest_node = self.node_list[nearest_ind]
            new_node = self.steer(nearest_node, rnd_node, self.expand_dis)

            if self.check_collision(new_node):
                near_inds = self.find_near_nodes(new_node)
                new_node = self.choose_parent(new_node, near_inds)
                
                if new_node:
                    self.node_list.append(new_node)
                    self.rewire(new_node, near_inds)

            if animation and i % 5 == 0:
                self.draw_graph(rnd_node)

            if self.calc_dist_to_goal(self.node_list[-1].x, self.node_list[-1].y) <= self.expand_dis:
                final_node = self.steer(self.node_list[-1], self.goal, self.expand_dis)
                if self.check_collision(final_node):
                    self.iteration_count = i + 1
                    
                    path = self.generate_final_course(len(self.node_list) - 1)
                    if path and self.path_smooth:
                        path = self.smooth_path(path)
                    else:
                        path = path[::-1]
                    
                    self.planning_time = time.time() - start_time
                    self.path_length = self.calc_path_length(path)
                    
                    return True, path
        
        self.planning_time = time.time() - start_time
        self.iteration_count = self.max_iter
        self.path_length = 0.0

        return False, []

    def calc_path_length(self, path):
        """计算路径长度"""
        if len(path) < 2:
            return 0.0
        
        total_length = 0.0
        for i in range(len(path) - 1):
            dx = path[i+1][0] - path[i][0]
            dy = path[i+1][1] - path[i][1]
            total_length += math.hypot(dx, dy)
        
        return total_length
    
    def print_metrics(self):
        """打印统计"""
        print("\n" + "="*50)
        print("           路径规划定量分析结果")
        print("="*50)
        print(f"  规划算法:        RRT*")
        print(f"  最大迭代次数:    {self.max_iter}")
        print(f"  实际迭代次数:    {self.iteration_count}")
        print(f"  扩展步长:        {self.expand_dis:.2f} m")
        print(f"  重连半径:        {self.connect_circle_dist:.2f} m")
        print("-"*50)
        print(f"  计算时间:        {self.planning_time:.4f} 秒")
        print(f"  路径长度:        {self.path_length:.4f} m")
        print(f"  树节点数量:      {len(self.node_list)}")
        print("="*50 + "\n")
    
    def get_metrics(self):
        """返回统计dict"""
        return {
            'algorithm': 'RRT*',
            'max_iter': self.max_iter,
            'actual_iter': self.iteration_count,
            'expand_dis': self.expand_dis,
            'connect_circle_dist': self.connect_circle_dist,
            'planning_time': self.planning_time,
            'path_length': self.path_length,
            'node_count': len(self.node_list)
        }

    def get_random_node(self):
        """随机采样"""
        if random.randint(0, 100) > self.goal_sample_rate:
            rnd = Node(
                random.uniform(self.min_x, self.max_x),
                random.uniform(self.min_y, self.max_y)
            )
        else:
            rnd = Node(self.goal.x, self.goal.y)
        return rnd

    def get_nearest_node_index(self, node_list, rnd_node):
        """找最近节点"""
        dlist = [self.calc_distance_and_angle(node, rnd_node)[0] for node in node_list]
        min_index = dlist.index(min(dlist))
        return min_index

    def steer(self, from_node, to_node, extend_length=float("inf")):
        """从from向to延伸"""
        dis, theta = self.calc_distance_and_angle(from_node, to_node)
        actual_len = min(extend_length, dis)
        new_x = from_node.x + actual_len * math.cos(theta)
        new_y = from_node.y + actual_len * math.sin(theta)
        new_node = Node(new_x, new_y)
        new_node.parent = from_node
        new_node.cost = from_node.cost + actual_len
        return new_node

    def choose_parent(self, new_node, near_inds):
        """选最优父节点"""
        if not near_inds:
            return new_node
        
        for i in near_inds:
            potential_parent = self.node_list[i]
            if self.check_segment_collision(potential_parent.x, potential_parent.y, new_node.x, new_node.y):
                dis, _ = self.calc_distance_and_angle(potential_parent, new_node)
                temp_cost = potential_parent.cost + dis
                if temp_cost < new_node.cost:
                    new_node.parent = potential_parent
                    new_node.cost = temp_cost

        return new_node

    def rewire(self, new_node, near_inds):
        """重连优化"""
        for i in near_inds:
            near_node = self.node_list[i]
            if self.check_segment_collision(new_node.x, new_node.y, near_node.x, near_node.y):
                dis, _ = self.calc_distance_and_angle(new_node, near_node)
                temp_cost = new_node.cost + dis
                if temp_cost < near_node.cost:
                    near_node.parent = new_node
                    near_node.cost = temp_cost

    def find_near_nodes(self, new_node):
        nnode = len(self.node_list) + 1
        r = self.connect_circle_dist * math.sqrt(math.log(nnode) / nnode)
        r = min(r, self.expand_dis * 5.0)
        dist_list = [(node.x - new_node.x)**2 + (node.y - new_node.y)**2 for node in self.node_list]
        near_inds = [dist_list.index(i) for i in dist_list if i <= r**2]
        return near_inds

    def check_collision(self, node):
        """点碰撞检测"""
        if node is None: return False
        if self.obs_tree is None: return True 
        dist, _ = self.obs_tree.query([node.x, node.y])
        if dist <= self.robot_radius:
            return False 
        return True 

    def check_segment_collision(self, x1, y1, x2, y2):
        """线段碰撞检测"""
        dist = math.hypot(x2 - x1, y2 - y1)
        step = self.robot_radius 
        if dist < step: return self.check_collision(Node(x2, y2))
        
        n_step = int(dist / step)
        for i in range(n_step + 1):
            u = i / n_step
            x = x1 + (x2 - x1) * u
            y = y1 + (y2 - y1) * u
            if not self.check_collision(Node(x, y)):
                return False
        return True

    def calc_distance_and_angle(self, from_node, to_node):
        dx = to_node.x - from_node.x
        dy = to_node.y - from_node.y
        d = math.hypot(dx, dy)
        theta = math.atan2(dy, dx)
        return d, theta

    def calc_dist_to_goal(self, x, y):
        return math.hypot(x - self.goal.x, y - self.goal.y)

    def generate_final_course(self, goal_ind):
        path = [[self.goal.x, self.goal.y]]
        node = self.node_list[goal_ind]
        while node.parent is not None:
            path.append([node.x, node.y])
            node = node.parent
        path.append([node.x, node.y])
        return path  # goal->start顺序

    def draw_graph(self, rnd=None):
        plt.clf()
        if rnd is not None:
            plt.plot(rnd.x, rnd.y, "^k")
        
        for node in self.node_list:
            if node.parent:
                plt.plot([node.x, node.parent.x], [node.y, node.parent.y], "-g")
        
        plt.plot(self.obs_x, self.obs_y, ".k")
        plt.plot(self.start.x, self.start.y, "xr")
        plt.plot(self.goal.x, self.goal.y, "xr")
        plt.axis([self.min_x, self.max_x, self.min_y, self.max_y])
        plt.grid(True)
        plt.pause(0.01)
        
    def smooth_path(self, path):
        """路径平滑/剪枝"""
        if len(path) < 3:
            return path

        path_reversed = path[::-1]
        smoothed_path = [path_reversed[0]]
        current_index = 0

        while current_index < len(path_reversed) - 1:
            best_next_index = current_index + 1
            
            for test_index in range(len(path_reversed) - 1, current_index, -1):
                x1, y1 = path_reversed[current_index]
                x2, y2 = path_reversed[test_index]
                
                if self.check_segment_collision(x1, y1, x2, y2):
                    best_next_index = test_index
                    break
            
            smoothed_path.append(path_reversed[best_next_index])
            current_index = best_next_index
        
        return smoothed_path[::-1]


if __name__ == '__main__':
    print("Start RRT Star complex simulation")
    
    obs_list = []
    
    def add_rect_obs(x, y, w, h, step=0.2):
        for ix in np.arange(x, x + w, step):
            for iy in np.arange(y, y + h, step):
                obs_list.append((ix, iy))

    def add_circle_obs(x, y, r):
        for theta in np.arange(0, 2*math.pi, 0.1):
            obs_list.append((x + r*math.cos(theta), y + r*math.sin(theta)))
            obs_list.append((x + (r*0.7)*math.cos(theta), y + (r*0.7)*math.sin(theta)))
            obs_list.append((x + (r*0.4)*math.cos(theta), y + (r*0.4)*math.sin(theta)))

    # 边界墙
    add_rect_obs(-2, -2, 22, 1)
    add_rect_obs(-2, 17, 22, 1)
    add_rect_obs(-2, -2, 1, 20)
    add_rect_obs(19, -2, 1, 20)

    # S型迷宫
    add_rect_obs(5, -2, 1, 14) 
    add_rect_obs(10, 6, 1, 12)

    # C型陷阱
    add_rect_obs(14, 8, 4, 1)
    add_rect_obs(14, 14, 4, 1)
    add_rect_obs(17, 8, 1, 7)

    # 圆形障碍
    add_circle_obs(2.5, 6, 1.0)
    add_circle_obs(8, 14, 1.0)
    add_circle_obs(8, 3, 1.0)

    rrt_star = RRT_star(
        minx=-5, maxx=20, 
        miny=-5, maxy=20, 
        obstacles=obs_list, 
        robot_size=0.5,     
        safe_dist=0.1,
        path_smooth=True
    )
    
    rrt_star.max_iter = 1500 
    
    is_found, path = rrt_star.plan(sx=0, sy=0, gx=16, gy=11, animation=True)
    print("Path found: ", is_found)
    print(path)

    if is_found:
        print("Path found!")
        
        rrt_star.print_metrics()
        
        metrics = rrt_star.get_metrics()
        print("Metrics dict:", metrics)
        
        rrt_star.draw_graph()
        plt.plot([x for (x, y) in path], [y for (x, y) in path], '-r', linewidth=2)
        
        plt.title(f"RRT* Path Planning\nPath Length: {rrt_star.path_length:.2f} m | Time: {rrt_star.planning_time:.4f} s")
        
        plt.show()
    else:
        print("Path not found")
        rrt_star.print_metrics()
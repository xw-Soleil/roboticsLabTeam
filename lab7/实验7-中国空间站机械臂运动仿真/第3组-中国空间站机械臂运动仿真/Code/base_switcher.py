"""
机器人基座切换模块: 在左臂基座和右臂基座之间切换参考坐标系
"""


def change_base_LtoR(sim):
    """
    从左基座切换到右基座为参考系
    重新组织机器人的父子关系链，使右基座成为根节点
    Args:
        sim: CoppeliaSim仿真对象
    """
    # 获取左臂组件句柄
    l_base = sim.getObject('./L_Base')
    l_joint1 = sim.getObject('./L_Joint1')
    l_link1 = sim.getObject('./L_Link1')
    l_joint2 = sim.getObject('./L_Joint2')
    l_link2 = sim.getObject('./L_Link2')
    l_joint3 = sim.getObject('./L_Joint3')
    l_link3 = sim.getObject('./L_Link3')

    # 获取中间连接关节
    joint4 = sim.getObject('./Joint4')

    # 获取右臂组件句柄
    r_base = sim.getObject('./R_Base')
    r_joint1 = sim.getObject('./R_Joint1')
    r_link1 = sim.getObject('./R_Link1')
    r_joint2 = sim.getObject('./R_Joint2')
    r_link2 = sim.getObject('./R_Link2')
    r_joint3 = sim.getObject('./R_Joint3')
    r_link3 = sim.getObject('./R_Link3')

    # 重建层级关系: 右臂为根节点
    # keep_in_place=True，保持物体在世界坐标系中的位置不变
    sim.setObjectParent(r_base, -1, 1)  # 右基座设为根节点
    sim.setObjectParent(r_joint1, r_base, 1)
    sim.setObjectParent(r_link1, r_joint1, 1)
    sim.setObjectParent(r_joint2, r_link1, 1)
    sim.setObjectParent(r_link2, r_joint2, 1)
    sim.setObjectParent(r_joint3, r_link2, 1)
    sim.setObjectParent(r_link3, r_joint3, 1)

    # 连接中间关节
    sim.setObjectParent(joint4, r_link3, 1)

    # 连接左臂(反向)
    sim.setObjectParent(l_link3, joint4, 1)
    sim.setObjectParent(l_joint3, l_link3, 1)
    sim.setObjectParent(l_link2, l_joint3, 1)
    sim.setObjectParent(l_joint2, l_link2, 1)
    sim.setObjectParent(l_link1, l_joint2, 1)
    sim.setObjectParent(l_joint1, l_link1, 1)
    sim.setObjectParent(l_base, l_joint1, 1)


def change_base_RtoL(sim):
    """
    从右基座切换到左基座为参考系
    重新组织机器人的父子关系链，使左基座成为根节点
    """
    # 获取右臂组件句柄
    r_base = sim.getObject('./R_Base')
    r_joint1 = sim.getObject('./R_Joint1')
    r_link1 = sim.getObject('./R_Link1')
    r_joint2 = sim.getObject('./R_Joint2')
    r_link2 = sim.getObject('./R_Link2')
    r_joint3 = sim.getObject('./R_Joint3')
    r_link3 = sim.getObject('./R_Link3')

    # 获取中间连接关节
    joint4 = sim.getObject('./Joint4')

    # 获取左臂组件句柄
    l_base = sim.getObject('./L_Base')
    l_joint1 = sim.getObject('./L_Joint1')
    l_link1 = sim.getObject('./L_Link1')
    l_joint2 = sim.getObject('./L_Joint2')
    l_link2 = sim.getObject('./L_Link2')
    l_joint3 = sim.getObject('./L_Joint3')
    l_link3 = sim.getObject('./L_Link3')

    # 重建层级关系:左臂为根节点
    sim.setObjectParent(l_base, -1, 1)  # 左基座设为根节点
    sim.setObjectParent(l_joint1, l_base, 1)
    sim.setObjectParent(l_link1, l_joint1, 1)
    sim.setObjectParent(l_joint2, l_link1, 1)
    sim.setObjectParent(l_link2, l_joint2, 1)
    sim.setObjectParent(l_joint3, l_link2, 1)
    sim.setObjectParent(l_link3, l_joint3, 1)

    # 连接中间关节
    sim.setObjectParent(joint4, l_link3, 1)

    # 连接右臂(反向)
    sim.setObjectParent(r_link3, joint4, 1)
    sim.setObjectParent(r_joint3, r_link3, 1)
    sim.setObjectParent(r_link2, r_joint3, 1)
    sim.setObjectParent(r_joint2, r_link2, 1)
    sim.setObjectParent(r_link1, r_joint2, 1)
    sim.setObjectParent(r_joint1, r_link1, 1)
    sim.setObjectParent(r_base, r_joint1, 1)

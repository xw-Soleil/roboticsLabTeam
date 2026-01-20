def change_base_LtoR(sim):

    l_base = sim.getObject('./L_Base')
    l_joint1 = sim.getObject('./L_Joint1')
    l_link1 = sim.getObject('./L_Link1')
    l_joint2 = sim.getObject('./L_Joint2')
    l_link2 = sim.getObject('./L_Link2')
    l_joint3 = sim.getObject('./L_Joint3')
    l_link3 = sim.getObject('./L_Link3')

    joint4 = sim.getObject('./Joint4')

    r_base = sim.getObject('./R_Base')
    r_joint1 = sim.getObject('./R_Joint1')
    r_link1 = sim.getObject('./R_Link1')
    r_joint2 = sim.getObject('./R_Joint2')
    r_link2 = sim.getObject('./R_Link2')
    r_joint3 = sim.getObject('./R_Joint3')
    r_link3 = sim.getObject('./R_Link3')

    sim.setObjectParent(r_base, -1, 1)
    sim.setObjectParent(r_joint1, r_base, 1)
    sim.setObjectParent(r_link1, r_joint1, 1)
    sim.setObjectParent(r_joint2, r_link1, 1)
    sim.setObjectParent(r_link2, r_joint2, 1)
    sim.setObjectParent(r_joint3, r_link2, 1)
    sim.setObjectParent(r_link3, r_joint3, 1)

    sim.setObjectParent(joint4, r_link3, 1)

    sim.setObjectParent(l_link3, joint4, 1)
    sim.setObjectParent(l_joint3, l_link3, 1)
    sim.setObjectParent(l_link2, l_joint3, 1)
    sim.setObjectParent(l_joint2, l_link2, 1)
    sim.setObjectParent(l_link1, l_joint2, 1)
    sim.setObjectParent(l_joint1, l_link1, 1)
    sim.setObjectParent(l_base, l_joint1, 1)

def change_base_RtoL(sim):
    r_base = sim.getObject('./R_Base')
    r_joint1 = sim.getObject('./R_Joint1')
    r_link1 = sim.getObject('./R_Link1')
    r_joint2 = sim.getObject('./R_Joint2')
    r_link2 = sim.getObject('./R_Link2')
    r_joint3 = sim.getObject('./R_Joint3')
    r_link3 = sim.getObject('./R_Link3')

    joint4 = sim.getObject('./Joint4')

    l_base = sim.getObject('./L_Base')
    l_joint1 = sim.getObject('./L_Joint1')
    l_link1 = sim.getObject('./L_Link1')
    l_joint2 = sim.getObject('./L_Joint2')
    l_link2 = sim.getObject('./L_Link2')
    l_joint3 = sim.getObject('./L_Joint3')
    l_link3 = sim.getObject('./L_Link3')

    sim.setObjectParent(l_base, -1, 1)
    sim.setObjectParent(l_joint1, l_base, 1)
    sim.setObjectParent(l_link1, l_joint1, 1)
    sim.setObjectParent(l_joint2, l_link1, 1)
    sim.setObjectParent(l_link2, l_joint2, 1)
    sim.setObjectParent(l_joint3, l_link2, 1)
    sim.setObjectParent(l_link3, l_joint3, 1)

    sim.setObjectParent(joint4, l_link3, 1)

    sim.setObjectParent(r_link3, joint4, 1)
    sim.setObjectParent(r_joint3, r_link3, 1)
    sim.setObjectParent(r_link2, r_joint3, 1)
    sim.setObjectParent(r_joint2, r_link2, 1)
    sim.setObjectParent(r_link1, r_joint2, 1)
    sim.setObjectParent(r_joint1, r_link1, 1)
    sim.setObjectParent(r_base, r_joint1, 1)
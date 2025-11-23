# Lab5Group3 - 世界坐标系下的轨迹规划

```txt
Lab5Group3/
├── Lab5Group3Position/                   # 位置控制
│   ├── group3_position.ttt               # CoppeliaSim 仿真工程文件
│   └── lab5_group3_position.py           # 位置控制主程序
├── Lab5Group3Velocity/                   # 速度控制
│   ├── Lab5Group3Velocity.ttt            # CoppeliaSim 仿真工程文件
│   ├── jacobi_zjui.cp310-win_amd64.pyd   # 编译后的雅可比模块pyd文件
│   └── Code/
│       ├── scriptVelocity.py             # 速度控制主程序
│       └── Jacobbi_generate/             # 雅可比矩阵C++模块
│           ├── jacobi_core.h             # 雅可比矩阵核心头文件
│           ├── jacobi_core.cpp           # 雅可比矩阵核心实现
│           ├── jacobi_zjui_module.cpp    # pybind11绑定模块
│           ├── setup.py                  # 模块构建脚本
│           ├── jacobi_zjui.cp310-win_amd64.pyd  # 编译输出
│           └── build/                    # 构建中间文件
├── Report/                               # 项目报告
│   ├── lab5bx.typ
│   ├── Lab5Group3.pdf
│   ├── lab5_report-jjk.typ
│   ├── template.typ
│   ├── images/                           # 图片资源
│   │   ├── arm.jpg
│   │   ├── dynamicmode.png
│   │   ├── gravity.png
│   │   ├── pic.typ
│   │   ├── velocity.png
│   │   ├── ZJU-Banner2.png
│   │   ├── （位置控制）圆形曲线.png
│   │   ├── （位置控制）圆形结果.png
│   │   ├── （位置控制）圆锥曲线.png
│   │   ├── （位置控制）圆锥结果.png
│   │   ├── （位置控制）正方形曲线.png
│   │   ├── （位置控制）正方形结果.png
│   │   └── velocityCtrl/
│   │       ├── circle.png
│   │       ├── circleDataPos.png
│   │       ├── circleDataVel.png
│   │       ├── cone.png
│   │       ├── ConeDataPos.png
│   │       ├── ConeDataVel.png
│   │       ├── dynamicmode.png
│   │       ├── gravity.png
│   │       ├── square.png
│   │       ├── squareDataPos.png
│   │       ├── squareDataVel.png
│   │       └── velocity.png
│   └── 导入函数库/
│       ├── individual.typ
│       ├── lib_academic.typ
│       ├── mDateTime.typ
│       ├── PageLib.typ
│       ├── RedNote.typ
│       ├── ref.bib
│       ├── template.typ
│       └── TimeLine.typ
├── 仿真结果视频/                           # 演示视频
│   ├── (位置控制)正方形.mp4
│   ├── (位置控制)圆形.mp4
│   ├── (位置控制)圆锥.mp4
│   ├── (速度控制)正方形.mp4
│   ├── (速度控制)圆形.mp4
│   └── (速度控制)圆锥.mp4
├── Lab5Group3.pdf                        # 项目报告
└── README.md                             # 项目说明
```

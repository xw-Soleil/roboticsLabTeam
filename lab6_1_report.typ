#import "导入函数库/lib_academic.typ": *
#show: codly-init.with()    // 初始化codly，每个文档只需执行一次
#codly(languages: codly-languages)  // 配置codly
#show table: three-line-table

#show: project.with(
  title: "实验6：机械臂实物实验-世界坐标系下轨迹规划
",
  author: "第3组 金加康 吴必兴 沈学文 钱满亮 赵钰泓 项科深",
  // date: auto,
  cover_name: "机械臂实物实验-世界坐标系下轨迹规划
",
  cover_subname: "机器人技术与实践实验报告",
  school_id: "第三组",
  course: "机器人技术与实践",
  teacher: "周春琳",
  cover_date: "2025年12月15日",
  author_cover: "金加康 吴必兴 沈学文 钱满亮 赵钰泓 项科深",

  // abstract: [基于ZJU-I型机械臂的笛卡尔空间轨迹规划实验。],
  // keywords: ("机械臂", "轨迹规划", "笛卡尔空间"),
)

// 定义部分标题（不参与编号，但会出现在目录中）
#let part(body) = {
  heading(level: 1, numbering: none, outlined: true)[#body]
  counter(heading).update(0)
}

// 设置无编号一级标题的样式（只影响正文，不影响目录）
#show heading.where(level: 1, numbering: none): it => {
  align(center)[
    #text(size: 1.2em)[#it]
  ]
}



= 实验任务与分工

== 实验目的
+ 学习并掌握实物机械臂的基本操作方法。
+ 了解ZJU-I型机械臂的基本结构和工作原理。
+ 学习使用Python语言+串口对机器人进行控制。

== 任务要求
+ 实现对ZJU-I型机械臂的控制。
+ 将实验5中的轨迹规划程序移植到实物机械臂上运行，完成画圆、画方、圆锥绘制任务。

== 小组分工

+ 代码与实物调试：金加康、吴必兴、沈学文、赵钰泓、项科深
+ 报告撰写：沈学文、吴必兴、金加康

= 实验结果与分析

== 实验结果
通过对ZJU-I型机械臂的控制，成功实现了实物机械臂按照预定轨迹绘制圆形、方形和圆锥的任务。具体结果如下：
#tip[
  具体实验结果请参考上传的视频文件夹，下图仅展示部分关键帧截图。
]

+ *机械臂圆形绘制任务与仿真对比*
  #figure(
    numbering: none,
    grid(
      columns: (auto, auto, auto, auto, auto),
      column-gutter: 0.5em,
      align: horizon,
      figure(
        image("images/lab6/开始绘制_圆.png", height: 6cm),
        caption: [圆形过程1],
      ),
      figure(
        image("images/lab6/绘制过程_圆.png", height: 6cm),
        caption: [圆形过程2],
      ),
      figure(
        image("images/lab6/goHome_圆.png", height: 6cm),
        caption: [机械臂归位],
      ),
      figure(
        image("images/velocityCtrl/circle.png", height: 6cm),
        caption: [仿真对比图],
      ),
    ),
  )

+ *机械臂正方形绘制任务*
  #figure(
    numbering: none,
    grid(
      columns: (auto, auto, auto, auto, auto),
      column-gutter: 0.5em,
      align: horizon,
      figure(
        image("images/lab6/开始绘制_方.png", height: 6cm),
        caption: [方形过程1],
      ),
      figure(
        image("images/lab6/绘制过程_方.png", height: 6cm),
        caption: [方形过程2],
      ),
      figure(
        image("images/lab6/绘制过程2_方.png", height: 6cm),
        caption: [方形过程3],
      ),
      figure(
        image("images/lab6/goHome_方.png", height: 6cm),
        caption: [机械臂归位],
      ),
      figure(
        image("images/velocityCtrl/squareCut.png", height: 6cm),
        caption: [仿真对比图],
      ),
    ),
  )


+ *机械臂圆锥轨迹绘制任务*
  #figure(
    numbering: none,
    grid(
      columns: (auto, auto, auto, auto, auto),
      column-gutter: 0.5em,
      align: horizon,
      figure(
        image("images/lab6/圆锥过程1.png", height: 6cm),
        caption: [圆锥过程1],
      ),
      figure(
        image("images/lab6/圆锥过程2.png", height: 6cm),
        caption: [圆锥过程2],
      ),
      figure(
        image("images/lab6/圆锥过程3.png", height: 6cm),
        caption: [圆锥过程3],
      ),
      figure(
        image("images/lab6/圆锥过程4.png", height: 6cm),
        caption: [圆锥过程4],
      ),
      figure(
        image("images/（位置控制）圆锥结果.png", height: 6cm),
        caption: [仿真对比图],
      ),
    ),
  )


== 结果分析

+ 对于*圆形轨迹*绘制任务，机械臂能够平滑地沿预定轨迹运动，圆形轮廓清晰，与仿真实验误差较小，整体形状符合预期。
+ 对于*正方形轨迹*绘制任务，机械臂在转角处的速度控制较好，能够准确到达各个顶点位置，与仿真实验误差较小，整体形状符合预期。
+ 对于*圆锥轨迹*绘制任务，机械臂能够实现从底部到顶部的平滑过渡，圆锥形状明显，与仿真实验误差较小，整体形状符合预期。

#note[
  实际调试过程中，与仿真实验代码相比，由于圆锥绘制轨迹角度变化较大，因此在根据实际实物机械臂调整顶点坐标后，机械臂才可在规定最大旋转角度范围之内完成圆锥轨迹绘制任务。
]

= 实验原理
由于实物机械臂的控制只支持位置控制接口，因此本实验主要通过位置控制方式实现轨迹跟踪。具体方法在本小组的实验五世界坐标系下的轨迹规划的仿真实验报告中已有阐述，此处不再赘述。

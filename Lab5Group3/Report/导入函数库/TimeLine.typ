/*
 * 名称：TimeLine
 * 描述：用于创建竖向时间轴的自定义模块
 * 作者：巽星石
 * 创建时间：2025年6月10日
 * 最后修改：2025年6月29日
 */

// 页面函数
#let time_line_page = page.with(
  background: [
    #place(top, dx: 3.5cm, dy: 1cm)[
      #line(start: (0cm, 0cm), angle: 90deg, length: 100% - 3cm, stroke: (dash: "dashed", paint: gray))
    ]
  ],
)

// 纵向时间轴的时间节点
#let time_node(date, title, ctn) = [
  #table(columns: 3, stroke: none, inset: 0pt)[
    #block(width: 2cm, clip: true, inset: 5pt, radius: 5pt, fill: luma(220))[
      #align(center)[#text(size: 10pt)[#date]]
    ]
  ][
    #block(width: 1cm, inset: 5pt)[
      #align(center + horizon)[
        #place(dy: 4pt)[ #line(start: (-5pt, 0pt), length: 100% + 10pt, stroke: luma(200))]
        #circle(radius: 4pt, fill: gray.darken(50%))
      ]
    ]
  ][
    // 内容
    #block(width: 100%, fill: luma(87.84%), radius: 5pt, inset: 10pt)[
      #(
        if title != "" [
          #block[#text(size: 16pt, fill: rgb("#c00000"))[【#title】]]
        ]
      )
      #text(size: 11pt)[#ctn]
    ]
  ]
]

#import "../导入函数库/PageLib.typ": *
#import "../导入函数库/TimeLine.typ": *
// #import "../导入函数库/RedNote.typ": *
#import "../导入函数库/mDateTime.typ": *
#import "@preview/cetz:0.3.0"
#import "@preview/gentle-clues:1.2.0": *
#import "@preview/showybox:2.0.4": showybox
#import "@preview/codly:1.3.0": *            // 导入codly包
#import "@preview/codly-languages:0.1.7": *  // 导入codly配套包codly-languages
#import "@preview/tablex:0.0.9": tablex, colspanx, rowspanx, hlinex, vlinex, cellx
#let my_red = rgb("#c00000")
#let my_green = rgb("#00c000")
#let my_blue = rgb("#0622f1")
#let reder(body) = {
  set text(fill: my_red)
  body
}
#let greener(body) = {
  set text(fill: my_green)
  body
}
#let bluer(body) = {
  set text(fill: my_blue)
  body
}

// ================================
// 字体配置
// ================================
#let font = (
  // 中文字体 - 使用你系统中已有的
  zh_shusong: "Source Han Serif SC VF",    // 思源宋体（已安装）
  zh_zhongsong: "STSong",                  // 华文中宋（已有）
  zh_kai: "Kaiti SC",                      // 楷体（已有）
  zh_hei: "Source Han Sans SC VF",         // 思源黑体（已安装）
  zh_fangsong: "STFangsong",               // 华文仿宋（已有）
  zh_handwriting: "HanziPen SC",           // 翩翩体手写字（已有）
  
  // 英文字体
  en_sans_serif: "Helvetica Neue",      // 系统自带
  en_serif: "Times New Roman",          // 系统自带
  en_typewriter: "Courier New",         // 系统自带
  en_code: "Menlo",                     // 系统自带的编程字体
)
// ================================
// 字号配置
// ================================

#let font-size = (
  n2: 18pt, // 二号
  s2: 17pt, // 小二
  n3: 16pt, // 三号
  s3: 15pt, // 小三
  n4: 14pt, // 四号
  s4: 12pt, // 小四
  n5: 10.5pt, // 五号
  s5: 9pt, // 小五
)

// ================================
// 样式配置
// ================================
// 

#let fakebold(content) = {
  set text(stroke: 0.02857em) // https://gist.github.com/csimide/09b3f41e838d5c9fc688cc28d613229f
  content
}



#let _underlined_cell(content, color: black) = {
  tablex(
    align: center + horizon,
    stroke: 0pt,
    inset: 0.75em,
    map-hlines: h => {
      if (h.y > 0) {
        (..h, stroke: 0.5pt + color)
      } else {
        h
      }
    },
    columns: 1fr,
    content,
  )
}

#let config = (
  // 字号设置
  title-size: font-size.s2,
  title1-size: font-size.n4,
  title2-size: font-size.s4,
  title3-size: font-size.n5,
  text-size: font-size.n5,
  author-size: font-size.n5,
  // 字体设置
  title-font: (font.en_serif, font.zh_hei),
  author-font: (font.en_sans_serif, font.zh_kai),
  body-font: (font.en_serif, font.zh_shusong),
  heading-font: (font.en_serif, font.zh_zhongsong),
  caption-font: (font.en_serif, font.zh_kai),
  header-font: (font.en_serif, font.zh_kai),
  strong-font: (font.en_serif, font.zh_hei),
  emph-font: (font.en_serif, font.zh_kai),
  raw-font: (font.en_code, font.zh_hei),
  // 间距设置
  spacing: 1.5em,
  leading: 1em,
  indent: 2em,
  small-space: 1em,
  block-space: 0.75em,
  // 颜色设置
  problem-color: rgb(241, 241, 255),
  summary-color: rgb(240, 248, 255),
  // 列表样式
  list-marker: ([•], [◦], [▶]),
  enum-numbering: ("1.", "(1)", "①", "a.", "i."),
  // 表格样式
  table-stroke: 0.08em,
  table-header-stroke: 0.05em,
)

// ================================
// 工具函数
// ================================

// 解决首段缩进问题的空白段
#let fake-par = {
  par(box())
  v(-config.spacing)
}

// 偏微分符号
#let pardiff(x, y) = $frac(partial #x, partial #y)$

// ================================
// 标注框函数
// ================================
#let callout(
  title: "",
  color: blue,
  size: 1em,
  content,
) = {
  let _inset = 0.8em
  let _color = color.darken(5%)
  v(0.2em)
  block(
    below: 1em,
    fill: color.lighten(100%),
    width: 100%,
    inset: _inset,
    radius: 5pt,
    stroke: 1pt + _color,
  )[
    #place(
      top + left,
      dy: -7pt - _inset,
      dx: 8pt - _inset,
      block(fill: white, inset: 2pt)[
        #set text(fill: _color, size)
        #title
      ],
    )
    #set text(fill: _color)
    #set par(first-line-indent: 0em)
    #content
  ]
}

#let callout-styles = (
  solution: (title: "Solution", it) => callout(title: title, color: rgb("#000000"))[#it],
  example: (title: "Example", it) => callout(title: title, color: rgb(100, 100, 100))[#it],
  proof: (title: "Proof", it) => callout(title: title, color: rgb(120, 120, 120))[#it],
  abstract: (title: "Abstract", it) => callout(title: title, color: rgb(0, 133, 143))[#it],
  summary: (title: "Summary", it) => callout(title: title, color: rgb(0, 133, 143))[#it],
  info: (title: "Info", it) => callout(title: title, color: rgb(68, 115, 218))[#it],
  note: (title: "Note", it) => callout(title: title, color: rgb(68, 115, 218))[#it],
  tip: (title: "Tip", it) => callout(title: title, color: rgb(0, 133, 91))[#it],
  hint: (title: "Hint", it) => callout(title: title, color: rgb(0, 133, 91))[#it],
  success: (title: "Success", it) => callout(title: title, color: rgb(62, 138, 0))[#it],
  important: (title: "Important", it) => callout(title: title, color: rgb(62, 138, 0))[#it],
  help: (title: "Help", it) => callout(title: title, color: rgb(153, 110, 36))[#it],
  warning: (title: "Warning", it) => callout(title: title, color: rgb("#e17909"))[#it],
  attention: (title: "Attention", it) => callout(title: title, color: rgb(216, 58, 49))[#it],
  caution: (title: "Caution", it) => callout(title: title, color: rgb(216, 58, 49))[#it],
  failure: (title: "Failure", it) => callout(title: title, color: rgb(216, 58, 49))[#it],
  danger: (title: "Danger", it) => callout(title: title, color: rgb(216, 58, 49))[#it],
  error: (title: "Error", it) => callout(title: title, color: rgb(216, 58, 49))[#it],
  bug: (title: "Bug", it) => callout(title: title, color: rgb(204, 51, 153))[#it],
  quote: (title: "Quote", it) => callout(title: title, color: rgb(132, 90, 231))[#it],
  cite: (title: "Cite", it) => callout(title: title, color: rgb(132, 90, 231))[#it],
  experiment: (title: "Experiment", it) => callout(title: title, color: rgb(132, 90, 231))[#it],
  question: (title: "Question", it) => callout(title: title, color: rgb(132, 90, 231))[#it],
  analysis: (title: "Analysis", it) => callout(title: title, color: rgb(0, 133, 91))[#it],
)

// shorthand for callout
#let c = callout-styles

// ================================
// 学术组件
// ================================

// 通用框组件
#let custom-block(
  title: none,
  color: rgb(245, 245, 245),
  it,
) = {
  set text(font: config.body-font)
  let body = if title != none {
    strong(title) + h(config.block-space) + it
  } else {
    it
  }

  block(
    fill: color,
    inset: 8pt,
    radius: 2pt,
    width: 100%,
    body,
  )
  fake-par
}

// 题目框
#let problem-counter = counter("problem")
#let problem = custom-block.with(
  title: [
    #problem-counter.step()
    题目 #context problem-counter.display().
  ],
  color: config.problem-color,
)

// 解答框
#let solution(it) = {
  set enum(numbering: "(1)")
  let body = [*解答.*] + h(config.block-space) + it
  block(
    inset: 8pt,
    below: config.leading,
    width: 100%,
    body,
  )
  fake-par
}

// 总结框
#let summary = custom-block.with(
  title: [总结.],
  color: config.summary-color,
)

// 三线表格
#let three-line-table(it) = {
  if it.children.any(c => c.func() == table.hline) {
    return it
  }

  let meta = it.fields()
  meta.stroke = none
  meta.remove("children")

  let header = it.children.find(c => c.func() == table.header)
  let cells = it.children.filter(c => c.func() == table.cell)

  if header == none {
    let columns = meta.columns.len()
    header = table.header(..cells.slice(0, columns))
    cells = cells.slice(columns)
  }

  return table(
    ..meta,
    table.hline(stroke: config.table-stroke),
    header,
    table.hline(stroke: config.table-header-stroke),
    ..cells,
    table.hline(stroke: config.table-stroke),
  )
}

// 标题
#let make-title(
  title: "",
  author: "",
  date: none,
  abstract: none,
  keywords: (),
) = {
  // 主标题
  align(center)[
    #block(
      text(
        font: config.title-font,
        weight: "bold",
        config.title-size,
        title,
      ),
    )
    #v(0.5em)
  ]

  // 作者
  if author != "" {
    set text(config.author-size, font: config.author-font)
    v(-0.5em)
    align(center, author)
    v(-0.5em)
  }

  // 日期
  if date != none {
    date = if date == auto {
      datetime.today().display("[year]年[month]月[day]日")
    } else {
      date
    }
    set text(config.author-size, font: config.author-font)
    align(center, date)
  }

  // 摘要和关键词
  if abstract != none [
    #v(2pt)
    *摘要：* #abstract

    #if keywords != () [
      *关键字：* #keywords.join("；")
    ]
    #v(2pt)
  ]
}

// ================================
// 主模板函数
// ================================

#let project(
  title: "",
  author: "",
  date: none,
  abstract: none,
  keywords: (),
  cover_name: "浙江大学课程实验报告模板",
  cover_subname: "ZJU Academic Report Template",
  course: none,
  name: none,
  school_id: none,
  college: none,
  major: none,
  place: none,
  teacher: none,
  body,
) = {
  // 文档设置
  set document(author: author, title: title, date: date, keywords: keywords)

  // 页面设置
  set page(
    // numbering: "1", // 设置页码
    number-align: center,
    margin: (
      // 页面边距
      x: 15mm, // 水平边距
      y: 25mm, // 垂直边距
    ),
  )

  // 基础样式设置
  set heading(numbering: "1.1.1")
  set text(
    font: config.body-font,
    lang: "zh",
    region: "cn",
    size: config.text-size,
  )
  set par(
    first-line-indent: config.indent,
    justify: true,
    leading: config.leading,
    spacing: config.spacing,
  )
  set bibliography(style: "gb-7714-2015-numeric")
  set enum(
    indent: config.indent,
    full: true,
    numbering: (..n) => {
      n = n.pos()
      let level = n.len()
      let number = config.enum-numbering.at(level - 1, default: "1.")
      numbering(number, ..n.slice(level - 1))
    },
  )
  set list(
    indent: config.indent,
    marker: config.list-marker,
  )
  set math.equation(numbering: "(1)")
  set underline(evade: false)

  // ================================
  // 标题样式
  // ================================

  show heading: it => {
    set text(font: config.heading-font)
    let body = if it.numbering != none {
      counter(heading).display() + h(config.small-space) + it.body
    } else {
      it.body
    }
    box(width: 100%, body)
  }

  show heading.where(level: 1): it => {
    // v(-0.5em)
    set align(center)
    set heading(numbering: "§ 1")
    set text(config.title1-size)
    it
    // v(-0.25em)
  }

  show heading.where(level: 2): it => {
    v(-1.25em)
    set text(config.title2-size)
    it
    v(-0.25em)
  }

  show heading.where(level: 3): it => {
    v(-1em)
    set text(config.title3-size)
    it
    v(-0.25em)
  }

  show heading.where(level: 4): it => {
    v(-1.08em)
    set text(config.title4-size)
    it
    v(-0.25em)
  }

  // ================================
  // 元素样式
  // ================================

  // 数学公式：无标签则不编号
  show math.equation: it => {
    set block(breakable: true)
    if it.block and not it.has("label") [
      #counter(math.equation).update(v => v - 1)
      #math.equation(it.body, block: true, numbering: none)#label("")
    ] else {
      it
    }
  }

  // 图表样式
  show figure: it => {
    set block(breakable: true)
    set text(font: config.caption-font)
    it + fake-par
  }
  show figure.where(kind: table): set figure.caption(position: top)
  show table: it => {
    set text(font: config.body-font)
    it + fake-par
  }
  show image: it => it + fake-par

  // 列表样式
  show list: it => {
    set list(indent: 0em)
    set enum(indent: 0em)
    it + fake-par
  }
  show enum: it => {
    set list(indent: 0em)
    set enum(indent: 0em)
    it + fake-par
  }
  show terms: it => {
    set text(font: config.caption-font)
    it + fake-par
  }

  // 文字样式
  show strong: set text(font: config.strong-font)
  show emph: set text(font: config.emph-font)
  show ref: set text(red)
  show link: it => {
    set text(blue)
    underline(it)
  }

  // ================================
  // 文档标题部分
  // ================================
  // make-title(
  //   title: title,
  //   author: author,
  //   date: date,
  //   abstract: abstract,
  //   keywords: keywords,
  // )

  // 添加
  set page(numbering: "1 / 1")

  // 添加页眉和页脚
  set page(
    header: context {
      set text(font: config.header-font)
      grid(
        columns: (1fr, 1fr),
        align(left, title), align(right, counter(page).display("1 / 1", both: true)),
      )
      v(-1.2em)
      line(stroke: 1pt + gray, length: 100%)
    },
    footer: context {
      set text(font: config.header-font)
      let headings = query(heading.where(level: 1, outlined: true).before(here()))
      if headings.len() == 0 {
        return
      }
      let level = counter(heading.where(level: 1)).display("1")
      let heading = level + h(config.small-space) + text(size: config.text-size)[#headings.last().body]

      line(stroke: 1pt + gray, length: 100%)
      v(-1.2em)
      grid(
        columns: (1fr, 1fr),
        align(left, author), align(right, heading),
      )
    },
  )

  set page(numbering: none)
    v(1fr)
    align(center, image("../images/ZJU-Banner2.png", width: 100%))
    align(center)[
      #set text(size: 26pt)
      #fakebold[#cover_name]
      #v(0.5cm)
      #set text(size: 17pt)
      #cover_subname
    ]
    v(2fr)
    let rows = ()
    if (course != none) {
      rows.push("课程名称")
      rows.push(course)
    }
    if (name != none) {
      rows.push("实验名称")
      rows.push(name)
    }
    if (author != none) {
      rows.push([小组成员])
      rows.push(author)
    }
    if (school_id != none) {
      rows.push([组$space.quad space.quad$号])
      rows.push(school_id)
    }
    if (college != none) {
      rows.push([学$space.quad space.quad$院])
      rows.push(college)
    }
    if (major != none) {
      rows.push([专$space.quad space.quad$业])
      rows.push(major)
    }
    if (place != none) {
      rows.push([实验地点])
      rows.push(place)
    }
    if (teacher != none) {
      rows.push([指导教师])
      rows.push(teacher)
    }
    if (date != none) {
      rows.push([报告日期])
      rows.push(date)
    }
    align(
      center,
      box(width: 75%)[
        #set text(size: 1.2em)
        #tablex(
          columns: (6.5em + 5pt, 1fr),
          align: center + horizon,
          stroke: 0pt,
          // stroke: 0.5pt + red, // this line is just for testing
          inset: 1pt,
          map-cells: cell => {
            if (cell.x == 0) {
              _underlined_cell([#cell.content#"："], color: white)
            } else {
              _underlined_cell(cell.content, color: black)
            }
          },
          ..rows,
        )
      ],
    )
    v(2fr)
    
    pagebreak()

  make-title(
    title: title,
    author: author,
    date: date,
    abstract: abstract,
    keywords: keywords,
  )
  

  // 正文内容
  body
}

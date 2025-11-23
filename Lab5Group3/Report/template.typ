/*
Documentation:
Template Name: Soleil Report Template
Description: This template is an improved version of the original work by mem and Sydney257 (98 account). 
            It has been enhanced by Soleil to better suit reporting needs. 
            Note that the input interfaces for this template are not fully documented yet.
Authors: 
  - Original: mem, Sydney257 (cc98 account)
  - Improvements: Soleil
Notes: 
  - This template is a work in progress, and further documentation is required for complete usage guidance.
Language: Bilingual (English and Chinese)
  - English: Provides a description of the template and its authorship.
  - 中文: 提供模板及其作者信息的描述。
模板名称：Soleil 报告模板
描述：此模板是在 mem 和 Sydney257（原始作品的基础上改进而成。
      Soleil 对其进行了增强，以更好地满足报告需求。
      请注意，此模板的输入接口尚未完全记录。
*/

#import "@preview/tablex:0.0.9": tablex, colspanx, rowspanx, hlinex, vlinex, cellx
#import "@preview/showybox:2.0.1": showybox
#import "@preview/i-figured:0.2.4"
#import "@preview/mitex:0.2.5": *
#import "@preview/zebraw:0.5.2": *
#import "@preview/algo:0.3.6": *





#let state_course = state("course", none)
#let state_author = state("author", none)
#let state_school_id = state("school_id", none)
#let state_date = state("date", none)
#let state_theme = state("theme", none)
#let state_block_theme = state("block_theme", none)
#let state_teacher = state("teacher", none)
#let state_major = state("major", none)
#let state_ProjName = state("ProjName", none)
#let noindent()=h(-2em)
#let indent = h(2em)
#let hp= v(0.2cm)
#let toprule() = table.hline(stroke: 1pt)
#let midrule() = table.hline(stroke: 0.5pt)
#let bottomrule() = table.hline(stroke: 1pt)
#let mathrm(x) = math.upright(x)
#let mathbf(x) = math.bold(math.upright(x))

// 装订线背景函数
#let binding_line_background() = {
  let binding_x = 1.3cm
  let binding_text_x = 1.05cm
  let page_content_height = 29.7cm - 2.5cm - 2.5cm  // A4高度减去上下边距 = 24.7cm
  let text_center_y = 2cm + page_content_height / 2  // 页面内容区域中心
  let text_height = 3.5em
  
  // 上半段虚线
  place(
    left + top,
    dx: binding_x,
    dy: 2.5cm,
    line(
      start: (0pt, 0pt),
      end: (0pt, text_center_y - 2.5cm - text_height / 2 - 0.3cm),
      stroke: (
        paint: black.lighten(30%),
        thickness: 1pt,
        dash: "dashed"
      )
    )
  )
  
  // 装订线文字（垂直居中）
  place(
    left + top,
    dx: binding_text_x,
    dy: text_center_y - text_height / 2,
    text(
      size: 14pt,
      font: ("Songti SC", "STSong", "Heiti SC"),
      fill: black.lighten(30%),
      weight: "bold",
      [装#v(0.2em)订#v(0.2em)线]
    )
  )
  
  // 下半段虚线
  place(
    left + top,
    dx: binding_x,
    dy: text_center_y + text_height / 2 + 1.8cm,
    line(
      start: (0pt, 0pt),
      end: (0pt, 29.7cm - 2.5cm - (text_center_y + text_height / 2 + 0.3cm)),
      stroke: (
        paint: black.lighten(30%),
        thickness: 1pt,
        dash: "dashed"
      )
    )
  )
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

#let fakebold(content) = {
  set text(stroke: 0.02857em) // https://gist.github.com/csimide/09b3f41e838d5c9fc688cc28d613229f
  content
}

#let project(
  theme: "project",
  block_theme: "default",
  course: none,
  title: "<title>",
  title_size: 3em,
  cover: true,
  cover_name: "本科实验报告",
  cover_subname: "Project Report",
  cover_image_padding: 1em,
  cover_image_size: none,
  semester: "<semester>",
  name: none,
  author: none,
  school_id: none,
  date: none,
  college: none,
  place: none,
  teacher: none,
  major: none,
  cover_comments: none,
  cover_comments_size: 1.25em,
  language: none,
  table_of_contents: none,
  font_serif: (
    "New Computer Modern",
    "Georgia",
    "Nimbus Roman No9 L",
    "Songti SC",
    "Noto Serif CJK SC",
    "Source Han Serif SC",
    "Source Han Serif CN",
    "STSong",
    "AR PL New Sung",
    "AR PL SungtiL GB",
    "NSimSun",
    "SimSun",
    "TW\-Sung",
    "WenQuanYi Bitmap Song",
    "AR PL UMing CN",
    "AR PL UMing HK",
    "AR PL UMing TW",
    "AR PL UMing TW MBE",
    "PingFang SC",
    "PMingLiU",
    "MingLiU",
  ),
  font_sans_serif: (
    "Noto Sans",
    "Helvetica Neue",
    "Helvetica",
    "Nimbus Sans L",
    "Arial",
    "Liberation Sans",
    "PingFang SC",
    "Hiragino Sans GB",
    "Noto Sans CJK SC",
    "Source Han Sans SC",
    "Source Han Sans CN",
    "Microsoft YaHei",
    "Wenquanyi Micro Hei",
    "WenQuanYi Zen Hei",
    "ST Heiti",
    "SimHei",
    "WenQuanYi Zen Hei Sharp",
  ),
  font_mono: ("Consolas", "Monaco"),
  // font_mono:("SF Mono","Monaco"),
  text_size: 12pt,
  text_Paragraphspace: 0.75em,
  page_header: false,
  body,
  ProjName : none,
) = {
  font_mono = (..font_mono, ..font_sans_serif)
  if (theme == "lab") {
    if (cover_image_size == none) {
      cover_image_size = 100%
    }
  } else if (theme == "project") {
    if (cover_image_size == none) {
      cover_image_size = 50%
    }
    if (language == none) {
      language = "en"
    }
    if (table_of_contents == none) {
      table_of_contents = true
    }
  }
  // fallback
  if (language == none) {
    language = "cn"
  }
  if (table_of_contents == none) {
    table_of_contents = false
  }

  set document(author: (author), title: title)

  set page(numbering: "1", number-align: center)
  if(language == "cn"){
    text_size = 9pt
    text_Paragraphspace = 1em
  }
  else if(language == "cen"){
    text_size = 10pt
    text_Paragraphspace = 0.75em
  }

  set text(font: font_serif, lang: language, size: text_size)
  
  show raw: set text(font: font_mono)
  show math.equation: set text(weight: 400)

  set par(spacing: 1.2em, leading: text_Paragraphspace)
  
/* -------------------------------------------------------------------------- */
  // Update global state
  state_course.update(course)
  state_author.update(author)
  state_school_id.update(school_id)
  state_date.update(date)
  state_theme.update(theme)
  state_block_theme.update(block_theme)
  state_teacher.update(teacher)
  state_major.update(major)
  state_ProjName.update(ProjName)
  


/* -------------------------------------------------------------------------- */
  // 设置页眉  注意if里面不能嵌套set
  let remain_page_header = table(columns: (40%, 20%, 40%), stroke: none, align: (left, center, right),
    if ProjName == none {"实验名称："+context state_ProjName.get()} else {"实验名称：" + ProjName},[姓名：#author],[学号：
    #school_id],
    table.hline(stroke: 0.5pt)
  )
  set page(paper: "a4", header: context if (counter(page).get().first() != 1) and (page_header == true) {
      remain_page_header
  })
/* -------------------------------------------------------------------------- */
  // Cover Page
  if (theme == "nocover" or theme == "notes" or cover == false) {
    // no cover page
  } 
  else if (theme == "lab" or theme == "teamLab") {
    set page(numbering: none)
    v(1fr)
    align(center, image("./ZJU-Banner2.png", width: cover_image_size))
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
  } else if (theme == "project") {
    v(1fr)
    box(
      width: 100%,
      align(center)[
        #text(2em, weight: 900)[
          #course
        ]

        #text(title_size, weight: 700)[
          #title
        ]

        #v(cover_image_padding)
        #image("./images/ZJU-Logo.png", width: cover_image_size)
        #v(cover_image_padding)

        #if (cover_comments == none) [
          #text(cover_comments_size)[
            #v(1em)
            #if (author != none) [
              Author: #author
            ]

            Date: #date

            #semester Semester
          ]
        ] else [
          // If cover_comments is assigned, it will be used as the cover's original comments
          #cover_comments
        ]
      ],
    )
    v(4fr)
    pagebreak()
  } else {
    set text(fill: red, size: 3em, weight: 900)
    align(center)[Theme not found!]
    pagebreak()
  }

  if (table_of_contents) {
    outline(title: text(1.1em, "Table of Contents"), depth: 3, indent: 1.2em)
    
    pagebreak()
  }
  
  set par(justify: true)
  set table(align: center + horizon, stroke: 0.5pt)

/* -------------------------------------------------------------------------- */
//标题格式
  if (theme == "lab") {
    set heading(
      numbering: (..args) => {
        let nums = args.pos()
        if nums.len() == 1 {
          return none
        } else if nums.len() == 2 {
          return numbering("一、", ..nums.slice(1))
        }
        else if nums.len() == 3 {
          return numbering("1. ", ..nums.slice(2))
        } else {
          return numbering("1.1)", ..nums.slice(2))
        }
      },
    )

    // show heading.where(level: 1): it => block(
    //   width: 100%,
    //   {
    //     set align(center)
    //     set text(size: 1em)
    //     it.body
    //     v(0.6em)
    //   },
    // )
    show heading.where(level: 1): it => {
    set align(center)
    set text(size: 14pt)
    set block(below: 25pt, above: 25pt)
    it
    }
    show heading.where(level: 2): it => {
      set block(below: 15pt, above: 15pt)
      set text(12pt)
      it
    }
    show heading.where(level: 3): it => {
      set block(below: 15pt, above: 15pt)
      set text(10.5pt)
      it
    }
    show heading.where(level: 4): it => {
      set block(below: 14pt, above: 15pt)
      set text(10pt)
      it
    }

    body
    
  }  else if(theme == "notes") {
    set heading(
      numbering: (..args) => {
        let nums = args.pos()
        if nums.len() == 1 {
          return numbering("Chapter 1 ", 1, ..nums.slice(0))

        } else if nums.len() == 2 {
          return numbering("一、", ..nums.slice(1))
        } else if nums.len() == 3 {
          return numbering("1.", ..nums.slice(2))}
        else if nums.len() == 4 {
          return numbering("1.1)", ..nums.slice(2))
        }
        else if nums.len() == 5 {
          return numbering("1.1.1)", ..nums.slice(2))
        }
      },
    )
    
    body
  } else if(theme == "nocover") {
    set heading(
      numbering: (..args) => {
        let nums = args.pos()
        if nums.len() == 1 {
          return none
        } else if nums.len() == 2 {
          return numbering("一、", ..nums.slice(1))
        } else if nums.len() == 3 {
          return numbering("1.", ..nums.slice(2))}
        else if nums.len() == 4 {
          return numbering("1.1)", ..nums.slice(2))
        }
        else if nums.len() == 5 {
          return numbering("1.1.1)", ..nums.slice(2))
        }
      },
    )

    body
  }
  else {
    set heading(
      numbering: (..args) => {
        let nums = args.pos()
        if nums.len() == 1 {
          return none
        } else {
          return numbering("1.1)", ..nums)
        }
      },
    )

    body
  }
}
/* -------------------------------------------------------------------------- */

//代码插入
#let codex(code, lang: none, size: 1em, border: true) = {
  if code.len() > 0 {
    if code.ends-with("\n") {
      code = code.slice(0, code.len() - 1)
    }
  } else {
    code = ""
  }
  set text(size: size)
  align(left)[
    #if border == true {
      block(width: 100%, stroke: 0.5pt + luma(150), radius: 3pt, inset: 8pt)[
        #raw(lang: lang, block: true, code)
      ]
    } else {
      raw(lang: lang, block: true, code)
    }
  ]
}
//代码插入
#let mycode(code, lang: none, size: 1em, border: true) = {
  if code.len() > 0 {
    if code.ends-with("\n") {
      code = code.slice(0, code.len() - 1)
    }
  } else {
    code = ""
  }
  set text(size: size)
  align(left)[
    #if border == true {
      block(width: 100%, stroke: 0.5pt + luma(150), radius: 3pt, inset: 3pt)[
        #raw(lang: lang, block: true, code)
      ]
    } else {
      raw(lang: lang, block: true, code)
    }
  ]
}


#let importCode(file, namespace: none, lang: "cpp") = {
  let source_code = read(file)
  let code = ""
  let note = ""
  let flag = false
  let firstlines = true

  for line in source_code.split("\n") {
    if namespace != none and line == ("} // namespace " + namespace) {
      flag = false
    }
    if namespace == none or flag {
      if firstlines and line.starts-with("// ") {
        note += line.slice(3) + "\n"
      } else {
        code += line + "\n"
        firstlines = false
      }
    }
    if namespace != none and line == ("namespace " + namespace + " {") {
      flag = true
    }
  }

  if note.len() > 0 {
    block(note)
  }

  codex(code, lang: lang, size: 1.05em)
}

/* -------------------------------------------------------------------------- */

//实验报告标头
#let lab_header(
  course: none,
  type: "综合",
  name: "<name>",
  author: none,
  school_id: none,
  place: "<place>",
  date: none,
) = {
  pagebreak(weak: true)
  align(center)[
    #set text(size: 1.5em)
    #fakebold[浙江大学实验报告]
  ]
  tablex(
    columns: (1fr, 0.32fr, 1.68fr, 1fr, 1fr, 1fr),
    align: center + horizon,
    stroke: 0pt,
    inset: 1pt,
    _underlined_cell("课程名称：", color: white),
    colspanx(
      2,
      _underlined_cell(if course == none {
        context state_course.get()
      } else {
        course
      }),
    ),
    (),
    _underlined_cell("实验类型：", color: white),
    colspanx(2, _underlined_cell(type)),
    (),
    colspanx(2, _underlined_cell("实验项目名称：", color: white)),
    (),
    colspanx(4, _underlined_cell(name)),
    (),
    (),
    (),
    _underlined_cell("学生姓名：", color: white),
    colspanx(
      2,
      _underlined_cell(if author == none {
        context state_author.get()
      } else {
        author
      }),
    ),
    (),
    _underlined_cell("学号：", color: white),
    colspanx(
      2,
      _underlined_cell(if school_id == none {
        context state_school_id.get()
      } else {
        school_id
      }),
    ),
    (),
    _underlined_cell("实验地点：", color: white),
    colspanx(2, _underlined_cell(place)),
    (),
    _underlined_cell("实验日期：", color: white),
    colspanx(
      2,
      _underlined_cell(if date == none {
        context state_date.get()
      } else {
        date
      }),
    ),
    (),
  )
}

#let lab_header_2(
  major: none,
  author: none,
  school_id: none,
  date: none,
  course: none,
  teacher: none,
  grade: none,
  name: none,
) = {
  align(center)[
    #grid(
      columns: 3,
      column-gutter: (-15pt, 20pt),
      [
        #pad(y: -4pt)[]
        #image("./images/ZJU-Banner.png", width: 75%)
      ],
      [
        #text(size: -10pt)[] \ #text(size: 30pt, stroke: 1pt)[实验报告]
      ],
      [
        #align(left)[
          #text(size: 1em)[
            专业：#major\
            姓名：#author \
            学号：#school_id \
            日期：#date\
          ]
        ]
      ],
    )
  ]

  tablex(
    columns: (1.3fr, 2fr, 1.3fr, 1fr, 1fr, 0.5fr),
    align: left,
    stroke: 0pt,
    inset: 1pt,
    _underlined_cell("课程名称：", color: white),
    colspanx(
      1,
      _underlined_cell(if course == none {
        context state_course.get()
      } else {
        course
      }),
    ),
    _underlined_cell("指导老师：", color: white),
    colspanx(1, _underlined_cell(teacher)),
    _underlined_cell("成绩：", color: white),
    colspanx(1, _underlined_cell(grade)),
    _underlined_cell("实验名称：", color: white),
    colspanx(4, _underlined_cell(name)),
    (),
    (),
    (),
  )
}
#let Cover_LAB(
  course: none,
  title: none,
  title_size: 3em,
  cover: true,
  cover_image_padding: 1em,
  cover_image_size: 50%,
  semester: none,
  name: none,
  cover_comment: none,
) = {
  let cover_comments = [#cover_comment]
  v(1fr)
    box(
      width: 100%,
      align(center)[
        #text(2em, weight: 900)[
          #course
        ]

        #text(title_size, weight: 700)[
          #title
        ]

        #v(cover_image_padding)
        #image("./images/ZJU-Logo.png", width: 50%)
        #v(cover_image_padding)

        #if (cover_comments == none) [
          #text(cover_comments_size)[
            #v(1em)
            #if (author != none) [
              Author: #author
            ]

            Date: #date

            #semester Semester
          ]
        ] else [
          // If cover_comments is assigned, it will be used as the cover's original comments
          #cover_comments
        ]
      ],
    )
    v(4fr)
    pagebreak()
}
#let ISEE_Header(
  groupmate:"<同组学生>",
  type: "<实验类型>",
  major: none,
  author: none,
  school_id: none,
  date: none,
  course: none,
  teacher: none,
  grade: none,
  ProjName: "<实验名称>",
  place: "<地点>",
) = {
    set text(size: 9.5pt)
    set table.hline(stroke: .5pt)
    table(columns: (68%, 30%), align: center+horizon, stroke: none,
      image("images/head.jpg"),
      table(align: center + horizon, stroke: none, columns: (1.5cm, 4cm),
      [专业：],if major == none {context state_major.get()} else {major},table.hline(start: 1),
      [姓名：],if author == none {context state_author.get()} else {author},table.hline(start: 1),
      [学号：],if school_id == none {context state_school_id.get()} else {school_id},table.hline(start: 1),
      [日期：],if date == none {context state_date.get()} else {date},table.hline(start: 1),
      [地点：],[#place],table.hline(start: 1),
      ),

      table.cell([
      #table(align: center+horizon, stroke: none, columns: (13%, 22%, 13%, 27%, 17%, 15%),
      table.cell([课程名称：], align: left),if course == none {context state_course.get()} else {course},table.hline(start: 1, end: 2),
      table.cell([指导老师：], align: left),if teacher == none {context state_teacher.get()} else {teacher},table.hline(start: 3, end: 4),
      table.cell([成$space.quad space.quad $绩：], align: left),[#grade],table.hline(start: 5, end: 6),
      table.cell([实验名称：], align: left),[#ProjName],table.hline(start: 1, end: 2),
      table.cell([实验类型：], align: left),[#type],table.hline(start: 3, end: 4),
      table.cell([同组学生姓名：], align: left),[#groupmate],table.hline(start: 5, end: 6),
      )
      ], colspan: 2)
    )
    state_ProjName.update(ProjName)
}

/* -------------------------------------------------------------------------- */
//其他杂项

#let table3(
  // 三线表
  ..args,
  inset: 0.5em,
  stroke: 0.5pt,
  align: center + horizon,
  columns: 1fr,
) = {
  tablex(
    columns: 1fr,
    inset: 0pt,
    stroke: 0pt,
    map-hlines: h => {
      if (h.y > 0) {
        (..h, stroke: (stroke * 2) + black)
      } else {
        h
      }
    },
    tablex(
      ..args,
      inset: inset,
      stroke: stroke,
      align: align,
      columns: columns,
      map-hlines: h => {
        if (h.y == 0) {
          (..h, stroke: (stroke * 2) + black)
        } else if (h.y == 1) {
          (..h, stroke: stroke + black)
        } else {
          (..h, stroke: 0pt)
        }
      },
      auto-vlines: false,
    ),
  )
}

#let figurex(img, caption) = {
  show figure.caption: it => {
    set text(size: 0.9em, fill: luma(100), weight: 700)
    it
    v(0.1em)
  }
  set figure.caption(separator: ":")
  figure(
    img,
    caption: [
      #set text(weight: 400)
      #caption
    ],
  )
}

#let blockx(it, name: "", color: red, theme: none) = {
  context {
    let _theme = theme
    if (_theme == none) {
      _theme = state_block_theme.get()
    }
    if (_theme == "default") {
      let _inset = 0.8em
      let _color = color.darken(5%)
      v(0.2em)
      block(below: 1em, stroke: 0.5pt + _color, radius: 3pt, width: 100%, inset: _inset)[
        #place(
          top + left,
          dy: -6pt - _inset, // Account for inset of block
          dx: 8pt - _inset,
          block(fill: white, inset: 2pt)[
            #set text(font: "Noto Sans", fill: _color)
            #name
          ],
        )
        #set text(fill: _color)
        #set par(first-line-indent: 0em)
        #it
      ]
    } else if (_theme == "boxed") {
      showybox(
        title: name,
        frame: (
          border-color: color,
          title-color: color.lighten(20%),
          body-color: color.lighten(95%),
          footer-color: color.lighten(80%),
        ),
        it,
      )
    } else if (_theme == "float") {
      showybox(
        title-style: (
          boxed-style: (anchor: (x: center, y: horizon), radius: (top-left: 10pt, bottom-right: 10pt, rest: 0pt)),
        ),
        frame: (
          title-color: color.darken(5%),
          body-color: color.lighten(95%),
          footer-color: color.lighten(60%),
          border-color: color.darken(20%),
          radius: (top-left: 10pt, bottom-right: 10pt, rest: 0pt),
        ),
        title: name,
        [
          #it
          #v(0.25em)
        ],
      )
    } else if (_theme == "thickness") {
      showybox(
        title-style: (color: color.darken(20%), sep-thickness: 0pt, align: center),
        frame: (title-color: color.lighten(85%), border-color: color.darken(20%), thickness: (left: 1pt), radius: 0pt),
        title: name,
        it,
      )
    } else if (_theme == "dashed") {
      showybox(
        title: name,
        frame: (
          border-color: color,
          title-color: color,
          radius: 0pt,
          thickness: 1pt,
          body-inset: 1em,
          dash: "densely-dash-dotted",
        ),
        it,
      )
    } else {
      block(
        width: 100%,
        stroke: 0.5pt + red,
        inset: 1em,
        radius: 5pt,
        align(center)[
          #set text(fill: red, size: 1.5em)
          Please use The Project to define block theme!
        ],
      )
    }
  }
}

#let Theorem(it, name: none) = blockx(
  it,
  name: if (name != none) {
    strong(name)
  } else {
    strong("Theorem")
  },
  color: rgb(0, 90, 239),
)

#let example(it, name: none) = blockx(
  it,
  name: if (name != none) {
    strong(name)
  } else {
    strong("Example")
  },
  color: gray.darken(60%),
)
#let proof(it, name: none) = blockx(
  it,
  name: if (name != none) {
    strong(name)
  } else {
    strong("Proof")
  },
  color: rgb(120, 120, 120),
)
#let abstract(it, name: none) = blockx(
  it,
  name: if (name != none) {
    strong(name)
  } else {
    strong("Abstract")
  },
  color: rgb(0, 133, 143),
)
#let summary(it, name: none) = blockx(
  it,
  name: if (name != none) {
    strong(name)
  } else {
    strong("Summary")
  },
  color: rgb(0, 133, 143),
)
#let info(it, name: none) = blockx(
  it,
  name: if (name != none) {
    strong(name)
  } else {
    strong("Info")
  },
  color: rgb(68, 115, 218),
)
#let note(it, name: none) = blockx(
  it,
  name: if (name != none) {
    strong(name)
  } else {
    strong("Note")
  },
  color: rgb(68, 115, 218),
)
#let tip(it, name: none) = blockx(
  it,
  name: if (name != none) {
    strong(name)
  } else {
    strong("Tip")
  },
  color: rgb(0, 133, 91),
)
#let hint(it, name: none) = blockx(
  it,
  name: if (name != none) {
    strong(name)
  } else {
    strong("Hint")
  },
  color: rgb(0, 133, 91),
)
#let success(it, name: none) = blockx(
  it,
  name: if (name != none) {
    strong(name)
  } else {
    strong("Success")
  },
  color: rgb(62, 138, 0),
)
#let important(it, name: none) = blockx(
  it,
  name: if (name != none) {
    strong(name)
  } else {
    strong("Important")
  },
  color: rgb(62, 138, 0),
)
#let help(it, name: none) = blockx(
  it,
  name: if (name != none) {
    strong(name)
  } else {
    strong("Help")
  },
  color: rgb(153, 110, 36),
)
#let warning(it, name: none) = blockx(
  it,
  name: if (name != none) {
    strong(name)
  } else {
    strong("Warning")
  },
  color: rgb(184, 95, 0),
)
#let attention(it, name: none) = blockx(
  it,
  name: if (name != none) {
    strong(name)
  } else {
    strong("Attention")
  },
  color: rgb(216, 58, 49),
)
#let caution(it, name: none) = blockx(
  it,
  name: if (name != none) {
    strong(name)
  } else {
    strong("Caution")
  },
  color: rgb(216, 58, 49),
)
#let failure(it, name: none) = blockx(
  it,
  name: if (name != none) {
    strong(name)
  } else {
    strong("Failure")
  },
  color: rgb(216, 58, 49),
)
#let danger(it, name: none) = blockx(
  it,
  name: if (name != none) {
    strong(name)
  } else {
    strong("Danger")
  },
  color: rgb(216, 58, 49),
)
#let error(it, name: none) = blockx(
  it,
  name: if (name != none) {
    strong(name)
  } else {
    strong("Error")
  },
  color: rgb(216, 58, 49),
)
#let bug(it, name: none) = blockx(
  it,
  name: if (name != none) {
    strong(name)
  } else {
    strong("Bug")
  },
  color: rgb(204, 51, 153),
)
#let quote(it, name: none) = blockx(
  it,
  name: if (name != none) {
    strong(name)
  } else {
    strong("Quote")
  },
  color: rgb(132, 90, 231),
)
#let Cite(it, name: none) = blockx(
  it,
  name: if (name != none) {
    strong(name)
  } else {
    strong("Cite")
  },
  color: rgb(132, 90, 231),
)
#let experiment(it, name: none) = blockx(
  it,
  name: if (name != none) {
    strong(name)
  } else {
    strong("Experiment")
  },
  color: rgb(132, 90, 231),
)
#let question(it, name: none) = blockx(
  it,
  name: if (name != none) {
    strong(name)
  } else {
    strong("Question")
  },
  color: rgb(132, 90, 231),
)
#let analysis(it, name: none) = blockx(
  it,
  name: if (name != none) {
    strong(name)
  } else {
    strong("Analysis")
  },
  color: rgb(0, 133, 91),
)
/*
  * 对行内代码的高亮
  */
#let c(
  content,
  lang: none,
  bg: rgb("#f3f4f4"),
  // border: none, // 默认不使用边框
  border: rgb("#d8dbde")
) = {
  box(
    fill: bg,
    stroke: (paint: border, thickness: 0.3pt),
    inset: (x: 2pt, y: 2pt),
    radius: 1pt,
    baseline: 20%,
    text(
      font: "Cascadia Mono",
      weight: "medium",
      // size: 0.7em,
      content
    )
  )
}
#let highlight(
  content,
  color: yellow.lighten(70%),
  stroke: none,
  radius: 2pt,
  inset: (x: 4pt, y: 2pt)
) = {
  box(
    fill: color,
    stroke: stroke,
    radius: radius,
    inset: inset,
    baseline: 20%,  // 调整基线对齐
    content
  )
}
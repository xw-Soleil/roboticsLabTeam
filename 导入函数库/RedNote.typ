/*
 * 名称: RedNote
 * 类型：Typst自定义模板
 * 描述：小红书图文排版模板
 * 创建时间：2025年6月26日
 * 最后修改：2025年6月29日
 */

// ----------------------- 通用元素函数 -----------------------
// 水平分割线
#let hr = line.with(length: 100%, stroke: luma(200))
// 水平分割线 - 虚线
#let dash_hr = line.with(
  length: 100%,
  stroke: (
    paint: luma(200),
    dash: "dashed",
  ),
)

// 无序列表
#let rect_list(body) = rect(fill: luma(230), width: 100%, inset: 20pt, radius: 5pt)[
  #set list(marker: "�9�7")
  #body
]

// 对齐
#let center(it) = box(width: 1fr)[#align(alignment.center)[#it]]
#let left(it) = box(width: 1fr)[#align(alignment.left)[#it]]
#let right(it) = box(width: 1fr)[#align(alignment.right)[#it]]

#let top_left = place.with(top, dy: 1cm, dx: 1cm)
#let bottom = place.with(bottom)


// ----------------------- 模板函数 -----------------------
// 模板
#let rednote(
  doc,
  my_title: none,
  my_sub_title: none,
  my_info: none,
  img_url: "",
  logo_url: "",
) = [
  // ----------------------- 封面基础设定 -----------------------
  #set page(margin: 0cm)
  // ----------------------- 封面元素设定 -----------------------
  // 标题
  #let title = text.with(size: 50pt, font: "FZCuHeiSongS-B-GB")
  #let sub_title = text.with(size: 30pt, font: "Ink Free")
  // 头图
  #let top_image = image.with(height: 40%, width: 100%, fit: "cover")

  // 内容
  #let body = block.with(inset: 1cm, height: 1fr)

  // 底部信息区域
  #let info = text.with(size: 30pt, font: "SimHei")
  // Logo
  #let logo(img, sttr) = rect(stroke: none, inset: 5pt)[
    #set text(size: 18pt, font: "SimHei")
    #stack(dir: ltr, spacing: 5pt)[#img][#sttr]
  ]



  // ----------------------- 实际封面设计区 -----------------------
  #let face_page(img_url, logo_url) = [
    #top_image(img_url, height: 50%)
    #top_left[
      #logo[#image(logo_url, width: 40pt, height: 40pt)][#text(white)[巽星石 \ XUN.SR]]
    ]
    #body[
      // 标题和副标题
      #title(red)[#center[#my_title]] \

      #sub_title(luma(100))[#center[#my_sub_title]]
      // 底部文字
      #bottom[
        #hr()
        #show "Typst": it => [#text(blue, size: 40pt, font: "Impact")[#it]]
        #center[#info[#my_info]]
      ]
    ]
  ]

  #face_page(img_url, logo_url)

  // ----------------------- 正文页面设定 -----------------------
  #set page(
    margin: (y: 3cm, x: 1cm),
    header: [
      #right[#text(size: 14pt)[#my_title <<]]
      #hr()
    ],
    footer: [
      #hr()
      #show "Typst": it => [#text(blue, size: 26pt, font: "Impact")[#it]]
      #text(size: 14pt)[
        >> #my_info]
    ],
  )

  #set par(
    first-line-indent: (
      amount: 2em,
      all: true,
    ),
    leading: 0.8em,
  )
  // 正文
  #set text(size: 18pt, font: "SimSun", lang: "zh")
  // 标题
  #show heading: set block(inset: (y: 0.5em))
  #show heading: set text(font: "SimHei")
  #show heading.where(level: 1): set text(size: 30pt)
  #show heading.where(level: 2): set text(size: 25pt)
  #show heading.where(level: 3): set text(size: 20pt)
  // 代码块
  #show raw.where(block: true): set block(width: 100%, inset: 20pt, radius: 5pt, stroke: luma(230))
  #show raw.where(block: true): set text(size: 14pt)
  #show raw.where(block: false): set text(red)
  // 一些特殊词的高亮
  #show "Typst": set text(blue, font: "Candara")
  #show "MarkDown": set text(orange, font: "Candara")
  #show "Marp": set text(red, font: "Candara")
  #show "HTML": set text(orange, font: "Candara")
  #show "CSS": set text(orange, font: "Candara")
  // ----------------------- 正文 -----------------------
  #doc
]

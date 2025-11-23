#import "PageLib.typ": *

#let template-title-row(
  title: "",
  authors: (),
  date: none,
  lang: "zh",
  body,
) = {
  //////////********** Document properties **********//////////
  set document(author: authors.map(a => a.name), title: title)
  set page(
    number-align: center,
    margin: (
      // 页面边距
      x: 10mm, // 水平边距
      y: 15mm, // 垂直边距
    ),
    paper: "a4",
    columns: 1,
  )

  //////////********** Type settings **********//////////
  // Set basic typographical properties.

  set text(
    font: ("AaTMKASXZ", "AaBNDKATYL", "LXGW WenKai", "AaGuaiGuaiTi", "FZCuHeiSongS-B-GB"),
    lang: lang,
    size: 10.5pt,
  )
  set math.equation(numbering: "(1)")
  // show math.equation: set text(size: 0.7em)
  show heading: set block(below: 1em, above: 1.3em)
  set heading(numbering: "1.1")

  // Code styles
  // 行内代码
  show raw.where(block: false): it => [
    #box(
      fill: rgb("#ececec"),
      inset: 2pt,
      outset: 2pt,
      radius: 2pt,
      stroke: rgb("#dcdcdc") + 1pt,
      baseline: 20%,
      it,
    )
  ]

  // 代码块
  show raw.where(block: true): it => [
    #align(left)[
      #block(
        fill: rgb("#ececec"),
        width: 100%,
        inset: 10pt,
        radius: 5pt,
        stroke: rgb("#dcdcdc") + 1pt,
        it,
      )
    ]
  ]

  // Chinese font in math equation
  show math.equation: it => {
    show regex("\p{script=Han}"): set text(font: "LXGW WenKai Mono")
    it
  }

  show raw: it => {
    show regex("\p{script=Han}"): set text(font: "LXGW WenKai Mono")
    it
  }

  //////////********** Title row **********//////////
  pic_page("../images/头像.jpg", size: (100%, 50%))[
    #place_content(pos: (1%, 52%))[
      // #repeat[#emoji.flower #emoji.face.clown]
      #repeat[#emoji.arm #emoji.hundred #emoji.laptop #emoji.office #emoji.robot ]
    ]

    // 一行标题
    #place_content(pos: (11%, 57%))[
      #text(black, size: 70pt, font: "aafuwati", title)
    ]

    // 两行标题
    // #place_content(pos: (43%, 56%))[
    //   #text(black, size: 35pt, font: "aafuwati", title)
    // ]
    // #place_content(pos: (49%, 62%))[
    //   #text(black, size: 35pt, font: "aafuwati", "数学建模精英联赛")
    // ]
    //
    #place_content(pos: (1%, 68%))[
      // #repeat[#emoji.flower #emoji.face.clown]
      #repeat[#emoji.rocket #emoji.wrench #emoji.tv #emoji.telescope #emoji.ufo]
    ]
    #place_content(pos: (0%, 72%))[
      #h(1fr) #text(black, size: 24pt, font: "FZCuHeiSongS-B-GB")[末荼Mo_Tu]
    ]
    #place_content(pos: (0%, 77%))[
      #h(1fr) #text(black, size: 20pt, font: "FZCuHeiSongS-B-GB")[#(
        datetime.today().display("[year]年[month padding:none]月[day padding:none]日")
      )]
    ]
  ]

  set page(numbering: "1 / 1")

  // Author info
  pad(
    top: 0em,
    bottom: 0.5em,
    x: 2em,
    grid(
      columns: (1fr,) * calc.min(3, authors.len()),
      gutter: 1em,
      ..authors.map(author => align(center)[
        *#author.name*
      ]),
    ),
  )

  set par(
    justify: true,
    first-line-indent: (
      amount: 2em,
      all: true,
    ),
    leading: 0.5em,
    spacing: 0.65em,
  )

  // set block(spacing: 1.2em)

  body
}

//////////********** Callout **********//////////
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
    fill: color.lighten(97%),
    width: 100%,
    inset: _inset,
    radius: 5pt,
    stroke: 1pt + _color,
  )[
    #place(
      top + left,
      dy: -8pt - _inset,
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
  note: (title: "Note", it) => callout(title: title, color: rgb(68, 115, 218), size: 1.4em)[#it],
  tip: (title: "Tip", it) => callout(title: title, color: rgb(0, 133, 91))[#it],
  hint: (title: "Hint", it) => callout(title: title, color: rgb(0, 133, 91))[#it],
  success: (title: "Success", it) => callout(title: title, color: rgb(62, 138, 0))[#it],
  important: (title: "Important", it) => callout(title: title, color: rgb(62, 138, 0))[#it],
  help: (title: "Help", it) => callout(title: title, color: rgb(153, 110, 36))[#it],
  warning: (title: "Warning", it) => callout(title: title, color: rgb("#e17909"), size: 1.4em)[#it],
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

//////////********** Codex implementation **********//////////
#let codex(
  code,
  lang: none,
  size: 1em,
) = {
  if code.len() > 0 {
    if code.ends-with("\n") {
      code = code.slice(0, code.len() - 1)
    }
  } else {
    code = "// no code"
  }
  set text(size: size)
  align(left)[
    #raw(lang: lang, block: true, code)
  ]
}

// added by xks
#let colred(x) = text(fill: red, $#x$)
#let colblue(x) = text(fill: blue, $#x$)

// added by ct
// usage:
// #resizeEquation(size: 0.7em)[$F=ma$]
#let resizeEquation(
  size: 0.5em,
  body,
) = {
  show math.equation: set text(size: size)
  body
}

// added by xks
// for a2 paper. if you use a3, replaces this with
// #let eqcolumns(n, gutter: 4%, content) = content;
// to bypass it.
// https://github.com/typst/typst/issues/466
#let eqcolumns(n, gutter: 4%, content) = {
  layout(size => [
    #let (height,) = measure(
      block(
        width: (1 / n) * size.width * (1 - float(gutter) * n),
        content,
      ),
    )
    #block(
      height: height / n,
      columns(n, gutter: gutter, content),
    )
  ])
}

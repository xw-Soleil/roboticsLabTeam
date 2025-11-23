#import "./template.typ":*

#let authors = (
  (
    name: "末荼Mo_Tu",
  ),
)

#show :template-title-row.with(
  title: "马原期末复习",
  authors: authors,
  date: [2025年1月2日],
  lang: "zh"
)

#outline(depth: 5) //创建目录

#colbreak() //创建列分隔符

= 简答题（套路模板）

== 辩证唯物主义

=== 唯物论
#(c.note)(title: [唯物论])[#v(1mm)
  #block[
    #set enum(numbering: "(1)", start: 1)
    + 世界是物质的
    + 物质决定意识，意识反作用于物质
    + 坚持主观能动性与客观规律性的统一
  ]
]

#(c.solution)()[]
#(c.example)()[]
#(c.proof)()[]
#(c.abstract)()[]
#(c.summary)()[]
#(c.info)()[]
#(c.note)()[]
#(c.tip)()[]
#(c.hint)()[]
#(c.success)()[]
#(c.important)()[]
#(c.help)()[]
#(c.warning)()[]
#(c.attention)()[]
#(c.caution)()[]
#(c.failure)()[]
#(c.danger)()[]
#(c.error)()[]
#(c.bug)()[]
#(c.quote)()[]
#(c.cite)()[]
#(c.experiment)()[]
#(c.question)()[]
#(c.analysis)()[]
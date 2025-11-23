/*
* 名称：PageLib
* 描述：用于创建特殊封面或背景效果的自定义模块
* 作者：巽星石
* 创建时间：2025年6月26日
* 最后修改：2025年6月28日
*/ 

// -------------------------- 基础页面函数 --------------------------
// 纯色背景页面
#let color_page =  page.with(fill:white)

// 背景页面
#let bg_page(
  bg_content,            // 背景内容
  fill:white,            // 背景颜色或渐变、纹理
  body                   // 页面正文
) =  page(
  background: [#bg_content],
  fill:fill,
)[#body]

// 图片背景页面
#let pic_page(
  img_path,              // 图片路径
  fill:white,            // 背景颜色或渐变、纹理
  // ----------- 定位与变换 ----------- 
  pos:(0pt,0pt),         // 左上角位置
  size:(100%,100%),      // 尺寸
  angle:0deg,            // 旋转角度
  scales:(100%,100%),    // 缩放
  // ---------------------- 
  body                   // 页面正文
) =  bg_page(fill:fill,)[
      #place(top,dx:pos.at(0),dy:pos.at(1))[
        #rotate(angle)[
          #scale(x:scales.at(0),y:scales.at(1))[
            #image(img_path,width:size.at(0),height: size.at(1))
          ]
        ]
      ]
    ][#body]

// -------------------------- 基础绝对定位函数 --------------------------
// 绝对定位的内容
#let place_content(
  pos:(0pt,0pt),       // 左上角位置
  size:(auto,auto),    // 尺寸
  angle:0deg,          // 旋转角度
  scales:(100%,100%),  // 缩放
  body                 // 具体内容
) = [
  #place(top,dx:pos.at(0),dy:pos.at(1))[
    #rotate(angle)[#scale(x:scales.at(0),y:scales.at(1))[
        #body
      ]
    ]
  ]
]


// -------------------------- 具体背景页面函数 --------------------------
// 正文区矩形框页面
#let rect_page(
  margin:2cm,                  // 页边距
  bg_fill:luma(220),         // 背景填充
  fill:white,                  // 矩形填充
  inset: 10pt,                 // 矩形内容边距
  radius: 5pt,                 // 矩形圆角
  // ----------- 阴影设置 ----------- 
  has_shadow:false,            // 是否有阴影
  shadow_offset:(5pt,5pt),     // 阴影偏移
  shadow_fill:luma(200),     // 阴影填充
  // ----------- 副矩形设置 -----------
  show_bg_rects:false,         // 是否显示副矩形
  bg_rects_count:1,            // 副矩形数量
  bg_rects_deg:2deg,           // 副矩形旋转角度
  bg_rects_start_deg:-4deg,    // 副矩形旋转角度
  bg_rects_fill:luma(200),   // 副矩形基础色
  // ----------- 其他自定义背景内容 -----------
  bg_contents:none,            // 其他自定义背景内容
  fg_contents:none,            // 其他自定义前景内容
  // ---------------------- 
  body                         // 页面正文
) = bg_page(fill: bg_fill)[
  #let p = 100% - margin * 2  // 版心宽度和高度
  #let top_left = (margin+ shadow_offset.at(0),margin+ shadow_offset.at(1))
  // 版心副矩形
  #if show_bg_rects [
    #has_shadow = false  // 强制关闭阴影
    #for i in range(bg_rects_count) {
      let opt = eval("-" + str(i / bg_rects_count * 100) + "%")
      let ang = bg_rects_start_deg + bg_rects_deg * i
      place_content(pos:(margin,margin),angle:ang)[
        #rect(fill:bg_rects_fill.opacify(opt),width: p,height: p,radius: radius)
      ]
    } 
  ]
  // 其他自定义背景内容
  #if bg_contents != none [#bg_contents] 
  // 版心阴影
  #if has_shadow and show_bg_rects == false [
    #place_content(pos:top_left)[
      #rect(fill:shadow_fill,width: p,height: p,radius: radius)
    ]
  ]
  // 版心
  #place_content(pos:(margin,margin))[
    #rect(fill:fill,width: p,height: p, inset: inset,radius: radius)
  ]
  // 其他自定义前景内容
  #if fg_contents != none [#fg_contents] 
][#body]


// Mac风格背景页面
#let mac_page(
  margin:2cm,                  // 背景页边距
  title_bar_height:20pt,       // 标题栏高度
  title_fill:gradient.linear(angle:-90deg,..(gray,gray.lighten(70%))), // 标题栏填充
  bg_fill:luma(220),         // 背景填充
  fill:gray.lighten(70%),      // 窗口填充
  border: gray,                // 窗口边线
  inset: 10pt,                 // 内容区内边距
  radius: 5pt,                 // 窗口圆角
  // ----------- 阴影设置 ----------- 
  has_shadow:false,            // 是否有阴影
  shadow_offset:(5pt,5pt),     // 阴影偏移
  shadow_fill:luma(200),     // 阴影填充
  // ----------- 其他自定义背景内容 -----------
  bg_contents:none,            // 其他自定义背景内容
  fg_contents:none,            // 其他自定义前景内容
  // ---------------------- 
  body                         // 页面正文  
) = page(
  fill: bg_fill,
  background: [
    #let w = 100% - margin * 2  // 版心宽度
    #let h = 100% - margin * 2 - title_bar_height  // 版心高度
    #let top_left = (margin+ shadow_offset.at(0),margin+ shadow_offset.at(1))
    // 其他自定义背景内容
    #if bg_contents != none [#bg_contents] 
    // 版心阴影
    #if has_shadow [
      #place_content(pos:top_left)[
        #rect(fill:shadow_fill,width: w,height: h,radius: radius)
      ]
    ]
    // 版心区域
    #place_content(pos:(margin,margin))[
      #let tile_rd = (top-left: radius,top-right: radius,rest: 0pt)  // 标题圆角
      // MAC窗口矩形
      #rect(width: w,height: h,inset:0pt,stroke: border,fill: fill,radius: radius)[
        // 标题区
        #rect(width:100%,height:title_bar_height,fill:title_fill,radius: tile_rd)[
          // 三个圆点
          #let r = title_bar_height/4.0
          #align(left)[
            #set circle(radius: r)
            #stack(dir: ltr,spacing: 5pt)[#align(horizon)[#circle(fill: red)]][#align(horizon)[#circle(fill: yellow)]][#align(horizon)[#circle(fill:green)]]
          ]
        ]
      ]
    ]
    // 其他自定义前景内容
    #if fg_contents != none [#fg_contents] 
  ],
  margin: (x:margin+inset,y:margin + title_bar_height +inset)
)[#body]

// -------------------------- 其他函数 --------------------------
// 明信片
#let post_card(pos:(0pt,0pt),size:(100%,20cm),angle:0deg,img_uri,title,sub_title) = [
  #place(top,dx:pos.at(0),dy:pos.at(1))[
    #rotate(angle)[
      #rect(fill:white,inset: 10pt,width: size.at(0)+20pt)[
        #set par(spacing: 6pt,linebreaks: "simple")
        #image(img_uri,width: size.at(0),height:size.at(1)) 
        #text(font: "FZCuHeiSongS-B-GB",size: 30pt)[#title]
        #text(font: "KaiTi",size: 20pt)[/#sub_title]
      ]
    ]
  ]
]


// 带透明渐变的单色渐变填充(单向)
#let color_op_grad(base_color) = {
  let arr = ()
  arr.push(base_color.opacify(-60%))
  arr.push(base_color.opacify(-100%))
  return arr
}

// 带透明渐变的单色渐变填充(双面)
#let color_op_grad2(base_color) = {
  let arr = ()
  arr.push(base_color.opacify(-100%))
  arr.push(base_color.opacify(-60%))
  arr.push(base_color.opacify(-60%))
  arr.push(base_color.opacify(-100%))
  return arr
}

// 彩条线
#let color_rect_line(colors,width:100%,height:4pt) = [
  #let w = width / colors.len()
  #stack(
    dir:ltr,
    ..colors.map(
      c => [
        #rect(fill:c,width:w,height:height)
      ]
    )
  )
]

// 水平分割线
#let hr = line.with(length: 100%,stroke: luma(200))
// 水平分割线 - 虚线
#let dash_hr = line.with(
  length: 100%,
  stroke: (
    paint:luma(200),dash: "dashed"
  )
)

// 无序列表
#let rect_list(body) = rect(fill: luma(230),width: 100%,inset: 20pt,radius: 5pt)[
  #set list(marker: "👉")
  #body
]

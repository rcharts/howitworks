---
title       : rCharts
author      : Ramnath Vaidyanathan
framework   : minimal
highlighter : prettify
hitheme     : twitter-bootstrap
mode        : selfcontained
github      : {user: rcharts, repo: howitworks, branch: gh-pages}
widgets     : [disqus, ganalytics]
assets:
  css: 
    - "http://fonts.googleapis.com/css?family=PT+Sans"
    - "../assets/css/app.css"
    - "../assets/css/gh-buttons.css"
    - "http://odyniec.net/articles/turning-lists-into-trees/css/tree.css"
url: {lib: ../libraries}
---

## Micropolar with rCharts

[Micropolar](http://micropolar.org) is a polar chart library made with `d3.js`. I saw the announcement on twitter by [@d3visualization](https://twitter.com/d3visualization) and could not resist the urge to integrate it with rCharts.

I should say that `micropolar` is extremely well designed for reusability.  The author Chris Viau is also a coauthor of the very good book [Developing a D3.js Edge](http://bleedingedgepress.com/our-books/developing-a-d3-js-edge/) that details how to make `d3.js` charts reusable.  Well designed reusable charts integrate easily with `rCharts`.

We need a helper function to transform a data frame to the format required by micropolar.





```r
make_dataset = function(x, y, data = data){
  require(rCharts)
  lapply(toJSONArray2(data[c(x, y)], json = F, names = F), unlist)
}

dat = data.frame(
  x = c(60, 180, 270, 360),
  y = c(5, 2, 3, 4)
)
```


### Example 1


```r
u1 <- rCharts$new()
u1$setLib('http://rcharts.github.io/howitworks/libraries/widgets/micropolar')
u1$set(
  data = make_dataset('x', 'y', dat),
  type = 'dotPlot',
  width = 400,
  height = 400
)
u1
```

<iframe src=assets/fig/unnamed-chunk-3.html seamless></iframe>


### Other Chart Types

We are working on some useful examples of R data with the other `micropolar` chart types.  For now, let's look at the chart types using the defaults specified by `micropolar`.


```r
u2 <- rCharts$new()
u2$setLib('http://rcharts.github.io/howitworks/libraries/widgets/micropolar')
u2$set(
  type = 'linePlot',
  width = 400,
  height = 400
)
u2
```

<iframe src=assets/fig/unnamed-chunk-4.html seamless></iframe>



```r
u3 <- u2
u3$set( type = 'areaChart' )
u3
```

<iframe src=assets/fig/unnamed-chunk-5.html seamless></iframe>



```r
u4 <- u2
u4$set( type = 'barChart' )
u4
```

<iframe src=assets/fig/unnamed-chunk-6.html seamless></iframe>



```r
u5 <- u2
u5$set( type = 'clock' )
u5
```

<iframe src=assets/fig/unnamed-chunk-7.html seamless></iframe>


<div id='disqus_thread'></div>



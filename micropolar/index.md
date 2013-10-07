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

I should say that `micropolar` is an extremely well designed library, and was actually really easy integrating with `rCharts`. You can find the library folder [here](../libraries/widgets/micropolar).

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
  width = 600,
  height = 400
)
u1
```

<iframe src=assets/fig/unnamed-chunk-3.html seamless></iframe>


<div id='disqus_thread'></div>



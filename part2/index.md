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

# How rCharts Works?
#### Part 2

<!-- AddThis Smart Layers BEGIN -->
<!-- Go to http://www.addthis.com/get/smart-layers to customize -->
<script type="text/javascript" src="//s7.addthis.com/js/300/addthis_widget.js#pubid=ra-4fdfcfd4773d48d3"></script>
<script type="text/javascript">
  addthis.layers({
    'theme' : 'transparent',
    'share' : {
      'position' : 'left',
      'numPreferredServices' : 5
    }   
  });
</script>
<!-- AddThis Smart Layers END -->




<a href="http://prose.io/#{{page.github.user}}/{{page.github.repo}}/edit/gh-pages/part2/index.Rmd" class="button icon edit">Edit Page</a>

This is the second part of a multi-part series on how rCharts works. My objective is to show you how easy it is to integrate a javascript visualization library into rCharts, and take advantage of a single-unified interface and other functionalities.

In the [first part](http://rcharts.io/howitworks), I showed you how to integrate [uvCharts](http://imaginea.github.io/uvCharts/) with rCharts, and create a simple barchart, straight from R. In this second part, I will take you through the steps required to expose the full API of uvCharts, so that all customization features are directly accessible from R.

## uvCharts

From the [documentation page](http://imaginea.github.io/uvCharts/documentation.html) of uvCharts, we observe that all charts are specified using a single function `uv.chart`.

```js
var chartObject = uv.chart(chartType, graphDefinition, optionalConfiguration)
```

It accepts three arguments.

- [chartType](http://imaginea.github.io/uvCharts/documentation.html#charts) is a string that specifies the type of the chart (e.g. BarChart).
- [graphDefinition](http://imaginea.github.io/uvCharts/documentation.html#graphdef) is a json object consisting of [categories](http://imaginea.github.io/uvCharts/documentation.html#graphdef-categories) and [dataset](http://imaginea.github.io/uvCharts/documentation.html#graphdef-categories), that specify the different groups and the dataset (name-value pairs) corresponding to each group.
-  [optionalConfiguration](http://imaginea.github.io/uvCharts/documentation.html#configuration) is a json object consisting of different configuration elements (e.g. [meta](http://imaginea.github.io/uvCharts/documentation.html#config-meta), [margin](http://imaginea.github.io/uvCharts/documentation.html#config-margin) etc), each of which consists of key-value pairs.

<iframe
  style="width: 100%; height: 650px"
  src="http://jsfiddle.net/ramnathv/w669V/2/embedded/js,result">
</iframe>

 

Our objective now is to translate this javascript into a mustache layout and populate it with data and parameters from R

--- .RAW

## Layout

The mustache layout shown below is a modified version of what we developed in [Part 1](http://rcharts.io/howitworks). The basic idea is to bundle the entire payload into a single json object `chartParams` (which is returned by default), and recover `graphdef`, `config` and `type` from it. Just as a reminder `foo.bar` in javascript is equivalent to `foo$bar` in R.

```html
<script>
  var chartParams = {{{ chartParams }}},
      graphdef = chartParams.graphdef,
      config = chartParams.config
  
  config.meta.position = '#{{chartId}}'
  
  var chart = uv.chart(chartParams.type, graphdef, config);
</script>
```

---

## Reference Class

`rCharts` uses an object-oriented approach called [reference classes](http://adv-r.had.co.nz/OO-essentials.html#rc), that allows common functionality to be bundled into a parent class, and library specific functionality to be defined or overridden in the child class.

In Part 1 of this series, we had directly used the `rCharts` base class and the generic `set` and `setLib` methods to integrate `uvCharts`. However, for greater flexibility, it is better to implement `uvCharts` as a separate class that inherits from the `rCharts` base class.

```r
Uvcharts <- setRefClass('Uvcharts', contains = 'rCharts', 
  methods = list(
    initialize = function(){
      callSuper()
      params$config <<- list(meta = list(position = "#uv-div"))
    },
    config = function(..., replace = F){
      params$config <<- setSpec(params$config, ..., replace = replace)
    }
  )
)
```

We define the `Uvcharts` class to be a reference class that __contains__ the parent `rCharts` class. This allows `Uvcharts` to inherit all common functionality, like publishing, integration with Shiny etc. The `initialize` method uses `callSuper()` to execute the default initialization code for all `rCharts` classes, and then sets the `meta` parameter of `config` to '#uv-div'.

The `config` method allows different configuration elements to be specified easily without having to resort to a convoluted sequence of nested lists. Note that these methods allows users to build a visualization in steps, rather than having to specify everything in a single function call. Moreover, reference classes have state, and so you can avoid writing statements like `x <- x + ...`

Now that all the hard work is done, our final step is to wrap the `Uvcharts` class into a `uPlot` function, that will be the primary interface through which a user will create charts. The `uPlot` function returns an instance of the `rCharts` class, whic allows a user to customize the plot further using helper methods. However, we also allow a user to pass configuration related parameters directly to `uPlot`,  use the ubiquitous `...`.


```r
uPlot <- function(x, y, data, group = NULL, type, ...){
  dataset = make_dataset(x = x, y = y, data = data, group = group)
  u1 <- Uvcharts$new()
  u1$set(graphdef = list(
    categories = names(dataset),
    dataset = dataset
  ))
  u1$set(type = type)
  if (length(list(...)) > 0){
   u1$config(...)
  }
  return(u1)
}
```




Now, it is time to recreate the chart using our new `Uvcharts` class and its new helper methods. Make sure to update your rCharts installation before trying this code in your R console.


```r
# devtools::install_github("rCharts", "ramnathv", ref = "dev")
hair_eye_male <- subset(as.data.frame(HairEyeColor), Sex == "Male")
dataset = make_dataset('Hair', 'Freq', hair_eye_male, group = 'Eye')
u1 <- uPlot("Hair", "Freq", 
  data = hair_eye_male, 
  group = "Eye",
  type = 'StackedBar'
)
u1$config(meta = list(
  caption = "Hair vs. Eye Colors",
  vlabel  = "Hair Color"
))
u1$config(graph = list(
  palette = "Olive"  
))
u1
```

<iframe src=assets/fig/myplot.html seamless></iframe>


<br/>

### Conclusions

I have hopefully convinced you by now, how easy it is to integrate javascript based visualization libraries with rCharts, making them reusable, and faster to incorporate. 

The underlying rationale behind my design of rCharts is twofold.

- The size of the javascript/d3.js developer community is always going to an order of magnitude higher than the R community. Moreover, the d3.js community has already created a huge number of [interactive visualizations](http://biovisualize.github.io/d3visualization/), that we can take advantage of. 
- As rCharts users start creating more visualizations that make use of these d3.js libraries, we will have a bigger voice in feature requests and enhancements (which is already happening for some libraries like polycharts and dimplejs) 

One of my goals behind writing this series of posts is to encourage more R users to contribute to the development of reusable interactive visualizations. You can pick any of the more than 1900 visualizations in this [gallery](http://biovisualize.github.io/d3visualization/) and write an rCharts wrapper for it. For more pointers on how to do this, I would recommend reading this [excellent post](http://timelyportfolio.github.io/rCharts_d3_horizon/) by [@timelyportfolio](http://github.com/timelyportfolio) on integrating a d3.js horizon chart with rCharts.

In the long run, I envisage a __reproducible__, __searchable__, __tagged__ gallery of interactive visualizations like [this one](http://rcharts.io/gallery), that will allow R users to quickly identify a visualization that is appropriate for their situation, fork the underlying code, and adapt it to suit their need.

The next part of this series will show you how to share your interactive chart as a [standalone chart](http://rcharts.io/viewer/?6847603), or as a part of a [knitr/slidify document](http://rcharts.io/nytinteractive/), or wrapped into a [shiny application](http://glimmer.rstudio.com/ramnathv/BikeShare/).

### Acknowledgements

I would like to thank [TimelyPortfolio](http://github.com/timelyportfolio) for his valuable suggestions and comments, which helped improve this post.


<div id='disqus_thread'></div>


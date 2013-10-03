---
title       : rCharts
author      : Ramnath Vaidyanathan
framework   : minimal
highlighter : prettify
hitheme     : twitter-bootstrap
mode        : selfcontained
github      : {user: rcharts, repo: howitworks, branch: gh-pages}
widgets     : [disqus]
assets:
  css: "http://fonts.googleapis.com/css?family=PT+Sans"
---

# How rCharts Works?

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





<a href="http://prose.io/#{{page.github.user}}/{{page.github.repo}}/edit/gh-pages/index.Rmd" class="button icon edit">Edit Page</a>

This is a two-part series on how rCharts works. My objective is to show you how easy it is to integrate a javascript visualization library into rCharts, and take advantage of a single-unified interface and other functionalities. 

In this tutorial, I will go over the steps to integrate [uvCharts](http://imaginea.github.io/uvCharts/), a new-entrant to the rapidly expanding set of wrapper libraries to [d3js](http://d3js.org). Specifically, we will recreate this barchart, which was created using uvCharts.


<iframe
  style="width: 100%; height: 600px"
  src="http://jsfiddle.net/RR8Ub/1/embedded/result,resources,js,html">
</iframe>

Browse through the `resources`, `javascript` and `html` tabs to get a sense of how the chart works.

### Resources

The resources required by a chart include the external javascript and css files that are included either in the head of the html document or at the end. rCharts uses a convention over configuration approach, and so the resources are specified using a `config.yml` file as shown below.

The [config](libraries/widgets/uvcharts/config.yml) file basically provides paths to the js/css files, both locally and  online using a cdn. 

```yaml
uvcharts:
  jshead: [js/d3.v3.min.js, js/uvcharts.js]
  cdn:
    jshead:
      - "http://cdnjs.cloudflare.com/ajax/libs/d3/3.2.2/d3.v3.min.js"
      - "http://imaginea.github.io/uvCharts/js/uvcharts.js"
```

At this point, the `uvCharts` library folder will look like this

```
uvCharts
  js
    d3.v3.min.js
    uvcharts.js
  config.yml
```


### Javascript

Our next step is to split the javascript for the chart into (1) a mustache layout, and then populate it using a `json` payload processed by R. 

<iframe
  style="width: 100%; height: 600px"
  src="http://jsfiddle.net/RR8Ub/1/embedded/js">
</iframe>

--- .RAW

By default, `rCharts` bundles all data into a single json variable `chartParams`. In addition to `chartParams`, it also sends `chartId` to the layout. So, we will begin by replacing all data in the javascript with the json payload that `rCharts` will return. We follow conventions and save this layout to `layouts/chart.html`.

#### Layout

```html
<script>
  var graphdef = {{{ chartParams }}}
  var config = {
    meta: {
      position: "#{{ chartId }}"
    }
  }
  var chart = uv.chart(graphdef.type, graphdef, config)
</script>
```

At this point our [uvCharts](libraries/widgets/uvCharts) library folder is going to look like this 

```
uvCharts
  js
    d3.v3.min.js
    uvcharts.js
  layouts
    chart.html
  config.yml
```

---

#### Payload

Different d3js wrapper libraries tend to use different data structures. Our goal with `rCharts` is to provide a single-unified interface for specifying a chart, so that a user does not need to worry about the underlying format used by a specific library. This can be easily achieved by writing functions that transform data to different formats, as required by the library.

Shown below is the dataset that we will be working with. We need to convert it into an R object, that when converted to JSON will look like the object `dataset` seen in the `javascript` shown above.



```r
hair_eye_male <- subset(as.data.frame(HairEyeColor), Sex == "Male")
head(hair_eye_male)
```

```
   Hair   Eye  Sex Freq
1 Black Brown Male   32
2 Brown Brown Male   53
3   Red Brown Male   10
4 Blond Brown Male    3
5 Black  Blue Male   11
6 Brown  Blue Male   50
```


We will now write a `make_dataset` data transformation function that takes `x`, `y`, `data` and `group` as inputs, and returns a data structure that when converted to JSON will match what we need. The basic idea behind `make_dataset` is to (a) rename the `x`, `y` columns to `name`, `value`, (b) split the `data` based on `group` and (c) convert each piece into a JSON array.



```r
make_dataset <- function(x, y, data, group = NULL){
  require(plyr)
  dat <- rename(data, setNames(c('name', 'value'), c(x, y)))
  dat <- dat[c('name', 'value', group)]
  if (!is.null(group)){
    dlply(dat, group, toJSONArray, json = F)
  } else {
    list(main = toJSONArray(dat, json = F)) 
  }
}
```


You can run the code below to check that it produces the same `dataset` variable seen in the javascript above.


```r
dataset = make_dataset('Hair', 'Freq', hair_eye_male, group = 'Eye')
cat(RJSONIO::toJSON(dataset))
```


--- #mychart

### Chart Creation

It is now time to put everything together and create the chart from R. We initialize the chart as an instance of `rCharts`, use the `setLib` method to point to the location of the library folder, and then pass the data payload using the `set` method. 


```r
u1 <- rCharts$new()
u1$setLib("libraries/widgets/uvcharts")
u1$set(
  type = 'Bar',
  categories = names(dataset),
  dataset = dataset,
  dom = 'chart1'
)
u1
```

<iframe src=assets/fig/unnamed-chunk-4.html seamless></iframe>


For the above code to work, you need to make sure that you have [downloaded](https://github.com/rcharts/howitworks/zipball/gh-pages) this repo, and are referring to the correct path to the `uvCharts` library.

You could save all this code in an file named [myChart.R](assets/code/mychart.R) and then publish the chart along with the code by running.

```r
u2 <- create_chart('assets/code/myChart.R')
u2$publish('My Chart')
```

You can simplify the chart creation interface further, by wrapping everything into a `uPlot` function


```r
uPlot <- function(x, y, data, group = NULL, ...){
  dataset = make_dataset(x = x, y = y, data = data, group = group)
  u1 <- rCharts$new()
  u1$setLib("libraries/widgets/uvcharts")
  u1$set(
    categories = names(dataset),
    dataset = dataset,
    ...
  )
  return(u1)
}
```


Let us create a `StackedBar` chart using `uPlot`


```r
uPlot("Hair", "Freq", 
  data = hair_eye_male, 
  group = "Eye",
  type = 'StackedBar'
)
```

<iframe src=assets/fig/stackedbar.html seamless></iframe>


So you can see for yourself, how easy it is to integrate a javascript visualization library into `rCharts`. Now, the [uvCharts](http://imaginea.github.io/uvCharts/documentation.html) API provides more functionality to customize the chart. While, we can use nested lists with the `set` method to access this functionality, it would be cleaner to write custom methods that make things easier. We will go over this in Part 2 of this series.


<div id='disqus_thread'></div>


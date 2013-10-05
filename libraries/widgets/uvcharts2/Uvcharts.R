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

uPlot2 <- function(x, y, data, group = NULL, type, ...){
  dataset = make_dataset(x = x, y = y, data = data, group = group)
  u1 <- rCharts::rCharts$new()
  u1$setLib("libraries/widgets/uvcharts2")
  u1$set(
    graphdef = list(
      categories = names(dataset),
      dataset = dataset
    ),
    type = type,
    config = modifyList(
      list(...),
      list(meta = list(position = '#uv-div'))
    )
  )
  return(u1)
}

hair_eye_male <- subset(as.data.frame(HairEyeColor), Sex == "Male")
dataset = make_dataset('Hair', 'Freq', hair_eye_male, group = 'Eye')

uPlot2("Hair", "Freq", 
  data = hair_eye_male, 
  group = "Eye",
  type = 'StackedBar',
  graph = list(palette = 'Olive'),
  meta = list(isDownloadable = TRUE, vlabel = 'Hair Color')
)

u1 <- uPlot("Hair", "Freq", data = hair_eye_male, 
  group = "Eye", type = 'StackedBar'
)
u1$config(graph = list(palette = 'Olive'))
u1$config(meta = list(vlabel = 'Hair Color', isDownloadable = TRUE))

Uvcharts <- setRefClass('Uvcharts', contains = 'rCharts', methods = list(
  initialize = function(){
    callSuper()
    params$config <<- list(meta = list(position = "#uv-div"))
    templates <<- list(
        
    )
  }
  config = function(...){
    params$config <<- setSpec(params$config, ..., replace = replace)
  }
))

uPlot2 <- function(x, y, data, group = NULL, type, ...){
  dataset = make_dataset(x = x, y = y, data = data, group = group)
  u1 <- rCharts::rCharts$new()
  u1$setLib("libraries/widgets/uvcharts2")
  u1$set(
    graphdef = list(
      categories = names(dataset),
      dataset = dataset
    ), type = type)
  )
  return(u1)
}

require(fAssets)

# example from fAssets documentation
LPP = as.timeSeries(data(LPP2005REC))
assetsBasicStatsPlot(LPP, title = "", description = "")
assetsBoxStatsPlot(LPP, title = "", description = "")
bs <- basicStats(LPP[,"LPP60"])
bs.df <- data.frame(1:(nrow(bs)-2),sqrt(abs(bs[-(1:2),])))
colnames(bs.df) <- c("x","y")
rownames(bs.df) <- rownames(bs)[-(1:2)]

# basic stats by default scales the values
# here is the code
x <- data.matrix(t(bs)[,-(1:2)])
x <- apply(x, 2L, function(x) (
  x - min(x, na.rm = TRUE))/diff(range(x, na.rm = TRUE)
))
x.df <- data.frame(rownames(x),x,stringsAsFactors = FALSE)
colnames(x.df) <- c("x","y")

bxs <- assetsBoxPlot(LPP[,"SPI"],plot=FALSE)$stats
bxs.df <- data.frame(1:nrow(bxs),bxs,stringsAsFactors=FALSE)
colnames(bxs.df) <- c("metric", "y")

#bs.df <- bs.df[-nrow(bs.df),]
bs.df[,2] <- 1:14


require(rCharts)

make_dataset = function(x, y, data = data){
  require(rCharts)
  lapply(toJSONArray2(data[c(x, y)], json = F, names = F), unlist)
}

uArea <- rCharts$new()
uArea$setLib('http://rcharts.github.io/howitworks/libraries/widgets/micropolar')
uArea$setLib(getwd())
uArea$set(
  data = make_dataset('x','y', x.df), #bs.df),
  angularDomain = as.character(x.df$x),
  radialDomain = range(x.df[,2]),
  radialAxisTheta = 0,
  originTheta = 90,
  type = 'areaChart',
  width = 400,
  height = 400,
  minorTicks = 0
)
uArea

uBarBox <- rCharts$new()
uBarBox$setLib('http://rcharts.github.io/howitworks/libraries/widgets/micropolar')
uBarBox$set(
  data = make_dataset( x="metric", y="y", bxs.df ),
  radialDomain = c(-max(bxs.df$y)/4,max(bxs.df$y) + max(bxs.df$y)/4),
  angularDomain = rownames(bxs.df),
  minorTicks = 0,
  height = 600,
  width = 600,
  type = "barChart"
)
uBarBox

uAreaBox <- rCharts$new()
#uAreaBox$setLib('http://rcharts.github.io/howitworks/libraries/widgets/micropolar')
uAreaBox$setLib(getwd())
uAreaBox$set(
  data = make_dataset( x="metric", y="y", bxs.df ),
  radialDomain = range(bxs.df$y),
  angularDomain = rownames(bxs.df),
  minorTicks = 0,
  height = 600,
  width = 600,
  type = "areaChart"
)
uAreaBox


uBar <- rCharts$new()
uBar$setLib('http://rcharts.github.io/howitworks/libraries/widgets/micropolar')
uBar$set(
  data = make_dataset('x','y', bs.df),
  angularDomain = rownames(bs.df),
  radialDomain = c(-0.25,ceiling(max(abs(range(bs.df[,2]))))),
  #radialAxisTheta = 360/nrow(bs.df),
  type = 'barChart',
  width = 400,
  height = 400
  #minorTicks = 0
)
uBar


polar.df <- data.frame(1:20,1:20,stringsAsFactors=FALSE)
colnames(polar.df) <- c("x","y")
uArea <- rCharts$new()
#uArea$setLib('http://timelyportfolio.github.io/howitworks/libraries/widgets/micropolar')
uArea$setLib(getwd())
uArea$set(
  data = make_dataset('x','y',polar.df),
  angularDomain = as.character(1:20),
  radialDomain = range(polar.df$y),
  type = 'areaChart',
  rewriteTicks=TRUE,
  orient="horizontal",
  originTheta = -90,
  flip=TRUE,
  width = 400,
  height = 400,
  minorTicks = 0
)
uArea




# default areaChart
areaData <- data.frame(seq(50,600,50),runif(12,0,1))
colnames(areaData) <- c("x","y")
microArea <- rCharts$new()
microArea$setLib('http://rcharts.github.io/howitworks/libraries/widgets/micropolar')
microArea$set(
  data = make_dataset('x','y',data=areaData),
  radialDomain = range(areaData$y),
  angularDomain = as.character(areaData$x),
  type = 'areaChart',
  minorTicks = 0,
  height = 250,
  width = 250
)
microArea





#try out method of visualizing weight and return or risk
maxport <- maxratioPortfolio(LPP)
wgt <- getWeights(maxport)
ret <- getMu(maxport)
risk <- sqrt(diag(getStatistics(maxport)$Cov))
dataPlot <- data.frame(wgt,ret,risk)

#polar area does not yet handle numeric angular scale
maxArea <- rCharts$new()
#maxArea$setLib('http://rcharts.github.io/howitworks/libraries/widgets/micropolar')
maxArea$setLib(getwd())
maxArea$set(
  data = make_dataset(x="wgt", y="ret",data=dataPlot[which(dataPlot$wgt!=0),]),
  radialDomain = c(0,max(dataPlot$ret)),
  angularDomain = c(0,1,0.1),#rownames(dataPlot[which(dataPlot$wgt!=0),]),
  type = "areaChart",
  minorTicks = 0,
  height = 400,
  width =400
)
maxArea


maxDot <- rCharts$new()
#maxDot$setLib('http://rcharts.github.io/howitworks/libraries/widgets/micropolar')
maxDot$setLib(getwd())
maxDot$set(
  data = make_dataset(x="wgt", y="ret",data=dataPlot),
  radialDomain = c(0,max(dataPlot$ret)),
  angularDomain = c(0,1,0.1),
  type = "dotPlot",
  #radialTicksSuffix = "%", #not supported by dotPlot
  originTheta = -90,
  flip = TRUE,
  minorTicks = 0,
  height = 400,
  width =400
)
maxDot


maxDot <- rCharts$new()
#maxDot$setLib('http://rcharts.github.io/howitworks/libraries/widgets/micropolar')
maxDot$setLib(getwd())
maxDot$set(
  data = make_dataset(x="risk", y="ret", data=dataPlot),
  radialDomain = c(0,max(dataPlot$ret)),
  angularDomain = c(0,1,0.1),
  type = "dotPlot",
  #radialTicksSuffix = "%", #not supported by dotPlot
  originTheta = -90,
  flip = TRUE,
  minorTicks = 0,
  height = 400,
  width =400
)
maxDot





lineData <- data.frame( seq(0,100,5) * 360 / 100, runif(21,0,1) )
colnames(lineData) <- c( "x", "y" )
microLine <- rCharts$new()
microLine$setLib( getwd() )
microLine$set(
  data = make_dataset( x = "x", y= "y", data = lineData),
  type = "linePlot",
  originTheta = 0,
  radialAxisTheta = 0,
  angularDomain = c( 0, 100, 5 ),
  radialDomain = c( 0, 1),
  angularTicksSuffix = "",
  minorTicks = 0,
  flip = TRUE,
  height = 400,
  width = 400
)
microLine


require(rCharts)
require(PerformanceAnalytics)
data(managers)
retData <- data.frame(
  0:(NROW(managers)-1) * 360/NROW(managers),  # 0 to nrow scaled to 360 since 360 deg in circle
  as.numeric(as.POSIXct(index(managers[,1])))*1000, # make numeric javascript date
  managers[,1]
)
colnames(retData) <- c('x','date','y')
retLine <- rCharts$new()
retLine$setLib( getwd() )
retLine$set(
  data = make_dataset( x = "x", y= "y", data = retData),
  type = "linePlot",
  originTheta = 0,
  radialAxisTheta = 0,
  angularDomain = 
    paste0(
      "#!d3.time.format('%b %Y')(new Date(",
      retData$date[seq(1,NROW(retData),6)],
      "))!#"),
  #radialDomain = c( 0, 1),
  angularTicksSuffix = '',
  tickOrientation = "horizontal",
  minorTicks = 0,
  flip = TRUE,
  height = 400,
  width = 400
)
retLine


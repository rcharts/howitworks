hair_eye_male <- subset(as.data.frame(HairEyeColor), Sex == "Male")
dataset = make_dataset('Hair', 'Freq', hair_eye_male, group = 'Eye')
u1 <- rCharts$new()
u1$setLib("libraries/widgets/uvcharts")
u1$set(
  type = 'Bar',
  categories = names(dataset),
  dataset = dataset,
  dom = 'chart1'
)
u1
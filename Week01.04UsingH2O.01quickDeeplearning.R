library(h2o)

h2o.init()

url <- "http://h2o-public-test-data.s3.amazonaws.com/smalldata/iris/iris_wheader.csv"
iris <- h2o.importFile(url)

parts <- h2o.splitFrame(iris, 0.8)
train <- parts[[1]]
test <- parts[[2]]

summary(train)
nrow(train)
nrow(test)

mDL <- h2o.deeplearning(1:4, 5, train)

mDL

p <- h2o.predict(mDL, test)

p

h2o.performance(mDL, test)

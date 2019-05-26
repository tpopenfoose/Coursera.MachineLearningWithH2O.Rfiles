library(h2o)
h2o.init(nthreads = -1)

url <- "http://h2o-public-test-data.s3.amazonaws.com/smalldata/iris/iris_wheader.csv"
iris <- h2o.importFile(url)

parts <- h2o.splitFrame(iris, 0.8)
train <- parts[[1]]
test <- parts[[2]]

## K-means

m <- h2o.kmeans(train, x = 1:4, k = 3)
p <- h2o.predict(m, train)

as.data.frame(h2o.cbind(train$class, p$predict))

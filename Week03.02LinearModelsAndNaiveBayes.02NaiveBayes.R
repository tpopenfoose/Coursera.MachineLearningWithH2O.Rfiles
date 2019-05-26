library(h2o)
h2o.init()

url <- "http://h2o-public-test-data.s3.amazonaws.com/smalldata/iris/iris_wheader.csv"; url
iris <- h2o.importFile(url)

parts <- h2o.splitFrame(iris, 0.8)
train <- parts[[1]]
test <- parts[[2]]

nrow(train)
nrow(test)

mNB <- h2o.naiveBayes(1:4, 5, train)

mNB

p <- h2o.predict(mNB, test)

p

h2o.performance(mNB, test)

mNB_1 <- h2o.naiveBayes(1:4, 5, train, laplace=1)
h2o.performance(mNB_1, test)

mNB_10 <- h2o.naiveBayes(1:4, 5, train, laplace=10)
h2o.performance(mNB_10, test)

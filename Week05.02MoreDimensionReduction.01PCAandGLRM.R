library(h2o)
h2o.init(nthreads = -1)

url <- "http://h2o-public-test-data.s3.amazonaws.com/smalldata/iris/iris_wheader.csv"
iris <- h2o.importFile(url)

parts <- h2o.splitFrame(iris, 0.8)
train <- parts[[1]]
test <- parts[[2]]

## PCA

m_PCA <- h2o.prcomp(train, 1:4, k = 4, impute_missing = TRUE)
m_PCA

p_PCA <- h2o.predict(m_PCA, train)
p_PCA


## GLRM

m_GLRM <- h2o.glrm(train, 1:4, k = 4)
m_GLRM

p_GLRM <- h2o.predict(m_GLRM, train)
p_GLRM

## Reduce 4 numeric and 1 enum to 3 columns

m_GLRM3 <- h2o.glrm(train, 1:5, k=3)
m_GLRM3

p_GLRM3 <- h2o.predict(m_GLRM3, train)
as.data.frame(h2o.cbind(train$class, p_GLRM3$reconstr_class))

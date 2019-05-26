library(h2o)
h2o.init()

data <- h2o.importFile("http://h2o-public-test-data.s3.amazonaws.com/smalldata/airlines/allyears2k_headers.zip")

nrow(data)

parts <- h2o.splitFrame(data, c(0.8,0.1), seed = 69)
train <- parts[[1]]; nrow(train)  ## 35255
valid <- parts[[2]]; nrow(valid)  ## 4272
test <- parts[[3]]; nrow(test)    ## 4451


h2o.describe(train)
nrow(train)


as.data.frame(  ## Show all 22 rows
    h2o.group_by(
        train,
        'Year',   ## Group by year
        nrow("CarrierDelay"),  ## Number of ...
        gb.control=list(na.methods="rm")   ## ...non-NAs
    )
)


h2o.hist(train$CarrierDelay)
as.data.frame(h2o.table(train$CarrierDelay))
h2o.hist(train$CarrierDelay[train$CarrierDelay >= 1, ], breaks = 285)


h2o.cor(train[ , c('CarrierDelay', 'DepDelay')], na.rm = TRUE)


y <- 'CarrierDelay'
x <- setdiff(colnames(train), c(y, "TailNum"))

badRowsT <- is.na(train$CarrierDelay)
badRowsV <- is.na(valid$CarrierDelay)

trainGood <- train[!badRowsT, ]
validGood <- valid[!badRowsV, ]
trainBad <- train[badRowsT, ]

m_GBM_g <- h2o.gbm(x, y, trainGood, validation_frame = validGood, distribution = "gamma")
m_GBM_g

## Now make predictions for the bad rows
newValues <- h2o.floor(h2o.predict(m_GBM_g, trainBad))

h2o.hist(trainGood[ , y], breaks = 100)
h2o.hist(newValues, breaks = 100)
range(trainGood[ , y])
range(newValues)


trainBad[ , y] <- newValues
train2 <- h2o.rbind(trainGood, trainBad)

h2o.describe(train2)
h2o.describe(train)

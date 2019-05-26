library(h2o)
h2o.init()

data <- h2o.importFile("http://h2o-public-test-data.s3.amazonaws.com/smalldata/airlines/allyears2k_headers.zip")

nrow(data)

parts <- h2o.splitFrame(data, c(0.8,0.1), seed = 69)
train <- parts[[1]]; nrow(train)  ## 35255
valid <- parts[[2]]; nrow(valid)  ## 4272
test <- parts[[3]]; nrow(test)    ## 4451

y <- "IsArrDelayed"

xAll <- setdiff(colnames(data), c(
                                    "ArrDelay", "DepDelay",
                                    "CarrierDelay", "WeatherDelay",
                                    "NASDelay", "SecurityDelay",
                                    "LateAircraftDelay",
                                    "IsDepDelayed", "IsArrDelayed",
                                    "ActualElapsedTime", # But CRSElapsedTime is fine
                                    "ArrTime"   ## But CRSArrTime is fine
                                )
                )

xLikely <- c("Month", "DayOfWeek", "UniqueCarrier",
             "Origin", "Dest", "Distance",
             "Cancelled", "Diverted")

system.time(  # 100s (2 cores/threads), or 47s to 50s with 4 cores, 8 threads
    m_def <- h2o.deeplearning(xAll, y, train,
                     validation_frame = valid)
)

h2o.performance(m_def, valid = TRUE)

## Default GLM: logloss 0.623, MSE 0.218, Error = 0.385
##   Tuned GLM:    -->> 0.590
##  Default DL: logloss 0.286 to 0.312, MSE 0.090 to 0.101, Error = 0.123 to 0.

plot(m_def)


m_200_epochs <- h2o.deeplearning(xAll, y, train,
                                 validation_frame = valid,
                                 epochs = 200,
                                 stopping_round = 5,  # Default
                                 stopping_tolerance = 0,  # Default
                                 stopping_metric = "logloss"  # Indirectly the default
                                 )
h2o.performance(m_200_epochs, valid = TRUE)
plot(m_200_epochs)

h2o.scoreHistory(m_200_epochs)

## In one test run: the low logloss was 0.30220, at epoch 23 (after 1m 52s)
##   It did a total of 13 scoring rounds, 54 epochs, in 5m 7.5s
##   (It was at 0.311 after roughly 10 epochs.)

## Tuning idea: does it need another layer?
m_200x200x200 <- h2o.deeplearning(xAll, y, train,
                                  validation_frame = valid,
                                  epochs = 200,
                                  hidden = c(200, 200, 200)
                                  )

h2o.performance(m_200x200x200, valid=TRUE)
plot(m_200x200x200)

h2o.scoreHistory(m_200x200x200)


## Tuning idea: does it bigger layers?
m_400x400 <- h2o.deeplearning(xAll, y, train,
                              validation_frame = valid,
                              epochs = 200,
                              hidden = c(400, 400)
                              )

h2o.performance(m_400x400, valid=TRUE)
plot(m_400x400)

h2o.scoreHistory(m_400x400)


#####  Part 2  #################################################

## The score history tells me 53 epochs took 11m 36s, i.e. over double
##  what the 200x200 model took.

models <- c(m_def, m_200_epochs, m_200x200x200, m_400x400)
sapply(models, h2o.auc, valid = TRUE)

m_def@model$model_summary$units   ## 3801  200  200    2

sapply(models, function(m) {
    u = m@model$model_summary$units
    sapply(2:length(u), function(ix) u[ix-1] * u[ix])
})

sapply(models, function(m) {
    u = m@model$model_summary$units
    sum(sapply(2:length(u), function(ix) u[ix-1] * u[ix]))
})

## [1]  800600  800600  840600 1681200
##                             ^^^^^^^ Aha!


h2o.describe(train)  ## and look at cardinality, which is how many
## levels a factor (aka enum/categorical) has


x2 <- setdiff(xAll, "TailNum")

system.time(  # 12s with 4 cores, 8 threads.
    m2_def <- h2o.deeplearning(x2, y, train,
                               validation_frame = valid)
)

system.time(  # 167s
    m2_400x400 <- h2o.deeplearning(x2, y, train,
                                   validation_frame = valid,
                                   epoch = 200,
                                   hidden = c(400, 400))
)

system.time(  # 96s
    m2_200_epochs<- h2o.deeplearning(x2, y, train,
                                     validation_frame = valid,
                                     epoch = 200)
)

system.time(  # 158s
    m2_200x200x200 <- h2o.deeplearning(x2, y, train,
                                       validation_frame = valid,
                                       epoch = 200,
                                       hidden = c(200, 200, 200))
)


all_models <- c(m_def, m2_def, m_200_epochs, m2_200_epochs,
                m_200x200x200, m2_200x200x200, m_400x400, m2_400x400)

loglosses <- sapply(all_models, function(m) {
                    h2o.logloss(m, valid = TRUE)
})
cat(sprintf(" defaults   : %.4f --> %.4f\n 200 epochs : %.4f --> %.4f\n 200x200x200: %.4f --> %.4f\n 400x400    : %.4f --> %.4f \n ",
        loglosses[1], loglosses[2], loglosses[3], loglosses[4], loglosses[5], loglosses[6], loglosses[7], loglosses[8]))


mses <- sapply(all_models, function(m) {
               h2o.mse(m, valid = TRUE)
})
cat(sprintf(" defaults   : %.4f --> %.4f\n 200 epochs : %.4f --> %.4f\n 200x200x200: %.4f --> %.4f\n 400x400    : %.4f --> %.4f \n ",
        mses[1], mses[2], mses[3], mses[4], mses[5], mses[6], mses[7], mses[8]))

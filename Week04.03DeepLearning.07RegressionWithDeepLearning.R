library(h2o)
h2o.init(nthreads = -1)

data <- h2o.importFile("http://h2o-public-test-data.s3.amazonaws.com/smalldata/airlines/allyears2k_headers.zip")

parts <- h2o.splitFrame(data, c(0.8,0.1), seed = 69)
train <- parts[[1]]; nrow(train)  ## 35255
valid <- parts[[2]]; nrow(valid)  ## 4272
test <- parts[[3]]; nrow(test)    ## 4451

y <- "ArrDelay"

xWithDep <- setdiff(colnames(data), c(
                                        "ArrDelay", "IsArrDelayed",
                                        "ActualElapsedTime", # But CRSElapsedTime is fine
                                        "ArrTime",   ## But CRSArrTime is fine
                                        "TailNum"    ## High cardinality, (presumed) low information
                                    )
                    )


system.time(  ## 17 to 18s
    m_DLR_def <- h2o.deeplearning(xWithDep, y, train,
                                  validation_frame = valid,
                                  model_id = "DLR_def",
                                  variable_importances = TRUE
                                  )
    )

h2o.performance(m_DLR_def, valid = TRUE)
plot(m_DLR_def)

h2o.varimp(m_DLR_def)
h2o.varimp_plot(m_DLR_def, 30)

system.time(  ## 17 to 18s
    m_DLR_200_epochs <- h2o.deeplearning(xWithDep, y, train,
                                         validation_frame = valid,
                                         model_id = "DLR_def",
                                         variable_importances = TRUE,
                                         epochs = 200,
                                         stopping_rounds=5,
                                         stopping_tolerance=0.0,
                                         stopping_metric="deviance"
                                         )
)


h2o.performance(m_DLR_200_epochs, valid = TRUE)
plot(m_DLR_200_epochs)

h2o.varimp(m_DLR_200_epochs)
h2o.varimp_plot(m_DLR_200_epochs, 30)

h2o.scoreHistory(m_DLR_200_epochs)

h2o.hist(train$ArrDelay)  ## looks like a laplace distribution

system.time(  ## 17 to 18s
    m_DLR_laplace <- h2o.deeplearning(xWithDep, y, train,
                                      validation_frame = valid,
                                      model_id = "DLR_def",
                                      variable_importances = TRUE,
                                      epochs = 200,
                                      stopping_rounds=5,
                                      stopping_tolerance=0.0,
                                      stopping_metric="deviance",
                                      distribution = "laplace"
                                      )
)

h2o.performance(m_DLR_laplace, valid = TRUE)
plot(m_DLR_laplace)

allModels <- c(m_DLR_def, m_DLR_200_epochs, m_DLR_laplace)
mae <- signif(sapply(allModels, function(m) {
                                h2o.mae(m, valid = TRUE)
               }), 5)
cat("   defaults:", mae[1], "\n 200 epochs:", mae[2], "\n    laplace:", mae[3], "\n")

rmse <- signif(sapply(allModels, function(m) {
                                h2o.rmse(m, valid = TRUE)
               }), 5)
cat("   defaults:", rmse[1], "\n 200 epochs:", rmse[2], "\n    laplace:", rmse[3], "\n")

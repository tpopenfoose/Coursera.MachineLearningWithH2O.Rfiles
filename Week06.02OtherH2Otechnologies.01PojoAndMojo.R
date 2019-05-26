library(h2o)
h2o.init()

data <- h2o.importFile("http://h2o-public-test-data.s3.amazonaws.com/smalldata/airlines/allyears2k_headers.zip")

parts <- h2o.splitFrame(data, c(0.8,0.1), seed = 69)
train <- parts[[1]]; nrow(train)  ## 35255
valid <- parts[[2]]; nrow(valid)  ## 4272
test <- parts[[3]]; nrow(test)    ## 4451

y <- "IsArrDelayed"

x <- setdiff(colnames(data), c(
                                 "ArrDelay", "DepDelay",
                                 "CarrierDelay", "WeatherDelay",
                                 "NASDelay", "SecurityDelay",
                                 "LateAircraftDelay",
                                 "IsDepDelayed", "IsArrDelayed",
                                 "ActualElapsedTime", # But CRSElapsedTime is fine
                                 "ArrTime",   ## But CRSArrTime is fine
                                 "TailNum"
                             )
             )


nfolds <- 5
train2 <- h2o.rbind(train, valid)

system.time(
    m_glm <- h2o.glm(x, y, train2,
                     family = "binomial",
                     model_id = "glm_def",
                     nfolds = nfolds,
                     fold_assignment = "Modulo",
                     keep_cross_validation_predictions = TRUE
                     )
)

system.time(
    m_gbm <- h2o.gbm(x, y, train2,
                     model_id = "rf_def",
                     nfolds = nfolds,
                     fold_assignment = "Modulo",
                     keep_cross_validation_predictions = TRUE
                     )
)

system.time(
    m_rf <- h2o.randomForest(x, y, train2,
                             model_id = "rf_def",
                             nfolds = nfolds,
                             fold_assignment = "Modulo",
                             keep_cross_validation_predictions = TRUE
                             )
)

model_ids <- list(m_glm@model_id, m_gbm@model_id, m_rf@model_id)

system.time(
m_SE <- h2o.stackedEnsemble(x, y, train2,
                            model_id = "SE_glm_gbm_rf",
                            base_models = model_ids)
)

models <- c(m_glm, m_gbm, m_rf, m_SE)

sapply(models, h2o.logloss)  ## Oooh!
sapply(models, h2o.logloss, xval = TRUE)  ## Hhhmm...

sapply(models, h2o.auc)
sapply(models, h2o.auc, xval = TRUE)




perfs <- lapply(models, h2o.performance, test)
sapply(perfs, h2o.logloss)  # Aha!
sapply(perfs, h2o.auc)


## POJO and MOJO

h2o.saveModel(m_glm, "/tmp/models/")
h2o.download_pojo(m_glm, "/tmp/models/", get_jar = FALSE)
h2o.download_mojo(m_glm, "/tmp/models/")

h2o.saveModel(m_SE, "/tmp/models/")
h2o.download_pojo(m_SE, "/tmp/models/", get_jar = FALSE)
h2o.download_mojo(m_SE, "/tmp/models/")

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

x2 <- setdiff(xAll, "TailNum")


system.time(  ## 1321 secs (22 mins) with 8 threads
g <- h2o.grid("deeplearning",
              search_criteria = list(
                  strategy = "RandomDiscrete",
                  max_models = 4  ## When testing with epochs = 0.01
                  #max_models = 12
              ),

              hyper_params = list(
                  seed = c(77),  ## Placeholder
                  l1 = c(0, 1e-6, 3e-6, 1e-5),
                  l2 = c(0, 1e-6, 3e-6, 1e-5),
                  input_dropout_ratio = c(0, 0.1, 0.2, 0.3),
                  hidden_dropout_ratios = list(
                      c(0, 0),
                      c(0.2, 0.2),
                      c(0.4, 0.4),
                      c(0.6, 0.6))
              ),

              grid_id = "dl-test",
              x = x2,
              y = y,
              hidden = c(400, 400),
              epochs = 0.01, # To test it quickly
              #epochs = 40, # Most were starting to overfit between 10 and 50
              training_frame = train,
              validation_frame = valid,
              activation = "RectifierWithDropout"
              )
)
g



system.time(  ## 1321 secs (22 mins) with 8 threads
g <- h2o.grid("deeplearning",
              search_criteria = list(
                  strategy = "RandomDiscrete",
                  #max_models = 4  ## When testing with epochs = 0.01
                  max_models = 12
              ),

              hyper_params = list(
                  seed = c(77),  ## Placeholder
                  l1 = c(0, 1e-6, 3e-6, 1e-5),
                  l2 = c(0, 1e-6, 3e-6, 1e-5),
                  input_dropout_ratio = c(0, 0.1, 0.2, 0.3),
                  hidden_dropout_ratios = list(
                      c(0, 0),
                      c(0.2, 0.2),
                      c(0.4, 0.4),
                      c(0.6, 0.6))
              ),

              grid_id = "dlB",
              x = x2,
              y = y,
              hidden = c(400, 400),
              #epochs = 0.01, # To test it quickly
              epochs = 40, # Most were starting to overfit between 10 and 50
              training_frame = train,
              validation_frame = valid,
              activation = "RectifierWithDropout"
              )
)
g


## Drop 0.6 for hidden_dropout_ratios, and 0.2 and 0.3 for input_dropout_ratio and make eight more models
## Remember: keep the same grid_id, then the new and old grid get merged.

system.time(  ## 1321 secs (22 mins) with 8 threads
g <- h2o.grid("deeplearning",
              search_criteria = list(
                  strategy = "RandomDiscrete",
                  #max_models = 4  ## When testing with epochs = 0.01
                  max_models = 8
              ),

              hyper_params = list(
                  seed = c(88),  ## Placeholder
                  l1 = c(0, 1e-6, 3e-6, 1e-5),
                  l2 = c(0, 1e-6, 3e-6, 1e-5),
                  input_dropout_ratio = c(0, 0.1),
                  hidden_dropout_ratios = list(
                      c(0, 0),
                      c(0.2, 0.2),
                      c(0.4, 0.4))
              ),

              grid_id = "dlB",
              x = x2,
              y = y,
              hidden = c(400, 400),
              #epochs = 0.01, # To test it quickly
              epochs = 40, # Most were starting to overfit between 10 and 50
              training_frame = train,
              validation_frame = valid,
              activation = "RectifierWithDropout"
              )
)
g


best_model <- h2o.getModel(g@model_ids[[1]])

h2o.saveModel(best_model, "/tmp")

h2o.performance(best_model, valid = TRUE)
h2o.performance(best_model, test)

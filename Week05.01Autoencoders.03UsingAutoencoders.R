library(h2o)
h2o.init(nthreads = -1)

url <- "http://h2o-public-test-data.s3.amazonaws.com/smalldata/iris/iris_wheader.csv"
iris <- h2o.importFile(url)

parts <- h2o.splitFrame(iris, 0.8)
train <- parts[[1]]
test <- parts[[2]]

m_AE_4 <- h2o.deeplearning(x = 1:4,
                           training_frame = train,
                           autoencoder = TRUE,
                           epochs = 300,   ## I'm needing about 140 to 150 to hit early stopping

                           model_id = "m_AE_4",

                           train_samples_per_iteration = nrow(train),
                           score_interval = 0,
                           score_duty_cycle = 1.0,
                           #stopping_rounds = 20,

                           hidden = c(4),
                           activation = "Tanh"
                           )

h2o.scoreHistory(m_AE_4)
plot(as.data.frame(h2o.scoreHistory(m_AE_4))$training_mse, type="l")
plot(tail(as.data.frame(h2o.scoreHistory(m_AE_4))$training_mse, 50), type="l")

m_AE_3 <- h2o.deeplearning(x = 1:4,
                           training_frame = train,
                           autoencoder = TRUE,
                           epochs = 300,   ## I'm needing about 140 to 150 to hit early stopping

                           model_id = "m_AE_3",

                           train_samples_per_iteration = nrow(train),
                           score_interval = 0,
                           score_duty_cycle = 1.0,
                           #stopping_rounds = 15,

                           hidden = c(3),
                           activation = "Tanh"
                           )

h2o.scoreHistory(m_AE_3)
plot(as.data.frame(h2o.scoreHistory(m_AE_3))$training_mse, type="l")
plot(tail(as.data.frame(h2o.scoreHistory(m_AE_3))$training_mse, 50), type="l")


m_AE_2 <- h2o.deeplearning(x = 1:4,
                           training_frame = train,
                           autoencoder = TRUE,
                           epochs = 300,   ## I'm needing about 140 to 150 to hit early stopping

                           model_id = "m_AE_2",

                           train_samples_per_iteration = nrow(train),
                           score_interval = 0,
                           score_duty_cycle = 1.0,
                           #stopping_rounds = 15,

                           hidden = c(2),
                           activation = "Tanh"
                           )

h2o.scoreHistory(m_AE_2)
plot(as.data.frame(h2o.scoreHistory(m_AE_2))$training_mse, type="l")
plot(tail(as.data.frame(h2o.scoreHistory(m_AE_2))$training_mse, 50), type="l")

m_AE_1 <- h2o.deeplearning(x = 1:4,
                           training_frame = train,
                           autoencoder = TRUE,
                           epochs = 300,   ## I'm needing about 140 to 150 to hit early stopping

                           model_id = "m_AE_1",

                           train_samples_per_iteration = nrow(train),
                           score_interval = 0,
                           score_duty_cycle = 1.0,
                           #stopping_rounds = 15,

                           hidden = c(1),
                           activation = "Tanh"
                           )

h2o.scoreHistory(m_AE_1)
plot(as.data.frame(h2o.scoreHistory(m_AE_1))$training_mse, type="l")
plot(tail(as.data.frame(h2o.scoreHistory(m_AE_1))$training_mse, 50), type="l")


## Multi-layer autoencoder

m_AE_5_3_5 <- h2o.deeplearning(x = 1:4,
                               training_frame = train,
                               autoencoder = TRUE,
                               epochs = 300,   ## I'm needing about 140 to 150 to hit early stopping

                               model_id = "m_AE_5_3_5",

                               train_samples_per_iteration = nrow(train),
                               score_interval = 0,
                               score_duty_cycle = 1.0,

                               hidden = c(5,3,5),
                               activation = "Tanh"
                               )

h2o.scoreHistory(m_AE_5_3_5)
plot(as.data.frame(h2o.scoreHistory(m_AE_5_3_5))$training_mse, type="l")
plot(tail(as.data.frame(h2o.scoreHistory(m_AE_5_3_5))$training_mse, 50), type="l")

m_AE_3_1_3 <- h2o.deeplearning(x = 1:4,
                               training_frame = train,
                               autoencoder = TRUE,
                               epochs = 300,   ## I'm needing about 140 to 150 to hit early stopping

                               model_id = "m_AE_3_1_3",

                               train_samples_per_iteration = nrow(train),
                               score_interval = 0,
                               score_duty_cycle = 1.0,
                               stopping_rounds = 20,

                               hidden = c(3,1,3),
                               activation = "Tanh"
                               )

h2o.scoreHistory(m_AE_3_1_3)
plot(as.data.frame(h2o.scoreHistory(m_AE_3_1_3))$training_mse, type="l")
plot(tail(as.data.frame(h2o.scoreHistory(m_AE_3_1_3))$training_mse, 50), type="l")


## Stacked autoencoder

## Builds on m_AE_3 that we've already built

train_AE_3 <- h2o.deepfeatures(m_AE_3, train, 1)
head(train_AE_3)
dim(train_AE_3)

m_AE_3x3 <- h2o.deeplearning(x = 1:3,
                             training_frame = train_AE_3,
                             autoencoder = TRUE,
                             epochs = 300,   ## I'm needing about 140 to 150 to hit early stopping

                             model_id = "m_AE_3x3",

                             train_samples_per_iteration = nrow(train),
                             score_interval = 0,
                             score_duty_cycle = 1.0,

                             hidden = c(3),
                             activation = "Tanh"
                             )

h2o.scoreHistory(m_AE_3x3)
plot(as.data.frame(h2o.scoreHistory(m_AE_3x3))$training_mse, type="l")
plot(tail(as.data.frame(h2o.scoreHistory(m_AE_3x3))$training_mse, 50), type="l")


## Simple vs. Multi vs. Stacked
h2o.mse(m_AE_3)
h2o.mse(m_AE_3_1_3)
h2o.mse(m_AE_3x3)


## Anomolies

m_AE_anomaly <- h2o.deeplearning(x = 1:5,
                                 training_frame = iris,
                                 autoencoder = TRUE,
                                 epochs = 300,   ## I'm needing about 140 to 150 to hit early stopping

                                 model_id = "m_AE_anomaly",

                                 train_samples_per_iteration = 0,
                                 score_interval = 0,
                                 score_duty_cycle = 1.0,

                                 hidden = c(16),
                                 activation = "Tanh"
                                 )

m_AE_anomaly

anomalies <- as.data.frame(h2o.cbind(iris, h2o.anomaly(m_AE_anomaly, iris))); anomalies
sorted <- anomalies[order(-anomalies$Reconstruction.MSE), ]
sorted

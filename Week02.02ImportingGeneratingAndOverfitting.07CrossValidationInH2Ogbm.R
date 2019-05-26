library(h2o)
h2o.init()

set.seed(123)

N <- 1000

bloodTypes <- c('A', 'O', 'AB', 'B')

d <- data.frame(id = 1:N)
d$bloodType <- bloodTypes[
    (d$id %% length(bloodTypes))
    + 1  # R indexes from 1
    ]
head(d)

bloodTypes <- c('A', 'A', 'A', 'O', 'O', 'O', 'AB', 'B')
d$bloodType <- as.factor(bloodTypes[(d$id %% length(bloodTypes))+1])

d$age = runif(N, min=18, max=65)

v = round(rnorm(N, mean=5, sd=2))   # 68% are 3,4,5,6,7
v = pmax(v, 0)
v = pmin(v, 9)
table(v)
d$healthyEating = v

v = round(rnorm(N, mean=5, sd=2))   # 68% are 3,4,5,6,7
v = v + ifelse(d$age<30, 1, 0)   # The kids are more active (?)
v = pmax(v, 0)
v = pmin(v, 9)
table(v)
d$activeLifestyle = v
d
v = 20000 + ((d$age * 3) ^ 2)   # Based salary based on age
range(v)                        # v is $22961 to $58023
v = v + (d$healthyEating * 500)
v = v - (d$activeLifestyle * 300)
v = v + runif(N, 0, 5000)
d$income = round(v, -2)         # Round to nearest $100

as.h2o(d, destination_frame = "people")

## In next videos we will be using this:

people <- h2o.getFrame("people")

parts <- h2o.splitFrame(
    people,
    ratios = 0.897,
    destination_frames=c("people_train", "people_test"),
    seed = 123)
train <- h2o.getFrame("people_train")  # 900
test <- h2o.getFrame("people_test")    # 100

y <- "income"
x <- setdiff(names(train), c("id", y))
m3 <- h2o.gbm(x, y, train,
              model_id = "def9folds_r",
              nfolds = 9
              )

h2o.performance(m3, train = TRUE)
h2o.performance(m3, xval = TRUE)
h2o.performance(m3, test)

m4 <- h2o.gbm(x, y, train,
              model_id = "overfit9folds_r",
              ntrees = 1000,
              max_depth = 10,
              nfolds = 9
              )

h2o.performance(m4, train = TRUE)
h2o.performance(m4, xval = TRUE)
h2o.performance(m4, test)

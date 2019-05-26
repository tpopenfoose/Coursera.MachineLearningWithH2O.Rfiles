library(h2o)
h2o.init()
people <- h2o.getFrame("people")

parts <- h2o.splitFrame(
    people, #nrows(people) == 1000
    c(0.8,0.1), #800 / 100 / 1000
    destination_frames=c("people_train", "people_valid", "people_test"),
    seed= 123)

sapply(parts, nrow)

train <- parts[[1]]
valid <- parts[[2]]
test <- parts[[3]]

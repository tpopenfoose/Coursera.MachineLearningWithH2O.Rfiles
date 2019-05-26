library(h2o)
h2o.init()

data <- h2o.importFile("http://h2o-public-test-data.s3.amazonaws.com/smalldata/airlines/allyears2k_headers.zip")

parts <- h2o.splitFrame(data, c(0.8,0.1), seed = 69)
train <- parts[[1]]; nrow(train)  ## 35255
valid <- parts[[2]]; nrow(valid)  ##  4272
test <- parts[[3]]; nrow(test)    ##  4451

## Different way to extract some rows.
## I.e.  Just like you do in normal R

train2 <- data[1:35255, ]  ## First 35,255 rows - not random!

h2o.ls()

train2 <- h2o.assign(train2, "first35255")

h2o.ls()

## Same goes for columns

ncol(data) ## 31

dates <- data[ , 1:4]  ## First 4 of 31 columns
airports <- data[ , c('Origin','Dest')]

ncol(airports)
ncol(dates)

## Use cbind to join ("bind") columns

a_and_d <- h2o.cbind(airports, dates)

dim(a_and_d)  ## New 6-column table created at this point

## Use rbind to join ("bind") rows

restored_data <- h2o.rbind(train, valid, test)
dim(restored_data)
dim(data)  ## Same!!

head(restored_data[ , 1:4])
head(data[ , 1:4])  ## DIFFERENT!!
head(train[ , 1:4])




## Use h2o.merge() to join tables together when they have 1+ columns alike
## Unlike h2o.cbind() they can have different number of rows and
## h2o.rbind() they can have different number of columns


A <- as.h2o(
    matrix(1:30, nrow = 10, ncol=3, dimnames=list(NULL, c("a", "b", "c"))),
    destination_frame = "A"
); A

set.seed(123)
B <- as.h2o(
    matrix(sample(6:12, size=40, replace=TRUE), ncol=2, dimnames=list(NULL, c("a", "d"))),
destination_frame = "A"
); B

dim(A)  ## 10 3  a/b/c
dim(B)  ## 20 2  a/d

M <- h2o.merge(A, B)
as.data.frame(M)

M <- h2o.merge(B, A)
as.data.frame(M)

M <- h2o.merge(B, A, by = "b")
as.data.frame(M)   ## Careful!

M <- h2o.merge(B, A, by.y = "b")
as.data.frame(M)  ## ?!

M <- h2o.merge(A, B, by = "a", all.x = TRUE)
as.data.frame(M)

M <- h2o.merge(A, B, all.y = TRUE)
as.data.frame(M)

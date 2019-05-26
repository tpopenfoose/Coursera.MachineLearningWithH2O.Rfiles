library(h2o)
h2o.init()

data <- h2o.importFile("http://h2o-public-test-data.s3.amazonaws.com/smalldata/airlines/allyears2k_headers.zip")

summary(data)

## Column Type Conversions

##  data[ , "xxx"] <- as.factor( data[ , "xxx"])
##  data[ , "xxx"] <- as.numeric( data[ , "xxx"])

## Column Stats

mean(data[ , "AirTime"])
mean(data[ , "AirTime"], na.rm = TRUE)
h2o.mean(data[ , "AirTime"], na.rm = TRUE)

range(data[ , "AirTime"], na.rm = TRUE)

h2o.hist(data[ , "AirTime"])


mean(data[ , c("ArrDelay", "DepDelay")], na.rm = TRUE)

h2o.any(data[ , "ArrDelay"] > 360)
h2o.all(data[ , "ArrDelay"] < 480)
## ... but it has no na.rm argument, so we need to do:
h2o.all( h2o.na_omit(data[ , "ArrDelay"]) < 480)

h2o.cumsum(data[ , "ArrDelay"], axis = 0)
## Set axis = 1 to go across a row, instead of down a column

## h2o.acos, h2o.cos, h2o.cosh, h2o.exp, h2o.sin, h2o.sd,

## h2o.ceiling(), h2o.floor()  (Not demonstrated, as all our)

h2o.cor(data[ , "ArrDelay"], data[ , "DepDelay"], na.rm = TRUE)

## h2o.ddply()
## h2o.group_by()

## Strings. (we have none, sw do a conversion)
uc = as.character(data[ , "UniqueCarrier"])

head(uc)
h2o.entropy(uc)

h2o.entropy(as.h2o("The quick brown fox jumps over the lazy"))

library(h2o)
h2o.init()

url <- "https://raw.githubusercontent.com/rajkstats/Machine-Learning-with-h2O/master/datasets/smoking.csv"; url
url <- "../../SourceCode/data/smoking.csv"; url
data <- h2o.importFile(url)

data
summary(data)
h2o.sum(data[ , 3])

x = 1:2
y = 5

m = h2o.glm(x, y, data,
            family="poisson",
            model_id="smoking_p"
            #nfolds=12,
            #fold_assignment="Modulo"
            )
m


m2 = h2o.glm(2, y, data,
             family="poisson",
             model_id="smoking_2"
             )
m2

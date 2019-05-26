## from http://docs.h2o.ai/h2o/latest-stable/h2o-docs/downloading.html

##  for use to upgrade to latest version of H2O after installing from CRAN

if ("package:h2o" %in% search()) { detach("package:h2o", unload=TRUE) }
if ("h2o" %in% rownames(installed.packages())) { remove.packages("h2o") }

install.packages("h2o", type="source", repos=(c("http://h2o-release.s3.amazonaws.com/h2o/latest_stable_R")))


## now test install
library(h2o)
localH2O = h2o.init()
demo(h2o.kmeans)

library(h2o)

h2o.init()

x = seq(0, 10, 0.01)
y = jitter( sin(x), 1000)
plot(x, y, type="l")

sineWave <- data.frame(a=x, b=y)

sineWave.h2o <- as.h2o(sineWave)

sineWave.h2o
tail(sineWave.h2o)

# Opposite direction
d <- as.data.frame(sineWave.h2o)
head(d)


#--------------------------------------------------------Variable Selection-----------------------------------------------------------------------------------------

ibrary("rjags")

mod1_string = " model {
    for (i in 1:length(y)) {
        y[i] ~ dbern(p[i])
        logit(p[i]) = int + b[1]*sediments[i] + b[2]*borrow[i] + b[3]*meander[i] + b[4]*channel_width[i] + b[5]*floodway_width[i] + b[6]*constriction_factor[i] + b[7]*landcover[i] + b[8]*veg_buffer[i] + b[9]*sinuosity[i] + b[10]*dredging[i] + b[11]*revertment[i]
    }
    int ~ dnorm(0.0, 1.0/25.0)
    for (j in 1:11) {
        b[j] ~ ddexp(0.0, sqrt(2.0)) # has variance 1.0
    }
} "


X = scale(train1[,-1], center=TRUE, scale=TRUE)

set.seed(83)
data_jags = list(y = train1$response, sediments = X[,"sediments"], borrow = X[,"borrow"], meander = X[,"meander"], channel_width = X[,"channel_width"], floodway_width = X[,"floodway_width"], constriction_factor = X[,"constriction_factor"], landcover = X[,"landcover"], veg_buffer = X[,"veg_buffer"], sinuosity = X[,"sinuosity"], dredging = X[,"dredging"], revertment = X[,"revertment"])

params = c("int", "b")

mod1 = jags.model(textConnection(mod1_string), data = data_jags, n.chains = 3)

update(mod1, 1000)

mod1_sim = coda.samples(model = mod1, variable.names = params, n.iter = 10e3)

mod1_csim = as.mcmc(do.call(rbind, mod1_sim))

par(mfrow = c(6,2))
densplot(mod1_csim[,1:11], xlim = c(-2.0,2.0))



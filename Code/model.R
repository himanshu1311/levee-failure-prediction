

#------------------------------------------------------------------------Final_Model--------------------------------------------------------------------------

mod_string = "model{
	for(i in 1:length(y)){
		y[i] ~ dbern(p[i])
		logit(p[i]) = int + b[1]*borrow[i] + b[2]*channel_width[i] + b[3]*constriction_factor[i] + b[4]*landcover[i] + b[5]*sinuosity[i] + b[6]*revertment[i]
}

		int ~ dnorm(0.0, 1.0/25)
		for(j in 1:6){
			b[j] ~ dnorm(0.0, 1/25)}
}"

X = train1
set.seed(83)
data_jags = list(y = train1$response, sediments = X[,"sediments"], borrow = X[,"borrow"], meander = X[,"meander"], channel_width = X[,"channel_width"], floodway_width = X[,"floodway_width"], constriction_factor = X[,"constriction_factor"], landcover = X[,"landcover"], veg_buffer = X[,"veg_buffer"], sinuosity = X[,"sinuosity"], dredging = X[,"dredging"], revertment = X[,"revertment"])

params = c("int", "b")

mod = jags.model(textConnection(mod4_string), data = data_jags, n.chains = 3)


#sampling
update(mod,1e3)   #Burn-in
mod_sim = coda.samples(model = mod, variable.names = params, n.iter = 10e3)
mod_csim = as.mcmc(do.call(rbind,mod_sim))


#convergence diagnostics
gelman.diag(mod_sim)
autocorr.diag(mod_sim)
autocorr.plot(mod_sim)
effectiveSize(mod_sim)


#jitter plot
plot(phat, jitter(train1$response, col = "red"))


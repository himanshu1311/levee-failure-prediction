#Read and Expore data



#----------------------------Data Reading---------------------
data = read.csv(file="/home/himanshu/Desktop/Bayesian project/data.csv", header=TRUE)

require(caTools)
set.seed(123)   
sample = sample.split(data,SplitRatio = 0.75)          #splitting into training and testing dataset
train1 =subset(data,sample ==TRUE) 
test1=subset(data, sample==FALSE)





#------------------------data exploration----------------------
summary(data)
library("corrplot")
Cor = cor(data)
corrplot(Cor, type="upper", method="ellipse", tl.pos="d")
corrplot(Cor, type="lower", method="number", col="black", 
         add=TRUE, diag=FALSE, tl.pos="n", cl.pos="n")



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



#-----------------------------Optimization-------------------------------------
#Computing the optimum value of threshold for maximum accuracy

sum = 0
max = 0
index = 0
while(sum<1){

tab = table(phat > sum, train1$response)
accuracy = sum(diag(tab)) / sum(tab)

if(accuracy > max){
max = accuracy
index = sum
}
sum = sum + 0.01
}

#--------------------------------Prediction-----------------------------------

#---------------------------------Train_Data-------------------------------

pm_coef = colMeans(mod_csim)

train = as.matrix(train1[,c(4,6,8,9,11,13)])
pm_Xb = pm_coef["int"] + train %*% pm_coef[1:6]
phat = 1.0 / (1.0 + exp(-pm_Xb))

tab = table(phat > index, train1$response)
sum(diag(tab)) / sum(tab)


#-------------------------------Test_Data----------------------------------

test = as.matrix(test1[,c(4,6,8,9,11,13)])

pm_Xb = pm_coef["int"] + test %*% pm_coef[1:6]
phat = 1.0 / (1.0 + exp(-pm_Xb))

tab = table(phat > index, test1$response)
sum(diag(tab)) / sum(tab)




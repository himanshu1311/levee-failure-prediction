

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



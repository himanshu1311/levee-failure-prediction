
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




#--------------------------------------------------------------------



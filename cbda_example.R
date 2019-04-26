library(CBDA)

# Accepting parameters from command line(or a PBS file when using flux)
args <- commandArgs(TRUE)
for(i in 1:length(args))
    {
    	#The printed value will be the parameters; you can use them in the R file.
        print(eval(parse(text=args[[i]])))
    }
print("Parameters Received Succesfully.")

# Installation
# Please upload the Windows binary and/or source CBDA_1.0.0 files from
# the CBDA Github repository https://github.com/SOCR/CBDA/releases

# Initialization
# This function call installs (if needed) and attaches all the necessary packages to run
# the CBDA package v1.0.0. It should be run before any production run or test.
# The output shows a table where for each package a TRUE or FALSE is displayed.
# Thus the necessary steps can be pursued in case some package has a FALSE.
CBDA_initialization()

# Set the specs for the synthetic dataset to be tested
n = 300          # number of observations
p = 100          # number of variables

# Generate a nxp matrix of IID variables (e.g., ~N(0,1))
X1 = matrix(rnorm(n*p), nrow=n, ncol=p)

# Setting the nonzero variables - signal variables
nonzero=c(1,100,200,300,400,500,600,700,800,900)

# Set the signal amplitude (for noise level = 1)
amplitude = 10

# Allocate the nonzero coefficients in the correct places
beta = amplitude * (1:p %in% nonzero)

# Generate a linear model with a bias (e.g., white  noise ~N(0,1))
ztemp <- function() X1 %*% beta + rnorm(n)
z = ztemp()

# Pass it through an inv-logit function to
# generate the Bernoulli response variable Ytemp
pr = 1/(1+exp(-z))
Ytemp = rbinom(n,1,pr)
X2 <- cbind(Ytemp,X1)

dataset_file ="Binomial_dataset_3.txt"

# Save the synthetic dataset
a <- tempdir()
write.table(X2, file = paste0(file.path(a),'/',dataset_file), sep=",")

# The file is now stored in the directory a
a
list.files(a)

# Load the Synthetic dataset
Data = read.csv(paste0(file.path(a),'/',dataset_file),header = TRUE)
Ytemp <- Data[,1] # set the outcome
original_names_Data <- names(Data)
cols_to_eliminate=1
Xtemp <- Data[-cols_to_eliminate] # set the matrix X of features/covariates
original_names_Xtemp <- names(Xtemp)

# Add more wrappers/algorithms to the SuperLearner ensemble predictor
# It can be commented out if only the default set of algorithms are used,
# e.g., algorithm_list = c("SL.glm","SL.xgboost","SL.glmnet","SL.svm",
#                          "SL.randomForest","SL.bartMachine")
# This defines a "new" wrapper, based on the default SL.glmnet
SL.glmnet.0.75 <- function(..., alpha = 0.75,family="binomial"){
  SL.glmnet(..., alpha = alpha, family = family)}

test_example <- c("SL.glmnet","SL.glmnet.0.75")

# Call the Main CBDA function
# Multicore functionality NOT enabled
CBDA_object <- CBDA(Ytemp , Xtemp , M = 12 , Nrow_min = 50, Nrow_max = 70,
                    top = 10, max_covs = 8 , min_covs = 3,algorithm_list = test_example ,
                    workspace_directory = a)

# Multicore functionality enabled
#test_example <- c("SL.xgboost","SL.svm")
#CBDA_test <- CBDA(Ytemp , Xtemp , M = 40 , Nrow_min = 50, Nrow_max = 70,
#                  N_cores = 2 , top = 30, max_covs = 20 ,
#                  min_covs = 5 , algorithm_list = test_example ,
#                  workspace_directory = a)

## End(Not run)
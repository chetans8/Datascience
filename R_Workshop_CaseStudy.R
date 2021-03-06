### Step 2 Solution

#View the top 5 rows of HousingData
head(HousingData,n = 10)
###View the summary statistics and information of the columns in HousingData
summary(HousingData)


#Delete the first 5 values from the bedroom and bathroom columns (Set as NA)
HousingData$bedrooms[1:5] = NA
HousingData$bathrooms[1:5] = NA

#View the missing rows

#Impute the missing bedrooms and bathrooms with the median bedroom and bathroom values
HousingData$bedrooms[is.na(HousingData$bedrooms)] = median(HousingData$bedrooms,na.rm = T)
HousingData$bathrooms[is.na(HousingData$bathrooms)] = median(HousingData$bathrooms,na.rm = T)


HousingData$`floor1.5` = (HousingData$floors == "1.5")*1
HousingData$`floor2` = (HousingData$floors == "2")*1
HousingData$`floor2.5` = (HousingData$floors == "2.5")*1
HousingData$`floor3` = (HousingData$floors == "3")*1
HousingData$`floor3.5` = (HousingData$floors == "3.5")*1

#Delete the floor column
HousingData$floors= NULL

unique(HousingData$bedrooms)


rows = 1:nrow(HousingData)
rows

train_rows = sample(x = rows,size= .8*nrow(HousingData))
#Make a vector called 'test_ rows' from the elements of 'rows' that are not in 'train_rows'
test_rows = rows[!rows %in% train_rows]

print test_rows


HousingData = HousingData[,.(price,bedrooms,bathrooms,sqft_living,waterfront,view,condition,grade,yr_built,
                             yr_renovated,lat,long,`floor1.5`,`floor2`,`floor2.5`,`floor3`,`floor3.5`)]

#Use the Min-Max Standardization techniques to standardize the following columns:
#bedrooms,bathrooms,sqft_living,view,condition,grade,yr_built,yr_renovated,lat,long

minmax = Vectorize(function(x){
  return((x - min(x,na.rm = T)/diff(range(x,na.rm = T))))
})
HousingData [,`:=`(
  bedrooms=(bedrooms - min(bedrooms[train_rows]))/diff(range(bedrooms[train_rows])),
  bathrooms=(bathrooms - min(bathrooms[train_rows]))/diff(range(bathrooms[train_rows])),
  sqft_living=(sqft_living - min(sqft_living[train_rows]))/diff(range(sqft_living[train_rows])),
  view = (view - min(view[train_rows]))/diff(range(view[train_rows])),
  condition=(condition - min(condition[train_rows]))/diff(range(condition[train_rows])),
  grade=(grade - min(grade[train_rows]))/diff(range(grade[train_rows])),
  yr_built=(yr_built - min(yr_built[train_rows]))/diff(range(yr_built[train_rows])),
  yr_renovated=(yr_renovated - min(yr_renovated))/diff(range(yr_renovated[train_rows])),
  lat=(lat - min(lat[train_rows]))/diff(range(lat[train_rows])),
  long=(long - min(long[train_rows]))/diff(range(long[train_rows]))
)]

#Create a training data frame called HousingData_train from HousingData with "train_rows"
#Create a training data frame called HousingData_test from HousingData with "test_rows"

HousingData_train = HousingData[train_rows]
HousingData_test = HousingData[test_rows]



x = HousingData_train[,.(  bedrooms,bathrooms,sqft_living)]
y = HousingData_train$price 

# Define the loss function
loss = function(X, y,  beta) {
  sum( (as.matrix(X) %*% beta - y)^2 ) / (2*length(y))
}


alpha = 0.1 
num_iters = 1000 
loss_history = rep(0,num_iters)
beta_history = list(num_iters) 
beta =  rep(0,ncol(x)+1) 
X = as.matrix(cbind(1,x))

for (i in 1:num_iters) {
  beta[1] = beta[1] - alpha * (1/length(y)) * sum(((X%*%beta)- y))
  for(j in 2:length(beta)){
    beta[j] = beta[j] - alpha * (1/length(y)) * sum(((X%*%beta)- y)*X[,j])
  }
  loss_history[i] = loss(X, y, beta)
  beta_history[[i]] = beta
} 


plot(loss_history/1000000,type = "l",ylab = "Loss (100000s)",xlab = "Iterations")


#Create a model matrix for the test data set. Call it X
X = as.matrix(cbind(1,HousingData_test[,.(  bedrooms,bathrooms,sqft_living)]))

#Multiply the beta's you calculated in the previous section to X to get the predictions
HousingData_test$price_pred = X%*%beta

#Calculate the median of the absolute difference between the predicted sale prices and the actual sale prices
median(HousingData_test[,.(absdiff=abs(price-price_pred))]$absdiff)


















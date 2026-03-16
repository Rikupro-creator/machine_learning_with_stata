view dialog import_delimited_dlg
import delimited "C:\users\moses\Desktop\train (1).csv"
* lets start by dropping passenger id
drop passengerid

graph bar (count), over(survived)
* The category of those who did not survive is too many.
hist age
* lets do summary statistics
summarize
* lets look at pclass
graph bar (count), over(pclass)
* histogram fro sibsp
hist sibsp
* fare
hist fare
* there is an outlier
graph box fare
* The box plot confirms the presence of outliers
* lets split the data into train and test dataset'
* Create a random variable

set seed 12345

generate random_split = runiform()



* Split data into train (80%) and test (20%) sets

generate train_data = random_split <= 0.8

generate test_data = random_split > 0.8
* lets confirm this
count if train_data == 1
count if test_data==1
* we have our dataset as we wanted
* lets do model fitting
logit survived pclass age sibsp parch fare
* not a very good model
* Predict on test data

predict predictions if test_data == 1
lroc

generate predicted_binary = (predictions >= 0.5)
drop correct_predictions
generate correct_predictions = ( survived == predicted_binary )
summarize correct_predictions
display "Accuracy: " r(mean)
summarize correct_predictions if test_data ==1
display "Accuracy: " r(mean)
tabulate survived predicted_binary
* lets try to improve the model further.
* firts lets check if there are missing values
mdesc
*age and cabin have a lot of missing values.
* lets replace the missing values in age with its median
summarize age, detail
scalar med = r(p50)
replace age = med if missing(age)

* lets look at embarked it also has two missing values
graph bar (count), over(embarked)
* there are three categories S,C, Q.
* Since S is so common we are replacing the missing values with S

replace embarked ="S" if missing(embarked)
* create numerical codes for embarked and gender

encode sex, gen(sex_num)
encode embarked, gen(embarked_num)

* we have more variables lets add them to our model and see the accuracy
logit survived pclass age sibsp parch fare sex_num embarked_num
* aoc curve
lroc
predict predictions1 if test_data == 1
generate predicted_binary1 = (predictions1 >= 0.5)
generate correct_predictions1 = ( survived == predicted_binary1 )
summarize correct_predictions1
summarize correct_predictions1 if test_data ==1
display "Accuracy: " r(mean)
* We have improved the models accuracy.
* We can see what the impact of removing missing variables, and adding more variables did to our model.

**************************************************************************************
*Regularization
**************************************************************************************

*LASSO
lasso2 survived pclass age sibsp parch fare sex_num embarked_num, alpha(0)
* Ridge

lasso2 survived pclass age sibsp parch fare sex_num embarked_num, alpha(1)
*elascinet
lasso2 survived pclass age sibsp parch fare sex_num embarked_num, alpha(0.5)

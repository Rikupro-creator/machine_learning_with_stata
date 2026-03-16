import delimited "C:\users\moses\Desktop\train (1).csv"
set matsize 800, permanently
* split the data into train and test data

generate random_split = runiform()

* Split data into train (80%) and test (20%) sets

generate train_data = random_split <= 0.8

generate test_data = random_split > 0.8
* lets confirm this
count if train_data == 1
count if test_data==1
* we have our dataset as we wanted
* lets do model fitting
svmachines survived pclass sibsp parch fare, ///
    type(svc) kernel(linear)

predict predictions if test_data == 1

generate correct_predictions = ( survived == predictions )
summarize correct_predictions if test_data ==1
display "Accuracy: " r(mean)
tabulate survived predictions if test_data ==1
*This is a very good model. 
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
svmachines survived pclass age sibsp parch fare sex_num embarked_num if train_data ==1, ///
 type(svc) kernel(linear)

predict predictions1 if test_data == 1
generate correct_predictions1 = ( survived == predictions1 )
summarize correct_predictions1
summarize correct_predictions1 if test_data ==1
display "Accuracy: " r(mean)

* The second round improved the model
* generate family size
generate familysize=sibsp*parch+1

* title extraction
gen title = regexs(1) if regexm(name, "(Mr|Mrs|Miss|Master|Dr)")
replace title = "Rare" if !inlist(title, "Mr", "Mrs", "Miss", "Master", "Dr")
* Age binning
egen AgeBin = cut(age), at(0 12 20 40 60 80) label
* encode title
encode title, gen(title_num)

* normalization
egen Age_z = std(age)
egen Fare_z = std(fare)

* lets refit the model
svmachines survived pclass sibsp parch sex_num embarked_num familysize title_num AgeBin ///
Age_z Fare_z if train_data ==1, ///
 type(svc) kernel(linear)

predict predictions2 if test_data == 1
generate correct_predictions2 = ( survived == predictions2 )
summarize correct_predictions2
summarize correct_predictions2 if test_data ==1
display "Accuracy: " r(mean)

* As we can see, the feature engineering did not improve the model at all.
* This is a clear indication that not all feature engineering can improve the model.
* It needs to be done  strategically. 

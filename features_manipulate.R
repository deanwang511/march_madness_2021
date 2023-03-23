rm(list=ls())
library(data.table)
library(caret)
library(ClusterR)
library(xgboost)

train_data<- fread("./project/volume/data/raw/train_data.csv")
train_emb<-fread("./project/volume/data/raw/train_emb.csv")
example_sub<-fread("./project/volume/data/raw/example_sub.csv")
test_data<-fread("./project/volume/data/raw/test_file.csv")
test_emb<- fread("./project/volume/data/raw/test_emb.csv")

text<- data.table(train_data$text)

train_data$text<- NULL

#melt train data
melt_dat<- melt(train_data, c("id"), variable.name = "category")

melt_dat<-melt_dat[value==1]
melt_dat$category<-as.numeric(melt_dat$category)
melt_dat$value<- NULL

#order arrange 
melt_dat$order<- as.integer(substr(melt_dat$id,start=7,stop = 9))
melt_dat<-melt_dat[order(melt_dat$order)]
melt_dat$category<- melt_dat$category-1
melt_dat$train<-1
#create train data
train<- cbind(melt_dat,train_emb)
train$order<- NULL

#test data
test<-cbind(test_data,test_emb)
test$category<-11
test$text<-NULL
test$train<-0
# master train

final_train<- rbind(train,test)


library(data.table)
library(caret)
library(ClusterR)
library(xgboost)
library(Rtsne)

#splitting data back to train and test
tsne_test<-final_master[identity==0]
tsne_train<-final_master[identity==1]
tsne_test$identity<-NULL
tsne_train$identity<-NULL
tsne_test$id<-NULL
tsne_train$id<-NULL
tsne_test$category<-NULL
tsne_train$category<-NULL


y.train <- melt_dat$category





dtrain <- xgb.DMatrix(as.matrix(tsne_train),
                      label = y.train,
                      missing = NA)
dtest <- xgb.DMatrix(as.matrix(tsne_test),
                     missing = NA)

hyper_parm_tune <- NULL


myparam <- list(  objective           = "multi:softprob",   
                  gamma               = 0.02,        
                  booster             = "gbtree",
                  num_class           = 10,
                  eval_metric         = "mlogloss",      
                  eta                 = 0.01,  # 0.1,0.05,0.02     
                  max_depth           = 5,   #15,10        
                  min_child_weight    = 1,      
                  subsample           = 1.0,   
                  colsample_bytree    = 1.0, 
                  tree_method         = 'hist'
)


XGBfit <- xgb.cv( params = myparam,
                  nfold = 5,#5,4,10
                  nrounds = 2000,#10000
                  missing = NA,
                  data = dtrain,
                  print_every_n = 1,    # so i can see the errors every step
                  early_stopping_rounds = 25) 




best_tree_n <- unclass(XGBfit)$best_iteration
new_row <- data.table(t(myparam))
new_row$best_tree_n <- best_tree_n
test_error <- unclass(XGBfit)$evaluation_log[best_tree_n,]$test_rmse_mean
new_row$test_error <- test_error
hyper_parm_tune <- rbind(new_row, hyper_parm_tune)

watchlist <- list( train = dtrain)
XGBfit <- xgb.train( params = myparam,
                     nrounds = best_tree_n, 
                     missing = NA,
                     data = dtrain,
                     watchlist = watchlist,
                     print_every_n = 1)


pred <- predict(XGBfit, newdata = dtest)


submit <- as.data.table(matrix(pred, ncol = 10, byrow = T))
submit$id<-example_sub$id
submit<-setNames(submit, c("subredditcars","subredditCooking", "subredditMachineLearning","subredditmagicTCG","subredditpolitics","subredditReal_Estate","subredditscience","subredditStockMarket", "subreddittravel","subredditvideogames","id"))

fwrite(submit,"./final11.csv")

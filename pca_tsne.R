library(data.table)
library(caret)
library(ClusterR)
library(xgboost)
library(Rtsne)
pca_train<-final_train
pca_train$id<- NULL
pca_train$category<- NULL
pca_train$train<-NULL
#pca
pca<-prcomp(pca_train)
pca_dt<- data.table(unclass(pca)$x)
#tsne 1 
tsne_dat1 <- Rtsne(pca_dt,
                  pca=F,
                  perplexity = 30, #45,30
                  check_duplicates = F,
                  )

tsne_data <- data.table(tsne_dat1$Y)


tsne_dat2<- Rtsne(pca_dt,
                  pca=F,
                 perplexity = 45, 
                  check_duplicates = F,
                  )
tsne_data2 <- data.table(tsne_dat2$Y)

tsne_dat3<- Rtsne(pca_train,
                  pca=F,
                  perplexity = 60, 
                  check_duplicates = F,
)

tsne_data3 <- data.table(tsne_dat3$Y)

tsne_data3<-setNames(tsne_data3,c("V5","V6"))

tsne_data2<-setNames(tsne_data2,c("V3","V4"))
#merge pca, tsne1, tsne2 results together
final_master<-cbind(pca_dt,tsne_data,tsne_data2,tsne_data3)
final_master$identity<-final_train$train
final_master$category<-final_train$category
final_master$id<-final_train$id


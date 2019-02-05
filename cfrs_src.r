---
title: "Item-Based Collaborative Filtering Recommendation"
author: "M Hendra Herviawan"
output: html_document
---

```{r setup, include=FALSE}
knitr::opts_chunk$set(echo = TRUE)
```

## Project Overview

This is a transnational data set which contains all the transactions occurring between 01/12/2010 and 09/12/2011 for a UK-based and registered non-store online retail.The company mainly sells unique all-occasion gifts. Many customers of the company are wholesalers.


The following libraries were used in this project:
```{r,message=FALSE}
library(methods)
library(recommenderlab)
library(data.table)
library(ggplot2)
library(knitr)
```

## Data Pre-preprocessing
Some pre-processing of the data available is required before creating the recommendation system.
```{r}
df_data <- fread('../input/data.csv')
df_data[ ,InvoiceDate := as.Date(InvoiceDate)]
```

#### Data Imputation
There is negatif Quantity & Unit Price, also NULL/NA Customer ID. We will delete all the NA Row
```{r}
df_data[Quantity<=0,Quantity:=NA]
df_data[UnitPrice<=0,UnitPrice:=NA]
df_data <- na.omit(df_data)
```

#### Item Dictionary
Create a Item Dictionary which allows an easy search of a Item name by any of its StockCode
```{r}
setkeyv(df_data, c('StockCode', 'Description'))
itemCode <- unique(df_data[, c('StockCode', 'Description')])
setkeyv(df_data, NULL)
```

#### Convert from long fromat to wide format
Convert from transactional to binary metrix, 0 for no transaction and vice versa
```{r}
df_train_ori <- dcast(df_data, CustomerID ~ StockCode, value.var = 'Quantity',fun.aggregate = sum, fill=0)

CustomerId <- df_train_ori[,1] #!

df_train_ori <- df_train_ori[,-c(1,3504:3508)]

#Fill NA with 0
for (i in names(df_train_ori))
 df_train_ori[is.na(get(i)), (i):=0]

```

#### Convert Wide Format to sparse matrix
In order to use the ratings data for building a recommendation engine with recommenderlab, I convert buying matrix into a sparse matrix of type realRatingMatrix.
```{r}
df_train <- as.matrix(df_train_ori)
df_train <- df_train[rowSums(df_train) > 5,colSums(df_train) > 5] 
df_train <- binarize(as(df_train, "realRatingMatrix"), minRatin = 1)
```

## Training
We will use Item Base Collaboratife Filtering or IBCF. Jaccard is used becouse our data is binary

#### Split Dataset
Dataset is split Randomly with 80% for training and 20% for test
```{r}
which_train <- sample(x = c(TRUE, FALSE), size = nrow(df_train),replace = TRUE, prob = c(0.8, 0.2))
y <- df_train[!which_train]
x <- df_train[which_train]
```

#### Training parameter
Let’s have a look at the default parameters of IBCF model. Here, k is the number of items to compute the similarities among them in the first step. After, for each item, the algorithm identifies its k most similar items and stores the number. method is a similarity funtion, which is Cosine by default, may also be pearson. I create the model using the default parameters of method = Cosine and k=30.
```{r}
recommender_models <- recommenderRegistry$get_entries(dataType ="binaryRatingMatrix")
recommender_models$IBCF_binaryRatingMatrix$parameters
```

#### Training Dataset
```{r}
method <- 'IBCF'
parameter <- list(method = 'Jaccard')
n_recommended <- 5
n_training <- 1000
```

```{r Train}
recc_model <- Recommender(data = x, method = method, parameter = parameter)
model_details <- getModel(recc_model)
```

## Predict
Test Dataset is split randomly, We only use 20% for test.Return value of prediction is top-N-List of recommendation item for each user in test dataset.
```{r Predict}
recc_predicted <-predict(object = recc_model, newdata=y,n = n_recommended, type="topNList")
```

#### Recomendation for 
Recomendation item for first 5 user in training dataset
```{r}
as(recc_predicted,"list")[1:5]
```
```{r include=TRUE }
user_1 <- CustomerId[as.integer(names(recc_predicted@items[1]))]
```
these are the recommendations for user: `r user_1[[1]]`
```{r}
vvv <- recc_predicted@items[[1]]
vvv <- rownames(model_details$sim)[vvv]
itemCode[vvv]
```

#### Compaire to actual purchase
Bellow is actual purchase of user: `r user_1[[1]]`. If we look name or description of the goods,Recommendations given are close to the actual purchase.
```{r}
user_1_buy <- df_data[CustomerID==user_1, sum(Quantity), by=StockCode]
merge(itemCode,user_1_buy, by='StockCode')
```
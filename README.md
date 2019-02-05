# Implementing a recommender system in R

# Source of the dataset
This is a transnational data set which contains all the transactions occurring between 01/12/2010 and 09/12/2011 for a UK-based and registered non-store online retail.The data is obtained fom UCI Machine Learning Repository.

# Structure of the data
Our data contains the following variables with the corresponding descriptions:<br>

1.InvoiceNo: Invoice number. Nominal, a 6-digit integral number uniquely assigned to each transaction. If this code starts with letter 'c', it indicates a cancellation.<br>
2. StockCode: Product (item) code. Nominal, a 5-digit integral number uniquely assigned to each distinct product.<br>
3. Description: Product (item) name. Nominal.<br>
4. Quantity: The quantities of each product (item) per transaction. Numeric.<br>
5. InvoiceDate: Invice Date and time. Numeric, the day and time when each transaction was generated.<br>
6. UnitPrice: Unit price. Numeric, Product price per unit in sterling.<br>
7. CustomerID: Customer number. Nominal, a 5-digit integral number uniquely assigned to each customer.<br>
8. Country: Country name. Nominal, the name of the country where each customer resides.

# Installing / Getting Started

The analysis was conducted using R.<br>

Minimal setup required:<br>

1. R<br>
2. R Studio<br>

Also apart from the R core packages, some other packages are also required for running the analysis.PLease open up the R Studio and run the following commands.The required libraries for this analysis will be installed if required and will be loaded for the current session.<br>

if (!require(tidyverse)) install.packages('tidyverse')<br>
if (!require(arules)) install.packages('arules')<br>
if (!require(arulesViz)) install.packages('arulesViz')<br>
# Libraries used in the project
library(methods)<br>
library(recommenderlab)<br>
library(data.table)<br>
library(ggplot2)<br>
library(knitr)

#

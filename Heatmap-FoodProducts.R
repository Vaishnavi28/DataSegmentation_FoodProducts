#### Shiny App configurationo####

install.packages('rsconnect')
rsconnect::setAccountInfo(name='vaishnavi-ayyadurai', token='24B55F3E373B6683FCC35E2801FE7370', secret='eZf/WvQx3ukMYvhV3ZVQJOhjKW+XfKDrtenUYX+M')
library(rsconnect)
deployApp()
rsconnect::deployApp('C:/Users/vaish/Dropbox/CSU/Data Mining/Assignment/Heatmap-FoodProducts')
rsconnect::configureApp("HEAT MAP- FOOD PRODUCTS", size="small")

setwd ("C:/Users/vaish/Dropbox/CSU/Data Mining/Assignment/")
#Load libraries
library(cluster)
library(ggplot2)
library(dendextend)
library(dplyr)
library(NbClust)#helping find optimal k, has lot of stats , analyses nd gievs best k
library(heatmaply)# for some visualisation

# Read product data file. Data on product nutrition from openfoodfacts.org
# Note colClasses specifies the variable types - first 2 are character, the rest (48) are numberic
# Interpret undefines as NA's

ProductData <- read.csv("products2.csv", na.strings = "undefined",
                        colClasses = c("character", "character", rep("numeric", 48)))
# Delete first column
ProductData$prodid <-NULL


# Select Product Data Subset that has less than 25 NA's
ProdDataSubset <- ProductData[rowSums(is.na(ProductData))<25,]
summary(ProdDataSubset)

# Remove duplicates
CleanProductData <- ProdDataSubset %>% distinct(prodname, .keep_all = TRUE)

# Set NA's to zero
CleanProductData[is.na(CleanProductData)] <- 0
View(CleanProductData)

# Set productname as row names
rownames(CleanProductData) <- CleanProductData[,1]
CleanProductData$prodname <- NULL

# Scale the data
ScaledProdData <- scale(CleanProductData)
ScaledProdData[is.na(ScaledProdData)] <- 0

########### Heat Map##################
# scale data to mean=0, sd=1 and convert to matrix
prodscaled <- as.matrix(scale(ScaledProdData))

## replacing inf, na, nan to 0
is.na(prodscaled) <- sapply(prodscaled, is.infinite)
prodscaled[is.na(prodscaled)] <- 0
prodscaled[is.nan(prodscaled)] <- 0

# create heatmap and don't reorder columns
heatmaply(prodscaled, Colv=F, scale='none')
heatmap(prodscaled, Colv=F, scale='none')

# cluster rows
hc.rows <- hclust(dist(prodscaled))
plot(hc.rows)

# transpose the matrix and cluster columns
hc.cols <- hclust(dist(t(prodscaled)))
plot(hc.cols)

# draw heatmap for first cluster
heatmaply(prodscaled[cutree(hc.rows,k=2)==1,], Colv=as.dendrogram(hc.cols), scale='none',margins = c(60, 150))

# draw heatmap for second cluster
heatmaply(prodscaled[cutree(hc.rows,k=2)==2,], Colv=as.dendrogram(hc.cols), scale='none')


library(ggplot2)
library(dplyr)


setwd(paste0(Sys.getenv('CS_HOME'),'/PatentsMining/Models/Semantic'))

# analysis of network modularities/size to parameters

#wyears = 1980:2012
wyears = 1980:2007
windowSize=5
kwLimit="100000.0"
eth="10.0"



year=2004
yearrange = paste0((year-windowSize+1),"-",year)


sensdata = as.tbl(read.csv(file=paste0('sensitivity/sensitivity_',yearrange,"_",kwLimit,"_eth",eth,".csv"),sep=";",header=TRUE))



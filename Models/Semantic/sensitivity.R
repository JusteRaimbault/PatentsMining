library(ggplot2)
library(dplyr)


setwd(paste0(Sys.getenv('CS_HOME'),'/PatentsMining/Models/Semantic'))

# analysis of network modularities/size to parameters

#wyears = 1980:2012
wyears = 1980:2007
windowSize=5
kwLimit="100000.0"
eth="10.0"


for(year in wyears){
year=1994
yearrange = paste0((year-windowSize+1),"-",year)
sensdata = as.tbl(read.csv(file=paste0('sensitivity/sensitivity_',yearrange,"_",kwLimit,"_eth",eth,".csv"),sep=";",header=TRUE))
argmaxs=sensdata%>% group_by(dispth)%>%summarise(argmaxeth=eth[comnum==max(comnum)][1])
mean(argmaxs$argmaxeth)

g=ggplot(sensdata[sensdata$dispth>0.06,] %>% group_by(dispth,eth) %>% summarise(maxmod=max(modularity),comnum=min(comnum),vcount=mean(vcount)))
g+geom_line(aes(x=eth,y=maxmod,colour=dispth,group=dispth))
g+geom_point(aes(x=maxmod,y=vcount,colour=dispth))
g+geom_point(aes(x=vcount,y=maxmod,colour=dispth))
g+geom_point(aes(x=vcount,y=comnum,colour=dispth))

# TODO : for each year, plot triobjective, highlight chosen points

}


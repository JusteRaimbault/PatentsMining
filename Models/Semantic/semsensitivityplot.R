
#############################
# 
# plot sensitivity results
 
setwd(paste0(Sys.getenv('CS_HOME'),'/PatentsMining/Models/Semantic'))
library(ggplot2)


kwNum = "100000"
type="giant"
years=paste0(1976:2008,"-",1980:2012)

# additional data for mse 
load("processed/sizes-5years.RData")
objdf = read.csv(paste0(Sys.getenv('CS_HOME'),'/PatentsMining/Data/processed/classes/distrib_class_grantdate.csv'),sep=";")


for(y in 1:length(years)){
  year=years[y]
  graph=paste0('relevant_',year,'_full_',kwNum)
  load(file=paste0('sensitivity/',graph,'_',type,'.RData'))
  names(d)[ncol(d)-5]="balance"
  #objdec=c(7,45,90,162,253,372,598,1023,2209)/sizes[y]
  objdec=objdf[y,1:9]/sizes[y]
  # # load from classes file
  # 
  msesizes=c()
  for(i in 1:length(comsizes)){
    msesizes=append(msesizes,sum((log(quantile(comsizes[[i]],(1:9)/10)/d$vertices[i])-log(objdec))^2))
  }
  d=cbind(msesizes,d)
   
   g = ggplot(data.frame(d,freqmaxdec=d$freqmax/sizes[y])) + scale_fill_gradient(low="yellow",high="red")#+ geom_raster(hjust = 0, vjust = 0)
   plots=list()
   for(indic in c("modularity","communities","components","vertices","msesizes","balance")){
     plots[[indic]] = g+geom_raster(aes_string("kmaxdec","edge_th",fill=indic))+facet_grid(freqmaxdec~freqmin)
   }
   multiplot(plotlist = plots,cols=3)
   
   ggsave(paste0(Sys.getenv('CS_HOME'),'/PatentsMining/Results/Semantic/Sensitivity/allyears/window/sensitivity_',year,'.png')) 
   
}





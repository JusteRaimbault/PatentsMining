
# optim params on patent level

setwd(paste0(Sys.getenv('CS_HOME'),'/PatentsMining/Models/Semantic'))

years = 1976:2012

objdf = read.csv(paste0(Sys.getenv('CS_HOME'),'/PatentsMining/Data/processed/classes/distrib_class_grantdate.csv'),sep=";")
objdf = objdf[,1:10]

kmin = 0
freqmin = 50
edge_th = 50

#kmaxs = c();freqmaxs=c();vals=c();indics=c();
vals = data.frame()
for(kmaxdec in c(0.15,0.2,0.25)){
  for(freqmaxdec in c(0.15,0.2,0.25)){
    
    for(y in 1:length(years)){
      year = years[y]
      show(year)
      load(paste0('probas/relevant_',year,'_full_100000_kmin',kmin,'_kmaxdec',kmaxdec,'_freqmin',freqmin,'_freqmaxdec',freqmaxdec,'_eth',edge_th,'.RData'))
      obj=objdf[y,2:ncol(objdf)]/nrow(probas)
      #show(summary(probas$kwproportion))
      #show(summary(colSums(probas[,3:ncol(probas)])/sum(probas[,3:ncol(probas)])))
      #vals=rbind(vals,c(kmaxdec,freqmaxdec,year,0,sum((log(quantile(colSums(probas[,3:ncol(probas)])/sum(probas[,3:ncol(probas)]),(1:9)/10))-log(obj))^2)))
      #vals=rbind(vals,c(kmaxdec,freqmaxdec,year,1,quantile(probas$kwproportion,0.5)))
      vals=rbind(vals,c(kmaxdec,freqmaxdec,year,1,ncol(probas)-2))
    }
  }
}

names(vals)<-c("kmaxdec","freqmaxdec","year","indic","val")
g = ggplot(vals[vals$indic==1,]) + scale_fill_gradient(low="yellow",high="red")
g+geom_raster(aes(kmaxdec,freqmaxdec,fill=val))#+facet_wrap(~year)

# -> take params 0.25,0.25 ? less coms
# whereas 0.15,0.15 : better on coms. <==






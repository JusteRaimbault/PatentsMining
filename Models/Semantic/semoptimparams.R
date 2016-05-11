
# find optim params for each year with multi-dim moving-window objective

setwd(paste0(Sys.getenv('CS_HOME'),'/PatentsMining/Models/Semantic'))

years = 1976:2012

objdf = read.csv(paste0(Sys.getenv('CS_HOME'),'/PatentsMining/Data/processed/classes/distrib_class_grantdate.csv'),sep=";")
objdf = objdf[,1:10]

# convol<-function(vals,p1,p2,p1vals,p2vals){
#   newvals=rep(0,length(vals))
#   for(i in 1:length(vals)){
#     p1ind = which(p1[i]==p1vals);p2ind=which(p2[i]==p2vals)
#     
#   }
# }


values=list()
#optim=data.frame()
optimaggreg=data.frame()
for(y in 1:length(years)){
  show(years[y])
  graph=paste0('relevant_',years[y],'_full_100000')
  load(paste0('sensitivity/',graph,'.RData'))
  load(paste0('processed/',graph,'.RData'))
  names(d)[ncol(d)-2]="balance"
  obj=objdf[y,2:ncol(objdf)]/length(res$keyword_dico)
  msesizes=c()
  for(i in 1:length(comsizes)){
   msesizes=append(msesizes,sum((log(quantile(comsizes[[i]],(1:9)/10)/d$vertices[i])-log(obj))^2))
  }
  d=cbind(msesizes,d)
  d$aggreg=1/4*(d$msesizes-min(d$msesizes,na.rm=TRUE))/(max(d$msesizes,na.rm=TRUE)-min(d$msesizes,na.rm=TRUE))+1/4*(1-(d$communities-min(d$communities,na.rm=TRUE))/(max(d$communities,na.rm=TRUE)-min(d$communities,na.rm=TRUE)))+1/4*(1-(d$modularity-min(d$modularity,na.rm=TRUE))/(max(d$modularity,na.rm=TRUE)-min(d$modularity,na.rm=TRUE)))+1/4*(1-(d$vertices-min(d$vertices,na.rm=TRUE))/(max(d$vertices,na.rm=TRUE)-min(d$vertices,na.rm=TRUE)))
  #show(names(d))
  # 
  # for(indic in c("modularity","communities","components","vertices","msesizes","balance")){
  g = ggplot(d) + scale_fill_gradient(low="yellow",high="red")#+ geom_raster(hjust = 0, vjust = 0)
  #g+geom_raster(aes_string("degree_max","edge_th",fill=indic))+facet_grid(freqmax~freqmin)
  g+geom_raster(aes(degree_max,edge_th,fill=aggreg))+facet_grid(freqmax~freqmin)
  
  # #plots=list()
  # #for(indic in c("modularity","communities","components","vertices","msesizes","balance")){
  # #  plots[[indic]] = g+geom_raster(aes_string("degree_max","edge_th",fill=indic))+facet_grid(freqmax~freqmin)
  # #}
  # #multiplot(plotlist = plots,cols=3)
  # 
  ggsave(paste0('../../Results/Semantic/Sensitivity/allyears/aggreg_',years[y],'.png'),width=30,height = 20,units = "cm")
  # }
  # 
  # moving window in param space : use focal raster ? or do it dirtily ; small dims
  # kmaxvals=unique(d$degree_max)
  # ethvals=unique(d$edge_th)
  # freqminvals=unique(d$freqmin)
  # freqmaxvals=unique(d$freqmax)
  # for(freqmin in freqminvals){
  #   for(freqmax in freqmaxvals){
  #     rows = d$freqmin==freqmin&d$freqmax==freqmax
  #     
  #   }
  # }
  # 
  
  #show(min(d$msesizes,na.rm=TRUE))
  #show(c(years[y],d[which(d$msesizes==min(d$msesizes))[1],]))
  #optim=rbind(optim,c(years[y],unlist(d[which(d$msesizes==min(d$msesizes,na.rm=TRUE))[1],])))
  optimaggreg=rbind(optimaggreg,c(years[y],unlist(d[which(d$aggreg==min(d$aggreg,na.rm=TRUE))[1],])))
  
  #values[[y]]=d
}

names(optim)<-c("year",names(d))
names(optimaggreg)<-c("year",names(d))

save(optim,optimaggreg,file='graphs/all/optim.RData')
load('graphs/all/optim.RData')

# moving window accross time







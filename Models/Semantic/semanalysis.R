
############
#  Analysis of semantic communities
############

setwd(paste0(Sys.getenv('CS_HOME'),'/PatentsMining/Models/Semantic'))

years = 1976:2012

kmin = 0;freqmin = 50;edge_th = 50;kmaxdec=0.15;freqmaxdec=0.15
prefix = paste0('_full_100000_kmin',kmin,'_kmaxdec',kmaxdec,'_freqmin',freqmin,'_freqmaxdec',freqmaxdec,'_eth',edge_th,'.RData')

##
#  1) First order interdisciplinarity

overlaps = c();cyears=c()
for(year in years){
  show(year)
  load(paste0('probas/relevant_',year,prefix))
  probas=probas[,3:ncol(probas)]
  for(i in 1:(ncol(probas)-1)){for(j in (i+1):ncol(probas)){
    overlaps=append(overlaps,sum(probas[,i]*probas[,j])/nrow(probas));cyears=append(cyears,year)
  }}
}

inds=1:length(overlaps)#overlaps>0
overlaps[overlaps==0]=1e-10
g=ggplot(data.frame(overlaps=overlaps[inds],years=as.character(cyears[inds])))
g+geom_density(aes(x=overlaps,colour=years),alpha=0.25,adjust=0.75)+scale_x_log10()+xlab("overlap")+ylab("density")#+scale_y_log10()




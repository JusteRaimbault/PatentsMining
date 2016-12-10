
library(igraph)
library(Matrix)
library(ggplot2)
library(dplyr)

setwd(paste0(Sys.getenv('CS_HOME'),'/PatentsMining/Models/Semantic'))

wyears = 1980:2007
windowSize=5
kwLimit="100000"
dispth=0.06
ethunit="4.1e-05"
classifdir = paste0('classification_window',windowSize,'_kwLimit',kwLimit,'_dispth',dispth,'_ethunit',ethunit)


library(doParallel)
cl <- makeCluster(28,outfile='log')
registerDoParallel(cl)

startTime = proc.time()[3]

modularities <- foreach(year=wyears) %dopar% {
  library(igraph);library(Matrix);source('semanalfun.R')
  load(paste0('processed/',classifdir,'/processed_',(year-windowSize+1),"-",year,'.RData'));
  load(paste0('processed/',classifdir,'/citadj_',(year-windowSize+1),"-",year,'.RData'));show(year)
  m=computemodularities(currentprobas,currentadj)
  m$year=year
  return(m)
}

save(modularities,file='res/modularities.RData')

show(proc.time()[3]-startTime)

stopCluster(cl)


# 
# resdir=paste0(Sys.getenv('CS_HOME'),'/PatentsMining/Results/Semantic/Analysis/window5/overlap/')
# 
# 
# load("res/full-overlaps.RData")
# 
# for(filter in c("all","positive")){
#   for(measure in c("real","norm-patents","relative")){
#     g=ggplot(df[df$filter==filter&df$measure==measure,],aes(x=overlap,colour=year))
#     g+geom_density(alpha=0.25)+scale_x_log10()+xlab(measure)+ylab("density")+facet_wrap(~type,scales="free_y")
#     ggsave(filename = paste0(resdir,measure,"_",filter,"_density.pdf"),width = 15, height = 10,unit="cm")
#     dsum = df[df$filter==filter&df$measure==measure,] %>% group_by(year,type) %>% summarise(overlap=mean(overlap),mi=quantile(overlap,0.1),ma=quantile(overlap,0.9))
#     gsum=ggplot(dsum,aes(x=year,y=overlap,colour=type,group=type),show.legend = FALSE)
#     labs=rep("",length(wyears));labs[seq(from=1,to=length(labs),by=3)]=as.character(wyears[seq(from=1,to=length(labs),by=3)])
#     gsum+geom_point()+geom_errorbar(ymin=mi,ymax=ma)+facet_wrap(~type,scales ="free_y",)+
#       scale_x_discrete(breaks=as.character(wyears),labels=labs)
#     ggsave(filename = paste0(resdir,measure,"_",filter,"_ts.pdf"),width = 15, height = 10,unit="cm")
#     #rm(g,gsum);gc()
#     }
# }



#library(doParallel)
#cl <- makeCluster(17,outfile='log')
#registerDoParallel(cl)
#
#startTime = proc.time()[3]
#
#res <- foreach(year=years) %dopar% {
#  library(Matrix)
#  load(paste0('probas/processed_',year,'.RData'))
#  technoprobas=currentprobas$technoprobas;semprobas=currentprobas$semprobas;#rm(currentprobas);gc()
#  inds = which(colSums(technoprobas)>200)
#  currenttechovs = c() #rep(0,ncol(technoprobas)*(ncol(technoprobas)-1)/2)
#  currentsemovs = c() #rep(0,ncol(semprobas)*(ncol(semprobas)-1)/2)
#  k=1
#  for(i in 1:(length(inds)-1)){show(i);for(j in (i+1):length(inds)){
#    currenttechovs=append(currenttechovs,sum(technoprobas[,inds[i]]*technoprobas[,inds[j]])/nrow(technoprobas))
#  }}
#  inds = which(colSums(semprobas)>200)
#  for(i in 1:(length(inds)-1)){show(i);for(j in (i+1):length(inds)){
#    currentsemovs=append(currentsemovs,sum(semprobas[,i]*semprobas[,j])/nrow(semprobas));
#  }}
#  return(list(techov=currenttechovs,techyear=rep(year,length(currenttechovs)),semov=currentsemovs,semyear=rep(year,length(currentsemovs))))
#}
#
#
#save(res,file='res/classes_overlaps.RData')
#
#show(proc.time()[3]-startTime)
#
#
#startTime = proc.time()[3]
#
#
#overlaps=c();cyears=c()
#res <- foreach(year=years) %dopar% {
#  load(paste0('probas_processed/processed_',year,'.RData'))
#  technoprobas=currentprobas$technoprobas;semprobas=currentprobas$semprobas;#rm(currentprobas);gc()
#  # all couples (i\in sem, j\in techno)
#  inds = which(colSums(technoprobas)>100)
#  currentovs = rep(0,length(inds)*ncol(semprobas))
#  k=1
#  for(i in 1:ncol(semprobas)){show(i);for(j in inds){
#    currentovs[k]=sum(semprobas[,i]*technoprobas[,j])/nrow(technoprobas);k=k+1
#  }}
#  return(list(overlap=currentovs,year=rep(year,length(inds)*ncol(semprobas))))
#}
#
#save(res,file='res/inter_overlaps.RData')
#
#show(proc.time()[3]-startTime)
#
#stopCluster(cl)


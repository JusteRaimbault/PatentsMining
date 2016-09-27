
setwd(paste0(Sys.getenv('CS_HOME'),'/PatentsMining/Models/Semantic'))

years = 1980:2012
windowSize=5

library(doParallel)
cl <- makeCluster(17,outfile='log')
registerDoParallel(cl)

startTime = proc.time()[3]

res <- foreach(year=years) %dopar% {
  library(Matrix)
  load(paste0('probas/processed_',year,'.RData'))
  technoprobas=currentprobas$technoprobas;semprobas=currentprobas$semprobas;#rm(currentprobas);gc()
  inds = which(colSums(technoprobas)>200)
  currenttechovs = c() #rep(0,ncol(technoprobas)*(ncol(technoprobas)-1)/2)
  currentsemovs = c() #rep(0,ncol(semprobas)*(ncol(semprobas)-1)/2)
  k=1
  for(i in 1:(length(inds)-1)){show(i);for(j in (i+1):length(inds)){
    currenttechovs=append(currenttechovs,sum(technoprobas[,inds[i]]*technoprobas[,inds[j]])/nrow(technoprobas))
  }}
  inds = which(colSums(semprobas)>200)
  for(i in 1:(length(inds)-1)){show(i);for(j in (i+1):length(inds)){
    currentsemovs=append(currentsemovs,sum(semprobas[,i]*semprobas[,j])/nrow(semprobas));
  }}
  return(list(techov=currenttechovs,techyear=rep(year,length(currenttechovs)),semov=currentsemovs,semyear=rep(year,length(currentsemovs))))
}


save(res,file='res/classes_overlaps.RData')

show(proc.time()[3]-startTime)


startTime = proc.time()[3]

overlaps=c();cyears=c()
res <- foreach(year=years) %dopar% {
  load(paste0('probas_processed/processed_',year,'.RData'))
  technoprobas=currentprobas$technoprobas;semprobas=currentprobas$semprobas;#rm(currentprobas);gc()
  # all couples (i\in sem, j\in techno)
  inds = which(colSums(technoprobas)>100)
  currentovs = rep(0,length(inds)*ncol(semprobas))
  k=1
  for(i in 1:ncol(semprobas)){show(i);for(j in inds){
    currentovs[k]=sum(semprobas[,i]*technoprobas[,j])/nrow(technoprobas);k=k+1
  }}
  return(list(overlap=currentovs,year=rep(year,length(inds)*ncol(semprobas))))
}

save(res,file='res/inter_overlaps.RData')

show(proc.time()[3]-startTime)

stopCluster(cl)


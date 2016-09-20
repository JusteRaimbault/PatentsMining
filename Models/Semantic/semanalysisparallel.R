
setwd(paste0(Sys.getenv('CS_HOME'),'/PatentsMining/Models/Semantic'))

years = 1980:2012
windowSize=5

library(doParallel)
cl <- makeCluster(33,outfile='log')
registerDoParallel(cl)

startTime = proc.time()[3]

res <- foreach(year=years) %dopar% {
  load(paste0('probas/processed_',year,'.RData'))
  technoprobas=currentprobas$technoprobas;semprobas=currentprobas$semprobas;#rm(currentprobas);gc()
  inds = which(colSums(technoprobas)>50)
  currenttechovs = c() #rep(0,ncol(technoprobas)*(ncol(technoprobas)-1)/2)
  currentsemovs = c() #rep(0,ncol(semprobas)*(ncol(semprobas)-1)/2)
  k=1
  for(i in 1:(length(inds)-1)){show(i);for(j in (i+1):length(inds)){
    currenttechovs=append(currenttechovs,sum(technoprobas[,inds[i]]*technoprobas[,inds[j]])/nrow(technoprobas))
  }}
  for(i in 1:(ncol(semprobas)-1)){show(i);for(j in (i+1):ncol(semprobas)){
    currentsemovs=append(currentsemovs,sum(semprobas[,i]*semprobas[,j])/nrow(semprobas));
  }}
  return(list(techov=currenttechovs,techyear=rep(year,length(currenttechovs)),semov=currentsemovs,semyear=rep(year,length(currentsemovs))))
}


save(res,file='res/classes_overlaps.RData')

show(proc.time()[3]-startTime)
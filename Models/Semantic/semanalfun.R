
library(Matrix)
library(ggplot2)

semsuffix='_kwLimit100000_dispth0.06_ethunit4.5e-05.csv'
#semprefix='probas/probas_'
semprefix='probas_count/counts_'
year=1980

technoprefix=paste0(Sys.getenv('CS_HOME'),'/PatentsMining/Data/processed/classes/technoPerYear/technoProbas_')
#sizeTh=10
# TODO : recompute techno probas on moving window ?
# or better : single matrix with all patents ; gets corresponding rows with semantic rownames
#  -> check rowname indexing perfs

# load techno probas
load(file=paste0(Sys.getenv('CS_HOME'),'/PatentsMining/Data/processed/classes/sparse.RData'))



loadSemantic<-function(year){
    show(paste0('loading year : ',year))
    yearrange=paste0((year-windowSize+1),"-",year)
    entrylist = read.csv(file=paste0(semprefix,yearrange,semsuffix),sep=";",header=FALSE)
    rowinds = cumsum(c(1,as.integer(entrylist[1:(nrow(entrylist)-1),1]!=entrylist[2:nrow(entrylist),1])))
    if(dim(entrylist)[2]==3){colinds=entrylist[,2]+1;vals=entrylist[,3]}else{colinds=entrylist[,3]+1;vals=entrylist[,4]}
    res = sparseMatrix(i=rowinds,j=colinds,x=vals)
    if(dim(entrylist)[2]==4){
      res =Diagonal(x=1/rowSums(res))%*%res
    }
    rownames(res)<-unique(as.character(entrylist[,1]))
   return(res)
}



loadProbas<-function(year){
  show(year)
  res=list()
  res$semprobas = loadSemantic(year)
  rowstoadd=setdiff(rownames(res$semprobas),rownames(technoMatrix))
  if(length(rowstoadd)>0){
    technoMatrix=rbind(technoMatrix,matrix(0,length(rowstoadd),ncol(technoMatrix)));
    rownames(technoMatrix)[(nrow(technoMatrix)-length(rowstoadd)+1):nrow(technoMatrix)]=rowstoadd
  }
  res$technoprobas = technoMatrix[rownames(res$semprobas),]
  return(res)
}

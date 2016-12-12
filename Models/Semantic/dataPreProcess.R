
library(Matrix)
setwd(paste0(Sys.getenv('CS_HOME'),'/PatentsMining/Models/Semantic'))

source('semanalfun.R')

wyears = 1980:2012
windowSize=5
kwLimitNum="100000.0"
kwLimit="100000"
dispth=0.06
ethunit="4.1e-05"

classifdir = paste0('classification_window',windowSize,'_kwLimit',kwLimit,'_dispth',dispth,'_ethunit',ethunit)



dir.create(paste0('processed/',classifdir))

semprefix = paste0('classification/',classifdir,'/probas_')
semsuffix = '_kwLimit100000.0_dispth0.06_ethunit4.1e-05.csv'

# 
# # load techno probas
# load(file=paste0(Sys.getenv('CS_HOME'),'/PatentsMining/Data/processed/classes/techno_sparse.RData'))
# load(file=paste0(Sys.getenv('CS_HOME'),'/PatentsMining/Data/processed/classes/techno_sparse_primary.RData'))
# 
# # first load all probas
# #probas=list()
# for(year in wyears){
#   currentprobas=loadProbas(year,semprefix,semsuffix)
#   yearrange=paste0((year-windowSize+1),"-",year)
#   save(currentprobas,file=paste0('processed/',classifdir,'/processed_',yearrange,'.RData'))
#   rm(currentprobas);gc()
# }




# load citation matrix
load(paste0(Sys.getenv('CS_HOME'),'/PatentsMining/Data/processed/citation/network/adjacency.RData'))

# preprocess adjacency for memory purposes
for(year in wyears){
  load(paste0('processed/',classifdir,'/processed_',(year-windowSize+1),"-",year,'.RData'));show(year)
  technoprobas=currentprobas$technoprobas;semprobas=currentprobas$semprobas;rm(currentprobas);gc()
  currentnames=intersect(rownames(technoprobas),rownames(citadjacency))
  namestoadd=setdiff(rownames(technoprobas),currentnames)
  currentadj = citadjacency[currentnames,currentnames]
  currentadj=rbind(currentadj,Matrix(0,length(namestoadd),ncol(currentadj)))
  rownames(currentadj)[(nrow(currentadj)-length(namestoadd)+1):nrow(currentadj)]=namestoadd
  currentadj=cbind(currentadj,Matrix(0,nrow(currentadj),length(namestoadd)))
  colnames(currentadj)[(ncol(currentadj)-length(namestoadd)+1):ncol(currentadj)]=namestoadd
  save(currentadj,file=paste0('processed/',classifdir,'/citadj_',(year-windowSize+1),"-",year,'.RData'))
  #sizes=append(sizes,sum(citadjacency[currentnames,currentnames]));cyears=append(cyears,year)
  #fromwindow=append(fromwindow,sum(citadjacency[currentnames,]))
  rm(technoprobas,semprobas,currentnames,currentadj);gc()
}







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


# load techno probas
load(file=paste0(Sys.getenv('CS_HOME'),'/PatentsMining/Data/processed/classes/techno_sparse.RData'))
load(file=paste0(Sys.getenv('CS_HOME'),'/PatentsMining/Data/processed/classes/techno_sparse_primary.RData'))

# first load all probas
#probas=list()
for(year in wyears){
  currentprobas=loadProbas(year,semprefix,semsuffix)
  yearrange=paste0((year-windowSize+1),"-",year)
  save(currentprobas,file=paste0('processed/',classifdir,'/processed_',yearrange,'.RData'))
  rm(currentprobas);gc()
}




# import and saving as RData of yearly techno classes structures

setwd(paste0(Sys.getenv('CS_HOME'),'/PatentsMining/Models/Techno/TechnoClasses/res/technoPerYear'))

library(Matrix)

years = 1976:2012

sizeTh = 10

for(year in years){
  show(year)
  d = read.table(file=paste0('technoProbas_',year,'_sizeTh',sizeTh),sep=";",row.names = 1,header=TRUE)
  #d[is.na(d)]=0
  m = Matrix(as.matrix(d),sparse=TRUE)
  save(m,file=paste0(Sys.getenv('CS_HOME'),'/PatentsMining/Data/processed/classes/technoPerYear/technoProbas_',year,'_sizeTh',sizeTh,'.RData'))
}




# import and saving as RData of yearly techno classes structures

setwd(paste0(Sys.getenv('CS_HOME'),'/PatentsMining/Models/Techno/TechnoClasses/res/technoPerYear'))

library(Matrix)

years = 1976:2012

sizeTh = 10

for(year in years){
  show(year)
  d = Matrix(read.table(file=paste0('technoProbas_',year,'_sizeTh',sizeTh),sep=";",row.names = TRUE,header=TRUE),sparse=TRUE)
  save(d,file=paste0(Sys.getenv('CS_HOME'),'/PatentsMining/Data/processed/classes/technoPerYear/technoProbas_',year,'_sizeTh',sizeTh,'.RData'))
}

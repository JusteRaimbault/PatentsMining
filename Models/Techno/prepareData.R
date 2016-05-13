
# import and saving as RData of yearly techno classes structures

setwd(paste0(Sys.getenv('CS_HOME'),'/PatentsMining/Models/Techno/TechnoClasses/res/technoPerYear'))

years = 1976:2012

for(year in years){
  d = read.table('',sep=";",row.names = TRUE,header=TRUE)
}


# parallel all year graph construction
#
#  should be invoked as R -f allYears.R --args yearfile

setwd(paste0(Sys.getenv('CS_HOME'),'/PatentsMining/Models/Semantic'))
source('networkConstruction.R')

years = read.csv(file=commandArgs(trailingOnly = TRUE)[1],header=FALSE)

show(years)

for(year in years[,1]){
  show(paste0("year:",year))
  importNetwork(paste0('relevant.relevant_',year,'_full_100000'),'patent.keywords',year,paste0('relevant.network_',year,'_full_100000_eth10'),10,paste0('processed/relevant_',year,'_full_100000'))
}

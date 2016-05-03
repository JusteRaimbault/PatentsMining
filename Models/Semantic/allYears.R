
# parallel all year graph construction
#
#  should be invoked as R -f allYears.R --args yearfile

setwd(paste0(Sys.getenv('CS_HOME'),'/PatentsMining/Models/Semantic'))
source('networkConstruction.R')

years = read.csv(file=commandArgs(trailingOnly = TRUE)[1])

for(year in years){
  importNetwork(paste0('relevant.relevant_',year,'_full_100000'),'patent.keywords',year,paste0('network_',year,'_full_100000_eth10'),10,paste0('processed/relevant_',year,'_full_100000'))
}



# construct full nws for fung years

setwd(paste0(Sys.getenv('CS_HOME'),'/PatentsMining/Models/Semantic'))
source('networkConstruction.R')


years = c("1998","1999","2000","2005","2006","2007","2008","2009","2010")

for(year in years){
  importNetwork(paste0('relevant_fung.relevant_',year,'_full_100000'),'patents_fung.keywords',year,paste0('network_',year,'_full_100000_eth10'),50,paste0('processed/relevant_',year,'_full_100000'))
}

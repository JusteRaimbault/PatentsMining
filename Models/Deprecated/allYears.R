
# parallel all year graph construction
#
#  should be invoked as R -f allYears.R --args yearfile
#  (for parrun)
#
#  format for years (moving window) : begin-end

setwd(paste0(Sys.getenv('CS_HOME'),'/PatentsMining/Models/Semantic'))
source('networkConstruction.R')

years = read.csv(file=commandArgs(trailingOnly = TRUE)[1],header=FALSE,sep=";")

show(years)

edgeTh = 10
kwNum = "100000"

for(i in 1:nrow(years)){
  yearRange=years[i,]
  show(yearRange)
  year = paste0(as.character(yearRange[1]),"-",as.character(yearRange[length(yearRange)]))
  show(paste0("yearRange : ",yearRange," ; year:",year))
  importNetwork(paste0('relevant.relevant_',year,'_full_',kwNum),'patent.keywords',yearRange,paste0('relevant.network_',year,'_full_',kwNum,'_eth',edgeTh),edgeTh,paste0('processed/relevant_',year,'_full_',kwNum))
}

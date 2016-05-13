
# construct citation network

setwd(paste0(Sys.getenv('CS_HOME'),'/PatentsMining/Data/processed/citation'))

library(igraph)
library(Matrix)

edf1 = read.csv(file=paste0(Sys.getenv('CS_HOME'),'/PatentsMining/Data/raw/citation/citation75_99.csv'),stringsAsFactors = FALSE)
edf2 = read.csv(file=paste0(Sys.getenv('CS_HOME'),'/PatentsMining/Data/raw/citation/citation00_10.csv'),stringsAsFactors = FALSE)

edf = rbind(edf1[,c(1,6)],edf2[,c(1,6)])
names(edf)<-c("from","to")

gcitation = graph_from_data_frame(edf)
citadjacency = get.adjacency(gcitation,sparse=TRUE)

save(gcitation,file='network/citationNetwork.RData')
save(citadjacency,file='network/adjacency.RData')

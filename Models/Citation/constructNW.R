
# construct citation network

setwd(paste0(Sys.getenv('CS_HOME'),'/PatentsMining/Data/processed/citation'))

library(igraph)
library(Matrix)

edf1 = read.csv(file=paste0(Sys.getenv('CS_HOME'),'/PatentsMining/Data/raw/citation/citation75_99/citation75_99.csv'),stringsAsFactors = FALSE)
edf2 = read.csv(file=paste0(Sys.getenv('CS_HOME'),'/PatentsMining/Data/raw/citation/citation00_10.csv'),stringsAsFactors = FALSE)

from = c(edf1[,1],edf2[,1])
to = c(edf1[,6],edf2[,6])
# apply : 7digits ids
from[sapply(from,nchar)==8] <- substr(from[sapply(from,nchar)==8],2,8)
to[sapply(from,nchar)==8] <- substr(to[sapply(from,nchar)==8],2,8)

#edf = rbind(edf1[,c(1,6)],edf2[,c(1,6)])
#names(edf)<-c("from","to")

edf = data.frame(from=from,to=to)

gcitation = graph_from_data_frame(edf)
citadjacency = get.adjacency(gcitation,sparse=TRUE)

save(gcitation,file='network/citationNetwork.RData')
save(citadjacency,file='network/adjacency.RData')

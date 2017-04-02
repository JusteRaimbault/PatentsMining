

setwd(paste0(Sys.getenv('CS_HOME'),'/PatentsMining/Data/Japan'))

filepath = paste0(Sys.getenv('CS_HOME'),'/PatentsMining/Data/Japan/jp.csv')

library(dplyr)
library(igraph)

raw <- as.tbl(read.csv(file=filepath,sep=',',stringsAsFactors = FALSE))

firms = as.character(unique(raw$fno))
classes = unique(raw$IPC)

probas = matrix(0,length(firms),length(classes))
rownames(probas) = firms
colnames(probas) = classes

# compute count matrix
for(i in 1:nrow(raw)){probas[as.character(raw$fno[i]),raw$IPC[i]]=probas[as.character(raw$fno[i]),raw$IPC[i]]+1}

# normalize to have probas by firm
probas <- t(apply(probas,1,function(r){r/sum(r)}))

# proximity matrix between firms
firmproximity = probas%*%t(probas)

# hist(c(firmproximity[firmproximity>0]),breaks=10000)
# -> seem to have a nice distribution

# optional threshold parameters, set > 0 to have smaller graphs
link_threshold = 0.05
firmproximity[firmproximity<link_threshold]=0

g = graph_from_adjacency_matrix(firmproximity,mode="undirected",weighted = TRUE,diag = FALSE)

# check modularity
#cl = cluster_louvain(g)

dir.create('test')
outfile = 'test/graph_theta0.05.gml'
write_graph(graph = g,file = outfile,format = 'gml')



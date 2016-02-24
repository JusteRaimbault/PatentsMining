
# semantic network construction from database

setwd(paste0(Sys.getenv('CS_HOME'),'/PatentsMining/Models/Semantic'))

library(dplyr)
library(igraph)
library(RSQLite)

source('networkConstruction.R')

## sqlite data
brun = 'run_year2005_limit-1_kw2000_csize20000_b10_runs10'
bpath=paste0('../TextProcessing/bootstrap/',brun,'/bootstrap.sqlite3')
db = dbConnect(SQLite(),bpath)
relevant = dbReadTable(db,'relevant')
dico = dbReadTable(db,'dico')



## Construct nw

nw=exportNetwork(list(relevant=relevant,dico=dico),
                kwthreshold=2500,linkthreshold=0,
                connex=FALSE,export=TRUE,exportPrefix="graphs/run_year2005_limit-1_kw2000_csize20000_b10_runs10/",
                filterFile="data/filter.csv"
                )

g=nw$g;keyword_dico=nw$keyword_dico
g = filterGraph(g,'data/filter.csv')


clust = clusters(g);cmax = which(clust$csize==max(clust$csize))
ggiant = induced.subgraph(g,which(clust$membership==cmax))


## graph filtering : node degree and edge weight

kmin = 50
kmax = 1200  
edge_th = 10 

# filter on degree (work already on giant component ?)
#max(degree(ggiant))
#max(E(ggiant)$weight) 
d=degree(ggiant)
gg=induced_subgraph(ggiant,which(d>kmin&d<kmax))
gg=subgraph.edges(gg,which(E(gg)$weight>edge_th))

write.graph(gg,file = paste0('graphs/',brun,'/all_connex_filt_kmin',kmin,'_kmax',kmax,'_edge',edge_th,'.gml'),format = "gml")
# filter on edge weight

# communities
com = cluster_louvain(gg)
for(i in unique(com$membership)){show(i);show(V(gg)$name[which(com$membership==i)])}
# construct kw -> thematic dico
thematics = list()
for(i in 1:length(V(gg))){
  thematics[[V(g)$name[i]]]=com$membership[i]
}

# compute proba matrix
them_probas = matrix(0,length(names(keyword_dico)),length(unique(com$membership)))
for(i in 1:length(names(keyword_dico))){
  if(i%%100==0){show(i)}
  kwcount=0
  for(kw in keyword_dico[[names(keyword_dico)[i]]]){if(kw %in% names(thematics)){
    j=thematics[[kw]]
    them_probas[i,j]=them_probas[i,j]+1;kwcount=kwcount+1
  }}
  if(kwcount>0){them_probas[i,]=them_probas[i,]/kwcount}
}


# test semantic originalities

originalities=apply(them_probas,MARGIN = 1,FUN = function(r){if(sum(r)==0){return(0)}else{return(1 - sum(r^2))}})
hist(originalities[originalities>0.6],breaks=50,main="",xlab="originalities")
#summary(originalities)





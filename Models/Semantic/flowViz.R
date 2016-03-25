
# community flow visualization

setwd(paste0(Sys.getenv('CS_HOME'),'/PatentsMining/Models/Semantic'))
source('networkConstruction.R')

library(networkD3)

# example from package
#sankeyNetwork(Links = Energy$links, Nodes = Energy$nodes, Source = "source",Target = "target", Value = "value", NodeID = "name",units = "TWh", fontSize = 12, nodeWidth = 30)



# TODO : single date overlaps -> use ?
#  http://jokergoo.github.io/circlize/example/grouped_chordDiagram.html

# TODO : inclusion in a shiny app : idem see
#  https://christophergandrud.github.io/networkD3/

years = c("1998","1999","2005","2006","2007","2008","2009","2010")

coms=list()

for(year in years){
  show(paste0("year ",year))
  load(paste0('processed/',year,'.RData'))
  g=nw$g
  g = filterGraph(g,'data/filter.csv')
  clust = clusters(g);cmax = which(clust$csize==max(clust$csize))
  ggiant = induced.subgraph(g,which(clust$membership==cmax))
  kmin = 200
  kmax = 20000
  edge_th = 20
  #d=degree(ggiant)
  d=strength(ggiant)
  gg=induced_subgraph(ggiant,which(d>kmin&d<kmax))
  gg=subgraph.edges(gg,which(E(gg)$weight>edge_th))
  d=strength(gg)
  com = cluster_louvain(gg)
  yearlycoms=list()
  for(k in 1:length(com)){
    # find name for each com : largest degree node
    inds = which(com$membership==k)
    yearlycoms[[names(d)[inds[which(max(d[inds])==d[inds])[1]]]]] = com[[k]]
  }
  coms[[year]]=yearlycoms
}



# construct distances between comunities
nodes=list()
links=list()

# communities as list in time of list of kws
#   list(year1 = list(com1 = c(...), com2 = c(...)))

similarityIndex <- function(com1,com2){
  return(2 * length(intersect(com1,com2))/(length(com1)+length(com2)))
}

# compute nodes

# -> data.frame with name
k=1
for(year in years){
  for(comname in names(coms[[year]])){
    nodes[[paste0(comname,"_",year)]]=k
    k=k+1
  }
}

# compute edges

links=list();
nodes=list()
# data.frame with source (id), target (id) and value = weight
k=1;kn=0
for(t in 2:length(years)){
  prec = coms[[years[t-1]]];current = coms[[years[t]]]
  for(i in 1:length(prec)){
    for(j in 1:length(current)){
        weight = similarityIndex(prec[[i]],current[[j]])
        if(weight>0.1&length(prec[[i]])>5&length(current[[j]]>5)){
          precname=paste0(names(prec)[i],"_",years[t-1]);currentname=paste0(names(current)[j],"_",years[t])
          if(!(precname %in% names(nodes))){nodes[[precname]]=kn;kn=kn+1}
          if(!(currentname %in% names(nodes))){nodes[[currentname]]=kn;kn=kn+1}
          links[[k]] = c(nodes[[precname]],nodes[[currentname]],weight)
          k = k + 1
        }
      }
  }
}

mlinks=as.data.frame(matrix(data = unlist(links),ncol=3,byrow=TRUE))
names(mlinks)<-c("from","to","weight")
#mlinks$weight=1000*mlinks$weight
mnodes = data.frame(id=1:length(nodes),name=names(nodes))

plot(graph_from_data_frame(mlinks,vertices=mnodes))

# plot the graph
sankeyNetwork(Links = mlinks, Nodes = mnodes, Source = "from",
              Target = "to", Value = "weight", NodeID = "name",
              ,fontSize = 12, nodeWidth = 20)
    
forceNetwork(Links = mlinks, Nodes = mnodes, Source = "from",
             Target = "to", Value = "weight", NodeID = "name",Group="name")
          
#sankeyNetwork(Links = mlinks, Nodes = mnodes)         

sankeyNetwork()


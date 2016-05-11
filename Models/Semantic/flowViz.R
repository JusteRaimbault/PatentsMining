
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

#years = c("1998","1999","2005","2006","2007","2008","2009","2010")
years = 1976:2012

coms=list()

for(y in 1:length(years)){
  show(paste0("year ",years[y]))
  graph=paste0('relevant_',years[y],'_full_100000')
  load(paste0('processed/',graph,'.RData'))
  g=res$g
  g = filterGraph(g,'data/filter.csv')
  save(g,file=paste0('processed/',graph,'_filtered.RData'))
  clust = clusters(g);cmax = which(clust$csize==max(clust$csize))
  ggiant = induced.subgraph(g,which(clust$membership==cmax))
  
  #sub = extractSubGraphCommunities(ggiant,0,optimaggreg$degree_max[y],optimaggreg$freqmin[y],optimaggreg$freqmax[y],optimaggreg$edge_th[y])
  sub = extractSubGraphCommunities(ggiant,0,max(degree(ggiant))*0.2,50,10000,50)
  
  com=sub$com
  d=V(sub$gg)$docfreq
  
  yearlycoms=list()
  for(k in 1:length(com)){
    # find name for each com : largest degree node
    inds = which(com$membership==k)
    yearlycoms[[V(sub$gg)$name[inds[which(max(d[inds])==d[inds])[1]]]]] = com[[k]]
  }
  coms[[years[y]]]=yearlycoms
}

save(coms,file='graphs/all/optim_coms.RData')

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
novelties=data.frame();cumnovs=c()
k=1;kn=0
for(t in 2:length(years)){
  prec = coms[[years[t-1]]];current = coms[[years[t]]]
  cumnov=0
  for(i in 1:length(current)){
    
    novelty=1
    for(j in 1:length(prec)){
        weight = similarityIndex(prec[[j]],current[[i]])
        novelty=novelty-weight^2
        # if(weight>0.01&length(prec[[i]])>2&length(current[[j]]>2)){
        #   precname=paste0(names(prec)[i],"_",years[t-1]);currentname=paste0(names(current)[j],"_",years[t])
        #   if(!(precname %in% names(nodes))){nodes[[precname]]=kn;kn=kn+1}
        #   if(!(currentname %in% names(nodes))){nodes[[currentname]]=kn;kn=kn+1}
        #   links[[k]] = c(nodes[[precname]],nodes[[currentname]],weight)
        #   k = k + 1
        # }
    }
    novelties=rbind(novelties,c(years[t],novelty*length(current[[i]])/sum(unlist(lapply(current,length)))))
   cumnov=cumnov+novelty*length(current[[i]])/sum(unlist(lapply(current,length))) 
  }
  cumnovs=append(cumnovs,cumnov)
}

plot(years[2:length(years)],cumnovs,type='l')

names(novelties)<-c("year","novelty")
g=ggplot(novelties,aes(year,novelty))
g+geom_point()+geom_smooth()


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


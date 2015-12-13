
# construct the graph from relevant kw dico

setwd(paste0(Sys.getenv('CS_HOME'),'/PatentsMining/Data/processed'))

dico <- read.csv('relevantDico_y2000_size10000_kwLimit40002015-12-13 20:08:06.398927.csv',
                 sep=";",header=FALSE,stringsAsFactors=FALSE)


###

library(igraph)

edges_o=c();edges_d=c();edges_names = c();

for(i in 1:nrow(dico)){
  for(j in 2:(ncol(dico)-1)){
    if(dico[i,j]!=""){
      for(k in (j+1):ncol(dico)){
        if(dico[i,k]!=""&&dico[i,k]!=dico[i,j]){
          edges_o=append(edges_o,dico[i,j]);edges_d=append(edges_d,dico[i,k]);edges_names=append(edges_names,dico[i,1]);
        }
      }
      
    }
  }
  if(i%%1000==0){show(i)}
}

# graph
g = graph.data.frame(data.frame(o=edges_o,d=edges_d,name=edges_names))

# take giant component only for now
g = induced.subgraph(g,which(clusters(g)$membership==1))
# use decompose.graph instaed


# summary stats
d = diameter(g)
plot(degree.distribution(g))
hist(degree(g),breaks=100)
V(g)[degree(g)>200]
E(g)[incident(g,V(g)[degree(g)>250])]

# test for comunities
com <- spinglass.community(g, spins=100)
V(g)$color <- com$membership+1
g <- set.graph.attribute(g, "layout", layout.kamada.kawai(g))



plot(g, layout=layout.fruchterman.reingold,
    # vertex.label=NA, 
     vertex.size=3, edge.arrow.mode=0,
     vertex.label.cex=degree(g)/200
    )


# cliques ?

clic = cliques(g,min=4)
clic_lengths = sapply(clic,length)
hist(clic_lengths,breaks=20)

# -> not interesting, patent abstract structure ?





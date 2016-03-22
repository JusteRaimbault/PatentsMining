
# community flow visualization

library(networkD3)

# example from package
#sankeyNetwork(Links = Energy$links, Nodes = Energy$nodes, Source = "source",
             #Target = "target", Value = "value", NodeID = "name",
             #units = "TWh", fontSize = 12, nodeWidth = 30)



# TODO : single date overlaps -> use ?
#  http://jokergoo.github.io/circlize/example/grouped_chordDiagram.html

# TODO : inclusion in a shiny app : idem see
#  https://christophergandrud.github.io/networkD3/


# construct distances between comunities
nodes = list()
links=list()

# communities as list in time of list of kws
#   list(year1 = list(com1 = c(...), com2 = c(...)))

similarityIndex <- function(com1,com2){}

# construct temporal 'flows' = similarity indexes between successives communities
years = c(1998,1999,2005:2010)

coms = list()
for(year in years){
  coms[[as.character(year)]]=yearlyCom(year,kmin=50,kmax=900,edge_th=10)
}

# compute nodes


# compute edges
for(t in 2:length(years)){
  prec = coms[[as.character(years[t-1])]];current = coms[[as.character(years[t])]]
  for(i in 1:length(prec)){
    for(j in 1:length(current)){
        weight = similarityIndex(prec[[i]],prec[[j]])
        #links = append(links,list())
    }
  }
}

# plot the graph




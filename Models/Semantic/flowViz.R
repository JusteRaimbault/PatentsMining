
# community flow visualization

setwd(paste0(Sys.getenv('CS_HOME'),'/PatentsMining/Models/Semantic'))

library(networkD3)
library(dplyr)
library(igraph)


wyears = 1980:2007
windowSize=5
kwLimitNum="100000.0"
kwLimit="100000"
dispth=0.06
ethunit="4.1e-05"
classifdir = paste0('classification_window',windowSize,'_kwLimit',kwLimit,'_dispth',dispth,'_ethunit',ethunit)
semprefix = paste0('classification/',classifdir,'/keywords_')
semsuffix = paste0('_kwLimit',kwLimitNum,'_dispth',dispth,'_ethunit',ethunit,'.csv')

# communities as list in time of list of kws
#   list(year1 = list(com1 = c(...), com2 = c(...)))


coms=list()

for(year in wyears){
  yearrange=paste0((year-windowSize+1),"-",year);show(year)
  currentkws = as.tbl(read.csv(file=paste0(semprefix,yearrange,semsuffix),sep=";",stringsAsFactors = FALSE))
  currentcoms = list()
  for(i in unlist(unique(currentkws$community))){
    rows = currentkws[currentkws$community==i,]
    # try to name by best techno disp
    name =unlist(rows[rows$technodispersion==max(rows$technodispersion),1])[1] #Reduce(function(s1,s2){return(paste0(s1," ; ",s2))},unlist(rows[rows$technodispersion==max(rows$technodispersion),1])[1:2])
    currentcoms[[name]]=unlist(rows[,1])
  }
  coms[[as.character(year)]]=currentcoms
}

# test independance measures for naming
#pcaname = prcomp(apply(currentkws[,3:11],2,function(col){return((col - min(col))/(max(col)-min(col)))}))
#cor(apply(currentkws[,3:11],2,function(col){return((col - min(col))/(max(col)-min(col)))}))
#summary(pcaname)

# test com size filtering
# for(year in wyears){
#   lengths = sapply(coms[[as.character(year)]],length)
#   #show(sum(lengths)/100)
#   show(length(which(lengths>(sum(lengths)/100)))/length(coms[[as.character(year)]]))
# }

# -> 100 seems ok




similarityIndex <- function(com1,com2){
  return(2 * length(intersect(com1,com2))/(length(com1)+length(com2)))
}

#similarityIndex(coms[["1980"]]$`insect trap`,coms[["1981"]]$`insect trap`)
# PB in nameing taking the most disp word : chemicals -> insect trap !

# compute nodes

# -> data.frame with name
# k=1
# for(year in years){
#   for(comname in names(coms[[year]])){
#     nodes[[paste0(comname,"_",year)]]=k
#     k=k+1
#   }
# }

# compute edges
years=as.character(wyears)
#sizeTh=100
sizeQuantile = 0.97

links=list();
nodes=list()
# data.frame with source (id), target (id) and value = weight
novelties=data.frame();cumnovs=c()
k=1;kn=0
for(t in 2:length(years)){
  show(years[t])
  prec = coms[[years[t-1]]];current = coms[[years[t]]]
  cumnov=0
  currentsizes=sapply(current,length)
  precsizes=sapply(prec,length)
  for(i in 1:length(current)){
    if(length(current[[i]])>quantile(currentsizes,sizeQuantile)){
      if(i%%100==0){show(i/length(current))}
      novelty=1
      for(j in 1:length(prec)){
        if(length(current[[i]])>quantile(precsizes,sizeQuantile)){
          weight = similarityIndex(unlist(prec[[j]]),unlist(current[[i]]))
          novelty=novelty-weight^2
          if(weight>0.01&length(prec[[j]])>20&length(current[[i]]>20)){
            # need community names indexing the list
            precname=paste0(names(prec)[j],"_",years[t-1]);currentname=paste0(names(current)[i],"_",years[t])
            if(!(precname %in% names(nodes))){nodes[[precname]]=kn;kn=kn+1}
            if(!(currentname %in% names(nodes))){nodes[[currentname]]=kn;kn=kn+1}
            links[[k]] = c(nodes[[precname]],nodes[[currentname]],weight)
            k = k + 1
          }
        }
      }
      #novelties=rbind(novelties,c(years[t],novelty*length(current[[i]])/sum(unlist(lapply(current,length)))))
      #cumnov=cumnov+novelty*length(current[[i]])/sum(unlist(lapply(current,length))) 
    }
  }
  #cumnovs=append(cumnovs,cumnov)
}

# plot(years[2:length(years)],cumnovs,type='l')
# 
#names(novelties)<-c("year","novelty")
#g=ggplot(novelties,aes(year,novelty))
#g+geom_point()+geom_smooth()


mlinks=as.data.frame(matrix(data = unlist(links),ncol=3,byrow=TRUE))
names(mlinks)<-c("from","to","weight")
#mlinks$weight=1000*mlinks$weight
mnodes = data.frame(id=0:(length(nodes)-1),name=names(nodes))

#plot(graph_from_data_frame(mlinks,vertices=mnodes))
g = graph_from_data_frame(mlinks,vertices=mnodes)
V(g)$year=as.numeric(sapply(V(g)$name,function(x){substring(text=x,first=nchar(x)-3)}))
V(g)$comname = sapply(V(g)$name,function(x){substring(text=x,first=1,last=nchar(x)-5)})

# Tests for layout
#V(g)$x = V(g)$year;V(g)$y=runif(vcount(g))
#layout = layout_with_fr(g);pca=prcomp(layout)
#V(g)$y=(layout%*%pca$rotation)[,1];
#V(g)$y=layout[,1]
#V(g)$x=2*V(g)$year
#for(year in unique(V(g)$year)){V(g)$y[V(g)$year==year]=rank(V(g)$y[V(g)$year==year],ties.method="random")*20/length(which(V(g)$year==year))}#V(g)$y[V(g)$year==year]-mean(V(g)$y[V(g)$year==year])}

# specific algo for layout, using weight proximity
V(g)$x=V(g)$year

# 
# V(g)$y[V(g)$year==wyears[1]]=(1:length(which(V(g)$year==wyears[1])))/length(which(V(g)$year==wyears[1])) # random layout for first row
# for(currentyear in wyears[2:length(wyears)]){
#   V(g)$y[V(g)$year==currentyear]=1:length(which(V(g)$year==currentyear))
#   currentvertices = V(g)[V(g)$year==currentyear]
#   for(v in currentvertices){
#     currentedges = E(g)[V(g)%->%v]
#     if(length(currentedges)>0){
#       V(g)$y[V(g)==v] = sum(currentedges$weight/sum(currentedges$weight)*head_of(g,currentedges)$y)
#     }
#   }
#   # put rank for more visibility
#   #V(g)$y[V(g)$year==currentyear] = rank(V(g)$y[V(g)$year==currentyear],ties.method = "random")/length(which(V(g)$year==currentyear))
#   #V(g)$y[V(g)$year==currentyear] = (V(g)$y[V(g)$year==currentyear] - min(V(g)$y[V(g)$year==currentyear]))/(max(V(g)$y[V(g)$year==currentyear])-min(V(g)$y[V(g)$year==currentyear]))
# }

# greedy algo optimisation ?

# uniform init
V(g)$y = runif(vcount(g))

nruns = 20
for(currentyear in wyears[2:length(wyears)]){
  incoming = E(g)[which(V(g)$year==(currentyear-1))%->%which(V(g)$year==currentyear)]
  diff = abs(head_of(g,incoming)$y - tail_of(g,incoming)$y)*incoming$weight
  # move vertex with largest angle <- move prevs ? ; need to aggregate on dest vertices.
  
}




plot.igraph(g,#layout=layout_as_tree(g),
            vertex.size=0.3,vertex.label=NA,#vertex.label.cex=0,
            edge.arrow.size=0,edge.width=5*E(g)$weight#,
            #edge.curved=TRUE,margin=0
            )



# try brutal optimisation

penalty<-function(coordinates)


optim <- ga(type="real-valued",fitness=penalty,min=rep(0,vcount(g)),max=rep(1,vcount(g)))
  










##########
## Plot on communities sizes

meansizes=c();medsizes=c();years=c()
for(year in wyears){
  currentcoms = coms[[as.character(year)]]
  currentlengths=sapply(currentcoms,length)
  meansizes=append(meansizes,mean(currentlengths));medsizes=append(medsizes,quantile(currentlengths,0.5));years=append(years,year)
}

ylabel = "community size"
gsum=ggplot(data.frame(meansizes,years),aes(x=years,y=meansizes))
labs=rep("",length(wyears));labs[seq(from=1,to=length(labs),by=5)]=as.character(wyears[seq(from=1,to=length(labs),by=5)])
gsum+geom_point()+geom_line()+
  #scale_x_discrete(breaks=as.character(wyears),labels=labs)+
  ylab(paste0("mean ",ylabel))+xlab("year")+
  theme(axis.title = element_text(size = 22), axis.text.x = element_text(size = 15),  axis.text.y = element_text(size = 15))
ggsave(file=paste0(Sys.getenv("CS_HOME"),'/PatentsMining/Results/Semantic/Analysis/window5/sizes/meancomsize.pdf'),width=10,height=5)








##########
# old plots with 3djs

# plot the graph
#sankeyNetwork(Links = mlinks, Nodes = mnodes, Source = "from",
#              Target = "to", Value = "weight", NodeID = "name",
#              fontSize = 12, nodeWidth = 20)



# TODO : single date overlaps -> use ?
#  http://jokergoo.github.io/circlize/example/grouped_chordDiagram.html

# TODO : inclusion in a shiny app : idem see
#  https://christophergandrud.github.io/networkD3/







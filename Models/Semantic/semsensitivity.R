
# sensitivity to threshold parameters

setwd(paste0(Sys.getenv('CS_HOME'),'/PatentsMining/Models/Semantic'))
library(dplyr)
library(igraph)
source('networkConstruction.R')

years = read.csv(file=commandArgs(trailingOnly = TRUE)[1],header=FALSE,sep=";")

# TODO read kwnum from file
kwNum = "100000"
type="full" # full or giant : take full graph or giant component

for(i in 1:nrow(years)){
  yearRange=years[i,]
  year = paste0(as.character(yearRange[1]),"-",as.character(yearRange[length(yearRange)]))
  
  graph=paste0('relevant_',year,'_full_100000')
  load(paste0('processed/',graph,'.RData'))
  nPatents = length(res$keyword_dico)
  g=res$g;
  rm(res);gc()
  
  g = filterGraph(g,'data/filter.csv')
  
  # TODO DO NOT USE giant component ?
  clust = clusters(g);
  cmax = which(clust$csize==max(clust$csize))
  if(type=="full"){ggiant=g}
  else{ggiant = induced.subgraph(g,which(clust$membership==cmax))}

  dd = V(ggiant)$docfreq
  d = degree(ggiant)
  
  kmin = 0
  
  modularities = c();
  comnumber=c();
  dmax=c();
  eth=c();
  csizes=c();
  gsizes=c();
  gdensity=c();
  cbalance=c();
  freqsmin=c();freqsmax=c()
  comsizes=list()
  i=1
  
  #
  # freqmin and freqmax as proportion of patent number ?
  #  - freqmin can be independent in a first time ; as edge_th -
  #    freqmax = c(5000,10000,20000,50000) ; 95 : 144706 patents -> ~ 0.25 max
  for(freqmaxdec in c(0.025,0.05,0.15,0.25)){
    freqmax = freqmaxdec*nPatents
    for(freqmin in c(50,100,200,500)){
      for(kmax in seq(from=0.05,to=0.6,by=0.05)*max(d)){
        for(edge_th in seq(from=50,to=250,by=20)){
          show(paste0('kmax : ',kmax,' e_th : ',edge_th,' ; freqmin : ',freqmin,' ; freqmax : ',freqmax))
          gg=induced_subgraph(ggiant,which(d>kmin&d<kmax&dd>freqmin&dd<freqmax))
          gg=subgraph.edges(gg,which(E(gg)$weight>edge_th))
          clust = clusters(gg);cmax = which(clust$csize==max(clust$csize))
          gg = induced.subgraph(gg,which(clust$membership==cmax))
          com = cluster_louvain(gg)
          # measures
          gsizes=append(gsizes,length(V(gg)));
          gdensity=append(gdensity,2*length(E(gg))/(length(V(gg))*(length(V(gg))-1)))
          csizes=append(csizes,length(clust$csize))
          modularities = append(modularities,modularity(com))
          comnumber=append(comnumber,length(communities(com)))
          cbalance=append(cbalance,sum((sizes(com)/length(V(gg)))^2))
          dmax=append(dmax,kmax);eth=append(eth,edge_th)
          freqsmin=append(freqsmin,freqmin);freqsmax=append(freqsmax,freqmax)
          comsizes[[i]]=sizes(com)
          i=i+1
        }
      }
    }
  }
  
  d = data.frame(degree_max=dmax,edge_th=eth,vertices=gsizes,components=csizes,modularity=modularities,communities=comnumber,density=gdensity,comunitiesbalance=cbalance,freqmin=freqsmin,freqmax=freqsmax)
  
  save(d,comsizes,file=paste0('sensitivity/',graph,'_',type,'.RData'))
  
}

#############################
# 
# 
# library(ggplot2)
#load('sensitivity/relevant_2010_full_100000.RData')
#names(d)[ncol(d)-2]="balance"
#objdec=c(7,45,90,162,253,372,598,1023,2209)/length(res$keyword_dico)
# load from classes file

#msesizes=c()
#for(i in 1:length(comsizes)){
#  msesizes=append(msesizes,sum((log(quantile(comsizes[[i]],(1:9)/10)/d$vertices[i])-log(objdec))^2))
#}
#d=cbind(msesizes,d)

#g = ggplot(d) + scale_fill_gradient(low="yellow",high="red")#+ geom_raster(hjust = 0, vjust = 0)
#plots=list()
#for(indic in c("modularity","communities","components","vertices","msesizes","balance")){
#  plots[[indic]] = g+geom_raster(aes_string("degree_max","edge_th",fill=indic))+facet_grid(freqmax~freqmin)
#}
#multiplot(plotlist = plots,cols=3)





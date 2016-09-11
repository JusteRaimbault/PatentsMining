
# sensitivity to threshold parameters

setwd(paste0(Sys.getenv('CS_HOME'),'/PatentsMining/Models/Semantic'))
library(dplyr)
library(igraph)
source('networkConstruction.R')

years = read.csv(file=commandArgs(trailingOnly = TRUE)[1],header=FALSE,sep=";")

# TODO read kwnum from file
kwNum = "100000"
#type="full" # full or giant : take full graph or giant component
type="giant"

sizes=c()
for(i in 1:nrow(years)){
  yearRange=years[i,]
  year = paste0(as.character(yearRange[1]),"-",as.character(yearRange[length(yearRange)]))
  show(year)
  
  graph=paste0('relevant_',year,'_full_',kwNum)
  load(paste0('processed/',graph,'.RData'))
  nPatents = length(res$keyword_dico)
  sizes=append(sizes,nPatents)

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
   freqsmin=c();freqsmax=c();
   freqsmaxdec=c();kmaxsdec=c()
   comsizes=list()
   i=1

   #
   # freqmin and freqmax as proportion of patent number ?
   #  - freqmin can be independent in a first time ; as edge_th -
   #    freqmax = c(5000,10000,20000,50000) ; 95 : 144706 patents -> ~ 0.25 max
   for(freqmaxdec in c(0.025,0.05,0.15,0.25)){
     freqmax = freqmaxdec*nPatents
     for(freqmin in c(50,100,200,500)){
       for(kmaxdec in seq(from=0.05,to=0.6,by=0.05)){
         kmax = kmaxdec*max(d)
 	for(edge_th in seq(from=50,to=250,by=20)){
           show(paste0('kmax : ',kmax,' e_th : ',edge_th,' ; freqmin : ',freqmin,' ; freqmax : ',freqmax))
           gg=induced_subgraph(ggiant,which(d>kmin&d<kmax&dd>freqmin&dd<freqmax))
           gg=subgraph.edges(gg,which(E(gg)$weight>edge_th))
           clust = clusters(gg);cmax = which(clust$csize==max(clust$csize))
           
           
           # TODO remove this second filtering ?
           #  -> seem not to change that much
           gg = induced.subgraph(gg,which(clust$membership==cmax))
           write.graph(gg,'graphs/test.gml')
           
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
           freqsmaxdec=append(freqsmaxdec,freqmaxdec);kmaxsdec=append(kmaxsdec,kmaxdec)
 	  comsizes[[i]]=sizes(com)
           i=i+1
         }
       }
     }
   }

   d = data.frame(degree_max=dmax,edge_th=eth,vertices=gsizes,components=csizes,modularity=modularities,communities=comnumber,density=gdensity,comunitiesbalance=cbalance,freqmin=freqsmin,freqmax=freqsmax,kmaxdec=kmaxsdec,kmaxdec=kmaxsdec)

   save(d,comsizes,file=paste0('sensitivity/',graph,'_',type,'.RData'))

}




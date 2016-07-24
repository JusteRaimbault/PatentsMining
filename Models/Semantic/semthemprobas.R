
setwd(paste0(Sys.getenv('CS_HOME'),'/PatentsMining/Models/Semantic'))
library(dplyr)
library(igraph)
source('networkConstruction.R')

years = read.csv(file=commandArgs(trailingOnly = TRUE)[1],header=FALSE)
for(year in years[,1]){
  show(paste0('computing probas for year ',year))
  graph=paste0('relevant_',year,'_full_100000')
  load(paste0('processed/',graph,'.RData'))
  g=res$g;
  
  g = filterGraph(g,'data/filter.csv')
  
  clust = clusters(g);cmax = which(clust$csize==max(clust$csize))
  ggiant = induced.subgraph(g,which(clust$membership==cmax))
  
  kmin = 0
  freqmin = 50
  for(edge_th in c(10,25)){
  for(kmaxdec in c(0.15,0.25)){
    for(freqmaxdec in c(0.15,0.25)){
      kmax=kmaxdec*max(degree(ggiant))
      freqmax=freqmaxdec*length(res$keyword_dico)
      sub = extractSubGraphCommunities(ggiant,kmin,kmax,freqmin,freqmax,edge_th)
      probas = computeThemProbas(sub$gg,sub$com,res$keyword_dico)
      save(sub,probas,file=paste0('probas/',graph,'_kmin',kmin,'_kmaxdec',kmaxdec,'_freqmin',freqmin,'_freqmaxdec',freqmaxdec,'_eth',edge_th,'.RData'))
    }
  }
  }
}

#################
#################

#dbparams = 'relevant_full_50000_eth50_nonfiltdico_kmin0_kmax1000_freqmin100_freqmax10000_eth150'
#load(paste0('probas/',dbparams,'.RData'))
#them_probas = probas


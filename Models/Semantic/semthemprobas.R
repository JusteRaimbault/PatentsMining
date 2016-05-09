
setwd(paste0(Sys.getenv('CS_HOME'),'/PatentsMining/Models/Semantic'))
library(dplyr)
library(igraph)
source('networkConstruction.R')

years = read.csv(file=commandArgs(trailingOnly = TRUE)[1],header=FALSE)
for(year in years){
  show(paste0('computing probas for year ',year))
  graph=paste0('relevant_',year,'_full_100000')
  load(paste0('processed/',graph,'.RData'))
  g=res$g;
  
  g = filterGraph(g,'data/filter.csv')
  
  clust = clusters(g);cmax = which(clust$csize==max(clust$csize))
  ggiant = induced.subgraph(g,which(clust$membership==cmax))
  
  
  kmin = 0
  freqmax = 10000
  freqmin = 50
  for(kmax in c(800,1200,2000)){
    for(edge_th in c(50,100)){
      sub = extractSubGraphCommunities(ggiant,kmin,kmax,freqmin,freqmax,edge_th)
      probas = computeThemProbas(sub$gg,sub$com,res$keyword_dico)
      save(sub,probas,file=paste0('probas/fung_',graph,'_kmin',kmin,'_kmax',kmax,'_freqmin',freqmin,'_freqmax',freqmax,'_eth',edge_th,'.RData'))
    }
  }
  
}

#################
#################

#dbparams = 'relevant_full_50000_eth50_nonfiltdico_kmin0_kmax1000_freqmin100_freqmax10000_eth150'
#load(paste0('probas/',dbparams,'.RData'))
#them_probas = probas


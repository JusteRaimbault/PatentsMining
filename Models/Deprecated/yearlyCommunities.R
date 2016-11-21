
# yearly communities construction from mongo relevant db

#library(RMongo)
library(rmongodb)

source('networkConstruction.R')

#'
#' Construct graph from mongo given the year
#'
yearlyCom <- function(year){#},kmin,kmax,edge_th){
  show(paste0('Constructing graph for year ',year,'...'))
  # path to bootstrap db (built-in)
  show('Bootstrap data...')
  brun='patent_limit-1_kw2000_csize10000_b10_runs10'
  mongo <- mongo.create()
  #mongo <- mongoDbConnect(brun, "localhost", 27017)  
  #relevant <- RMongo::dbGetQuery(mongo,paste0('relevant_',year),'{}',skip=0,limit = 10000)
  relevant <-mongo.find.all(mongo,paste0(brun,'.relevant_',year))
  # get dico
  show('Dico data...')
  #dico <- RMongo::dbGetQuery(mongo,'keywords',paste0('{year :',year,'}'),skip=0,limit = )
  dico <- mongo.find.all(mongo,'patents_keywords.keywords',list(year=year))
  
  # fit data to exportNetwork function
  relevant = data.frame(keyword=sapply(relevant,function(d){d$keyword}),cumtermhood=sapply(relevant,function(d){d$cumtermhood}))
  # no change dico : list
  
  # construct nw
  show('Constructing network...')
  nw=exportNetwork(list(relevant=relevant,dico=dico),
                   kwthreshold=3000,linkthreshold=0,
                   connex=FALSE,export=FALSE)
  
  
  #g=nw$g;keyword_dico=nw$keyword_dico
  
  save(nw,file=paste0('processed/',year,'.RData'))
  #g = filterGraph(g,'data/filter.csv')
  # export data as R vars
  
  
  # giant component
  #clust = clusters(g);cmax = which(clust$csize==max(clust$csize))
  #ggiant = induced.subgraph(g,which(clust$membership==cmax))
  
  # construct communities
  #d=degree(ggiant)
  #gg=induced_subgraph(ggiant,which(d>kmin&d<kmax))
  #gg=subgraph.edges(gg,which(E(gg)$weight>edge_th))
  #com = cluster_louvain(gg)
  
  # get comunities nodes names and degrees
  #weightedDegree = strength(gg)
  
  #res=list()
  
  #return(res)
  
}

setwd(paste0(Sys.getenv('CS_HOME'),'/PatentsMining/Models/Semantic'))

#years = c(1998,1999,2005:2010)
years = 2007:2010
for(year in years){
  yearlyCom(year)
}



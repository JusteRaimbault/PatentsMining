
# semantic network construction from database

setwd(paste0(Sys.getenv('CS_HOME'),'/PatentsMining/Models/Semantic'))

library(dplyr)
library(igraph)
library(RSQLite)
library(ggplot2)

source('networkConstruction.R')


## Load nw

year = 2010
graph=paste0('relevant_',year,'_full_100000')
load(paste0('processed/',graph,'.RData'))
g=res$g;
rm(res);gc()
g = filterGraph(g,'data/filter.csv')

clust = clusters(g);cmax = which(clust$csize==max(clust$csize))
ggiant = induced.subgraph(g,which(clust$membership==cmax))


## graph filtering : node degree and edge weight

kmin = 0
kmax = 500
edge_th = 50
freqmin=50
freqmax=10000

sub=extractSubGraphCommunities(ggiant,kmin,kmax,freqmin,freqmax,edge_th)
sub$gg;sub$com

#write.graph(gg,file = paste0('graphs/',brun,'/all_connex_filt_kmin',kmin,'_kmax',kmax,'_edge',edge_th,'.gml'),format = "gml")
write.graph(sub$gg,file = 'graphs/fung/test.gml',format = "gml")


# filter on edge weight

# communities
com = cluster_louvain(gg)
#for(i in unique(com$membership)){show(i);show(V(gg)$name[which(com$membership==i)])}
# construct kw -> thematic dico
weighteddegree=strength(gg);names(weighteddegree)=1:length(weighteddegree)
thematics = list();weights=list()
for(i in 1:length(V(gg))){
  thematics[[V(g)$name[i]]]=com$membership[i]
  weights[[V(g)$name[i]]]=weighteddegree[i]
}

# compute proba matrix
them_probas = matrix(0,length(names(keyword_dico)),length(unique(com$membership)))
for(i in 1:length(names(keyword_dico))){
  if(i%%100==0){show(i)}
  kwcount=0
  for(kw in keyword_dico[[names(keyword_dico)[i]]]){if(kw %in% names(thematics)){
    j=thematics[[kw]];w=weights[[kw]]
    them_probas[i,j]=them_probas[i,j]+w;
    kwcount=kwcount+w
  }}
  if(kwcount>0){them_probas[i,]=them_probas[i,]/kwcount}
}

#length(which(rowSums(them_probas)==0))
# test semantic originalities

originalities=apply(them_probas,MARGIN = 1,FUN = function(r){if(sum(r)==0){return(0)}else{return(1 - sum(r^2))}})
#hist(originalities[originalities>0.6],breaks=50,main="",xlab="originalities (92% > 0.6)")
#ggplot(data.frame(originality=originalities), aes(x=originality)) + geom_density(alpha=.3,fill="grey")+geom_vline(xintercept=mean(originalities),linetype="dashed", size=1)
#summary(originalities)
#length(originalities[originalities>0.6])

# Null model
kwlength=mean(sapply(V(g)$name,nchar))
abstractlengths=sapply(dico$keywords,nchar)
names(abstractlengths)<-1:length(abstractlengths)
memberships<-com$membership
nullweights=list();for(k in unique(memberships)){nullweights[[k]]=weighteddegree[which(com$membership==k)]}
drawWeights<-function(m){w=c();for(k in m){w=append(w,sample(nullweights[[k]],1))};return(w)}

bsize=20000
borig=c()
for(b in 1:bsize){
  if(b%%1000==0){show(b)}
  nkws = floor(sample(abstractlengths,1)/kwlength)+1
  m=sample(memberships,nkws,replace=TRUE);w=drawWeights(m)
  probas=list();for(k in 1:length(m)){if(!(as.character(m[k]) %in% names(probas))){probas[[as.character(m[k])]]=w[k]}else{probas[[as.character(m[k])]]=probas[[as.character(m[k])]]+w[k]}}
  borig=append(borig,1-sum((sapply(probas,function(x){x/sum(w)}))^2))
}

dat=data.frame(originality=c(originalities,borig),type=c(rep("patents",length(originalities)),rep("null",length(borig))))
sdat=as.tbl(dat)%>%group_by(type)%>%summarise(mean=mean(originality))  
ggplot(dat, aes(x=originality, fill=type)) + geom_density(alpha=.3)+geom_vline(data=sdat, aes(xintercept=mean,  colour=type),linetype="dashed", size=1)+ggtitle(paste0("Weighted by terms weighted degree, kmax = ",kmax,", edge_th = ",edge_th))



# search patent with no kw
db = dbConnect(SQLite(),'../../Data/raw/patdesc/patdesc.sqlite3')
relevant = dbReadTable(db,'patdesc')




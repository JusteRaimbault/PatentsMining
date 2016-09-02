
#  functions for netowrk export

library(dplyr)
library(igraph)
library(rmongodb)



##
# Compute thematic probability matrix
#
computeThemProbas<-function(gg,com,keyword_dico){
  # construct kw -> thematic dico
  thematics = list()
  for(i in 1:length(V(gg))){
    thematics[[V(gg)$name[i]]]=com$membership[i]
  }
  
  them_probas = matrix(0,length(names(keyword_dico)),length(unique(com$membership)))
  kwproportion=c();kwnum=c()
  for(i in 1:length(names(keyword_dico))){
    if(i%%100==0){show(i)}
    kwcount=0
    for(kw in keyword_dico[[names(keyword_dico)[i]]]){
      if(kw %in% names(thematics)){
        j=thematics[[kw]]
        them_probas[i,j]=them_probas[i,j]+1;kwcount=kwcount+1
      }
    }
    if(kwcount>0){
      them_probas[i,]=them_probas[i,]/kwcount
    }
    kn=length(keyword_dico[[names(keyword_dico)[i]]])
    kwnum = append(kwnum,kn)
    if(kn>0){kwproportion=append(kwproportion,kwcount/kn)}else{kwproportion=append(kwproportion,0)}
  }
  res=cbind(kwproportion,kwnum,data.frame(them_probas))
  rownames(res)=names(keyword_dico);colnames(res)[1:2]=c("kwproportion","kwnum")
  return(res)
}





##
# extract subgraph communities for given parameters
extractSubGraphCommunities<-function(ggiant,kmin,kmax,freqmin,freqmax,edge_th){
  dd = V(ggiant)$docfreq
  d = degree(ggiant)
  gg=induced_subgraph(ggiant,which(d>kmin&d<kmax&dd>freqmin&dd<freqmax))
  gg=subgraph.edges(gg,which(E(gg)$weight>edge_th))
  clust = clusters(gg);cmax = which(clust$csize==max(clust$csize))
  gg = induced.subgraph(gg,which(clust$membership==cmax))
  com = cluster_louvain(gg)
  return(list(gg=gg,com=com))
}


# repeated louvain
repeatedLouvain<-function(gg,Nrep){
  
}


##
# construct network from mongo
importNetwork<-function(relevantcollection,kwcollection,kwyear,nwcollection,edge_th,target){
  show(paste0('Constructing network for years ',kwyear,' with eth ',edge_th))
  show(kwyear)
  mongo <- mongo.create(host="127.0.0.1:29019")
  #mongo.authenticate(mongo,"root","root")
  # 
  relevant <- mongo.find.all(mongo,relevantcollection)
  dico <- mongo.find.all(mongo,kwcollection,query=list(app_year=list('$in'=as.character(kwyear))))
 
  show(paste0('dico size : ',length(dico)))
  show(paste0('relevant : ',length(relevant)))
 
  relevant = data.frame(keyword=sapply(relevant,function(d){d$keyword}),
                        cumtermhood=sapply(relevant,function(d){d$cumtermhood}),
                        docfreq=sapply(relevant,function(d){d$docfrequency}),
                        tidf=sapply(relevant,function(d){d$tidf})
  )
  
  srel = as.tbl(relevant)
  srel$keyword = as.character(srel$keyword)
  
  rel = list()
  for(i in 1:length(srel$keyword)){rel[[srel$keyword[i]]]=i}
  
  # construct kw dico : ID -> keywords
  keyword_dico = list()
  for(i in 1:length(dico)){
    if(i%%100==0){show(paste0('dico : ',i/length(dico),'%'))}
    #kws = unique(dico[[i]]$keywords)
    kws=dico[[i]]$keywords
    #show(kws)
    if(length(kws)>0){
      #kws = kws[sapply(kws,function(w){w %in% srel$keyword})]
      keyword_dico[[dico[[i]]$id]]=kws
    }
  }
  
  # construct now edge dataframe
  edges <- mongo.find.all(mongo,nwcollection)
  e1=c();e2=c();weights=c()
  for(i in 1:length(edges)){
    if(i%%1000==0){show(paste0('edges : ',i/length(edges),'%'))}
    w=edges[[i]]$weight
    if(w>=edge_th){
      e = strsplit(edges[[i]]$edge,";")[[1]]
      if(length(e)==2){
      if(e[1]!=e[2]){# avoid self loops, weight info is already contained in doc frequency of nodes
        e1=append(e1,e[1]);e2=append(e2,e[2]);weights=append(weights,w)
      }
      }
    }
  }
  
  res = list()
  res$g = graph_from_data_frame(data.frame(from=e1,to=e2,weight=weights),directed=FALSE,vertices = relevant)
  res$keyword_dico=keyword_dico
  
  save(res,file=paste0(target,'.RData'))
  
}









# filter nodes : grep -v -f file for nodes names
filterGraph<-function(graph,file){
  show(paste0('Filtering graph nodes from ',file))
  words<-unlist(read.csv(file,stringsAsFactors=FALSE,header=FALSE))
  g=graph
  for(w in 1:length(words)){
    #show(words[w])   
    g=induced.subgraph(g,which(V(g)$name!=words[w]))
    #show(length(V(g)))
  }
  return(g)
}


# 
# ##
# #  generic function to create and export nw
# #  also compute kws dictionary (used later in originality computation)
# exportNetwork<-function(data,
#                         kwthreshold = 2000,
#                         linkthreshold =15,
#                         connex=TRUE,
#                         export=FALSE,
#                         exportPrefix="",
#                         filterFile="",
#                         kwFile="2000"#,
#                         #dicoSplitFunction = function(s){strsplit(enc2utf8(s),";")[[1]]}
#                         ){
#   
#   relevant = data$relevant
#   dico = data$dico
#   # dico can be of two types : output of a scanned pseudo-csv or structured output of sqlite table
#   # must take that into account
#   #kwCol=2
#   #if(is.null(dim(dico))){dico=data.frame(keywords=dico);kwCol=1}
#   # dirty as keep id in kws, but needed for perf to not split strings twice
#   
#   srel = as.tbl(relevant)
#   srel$keyword = as.character(srel$keyword)
#   srel = srel %>% arrange(desc(cumtermhood))
#   if(filterFile!=""){
#     forbidden = read.csv(filterFile)
#     srel = srel %>% filter(!(keyword %in% forbidden))
#   }
#   
#   
#   srel = srel[1:min(kwthreshold,nrow(srel)),]
#   
#   # construct relevant dico : word -> index
#   rel = list()
#   for(i in 1:length(srel$keyword)){rel[[srel$keyword[i]]]=i}
#   
#   res=list()
# 
#   keyword_dico = list()
#   
#   # fill keyword dico before coocs, avoid N^2 in all words
#   for(i in 1:length(dico)){
#     if(i%%100==0){show(i)}
#     kws = unique(dico[[i]]$keywords)
#     kws = kws[sapply(kws,function(w){w %in% srel$keyword})]
#     keyword_dico[[dico[[i]]$id]]=kws
#   }
#   
#   keyword_dico_keys = names(keyword_dico)
#   
#   cooccs = matrix(0,nrow(srel),nrow(srel))
#   
#   for(i in 1:length(keyword_dico)){
#     if(i%%100==0){show(i)}
#     #kws=strsplit(enc2utf8(dico[i,kwCol]),";")[[1]]
#     #kws = dicoSplitFunction(dico[i,kwCol])
#     kws = keyword_dico[[i]]
#     #id=keyword_dico_keys[i]
#     #if(kwCol==1){id=kws[1];kws=kws[-1];}else{id=dico[i,1]}
#     if(length(kws)>1){
#       for(k in 1:(length(kws)-1)){
#         for(l in (k+1):(length(kws))){
#           if(nchar(kws[k])>0&nchar(kws[l])>0){
#             cooccs[rel[[kws[k]]],rel[[kws[l]]]]=cooccs[rel[[kws[k]]],rel[[kws[l]]]]+1
#           }
#         }
#       }
#     }
#     #keyword_dico[[id]]=kws
#   }
#   
#   colnames(cooccs) = names(unlist(rel))
#   # filter edges
#   adjacency=cooccs;adjacency[adjacency<linkthreshold]=0
#   g = graph_from_adjacency_matrix(adjacency,weighted=TRUE,mode="undirected")
#   
#   
#   # keep giant component
#   if(connex==TRUE){
#     clust = clusters(g);cmax = which(clust$csize==max(clust$csize))
#     g = induced.subgraph(g,which(clust$membership==cmax))
#   }
#   
#   if(export==TRUE){
#     if(kwCol==1){
#     filename=paste0(exportPrefix,"_kw",kwFile,"_kwth",kwthreshold,"_th",linkthreshold,"_connex",connex)
#     }else{
#       filename=paste0(exportPrefix,"_kwth",kwthreshold,"_th",linkthreshold,"_connex",connex)
#     }
#     if(filterFile!=""){filename=paste0(filename,"_filtered")}
#     filename=paste0(filename,".gml")
#     write.graph(g,filename,"gml")
#   }
#   
#   res=list()
#   res$g=g
#   res$keyword_dico=keyword_dico
#   
#   return(res)
# }
# 


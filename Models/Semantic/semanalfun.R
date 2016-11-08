
#library(Matrix)


#semsuffix='_kwLimit100000_dispth0.06_ethunit4.5e-05.csv'
#semprefix='probas/probas_'
#semprefix='probas_count/counts_'

#technoprefix=paste0(Sys.getenv('CS_HOME'),'/PatentsMining/Data/processed/classes/technoPerYear/technoProbas_')
#sizeTh=10
# TODO : recompute techno probas on moving window ?
# or better : single matrix with all patents ; gets corresponding rows with semantic rownames
#  -> check rowname indexing perfs

# load techno probas
load(file=paste0(Sys.getenv('CS_HOME'),'/PatentsMining/Data/processed/classes/sparse.RData'))
#technoMatrixAll=technoMatrix
#load(file=paste0(Sys.getenv('CS_HOME'),'/PatentsMining/Data/processed/classes/techno_primary.RData'))


loadSemantic<-function(year){
    show(paste0('loading year : ',year))
    yearrange=paste0((year-windowSize+1),"-",year)
    entrylist = read.csv(file=paste0(semprefix,yearrange,semsuffix),sep=";",header=FALSE)
    rowinds = cumsum(c(1,as.integer(entrylist[1:(nrow(entrylist)-1),1]!=entrylist[2:nrow(entrylist),1])))
    if(dim(entrylist)[2]==3){colinds=entrylist[,2]+1;vals=entrylist[,3]}else{colinds=entrylist[,3]+1;vals=entrylist[,4]}
    res = sparseMatrix(i=rowinds,j=colinds,x=vals)
    if(dim(entrylist)[2]==4){
      res = diag(rowSums(res))%*%res
    }
    rownames(res)<-unique(as.character(entrylist[,1]))
   return(res)
}



loadProbas<-function(year){
  show(year)
  res=list()
  res$semprobas = loadSemantic(year)
  rowstoadd=setdiff(rownames(res$semprobas),rownames(technoMatrix))
  if(length(rowstoadd)>0){
    technoMatrix=rbind(technoMatrix,matrix(0,length(rowstoadd),ncol(technoMatrix)));
    rownames(technoMatrix)[(nrow(technoMatrix)-length(rowstoadd)+1):nrow(technoMatrix)]=rowstoadd
  }
  res$technoprobas = technoMatrix[rownames(res$semprobas),]
  return(res)
}


##
# further data preprocessing : primary techno probas
addPrimaryTechno<-function(yearrange){
  load(paste0('probas/processed_counts_',yearrange,'.RData'))
  res=currentprobas
  rowstoadd=setdiff(rownames(res$semprobas),rownames(technoMatrix))
  if(length(rowstoadd)>0){
    technoMatrix=rbind(technoMatrix,matrix(0,length(rowstoadd),ncol(technoMatrix)));
    rownames(technoMatrix)[(nrow(technoMatrix)-length(rowstoadd)+1):nrow(technoMatrix)]=rowstoadd
  }
  res$primarytechnoprobas = technoMatrix[rownames(res$semprobas),]
  return(res)
}



sempreprocess<-function(){
  
  # load citation matrix
  load(paste0(Sys.getenv('CS_HOME'),'/PatentsMining/Data/processed/citation/network/adjacency.RData'))
  
  # preprocess adjacency for memory purposes
  for(year in wyears){
    load(paste0('probas/processed_counts_',(year-windowSize+1),"-",year,'.RData'));show(year)
    technoprobas=currentprobas$technoprobas;semprobas=currentprobas$semprobas;rm(currentprobas);gc()
    currentnames=intersect(rownames(technoprobas),rownames(citadjacency))
    namestoadd=setdiff(rownames(technoprobas),currentnames)
    currentadj = citadjacency[currentnames,currentnames]
    currentadj=rbind(currentadj,Matrix(0,length(namestoadd),ncol(currentadj)))
    rownames(currentadj)[(nrow(currentadj)-length(namestoadd)+1):nrow(currentadj)]=namestoadd
    currentadj=cbind(currentadj,Matrix(0,nrow(currentadj),length(namestoadd)))
    colnames(currentadj)[(ncol(currentadj)-length(namestoadd)+1):ncol(currentadj)]=namestoadd
    save(currentadj,file=paste0('probas/citadj_',(year-windowSize+1),"-",year,'.RData'))
    #sizes=append(sizes,sum(citadjacency[currentnames,currentnames]));cyears=append(cyears,year)
    #fromwindow=append(fromwindow,sum(citadjacency[currentnames,]))
    rm(technoprobas,semprobas,currentnames,currentadj);gc()
  }
  
}


##
#  Overlapping community modularity
#    implementing (Nicoasia et al., 2009)
#
#  simplified : linkfun = x1*x2, more efficient to compute ?
#  outer tensor product ? let do it dirtily with a loop
overlappingmodularity <- function(probas,adjacency){#,linkfun=function(p1,p2){return(p1*p2)}){
  show(paste0('Computing overlapping modularity : dim(probas)=',dim(probas)[1],' ',dim(probas)[2],' ; dim(adjacency)=',dim(adjacency)[1],' ',dim(adjacency)[2]))
  m = sum(adjacency)
  n=nrow(probas)
  kout=rowSums(adjacency)
  kin=colSums(adjacency)
  res=0
  for(c in 1:ncol(probas)){
    if(sum(probas[,c])>0){
      if(c%%100==0){show(c/ncol(probas))}
      a1 = Diagonal(x=probas[,c])%*%adjacency%*%Diagonal(x=probas[,c])
      a2 = sum(kout*probas[,c])*sum(kin*probas[,c])*((sum(probas[,c])/n)^2)/m
      res = res + sum(a1) - a2
      rm(a1);gc() # loose time to call gc at each step ?
    }
  }
  return(res/m)
}


##
# simple directed modularity
#
#  Test with probas = primtechnoprobas : membership = apply(probas,1,function(r){which(r>0)[1]})
#   NAs ?
directedmodularity<-function(membership,adjacency){
  # sum([A_ij - k_iout k_j in/m ]\delta (c_i,c_j))
  # 
  #deltac = sparseMatrix(1:nrow(adjacency),1:ncol(adjacency),x=0)
  #inds=c()
  #for(c in unique(membership)){inds = append(inds,which(membership==c))}
  m=sum(adjacency)
  kout=rowSums(adjacency);kin=colSums(adjacency)
  res = 0;k=length(unique(membership))
  for(c in unique(membership)){
    #if(c%%100==0){show(c/k)}
    inds=which(membership==c)
    res = res + sum(adjacency[inds,inds]) - sum(kin[inds])*sum(kout[inds])/m 
    gc()
  }
  return(res/m)
}

computemodularities<-function(currentprobas,currentadj){
  technoprobas=currentprobas$technoprobas;semprobas=currentprobas$semprobas;primtechnoprobas=currentprobas$primarytechnoprobas;
  
  res=list()
  # overlapping modularities
  res$technoovmod = overlappingmodularity(technoprobas,currentadj)
  res$semovmod = overlappingmodularity(semprobas,currentadj)
  
  # simple directed modularities
  primtechmembership = apply(primtechnoprobas,1,function(r){which(r>0)[1]})
  semmembership = apply(semprobas,1,function(r){which(r==max(r))[1]})
  res$technodirmod=directedmodularity(primtechmembership,currentadj)
  res$semdirmod=directedmodularity(semmembership,currentadj)
  
  # igraph computed measures
  symadj=(currentadj+t(currentadj))/2
  gsim = graph_from_adjacency_matrix(symadj,mode='undirected')
  g = graph_from_adjacency_matrix(currentadj,mode='directed')
  res$technodirgraphmod = modularity(g,primtechmembership)
  res$semdirgraphmod =  modularity(g,semmembership)
  res$technoundirgraphmod = modularity(gsim,primtechmembership)
  res$semundirgraphmod =  modularity(gsim,semmembership)
  gc();
  return(res)
}


#m = computemodularities(currentprobas,currentadj)


# test with igraph modularity


#m2 = overlappingmodularity(probas,adjacency)
# sem = 0.05267096 ; techno = 0.004932782 -- pb to have an order of magnitude ≠ ?
#  \sum_{edges} F(p_ic,p_jc) = ? -> normalisation ?

#m2004techno = overlappingmodularity(technoprobas,currentadj)
#m2004sem = overlappingmodularity(semprobas,currentadj)

# Q : comparability of modularity with different overlap patterns (strongly concentrated for techno vs more dispersed for semantic)

# TODO : compare with thresholded modularities -- for ≠ threshold values. Q : threshold on what ?


# c=1
# 
# for(c in 1:ncol(probas)){
# a = Diagonal(x=probas[,c])%*%adjacency%*%Diagonal(x=probas[,c])
# show(sum(a))
# # + sum_i (p_ic*k_i in)
# 
# 
# }





# import and saving as RData of yearly techno classes structures

library(Matrix)

#technolist = read.csv(paste0(Sys.getenv('CS_HOME'),'/PatentsMining/Data/processed/classes/class_CLEANED_20161114_2.csv'),header=TRUE,sep=',')
technolist = read.csv(paste0(Sys.getenv('CS_HOME'),'/PatentsMining/Data/processed/classes/class.csv'),header=TRUE,sep=',')


# get only primary classes ; remove subclass record
#technolistprim = technolist[technolist$Prim==1,1:3]
# remove duplicates
#technolistprim=unique(technolistprim)

getTechnoMatrix <- function(technolist,primary=FALSE){
  allpatents=as.character(unique(technolist$patent))
  inds = 1:length(allpatents)
  names(inds)<-allpatents
  rowinds=inds[as.character(technolist$patent)]
  primRows=(c(1,diff(rowinds)))>0
  allclasses = unique(as.character(technolist$class))
  if(primary==TRUE){
    rowinds=inds
    allclasses = unique(as.character(technolist$class[primRows]))
  }
  #allclasses = unique(as.character(technolist$class))
  inds =  1:length(allclasses)
  names(inds)<-allclasses
  colinds = inds[as.character(technolist$class)]
  if(primary==TRUE){
    colinds = inds[as.character(technolist$class[primRows])]
  }
  show(head(rowinds))
  show(head(colinds))
  technoMatrix = sparseMatrix(i = rowinds,j=colinds,x=rep(1,length(rowinds)))
  rownames(technoMatrix)<-allpatents
  colnames(technoMatrix)<-allclasses
  return(technoMatrix)
}

technoMatrix = getTechnoMatrix(technolist)
technoMatrixPrim = getTechnoMatrix(technolist,primary=TRUE)

# normalize to probas if not primary class only
technoMatrix = Diagonal(x=1/rowSums(technoMatrix))%*%technoMatrix
# prim
technoMatrixPrim[rowSums(technoMatrixPrim)>1,]<-t(apply(technoMatrixPrim[rowSums(technoMatrixPrim)>1,],1,function(r){i=which(r>0)[1];res=rep(0,length(r));res[i]=1;return(res)}))


# issue : patents with many Primary classes ?
# ex 06886596
#  -> corresponds to ≠ subclass records
#           Patent Prim Class SubClass
#12727491 06886596    1   137    62533
#13230050 06886596    1   137   625.33
#13230051 06886596    0   251      118
#
# still 1474 record with 2 classes 
#  ex 07554801
#          Patent Prim Class SubClass
#16071453 07554801    1   361      685
#16425985 07554801    1   439      680
#  :: ERROR in file
#  -> take first class only

#test=Diagonal(x=1/rowSums(technoMatrix))%*%technoMatrix
#prov = apply(t(technoMatrix),2,function(row){return(row/sum(row))})
#technoMatrix = t(apply(technoMatrix,1,function(row){return(row/sum(row))}))

rownames(technoMatrix)<-sapply(rownames(technoMatrix),function(s){ifelse(nchar(s)==8,substring(s,2),s)})
rownames(technoMatrixPrim)<-sapply(rownames(technoMatrixPrim),function(s){ifelse(nchar(s)==8,substring(s,2),s)})

save(technoMatrix,file=paste0(Sys.getenv('CS_HOME'),'/PatentsMining/Data/processed/classes/techno_sparse.RData'))
save(technoMatrixPrim,file=paste0(Sys.getenv('CS_HOME'),'/PatentsMining/Data/processed/classes/techno_sparse_primary.RData'))

  
  
  

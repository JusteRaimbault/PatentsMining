
# import and saving as RData of yearly techno classes structures

setwd(paste0(Sys.getenv('CS_HOME'),'/PatentsMining/Models/Techno/TechnoClasses/res/technoPerYear'))

library(Matrix)

# years = 1976:2012
# 
# sizeTh = 10
# 
# for(year in years){
#   show(year)
#   d = read.table(file=paste0('technoProbas_',year,'_sizeTh',sizeTh),sep=";",row.names = 1,header=TRUE)
#   #d[is.na(d)]=0
#   m = Matrix(as.matrix(d),sparse=TRUE)
#   save(m,file=paste0(Sys.getenv('CS_HOME'),'/PatentsMining/Data/processed/classes/technoPerYear/technoProbas_',year,'_sizeTh',sizeTh,'.RData'))
# }

technolist = read.csv(paste0(Sys.getenv('CS_HOME'),'/PatentsMining/Data/raw/classesTechno/class.csv'),header=TRUE,sep=',')#,nrows = 1000)
#full=read.csv(paste0(Sys.getenv('CS_HOME'),'/PatentsMining/Data/raw/classesTechno/class.csv'),header=TRUE,sep=',')

primary = TRUE


if(primary){
  # get only primary classes ; remove subclass record
  technolist = technolist[technolist$Prim==1,1:3]
  # remove duplicates
  #dim(unique(technolist))
  technolist=unique(technolist)
}

allpatents=as.character(unique(technolist$Patent))
inds = 1:length(allpatents)
names(inds)<-allpatents
rowinds=inds[as.character(technolist$Patent)]
#rowinds2 = cumsum(c(1,as.integer(technolist$Patent[1:(nrow(technolist)-1)]!=technolist$Patent[2:nrow(technolist)])))
#data.frame(unique(rowinds),unique(technolist$Patent))
#length(as.character(unique(technolist$Patent)))
allclasses = unique(as.character(technolist$Class))
inds =  1:length(allclasses)
names(inds)<-allclasses
colinds = inds[as.character(technolist$Class)]#sapply(technolist$Class,function(s){which(allclasses==s)})

technoMatrix = sparseMatrix(i = rowinds,j=colinds,x=rep(1,length(rowinds)))
rownames(technoMatrix)<-allpatents
colnames(technoMatrix)<-allclasses

if(!primary){
  # normalize to probas if not primary class only
  technoMatrix = Diagonal(x=1/rowSums(technoMatrix))%*%technoMatrix
}else{
  technoMatrix[rowSums(technoMatrix)>1,]<-t(apply(technoMatrix[rowSums(technoMatrix)>1,],1,function(r){i=which(r>0)[1];res=rep(0,length(r));res[i]=1;return(res)}))
}

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

if(!primary){
  save(technoMatrix,file=paste0(Sys.getenv('CS_HOME'),'/PatentsMining/Data/processed/classes/sparse.RData'))
}else{
  save(technoMatrix,file=paste0(Sys.getenv('CS_HOME'),'/PatentsMining/Data/processed/classes/techno_primary.RData'))
}
  
  
  
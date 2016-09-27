
############
#  Analysis of semantic communities
############

setwd(paste0(Sys.getenv('CS_HOME'),'/PatentsMining/Models/Semantic'))

years = 1980:2012
windowSize=5

#kmin = 0;freqmin = 50;edge_th = 50;kmaxdec=0.25;freqmaxdec=0.25
#semprefix = paste0('_full_100000_kmin',kmin,'_kmaxdec',kmaxdec,'_freqmin',freqmin,'_freqmaxdec',freqmaxdec,'_eth',edge_th,'.RData')
semsuffix='_kwLimit100000_dispth0.06_ethunit4.5e-05.csv'

technoprefix=paste0(Sys.getenv('CS_HOME'),'/PatentsMining/Data/processed/classes/technoPerYear/technoProbas_')
#sizeTh=10
# TODO : recompute techno probas on moving window ?
# or better : single matrix with all patents ; gets corresponding rows with semantic rownames
#  -> check rowname indexing perfs

# load techno probas
load(file=paste0(Sys.getenv('CS_HOME'),'/PatentsMining/Data/processed/classes/sparse.RData'))

loadSemantic<-function(year){
   show(paste0('loading year : ',year))
    yearrange=paste0((year-windowSize+1),"-",year)
    entrylist = read.csv(file=paste0('probas/probas_',yearrange,semsuffix),sep=";",header=FALSE)
    rowinds = cumsum(c(1,as.integer(entrylist[1:(nrow(entrylist)-1),1]!=entrylist[2:nrow(entrylist),1])))
    res = sparseMatrix(i=rowinds,j=entrylist[,2]+1,x=entrylist[,3])
    rownames(res)<-unique(as.character(entrylist[,1]))
   return(res)
}



# loadTechno<-function(year){
#   techno=Matrix();colnames(techno)<-c()
#  for(yy in (year-windowSize+1):year){
#   load(paste0(technoprefix,year,'_sizeTh',sizeTh,'.RData'))
#   rownames(m)<-sapply(rownames(m),function(s){ifelse(nchar(s)==8,substring(s,2),s)})
#   newcols=setdiff(colnames(techno),colnames(m))
#  techno=rbind(techno,m)
# }
#   return(m)
# }
#test = loadTechno(1980)

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

# data conversion
# for(year in years){
#   load(paste0(technoprefix,year,'_sizeTh',sizeTh,'.RData'))
#   save(m,file=paste0(technoprefix,year,'_sizeTh',sizeTh,'_uncompressed.RData'),compress=FALSE)
# }

# first load all probas
#probas=list()
for(year in years){
  currentprobas=loadProbas(year)
  save(currentprobas,file=paste0('probas/processed_',year,'.RData'))
  rm(currentprobas)
}


####
kwex <- as.tbl(read.csv("keywords/keywords_2000-2004_kwLimit100000_dispth0.06_ethunit4.5e-05.csv",sep=";",header=FALSE))

kwex %>% group_by(V2)
data.frame(kwex[kwex$V2==156,1],stringsAsFactors = FALSE)




##
#  1) First order interdisciplinarity

#  1.1) Macro-level

techoverlaps = c();semoverlaps = c()
techyears=c();semyears=c()
for(year in years){
  load(paste0('probas/processed_',year,'.RData'))
  technoprobas=currentprobas$technoprobas;semprobas=currentprobas$semprobas;rm(currentprobas);gc()
  inds = which(colSums(technoprobas)>50)
  currenttechovs = rep(0,ncol(technoprobas)*(ncol(technoprobas)-1)/2)
  currentsemovs = rep(0,ncol(semprobas)*(ncol(semprobas)-1)/2)
  k=1
  for(i in 1:(length(inds)-1)){show(i);for(j in (i+1):length(inds)){
    currenttechovs=append(currenttechovs,sum(technoprobas[,inds[i]]*technoprobas[,inds[j]])/nrow(technoprobas))
  }}
  for(i in 1:(ncol(semprobas)-1)){show(i);for(j in (i+1):ncol(semprobas)){
    currentsemovs=append(currentsemovs,sum(semprobas[,i]*semprobas[,j])/nrow(semprobas));
  }}
  techoverlaps=append(techoverlaps,currenttechovs);semoverlaps=append(semoverlaps,currentsemovs)
  techyears=append(techyears,rep(year,length(currenttechovs)));semyears=append(semyears,rep(year,length(currentsemovs)))
}

#save(overlaps,cyears,file='res/techno_overlaps.RData')
#load(file='res/techno_overlaps.RData')
load(file='res/classes_overlaps.RData')
techoverlaps=unlist(lapply(res,function(l){l$techov}))
techyears=unlist(lapply(res,function(l){l$techyear}))
semoverlaps=unlist(lapply(res,function(l){l$semov}))
semyears=unlist(lapply(res,function(l){l$semyear}))

# Techno
inds=techoverlaps>0#1:length(overlaps)#
#overlaps[overlaps==0]=1e-10
# distribution of overlaps 
g=ggplot(data.frame(overlap=techoverlaps[inds],year=techyears[inds]),aes(x=overlap,colour=as.character(year)))#aes(x=year,y=overlap))
g+geom_density(alpha=0.25)+scale_x_log10()+xlab("techno overlap")+ylab("density")#+scale_y_log10()
# variation in time
g=ggplot(data.frame(overlap=techoverlaps[inds],year=techyears[inds]),aes(x=year,y=overlap))
g+geom_point(pch='.')+scale_y_log10()+stat_smooth()

# Semantic
inds=semoverlaps>0
# distribution of overlaps 
g=ggplot(data.frame(overlap=semoverlaps[inds],year=semyears[inds]),aes(x=overlap,colour=as.character(year)))#aes(x=year,y=overlap))
g+geom_density(alpha=0.25)+scale_x_log10()+xlab("sem overlap")+ylab("density")#+scale_y_log10()
# variation in time
g=ggplot(data.frame(overlap=semoverlaps[inds],year=semyears[inds]),aes(x=year,y=overlap))
g+geom_point(pch='.')+scale_y_log10()+stat_smooth()





##################
# 1.2) Micro-level : patent level interdisciplinarity

origs=c();cyears=c();types=c();
for(year in years){
  show(year)
  load(paste0('probas_processed/processed_',year,'.RData'))
  technoprobas=currentprobas$technoprobas;semprobas=currentprobas$semprobas;rm(currentprobas);gc()
  origs = append(origs,1 - rowSums(semprobas^2));types=append(types,rep("semantic",nrow(semprobas)))
  origs = append(origs,1 - rowSums(technoprobas^2));types=append(types,rep("techno",nrow(technoprobas)))
  cyears=append(cyears,rep(year,nrow(semprobas)+nrow(technoprobas)))
}

#save(origs,cyears,types,file='res/patentlevel_orig.RData')
load('res/patentlevel_origs.RData')

# techno patent origs
inds=types=="techno"&origs<1
df = data.frame(originality=origs[inds],year=as.character(cyears[inds]),type=types[inds])
g=ggplot(df)
g+geom_density(aes(x=originality,colour=year))

# semantic patent origs
inds=types=="semantic"&origs<1
df = data.frame(originality=origs[inds],year=as.character(cyears[inds]),type=types[inds])
g=ggplot(df)
g+geom_density(aes(x=originality,colour=year))+scale_y_log10()



##
#  2) Layers macro-structure comparison

overlaps=c();cyears=c()
for(year in years){
  res = loadProbas(year);technoprobas=res$technoprobas;semprobas=res$semprobas
  # all couples (i\in sem, j\in techno)
  inds = which(colSums(technoprobas)>100)
  currentovs = rep(0,ncol(technoprobas)*ncol(semprobas))
  k=1
  for(i in 1:ncol(semprobas)){show(i);for(j in inds){
    currentovs[k]=sum(semprobas[,i]*technoprobas[,j])/nrow(technoprobas);k=k+1
  }}
  overlaps=append(overlaps,currentovs)
  cyears=append(cyears,rep(year,ncol(technoprobas)*ncol(semprobas)))
}

#
load('res/inter_overlaps.RData')
overlaps=unlist(lapply(res,function(l){l$overlap}))
cyears=unlist(lapply(res,function(l){l$year}))

inds=overlaps>0
#overlaps[overlaps==0]=1e-10
g=ggplot(data.frame(overlaps=overlaps[inds],cyears=as.character(cyears[inds])))#,aes(x=cyears,y=overlaps))
g+geom_density(aes(x=overlaps,colour=cyears),alpha=0.25,adjust=0.75)+scale_x_log10()+xlab("overlap")+ylab("density")#+scale_y_log10()


g=ggplot(data.frame(overlaps=overlaps[inds],cyears=as.character(cyears[inds])),aes(x=cyears,y=overlaps))
g+geom_point(pch='.')+scale_y_log10()+stat_smooth()




##
#  3) Second order interdisciplinarity (citation)

# load citation matrix
load(paste0(Sys.getenv('CS_HOME'),'/PatentsMining/Data/processed/citation/network/adjacency.RData'))

# 3.1) Patent level

origs=c();cyears=c();types=c();
for(year in years){
  res = probas[[year]];
  technoprobas=Matrix(as.matrix(res$technoprobas));semprobas=Matrix(as.matrix(res$semprobas))
  currentnames=intersect(rownames(technoprobas),rownames(citadjacency))
  currentadj = citadjacency[currentnames,currentnames]
  currentadj = diag(rowSums(currentadj))%*%currentadj
  technocit = currentadj%*%technoprobas[currentnames,]
  semcit = currentadj%*%semprobas[currentnames,]
  origs = append(origs,1 - rowSums(technocit^2));types=append(types,rep("techno",nrow(technocit)))
  origs = append(origs,1 - rowSums(semcit^2));types=append(types,rep("semantic",nrow(semcit)))
  cyears=append(cyears,rep(year,nrow(technocit)+nrow(semcit)))
}

#
g=ggplot(data.frame(originality=origs[types=="techno"],year=as.character(cyears[types=="techno"])))
g+geom_density(aes(x=originality,colour=year))


g=ggplot(data.frame(originality=origs[types=="semantic"],year=as.character(cyears[types=="semantic"])))
g+geom_density(aes(x=originality,colour=year))


# 3.2) class level

origs=c();cyears=c();types=c();
for(year in years){
  res = loadProbas(year);technoprobas=res$technoprobas;semprobas=res$semprobas
  currentadj = adjacency[rownames(technoprobas),rownames(technoprobas)]
  currentadj = diag(rowSums(currentadj))%*%currentadj
  technocit = t(technoprobas)%*%(currentadj%*%technoprobas)
  semcit = t(semprobas)%*%(currentadj%*%semprobas)
  origs = append(origs,1 - rowSums(technocit^2));types=append(types,rep("techno",nrow(technocit)))
  origs = append(origs,1 - rowSums(semcit^2));types=append(types,rep("semantic",nrow(semcit)))
  cyears=append(cyears,rep(year,nrow(technocit)+nrow(semcit)))
}

inds=1:length(origs)#overlaps>0
origs[origs==0]=1e-10
g=ggplot(data.frame(origs=origs[inds],years=cyears[inds]),aes(x=years,y=origs))
g+geom_density(aes(x=origs,colour=years),alpha=0.25,adjust=0.75)+scale_x_log10()+xlab("origs")+ylab("density")#+scale_y_log10()
#g+geom_point(pch='.')+scale_y_log10()+stat_smooth()




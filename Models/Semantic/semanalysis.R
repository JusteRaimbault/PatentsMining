
############
#  Analysis of semantic communities
############

setwd(paste0(Sys.getenv('CS_HOME'),'/PatentsMining/Models/Semantic'))

years = 1976:2012

kmin = 0;freqmin = 50;edge_th = 50;kmaxdec=0.25;freqmaxdec=0.25
sizeTh=10
semprefix = paste0('_full_100000_kmin',kmin,'_kmaxdec',kmaxdec,'_freqmin',freqmin,'_freqmaxdec',freqmaxdec,'_eth',edge_th,'.RData')
technoprefix=paste0(Sys.getenv('CS_HOME'),'/PatentsMining/Data/processed/classes/technoPerYear/technoProbas_')

loadProbas<-function(year){
  show(year)
  res=list()
  load(paste0('probas/relevant_',year,semprefix))
  res$semprobas=probas[,3:ncol(probas)]
  load(paste0(technoprefix,year,'_sizeTh',sizeTh,'.RData'))
  rownames(m)<-sapply(rownames(m),function(s){ifelse(nchar(s)==8,substring(s,2),s)})
  rowstoadd=setdiff(rownames(res$semprobas),rownames(m))
  m=rbind(m,matrix(0,length(rowstoadd),ncol(m)));rownames(m)[(nrow(m)-length(rowstoadd)+1):nrow(m)]=rowstoadd
  res$technoprobas = m[rownames(res$semprobas),]
  return(res)
}


# for(year in years){
#   load(paste0(technoprefix,year,'_sizeTh',sizeTh,'.RData'))
#   save(m,file=paste0(technoprefix,year,'_sizeTh',sizeTh,'_uncompressed.RData'),compress=FALSE)
# }

##
#  1) First order interdisciplinarity

#  1.1) Macro-level

overlaps = c();cyears=c()
for(year in years){
  res = loadProbas(year);technoprobas=res$technoprobas;semprobas=res$semprobas
  inds = which(colSums(technoprobas)>50)
  #currentovs = rep(0,ncol(technoprobas)*(ncol(technoprobas)-1)/2)
  currentovs = rep(0,ncol(semprobas)*(ncol(semprobas)-1)/2)
  k=1
  #for(i in 1:(length(inds)-1)){show(i);for(j in (i+1):length(inds)){
  #  currentovs[k]=sum(technoprobas[,inds[i]]*technoprobas[,inds[j]])/nrow(technoprobas);k=k+1
  #}}
  for(i in 1:(ncol(semprobas)-1)){show(i);for(j in (i+1):ncol(semprobas)){
    currentovs=append(currentovs,sum(semprobas[,i]*semprobas[,j])/nrow(semprobas));
  }}
  overlaps=append(overlaps,currentovs)
  cyears=append(cyears,rep(year,length(currentovs)))
}

#save(overlaps,cyears,file='res/techno_overlaps.RData')
load(file='res/techno_overlaps.RData')

inds=overlaps>0#1:length(overlaps)#
#overlaps[overlaps==0]=1e-10
g=ggplot(data.frame(overlap=overlaps[inds],year=cyears[inds]),aes(x=overlap,colour=as.character(year)))#aes(x=year,y=overlap))
g+geom_density(alpha=0.25)+scale_x_log10()+xlab("overlap")+ylab("density")#+scale_y_log10()
g+geom_point(pch='.')+scale_y_log10()+stat_smooth()


# 1.2) Micro-level : patent level interdisciplinarity

origs=c();cyears=c();types=c();
for(year in years){
  res = loadProbas(year);technoprobas=res$technoprobas;semprobas=res$semprobas
  origs = append(origs,1 - rowSums(semprobas^2));types=append(types,rep("semantic",nrow(semprobas)))
  origs = append(origs,1 - rowSums(technoprobas^2));types=append(types,rep("techno",nrow(technoprobas)))
  cyears=append(cyears,rep(year,nrow(semprobas)+nrow(technoprobas)))
}

df = data.frame(originality=origs[types=="techno"],year=as.character(cyears[types=="techno"]),type=types[types=="techno"])
g=ggplot(df)
g+geom_density(aes(x=originality,colour=year))


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

inds=overlaps>0
#overlaps[overlaps==0]=1e-10
g=ggplot(data.frame(overlaps=overlaps[inds],cyears=as.character(cyears[inds])))#,aes(x=cyears,y=overlaps))
g+geom_density(aes(x=overlaps,colour=cyears),alpha=0.25,adjust=0.75)+scale_x_log10()+xlab("overlap")+ylab("density")#+scale_y_log10()
#g+geom_point(pch='.')+scale_y_log10()+stat_smooth()




##
#  3) Second order interdisciplinarity (citation)

# load citation matrix
load(paste0(Sys.getenv('CS_HOME'),'/PatentsMining/Data/processed/citation/network/adjacency.RData'))

# 3.1) Patent level

origs=c();cyears=c();types=c();
for(year in years){
  res = loadProbas(year);technoprobas=Matrix(as.matrix(res$technoprobas));semprobas=Matrix(as.matrix(res$semprobas))
  currentnames=intersect(rownames(technoprobas),rownames(citadjacency))
  currentadj = citadjacency[currentnames,currentnames]
  currentadj = diag(rowSums(currentadj))%*%currentadj
  technocit = currentadj%*%technoprobas[currentnames,]
  semcit = currentadj%*%semprobas[currentnames,]
  origs = append(origs,1 - rowSums(technocit^2));types=append(types,rep("techno",nrow(technocit)))
  origs = append(origs,1 - rowSums(semcit^2));types=append(types,rep("semantic",nrow(semcit)))
  cyears=append(cyears,rep(year,nrow(technocit)+nrow(semcit)))
}

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




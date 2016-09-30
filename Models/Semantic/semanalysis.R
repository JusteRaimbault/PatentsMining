
############
#  Analysis of semantic communities
############

library(Matrix)
library(ggplot2)
library(dplyr)

setwd(paste0(Sys.getenv('CS_HOME'),'/PatentsMining/Models/Semantic'))

wyears = 1980:2012
windowSize=5

source('semanalfun.R')








# data conversion
# for(year in years){
#   load(paste0(technoprefix,year,'_sizeTh',sizeTh,'.RData'))
#   save(m,file=paste0(technoprefix,year,'_sizeTh',sizeTh,'_uncompressed.RData'),compress=FALSE)
# }

# first load all probas
#probas=list()
for(year in years){
  currentprobas=loadProbas(year)
  yearrange=paste0((year-windowSize+1),"-",year)
  save(currentprobas,file=paste0('probas/processed_counts_',yearrange,'.RData'))
  rm(currentprobas)
}
gc()

#######
## kw examples
kwex <- as.tbl(read.csv("keywords/keywords_2000-2004_kwLimit100000_dispth0.06_ethunit4.5e-05.csv",sep=";",header=FALSE))

kwex %>% group_by(V2)
data.frame(kwex[kwex$V2==156,1],stringsAsFactors = FALSE)


#######
## patent example
# year : 2004 ; semantic class : 5 ("optic")
year=1980;yearrange=paste0((year-windowSize+1),"-",year)
load(file=paste0('probas_processed/processed_',yearrange,'.RData'))
technoprobas=currentprobas$technoprobas;semprobas=currentprobas$semprobas;rm(currentprobas);gc()

#techov=t(technoprobas)%*%technoprobas
#diag(techov)<-0
#hist(log(techov[techov>0]),breaks=10000)

# beware : class 5 is index 6 (classes begin at 0 !)
rownames(semprobas)[which(semprobas[,6]==max(semprobas[,6]))]

origs=1 - rowSums(semprobas^2)
difcols = rowSums(semprobas>0)
inds = which(semprobas[,6]>0.2&difcols>2&rowSums(semprobas)>0.5)
origs[inds]
as.matrix(semprobas[inds,])
# 8243175
# best orig 0.744 - but single class.
#inds = which(semprobas[,6]>0.5&origs>0.744)
# 7534052 ? NO 

##
#  1) First order interdisciplinarity

#  1.1) Macro-level

# 
# techoverlaps = c();semoverlaps = c()
# techyears=c();semyears=c()
# for(year in years){
#   load(paste0('probas/processed_',(year-windowSize+1),"-",year,'.RData'))
#   technoprobas=currentprobas$technoprobas;semprobas=currentprobas$semprobas;rm(currentprobas);gc()
#   inds = which(colSums(technoprobas)>50)
#   currenttechovs = rep(0,ncol(technoprobas)*(ncol(technoprobas)-1)/2)
#   currentsemovs = rep(0,ncol(semprobas)*(ncol(semprobas)-1)/2)
#   k=1
#   for(i in 1:(length(inds)-1)){show(i);for(j in (i+1):length(inds)){
#     currenttechovs=append(currenttechovs,sum(technoprobas[,inds[i]]*technoprobas[,inds[j]])/nrow(technoprobas))
#   }}
#   for(i in 1:(ncol(semprobas)-1)){show(i);for(j in (i+1):ncol(semprobas)){
#     currentsemovs=append(currentsemovs,sum(semprobas[,i]*semprobas[,j])/nrow(semprobas));
#   }}
#   techoverlaps=append(techoverlaps,currenttechovs);semoverlaps=append(semoverlaps,currentsemovs)
#   techyears=append(techyears,rep(year,length(currenttechovs)));semyears=append(semyears,rep(year,length(currentsemovs)))
# }



overlaps = c();years=c();measures=c();types=c();filters=c();nullovs=c();classnum=c();pcount=c();gc()
ovsize=c()
for(year in wyears){
  load(paste0('probas_processed/processed_',(year-windowSize+1),"-",year,'.RData'));show(year)
  technoprobas=currentprobas$technoprobas;semprobas=currentprobas$semprobas;rm(currentprobas);gc()
  techov=t(technoprobas)%*%technoprobas;
  diag(techov)<-0
  semov=t(semprobas)%*%semprobas;
  diag(semov)<-0
  #nullovs=append(nullovs,length(which(techov==0)));nullovs=append(nullovs,length(which(semov==0)))
  #ovsize=append(ovsize,c(sum(techov),sum(semov)))
  #types=append(types,c("techno","semantic"));years=append(years,c(year,year))
  #classnum=append(classnum,ncol(techov));classnum=append(classnum,ncol(semov))
  #pcount=append(pcount,c(nrow(semprobas),nrow(semprobas)))
  
  # NON NORMALIZED
  #overlaps=append(overlaps,as.numeric(techov));n=length(as.numeric(techov));years=append(years,rep(year,n));types=append(types,rep("techno",n))#;measures=append(measures,rep("real",n));filters=append(filters,rep("all",n))
  #overlaps=append(overlaps,as.numeric(semov));n=length(as.numeric(semov));years=append(years,rep(year,n));types=append(types,rep("semantic",n))#;measures=append(measures,rep("real",n));filters=append(filters,rep("all",n))
  #inds=which(techov>0);overlaps=append(overlaps,techov[inds]);n=length(inds);years=append(years,rep(year,n));types=append(types,rep("techno",n))#;measures=append(measures,rep("real",n));filters=append(filters,rep("positive",n))
  #inds=which(semov>0);overlaps=append(overlaps,semov[inds]);n=length(inds);years=append(years,rep(year,n));types=append(types,rep("semantic",n))#;measures=append(measures,rep("real",n));filters=append(filters,rep("positive",n))
  # # NORMALIZED PATENT COUNT
  #overlaps=append(overlaps,as.numeric(techov)/nrow(technoprobas));n=length(as.numeric(techov));years=append(years,rep(year,n));types=append(types,rep("techno",n));#measures=append(measures,rep("norm-patents",n));filters=append(filters,rep("all",n))
  #overlaps=append(overlaps,as.numeric(semov)/nrow(semprobas));n=length(as.numeric(semov));years=append(years,rep(year,n));types=append(types,rep("semantic",n));#measures=append(measures,rep("norm-patents",n));filters=append(filters,rep("all",n))
  #inds=which(techov>0);overlaps=append(overlaps,techov[inds]/nrow(technoprobas));n=length(inds);years=append(years,rep(year,n));types=append(types,rep("techno",n));#measures=append(measures,rep("norm-patents",n));filters=append(filters,rep("positive",n))
  #inds=which(semov>0);overlaps=append(overlaps,semov[inds]/nrow(semprobas));n=length(inds);years=append(years,rep(year,n));types=append(types,rep("semantic",n));#measures=append(measures,rep("norm-patents",n));filters=append(filters,rep("positive",n))
  # # RELATIVE OVERLAP
   #technorm=Matrix(1,nrow(techov),ncol(techov))%*%Diagonal(x=colSums(technoprobas));
   #semnorm=Matrix(1,nrow(semov),ncol(semov))%*%Diagonal(x=colSums(semprobas));
   #techov=techov*2/(technorm+t(technorm))
   #semov=semov*2/(semnorm+t(semnorm))
   #overlaps=append(overlaps,as.numeric(techov));n=length(as.numeric(techov));years=append(years,rep(year,n));types=append(types,rep("techno",n));#measures=append(measures,rep("relative",n));filters=append(filters,rep("all",n))
   #overlaps=append(overlaps,as.numeric(semov));n=length(as.numeric(semov));years=append(years,rep(year,n));types=append(types,rep("semantic",n));#measures=append(measures,rep("relative",n));filters=append(filters,rep("all",n))
   #inds=which(techov>0);overlaps=append(overlaps,techov[inds]/nrow(technoprobas));n=length(inds);years=append(years,rep(year,n));types=append(types,rep("techno",n));#measures=append(measures,rep("relative",n));filters=append(filters,rep("positive",n))
   #inds=which(semov>0);overlaps=append(overlaps,semov[inds]/nrow(semprobas));n=length(inds);years=append(years,rep(year,n));types=append(types,rep("semantic",n));#measures=append(measures,rep("relative",n));filters=append(filters,rep("positive",n))
   rm(techov,semov,technorm,semnorm,technoprobas,semprobas);gc()
}

resdir=paste0(Sys.getenv('CS_HOME'),'/PatentsMining/Results/Semantic/Analysis/window5/overlap/')
df=data.frame(overlap=overlaps,year=as.character(years),type=types)#,measure=measures,filter=filters)
#save(df,file="res/full-overlaps.RData")
#load("res/full-overlaps.RData")

#for(filter in c("all","positive")){
#  for(measure in c("real","norm-patents","relative")){
   filter="positive";measure="relative overlap"
   g=ggplot(df,aes(x=overlap,colour=year))#df[df$filter==filter&df$measure==measure,])
    g+geom_density(alpha=0.25)+xlab(measure)+ylab("density")+facet_wrap(~type,scales="free_y")+scale_x_log10()
    #ggsave(filename = paste0(resdir,measure,"_",filter,"_density.pdf"),width=16,height=10,unit="cm")
    dsum = df%>% group_by(year,type) %>% summarise(meanoverlap=mean(overlap),mi=quantile(overlap,0.1),ma=quantile(overlap,0.9))
    gsum=ggplot(dsum,aes(x=year,y=meanoverlap,colour=type,group=type),show.legend = FALSE)
    labs=rep("",length(wyears));labs[seq(from=1,to=length(labs),by=3)]=as.character(wyears[seq(from=1,to=length(labs),by=3)])
    gsum+geom_point()+geom_line()+#geom_errorbar(aes(ymin=mi,ymax=ma))+
      facet_wrap(~type,scales ="free_y")+
      scale_x_discrete(breaks=as.character(wyears),labels=labs)#+scale_y_log10()
    #ggsave(filename = paste0(resdir,measure,"_",filter,"_ts.pdf"))
    #rm(g,gsum);gc()
#   }
#}

labs=rep("",length(wyears));labs[seq(from=1,to=length(labs),by=3)]=as.character(wyears[seq(from=1,to=length(labs),by=3)])
g=ggplot(data.frame(empty=ovsize/(pcount*(classnum*classnum/(classnum[1]*classnum[1]))),year=years,type=types,classes=classnum,pcount=pcount))
g+geom_point(aes(x=year,y=empty,colour=type))+geom_line(aes(x=year,y=empty,colour=type))+ facet_wrap(~type,scales ="free_y")+
  geom_line(aes(x=year,y=(pcount - min(pcount))/(max(pcount)-min(pcount))),color='purple',linetype=2)
  #scale_x_discrete(breaks=as.character(wyears),labels=labs)
g+geom_point(aes(x=pcount,y=empty,colour=year,shape=type))+ facet_wrap(~type,scales ="free")
    
# Techno
inds=1:length(technoverlaps)#
#overlaps[overlaps==0]=1e-10
# distribution of overlaps 
g=ggplot(data.frame(overlap=technoverlaps[inds],year=as.character(techyears[inds])),aes(x=overlap,colour=year))#aes(x=year,y=overlap))
g+geom_density(alpha=0.25)+scale_x_log10()+xlab("techno overlap normalized by patent count")+ylab("density")#+scale_y_log10()
# variation in time
g=ggplot(data.frame(overlap=technoverlaps[inds],year=techyears[inds]),aes(x=year,y=overlap))
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
inds=origs<1
df = data.frame(originality=origs[inds],year=as.character(cyears[inds]),type=types[inds])
gc()
g=ggplot(df)
g+geom_density(aes(x=originality,colour=year))+scale_y_log10()

byyearorigs = as.tbl(df) %>% group_by(year,type) %>% summarize(meanorig=mean(originality),count=n())
gsum=ggplot(byyearorigs)
labs=rep("",length(years));labs[seq(from=1,to=length(labs),by=3)]=as.character(years[seq(from=1,to=length(labs),by=3)])
gsum+geom_point(aes(x=year,y=meanorig,colour=type),show.legend = FALSE)+facet_wrap(~type,scales ="free_y",)+
  scale_x_discrete(breaks=as.character(years),labels=labs)

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
  load(paste0('probas_processed/processed_',(year-windowSize+1),"-",year,'.RData'));show(year)
  technoprobas=currentprobas$technoprobas;semprobas=currentprobas$semprobas;rm(currentprobas);gc()
  currentnames=intersect(rownames(technoprobas),rownames(citadjacency))
  currentadj = citadjacency[currentnames,currentnames]
  currentadj = Diagonal(x=rowSums(currentadj))%*%currentadj
  technocit = currentadj%*%technoprobas[currentnames,]
  semcit = currentadj%*%semprobas[currentnames,]
  origs = append(origs,1 - rowSums(technocit^2));types=append(types,rep("techno",nrow(technocit)))
  origs = append(origs,1 - rowSums(semcit^2));types=append(types,rep("semantic",nrow(semcit)))
  cyears=append(cyears,rep(year,nrow(technocit)+nrow(semcit)))
}

#
g=ggplot(data.frame(originality=origs[types=="techno"],year=as.character(cyears[types=="techno"])))
g+geom_density(aes(x=originality,colour=year))#+facet_wrap(~type)


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




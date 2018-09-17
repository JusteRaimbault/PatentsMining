
############
#  Analysis of semantic communities
############

library(Matrix)
library(ggplot2)
library(dplyr)
library(reshape2)

setwd(paste0(Sys.getenv('CS_HOME'),'/PatentsMining/Models/Semantic'))

#wyears = 1980:2012
wyears = 1980:2007
windowSize=5
kwLimit="100000"
dispth=0.06
ethunit="4.1e-05"

classifdir = paste0('classification_window',windowSize,'_kwLimit',kwLimit,'_dispth',dispth,'_ethunit',ethunit)


# data preprocessing -> preProcessData in semanalfun.R

source('semanalfun.R')

#######
## kw examples
year=2001;yearrange=paste0((year-windowSize+1),"-",year)
kwex <- as.tbl(read.csv(paste0("probas_count_extended/keywords-count-extended_",yearrange,"_kwLimit",kwLimit,"_dispth0.06_ethunit4.5e-05.csv"),sep=";",header=TRUE,stringsAsFactors=FALSE))

sizes = kwex %>% group_by(V2) %>% summarise(count=n())
data.frame(kwex[kwex$V2==156,1],stringsAsFactors = FALSE)


#######
## patent example
# year : 2004 ; semantic class : 5 ("optic")

for(year in wyears){
  #year=1980;
  yearrange=paste0((year-windowSize+1),"-",year)
load(file=paste0('probas/processed_',yearrange,'.RData'))
technoprobas=currentprobas$technoprobas;semprobas=currentprobas$semprobas;rm(currentprobas);gc()
show(sum(semprobas)/nrow(semprobas))
show(sum(technoprobas)/nrow(technoprobas))
}
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

#
#  1) First order interdisciplinarity

#  1.1) Macro-level

###############
# size hierarchy in years
#
#   (FIG. 4)

sizes=c();nsizes=c();years=c();type=c();ranks=c();sortedsizes=c();sortednsizes=c()
for(year in wyears){
  load(paste0('processed/',classifdir,'/processed_',(year-windowSize+1),"-",year,'.RData'));show(year)
  technoprobas=currentprobas$technoprobas;semprobas=currentprobas$semprobas;rm(currentprobas);gc()
  techsizes=colSums(technoprobas);semsizes=colSums(semprobas)
  techsizes=techsizes[techsizes>0];semsizes=semsizes[semsizes>0]
  sizes=append(sizes,sort(techsizes,decreasing=TRUE));
  years=append(years,rep(year,length(techsizes)));ranks=append(ranks,1:length(techsizes));
  type=append(type,rep("technological classes",length(techsizes)))
  sizes=append(sizes,sort(semsizes,decreasing=TRUE));
  years=append(years,rep(year,length(semsizes)));ranks=append(ranks,1:length(semsizes));
  type=append(type,rep("semantic classes",length(semsizes)))
  
  #nsizes=append(nsizes,techsizes/nrow(technoprobas));;type=append(type,rep("techno",length(techsizes)));
  #ranks=append(ranks,1:length(techsizes));sortedsizes=append(sortedsizes,sort(techsizes,decreasing = TRUE));sortednsizes=append(sortednsizes,sort(techsizes/nrow(technoprobas),decreasing = TRUE))
  #sizes=append(sizes,semsizes);nsizes=append(nsizes,semsizes/nrow(semprobas));years=append(years,rep(year,length(semsizes)));type=append(type,rep("semantic",length(semsizes)))
  #ranks=append(ranks,1:length(semsizes));sortedsizes=append(sortedsizes,sort(semsizes,decreasing = TRUE));sortednsizes=append(sortednsizes,sort(semsizes/nrow(semprobas),decreasing = TRUE))
}

#save(sizes,years,type,ranks,file='figdata/fig4.RData')
#load('figdata/fig4.RData')

## rank size plot 

g=ggplot(data.frame(size=sizes,year=as.character(years),rank=ranks,type=type))
g+geom_line(aes(x=rank,y=size,colour=year,group=year))+
  scale_x_log10()+scale_y_log10()+facet_wrap(~type,scales="fixed")+ylab("size") + theme(axis.title = element_text(size = 22), 
    axis.text.x = element_text(size = 15),axis.text.y = element_text(size = 15),
    strip.text = element_text(size=15),
    legend.text=element_text(size=15), legend.title=element_text(size=15))
ggsave(file=paste0(Sys.getenv("CS_HOME"),'/PatentsMining/Results/Semantic/Analysis/window5/sizes/all_raw_counts.pdf'),width=10,height=5)


# mean and median in time
g=ggplot(as.tbl(data.frame(size=sizes,year=years,type=type))%>%group_by(type,year)%>%summarise(meansize=mean(size),medsize=quantile(size,0.5)))
g+geom_point(aes(x=year,y=meansize,color=type))+geom_line(aes(x=year,y=meansize,color=type,group=type))



## kw sizes in time
sizes=c();years=c()
for(year in wyears){
  yearrange=paste0((year-windowSize+1),"-",year);show(year)
  currentkws = as.tbl(read.csv(paste0("classification/",classifdir,"/keywords_",yearrange,"_kwLimit",kwLimit,".0_dispth",dispth,"_ethunit",ethunit,".csv"),sep=";",header=TRUE,stringsAsFactors = FALSE))
  currentkws%>%group_by(community)%>%summarise(size=n())
  
  
  
}




#df=data.frame(size=sizes,nsize=nsizes,sortedsize=sortedsizes,sortednsize=sortednsizes,years=as.character(years),type=type)
#g=ggplot(df,aes(x=sizes,color=years))
#g+geom_density()+scale_x_log10()+facet_wrap(~type)
#
#g=ggplot(data.frame(size=sizes,nsize=nsizes,years=as.character(years),type=type)%>%group_by(years,type)%>%summarise(meansize=mean(size),meannsizes=mean(nsize)),
#         aes(x=years,y=meannsizes,color=type))
#g+geom_point()+geom_line()+stat_smooth()+scale_y_log10()+facet_wrap(~type)
#
#g=ggplot(df,aes(x=ranks,y=sortedsizes,colour=years,group=years))
#g+geom_point()+scale_x_log10()+scale_y_log10()+facet_wrap(~type)


## Classes concentrations
years=c();type=c();concentration=c()
for(year in wyears){
  load(paste0('probas/processed_counts_',(year-windowSize+1),"-",year,'.RData'));show(year)
  technoprobas=currentprobas$technoprobas;semprobas=currentprobas$semprobas;rm(currentprobas);gc()
  
  show(tail(setdiff(rownames(semprobas),rownames(technoMatrix))))
  #concentration=append(concentration,c(1-sum((colSums(semprobas)/nrow(semprobas))^2),1-sum((colSums(technoprobas)/nrow(technoprobas))^2)))
  #years=append(years,c(year,year));type=append(type,c("semantic","technological"))
}

df=data.frame(year=years,type=type,concentration=concentration)
g = ggplot(df[type=="semantic",],aes(x=year,y=concentration,colour=type,group=type))
g+geom_point()+geom_line() + theme(axis.title = element_text(size = 22), axis.text.x = element_text(size = 15),   axis.text.y = element_text(size = 15))



#############
## Overlaps
##
## (FIG. 7 and 8)
##



overlaps = c();years=c();measures=c();types=c();filters=c();nullovs=c();classnum=c();pcount=c();gc()
ovsize=c()
for(year in wyears){
  load(paste0('processed/',classifdir,'/processed_',(year-windowSize+1),"-",year,'.RData'));show(year)
  technoprobas=currentprobas$technoprobas;semprobas=currentprobas$semprobas;rm(currentprobas);gc()
  techov=t(technoprobas)%*%technoprobas;
  diag(techov)<-0
  semov=t(semprobas)%*%semprobas;
  diag(semov)<-0
  interov=t(technoprobas)%*%semprobas
  
  #nullovs=append(nullovs,length(which(techov==0)));nullovs=append(nullovs,length(which(semov==0)))
  #ovsize=append(ovsize,c(sum(techov),sum(semov)))
  #types=append(types,c("techno","semantic"));years=append(years,c(year,year))
  #classnum=append(classnum,ncol(techov));classnum=append(classnum,ncol(semov))
  #pcount=append(pcount,c(nrow(semprobas),nrow(semprobas)))
  
  # NON NORMALIZED
  #overlaps=append(overlaps,as.numeric(interov));n=length(as.numeric(interov));years=append(years,rep(year,n));types=append(types,rep("techno",n))#;measures=append(measures,rep("real",n));filters=append(filters,rep("all",n))
  #overlaps=append(overlaps,as.numeric(techov));n=length(as.numeric(techov));years=append(years,rep(year,n));types=append(types,rep("techno",n))#;measures=append(measures,rep("real",n));filters=append(filters,rep("all",n))
  #overlaps=append(overlaps,as.numeric(semov));n=length(as.numeric(semov));years=append(years,rep(year,n));types=append(types,rep("semantic",n))#;measures=append(measures,rep("real",n));filters=append(filters,rep("all",n))
  #inds=which(techov>0);overlaps=append(overlaps,techov[inds]);n=length(inds);years=append(years,rep(year,n));types=append(types,rep("techno",n))#;measures=append(measures,rep("real",n));filters=append(filters,rep("positive",n))
  #inds=which(semov>0);overlaps=append(overlaps,semov[inds]);n=length(inds);years=append(years,rep(year,n));types=append(types,rep("semantic",n))#;measures=append(measures,rep("real",n));filters=append(filters,rep("positive",n))
  # # NORMALIZED PATENT COUNT
  overlaps=append(overlaps,as.numeric(interov)/nrow(technoprobas));n=length(as.numeric(interov));years=append(years,rep(year,n));types=append(types,rep("inter-classifications",n));measures=append(measures,rep("norm-patents",n));#filters=append(filters,rep("all",n))
  overlaps=append(overlaps,as.numeric(techov)/nrow(technoprobas));n=length(as.numeric(techov));years=append(years,rep(year,n));types=append(types,rep("technological classification",n));measures=append(measures,rep("norm-patents",n));#filters=append(filters,rep("all",n))
  overlaps=append(overlaps,as.numeric(semov)/nrow(semprobas));n=length(as.numeric(semov));years=append(years,rep(year,n));types=append(types,rep("semantic classification",n));measures=append(measures,rep("norm-patents",n));#filters=append(filters,rep("all",n))
  #inds=which(techov>0);overlaps=append(overlaps,techov[inds]/nrow(technoprobas));n=length(inds);years=append(years,rep(year,n));types=append(types,rep("techno",n));#measures=append(measures,rep("norm-patents",n));filters=append(filters,rep("positive",n))
  #inds=which(semov>0);overlaps=append(overlaps,semov[inds]/nrow(semprobas));n=length(inds);years=append(years,rep(year,n));types=append(types,rep("semantic",n));#measures=append(measures,rep("norm-patents",n));filters=append(filters,rep("positive",n))
  # # RELATIVE OVERLAP
  technorm=Matrix(1,nrow(techov),ncol(techov))%*%Diagonal(x=colSums(technoprobas));
  semnorm=Matrix(1,nrow(semov),ncol(semov))%*%Diagonal(x=colSums(semprobas));
  internorm=2*(Diagonal(x=1/colSums(technoprobas))%*%Matrix(1,ncol(technoprobas),ncol(semprobas)))+(Matrix(1,ncol(technoprobas),ncol(semprobas))%*%Diagonal(x=1/colSums(semprobas)))
  interov=interov*internorm
  techov=techov*2/(technorm+t(technorm))
  semov=semov*2/(semnorm+t(semnorm))
  overlaps=append(overlaps,as.numeric(interov));n=length(as.numeric(interov));years=append(years,rep(year,n));types=append(types,rep("inter-classifications",n));measures=append(measures,rep("relative",n));#filters=append(filters,rep("all",n))
  overlaps=append(overlaps,as.numeric(techov));n=length(as.numeric(techov));years=append(years,rep(year,n));types=append(types,rep("technological classification",n));measures=append(measures,rep("relative",n));#filters=append(filters,rep("all",n))
  overlaps=append(overlaps,as.numeric(semov));n=length(as.numeric(semov));years=append(years,rep(year,n));types=append(types,rep("semantic classification",n));measures=append(measures,rep("relative",n));#filters=append(filters,rep("all",n))
  ##inds=which(techov>0);overlaps=append(overlaps,techov[inds]/nrow(technoprobas));n=length(inds);years=append(years,rep(year,n));types=append(types,rep("techno",n));#measures=append(measures,rep("relative",n));filters=append(filters,rep("positive",n))
  ##inds=which(semov>0);overlaps=append(overlaps,semov[inds]/nrow(semprobas));n=length(inds);years=append(years,rep(year,n));types=append(types,rep("semantic",n));#measures=append(measures,rep("relative",n));filters=append(filters,rep("positive",n))
  rm(techov,semov,technorm,semnorm,technoprobas,semprobas);gc()
}

resdir=paste0(Sys.getenv('CS_HOME'),'/PatentsMining/Results/Semantic/Analysis/window5/overlap/')
df=data.frame(overlap=overlaps,year=as.character(years),type=as.character(types),measure=measures)#,filter=filters)
rm(overlaps,years,types);gc()
#save(df,file="res/full-overlaps.RData")
#load("res/full-overlaps.RData")

plotsIntraOverlap <-function(measure,xlabel){
  g=ggplot(df[df$measure==measure&df$type!="inter-classifications",],aes(x=overlap,colour=year))
  g+geom_density(alpha=0.25)+xlab(xlabel)+ylab("density")+
    scale_x_log10()+facet_wrap(~type,scales="free_y")+
    theme(axis.title = element_text(size = 22), axis.text.x = element_text(size = 15),  axis.text.y = element_text(size = 15),
          strip.text = element_text(size=15),
          legend.text=element_text(size=15), legend.title=element_text(size=15))
  ggsave(file=paste0(Sys.getenv("CS_HOME"),'/PatentsMining/Results/Semantic/Analysis/window5/overlap/',measure,'_all_density_semcounts.pdf'),width=10,height=5)

  rm(g);gc()
  
  dsum = df[df$measure==measure&df$type!="inter-classifications",]%>% group_by(year,type) %>% summarise(meanoverlap=mean(overlap,na.rm=TRUE),mi=quantile(overlap,0.1,na.rm=TRUE),ma=quantile(overlap,0.9,na.rm=TRUE))
  gsum=ggplot(dsum,aes(x=year,y=meanoverlap,colour=type,group=type))
  labs=rep("",length(wyears));labs[seq(from=1,to=length(labs),by=5)]=as.character(wyears[seq(from=1,to=length(labs),by=5)])
  gsum+geom_point()+geom_line()+
    facet_wrap(~type,scales ="free_y")+
    scale_x_discrete(breaks=as.character(wyears),labels=labs)+ylab(paste0("mean ",xlabel))+
    theme(legend.position="none",axis.title = element_text(size = 22), axis.text.x = element_text(size = 15),  axis.text.y = element_text(size = 15), strip.text = element_text(size=15))
  ggsave(file=paste0(Sys.getenv("CS_HOME"),'/PatentsMining/Results/Semantic/Analysis/window5/overlap/',measure,'_all_ts_semcounts.pdf'),width=10,height=5)
  
}


plotsIntraOverlap("norm-patents","normalized overlap")
plotsIntraOverlap("relative","relative overlap")


#for(filter in c("all","positive")){
#  for(measure in c("real","norm-patents","relative")){
#   }
#}
# 
# labs=rep("",length(wyears));labs[seq(from=1,to=length(labs),by=3)]=as.character(wyears[seq(from=1,to=length(labs),by=3)])
# g=ggplot(data.frame(empty=ovsize/(pcount*(classnum*classnum/(classnum[1]*classnum[1]))),year=years,type=types,classes=classnum,pcount=pcount))
# g+geom_point(aes(x=year,y=empty,colour=type))+geom_line(aes(x=year,y=empty,colour=type))+ facet_wrap(~type,scales ="free_y")+
#   geom_line(aes(x=year,y=(pcount - min(pcount))/(max(pcount)-min(pcount))),color='purple',linetype=2)
#   #scale_x_discrete(breaks=as.character(wyears),labels=labs)
# g+geom_point(aes(x=pcount,y=empty,colour=year,shape=type))+ facet_wrap(~type,scales ="free")
#     
# # Techno
# inds=1:length(technoverlaps)#
# #overlaps[overlaps==0]=1e-10
# # distribution of overlaps 
# g=ggplot(data.frame(overlap=technoverlaps[inds],year=as.character(techyears[inds])),aes(x=overlap,colour=year))#aes(x=year,y=overlap))
# g+geom_density(alpha=0.25)+scale_x_log10()+xlab("techno overlap normalized by patent count")+ylab("density")#+scale_y_log10()
# # variation in time
# g=ggplot(data.frame(overlap=technoverlaps[inds],year=techyears[inds]),aes(x=year,y=overlap))
# g+geom_point(pch='.')+scale_y_log10()+stat_smooth()
# 
# # Semantic
# inds=semoverlaps>0
# # distribution of overlaps 
# g=ggplot(data.frame(overlap=semoverlaps[inds],year=semyears[inds]),aes(x=overlap,colour=as.character(year)))#aes(x=year,y=overlap))
# g+geom_density(alpha=0.25)+scale_x_log10()+xlab("sem overlap")+ylab("density")#+scale_y_log10()
# # variation in time
# g=ggplot(data.frame(overlap=semoverlaps[inds],year=semyears[inds]),aes(x=year,y=overlap))
# g+geom_point(pch='.')+scale_y_log10()+stat_smooth()
# 



plotsInterOverlap <-function(measure,xlabel){
  g=ggplot(df[df$measure==measure&df$type=="inter-classifications",],aes(x=overlap,colour=year))
  g+geom_density(alpha=0.25)+xlab(xlabel)+ylab("density")+scale_x_log10()+
    theme(axis.title = element_text(size = 22), axis.text.x = element_text(size = 15),  axis.text.y = element_text(size = 15),legend.text=element_text(size=15), legend.title=element_text(size=15))
  ggsave(file=paste0(Sys.getenv("CS_HOME"),'/PatentsMining/Results/Semantic/Analysis/window5/overlap/',measure,'_interclassif_all_density_semcounts.pdf'),width=10,height=5)
  
  rm(g);gc()
  
  dsum = df[df$measure==measure&df$type=="inter-classifications",]%>% group_by(year,type) %>% summarise(meanoverlap=mean(overlap,na.rm=TRUE),mi=quantile(overlap,0.1,na.rm=TRUE),ma=quantile(overlap,0.9,na.rm=TRUE))
  gsum=ggplot(dsum,aes(x=year,y=meanoverlap,group=type))
  labs=rep("",length(wyears));labs[seq(from=1,to=length(labs),by=5)]=as.character(wyears[seq(from=1,to=length(labs),by=5)])
  gsum+geom_point()+geom_line()+
    scale_x_discrete(breaks=as.character(wyears),labels=labs)+ylab(paste0("mean ",xlabel))+
    theme(axis.title = element_text(size = 22), axis.text.x = element_text(size = 15),  axis.text.y = element_text(size = 15))
  ggsave(file=paste0(Sys.getenv("CS_HOME"),'/PatentsMining/Results/Semantic/Analysis/window5/overlap/',measure,'_interclassif_all_ts_semcounts.pdf'),width=10,height=5)
  
}

plotsInterOverlap("norm-patents","normalized overlap")
plotsInterOverlap("relative","relative overlap")





##################
# 1.2) Micro-level : patent level interdisciplinarity
#
#  FIG. 5

origs=c();cyears=c();types=c();
for(year in wyears){
  show(year)
  #load(paste0('probas_processed/processed_',year,'.RData'))
  load(paste0('processed/',classifdir,'/processed_',(year-windowSize+1),"-",year,'.RData'))
  technoprobas=currentprobas$technoprobas;semprobas=currentprobas$semprobas;rm(currentprobas);gc()
  origs = append(origs,1 - rowSums(semprobas^2));types=append(types,rep("semantic classification",nrow(semprobas)))
  origs = append(origs,1 - rowSums(technoprobas^2));types=append(types,rep("technological classification",nrow(technoprobas)))
  cyears=append(cyears,rep(year,nrow(semprobas)+nrow(technoprobas)))
  rm(semprobas,technoprobas);gc()
}

#save(origs,cyears,types,file='res/patentlevel_orig.RData')
#load('res/patentlevel_orig.RData')

show(paste0('Unclassified : ',length(which(origs<1))/length(origs)))
# 5.2 % of patent in total are not classified : quite ok

# techno patent origs

inds=origs<1
df = data.frame(originality=origs[inds],year=as.character(cyears[inds]),type=types[inds])
rm(origs,cyears,types);gc()

#save(df,file='figdata/fig5.RData')
#load('figdata/fig5.RData)

g=ggplot(df)
g+geom_density(aes(x=originality,colour=year))+facet_wrap(~type) + 
  xlab("patent diversity")+#scale_y_log10()+
  theme(axis.title = element_text(size = 22), axis.text.x = element_text(size = 15),  axis.text.y = element_text(size = 15),
        strip.text = element_text(size=15),
        legend.text=element_text(size=15), legend.title=element_text(size=15))
ggsave(file=paste0(Sys.getenv("CS_HOME"),'/PatentsMining/Results/Semantic/Analysis/window5/diversity/patentlevelorigs_all_semcounts.pdf'),width=10,height=5)
rm(g);gc()

g=ggplot(df[df$originality>0,])
g+geom_density(aes(x=originality,colour=year))+facet_wrap(~type) + 
  xlab("patent diversity")+#scale_y_log10()+
  theme(axis.title = element_text(size = 22), axis.text.x = element_text(size = 15),  axis.text.y = element_text(size = 15),
        strip.text = element_text(size=15),
        legend.text=element_text(size=15), legend.title=element_text(size=15))
ggsave(file=paste0(Sys.getenv("CS_HOME"),'/PatentsMining/Results/Semantic/Analysis/window5/diversity/patentlevelorigs_positive_semcounts.pdf'),width=10,height=5)
rm(g);gc()

# time series by year

byyearorigs = as.tbl(df) %>% group_by(year,type) %>% summarize(meanorig=mean(originality),count=n())
gsum=ggplot(byyearorigs,aes(x=year,y=meanorig,colour=type,group=type))
labs=rep("",length(wyears));labs[seq(from=1,to=length(labs),by=5)]=as.character(wyears[seq(from=1,to=length(labs),by=5)])
gsum+geom_point()+geom_line()+facet_wrap(~type,scales ="free_y")+
  scale_x_discrete(breaks=as.character(wyears),labels=labs)+
  xlab("year")+ylab("mean patent diversity") +
  theme(legend.position = "none",axis.title = element_text(size = 22), axis.text.x = element_text(size = 15),  axis.text.y = element_text(size = 15),strip.text = element_text(size=15))
ggsave(file=paste0(Sys.getenv("CS_HOME"),'/PatentsMining/Results/Semantic/Analysis/window5/diversity/patentlevelorigs_all_ts_semcounts.pdf'),width=10,height=5)


byyearorigs = as.tbl(df[df$originality>0,]) %>% group_by(year,type) %>% summarize(meanorig=mean(originality),count=n())
gsum=ggplot(byyearorigs,aes(x=year,y=meanorig,colour=type,group=type))
labs=rep("",length(wyears));labs[seq(from=1,to=length(labs),by=5)]=as.character(wyears[seq(from=1,to=length(labs),by=5)])
gsum+geom_point()+geom_line()+facet_wrap(~type,scales ="free_y")+
  scale_x_discrete(breaks=as.character(wyears),labels=labs)+
  xlab("year")+ylab("mean patent diversity") +
  theme(legend.position = "none",axis.title = element_text(size = 22), axis.text.x = element_text(size = 15),  axis.text.y = element_text(size = 15),strip.text = element_text(size=15))
ggsave(file=paste0(Sys.getenv("CS_HOME"),'/PatentsMining/Results/Semantic/Analysis/window5/diversity/patentlevelorigs_positive_ts_semcounts.pdf'),width=10,height=5)




##
#  2) Layers macro-structure comparison
#
#  -> done in overlaps





##
#  3) Second order interdisciplinarity (citation)

# preprocess adjacency matrices -> semanalfun.R


# 3.1) Patent level

#origs=c();cyears=c();types=c();
sizes=c();fromwindow=c();cyears=c()
for(year in wyears){
  load(paste0('probas/processed_counts_prim_',(year-windowSize+1),"-",year,'.RData'));load(paste0('probas/citadj_',(year-windowSize+1),"-",year,'.RData'));show(year)
  technoprobas=currentprobas$technoprobas;semprobas=currentprobas$semprobas;primtechnoprobas=currentprobas$primarytechnoprobas;rm(currentprobas);gc()
  #currentadj = Diagonal(x=1/rowSums(currentadj))%*%currentadj
  technocit = t(technoprobas)%*%(Diagonal(x=1/rowSums(currentadj))%*%currentadj)%*%technoprobas
  technorm=Matrix(1,nrow(technocit),ncol(technocit))%*%Diagonal(x=colSums(technoprobas));
  technocit=technocit*2/(technorm+t(technorm))
  #semcit = currentadj%*%semprobas[currentnames,]
  #origs = append(origs,1 - rowSums(technocit^2));types=append(types,rep("techno",nrow(technocit)))
  #origs = append(origs,1 - rowSums(semcit^2));types=append(types,rep("semantic",nrow(semcit)))
  #cyears=append(cyears,rep(year,nrow(technocit)+nrow(semcit)))
  rm(technoprobas,semprobas,currentadj,currentnames);gc()
}

# test
rownames(technocit)<-1:nrow(technocit);colnames(technocit)<-1:ncol(technocit)
df = melt(as.matrix(technocit));colnames(df)<-c("t1","t2",'citcount')
#g=ggplot(df)
#g+geom_raster(aes(x=t1,y=t2,fill=citcount))

sizes=log(1+colSums(technoprobas));centers=cumsum(sizes)-sizes/2
df=cbind(df,sizes[df$t1],sizes[df$t2],centers[df$t1],centers[df$t2]);
names(df)<-c("t1","t2",'citcount','w','h','x','y')
g=ggplot(df)
g+geom_tile(aes(x=x,y=y,width=w,height=h,fill=citcount))




g=ggplot(data.frame(inblockcitation=sizes,year=cyears),aes(x=year,y=inblockcitation))
g+geom_point()+geom_line()#+scale_y_log10()


#
g=ggplot(data.frame(originality=origs[types=="techno"],year=as.character(cyears[types=="techno"])))
g+geom_density(aes(x=originality,colour=year))#+facet_wrap(~type)


g=ggplot(data.frame(originality=origs[types=="semantic"],year=as.character(cyears[types=="semantic"])))
g+geom_density(aes(x=originality,colour=year))


# 3.2) class level

origs=c();cyears=c();types=c();
for(year in years){
  load(paste0('probas/processed_counts_prim_',(year-windowSize+1),"-",year,'.RData'));show(year)
  technoprobas=currentprobas$technoprobas;semprobas=currentprobas$semprobas;rm(currentprobas);gc()
  currentnames=intersect(rownames(technoprobas),rownames(citadjacency))
  currentadj = citadjacency[currentnames,currentnames]
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



################
#  3.3)  Citation graph modularities

load('res/modularities.RData')

df = data.frame(year=sapply(modularities,function(l){l$year}),
                technoovmod=sapply(modularities,function(l){l$technoovmod}),
                semovmod=sapply(modularities,function(l){l$semovmod}),
                technodirmod=sapply(modularities,function(l){l$technodirmod}),
                semdirmod=sapply(modularities,function(l){l$semdirmod}),
                technodirgraphmod=sapply(modularities,function(l){l$technodirgraphmod}),
                semdirgraphmod=sapply(modularities,function(l){l$semdirgraphmod}),
                technoundirgraphmod=sapply(modularities,function(l){l$technoundirgraphmod}),
                semundirgraphmod=sapply(modularities,function(l){l$semundirgraphmod})
                )

g=ggplot(data.frame(year=c(df$year,df$year),mod = c(df$technoovmod,df$semovmod),type=c(rep("technological",nrow(df)),rep("semantic",nrow(df)))),aes(x=year,y=mod,colour=type,group=type))
g+geom_line()+geom_point()+ylab("overlapping modularity")+#scale_y_log10()+
  theme(axis.title = element_text(size = 22), axis.text.x = element_text(size = 15),  axis.text.y = element_text(size = 15),legend.text=element_text(size=15), legend.title=element_text(size=15))
ggsave(file=paste0(Sys.getenv("CS_HOME"),'/PatentsMining/Results/Semantic/Analysis/window5/citation/overlappingmodularity.pdf'),width=10,height=5)



g=ggplot(data.frame(year=c(df$year,df$year),mod = c(df$technodirmod,df$semdirmod),type=c(rep("technological",nrow(df)),rep("semantic",nrow(df)))),aes(x=year,y=mod,colour=type,group=type))
g+geom_line()+geom_point()+ylab("modularity")+#scale_y_log10()+
  theme(axis.title = element_text(size = 22), axis.text.x = element_text(size = 15),  axis.text.y = element_text(size = 15),legend.text=element_text(size=15), legend.title=element_text(size=15))
ggsave(file=paste0(Sys.getenv("CS_HOME"),'/PatentsMining/Results/Semantic/Analysis/window5/citation/simplemodularity.pdf'),width=10,height=5)



##

g+geom_line(aes(x=year,y=technoovmod,colour="techno"))+geom_line(aes(x=year,y=semovmod,colour="semantic"))+scale_y_log10()
g+geom_line(aes(x=year,y=technodirmod,colour="techno"))+geom_line(aes(x=year,y=semdirmod,colour="semantic"))
g+geom_line(aes(x=year,y=technodirgraphmod))
g+geom_line(aes(x=year,y=semdirgraphmod))



##############
## Originalities and Generalities

origgens = read.csv('data/origgen.csv',sep=";")



g=ggplot(data.frame(year=c(origgens$year,origgens$year),originality=c(origgens$orig.tech,origgens$orig.sem),type=c(rep("technological",nrow(origgens)),rep("semantic",nrow(origgens)))),aes(x=year,y=originality,group=type,colour=type))
g+geom_line(na.rm=TRUE)+geom_point(na.rm=TRUE)+
  theme(axis.title = element_text(size = 22), axis.text.x = element_text(size = 15),  axis.text.y = element_text(size = 15),legend.text=element_text(size=15), legend.title=element_text(size=15))
ggsave(file=paste0(Sys.getenv("CS_HOME"),'/PatentsMining/Results/Semantic/Analysis/window5/originality/originality.pdf'),width=10,height=5)


g=ggplot(data.frame(year=c(origgens$year,origgens$year),generality=c(origgens$gen.tech,origgens$gen.sem),type=c(rep("technological",nrow(origgens)),rep("semantic",nrow(origgens)))),aes(x=year,y=generality,group=type,colour=type))
g+geom_line(na.rm=TRUE)+geom_point(na.rm=TRUE)+
  theme(axis.title = element_text(size = 22), axis.text.x = element_text(size = 15),  axis.text.y = element_text(size = 15),legend.text=element_text(size=15), legend.title=element_text(size=15))
ggsave(file=paste0(Sys.getenv("CS_HOME"),'/PatentsMining/Results/Semantic/Analysis/window5/generality/generality.pdf'),width=10,height=5)








##################
##################

pca = prcomp(semprobas)

## BigPCA ;; NCmisc libraries







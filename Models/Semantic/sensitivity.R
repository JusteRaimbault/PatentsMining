library(ggplot2)
library(dplyr)


setwd(paste0(Sys.getenv('CS_HOME'),'/PatentsMining/Models/Semantic'))

# analysis of network modularities/size to parameters

#wyears = 1980:2007
wyears = 1978:2007
windowSize=3;windowStr="3"
kwLimit="100000.0"
eth="10.0"

yearlycount=read.csv(file=paste0('data/patentcount_window',windowStr,'.csv'),sep=";",header=TRUE,stringsAsFactors = FALSE)

ethunit=4.1e-5
# -> mean argmax on all dispth ; lay on pareto front (comnum,vcount) (or very near) for each year

argmax=c()
alldata=data.frame()
projval=c();projtype=c();projdisp=c();projyear=c()
for(year in wyears){
#year=1980
  show(year)
yearrange = paste0((year-windowSize+1),"-",year)
npatents=yearlycount[yearlycount$yearrange==yearrange,2]
sensdata = as.tbl(read.csv(file=paste0('sensitivity/sensitivity_',yearrange,"_",kwLimit,"_eth",eth,".csv"),sep=";",header=TRUE))
#sensdata=sensdata[sensdata$eth<60,]
sensdata = sensdata %>% group_by(dispth,eth) %>% summarise(modularity=max(modularity),comnum=min(comnum),vcount=mean(vcount))
argmaxs=sensdata%>% group_by(dispth)%>%summarise(argmaxeth=eth[comnum==max(comnum)][1])
argmax=append(argmax,mean(argmaxs$argmaxeth)/npatents)

ethunitdist = log(1+abs((ethunit*npatents) - sensdata$eth))

alldata=rbind(alldata,cbind(sensdata,
                            year=rep(as.character(year),nrow(sensdata)),
                            dist=abs(sensdata$eth-mean(argmaxs$argmaxeth)),
                            ethunitdist=ethunitdist
                            )
              
              )

projrows = which(ethunitdist==min(ethunitdist))
projval=append(projval,c(sensdata$comnum[projrows]/max(sensdata$comnum[projrows]),sensdata$vcount[projrows]/max(sensdata$vcount[projrows]),sensdata$modularity[projrows]/max(sensdata$modularity[projrows])))
projtype=append(projtype,c(rep("number of communities",length(projrows)),rep("number of vertices",length(projrows)),rep("modularity",length(projrows))))
projdisp=append(projdisp,rep(sensdata$dispth[projrows],3))
projyear=append(projyear,rep(as.character(year),3*length(projrows)))

}

#mean(argmax)
#plot(wyears,argmax,type='l')


# for each year, plot triobjective, highlight chosen points

# 
g=ggplot(sensdata %>% group_by(dispth,eth) %>% summarise(maxmod=max(modularity),comnum=min(comnum),vcount=mean(vcount)))
g+geom_line(aes(x=eth,y=comnum,colour=dispth,group=dispth))
# g+geom_point(aes(x=maxmod,y=vcount,colour=dispth))
# g+geom_point(aes(x=vcount,y=maxmod,colour=dispth))
# g+geom_point(aes(x=vcount,y=comnum,colour=dispth))


##
# 

# all years, comnum = f(theta_w)

g=ggplot(alldata %>% group_by(dispth,eth,year) %>% summarise(maxmod=max(modularity),comnum=min(comnum),vcount=mean(vcount)))
g+geom_line(aes(x=eth,y=comnum,colour=dispth,group=dispth))+facet_wrap(~year)+
    xlab(expression(theta[w]))+ylab("number of communities")+scale_colour_continuous(name=expression(theta[c]))

# all years
g+geom_point(aes(x=comnum,y=vcount,colour=maxmod),size=1)+facet_wrap(~year)+
  xlab("number of communities")+ylab("number of vertices")+scale_colour_continuous(name="modularity")
ggsave(file=paste0(Sys.getenv("CS_HOME"),'/PatentsMining/Results/Semantic/Sensitivity/window',windowStr,'/vcount_comnum_pareto_window',windowStr,'.pdf'),width=10,height=7)



###
## for 2004, argmax = 4.13e-5
year=2004

# plot comnum = f(theta_w)

argmaxs=alldata[alldata$year==year,]%>% group_by(dispth)%>%summarise(argmaxeth=eth[comnum==max(comnum)][1])
g=ggplot(alldata[alldata$year==year,] %>% group_by(dispth,eth) %>% summarise(maxmod=max(modularity),comnum=min(comnum),vcount=mean(vcount)))
g+geom_line(aes(x=eth,y=comnum,colour=dispth,group=dispth))+
  geom_vline(xintercept=mean(argmaxs$argmaxeth),color='red',linetype=2)+
  xlab(expression(theta[w]))+ylab("number of communities")+scale_colour_continuous(name=expression(theta[c]))+ theme(axis.title = element_text(size = 22),legend.title = element_text(size = 22), axis.text.x = element_text(size = 15),   axis.text.y = element_text(size = 15))

ggsave(file=paste0(Sys.getenv("CS_HOME"),'/PatentsMining/Results/Semantic/Sensitivity/window',windowStr,'/comnum_thetaw_',year,'.pdf'),width=10,height=7)


# pareto plot
# mean(argmaxs$argmaxeth) -> theta_w = 40 this year
currentdata=alldata[alldata$year==year,] %>% group_by(dispth,eth) %>% summarise(maxmod=max(modularity),comnum=min(comnum),vcount=mean(vcount))
g=ggplot(currentdata)
g+geom_point(aes(x=comnum,y=vcount,colour=maxmod),size=1)+
  geom_point(mapping=aes(x=comnum,y=vcount),data = currentdata[currentdata$eth==40,],colour='purple',size=2,pch=1)+
  geom_point(mapping=aes(x=comnum,y=vcount),data = currentdata[currentdata$eth==40&currentdata$dispth==0.06,],colour='red',size=4,pch=22)+
  xlab("number of communities")+ylab("number of vertices")+scale_colour_continuous(name="modularity")+ theme(axis.title = element_text(size = 22), axis.text.x = element_text(size = 15),   axis.text.y = element_text(size = 15))


ggsave(file=paste0(Sys.getenv("CS_HOME"),'/PatentsMining/Results/Semantic/Sensitivity/window',windowStr,'/comnum_vcount_pareto_',year,'.pdf'),width=10,height=7)





g=ggplot(alldata)
g+geom_point(aes(x=comnum,y=vcount,colour=ethunitdist))+facet_wrap(~year)

g=ggplot(alldata)
g+geom_point(aes(x=modularity,y=vcount,colour=ethunitdist))+facet_wrap(~year)


g=ggplot(cbind(alldata,col=as.character(alldata$dispth==0.06)))
g+geom_point(aes(x=comnum,y=vcount,colour=col))+facet_wrap(~year)


g=ggplot(data.frame(dispth=projdisp,val=projval,objective=projtype,year=projyear))
g+geom_line(aes(x=dispth,y=val,col=objective,group=objective))+facet_wrap(~year)+
    xlab(expression(theta[c]))+ylab("normalized objectives")#+ theme(axis.title = element_text(size = 22), axis.text.x = element_text(size = 15),   axis.text.y = element_text(size = 15))


# -> 0.06 as dispth fits all years, in particular first ones where 0.05 is not enough ; and better than 0.07 in terms of vertices number


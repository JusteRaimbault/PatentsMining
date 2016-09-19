
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

rowinds = cumsum(c(1,as.integer(technolist$Patent[1:(nrow(technolist)-1)]!=technolist$Patent[2:nrow(technolist)])))
#data.frame(unique(rowinds),unique(technolist$Patent))
allclasses = unique(as.character(technolist$Class))
colinds = sapply(technolist$Class,function(s){which(allclasses==s)})

technoMatrix = sparseMatrix(i = rowinds,j=colinds,x=rep(1,length(rowinds)))
rownames(technoMatrix)<-as.character(unique(technolist$Patent))
colnames(technoMatrix)<-allclasses

save(technoMatrix,file=paste0(Sys.getenv('CS_HOME'),'/PatentsMining/Data/processed/classes/sparse.RData'))
